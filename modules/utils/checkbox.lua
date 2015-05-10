
--newCheckbox(parent, size[, text[, fontSize]])
	--parent: förälder till checkBoxen
	--size: storlek på checkboxen
	--text: om det ska stå någon text vid checkboxen
	--fontSize: storlek på texten [default: _G.fontSizeNormal]

	--Ex:
	--[[
		--CheckBox utan altCheck
			local checkBoxForRemoval = _G.newCheckbox(eventGroup, 64, "Ta bort")
			checkBoxForRemoval.x, checkBoxForRemoval.y = _W/2, _H/2
			checkBoxForRemoval:addEventListener("touch", function(e)
				if e.phase == "ended" then
					e.target:setCheck(not e.target:isChecked())
				end
			end)
		---
		--CheckBox med altCheck
			local parentCheck = _G.newCheckbox(eventGroup, 64, "Parent")

			function parentCheck:checkStatus()
				--Kollar om föräldern ska checkas
					local checkCount = 0
					for i, childCheck in ipairs(childBoxes) do
						if childCheck:isChecked() then
							checkCount = checkCount + 1
						end
					end
					if checkCount == #childBoxes then
						parentCheck:setCheck(true)
					elseif checkCount > 0 then
						parentCheck:setCheck(true, true)
					else
						parentCheck:setCheck(false)
					end
				---
			end
			parentCheck.x, parentCheck.y = _W/2 - 20, _H/2 - 70
			parentCheck:addEventListener("touch", function(e)
				if e.phase == "ended" then
					if parentCheck:isChecked(true) then
						for i, childCheck in ipairs(childBoxes) do
							childCheck:setCheck(true)
						end
					elseif parentCheck:isChecked() then
						for i, childCheck in ipairs(childBoxes) do
							childCheck:setCheck(false)
						end
					else
						for i, childCheck in ipairs(childBoxes) do
							childCheck:setCheck(true)
						end
					end
					parentCheck:checkStatus()
				end
			end)


			for i = 0, 2 do
				local childCheck = _G.newCheckbox(eventGroup, 64, "Child "..tostring(i+1))
				childCheck.x, childCheck.y = _W/2, _H/2 + i * (70)

				childCheck:addEventListener("touch", function(e)
					if e.phase == "ended" then
						e.target:setCheck(not e.target:isChecked())

						parentCheck:checkStatus()
					end
				end)

				table.insert(childBoxes, childCheck)
			end
		---
	]]


local function newCheckbox(parent, size, text, fontSize)
	fontSize = fontSize or _G.fontSizeNormal
	local checkbox = _G.newGroup(parent)
	_G.setAttr( display.newRect(checkbox, 0, 0, size, size), {x=0, y=0}, {fc={255,0,0,0}} ) -- tryckyta
	_G.setAttr( display.newRect(checkbox, 0, 0, size, size), {x=0, y=0}, {fc=0} )
	_G.setAttr( display.newRect(checkbox, 0, 0, size-2, size-2), {x=0, y=0}, {fc=255} )
	
	checkbox.check = setAttr( display.newImageRect(checkbox, 'images/checkBox/check.png', size-4, size-4), {x=0, y=0, isVisible=false} )
	checkbox.altCheck = setAttr( display.newImageRect(checkbox, 'images/checkBox/checkAlt.png', size-4, size-4), {x=0, y=0, isVisible=false} )
	
	if text then
		local txt = display.newText(checkbox, text, 0, 0, _G.fontName, fontSize)
		_G.setAttr(txt, {x = size/2 + txt.width/2 + 5, y = 0}, {tc={0}})
		local offset = -(checkbox.width / 2 - size/2)

		for i, obj in _G.tenfLib.ipairs(checkbox) do
			obj.x = obj.x + offset
		end

		--Skapar bakgrund för att touch-lyssnaren ska fungera över hela gruppen.
			local w, h = checkbox.width, checkbox.height
			local bg = display.newRect(checkbox, 0, 0, w, h)
			bg.x, bg.y = 0, 0
			bg:setFillColor(0, 0)
		---
	end

	function checkbox:setCheck(_check, _alt)
		if _check == true then
			if _alt then
				_G.setAttr( self.check, {isVisible=not _check} )
				_G.setAttr( self.altCheck, {isVisible=_check} )
			else
				_G.setAttr( self.check, {isVisible=_check} )
				_G.setAttr( self.altCheck, {isVisible=not _check} )
			end
		else
			_G.setAttr( self.check, {isVisible=_check} )
			_G.setAttr( self.altCheck, {isVisible=_check} )
		end
	end

	function checkbox:isChecked(_alt)
		local retVal
		if _alt then
			retVal = self.altCheck.isVisible
		else
			retVal = self.check.isVisible
		end
		return retVal
	end

	return checkbox
end

return {newCheckbox = newCheckbox}


