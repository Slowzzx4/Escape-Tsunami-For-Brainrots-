if game.PlaceId ~= 131623223084840 then return end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer

pcall(function()
    if CoreGui:FindFirstChild("RobloxNetworkPauseNotification") then
        CoreGui.RobloxNetworkPauseNotification:Destroy()
    end
end)

task.spawn(function()
    while true do
        task.wait()
        pcall(function()
            player.GameplayPaused = false
        end)
    end
end)

player.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

local hrp
local mySpawn = nil

local function setupChar(char)
    hrp = char:WaitForChild("HumanoidRootPart", 10)
end

local function detectMySpawn()
    if not hrp then return end
    local bases = workspace:WaitForChild("Bases", 10)
    if not bases then return end
    
    local shortest = math.huge
    mySpawn = nil
    
    for _, base in bases:GetChildren() do
        local sp = base:FindFirstChild("Spawn")
        if sp and sp:IsA("BasePart") then
            local dist = (hrp.Position - sp.Position).Magnitude
            if dist < shortest then
                shortest = dist
                mySpawn = sp
            end
        end
    end
end

if player.Character then
    setupChar(player.Character)
    task.wait(1.2)
    detectMySpawn()
end

player.CharacterAdded:Connect(function(char)
    task.wait(1.2)
    setupChar(char)
    task.wait(1.2)
    detectMySpawn()
end)

local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua", true))()
local Window = WindUI:CreateWindow({
    Title = "Nexus Hub",
    Icon = "crown",
    Author = "By Slowzzx4",
    Folder = "TsunamiBrainrots",
    Size = UDim2.fromOffset(560, 430),
    Theme = "Crimson",
    Transparent = true,
    Resizable = true,
    User = { Enabled = true }
})

local FarmTab = Window:Tab({ Title = "Farm", Icon = "zap" })
local SellTab = Window:Tab({ Title = "Sell", Icon = "dollar-sign" })
local UpgradeTab = Window:Tab({ Title = "Upgrade", Icon = "trending-up" })
local ESPTab = Window:Tab({ Title = "ESP", Icon = "eye" })
local ThemeTab = Window:Tab({ Title = "Theme", Icon = "palette" })

local BASE_POS = Vector3.new(130, 3, 0)
local SECRET_POS = Vector3.new(2440, 3, -4)
local CELESTIAL_POS = Vector3.new(2803, 3, -1)

local secretBrainrots = {
    "Fragola La La La", "Statutino Libertino", "Gattatino Neonino",
    "Aura Farma", "Los Combinasionas", "Los Tungtungtungcitos",
    "Espresso Signora", "Matteo", "Unclito Samito", "Rainbow 67"
}

local celestialBrainrots = {
    "Alessio", "Esok Sekolah", "Dug Dug Dug",
    "Job Job Job Sahur", "Bisonte Giuppitere"
}

local SelectedSecret = secretBrainrots[1]
local SelectedCelestial = {celestialBrainrots[1]}
local findSecretOn = false
local findCelestialOn = false
local secretInitialized = false
local celestialInitialized = false

FarmTab:Button({
    Title = "Goto Base",
    Callback = function()
        if hrp and mySpawn then
            hrp.CFrame = mySpawn.CFrame + Vector3.new(0, 5, 0)
        end
    end
})

FarmTab:Dropdown({
    Title = "Select Celestial",
    Values = celestialBrainrots,
    Multi = true,
    Default = SelectedCelestial,
    Callback = function(v)
        SelectedCelestial = v
    end
})

FarmTab:Toggle({
    Title = "Find Celestial",
    Default = false,
    Callback = function(v)
        findCelestialOn = v
        celestialInitialized = false
    end
})

FarmTab:Dropdown({
    Title = "Select Brainrot",
    Values = secretBrainrots,
    Default = SelectedSecret,
    Callback = function(v)
        SelectedSecret = v
    end
})

FarmTab:Toggle({
    Title = "Find Secret",
    Default = false,
    Callback = function(v)
        findSecretOn = v
        secretInitialized = false
    end
})

local autoCollect = false
local collectDelay = 1

SellTab:Toggle({
    Title = "Auto Collect Money",
    Default = false,
    Callback = function(v) autoCollect = v end
})

SellTab:Slider({
    Title = "Collect Delay",
    Value = {Min = 1, Max = 100, Default = 1},
    Step = 1,
    IsTextbox = true,
    Callback = function(v) collectDelay = v end
})

