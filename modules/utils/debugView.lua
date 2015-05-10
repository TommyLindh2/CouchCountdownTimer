local obj = {}

local function setBoundingBox(v)
	if v.contentBounds then
		local b = v.contentBounds
		local a = display.newRect(b.xMin, b.yMin, b.xMax-b.xMin, b.yMax-b.yMin)
		a:setFillColor(0,0)
		a:setStrokeColor(unpack(v.debugColor))
		a.strokeWidth=1
		a.skip = true
		obj[#obj+1] = a
	end
end

local function setDebugObjects(t)
	for i = 1, (t.numChildren or 0) do
		local v = t[i]
		v.debugColor = v.debugColor or {math.random(255),math.random(255),math.random(255)}
		if v.numChildren then
			setDebugObjects(v)
			setBoundingBox(v)
		elseif not v.skip then
			setBoundingBox(v)
		end

		if not v.skip then
			local x, y = v:localToContent(0,0)
			v.hej = display.newCircle(x,y,3)
			v.hej.skip = true
			v.hej:setFillColor(unpack(v.debugColor))
			obj[#obj+1] = v.hej
		end
	end
end

-- Exempel: require('debugView')(display.currentStage)
return function(t)
	timer.performWithDelay(1,function()
		for k,v in pairs(obj) do
			v:removeSelf()
		end
		obj = {}
		setDebugObjects(t)
	end,0)
end