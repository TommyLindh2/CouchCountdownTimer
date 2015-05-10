
-- Functions
local getSeasonData
local getAmountOfSeasons
local errorOccured

function getAmountOfSeasons(imdbID, _onComplete)
	local url = "http://www.imdb.com/title/" .. imdbID .. "/episodes"
	network.request( url, "GET", function( event )
		local xmlReader = require("modules.xmlParser")
		if ( event.isError ) then
			print( "Network error!")
			errorOccured()
		else
			local resp = event.response
			-- Specify as many/few of these as you like

			local insideSelect = false
			local insideSeasonSelect = false
			local listOfSeasons = {}
			local parser = xmlReader:parser(
			{
				startElement = function(name,nsURI,nsPrefix)  		-- When "<foo" or <x:foo is seen
					if name == "select" then
						insideSelect = true
						insideSeasonSelect = false
					end
				end,
				attribute    = function(name,value,nsURI,nsPrefix) 	-- attribute found on current element
					if insideSelect then
						if name == "id" and value == "bySeason" then
							insideSeasonSelect = true
						end

						if insideSeasonSelect then
							if name == "value" then
								listOfSeasons[#listOfSeasons + 1] = value
							end
						end
					end
				end,
				closeElement = function(name,nsURI,nsPrefix)
					if name == "select" then
						insideSelect = false
						insideSeasonSelect = false
					end
				end,
				text = function(text)
					
				end
			})

			-- Ignore whitespace-only text nodes and strip leading/trailing whitespace from text
			-- (does not strip leading/trailing whitespace from CDATA)
			if pcall(function() parser:parse(resp, {stripWhitespace=true}) end) then
				_onComplete(listOfSeasons)
			else
				errorOccured()
			end
		end
	end)
end

function getSeasonData(imdbID, seasonNr, _onComplete)
	local url = "http://www.imdb.com/title/" .. imdbID .. "/episodes?season=" .. seasonNr
	print("Hämtar data från: "..url)
	network.request( url, "GET", function( event )
		local xmlReader = require("modules.xmlParser")
		if ( event.isError ) then
			errorOccured()
			print( "Network error!")
		else
			local resp = event.response
			-- Specify as many/few of these as you like

			local episodeListStarted = false

			local listOfEpisodes = {}
			local currentEpisode = nil
			local currentValueToFind = nil
			local nrOfBehindImg = nil

			local parser = xmlReader:parser(
			{
				startElement = function(name,nsURI,nsPrefix)  		-- When "<foo" or <x:foo is seen
					if episodeListStarted and name == "img" then
						nrOfBehindImg = 0
					end
				end,
				attribute    = function(name,value,nsURI,nsPrefix) 	-- attribute found on current element
					if name == "class" and (value == "list detail eplist") then
						episodeListStarted = true
					end

					if episodeListStarted then
						if name == "class" and _G.stringStartsWith(value, "list_item") then
							currentEpisode = {episodeNr = #listOfEpisodes + 1}
							listOfEpisodes[#listOfEpisodes + 1] = currentEpisode
						end

						if name == "class" and value == "airdate" then
							currentValueToFind = value
						elseif name == "itemprop" and (value == "name" or value == "description") then
							currentValueToFind = value
						else
							currentValueToFind = nil
						end

					end

				end,
				text = function(text)
					if nrOfBehindImg ~= nil then
						if nrOfBehindImg > 1 then
							print("test", text)
							nrOfBehindImg = nil
						else
							nrOfBehindImg = nrOfBehindImg + 1
						end
					end
					if currentValueToFind then
						if currentValueToFind == "airdate" then
							text = _G.getDateFromImdbString(text)
						end
						currentEpisode[currentValueToFind] = text
						currentValueToFind = nil
					end
				end
			})

			-- Ignore whitespace-only text nodes and strip leading/trailing whitespace from text
			-- (does not strip leading/trailing whitespace from CDATA)
			if pcall(function() parser:parse(resp, {stripWhitespace=true}) end) then
				_onComplete(listOfEpisodes)
			else
				errorOccured()
			end

		end
	end)
end

return function(data, onComplete)
	local imdbID = data.imdbID

	local listOfEverything = {seasons = {}}

	local nrOfSeasons

	local function addNewSeason(seasonNr, seasonData)
		listOfEverything.seasons[seasonNr] = seasonData
		print("Lägger till säsong "..seasonNr.." med ".. #seasonData.episodes .. " episoder")

		local count = _G.tenfLib.tableCount(listOfEverything.seasons)

		if count == nrOfSeasons then
			_G.setAttr(listOfEverything, data)
			onComplete({data = listOfEverything})
		end
	end

	getAmountOfSeasons(imdbID, function(listOfSeasons)
		nrOfSeasons = #listOfSeasons
		if nrOfSeasons > 0 then
			for seasonNr, _ in ipairs(listOfSeasons) do
				getSeasonData(imdbID, seasonNr, function(listOfEpisodes)
					addNewSeason(seasonNr, {seasonNr = seasonNr, episodes = listOfEpisodes})
				end)		
			end
		else
			local dataToReturn = {seasons = {}}
			_G.setAttr(dataToReturn, data)
			onComplete({data = dataToReturn})
		end
	end)

	function errorOccured()
		onComplete({isError = true, messageToUser = "Något gick fel, vill du SMSa felet till Tommy? (Det skrivs automatiskt)", message = "fetching/parsing series imdbID: " .. imdbID})
	end
	
end

