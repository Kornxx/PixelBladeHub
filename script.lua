--[[
    Pixel Blade Hub - UI Moderna (Dark Mode) + Raid Circle Fix + Random Cards
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local VirtualInputManager = game:GetService("VirtualInputManager")
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
        BreakObjects = false,
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

-- ==========================================
-- INTERFAZ GRÁFICA (HUD) MODERNA
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PixelBladeSmartHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, 340)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -170)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 22) -- Dark Mode
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner_Main = Instance.new("UICorner")
UICorner_Main.CornerRadius = UDim.new(0, 10)
UICorner_Main.Parent = MainFrame

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 35)
TopBar.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local UICorner_Top = Instance.new("UICorner")
UICorner_Top.CornerRadius = UDim.new(0, 10)
UICorner_Top.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -70, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.Text = "Blade Hub [Pro V2]"
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
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
MinimizeBtn.Parent = TopBar
Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0, 6)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.Position = UDim2.new(1, -30, 0, 5)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 12
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
CloseBtn.Parent = TopBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, -20, 0, 30)
TabBar.Position = UDim2.new(0, 10, 0, 45)
TabBar.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
TabBar.Parent = MainFrame
Instance.new("UICorner", TabBar).CornerRadius = UDim.new(0, 6)

local TabDungeonBtn = Instance.new("TextButton")
TabDungeonBtn.Size = UDim2.new(0.5, 0, 1, 0)
TabDungeonBtn.Text = "DUNGEON"
TabDungeonBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TabDungeonBtn.Font = Enum.Font.GothamBold
TabDungeonBtn.TextSize = 11
TabDungeonBtn.BackgroundColor3 = Color3.fromRGB(80, 120, 200)
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

local colorOn = Color3.fromRGB(80, 180, 120)
local colorOff = Color3.fromRGB(45, 45, 50)
local raidColorOn = Color3.fromRGB(160, 100, 200) 

local function createButton(parent, text, yPos, stateKey, activeColor)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 28)
    btn.Position = UDim2.new(0, 10, 0, yPos)
    btn.Text = text .. ": " .. (getgenv().PixelBladeState[stateKey] and "ON" or "OFF")
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 11
    btn.BackgroundColor3 = getgenv().PixelBladeState[stateKey] and activeColor or colorOff
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    btn.MouseButton1Click:Connect(function()
        getgenv().PixelBladeState[stateKey] = not getgenv().PixelBladeState[stateKey]
        btn.Text = text .. ": " .. (getgenv().PixelBladeState[stateKey] and "ON" or "OFF")
        btn.BackgroundColor3 = getgenv().PixelBladeState[stateKey] and activeColor or colorOff
    end)
    return btn
end

local D_Farm = createButton(DungeonTab, "Auto-Farm Mobs", 0, "AutoFarm", colorOn)
local D_Cards = createButton(DungeonTab, "Auto-Cartas (Aleatorio)", 35, "AutoCards", colorOn)
local D_Ulti = createButton(DungeonTab, "Auto-Habilidades (Sin Dash)", 70, "AutoUlti", colorOn)
local D_Chests = createButton(DungeonTab, "Romper Cofres", 105, "BreakObjects", colorOn)
local D_Zone = createButton(DungeonTab, "Auto-Avanzar (Portales)", 140, "AutoNextZone", colorOn)
local D_Boss = createButton(DungeonTab, "Auto-Botones (Jefes)", 175, "AutoButtons", colorOn)
local D_Continue = createButton(DungeonTab, "Auto-Seguir (Continuar)", 210, "AutoContinue", colorOn)

local R_Farm = createButton(RaidTab, "Auto-Farm Raids", 0, "AutoFarm", raidColorOn)
local R_Cards = createButton(RaidTab, "Auto-Cartas (Aleatorio)", 35, "AutoCards", raidColorOn)
local R_Ulti = createButton(RaidTab, "Auto-Habilidades (Sin Dash)", 70, "AutoUlti", raidColorOn)
local R_Tree = createButton(RaidTab, "Auto Círculo Morado (Oleadas)", 105, "AutoTree", raidColorOn)
local R_Continue = createButton(RaidTab, "Auto-Seguir (Continuar)", 140, "AutoContinue", raidColorOn)

