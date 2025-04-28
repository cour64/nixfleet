-- Hammerspoon script for switching Mission Control desktops and moving apps between them
-- Uses Option+1-9 to switch desktops and Option+Shift+1-9 to move current app to a desktop

-- Store the spaces/desktop functionality in a table
local spaces = {}

-- Load the required Hammerspoon extension for Mission Control spaces
spaces.watcher = require("hs.spaces")

-- Initialize the script
function spaces:init()
    -- Define modifiers for both actions
    local switchMod = {"alt"}
    local moveMod = {"alt", "shift"}
    
    -- Set up key bindings for desktop switching (Option + 1-9)
    for i = 1, 9 do
        hs.hotkey.bind(switchMod, tostring(i), function()
            self:switchToSpace(i)
        end)
    end
    
    -- Set up key bindings for moving apps to desktops (Option + Shift + 1-9)
    for i = 1, 9 do
        hs.hotkey.bind(moveMod, tostring(i), function()
            self:moveAppToSpace(i)
        end)
    end
    
    return self
end

-- Function to switch to a specific Mission Control desktop
function spaces:switchToSpace(spaceNumber)
    local allSpaces = spaces.watcher.allSpaces()
    local currentScreen = hs.screen.mainScreen()
    local screenSpaces = allSpaces[currentScreen:getUUID()]
    
    -- Check if the requested space exists
    if spaceNumber <= #screenSpaces then
        local targetSpace = screenSpaces[spaceNumber]
        spaces.watcher.gotoSpace(targetSpace)
    else
        hs.alert.show("Space " .. spaceNumber .. " does not exist")
    end
end

-- Function to move the current application to a specific Mission Control desktop
function spaces:moveAppToSpace(spaceNumber)
    local win = hs.window.focusedWindow()
    if not win then
        hs.alert.show("No window in focus")
        return
    end
    
    local allSpaces = spaces.watcher.allSpaces()
    local currentScreen = hs.screen.mainScreen()
    local screenSpaces = allSpaces[currentScreen:getUUID()]
    
    -- Check if the requested space exists
    if spaceNumber <= #screenSpaces then
        local targetSpace = screenSpaces[spaceNumber]
        spaces.watcher.moveWindowToSpace(win:id(), targetSpace)
        spaces:switchToSpace(spaceNumber)
        hs.alert.show("Moved to space " .. spaceNumber)
    else
        hs.alert.show("Space " .. spaceNumber .. " does not exist")
    end
end

-- Initialize and return our spaces module
return spaces:init()