--=======================================================================================
--=
--=  tenfLib - samling av generella återanvändbara funktioner av 10Fingers AB
--=  Branch: SchemaTasksApp
--=
--=  Uppdateringar:
--=   • 2013-08-29
--=        <MarcusThunström> - Nya funktioner: fontExists, chooseFont, printFonts.
--=   • 2013-08-20
--=        <MarcusThunström> - Nya funktioner: closest, farthest, tableEmpty, tableMigrate, tableFilter.
--=   • 2013-06-26
--=        <MarcusThunström> - Ny funktion: fillObjectInArea.
--=   • 2013-06-18
--=        <MarcusThunström> - Nya funktioner: itemWith, allItemsWith.
--=   • 2013-06-10
--=        <MarcusThunström> - Ny funktion: setEventListenerPosition.
--=   • 2013-05-31
--=        <MarcusThunström> - Nya funktioner: timerPerformWithActualDelay, timerCancel, timerGetRemainingTime.
--=   • 2013-05-30
--=        <MarcusThunström> - Uppdaterat enableFocusOnTouch och enableTouchPhaseEvents.
--=        <MarcusThunström> - removeAllChildren: Nytt argument: recursive. Ny funktion: safeRemove.
--=   • 2013-05-24
--=        <MarcusThunström> - Lagt in tenfLib i 10FConcepts.
--=   • 2013-05-22
--=        <MarcusThunström> - Uppdaterat/lagt till funktioner.
--=   • 2013-03-26
--=        <TommyLind> - Uppdaterat/lagt till funktioner.
--=   • 2013-03-18
--=        <MarcusThunström> - Uppdaterat/lagt till funktioner.
--=   • 2013-03-05
--=        <TommyLind> - Uppdaterat/lagt till funktioner.
--=   • 2013-02-08
--=        <MarcusThunström> - Uppdaterat/lagt till funktioner.
--=   • 2013-01-07
--=        <ErikTorstensson> - Uppdaterat/lagt till funktioner.
--=        <MarcusThunström> - Uppdaterat/lagt till funktioner.
--=   • 2013-01-04
--=        <MarcusThunström> - Uppdaterat/lagt till funktioner.
--=   • 2012-08-30
--=        <TommyLindh> - Uppdaterat/lagt till funktioner.
--=   • 2012-08-29
--=        <MarcusThunström> - Uppdaterat/lagt till funktioner.
--=   • 2012-08-14
--=        <TommyLindh> - Uppdaterat/lagt till funktioner.
--=   • 2012-08-01
--=        <MarcusThunström> - Uppdaterat/lagt till funktioner.
--=   • 2012-07-24
--=        <AlexanderAlesand> - Uppdaterat/lagt till funktioner.
--=   • 2012-07-??
--=        <MarcusThunström> - Fil skapad.
--=
--=======================================================================================
--=
--=  Om du vill lägga till en funktion eller ändra något:
--=   1. Deklarera funktionen som local högst upp på sidan. (Gruppera relaterade funktioner.)
--=   2. Definiera funktionen bland de andra funktionerna.
--=   3. Lägg till din funktions namn i tabellen som returneras längst ner på sidan.
--=   4. Lägg till datum, ditt namn och vad du lagt till/ändrat i uppdateringslistan här ovan. (Viktigt!)
--=   5. Commita!
--=
--=  NOTERA: Om denna fil ligger i ett projekt utanför 10FConcepts/tenfLib-projektet se till att ändra "Branch" här ovan till projektnamnet.
--=
--=======================================================================================



-- Moduler
local utf8; pcall(function() utf8 = require('modules.utils.utf8') end)



-- Funktioner
local addSelfRemovingEventListener, removeEventListeners, setEventListenerPosition
local calculate, compare, executeMathStatement
local changeGroup
local closest, farthest
local copyFile
local enableFocusOnTouch, disableFocusOnTouch, setDefaultFocusOnTouchOverflow
local enableTouchPhaseEvents, disableTouchPhaseEvents
local extractRandom
local fileExists, getMissingFiles
local fitObjectInArea, fillObjectInArea, fitTextInArea
local fontExists, chooseFont, printFonts
local foreach
local generateWord, generateSentences, generateParagraphs
local getCsvTable
local getFileSize
local getKeys, getUniqueValues, getValues
local getLetterOffset, getLetterAtOffset
local getLineHeight
local getRandom
local getScaleFactor
local getTablePathToValue
local getWidth, getHeight
local gotoCurrentScene
local indexOf, indexOfChild, indicesOf, indexWith, indicesWith, indicesContaining, itemWith, allItemsWith
local ipairs_
local isEmpty
local isVowel, isConsonant
local jsonLoad, jsonSave
local latLonDist
local loadSounds, unloadSounds
local localToLocal
local max, min, clamp
local midPoint
local moduleCreate, moduleExists, moduleUnload, requireNew
local newCaret, setDefaultCaretHeight, setDefaultCaretOffset
local newColorTable
local newFormattedText
local newGroup
local newLetterSequence
local newMultiLineText
local newOutlineLetterSequence
local newOutlineText
local newSpriteMultiImageSet
local numberSequence
local numberToString
local orderObjects
local patternEscape
local pointDist
local pointInRect, rectIntersection
local predefArgsFunc
local printObj
local randomize
local randomWithSparsity
local range
local removeAllChildren, safeRemove
local removeTableItem
local round
local runTimeSequence
local sceneRemoveAfterExit
local setAttr, setKeys, setMissing
local setTableValue, getTableValue
local shuffleList
local splitEquation
local sqlBool, sqlInt, sqlStr
local stopPropagation, stopImmediatePropagation
local stringCount
local stringMatchAll
local stringPad
local stringSplit
local stringToLower, stringToUpper
local tableCompare
local tableCopy
local tableDiff, tableCount
local tableEmpty, tableMigrate
local tableFilter
local tableGetAttr
local tableInsertUnique
local tableLimitLength, tableFillEmpty
local tableMap, tableMapRecursive
local tableMerge, tableMergeUnique
local tableReverse
local tableSlice
local tableSum
local timerCancel, timerGetRemainingTime, timerPerformWithActualDelay
local toFileName
local trim, shortenText
local wordwrap
local xmlGetChild
local xor






-- Lägger till en eventlistener som bara exekveras högst en gång
function addSelfRemovingEventListener(object, eventName, handler)
	local function localHandler(e)
		object:removeEventListener(eventName, localHandler)
		handler(e)
	end
	object:addEventListener(eventName, localHandler)
end



--[[
	removeEventListeners()
		Tar bort alla eventlisteners på ett objekt.

	Beskrivning:
		removeEventListeners( object [, eventName [, recursiveRemove ] ] )
			- object: Det DisplayObject som ska påverkas.
			- eventName: Namn på det event vars listeners ska tas bort. nil tar bort alla event listeners. (Default: nil)
			- recursiveRemove: Om event listeners rekursivt ska tas bort från alla underliggande children.

	Exempel:
		local button = newImage("button.png")
		button:addEventListener("touch", function(event)
			print("Touch!")
		end)
		removeEventListeners(obj, "touch")

]]
-- Uppdaterad: 2013-05-16 09:35 av Marcus Thunström
function removeEventListeners(obj, eventName, recursive)
	if eventName then
		if obj._functionListeners then
			local listeners = obj._functionListeners[eventName]
			if listeners then
				for _, handler in ipairs(tableCopy(listeners)) do obj:removeEventListener(eventName, handler) end
			end
		end
		if obj._tableListeners then
			local listeners = obj._tableListeners[eventName]
			if listeners then
				for _, handler in ipairs(tableCopy(listeners)) do obj:removeEventListener(eventName, handler) end
			end
		end
	else
		if obj._functionListeners then
			for eventName, _ in pairs(tableCopy(obj._functionListeners)) do removeEventListeners(obj, eventName) end
		end
		if obj._tableListeners then
			for eventName, _ in pairs(tableCopy(obj._tableListeners)) do removeEventListeners(obj, eventName) end
		end
	end
	if recursive and obj.numChildren then tableMap(obj, removeEventListeners, eventName, recursive) end
end



--[[
	setEventListenerPosition()
		Flyttar en eventlyssnare till angiven position. Detta påverkar i vilken ordningsföljd alla eventlyssnare exekveras på ett objekt.

	Beskrivning:
		setEventListenerPosition( object, eventName, listener, index )
			- object: Det EventDispatcher-objekt som ska påverkas. [EventDispatcher]
			- eventName: Namnet på eventet. [""]
			- listener: Lyssnarfunktionen/tabellen som ska flyttas. [function|{}]
			- index: Vilken index lyssnaren ska flyttas till. Index 1 avfyras först. [1..n]

	Exempel:
		Runtime:addEventListener("enterFrame", lessImportantFunction)
		Runtime:addEventListener("enterFrame", importantFunction)
		setEventListenerPosition(Runtime, "enterFrame", importantFunction, 1)

]]
-- Uppdaterad: 2013-06-10 13:30 av Marcus Thunström
function setEventListenerPosition(obj, eventName, listener, i)
	local listeners = (type(listener) == 'table' and obj._tableListeners or obj._functionListeners)
	listeners = listeners and listeners[eventName] or {}
	local oldI = table.indexOf(listeners, listener)
	if not oldI then
		local info = debug.getinfo(2, 'Sl')
		print(debug.traceback('WARNING\n\t'..info.short_src..':'..info.currentline..': listener is not added', 2))
		return
	end
	table.insert(listeners, i, table.remove(listeners, oldI))
end







-- Utför en simpel uträkning och returnerar resultatet
-- Exempel:
--   print(calculate(4, "+", 3)) -- 7
--   print(calculate(9, "/", 2)) -- 4.5
--   print(calculate(11, "foo", 14)) -- nil
-- Uppdaterad: 2012-04-14 11:00 av Marcus Thunström
function calculate(nr1, op, nr2)
	if op == '+' then return nr1+nr2
	elseif op == '-' then return nr1-nr2
	elseif op == '*' then return nr1*nr2
	elseif op == '/' then return nr1/nr2
	elseif op == '%' then return nr1%nr2
	elseif op == '^' then return nr1^nr2
	else return nil end -- error
end



-- Jämför två tal
-- Exempel: compare(2, 5, "<")  -- true
-- Uppdaterad: 2012-09-24 17:20 av Marcus Thunström
function compare(a, b, method)
	method = method or '='
	if     method == '='    then return a == b
	elseif method == '~='   then return a ~= b
	elseif method == '<'    then return a < b
	elseif method == '>'    then return a > b
	elseif method == '<='   then return a <= b
	elseif method == '>='   then return a >= b
	elseif method == '!='   then return a ~= b
	elseif method == '<>'   then return a < b or a > b
	elseif method == 'type' then return type(a) == type(b)
	end
	return nil
end



-- Returnerar värdet av ett matematiskt påstående
-- Variabler och funktioner kan användas i påståendet (Se exempel)
--[[
	Exempel:

		executeMathStatement("1+2")  -- 3
		executeMathStatement("1+x*y", {x=2, y=3})  -- (1+2)*3  = 9

		local funcs = {}
		funcs.randOne = function(currentNumber, operator)
			return false, math.random(3, 5) -- returnerat värde läggs på det gamla värdet
		end
		executeMathStatement("5+randOne", funcs)  -- 5+math.random(3,5)  = [8..10]

		funcs.randTwo = function(currentNumber, operator)
			return true, math.random(3, 5) -- returnerat värde ersätter det gamla värdet
		end
		executeMathStatement("5+randTwo", funcs)  -- math.random(3,5)  = [3..5]

		funcs.mod = function(currentNumber, operator)
			return nil, nil, "%" -- returnera ny operator (men inget nytt värde)
		end
		executeMathStatement("5mod3", funcs)  -- 5%3  = 2

]]
-- Uppdaterad: 2012-09-05 18:05 av Marcus Thunström
function executeMathStatement(eq, funcs)
	local nr, op, funcs = 0, '+', funcs or {}
	for _, part in ipairs(splitEquation(eq)) do
		local func = funcs[part]
		if part == ' ' then
			--void
		elseif func then
			if type(func) == 'function' then
				local absolute, newNr, newOp = funcs[part](nr, op)
				if newOp then op = newOp end
				if absolute then nr = newNr elseif newNr then nr = calculate(nr, op, newNr) end
			else
				nr = calculate(nr, op, func)
			end
		elseif part=='+' or part=='-' or part=='*' or part=='/' or part=='%' or part=='^' then
			op = part
		elseif funcs._nr then
			nr = calculate(nr, op, funcs._nr(tonumber(part)))
		else
			nr = calculate(nr, op, tonumber(part))
		end
	end
	return nr
end







--Flyttar ett object från en grupp till en annan.
--Objektet behåller sin plats på skärmen.

-- Uppdaterad: 2012-08-01 19:50 av Marcus Thunström
function changeGroup(object, group)
	local x, y = localToLocal(object, 0, 0, group)
	group:insert(object)
	object.xOrigin, object.yOrigin = x, y
end







--[[

	closest()
		Retunerar det värde som är närmast angivet värde.

	Beskrivning:
		closest( v, v1 [, ... vN ] )
		 • v: Värde.
		 > vN: Värden att jämföra med.

	Exempel:
		print(closest(  5,  1, 6  )) -- 6
		print(closest(  5,  1, 6, 4.5  )) -- 4.5

]]
-- Uppdaterad: 2013-08-20 12:50 av Marcus Thunström
function closest(v, ...)
	local closestDist, closestValue = math.abs(v-(...)), ...
	for i = 2, select('#', ...) do
		local compareValue = select(i, ...)
		local compareDist = math.abs(v-compareValue)
		if compareDist < closestDist then closestValue, closestDist = compareValue, compareDist end
	end
	return closestValue
end



--[[

	farthest()
		Retunerar det värde som är längst från angivet värde.

	Beskrivning:
		farthest( v, v1 [, ... vN ] )
		 • v: Värde.
		 > vN: Värden att jämföra med.

	Exempel:
		print(farthest(  5,  1, 6  )) -- 1
		print(farthest(  5,  1, 6, 20  )) -- 20

]]
-- Uppdaterad: 2013-08-20 12:55 av Marcus Thunström
function farthest(v, ...)
	local farthestDist, farthestValue = math.abs(v-(...)), ...
	for i = 2, select('#', ...) do
		local compareValue = select(i, ...)
		local compareDist = math.abs(v-compareValue)
		if compareDist > farthestDist then farthestValue, farthestDist = compareValue, compareDist end
	end
	return farthestValue
end







-- Kopierar en fil till en annan fil
function copyFile( copyFromPath, pasteToPath )
	local reader = io.open( copyFromPath, "r" )
	if not reader then
		print ("WARNING: copyFromPath är inte korrekt")
		return false
	end
	local contents = reader:read( "*a" )
	io.close( reader )

	local writer = io.open( pasteToPath, "w" )
	if not writer then
		print ("WARNING: pasteToPath är inte korrekt")
		return false
	end
	writer:write( contents )
	io.close( writer )
	return true
end