local function syncButtons()
    D_Farm.Text = "Auto-Farm Mobs: " .. (getgenv().PixelBladeState.AutoFarm and "ON" or "OFF")
    D_Farm.BackgroundColor3 = getgenv().PixelBladeState.AutoFarm and colorOn or colorOff
    R_Farm.Text = "Auto-Farm Raids: " .. (getgenv().PixelBladeState.AutoFarm and "ON" or "OFF")
    R_Farm.BackgroundColor3 = getgenv().PixelBladeState.AutoFarm and raidColorOn or colorOff

    D_Cards.Text = "Auto-Cartas (Aleatorio): " .. (getgenv().PixelBladeState.AutoCards and "ON" or "OFF")
    D_Cards.BackgroundColor3 = getgenv().PixelBladeState.AutoCards and colorOn or colorOff
    R_Cards.Text = "Auto-Cartas (Aleatorio): " .. (getgenv().PixelBladeState.AutoCards and "ON" or "OFF")
    R_Cards.BackgroundColor3 = getgenv().PixelBladeState.AutoCards and raidColorOn or colorOff

    D_Ulti.Text = "Auto-Habilidades (Sin Dash): " .. (getgenv().PixelBladeState.AutoUlti and "ON" or "OFF")
    D_Ulti.BackgroundColor3 = getgenv().PixelBladeState.AutoUlti and colorOn or colorOff
    R_Ulti.Text = "Auto-Habilidades (Sin Dash): " .. (getgenv().PixelBladeState.AutoUlti and "ON" or "OFF")
    R_Ulti.BackgroundColor3 = getgenv().PixelBladeState.AutoUlti and raidColorOn or colorOff
    
    D_Continue.Text = "Auto-Seguir (Continuar): " .. (getgenv().PixelBladeState.AutoContinue and "ON" or "OFF")
    D_Continue.BackgroundColor3 = getgenv().PixelBladeState.AutoContinue and colorOn or colorOff
    R_Continue.Text = "Auto-Seguir (Continuar): " .. (getgenv().PixelBladeState.AutoContinue and "ON" or "OFF")
    R_Continue.BackgroundColor3 = getgenv().PixelBladeState.AutoContinue and raidColorOn or colorOff
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
    TabDungeonBtn.BackgroundColor3 = Color3.fromRGB(80, 120, 200)
    TabDungeonBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    TabDungeonBtn.BackgroundTransparency = 0
    TabRaidBtn.BackgroundTransparency = 1
    TabRaidBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
end)

