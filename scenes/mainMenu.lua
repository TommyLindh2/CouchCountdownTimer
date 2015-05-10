

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

--Settings
local buttonColor = {normal = {154 / 255, 53 / 255, 255 / 255}, over = {101 / 255, 0, 202 / 255}}
local buttonTextColor = {over = {0}, normal = {0}}
local buttonStrokeColor = {80 / 255, 0, 180 / 255}
local buttonStrokeWidth = 3

local nrOfColumns = 1
local margin = {x = 20, y = 80}
local padding = {x = 10, y = 20}
local width = math.floor((_G._W - margin.x * 2 - padding.x * (nrOfColumns - 1)) / nrOfColumns)
local height = 40

---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------



-- Called when the scene's view does not exist:
function scene:createScene( event )
    local sceneView = self.view
    
    local bgGroup = _G.newGroup(sceneView)
    local guiGroup = _G.newGroup(sceneView)

	_G.createBackground(bgGroup)
	local settings = 
	{
		nrOfColumns = nrOfColumns,
		margin = margin,
		padding = padding,
		width = width,
		height = height,

		buttonColor = buttonColor,
		buttonTextColor = buttonTextColor,
		buttonStrokeColor = buttonStrokeColor,
		buttonStrokeWidth = buttonStrokeWidth,

	}
	local buttonGrid = require("modules.buttonGrid")(guiGroup, settings)

	_G.createTitle(guiGroup, "Huvudmeny")

    local x, y = buttonGrid:getPosition(buttonGrid:getColumnRow(1))
    local btnMySeries = buttonGrid:createButton("Mina titlar", x, y, function(e)
        storyboard.gotoScene("scenes.myTitles")
	end)

	local x, y = buttonGrid:getPosition(buttonGrid:getColumnRow(2))
	local btnAddNewSeries = buttonGrid:createButton("Lägg till titlar", x, y, function(e)
		storyboard.gotoScene("scenes.addTitles")
	end)

    _G.setKeyEventHandlers(
        {
            back = function(e)
                return false
            end
        }
    )

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