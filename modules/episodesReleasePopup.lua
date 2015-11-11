
--Variables
local seriesData
local seriesInfo
local scrollViewCreator = require("modules.buttonScrollView")
local scrollViewSeasons, scrollViewEpisodes
local posterImageSize = {width = 100, height = 150}
local directory = system.DocumentsDirectory
local oldHandlers

local reloadTitles = false
local reloadSeasons = false

-- Functions
local loadView
local loadSeasons, loadEpisodes

return function(parent, data)
	oldHandlers = _G.tenfLib.tableCopy(_G.keyEventHandlers, true)
	seriesInfo = data
	local group = _G.newGroup(parent)
	group.x, group.y = _G._w, _G._h

	local indicatorText = "Hämtar episodinformation" .. (seriesInfo.Title and "om:\n\"" .. seriesInfo.Title .."\"" or ".")
	native.setActivityIndicator(true, indicatorText)

	if _G.seriesExists(seriesInfo.imdbID) then
		timer.performWithDelay(0, function()
			native.setActivityIndicator(false)
			seriesData = _G.loadSeries(seriesInfo.imdbID)
			loadView()
		end)
	else
		local titleDone = false
		local seriesDone = false
		local function onCompleteHandler()
			if titleDone and seriesDone then
				native.setActivityIndicator(false)
				reloadTitles = true
				loadView()
			end
		end
		_G.downloadTitle(data.imdbID, directory, function(e)
			if e.isError then
				print( "Network error!")
				_G.errorAlert(e, function()
					group:close()
				end)
			else
				_G.addTitle(e.data)
				display.remove(e.posterImage)

				titleDone = true
				onCompleteHandler()
			end
		end)

		require("modules.imdbEpisodeParser")(seriesInfo, function(e)
			if e.isError then
				print("Network error")
				_G.errorAlert(e, function()
					group:close()
				end)
			else
				seriesData = e.data
				_G.addSeries(seriesData)
				
				seriesDone = true
				onCompleteHandler()
			end
		end)
	end

	function group:close(extraData)
		_G.setKeyEventHandlers(oldHandlers)

		extraData = extraData or {}
		local beforeClosedEvent = _G.tenfLib.tableCopy(extraData, true)
		beforeClosedEvent.name = "beforeClosed"
		beforeClosedEvent.target = self

		local closedEvent = _G.tenfLib.tableCopy(extraData, true)
		closedEvent.name = "closed"
		closedEvent.target = self

		self:dispatchEvent(beforeClosedEvent)
		transition.to(self, {time = 500, xScale = 0.001, yScale = 0.001, alpha = 0, transition = easing.outExpo, onComplete = function()
			self:dispatchEvent(closedEvent)
			display.remove(self)
		end})
	end

	function loadView()

		for i = 1, group.numChildren do
			display.remove(group[i])
		end

		transition.from(group, {time = 500, xScale = 0.001, yScale = 0.001, alpha = 0, transition = easing.outExpo})


		local clickableBackground = display.newRect(group, 0, 0, _G._W, _G._H)
		clickableBackground:setFillColor(0, _G.blackoutAlpha)
		clickableBackground:addEventListener("touch", function(e)
			if e.phase == "ended" then
				timer.performWithDelay(0, function()
					group:close({reloadTitles = reloadTitles})
				end)
			end
			return true
		end)


		local bg = display.newRoundedRect(group, 0, 0, _G._W - 40, _G._H - 40, 10)
		bg:setFillColor(0.7)


		-- Lägger till bild och titel
			local fileName = seriesInfo.imdbID .. ".jpg"
			local posterImage
			if _G.tenfLib.fileExists(fileName, directory) then
				local tmp = display.newImage(fileName, directory)
				local w, h = tmp.width, tmp.height
				display.remove(tmp)

				posterImage = display.newImageRect(fileName, directory, w, h)
			else
				posterImage = _G.newImage("images/noImage.png")
			end

			-- Kod för att förstora bilden

				local coverBG = display.newRect(group, 0, 0, _G._W, _G._H)
				coverBG.alpha = 0

				local zoomed = false
				local pictureLetThrough = true
				posterImage:addEventListener("touch", function(e)
					if e.phase == "ended" then
						if not zoomed then

							_G.tenfLib.removeEventListeners(coverBG, "touch")

							coverBG:addEventListener("touch", function(ee)
								display.currentStage:setFocus(ee.target)
								if ee.phase == "ended" then
									local scale = e.target.orgScale
									local x, y = e.target.orgPos.x, e.target.orgPos.y
									transition.to(e.target, {time = 500, anchorX = 0, anchorY = 0, x = x, y = y, xScale = scale, yScale = scale, transition = easing.inOutQuad})
									transition.to(coverBG, {time = 500, alpha = 0, transition = easing.inOutQuad, onComplete = function()
										if scrollViewEpisodes then
											scrollViewEpisodes:setEnabled(true)
										else
											scrollViewSeasons:setEnabled(true)
										end
									end})
									zoomed = false
									display.currentStage:setFocus(nil)
								end
								return true
							end)

							coverBG:setFillColor(0)
							coverBG.alpha = 0
							e.target:toFront()

							local scale = (_G._W - 10) / (e.target.width)
							local x, y = 0, 0
							transition.to(e.target, {time = 500, anchorX = 0.5, anchorY = 0.5, x = x, y = y, xScale = scale, yScale = scale, transition = easing.inOutQuad})
							transition.to(coverBG, {time = 500, alpha = _G.blackoutAlpha, transition = easing.inOutQuad})
							zoomed = true
							if scrollViewEpisodes then
								scrollViewEpisodes:setEnabled(false)
							else
								scrollViewSeasons:setEnabled(false)
							end
							display.currentStage:setFocus(coverBG)
						end
					end
					return true
				end)
			---
			group:insert(posterImage)
			_G.tenfLib.fitObjectInArea(posterImage, posterImageSize.width, posterImageSize.height)
			posterImage.anchorX, posterImage.anchorY = 0, 0
			posterImage.x, posterImage.y = -bg.width / 2 + 10, -bg.height / 2 + 10

			posterImage.orgPos = {x = posterImage.x, y = posterImage.y}
			posterImage.orgScale = posterImage.xScale


			local xMin = posterImage.x + posterImageSize.width + 5
			local xMax = bg.width / 2 - 5
			local width = (xMax - xMin)

			local settings = 
			{
				width = width,
				height = 25,
			}
			local buttonGrid = require("modules.buttonGrid")(group, settings)
			

			local btnRemove = buttonGrid:createButton("Ta bort serie", 0, 0, function(e)
				_G.removeTitle(seriesInfo.imdbID)
				_G.removeSeries(seriesInfo.imdbID)
				group:close({reloadTitles = true})
			end)
			btnRemove.x, btnRemove.y = xMin + width / 2, -bg.height / 2 + btnRemove.height / 2 + 10

			
			local isHidden = _G.getHidden(seriesInfo.imdbID)
			local btnHide = buttonGrid:createButton(isHidden and "Visa serie" or "Dölj serie", 0, 0, function(e)
				_G.setHidden(seriesInfo.imdbID, not isHidden)
				group:close({reloadTitles = true})
			end)
			btnHide.x, btnHide.y = btnRemove.x, btnRemove.y + btnRemove.height + 5

			

			local y = btnHide.y + btnHide.height
			local height = posterImage.y + posterImageSize.height - y

			local options = 
			{
				parent = group,
				text = seriesInfo.Title or "<Ingen titel hittad>",
				x = xMin + width / 2,
				y = y,
				width = width,     --required for multi-line and alignment
				height = height,
				font = _G.fontNameBold,   
				fontSize = _G.fontSizeNormal,
				align = "center"  --new alignment parameter
			}

			local title = display.newText(options)
			title.anchorY = 0
			title:setFillColor(0)

		---

		local yMin = posterImage.y + posterImageSize.height + 5
		local _, y = posterImage:localToContent(0, posterImageSize.height + 5)
		local settingsSeasons =
		{
			margin = {top = yMin, bottom = y + 30},
			width = bg.width - 20
		}

		local function checkBoxHandlerSeasons(e)
			
			local function handleStates(doWork, type)
				local seasonIndex = e.index
				local seasonNr = seriesData.seasons[e.index].seasonNr
				if doWork then
					if type == "add" then
						_G.addSeenState(seriesInfo.imdbID, seasonIndex)
					elseif type == "remove" then
						_G.removeSeenState(seriesInfo.imdbID, seasonIndex)
					end
					reloadTitles = true
					loadSeasons()
				else
					local state, seenCount = _G.loadSeenState(seriesInfo.imdbID, seasonIndex)
					if state == "all" then
						e.target:setChecked(true)
					elseif state == "some" then
						e.target:setCheckedAlt(true)
					elseif state == "allReleased" then
						if seenCount.seen > 0 then
							e.target:setCheckedAlt(true)
						else
							e.target:setCheckedAlt(false)
						end
					else
						e.target:setChecked(false)
					end
				end
			end

			if e.checked then
				native.showAlert("Varning", "Vill du bocka i hela säsongen som sedd?", {"Ja", "Nej"}, function(alertEvent)
					if alertEvent.action == "clicked" then
						if alertEvent.index == 1 then
							handleStates(true, "add")
						else
							handleStates(false)
						end
					end
				end)
			else
				native.showAlert("Varning", "Vill du avbocka hela säsongen som sedd?", {"Ja", "Nej"}, function(alertEvent)
					if alertEvent.action == "clicked" then
						if alertEvent.index == 1 then
							handleStates(true, "remove")
						else
							handleStates(false)
						end
					end
				end)
			end
		end

		scrollViewSeasons = scrollViewCreator(group, settingsSeasons, function(e)
			if e.data.ignore then return end

			local seasonNr = e.data.seasonNr
			local seasonIndex = e.index

			local currentSeason = seriesData.seasons[seasonIndex]

			scrollViewSeasons.isVisible = false

			local btnBack

			local function moveBackToSeasons()
				if reloadSeasons then
					loadSeasons()
				end
				timer.performWithDelay(0, function()
					scrollViewSeasons.tapped = false
				end)
				scrollViewSeasons.isVisible = true

				display.remove(scrollViewEpisodes)
				scrollViewEpisodes = nil
				display.remove(btnBack)
				btnBack = nil
				_G.setKeyEventHandlers(oldHandlers)

				reloadSeasons = false
				return true
			end

			_G.setKeyEventHandlers(
				{
					back = moveBackToSeasons
				}
			)

			local settingsEpisodes = _G.tenfLib.tableCopy(settingsSeasons, true)
			settingsEpisodes.align = "left"
			settingsEpisodes.margin.top = settingsEpisodes.margin.top + 30

			local settings = 
			{
				width = settingsEpisodes.width,
				height = buttonGrid.height,
			}
			local buttonGrid = require("modules.buttonGrid")(group, settings)
			btnBack = buttonGrid:createButton("Tillbaka", 0, 0, moveBackToSeasons)

			btnBack.x, btnBack.y = 0, settingsEpisodes.margin.top - btnBack.height / 2 - 5

			local function checkBoxHandlerEpisodes(e)
				reloadTitles = true
				reloadSeasons = true

				local episodeNr = currentSeason.episodes[e.index].episodeNr
				local episodeIndex = e.index

				if episodeIndex then
					if e.checked then
						_G.addSeenState(seriesInfo.imdbID, seasonIndex, episodeIndex)
					else
						_G.removeSeenState(seriesInfo.imdbID, seasonIndex, episodeIndex)
					end
				end
				loadEpisodes()
			end
			if scrollViewEpisodes then display.remove(scrollViewEpisodes); scrollViewEpisodes = nil end
			scrollViewEpisodes = scrollViewCreator(group, settingsEpisodes, function(e)
				if e.data.ignore then return end

				local text = ""
				--for k,v in pairs(e.data) do
				--	text = text .. k .. ":\t" .. _G.tenfLib.shortenText(type(v) == "table" and _G.getDateString(v) or v, 200, "...") .. "\n"
				--end
				text = "Release:\t" .. _G.getDateString(e.data['airdate'])
				text = text .. "\n" .. "Name:\t\t" .. e.data['name']
				text = text .. "\n\n" .. "Desc:\t\t" .. _G.tenfLib.shortenText(e.data['description'], 200, "...")

				native.showAlert("Info", text, {"Ok"}, function()
					scrollViewEpisodes.tapped = false
				end)

			end, checkBoxHandlerEpisodes)
			scrollViewEpisodes.x = 0

			function loadEpisodes()
				local previousScrollY = nil
				if scrollViewEpisodes:getNumRows() > 0 then
					previousScrollY = scrollViewEpisodes:getContentPosition()
					scrollViewEpisodes:deleteRows()
				end

				if #currentSeason.episodes > 0 then
					for episodeIndex, episodeData in ipairs(currentSeason.episodes) do
						local episodeNr = episodeData.episodeNr
						local seen, seenCount = _G.loadSeenState(seriesInfo.imdbID, seasonIndex, episodeIndex)
						local viewData = 
						{
							seen = seen,
							seenCount = seenCount,
						}

						local title = _G.tenfLib.shortenText(episodeData.name, 20, "...")
						local text = _G.getEpisodeString(seasonNr, episodeNr) .. " ( " .. title .." )"
						scrollViewEpisodes:append(text, episodeData, viewData)
					end
				else
					scrollViewEpisodes:append("Finns inga avsnitt", {ignore=true})
				end
				if previousScrollY then
					scrollViewEpisodes:scrollToY({ y=previousScrollY, time=0 })
				end
			end
			loadEpisodes()

		end, checkBoxHandlerSeasons)
		scrollViewSeasons.x = 0


		function loadSeasons()
			local previousScrollY = nil
			if scrollViewSeasons:getNumRows() > 0 then
				previousScrollY = scrollViewSeasons:getContentPosition()
				scrollViewSeasons:deleteRows()
			end

			if #seriesData.seasons > 0 then
				for seasonIndex, seasonData in ipairs(seriesData.seasons) do
					local seasonNr = seasonData.seasonNr
					local seen, seenCount = _G.loadSeenState(seriesInfo.imdbID, seasonIndex)
					local viewData = 
					{
						showProgress = true,
						seen = seen,
						seenCount = seenCount,
					}
					scrollViewSeasons:append("Säsong " .. seasonNr, seasonData, viewData)
				end
			else
				scrollViewSeasons:append("Finns inga avsnitt", {ignore = true})
			end	
			if previousScrollY then
				scrollViewSeasons:scrollToY({ y=previousScrollY, time=0 })
			end
		end

		loadSeasons()

		

		coverBG:toFront()

	end

	return group
end