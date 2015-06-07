--=======================================================================================
--=======================================================================================
--= Globala variabler ===================================================================
--=======================================================================================
--=======================================================================================



-- Device-variabler
_G.isSimulator             = system.getInfo('environment') == 'simulator'
_G.isAndroid               = system.getInfo('platformName') == 'Android'
_G.isIos                   = system.getInfo('platformName') == 'iPhone OS' or system.getInfo('platformName') == 'Mac OS X'
_G.isIpad                  = system.getInfo('model') == 'iPad'

-- Konstanter
_G._W, _G._H               = display.actualContentWidth, display.actualContentHeight
	if _G._W>_G._H then _G._W,_G._H = _G._H,_G._W end
_G._w, _G._h               = _G._W/2, _G._H/2
_G.FPS                     = display.fps
_G.statusBarHeight 		   = display.topStatusBarContentHeight or 0


--SparFiler
local fileExtension = ".json"

_G.myTitlesSaveFile 		= "myTitles" .. fileExtension
_G.mySeriesSaveFile 		= "mySeries" .. fileExtension
_G.myMoviesSaveFile 		= "myMovies" .. fileExtension
_G.mySeenStatesSaveFile  	= "myStates" .. fileExtension
_G.mySettingsSaveFile  		= "mySettings" .. fileExtension
_G.myFiltersSaveFile  		= "myFilters" .. fileExtension
_G.myHiddenSaveFile  		= "myHiddens" .. fileExtension
_G.myLastDownloadSaveFile	= "myLastDownload" .. fileExtension


_G.dataToSendReceive = 
{
	["titles"] = { file = _G.myTitlesSaveFile },
	["series"] = { remove = true, file = _G.mySeriesSaveFile },
	["movies"] = { remove = true, file = _G.myMoviesSaveFile },
	["seenStates"] = { file = _G.mySeenStatesSaveFile },
	["settings"] = { file = _G.mySettingsSaveFile },
	["filters"] = { file = _G.myFiltersSaveFile },
	--["hidden"] = { file = _G.myHiddenSaveFile }
}

-- Moduler
_G.orientation             = require('modules.utils.orientation')
_G.tenfLib                 = require('modules.utils.tenfLib')
_G.traverse                = require('modules.utils.traverse')
_G.utf8                    = require('modules.utils.utf8')
_G.button				   = require('modules.utils.menuButtons')
_G.checkbox				   = require('modules.utils.checkbox')
_G.widget                  = require('widget')
_G.json					   = require('json')



-- Modulfunktioner
_G.indexWith               = tenfLib.indexWith
_G.newGroup                = tenfLib.newGroup
_G.printObj                = tenfLib.printObj
_G.setAttr                 = tenfLib.setAttr

_G.blackoutAlpha           = 0.7

_G.fontName                = _G.tenfLib.chooseFont("Helvetica", "DroidSans", "Roboto-Regular") or native.systemFont
_G.fontNameBold            = _G.tenfLib.chooseFont("Helvetica-Bold", "DroidSans-Bold", "Roboto-Bold") or native.systemFontBold


_G.fontSizeVerySmall       = 12
_G.fontSizeSmall           = 16
_G.fontSizeNormal          = 20
_G.fontSizeLarge           = 24
_G.fontSizeVeryLarge       = 28
_G.scrollDeadZoneRadius    = 6
_G.activationPressTime     = 300
_G.keyEventHandlers 	   = {}

_G.navBarColor = {0.6039, 0.2078, 1}
_G.navBarGradientOverlay = {0, 0.4}
_G.tabBarHeight = 50

_G.buttonColor = {normal = {154 / 255, 53 / 255, 255 / 255}, over = {101 / 255, 0, 202 / 255}}



