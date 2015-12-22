--=======================================================================================
--=
--=  Testningsfunktioner av 10FINGERS AB 
--=  testHelper.lua
--=
--=  Filuppdateringar:
--=   * 2013-06-13 <MarcusThunström> - Ny funktion: enableDisplayPrint.
--=   * 2013-04-29 <MarcusThunström> - Brus från widget.newButton-funktionen borttaget.
--=   * 2013-01-26 <MarcusThunström> - Brus från socket-modulen borttaget.
--=   * 2013-01-22 <MarcusThunström> - Brus från lfs-modulen borttaget.
--=   * 2013-01-11 <MarcusThunström> - Uppdaterad.
--=   * 2012-08-29 <MarcusThunström> - Fil skapad.
--=
--[[=====================================================================================



Beskrivning:

	testHelper = require("modules.utils.testHelper")

	nameArray = testHelper.getAddedGlobalNames(  )
	nameArray = testHelper.getDefaultGlobalNames(  )
		> Returnerar: En lista med namn på globala variabler.

	testHelper.enableDebugMode( [ produceError = false ] )
		- produceError: Om error-meddelanden ska visas (med radnummer och filnamn) eller om information bara ska printas ut. (default: false)

	testHelper.enableDisplayPrint( [ height [, quality ] ] )
		- height: Höjden på rutan där meddelanden ska printas. (Default=display.contentHeight/3)
		- quality: Kvalitén på texten. Kan vara 0-2 där 2 är bäst kvalité. (Default=2)

	displayObjectArray = testHelper.getHiddenDisplayObjects( [ group ] )
		- group: Vilken grupp som ska kontrolleras. (default: display.getCurrentStage())
		> Returnerar: En array med en grupps display objects vilka är gömda eller positionerade utanför skärmen. Även tomma grupper returneras.

	testHelper.startMonitorTable( table [, simpeOutput [, ignoreIndex [, ignoreNewindex ] ] ] )
		- table: Vilken tabell som ska övervakas.
		- simpeOutput: Om mindre utförlig information ska printas ut. (default: false)
		- ignoreIndex: Om hämtningar av oexisterande attributer ska ignoreras. (default: false)
		- ignoreNewindex: Om tillägg av nya attributer ska ignoreras. (default: false)



Info om debug mode:

	Hur man aktiverar debug mode:
	 * require("modules.utils.testHelper").enableDebugMode() -- printar ut meddelanden
	 * require("modules.utils.testHelper").enableDebugMode(true) -- ger errormeddelanden med radnummer och filnamn

	Funktioner som övervakas:
	 * audio.dispose
	 * audio.play
	 * display.remove



--=====================================================================================]]

local lib = {}



-----------------------------------------------------------------------------------------
-- Globala namn (Måste vara överst i denna fil!)
-- getAddedGlobalNames, getDefaultGlobalNames
-----------------------------------------------------------------------------------------

