

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

local popup

-- Called when the scene's view does not exist:
function scene:createScene( event )
    local sceneView = self.view
    
    local bgGroup = _G.newGroup(sceneView)
    local guiGroup = _G.newGroup(sceneView)

	_G.createBackground(bgGroup)
	
    local title = _G.createTitle(guiGroup, "Inställningar")
    
    local padding = 10

    local mySettings = _G.getSettings()
    local function addChooserRow(parent, text, previous, setting)
        local row = _G.newGroup(parent)

        local marginSides = 40

        local text = display.newText(row, text, 0, 0, _G.fontName, _G.fontSizeNormal)
        text.anchorX, text.anchorY = 0, 0
        text.x, text.y = 0, 0

        if setting then
            local check = require("modules.checkBox")(row, 0, 0, text.height, 5)
            check.x, check.y = _G._W - check.width / 2 - marginSides*2, text.height / 2

            local settingValue = not not mySettings[setting]
            check:setChecked(settingValue)

            check:addEventListener("check", function(e)
                local settingsId = check.parent.setting
                if not settingsId then return end

                local settings = {}
                settings[settingsId] = e.checked
                _G.setSettings(settings)
            end)
        end

        row.x, row.y = marginSides, previous.y + previous.height + padding

        row.setting = setting

        return row
    end

    -- Filmer
        local movieGroup = _G.newGroup(guiGroup)

        local subTitleMovies = _G.setAttr( display.newText(movieGroup, "Filmer:", 0, 0, _G.fontName, _G.fontSizeLarge), {x = 10, y = 0}, {rp='TL'} )

        local movieAirDateText = addChooserRow(movieGroup, "Film släpps:", {x = 0, y = subTitleMovies.y, height = subTitleMovies.height}, "movieStart")

        movieGroup.x, movieGroup.y = 0, title.y + title.height + padding
    ---

    local lineY = movieGroup.y + movieGroup.height + padding * 1.5
    local divider = display.newLine(guiGroup, 10, lineY, _G._W - 10, lineY)
    divider.strokeWidth = 2

    -- Serier
        local seriesGroup = _G.newGroup(guiGroup)

        local subTitleSeries = _G.setAttr( display.newText(seriesGroup, "Serier:", 0, 0, _G.fontNameBold, _G.fontSizeLarge), {x = 10, y = 0}, {rp='TL'} )

        local newSeasonStartText = addChooserRow(seriesGroup, "Säsong startar:", {x = 30, y = subTitleSeries.y, height = subTitleSeries.height}, "seasonStart")

        local newSeasonEndText = addChooserRow(seriesGroup, "Säsong slutar:", newSeasonStartText, "seasonEnd")

        local newEpisodeStartText = addChooserRow(seriesGroup, "Episod släpps:", newSeasonEndText, "episodeStart")

        seriesGroup.x, seriesGroup.y = movieGroup.x, divider.y + divider.height + padding
    ---

    local lineY = seriesGroup.y + seriesGroup.height + padding * 1.5
    local divider = display.newLine(guiGroup, 10, lineY, _G._W - 10, lineY)
    divider.strokeWidth = 2
-- [[
    local settings = _G.getSettings()
    if settings.username then
        -- Login
            local loginGroup = _G.newGroup(guiGroup)

            local subTitleLogin = _G.setAttr( display.newText(loginGroup, "Inloggning:", 0, 0, _G.fontNameBold, _G.fontSizeLarge), {x = 10, y = 0}, {rp='TL'} )

            local UsernameText = addChooserRow(loginGroup, "Användarnamn: " .. settings.username, {x = 30, y = subTitleLogin.y, height = subTitleLogin.height}, nil)

            local UserId = addChooserRow(loginGroup, "AnvändarID: " .. (settings.userid or "Not found"), UsernameText, nil)

            loginGroup.x, loginGroup.y = seriesGroup.x, divider.y + divider.height + padding
        ---
    end
--]]
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