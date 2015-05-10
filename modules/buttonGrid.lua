--[[
Example:

local settings = 
{
	nrOfColumns = 1,
	margin = {x = 20, y = 80},
	padding = {x = 10, y = 20},
	width = math.floor((_G._W - margin.x * 2 - padding.x * (nrOfColumns - 1)) / nrOfColumns),
	height = 40,

	buttonColor = {normal = {154 / 255, 53 / 255, 255 / 255}, over = {101 / 255, 0, 202 / 255}},
	buttonTextColor = {over = {0}, normal = {0}},
	buttonStrokeColor = {80 / 255, 0, 180 / 255},
	buttonStrokeWidth = 3,
}
local buttonGrid = require("modules.buttonGrid")(guiGroup, settings)

local x, y = buttonGrid:getPosition(buttonGrid:getColumnRow(1))
local btnMySeries = buttonGrid:createButton("Mina serier", x, y, function(e)
	print("Mina serier")
end)

--]]

local nrOfColumns = 1
local margin, padding = {x = 20, y = 80}, {x = 5, y = 20}
local width, height = math.floor((_G._W - margin.x * 2 - padding.x * (nrOfColumns - 1)) / nrOfColumns), 40

local buttonColor = _G.buttonColor
local buttonTextColor = {over = {0.5}, normal = {0.8}}
local buttonStrokeColor = {80 / 255, 0, 180 / 255}
local buttonStrokeWidth = 0


return function(parent, settings)
	settings = settings or {}

	nrOfColumns = settings.nrOfColumns or nrOfColumns
	margin, padding = settings.margin or margin, settings.padding or padding
	width, height = settings.width or width, settings.height or height
	buttonColor = settings.buttonColor or buttonColor
	buttonTextColor = settings.buttonTextColor or buttonTextColor
	buttonStrokeColor = settings.buttonStrokeColor or buttonStrokeColor
	buttonStrokeWidth = settings.buttonStrokeWidth or buttonStrokeWidth


	function settings:getPosition(column, row)
		return margin.x + width / 2 + column * (width + padding.x), margin.y + height / 2 + row * (height + padding.y)
	end

	function settings:getColumnRow(index)
		return (index - 1) % nrOfColumns, math.floor((index - 1) / nrOfColumns)
	end

	function settings:createButton(titleText, x, y, onClick)
		local button = _G.newGroup(parent)

		local buttonRect = display.newRoundedRect(button, 0, 0, width, height, 10)
		buttonRect.strokeWidth = buttonStrokeWidth
		buttonRect:setStrokeColor(unpack(buttonStrokeColor))
		buttonRect.x, buttonRect.y = 0, 0

		local title = display.newText(button, "", 0, 0, _G.fontName, _G.fontSizeNormal)
		

		function button:setTitle(text)
			title.text = text
			_G.tenfLib.fitTextInArea(title, width - 10, height - 3)
			title.x, title.y = 0, 0
		end

		button:setTitle(titleText)

		button.x, button.y = x, y

		_G.tenfLib.enableFocusOnTouch(button)

		function button:setOverColor()
			local buttonOver = _G.getGradientColor(buttonColor.over)

			self.bgRect:setFillColor(unpack(buttonOver))
			self.text:setFillColor(unpack(buttonTextColor.over))
		end

		function button:setNormalColor()
			local buttonNormal = _G.getGradientColor(buttonColor.normal)
			
			self.bgRect:setFillColor(unpack(buttonNormal))
			self.text:setFillColor(unpack(buttonTextColor.normal))
		end

		button:addEventListener("focusBegan", function(e)
			if not button.enabled then 
				e.target:setNormalColor()
				return
			end
			e.target:setOverColor()
		end)

		button:addEventListener("focusMoved", function(e)
			if not button.enabled then 
				e.target:setNormalColor()
				return
			end

			if e.over then
				e.target:setOverColor()
			else
				e.target:setNormalColor()
			end
		end)

		button:addEventListener("focusEnded", function(e)
			if not button.enabled then 
				e.target:setNormalColor()
				return
			end
			e.target:setNormalColor()
		end)

		button:addEventListener("focusEndedOver", function(e)
			if not button.enabled then 
				e.target:setNormalColor()
				return
			end
			onClick(e)
		end)
		
		button.bgRect = buttonRect;
		button.text = title;

		button:setNormalColor()
		button.enabled = true
		function button:setEnabled(enabled)
			button.enabled = enabled
			if enabled then
				self:setNormalColor()
			end
		end

		return button
	end

	return settings
end