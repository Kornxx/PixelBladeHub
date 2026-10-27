--[[
    Pixel Blade Hub - Definitivo (Filtro Inteligente Anti-Aliados por Distancia y Dueño)
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
        BreakObjects = true,
        AutoUlti = false,
        AutoNextZone = false
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
    "cannon_goblin", "mage", "giant", "undead", "skeleton"
}
local chestNames = {"chest", "crate"}

-- Lista Negra para ignorar aliados, mascotas y cofres negros
local ignoreMobs = {
    "necromancer", "tutorial_clyde", "ally", "summon", "pet", "familiar", 
    "black_chest", "locked", "key_chest", "boss_chest"
}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PixelBladeSmartHub"
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 240, 0, 330)
MainFrame.Position = UDim2.new(0.5, -120, 0.5, -165)
MainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Active = false
MainFrame.Draggable = false
MainFrame.Parent = ScreenGui

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 30)
TopBar.BackgroundColor3 = Color3.fromRGB(245, 245, 220)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -60, 1, 0)
Title.Position = UDim2.new(0, 5, 0, 0)
Title.Text = "Blade Hub [Smart Filter]"
Title.TextColor3 = Color3.fromRGB(20, 20, 15)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 13
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local isMinimized = false
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 25, 0, 20)
MinimizeBtn.Position = UDim2.new(1, -55, 0, 5)
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Color3.fromRGB(20, 20, 15)
MinimizeBtn.Font = Enum.Font.SourceSansBold
MinimizeBtn.TextSize = 14
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(200, 200, 180)
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

local ContentContainer = Instance.new("Folder")
ContentContainer.Name = "ContentContainer"
ContentContainer.Parent = MainFrame

local RadarBox = Instance.new("TextBox")
RadarBox.Size = UDim2.new(1, -20, 0, 70)
RadarBox.Position = UDim2.new(0, 10, 0, 38)
RadarBox.Text = "Radar Activo..."
RadarBox.TextColor3 = Color3.fromRGB(255, 255, 255)
RadarBox.Font = Enum.Font.Code
RadarBox.TextSize = 10
RadarBox.TextWrapped = true
RadarBox.ClearTextOnFocus = false
RadarBox.MultiLine = true
RadarBox.BackgroundColor3 = Color3.fromRGB(50, 50, 45)
RadarBox.BorderSizePixel = 0
RadarBox.Parent = ContentContainer

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(1, -20, 0, 30)
ToggleBtn.Position = UDim2.new(0, 10, 0, 115)
ToggleBtn.Text = "Auto-Farm Mobs: " .. (getgenv().PixelBladeState.AutoFarm and "ON" or "OFF")
ToggleBtn.TextColor3 = Color3.fromRGB(20, 20, 15)
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.TextSize = 12
ToggleBtn.BackgroundColor3 = getgenv().PixelBladeState.AutoFarm and Color3.fromRGB(180, 220, 180) or Color3.fromRGB(245, 245, 220)
ToggleBtn.BorderSizePixel = 0
ToggleBtn.Parent = ContentContainer

ToggleBtn.MouseButton1Click:Connect(function()
    getgenv().PixelBladeState.AutoFarm = not getgenv().PixelBladeState.AutoFarm
    ToggleBtn.Text = "Auto-Farm Mobs: " .. (getgenv().PixelBladeState.AutoFarm and "ON" or "OFF")
    ToggleBtn.BackgroundColor3 = getgenv().PixelBladeState.AutoFarm and Color3.fromRGB(180, 220, 180) or Color3.fromRGB(245, 245, 220)
end)

local CardBtn = Instance.new("TextButton")
CardBtn.Size = UDim2.new(1, -20, 0, 30)
CardBtn.Position = UDim2.new(0, 10, 0, 150)
CardBtn.Text = "Auto-Cartas: " .. (getgenv().PixelBladeState.AutoCards and "ON" or "OFF")
CardBtn.TextColor3 = Color3.fromRGB(20, 20, 15)
CardBtn.Font = Enum.Font.SourceSansBold
CardBtn.TextSize = 12
CardBtn.BackgroundColor3 = getgenv().PixelBladeState.AutoCards and Color3.fromRGB(180, 220, 180) or Color3.fromRGB(245, 245, 220)
CardBtn.BorderSizePixel = 0
CardBtn.Parent = ContentContainer

CardBtn.MouseButton1Click:Connect(function()
    getgenv().PixelBladeState.AutoCards = not getgenv().PixelBladeState.AutoCards
    CardBtn.Text = "Auto-Cartas: " .. (getgenv().PixelBladeState.AutoCards and "ON" or "OFF")
    CardBtn.BackgroundColor3 = getgenv().PixelBladeState.AutoCards and Color3.fromRGB(180, 220, 180) or Color3.fromRGB(245, 245, 220)
end)

