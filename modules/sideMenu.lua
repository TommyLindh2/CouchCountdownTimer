
local goToClose, goToOpen
local dragFunction
local setAlphaOnContent
local createCoverBG

function dragFunction(e)
	if e.target.master.inTransition then display.getCurrentStage():setFocus(nil); e.target.focused = false; return end
	local master = e.target.master
	if e.phase == "began" then
		
	elseif e.target.focused then
		if e.phase == "moved" then

			local t = e.target
			t.x = _G.tenfLib.clamp(e.x - e.target.offset.x, t.xMin, t.xMax)
			setAlphaOnContent(t)
		else
			display.getCurrentStage():setFocus(nil)
			e.target.focused = false

			local middle = e.target.xMin + (e.target.xMax - e.target.xMin) * (e.target.master.opened and 0.8 or 0.2)

			if e.target.x < middle then
				goToClose(e.target.master)
			else
				goToOpen(e.target.master)
			end
		end
	elseif e.phase == "moved" then
		if math.abs(e.x - e.xStart) > 4 then
			display.getCurrentStage():setFocus(e.target)
			e.target.focused = true
			e.target.offset = {x = e.x - e.target.x, y = e.target.y}
			master:dispatchEvent({name = "beganDragging"})

			if not e.target.coverBG then
				createCoverBG(e.target)
			end
		end
	end
end

function createCoverBG(contentGroup)
	contentGroup.coverBG = display.newRect(contentGroup.master, _G._w, _G._h, _G._W, _G._H)
	contentGroup.coverBG:toBack()
	contentGroup.coverBG:setFillColor(0)
	contentGroup.coverBG.alpha = 0.01
	contentGroup:addEventListener("touch", function() return true end)
	contentGroup:addEventListener("tap", function() return true end)
end

function setAlphaOnContent(contentGroup)
	if contentGroup.coverBG then
		local max, min = contentGroup.xMax, contentGroup.xMin
		local percentage = (contentGroup.x - min) / (max - min)
		contentGroup.coverBG.alpha = 0.01 + percentage * contentGroup.alphaMax
	end
end

function goToClose(master)
	master.inTransition = true
	if master.contentGroup.coverBG then
		transition.to(master.contentGroup.coverBG, {time = 180, alpha = 0.01})
	end

	transition.to(master.contentGroup, {time = 200, x = master.contentGroup.xMin, onComplete = function(e)
		if master.contentGroup.coverBG then
			display.remove(master.contentGroup.coverBG)
			master.contentGroup.coverBG = nil
		end
		master:dispatchEvent({name = "closed"})
		master.opened = false
		master.inTransition = false
	end})
end

function goToOpen(master)
	master.inTransition = true
	if master.contentGroup.coverBG then
		transition.to(master.contentGroup.coverBG, {time = 180, alpha = master.contentGroup.alphaMax})
	end

	transition.to(master.contentGroup, {time = 200, x = master.contentGroup.xMax, onComplete = function(e)
		master:dispatchEvent({name = "opened"})
		master.opened = true
		master.inTransition = false
	end})
end

local function getMenuButton(menuBackground)
	local buttonGroup = _G.newGroup(menuBackground)
	local bg = display.newRoundedRect(buttonGroup, 0, 0, 55, 40, 8)
	bg:setFillColor(unpack(_G.getGradientColor(_G.buttonColor.normal, "right", 0.2)))

	local icon = _G.newGroup(buttonGroup)
	local xMin, xMax = bg.x - bg.width / 2 + 15, bg.x + bg.width / 2 - 10
	local thickness = 4
	local line1 = display.newLine(icon, xMin, bg.y - 10, xMax, bg.y - 10)
	line1.strokeWidth = thickness

	local line2 = display.newLine(icon, xMin, bg.y, xMax, bg.y)
	line2.strokeWidth = thickness

	local line3 = display.newLine(icon, xMin, bg.y + 10, xMax, bg.y + 10)
	line3.strokeWidth = thickness

	buttonGroup.x, buttonGroup.y = menuBackground.width - 5, menuBackground.y + bg.height / 2 + 3

	return buttonGroup
end

return function(params)
	local params = params or {}

	-- Settings
	local parent = params.parent
	local width = params.width or _G._W * 0.7
	local height = params.height or _G._H
	local buttonsInMenu = params.buttons or {}
	---

	local master = _G.newGroup(parent)

	local contentGroup = _G.newGroup(master)
	master.contentGroup = contentGroup
	contentGroup.master = master

	local menuBackground = _G.newGroup(contentGroup)
	local bg = display.newRect(menuBackground, width / 2, height / 2, width, height)
	bg:setFillColor(unpack(_G.getGradientColor({0.3, 0.3, 0.3}, "left", 0.15)))

	local menuButton = getMenuButton(menuBackground, 20, 20)
	menuButton:addEventListener("tap", function(e)
		if master.inTransition then return end
		master:dispatchEvent({name = "beganDragging"})
		if master.opened then
			goToClose(master)
		else
			createCoverBG(contentGroup)
			goToOpen(master)
		end
	end)
	menuButton:toBack()

	contentGroup.xMax = contentGroup.x
	contentGroup.xMin = contentGroup.xMax - bg.width
	contentGroup.alphaMax = 0.7

	contentGroup.x = contentGroup.xMin
	contentGroup:addEventListener("touch", dragFunction)

	local buttonGroup = _G.newGroup(contentGroup)
	local buttonSettings = {width = bg.width - 50, height = 30}
	local buttonGrid = require("modules.buttonGrid")(guiGroup, buttonSettings)

	for i, buttonData in ipairs(buttonsInMenu) do
		local x, y = bg.x - bg.width / 2 + 10 + buttonSettings.width / 2, buttonSettings.height / 2 + 10 + (i - 1) * (buttonSettings.height + 10)
		local btn = buttonGrid:createButton(buttonData.title, x, y, buttonData.onClick)
		buttonGroup:insert(btn)
	end

	return master
end