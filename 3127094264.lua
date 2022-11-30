local fileVersion = "v1.0a"

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

local Players = game:GetService("Players")

-- // Character Handler 

local characterList = {}
for i, v in pairs(workspace:GetChildren()) do
    if v:FindFirstChild("Head") ~= nil and v.Head:FindFirstChild("Nametag") ~= nil and Players:FindFirstChild(v.Head.Nametag.tag.Text) then 
        characterList[v.Head.Nametag.tag.Text] = v 
    end 
end 

workspace.ChildAdded:Connect(function(v)
    if v:FindFirstChild("Head") ~= nil and v.Head:FindFirstChild("Nametag") ~= nil and Players:FindFirstChild(v.Head.Nametag.tag.Text) then 
        characterList[v.Head.Nametag.tag.Text] = v 
    end 
end)

-- // Functions

function playerFunctions.getTeam(Player) -- // Return the player Team and TeamColor
    local Team = Player.Team 
    return Team, Player.TeamColor.Color
end

function playerFunctions.getCharacter(Player) -- // Return the player Character and RootPart
    local Character = characterList[Player.Name]
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
function otherFunctions.getMouseOffset()
    return Vector2.new(0,0)
end 

otherFunctions.getESPOffsetEnabled = false 
function otherFunctions.getESPOffset()
    return Vector2.new(0,0)
end 

return playerFunctions, otherFunctions, fileVersion
