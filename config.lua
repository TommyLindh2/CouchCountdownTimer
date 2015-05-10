local minWidth, scale2 = 320, 1.5

local aspectRatio = display.pixelHeight/display.pixelWidth
local isRetina = (minWidth/display.pixelWidth < 1/scale2)

local width = --[[isRetina and math.max(display.pixelWidth/2, minWidth) or]] minWidth



application = {



	content = {

		-- [[ Dynamisk storlek:
		width = width,
		height = math.round(width*aspectRatio),
		--]]

		--[[ Fast storlek:
		width = minWidth,
		height = math.floor(minWidth*display.pixelHeight/display.pixelWidth),
		--]]

		scale = "zoomEven",
		xAlign = "left",
		yAlign = "top",
		fps = 60,
		imageSuffix = {
		},

	},



	notification = {
		iphone = {
			types = {
				"alert"
				-- "badge", "sound", "alert", "newsstand" -- (Note: if app should have push enabled this is crucial for device registration)
			},
		},
	},



}
