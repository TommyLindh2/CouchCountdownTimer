local widget = require( "widget" )
local tenfLib = require("modules.utils.tenfLib")

return function(_parent, settings, onTouch, checkBoxTouch)
	local tableView

	local padding = 10
	settings = settings or {}
	local margin = settings.margin or {top = 40, bottom = 20}

	local typeOfView = settings.typeOfView or "normal"
	local rowHeight = settings.rowHeight or 40
	local width = settings.width or _G._W - 20
	local height = _G._H - (margin.top + margin.bottom)
	local fontName, textSize = _G.fontName, _G.fontSizeNormal
	local rounding = 10
	local bgColor = settings.bgColor or {0.4, 0.4, 0.4}
	local textColor = settings.textColor or {1}
	local alignment = settings.align or settings.alignment or "center"

	local rowData = {}
	-- Handle row rendering
	local function onRowRender( event )
		local phase = event.phase
		local rowGroup = event.row
		local index = event.row.index
		local viewData = rowData[index].viewData or {}
		local seenCount = viewData.seenCount

		--Skapar bakgrunden
			local bg = display.newRoundedRect(rowGroup, 0, 0, width, rowHeight, rounding)
			bg.anchorX = 0
			bg.x, bg.y = rowGroup.x, bg.height / 2
		---

		--Skapar eventuell bild
			local image
			if typeOfView == "photo" then
				local fileName = rowData[index].data.imdbID .. ".jpg"
				local tempExist = _G.tenfLib.fileExists(fileName, system.TemporaryDirectory)
				local docExist = _G.tenfLib.fileExists(fileName, system.DocumentsDirectory)
				if tempExist or docExist then
					local directory = docExist and system.DocumentsDirectory or system.TemporaryDirectory
					local tmp = display.newImage(fileName, directory)
					local w, h = tmp.width, tmp.height
					display.remove(tmp)

					image = display.newImageRect(rowGroup, fileName, directory, w, h)
				else
					image = _G.newImage(rowGroup, "images/noImage.png")
				end
				local imageHeight = rowHeight - padding
				_G.tenfLib.fitObjectInArea(image, imageHeight * (1 / 1.5), imageHeight)
				image.anchorX, image.anchorY = 0, 0.5
				image.x, image.y = padding / 2, rowHeight / 2
			end
		---

		local checkBoxSize = {size = 28, inVisible = 12}
		local check = nil
		-- Färgsätter utrifrån sedda värden
			local myBgColor = viewData.bgColor
			local myTextColor = viewData.textColor
			local myAlignment = viewData.align or viewData.alignment

			local seen = viewData.seen
			if seen then
				check = require("modules.checkBox")(rowGroup, 0, 0, checkBoxSize.size, checkBoxSize.inVisible)
			    check:addEventListener("checkEnded", function(e)
			    	if tableView then tableView:setEnabled(true) end
			    end)
			    check:addEventListener("checkBegan", function(e)
			    	if tableView then tableView:setEnabled(false) end
			    end)
			    check:addEventListener("check", function(e)
			        if checkBoxTouch then
			        	local event = _G.tenfLib.tableCopy(e)
			        	event.index = index
			        	event.data = rowData[index].data
			        	event.viewData = rowData[index].viewData
			        	checkBoxTouch(event)
			        end
			    end)
			    check.x, check.y = check.width / 2 + (image and (image.width * image.xScale) + 3 or 0), bg.y

			    if seen == "all" then
					myTextColor = {0}
					myBgColor = {0.3725, 0.8705, 0.3568}
					check:setChecked(true)
				elseif seen == "allReleased" then
					myTextColor = {0}
					myBgColor = {0.5137, 0.8823, 0.7098}
					if seenCount and seenCount.seen > 0 then
						check:setCheckedAlt(true)
					else
						check:setCheckedAlt(false)
					end
				elseif seen == "some" then
					myTextColor = {0}
					myBgColor = {0.9686, 0.8705, 0.3568}
					check:setCheckedAlt(true)
				elseif seen == "none" then
					myTextColor = {0}
					myBgColor = {0.8705, 0.3568, 0.3568}
					check:setChecked(false)
				elseif seen == "unknown" then
					myTextColor = {1}
					check:setChecked(false)
					check.alpha = 0
				end
			end

			local bgColor = myBgColor or bgColor
			local textColor = myTextColor or textColor
			local alignment = myAlignment or alignment

			bgColor = _G.getGradientColor(bgColor)
		---

		--Skapar avsnittsräknare
			local progressDisplay = nil
			if seenCount  and viewData.showProgress then
				local progress2 = nil

				local xMin = padding + (check and check.x + (check.width * check.xScale) / 2)
				local xMax = width - padding
				local progressWidth = xMax - xMin


				-- local params2 = 
				-- {
				-- 	blurAlpha = 1,
				-- 	focusAlpha = 1,
				-- 	color = {1, 1, 0},
				-- 	bgColor = {1, 0.2, 0.2},
				-- 	size = _G.fontSizeVerySmall,
				-- 	width = progressWidth,
				-- 	hideText = true
				-- }
				-- progress2 = require("modules.progressDisplay")(rowGroup, "bar", 0, seenCount.releasedMax, params2)
				-- progress2.x, progress2.y = xMin + progressWidth / 2, bg.y + bg.height / 2 - 3

				-- local params = 
				-- {
				-- 	blurAlpha = 0,
				-- 	focusAlpha = 1,
				-- 	color = {0.2, 1, 0.2},
				-- 	bgColor = {1, 0.2, 0.2},
				-- 	size = _G.fontSizeVerySmall,
				-- 	width = progressWidth,
				-- }
				-- progressDisplay = require("modules.progressDisplay")(rowGroup, "bar", 0, seenCount.max, params)
				-- progressDisplay.x, progressDisplay.y = xMin + progressWidth / 2, bg.y + bg.height / 2 - 3




				-- progressDisplay:setProgress(seenCount.seen)
				-- progress2:setProgress(seenCount.seen)


				local params = 
				{
					blurAlpha = 0.7,
					focusAlpha = 1,
					size = _G.fontSizeVerySmall,
					width = progressWidth,
				}
				progressDisplay = require("modules.progressDisplay")(rowGroup, "bar", 0, seenCount.max, params)
				progressDisplay.x, progressDisplay.y = xMin + progressWidth / 2, bg.y + bg.height / 2 - 3
				

				progressDisplay:setProgress(seenCount.seen)


			end
		---

		--Skapar texten
			local rowTitle
			if typeOfView == "normal" then
				local xMin = padding + (check and check.x + check.width / 2 or 0)
				local xMax = width - padding
				local textWidth = xMax - xMin

				rowTitle = display.newText( rowGroup, rowData[index].text, 0, 0, fontName, textSize )

				tenfLib.fitTextInArea(rowTitle, textWidth, rowHeight, _G.fontSizeVerySmall, "...")
				if alignment == "center" then
					rowTitle.anchorX = 0.5
					rowTitle.x = xMin + textWidth / 2
				elseif alignment == "left" then
					rowTitle.anchorX = 0
					rowTitle.x = xMin
				elseif alignment == "right" then
					rowTitle.anchorX = 1
					rowTitle.x = xMax
				end
				rowTitle.y = bg.y - (progressDisplay and progressDisplay:getMaxHeight()*0.7 or 0)
			elseif typeOfView == "photo" then

				local extraOffset = padding + ((check and check.x + check.width / 2) or (image and image.x + image.width * image.xScale) or 0)
				local xMin = extraOffset
				local xMax = width - padding

				local textWidth = xMax - xMin

				local options = 
				{
					parent = rowGroup,
					text = rowData[index].text,
					x = xMin + textWidth / 2,
					y = bg.y,
					width = textWidth,     --required for multi-line and alignment
					height = rowHeight - padding*2,
					font = fontName,   
					fontSize = textSize,
					align = alignment  --new alignment parameter
				}
				rowTitle = display.newText( options )
			end
		---


		-- PluppData
			local imdbType = viewData.imdbType
			local pluppType = viewData.pluppType
			local pluppColor = viewData.pluppColor
			local pluppSize = viewData.pluppSize

			if imdbType then
				if imdbType == "series" then
					pluppType = "circle"
					pluppColor = {0, 0, 1}
				else--if imdbType == "movie" then
					pluppType = "square"
					pluppColor = {1, 1, 0}
				--elseif imdbType == "episode" then
				--	pluppType = "roundedSquare"
				--	pluppColor = {1, 0, 1}
				end
				pluppSize = 8
			end

			pluppSize = pluppSize or 8
			pluppColor = pluppColor or {0}
			pluppType = pluppType or "none"

			local plupp
			if pluppType == "circle" then
				plupp = display.newCircle(rowGroup, 0, 0, pluppSize / 2)
			elseif pluppType == "square" then
				plupp = display.newRect(rowGroup, 0, 0, pluppSize, pluppSize)
			elseif pluppType == "roundedSquare" then
				plupp = display.newRoundedRect(rowGroup, 0, 0, pluppSize, pluppSize, pluppSize / 4)
			end

			if plupp then
				plupp.anchorX, plupp.anchorY = 1, 0
				plupp.x, plupp.y = width - 5, 5
				plupp:setFillColor(unpack(pluppColor))
			end
		---

		rowTitle:setFillColor(unpack(textColor))
		bg:setFillColor(unpack(bgColor))
	end
	
	-- Handle touches on the row
	local function onRowTouch( event )
		local phase = event.phase
		if not tableView.enabled then return end
		if phase == "press" then
			event.target.alpha = 0.5
		elseif phase == "cancelled" then
			event.target.alpha = 1
		elseif phase == "release" or phase == "tap" then
			event.target.alpha = 1
			if onTouch and not tableView.tapped then
				tableView.tapped = true
				onTouch({data = rowData[event.target.index].data, viewData = rowData[event.target.index].viewData, index = event.target.index})
			end
		end
	end

	-- Create a tableView

	tableView = widget.newTableView({
		hideBackground = true, hideScrollBar = true,
		top = margin.top, left = _G._W*0.5 - width / 2,
		width = width,  height = height,
		onRowRender = onRowRender,
		onRowTouch = onRowTouch,
	})
	tableView.enabled = true
	--tableView.x, tableView.y = _G._W * 0.5, margin.top*3 + width / 2
	_parent:insert( tableView )

	_G.setRectMask(tableView, width, height)

	function tableView:append(_text, _data, _viewData)
		table.insert(rowData, {
			text = _text,
			data = _data or {},
			viewData = _viewData or {},
		})

		local isCategory = false
		local currentRowHeight = rowHeight + padding
		local rowColor = { 
			default = {0, 0},
			over = {0, 0},
		}
		local lineColor = { 0, 0 }

		local rowInfo =
		{
			isCategory = isCategory,
			rowHeight = currentRowHeight,
			rowColor = rowColor,
			lineColor = lineColor,
		}

		self:insertRow(rowInfo)
	end

	function tableView:reloadSameData()
		tableView:reloadWithData(_G.tenfLib.tableCopy(rowData))
	end

	function tableView:setEnabled(state)
		self.enabled = state
	end

	function tableView:reloadWithData(_dataToReload)
		tableView:deleteRows()
		for i, seriesData in ipairs(_dataToReload) do
			self:append(seriesData.text, seriesData.data, seriesData.viewData)
		end
		self:scrollToY({y = 0, time = 0})
	end

	function tableView:deleteRows()
		self:deleteAllRows()
		rowData = {}
		--tableView.tapped = false
	end

	function tableView:getContentHeight()
		return math.max(0, #rowData * (rowHeight + padding) - padding)
	end

	function tableView:setTypeOfView(_type)
		_type = _type or "normal"
		if _type == typeOfView then return end
		typeOfView = _type

		if typeOfView == "normal" then
			rowHeight = 40
		elseif typeOfView == "photo" then
			rowHeight = 120
		end
		tableView:reloadSameData()
	end

	tableView.tapped = false
	tableView:setTypeOfView(typeOfView)

	return tableView
end