
--Variables
local movieData
local movieInfo
local scrollViewCreator = require("modules.buttonScrollView")
local posterImageSize = {width = 100, height = 150}
local directory = system.DocumentsDirectory
local reloadTitles = false

-- Functions
local loadView

return function(parent, data)
	movieInfo = data
	local group = _G.newGroup(parent)
	group.x, group.y = _G._w, _G._h

	local indicatorText = "Hämtar filminformation" .. (movieInfo.Title and "om:\n\"" .. movieInfo.Title .."\"" or ".")
	native.setActivityIndicator(true,  indicatorText)


	if _G.movieExists(movieInfo.imdbID) then
		timer.performWithDelay(0, function()
			native.setActivityIndicator(false)
			movieData = _G.loadMovie(movieInfo.imdbID)
			loadView()
		end)
	else
		_G.downloadTitle(movieInfo.imdbID, directory, function(e)
			native.setActivityIndicator(false)
			if e.isError then
				_G.errorAlert(e, function()
					group:close()
				end)
			else
				display.remove(e.posterImage)
				reloadTitles = true
				movieData = e.data

				_G.addMovie(movieData)
				_G.addTitle(movieData)
			end
			loadView()
		end)
	end

	function group:close(extraData)
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
			local fileName = movieInfo.imdbID .. ".jpg"
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
									transition.to(coverBG, {time = 500, alpha = 0, transition = easing.inOutQuad})
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

			local btnRemove = buttonGrid:createButton("Ta bort film", 0, 0, function(e)
				_G.removeTitle(movieInfo.imdbID)
				_G.removeMovie(movieInfo.imdbID)
				group:close({reloadTitles = true})
			end)
			btnRemove.x, btnRemove.y = xMin + width / 2, -bg.height / 2 + btnRemove.height / 2 + 10

			local isHidden = _G.getHidden(movieInfo.imdbID)
			local btnHide = buttonGrid:createButton(isHidden and "Visa film" or "Dölj film", 0, 0, function(e)
				_G.setHidden(movieInfo.imdbID, not isHidden)
				group:close({reloadTitles = true})
			end)
			btnHide.x, btnHide.y = btnRemove.x, btnRemove.y + btnRemove.height + 5

			local xMin = posterImage.x + posterImageSize.width + 5
			local xMax = bg.width / 2 - 5
			local width = (xMax - xMin)

			local y = btnHide.y + btnHide.height
			local height = posterImage.y + posterImageSize.height - y

			local options = 
			{
				parent = group,
				text = movieData.Title or "<Ingen titel hittad>",
				x = xMin + width / 2,
				y = y,
				width = width,     --required for multi-line and alignment
				height = height,
				font = _G.fontNameBold,   
				fontSize = _G.fontSizeNormal,
				align = "center"  --new alignment parameter
			}

			local title = display.newText(options)
			title:setFillColor(0)
			title.anchorY = 0

		---

		local yMin = posterImage.y + posterImageSize.height + 5
		local yMax = bg.height / 2 - 10
		local height = yMax - yMin
		local options = 
		{
			parent = group,
		    text = movieData.Plot and #movieData.Plot > 5 and movieData.Plot or "<Ingen handling hittad>",     
		    x = 0,
		    y = yMin,
		    width = bg.width - 20,     --required for multi-line and alignment
		    height = height,
		    font = _G.fontName,
		    fontSize = _G.fontSizeSmall,
		    align = "left"  --new alignment parameter
		}

		local plot = display.newText(options)
		plot.anchorY = 0

		coverBG:toFront()

	end

	return group
end