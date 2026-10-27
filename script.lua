--[[
    Pixel Blade Hub - Auto Farm + Auto Cartas + Radar
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local VirtualInputManager = game:GetService("VirtualInputManager")
local player = Players.LocalPlayer

if CoreGui:FindFirstChild("PixelBladeSmartHub") then
    CoreGui.PixelBladeSmartHub:Destroy()
end

getgenv().PixelBladeState = {
    AutoFarm = false,
    AutoCards = true,
    BreakObjects = true
}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PixelBladeSmartHub"
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 240, 0, 260)
MainFrame.Position = UDim2.new(0.5, -120, 0.5, -130)
MainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 30)
TopBar.BackgroundColor3 = Color3.fromRGB(245, 245, 220)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -30, 1, 0)
Title.Text = "Pixel Blade Hub [Smart]"
Title.TextColor3 = Color3.fromRGB(20, 20, 15)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 13
Title.BackgroundTransparency = 1
Title.Parent = TopBar

-- Caja del Radar de Mobs
local RadarBox = Instance.new("TextBox")
RadarBox.Size = UDim2.new(1, -20, 0, 70)
RadarBox.Position = UDim2.new(0, 10, 0, 38)
RadarBox.Text = "Escaneando entidades..."
RadarBox.TextColor3 = Color3.fromRGB(255, 255, 255)
RadarBox.Font = Enum.Font.Code
RadarBox.TextSize = 10
RadarBox.TextWrapped = true
RadarBox.ClearTextOnFocus = false
RadarBox.MultiLine = true
RadarBox.BackgroundColor3 = Color3.fromRGB(50, 50, 45)
RadarBox.BorderSizePixel = 0
RadarBox.Parent = MainFrame

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(1, -20, 0, 30)
ToggleBtn.Position = UDim2.new(0, 10, 0, 115)
ToggleBtn.Text = "Auto-Farm Mobs: OFF"
ToggleBtn.TextColor3 = Color3.fromRGB(20, 20, 15)
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.TextSize = 12
ToggleBtn.BackgroundColor3 = Color3.fromRGB(245, 245, 220)
ToggleBtn.BorderSizePixel = 0
ToggleBtn.Parent = MainFrame

ToggleBtn.MouseButton1Click:Connect(function()
    getgenv().PixelBladeState.AutoFarm = not getgenv().PixelBladeState.AutoFarm
    ToggleBtn.Text = "Auto-Farm Mobs: " .. (getgenv().PixelBladeState.AutoFarm and "ON" or "OFF")
    ToggleBtn.BackgroundColor3 = getgenv().PixelBladeState.AutoFarm and Color3.fromRGB(180, 220, 180) or Color3.fromRGB(245, 245, 220)
end)

local CardBtn = Instance.new("TextButton")
CardBtn.Size = UDim2.new(1, -20, 0, 30)
CardBtn.Position = UDim2.new(0, 10, 0, 150)
CardBtn.Text = "Auto-Cartas (Ventajas): ON"
CardBtn.TextColor3 = Color3.fromRGB(20, 20, 15)
CardBtn.Font = Enum.Font.SourceSansBold
CardBtn.TextSize = 12
CardBtn.BackgroundColor3 = Color3.fromRGB(180, 220, 180)
CardBtn.BorderSizePixel = 0
CardBtn.Parent = MainFrame

CardBtn.MouseButton1Click:Connect(function()
    getgenv().PixelBladeState.AutoCards = not getgenv().PixelBladeState.AutoCards
    CardBtn.Text = "Auto-Cartas (Ventajas): " .. (getgenv().PixelBladeState.AutoCards and "ON" or "OFF")
    CardBtn.BackgroundColor3 = getgenv().PixelBladeState.AutoCards and Color3.fromRGB(180, 220, 180) or Color3.fromRGB(245, 245, 220)
end)

local ChestBtn = Instance.new("TextButton")
ChestBtn.Size = UDim2.new(1, -20, 0, 30)
ChestBtn.Position = UDim2.new(0, 10, 0, 185)
ChestBtn.Text = "Romper Cofres: ON"
ChestBtn.TextColor3 = Color3.fromRGB(20, 20, 15)
ChestBtn.Font = Enum.Font.SourceSansBold
ChestBtn.TextSize = 12
ChestBtn.BackgroundColor3 = Color3.fromRGB(180, 220, 180)
ChestBtn.BorderSizePixel = 0
ChestBtn.Parent = MainFrame

