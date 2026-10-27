--[[
    Pixel Blade Hub - Versión con Minimizar y Cerrar
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
MainFrame.Size = UDim2.new(0, 240, 0, 270)
MainFrame.Position = UDim2.new(0.5, -120, 0.5, -135)
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
Title.Size = UDim2.new(1, -60, 1, 0)
Title.Position = UDim2.new(0, 5, 0, 0)
Title.Text = "Pixel Blade Hub"
Title.TextColor3 = Color3.fromRGB(20, 20, 15)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 13
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

-- Botón para Minimizar / Contraer a cuadrito pequeño (- / +)
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

-- Botón para Cerrar por completo (X)
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

-- Contenedor de los elementos internos para ocultarlos al minimizar
local ContentContainer = Instance.new("Folder")
ContentContainer.Name = "ContentContainer"
ContentContainer.Parent = MainFrame

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
RadarBox.Parent = ContentContainer

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(1, -20, 0, 30)
ToggleBtn.Position = UDim2.new(0, 10, 0, 115)
ToggleBtn.Text = "Auto-Farm Mobs: OFF"
ToggleBtn.TextColor3 = Color3.fromRGB(20, 20, 15)
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.TextSize = 12
ToggleBtn.BackgroundColor3 = Color3.fromRGB(245, 245, 220)
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
CardBtn.Text = "Auto-Cartas (Ventajas): ON"
CardBtn.TextColor3 = Color3.fromRGB(20, 20, 15)
CardBtn.Font = Enum.Font.SourceSansBold
CardBtn.TextSize = 12
CardBtn.BackgroundColor3 = Color3.fromRGB(180, 220, 180)
CardBtn.BorderSizePixel = 0
CardBtn.Parent = ContentContainer

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
ChestBtn.Parent = ContentContainer

ChestBtn.MouseButton1Click:Connect(function()
    getgenv().PixelBladeState.BreakObjects = not getgenv().PixelBladeState.BreakObjects
    ChestBtn.Text = "Romper Cofres: " .. (getgenv().PixelBladeState.BreakObjects and "ON" or "OFF")
    ChestBtn.BackgroundColor3 = getgenv().PixelBladeState.BreakObjects and Color3.fromRGB(180, 220, 180) or Color3.fromRGB(245, 245, 220)
end)

-- Botón para cerrar completo dentro del menú
local ExitBtn = Instance.new("TextButton")
ExitBtn.Size = UDim2.new(1, -20, 0, 25)
ExitBtn.Position = UDim2.new(0, 10, 0, 225)
ExitBtn.Text = "Cerrar Hub por completo"
ExitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ExitBtn.Font = Enum.Font.SourceSansBold
ExitBtn.TextSize = 11
ExitBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
ExitBtn.BorderSizePixel = 0
ExitBtn.Parent = ContentContainer

-- Lógica del botón Minimizar (-)
MinimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        MainFrame.Size = UDim2.new(0, 240, 0, 30)
        MinimizeBtn.Text = "+"
        for _, obj in ipairs(ContentContainer:GetChildren()) do
            if obj:IsA("GuiObject") then obj.Visible = false end
        end
    else
        MainFrame.Size = UDim2.new(0, 240, 0, 270)
        MinimizeBtn.Text = "-"
        for _, obj in ipairs(ContentContainer:GetChildren()) do
            if obj:IsA("GuiObject") then obj.Visible = true end
        end
    end
end)

-- Lógica de cierre total (X y botón inferior)
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

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
        pcall(function()
            if getgenv().PixelBladeState.AutoCards then
                for _, gui in ipairs(player.PlayerGui:GetDescendants()) do
                    if gui:IsA("TextButton") and (gui.Text:lower():find("elegir") or gui.Text:lower():find("select")) then
                        local vim = VirtualInputManager
                        local absPos = gui.AbsolutePosition
                        local absSize = gui.AbsoluteSize
                        vim:SendMouseButtonEvent(absPos.X + absSize.X/2, absPos.Y + absSize.Y/2, 0, true, game, 1)
                        task.wait(0.05)
                        vim:SendMouseButtonEvent(absPos.X + absSize.X/2, absPos.Y + absSize.Y/2, 0, false, game, 1)
                        task.wait(1)
                    end
                end
            end

            if getgenv().PixelBladeState.AutoFarm then
                local char = player.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    local hrp = char.HumanoidRootPart
                    local target = getBestTarget()
                    
                    if target then
                        hrp.CFrame = target.CFrame * CFrame.new(0, 0, 2.5)
