--[[
    Pixel Blade Hub - Versión Final (Solo Mobs Oficiales + Cero Lag + Cuidado de Decoraciones)
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

-- LISTA OFICIAL ESTRICTA: Solo atacará a estos nombres exactos y conocidos
local targetMobs = {
    "zombie", "archer", "mortar", "ghoul", "lumberjack", 
    "cannon_goblin", "mage", "giant", "undead", "skeleton",
    "kingslayer", "goblintype1", "goblintype2", "bolt"
}
local chestNames = {"chest", "crate"}
local ignoreMobs = {
    "necromancer", "tutorial_clyde", "ally", "summon", "pet", "familiar", 
    "black_chest", "locked", "key_chest", "boss_chest", "key", "black", "decoration", "prop", "flora", "tree"
}

-- INTERFAZ GRÁFICA (HUD) COMPACTA Y LIGERA
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PixelBladeSmartHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 240, 0, 310)
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
Title.Text = "Blade Hub [Estricto]"
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

    D_Cards.Text = "Auto-Cartas (Llama/Furia): " .. (getgenv().PixelBladeState.AutoCards and "ON" or "OFF")
    D_Cards.BackgroundColor3 = getgenv().PixelBladeState.AutoCards and colorOn or colorOff
    R_Cards.Text = "Auto-Cartas (Llama/Furia): " .. (getgenv().PixelBladeState.AutoCards and "ON" or "OFF")
    R_Cards.BackgroundColor3 = getgenv().PixelBladeState.AutoCards and raidColorOn or colorOff

    D_Ulti.Text = "Auto-Habilidades (Ulti): " .. (getgenv().PixelBladeState.AutoUlti and "ON" or "OFF")
    D_Ulti.BackgroundColor3 = getgenv().PixelBladeState.AutoUlti and colorOn or colorOff
    R_Ulti.Text = "Auto-Habilidades (Ulti): " .. (getgenv().PixelBladeState.AutoUlti and "ON" or "OFF")
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
    TabDungeonBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 65)
    TabDungeonBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    TabRaidBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 35)
    TabRaidBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
end)

TabRaidBtn.MouseButton1Click:Connect(function()
    DungeonTab.Visible = false
    RaidTab.Visible = true
    TabRaidBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 65)
    TabRaidBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    TabDungeonBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 35)
    TabDungeonBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
end)

local ExitBtn = Instance.new("TextButton")
ExitBtn.Size = UDim2.new(1, -20, 0, 24)
ExitBtn.Position = UDim2.new(0, 10, 1, -30)
ExitBtn.Text = "Cerrar Hub por completo"
ExitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ExitBtn.Font = Enum.Font.SourceSansBold
ExitBtn.TextSize = 11
ExitBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
ExitBtn.BorderSizePixel = 0
ExitBtn.Parent = MainFrame

local isMinimized = false
MinimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        MainFrame.Size = UDim2.new(0, 240, 0, 30)
        MinimizeBtn.Text = "+"
        DungeonTab.Visible = false
        RaidTab.Visible = false
        TabBar.Visible = false
        ExitBtn.Visible = false
    else
        MainFrame.Size = UDim2.new(0, 240, 0, 310)
        MinimizeBtn.Text = "-"
        TabBar.Visible = true
        ExitBtn.Visible = true
        if TabDungeonBtn.BackgroundColor3 == Color3.fromRGB(70, 70, 65) then
            DungeonTab.Visible = true
        else
            RaidTab.Visible = true
        end
    end
end)

CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
ExitBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

local cachedTargets = {}
local cachedPortal = nil
local cachedTree = nil
local cachedButton = nil
local isEnemyAlive = false