ChestBtn.MouseButton1Click:Connect(function()
    getgenv().PixelBladeState.BreakObjects = not getgenv().PixelBladeState.BreakObjects
    ChestBtn.Text = "Romper Cofres: " .. (getgenv().PixelBladeState.BreakObjects and "ON" or "OFF")
    ChestBtn.BackgroundColor3 = getgenv().PixelBladeState.BreakObjects and Color3.fromRGB(180, 220, 180) or Color3.fromRGB(245, 245, 220)
end)

local ExitBtn = Instance.new("TextButton")
ExitBtn.Size = UDim2.new(1, -20, 0, 25)
ExitBtn.Position = UDim2.new(0, 10, 0, 222)
ExitBtn.Text = "Cerrar Hub"
ExitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ExitBtn.Font = Enum.Font.SourceSansBold
ExitBtn.TextSize = 12
ExitBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
ExitBtn.BorderSizePixel = 0
ExitBtn.Parent = MainFrame

ExitBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Buscador de enemigos y radar
local function getBestTarget()
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    local hrp = char.HumanoidRootPart

    local bestTarget = nil
    local minDistance = math.huge
    local discoveredMobs = ""

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj ~= char then
            local name = obj.Name:lower()
            local humanoid = obj:FindFirstChildOfClass("Humanoid")
            
            if humanoid and humanoid.Health > 0 and name ~= "player" and not name:find("ishiro") and name ~= "tutorial_clyde" then
                discoveredMobs = discoveredMobs .. obj.Name .. "\n"

                -- Enemigos conocidos + los nuevos que vayan saliendo
                local isKnown = name:find("zombie") or name:find("archer") or name:find("mortar") or name:find("ghoul")
                local isChest = getgenv().PixelBladeState.BreakObjects and (name:find("chest") or name:find("crate"))

                if isKnown or isChest then
                    local enemyRoot = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Head") or obj:FindFirstChild("PrimaryPart") or obj:FindFirstChildOfClass("Part")
                    if enemyRoot then
                        local dist = (hrp.Position - enemyRoot.Position).Magnitude
                        if dist < minDistance then
                            minDistance = dist
                            bestTarget = enemyRoot
                        end
                    end
                end
            end
        end
    end

    if discoveredMobs ~= "" then
        RadarBox.Text = "Detectados:\n" .. discoveredMobs
    else
        RadarBox.Text = "Buscando entidades..."
    end

    return bestTarget
end

-- Motor principal (Combate + Auto Cartas)
task.spawn(function()
    while true do
        pcall(function
            -- 1. Auto-Cartas (Busca botones de elegir ventaja en pantalla)
            if getgenv().PixelBladeState.AutoCards then
                for _, gui in ipairs(player.PlayerGui:GetDescendants()) do
                    if gui:IsA("TextButton") and (gui.Text:lower():find("elegir") or gui.Text:lower():find("select")) then
                        -- Simula clic en la ventaja para seleccionarla al instante
                        local vim = VirtualInputManager
                        -- Dispara evento de clic táctil o de mouse directo en la posición del botón
                        local absPos = gui.AbsolutePosition
                        local absSize = gui.AbsoluteSize
                        vim:SendMouseButtonEvent(absPos.X + absSize.X/2, absPos.Y + absSize.Y/2, 0, true, game, 1)
                        task.wait(0.05)
                        vim:SendMouseButtonEvent(absPos.X + absSize.X/2, absPos.Y + absSize.Y/2, 0, false, game, 1)
                        task.wait(1)
                    end
                end
            end

            -- 2. Auto-Farm de Mobs
            if getgenv().PixelBladeState.AutoFarm then
                local char = player.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    local hrp = char.HumanoidRootPart
                    local target = getBestTarget()
                    
                    if target then
                        hrp.CFrame = target.CFrame * CFrame.new(0, 0, 2.5)
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                        task.wait(0.05)
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                    end
                end
            end
        end)
        task.wait(0.2)
    end
end)
