--=======================================================================================
--=
--=  Canvas
--=  av 10Fingers AB
--=
--=  Filuppdateringar:
--=   * 2013-03-26 <MarcusThunström> - Fil skapad.
--=   * 2013-03-27 <MarcusThunström> - Fortsättning...
--=
--=  TODO:
--=   * saveGif: Support för fler färger än två.
--=   * saveGif: Support för genomskinlighet.
--=   * Fler ritmetoder.
--=
--[[=====================================================================================



	API-beskrivning:

		canvas = require("modules.utils.canvas")( width, height ) :: skapar ett canvas-objekt
			- width, height: Dimensioner i kolumner och rader.

		canvas:createVector( [parent,] [width, height] ) :: skapar ett DisplayObject som visar bilden på skärmen
			- width, height: Dimensioner i pixlar.

		canvas:fillRect( left, top, width, height ) :: ritar en fylld rektangel
			- left, top: Position på övre vänstra hörnet på rektangeln.
			- width, height: Rektangelns storlek.

		canvas:saveGif( fileName [, directory] ) :: sparar bilen till en fil
			- fileName, directory: plats för GIF-filen.

		canvas:setFillColor( value [, alpha ] ) :: sätter färgen för fylloperationer
			- value: ljushetsvärde (kombinerad röd/grön/blå). [0-255]
			- alpha: alpha. [0-255] (Default: 255)
		canvas:setFillColor( red, green, blue [, alpha ] ) :: sätter färgen för fylloperationer
			- red: röd. [0-255]
			- green: grön. [0-255]
			- blue: blå. [0-255]
			- alpha: alpha. [0-255] (Default: 255)



	Exempel:

		-- Skapa canvas-objektet
		local canvas = require("modules.utils.canvas")(5, 10)

		-- Rita med en färg
		canvas:setFillColor(0,0,255)
		canvas:fillRect(0, 0, 5, 10)

		-- Rita med en annan färg
		canvas:setFillColor(255,0,0)
		canvas:fillRect(1, 1, 1, 1)
		canvas:fillRect(3, 1, 1, 1)
		canvas:fillRect(1, 5, 3, 4)

		-- Visa bilden på skärmen
		canvas:createVector(80, 160)

		-- Spara bilden till en fil
		canvas:saveGif("myImage.gif", system.TemporaryDirectory)



--=====================================================================================]]



local bit               = require('modules.utils.bit')
local tenfLib           = require('modules.utils.tenfLib')

local newColor          = require('modules.utils.color')

local k, methods        = {}, {}
local mt                = {__index=methods}

local colorBlack        = {0,0,0,255}
local colorTransparent  = {0,0,0,0}



--=======================================================================================



local bitStream
local getLzwRaster
local lzwTable



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



--=======================================================================================



-- canvas:createVector( [parent,] [width, height] )
function methods.createVector(canvas, parent, width, height)
	local data = canvas[k]

	if type(parent) == 'number' then parent, width, height = nil, parent, width end
	if not width then width, height = data.columns, data.rows end

	local vectorGroup = tenfLib.newGroup(parent)
	local xDist, yDist = width/data.columns, height/data.rows
	local map = data.map
	for row = 1, data.rows do
		for col = 1, data.columns do
			local color = map[row][col]
			if color and color[4] > 0 then
				local pixel = display.newRect(vectorGroup, xDist*(col-1), yDist*(row-1), xDist, yDist)
				pixel:setFillColor(unpack(color))
			end
		end
	end

	return vectorGroup
end



-- canvas:fillRect( left, top, width, height )
function methods.fillRect(canvas, left, top, width, height)
	local data = canvas[k]
	local color, map = data.fillColor, data.map
	for col = left+1, left+width do
		for row = top+1, top+height do
			map[row][col] = color
		end
	end
end