TabRaidBtn.MouseButton1Click:Connect(function()
    DungeonTab.Visible = false
    RaidTab.Visible = true
    TabRaidBtn.BackgroundColor3 = Color3.fromRGB(160, 100, 200)
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
        MainFrame.Size = UDim2.new(0, 250, 0, 340)
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
-- MOTORES LOGICOS
-- ==========================================
local cachedTargets = {}
local cachedPortal = nil
local cachedTree = nil
local cachedButton = nil
local isEnemyAlive = false

-- MOTOR 1: Escáner (Mobs Reales y Círculos de Raid)
task.spawn(function()
    while true do
        pcall(function()
            local newTargets = {}
            local pFound = nil
            local tFound = nil
            local bFound = nil
            local char = player.Character
            isEnemyAlive = false

            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("Model") or obj:IsA("Part") or obj:IsA("MeshPart") then
                    local name = obj.Name:lower()
                    local hum = obj:FindFirstChildOfClass("Humanoid")
                    
                    if obj ~= char then
                        local isIgnored = false
                        local isChest = false
                        
                        if obj:IsDescendantOf(char) or name:find("player") or name:find(player.Name:lower()) then 
                            isIgnored = true 
                        end
                        for _, ig in ipairs(ignoreMobs) do
                            if name:find(ig) then isIgnored = true break end
                        end

                        if not isIgnored then
                            if getgenv().PixelBladeState.BreakObjects then
                                for _, chest in ipairs(chestNames) do 
                                    if name:find(chest) and not name:find("black") and not name:find("key") and not name:find("locked") then 
                                        isChest = true 
                                        break 
                                    end 
                                end
                            end

                            -- Solo ataca si tiene vida real y no es decoración
                            if (hum and hum.Health > 0 and hum.MaxHealth > 5) or isChest then
                                local isKnown = false
                                for _, mob in ipairs(targetMobs) do 
                                    if name:find(mob) then isKnown = true break end 
                                end

                                if isKnown or (hum and hum.Health > 0 and hum.MaxHealth > 5 and not isChest) then
                                    isEnemyAlive = true
                                    local root = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("PrimaryPart") or obj:FindFirstChildOfClass("Part")
                                    if root then table.insert(newTargets, root) end
                                end
                            end

                            if getgenv().PixelBladeState.AutoButtons then
                                if (name:find("button") or name:find("switch") or name:find("lever")) and not name:find("chest") then
                                    if not bFound then bFound = obj:IsA("Part") and obj or obj:FindFirstChildOfClass("Part") end
                                end
                            end
                        end
                    end

                    if getgenv().PixelBladeState.AutoNextZone then
                        if name:find("portal") or name:find("exit_door") or name:find("door") then
                            if not pFound then pFound = obj:IsA("Part") and obj or obj:FindFirstChildOfClass("Part") end
                        end
                    end
                    
                    -- Escáner Especial para Círculo Morado / Raid
                    if getgenv().PixelBladeState.AutoTree then
                        -- Busca por nombres clave de inicio de raid, o si tiene un ProximityPrompt (botón E interactuable)
                        if name:find("circle") or name:find("raid") or name:find("spawn") or name:find("wave") or obj:FindFirstChildOfClass("ProximityPrompt") then
                            if not tFound then tFound = obj:IsA("Part") and obj or obj:IsA("MeshPart") and obj or obj:FindFirstChildOfClass("Part") end
                        end
                    end
                end
            end
            
            cachedTargets = newTargets
            cachedPortal = pFound
            cachedTree = tFound
            cachedButton = bFound
        end)
        task.wait(1.0)
    end
end)

-- MOTOR 2: Interfaz (Cartas Random y Seguir Estricto)
task.spawn(function()
    while true do
        pcall(function()
            -- 1. Auto-Seguir (SOLO SEGUIR, ignora salir/lobby)
            if getgenv().PixelBladeState.AutoContinue then
                for _, gui in ipairs(player.PlayerGui:GetDescendants()) do
                    if gui:IsA("TextButton") and gui.Visible then
                        local text = gui.Text:lower()
                        if (text:find("seguir") or text:find("continuar") or text:find("next")) and not text:find("salir") and not text:find("lobby") and not text:find("return") then
                            local absPos = gui.AbsolutePosition
                            local absSize = gui.AbsoluteSize
                            if absPos.X > 0 and absSize.X > 0 then
                                VirtualInputManager:SendMouseButtonEvent(absPos.X + absSize.X/2, absPos.Y + absSize.Y/2, 0, true, game, 1)
                                task.wait(0.1)
                                VirtualInputManager:SendMouseButtonEvent(absPos.X + absSize.X/2, absPos.Y + absSize.Y/2, 0, false, game, 1)
                                task.wait(1.5)
                            end
                        end
                    end
                end
            end

            -- 2. Auto-Cartas 100% Aleatorias
            if getgenv().PixelBladeState.AutoCards then
                local foundCards = {}
                for _, gui in ipairs(player.PlayerGui:GetDescendants()) do
                    if gui:IsA("TextButton") and gui.Visible then
                        local btnText = gui.Text:lower()
                        if btnText:find("elegir") or btnText:find("choose") or btnText:find("select") then
                            table.insert(foundCards, gui)
                        end
                    end
                end
                
                -- Elige una carta de la lista al azar
                if #foundCards > 0 then
                    local randomCard = foundCards[math.random(1, #foundCards)]
                    local absPos = randomCard.AbsolutePosition
                    local absSize = randomCard.AbsoluteSize
                    if absPos.X > 0 and absSize.X > 0 then
                        VirtualInputManager:SendMouseButtonEvent(absPos.X + absSize.X/2, absPos.Y + absSize.Y/2, 0, true, game, 1)
                        task.wait(0.1)
                        VirtualInputManager:SendMouseButtonEvent(absPos.X + absSize.X/2, absPos.Y + absSize.Y/2, 0, false, game, 1)
                        task.wait(1.5)
                    end
                end
            end
        end)
        task.wait(0.5)
    end
end)

-- MOTOR 3: Combate y Teletransporte sin Dash
task.spawn(function()
    while true do
        pcall(function()
            local char = player.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local hrp = char.HumanoidRootPart
                
                if getgenv().PixelBladeState.AutoFarm and isEnemyAlive then
                    local bestTarget = nil
                    local minDistance = math.huge
                    
                    for _, root in ipairs(cachedTargets) do
                        if root and root.Parent and root:IsDescendantOf(Workspace) then
                            local dist = (hrp.Position - root.Position).Magnitude
                            if dist < minDistance then
                                minDistance = dist
                                bestTarget = root
                            end
                        end
                    end
                    
                    if bestTarget then
                        if minDistance > 4 then
                            hrp.CFrame = bestTarget.CFrame * CFrame.new(0, 0, 3)
                        else
                            hrp.CFrame = CFrame.lookAt(hrp.Position, Vector3.new(bestTarget.Position.X, hrp.Position.Y, bestTarget.Position.Z))
                        end
                        
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                        task.wait(0.1)
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                        
                        -- Auto-Ulti (Sin apretar la Q para evitar el dash)
                        if getgenv().PixelBladeState.AutoUlti then
                            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.R, false, game)
                            task.wait(0.05)
                            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.R, false, game)
                        end
                    end
                
                elseif not isEnemyAlive then
                    if getgenv().PixelBladeState.AutoNextZone and cachedPortal then
                        if (hrp.Position - cachedPortal.Position).Magnitude > 4 then
                            hrp.CFrame = cachedPortal.CFrame * CFrame.new(0, 2, 0)
                        end
                    elseif getgenv().PixelBladeState.AutoButtons and cachedButton then
                        if (hrp.Position - cachedButton.Position).Magnitude > 4 then
                            hrp.CFrame = cachedButton.CFrame * CFrame.new(0, 2, 2)
                        end
                        task.wait(0.2)
                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                        task.wait(1.0)
                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                    elseif getgenv().PixelBladeState.AutoTree and cachedTree then
                        task.wait(2.0) -- Espera 2 segundos al acabar la oleada antes de saltar al círculo
                        if (hrp.Position - cachedTree.Position).Magnitude > 4 then
                            hrp.CFrame = cachedTree.CFrame * CFrame.new(0, 2, 0)
                        end
                    end
                end
            end
        end)
        task.wait(0.1)
    end
end)
