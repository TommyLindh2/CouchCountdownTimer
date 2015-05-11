

local storyboard = require( "storyboard" )
local scene = storyboard.newScene()

----------------------------------------------------------------------------------
-- 
--      NOTE:
--      
--      Code outside of listener functions (below) will only be executed once,
--      unless storyboard.removeScene() is called.
-- 
---------------------------------------------------------------------------------


-- local forward references should go here --


---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

local scrollViewCreator = require("modules.buttonScrollView")
local scrollView
local popup

local myTitles
local searchField
local lastSearch

local reloadTitles
local searchFunction, filtersFunction
local updateAllTitles

local saveManager = require("modules.saveManager")('tompa', 'hemligt123')

function updateAllTitles(_onComplete)
	_G.downloadTitles(_G.loadTitles(), function(args)
		if args.counter >= args.total then
			reloadTitles(lastSearch)
			native.setActivityIndicator(false)
			if _onComplete then
				_onComplete()
			end
		else
			native.setActivityIndicator(true, args.counter .. " / " .. args.total .. " Klar!")
		end
	end)
end

-- Called when the scene's view does not exist:
function scene:createScene( event )
	local sceneView = self.view
	
	local bgGroup = _G.newGroup(sceneView)
	local guiGroup = _G.newGroup(sceneView)

	_G.createBackground(bgGroup)
	local params = event.params or {}

	if params.askForUpdate then
		local timeSinceLastUpdate = _G.getTimeSinceLastDownload()
		if timeSinceLastUpdate.day >= 7 then
			
			native.showAlert("Varning!", "Det var mer än en vecka sen du uppdaterade dina titlar.\nVill du uppdatera de nu? (Det rekomenderas)", {"Ja", "Nej"}, function(e)
				if e.action == "clicked" then
					if e.index == 1 then
						updateAllTitles()		
					else
						-- void
					end
				end
			end)
		end
	end
	

	local function setView(_type)
		if scrollView then
			_G.setSettings({typeOfView = _type})
			scrollView:setTypeOfView(_type)
		end
	end

	local function downloadAllTitles()
		native.setKeyboardFocus( nil )
		updateAllTitles()
	end

	local title = _G.createTitle(guiGroup, "Mina titlar")
	local inputFontSize = _G.fontSizeNormal

	local tHeight = 30
	local tWidth = _G._W - 130
	local buttonGrid = require("modules.buttonGrid")(guiGroup, {width = 100, height = tHeight})
	
	if ( _G.isAndroid ) then
		inputFontSize = inputFontSize - 4
		tHeight = tHeight + 10
	end

	searchField = native.newTextField( 0, title.y + title.height + 10, tWidth, tHeight )
	searchField.placeholder = "Sök..."
	searchField.anchorX = 0
	searchField.x = 10
	guiGroup:insert(searchField)
	searchField.font = native.newFont( _G.fontName, inputFontSize )
	searchField:addEventListener( "userInput", function(event)
		if ( event.phase == "began" ) then
			-- void
		elseif ( event.phase == "ended" ) then
			-- void
		elseif ( event.phase == "ended" or event.phase == "submitted" ) then
			-- void
		elseif ( event.phase == "editing" ) then
			local searchText = event.text
			reloadTitles(searchText)
		end
	end )


	local x, y = searchField.x + tWidth + 10 + 50, searchField.y
	local btnFilter = buttonGrid:createButton("Filter", x, y, function(e)
		local target = e.target
		local refPos = 
		{
			x = target.x + target.width / 2,
			y = target.y - target.height / 2
		}
		popup = require("modules.filtersPopup")(nil, refPos)
		searchField.isVisible = false
		popup:addEventListener("beforeClosed", function(e)
			if e.reloadTitles then
				reloadTitles(lastSearch)
			end
		end)
		popup:addEventListener("closed", function(e)
			searchField.isVisible = true
			popup = nil
		end)
		native.setKeyboardFocus( nil )
	end)

	local function checkBoxHandler(e)

		local function handleStates(doWork, type)
			if doWork then
				if type == "add" then
					_G.addSeenState(e.data.imdbID)
				elseif type == "remove" then
					_G.removeSeenState(e.data.imdbID)
				end
				reloadTitles(lastSearch)
			else
				local state = _G.loadSeenState(e.data.imdbID)
				if state == "all" then
					e.target:setChecked(true)
				elseif state == "some" then
					e.target:setCheckedAlt(true)
				elseif state == "allReleased" then
					e.target:setCheckedAlt(true)
				else
					e.target:setChecked(false)
				end
			end
		end

		if e.target.checked then
			if e.data.Type == "series" then
				native.showAlert("Varning", "Vill du bocka i hela serien som sedd?", {"Ja", "Nej"}, function(alertEvent)
					if alertEvent.action == "clicked" then
						if alertEvent.index == 1 then
							handleStates(true, "add")
						else
							handleStates(false)
						end
					end
				end)
			else
				handleStates(true, "add")
			end
		else
			if e.data.Type == "series" then
				native.showAlert("Varning", "Vill du avbocka hela serien som sedd?", {"Ja", "Nej"}, function(alertEvent)
					if alertEvent.action == "clicked" then
						if alertEvent.index == 1 then
							handleStates(true, "remove")
						else
							handleStates(false)
						end
					end
				end)
			else
				handleStates(true, "remove")
			end
		end
	end

	local settings =
	{
		margin = {top = btnFilter.y + btnFilter.height / 2 + 10, bottom = 10 + _G.tabBarHeight},
	}
	scrollView = scrollViewCreator(guiGroup, settings, function(e)
		if e.data.Type == "series" then
			popup = require("modules.episodesReleasePopup")(nil, e.data)
		else
			popup = require("modules.movieReleasePopup")(nil, e.data)
		end
		searchField.isVisible = false
		popup:addEventListener("beforeClosed", function(e)
			if e.reloadTitles then
				reloadTitles(lastSearch)
			end
		end)
		popup:addEventListener("closed", function(e)
			searchField.isVisible = true
			scrollView.tapped = false
			popup = nil
		end)
	end, checkBoxHandler)

	function reloadTitles(_search)
		if not scrollView then return end

		local filters = _G.getFilters()

		lastSearch = _search
		if _search then
			_search = _G.tenfLib.trim(_search)
			_search = _G.tenfLib.stringToLower(_search)
			_search = _G.tenfLib.stringSplit(_search, " ")
		end


		local previousScrollY = nil
		if scrollView:getNumRows() > 0 then
			previousScrollY = scrollView:getContentPosition()
			scrollView:deleteRows()
		end

		myTitles = _G.loadTitles()

		for imdbID, data in pairs(myTitles) do
			local seen, seenCount = _G.loadSeenState(imdbID)
			local viewData = 
			{
				showProgress = data.Type == "series",
				imdbType = data.Type,
				seen = seen,
				seenCount = seenCount,
			}

			local filterSuccessful = filtersFunction(data, filters, _G.getHidden(imdbID))
			local searchSuccessful = searchFunction(data, _search)

			if (_search and searchSuccessful) or (filterSuccessful and searchSuccessful) then
				scrollView:append(data.Title .. " ( ".. data.Year .." )", data, viewData)
			end
			
		end
		if previousScrollY then
			scrollView:scrollToY({ y=previousScrollY, time=0 })
		end
	end

	function filtersFunction(data, _filters, _hidden)
		if _filters and _G.tenfLib.tableCount(_filters) > 0 then
			--[[
				hideSeries
				hideMovies
				hideSeen
				hideUnSeenNotReleased
				hideUnSeen
				hideSomeSeen
				hideUnknown
				showHidden
			]]
			local mySeenState = _G.loadSeenState(data.imdbID)
			if _filters["hideSeries"] then if data.Type == "series" then return false end end
			if _filters["hideMovies"] then if data.Type ~= "series" then return false end end
			if _filters["hideSeen"] then if mySeenState == "all" then return false end end
			if _filters["hideUnSeen"] then if mySeenState == "none" then return false end end
			if _filters["hideSomeSeen"] then if mySeenState == "some" then return false end end
			if _filters["hideUnknown"] then if mySeenState == "unknown" then return false end end
			if _filters["hideUnSeenNotReleased"] then if mySeenState == "allReleased" then return false end end
			if not _filters["showHidden"] then if _hidden then return false end end
		end
		return true
	end

	function searchFunction(data, _searchParts)
		
		if _searchParts and #_searchParts > 0 then
			local title = _G.tenfLib.stringToLower(data.Title)
			local titleParts = _G.tenfLib.stringSplit(title, " ")
			local found = false
			for i, _searchString in ipairs(_searchParts) do
				for j, _titlePart in ipairs(titleParts) do
					found = _G.stringStartsWith(_titlePart, _searchString)
					if found then break end
				end
				if found then break end
			end
			return found
		else
			return true
		end
	end

	reloadTitles(lastSearch)
	
	_G.setKeyEventHandlers(
		{
			back = function(e)
				if popup then
					popup:close()
					popup = nil
				else
					return false
				end
				return true
			end
		}
	)

	local typeOfView = _G.getSettings().typeOfView
	scrollView:setTypeOfView(typeOfView)

	local buttons =
	{
		{title = "Uppdatera data från IMDB", onClick = downloadAllTitles},
		{title = "Utan bild", onClick = function(e) setView("normal") end},
		{title = "Med bild", onClick = function(e) setView("photo") end},
		--{title = "Server:", type = 'separator'},
		{title = "Spara data på server", onClick = function(e)
			saveManager:saveData(_G.getMyData(), function(e)
				if e.success then
					native.showAlert("Yaay!", e.message, {"Ok"}, function(e)
						-- void
					end)
				else
					native.showAlert("Varning!", e.message, {"Ok"}, function(e)
						-- void
					end)
				end
			end)
		end},
		{title = "Ladda data från server", onClick = function(e)
			saveManager:loadData(function(e)
				if e.success then
					if not (_G.tenfLib.trim(e.data or "") == "") then
						local result = _G.setMyData(e.data)
						if result then
							native.showAlert("Yaay!", "Data hämtad från server", {"Ok"}, function(e)
								_G.reloadMyData()
								reloadTitles(lastSearch)
							end)
						else
							native.showAlert("Varning!", "Hämtad data är korrupt.\n\nSätt dig ett tag och gråt, för detta är inte bra... :(", {"Ok"}, function(e)
								-- void
							end)
						end
					else
						native.showAlert("Varning!", "Hittar ingen data med din användare.", {"Ok"}, function(e)
							-- void
						end)
					end
				else
					native.showAlert("Varning!", e.message or "<what?>", {"Ok"}, function(e)
						-- void
					end)
				end
			end)
		end}
	}
	local sideMenu = require("modules.sideMenu")(
		{
			parent = guiGroup,
			buttons = buttons
		}
	)

	sideMenu:addEventListener("beganDragging", function()
		searchField.isVisible = false
		if scrollView then
			scrollView:setEnabled(false)
		end
	end)

	sideMenu:addEventListener("closed", function()
		searchField.isVisible = true
		if scrollView then
			scrollView:setEnabled(true)
		end
	end)

