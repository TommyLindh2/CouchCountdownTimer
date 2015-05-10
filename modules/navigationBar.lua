--------------------------------------------------
-- navigationMenu.lua
-- Miltronic-Prisappen
-- 10FINGERS AB
-- Påbörjad: 2013-03-?? av Kevin Sund
-- Uppdaterad: 2013-04-12 av Erik Torstensson
--             2013-04-16 av Marcus Thunström
--             2013-06-27 av Erik Torstensson
--------------------------------------------------
--[[

	Beskrivning:

		navMenu = require("navigationMenu")( [parent,] buttonDataList ) -- Skapar en header
			* parent: Om menyn ska läggas in i en grupp.
			* buttonDataList: Lista med knappdata.

		show() -- Visar menyn
		hide() -- Gömmer menyn
		setSelected(nr) -- Markerar knapp


	Exempel på användande:

		local navMenu = require("modules.navigationMenu"){
			{title="Schema", icon="calendar"},
			{title="Uppgifter", icon="tasks", callback=function() print("Foo") end},
		}
		navMenu:setSelected(1)

--]]

local tabBarHeight = _G.tabBarHeight
local gradientHeight = 1
local strokeWidth = 1

local transitionTime = 150

local tabHeight = tabBarHeight - gradientHeight

return function(parent, buttonDataList, fade)
	if not buttonDataList then parent, buttonDataList = nil, parent end

	local navGroup = _G.newGroup(parent)
	local contentGroup = _G.newGroup(navGroup)
	rawset(navGroup, 'height', tabHeight)

	navGroup.buttons = {}


	local transitionId

	local tabOver = _G.setAttr(display.newRect(contentGroup--[[, 'images/navigationMenu/tabBar.png']],0,0, _G._W, tabHeight), {x=0, y=_G._H-tabHeight, anchorX = 0, anchorY = 0}, {fc=_G.getGradientColor(_G.navBarColor, nil, 0.5)[1]})
	_G.setAttr(display.newRect(contentGroup, 0, 0, _G._W, gradientHeight), {y=tabOver.y-gradientHeight, anchorX = 0, anchorY = 0}, {fc=0})
	_G.setAttr(display.newRect(contentGroup, 0, 0, _G._W, strokeWidth), {y=_G._H-strokeWidth*0.5})

	local function createTabs(_buttonList, _hard, _onComplete)
		if #_buttonList > 0 then
			local buttonWidth = math.floor(_W/#_buttonList/2)*2
			for i, buttonData in ipairs(_buttonList) do
				local button = _G.setAttr(display.newRect(contentGroup, 0, 0, buttonWidth, tabHeight), {strokeWidth = strokeWidth, x=buttonWidth*(i-1), y=_G._H-tabHeight, id=i, anchorX = 0, anchorY = 0}, {fc={0,0}})
				button.overlay = _G.setAttr(display.newRect(contentGroup, 0, 0, button.width, button.height), {x=button.x, y=button.y+strokeWidth, alpha=0, strokeWidth=strokeWidth, anchorX = 0, anchorY = 0}, {fc=_G.navBarGradientOverlay})
				button.text = _G.setAttr(display.newText(contentGroup, buttonData.title, 0, 0, _G.fontName, _G.fontSizeSmall), {x=button.x+button.width*0.5, y=math.round(button.y+button.height*0.5)}, {tc={0}})

				button.handler = buttonData.callback

				navGroup.buttons[#navGroup.buttons+1] = button
				
				if _hard then
					if i == #_buttonList then
						if _onComplete then _onComplete() end
					end
				else
					button.text.alpha = 0
					transition.to(button.text, {
						time = transitionTime,
						alpha = 1,
						transition=easing.inOutQuad,
						onComplete = function()
							if i == #_buttonList then
								if _onComplete then _onComplete() end
							end
						end
					})
				end
			end
		else
			if _onComplete then _onComplete() end
		end
	end
	createTabs(buttonDataList, fade)

	tenfLib.enableFocusOnTouch(contentGroup)
	contentGroup:addEventListener('focusBegan', function(e)
		for _,button in ipairs(navGroup.buttons) do
			if _G.tenfLib.pointInRect(e.x, e.y, button) then
				navGroup:setSelected(button.id)
			end
		end
	end)
	contentGroup:addEventListener('focusMoved', function(e)
		for _,button in ipairs(navGroup.buttons) do
			if _G.tenfLib.pointInRect(e.x, e.y, button) then
				navGroup:setSelected(button.id)
				break
			else
				navGroup:setSelected()
			end
		end
	end)
	local previousSelected = 1
	contentGroup:addEventListener('focusEnded', function(e)
		local droppedOver = false
		for i, button in ipairs(navGroup.buttons) do
			if _G.tenfLib.pointInRect(e.x, e.y, button) then
				droppedOver = true
				previousSelected = i
				local handler = button.handler
				if handler then handler() end
				break
			end
		end
		if not droppedOver then
			navGroup:setSelected(previousSelected)
		end
	end)

	function navGroup:addNewTabs(_tabs, _hard, _onComplete)
		navGroup:removeTabs(_hard, function()
			navGroup:addTabs(_tabs, _hard, function()
				if _onComplete then _onComplete() end
			end)
		end)
	end

	function navGroup:addTabs(_tabs, _hard, _onComplete)
		createTabs(_tabs, _hard, _onComplete)
	end

	function navGroup:removeTabs(_hard, _onComplete)
		if #navGroup.buttons > 0 then
			local lengthBefore = #navGroup.buttons
			for i, button in ipairs(navGroup.buttons) do
				if _hard then
					display.remove(button.text)
					display.remove(button.overlay)
					display.remove(button)
					button = nil
					if _onComplete then _onComplete() end
				else
					transition.to(button.text, {
						time = transitionTime,
						alpha = 0,
						transition=easing.inOutQuad,
						onComplete = function()
							display.remove(button.text)
						end
					})
					transition.to(button.overlay, {
						time = transitionTime,
						alpha = 0,
						transition=easing.inOutQuad,
						onComplete = function()
							display.remove(button.overlay)
						end
					})
					transition.to(button, {
						time = transitionTime,
						alpha = 0,
						transition=easing.inOutQuad,
						onComplete = function()
							display.remove(button)
							if i == lengthBefore then
								if _onComplete then _onComplete() end
							end
						end
					})
				end
			end
			navGroup.buttons = {}
		else
			if _onComplete then _onComplete() end
		end
	end

	function navGroup:setSelected(nr)
		for i, button in ipairs(self.buttons) do
			button.overlay.alpha = i==nr and 1 or 0
			local textColor = i==nr and {1} or {1}
			button.text:setFillColor(unpack(textColor))
			-- button.defaultIcon.isVisible = i~=nr
			-- button.hilightIcon.isVisible = i==nr
		end
	end

	function navGroup:show(_hard, _onComplete)
		if transitionId then return end
		if _hard then
			if transitionId then transition.cancel(transitionId); transitionId = nil; end	
			contentGroup.y = 0
			if _onComplete then _onComplete() end
		else
			transitionId = transition.to(contentGroup, {time=transitionTime, y=0, transition=easing.outQuad, onComplete=function() transitionId = nil; if _onComplete then _onComplete() end; end})
		end
	end

	function navGroup:hide(_hard, _onComplete)
		if transitionId then transition.cancel(transitionId); transitionId = nil; end
		if _hard then
			contentGroup.y = tabHeight
			if _onComplete then _onComplete() end
		else
			transitionId = transition.to(contentGroup, {time=transitionTime, y=tabHeight, transition=easing.inQuad, onComplete=function() transitionId = nil; if _onComplete then _onComplete() end; end})
		end
	end

	return navGroup
end
