-- // Variables

local LocalPlayer = game:GetService("Players").LocalPlayer
local Character = LocalPlayer.Character
local PlayerGui = LocalPlayer.PlayerGui

local PlantMenu = PlayerGui.PlantMenu

local plantRemote = game:GetService("ReplicatedStorage").IslandFieldPlant
local harvestCrop = game:GetService("ReplicatedStorage").HarvestIslandCrop
local buttonClicked = game:GetService("ReplicatedStorage").ButtonClicked
local getCurrency = game:GetService("ReplicatedStorage").GetCurrency

local bakerySell = game:GetService("ReplicatedStorage").BakeryStuff.Sell
local bakerySetRecipe = game:GetService("ReplicatedStorage").BakeryStuff.SetRecipe
local bakeryRequest = game:GetService("ReplicatedStorage").BakeryStuff.RequestRecipe -- // get info for a recipe

local getSeedCount = game:GetService("ReplicatedStorage").GetSeedCount
local buySomethingElse = game:GetService("ReplicatedStorage").BuySomethingElse

local islandField = workspace.IslandField.field 

-- // UI Variables

local wallyRepository = "https://raw.githubusercontent.com/wally-rblx/LinoriaLib/main/"
local Repository = "https://raw.githubusercontent.com/perhaps0309Lua/perhapsHub/main/"

