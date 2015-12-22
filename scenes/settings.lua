

local composer = require( "composer" )
local scene = composer.newScene()

-- local forward references should go here --


---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

local popup

-- Called when the scene's view does not exist:
function scene:create( event )
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

            local UserId = addChooserRow(loginGroup, "AnvändarID: " .. (settings.iduser or "Not found"), UsernameText, nil)

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

-- Called when scene is about to move offscreen:
local sceneName
function scene:hide( event )
        local group = self.view
        local phase = event.phase

        if phase == "will" then
            sceneName = composer.getSceneName("current")
        elseif phase == "did" then
            timer.performWithDelay(0, function()
                composer.removeScene(sceneName)
            end)
        end
end

---------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

-- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener( "create", scene )

-- "exitScene" event is dispatched before next scene's transition begins
scene:addEventListener( "hide", scene )

---------------------------------------------------------------------------------

return scene