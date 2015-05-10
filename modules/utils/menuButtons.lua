
local function createButtonGroup(switchmode)
	local componentGroup = display.newGroup()
	componentGroup.table = {}
	componentGroup.windowOpen = false
	componentGroup.type = "componentGroup"

	if switchmode then
		componentGroup.switchmode = true
	end
	

	function componentGroup:append(component)
		componentGroup:insert(component)
		component.isGrouped = true
		table.insert(componentGroup.table, component)
			if componentGroup.switchmode then
				component.sticky = true; component.on = false
			end

		return component
	end

	function componentGroup:buttonPressed(obj)
		if obj and obj.sticky then
			if not obj.on then
				for k,v in pairs(componentGroup.table) do	
					
					if v.sticky and v.type == "rounded" then
						v.center.isVisible = true
						v.top.isVisible = true
						v.bottom.isVisible = true

						v.centerOver.isVisible = false
						v.topOver.isVisible = false
						v.bottomOver.isVisible = false
						v.on = false
					end
					if v.text then v.text.y = 10 end
				end

				if obj.type == "rounded" then
					obj.on = true
					obj.center.isVisible = false
					obj.top.isVisible = false
					obj.bottom.isVisible = false

					obj.centerOver.isVisible = true
					obj.topOver.isVisible = true
					obj.bottomOver.isVisible = true
					obj.onRelease()
				end
				if obj.text then obj.text.y = obj.centerOver.y end

			elseif obj.on then
				-- do nothing
			end

		elseif not componentGroup.windowOpen then
			--componentGroup.windowOpen = true
			obj.onRelease()
		end
		return componentGroup
	end

	function componentGroup:align(xSpacing, ySpacing, order)
		if order == nil then order = componentGroup.table end
		local moveVar = 0
		for i = 1, #order do
			if i == 1 then
				order[i].x, order[i].y = 0, 0 
			else
				if order[i].depth then moveVar = 4 else moveVar = 0 end
				
				if xSpacing then
					order[i].x = order[i-1].x + order[i-1].width + xSpacing
				end
				if ySpacing then
					order[i].y = order[i-1].y + order[i-1].height + ySpacing 
				end

			end
		end
	end

	return componentGroup
end