do

	-- Ta bort "brus":
	require('json')
	require('lfs')
	require('mime')
	require('physics')
	require('socket')
	--require('sprite')
	require('sqlite3')
	pcall(require, 'modules.utils.movieclip')
	--

	local globalNames = {}; for name, _ in pairs(_G) do globalNames[#globalNames+1] = name end

	function lib.getAddedGlobalNames()
		local names = {}
		for name, _ in pairs(_G) do
			if not table.indexOf(globalNames, name) then names[#names+1] = name end
		end
		return names
	end

	function lib.getDefaultGlobalNames()
		return table.copy(globalNames)
	end

end



-----------------------------------------------------------------------------------------
-- Debug mode
-- enableDebugMode
-----------------------------------------------------------------------------------------

do

	local function showMessage(produceError, message, errorLevel)
		message = 'DEBUG: '..message
		if produceError then error(message, errorLevel) else print(message) end
	end

	local debugModeEnabled = false

	function lib.enableDebugMode(produceError)
		if debugModeEnabled then return end
		debugModeEnabled = true

		do
			local f, fName = audio.dispose, 'audio.dispose'
			function audio.dispose(...)
				if select(1, ...) == nil then showMessage(produceError, fName..' - argument #1 is nil', 3)
				end
				return f(...)
			end
		end

		do
			local f, fName = audio.play, 'audio.play'
			function audio.play(...)
				if select(1, ...) == nil then showMessage(produceError, fName..' - argument #1 is nil', 3)
				end
				return f(...)
			end
		end

		do
			local f, fName = display.remove, 'display.remove'
			function display.remove(...)
				if select(1, ...) == nil then showMessage(false, fName..' - argument #1 is nil', 3)
				elseif not select(1, ...).parent then showMessage(produceError, fName..' - argument #1 (table or DisplayObject) has no parent', 3)
				end
				return f(...)
			end
		end

	end

end



-----------------------------------------------------------------------------------------
-- Printning på skärm
-- enableDisplayPrint
-----------------------------------------------------------------------------------------

do
	local maxMessages = 50
	local width = display.contentWidth-2

	local tenfLib = require('modules.utils.tenfLib')
	local rawPrint = print
	local screenPrintEnabled = false
	local messages

	function lib.enableDisplayPrint(height, quality)
		if screenPrintEnabled then return end
		height, quality = height or math.round(display.contentHeight/3), quality or 2

		messages = display.newGroup()

		function print(...)
			rawPrint(...)
			if messages[maxMessages] then messages[1]:removeSelf() end
			local y = messages.height
			if messages[1] then y = messages[1].y+y end
			local txtGroup = tenfLib.newGroup(messages)
			txtGroup.y = y
			local str = '['..os.date('%T')..'] '..table.concat(tenfLib.tableMap({...}, tostring), '\t')
			if quality > 1 then
				display.newText(txtGroup, str, 0, 0, width, 0, native.systemFontBold, 10):setFillColor(255,130)
				display.newText(txtGroup, str, 2, 0, width, 0, native.systemFontBold, 10):setFillColor(255,130)
				display.newText(txtGroup, str, 2, 2, width, 0, native.systemFontBold, 10):setFillColor(255,130)
				display.newText(txtGroup, str, 0, 2, width, 0, native.systemFontBold, 10):setFillColor(255,130)
			end
			if quality > 0 then
				display.newText(txtGroup, str, 1, 0, width, 0, native.systemFontBold, 10):setFillColor(255)
				display.newText(txtGroup, str, 2, 1, width, 0, native.systemFontBold, 10):setFillColor(255)
				display.newText(txtGroup, str, 1, 2, width, 0, native.systemFontBold, 10):setFillColor(255)
				display.newText(txtGroup, str, 0, 1, width, 0, native.systemFontBold, 10):setFillColor(255)
			end
			display.newText(txtGroup, str, 1, 1, width, 0, native.systemFontBold, 10):setFillColor(0)
			messages.y = math.min(height-y, 0) + 10
			messages.x = messages.width / 2
		end

		timer.performWithDelay(1000, function() messages:toFront() end, 0)
		screenPrintEnabled = true
	end

end



-----------------------------------------------------------------------------------------
-- Display-objekt
-- getHiddenDisplayObjects
-----------------------------------------------------------------------------------------

do
	local _W, _H = display.contentWidth, display.contentHeight
	local tenfLib = require('modules.utils.tenfLib')

	function lib.getHiddenDisplayObjects(group)
		local objects = {}
		tenfLib.foreach(group or display.getCurrentStage(), function(obj)
			local bounds = obj.contentBounds
			if not obj.isVisible or obj.alpha == 0
				or obj.width == 0 or obj.height == 0
				or obj.contentHeight == 0 or obj.contentWidth == 0
				or bounds.xMax <= 0 or bounds.xMin >= _W
				or bounds.yMax <= 0 or bounds.yMin >= _H
			then
				objects[#objects+1] = obj
			end
		end)
		return objects
	end

end



-----------------------------------------------------------------------------------------
-- Tabellövervakning
-- startMonitorTable
-----------------------------------------------------------------------------------------

do
	local getinfo = debug.getinfo
	local traceback = debug.traceback

	function lib.startMonitorTable(t, simpeOutput, ignoreIndex, ignoreNewindex)
		if getmetatable(t) then print('WARNING: startMonitorTable: cannot monitor tables that already has a metatable.'); return; end
		local attrName = (t == _G and 'global' or 'attribute')
		setmetatable(t, {
			__index = not ignoreIndex and function(t, k)
				local info = getinfo(2, 'Sl')
				if simpeOutput then
					print('Debug note: '..info.short_src..':'..info.currentline..": referencing "..attrName.." '"..tostring(k).."' (a nil value)")
				else
					print(traceback('Debug note\n\t'..info.short_src..':'..info.currentline..": referencing "..attrName.." '"..tostring(k).."' (a nil value)", 2))
				end
				return rawget(t, k)
			end or nil,
			__newindex = not ignoreNewindex and function(t, k, v)
				local info = getinfo(2, 'Sl')
				if simpeOutput then
					print('Debug note: '..info.short_src..':'..info.currentline..": creating new "..attrName.." '"..tostring(k).."'")
				else
					print(traceback('Debug note\n\t'..info.short_src..':'..info.currentline..": creating new "..attrName.." '"..tostring(k).."'", 2))
				end
				rawset(t, k, v)
			end or nil,
		})
	end

end



-----------------------------------------------------------------------------------------

return lib
