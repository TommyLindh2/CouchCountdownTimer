--=======================================================================================
--=
--=  Färgobjekt
--=  av 10Fingers
--=
--=  Filuppdateringar:
--=   * 2013-03-26 <MarcusThunström> - Fil skapad.
--=   * 2013-03-27 <MarcusThunström> - Lagt till toHex-metod. Lagt till "normal" blendmode.
--=
--[[=====================================================================================



	API-beskrivning:

		color = require("modules.utils.color")( v [, a ] )
			- v: ljushetsvärde (kombinerad röd/grön/blå). [0-255]
			- a: alpha. [0-255] (Default: 255)
		color = require("modules.utils.color")( r, g, b [, a ] )
			- r: röd. [0-255]
			- g: grön. [0-255]
			- b: blå. [0-255]
			- a: alpha. [0-255] (Default: 255)

		color:blend( otherColor, blendMode )
			- otherColor: färg som ska blandas med denna färg.
			- blendMode: typ av blandning. ["normal","multiply"|"overlay"|"screen"] (Default: "normal")
			> Returnerar: ett nytt färgobjekt.

		color:clone(  )
			> Retunerar en kopia av färgen. newColor = color:clone()

		color:getComponents(  )
			> Returnerar: röd, grön och blå färgkomponent och alpha. r, g, b, a = color:getComponents()

		color:toHex( [includeAlpha] )
			- includeAlpha: om alpha ska inkluderas. (Default: false)
			> Returnerar: en sträng som visar ett hexadecimalt värde, t.ex. "09FF2D". hex = color:toHex()

		color:toRgb( [includeAlpha] )
			- includeAlpha: om alpha ska inkluderas. (Default: false)
			> Returnerar: en sträng som visar färgkomponenterna i decimal form, t.ex. "100,255,62". rgb = color:toRgb()

		tostring(color)
			> Returnerar: en sträng som beskriver färgen, t.ex. "rgba(90,165,50,255)". cssRgba = tostring(color)



	Exempel:

		local a = require("modules.utils.color")(220,150,150,150)
		local b = require("modules.utils.color")(100,200)
		print("a", a) -- rgba(220,150,150,150)
		print("b", b) -- rgba(100,100,100,200)
		print("-a", -a) -- rgba(35,105,105,255)
		print("-b", -b) -- rgba(155,155,155,255)
		print("+", a+b) -- rgba(255,250,250,232)
		print("-", a-b) -- rgba(120,50,50,232)
		print("*", a*b) -- rgba(86,59,59,232)
		print("screen  ", a:blend(b,"screen")) -- rgba(231,182,182,150)
		print("multiply", a:blend(b,"multiply")) -- rgba(115,78,78,150)
		print("overlay ", a:blend(b,"overlay")) -- rgba(183,125,125,150)

		display.newRect(_W*0/3, 0, _W/3, _H):setFillColor(a:getComponents())
		display.newRect(_W*2/3, 0, _W/3, _H):setFillColor(b:getComponents())

		display.newRect(_W*1/3, _H*0/8, _W/3, _H/8-2):setFillColor((-a):getComponents())
		display.newRect(_W*1/3, _H*1/8, _W/3, _H/8-2):setFillColor((-b):getComponents())
		display.newRect(_W*1/3, _H*2/8, _W/3, _H/8-2):setFillColor((a+b):getComponents())
		display.newRect(_W*1/3, _H*3/8, _W/3, _H/8-2):setFillColor((a-b):getComponents())
		display.newRect(_W*1/3, _H*4/8, _W/3, _H/8-2):setFillColor((a*b):getComponents())
		display.newRect(_W*1/3, _H*5/8, _W/3, _H/8-2):setFillColor((a:blend(b,"screen")):getComponents())
		display.newRect(_W*1/3, _H*6/8, _W/3, _H/8-2):setFillColor((a:blend(b,"multiply")):getComponents())
		display.newRect(_W*1/3, _H*7/8, _W/3, _H/8-2):setFillColor((a:blend(b,"overlay")):getComponents())



--=====================================================================================]]



local tenfLib    = require('modules.utils.tenfLib')

local min, max   = math.min, math.max
local round      = math.round
local stringPad  = tenfLib.stringPad

local methods    = {}, {}
local mt         = {__index=methods}



--=======================================================================================