local Library = loadstring(game:HttpGet(Repository.."LinoriaLib.lua"))()
local ThemeManager = loadstring(game:HttpGet(Repository.."ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(wallyRepository.."addons/SaveManager.lua"))()

local Window = Library:CreateWindow({Title = "Crop Farming Incremental", Center = true, AutoShow = true})
local Main = Window:AddTab("Main")
local IslandsAndBakery = Window:AddTab("Island & Bakery")

local mainGroup = Main:AddLeftGroupbox("Main")
local autoSellGroup = Main:AddRightGroupbox("Auto Sell")

local validCrops = {}
for i, v in pairs(game:GetService("ReplicatedStorage").Models:GetChildren()) do
    table.insert(validCrops, v.Name)
end

local chosenCrop = "Wheat";
local chosenCropDropdown = mainGroup:AddDropdown("chosenCrop", {
    Values = validCrops,
    Default = 1,
    Multi = false,
    Text = "Chosen Crop",
    Callback = function(Value)
        chosenCrop = Value
    end,
    Tooltip = "The crop you want to farm"
})

local autoPlantEnabled
local autoPlantToggle = mainGroup:AddToggle("autoPlant", {
    Text = "Auto Plant",
    Enabled = false,
    Callback = function(Value)
        autoPlantEnabled = Value
    end,
    Tooltip = "Automatically plants the chosen crop on the plot you are standing on"
})

local autoHarvestEnabled
local autoHarvestToggle = mainGroup:AddToggle("autoHarvest", {
    Text = "Auto Harvest",
    Enabled = false,
    Callback = function(Value)
        autoHarvestEnabled = Value
    end,
    Tooltip = "Automatically harvests the crop on the plot you are standing on"
})

local autoSellAll = false
local autoSellAllToggle = autoSellGroup:AddToggle("autoSellAll", {
    Text = "Sell All",
    Enabled = false,
    Callback = function(Value)
        autoSellAll = Value
    end,
    Tooltip = "Automatically sells all crops"
})

autoSellGroup:AddDivider()

local autoSellEnabled = false
local autoSellToggle = autoSellGroup:AddToggle("autoSellEnabled", {
    Text = "Enabled",
    Enabled = false,
    Callback = function(Value)
        autoSellEnabled = Value
    end,
    Tooltip = "Automatically sells the chosen crop"
})

local autoSellValues = {}
local autoSellDropdown = autoSellGroup:AddDropdown("autoSellDropdown", {
    Values = validCrops,
    Default = 1,
    Multi = true,
    Text = "Auto Sell",
    Callback = function(Value)
        autoSellValues = Value
    end,
    Tooltip = "Automatically sells the chosen crop"
})

-- // Islands

local islandsGroup = IslandsAndBakery:AddLeftGroupbox("Islands")

local islandAutoPlant = false
local islandAutoPlantToggle = islandsGroup:AddToggle("islandAutoPlant", {
    Text = "Auto Plant",
    Enabled = false,
    Callback = function(Value)
        islandAutoPlant = Value
    end,
    Tooltip = "Automatically plants the chosen crop in the island"
})

local islandAutoHarvest = false
local islandAutoHarvestToggle = islandsGroup:AddToggle("islandAutoHarvest", {
    Text = "Auto Harvest",
    Enabled = false,
    Callback = function(Value)
        islandAutoHarvest = Value
    end,
    Tooltip = "Automatically harvests the chosen crop in the island"
})

local islandAutoBuySeeds = false
local islandAutoBuySeedsToggle = islandsGroup:AddToggle("islandAutoBuySeeds", {
    Text = "Auto Buy Seeds",
    Enabled = false,
    Callback = function(Value)
        islandAutoBuySeeds = Value
    end,
    Tooltip = "Automatically buys seeds in the island"
})

-- // Bakery

local bakeryGroup = IslandsAndBakery:AddRightGroupbox("Bakery")

local bakeryRecipes = {"Bread", "Tomato", "Sugar", "Ketchup", "Apple Juice"}

local bakeryBakeValues = {["Bread"] = true}
local bakeryBakeDropdown = bakeryGroup:AddDropdown("bakeryBakeDropdown", {
    Values = bakeryRecipes,
    Default = 1,
    Multi = true,
    Text = "Recipes",
    Callback = function(Value)
        bakeryBakeValues = Value
    end,
    Tooltip = "Automatically bakes/sells the chosen recipes"
})

local bakeryAutoSell = false
local bakeryAutoSellToggle = bakeryGroup:AddToggle("bakeryAutoSell", {
    Text = "Auto Sell",
    Enabled = false,
    Callback = function(Value)
        bakeryAutoSell = Value
    end,
    Tooltip = "Automatically sells the chosen recipes"
})

local bakeryAutoBake = false
local bakeryAutoBakeToggle = bakeryGroup:AddToggle("bakeryAutoBake", {
    Text = "Auto Bake - Bread for Chlorophyll",
    Enabled = false,
    Callback = function(Value)
        bakeryAutoBake = Value
    end,
    Tooltip = "Automatically bakes the chosen recipes, will bake hundreds per second ;)"
})

-- // Code

local cooldownPlant = false 
PlantMenu:GetPropertyChangedSignal("Enabled"):Connect(function(Value)
    if PlayerGui.PlantMenu.Enabled and not cooldownPlant and autoPlantEnabled then 
        cooldownPlant = true
        task.wait(0.25)
        for i, v in pairs(PlayerGui.PlantMenu.b.PlantCrops:GetChildren()) do 
            if v:IsA("TextButton") and v.Text:lower():find(chosenCrop:lower()) then 
                firesignal(v.Activated)
            end
        end
        task.wait(0.25)
        cooldownPlant = false 
    end
end)

task.spawn(function()
    while task.wait(1) do 
        if not autoPlantEnabled and not autoHarvestEnabled then continue end 

        for i, v in pairs(workspace.Plots:GetChildren()) do 
            if not v:FindFirstChild("interaction") then continue end 

            local interaction = v.interaction
            if autoPlantEnabled then 
                fireproximityprompt(interaction.Plant)
            end 

            if autoHarvestEnabled then 
                fireproximityprompt(interaction.Harvest)
            end
        end
    end 
end)

task.spawn(function() -- // auto sell
    while task.wait(1) do 
        if autoSellEnabled then 
            for i, v in pairs(validCrops) do 
                buttonClicked:InvokeServer("Max", v)
            end 
        else 
            for i, v in pairs(autoSellValues) do 
                buttonClicked:InvokeServer("Max", v)
            end
        end 
    end 
end)

-- // Islands

islandField.DescendantAdded:Connect(function(Part)
    if Part.Name ~= "4" or not Part:IsA("Model") then return end 

    task.wait(math.random(1, 3)/1000)
    local partParent = Part.Parent 
    if islandAutoHarvest then 
        harvestCrop:FireServer(partParent)
    end 

    if islandAutoPlant then 
        task.wait(0.25)
        plantRemote:FireServer(partParent, chosenCrop)
    end
end)

task.spawn(function()
    while task.wait(5) do 
        if not islandAutoPlant then continue end; 

        for i, v in pairs(islandField:GetChildren()) do 
            if v.Name ~= "part" or v:FindFirstChildWhichIsA("Model") then continue end

            task.spawn(function()
                task.wait(0.25)
                plantRemote:FireServer(v, chosenCrop)
            end)
        end 
    end 
end)

task.spawn(function()
    while task.wait(1) do 
        if not islandAutoBuySeeds then continue end; 

        local currentCount = getSeedCount:InvokeServer(chosenCrop)
        if currentCount ~= 420 and typeof(currentCount) == "number" then 
            buySomethingElse:InvokeServer("Seed", chosenCrop, 420-currentCount)
        end
    end
end)

-- // Bakery

task.spawn(function()
    while task.wait(1) do 
        if not bakeryAutoSell then continue end;
        
        -- // grab bakery amounts, then sell a max of 500 of each, sell each recipe simultaneously
        for i, v in pairs(bakeryBakeValues) do 
            task.spawn(function()
                local recipeAmount = getCurrency:InvokeServer(i)
                if not recipeAmount then return end;
                -- // pause for 0.25 every 125 recipes sold

                local passedAmount = 0
                for i1 = 1, recipeAmount > 500 and 500 or recipeAmount do 
                    passedAmount += 1
                    task.spawn(function()
                        bakerySell:InvokeServer(i)
                    end)

                    if passedAmount == 125 then 
                        task.wait(0.25)
                        passedAmount = 0
                    end
                end 
            end)
        end
    end 
end)

-- // bakery auto bake

task.spawn(function()
    while task.wait(1) do 
        if not bakeryAutoBake then continue end;

        for i, v in pairs(bakeryBakeValues) do 
            task.spawn(function()
                local recipeInfo = bakeryRequest:InvokeServer(i)
                if not recipeInfo then return end

                local recipeIngredients = recipeInfo.Ingredients

                local recipeAmounts = {}
                for i, v in pairs(recipeIngredients) do 
                    recipeAmounts[v] = getCurrency:InvokeServer(i) -- // store needed amount and current amount
                end

                -- // get how many we can bake

                local bakeAmount;
                for i, v in pairs(recipeAmounts) do -- // get the lowest amount of ingredients we can bake
                    if not bakeAmount then 
                        bakeAmount = (v/i)
                    elseif (v/i) < bakeAmount then
                        bakeAmount = (v/i)
                    end
                end

                -- // bake

                local passedAmount = 0
                for i1 = 1, bakeAmount > 500 and 500 or bakeAmount do 
                    passedAmount += 1
                    task.spawn(function()
                        bakerySetRecipe:InvokeServer(i)
                    end)

                    if passedAmount == 125 then 
                        task.wait(0.25)
                        passedAmount = 0
                    end
                end
            end)
        end
    end 
end)

-- // Finish UI

local UISettings = Window:AddTab("UI Settings")
local MenuGroup = UISettings:AddLeftGroupbox("Menu")

MenuGroup:AddButton('Unload', function() Library:Unload() end)
MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { Default = 'Minus', NoUI = true, Text = 'Menu keybind' }) 

Library.ToggleKeybind = Options.MenuKeybind 

Library:OnUnload(function()
    Library.Unloaded = true
end)

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

SaveManager:IgnoreThemeSettings() 
SaveManager:SetIgnoreIndexes({ 'MenuKeybind' }) 

ThemeManager:SetFolder('perhapsScripts')
SaveManager:SetFolder('perhapsScripts/CFI')

SaveManager:BuildConfigSection(UISettings) 

ThemeManager:ApplyToTab(UISettings)
