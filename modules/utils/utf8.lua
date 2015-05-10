------------------------------------------------------------------------
--
-- Resurs för att behandla UTF-8-bokstäver (åäö etc.)
-- utf8.lua
--
-- Påbörjad: innan 2012-04-10 av Marcus Thunström
-- Uppdaterad: 2012-08-01 av Marcus Thunström
--
------------------------------------------------------------------------



-- Returnerar hur många bytes ett tecken upptar, baserat på RFC 3629
-- Referenser:
--   http://developer.anscamobile.com/reference/index/stringsub#comment-82171
--   http://developer.anscamobile.com/reference/index/stringsub#comment-86944
--   http://home.tiscali.nl/t876506/utf8tbl.html
--   http://tools.ietf.org/html/rfc3629#section-4
-- Exempel:
--   local str1 = "U"
--   local str2 = "Ä"
--   print(utf8.charSize(str1:byte(1)))  -- 1
--   print(utf8.charSize(str2:byte(1)))  -- 2
local function charSize(byte)
	if not byte then
		return 0
	elseif byte >= 240 then
		return 4
	elseif byte >= 224 then
		return 3
	elseif byte >= 192 then
		return 2
	else
		return 1
	end
end



-- Letar efter enskilda bokstäver i en sträng (Notering: ingen support för pattern)
-- Exempel:
--   print(utf8.findChar("Höga bägare", "ä"))  -- 7
--   print(utf8.findChar("foobar", "é"))  -- nil
local function findChar(str, char)

	local byteIndex = 1
	local charIndex = 0

	local len = #str
	while byteIndex <= len do
		charIndex  = charIndex+1
		local size = charSize(str:byte(byteIndex))
		if str:sub(byteIndex, byteIndex+size-1) == char then return charIndex end
		byteIndex  = byteIndex+size
	end

	return nil

end



-- Returnerar det faktiska antalet bokstäver
-- Exempel:
--   print(utf8.len("Räv"))  -- 3
local function len(str)

	local i      = 1
	local bytes  = #str
	local len    = 0

	while i <= bytes do
		len  = len+1
		i    = i+charSize(str:byte(i))
	end

	return len

end



-- Extraherar en del av en sträng
--   print(utf8.sub("Jägare", 2, 4))  -- "äga"
local function sub(str, startIndex, endIndex)

	startIndex  = startIndex or 1
	endIndex    = endIndex or #str

	local byteIndex = 1
	local charIndex = 1

	while charIndex < startIndex do
		charIndex = charIndex+1
		byteIndex = byteIndex+charSize(str:byte(byteIndex))
	end
	local startByte = byteIndex

	local len = #str
	while charIndex <= endIndex and byteIndex <= len do
		charIndex = charIndex+1
		byteIndex = byteIndex+charSize(str:byte(byteIndex))
	end
	local endByte = byteIndex-1

	return str:sub(startByte, endByte)

end



-- Konverterar en sträng till en array
--   utf8.split("bår") -- {"b", "å", "r"}
local function split(str)
	local t = {}
	for i = 1, len(str) do t[i] = sub(str, i, i) end
	return t
end



return {
	charSize = charSize,
	findChar = findChar,
	len = len,
	sub = sub,
	split = split,
}


