--=======================================================================================
--=
--=  Bytelista
--=  av 10Fingers
--=
--=  Filuppdateringar:
--=   * 2013-03-26 <MarcusThunström> - Fil skapad.
--=
--[[=====================================================================================



	API-beskrivning:

		byteArray = require("modules.utils.byteArray")(  )

		byteArray:writeByte( byte ) :: skriver till en byte till listan
			- byte: ett heltal på en byte.

		byteArray:writeShort( short ) :: skriver till två bytes till listan
			- short: ett heltal på två bytes.

		byteArray:writeBytes( bytes [, offset [, length ] ] ) :: skriver en lista med bytes till denna lista
			- bytes: lista med bytes.
			- offset: vart i denna lista bytes-listan ska skrivas. (Default: 0)
			- length: längden på bytes-listan. (Default: #bytes)

		byteArray:writeString( string ) :: skriver en sträng till listan
			- string: sträng.

		tostring(byteArray) :: returnerar bytelistan som en sträng



	Exempel:

		local byteArray = require("modules.utils.byteArray")()
		byteArray:writeByte(72)
		byteArray:writeByte(256+69)
		byteArray:writeString("J!")
		print(byteArray[3])  -- 74 (kod för J)
		print(byteArray)  -- HEJ!



--=====================================================================================]]

local bit = require('modules.utils.bit')

-----------------------------------------------------------------------------------------

local mt = {

	__index = {

		writeByte = function(array, b)
			array[#array+1] = bit.band(b, 0xff)
		end,

		writeShort = function(array, i)
			array:writeByte(i)
			array:writeByte(bit.blogic_rshift(i, 8))
		end,

		writeBytes = function(array, b, off, len)
			if not off then off = 0 end
			for i = 1, len or #b do array:writeByte(b[i+off]) end
		end,

		writeString = function(array, s)
			for i = 1, #s do array:writeByte(s:byte(i, i)) end
		end,

	},

	__tostring = function(array)
		local s = ''
		for i = 1, #array do s = s..string.char(array[i]) end
		return s
	end,

}

-----------------------------------------------------------------------------------------

return function()
	return (setmetatable({}, mt))
end
