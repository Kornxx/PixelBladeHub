--[[
    Pixel Blade Hub - Debugging & Working Motors
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local VirtualInputManager = game:GetService("VirtualInputManager")
local player = Players.LocalPlayer

if CoreGui:FindFirstChild("PixelBladeFunctionalHub") then
    CoreGui.PixelBladeFunctionalHub:Destroy()
end

getgenv().PixelBladeState = {
    AutoDungeon = false,
    AutoRaid = false,
    AutoFishing = false
}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PixelBladeFunctionalHub"
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 200, 0, 210)
MainFrame.Position = UDim2.new(0.5, -100, 0.5, -105)
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
Title.Text = "Pixel Blade Hub [Debug]"
Title.TextColor3 = Color3.fromRGB(20, 20, 15)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 14
Title.BackgroundTransparency = 1
Title.Parent = TopBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 1, 0)
CloseBtn.Position = UDim2.new(1, -30, 0, 0)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(20, 20, 15)
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 14
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 200, 180)
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = TopBar

local function CreateToggleButton(name, stateKey, positionY)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 35)
    btn.Position = UDim2.new(0, 10, 0, positionY)
    btn.Text = name .. ": OFF"
    btn.TextColor3 = Color3.fromRGB(20, 20, 15)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 13
    btn.BackgroundColor3 = Color3.fromRGB(245, 245, 220)
    btn.BorderSizePixel = 0
    btn.Parent = MainFrame

    btn.MouseButton1Click:Connect(function()
        getgenv().PixelBladeState[stateKey] = not getgenv().PixelBladeState[stateKey]
        if getgenv().PixelBladeState[stateKey] then
            btn.Text = name .. ": ON"
            btn.BackgroundColor3 = Color3.fromRGB(180, 220, 180)
        else
            btn.Text = name .. ": OFF"
            btn.BackgroundColor3 = Color3.fromRGB(245, 245, 220)
        end
    end)
end

CreateToggleButton("Auto Dungeon", "AutoDungeon", 45)
CreateToggleButton("Auto Raid", "AutoRaid", 90)
CreateToggleButton("Auto Fishing", "AutoFishing", 135)

local ExitBtn = Instance.new("TextButton")
ExitBtn.Size = UDim2.new(1, -20, 0, 25)
ExitBtn.Position = UDim2.new(0, 10, 0, 175)
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

-- Buscador Inteligente con impresión en consola de Delta
local function getNearestEnemy()
    local nearest = nil
    local shortestDist = math.huge
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    local hrp = char.HumanoidRootPart

    -- Escaneamos todo el Workspace para encontrar qué carpeta contiene a los monstruos vivos
    for _, folder in ipairs(Workspace:GetChildren()) do
        if folder:IsA("Folder") or folder:IsA("Model") then
            for _, enemy in ipairs(folder:GetChildren()) do
                local enemyRoot = enemy:FindFirstChild("HumanoidRootPart") or enemy:FindFirstChild("Head") or enemy:FindFirstChild("RootPart")
                local hum = enemy:FindFirstChildOfClass("Humanoid")
                if enemyRoot and hum and hum.Health > 0 and enemy ~= char then
                    local dist = (hrp.Position - enemyRoot.Position).Magnitude
                    if dist < shortestDist then
                        shortestDist = dist
                        nearest = enemyRoot
                    end
                end
            end
        end
    end
    return nearest
end

task.spawn(function()
    while true do
        pcall(function()
            local char = player.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then return end
            local hrp = char.HumanoidRootPart

            if getgenv().PixelBladeState.AutoDungeon or getgenv().PixelBladeState.AutoRaid then
                local target = getNearestEnemy()
                if target then
                    print("[Pixel Blade] ¡Enemigo detectado! Teletransportando...")
                    hrp.CFrame = target.CFrame * CFrame.new(0, 0, 3)
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                    task.wait(0.05)
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                end
            end

            if getgenv().PixelBladeState.AutoFishing then
                VirtualInputManager:SendMouseButtonEvent(200, 200, 0, true, game, 1)
                task.wait(0.1)
                VirtualInputManager:SendMouseButtonEvent(200, 200, 0, false, game, 1)
                task.wait(1.5)
            end
        end)
        task.wait(0.2)
    end
end)

print("[Pixel Blade] Hub actualizado con buscador universal de entidades.")
