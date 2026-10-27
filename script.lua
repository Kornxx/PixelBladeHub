--[[
    Pixel Blade Hub - Inspector Visual Corregido y Amplio
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
MainFrame.Size = UDim2.new(0, 260, 0, 240)
MainFrame.Position = UDim2.new(0.5, -130, 0.5, -120)
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
Title.Text = "Inspector de Rutas [Fix]"
Title.TextColor3 = Color3.fromRGB(20, 20, 15)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 14
Title.BackgroundTransparency = 1
Title.Parent = TopBar

-- Caja de texto grande y visible para los nombres de las carpetas
local StatusBox = Instance.new("TextBox")
StatusBox.Size = UDim2.new(1, -20, 0, 90)
StatusBox.Position = UDim2.new(0, 10, 0, 40)
StatusBox.Text = "Presiona 'Escanear' para ver las carpetas aquí..."
StatusBox.TextColor3 = Color3.fromRGB(255, 255, 255)
StatusBox.Font = Enum.Font.Code
StatusBox.TextSize = 11
StatusBox.TextWrapped = true
StatusBox.ClearTextOnFocus = false
StatusBox.MultiLine = true
StatusBox.BackgroundColor3 = Color3.fromRGB(50, 50, 45)
StatusBox.BorderSizePixel = 0
StatusBox.Parent = MainFrame

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(1, -20, 0, 35)
ToggleBtn.Position = UDim2.new(0, 10, 0, 140)
ToggleBtn.Text = "Escanear Mapa: OFF"
ToggleBtn.TextColor3 = Color3.fromRGB(20, 20, 15)
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.TextSize = 13
ToggleBtn.BackgroundColor3 = Color3.fromRGB(245, 245, 220)
ToggleBtn.BorderSizePixel = 0
ToggleBtn.Parent = MainFrame

ToggleBtn.MouseButton1Click:Connect(function()
    getgenv().PixelBladeState.InspectMap = not getgenv().PixelBladeState.InspectMap
    ToggleBtn.Text = "Escanear Mapa: " .. (getgenv().PixelBladeState.InspectMap and "ON" or "OFF")
    ToggleBtn.BackgroundColor3 = getgenv().PixelBladeState.InspectMap and Color3.fromRGB(180, 220, 180) or Color3.fromRGB(245, 245, 220)
end)

local ExitBtn = Instance.new("TextButton")
ExitBtn.Size = UDim2.new(1, -20, 0, 30)
ExitBtn.Position = UDim2.new(0, 10, 0, 185)
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

-- Loop que escanea y escribe los nombres dentro de la caja de texto
task.spawn(function()
    while true do
        if getgenv().PixelBladeState.InspectMap then
            local foundNames = ""
            for _, child in ipairs(Workspace:GetChildren()) do
                if child:IsA("Folder") or child:IsA("Model") then
                    foundNames = foundNames .. child.Name .. " (" .. child.ClassName .. ")\n"
                end
            end
            if foundNames ~= "" then
                StatusBox.Text = foundNames
            else
                StatusBox.Text = "No se encontraron carpetas o modelos."
            end
        else
            StatusBox.Text = "Inactivo. Activa el escáner."
        end
        task.wait(1)
    end
end)