--[[
	enableFocusOnTouch()
	disableFocusOnTouch()
		Gör att ett objekt får focus när man trycker på det och förlorar focus när man släpper.

	Beskrivning:
		enableFocusOnTouch( object [, overflow ] )
		disableFocusOnTouch( object )
			- object: Det displayObject som ska ha/sluta ha denna funktionalitet.
			- overflow: Hur mycket objektet ska breda ut sig medans det har fokus. Påverkar hur tidigt event.over blir false. (Default: 0)
		setDefaultFocusOnTouchOverflow( defaultOverflow )
			- defaultOverflow: Hur mycket objekt som standard ska breda ut sig medans de har fokus. Påverkar hur tidigt event.over blir false. (Default: 0)

	Event:
		focusBegan
			Exekveras när objektet får focus.
			Har samma parametrar som touch-event, förrutom 'phase'.
			Returnera true för att stoppa objektet från att få fokus.
		focusMoved
			Exekveras när event.x eller event.y ändras.
			Har samma parametrar som touch-event, förrutom 'phase'.
			event.over är en boolean som säger om event.x och event.y är inom objektets contentBounds (plus overflow).
		focusEnded
			Exekveras när objektet förlorar focus.
			Har samma parametrar som touch-event, förrutom 'phase'.
			event.over är en boolean som säger om event.x och event.y är inom objektets contentBounds (plus overflow).
		focusEndedOver
			Exekveras när objektet förlorar focus och event.x och event.y är inom objektets contentBounds. (Samma som focusEnded när event.over är true.)
			Har samma parametrar som touch-event, förrutom 'phase'.

	Exempel:
		local img = newImage("foo.png")
		enableFocusOnTouch(img)
		img:addEventListener("focusEnded", function(event)
			if event.over then print("Bilden fungerar nu precis som en widget-knapp.") end
		end)

]]
-- Uppdaterad: 2013-06-17 14:30 av Marcus Thunström
do
	local focusKey, overflowKey, defaultOverflow = {}, {}, 0

	local function touchListener(e)
		local obj, p = e.target, e.phase
		if e.stopImmediatePropagation then return true end
		if p == 'began' then
			local focusEvent = tableCopy(e)
			focusEvent.name, focusEvent.phase = 'focusBegan', nil
			local returnValue = obj:dispatchEvent(focusEvent)
			if returnValue == 'stopTouch' then
				e.stopImmediatePropagation = true
				return true
			elseif returnValue then
				return
			end
			display.currentStage:setFocus(obj)
			obj[focusKey] = true
			e.stopImmediatePropagation = true
			return true
		elseif obj[focusKey] then
			local bounds, focusEvent, of = obj.contentBounds, tableCopy(e), obj[overflowKey] or defaultOverflow
			focusEvent.phase = nil
			if p == 'moved' then
				focusEvent.name = 'focusMoved'
				focusEvent.over = pointInRect(e.x, e.y, bounds.xMin-of, bounds.yMin-of, bounds.xMax-bounds.xMin+of*2, bounds.yMax-bounds.yMin+of*2)
				obj:dispatchEvent(focusEvent)
			else
				display.currentStage:setFocus(nil)
				obj[focusKey] = nil
				focusEvent.name = 'focusEnded'
				focusEvent.over = pointInRect(e.x, e.y, bounds.xMin-of, bounds.yMin-of, bounds.xMax-bounds.xMin+of*2, bounds.yMax-bounds.yMin+of*2)
				obj:dispatchEvent(focusEvent)
				if focusEvent.over then
					focusEvent.name, focusEvent.over = 'focusEndedOver', nil
					obj:dispatchEvent(focusEvent)
				end
			end
			e.stopImmediatePropagation = true
			return true
		end
	end

	function enableFocusOnTouch(obj, overflow)
		obj:addEventListener('touch', touchListener)
		obj[overflowKey] = overflow
		return obj
	end

	function disableFocusOnTouch(obj)
		obj:removeEventListener('touch', touchListener)
		obj[overflowKey] = nil
		return obj
	end

	function setDefaultFocusOnTouchOverflow(overflow)
		defaultOverflow = overflow or 0
	end

end



--[[

	enableTouchPhaseEvents()
	disableTouchPhaseEvents()
		Lägger till ytterligare typer av touch-event som inte använder sig av någon phase-paramater.

	Beskrivning:
		enableTouchPhaseEvents( object )
			- object: det DisplayObject som ska avfyra dessa event.
		disableTouchPhaseEvents( object )
			- object: det DisplayObject som ska sluta avfyra dessa event.

	Event:
		touchBegan
			Exekveras när touch-event avfyras och event.phase är "began".
			Har samma parametrar som touch-event, förrutom 'phase'.
		touchMoved
			Exekveras när touch-event avfyras och event.phase är "moved".
			Har samma parametrar som touch-event, förrutom 'phase'.
		touchEnded
			Exekveras när touch-event avfyras och event.phase är "ended" eller "cancelled".
			Har samma parametrar som touch-event, förrutom 'phase'.

	Exempel:
		local img = newImage("foo.png")
		enableTouchPhaseEvents(img)
		img:addEventListener("touchBegan", function(event)
			print("Petade på bilden.")
		end)

]]
-- Uppdaterad: 2013-03-06 16:55 av Marcus Thunström
do
	local phaseEventNames = {began='touchBegan', moved='touchMoved'}
	local standardPhaseEventName = 'touchEnded'

	local function touchListener(e)
		if e.stopImmediatePropagation then return true end
		e = tableCopy(e)
		e.name, e.phase = (phaseEventNames[e.phase] or standardPhaseEventName), nil
		return e.target:dispatchEvent(e)
	end

	function enableTouchPhaseEvents(obj)
		obj:addEventListener('touch', touchListener)
		return obj
	end

	function disableTouchPhaseEvents(obj)
		obj:removeEventListener('touch', touchListener)
		return obj
	end

end







