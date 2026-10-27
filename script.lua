--[[
    Pixel Blade Hub - Inspector Visual en Pantalla
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local player = Players.LocalPlayer

if CoreGui:FindFirstChild("PixelBladeVisualInspector") then
    CoreGui.PixelBladeVisualInspector:Destroy()
end

getgenv().PixelBladeState = {
    InspectMap = false
}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PixelBladeVisualInspector"
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 220, 0, 180)
MainFrame.Position = UDim2.new(0.5, -110, 0.5, -90)
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
Title.Text = "Inspector Visual de Mapa"
Title.TextColor3 = Color3.fromRGB(20, 20, 15)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 14
Title.BackgroundTransparency = 1
Title.Parent = TopBar

-- Etiqueta donde muestra el resultado en la pantallita del HUD
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 40)
StatusLabel.Position = UDim2.new(0, 10, 0, 40)
StatusLabel.Text = "Estado: Inactivo"
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatusLabel.Font = Enum.Font.SourceSans
StatusLabel.TextSize = 11
StatusLabel.TextWrapped = true
StatusLabel.BackgroundColor3 = Color3.fromRGB(60, 60, 55)
StatusLabel.BorderSizePixel = 0
StatusLabel.Parent = MainFrame

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(1, -20, 0, 30)
ToggleBtn.Position = UDim2.new(0, 10, 0, 90)
ToggleBtn.Text = "Escanear Workspace: OFF"
ToggleBtn.TextColor3 = Color3.fromRGB(20, 20, 15)
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.TextSize = 12
ToggleBtn.BackgroundColor3 = Color3.fromRGB(245, 245, 220)
ToggleBtn.BorderSizePixel = 0
ToggleBtn.Parent = MainFrame

ToggleBtn.MouseButton1Click:Connect(function()
    getgenv().PixelBladeState.InspectMap = not getgenv().PixelBladeState.InspectMap
    ToggleBtn.Text = "Escanear Workspace: " .. (getgenv().PixelBladeState.InspectMap and "ON" or "OFF")
    ToggleBtn.BackgroundColor3 = getgenv().PixelBladeState.InspectMap and Color3.fromRGB(180, 220, 180) or Color3.fromRGB(245, 245, 220)
end)

local ExitBtn = Instance.new("TextButton")
ExitBtn.Size = UDim2.new(1, -20, 0, 25)
ExitBtn.Position = UDim2.new(0, 10, 0, 135)
ExitBtn.Text = "Cerrar"
ExitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ExitBtn.Font = Enum.Font.SourceSansBold
ExitBtn.TextSize = 12
ExitBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
ExitBtn.BorderSizePixel = 0
ExitBtn.Parent = MainFrame

ExitBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Loop que lee las carpetas y cambia el texto en el menú flotante
task.spawn(function()
    while true do
        if getgenv().PixelBladeState.InspectMap then
            local foundNames = ""
            for _, child in ipairs(Workspace:GetChildren()) do
                if child:IsA("Folder") or child:IsA("Model") then
                    foundNames = foundNames .. child.Name .. ", "
                end
            end
            if foundNames ~= "" then
                StatusLabel.Text = "Carpetas: " .. foundNames
            else
                StatusLabel.Text = "Estado: No se encontraron carpetas"
            end
        else
            StatusLabel.Text = "Estado: Inactivo"
        end
        task.wait(1)
    end
end)
