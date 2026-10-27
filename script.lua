--[[
    Pixel Blade Hub - Inspector de Rutas (Para ver nombres reales en consola)
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local player = Players.LocalPlayer

if CoreGui:FindFirstChild("PixelBladeFunctionalHub") then
    CoreGui.PixelBladeFunctionalHub:Destroy()
end

getgenv().PixelBladeState = {
    InspectMap = false
}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PixelBladeFunctionalHub"
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 200, 0, 140)
MainFrame.Position = UDim2.new(0.5, -100, 0.5, -70)
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
Title.Text = "Inspector de Rutas"
Title.TextColor3 = Color3.fromRGB(20, 20, 15)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 14
Title.BackgroundTransparency = 1
Title.Parent = TopBar

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(1, -20, 0, 35)
ToggleBtn.Position = UDim2.new(0, 10, 0, 45)
ToggleBtn.Text = "Escanear Mapa: OFF"
ToggleBtn.TextColor3 = Color3.fromRGB(20, 20, 15)
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.TextSize = 12
ToggleBtn.BackgroundColor3 = Color3.fromRGB(245, 245, 220)
ToggleBtn.BorderSizePixel = 0
ToggleBtn.Parent = MainFrame

ToggleBtn.MouseButton1Click:Connect(function()
    getgenv().PixelBladeState.InspectMap = not getgenv().PixelBladeState.InspectMap
    ToggleBtn.Text = "Escanear Mapa: " .. (getgenv().PixelBladeState.InspectMap and "ON" or "OFF")
    ToggleBtn.BackgroundColor3 = getgenv().PixelBladeState.InspectMap and Color3.fromRGB(180, 220, 180) or Color3.fromRGB(245, 245, 220)
end)

local ExitBtn = Instance.new("TextButton")
ExitBtn.Size = UDim2.new(1, -20, 0, 25)
ExitBtn.Position = UDim2.new(0, 10, 0, 95)
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

-- Loop de inspección que escribe en la Delta Console
task.spawn(function()
    while true do
        if getgenv().PixelBladeState.InspectMap then
            print("--- ESCANEANDO HIJOS DEL WORKSPACE ---")
            for _, child in ipairs(Workspace:GetChildren()) do
                print("Nombre: " .. child.Name .. " | Clase: " .. child.ClassName)
            end
            print("---------------------------------------")
        end
        task.wait(3)
    end
end)

print("[Inspector] Script cargado. Activa el botón para ver rutas en la consola.")