-- canvas:saveGif( path [, dir ] )
function methods.saveGif(canvas, path, dir)
	local data = canvas[k]
	local map = data.map

	local file = io.open(system.pathForFile(path, dir or system.DocumentsDirectory), 'w+')

	local out = require('modules.utils.byteArray')()

	-- Hämta unika färger
	local colorMap, colorIndices, i = {}, {}, 0
	for row = 1, data.rows do
		for col = 1, data.columns do
			i = i+1
			local color = map[row][col] or data.backgroundColor
			color = newColor(color[1], color[2], color[3], 255) --tempalpha (TODO: transparency för GIF-filer)
			local colorIndex = table.indexOf(colorMap, color)
			if not colorIndex then
				colorIndex = #colorMap+1
				if colorIndex > 256 then error('Too many colors for GIF file') end -- TODO: bättre hantering vid för många färger
				colorMap[colorIndex] = color
			end
			colorIndices[i] = colorIndex
		end
	end
	-- for colorIndex = 1, #colorMap do print('colorIndex_'..colorIndex..': '..#tenfLib.indicesOf(colorIndices, colorIndex)) end

	-- -- Förbered data för färgindex
	-- local colorIndices = {}
	-- for i = 1, data.rows*data.columns do
	-- 	colorIndices[i] = math.random(0, 1)
	-- end

	--------------------------------
	-- GIF Signature

	out:writeString('GIF87a')

	--------------------------------
	-- Screen Descriptor

	out:writeShort(data.columns)
	out:writeShort(data.rows)

	-- 2^(size+1) = total
	-- log(2^(size+1)) = log(total)
	-- (size+1)*log(2) = log(total)
	-- size+1 = log(total)/log(2)
	-- size = log(total)/log(2)-1
	local size = math.ceil(math.log(#colorMap)/math.log(2)-1)
	-- print('size', size)
	-- printObj('0x80', 0x80, bit.tobits(0x80))
	-- printObj('size', bit.tobits(size))

	local tableSize = bit.tobits(size+1)
	while #tableSize < 8 do table.insert(tableSize, 1, 0) end
	-- printObj('tableSize', tableSize, bit.tonumb(tableSize))
	out:writeByte(bit.tonumb(tableSize))

	-- out:writeByte(bit.tonumb(tenfLib.tableReverse(tenfLib.tableFillEmpty(bit.tobits(size), 8, 0))))

	-- out:writeByte(bit.tonumb(tenfLib.tableReverse(bit.tobits(size))))

	-- out:writeByte(size)

	-- out:writeByte(0x80) -- 2bit

	out:writeByte(0)
	out:writeByte(0)

	--------------------------------
	-- Global Color Map

	for i = 1, 2^(size+1) do
		local color, r, g, b = colorMap[i], 0, 0, 0
		if color then r, g, b = color:getComponents() end
		-- print(r, g, b)
		out:writeByte(r); out:writeByte(g); out:writeByte(b);
	end

	-- -- black
	-- out:writeByte(0x00)
	-- out:writeByte(0x00)
	-- out:writeByte(0x00)
	-- -- white
	-- out:writeByte(0xff)
	-- out:writeByte(0xff)
	-- out:writeByte(0xff)

	--------------------------------
	-- Image Descriptor

	out:writeString(',')
	out:writeShort(0)
	out:writeShort(0)
	out:writeShort(data.columns)
	out:writeShort(data.rows)
	out:writeByte(0)

	--------------------------------
	-- Local Color Map

	--------------------------------
	-- Raster Data

	local lzwMinCodeSize = 2--size--2 asdf
	local raster = getLzwRaster(colorIndices, lzwMinCodeSize)
	-- print(table.concat(raster, ','))

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
	file:write(tostring(out))
	io.close(file)
end



-- canvas:setFillColor( v [, a ] )
-- canvas:setFillColor( r, g, b [, a ] )
function methods.setFillColor(canvas, r, g, b, a)
	local data = canvas[k]
	local argAmount = #{r,g,b,a}
	if argAmount == 1 then
		data.fillColor = {r,r,r,255}
	elseif argAmount == 2 then
		data.fillColor = {r,r,r,g}
	elseif argAmount == 3 then
		data.fillColor = {r,g,b,255}
	else
		data.fillColor = {r,g,b,a}
	end
end



--=======================================================================================



return function(width, height)
	local canvas = setmetatable({}, mt)

	local data = {
		backgroundColor = colorBlack,
		fillColor = colorTransparent,
		columns = width, rows = height,
	}
	canvas[k] = data

	local map = {}
	for row = 1, data.rows do
		map[row] = {}
	end
	data.map = map

	return canvas
end



--[[             .,77$I88$?
        .?ZZ77Z:..,:ZZZOONZ$O8O$:
      ,ZOOMO8$,....:OOOOZODZ8OD8OZ.
  ,ZODO8$DDNI:,....,O8OZOODN$$OOO7
.OOO8888$NMN$+,....,Z8I+I$OD877OO.
?8OOO8ZOOMMN8O=,...,7OII$$?IMO$Z$
 $DOOZOONMN$ZZD?=,.,7$7$$DN?78O$.
  Z8OZ$ZMN$ZNN7O$+,.+8$I$NMD??                 ,:::::::,,,.
   $8OO.8DNMMNZZZ~,.,I$$$?Z$I=.             ,:,::::~~~:. .
    ZZ+ $ZODO888+::,,.,~$7$I?+            :~:,,,,:
        .ZOO88O8+~:,,,..,I?I+,          8NNDZ:,,
         7$ZOOZ?+:,~::,...+=:.        NMMMMNO.
          Z$$$+?+~I88D8O,..,        ZNMMMND.
          :?$O$++=8NN8N8:...       NMNNNN.
          :7I7+?+=?DNNND:,.,     :7NNNDI
          I7+7I?I++$ZOZ7=,:O=  .,,~888+
        .I77$$Z7?I$$$77I~:,.?DZ,,,,:8$
        7$$777Z$$7?I?++~:,,..=DD:,,.,?
       7$$$7I77$II++~:::,,...,8DD:,..,,
      ,7$$$7I777?I++~::,,.....=DDDZ,...,
      77$77$I$II??+=~~:,,,....,DDDDD,..,,
     .777III77$??+=:~~~:,,,,,.,=DD8D~...,,
     I777I??I$ZI?=~:~==:,,.,..,,8D$DZ....,
     III??++I7I?=~,,,~~~:,,....,IO=DZ....,.
     I?+==~=I??=~~,,.:~:,,....,,::+8:....,.
    .II?=++=I?+=~~::,,:::,,,..,,,,::,......
     +I?++=?=?+==~~:::::=:,,,,,,:,,,,.....,
      II+??????++~~==~=~~:,::,,::,,,.,...,,.
      7I?+?7?I??~:+=+++?==~,,,,::,..=:,,.,,,
     .I++?I++??++=~~~===+?~:,,,.    ,=~,...,
      I+===++++=+~====?=++~,,.,      :=:,.,,
      ?+~:~~= ,,~~~==~~=+~:,.,,       =~:,,.
      =+=~::~.       =~~+~,,,,,       ,~:,,.
       ++~:,,.       =~~+~::,,.       =~,,,
       +=~:,,,       =~~:,,,,,        ~:..,
       ~+~,,.,      .~:~:,....        =:.,,
       .+=,,..      ~:=:,,,,,         ~,..,
        ?+~,..,   .~::~:,,,,,         ~,..,
        +~:,.., ,:~:::~:,,..,         :,,.,
        +~,...,~~::~:~:,.....        .:,,,,
       .~,,....I7=+=:~:,,...         ::,=::,
      .,,,,,,.,     ,,,,....        ,+=,+:,~
     :=,:=,,~,,     :::::,,,.         ,::=~
    .?=,+:,,:,,    ~~~~~,,,,,
                   ..~7++=:~.
]]
