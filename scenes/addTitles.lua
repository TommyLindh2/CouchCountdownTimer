

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
local searchField
local btnSearch

local bgGroup
local guiGroup


local function btnSearchFunction(e)
	native.setKeyboardFocus( nil )
	if scrollView then
		scrollView:deleteRows()
	end

	local searchString = (_G.isSimulator and not _G.isIos) and searchField.myText or searchField.text
	native.setActivityIndicator(true, "Söker efter: \"" .. searchString .."\"")
	searchField.isVisible = false
	searchString = searchString:gsub(" ", "+")

	local settings =
	{
		margin = {top = btnSearch.y + btnSearch.height / 2 + 10, bottom = 10 + _G.tabBarHeight},
	}
	if not scrollView then
		scrollView = scrollViewCreator(guiGroup, settings, function(e)
			popup = require("modules.titlePopup")(nil, e.data)
			searchField.isVisible = false
			popup:addEventListener("beforeClosed", function(e)
				searchField.isVisible = true
				popup = nil
			end)
			popup:addEventListener("closed", function(e)
				scrollView.tapped = false
			end)
		end)
	end

	require("modules.searchOnImdbParser")(searchString, function(event)
		native.setActivityIndicator(false)
		searchField.isVisible = true
		if event.isError then
			_G.errorAlert(event)
		else
			for i, searchData in ipairs(event.result) do
				local viewData = 
				{
					
				}
				scrollView:append(searchData.Title, searchData, viewData)
			end
		end
	end)
end

-- Called when the scene's view does not exist:
function scene:createScene( event )
	local sceneView = self.view
	
	bgGroup = _G.newGroup(sceneView)
	guiGroup = _G.newGroup(sceneView)

	_G.createBackground(bgGroup)
	
	local title = _G.createTitle(guiGroup, "Lägg till titlar")
	

	local tHeight = 30
	local tWidth = _G._W - 130
	local buttonGrid = require("modules.buttonGrid")(guiGroup, {width = 100, height = tHeight})

	local inputFontSize = _G.fontSizeNormal

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
	searchField:addEventListener( "userInput", function(e)
		if e.phase == "submitted" then
			btnSearchFunction()
		end
	end )
	searchField.myText = "true"


	local x, y = searchField.x + tWidth + 10 + 50, searchField.y
	btnSearch = buttonGrid:createButton("Sök", x, y, btnSearchFunction)
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
	if searchField then
		searchField.isVisible = true
	end

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
end


-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local group = self.view
	if searchField then
		searchField.isVisible = false
	end

	if popup then
        _G.tenfLib.removeEventListeners(popup)
        popup:close()
    end
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