SellTab:Button({
    Title = "Sell All",
    Callback = function()
        pcall(function()
            ReplicatedStorage.RemoteFunctions.SellAll:InvokeServer()
        end)
    end
})

local function fireAllSlots()
    if not hrp then return end
    for _, base in ipairs(workspace:GetDescendants()) do
        if base.Name:match("Base") and base:FindFirstChild("Slots") then
            for _, slot in ipairs(base.Slots:GetChildren()) do
                if slot:FindFirstChild("Collect") then
                    pcall(function()
                        firetouchinterest(hrp, slot.Collect, 0)
                        firetouchinterest(hrp, slot.Collect, 1)
                    end)
                end
            end
        end
    end
end

task.spawn(function()
    while true do
        task.wait(0.2)
        if autoCollect then
            fireAllSlots()
            task.wait(collectDelay)
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.35)
        if not findCelestialOn or not hrp or #SelectedCelestial == 0 then
            task.wait(0.8)
            continue
        end

        if not celestialInitialized then
            pcall(function()
                if player.Character:FindFirstChild("Humanoid") then
                    player.Character.Humanoid:UnequipTools()
                end
            end)
            hrp.CFrame = CFrame.new(CELESTIAL_POS + Vector3.new(0, 5, 0))
            task.wait(1)
            celestialInitialized = true
        end

        local folder = workspace.ActiveBrainrots and workspace.ActiveBrainrots:FindFirstChild("Celestial")
        if folder then
            local collected = false
            for _, name in ipairs(SelectedCelestial) do
                local br = folder:FindFirstChild(name)
                if br and br:FindFirstChild("Handle") then
                    hrp.CFrame = br.Handle.CFrame + Vector3.new(0, 5, 0)
                    task.wait(1)

                    for _, p in br:GetDescendants() do
                        if p:IsA("ProximityPrompt") then
                            pcall(function() fireproximityprompt(p) end)
                        end
                    end

                    collected = true
                    break
                end
            end

            if collected then
                if mySpawn then
                    hrp.CFrame = mySpawn.CFrame + Vector3.new(0, 5, 0)
                    task.wait(2.5)
                end
                hrp.CFrame = CFrame.new(CELESTIAL_POS + Vector3.new(0, 5, 0))
                task.wait(0.5)
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.35)
        if not findSecretOn or not hrp then
            task.wait(0.8)
            continue
        end

        if not secretInitialized then
            pcall(function()
                if player.Character:FindFirstChild("Humanoid") then
                    player.Character.Humanoid:UnequipTools()
                end
            end)
            hrp.CFrame = CFrame.new(SECRET_POS + Vector3.new(0, 5, 0))
            task.wait(1)
            secretInitialized = true
        end

        local folder = workspace.ActiveBrainrots and workspace.ActiveBrainrots:FindFirstChild("Secret")
        if folder then
            local br = folder:FindFirstChild(SelectedSecret)
            if br and br:FindFirstChild("Handle") then
                hrp.CFrame = br.Handle.CFrame + Vector3.new(0, 5, 0)
                task.wait(1)

                for _, p in br:GetDescendants() do
                    if p:IsA("ProximityPrompt") then
                        pcall(function() fireproximityprompt(p) end)
                    end
                end

                if mySpawn then
                    hrp.CFrame = mySpawn.CFrame + Vector3.new(0, 5, 0)
                    task.wait(2.5)
                end
                hrp.CFrame = CFrame.new(SECRET_POS + Vector3.new(0, 5, 0))
                task.wait(0.5)
            end
        end
    end
end)

FarmTab:Toggle({
    Title = "Remove Tsunami",
    Default = false,
    Callback = function(v)
        if v then
            pcall(function()
                if workspace:FindFirstChild("ActiveTsunamis") then workspace.ActiveTsunamis:Destroy() end
                if workspace:FindFirstChild("Lava") then workspace.Lava:Destroy() end
                if workspace:FindFirstChild("Limited") then workspace.Limited:Destroy() end
            end)
        end
    end
})

local autoRebirth = false
local autoSpeed = false
local autoCarry = false
local autoBrainrot = false

