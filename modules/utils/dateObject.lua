-----------------------------------------------------------------------------------------
-- dateObject.lua
-- 10FINGERS AB
-- Påbörjad: 2013-04-29 av Erik Torstensson
-- Uppdaterad: 2013-06-13 av Marcus Thunström
--[[-------------------------------------------------------------------------------------


Beskrivning:

	local dateObject = require("dateObject")(t)
		t: Tabell med tid/datum t.ex. som os.date("*t")

	require("dateObject").setDayNames(days)
		days: Lista med namn på dagar

	require("dateObject").setMonthNames(months)
		months: Lista med namn på månader


Exempel på användande:
		
	local dateObject = require("modules.utils.dateObject")(os.date("*t"))

	print(dateObject)
		--> 20 Mars 2013 klockan 10:59
	print(os.date("%c", os.time(dateObject)))
		--> Wed Mar 20 10:59:49 2013

	require("modules.utils.dateObject").setDays{"Mon","Tue","Wed","Thu","Fri","Sat","Sun"}


--]]-------------------------------------------------------------------------------------


local tenfLib = require('modules.utils.tenfLib')

local libFuncs = {}
local libMetatable = {__index=libFuncs}
local lib = setmetatable({}, libMetatable)


local months = {
	'Januari',
	'Februari',
	'Mars',
	'April',
	'Maj',
	'Juni',
	'Juli',
	'Augusti',
	'September',
	'Oktober',
	'November',
	'December'
}


local days = {
	'måndag',
	'tisdag',
	'onsdag',
	'torsdag',
	'fredag',
	'lördag',
	'söndag',
}


function libFuncs.setDayNames(dayNames)
	days = tenfLib.tableMap(dayNames, tenfLib.stringToLower)
end

function libFuncs.setMonthNames(monthNames)
	months = tenfLib.tableCopy(monthNames)
end


local metamethods = {

	__tostring = function(t)
		return t.day..' '..months[t.month]..' '..t.year..' klockan '..t.hour..':'..(t.min<10 and '0'..t.min or t.min)
	end,

	__eq = function(a, b)
		return os.time(a) == os.time(b)
	end,

	__lt = function(a, b)
		return os.time(a) < os.time(b)
	end,

	__le = function(a, b)
		return os.time(a) <= os.time(b)
	end,

}


function libMetatable:__call(t)
	if type(t) == 'number' then t = os.date("*t", t) end
	if type(t.hour) == 'table' and t.hour.getHours then t.hour = t.hour:getHours() end
	if type(t.min) == 'table' and t.min.getMinutes then t.min = t.min:getMinutes() end
	if type(t.month) == 'string' then t.month = table.indexOf(months, t.month) end
	if type(t.wday) == 'string' then t.wday = table.indexOf(days, tenfLib.stringToLower(t.wday)) end

	local currentTime = type(t) == 'table' and _G.setAttr(t, os.date("*t", os.time(t))) or os.date("*t", os.time(t))

	local time = setmetatable(currentTime, metamethods)

	return time
end


return lib