local function roundedRect(group, text, width, height, round, depth, color, onRelease, active)

	local cTop, cBot = color[1], color[1]
	local cInverseTop, cInverseBot = color[1], color[1]
	local inverseColor
	local inverseTop, inverseBot = color[1], color[1]
	local gradientColor
	local moveVar = 0

	if depth then moveVar = 4 end


	local buttonGroup = display.newGroup()

	--Funktion för att byta färg på knappen
		function buttonGroup:setFillColor(colorTable)
			if #colorTable > 1 then
				gradientColor = true
				cTop, cBot = colorTable[1], colorTable[2]
				cInverseTop, cInverseBot = cBot, cTop
				inverseColor = graphics.newGradient(colorTable[1], colorTable[2], colorTable[3] == "down" and "up" or "down")
				colorTable = graphics.newGradient(colorTable[1], colorTable[2], colorTable[3])
			else
				gradientColor = false
				colorTable = colorTable[1]
				inverseColor = {colorTable[1] - 40 ,colorTable[2]- 40,colorTable[3] - 40}
				cInverseTop, cInverseBot = inverseColor, inverseColor
			end

			if type(colorTable) == "table" then
				self.background:setFillColor(unpack(colorTable))
			else
				self.background:setFillColor(colorTable)
			end
			self.top:setFillColor(unpack(cTop))
			self.bottom:setFillColor(unpack(cBot))

			if type(inverseColor) == "table" then
				self.centerOver:setFillColor(unpack(inverseColor))
			else
				self.centerOver:setFillColor(inverseColor)
			end
			self.topOver:setFillColor(unpack(cInverseTop))
			self.bottomOver:setFillColor(unpack(cInverseBot))
		end
	---


	--Skapar normal bakgrund
		local backgroundNormal = display.newRect(buttonGroup, 0, 0, width, height-(round*2))
		backgroundNormal.x, backgroundNormal.y = 0, backgroundNormal.height / 2
		buttonGroup.background = backgroundNormal

		local roundedTopNormal = display.newRoundedRect(buttonGroup, 0, 0, width, round*2, round)
		roundedTopNormal.x, roundedTopNormal.y = backgroundNormal.x, backgroundNormal.y - (backgroundNormal.height/2)
		roundedTopNormal:toBack()

		local roundedBottomNormal = display.newRoundedRect(buttonGroup, 0, 0, width, round*2, round)
		roundedBottomNormal.x, roundedBottomNormal.y = backgroundNormal.x, backgroundNormal.y + (backgroundNormal.height/2)
		roundedBottomNormal:toBack()

		if depth then
			
			local shadow = display.newGroup()
			buttonGroup:insert(shadow)
			local R,G,B = color[2][1] - 40, color[2][2] - 40, color[2][3] - 40

			local midShadow = display.newRect(shadow, 0, 0, width, height-(round*2))
			midShadow.x, midShadow.y = backgroundNormal.x, backgroundNormal.y + moveVar
			midShadow:setFillColor(_G.tenfLib.clamp(R,0,255), _G.tenfLib.clamp(G,0,255), _G.tenfLib.clamp(B,0,255))
			midShadow:toBack()

			local lowerShadow = display.newRoundedRect(shadow, 0, 0, width, round*2, round)
			lowerShadow.x, lowerShadow.y = roundedBottomNormal.x, roundedBottomNormal.y + moveVar
			lowerShadow:setFillColor(_G.tenfLib.clamp(R,0,255), _G.tenfLib.clamp(G,0,255), _G.tenfLib.clamp(B,0,255))
			lowerShadow:toBack()


			
			buttonGroup.shadow = shadow
			buttonGroup.depth = true


		end
	---

	--Skapar inverterad bakgrund
		local backgroundOver = display.newRect(buttonGroup, 0, 0, width, height-(round*2))
		backgroundOver.isVisible = false
		backgroundOver.x, backgroundOver.y = 0, backgroundOver.height / 2 + moveVar

		local roundedTopOver = display.newRoundedRect(buttonGroup, 0, 0, width, round*2, round)
		roundedTopOver.isVisible = false
		roundedTopOver.x, roundedTopOver.y = backgroundNormal.x, backgroundNormal.y - (backgroundNormal.height/2) + moveVar
		roundedTopOver:toBack()

		local roundedBottomOver = display.newRoundedRect(buttonGroup, 0, 0, width, round*2, round)
		roundedBottomOver.isVisible = false
		roundedBottomOver.x, roundedBottomOver.y = backgroundNormal.x, backgroundNormal.y + (backgroundNormal.height/2) + moveVar
		roundedBottomOver:toBack()
	---


	if depth then buttonGroup.shadow:toBack() end
	buttonGroup:setReferencePoint(display.CenterReferencePoint)

	buttonGroup.x, buttonGroup.y = 0, backgroundNormal.height/2 + round

	--Skapar Text
		if text then
			local label
			if type(text) == "table" then			
				if text._class then
					label = text
					buttonGroup:insert(label)
					label.x, label.y = backgroundNormal.x, backgroundNormal.y
					
				else
					label = display.newText(buttonGroup, text.text, 0, 0, text.font or _G.fontName, text.size or _G.fontSizeSmall)
					label.x, label.y = backgroundNormal.x, backgroundNormal.y
					
				end
			else
				label = display.newText(buttonGroup, text, 0,0, _G.fontName, _G.fontSizeSmall)
				label.x, label.y = backgroundNormal.x, backgroundNormal.y


			end
			buttonGroup.text = label
		end

	---
	local sizeRect = display.newRect(buttonGroup, 0, 0, width, height)
	sizeRect.x, sizeRect.y = 0, sizeRect.height / 2 - round
	sizeRect:setFillColor(0, 0)

	if group and group.type == "componentGroup" then
		group:append(buttonGroup)
	elseif group then
		group:insert(buttonGroup)
		buttonGroup.isGrouped = false
	end

	if onRelease and not active then
		buttonGroup.active = true
	else
		buttonGroup.active = active
	end

	buttonGroup.top = roundedTopNormal
	buttonGroup.bottom = roundedBottomNormal
	buttonGroup.center = backgroundNormal
	buttonGroup.topOver = roundedTopOver
	buttonGroup.bottomOver = roundedBottomOver
	buttonGroup.centerOver = backgroundOver
	

	buttonGroup.size = sizeRect
	buttonGroup.onRelease = onRelease
	buttonGroup.type = "rounded"

	buttonGroup.center:setReferencePoint(display.TopCenterReferencePoint)
	buttonGroup.size:setReferencePoint(display.TopCenterReferencePoint)

	--Sätter färg på knappen
		buttonGroup:setFillColor(color)
	---

	local function setButtonState(_isOver)
		if not buttonGroup.on and buttonGroup.active then
			if _isOver then
				if buttonGroup.text and depth then buttonGroup.text.y = backgroundOver.y end
				--Normal
					backgroundNormal.isVisible = false
					roundedTopNormal.isVisible = false
					roundedBottomNormal.isVisible = false
				---

				--Over
					backgroundOver.isVisible = true
					roundedTopOver.isVisible = true
					roundedBottomOver.isVisible = true
				---

			else
				if buttonGroup.text and depth then buttonGroup.text.y = 10 end
				--Normal
					backgroundNormal.isVisible = true
					roundedTopNormal.isVisible = true
					roundedBottomNormal.isVisible = true
				---

				--Over
					backgroundOver.isVisible = false
					roundedTopOver.isVisible = false
					roundedBottomOver.isVisible = false
				---
			end
		end
	end
	setButtonState(false)
	local resetButtonStateTimerHandle
	local function cancelTimer(_handle)
		if _handle then
			timer.cancel(_handle)
		end
		_handle = nil
	end
	local isTap = false
	if onRelease then
		_G.tenfLib.enableFocusOnTouch(buttonGroup)
		buttonGroup:addEventListener("focusBegan", function(e)
			setButtonState(true)
		end)
		buttonGroup:addEventListener("focusMoved", function(e)
			setButtonState(e.over)
		end)
		buttonGroup:addEventListener("focusEnded", function(e)
			setButtonState(false)
		end)

		buttonGroup:addEventListener("focusEndedOver", function(e)
			if buttonGroup.active then
				if buttonGroup.isGrouped then
					if buttonGroup.sticky then
						buttonGroup.parent:buttonPressed(e.target)
					elseif not buttonGroup.parent.windowOpen then
						buttonGroup.parent:buttonPressed(e.target)
					end
				else
					onRelease(e)
				end
			end
			setButtonState(false)
		end)
	end

	return buttonGroup
end



return {createButtonGroup = createButtonGroup, roundedRect = roundedRect}