end
-- Called BEFORE scene has moved onscreen:
function scene:willEnterScene( event )
	local group = self.view

	-----------------------------------------------------------------------------

	--      This event requires build 2012.782 or later.

	-----------------------------------------------------------------------------

end


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
		local group = self.view

		-----------------------------------------------------------------------------

		--      INSERT code here (e.g. start timers, load audio, start listeners, etc.)

		-----------------------------------------------------------------------------

end


-- Called when scene is about to move offscreen:
function scene:exitScene( event )
		local group = self.view

		if popup then
			_G.tenfLib.removeEventListeners(popup)
			popup:close()
		end

		if searchField then
			searchField:removeSelf()
			searchField = nil
		end

		local sceneName = storyboard.getCurrentSceneName()
		timer.performWithDelay(0, function()
			storyboard.removeScene(sceneName)
		end)
end


-- Called AFTER scene has finished moving offscreen:
function scene:didExitScene( event )
		local group = self.view

		-----------------------------------------------------------------------------

		--      This event requires build 2012.782 or later.

		-----------------------------------------------------------------------------

end


-- Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )
		local group = self.view

		-----------------------------------------------------------------------------

		--      INSERT code here (e.g. remove listeners, widgets, save state, etc.)

		-----------------------------------------------------------------------------

end


-- Called if/when overlay scene is displayed via storyboard.showOverlay()
function scene:overlayBegan( event )
		local group = self.view
		local overlay_name = event.sceneName  -- name of the overlay scene

		-----------------------------------------------------------------------------

		--      This event requires build 2012.797 or later.

		-----------------------------------------------------------------------------

