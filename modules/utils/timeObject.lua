--=======================================================================================
--=
--=  Tidsobjekt innehållande timma och minut
--=  av 10Fingers
--=
--=  Filuppdateringar:
--=   * 2013-05-08 <MarcusThunström> - set-metoderna returnerar nu tidsobjektet.
--=   * 2013-03-26 <MarcusThunström> - Lade till toArray-metod.
--=   * 2013-03-20 <MarcusThunström> - Lade till __eq, __lt och __le-metametoder.
--=   * 2013-03-18 <MarcusThunström> - Lade till setTotalMinutes-metod.
--=   * 2013-03-15 <MarcusThunström> - Fil skapad.
--=
--[[=====================================================================================



	API-beskrivning:

		require("modules.utils.timeObject")( [hours [, minutes ] ] )
			- hours: Timmar.
			- minutes: Minuter.
			> Returnerar: Ett tidsobjekt (tabell).

		courseBlock:clone(  )
			> Returnerar: Ett nytt tidsobjekt som är identiskt med detta tidsobjekt.

		courseBlock:getHours(  )
			> Returnerar: Timmarna.

		courseBlock:getMinutes(  )
			> Returnerar: Minuterna.

		courseBlock:getTotalMinutes(  )
			> Returnerar: Timmarna och minuterna i minuter.

		courseBlock:setHours( hours )
			- hours: Nya timmar.

		courseBlock:setMinutes( minutes )
			- minutes: Nya minuter.

		courseBlock:setTotalMinutes( minutes )
			- minutes: Nya totala antal minuter. (Görs internt om till timmar och minuter.)

		courseBlock:toArray(  )



	Exempel:

		local newTime = require("modules.utils.timeObject")
		local time1 = newTime(2,10)
		local time2 = newTime(0,40)
		print( time1:getMinutes() ) -- 10
		print( time1 + time2 ) -- 2:50



--=====================================================================================]]



local tenfLib = require('modules.utils.tenfLib')

local api = {}
local libMt = {__index=api}
local lib = {}
setmetatable(lib, libMt)

local k = {}
local methods = {}



-----------------------------------------------------------------------------------------



local instanceMt = {

	__add = function(a, b)
		local hours = a:getHours()+b:getHours()
		local minutes = a:getMinutes()+b:getMinutes()
		hours = math.floor(hours+minutes/60)
		minutes = minutes%60
		return lib(hours, minutes)
	end,

	__sub = function(a, b)
		local hours = a:getHours()-b:getHours()
		local minutes = a:getMinutes()-b:getMinutes()+60*hours
		hours = math.floor(minutes/60)
		minutes = minutes%60
		return lib(hours, minutes)
	end,

	__div = function(a, b)
		return a:getTotalMinutes()/b:getTotalMinutes()
	end,

	__eq = function(a, b)
		return a:getTotalMinutes() == b:getTotalMinutes()
	end,
	__lt = function(a, b)
		return a:getTotalMinutes() < b:getTotalMinutes()
	end,
	__le = function(a, b)
		return a:getTotalMinutes() <= b:getTotalMinutes()
	end,

	__tostring = function(time)
		local minutes = time:getMinutes()
		return time:getHours()..':'..(minutes<10 and '0'..minutes or minutes)
	end,

}



-----------------------------------------------------------------------------------------



function methods.clone(time)
	local data = time[k]
	return lib(data.hours, data.minutes)
end



function methods.getHours(time)
	return time[k].hours
end

function methods.getMinutes(time)
	return time[k].minutes
end

function methods.getTotalMinutes(time)
	local data = time[k]
	return 60*data.hours+data.minutes
end



function methods.setHours(time, hours)
	time[k].hours = hours
	return time
end

function methods.setMinutes(time, minutes)
	if minutes >= 60 then error('minutes must be less than 60 (Note: use setTotalMinutes to set total minutes)', 2) end
	time[k].minutes = minutes
	return time
end

function methods.setTotalMinutes(time, minutes)
	local data = time[k]
	data.hours = math.floor(minutes/60)
	data.minutes = minutes%60
	return time
end



function methods.toArray(time)
	local data = time[k]
	return {data.hours, data.minutes}
end



-----------------------------------------------------------------------------------------



function libMt:__call(hours, minutes)
	local time = tenfLib.setAttr(setmetatable({}, instanceMt), methods)

	local data = {
		hours = hours and hours+math.floor(minutes/60) or 0,
		minutes = minutes and minutes%60 or 0,
	}
	time[k] = data

	return time
end



-----------------------------------------------------------------------------------------



return lib