-- Tar bort 'amount' stycken objekt ur en array och returnerar de borttagna objekten
-- Exempel:
--   local allNumbers = {1, 2, 3, 5, 8}
--   local extractedNumbers = extractRandom(allNumbers, 2)
--   -- Om nu extractedNumbers={3,8} så är allNumbers={1,2,5}
--   -- Om istället extractedNumbers={5,1} så är allNumbers={2,3,8}
-- Uppdaterad: 2012-04-14 11:00 av Marcus Thunström
function extractRandom(t, amount)
	local randT = {}
	for i = 1, amount do
		table.insert(randT, table.remove(t, math.random(1, #t)))
	end
	return randT
end







-- Kollar om en fil existerar i ett directory (Åäö konverteras automatiskt till aa, ae och oe)
-- Exempel:
--   print(fileExists("filSomInteFinns.png", system.TemporaryDirectory))  -- false
-- Uppdaterad: 2012-04-23 16:45 av Marcus Thunström
function fileExists(file, dir)
	local path = system.pathForFile(toFileName(file), dir or system.DocumentsDirectory)
	if not path then return false end
	local handle = io.open(path, 'r')
	if handle then
		handle:close()
		return true
	else
		return false
	end
end



--[[

	getMissingFiles()
		Kollar vilka filer som inte existerar.
		Åäö konverteras automatiskt till aa, ae och oe.
		Notera att funktionen inte fungerar som väntat för PNG-bilder i Resources-mappen (p.g.a. pngcrush).

	Beskrivning:
		missingFileArray = getMissingFiles( [path,] fileNames, [extension, [directory] ] )
		 * path: vägen till filen. (Default="")
		 * fileNames: array med filnamn.
		 * extension: filändelse på filerna. (Default="")
		 * directory: vilket directory filerna ligger i. (Default=system.DocumentsDirectory)
		 > Returnerar: en array med filnamnen på de filer som inte finns.

	Exempel:
		local soundNames = {"hej", "räka"}
		local missingSounds = getMissingFiles("sounds/", soundNames, ".mp3")
		print("Ljud som fattas: "..unpack(missingSounds))

]]
-- Uppdaterad: 2012-10-16 17:40 av Marcus Thunström
function getMissingFiles(path, fileNames, ext, dir)
	if type(path) == 'table' then path, fileNames, ext, dir = nil, path, fileNames, ext end
	path, ext = path or '', ext or ''
	local missing = {}
	for _, fileName in ipairs(fileNames) do
		if not fileExists(path..fileName..ext, dir) then missing[#missing+1] = fileName end
	end
	return missing
end







-- Skalar ner ett displayobjekt så det passar i en ruta om objektet är för stort
-- Kan även skala upp för små objekt om 'alwaysScale' är satt
-- Uppdaterad: 2013-05-10 10:05 av Marcus Thunström
function fitObjectInArea(obj, width, height, alwaysScale, defaultScaleX, defaultScaleY)
	if defaultScaleX then obj.xScale = defaultScaleX end
	if defaultScaleY then obj.yScale = defaultScaleY end
	local objW, objH = obj.width, obj.height
	if alwaysScale or objW > width or objH > height then
		local scale = math.min(width/objW, height/objH)
		obj.xScale, obj.yScale = scale, scale
	end
	return obj
end

-- Skalar upp ett displayobjekt så det fyller ut en ruta
-- Kan även skala ner för stora objekt om 'alwaysScale' är satt
-- Uppdaterad: 2013-06-26 11:30 av Marcus Thunström
function fillObjectInArea(obj, width, height, alwaysScale, defaultScaleX, defaultScaleY)
	if defaultScaleX then obj.xScale = defaultScaleX end
	if defaultScaleY then obj.yScale = defaultScaleY end
	local objW, objH = obj.width, obj.height
	if alwaysScale or objW < width or objH < height then
		local scale = math.max(width/objW, height/objH)
		obj.xScale, obj.yScale = scale, scale
	end
	return obj
end



-- Förminskar textstorleken tills textobjektet får plats inom en viss bredd/höjd
-- fitTextInArea( txtObj [, maxWidth [, maxHeight [, aposiopesisString ] ] ] )
-- fitTextInArea( txtObj [, maxWidth [, maxHeight [, scaleAsLastResort [, defaultScaleX [, defaultScaleY ] ] ] ] ] )
-- Om aposiopesisString anges tas bokstäver bort från slutet, annars minskas size-egenskapen, tills textojektet får plats.
-- Om scaleAsLastResort är true skalas objektet tills så får plats om textens storlek inte kan minskas mer.
-- Om defaultScaleX och/eller defaultScaleY är satta så skalas texten till dessa värden innan texten passas in.
--
-- Exempel:
--    local txtObj = display.newText("Hej hallå!")
--    fitTextInArea( txtObj, 100, nil, "..." )
--    alert(txtObj.text) -- "Hej ha..." (eller dylikt om texten inte fick plats)
--
-- Uppdaterad: 2013-05-03 10:30 av Marcus Thunström
--
-- Debugtest
--  str=8 correct=5 >too_much
--  1..8 4 <too_little
--  4..8 6 >too_much
--  4..6 5 <too_little ok!
--  str=7 correct=6 >too_much
--  1..7 4 <too_little
--  4..7 6 <too_little ok!
--  str=7 correct=2 >too_much
--  1..7 4 >too_much
--  1..4 3 >too_much
--  1..3 2 <too_little ok!
--  str=5 correct=1 >too_much
--  1..5 3 >too_much
--  1..3 2 >too_much ok!
do
	local ceil = math.ceil

	--Tommys mod
	function fitTextInArea(txtObj, maxWidth, maxHeight, apoStrOrMinSize, ApoStr)
		if type(apoStrOrMinSize) == 'string' then

			if (maxWidth and txtObj.width*txtObj.xScale > maxWidth) or (maxHeight and txtObj.height*txtObj.yScale > maxHeight) then
				local str = txtObj.text
				local iMin, iMax, loops = 1, utf8.len(str), 0
				for loops = 1, iMax do
					-- print('------------------')
					-- print('#'..loops)
					local len = iMin+ceil((iMax-iMin)/2)
					txtObj.text = utf8.sub(str, 1, len)..apoStrOrMinSize
					if (maxWidth and txtObj.width*txtObj.xScale > maxWidth) or (maxHeight and txtObj.height*txtObj.yScale > maxHeight) then
						-- print('too_much')
						-- print('FROM', iMin..'..'..iMax)
						iMax = len
						-- print('TO', iMin..'..'..iMax)
						if iMax <= iMin+1 then
							txtObj.text = utf8.sub(str, 1, iMax-1)..apoStrOrMinSize
							break
						end
					else
						-- print('too_little')
						-- print('FROM', iMin..'..'..iMax)
						iMin = len
						-- print('TO', iMin..'..'..iMax)
						if iMin >= iMax-1 then
							txtObj.text = utf8.sub(str, 1, iMax-1)..apoStrOrMinSize
							break
						end
					end
				end
			end

		else
			local minSize = apoStrOrMinSize or 3
			while txtObj.size > minSize and ((maxWidth and txtObj.width*txtObj.xScale > maxWidth) or (maxHeight and txtObj.height*txtObj.yScale > maxHeight)) do
				txtObj.size = txtObj.size-2
			end

			if not (txtObj.size > minSize) then
				return fitTextInArea(txtObj, maxWidth, maxHeight, ApoStr)
			end

		end
		return txtObj
	end


	--[[ Originalfunktionen
	function fitTextInArea(txtObj, maxWidth, maxHeight, aposiopesisStr, defaultScaleX, defaultScaleY)
		if type(aposiopesisStr) == 'string' then

			if (maxWidth and txtObj.width*txtObj.xScale > maxWidth) or (maxHeight and txtObj.height*txtObj.yScale > maxHeight) then
				local str = txtObj.text
				local iMin, iMax, loops = 1, utf8.len(str), 0
				for loops = 1, iMax do
					-- print('------------------')
					-- print('#'..loops)
					local len = iMin+ceil((iMax-iMin)/2)
					txtObj.text = utf8.sub(str, 1, len)..aposiopesisStr
					if (maxWidth and txtObj.width*txtObj.xScale > maxWidth) or (maxHeight and txtObj.height*txtObj.yScale > maxHeight) then
						-- print('too_much')
						-- print('FROM', iMin..'..'..iMax)
						iMax = len
						-- print('TO', iMin..'..'..iMax)
						if iMax <= iMin+1 then
							txtObj.text = utf8.sub(str, 1, iMax-1)..aposiopesisStr
							break
						end
					else
						-- print('too_little')
						-- print('FROM', iMin..'..'..iMax)
						iMin = len
						-- print('TO', iMin..'..'..iMax)
						if iMin >= iMax-1 then
							txtObj.text = utf8.sub(str, 1, iMax-1)..aposiopesisStr
							break
						end
					end
				end
			end

		else

			if defaultScaleX then txtObj.xScale = defaultScaleX end
			if defaultScaleY then txtObj.yScale = defaultScaleY end

			while txtObj.size > 3 and ((maxWidth and txtObj.width*txtObj.xScale > maxWidth) or (maxHeight and txtObj.height*txtObj.yScale > maxHeight)) do
				txtObj.size = txtObj.size-2
			end

			if aposiopesisStr then
				if maxWidth and txtObj.width*txtObj.xScale > maxWidth then txtObj.width = maxWidth end
				if maxHeight and txtObj.height*txtObj.yScale > maxHeight then txtObj.height = maxHeight end
			end

		end
		return txtObj
	end
	--]]
end







do
	local fontNames = {}
	for k,v in pairs(native.getFontNames()) do
		fontNames[v] = v
	end

	-- Kollar om en font existerar på enheten
	-- Exempel: print(fontExists("HelveticaNeue"))
	-- Uppdaterad: 2013-08-29 9:25 av Marcus Thunström
	function fontExists(fontName)
		if not fontNames then
			fontNames = setKeys({}, native.getFontNames(), true)
			fontNames[native.systemFont] = true
			fontNames[native.systemFontBold] = true
		end
		return fontNames[fontName] or false
	end

	-- Returnerar det första av angivna typsnitt som finns på enheten, eller nil om ingen finns
	-- Exempel: local font = chooseFont("HelveticaNeue", "Times-Roman", "ArialNarrow") or native.systemFont
	-- Uppdaterad: 2013-08-29 9:25 av Marcus Thunström
	function chooseFont(...)
		for _, fontName in ipairs({...}) do
			if fontNames[fontName] then return fontName end
		end
		return nil
	end

	function printFonts()
		for i, fontName in ipairs(native.getFontNames()) do
			print(i, fontName)
		end
	end

end







-- Kör en funktion på alla objekt i en array eller grupp
-- Uppdaterad: 2012-09-13 15:35 av Marcus Thunström
function foreach(tableOrGroup, callback, reverse)
	local from, to, step = 1, tableOrGroup.numChildren or #tableOrGroup, 1
	if reverse then from, to, step = to, from, -1 end
	for i = from, to, step do
		if callback(tableOrGroup[i], i) then break end
	end
end







-- Skapar ett påhittat ord
-- Uppdaterad: 2013-05-21 09:30 av Marcus Thunström
function generateWord(minLetters, maxLetters, case, allowSpecial)
	local len, rand, sub, upper = utf8.len, math.random, utf8.sub, tenfLib.stringToUpper
	local vowels, consonants, word, vowel = 'aeiouy'..(allowSpecial and 'åäö' or ''), 'bcdfghjklmnpqrstvwxz', '', (rand(3) == 1)
	for pos = 1, rand(minLetters, maxLetters) do
		local letters = vowel and vowels or consonants
		local i = rand(1, len(letters))
		local letter = sub(letters, i, i)
		if case == 'upper' or (case == 'title' and pos == 1) then letter = upper(letter) end
		word = word..letter
		vowel = not vowel
	end
	return word
end

-- Skapar meningar på ett påhittat språk
-- Uppdaterad: 2013-05-21 09:30 av Marcus Thunström
function generateSentences(minLetters, maxLetters, minWords, maxWords, minSentences, maxSentences, allowSpecial)
	local concat, rand = table.concat, math.random
	local sentences = {}
	for sentenceI = 1, rand(minSentences, maxSentences) do
		local words = {}
		for wordI = 1, rand(minWords, maxWords) do
			words[wordI] = generateWord(minLetters, maxLetters, wordI == 1 and 'title' or 'lower', allowSpecial)
		end
		local sentence = concat(words, ' '):gsub(' ', function()
			return rand(10) == 1 and (rand(8) == 1 and '; ' or ', ') or ' '
		end)
		sentences[sentenceI] = sentence
	end
	return concat(sentences, '. ')..'.'
end

-- Skapar paragrafer med meningar på ett påhittat språk
-- Uppdaterad: 2013-05-21 14:00 av Marcus Thunström
function generateParagraphs(minLetters, maxLetters, minWords, maxWords, minSentences, maxSentences, minParagraphs, maxParagraphs, allowSpecial, paragraphGlue)
	local paragraphs = {}
	for i = 1, math.random(minParagraphs, maxParagraphs) do
		paragraphs[i] = generateSentences(minLetters, maxLetters, minWords, maxWords, minSentences, maxSentences, allowSpecial)
	end
	return table.concat(paragraphs, paragraphGlue or '\n')
end







-- Konverterar en fil innehållande CSV-data till en array med tables (OBSOLET! Använd utils.dataObject från 10FConcepts istället)
-- Första raden i CSV-filen används som kolumn/attributnamn
--   getCsvTable(fileName, [dir,] [colNames])
-- Uppdaterad: 2012-08-28 12:00 av Marcus Thunström
function getCsvTable(fileName, dir, colNames)
	if type(dir) ~= 'userdata' then dir, colNames = nil, dir end

	local path = system.pathForFile(fileName, dir or system.ResourceDirectory)
	if not path then return nil end
	local file = io.open(path, 'r')

	local contents = file:read('*a')
	io.close(file)

	local lines = {}

	local values = {}
	local valueStart = 1
	local isInQuote = false
	local isQuote = false
	local lastChar = nil
	for i = 1, #contents+1 do
		local char = contents:sub(i, i)
		isQuote = (char == '"')
		if isInQuote then

			if isQuote then
				isInQuote = false
				isQuote = true
			elseif char == '' then
				error('EOF reached - missing a quote sign in '..fileName, 2)
			end

		else--if not isInQuote then

			if isQuote then
				isInQuote = true
			elseif (char == '\n' or char == '') and lastChar == '\n' then
				valueStart = i+1
			elseif char == ',' or char == '\n' or char == '' then
				local valueEnd = i-1
				if lastChar == '"' then valueStart = valueStart+1; valueEnd = valueEnd-1 end
				if valueEnd < valueStart then
					values[#values+1] = ''
				else
					values[#values+1] = contents:sub(valueStart, valueEnd):gsub('""', '"')
				end
				valueStart = i+1
				if char ~= ',' then
					lines[#lines+1] = values
					values = {}
				end
			end

		end
		lastChar = char
	end--for

	if #lines < 2 then
		return {}
	else
		local cols = lines[1]
		local t = {}
		for i = 2, #lines do
			local line = lines[i]
			local row = {}
			if colNames then
				for i, col in ipairs(cols) do
					local k = colNames[col]
					if k then row[k] = line[i] or '' end
				end
			else
				for i, col in ipairs(cols) do row[col] = line[i] or '' end
			end
			t[#t+1] = row
		end
		return t
	end

end


function getFileSize(_fileName, _dir)
	local reader = io.open( system.pathForFile(toFileName(_fileName), _dir or system.DocumentsDirectory), "r" )
	if not reader then
		print ("WARNING: file doseNotExist")
		return false
	end
	local contents = reader:read( "*a" )
	io.close( reader )
	return contents and #contents
end





-- Listar alla keys som används i en tabell
-- Uppdaterad 2012-08-16 13:50 av Marcus Thunström
function getKeys(t)
	local keys = {}
	for k, _ in pairs(t) do keys[#keys+1] = k end
	return keys
end

-- Listar alla unika värden i en tabell
function getUniqueValues(t)
	local values = {}
	for _, v in pairs(t) do
		values[v] = true
	end
	return getKeys(values)
end

-- Listar alla värden som finns i en tabell eller alla DisplayObjects i en grupp
-- Du kan specifiera vilka index/keys vars värde ska returneras
-- Uppdaterad 2012-10-24 14:45 av Marcus Thunström
function getValues(t, keys)
	local values = {}
	if keys then
		for i, k in ipairs(keys) do
			values[i] = t[k]
		end
	else
		if t.numChildren then
			for i = 1, t.numChildren do values[i] = t[i] end
		else
			for _, v in pairs(t) do values[#values+1] = v end
		end
	end
	return values
end







-- Beräknar en bokstavs x-position i ett textobjekt. (Har support för ÅÄÖ, radbrytningar fungerar ej.)
-- Returnerar även bokstavens början och bokstavens slut.
-- 'char' kan vara en bokstav eller ett index.
-- Uppdaterad 2013-01-03 16:00 av Marcus Thunström

function getLetterOffset(txtObj, char, fontName)
	local i = type(char) == 'number' and char or utf8.findChar(txtObj.text, char)
	local refTxtObj = display.newText(utf8.sub(txtObj.text, 1, i-1), 0, 0, fontName, txtObj.size/getScaleFactor())
	local w1 = refTxtObj.width
	refTxtObj.text = utf8.sub(txtObj.text, 1, i)
	local w2 = refTxtObj.width
	local offset = (w1+w2)/2
	refTxtObj:removeSelf()
	return offset, w1, w2
end



-- Returnerar indexet på bokstaven som finns på angiven x-position i ett textobjekt. (Har support för ÅÄÖ.)
-- Returnerar även vilken sida av bokstaven x-positionen är på ("L" eller "R") och exakt x-start och x-slut för bokstaven.
-- Uppdaterad 2013-01-03 11:15 av Marcus Thunström
function getLetterAtOffset(txtObj, offset, fontName)
	local refTxtObj = display.newText('', 0, 0, fontName, txtObj.size/getScaleFactor())
	local w, lastW, len = 0, 0, utf8.len(txtObj.text)
	for i = 1, len do
		refTxtObj.text = utf8.sub(txtObj.text, 1, i)
		w = refTxtObj.width
		if offset < w and offset >= lastW then
			refTxtObj:removeSelf()
			return i, offset < lastW+(w-lastW)/2 and 'L' or 'R', lastW, w
		end
		if i < len then lastW = w end
	end
	refTxtObj:removeSelf()
	return len, 'R', lastW, w
end







-- Returnerar radhöjden för en text
-- Om singleLine är satt returneras höjden på en rad
-- Uppdaterad 2013-05-15 17:00 av Marcus Thunström
do

	local _W = display.contentWidth
	local newText, remove = display.newText, display.remove

	function getLineHeight(fontName, fontSize, singleLine)
		if singleLine then
			local refTxtObj = newText('A', 0, 0, fontName, fontSize)
			local h = refTxtObj.height
			remove(refTxtObj)
			return h
		else
			local refTxtObj = newText('A\nA', 0, 0, _W, 0, fontName, fontSize)
			local h = refTxtObj.height
			refTxtObj.text = 'A\nA\nA'
			local lineHeight = refTxtObj.height-h
			remove(refTxtObj)
			return lineHeight
		end
	end

end







-- Returnerar ett slumpmässigt objekt från en array eller en grupp
-- Ett intervall kan anges
-- Uppdaterad 2012-09-12 15:00 av Marcus Thunström
function getRandom(t, from, to)
	return t[math.random(from or 1, to or t.numChildren or #t)]
end







-- Returnerar skalfaktorn för text i retina-upplösning
-- alltså 2 för retina och 1 för "vanlig"
-- Uppdaterad 2012-09-25 15:00 av Tommy Lindh
function getScaleFactor()
    local deviceWidth = ( display.contentWidth - (display.screenOriginX * 2) ) / display.contentScaleX
    return math.floor(deviceWidth / display.contentWidth)
end







--[[

	getTablePathToValue()
		Returnerar en array som visar vägen till ett värde i en tabell.
		Kan t.ex. användas tillsammans med setTableValue() för att uppdatera just det värdet.

	Beskrivning:
		path = getTablePathToValue( table, value )
		 * table: tabell att söka igenom.
		 * value: värde att leta efter.
		 > Returnerar: en array med index/keys som representerar sökvägen till värdet, eller nil om värdet inte hittades.

	Exempel:
		local t = {
			foo = "a",
			bar = "b",
			animal = {fish = "c", bird = "d"},
			[4] = "e",
		}
		print(table.concat(getTablePathToValue(t, "c"), ", ")) -- animal, fish

]]
-- Uppdaterad: 2012-12-20 17:10 av Marcus Thunström
do

	local ins = table.insert

	local function explore(t, vToFind, path)
		for k, v in pairs(t) do
			if v == vToFind then
				path[1] = k
				return true
			elseif type(v) == 'table' and explore(v, vToFind, path) then
				ins(path, 1, k)
				return true
			end
		end
		return false
	end

	function getTablePathToValue(t, v)
		local path = {}
		return explore(t, v, path) and path or nil
	end

end







function getWidth(obj)
	return obj.width*obj.xScale
end

function getHeight(obj)
	return obj.height*obj.yScale
end







-- Uppdaterad: innan 2012-07-16 av Marcus Thunström
--[[
function gotoCurrentScene(options)

	local storyboard = require('storyboard')
	local curSceneName = composer.getSceneName("current")

	local overlay = display.captureScreen()

	local tmpSceneName = 'temp'..math.random(10000, 99999)
	local tmpScene = storyboard.newScene(tmpSceneName)

	function tmpScene:createScene()
		self.view:insert(overlay)
		overlay.x, overlay.y = display.contentWidth/2, display.contentHeight/2
	end
	function tmpScene:enterScene()
		storyboard.gotoScene(curSceneName, options)
	end
	function tmpScene:didExitScene()
		storyboard.removeScene(tmpSceneName)
	end

	tmpScene:addEventListener('createScene', tmpScene)
	tmpScene:addEventListener('enterScene', tmpScene)
	tmpScene:addEventListener('didExitScene', tmpScene)

	storyboard.gotoScene(tmpSceneName)

end
--]]






--[[ Notera: ej relevant längre!
-- Buggfix: delvis svart skärm när man går från en scen till samma scen
-- Uppdaterad: 2012-05-09 13:45 av Marcus Thunström
function gotoSceneSlideEffectFix(sceneToFollow, time, offsetX, offsetY)

	tabBar.isVisible = false
	local overlay = display.captureScreen()
	tabBar.isVisible = true

	if sceneToFollow then overlay:toBack() else overlay.isVisible = false end
	overlay:setReferencePoint(display.CenterReferencePoint)

	local handle = {}

	local function efHandle()
		if not sceneToFollow then return end
		overlay.x = sceneToFollow.view.x+(offsetX or 0)
		overlay.y = sceneToFollow.view.y+(offsetY or 0)
	end

	Runtime:addEventListener('enterFrame', efHandle)

	timer.performWithDelay(time, function()
		overlay:removeSelf()
		Runtime:removeEventListener('enterFrame', efHandle)
		handle.setScene = nil
	end)

	function handle:setScene(scene)
		sceneToFollow = scene
		overlay.isVisible = not not scene
		overlay:toBack()
	end

	return handle

end
--]]







-- Returnerar vilket index ett objekt har i en array (precis som table.indexOf)
-- Funktionen fungerar även på displaygrupper
--[[
	Beskrivning:
		index = indexOf( table, value, returnLast, startIndex )
			table: arrayen att söka igenom
			value: värdet att söka efter
			returnLast: om satt, returnerar sista förekomsten av värdet istället för första
			startIndex: på vilket index sökningen ska börja
		index = indexOf( child )
			child: displayobjectet vars position du vill veta
	Exempel:
		t = {"A", "B", "C", "B"}
		indexOf(t, "B")  -- 2
		indexOf(t, "foo")  -- nil
		indexOf(t, "B", true)  -- 4
		group = display.newGroup()
		child1 = newImage(group, "foo.png")
		child2 = newImage(group, "bar.png")
		indexOf(child2)  -- 2
]]
-- Uppdaterad: 2013-03-01 13:40 av Marcus Thunström
function indexOf(t, obj, returnLast, startIndex)
	startIndex = startIndex or 1
	if not obj then t, obj = t.parent, t end
	local from, to, step = startIndex, t.numChildren or #t, startIndex
	if returnLast then from, to, step = to, from, -1 end
	for i = from, to, step do
		if t[i] == obj then return i end
	end
	return nil
end



-- Returnerar vilken position 'child' har i en/sin parent
-- Ger tillbaks nil om 'child' inte finns i 'parent' (om 'parent' har angetts)
-- Uppdaterad: 2012-05-07 14:00 av Marcus Thunström
function indexOfChild(child, parent)
	parent = parent or child.parent
	for i = 1, parent.numChildren do
		if parent[i] == child then return i end
	end
	return nil
end



-- Kollar upp vilka index som innehåller angivet värde i en array
--[[
	Beskrivning:
		indices = indicesOf( table, value, invert )
			table: arrayen att söka igenom.
			value: värdet att söka efter.
			invert: om satt, returnerar alla förekomster som INTE innehåller värdet
	Exempel:
		t = {"A", "B", "A"}
		print(unpack( indicesOf(t, "A") ))  -- 1 3
		print(unpack( indicesOf(t, "A", true) ))  -- 2
]]
-- Uppdaterad: 2013-03-27 13:05 av Marcus Thunström
function indicesOf(t, obj, invert)
	invert = not invert
	local indices = {}
	for i = 1, #t do
		if (t[i] == obj) == invert then indices[#indices+1]=i end
	end
	return indices
end



-- Kollar upp vilket objekt i en array vars specifierad attribut innehåller ett värde
-- Funktionen fungerar även på displaygrupper
--[[
	Beskrivning:
		index = indexWith(table, attr, value, returnLast, invert)
			table: arrayen att söka igenom
			attr: vilket attribut som ska kollas på objekten
			value: värdet att söka efter
			returnLast: om satt, returnerar sista förekomsten av värdet istället för första
			invert: om satt, returnerar alla förekomster som INTE innehåller värdet
	Exempel:
		t = {
			{name = "foo"},
			{name = "bar"},
			{name = "bat"}
			{name = "foo"},
		}
		indexWith(t, "name", "bar")  -- 2
		indexWith(t, "name", "foobar")  -- nil
		indexWith(t, "name", "foo", true)  -- 4
		indexWith(t, "name", "foo", false, true)  -- 2
]]
-- Uppdaterad: 2012-08-16 09:50 av Marcus Thunström
function indexWith(t, attr, obj, returnLast, invert, startIndex)
	invert = not invert
	local from, to, step
	if returnLast then
		from, to, step = startIndex or t.numChildren or #t, 1, -1
	else
		from, to, step = startIndex or 1, t.numChildren or #t, 1
	end
	if attr then
		for i = from, to, step do
			if (t[i][attr] == obj) == invert then return i, t[i] end
		end
	else -- obj = key/value pairs
		for i = from, to, step do
			local match = true
			for k, v in pairs(obj) do
				if t[i][k] ~= v then match=false; break end
			end
			if match == invert then return i, t[i] end
		end
	end
	return nil, nil
end



-- Kollar upp vilka objekt i arrayen 't' vars attribut 'attr' innehåller 'obj'
-- Sätt invert för 
-- Funktionen fungerar även på displaygrupper
-- Exempel:
--   t = {
--     {name = "foo"},
--     {name = "bar"},
--     {name = "foo"},
--     {name = "bat"}
--   }
--   indicesWith(t, "name", "foo")  -- {1, 3}
--   indicesWith(t, "name", "foobar")  -- {}
--   indicesWith(t, "name", "bat", true)  -- {1, 2, 3}
-- Uppdaterad: 2012-08-28 13:10 av Marcus Thunström
function indicesWith(t, attr, obj, invert)
	invert = not invert
	local indices, objects = {}, {}
	if attr then
		for i = 1, t.numChildren or #t do
			if (t[i][attr] == obj) == invert then indices[#indices+1]=i; objects[#objects+1]=t[i] end
		end
	else -- obj = key/value pairs
		for i = 1, t.numChildren or #t do
			local match = true
			for k, v in pairs(obj) do
				if t[i][k] ~= v then match=false; break end
			end
			if match == invert then indices[#indices+1]=i; objects[#objects+1]=t[i] end
		end
	end
	return indices, objects
end



--[[

	indicesContaining()
		Kollar upp vilka strängar i en array som innehåller en söksträng.
		Det går att ange index var sökningen ska ske i strängarna i arrayen.

	Beskrivning:
		indexArray, stringArray = indicesContaining( array, search [, searchIndex [, invert ] ] )
		 * array: array med strängar att söka igenom.
		 * search: sträng att söka efter.
		 * searchIndex: Var i strängarna i arrayen som matchningen ska ske. (Default=nil)
		 * invert: om index till strängar som INTE matchar ska returneras. (Default=false)
		 > Returnerar: en array med index och en array med de matchande strängarna.

	Exempel:
		local t = {
			"bar",
			"foo",
			"foobar",
			"bat",
		}
		indicesContaining(t, "ba")  -- {1, 3, 4}, {"bar", "foobar", "bat"}
		indicesContaining(t, "ba", 1)  -- {1, 4}, {"bar", "bat"}
		indicesContaining(t, "ba", 1, true)  -- {2, 3}, {"foo", "foobar"}

]]
-- Uppdaterad: 2012-10-03 11:40 av Marcus Thunström
function indicesContaining(t, search, searchIndex, invert)
	invert = not invert
	local indices, strings = {}, {}
	if searchIndex then
		local endIndex = searchIndex+#search-1
		for i, str in ipairs(t) do
			if (str:sub(searchIndex, endIndex) == search) == invert then indices[#indices+1]=i; strings[#strings+1]=str end
		end
	else
		for i, str in ipairs(t) do
			if invert ~= not str:find(search, 1, true) then indices[#indices+1]=i; strings[#strings+1]=str end
		end
	end
	return indices, strings
end



-- itemWith - Samma som indexWith, fast objektet returneras först och sedan indexet
function itemWith(...)
	local i, obj = indexWith(...)
	return obj, i
end



-- allItemsWith - Samma som indicesWith, fast listan med objekt returneras först och sedan listan med index
function allItemsWith(...)
	local indices, objects = indicesWith(...)
	return objects, indices
end







-- ipairs (som vanliga ipairs fast fungerar även på grupper)
-- ipairs( table [, reverse ] )
--  * table: Listan eller gruppen som ska itereras.
--  * reverse: Om det sista elementet ska komma först. (Default: false)
-- Uppdaterad: 2013-04-26 10:50 av Marcus Thunström
do

	local function iterator(t, i)
		i = i+1
		local v = t[i]
		if v then return i, v end
	end

	local function iteratorReverse(t, i)
		i = i-1
		local v = t[i]
		if v then return i, v end
	end

	function ipairs_(t, reverse)
		if reverse then
			return iteratorReverse, t, (t.numChildren or #t)+1
		else
			return iterator, t, 0
		end
	end

end







--[[
	isEmpty()
		Kollar om en variabel innehåller något värde (likt empty-funktionen i PHP).

	Beskrivning:
		isEmpty( value )
			- value: Vilket värde som helst.
			> Returnerar true om variabeln är tom, annars false.

	Exempel:

		-- Tomma värden
		print(isEmpty( nil )) -- true
		print(isEmpty( false )) -- true
		print(isEmpty( 0 )) -- true
		print(isEmpty( '' )) -- true
		print(isEmpty( {} )) -- true

		-- Icke-tomma värden
		print(isEmpty( true )) -- false
		print(isEmpty( 1 )) -- false
		print(isEmpty( 'a' )) -- false
		print(isEmpty( {0} )) -- false (tabellen innehåller ett värde)

]]
-- Uppdaterad: 2013-05-13 17:45 av Marcus Thunström
function isEmpty(v)
	if type(v) == 'table' then
		return not next(v)
	else
		return not v or v == '' or v == 0
	end
end







do
	local vowels = {'a', 'o', 'u', 'å', 'e', 'i', 'y', 'ä', 'ö'}

	function isVowel(letter)
		return not isConsonant(letter)
	end

	function isConsonant(letter)
		return not table.indexOf(vowels, stringToLower(letter))
	end

end







-- Ladda data från en JSON-fil
-- jsonLoad(fileName, dir)
function jsonLoad(fileName, dir)
	local path = system.pathForFile(fileName, dir or system.DocumentsDirectory)
	if not path then return nil end
	local file = io.open(path, 'r')
	if not file then return nil end
	local data = require('json').decode(file:read('*a'))
	io.close(file)
	return data
end

-- Spara data till en JSON-fil
-- jsonSave(fileName, [dir,] data)
function jsonSave(fileName, dir, data)
	if type(dir) ~= 'userdata' then dir, data = nil, dir end
	local path = system.pathForFile(fileName, dir or system.DocumentsDirectory)
	local file = io.open(path, 'w+')
	file:write(require('json').encode(data))
	io.close(file)
end







-- Räknar ut avståndet mellan två latitud/longitud-koordinater
-- Källa: http://www.movable-type.co.uk/scripts/latlong.html
function latLonDist(lat1, lon1, lat2, lon2)

	local R = 6371 -- km
	local dLat = math.rad(lat2-lat1)
	local dLon = math.rad(lon2-lon1)
	local lat1 = math.rad(lat1)
	local lat2 = math.rad(lat2)

	local a = math.sin(dLat/2) * math.sin(dLat/2) +
		math.sin(dLon/2) * math.sin(dLon/2) * math.cos(lat1) * math.cos(lat2) 
	local c = 2 * math.atan2(math.sqrt(a), math.sqrt(1-a)) 
	local d = R * c

	return d

end







-- Laddar flera ljud in i en tabell
--[[
	Beskrivning:
		soundTable = loadSounds(t, [pathPrefix, pathSuffix])
			t: tabell innehållande ljudfilsnamn (se exempel)
			pathPrefix: sträng som läggs till före ljudfilsnamnet när ljudet laddas
			pathSuffix: sträng som läggs till efter ljudfilsnamnet när ljudet laddas (Default = ".mp3")

	Exempel 1:
		local t = {
			["foo"] = 'audio/foo_music.mp3',
			["bar"] = 'audio/bar_sound.mp3',
		}
		local sounds = loadSounds(t)
		audio.play(sounds['foo'])  -- spelar upp 'audio/foo_music.mp3'

	Exempel 2:
		local t = {"foo", "bär"}
		local sounds = loadSounds(t, "audio/", ".mp3")
		audio.play(sounds["bär"])  -- spelar upp 'audio/baer.mp3'
]]
-- Uppdaterad: 2012-09-04 11:15 av Marcus Thunström
function loadSounds(t, pre, suf, fileNameFormat)
	pre, suf = pre or '', suf or '.mp3'
	local sounds = {}
	if type((pairs(t)(t))) == 'number' then
		for _, name in ipairs(t) do sounds[name] = audio.loadSound(pre..toFileName(name, fileNameFormat)..suf) end
	else
		for name, path in pairs(t) do sounds[name] = audio.loadSound(pre..toFileName(path, fileNameFormat)..suf) end
	end
	return sounds
end



-- Kör audio.dispose() på alla ljud i en array eller tabell
-- Uppdaterad: 2012-08-27 09:15 av Marcus Thunström
function unloadSounds(t)
	for _, h in pairs(t) do audio.dispose(h) end
end







-- Returnerar ett displayobjekts koordinater i ett annat objekts koordinatsystem
-- Uppdaterad: 2012-07-17 15:50 av Marcus Thunström
function localToLocal(obj, objX, objY, refSpace)
	local contentX, contentY = obj:localToContent(objX, objY)
	return refSpace:contentToLocal(contentX, contentY)
end







-- Returnerar största argumentet. Fungerar även på tabeller med __gt-metatable-metod.
-- Uppdaterad: 2013-05-10 16:50 av Marcus Thunström
function max(...)
	local v = ...
	for i = 2, select('#', ...) do
		local v2 = select(i, ...)
		if v2 > v then v = v2 end
	end
	return v
end

-- Returnerar minsta argumentet. Fungerar även på tabeller med __lt-metatable-metod.
-- Uppdaterad: 2013-05-10 16:50 av Marcus Thunström
function min(...)
	local v = ...
	for i = 2, select('#', ...) do
		local v2 = select(i, ...)
		if v2 < v then v = v2 end
	end
	return v
end



-- Begränsar ett värde inom ett intervall
-- Uppdaterad: 2013-02-08 15:50 av Marcus Thunström
function clamp(value, min, max, reverseNegativeIntervalBehavior)
	if reverseNegativeIntervalBehavior then
		if value >= max then
			return max
		elseif value <= min then
			return min
		else 
			return value
		end
	else
		if value <= min then
			return min
		elseif value >= max then
			return max
		else 
			return value
		end
	end
end







-- Returnerar coordinaten för punkten mitt mellan två punkter
-- Uppdaterad: 2013-05-30 11:20 av Marcus Thunström
function midPoint(x1, x2, y1, y2, z1, z2)
	x1, x2, y1, y2, z1, z2 = x1 or 0, x2 or 0, y1 or 0, y2 or 0, z1 or 0, z2 or 0
	return x1+(x2-x1)/2, y1+(y2-y1)/2, z1+(z2-z1)/2
end







-- Skapar angiven modul (om den inte redan existerar)
-- Sätt 'overwrite' till true för att skriva över existerande modul
-- Uppdaterad: 2012-08-31 09:00 av Marcus Thunström
function moduleCreate(name, content, overwrite)
	if not (overwrite and package.loaded[name]) then package.loaded[name] = content end
	return require(name)
end

-- Kollar om angiven modul existerar
-- Uppdaterad: 2012-08-31 09:00 av Marcus Thunström
function moduleExists(name)
	return not not package.loaded[name]
end

-- Tar bort angiven modul
-- Uppdaterad: 2012-08-31 09:00 av Marcus Thunström
function moduleUnload(name)
	package.loaded[name] = nil
end

-- Tar bort angiven modulen om den finns och returnerar en nyladdad modul
-- Uppdaterad: 2012-08-31 09:00 av Marcus Thunström
function requireNew(name)
	package.loaded[name] = nil
	return require(name)
end







-- Skapar en textmarkör som blinkar. (Kalla på removeSelf eller display.remove som vanligt för att ta bort objektet.)
-- Uppdaterad: 2013-01-03 11:45 av Marcus Thunström
do

	local defaultHeight = 1
	local defaultOffset = 0

	function newCaret(parent, fontName, fontSize, color, x, y, width, heightMod, offsetMod)

		local lineH = getLineHeight(fontName, fontSize)
		local caret = setAttr(display.newLine(0, 0, 0, lineH*(heightMod or defaultHeight)), {x=x,y=y,strokeWidth=width or 2}, {rp='C',c=color})
		caret.yReference = caret.yReference-lineH*(offsetMod or defaultOffset)
		if parent then parent:insert(caret) end
		local timerId

		function caret:reset()
			if timerId then timer.cancel(timerId) end
			caret.isVisible = true
			timerId = timer.performWithDelay(300, function()
				if not caret.parent then timer.cancel(timerId); return; end
				caret.isVisible = not caret.isVisible
			end, 0)
		end

		caret:reset()
		return caret

	end

	function setDefaultCaretHeight(height) defaultHeight = height end
	function setDefaultCaretOffset(offset) defaultOffset = offset end

end







-- newColorTable(50,100,200)  -- {50,100,200,255}
-- newColorTable(75)  -- {75,75,75,255}
-- newColorTable(20,30)  -- {20,20,20,30}
function newColorTable(c1, c2, c3, c4)
	if type(c1) == 'table' then c1,c2,c3,c4 = unpack(c1) end -- {r,g,b,a}
	if c4 then -- r,g,b,a
		return {c1,c2,c3,c4}
	elseif c3 then -- r,g,b
		return {c1,c2,c3,255}
	elseif c2 then -- v,a
		return {c1,c1,c1,c2}
	else -- v
		return {c1,c1,c1,255}
	end
end







--[[

	newFormattedText()
		Skapar en grupp med textobjekt med olika formatering.

	Beskrivning:
		newFormattedText( [parent,] textData [, wrapWidth], [left, top] )
		newFormattedText( [parent,] textData [, settings] )
		 * parent: vilken grupp den formaterade texten ska läggas in i. (Optional, default=nil)
		 * textData: textdata (se 'textdataparametrar' och exempel).
		 * wrapWidth: hur långa raderna får vara. nil = oändligt. (Optional, default=nil)
		 * left: marginal till vänster kant.
		 * top: marginal till övre kant.
		 * settings: inställningsdata (se 'inställningar').
		 > Returnerar: en grupp innehållande textobjekt.

	Textdataparametrar:
		color: textfärg. (Optional, default=nil)
		font: typsnitt. (Optional, default=native.systemFont)
		size: textstorlek.
		text: textsträng.

	Inställningar:
		 * left: marginal till vänster kant.
		 * lineHeight: fast höjd på alla rader (annars används den högsta höjden på textobjekten).
		 * lineMargin: marginal mellan rader vid automatisk radbrytning (när wrapWidth används)
		 * paragraphMargin: marginal mellan rader vid manuell radbrytning med "\n"
		 * top: marginal till övre kant.
		 * wrapWidth: hur långa raderna får vara. nil = oändligt.

	Exempel:
		local wrapWidth, left, top = 500, 150, 130
		local textData = {
			{text="Hej på ", font=native.systemFont, size=64},
			{text="dig", font=native.systemFontBold, size=64, color={240,140,0}},
			{text=" och din ", font=native.systemFont, size=64},
			{text="katt!", font=native.systemFontBold, size=64, color={0,140,240}},
		}
		local textGroup1 = newFormattedText(sceneView, textData, wrapWidth, left, top)
		local textGroup2 = newFormattedText(sceneView, textData, {top=120, paragraphMargin=-10})

]]
-- Uppdaterad: 2012-12-12 14:10 av Marcus Thunström
do

	local function getWords(txtGroup)
		return getValues(txtGroup)
	end

	function newFormattedText(parent, txtData, wrapWidth, left, top)

		if type(txtData) ~= 'table' then parent, txtData, wrapWidth, left, top = nil, parent, txtData, wrapWidth, left end
		if type(wrapWidth) ~= 'table' and not top then wrapWidth, left, top = nil, wrapWidth, left end

		local settings = {
			left = left or 0,
			lineHeight = nil,
			lineMargin = 0,
			paragraphMargin = 0,
			top = top or 0,
			wrapWidth = wrapWidth or nil,
		}
		if type(wrapWidth) == 'table' then settings.wrapWidth = nil; setAttr(settings, wrapWidth); end

		local txtGroup = newGroup(parent)
		txtGroup.x, txtGroup.y = settings.left, settings.top

		txtGroup.getWords = getWords

		local x, y, h = 0, 0, 0
		for _, data in ipairs(txtData) do
			local color = data.color; if color and type(color) ~= 'table' then color = {color} end
			local whitespaces = stringMatchAll(data.text, '%s')
			for i, txt in ipairs(stringSplit(data.text, '%s')) do
				local txtObj = display.newText(txtGroup, ((x==0 or i==1) and txt or ' '..txt), x, y, data.font, data.size)
				if (settings.wrapWidth and txtGroup.width > settings.wrapWidth) or whitespaces[i-1] == '\n' then
					x, y, h = 0, y+h+(whitespaces[i-1] == '\n' and settings.paragraphMargin or settings.lineMargin), 0
					txtObj:removeSelf()
					txtObj = display.newText(txtGroup, txt, x, y, data.font, data.size)
				end
				if color then txtObj:setTextColor(unpack(color)) end
				x, h = x+txtObj.width, settings.lineHeight or math.max(h, getLineHeight(data.font, data.size))
			end
		end

		return txtGroup

	end

end







-- Skapar en grupp direkt i en annan grupp
-- Index kan också anges
-- Uppdaterad: 2013-05-30 10:20 av Marcus Thunström
function newGroup(parent, i)
	local group = display.newGroup()
	if parent then
		if i then parent:insert(i, group) else parent:insert(group) end
	end
	return group
end







-- Skapar en grupp som innehåller alla individuella tecken i en sträng som individuella textobjekt
-- Uppdaterad: 2012-10-10 10:35 av Marcus Thunström
do
	local function increaseSpacing(self, amount)
		amount = amount or 1
		for i = 1, self.numChildren do
			self[i].x = self[i].x+(i-1)*amount
		end
	end
	local function setText(self, txt)
		for i = 1, self.numChildren do
			self[i].text = txt
		end
	end
	local function setTextColor(self, ...)
		for i = 1, self.numChildren do
			self[i]:setTextColor(...)
		end
	end
	function newLetterSequence(parent, str, ...)

		local charGroup = display.newGroup()
		if parent then parent:insert(charGroup) end

		local refText = display.newText('', ...)
		for i = 1, utf8.len(str) do
			--
			local char = utf8.sub(str, i, i)
			local txtObj = display.newText(charGroup, char, ...)
			--
			local w = refText.width
			refText.text = refText.text..char
			txtObj.x = (w+refText.width)/2
			--
		end
		refText:removeSelf()

		charGroup:setReferencePoint(display.CenterReferencePoint)
		charGroup.increaseSpacing = increaseSpacing
		charGroup.setText = setText
		charGroup.setTextColor = setTextColor

		return charGroup

	end
end







--[[

	newMultiLineText()
		Alternativ till display.newText(), fast radbrytningar funkar utan att man behöver specificera bredd och höjd.
		Man kan även ange vilken typ av justering texten ska ha. (Vänster, höger eller centrerat.)
		Notera att texten aldrig bryts automatiskt.

	Beskrivning:
		textGroup = newMultiLineText( [parent,] text, x, y, fontName, fontSize, align )
			- parent: Vilken grupp textgruppen ska läggas in i, om någon alls. (Default=nil)
			- text: Sträng som kan innehålla radbrytningar.
			- x, y: Position för gruppen.
			- fontName, fontSize: Typsnitt och storlek.
			- align: Horisontell textjustering. ("R"=höger, "L"=vänster, "C"=centrerat)
			> Returnerar: En grupp med textobjekt.

	Exempel:
		newMultiLineText(sceneView, "Foo!\nFoobar!!!", 450, 300, native.systemFont, 24, "C")

]]
-- Uppdaterad: 2013-05-15 16:40 av Marcus Thunström
do

	local methods, alignments = {}, {
		R = 'TR',
		C = 'TC',
		L = 'TL',
	}

	function methods.setTextColor(textGroup, ...)
		local args = {...}
		foreach(textGroup, function(txtObj)
			txtObj:setTextColor(unpack(args))
		end)
	end

	function newMultiLineText(parent, txt, x, y, font, size, align)
		if type(parent) ~= 'table' then parent, txt, x, y, font, size, align = nil, parent, txt, x, y, font, size end
		local textGroup = setAttr(newGroup(parent), methods)
		local lineHeight, rp = getLineHeight(font, size), alignments[align] or alignments.L
		for i, txtRow in ipairs(stringSplit(txt, '\n')) do
			setAttr(display.newText(textGroup, txtRow, 0, 0, font, size), {x=0, y=i*lineHeight}, {rp=rp})
		end
		setAttr(textGroup, {x=x, y=y}, {rp='C'})
		return textGroup
	end

end







-- Kombinerar newLetterSequence() och newOutlineText()
-- Uppdaterad: 2012-10-10 10:35 av Marcus Thunström
do
	local function increaseSpacing(self, amount)
		amount = amount or 1
		for i = 1, self.numChildren do
			self[i].x = self[i].x+(i-1)*amount
		end
	end
	local function setText(self, txt)
		for i = 1, self.numChildren do
			self[i].text = txt
		end
	end
	local function setTextColor(self, ...)
		for i = 1, self.numChildren do
			self[i]:setTextColor(...)
		end
	end
	function newOutlineLetterSequence(txtColor, outlineColor, offset, quality, parent, str, ...)

		local charGroup = display.newGroup()
		if parent then parent:insert(charGroup) end

		local refText = display.newText('', ...)
		for i = 1, utf8.len(str) do
			--
			local char = utf8.sub(str, i, i)
			local txtObj = newOutlineText(txtColor, outlineColor, offset, quality, charGroup, char, ...)
			--
			local w = refText.width
			refText.text = refText.text..char
			txtObj.x = (w+refText.width)/2
			--
		end
		refText:removeSelf()

		charGroup:setReferencePoint(display.CenterReferencePoint)
		charGroup.increaseSpacing = increaseSpacing
		charGroup.setText = setText
		charGroup.setTextColor = setTextColor

		return charGroup

	end
end







-- Skapar en text med en färgad outline
--[[
	Beskrivning:
		displayGroup = newOutlineText(textColor, outlineColor, outlineThickness, quality, parent, string, left, top, [width, height,] font, size)
			textColor & outlineColor: RGBA-färg
			outlineThickness: ytterlinjens tjocklek
			quality: hur många textobjekt ytterlinjen ska bestå av
	Exempel:
		local niceText = newOutlineText({0,200,255}, {150,0,0}, 1, 3, nil, "Kalle", 80, 70, "aNiceFont", 32)
]]
-- Uppdaterad: 2012-07-27 14:50 av Marcus Thunström
do

	local function setOutlineColor(self, ...)
		for i = 1, self.numChildren-1 do self[i]:setTextColor(...) end
	end

	local function setText(self, txt)
		for i = 1, self.numChildren do self[i].text = txt end
	end

	local function setTextColor(self, ...)
		self[self.numChildren]:setTextColor(...)
	end

	local mt
	mt = {
		__index = function(self, k)
			if k == 'text' then
				return self[1].text
			else
				setmetatable(self, self.__coronaMt)
				local v = self[k]
				setmetatable(self, mt)
				return v
			end
		end,
		__newindex = function(self, k, v)
			if k == 'text' then
				for i = 1, self.numChildren do self[i].text = v end
			else
				setmetatable(self, self.__coronaMt)
				self[k] = v
				setmetatable(self, mt)
			end
		end,
	}



	function newOutlineText(txtColor, outlineColor, offset, quality, parent, ...)

		local txtGroup = display.newGroup()
		if parent then parent:insert(txtGroup) end

		if type(outlineColor) ~= 'table' then
			outlineColor = {outlineColor, outlineColor, outlineColor, 255}
		end
		local r, g, b, a = unpack(outlineColor)
		a = a or 255

		local ang = 0
		local stepAng = 2*math.pi/quality
		for outline = 1, quality do
			local txtObj = display.newText(txtGroup, ...)
			txtObj:setTextColor(r, g, b, a)
			txtObj.x, txtObj.y = offset*math.sin(ang), offset*math.cos(ang)
			ang = ang+stepAng
		end

		local txtObj = display.newText(txtGroup, ...)
		txtObj:setTextColor(unpack(type(txtColor) == 'table' and txtColor or {txtColor}))
		txtObj.x, txtObj.y = 0, 0

		txtGroup.setText = setText
		txtGroup.setTextColor = setTextColor
		txtGroup.setOutlineColor = setOutlineColor

		txtGroup.__coronaMt = getmetatable(txtGroup)
		setmetatable(txtGroup, mt)

		return txtGroup

	end

end







-- Skapar ett sprite sheet utifrån flera bildfiler med en frame i varje fil (Obsolet!)
-- Uppdaterad: 2012-04-14 11:00 av Marcus Thunström
function newSpriteMultiImageSet(pathPrefix, pathSuffix, frames, w, h)
	local spriteSheets = {}
	for frame = 1, frames do
		local path = pathPrefix..stringPad(tostring(frame), '0', 3, 'L')..pathSuffix
		table.insert(spriteSheets, {
			sheet = sprite.newSpriteSheet(path, w, h),
			frames = {1}
		})
	end
	return sprite.newSpriteMultiSet(spriteSheets)
end







-- Skapar en array med 'amount' antal slumpmässigt unika nummer mellan 'min' och 'max'
-- Det går att ange nummer som alltid ska vara med med 'nrsToKeep'
-- Exempel:
--
--   local numbers = numberSequence(1, 10, 3)
--   -- numbers kan vara t.ex. {2,6,8} eller {1,8,10}
--
--   numbers = numberSequence(1, 10, 4, {1,2} )
--   -- numbers kan vara t.ex. {1,2,4,10} eller {1,2,7,9}
--   -- 1 & 2 är alltid med
--
-- Uppdaterad: 2012-04-14 11:00 av Marcus Thunström
function numberSequence(min, max, amount, nrsToKeep)
	nrsToKeep = nrsToKeep or {}
	local nrs = {}
	for nr = min, max do table.insert(nrs, nr) end
	for i = min, max-amount do
		local loops, iToRemove = 0
		repeat
			loops = loops+1
			if loops > 10000 then return nrs end -- Error: kan inte ta bort till räckligt många nummer?
			iToRemove = math.random(1, #nrs)
		until table.indexOf(nrsToKeep, nrs[iToRemove]) == nil
		table.remove(nrs, iToRemove)
	end
	return nrs
end







-- numberToString()
-- Gör om ett nummer till en sträng (t.ex. numberToString(5) returnerar "fem")
-- Uppdaterad: 2012-10-19 16:00 av Marcus Thunström
-- TODO: dynamiskt sätta ihop mer avancerade nummersträngar - t.ex. numberToString(125) ska returnera names[100]..names[20]..names[5]
do

	local names = {
		[0] = 'noll',
		[1] = 'ett',
		[2] = 'två',
		[3] = 'tre',
		[4] = 'fyra',
		[5] = 'fem',
		[6] = 'sex',
		[7] = 'sju',
		[8] = 'åtta',
		[9] = 'nio',
		[10] = 'tio',
		[11] = 'elva',
		[12] = 'tolv',
		[13] = 'tretton',
		[14] = 'fjorton',
		[15] = 'femton',
		[16] = 'sexton',
		[17] = 'sjutton',
		[18] = 'arton',
		[19] = 'nitton',
		[20] = 'tjugo',
		[30] = 'trettio',
		[40] = 'fyrtio',
		[70] = 'sjuttio',
		[80] = 'åttio',
		[90] = 'nittio',
		[100] = 'hundra',
		[1000] = 'tusen',
	}

	function numberToString(nr)
		return names[nr]
	end

end







-- Ordnar displayObjects efter deras y-värde
-- Uppdaterad: 2012-09-26 17:10 av Marcus Thunström
function orderObjects(group)
	local children = {}
	foreach(group, function(child, i) children[i] = child end)
	table.sort(children, function(a, b) return a.y < b.y end)
	for _, child in ipairs(children) do child:toFront() end
end







function patternEscape(str)
	return (str:gsub('([%.%[%]%^%$%(%)%*%+%?%{%}%%])', '%%%1'))
end







-- Returnerar avståndet mellan två punkter
-- Uppdaterad: 2012-09-05 12:15 av Marcus Thunström
function pointDist(x1, y1, x2, y2)
	return math.sqrt((x1-x2)^2+(y1-y2)^2)
end







-- Kollar om en punkt är inom en rektangel
-- Det finns två sätt att kalla på funktionen:
--   pointInRect(pointX, pointY, rectX, rectY, rectWidth, rectHeight)
--   pointInRect(pointX, pointY, rectObject)
--     rectObject är ett ett objekt med ett x-, y-, width- och height-värde
-- Uppdaterad: 2012-04-14 11:00 av Marcus Thunström
function pointInRect(pointX, pointY, rectX, rectY, w, h)
	if type(rectX) == 'table' then
		local rect = rectX
		rectX, rectY, w, h = rect.x, rect.y, rect.width, rect.height
	end
	return pointX >= rectX and pointY >= rectY and pointX < rectX+w and pointY < rectY+h
end


-- Kollar om två rektanglar överlappar varandra (fungerar med alla display objects)
-- rectIntersection(r1, r2)
-- r1 och r2 är displayobjects.
-- Uppdaterad: 2012-08-30 17:57 av Tommy Lindh
function rectIntersection(r1, r2)
	local bounds1 = r1.contentBounds
	local bounds2 = r2.contentBounds

    return not ( bounds2.xMin > bounds1.xMax
				or bounds2.xMax < bounds1.xMin
				or bounds2.yMin > bounds1.yMax
				or bounds2.yMax < bounds1.yMin
			)
end




-- "Predefined arguments function"
-- Returnerar en funktion som kallar på speciferad function med en uppsättning av fördefinerade argument
-- Exempel:
--   function printString(str)
--     print(str)
--   end
--   printHello = predefArgsFunc(printString, "Hello!")
--   printHello()  -- Hello!
--   printWorld = predefArgsFunc(printString, "world")
--   printWorld()  -- world
-- Uppdaterad: 2012-05-09 16:20 av Marcus Thunström
function predefArgsFunc(func, ...)
	local args = {...}
	return function() return func(unpack(args)) end
end







-- Printar ut objekt på ett bättre sätt
-- Uppdaterad: 2012-11-12 10:20 av Marcus Thunström
function printObj(...)
	local function printObj(o, indent, name)
		if indent > 100 then return end
		if name then
			name = tostring(name)..' = '
		else
			name = ''
		end
		if type(o) == 'table' then
			print(string.rep('\t', indent)..name..'{')
			for i, v in pairs(o) do
				if v == o then
					print(string.rep('\t', indent+1)..name..'SELF')
				else
					printObj(v, indent+1, i)
				end
			end
			print(string.rep('\t', indent)..'}')
		else
			print(string.rep('\t', indent)..name..tostring(o))
		end
	end
	for i, v in ipairs({...}) do
		printObj(v, 0)
	end
end








-- Lägger objekten i en array i slumpmässig ordning (Notera att originalarrayen ändras)
-- Ett intervall kan anges
-- Funktionen kan även blanda runt bokstäver i en utf8-sträng
-- Uppdaterad: 2012-09-12 13:10 av Marcus Thunström
function randomize(t, from, to)
	if type(t) == 'table' then
		from, to = from or 1, to or #t
		if from < 1 then from = #t+from+1 end
		if to < 1 then to = #t+to end
		for i = from, to-1 do table.insert(t, from, table.remove(t, math.random(i, to))) end
		return t
	else--if type(t) == 'string' then
		local indices, len = {}, utf8.len(t)
		for i = 1, len do indices[i] = i end
		for i = 1, len-1 do table.insert(indices, 1, table.remove(indices, math.random(i, len))) end
		local str = ''
		for _, i in ipairs(indices) do str = str..utf8.sub(t, i, i) end
		return str
	end
end







-- Variation av math.random, med mindre risk för specifierade nummer
-- Uppdaterad: 2012-06-20 17:30 av Marcus Thunström
--[[ Slumphetstest:
	for sparsity = 1, 10 do
		print('Sparsity: '..sparsity)
		local counts = {[0]=0, 0, 0, 0, 0, 0}
		for i = 1, 10000 do
			local nr = randomWithSparsity(0, 5, {0, 5}, sparsity)
			counts[nr] = counts[nr]+1
		end
		for i = 0, 5 do
			print('  '..i..': '..counts[i])
		end
	end
--]]
function randomWithSparsity(min, max, sparsities, sparsity)
	sparsities = sparsities or {}
	local nr
	for i = 1, sparsity do
		nr = math.random(min, max)
		if not table.indexOf(sparsities, nr) then return nr end
	end
	return nr
end







-- Fyller en ny array med nummer mellan angivet intervall
-- Exempel:
--    range(3) -- {1,2,3}
--    range(2, 5) -- {2,3,4,5}
--    range(0, 30, 10) -- {0,10,20,30}
-- Uppdaterad: 2012-10-24 14:35 av Marcus Thunström
function range(from, to, step)
	if not to then from, to = 1, from end
	local arr = {}
	for nr = from, to, step or 1 do
		arr[#arr+1] = nr
	end
	return arr
end







-- removeAllChildren( group [, targetGroup ] )
-- removeAllChildren( groupOrList [, recursive ] )
-- Tar bort alla children från en grupp eller lägger alla children i angiven grupp.
-- Kan även ta bort children i en array från deras respektive parent.
-- Om recursive är satt tas alla childrens children bort rekursivt.
-- Om en målgrupp anges returneras den som första värde och 't' som andra värde, annars returneras bara 't'.
-- Uppdaterad: 2013-05-30 13:00 av Marcus Thunström
function removeAllChildren(t, targetGroupOrRecursive)
	if type(targetGroupOrRecursive) == 'table' then
		for i = 1, t.numChildren do targetGroupOrRecursive:insert(t[1]) end
		return targetGroupOrRecursive, t
	else
		for i = t.numChildren or #t, 1, -1 do
			local child = t[i]
			if targetGroupOrRecursive and child.numChildren then removeAllChildren(child, true) end
			if child.parent then child:removeSelf() end
		end
		return t
	end
end



-- safeRemove(group)
-- Tar bort en grupp och alla dess children på ett säkert sätt
function safeRemove(group)
	if group and group.parent then removeAllChildren(group, true):removeSelf() end
	return group
end







-- Tar bort ett objekt från en array (om det finns)
-- Uppdaterad: 2013-02-07 11:30 av Marcus Thunström
function removeTableItem(t, obj)
	local i = table.indexOf(t, obj)
	return i and table.remove(t, i) or nil
end


-- round( _number [, _decimal = 0] )
--Avrundar talet _number med _decimal(standar = 0) st decimaler.

--Uppdaterad: 2013-05-03 av Tommy Lind
function round(_number, _decimal)
	local mult = 10^(_decimal or 0)
 	return math.floor(_number * mult + 0.5) / mult
end







--[[
	runTimeSequence()
		Kör flera transition.to/from, timer.performWithDelay och/eller audio.play efter varann.
		Returnerar ett handle som kan användas för att manipulera sekvensen.


	Beskrivning:

		handle = runTimeSequence( steps )
			- steps: Lista med sekvenssteg:
				- type: Vad detta steg ska göra. ["transition"|"delay"|"sound"] (Default: "transition")
				- delay: Tid innan steget påbörjas. (Påverkar ej ljud.) (Default: 0)
				- time: Under hur lång tid steget ska genomföras. (Default: 500)
				- target: Om type="transition", vilket objekt som köras transition på. Om type="sound", vilket ljud (laddat med audio.loadSound) som ska spelas upp.
				- multi: Om type="transition", en lista med steg som ska genomföras samtidigt. (Kan endast vara transitions för tillfället.)
				- onComplete: Funktion som ska avfyras när steget är klart. (Default: nil)
			> Returnerar: Ett handle (med metoder).

		handle:cancel(  ) :: avbryter sekvensen

		handle:skip(  ) :: avbryter pågående steg och påbörjar nästa steg


	Exempel:
		local o1 = display.newRect(0, 50, 100, 100)
		local o2 = display.newRect(600, 50, 100, 100)
		local steps = {
			{type='delay', time=1000, onComplete=function()print('delay#1')end},
			{target=o1, x=200, time=1000, onComplete=function()print('transition#1')end},
			{type='delay', time=1000, onComplete=function()print('delay#2')end},
			{multi={
				{target=o2, x=400, y=300, time=2000},
				{target=o1, y=300, time=1000},
			}, onComplete=function()print('transition#2')end}
		}
		local handle = runTimeSequence(steps)

]]
-- Uppdaterad: 2013-05-07 17:10 av Marcus Thunström
do
	local performWithDelay  = timer.performWithDelay
	local tranFrom          = transition.from
	local tranTo            = transition.to

	local function performMagic(obj)
		local transitionFunc, target = (obj.from and tranFrom or tranTo), obj.target
		obj.type, obj.target, obj.from = nil, nil, nil
		return transitionFunc, target
	end

	function runTimeSequence(steps)
		local delay         = nil
		local i             = 0
		local soundChannel  = nil
		local timeSequence  = {}
		local transitions   = {}

		local function performNext(...)
			delay = nil
			soundChannel = nil
			transitions = {}
			local step = steps[i]
			if step and step._callback then step._callback(...) end
			i = i+1
			local step = steps[i]
			if not step then return end
			step._callback = step.onComplete

			----------------------------------------------------------------
			if step.type == 'transition' or not step.type then

				local multi = step.multi
				if multi then

					if #multi == 0 then
						performNext()
					else
						local longestPart = multi[1]
						for i = #multi, 2, -1 do
							local part = multi[i]
							if ((part.time or 500) + (part.delay or 0)) > ((longestPart.time or 500) + (longestPart.delay or 0)) then longestPart = part end
						end
						for _, part in ipairs(multi) do
							if part == longestPart then part.onComplete = performNext else part.onComplete = nil end
							local transitionFunc, target = performMagic(part)
							transitions[#transitions+1] = transitionFunc(target, part)
						end
					end

				else

					step.onComplete = performNext
					local transitionFunc, target = performMagic(step)
					transitions = {transitionFunc(target, step)}

				end

			----------------------------------------------------------------
			elseif step.type == 'delay' then

				delay = performWithDelay((step.delay or 0)+(step.time or 500), performNext)

			----------------------------------------------------------------
			elseif step.type == 'sound' and step.target then

				soundChannel = audio.play(step.target, setAttr(step, {onComplete=function(e)
					if e.completed then performNext(e) end
				end}))

			----------------------------------------------------------------
			else
				performNext()
			end

		end

		function timeSequence:cancel()
			if delay then timer.cancel(delay) end
			if soundChannel then audio.stop(soundChannel) end
			for i = 1, #transitions do
				transition.cancel(transitions[i])
			end
			delay = nil
			soundChannel = nil
			transitions = {}
		end

		function timeSequence:skip()
			timeSequence:cancel()
			performNext()
		end

		performNext()
		return timeSequence
	end

end







-- Sätter flera attributer på ett objekt.
-- Kan även sätta speciella parametrar m.h.a. metoder, så som referenspunkten med setReferencePoint().
-- Returnerar argumentobjektet.
-- Specialparametrar:
--   c: color
--   p: parent
--   s: scale
--   rp: reference point
--   fc: fill color
--   sc: stroke color
--   tc: text color
-- Exempel:
--   img = display.newImage('foo.png')
--   setAttr(img, { x=70, rotation=5 })
--   img = display.newImageRect('background.png', 1024, 768)
--   setAttr(img, { x=0, y=0 }, { rp='TL', fc={120,100,255} })
-- Uppdaterad: 2013-03-06 17:20 av Marcus Thunström
do
	local emptyTable = {}
	local rps = {
		TL={0, 0},		--display.TopLeftReferencePoint,
		TC={0.5, 0},	--display.TopCenterReferencePoint,
		TR={1, 0},		--display.TopRightReferencePoint,
		CL={0, 0.5},	--display.CenterLeftReferencePoint,
		C={0.5, 0.5},	--display.CenterReferencePoint,
		CR={0.5, 1},	--display.CenterRightReferencePoint,
		BL={1, 0},		--display.BottomLeftReferencePoint,
		BC={1, 0.5},	--display.BottomCenterReferencePoint,
		BR={1, 1},		--display.BottomRightReferencePoint
	}
	function setAttr(obj, attrs, special)
		attrs = attrs or emptyTable
		special = special or emptyTable
		if special.p then special.p:insert(obj) end
		if special.s then obj:scale(special.s, special.s) end
		-- [[
		if special.rp then
			obj.anchorX, obj.anchorY = rps[special.rp][1], rps[special.rp][2]
			--[[
			if type(special.rp)=='table' then
				obj.xReference,obj.yReference=special.rp[1],special.rp[2]
			else
				obj:setReferencePoint(rps[special.rp])
			end
			--]]
		end
		--]]
		for k, v in pairs(attrs) do obj[k] = v end
		if special.c then obj:setColor(unpack(type(special.c)=='table'and special.c or{special.c})) end
		if special.fc then obj:setFillColor(unpack(type(special.fc)=='table'and not special.fc.color1 and special.fc or{special.fc})) end
		if special.sc then obj:setStrokeColor(unpack(type(special.sc)=='table'and not special.sc.color1 and special.sc or{special.sc})) end
		if special.tc then obj:setFillColor(unpack(type(special.tc)=='table'and not special.tc.color1 and special.tc or{special.tc})) end
		return obj
	end
end



-- Sätter flera attributer på ett objekt.
-- Liknar setAttr, förutom att nycklarna och värderna finns i två olika arrayer.
-- values kan även vara en icke-tabell. Då sätts nycklarna med just det värdet.
--[[
	Exempel:
		local t = {}
		setKeys(t, {"a","b"}, {"Foo","Bar"})
		print(t.a..t.b)  -- FooBar
		setKeys(t, {"c","a"}, "Hello")
		print(t.a..t.b..t.c)  -- HelloBarHello
]]
-- Uppdaterad: 2013-01-31 09:20 av Marcus Thunström
function setKeys(t, keys, values)
	local isValueTable = type(values) == 'table'
	for i, k in ipairs(keys) do
		t[k] = isValueTable and values[i] or values
	end
	return t
end



--[[
	setMissing()
		Sätter attributer som fattas på ett objekt.

	Beskrivning:
		setMissing( t, values )
		 * t: tabellen som ska kompletteras.
		 * values: tabell med standardvärden.
		 > Returnerar: argumenttabellen t.

	Exempel:
		local defaultPerson = { name="Namn Namnsson", age=30, height=175 }
		local person = { name="Hans Hansson", height=179 }
		setMissing(person, defaultPerson)
		print(person.name, person.age)  -- Hans Hansson  30

]]
-- Uppdaterad: 2012-10-19 18:10 av Marcus Thunström
function setMissing(t, values)
	for k, v in pairs(values) do
		if t[k] == nil then t[k] = v end
	end
	return t
end







-- Sätter en attribut i en multidimensionell array/tabell
-- Om en viss dimension inte finns så skapas den (Se exempel)
--[[
	Exempel:
		local t = {}
		setTableValue(t, {1, 2, 3}, "foo")
		print(t[1][2][3])  -- foo
]]
-- Uppdaterad: 2012-08-24 17:25 av Marcus Thunström
function setTableValue(t, path, v)
	if path[2] then
		local k = table.remove(path, 1)
		if not t[k] then t[k] = {} end
		setTableValue(t[k], path, v)
	else
		t[path[1]] = v
	end
end



-- Hämtar en attribut från en multidimensionell array/tabell på ett säkert sätt
-- Om en viss dimension inte finns så ges inget error - funktionen returnerar bara nil (Se exempel)
--[[
	Exempel:

		local t = {a = "foo"}

		print(t.a)  -- foo
		print(getTableValue(t, {"a"}))  -- foo, true

		print(t.a.b)  -- nil
		print(getTableValue(t, {"a", "b"}))  -- nil, true

		print(t.a.b.c)  -- Runtime error: attempt to index field 'b' (a nil value)
		print(getTableValue(t, {"a", "b", "c"}))  -- nil, false  (Inget error här)

]]
-- Uppdaterad: 2012-08-24 17:30 av Marcus Thunström
function getTableValue(t, path)
	if path[2] then
		local k = table.remove(path, 1)
		if not t[k] then return nil, false end
		return getTableValue(t[k], path)
	else
		return t[path[1]], true
	end
end







--Slumpar positionerna på objekten i en lista.
--Valfria upperbound och lowerbound för att slumpa del av listan.

-- Uppdaterad: 2012-09-04 11:50 av Marcus Thunström
function shuffleList(list, lowerBound, upperBound)
	lowerBound = lowerBound or 1
	upperBound = upperBound or #list
	for i = upperBound, lowerBound, -1 do
	   local j = math.random(lowerBound, i)
	   local tempi = list[i]
	   list[i] = list[j]
	   list[j] = tempi
	end
end







-- Delar på en sträng innehållande siffror, tecken och variabler till en array
-- Notera: det bör inte vara något whitespace i strängen
-- Exempel:
--   splitEquation("3+_=10")  -- {"3", "+", "_", "=", "10"}
--   splitEquation("32+x=58+y")  -- {"32", "+", "x", "=", "58", "+", "y"}
-- Uppdaterad: 2012-04-14 11:00 av Marcus Thunström
function splitEquation(str)

	if str == '' then return {} end

	local starts = {}
	local startI, endI

	endI = 0
	while true do -- hitta siffror
		startI, endI = str:find('%d+', endI+1)
		if startI == nil then break end
		starts[#starts+1] = startI
	end
	endI = 0
	while true do -- hitta tecken
		startI, endI = str:find('%p', endI+1)
		if startI == nil then break end
		starts[#starts+1] = startI
	end
	endI = 0
	while true do -- hitta bokstäver/ord
		startI, endI = str:find('[%l%u]+', endI+1)
		if startI == nil then break end
		starts[#starts+1] = startI
	end
	endI = 0
	while true do -- hitta mellanrum
		startI, endI = str:find('%s+', endI+1)
		if startI == nil then break end
		starts[#starts+1] = startI
	end
	table.sort(starts)

	local parts = {}
	for i = 1, #starts-1 do
		parts[#parts+1] = str:sub(starts[i], starts[i+1]-1)
	end
	parts[#parts+1] = str:sub(starts[#starts], #str)
	return parts

end







-- Uppdaterad: 2012-05-15 10:55 av Marcus Thunström
function sqlBool(v)
	return v and 1 or 0
end

-- Uppdaterad: 2012-05-15 10:55 av Marcus Thunström
function sqlInt(v)
	return math.floor(tonumber(v) or 0)
end

-- Uppdaterad: 2012-05-15 10:55 av Marcus Thunström
function sqlStr(v)
	return '"'..(v or ''):gsub('"', '""')..'"'
end







-- Lägg till denna funktion som event listener för att stoppa propagering vid ett visst displayobjekt
-- Exempel:
--   w, h = display.contentWidth, display.contentHeight
--   touchBlocker = display.newRect(0, 0, w, h)
--   touchBlocker:addEventListener("touch", stopPropagation)
function stopPropagation(e)
	return true
end

function stopImmediatePropagation(e)
	e.stopImmediatePropagation = true
	return true
end







-- Räknar antalet sub-strängar i en sträng
-- Exempel:
--   print(stringCount("Hej hej hej!", "hej"))  -- 2
-- Uppdaterad: 2012-04-14 11:00 av Marcus Thunström
function stringCount(strToSearch, strToFind)
	if #strToFind == 0 then return 0 end
	local count = 0
	local _, i = 0, 1
	while true do
		_, i = string.find(strToSearch, strToFind, i+1, true)
		if i == nil then
			return count
		else
			count = count+1
		end
	end
end







-- Returnerar alla matchningar i en sträng m.h.a. string.gmatch()
-- Exempel: printObj(stringMatchAll("Hej på dig!", "[%wåäöÅÄÖ]+")) -- {"Hej", "på", "dig"}
-- Uppdaterad: 2012-12-12 11:30 av Marcus Thunström
function stringMatchAll(str, pattern)
	local matches = {}
	for match in str:gmatch(pattern) do matches[#matches+1] = match end
	return matches
end







-- Fyller ut tomrummet runt en sträng så att strängen får en bestämd längd
-- Exempel:
--   print(stringPad('Hej', '!', 6))  -- Hej!!!
-- Uppdaterad: 2012-04-14 11:00 av Marcus Thunström
function stringPad(str, padding, len, side)
	str, padding, side = tostring(str), tostring(padding), side or 'R'
	if #str < len then
		if side == 'L' then
			return padding:rep(math.floor((len-#str)/#padding))..str
		else
			return str..padding:rep(math.floor((len-#str)/#padding))
		end
	else
		return str
	end
end







-- Delar en sträng till en array.
-- Notera att specialtecken för patterns ej fungerar som delimiters!
-- Exempel:
--   local array = stringSplit("Hej på dig!", " ")
--   print(array[2])  -- "på"
--   local array, delimiters = stringSplit("Hello big\nworld", {" ", "\n"})
--   print(array[2], delimiters[2])  -- "big"  "\n"
-- Uppdaterad: 2013-01-31 17:00 av Marcus Thunström
do local nullChar = string.char(0)

	function stringSplit(str, delimiter)
		local result = {}
		if type(delimiter) == 'table' then

			local delimitersAtSplits = {}
			str = str:gsub('['..table.concat(delimiter, '')..']', function(delimiter)
				delimitersAtSplits[#delimitersAtSplits+1] = delimiter
				return nullChar
			end)
			return stringSplit(str, nullChar), delimitersAtSplits

		else

			local from = 1
			local delimFrom, delimTo = str:find(delimiter, from)
			while delimFrom do
				result[#result+1] = str:sub(from, delimFrom-1)
				from = delimTo + 1
				delimFrom, delimTo = str:find(delimiter, from)
			end
			result[#result+1] = str:sub(from)

		end
		return result
	end

end







-- Ändrar alla bokstäver (inklusive åäö) i en sträng till stora eller små
-- Kan även ta en array med strängar som argument (även multidimensionella arrayer)
-- Uppdaterad: 2012-09-07 11:45 av Marcus Thunström

function stringToLower(str)
	if type(str) == 'table' then
		local arr = {}
		for i, s in ipairs(str) do arr[i] = stringToLower(s) end
		return arr
	else
		return str:lower():gsub('Å', 'å'):gsub('Ä', 'ä'):gsub('Ö', 'ö')
	end
end

function stringToUpper(str)
	if type(str) == 'table' then
		local arr = {}
		for i, s in ipairs(str) do
			arr[i] = stringToUpper(s)
		end
		return arr
	else
		return str:upper():gsub('å', 'Å'):gsub('ä', 'Ä'):gsub('ö', 'Ö')
	end
end







-- Kollar om en tabell innehåller samma värden som en annan tabell (eller flera andra tabeller).
-- Returnerar true om tabellerna är lika.
-- Uppdaterad: 2013-01-31 09:30 av Marcus Thunström
function tableCompare(t1, ...)
	local t1Keys = setKeys({}, getKeys(t1), true)
	for _, t2 in pairs{...} do
		local keys = setKeys(tableCopy(t1Keys), getKeys(t2), true)
		for k, _ in pairs(keys) do
			if t1[k] ~= t2[k] then return false end
		end
	end
	return true
end







-- Kopierar en tabell
-- Uppdaterad: 2012-07-16 09:50 av Marcus Thunström
function tableCopy(t, deepCopy)
	local copy = {}
	if deepCopy then
		for k, v in pairs(t) do
			copy[k] = ((type(v) == 'table') and tableCopy(v, true) or v)
		end
	else
		for k, v in pairs(t) do
			copy[k] = v
		end
	end
	return copy
end







--[[

	tableDiff()
		Returnerar skillnaden mellan arrayer.

	Beskrivning:
		tableDiff( t1, t2 [, ... ] )
		 * t1: arrayen att jämföra från.
		 * t2: arrayen att jämföra mot.
		 * ...: fler arrayer att jämföra mot.
		 > Returnerar: en array med alla värden i 't1' som inte finns i någon annan array.

	Exempel:
		local t1 = {"grön", "röd", "blå", "röd"}
		local t2 = {"grön", "gul", "röd"}
		local difference = tableDiff(t1, t2)
		print(table.concat(difference, ", ")) -- blå

]]
-- Uppdaterad: 2012-10-19 18:10 av Marcus Thunström
function tableDiff(t, ...)
	local len, indexOf, diff = select('#', ...), table.indexOf, {}
	for i, v in ipairs(t) do
		local exists = false
		for arg = 1, len do
			if indexOf(select(arg, ...), v) then exists = true; break end
		end
		if not exists then diff[#diff+1] = v end
	end
	return diff
end


--Uppdaterad: 2013-06-19 av Tommy Lind
function tableCount(_table)
	local count = 0
	for k,v in pairs(_table) do
		count = count + 1
	end
	return count
end




--[[

	tableEmpty()
		Tömmer en tabell.

	Beskrivning:
		tableEmpty( table )
		 • table: Vilken tabell som ska tömmas.
		 > Returnerar: 'table'.

	Exempel:
		local t = {1,5,9}
		t.name = "Kalle"
		tableEmpty(t)
		print(unpack(t)) -- printar inget
		print(t.name) -- nil

]]
-- Uppdaterad: 2013-08-20 12:00 av Marcus Thunström
function tableEmpty(t)
	for k, _ in pairs(t) do t[k] = nil end
	return t
end



--[[

	tableMigrate()
		Flyttar över alla värden från en lista till en annan, alternativt kopierar över dem.
		För att flytta över element mellan DisplayGroups, se removeAllChildren(group, targetGroup)

	Beskrivning:
		tableMigrate( from, to [, keepInOriginal ] )
		 • from: Tabellen att flytta från.
		 • to: Tabellen att flytta till.
		 • keepInOriginal: Om värdena ska kopieras istället för att flyttas.
		 > Returnerar: 'from' och 'to'.

	Exempel - flytta värden:
		local list1, list2 = {1,2}, {8,9}
		tableMigrate( list1, list2 )
		print(unpack(list1)) -- printar inget
		print(unpack(list2)) -- 8 9 1 2

	Exempel - kopiera värden:
		local list1, list2 = {1,2}, {8,9}
		tableMigrate( list1, list2, true )
		print(unpack(list1)) -- 1 2
		print(unpack(list2)) -- 8 9 1 2

]]
-- Uppdaterad: 2013-08-20 12:20 av Marcus Thunström
function tableMigrate(from, to, keepInOriginal)
	if keepInOriginal then
		for i, v in ipairs(from) do to[#to+1] = v end
	else
		for i, v in ipairs(from) do to[#to+1], from[i] = v, nil end
	end
	return from, to
end







--[[

	tableFilter()
		Filtrerar bort värden ur en lista.

	Beskrivning:
		tableFilter( list, filter [, keepFiltered ] )
		 • list: Listan som ska filtreras.
		 • filter: Funktionen som testar om ett värde ska filtreras bort eller inte.
		 • keepFiltered: Om bortfiltrerade värden ska returneras istället för den filtrerade listan. (Default: false)
		 > Returnerar: Den filtrerade listan. (Notera att originallistan förblir oförändrad.)

	Exempel - Sortera bort tal mindre än 3 från en lista:
		local function lessThanThree(v)
			return v < 3
		end
		local list = {1,2,3,4,5}
		local filteredList = tableFilter( list, lessThanThree )
		print(unpack(filteredList)) -- 3 4 5

]]
-- Uppdaterad: 2013-08-20 12:00 av Marcus Thunström
function tableFilter(list, filter, keepFiltered)
	keepFiltered = not keepFiltered
	local returnList = {}
	for _, v in ipairs(list) do
		if not filter(v) == keepFiltered then returnList[#returnList+1] = v end
	end
	return returnList
end







-- Hämtar specifierad attribut hos alla objekt i en array eller grupp
-- Uppdaterad: 2012-12-19 10:50 av Marcus Thunström
--[[
	Exempel:
		local t = {
			{x=1, y=10},
			{x=2, y=15},
			{x=3, y=20},
		}
		tableGetAttr(t, "y")  -- {10,15,20}
]]
function tableGetAttr(t, attr)
	local vals = {}
	foreach(t, function(o) vals[#vals+1] = o[attr] end)
	return vals
end







-- Lägger in ett värde i en tabell om det inte redan finns däri
-- Uppdaterad: 2012-07-25 15:05 av Marcus Thunström
--[[
	Exempel:
		local t = {}
		tableInsertUnique(t, "A")  -- t = {"A"}
		tableInsertUnique(t, "B")  -- t = {"A", "B"}
		tableInsertUnique(t, "A")  -- t = {"A", "B"}
]]
function tableInsertUnique(t, v)
	local unique = true
	for i, tv in ipairs(t) do
		if v == tv then
			unique = false
			break
		end
	end
	if unique then t[#t+1] = v end
	return t
end







-- Kallar på en funktion på alla element i en array eller grupp
-- Returnerar även en lista med alla returnerade värden från callback-kallningarna
-- Uppdaterad: 2013-02-07 11:35 av Marcus Thunström
function tableMap(t, callback, ...)
	local returnT = {}
	for i = 1, t.numChildren or #t do returnT[i] = callback(t[i], ...) end
	return returnT
end



-- Kallar på en funktion rekursivt på alla element i en array eller grupp och dess underelement/children
-- Uppdaterad: 2013-05-22 10:20 av Marcus Thunström
do
	local function map(isGroup, t, callback, ...)
		for i = 1, t.numChildren or #t do
			local v = t[i]
			callback(v, ...)
			if (isGroup and v.numChildren) or (not isGroup and type(v) == 'table') then map(isGroup, v, callback, ...) end
		end
	end

	function tableMapRecursive(t, callback, ...)
		map(not not t.numChildren, t, callback, ...)
	end

end







-- Slår ihop två numrerade arrayer till en array
-- Uppdaterad: 2012-07-27 17:00 av Marcus Thunström
--[[
	Exempel:
		local t1 = {"A", "B"}
		local t2 = {"i", "j"}
		local t3 = {true}
		tableMerge(t1, t2, t3)  -- {"A", "B", "i", "j", true}
]]
function tableMerge(t1, ...)
	local t = table.copy(t1)
	for _, t2 in ipairs{...} do
		for _, v in ipairs(t2) do
			t[#t+1] = v
		end
	end
	return t
end



-- Slår ihop två numrerade arrayer till en array utan att skapa dublettvärden
-- Uppdaterad: 2012-09-27 11:25 av Marcus Thunström
--[[
	Exempel:
		local t1 = {"A", "i", "B", true}
		local t2 = {"i", "j"}
		local t3 = {true}
		tableMergeUnique(t1, t2, t3)  -- {"A", "i", "B", true, "j"}
]]
function tableMergeUnique(t1, ...)
	local t = table.copy(t1)
	for _, t2 in ipairs{...} do
		for _, v in ipairs(t2) do
			tableInsertUnique(t, v)
		end
	end
	return t
end







-- Vänder på en array
-- Uppdaterad: 2013-03-27 10:55 av Marcus Thunström
--[[
	Exempel:
		local t = range(3)
		print( unpack(t) )  -- 1 2 3
		tableReverse(t)
		print( unpack(t) )  -- 3 2 1
]]
function tableReverse(t)
	local len = #t+1
	for i = 1, math.floor(#t/2) do
		t[i], t[len-i] = t[len-i], t[i]
	end
	return t
end







-- Returnerar en del av en array
-- Uppdaterad: 2012-12-14 16:55 av Marcus Thunström
function tableSlice(t, from, length)
	local slice = {}
	for i = from, math.min(from+(length or #t)-1, #t) do slice[#slice+1] = t[i] end
	return slice
end







-- Returnerar summan av alla värden i en tabell
-- Uppdaterad: 2012-10-30 18:00 av Marcus Thunström
function tableSum(t)
	local sum = 0
	for _, v in pairs(t) do sum = sum+v end
	return sum
end







-- Tar bort överflödiga element i en array
-- Uppdaterad: 2012-10-02 15:10 av Marcus Thunström
function tableLimitLength(t, len)
	for i = len+1, #t do t[i] = nil end
	return t
end



-- Fyller en array så att den får angiven längd
-- Uppdaterad: 2013-03-27 11:05 av Marcus Thunström
function tableFillEmpty(t, len, v)
	for i = #t+1, len do t[i] = v end
	return t
end







do
	local lastEventTime, timers = 0, {}

	local function enterFrameHandler()
		local eventTime = os.time()
		if eventTime == lastEventTime then return end
		for id, timerData in pairs(timers) do
			if eventTime >= timerData.endTime then
				timers[id] = nil
				if not next(timers) then Runtime:removeEventListener('enterFrame', enterFrameHandler) end
				timerData.handler(eventTime, timerData.endTime-eventTime)
			end
		end
		lastEventTime = eventTime
	end

	-- Avbryter en timer startad av timerPerformWithActualDelay
	-- timerCancel( timerId )
	-- Uppdaterad: 2013-05-31 14:50 av Marcus Thunström
	function timerCancel(id)
		timers[id] = nil
		if not next(timers) then Runtime:removeEventListener('enterFrame', enterFrameHandler) end
	end

	-- Returnerar resterande tid för en timer
	-- timerGetRemainingTime( timerId )
	-- Uppdaterad: 2013-05-31 15:30 av Marcus Thunström
	function timerGetRemainingTime(id)
		local timerData = timers[id]
		if not timerData then return nil end
		return math.max(timerData.endTime-os.time(), 0)
	end

	-- Exekverar en funktion efter angivet antal sekunder.
	-- Timern använder os.time för tidräkning (istället för system.getTimer som timer-biblioteket använder).
	-- Notera: begränsningar gör att listener-funktionen kan exekveras upp till en sekund innan angiven
	--    tid gått, och om appen är suspenderad så exekveras inte funktionen förrän appen återupptas.
	-- timerId = timerPerformWithActualDelay( timeInSeconds, listener )
	-- Uppdaterad: 2013-05-31 14:50 av Marcus Thunström
	function timerPerformWithActualDelay(time, listener)
		if not next(timers) then Runtime:addEventListener('enterFrame', enterFrameHandler) end
		local id, startTime = {}, os.time()
		timers[id] = {startTime=startTime, endTime=startTime+time, handler=function(eventTime, overtime)
			timers[id] = nil
			if not next(timers) then Runtime:removeEventListener('enterFrame', enterFrameHandler) end
			local e = { name='timer', source=listener, time=eventTime, overtime=overtime }
			if type(listener) == 'table' then
				if listener.timer then listener:timer(e) end
			else
				listener(e)
			end
		end}
		lastEventTime = 0 -- gör att om 'time' är 0 så exekveras funktionen nästa frame
		return id
	end

end







-- Ersätter ÅÄÖ med AA, AE och OE
-- Kan även ytterligare formatera namnet
-- Exempel
--   toFileName("Många rädisor") -- "Maanga raedisor"
--   toFileName("- Hej på räven!!!", "lowercase") -- "hej_paa_raeven"
-- Uppdaterad: 2012-12-19 09:20 av Marcus Thunström
function toFileName(name, format)
	name = name:gsub('Å', 'AA')
	name = name:gsub('Ä', 'AE')
	name = name:gsub('Ö', 'OE')
	name = name:gsub('å', 'aa')
	name = name:gsub('ä', 'ae')
	name = name:gsub('ö', 'oe')
	if format == 'lowercase' then
		name = name:gsub('%W+', '_')
		name = name:gsub('^%W+', '')
		name = name:gsub('%W$', '')
		name = stringToLower(name)
	end
	return name
end







-- Tar bort whitespace-tecken (eller angivna tecken) från början och/eller slutet av en sträng
function trim(str, chars, side)
	if not chars then chars = ' \t\n\r\011' end -- ordinary space, tab, new line (line feed), carriage return, NUL-byte, vertical tab
	local from, to
	if side ~= 'R' then
		from = #str+1
		for i = 1, #str do
			if not chars:find(str:sub(i, i), 1, true) then from = i; break; end
		end
	end
	if side ~= 'L' then
		to = 0
		for i = #str, 1, -1 do
			if not chars:find(str:sub(i, i), 1, true) then to = i; break; end
		end
	end
	return str:sub(from or 1, to)
end

-- Kortar ner en angiven text till ett angivet antal tecken, om antalet tecken är för långt kortas det ner och _lengthIndicator sätts i slutet.
--[[ Exempel:
	local text = "Hej du är så snygg"
	print (shortenText(text, 15, "...")) -> Hej du är så...
	print (shortenText(text, 30, "...")) -> Hej du är så snygg
]]
function shortenText(text, maxLength, lengthIndicator)
	local text = tostring(text)
	local maxLength = maxLength or 999999
	local lengthIndicator = lengthIndicator or ""
	local tempText = utf8.sub(text, 1, math.min(utf8.len(text), maxLength))
	if maxLength > utf8.len(lengthIndicator) then
		if utf8.len(text) > maxLength then
			tempText = utf8.sub(text, 1, maxLength-utf8.len(lengthIndicator))..lengthIndicator
		end
	end
	return tempText
end






-- Källa: http://lua-users.org/wiki/StringRecipes
-- Uppdaterad: innan 2012-05-18 09:55 av Marcus Thunström
function wordwrap(str, limit, indent, indent1)
	indent = indent or ''
	indent1 = indent1 or indent
	limit = limit or 72
	local here = 1-#indent1
	return indent1..str:gsub( '(%s+)()(%S+)()', function(sp, st, word, fi)
		if fi-here > limit then
			here = st - #indent
			return '\n'..indent..word
		end
	end)
end







-- Uppdaterad: 2012-05-14 18:20 av Marcus Thunström
function xmlGetChild(parent, childName)
	for i, child in ipairs(parent.child) do
		if child.name == childName then return child end
	end
	return nil
end







-- Returnerar ett true-värde om endast ett argument är något, annars false
--[[
	Exempel:
		print(xor(false, false))  -- false
		print(xor(true, false))  -- true
		print(xor(false, true))  -- true
		print(xor(true, true))  -- false
		print(xor(nil, true))  -- true
		print(xor(8, false))  -- 8
		print(xor(8, false, 5))  -- false
]]
-- Uppdaterad: 2012-09-11 15:45 av Marcus Thunström
function xor(...)
	local trueAmount = 0
	for _, v in pairs{...} do
		if v then trueAmount = trueAmount+1; trueV = v end
	end
	return trueAmount == 1 and trueV
end







return {
	addSelfRemovingEventListener = addSelfRemovingEventListener,  removeEventListeners = removeEventListeners,  setEventListenerPosition = setEventListenerPosition,
	calculate = calculate,  compare = compare,  executeMathStatement = executeMathStatement,
	changeGroup = changeGroup,
	closest = closest,  farthest = farthest,
	copyFile = copyFile,
	enableFocusOnTouch = enableFocusOnTouch,  disableFocusOnTouch = disableFocusOnTouch,  setDefaultFocusOnTouchOverflow = setDefaultFocusOnTouchOverflow,
	enableTouchPhaseEvents = enableTouchPhaseEvents,  disableTouchPhaseEvents = disableTouchPhaseEvents,
	extractRandom = extractRandom,
	fileExists = fileExists,  getMissingFiles = getMissingFiles,
	fitObjectInArea = fitObjectInArea,  fillObjectInArea = fillObjectInArea,  fitTextInArea = fitTextInArea,
	fontExists = fontExists,  chooseFont = chooseFont,  printFonts = printFonts,
	foreach = foreach,
	generateWord = generateWord,  generateSentences = generateSentences,  generateParagraphs = generateParagraphs,
	getCsvTable = getCsvTable,
	getFileSize = getFileSize,
	getKeys = getKeys,  getUniqueValues = getUniqueValues,  getValues = getValues,
	getLetterOffset = getLetterOffset,  getLetterAtOffset = getLetterAtOffset,
	getLineHeight = getLineHeight,
	getRandom = getRandom,
	getScaleFactor = getScaleFactor,
	getTablePathToValue = getTablePathToValue,
	getWidth = getWidth,  getHeight = getHeight,
	gotoCurrentScene = gotoCurrentScene,
	indexOf = indexOf,  indexOfChild = indexOfChild,  indicesOf = indicesOf,  indexWith = indexWith,  indicesWith = indicesWith,  indicesContaining = indicesContaining,  itemWith = itemWith,  allItemsWith = allItemsWith,
	ipairs = ipairs_,
	isEmpty = isEmpty,
	isVowel = isVowel,  isConsonant = isConsonant,
	jsonLoad = jsonLoad,  jsonSave = jsonSave,
	latLonDist = latLonDist,
	loadSounds = loadSounds,  unloadSounds = unloadSounds,
	localToLocal = localToLocal,
	max = max,  min = min,  clamp = clamp,
	midPoint = midPoint,
	moduleCreate = moduleCreate,  moduleExists = moduleExists,  moduleUnload = moduleUnload,  requireNew = requireNew,
	newCaret = newCaret,  setDefaultCaretHeight = setDefaultCaretHeight,  setDefaultCaretOffset = setDefaultCaretOffset,
	newColorTable = newColorTable,
	newFormattedText = newFormattedText,
	newGroup = newGroup,
	newLetterSequence = newLetterSequence,
	newMultiLineText = newMultiLineText,
	newOutlineLetterSequence = newOutlineLetterSequence,
	newOutlineText = newOutlineText,
	newSpriteMultiImageSet = newSpriteMultiImageSet,
	numberSequence = numberSequence,
	numberToString = numberToString,
	orderObjects = orderObjects,
	patternEscape = patternEscape,
	pointDist = pointDist,
	pointInRect = pointInRect, rectIntersection = rectIntersection,
	predefArgsFunc = predefArgsFunc,
	printObj = printObj,
	randomize = randomize,
	randomWithSparsity = randomWithSparsity,
	range = range,
	removeAllChildren = removeAllChildren,  safeRemove = safeRemove,
	removeTableItem = removeTableItem,
	round = round,
	runTimeSequence = runTimeSequence,
	sceneRemoveAfterExit = sceneRemoveAfterExit,
	setAttr = setAttr,  setKeys = setKeys,  setMissing = setMissing,
	setTableValue = setTableValue,  getTableValue = getTableValue,
	shuffleList = shuffleList,
	splitEquation = splitEquation,
	sqlBool = sqlBool,  sqlInt = sqlInt,  sqlStr = sqlStr,
	stopPropagation = stopPropagation,  stopImmediatePropagation = stopImmediatePropagation,
	stringCount = stringCount,
	stringMatchAll = stringMatchAll,
	stringPad = stringPad,
	stringSplit = stringSplit,
	stringToLower = stringToLower,  stringToUpper = stringToUpper,
	tableCompare = tableCompare,
	tableCopy = tableCopy,
	tableDiff = tableDiff, tableCount = tableCount,
	tableEmpty = tableEmpty,  tableMigrate = tableMigrate,
	tableFilter = tableFilter,
	tableGetAttr = tableGetAttr,
	tableInsertUnique = tableInsertUnique,
	tableLimitLength = tableLimitLength,  tableFillEmpty = tableFillEmpty,
	tableMap = tableMap,  tableMapRecursive = tableMapRecursive,
	tableMerge = tableMerge,  tableMergeUnique = tableMergeUnique,
	tableReverse = tableReverse,
	tableSlice = tableSlice,
	tableSum = tableSum,
	timerCancel = timerCancel,  timerGetRemainingTime = timerGetRemainingTime,  timerPerformWithActualDelay = timerPerformWithActualDelay,
	toFileName = toFileName,
	trim = trim, shortenText = shortenText,
	wordwrap = wordwrap,
	xmlGetChild = xmlGetChild,
	xor = xor,
}






