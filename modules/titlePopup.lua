
--Variables
local posterImage
local directory = system.TemporaryDirectory
local posterImageSize = {width = 100, height = 150}

-- Functions
local loadView

return function(parent, data)
	local group = _G.newGroup(parent)
	group.x, group.y = _G._w, _G._h

	native.setActivityIndicator(true, "Hämtar data om:\n\"" .. data.Title .."\"")

	_G.downloadTitle(data.imdbID, directory, function(e)
		native.setActivityIndicator(false)
		if e.isError then
            print( "Network error!")
		else
			data = e.data
			posterImage = e.posterImage
		end
		loadView()
	end)

    function group:close()
    	self:dispatchEvent({name = "beforeClosed", target = self})
		transition.to(self, {time = 500, xScale = 0.001, yScale = 0.001, alpha = 0, transition = easing.outExpo, onComplete = function()
			self:dispatchEvent({name = "closed", target = self})
			display.remove(self)
		end})
    end

	function loadView()
		transition.from(group, {time = 500, xScale = 0.001, yScale = 0.001, alpha = 0, transition = easing.outExpo})


		local clickableBackground = display.newRect(group, 0, 0, _G._W, _G._H)
		clickableBackground:setFillColor(0, _G.blackoutAlpha)
		clickableBackground:addEventListener("touch", function(e)
			if e.phase == "ended" then
				timer.performWithDelay(0, function()
					group:close()
				end)
			end
			return true
		end)


		local bg = display.newRoundedRect(group, 0, 0, _G._W - 40, _G._H - 40, 10)
		bg:setFillColor(0.7)

		if not posterImage then
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


		local settings = 
		{
			width = bg.width / 2 - (posterImage.x + posterImageSize.width) - 20,
			height = 25,
		}
		local buttonGrid = require("modules.buttonGrid")(group, settings)
		local titleExists = _G.titleExists(data.imdbID)
		local btnAdd
		btnAdd = buttonGrid:createButton(titleExists and "Titel redan tillagd" or "Lägg till", 0, 0, function(e)

			_G.addTitle(data)

			btnAdd:setTitle("Titel tillagd")
			btnAdd:setEnabled(false)
		end)
		btnAdd:setEnabled(not titleExists)
		btnAdd.x, btnAdd.y = bg.width / 2 - btnAdd.width / 2 - 10, -bg.height / 2 + btnAdd.height / 2 + 10

		local xMin = posterImage.x + posterImageSize.width + 5
		local xMax = bg.width / 2 - 5
		local width = (xMax - xMin)

		local y = btnAdd.y + btnAdd.height + 10
		local height = posterImage.y + posterImageSize.height - y

		local options = 
		{
			parent = group,
		    text = data.Title or "<Ingen titel hittad>",
		    x = xMin + width / 2,
		    y = y,
		    width = width,     --required for multi-line and alignment
		    height = height,
		    font = _G.fontNameBold,   
		    fontSize = _G.fontSizeLarge,
		    align = "center"  --new alignment parameter
		}

		local title = display.newText(options)
		title.anchorY = 0


		local yMin = posterImage.y + posterImageSize.height + 5
		local yMax = bg.height / 2 - 10
		local height = yMax - yMin
		local options = 
		{
			parent = group,
		    text = data.Plot or "<Ingen handling hittad>",     
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