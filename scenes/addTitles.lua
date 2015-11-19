

local composer = require( "composer" )
local scene = composer.newScene()

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
			native.setKeyboardFocus( nil )
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
		native.setKeyboardFocus( nil )
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
function scene:create( event )
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
	searchField.myText = "supernatural"


	local x, y = searchField.x + tWidth + 10 + 50, searchField.y
	btnSearch = buttonGrid:createButton("Sök", x, y, btnSearchFunction)
end


-- Called immediately after scene has moved onscreen:
function scene:show( event )
	local group = self.view

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
local sceneName
function scene:hide( event )
	local group = self.view
	local phase = event.phase

    if phase == "will" then
		sceneName = composer.getCurrentSceneName()
		if searchField then
			searchField:removeSelf()
			searchField = nil
		end
    elseif phase == "did" then

		if popup then
	        _G.tenfLib.removeEventListeners(popup)
	        popup:close()
	    end

	    timer.performWithDelay(0, function()
            composer.removeScene(sceneName)
        end)
	end
end



---------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------


scene:addEventListener( "show", scene )

-- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener( "create", scene )

-- "exitScene" event is dispatched before next scene's transition begins
scene:addEventListener( "hide", scene )

---------------------------------------------------------------------------------

return scene