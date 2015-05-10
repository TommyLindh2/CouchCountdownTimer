--=======================================================================================
--=
--=  Maskmodul
--=  av 10Fingers AB
--=
--=  Filuppdateringar:
--=   * 2013-05-10 <MarcusThunström> - Optimering: Masker skapas snabbare.
--=   * 2013-04-11 <MarcusThunström> - setRectMask: width och height avrundas nu neråt till jämna tal.
--=   * 2013-03-27 <MarcusThunström> - Fil skapad.
--=
--[[=====================================================================================



	API-beskrivning:

		mask.setRectMask( obj, width, height, hAlign, vAlign )
			- obj: Vilket DisplayObject som ska ha masken.
			- width, height: Dimensioner på masken.
			- hAlign: Horizontell justering på mask (center/left/right). ["C","L","R"] (Default: "C")
			- vAlign: Vertikal justering på mask (center/top/bottom). ["C","T","B"] (Default: "C")



	Exempel:

		local img = display.newImage("foo.png")
		require("modules.utils.mask").setRectMask(img, 20, 20)



--=====================================================================================]]



local bit             = require('modules.utils.bit')
local tenfLib         = require('modules.utils.tenfLib')



local ceil, floor     = math.ceil, math.floor
local fileExists      = tenfLib.fileExists
local newMask         = graphics.newMask

local dir             = system.DocumentsDirectory

local lib             = {}



--=======================================================================================



local bitStream
local getLzwRaster
local lzwTable
local saveMask



function bitStream(out)

	local _out = out
	local _bitLength = 0
	local _bitBuffer = 0

	local _this = {}

	function _this:write(data, length)

		if bit.blogic_rshift(data, length) ~= 0 then
			error('length over')
		end

		while _bitLength+length >= 8 do
			_out:writeByte(bit.band(0xff, bit.bor(bit.blshift(data, _bitLength), _bitBuffer)) )
			length = length-(8-_bitLength)
			data = bit.blogic_rshift(data, 8-_bitLength)
			_bitBuffer = 0
			_bitLength = 0
		end

		_bitBuffer = bit.bor(bit.blshift(data, _bitLength), _bitBuffer)
		_bitLength = _bitLength+length
	end

	function _this:flush()
		if _bitLength > 0 then
			_out:writeByte(_bitBuffer)
		end
	end

	return _this
end



function getLzwRaster(colorIndices, lzwMinCodeSize)

	local clearCode = bit.blshift(1, lzwMinCodeSize)
	local endCode = bit.blshift(1, lzwMinCodeSize)+1
	local bitLength = lzwMinCodeSize + 1

	-- Setup LZWTable
	local tbl = lzwTable()

	for i = 1, clearCode do
		tbl:add(string.char(i-1) )
	end
	tbl:add(string.char(clearCode) )
	tbl:add(string.char(endCode) )

	local byteOut = require('modules.utils.byteArray')()
	local bitOut = bitStream(byteOut)

	-- clear code
	bitOut:write(clearCode, bitLength)

	local dataIndex = 1

	local s = string.char(colorIndices[dataIndex]-1) -- Notera: färgindex i GIF-filen är nollbaserade
	dataIndex = dataIndex+1

	while dataIndex <= #colorIndices do

		local c = string.char(colorIndices[dataIndex]-1)
		dataIndex = dataIndex+1

		if tbl:contains(s..c) then

			s = s..c

		else

			bitOut:write(tbl:indexOf(s), bitLength)

			if tbl:size() < 0xfff then

				if tbl:size() == bit.blshift(1, bitLength) then
					bitLength = bitLength+1
				end

				tbl:add(s..c)
			end

			s = c
		end
	end

	bitOut:write(tbl:indexOf(s), bitLength)

	-- end code
	bitOut:write(endCode, bitLength)

	bitOut:flush()

	return byteOut
end



function lzwTable()

	local _map = {}
	local _size = 0

	local _this = {}

	function _this:add(key)
		if _this:contains(key) then
			error('dup key:'..key)
		end
		_map[key] = _size
		_size = _size+1
	end

	function _this:size()
		return _size
	end

	function _this:indexOf(key)
		return _map[key]
	end

	function _this:contains(key)
		return _map[key] ~= nil
	end

	return _this
end



function saveMask(width, height, path, dir)

	local outerWidth, outerHeight = ceil((width+8)/4)*4, ceil((height+8)/4)*4
	local x1, y1 = (outerWidth-width)/2, (outerHeight-height)/2
	local x2, y2 = outerWidth-x1, outerHeight-y1
	local colorIndices, i = {}, 0
	for row = 1, outerHeight do
		for col = 1, outerWidth do
			i = i+1
			colorIndices[i] = (row <= y1 or row > y2 or col <= x1 or col > x2) and 1 or 2
		end
	end

	local out = require('modules.utils.byteArray')()

	--------------------------------
	-- GIF Signature

	out:writeString('GIF87a')

	--------------------------------
	-- Screen Descriptor

	out:writeShort(outerWidth)
	out:writeShort(outerHeight)

	out:writeByte(0x80) -- 2bit

	out:writeByte(0)
	out:writeByte(0)

	--------------------------------
	-- Global Color Map

	-- Black
	out:writeByte(0x00)
	out:writeByte(0x00)
	out:writeByte(0x00)

	-- White
	out:writeByte(0xff)
	out:writeByte(0xff)
	out:writeByte(0xff)

	--------------------------------
	-- Image Descriptor

	out:writeString(',')
	out:writeShort(0)
	out:writeShort(0)
	out:writeShort(outerWidth)
	out:writeShort(outerHeight)
	out:writeByte(0)

	--------------------------------
	-- Local Color Map

	--------------------------------
	-- Raster Data

	local lzwMinCodeSize = 2
	local raster = getLzwRaster(colorIndices, lzwMinCodeSize)

	out:writeByte(lzwMinCodeSize)

	local offset = 0

	while #raster-offset > 255 do
		out:writeByte(255)
		out:writeBytes(raster, offset, 255)
		offset = offset+255
	end

	out:writeByte(#raster-offset)
	out:writeBytes(raster, offset, #raster-offset)
	out:writeByte(0x00)

	--------------------------------
	-- GIF Terminator
	out:writeString(';')

	--------------------------------
	local file = io.open(system.pathForFile(path, dir or system.DocumentsDirectory), 'w+')
	file:write(tostring(out))
	io.close(file)
end



--=======================================================================================



function lib.setRectMask(obj, width, height, hAlign, vAlign)
	width, height = floor(width/2)*2, floor(height/2)*2
	local fileName = 'mask_rect_'..width..'x'..height..'.gif'

	if not fileExists(fileName, dir) then saveMask(width, height, fileName, dir) end

	obj:setMask(newMask(fileName, dir))
	if hAlign=='L' then obj.maskX=width/2  elseif hAlign=='R' then obj.maskX=-width/2  end
	if vAlign=='T' then obj.maskY=height/2 elseif vAlign=='B' then obj.maskY=-height/2 end

	return obj
end



--=======================================================================================



return lib


