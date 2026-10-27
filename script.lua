--[[
    Shiro Hub [v1.2] - Máxima Optimización Móvil + Sin Radar + Spawn Definitivo
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local VirtualInputManager = game:GetService("VirtualInputManager")
local player = Players.LocalPlayer

if CoreGui:FindFirstChild("ShiroSmartHub") then
    CoreGui.ShiroSmartHub:Destroy()
end

-- ESTADOS PERSISTENTES
if not getgenv().ShiroHubState then
    getgenv().ShiroHubState = {
        AutoFarm = true,  
        AutoCards = true,
        AutoUlti = true,
        AutoContinue = true,
        BreakObjects = false,
        AutoNextZone = false,
        AutoButtons = false,
        AutoTree = true
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

-- ==========================================
-- INTERFAZ GRÁFICA (HUD) SHIRO HUB v1.2
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ShiroSmartHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, 310) -- Interfaz compacta al quitar el radar
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -155)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner_Main = Instance.new("UICorner")
UICorner_Main.CornerRadius = UDim.new(0, 8)
UICorner_Main.Parent = MainFrame

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 35)
TopBar.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local UICorner_Top = Instance.new("UICorner")
UICorner_Top.CornerRadius = UDim.new(0, 8)
UICorner_Top.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -70, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.Text = "Shiro Hub [v1.2]"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 25, 0, 25)
MinimizeBtn.Position = UDim2.new(1, -60, 0, 5)
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 16
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
MinimizeBtn.Parent = TopBar
Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0, 6)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.Position = UDim2.new(1, -30, 0, 5)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 12
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Parent = TopBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, -20, 0, 30)
TabBar.Position = UDim2.new(0, 10, 0, 45)
TabBar.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
TabBar.Parent = MainFrame
Instance.new("UICorner", TabBar).CornerRadius = UDim.new(0, 6)

local TabDungeonBtn = Instance.new("TextButton")
TabDungeonBtn.Size = UDim2.new(0.5, 0, 1, 0)
TabDungeonBtn.Text = "DUNGEON"
TabDungeonBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TabDungeonBtn.Font = Enum.Font.GothamBold
TabDungeonBtn.TextSize = 11
TabDungeonBtn.BackgroundColor3 = Color3.fromRGB(70, 110, 190)
TabDungeonBtn.Parent = TabBar
Instance.new("UICorner", TabDungeonBtn).CornerRadius = UDim.new(0, 6)

local TabRaidBtn = Instance.new("TextButton")
TabRaidBtn.Size = UDim2.new(0.5, 0, 1, 0)
TabRaidBtn.Position = UDim2.new(0.5, 0, 0, 0)
TabRaidBtn.Text = "RAIDS"
TabRaidBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
TabRaidBtn.Font = Enum.Font.GothamBold
TabRaidBtn.TextSize = 11
TabRaidBtn.BackgroundTransparency = 1
TabRaidBtn.Parent = TabBar

local DungeonTab = Instance.new("Frame")
DungeonTab.Size = UDim2.new(1, 0, 1, -85)
DungeonTab.Position = UDim2.new(0, 0, 0, 85)
DungeonTab.BackgroundTransparency = 1
DungeonTab.Parent = MainFrame

local RaidTab = Instance.new("Frame")
RaidTab.Size = UDim2.new(1, 0, 1, -85)
RaidTab.Position = UDim2.new(0, 0, 0, 85)
RaidTab.BackgroundTransparency = 1
RaidTab.Visible = false
RaidTab.Parent = MainFrame

local colorOn = Color3.fromRGB(70, 170, 110)
local colorOff = Color3.fromRGB(40, 40, 45)
local raidColorOn = Color3.fromRGB(150, 90, 190) 

local function createButton(parent, text, yPos, stateKey, activeColor)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 28)
    btn.Position = UDim2.new(0, 10, 0, yPos)
    btn.Text = text .. ": " .. (getgenv().ShiroHubState[stateKey] and "ON" or "OFF")
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 11
    btn.BackgroundColor3 = getgenv().ShiroHubState[stateKey] and activeColor or colorOff
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    btn.MouseButton1Click:Connect(function()
        getgenv().ShiroHubState[stateKey] = not getgenv().ShiroHubState[stateKey]
        btn.Text = text .. ": " .. (getgenv().ShiroHubState[stateKey] and "ON" or "OFF")
        btn.BackgroundColor3 = getgenv().ShiroHubState[stateKey] and activeColor or colorOff
    end)
    return btn
end

