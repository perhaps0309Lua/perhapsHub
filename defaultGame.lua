local fileVersion = "v1.0b"

local playerFunctions = {}
local otherFunctions = {}

-- // Variables

local findFirstChild = game.FindFirstChild

local Raycast = workspace.Raycast

local Enum = Enum
local RaycastFilterType = Enum.RaycastFilterType
local BlacklistFilterType = RaycastFilterType.Blacklist

local raycastParamsNew = RaycastParams.new 
local emptyParams = raycastParamsNew()
emptyParams.IgnoreWater = true 
emptyParams.FilterType = BlacklistFilterType

local currentCamera = workspace.CurrentCamera
local cameraCFrame = currentCamera.CFrame 
local cameraOrigin = cameraCFrame.Position

local Players = game:GetService("Players")

-- // Functions

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

function playerFunctions.isVisible(Character, castPosition, localPlayerCharacter)
    local newParams = emptyParams;

    newParams.FilterDescendantsInstances = {localPlayerCharacter, currentCamera, Character}
    return not Raycast(workspace, cameraOrigin, castPosition - cameraOrigin, newParams)
end

function playerFunctions.GetPlayerFromCharacter(Character)
    return Players:GetPlayerFromCharacter(Character)
end

function playerFunctions.GetColor(Object)
    local isPlayer = playerFunctions.GetPlayerFromCharacter(Object)
    return isPlayer and isPlayer.Team and isPlayer.Team.TeamColor and isPlayer.Team.TeamColor.Color or false -- // false will just default to rgb(0, 255, 0)
end

otherFunctions.getMouseOffsetEnabled = false 
function otherFunctions.getMouseOffset()
    return Vector2.new(0,0)
end 

otherFunctions.getESPOffsetEnabled = false 
function otherFunctions.getESPOffset()
    return Vector2.new(0,0)
end 

--[[custom ESP Objects
local chestToggle = customESPObjects.Add("Chest") -- // adds a toggle to the ui, returns a table; (chestToggle.Value, chestToggle:Disable(), chestToggle:Enable())
--]]

return playerFunctions, otherFunctions, fileVersion
