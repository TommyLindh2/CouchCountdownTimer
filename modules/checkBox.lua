
local backgroundColor = {
	normal = {1},
	over = {0.7},
	disable = {0.3},
}
local checkColor = {
	normal = {1},
	over = {0.7},
	disable = {0.3}
}

local strokeColor = {0}

local strokeWidth = 1

return function(parent, x, y, size, largener)
	if not size then parent, x, y, size = nil, parent, x, y end

	local checkBox = _G.newGroup(parent)

	if largener then

		local touchLargener = display.newRect(checkBox, 0, 0, size + largener, size + largener)
		touchLargener.x, touchLargener.y = 0, 0
		touchLargener.alpha = 0.01
	end

	local bg = display.newRect(checkBox, 0, 0, size, size)
	bg.strokeWidth = strokeWidth
	bg:setStrokeColor(unpack(strokeColor))
	bg.x, bg.y = 0, 0

	local check = display.newImageRect(checkBox, "images/check.png", size + 3, size + 3)
	check.x, check.y = 0, 0

	local checkAlt = display.newImageRect(checkBox, "images/checkAlt.png", size + 3, size + 3)
	checkAlt.x, checkAlt.y = 0, 0
	
	checkBox.x, checkBox.y = x, y
	local focusKey = {}
	_G.tenfLib.enableFocusOnTouch(checkBox)
	checkBox:addEventListener("touch", function(e)
		local obj, p = e.target, e.phase

		if p == "began" then
			local focusEvent = _G.tenfLib.tableCopy(e)
			focusEvent.name, focusEvent.phase = "focusBegan", nil
			obj:dispatchEvent(focusEvent)
			display.currentStage:setFocus(obj)
			obj[focusKey] = true
		elseif obj[focusKey] then
			local bounds, focusEvent, of = obj.contentBounds, _G.tenfLib.tableCopy(e), 0
			focusEvent.phase = nil
			if p == "moved" then
				focusEvent.name = 'focusMoved'
				focusEvent.over = _G.tenfLib.pointInRect(e.x, e.y, bounds.xMin-of, bounds.yMin-of, bounds.xMax-bounds.xMin+of*2, bounds.yMax-bounds.yMin+of*2)
				obj:dispatchEvent(focusEvent)
			else
				display.currentStage:setFocus(nil)
				obj[focusKey] = nil
				focusEvent.name = 'focusEnded'
				focusEvent.over = _G.tenfLib.pointInRect(e.x, e.y, bounds.xMin-of, bounds.yMin-of, bounds.xMax-bounds.xMin+of*2, bounds.yMax-bounds.yMin+of*2)
				if focusEvent.over then
					local overEvent = _G.tenfLib.tableCopy(focusEvent)
					overEvent.name, overEvent.over = 'focusEndedOver', nil
					obj:dispatchEvent(overEvent)
				end
				obj:dispatchEvent(focusEvent)
			end
		end
		return true
	end)
	checkBox:addEventListener("tap", function() return true end)

	function checkBox:setOverColor()
		self.background:setFillColor(unpack(backgroundColor.over))
		self.check:setFillColor(unpack(checkColor.over))
	end

	function checkBox:setNormalColor()
		self.background:setFillColor(unpack(backgroundColor.normal))
		self.check:setFillColor(unpack(checkColor.normal))
	end

	function checkBox:setDisableColor()
		self.background:setFillColor(unpack(backgroundColor.disable))
		self.check:setFillColor(unpack(checkColor.disable))
	end

	checkBox:addEventListener("focusBegan", function(e)
		if not e.target.enabled then 
			e.target:setDisableColor()
			return
		end
		e.target:setOverColor()
		e.target:dispatchEvent({name = "checkBegan"})
		return true
	end)

	checkBox:addEventListener("focusMoved", function(e)
		if not e.target.enabled then 
			e.target:setDisableColor()
			return
		end

		if e.over then
			e.target:setOverColor()
		else
			e.target:setNormalColor()
		end
	end)

	checkBox:addEventListener("focusEnded", function(e)
		if not e.target.enabled then 
			e.target:setDisableColor()
			return
		end
		e.target:setNormalColor()
		e.target:dispatchEvent({name = "checkEnded"})
	end)

	checkBox:addEventListener("focusEndedOver", function(e)
		if not e.target.enabled then 
			e.target:setDisableColor()
			return
		end
		local altChecked = e.target:getCheckedAlt()
		if altChecked then
			e.target:setChecked(true)
		else
			e.target:setChecked(not e.target:getChecked())
		end
		
		e.target:dispatchEvent({name = "check", checked = e.target:getChecked(), target = e.target})
		e.target:dispatchEvent({name = "checkAlt", checked = e.target:getCheckedAlt(), target = e.target})
	end)
	
	checkBox.background = bg
	checkBox.check = check
	checkBox.checkAlt = checkAlt

	checkBox:setNormalColor()
	checkBox.enabled = true
	checkBox.checked = false
	checkBox.checkedAlt = false
	function checkBox:setEnabled(enabled)
		checkBox.enabled = enabled
		if enabled then
			self:setNormalColor()
		else
			self:setDisableColor()
		end
	end

	function checkBox:setChecked(checked, limit)
		if not limit then
			self:setCheckedAlt(false, true)
		end

		self.checked = not not checked
		self.check.isVisible = self.checked
	end

	function checkBox:getChecked()
		return self.checked
	end

	function checkBox:setCheckedAlt(checked, limit)
		if not limit then
			self:setChecked(false, true)
		end

		self.checkedAlt = not not checked
		self.checkAlt.isVisible = self.checkedAlt
	end

	function checkBox:getCheckedAlt()
		return self.checkedAlt
	end

	check.isVisible = checkBox.checked
	checkAlt.isVisible = checkBox.checkedAlt

	return checkBox
end