-- ======================= ELEMENTOS DUNGEON =======================
local D_Farm = createButton(DungeonTab, "Auto-Farm Mobs", 0, "AutoFarm", colorOn)
local D_Cards = createButton(DungeonTab, "Auto-Cartas", 35, "AutoCards", colorOn)
local D_Ulti = createButton(DungeonTab, "Auto-Habilidades (No Dash)", 70, "AutoUlti", colorOn)
local D_Chests = createButton(DungeonTab, "Romper Cofres", 105, "BreakObjects", colorOn)
local D_Zone = createButton(DungeonTab, "Auto-Avanzar Portales", 140, "AutoNextZone", colorOn)
local D_Boss = createButton(DungeonTab, "Auto-Botones Jefes", 175, "AutoButtons", colorOn)
local D_Continue = createButton(DungeonTab, "Auto-Seguir Partida", 210, "AutoContinue", colorOn)

-- ======================= ELEMENTOS RAID (SIN RADAR) =======================
local R_Farm = createButton(RaidTab, "Auto-Farm Raids", 0, "AutoFarm", raidColorOn)
local R_Cards = createButton(RaidTab, "Auto-Cartas", 35, "AutoCards", raidColorOn)
local R_Ulti = createButton(RaidTab, "Auto-Habilidades (No Dash)", 70, "AutoUlti", raidColorOn)
local R_Tree = createButton(RaidTab, "Proteger Spawn (Raid)", 105, "AutoTree", raidColorOn)
local R_Continue = createButton(RaidTab, "Auto-Seguir Partida", 140, "AutoContinue", raidColorOn)

local function syncButtons()
    D_Farm.Text = "Auto-Farm Mobs: " .. (getgenv().ShiroHubState.AutoFarm and "ON" or "OFF")
    D_Farm.BackgroundColor3 = getgenv().ShiroHubState.AutoFarm and colorOn or colorOff
    R_Farm.Text = "Auto-Farm Raids: " .. (getgenv().ShiroHubState.AutoFarm and "ON" or "OFF")
    R_Farm.BackgroundColor3 = getgenv().ShiroHubState.AutoFarm and raidColorOn or colorOff

    D_Cards.Text = "Auto-Cartas: " .. (getgenv().ShiroHubState.AutoCards and "ON" or "OFF")
    D_Cards.BackgroundColor3 = getgenv().ShiroHubState.AutoCards and colorOn or colorOff
    R_Cards.Text = "Auto-Cartas: " .. (getgenv().ShiroHubState.AutoCards and "ON" or "OFF")
    R_Cards.BackgroundColor3 = getgenv().ShiroHubState.AutoCards and raidColorOn or colorOff

    D_Ulti.Text = "Auto-Habilidades (No Dash): " .. (getgenv().ShiroHubState.AutoUlti and "ON" or "OFF")
    D_Ulti.BackgroundColor3 = getgenv().ShiroHubState.AutoUlti and colorOn or colorOff
    R_Ulti.Text = "Auto-Habilidades (No Dash): " .. (getgenv().ShiroHubState.AutoUlti and "ON" or "OFF")
    R_Ulti.BackgroundColor3 = getgenv().ShiroHubState.AutoUlti and raidColorOn or colorOff
    
    D_Continue.Text = "Auto-Seguir Partida: " .. (getgenv().ShiroHubState.AutoContinue and "ON" or "OFF")
    D_Continue.BackgroundColor3 = getgenv().ShiroHubState.AutoContinue and colorOn or colorOff
    R_Continue.Text = "Auto-Seguir Partida: " .. (getgenv().ShiroHubState.AutoContinue and "ON" or "OFF")
    R_Continue.BackgroundColor3 = getgenv().ShiroHubState.AutoContinue and raidColorOn or colorOff
end

D_Farm.MouseButton1Click:Connect(syncButtons)
R_Farm.MouseButton1Click:Connect(syncButtons)
D_Cards.MouseButton1Click:Connect(syncButtons)
R_Cards.MouseButton1Click:Connect(syncButtons)
D_Ulti.MouseButton1Click:Connect(syncButtons)
R_Ulti.MouseButton1Click:Connect(syncButtons)
D_Continue.MouseButton1Click:Connect(syncButtons)
R_Continue.MouseButton1Click:Connect(syncButtons)

TabDungeonBtn.MouseButton1Click:Connect(function()
    DungeonTab.Visible = true
    RaidTab.Visible = false
    TabDungeonBtn.BackgroundColor3 = Color3.fromRGB(70, 110, 190)
    TabDungeonBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    TabDungeonBtn.BackgroundTransparency = 0
    TabRaidBtn.BackgroundTransparency = 1
    TabRaidBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
end)