-- MOTOR 1: Escáner Estricto (Solo Mobs de la lista oficial, ignorando decoraciones y objetos fijos)
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
                if obj:IsA("Model") or obj:IsA("Part") then
                    local name = obj.Name:lower()
                    local hum = obj:FindFirstChildOfClass("Humanoid")
                    
                    if obj ~= char then
                        local isIgnored = false
                        local isKnown = false
                        local isChest = false
                        
                        if obj:IsDescendantOf(char) or name:find("player") or name:find(player.Name:lower()) then 
                            isIgnored = true 
                        end
                        
                        for _, ig in ipairs(ignoreMobs) do
                            if name:find(ig) then isIgnored = true break end
                        end

                        if not isIgnored then
                            -- Comprueba estrictamente si el nombre coincide con la lista oficial de enemigos
                            for _, mob in ipairs(targetMobs) do 
                                if name:find(mob) then 
                                    isKnown = true 
                                    break 
                                end 
                            end
                            
                            if getgenv().PixelBladeState.BreakObjects then
                                for _, chest in ipairs(chestNames) do 
                                    if name:find(chest) and not name:find("black") and not name:find("key") and not name:find("locked") then 
                                        isChest = true 
                                        break 
                                    end 
                                end
                            end

                            -- Solo acepta al enemigo si está en la lista oficial de mobs o es un cofre real válido
                            if (isKnown and hum and hum.Health > 0) or isChest then
                                if isKnown then isEnemyAlive = true end
                                local root = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("PrimaryPart") or obj:FindFirstChildOfClass("Part")
                                if root then table.insert(newTargets, root) end
                            end

                            if getgenv().PixelBladeState.AutoButtons then
                                if (name:find("button") or name:find("switch") or name:find("lever") or name:find("mechanism")) and not name:find("chest") and not name:find("black") then
                                    if not bFound then
                                        bFound = obj:IsA("Part") and obj or obj:FindFirstChildOfClass("Part") or obj:FindFirstChild("PrimaryPart")
                                    end
                                end
                            end
                        end
                    end

                    if getgenv().PixelBladeState.AutoNextZone then
                        if name:find("portal") or name:find("exit_door") or name:find("door") or name:find("next") then
                            if not pFound then pFound = obj:IsA("Part") and obj or obj:FindFirstChildOfClass("Part") or obj:FindFirstChild("PrimaryPart") end
                        end
                    end
                    
                    if getgenv().PixelBladeState.AutoTree then
                        if name:find("tree") or name:find("arbol") or name:find("circle") or name:find("spawn") or name:find("wave") then
                            if not tFound then tFound = obj:IsA("Part") and obj or obj:FindFirstChildOfClass("Part") or obj:FindFirstChild("PrimaryPart") end
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

-- MOTOR 2: UI Scanner (Auto-Seguir, Auto-Cartas)
task.spawn(function()
    while true do
        pcall(function()
            if getgenv().PixelBladeState.AutoContinue then
                for _, gui in ipairs(player.PlayerGui:GetDescendants()) do
                    if gui:IsA("TextButton") and gui.Visible then
                        local text = gui.Text:lower()
                        if text:find("seguir") or text:find("continuar") or text:find("next") or text:find("continue") then
                            local absPos = gui.AbsolutePosition
                            local absSize = gui.AbsoluteSize
                            if absPos.X > 0 and absSize.X > 0 then
                                for _, conn in ipairs(getconnections(gui.MouseButton1Click)) do conn:Fire() end
                                for _, conn in ipairs(getconnections(gui.Activated)) do conn:Fire() end
                                VirtualInputManager:SendMouseButtonEvent(absPos.X + absSize.X/2, absPos.Y + absSize.Y/2, 0, true, game, 1)
                                task.wait(0.1)
                                VirtualInputManager:SendMouseButtonEvent(absPos.X + absSize.X/2, absPos.Y + absSize.Y/2, 0, false, game, 1)
                                task.wait(1)
                            end
                        end
                    end
                end
            end

            if getgenv().PixelBladeState.AutoCards then
                local priorityCard = nil
                local anyCard = nil
                
                for _, gui in ipairs(player.PlayerGui:GetDescendants()) do
                    if gui:IsA("TextButton") and gui.Visible then
                        local parentModel = gui.Parent
                        local cardText = ""
                        for _, sub in ipairs(parentModel:GetDescendants()) do
                            if sub:IsA("TextLabel") or sub:IsA("TextBox") then
                                cardText = cardText .. " " .. sub.Text:lower()
                            end
                        end
                        cardText = cardText .. " " .. gui.Text:lower()

                        if cardText:find("llama") or cardText:find("flame") or cardText:find("espiritus") or cardText:find("furia") or cardText:find("spirit") then
                            priorityCard = gui
                        else
                            anyCard = gui
                        end
                    end
                end
                
                local targetCard = priorityCard or anyCard
                if targetCard then
                    local absPos = targetCard.AbsolutePosition
                    local absSize = targetCard.AbsoluteSize
                    if absPos.X > 0 and absSize.X > 0 then
                        for _, conn in ipairs(getconnections(targetCard.MouseButton1Click)) do conn:Fire() end
                        for _, conn in ipairs(getconnections(targetCard.Activated)) do conn:Fire() end
                        VirtualInputManager:SendMouseButtonEvent(absPos.X + absSize.X/2, absPos.Y + absSize.Y/2, 0, true, game, 1)
                        task.wait(0.1)
                        VirtualInputManager:SendMouseButtonEvent(absPos.X + absSize.X/2, absPos.Y + absSize.Y/2, 0, false, game, 1)
                    end
                end
            end
        end)
        task.wait(1)
    end
end)

-- MOTOR 3: Combate Termo-Estable
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
                        
                        if getgenv().PixelBladeState.AutoUlti then
                            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Q, false, game)
                            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.R, false, game)
                            task.wait(0.05)
                            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Q, false, game)
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
                        task.wait(1.5)
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
