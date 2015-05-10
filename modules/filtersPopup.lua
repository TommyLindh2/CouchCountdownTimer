return function(parent, referencePos, settings)
	settings = settings or {}
	local reloadTitles = false

    local padding = 10
	local width = _G._W - 20

	local group = _G.newGroup(parent)
	local contentGroup = _G.newGroup(group)
	contentGroup.alpha = 0

	local transComplete = false
	local closingStarted = false
	local coverBG = display.newRect(group, _G._w, _G._h, _G._W, _G._H)
	coverBG:addEventListener("touch", function(e)
		if e.phase == "ended" and transComplete and not closingStarted then
			group:close({reloadTitles = reloadTitles})
		end
		return true
	end)
	coverBG:addEventListener("tap", function() return true end)
	coverBG:setFillColor(0, _G.blackoutAlpha)

	local title = _G.createTitle(contentGroup, "Filter")
	title.x, title.y = _G._w, title.height / 2


    local myFilters = _G.getFilters()
	local function addChooserRow(parent, text, previous, filter)
        local row = _G.newGroup(parent)

        local marginSides = 25

        local text = display.newText(row, text, 0, 0, _G.fontName, _G.fontSizeNormal)
        text.anchorX, text.anchorY = 0, 0
        text.x, text.y = 0, 0

        local check = require("modules.checkBox")(row, 0, 0, text.height, 5)
        check.x, check.y = width - check.width / 2 - marginSides*2, text.height / 2

        local filterValue = not not myFilters[filter]
        check:setChecked(filterValue)

        check:addEventListener("check", function(e)
            local filterId = check.parent.filter
            if not filterId then return end

            local filters = {}
            filters[filterId] = e.checked
            _G.setFilters(filters)
            reloadTitles = true
        end)

        row.x, row.y = marginSides, previous.y + previous.height + padding

        row.filter = filter

        return row
    end


    local previous = title
	for i, filterData in ipairs(_G.getAvailableFilters()) do
		local chooserRow = addChooserRow(contentGroup, filterData.displayName, previous, filterData.id)
		previous = chooserRow
	end

	local bg = display.newRoundedRect(group, 0, 0, width, contentGroup.height + 50, 5)
	bg.anchorX, bg.anchorY = 1, 0
	bg.x, bg.y = referencePos.x, referencePos.y
	bg:setFillColor(_G.getGradientColor(_G.buttonColor.normal)[1])

	contentGroup.y = referencePos.y + padding

	function group:close(extraData)
		closingStarted = true
		local event = {name = "beforeClosed", target = self}
		_G.setAttr(event, extraData or {})
		group:dispatchEvent(event)
		local contentValues = _G.tenfLib.tableCopy(contentGroup.minimizedValues, true)
		contentValues.onComplete = function()
			local bgValues = _G.tenfLib.tableCopy(bg.minimizedValues, true)
			bgValues.onComplete = function()
				local event = {name = "closed", target = self}
				_G.setAttr(event, extraData or {})
				group:dispatchEvent(event)
				display.remove(self)
			end
			transition.to(bg, bgValues)
		end
		transition.to(contentGroup, contentValues)
		transition.to(coverBG, coverBG.minimizedValues)
		
	end

	bg.minimizedValues = {time = 500, xScale = 0.01, yScale = 0.01, transition = easing.inOutQuad}
	coverBG.minimizedValues = {time = 200, alpha = 0.01}
	contentGroup.minimizedValues = {time = 200, alpha = 0}

	contentGroup:toFront()
	

	local bgValues = _G.tenfLib.tableCopy(bg.minimizedValues, true)
	bgValues.onComplete = function()
		contentGroup.alpha = 1
		transition.from(contentGroup, contentGroup.minimizedValues)
		timer.performWithDelay(contentGroup.minimizedValues.time, function()
			transComplete = true
		end)
	end
	transition.from(bg, bgValues)
	transition.from(coverBG, coverBG.minimizedValues)

	return group
end