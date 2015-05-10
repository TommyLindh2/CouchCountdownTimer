-- Functions
local SearchOnImdb
local errorOccured

local searchTypes = 
{
	All = "all",
	Titles = "tt",
	TvEpisodes = "ep",
	Names = "nm",
	Characters = "ch",
}



function SearchOnImdb(searchString, searchType, _onComplete)	
	local searchValue = searchTypes["Titles"]
	local url = "http://www.imdb.com/find?q=" .. searchString .. "&s=" .. searchValue
	print("Hämtar data från: "..url)

	network.request( url, "GET", function( event )
		local xmlReader = require("modules.xmlParser")
		if ( event.isError ) then
			errorOccured(url)
			print( "Network error!")
		else
			local resp = event.response
			-- Specify as many/few of these as you like

			local resultListStarted = false

			local listOfSearchHits = {}
			local currentHit = nil
			local currentValueToFind = nil

			

			local parser = xmlReader:parser(
			{
				startElement = function(name,nsURI,nsPrefix)  		-- When "<foo" or <x:foo is seen
					
				end,
				attribute = function(name,value,nsURI,nsPrefix) 	-- attribute found on current element
					if name == "class" and (value == "findSection") then
						resultListStarted = true
					end

					if resultListStarted then
						if name == "class" and _G.stringStartsWith(value, "findResult") then
							currentHit = {}
							listOfSearchHits[#listOfSearchHits + 1] = currentHit
						end
						if name == "class" and value == "result_text" then
							currentValueToFind = value
						elseif name == "href" and currentValueToFind == "result_text" then
							local splitted = _G.tenfLib.stringSplit(value, "/")
							if #splitted >= 3 then
								currentHit.imdbID = splitted[3]
							else
								currentHit.imdbID = false
							end
						else
							currentValueToFind = nil
						end

					end

				end,
				text = function(text)
					if currentValueToFind then
						currentHit[#currentHit + 1] = text
					end
				end,
				closeElement = function(name,nsURI,nsPrefix)
					if resultListStarted and name == "table" then
						resultListStarted = false
						currentValueToFind = nil
					end
				end
			})

			

			-- Ignore whitespace-only text nodes and strip leading/trailing whitespace from text
			-- (does not strip leading/trailing whitespace from CDATA)
			if pcall(function() parser:parse(resp, {stripWhitespace=true}) end) then
				for i, searchHit in ipairs(listOfSearchHits) do
					for j,_ in ipairs(searchHit) do
						searchHit.Title = searchHit.Title or ""
						local attr = searchHit[j]
						searchHit[j] = nil
						searchHit.Title = searchHit.Title .. " " .. attr
					end
				end

				_onComplete(listOfSearchHits)
			else
				errorOccured(url)
			end

		end
	end)
end



return function(searchString, onComplete)

	SearchOnImdb(searchString, "Titles", function(searchHits)
		onComplete({isError = false, result = searchHits})
	end)

	function errorOccured(url)
		onComplete({isError = true, messageToUser = "Något gick fel, vill du SMSa felet till Tommy? (Det skrivs automatiskt)", message = "fetching searchResults: " .. url})
	end
end