local function newColor(r, g, b, a)
	local color = setmetatable({}, mt)

	local argAmount = #{r,g,b,a}
	if argAmount == 1 then
		color.r, color.g, color.b, color.a = r, r, r, 255
	elseif argAmount == 2 then
		color.r, color.g, color.b, color.a = r, r, r, g
	elseif argAmount == 3 then
		color.r, color.g, color.b, color.a = r, g, b, 255
	else
		color.r, color.g, color.b, color.a = r, g, b, a
	end

	return color
end



--=======================================================================================



function mt.__eq(c1, c2)
	return c1.r == c2.r and c1.g == c2.g and c1.b == c2.b and c1.a == c2.a
end



function mt.__unm(color)
	return newColor( 255-color.r, 255-color.g, 255-color.b )
end



function mt.__add(c1, c2)
	return newColor(
		min(c1.r+c2.r,255),
		min(c1.g+c2.g,255),
		min(c1.b+c2.b,255),
		255-round((255-c1.a)*(255-c2.a)/255)
	)
end

function mt.__sub(c1, c2)
	return newColor(
		max(c1.r-c2.r,0),
		max(c1.g-c2.g,0),
		max(c1.b-c2.b,0),
		255-round((255-c1.a)*(255-c2.a)/255)
	)
end

function mt.__mul(c1, c2)
	return newColor(
		round(c1.r*c2.r/255),
		round(c1.g*c2.g/255),
		round(c1.b*c2.b/255),
		255-round((255-c1.a)*(255-c2.a)/255)
	)
end



function mt.__tostring(color)
	return 'rgba('..color:toRgb(true)..')'
end



--=======================================================================================



local blendModes = {} -- Se: http://en.wikipedia.org/wiki/Blend_modes

function blendModes.multiply(c1, c2)
	local a2 = c2.a/255
	local a1 = 1-a2
	return
		round( a1*c1.r + a2*c1.r*c2.r/255 ),
		round( a1*c1.g + a2*c1.g*c2.g/255 ),
		round( a1*c1.b + a2*c1.b*c2.b/255 ),
		c1.a
end

function blendModes.normal(c1, c2)
	local a2 = c2.a/255
	local a1 = 1-a2
	return
		round( a1*c1.r + a2*c2.r ),
		round( a1*c1.g + a2*c2.g ),
		round( a1*c1.b + a2*c2.b ),
		round( c1.a + c2.a*(255-c1.a)/255 )
end

function blendModes.overlay(c1, c2)
	local a2 = c2.a/255
	local a1 = 1-a2
	return
		round( a1*c1.r + a2*(c2.r < 255/2 and 2*c1.r*c2.r/255 or (255-2*(255-c1.r)*(255-c2.r)/255) ) ),
		round( a1*c1.g + a2*(c2.r < 255/2 and 2*c1.g*c2.g/255 or (255-2*(255-c1.g)*(255-c2.g)/255) ) ),
		round( a1*c1.b + a2*(c2.r < 255/2 and 2*c1.b*c2.b/255 or (255-2*(255-c1.b)*(255-c2.b)/255) ) ),
		c1.a
end

function blendModes.screen(c1, c2)
	local a2 = c2.a/255
	local a1 = 1-a2
	return
		round( a1*c1.r + a2*(255-(255-c1.r)*(255-c2.r)/255) ),
		round( a1*c1.g + a2*(255-(255-c1.g)*(255-c2.g)/255) ),
		round( a1*c1.b + a2*(255-(255-c1.b)*(255-c2.b)/255) ),
		c1.a
end



-----------------------------------------------------------------------------------------



function methods.blend(c1, c2, mode)
	return newColor(blendModes[mode or 'multiply'](c1, c2))
end



function methods.clone(color)
	return newColor(color.r, color.g, color.b, color.a)
end



function methods.getComponents(color)
	return color.r, color.g, color.b, color.a
end



function methods.toHex(color, includeAlpha)
	return stringPad(string.format('%X', color.r), '0', 2, 'L')
		..stringPad(string.format('%X', color.g), '0', 2, 'L')
		..stringPad(string.format('%X', color.b), '0', 2, 'L')
		..(includeAlpha and stringPad(string.format('%X', color.a), '0', 2, 'L') or '')
end

function methods.toRgb(color, includeAlpha)
	if includeAlpha then
		return color.r..','..color.g..','..color.b..','..color.a
	else
		return color.r..','..color.g..','..color.b
	end
end



--=======================================================================================



return newColor


