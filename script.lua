--[[
    Pixel Blade Hub - Auto Farm + Radar Dinámico de Nuevos Mobs
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local VirtualInputManager = game:GetService("VirtualInputManager")
local player = Players.LocalPlayer

if CoreGui:FindFirstChild("PixelBladeDynamicHub") then
    CoreGui.PixelBladeDynamicHub:Destroy()
end

getgenv().PixelBladeState = {
    AutoFarm = false,
    BreakObjects = true
}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PixelBladeDynamicHub"
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
Title.Text = "Pixel Blade Hub [Radar + Farm]"
Title.TextColor3 = Color3.fromRGB(20, 20, 15)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 13
Title.BackgroundTransparency = 1
Title.Parent = TopBar

-- Caja de texto para ver en vivo los enemigos que va descubriendo
local RadarBox = Instance.new("TextBox")
RadarBox.Size = UDim2.new(1, -20, 0, 80)
RadarBox.Position = UDim2.new(0, 10, 0, 38)
RadarBox.Text = "Esperando enemigos nuevos..."
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
ToggleBtn.Size = UDim2.new(1, -20, 0, 35)
ToggleBtn.Position = UDim2.new(0, 10, 0, 125)
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

local ChestBtn = Instance.new("TextButton")
ChestBtn.Size = UDim2.new(1, -20, 0, 35)
ChestBtn.Position = UDim2.new(0, 10, 0, 168)
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
ExitBtn.Size = UDim2.new(1, -20, 0, 30)
ExitBtn.Position = UDim2.new(0, 10, 0, 215)
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

-- Buscador inteligente que ataca conocidos y detecta todo lo demás para el radar
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
            
            -- Si tiene vida, es una entidad de combate potencial
            if humanoid and humanoid.Health > 0 and name ~= "player" and not name:find("ishiro") then
                discoveredMobs = discoveredMobs .. obj.Name .. "\n"

                -- Ataca si coincide con conocidos o si tiene barra de vida activa en combate
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

    -- Actualiza el cuadro de texto del radar con los mobs que vaya encontrando
    if discoveredMobs ~= "" then
        RadarBox.Text = "Detectados:\n" .. discoveredMobs
    else
        RadarBox.Text = "Buscando entidades..."
    end

    return bestTarget
end

-- Motor de ataque continuo
task.spawn(function()
    while true do
        pcall(function()
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
        task.wait(0.15)
    end
end)
