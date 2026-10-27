--[[
    Pixel Blade Hub - Max Opt (Sin Radar UI + Auto-Caza Silenciosa + AFK Infinito)
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TeleportService = game:GetService("TeleportService")
local player = Players.LocalPlayer

if CoreGui:FindFirstChild("PixelBladeSmartHub") then
    CoreGui.PixelBladeSmartHub:Destroy()
end

if not getgenv().PixelBladeState then
    getgenv().PixelBladeState = {
        AutoFarm = false,
        AutoCards = true,
        AutoUlti = false,
        AutoContinue = true,
        BreakObjects = true,
        AutoNextZone = false,
        AutoButtons = false,
        AutoTree = false
    }
end

pcall(function()
    if queue_on_teleport then
        queue_on_teleport([[
            task.wait(3)
            loadstring(game:HttpGet("https://raw.githubusercontent.com/Kornxx/PixelBladeHub/refs/heads/main/script.lua?t=" .. tostring(tick())))()
        ]])
    end
end)

local targetMobs = {
    "zombie", "archer", "mortar", "ghoul", "lumberjack", 
    "cannon_goblin", "mage", "giant", "undead", "skeleton",
    "kingslayer", "goblintype1", "goblintype2", "bolt"
}
local chestNames = {"chest", "crate"}
local ignoreMobs = {
    "necromancer", "tutorial_clyde", "ally", "summon", "pet", "familiar", 
    "black_chest", "locked", "key_chest", "boss_chest", "key", "black"
}

-- INTERFAZ GRÁFICA (HUD) COMPACTA Y LIGERA
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PixelBladeSmartHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 240, 0, 310) -- Interfaz más pequeña
MainFrame.Position = UDim2.new(0.5, -120, 0.5, -155)
MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 32)
MainFrame.BorderSizePixel = 0
MainFrame.Active = false
MainFrame.Draggable = false
MainFrame.Parent = ScreenGui

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 30)
TopBar.BackgroundColor3 = Color3.fromRGB(245, 235, 210)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -60, 1, 0)
Title.Position = UDim2.new(0, 5, 0, 0)
Title.Text = "Blade Hub [Ultra Ligero]"
Title.TextColor3 = Color3.fromRGB(20, 20, 15)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 14
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 25, 0, 20)
MinimizeBtn.Position = UDim2.new(1, -55, 0, 5)
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Color3.fromRGB(20, 20, 15)
MinimizeBtn.Font = Enum.Font.SourceSansBold
MinimizeBtn.TextSize = 14
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(200, 190, 170)
MinimizeBtn.BorderSizePixel = 0
MinimizeBtn.Parent = TopBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 25, 0, 20)
CloseBtn.Position = UDim2.new(1, -28, 0, 5)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 12
CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = TopBar

local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, 0, 0, 25)
TabBar.Position = UDim2.new(0, 0, 0, 30)
TabBar.BackgroundColor3 = Color3.fromRGB(50, 50, 45)
TabBar.BorderSizePixel = 0
TabBar.Parent = MainFrame

local TabDungeonBtn = Instance.new("TextButton")
TabDungeonBtn.Size = UDim2.new(0.5, 0, 1, 0)
TabDungeonBtn.Text = "DUNGEON"
TabDungeonBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TabDungeonBtn.Font = Enum.Font.SourceSansBold
TabDungeonBtn.TextSize = 12
TabDungeonBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 65)
TabDungeonBtn.BorderSizePixel = 0
TabDungeonBtn.Parent = TabBar

local TabRaidBtn = Instance.new("TextButton")
TabRaidBtn.Size = UDim2.new(0.5, 0, 1, 0)
TabRaidBtn.Position = UDim2.new(0.5, 0, 0, 0)
TabRaidBtn.Text = "RAIDS"
TabRaidBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
TabRaidBtn.Font = Enum.Font.SourceSansBold
TabRaidBtn.TextSize = 12
TabRaidBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 35)
TabRaidBtn.BorderSizePixel = 0
TabRaidBtn.Parent = TabBar