end


-- Called if/when overlay scene is hidden/removed via storyboard.hideOverlay()
function scene:overlayEnded( event )
		local group = self.view
		local overlay_name = event.sceneName  -- name of the overlay scene

		-----------------------------------------------------------------------------

		--      This event requires build 2012.797 or later.

		-----------------------------------------------------------------------------

end



---------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

-- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener( "createScene", scene )

-- "willEnterScene" event is dispatched before scene transition begins
scene:addEventListener( "willEnterScene", scene )

-- "enterScene" event is dispatched whenever scene transition has finished
scene:addEventListener( "enterScene", scene )

-- "exitScene" event is dispatched before next scene's transition begins
scene:addEventListener( "exitScene", scene )

-- "didExitScene" event is dispatched after scene has finished transitioning out
scene:addEventListener( "didExitScene", scene )

-- "destroyScene" event is dispatched before view is unloaded, which can be
-- automatically unloaded in low memory situations, or explicitly via a call to
-- storyboard.purgeScene() or storyboard.removeScene().
scene:addEventListener( "destroyScene", scene )

-- "overlayBegan" event is dispatched when an overlay scene is shown
scene:addEventListener( "overlayBegan", scene )

-- "overlayEnded" event is dispatched when an overlay scene is hidden/removed
scene:addEventListener( "overlayEnded", scene )

---------------------------------------------------------------------------------

return scene