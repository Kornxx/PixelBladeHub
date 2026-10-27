--[[
    Project: Pixel Blade Ultimate AFK Hub - Modular Version
    Compatible with Delta Mobile
]]

if not game:IsLoaded() then game.Loaded:Wait() end

-- Auto-reconexión para cuando el juego cambie de servidor
local queueOnTeleport = syn and syn.queue_on_teleport or queue_on_teleport or fluxus and fluxus.queue_on_teleport
if queueOnTeleport then
    queueOnTeleport([[
        task.wait(3)
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Kornxx/PixelBladeHub/refs/heads/main/script.lua"))()
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

-- Configuración general de opciones
getgenv().PixelBladeSettings = {
    -- Dungeon
    AutoDungeon = false,
    BreakObjects = false,
    AutoCardsDungeon = true,
    
    -- Raid
    AutoRaid = false,
    AutoCardsRaid = true,

    -- Fishing & Sell
    AutoFishing = false,
    AutoSellCustom = false,

    -- Combat & Survival
    AutoSkill = false,
    AutoPotion = false,
    PotionHealthThreshold = 50,
    AutoUpgradeGear = false
}

-- ==========================================
-- INTERFAZ GRÁFICA CON PESTAÑAS (BEIGE MINIMALISTA)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
ScreenGui.Name = "PixelBladeModular"

local ColorBeige = Color3.fromRGB(245, 245, 220)
local ColorDarkBeige = Color3.fromRGB(200, 200, 180)
local ColorBackground = Color3.fromRGB(40, 40, 35)
local ColorText = Color3.fromRGB(20, 20, 15)

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 220, 0, 280)
MainFrame.Position = UDim2.new(0.5, -110, 0.5, -140)
MainFrame.BackgroundColor3 = ColorBackground
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true

-- Barra Superior
local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, 0, 0, 25)
TopBar.BackgroundColor3 = ColorBeige
TopBar.BorderSizePixel = 0

local Title = Instance.new("TextLabel", TopBar)
Title.Size = UDim2.new(1, -30, 1, 0)
Title.Text = "Pixel Blade Hub"
Title.TextColor3 = ColorText
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 13
Title.BackgroundTransparency = 1

local MinimizeButton = Instance.new("TextButton", TopBar)
MinimizeButton.Size = UDim2.new(0, 30, 1, 0)
MinimizeButton.Position = UDim2.new(1, -30, 0, 0)
MinimizeButton.Text = "X"
MinimizeButton.TextColor3 = ColorText
MinimizeButton.Font = Enum.Font.SourceSansBold
MinimizeButton.TextSize = 13
MinimizeButton.BackgroundColor3 = ColorDarkBeige
MinimizeButton.BorderSizePixel = 0

-- Botones de Pestañas (Tabs)
local TabBar = Instance.new("Frame", MainFrame)
TabBar.Size = UDim2.new(1, 0, 0, 25)
TabBar.Position = UDim2.new(0, 0, 0, 25)
TabBar.BackgroundColor3 = ColorDarkBeige
TabBar.BorderSizePixel = 0

local function CreateTabButton(name, positionX, width)
    local btn = Instance.new("TextButton", TabBar)
    btn.Size = UDim2.new(0, width, 1, 0)
    btn.Position = UDim2.new(0, positionX, 0, 0)
    btn.Text = name
    btn.TextColor3 = ColorText
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 11
    btn.BackgroundColor3 = ColorBeige
    btn.BorderSizePixel = 0
    return btn
end

local tabDungeonBtn = CreateTabButton("Dungeon", 0, 55)
local tabRaidBtn = CreateTabButton("Raid", 55, 50)
local tabFishingBtn = CreateTabButton("Fishing", 105, 55)
local tabExtraBtn = CreateTabButton("Extra", 160, 60)

-- Contenedores de cada Pestaña
local function CreateContainer()
    local sc = Instance.new("ScrollingFrame", MainFrame)
    sc.Size = UDim2.new(1, -10, 1, -60)
    sc.Position = UDim2.new(0, 5, 0, 55)
    sc.BackgroundTransparency = 1
    sc.BorderSizePixel = 0
    sc.ScrollBarThickness = 2
    sc.Visible = false
    return sc
end

local ContainerDungeon = CreateContainer()
local ContainerRaid = CreateContainer()
local ContainerFishing = CreateContainer()
local ContainerExtra = CreateContainer()

ContainerDungeon.Visible = true -- Mostrar dungeon por defecto

local function SwitchTab(activeContainer)
    ContainerDungeon.Visible = false
    ContainerRaid.Visible = false
    ContainerFishing.Visible = false
    ContainerExtra.Visible = false
    activeContainer.Visible = true
end

tabDungeonBtn.MouseButton1Click:Connect(function() SwitchTab(ContainerDungeon) end)
tabRaidBtn.MouseButton1Click:Connect(function() SwitchTab(ContainerRaid) end)
tabFishingBtn.MouseButton1Click:Connect(function() SwitchTab(ContainerFishing) end)
tabExtraBtn.MouseButton1Click:Connect(function() SwitchTab(ContainerExtra) end)

-- Función para agregar Toggles a cada Pestaña
local function CreateToggleInContainer(container, name, settingKey)
    local childrenCount = #container:GetChildren()
    local Toggle = Instance.new("TextButton", container)
    Toggle.Size = UDim2.new(1, -10, 0, 28)
    Toggle.Position = UDim2.new(0, 5, 0, childrenCount * 32)
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

-- Rellenar Pestañas con opciones
CreateToggleInContainer(ContainerDungeon, "Auto Dungeon Farm", "AutoDungeon")
CreateToggleInContainer(ContainerDungeon, "Break Objects/Chests", "BreakObjects")
CreateToggleInContainer(ContainerDungeon, "Auto Select Cards", "AutoCardsDungeon")

CreateToggleInContainer(ContainerRaid, "Auto Raid Farm", "AutoRaid")
CreateToggleInContainer(ContainerRaid, "Auto Select Raid Cards", "AutoCardsRaid")

CreateToggleInContainer(ContainerFishing, "Auto Fishing (Timing)", "AutoFishing")
CreateToggleInContainer(ContainerFishing, "Auto Sell Junk", "AutoSellCustom")

CreateToggleInContainer(ContainerExtra, "Auto Use Potion", "AutoPotion")
CreateToggleInContainer(ContainerExtra, "Auto Use Skill", "AutoSkill")
CreateToggleInContainer(ContainerExtra, "Auto Upgrade Gear", "AutoUpgradeGear")

-- Botón Flotante de Minimizar
local MinButton = Instance.new("TextButton", ScreenGui)
MinButton.Size = UDim2.new(0, 35, 0, 35)
MinButton.Position = UDim2.new(0.05, 0, 0.05, 0)
MinButton.Text = "M"
MinButton.TextColor3 = ColorText
MinButton.Font = Enum.Font.SourceSansBold
MinButton.TextSize = 14
MinButton.BackgroundColor3 = ColorBeige
MinButton.BorderSizePixel = 0
MinButton.Visible = false
MinButton.Active = true
MinButton.Draggable = true

MinimizeButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    MinButton.Visible = true
end)

MinButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    MinButton.Visible = false
end)

-- ==========================================
-- MOTORES LÓGICOS (LOOPS DE ACCIÓN EN JUEGO)
-- ==========================================

-- 1. Buscador genérico de enemigos en el Workspace
local function getNearestEnemy()
    local enemiesFolder = Workspace:FindFirstChild("Enemies") or Workspace:FindFirstChild("Mobs") or Workspace:FindFirstChild("Monsters")
    if not enemiesFolder then
        for _, v in ipairs(Workspace:GetChildren()) do
            if v:IsA("Folder") and (v.Name:lower():find("enemy") or v.Name:lower():find("mob") or v.Name:lower():find("monster")) then
                enemiesFolder = v
                break
            end
        end
    end
    if not enemiesFolder then return nil end

    local nearest = nil
    local shortestDistance = math.huge
    for _, enemy in ipairs(enemiesFolder:GetChildren()) do
        local enemyRoot = enemy:FindFirstChild("HumanoidRootPart") or enemy:FindFirstChild("Head") or enemy:PrimaryPart
        local enemyHumanoid = enemy:FindFirstChildOfClass("Humanoid")
        if enemyRoot and enemyHumanoid and enemyHumanoid.Health > 0 then
            local dist = (humanoidRootPart.Position - enemyRoot.Position).Magnitude
            if dist < shortestDistance then
                shortestDistance = dist
                nearest = enemyRoot
            end
        end
    end
    return nearest
end

-- 2. Selector automático de cartas / buffs (Pantalla de nivel)
local function checkLevelUpChoices()
    local playerGui = player:FindFirstChild("PlayerGui")
    if not playerGui then return end
    for _, gui in ipairs(playerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled then
            local choicesContainer = gui:FindFirstChild("CardContainer", true) or gui:FindFirstChild("Selection", true) or gui:FindFirstChild("Choices", true) or gui:FindFirstChild("Cards", true)
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

-- Loop principal para Dungeons, Raids y Combate
task.spawn(function()
    while true do
        pcall(function()
            character = player.Character or player.CharacterAdded:Wait()
            humanoidRootPart = character:WaitForChild("HumanoidRootPart")
            humanoid = character:WaitForChild("Humanoid")

            -- Cartas en Dungeon
            if getgenv().PixelBladeSettings.AutoCardsDungeon then
                checkLevelUpChoices()
            end

            -- Cartas en Raid
            if getgenv().PixelBladeSettings.AutoCardsRaid then
                checkLevelUpChoices()
            end

            -- Auto Potion
            if getgenv().PixelBladeSettings.AutoPotion and humanoid.Health > 0 then
                if (humanoid.Health / humanoid.MaxHealth) * 100 <= getgenv().PixelBladeSettings.PotionHealthThreshold then
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Q, false, game)
                    task.wait(0.1)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Q, false, game)
                    task.wait(1)
                end
            end

            -- Lógica de Auto Dungeon Farm
            if getgenv().PixelBladeSettings.AutoDungeon then
                local target = getNearestEnemy()
                if target then
                    humanoidRootPart.CFrame = target.CFrame * CFrame.new(0, 0, 3)
                    -- Simular ataque básico (Click izquierdo)
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                    task.wait(0.1)
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                end
            end

            -- Lógica de Auto Raid Farm (Combate sostenido flotando frente al mob)
            if getgenv().PixelBladeSettings.AutoRaid then
                local target = getNearestEnemy()
                if target then
                    -- Posicionarse frente al enemigo rotando la vista hacia él para asegurar el golpe
                    humanoidRootPart.CFrame = CFrame.new(target.Position + Vector3.new(0, 3, 3), target.Position)
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                    task.wait(0.1)
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                end
            end
        end)
        task.wait(0.2)
    end
end)

print("[Pixel Blade Hub] Módulos separados y motores de ejecución activos.")