--=======================================================================================
--=======================================================================================
--= Lokala variabler ====================================================================
--=======================================================================================
--=======================================================================================
--[[
local function doOnAll(obj, func)
	local function doOnAll(obj2, parent, key)
		if type(obj2) == 'table' then
			for i, v in pairs(obj2) do
				doOnAll(v, obj2, i)
			end
		else
			if parent and key then
				parent[key] = func(tostring(obj2))
			end
		end
	end
	if type(obj) == "table" then
		doOnAll(obj)
		return obj
	else
		return func(tostring(obj))
	end
end
--]]
do
	local mime = require("mime")
	_G.base64 = {}
	function _G.base64.encode(data)
		local len = data:len()
		local t = {}
		for i=1,len,384 do
			local n = math.min(384, len+1-i)
			if n > 0 then
				local s = data:sub(i, i+n-1)
				local enc, _ = mime.b64(s)
				t[#t+1] = enc
			end
		end

		return table.concat(t)
	end

	function _G.base64.decode(data)
		local len = data:len()
		local t = {}
		for i=1,len,384 do
			local n = math.min(384, len+1-i)
			if n > 0 then
				local s = data:sub(i, i+n-1)
				local dec, _ = mime.unb64(s)
				t[#t+1] = dec
			end
		end
		return table.concat(t)
	end

end

function _G.getMyData()
	local data = {}

	for name, dataToGet in pairs(_G.dataToSendReceive or {}) do
		local loadedData = _G.tenfLib.jsonLoad(dataToGet.file)
		local dataToSend
		if name == "titles" then
			dataToSend = {}
			for imdbID, titleData in pairs(loadedData) do
				dataToSend[imdbID] = {
					Type = titleData.Type,
					imdbID = imdbID
				}
			end
		elseif not dataToGet.remove then
			dataToSend = loadedData
		end
		data[name] = dataToSend
	end

	local jsonBlob = _G.json.encode(data)
	return _G.base64.encode(jsonBlob)
end

function _G.setMyData(data)

	local jsonBlob = _G.base64.decode(data)
	local tableData = _G.json.decode(jsonBlob)

	if type(tableData) == 'table' then
		for k,v in pairs(_G.dataToSendReceive) do
			if v.remove then
				
				print( "Remove: ", os.remove( system.pathForFile( v.file, system.DocumentsDirectory ) ) )
			end
		end

		for key, dataToSet in pairs(tableData or {}) do
			if _G.dataToSendReceive[key] then
				_G.tenfLib.jsonSave(_G.dataToSendReceive[key].file, dataToSet)
			end
		end
		return true
	else
		return false
	end
end

function _G.reloadMyData()
	_G.reloadMyHiddens()
	_G.reloadMyFilters()
	_G.reloadMySettings()
	_G.reloadMySeenStates()
	_G.reloadMySeries()
	_G.reloadMyMovies()
	_G.reloadMyTitles()
end

-- Moduler
local storyboard         = require('storyboard')

--=======================================================================================
--=======================================================================================
--= Lokala funktioner ===================================================================
--=======================================================================================
--=======================================================================================



--=======================================================================================
--=======================================================================================
--= Globala funktioner ==================================================================
--=======================================================================================
--=======================================================================================

-- stringStartsWith
-- errorAlert
-- getHidden, getHiddens, setHidden
-- setDownloadDate, getDownloadDate, getTimeSinceLastDownload
-- setFilters, getFilters, getAvailableFilters
-- setSettings, getSettings
-- addSeenState, removeSeenState, loadSeenState
-- loadAllMoviesAndSeries
-- addSeries, removeSeries, seriesExists, loadSeries
-- addMovie, removeMovie, movieExists, loadMovie
-- downloadTitles, downloadTitle
-- addTitle, removeTitle, titleExists, loadTitles, loadTitleType
-- getEpisodeString
-- getDateString, getDateFromImdbString, isCompleteDate
-- createTitle, createBg
-- newImage, setRectMask
-- setKeyEventHandlers, getKeyEventHandlers
-- broadcastEvent, dispatchBubblingEvent
-- getDisplayDimensions
-- getDiffTime, convertDiffToTable
-- scheduleNotifications
-- getGradientColor

function _G.stringStartsWith(_string, _value)
	local startIndex = _string:find(_value)
	return startIndex == 1
end

function _G.errorAlert(info, onComplete)
	info = info or {}
	native.setActivityIndicator(false)
	if native.canShowPopup( "sms" ) then
		native.showAlert("Error!", info.messageToUser, {"Ja", "Nej"}, function(e)
			if e.action == "clicked" then
		        if e.index == 1 then
		        	local options =
					{
					   to = { "0736446917"},
					   body = info.message
					}
					native.showPopup( "sms", options )
		        else
		        	-- void
		        end
				if onComplete then onComplete() end
		    end
		end)
	else
		native.showAlert("Error!", "Något gick fel!", {"Ok"}, function(e)
			if e.action == "clicked" then
				if onComplete then onComplete() end
			end
		end)
	end
end

do
	local myHiddens = _G.tenfLib.jsonLoad(_G.myHiddenSaveFile) or {}

	function _G.reloadMyHiddens()
		myHiddens = _G.tenfLib.jsonLoad(_G.myHiddenSaveFile) or {}
	end

	if _G.dataToSendReceive["hidden"] then _G.dataToSendReceive["hidden"].dataTable = myHiddens end

	function _G.getHidden(imdbID)
		return not not myHiddens[imdbID]
	end

	function _G.getHiddens()
		return _G.tenfLib.tableCopy(myHiddens, true)
	end

	function _G.setHidden(imdbID, hidden)
		myHiddens[imdbID] = hidden
		_G.tenfLib.jsonSave(_G.myHiddenSaveFile, myHiddens)
	end
end

do
	local myLastDownloadDate = _G.tenfLib.jsonLoad(_G.myLastDownloadSaveFile) or os.time()

	function _G.setDownloadDate()
		myLastDownloadDate = os.time()
		_G.tenfLib.jsonSave(_G.myLastDownloadSaveFile, myLastDownloadDate)
	end

	function _G.getDownloadDate()
		return myLastDownloadDate
	end

	function _G.getTimeSinceLastDownload()
		return _G.convertDiffToTable( os.time() - _G.getDownloadDate() )
	end

end

do
	local myFilters

	function _G.reloadMyFilters()
		myFilters = _G.tenfLib.jsonLoad(_G.myFiltersSaveFile) or {}
	end
	_G.reloadMyFilters()

	local availableFilters =
	{
		{id = "hideSeries", displayName = "Göm serier"},
		{id = "hideMovies", displayName = "Göm filmer"},
		{id = "hideSeen", displayName = "Göm sedda"},
		{id = "hideUnSeenNotReleased", displayName = "Göm icke släppta"},
		{id = "hideUnSeen", displayName = "Göm osedda"},
		{id = "hideSomeSeen", displayName = "Göm halvsedda"},
		{id = "hideUnknown", displayName = "Göm icke uppdaterade"},
		{id = "showHidden", displayName = "Visa dolda"},
	}

	function _G.setFilters(filtersTable)
		_G.setAttr(myFilters, filtersTable)
		_G.tenfLib.jsonSave(_G.myFiltersSaveFile, myFilters)
	end

	function _G.getFilters()
		return myFilters and _G.tenfLib.tableCopy(myFilters) or {}
	end

	function _G.getAvailableFilters()
		return _G.tenfLib.tableCopy(availableFilters, true)
	end

end

do
	local mySettings

	function _G.reloadMySettings()
		mySettings = _G.tenfLib.jsonLoad(_G.mySettingsSaveFile) or {}
	end
	_G.reloadMySettings()

	--[[
		settingsTable:
			*seasonStart
			*seasonEnd
			*episodeStart

			*movieStart
		
			*typeOfView
			*username
			*password
			*iduser
	--]]
	function _G.setSettings(settingsTable)
		_G.setAttr(mySettings, settingsTable)
		_G.tenfLib.jsonSave(_G.mySettingsSaveFile, mySettings)
	end

	function _G.getSettings()
		return mySettings and _G.tenfLib.tableCopy(mySettings) or {}
	end
end

do
	--[[
		States:
		* none
		* some
		* all
		* allReleased
	]]
	local mySeenStates

	function _G.reloadMySeenStates()
		mySeenStates = _G.tenfLib.jsonLoad(_G.mySeenStatesSaveFile) or {}
	end
	_G.reloadMySeenStates()
	
	function _G.addSeenState(imdbID, seasonIndex, episodeIndex)
		local imdbType = _G.loadTitleType(imdbID)
		if not imdbType then return end

		if seasonIndex then
			mySeenStates[imdbID] = mySeenStates[imdbID] or {}
			mySeenStates[imdbID][seasonIndex] = mySeenStates[imdbID][seasonIndex] or {}
			if episodeIndex then
				mySeenStates[imdbID][seasonIndex][episodeIndex] = true
			else
				local seriesData = _G.loadSeries(imdbID)
				if seriesData and seriesData.seasons[seasonIndex] then
					for eIdx, episodeData in ipairs(seriesData.seasons[seasonIndex].episodes) do
						mySeenStates[imdbID][seasonIndex][eIdx] = true
					end
				end
			end
		else
			if imdbType == "series" then
				local seriesData = _G.loadSeries(imdbID)
				if seriesData then
					mySeenStates[imdbID] = mySeenStates[imdbID] or {}
					for sIdx, seasonData in ipairs(seriesData.seasons) do
						mySeenStates[imdbID][sIdx] = mySeenStates[imdbID][sIdx] or {}
						for eIdx, episodeData in ipairs(seasonData.episodes) do
							mySeenStates[imdbID][sIdx][eIdx] = true
						end
					end
				end
			else
				mySeenStates[imdbID] = true
			end
		end
		_G.tenfLib.jsonSave(_G.mySeenStatesSaveFile, mySeenStates)
	end

	function _G.removeSeenState(imdbID, seasonIndex, episodeIndex)
		if seasonIndex then
			mySeenStates[imdbID] = mySeenStates[imdbID] or {}
			mySeenStates[imdbID][seasonIndex] = mySeenStates[imdbID][seasonIndex] or {}
			if episodeIndex then
				mySeenStates[imdbID][seasonIndex][episodeIndex] = nil
			else
				mySeenStates[imdbID][seasonIndex] = nil
			end
		else
			mySeenStates[imdbID] = nil
		end
		_G.tenfLib.jsonSave(_G.mySeenStatesSaveFile, mySeenStates)
	end

	function _G.loadSeenState(imdbID, seasonIndex, episodeIndex)
		local state = "none"
		local seenCount = {seen = 0, max = 0, releasedMax = 0}

		if not imdbID then return "none" end
		
		local myState = mySeenStates[imdbID] or {}
		if seasonIndex then
			local seriesData = _G.loadSeries(imdbID)
			myState[seasonIndex] = myState[seasonIndex] or {}
			if episodeIndex then
				local foundState = false
				if seriesData and seriesData.seasons[seasonIndex] and seriesData.seasons[seasonIndex].episodes[episodeIndex] then
					local airdate = seriesData.seasons[seasonIndex].episodes[episodeIndex].airdate
					
					local now = os.date( "*t" )
					now.hour, now.min, now.sec = 0, 0, 0

					if not (_G.isCompleteDate(airdate) and _G.getDiffTime(airdate, now) >= 0) then
						foundState = true
						state = "allReleased"
					end
				end
				
				state = myState[seasonIndex][episodeIndex] and "all" or (not foundState and "none") or state
				
				if myState[seasonIndex][episodeIndex] then
					seenCount.seen = 1
				end
				seenCount.max = 1
			else
				local allSeen = true
				local anySeen = false
				local unSeen = {}

				if seriesData and seriesData.seasons[seasonIndex] then
					for eIdx, episodeData in ipairs(seriesData.seasons[seasonIndex].episodes) do
						local state = myState[seasonIndex][eIdx]
						
						local addReleasedMax = true
						if state then
							seenCount.seen = seenCount.seen + 1
							anySeen = true
						else
							unSeen[#unSeen + 1] = episodeData
							allSeen = false

							local now = os.date( "*t" )
							now.hour, now.min, now.sec = 0, 0, 0

							local airdate = episodeData.airdate
							if not ((_G.isCompleteDate(airdate) and _G.getDiffTime(airdate, now) >= 0)) then
								-- Inte har släppts
								addReleasedMax = false
							end

						end

						if addReleasedMax then
							seenCount.releasedMax = seenCount.releasedMax + 1
						end
						seenCount.max = seenCount.max + 1
					end
				end

				local allUnSeenNotReleased = true
				for eIdx, episodeData in ipairs(unSeen) do
					local now = os.date( "*t" )
					now.hour, now.min, now.sec = 0, 0, 0

					local airdate = episodeData.airdate
					if (_G.isCompleteDate(airdate) and _G.getDiffTime(airdate, now) >= 0) then
						allUnSeenNotReleased = false
						break
					end
				end

				if allSeen then
					state = "all"
				elseif allUnSeenNotReleased then
					state = "allReleased"
				elseif anySeen then
					state = "some"
				else
					state = "none"
				end

			end
		else
			local imdbType = _G.loadTitleType(imdbID)
			if imdbType == "series" then
				local allSeen = true
				local anySeen = false
				local unSeen = {}

				local seriesData = _G.loadSeries(imdbID)
				if seriesData then
					for sIdx, seasonData in ipairs(seriesData.seasons) do
						myState[sIdx] = myState[sIdx] or {}
						for eIdx, episodeData in ipairs(seasonData.episodes) do
							local state = myState[sIdx][eIdx]

							local addReleasedMax = true
							if state then
								seenCount.seen = seenCount.seen + 1
								anySeen = true
							else
								unSeen[#unSeen + 1] = episodeData
								allSeen = false

								local now = os.date( "*t" )
								now.hour, now.min, now.sec = 0, 0, 0

								local airdate = episodeData.airdate
								if not ((_G.isCompleteDate(airdate) and _G.getDiffTime(airdate, now) >= 0)) then
									-- Inte har släppts
									addReleasedMax = false
								end
							end

							if addReleasedMax then
								seenCount.releasedMax = seenCount.releasedMax + 1	
							end
							seenCount.max = seenCount.max + 1
						end
					end

					local allUnSeenNotReleased = true
					for eIdx, episodeData in ipairs(unSeen) do
						local now = os.date( "*t" )
						now.hour, now.min, now.sec = 0, 0, 0

						local airdate = episodeData.airdate
						if (_G.isCompleteDate(airdate) and _G.getDiffTime(airdate, now) >= 0) then
							allUnSeenNotReleased = false
							break
						end
					end

					if allSeen then
						state = "all"
					elseif allUnSeenNotReleased then
						state = "allReleased"
					elseif anySeen then
						state = "some"
					else
						state = "none"
					end
				else
					state = "unknown"
				end
			else
				seenCount.max = 1
				local movieData = _G.loadMovie(imdbID)
				local isMovie = not not movieData
				
				if isMovie then
					local now = os.date( "*t" )
					now.hour, now.min, now.sec = 0, 0, 0
					local realeased = movieData.Released
					
					if mySeenStates[imdbID] then
						seenCount.seen = 1
					end
					
					state = mySeenStates[imdbID] and "all" or ((_G.isCompleteDate(realeased) and _G.getDiffTime(realeased, now) >= 0) and "none" or "allReleased")
				else
					state = "unknown"
				end
			end
		end

		function seenCount:toString()
			return self.seen .. " / " .. self.max, ((self.max ~= 0 and self.seen / self.max) or 0)
		end

		return state, seenCount
	end
end

function _G.loadAllMoviesAndSeries()
	local myTitles = _G.loadTitles()

	local myMovies = {}
	local mySeries = {}
	for imdbID, titleData in pairs(myTitles) do
		if titleData.Type == "series" then
			mySeries[imdbID] = _G.loadSeries(imdbID)
		else
			myMovies[imdbID] = _G.loadMovie(imdbID)
		end
	end
	return myMovies, mySeries
end

do
	local mySeries

	function _G.reloadMySeries()
		mySeries = _G.tenfLib.jsonLoad(_G.mySeriesSaveFile) or {}
	end
	_G.reloadMySeries()

	function _G.addSeries(data)
		local seriesExists = _G.seriesExists(data.imdbID)
		mySeries[data.imdbID] = _G.tenfLib.tableCopy(data, true)
		
		_G.tenfLib.jsonSave(_G.mySeriesSaveFile, mySeries)
		return seriesExists
	end

	function _G.removeSeries(imdbID)
		mySeries[imdbID] = nil
		_G.tenfLib.jsonSave(_G.mySeriesSaveFile, mySeries)
	end

	function _G.seriesExists(imdbID)
		return not not mySeries[imdbID]
	end

	function _G.loadSeries(imdbID)
		return mySeries[imdbID] and _G.tenfLib.tableCopy(mySeries[imdbID], true) or nil
	end
end

do
	local myMovies

	function _G.reloadMyMovies()
		myMovies = _G.tenfLib.jsonLoad(_G.myMoviesSaveFile) or {}
	end
	_G.reloadMyMovies()

	function _G.addMovie(data)
		local movieExists = _G.movieExists(data.imdbID)
		myMovies[data.imdbID] = _G.tenfLib.tableCopy(data, true)
		
		_G.tenfLib.jsonSave(_G.myMoviesSaveFile, myMovies)
		return movieExists
	end

	function _G.removeMovie(imdbID)
		myMovies[imdbID] = nil
		_G.tenfLib.jsonSave(_G.myMoviesSaveFile, myMovies)
	end

	function _G.movieExists(imdbID)
		return not not myMovies[imdbID]
	end

	function _G.loadMovie(imdbID)
		return myMovies[imdbID] and _G.tenfLib.tableCopy(myMovies[imdbID], true) or nil
	end
end

function _G.downloadTitles(titleList, progressFunction)
	local nrOfTitles = _G.tenfLib.tableCount(titleList)
	local downloadCounter = 0

	if progressFunction then
		progressFunction({counter = 0, total = nrOfTitles})
	end

	local function CheckDownloadCompletion()
		downloadCounter = downloadCounter + 1

		if downloadCounter >= nrOfTitles then
			_G.setDownloadDate()
		end

		if progressFunction then
			progressFunction({counter = downloadCounter, total = nrOfTitles})
		end
	end

	for imdbID, data in pairs(titleList) do
		local isSeries = data.Type == "series"
		local currentData = data
		if isSeries then
			_G.downloadTitle(currentData.imdbID, system.DocumentsDirectory, function(eTitle)
				if eTitle.isError then
					print("Network error")
					CheckDownloadCompletion()
				else
					display.remove(eTitle.posterImage)
					_G.addTitle(eTitle.data)				
					require("modules.imdbEpisodeParser")(currentData, function(eSeries)
						if eSeries.isError then
							print("Network error")
							-- void
						else
							local seriesData = eSeries.data
							_G.addSeries(seriesData)
						end
						CheckDownloadCompletion()
					end)
				end
			end)
		else
			_G.downloadTitle(currentData.imdbID, system.DocumentsDirectory, function(e)
				if e.isError then
					print("Network error")
					-- void
				else
					display.remove(e.posterImage)
					local movieData = e.data
					_G.addMovie(movieData)
					_G.addTitle(movieData)
				end
				CheckDownloadCompletion()
			end)
		end
	end
end

function _G.downloadTitle(imdbID, directoryForImage, onComplete)
	local url = "http://www.omdbapi.com/?&i=" .. imdbID
    network.request( url, "GET", function( event )
        local posterImage
        if ( event.isError ) then
            onComplete({isError = true, messageToUser = "Något gick fel, vill du SMSa felet till Tommy? (Det skrivs automatiskt)", message = "fetching/parsing title imdbID: " .. imdbID})
        else
            local data = _G.json.decode(event.response)

			--[[
				Actors
				imdbVotes
				Released
				Genre
				Metascore
				Rated
				imdbID
				Language
				Plot
				Director
				Awards
				Country
				imdbRating
				Poster
				Runtime
				Title
				Writer
				Response
				Type
				Year
			--]]

			if data.Released then
				data.Released = _G.getDateFromImdbString(data.Released)
			end

            local function imageDownloadOnComplete( e )
			    if ( e.isError ) then
			        posterImage = nil
			        print ( "Network error - download failed" )
			    else
			    	posterImage = e.target
			    end
			    onComplete({isError = false, data = data, posterImage = posterImage})
			end
			local fileName = data.imdbID .. ".jpg"

			if _G.tenfLib.fileExists(fileName, directoryForImage) then
				local tmp = display.newImage(fileName, directoryForImage)
				local w, h = tmp.width, tmp.height
				display.remove(tmp)

				local image = display.newImageRect(fileName, directoryForImage, w, h)
				imageDownloadOnComplete( { target = image} )
			else
				display.loadRemoteImage( data.Poster, "GET", imageDownloadOnComplete, fileName, directoryForImage, 0, 0 )
			end
        end
    end )
end

do
	local myTitles

	function _G.reloadMyTitles()
		myTitles = _G.tenfLib.jsonLoad(_G.myTitlesSaveFile) or {}
	end
	_G.reloadMyTitles()

	function _G.addTitle(data)
		local titleExist = _G.titleExists(data.imdbID)
		myTitles[data.imdbID] = _G.tenfLib.tableCopy(data, true)
		myTitles[data.imdbID].seasons = nil

		_G.tenfLib.jsonSave(_G.myTitlesSaveFile, myTitles)
		return titleExist
	end

	function _G.removeTitle(imdbID)
		myTitles[imdbID] = nil
		_G.tenfLib.jsonSave(_G.myTitlesSaveFile, myTitles)
	end

	function _G.titleExists(imdbID)
		return not not myTitles[imdbID]
	end

	function _G.loadTitles()
		return _G.tenfLib.tableCopy(myTitles, true)
	end

	function _G.loadTitle(imdbID)
		return myTitles[imdbID]
	end

	function _G.loadTitleType(imdbID)
		return myTitles[imdbID] and myTitles[imdbID].Type
	end
end


function _G.getEpisodeString(seasonNr, episodeNr)
	local seasonStr = seasonNr < 10 and tostring("0" .. seasonNr) or tostring(seasonNr)
	local episodeStr = episodeNr < 10 and tostring("0" .. episodeNr) or tostring(episodeNr)

	return "S" .. seasonStr .. "E" .. episodeStr
end

do 
	local monthTranslatorTable =
	{
		["Jan"] = {nr = 1, name = "Januari"},
		["Feb"] = {nr = 2, name = "Februari"},
		["Mar"] = {nr = 3, name = "Mars"},
		["Apr"] = {nr = 4, name = "April"},
		["May"] = {nr = 5, name = "Maj"},
		["Jun"] = {nr = 6, name = "Juni"},
		["Jul"] = {nr = 7, name = "Juli"},
		["Aug"] = {nr = 8, name = "Augusti"},
		["Sep"] = {nr = 9, name = "September"},
		["Oct"] = {nr = 10,name =  "Oktober"},
		["Nov"] = {nr = 11,name =  "November"},
		["Dec"] = {nr = 12,name =  "December"},
	}

	local function getMonthName(monthId)
		for k, v in pairs(monthTranslatorTable) do
			if v.nr == monthId then
				return v.name
			end
		end
	end
	
	function _G.getDateString(dateTable)
		return tostring(dateTable.day or "") .. " " .. tostring(getMonthName(dateTable.month) or "") .. " " .. tostring(dateTable.year or "")
	end

	function _G.getDateFromImdbString(dateString)
		dateString = _G.tenfLib.trim(dateString)
		local parts = _G.tenfLib.stringSplit(dateString, " ")

		local day, month, year = nil, nil, nil
		if #parts == 3 then
			day = tonumber(parts[1])
			month = parts[2]:sub(1, 3)
			year = tonumber(parts[3])
		elseif #parts == 2 then
			month = parts[1]:sub(1, 3)
			year = tonumber(parts[2])
		elseif #parts == 1 then
			year = tonumber(parts[1])
		end

		
		if month then
			month = monthTranslatorTable[month] and monthTranslatorTable[month].nr or nil
		end
		
		return {year = year, month = month, day = day}
	end

	function _G.isCompleteDate(dateTable)
		return dateTable and dateTable.day and dateTable.month and dateTable.year
	end
end

function _G.createTitle(parent, title, leftButtonData, rightButtonData)
	local titleGroup = _G.newGroup(parent)
	local title = display.newText(titleGroup, title, 0, 0, _G.fontName, _G.fontSizeVeryLarge)
	title.x, title.y = 0, 0

	local line = display.newLine(titleGroup, 0, 0, title.width, 0)
	line.strokeWidth = 1
	line.x, line.y = title.x - title.width / 2, title.y + title.height / 2 - 4

	local settings = 
	{
		width = (_G._W - title.width - 40) / 2,
		height = title.height,
	}
	local buttonGrid = require("modules.buttonGrid")(titleGroup, settings)

	local offset = title.width / 2 + 10 + settings.width / 2
	if leftButtonData then
		local leftButton = buttonGrid:createButton(leftButtonData.text, title.x - offset, title.y, function(e)
			if leftButtonData.onPress then
				leftButtonData.onPress(e)
			end
		end)
	end
	if rightButtonData then
		local rightButton = buttonGrid:createButton(rightButtonData.text, title.x + offset, title.y, function(e)
			if rightButtonData.onPress then
				rightButtonData.onPress(e)
			end
		end)
	end


	titleGroup.x, titleGroup.y = _G._w, 20
	return titleGroup
end


function _G.createBackground(groupInsert)
	local bgGroup = display.newGroup()
	local appBG = display.newRect(bgGroup ,_G._w , _G._h, _G._W, _G._H)
	
	local bgColor = {
		color2 = { 0., 0, 0 },
		color1 = { 0.3, 0.3, 0.3 },
		direction = "up"
	  }

	appBG:setFillColor(bgColor)

	if groupInsert then
		groupInsert:insert(bgGroup)
	else
		display.currentStage:insert(1, bgGroup)	
	end

	return bgGroup
end

function _G.setRectMask(obj, sizeX, sizeY)
	local mask = graphics.newMask("images/Masks/mask_songList.png")
	obj:setMask(mask)

	local originalSize = {x = 340 - 6, y = 400 - 6} -- -6 används för att kompensera bort den svarta ramen runt masken.
	local targetSize = {x = sizeX, y = sizeY}
	local scale = {x = targetSize.x / originalSize.x, y = targetSize.y / originalSize.y}

	obj.maskScaleX = scale.x
	obj.maskScaleY = scale.y

	obj.maskX, obj.maskY = 0, 0--sizeX / 2, sizeY / 2
end


--Skapar en bild med orginal-storlek.
function _G.newImage(parent, path)
	if type(parent) == 'string' then parent, path = nil, parent end
	local tmp = display.newImage(path)
	local w, h = tmp.width, tmp.height
	display.remove(tmp)
	local img
	if parent then
		img = display.newImageRect(parent, path, w, h)
	else
		img = display.newImageRect(path, w, h)
	end
	return img
end

-- Uppdaterar tabellen med event handlers för native "key"-event (Back, search etc.)
-- Exempel:
--    _G.setKeyEventHandlers{ back=tenfLib.stopPropagation } -- bakåtknappen avslutar ej appen
--    _G.setKeyEventHandlers( nil ) -- bakåtknappen avslutar appen som vanligt
function _G.setKeyEventHandlers(handlers)
	_G.keyEventHandlers = handlers or {}
end




-- Som DisplayObject:dispatchEvent(), fast avfyras även av alla child-objekt
-- Exempel:
--   local function printHello()
--     print("Hej!")
--   end
--   local group = display.newGroup()
--   group:addEventListener( "myEvent", printHello )
--   local image1 = display.newImage( group, "foo.png" )
--   image1:addEventListener( "myEvent", printHello )
--   local image2 = display.newImage( group, "bar.png" )
--   image2:addEventListener( "myEvent", printHello )
--   _G.broadcastEvent{ name="myEvent", target=group } -- printar "Hej!" när eventet når gruppen och när det når bilderna
function _G.broadcastEvent(e)
	local t = e.target or display.currentStage
	e.target = t
	t:dispatchEvent(e)
	if t.numChildren then
		for i = 1, t.numChildren do
			e.target = t[i]
			_G.broadcastEvent(e)
		end
	end
end

-- Som DisplayObject:dispatchEvent(), fast bubblar även upp i hierarkin.
-- Bubblingen stoppas om en event handler returnerar ett sant värde eller efter eventet nått Runtime.
-- event.originalTarget är originalobjektet som eventet avfyrades på.
-- Exempel:
--   local group = display.newGroup()
--   group:addEventListener( "myEvent", function(e) print("Hej!") end )
--   local image = display.newImage( group, "foo.png" )
--   _G.dispatchBubblingEvent{ name="myEvent", target=image } -- printar "Hej!" när eventet når gruppen
function _G.dispatchBubblingEvent(e)
	e.originalTarget = e.target
	local stopValue = e.target:dispatchEvent(e)
	if not stopValue then
		while e.target.parent do
			e.target = e.target.parent
			stopValue = e.target:dispatchEvent(e)
			if stopValue then break end
		end
		if not stopValue then
			e.target = nil
			stopValue = Runtime:dispatchEvent(e)
		end
	end
	return stopValue
end



-- _G.getDisplayDimensions(  )
-- Returnerar dimensionerna på skärmen beroende på orientationen (iPad returnerar alltid samma)
function _G.getDisplayDimensions()
	local width, height = _H, _W
	if _G.isTablet or _G.orientation.getCurrentForApp() == 'portrait' then width, height = height, width end
	return width, height
end

function _G.getDiffTime(dateTable, dateTable2)
	local now = os.date( "*t" )
	if dateTable2 then
		now = dateTable2
	end

	local required = {{k="day", v=1}, {k="month", v=1}, {k="year", v=1}, {k="hour", v=0}, {k="min", v=0}}

	for k, v in pairs(now) do
		if not(k == "day" or k == "month" or k == "year" or k == "min" or k == "hour") then
			now[k] = nil
		end
	end

	for _, v in pairs(required) do
		now[v.k] = now[v.k] or v.v
		dateTable[v.k] = dateTable[v.k] or v.v
	end

	if not dateTable2 then
		dateTable.hour = 12
		dateTable.min = 0
	else
		local tempSwitch = dateTable
		dateTable = now
		now = tempSwitch
	end

	return os.time(dateTable) - os.time(now)
end

function _G.convertDiffToTable(seconds)
	local isNegative = seconds < 0
	seconds = math.abs(seconds)

	local day = math.floor((seconds) / (3600 * 24))
	seconds = seconds - day * (3600 * 24)
	local hour = math.floor((seconds) / 3600)
	seconds = seconds - hour * (3600)
	local min = math.floor((seconds) / 60)
	seconds = seconds - min * (60)
	if isNegative then
		day, hour, min, seconds = -day, -hour, -min, -seconds
	end
	return {day = day, hour = hour, min = min, sec = seconds}
end

function _G.getGradientColor(color, direction, colorDiff)
	colorDiff = colorDiff or 0.3
	direction = direction or "down"
	local gradColor =
	{{
		color1 = _G.tenfLib.tableCopy(color),
		color2 = _G.tenfLib.tableCopy(color),
		direction = direction,
	}}
	for k,v in pairs(gradColor[1].color2) do
		gradColor[1].color2[k] = math.max(0, v - colorDiff)
	end
	return gradColor
end

function _G.scheduleNotifications()
	--Avbryter alla nuvarande notifications
	system.cancelNotification()

	local settings = _G.getSettings()
	--[[
		settingsTable:
			* "seasonStart"
			* "seasonEnd"
			* "episodeStart"

			* "movieStart"
			
			* "withImage"
	--]]
	local myMovies, mySeries = _G.loadAllMoviesAndSeries()
	
	for imdbID, seriesData in pairs(mySeries) do
		for _, seasonData in ipairs(seriesData.seasons) do
			local seasonNr = seasonData.seasonNr
			local seasonMin, seasonMax
			local titleData = _G.loadTitle(imdbID)

			for episodeIndex, episodeData in ipairs(seasonData.episodes) do
				local episodeNr = episodeData.episodeNr
				if _G.isCompleteDate(episodeData.airdate) then
					if episodeIndex == 1 then
						seasonMin = episodeData.airdate
					elseif episodeIndex == #seasonData.episodes then
						seasonMax = episodeData.airdate
					end
					if settings["episodeStart"] then
						local episodeString = _G.getEpisodeString(seasonNr, episodeNr)
						local options = {
							alert = titleData.Title .. ",\n" .. episodeString .. " släpps " .. _G.getDateString(episodeData.airdate),
							custom = { data = seasonData }
						}

						local diffInSeconds = _G.getDiffTime(episodeData.airdate)
						if diffInSeconds > 0 then
							print(options.alert)
							system.scheduleNotification( diffInSeconds, options )
						end
					end
				end
			end

			if settings["seasonStart"] then
				if seasonMin then
					local options = {
						alert = titleData.Title .. ",\nSäsong " .. seasonNr .. " börjar " .. _G.getDateString(seasonMin),
						custom = { data = seasonData }
					}

					local diffInSeconds = _G.getDiffTime(seasonMin)
					if diffInSeconds > 0 then
						system.scheduleNotification( diffInSeconds, options )
					end
				end
			end
			if settings["seasonEnd"] then
				if seasonMax then
					local options = {
					alert = titleData.Title .. ",\nSäsong " .. seasonNr .. " är slut " .. _G.getDateString(seasonMax),
					custom = { data = seasonData } }
					local diffInSeconds = _G.getDiffTime(seasonMax)
					if diffInSeconds > 0 then
						system.scheduleNotification( diffInSeconds, options )
					end
				end
			end

		end
	end

	for imdbID, movieData in pairs(myMovies) do
		if _G.isCompleteDate(movieData.Released) then
			if settings["movieStart"] then
				local options = {
				alert = movieData.Title .. " släpps " .. _G.getDateString(movieData.Released),
				custom = { data = movieData } }
				local diffInSeconds = _G.getDiffTime(movieData.Released)
				if diffInSeconds > 0 then
					system.scheduleNotification( diffInSeconds, options )
				end
			end
		end
	end
end



do
	local bg
	local indicator

	function native.setActivityIndicator(state, text)

		-- Skapar indikator och bakgrund.
		if state and not indicator and not bg then
			bg = display.newRect(_G._w, _G._h, _G._W, _G._H)
			bg:setFillColor(1, _G.blackoutAlpha)
			bg:addEventListener('touch', _G.tenfLib.stopPropagation)
			bg:addEventListener('tap', _G.tenfLib.stopPropagation)

			local options = 
			{
				text = text,     
				x = _G._w,
				y = _G._h,
				width = bg.width - 20,     --required for multi-line and alignment
				font = _G.fontName,   
				fontSize = _G.fontSizeSmall,
				align = "center"  --new alignment parameter
			}


			local textObj = text and display.newText(options) or nil
			if textObj then textObj:setFillColor(0.3) end
			indicator = _G.newGroup()
			if textObj then
				indicator:insert(textObj)
				indicator.txtObj = textObj
			end

			transition.from(bg, {time=100, alpha=0, transition=easing.inOutQuad})
			transition.from(indicator, {time=100, alpha=0, transition=easing.inOutQuad})

		-- Byter text på redan skapad indikator.
		elseif state and text and indicator then
			indicator.txtObj.text = text

		-- Tar bort indikator och bakgrund.
		else
			if bg then bg:removeSelf() bg = nil end
			if indicator then indicator:removeSelf() indicator = nil end
		end
	end
end


function _G.loginScreen(callback)

	local parentGroup = display.newGroup()
	local contentGroup = display.newGroup()
	local bg = setAttr( display.newRect(parentGroup, 0, 0, _G._W, _G._H), {x=0, y=0}, {rp='TL', fc=0.4} )
	bg:addEventListener("touch", function(e) return true end)
	bg:addEventListener("tap", function(e) return true end)
	parentGroup:insert(contentGroup)

	local function gotoNext(event)
		display.remove(parentGroup)
		callback(event)
	end

	local usernameInput, passwordInput
	local function Proceed(tryProceed)
		if tryProceed then
			local loginText = (_G.isSimulator and not _G.isIos) and "tompa" or usernameInput.text
			local passText = (_G.isSimulator and not _G.isIos) and "hemligt123" or passwordInput.text
			local saveManager = require("modules.saveManager")()
			saveManager:login(loginText, passText, function(e)
				if e.success then
					native.showAlert("Yaay!", "Du är nu inloggad!", {"Ok"}, function()
						gotoNext({cancel = false, iduser = e.data, username = loginText, password = passText})
					end)
				else
					native.showAlert("Varning!", e.message, {"Ok"})
				end
			end)
		else
			gotoNext({cancel = true})
		end

	end

	local options = 
	{
		text = "Fyll i inloggningsinfo till servern.\n(Du borde fått av Mattias eller Tommy)",
		width = bg.width - 20,     --required for multi-line and alignment
		font = _G.fontName,
		fontSize = _G.fontSizeSmall,
		align = "center",  --new alignment parameter
		parent = contentGroup
	}
	local text = _G.setAttr(display.newText(options), {x = _G._w, y = 10}, {rp='TC', fc=0})


	usernameInput = native.newTextField( 0, 0, _G._W - 50, 30 )
	_G.setAttr(usernameInput, {placeholder = "Användarnamn", x = text.x, y = text.y + text.height + 10, font = native.newFont( _G.fontName, _G.fontSizeNormal )}, {rp='TC'})
	contentGroup:insert(usernameInput)
	usernameInput:addEventListener( "userInput", function(event)
		if ( event.phase == "began" ) then
			-- void
		elseif ( event.phase == "ended" ) then
			-- void
		elseif ( event.phase == "submitted" ) then
			native.setKeyboardFocus( passwordInput )
		elseif ( event.phase == "editing" ) then

		end
	end )

	passwordInput = native.newTextField( 0, 0, _G._W - 50, 30 )
	_G.setAttr(passwordInput, {placeholder = "Lösenord", x = usernameInput.x, y = usernameInput.y + usernameInput.height + 10, font = native.newFont( _G.fontName, _G.fontSizeNormal )}, {rp='TC'})
	contentGroup:insert(passwordInput)
	passwordInput:addEventListener( "userInput", function(event)
		if ( event.phase == "began" ) then
			-- void
		elseif ( event.phase == "ended" ) then
			-- void
		elseif ( event.phase == "submitted" ) then
			Proceed(true)			
		elseif ( event.phase == "editing" ) then

		end
	end )


	local buttonSettings = {width = _G._W - 50, height = 30}
	local buttonGrid = require("modules.buttonGrid")(contentGroup, buttonSettings)
	local buttonGroup = display.newGroup()
	contentGroup:insert(buttonGroup)

	local buttonsInMenu = {
		{title = "Logga in", onClick = function()
			Proceed(true)
		end},
		{title = "Avbryt", onClick = function()
			Proceed(false)
		end}
	}

	for i, buttonData in ipairs(buttonsInMenu) do
		local x, y = 0, buttonSettings.height / 2 + 10 + (i - 1) * (buttonSettings.height + 10)
		local btn = buttonGrid:createButton(buttonData.title, x, y, buttonData.onClick)
		buttonGroup:insert(btn)
	end
	setAttr(buttonGroup, {x = passwordInput.x, y = passwordInput.y + passwordInput.height + 20})

	contentGroup.y = _G._H * 0.1

--[[
	usernameInput = page:append(ui.newTextInput("Användarnamn"))
	passwordInput = page:append(ui.newTextInput("Lösenord", nil, true))


	page:append(ui.newButton("Logga in", function()
		Proceed(true)
	end))
	page:append(ui.newButton("Avbryt", function()
		Proceed(false)
	end))
--]]
end

--=======================================================================================
--=======================================================================================
--= Initialisering ======================================================================
--=======================================================================================
--=======================================================================================




-- Sätt standardvärden

display.setDefault('background', 255)
--display.setDefault('textColor', 0)



-- Android: Lyssna efter native key-event (Back, search etc.)
-- Returnera true från 'back'-lyssnaren för att avsluta appen
Runtime:addEventListener('key', function(e)
	if e.phase == 'up' then
		local returnValue
		local handler = _G.keyEventHandlers[e.keyName]
		if handler then returnValue = handler(e) end
		if e.keyName == 'back' then
			if not returnValue then native.requestExit() end
			return true
		end
		return returnValue
	end
end)

Runtime:addEventListener( "system", function( event )
	if ( event.type == "applicationExit" ) or (event.type == "applicationSuspend") then
		_G.scheduleNotifications()
	elseif ( event.type == "applicationOpen" ) or ( event.type == "applicationResume" ) then
		
	end
end )


-- Fixa storyboard-övergångar
do
	local h, _H = display.contentHeight, _G._H
	for effectName, effect in pairs(require('storyboard').effectList) do
		if effect.from and effect.from.yStart == h then effect.from.yStart = _H end
		if effect.from and effect.from.yEnd   == h then effect.from.yEnd   = _H end
		if effect.to   and effect.to.yStart   == h then effect.to.yStart   = _H end
		if effect.to   and effect.to.yEnd     == h then effect.to.yEnd     = _H end
		if effect.from and effect.from.yStart == -h then effect.from.yStart = -_H end
		if effect.from and effect.from.yEnd   == -h then effect.from.yEnd   = -_H end
		if effect.to   and effect.to.yStart   == -h then effect.to.yStart   = -_H end
		if effect.to   and effect.to.yEnd     == -h then effect.to.yEnd     = -_H end
	end
end

_G.navMenu = require("modules.navigationBar")(
	{
		{title="Mina titlar", callback = function()
			storyboard.gotoScene("scenes.myTitles")
		end},
		{title="Lägg till titlar", callback = function()
			storyboard.gotoScene("scenes.addTitles")
		end},
		{title="Inställningar", callback = function()
			storyboard.gotoScene("scenes.settings")
		end},
	}
)


local function goToStartScreen()
	_G.navMenu:setSelected(1)
	storyboard.gotoScene("scenes.myTitles", {params = {askForUpdate = true}})
end

if not _G.getSettings().username then
	_G.loginScreen(function(e)
		if e.cancel then
			-- void
		else
			_G.setSettings({username = e.username, password = e.password, iduser = e.iduser})
		end
		goToStartScreen()
	end)
else
	goToStartScreen()
end



--=======================================================================================

-- Printa ut globaler (Debug)
if _G.debugMode then
	require('modules.utils.testHelper').startMonitorTable(_G, true) -- printa ut globaler
end

-- require('modules.utils.debugView')(display.currentStage)