local ChestBtn = Instance.new("TextButton")
ChestBtn.Size = UDim2.new(1, -20, 0, 30)
ChestBtn.Position = UDim2.new(0, 10, 0, 185)
ChestBtn.Text = "Romper Cofres: " .. (getgenv().PixelBladeState.BreakObjects and "ON" or "OFF")
ChestBtn.TextColor3 = Color3.fromRGB(20, 20, 15)
ChestBtn.Font = Enum.Font.SourceSansBold
ChestBtn.TextSize = 12
ChestBtn.BackgroundColor3 = getgenv().PixelBladeState.BreakObjects and Color3.fromRGB(180, 220, 180) or Color3.fromRGB(245, 245, 220)
ChestBtn.BorderSizePixel = 0
ChestBtn.Parent = ContentContainer

ChestBtn.MouseButton1Click:Connect(function()
    getgenv().PixelBladeState.BreakObjects = not getgenv().PixelBladeState.BreakObjects
    ChestBtn.Text = "Romper Cofres: " .. (getgenv().PixelBladeState.BreakObjects and "ON" or "OFF")
    ChestBtn.BackgroundColor3 = getgenv().PixelBladeState.BreakObjects and Color3.fromRGB(180, 220, 180) or Color3.fromRGB(245, 245, 220)
end)

local UltiBtn = Instance.new("TextButton")
UltiBtn.Size = UDim2.new(1, -20, 0, 30)
UltiBtn.Position = UDim2.new(0, 10, 0, 220)
UltiBtn.Text = "Auto-Habilidades (Ulti): " .. (getgenv().PixelBladeState.AutoUlti and "ON" or "OFF")
UltiBtn.TextColor3 = Color3.fromRGB(20, 20, 15)
UltiBtn.Font = Enum.Font.SourceSansBold
UltiBtn.TextSize = 12
UltiBtn.BackgroundColor3 = getgenv().PixelBladeState.AutoUlti and Color3.fromRGB(180, 220, 180) or Color3.fromRGB(245, 245, 220)
UltiBtn.BorderSizePixel = 0
UltiBtn.Parent = ContentContainer

UltiBtn.MouseButton1Click:Connect(function()
    getgenv().PixelBladeState.AutoUlti = not getgenv().PixelBladeState.AutoUlti
    UltiBtn.Text = "Auto-Habilidades (Ulti): " .. (getgenv().PixelBladeState.AutoUlti and "ON" or "OFF")
    UltiBtn.BackgroundColor3 = getgenv().PixelBladeState.AutoUlti and Color3.fromRGB(180, 220, 180) or Color3.fromRGB(245, 245, 220)
end)

local ZoneBtn = Instance.new("TextButton")
ZoneBtn.Size = UDim2.new(1, -20, 0, 30)
ZoneBtn.Position = UDim2.new(0, 10, 0, 255)
ZoneBtn.Text = "Auto-Avanzar Zona: " .. (getgenv().PixelBladeState.AutoNextZone and "ON" or "OFF")
ZoneBtn.TextColor3 = Color3.fromRGB(20, 20, 15)
ZoneBtn.Font = Enum.Font.SourceSansBold
ZoneBtn.TextSize = 12
ZoneBtn.BackgroundColor3 = getgenv().PixelBladeState.AutoNextZone and Color3.fromRGB(180, 220, 180) or Color3.fromRGB(245, 245, 220)
ZoneBtn.BorderSizePixel = 0
ZoneBtn.Parent = ContentContainer

ZoneBtn.MouseButton1Click:Connect(function()
    getgenv().PixelBladeState.AutoNextZone = not getgenv().PixelBladeState.AutoNextZone
    ZoneBtn.Text = "Auto-Avanzar Zona: " .. (getgenv().PixelBladeState.AutoNextZone and "ON" or "OFF")
    ZoneBtn.BackgroundColor3 = getgenv().PixelBladeState.AutoNextZone and Color3.fromRGB(180, 220, 180) or Color3.fromRGB(245, 245, 220)
end)

local ExitBtn = Instance.new("TextButton")
ExitBtn.Size = UDim2.new(1, -20, 0, 25)
ExitBtn.Position = UDim2.new(0, 10, 0, 290)
ExitBtn.Text = "Cerrar Hub por completo"
ExitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ExitBtn.Font = Enum.Font.SourceSansBold
ExitBtn.TextSize = 11
ExitBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
ExitBtn.BorderSizePixel = 0
ExitBtn.Parent = ContentContainer

MinimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        MainFrame.Size = UDim2.new(0, 240, 0, 30)
        MinimizeBtn.Text = "+"
        for _, obj in ipairs(ContentContainer:GetChildren()) do
            if obj:IsA("GuiObject") then obj.Visible = false end
        end
    else
        MainFrame.Size = UDim2.new(0, 240, 0, 330)
        MinimizeBtn.Text = "-"
        for _, obj in ipairs(ContentContainer:GetChildren()) do
            if obj:IsA("GuiObject") then obj.Visible = true end
        end
    end
end)

CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
ExitBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

local cachedTargets = {}
local cachedPortal = nil
local isEnemyAlive = false

-- MOTOR 1: Radar con validación estricta de jerarquía (Ignora aliados invocados)
task.spawn(function()
    while true do
        pcall(function()
            local newTargets = {}
            local portalFound = nil
            local detected = ""
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
                        
                        -- NUEVO: Si el objeto está dentro de tu propio personaje o modelo, es tu aliado/minion
                        if obj:IsDescendantOf(char) then
                            isIgnored = true
                        end

                        -- Filtro por nombres en lista negra (necromancer, cofres negros, etc.)
                        if name:find("player") or name:find(player.Name:lower()) then isIgnored = true end
                        for _, ig in ipairs(ignoreMobs) do
                            if name:find(ig) then isIgnored = true break end
                        end

                        if not isIgnored then
                            for _, mob in ipairs(targetMobs) do if name:find(mob) then isKnown = true break end end
                            
                            if getgenv().PixelBladeState.BreakObjects then
                                for _, chest in ipairs(chestNames) do 
                                    if name:find(chest) and not name:find("black") and not name:find("key") and not name:find("locked") then 
                                        isChest = true 
                                        break 
                                    end 
                                end
                            end

                            if (isKnown and hum and hum.Health > 0) or isChest then
                                if isKnown then isEnemyAlive = true end
                                local root = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("PrimaryPart") or obj:FindFirstChildOfClass("Part")
                                if root then table.insert(newTargets, root) end
                            end

                            if hum and hum.Health > 0 and not isKnown and not isIgnored then
                                detected = detected .. "[Mob] " .. obj.Name .. "\n"
                            end
                        end
                    end

                    if getgenv().PixelBladeState.AutoNextZone then
                        if name:find("exit_door") or name:find("portal") or name:find("door") or name:find("next") then
                            detected = detected .. "[Portal] " .. obj.Name .. "\n"
                            if not portalFound then
                                portalFound = obj:IsA("Part") and obj or obj:FindFirstChildOfClass("Part") or obj:FindFirstChild("PrimaryPart")
                            end
                        end
                    end
                end
            end
            
            cachedTargets = newTargets
            cachedPortal = portalFound
            
            if detected ~= "" then
                RadarBox.Text = "Nuevos Descubiertos:\n" .. detected
            else
                RadarBox.Text = "Radar en espera... (Todo despejado)"
            end
        end)
        task.wait(1)
    end
end)

-- MOTOR 2: Auto Cartas y Auto Ulti
task.spawn(function()
    while true do
        pcall(function()
            if getgenv().PixelBladeState.AutoCards then
                for _, gui in ipairs(player.PlayerGui:GetDescendants()) do
                    if gui:IsA("TextButton") and gui.Visible then
                        if gui.Text:upper():find("ELEGIR") or gui.Name:lower():find("elegir") then
                            local absPos = gui.AbsolutePosition
                            local absSize = gui.AbsoluteSize
                            if absPos.X > 0 and absSize.X > 0 then
                                for _, conn in ipairs(getconnections(gui.MouseButton1Click)) do conn:Fire() end
                                for _, conn in ipairs(getconnections(gui.Activated)) do conn:Fire() end
                                VirtualInputManager:SendMouseButtonEvent(absPos.X + absSize.X/2, absPos.Y + absSize.Y/2, 0, true, game, 1)
                                task.wait(0.05)
                                VirtualInputManager:SendMouseButtonEvent(absPos.X + absSize.X/2, absPos.Y + absSize.Y/2, 0, false, game, 1)
                            end
                        end
                    end
                end
            end

            if getgenv().PixelBladeState.AutoUlti and getgenv().PixelBladeState.AutoFarm and isEnemyAlive then
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Q, false, game)
                task.wait(0.05)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Q, false, game)
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                task.wait(0.05)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.R, false, game)
                task.wait(0.05)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.R, false, game)
            end
        end)
        task.wait(0.4)
    end
end)

-- MOTOR 3: Combate Clásico
task.spawn(function()
    while true do
        pcall(function()
            local char = player.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local hrp = char.HumanoidRootPart
                
                if getgenv().PixelBladeState.AutoFarm then
                    local bestTarget = nil
                    local minDistance = math.huge
                    
                    for _, root in ipairs(cachedTargets) do
                        if root and root.Parent then
                            local dist = (hrp.Position - root.Position).Magnitude
                            if dist < minDistance then
                                minDistance = dist
                                bestTarget = root
                            end
                        end
                    end
                    
                    if bestTarget then
                        hrp.CFrame = bestTarget.CFrame * CFrame.new(0, 0, 2.5)
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                        task.wait(0.05)
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                    end
                end

                if getgenv().PixelBladeState.AutoNextZone and not isEnemyAlive and cachedPortal then
                    hrp.CFrame = cachedPortal.CFrame
                end
            end
        end)
        task.wait(0.15)
    end
end)