TabRaidBtn.MouseButton1Click:Connect(function()
    DungeonTab.Visible = false
    RaidTab.Visible = true
    TabRaidBtn.BackgroundColor3 = Color3.fromRGB(150, 90, 190)
    TabRaidBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    TabRaidBtn.BackgroundTransparency = 0
    TabDungeonBtn.BackgroundTransparency = 1
    TabDungeonBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
end)

local isMinimized = false
MinimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        MainFrame.Size = UDim2.new(0, 250, 0, 35)
        TabBar.Visible = false
        DungeonTab.Visible = false
        RaidTab.Visible = false
    else
        MainFrame.Size = UDim2.new(0, 250, 0, 310)
        TabBar.Visible = true
        if TabDungeonBtn.BackgroundTransparency == 0 then
            DungeonTab.Visible = true
        else
            RaidTab.Visible = true
        end
    end
end)

CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- ==========================================
-- MOTOR 1: CACHÉ POR EVENTOS (ULTRA OPTIMIZADO)
-- ==========================================
local WorldCache = {
    Mobs = {},
    Spawns = {},
    Portal = nil,
    Button = nil
}

local function classifyObject(obj)
    pcall(function()
        if not obj or not obj.Parent then return end
        local name = obj.Name:lower()

        if obj:IsA("Model") then
            local hum = obj:FindFirstChildOfClass("Humanoid")
            if hum then WorldCache.Mobs[obj] = hum end
        elseif obj:IsA("BasePart") then
            -- Búsqueda exclusiva de los spawns de las raids
            if name == "spawn" then
                WorldCache.Spawns[obj] = true
            elseif name:find("portal") or name:find("exit_door") or name:find("door") then
                WorldCache.Portal = obj
            elseif (name:find("button") or name:find("switch") or name:find("lever")) and not name:find("chest") then
                WorldCache.Button = obj
            end
            
            if getgenv().ShiroHubState.BreakObjects then
                for _, chest in ipairs(chestNames) do
                    if name:find(chest) and not name:find("black") and not name:find("key") then
                        WorldCache.Mobs[obj] = {Health = 1, MaxHealth = 100, IsChest = true}
                    end
                end
            end
        end
    end)
end

Workspace.DescendantAdded:Connect(classifyObject)

task.spawn(function()
    local allDescendants = Workspace:GetDescendants()
    for i, obj in ipairs(allDescendants) do
        classifyObject(obj)
        if i % 300 == 0 then task.wait() end 
    end
end)

