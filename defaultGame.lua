local fileVersion = "v0.01"

local playerFunctions = {}
local otherFunctions = {}

function playerFunctions.getTeam(Player) -- // Return the player Team and TeamColor
    local Team = Player.Team 
    return Team, Player.TeamColor.Color
end

function playerFunctions.getCharacter(Player) -- // Return the player Character and RootPart
    local Character = Player.Character 
    return Character, Character and findFirstChild(Character, "HumanoidRootPart") -- // check if Character exists and return the RootPart
end

function playerFunctions.getHealth(Character)
    local Humanoid = findFirstChild(Character, "Humanoid")
    if not Humanoid then return 100, 100 end 

    return Humanoid.Health, Humanoid.MaxHealth
end

function playerFunctions.isVisible(Character, castPosition)
    local newParams = emptyParams;

    newParams.FilterDescendantsInstances = {localPlayerCharacter, currentCamera, Character}
    return not Raycast(workspace, cameraOrigin, castPosition - cameraOrigin, newParams)
end

otherFunctions.getMouseOffsetEnabled = false 
local function otherFunctions.getMouseOffset()
    return Vector2.new(0,0)
end 

otherFunctions.getESPOffsetEnabled = false 
local function otherFunctions.getESPOffset()
    return Vector2.new(0,0)
end 

--[[custom ESP Objects
local chestToggle = customESPObjects.Add("Chest") -- // adds a toggle to the ui, returns a table; (chestToggle.Value, chestToggle:Disable(), chestToggle:Enable())
--]]

return playerFunctions, otherFunctions, fileVersion