local DungeonTab = Instance.new("Frame")
DungeonTab.Size = UDim2.new(1, 0, 1, -85)
DungeonTab.Position = UDim2.new(0, 0, 0, 55)
DungeonTab.BackgroundTransparency = 1
DungeonTab.Visible = true
DungeonTab.Parent = MainFrame

local RaidTab = Instance.new("Frame")
RaidTab.Size = UDim2.new(1, 0, 1, -85)
RaidTab.Position = UDim2.new(0, 0, 0, 55)
RaidTab.BackgroundTransparency = 1
RaidTab.Visible = false
RaidTab.Parent = MainFrame

local function createButton(parent, text, yPos, stateKey, colorOn, colorOff)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 26)
    btn.Position = UDim2.new(0, 10, 0, yPos)
    btn.Text = text .. ": " .. (getgenv().PixelBladeState[stateKey] and "ON" or "OFF")
    btn.TextColor3 = Color3.fromRGB(20, 20, 15)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 12
    btn.BackgroundColor3 = getgenv().PixelBladeState[stateKey] and colorOn or colorOff
    btn.BorderSizePixel = 0
    btn.Parent = parent
    
    btn.MouseButton1Click:Connect(function()
        getgenv().PixelBladeState[stateKey] = not getgenv().PixelBladeState[stateKey]
        btn.Text = text .. ": " .. (getgenv().PixelBladeState[stateKey] and "ON" or "OFF")
        btn.BackgroundColor3 = getgenv().PixelBladeState[stateKey] and colorOn or colorOff
    end)
    return btn
end

local colorOn = Color3.fromRGB(180, 220, 180)
local colorOff = Color3.fromRGB(245, 245, 220)
local raidColorOn = Color3.fromRGB(200, 180, 220) 

-- Posiciones ajustadas hacia arriba al eliminar los radares
local D_Farm = createButton(DungeonTab, "Auto-Farm Mobs", 15, "AutoFarm", colorOn, colorOff)
local D_Cards = createButton(DungeonTab, "Auto-Cartas (Llama/Furia)", 45, "AutoCards", colorOn, colorOff)
local D_Ulti = createButton(DungeonTab, "Auto-Habilidades (Ulti)", 75, "AutoUlti", colorOn, colorOff)
local D_Chests = createButton(DungeonTab, "Romper Cofres", 105, "BreakObjects", colorOn, colorOff)
local D_Zone = createButton(DungeonTab, "Auto-Avanzar (Portales)", 135, "AutoNextZone", colorOn, colorOff)
local D_Boss = createButton(DungeonTab, "Auto-Botones (Jefes)", 165, "AutoButtons", colorOn, colorOff)
local D_Continue = createButton(DungeonTab, "Auto-Seguir (Continuar)", 195, "AutoContinue", colorOn, colorOff)

local R_Farm = createButton(RaidTab, "Auto-Farm Raids", 15, "AutoFarm", raidColorOn, colorOff)
local R_Cards = createButton(RaidTab, "Auto-Cartas (Llama/Furia)", 45, "AutoCards", raidColorOn, colorOff)
local R_Ulti = createButton(RaidTab, "Auto-Habilidades (Ulti)", 75, "AutoUlti", raidColorOn, colorOff)
local R_Tree = createButton(RaidTab, "Auto-Árbol (Sig. Oleada)", 105, "AutoTree", raidColorOn, colorOff)
local R_Continue = createButton(RaidTab, "Auto-Seguir (Continuar)", 135, "AutoContinue", raidColorOn, colorOff)

local function syncButtons()
    D_Farm.Text = "Auto-Farm Mobs: " .. (getgenv().PixelBladeState.AutoFarm and "ON" or "OFF")
    D_Farm.BackgroundColor3 = getgenv().PixelBladeState.AutoFarm and colorOn or colorOff
    R_Farm.Text = "Auto-Farm Raids: " .. (getgenv().PixelBladeState.AutoFarm and "ON" or "OFF")
    R_Farm.BackgroundColor3 = getgenv().PixelBladeState.AutoFarm and raidColorOn or colorOff

    D_Cards.Text = "Auto-Cartas (Llama/Furia): " .. (getgenv().PixelBladeState.Auto