-- ==========================================
-- MOTOR 2: INTERFAZ BLINDADA (Cartas y Rejoin)
-- ==========================================
task.spawn(function()
    while true do
        pcall(function()
            if getgenv().ShiroHubState.AutoContinue then
                for _, gui in ipairs(player.PlayerGui:GetDescendants()) do
                    if gui:IsA("TextButton") and gui.Visible then
                        local text = gui.Text:lower()
                        if (text:find("seguir") or text:find("continuar") or text:find("next")) and not text:find("salir") and not text:find("lobby") and not text:find("return") then
                            local absPos = gui.AbsolutePosition
                            local absSize = gui.AbsoluteSize
                            if absPos.X > 0 and absSize.X > 0 then
                                for _, conn in ipairs(getconnections(gui.MouseButton1Click)) do conn:Fire() end
                                for _, conn in ipairs(getconnections(gui.Activated)) do conn:Fire() end
                                VirtualInputManager:SendMouseButtonEvent(absPos.X + absSize.X/2, absPos.Y + absSize.Y/2, 0, true, game, 1)
                                task.wait(0.1)
                                VirtualInputManager:SendMouseButtonEvent(absPos.X + absSize.X/2, absPos.Y + absSize.Y/2, 0, false, game, 1)
                                task.wait(1.5)
                            end
                        end
                    end
                end
            end

            if getgenv().ShiroHubState.AutoCards then
                local foundCards = {}
                for _, gui in ipairs(player.PlayerGui:GetDescendants()) do
                    if gui:IsA("TextButton") and gui.Visible then
                        local btnText = gui.Text:lower()
                        if btnText:find("elegir") or btnText:find("choose") or btnText:find("select") or gui.Name:lower():find("card") or gui.Name:lower():find("carta") then
                            table.insert(foundCards, gui)
                        end
                    end
                end
                
                if #foundCards > 0 then
                    local randomCard = foundCards[math.random(1, #foundCards)]
                    local absPos = randomCard.AbsolutePosition
                    local absSize = randomCard.AbsoluteSize
                    if absPos.X > 0 and absSize.X > 0 then
                        for _, conn in ipairs(getconnections(randomCard.MouseButton1Click)) do conn:Fire() end
                        for _, conn in ipairs(getconnections(randomCard.Activated)) do conn:Fire() end
                        VirtualInputManager:SendMouseButtonEvent(absPos.X + absSize.X/2, absPos.Y + absSize.Y/2, 0, true, game, 1)
                        task.wait(0.1)
                        VirtualInputManager:SendMouseButtonEvent(absPos.X + absSize.X/2, absPos.Y + absSize.Y/2, 0, false, game, 1)
                        task.wait(1.5)
                    end
                end
            end
        end)
        task.wait(1.0) -- Frecuencia ligera para ahorrar batería y CPU en móvil
    end
end)

-- ==========================================
-- MOTOR 3: COMBATE TÁCTICO Y TP AL SPAWN ACTIVO
-- ==========================================
task.spawn(function()
    while true do
        pcall(function()
            local char = player.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local hrp = char.HumanoidRootPart
                local isEnemyAlive = false
                local bestTarget = nil
                local minDistance = math.huge
                
                -- SELECCIONAR ÚNICAMENTE EL SPAWN MÁS CERCANO (Descartando los otros 3 lejanos)
                local activeSpawn = nil
                local minSpawnDist = math.huge
                for obj, _ in pairs(WorldCache.Spawns) do
                    if obj and obj.Parent then
                        local sDist = (hrp.Position - obj.Position).Magnitude
                        if sDist < minSpawnDist then
                            minSpawnDist = sDist
                            activeSpawn = obj
                        end
                    else
                        WorldCache.Spawns[obj] = nil
                    end
                end
                
                -- Evaluación de Mobs
                if getgenv().ShiroHubState.AutoFarm then
                    for obj, hum in pairs(WorldCache.Mobs) do
                        if obj and obj.Parent and hum and (hum.Health > 0) then
                            local name = obj.Name:lower()
                            local isIgnored = false
                            
                            if obj == char or name:find("player") or name:find(player.Name:lower()) then isIgnored = true end
                            for _, ig in ipairs(ignoreMobs) do
                                if name:find(ig) then isIgnored = true break end
                            end

                            if not isIgnored then
                                isEnemyAlive = true
                                local root = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("PrimaryPart") or (obj:IsA("BasePart") and obj)
                                if root then
                                    local dist = math.huge
                                    -- RADAR DEFENSIVO: Si estamos en raid, defiende el spawn activo cercano
                                    if getgenv().ShiroHubState.AutoTree and activeSpawn then
                                        dist = (activeSpawn.Position - root.Position).Magnitude
                                    else
                                        dist = (hrp.Position - root.Position).Magnitude
                                    end
                                    
                                    if dist < minDistance then
                                        minDistance = dist
                                        bestTarget = root
                                    end
                                end
                            end
                        else
                            WorldCache.Mobs[obj] = nil 
                        end
                    end
                end
                
                if WorldCache.Portal and not WorldCache.Portal.Parent then WorldCache.Portal = nil end

                if bestTarget and isEnemyAlive then
                    local distToPlayer = (hrp.Position - bestTarget.Position).Magnitude
                    if distToPlayer > 4 then
                        hrp.CFrame = bestTarget.CFrame * CFrame.new(0, 0, 3)
                    else
                        hrp.CFrame = CFrame.lookAt(hrp.Position, Vector3.new(bestTarget.Position.X, hrp.Position.Y, bestTarget.Position.Z))
                    end
                    
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                    task.wait(0.1)
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                    
                    if getgenv().ShiroHubState.AutoUlti then
                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.R, false, game)
                        task.wait(0.05)
                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.R, false, game)
                    end
                
                elseif not isEnemyAlive then
                    if getgenv().ShiroHubState.AutoNextZone and WorldCache.Portal then
                        if (hrp.Position - WorldCache.Portal.Position).Magnitude > 4 then
                            hrp.CFrame = WorldCache.Portal.CFrame * CFrame.new(0, 2, 0)
                        end
                    elseif getgenv().ShiroHubState.AutoButtons and WorldCache.Button then
                        if (hrp.Position - WorldCache.Button.Position).Magnitude > 4 then
                            hrp.CFrame = WorldCache.Button.CFrame * CFrame.new(0, 2, 2)
                        end
                        task.wait(0.2)
                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                        task.wait(1.0)
                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                        
                    -- TP INSTANTÁNEO ÚNICAMENTE AL SPAWN ACTIVO CERCANO
                    elseif getgenv().ShiroHubState.AutoTree and activeSpawn then
                        if (hrp.Position - activeSpawn.Position).Magnitude > 3 then
                            hrp.CFrame = activeSpawn.CFrame * CFrame.new(0, 2.5, 0)
                        else
                            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                            task.wait(0.1)
                            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                        end
                    end
                end
            end
        end)
        task.wait(0.1)
    end
end)
