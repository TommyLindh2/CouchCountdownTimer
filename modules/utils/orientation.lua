--=======================================================================================
--=
--=  Orientationsmodul
--=  av 10Fingers
--=
--=  Filuppdateringar:
--=   * 2013-04-29 <MarcusThunström> - Lagt till funktioner: getLast, getLastForApp.
--=   * 2013-03-26 <MarcusThunström> - Buggfix för appOrientation-event.
--=   * 2013-03-19 <MarcusThunström> - Lade till appOrientation-event på Runtime.
--=   * 2013-03-07 <MarcusThunström> - Fil skapad.
--=
--[[=====================================================================================



Beskrivning:
	(Notering: argument inom hakparanteser är valfria)

	orientation = require("modules.utils.orientation")

	orientation.getCurrent(  ) :: Returnerar nuvarande orientation.
		> Returnerar: orientationen (sträng).

	orientation.getCurrentForApp(  ) :: Returnerar nuvarande orientation som appen visas i.
		> Returnerar: orientationen (sträng).

	orientation.startMonitor( [defaultOrientation], [supportedOrientations] ) :: Modulen börjar övervaka orientationsändringar.
		- defaultOrientation: startvärde för orientationen. (Default: nil)
		- supportedOrientations: lista med orientationer som getCurrentForApp() ska kunna returnera. (Default: <AllOrientations>)

	orientation.stopMonitor(  ) :: Modulen slutar övervaka orientationsändringar.



Exempel på användande:

	orientation.startMonitor()
	print("Orientation: "..orientation.getCurrent())



--=====================================================================================]]



local lib = {}

local allOrientations = {'portrait', 'portraitUpsideDown', 'landscapeLeft', 'landscapeRight', 'faceUp', 'faceDown'}

local supportedOrientations = allOrientations

local currentOrientation, currentOrientationForApp
local lastOrientation, lastOrientationForApp



local function orientationChangeHandler(e)
	if currentOrientation == e.type then return end
	lastOrientation = currentOrientation
	currentOrientation = e.type
	if currentOrientation ~= currentOrientationForApp and table.indexOf(supportedOrientations, currentOrientation) then
		lastOrientationForApp, currentOrientationForApp = currentOrientationForApp, currentOrientation
		Runtime:dispatchEvent{ name='appOrientation', type=currentOrientationForApp, lastType=lastOrientationForApp }
	end
end



function lib.getCurrent()
	return currentOrientation
end

function lib.getCurrentForApp()
	return currentOrientationForApp
end



function lib.getLast()
	return lastOrientation
end

function lib.getLastForApp()
	return lastOrientationForApp
end



function lib.startMonitor(defaultOrientation, supportedOrientations_)
	if type(defaultOrientation) == 'table' then defaultOrientation, supportedOrientations_ = nil, defaultOrientation end
	Runtime:addEventListener('orientation', orientationChangeHandler)
	supportedOrientations = supportedOrientations_ or allOrientations
	currentOrientation, currentOrientationForApp = defaultOrientation, defaultOrientation
end

function lib.stopMonitor()
	Runtime:removeEventListener('orientation', orientationChangeHandler)
	currentOrientation, currentOrientationForApp = nil, nil
	lastOrientation, lastOrientationForApp = nil, nil
end



return lib


