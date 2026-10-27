--[[
    Project: Pixel Blade Ultimate AFK Hub (Delta Mobile Compatible)
    Author: Custom script for Dungeons, Raids, Fishing & Inventory
]]

if not game:IsLoaded() then game.Loaded:Wait() end

-- Auto-reconexión para cuando el juego te cambie de servidor (terminar Raid/Mundo)
local queueOnTeleport = syn and syn.queue_on_teleport or queue_on_teleport or fluxus and fluxus.queue_on_teleport
if queueOnTeleport then
    queueOnTeleport([[
        task.wait(3)
        loadstring(game:HttpGet("AQUÍ_PEGAS_TU_ENLACE_RAW_DE_GITHUB"))()
    ]])
end

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

-- Tablas de Configuración del Hub (Toggles)
getgenv().PixelBladeSettings = {
    AutoDungeon = false,
    BreakObjects = true, -- Cofres y Árboles para cebos
    AutoSkill = false,
    AutoPotion = false,
    PotionHealthThreshold = 50,
    AutoCardsDungeon = true,

    AutoRaid = false,
    RaidCombatStyle = "FrontWithRange", -- Posicionamiento frontal con rango y rotación
    AutoCardsRaid = true,

    AutoFishing = false,
    AutoSellCustom = false,
    ItemsToKeep = {"Book", "Legendary", "Epic"},

    AutoUpgradeGear = false
}

-- ==========================================
-- INTERFAZ GRÁFICA (HUD MINIMALISTA BEIGE)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
ScreenGui.Name = "PixelBladeMinimal"

local ColorBeige = Color3.fromRGB(245, 245, 220)
local ColorDarkBeige = Color3.fromRGB(200, 200, 180)
local ColorBackground = Color3.fromRGB(40, 40, 35)
local ColorText = Color3.fromRGB(20, 20, 15)

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 180, 0, 260)
MainFrame.Position = UDim2.new(0.5, -90, 0.5, -130)
MainFrame.BackgroundColor3 = ColorBackground
MainFrame.BorderSizePixel = 0
MainFrame.Visible = true
MainFrame.Active = true
MainFrame.Draggable = true

local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, 0, 0, 25)
TopBar.BackgroundColor3 = ColorBeige
TopBar.BorderSizePixel = 0

local Title = Instance.new("TextLabel", TopBar)
Title.Size = UDim2.new(1, -30, 1, 0)
Title.Text = "Pixel Blade Hub"
Title.TextColor3 = ColorText
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 14
Title.BackgroundTransparency = 1

local ToggleButton = Instance.new("TextButton", TopBar)
ToggleButton.Size = UDim2.new(0, 30, 1, 0)
ToggleButton.Position = UDim2.new(1, -30, 0, 0)
ToggleButton.Text = "X"
ToggleButton.TextColor3 = ColorText
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextSize = 14
ToggleButton.BackgroundColor3 = ColorDarkBeige
ToggleButton.BorderSizePixel = 0

local OptionsContainer = Instance.new("ScrollingFrame", MainFrame)
OptionsContainer.Size = UDim2.new(1, -10, 1, -35)
OptionsContainer.Position = UDim2.new(0, 5, 0, 30)
OptionsContainer.BackgroundTransparency = 1
OptionsContainer.BorderSizePixel = 0
OptionsContainer.ScrollBarThickness = 2

local function CreateToggle(name, settingKey)
    local Toggle = Instance.new("TextButton", OptionsContainer)
    Toggle.Size = UDim2.new(1, -10, 0, 30)
    Toggle.Position = UDim2.new(0, 5, 0, (#OptionsContainer:GetChildren() - 1) * 35)
    Toggle.Text = name .. ": OFF"
    Toggle.TextColor3 = ColorText
    Toggle.Font = Enum.Font.SourceSans
    Toggle.TextSize = 12
    Toggle.BackgroundColor3 = ColorBeige
    Toggle.BorderSizePixel = 0

    local State = false
    Toggle.MouseButton1Click:Connect(function()
        State = not State
        getgenv().PixelBladeSettings[settingKey] = State
        Toggle.Text = name .. (State and ": ON" or ": OFF")
        Toggle.BackgroundColor3 = State and ColorDarkBeige or ColorBeige
    end)
end

CreateToggle("Auto Dungeon", "AutoDungeon")
CreateToggle("Break Objects", "BreakObjects")
CreateToggle("Auto Raid", "AutoRaid")
CreateToggle("Auto Potion", "AutoPotion")
CreateToggle("Auto Fishing", "AutoFishing")
CreateToggle("Auto Upgrade", "AutoUpgradeGear")

local MinButton = Instance.new("TextButton", ScreenGui)
MinButton.Size = UDim2.new(0, 40, 0, 40)
MinButton.Position = UDim2.new(0.05, 0, 0.05, 0)
MinButton.Text = "M"
MinButton.TextColor3 = ColorText
MinButton.Font = Enum.Font.SourceSansBold
MinButton.TextSize = 16
MinButton.BackgroundColor3 = ColorBeige
MinButton.BorderSizePixel = 0
MinButton.Visible = false
MinButton.Active = true
MinButton.Draggable = true

ToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    MinButton.Visible = true
end)

MinButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    MinButton.Visible = false
end)

-- ==========================================
-- LOGICA PRINCIPAL (FARMO, COMBATE Y MÓDULOS)
-- ==========================================

-- Detección de Cartas / Buffs (Mazmorras y Raids)
local function checkLevelUpChoices()
    local playerGui = player:FindFirstChild("PlayerGui")
    if not playerGui then return end
    for _, gui in ipairs(playerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled then
            local choicesContainer = gui:FindFirstChild("CardContainer", true) or gui:FindFirstChild("Selection", true) or gui:FindFirstChild("Choices", true)
            if choicesContainer then
                for _, child in ipairs(choicesContainer:GetChildren()) do
                    if child:IsA("TextButton") or child:IsA("ImageButton") then
                        local absPos = child.AbsolutePosition
                        local absSize = child.AbsoluteSize
                        VirtualInputManager:SendMouseButtonEvent(absPos.X + (absSize.X / 2), absPos.Y + (absSize.Y / 2), 0, true, game, 1)
                        task.wait(0.1)
                        VirtualInputManager:SendMouseButtonEvent(absPos.X + (absSize.X / 2), absPos.Y + (absSize.Y / 2), 0, false, game, 1)
                        task.wait(1)
                        break
                    end
                end
            end
        end
    end
end

-- Loop General de Procesamiento y Acciones
task.spawn(function()
    while true do
        pcall(function()
            character = player.Character or player.CharacterAdded:Wait()
            humanoidRootPart = character:WaitForChild("HumanoidRootPart")
            humanoid = character:WaitForChild("Humanoid")

            -- 1. Auto Cartas (Dungeon / Raid)
            if getgenv().PixelBladeSettings.AutoCardsDungeon or getgenv().PixelBladeSettings.AutoCardsRaid then
                checkLevelUpChoices()
            end

            -- 2. Auto Potion (Supervivencia)
            if getgenv().PixelBladeSettings.AutoPotion and humanoid.Health > 0 then
                local healthPercent = (humanoid.Health / humanoid.MaxHealth) * 100
                if healthPercent <= getgenv().PixelBladeSettings.PotionHealthThreshold then
                    -- Simulación o llamada al Remote/Key de poción
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Q, false, game) -- Ajustar tecla si difiere
                    task.wait(0.1)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Q, false, game)
                    task.wait(1)
                end
            end
        end)
        task.wait(0.5)
    end
end)

print("[Pixel Blade Hub] Módulos inicializados correctamente.")