UpgradeTab:Toggle({ Title = "Auto Upgrade Rebirth", Callback = function(v) autoRebirth = v end })
UpgradeTab:Toggle({ Title = "Auto Upgrade Speed", Callback = function(v) autoSpeed = v end })
UpgradeTab:Toggle({ Title = "Auto Upgrade Carry", Callback = function(v) autoCarry = v end })
UpgradeTab:Toggle({ Title = "Auto Upgrade Brainrot", Callback = function(v) autoBrainrot = v end })

local UpgradeBrainrot = ReplicatedStorage:WaitForChild("RemoteFunctions"):WaitForChild("UpgradeBrainrot")

task.spawn(function()
    while true do
        task.wait(0.1)
        
        if autoSpeed then 
            pcall(function() ReplicatedStorage.RemoteFunctions.UpgradeSpeed:InvokeServer(10) end) 
        end
        
        if autoCarry then 
            pcall(function() ReplicatedStorage.RemoteFunctions.UpgradeCarry:InvokeServer() end) 
        end
        
        if autoRebirth then 
            pcall(function() ReplicatedStorage.RemoteFunctions.Rebirth:InvokeServer() end) 
        end
        
        if autoBrainrot then
            for i = 1, 50 do
                pcall(function()
                    UpgradeBrainrot:InvokeServer("Slot" .. i)
                end)
            end
        end
    end
end)

task.spawn(function()
    local Floors = workspace:WaitForChild("Floors")
    local BLACK = Color3.fromRGB(0,0,0)

    while true do
        for _, v in ipairs(Floors:GetDescendants()) do
            if v:IsA("BasePart") then
                v.Color = BLACK
                v.Material = Enum.Material.SmoothPlastic
                v.Transparency = 0
                v.Reflectance = 0
            end
            if v:IsA("MeshPart") then v.TextureID = "" end
            if v:IsA("SurfaceAppearance") or v:IsA("Decal") or v:IsA("Texture") then v:Destroy() end
        end
        task.wait(0.3)
    end
end)

local espOn = false
local Targets = {
    ["Fragola La La La"] = true,
    ["Rainbow 67"] = true,
    ["Aura Farma"] = true,
    ["Alessio"] = true,
    ["Esok Sekolah"] = true
}

local Highlights = {}

local function createChams(brainrot)
    if brainrot:FindFirstChild("RainbowChams") then return end
    local highlight = Instance.new("Highlight")
    highlight.Name = "RainbowChams"
    highlight.Adornee = brainrot
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillTransparency = 0.2
    highlight.OutlineTransparency = 0
    highlight.Parent = brainrot
    table.insert(Highlights, highlight)
end

ESPTab:Toggle({
    Title = "ESP Best Brainrots",
    Default = false,
    Callback = function(v)
        espOn = v
    end
})

task.spawn(function()
    local SecretFolder = workspace:WaitForChild("ActiveBrainrots"):WaitForChild("Secret")
    local CelestialFolder = workspace:WaitForChild("ActiveBrainrots"):WaitForChild("Celestial")

    for _, folder in {SecretFolder, CelestialFolder} do
        for _, obj in ipairs(folder:GetChildren()) do
            if Targets[obj.Name] then createChams(obj) end
        end
    end

    SecretFolder.ChildAdded:Connect(function(obj)
        if Targets[obj.Name] then task.wait(0.1) createChams(obj) end
    end)

    CelestialFolder.ChildAdded:Connect(function(obj)
        if Targets[obj.Name] then task.wait(0.1) createChams(obj) end
    end)

    local hue = 0
    RunService.RenderStepped:Connect(function()
        if not espOn then
            for i = #Highlights, 1, -1 do
                if Highlights[i] then Highlights[i]:Destroy() end
                table.remove(Highlights, i)
            end
            return
        end

        hue += 0.004
        if hue > 1 then hue = 0 end
        local color = Color3.fromHSV(hue, 1, 1)

        for i = #Highlights, 1, -1 do
            local h = Highlights[i]
            if not h or not h.Parent then
                table.remove(Highlights, i)
            else
                h.FillColor = color
                h.OutlineColor = color
            end
        end
    end)
end)

ThemeTab:Dropdown({
    Title = "Select Theme",
    Values = {"Dark","Light","Rose","Plant","Red","Indigo","Sky","Violet","Amber","Emerald","Midnight","Crimson","MonokaiPro","CottonCandy"},
    Default = "Crimson",
    Callback = function(t)
        WindUI:SetTheme(t)
    end
})

Window:SelectTab(1)
Window:SetVisible(true)
