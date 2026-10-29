--[[
    Shiro Hub [v3.9.1] - Raids Fix, Anti-Duplicados, Separación de Mundos y Guardado
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local player = Players.LocalPlayer

-- ==========================================
-- CONTROL DE EJECUCIONES (evita loops duplicados si ejecutas 2 veces)
-- ==========================================
local genv = getgenv()
genv.ShiroRunId = (genv.ShiroRunId or 0) + 1
local RUN_ID = genv.ShiroRunId
local function alive() return genv.ShiroRunId == RUN_ID end

if genv.ShiroConns then
    for _, c in ipairs(genv.ShiroConns) do pcall(function() c:Disconnect() end) end
end
genv.ShiroConns = {}
local function track(conn) table.insert(genv.ShiroConns, conn) return conn end

-- Limpieza de HUDs duplicados
local function getGuiParent()
    local ok, res = pcall(function() return gethui and gethui() end)
    if ok and res then return res end
    return CoreGui
end
local guiParent = getGuiParent()
for _, parent in ipairs({CoreGui, guiParent}) do
    pcall(function()
        for _, gui in ipairs(parent:GetChildren()) do
            if gui.Name == "ShiroSmartHub" then gui:Destroy() end
        end
    end)
end

-- ==========================================
-- ESTADO + GUARDADO (sobrevive a teleports/reinicios)
-- ==========================================
local SAVE_FILE = "ShiroHub_PixelBlade.json"

local State = {
    Tab = 1,
    Dungeon = {
        AutoFarm = true, AutoCards = true, AutoUlti = true,
        BreakObjects = false, AutoNextZone = true, AutoContinue = true
    },
    Raid = {
        AutoFarm = true, AutoCards = true, AutoUlti = true,
        AutoTree = true, AutoContinue = true
    }
}

pcall(function()
    if isfile and readfile and isfile(SAVE_FILE) then
        local data = HttpService:JSONDecode(readfile(SAVE_FILE))
        if type(data) == "table" then
            if data.Tab == 1 or data.Tab == 2 then State.Tab = data.Tab end
            for _, cat in ipairs({"Dungeon", "Raid"}) do
                if type(data[cat]) == "table" then
                    for k, v in pairs(data[cat]) do
                        if State[cat][k] ~= nil and type(v) == "boolean" then
                            State[cat][k] = v
                        end
                    end
                end
            end
        end
    end
end)

local function saveState()
    pcall(function()
        if writefile then writefile(SAVE_FILE, HttpService:JSONEncode(State)) end
    end)
end

genv.ShiroHubState = State

local function getConfig()
    return (State.Tab == 1) and State.Dungeon or State.Raid
end

pcall(function()
    if queue_on_teleport then
        queue_on_teleport([[
            task.wait(3)
            loadstring(game:HttpGet("https://raw.githubusercontent.com/Kornxx/PixelBladeHub/refs/heads/main/script.lua?t=" .. tostring(tick())))()
        ]])
    end
end)

-- Ignorar por coincidencia de texto parcial
local ignoreSubstr = {
    "necromancer", "tutorial_clyde", "summon", "familiar",
    "dummy", "statue", "decora"
}
-- Ignorar solo como PALABRA completa
local ignoreWords = {
    "ally", "pet", "npc", "locked", "key", "black"
}

local function isIgnoredName(name)
    for _, s in ipairs(ignoreSubstr) do
        if name:find(s, 1, true) then return true end
    end
    for _, w in ipairs(ignoreWords) do
        if name:find("%f[%a]" .. w .. "%f[%A]") then return true end
    end
    return false
end

-- ==========================================
-- GESTOR DE MEMORIA Y CACHÉ (SEPARACIÓN DE MUNDOS)
-- ==========================================
local WorldCache = {
    Mobs = {},
    Spawns = {},
    Portal = nil
}
local pending = {}
local blacklist = {}
local homeSpawn = nil
local currentTarget, targetSince, targetLastHealth = nil, 0, 0

-- Función vital: Purga la memoria al cambiar de mundo o pestaña
local function clearCache()
    WorldCache.Mobs = {}
    WorldCache.Spawns = {}
    WorldCache.Portal = nil
    pending = {}
    blacklist = {}
    currentTarget = nil
    homeSpawn = nil
end

local safeToFarm = false
task.spawn(function()
    task.wait(4)
    if alive() then safeToFarm = true end
end)
track(player.CharacterAdded:Connect(function()
    safeToFarm = false
    clearCache() -- Limpia la memoria vieja al teletransportarse
    task.wait(4)
    if alive() then safeToFarm = true end
end))

-- ==========================================
-- INTERFAZ GRÁFICA (HUD)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ShiroSmartHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = guiParent

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, 35)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -155)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 35)
TopBar.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -70, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.Text = "Shiro Hub [v3.9.1]"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 25, 0, 25)
MinimizeBtn.Position = UDim2.new(1, -60, 0, 5)
MinimizeBtn.Text = "+"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 16
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
MinimizeBtn.Parent = TopBar
Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0, 6)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.Position = UDim2.new(1, -30, 0, 5)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 12
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Parent = TopBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, -20, 0, 30)
TabBar.Position = UDim2.new(0, 10, 0, 45)
TabBar.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
TabBar.Visible = false
TabBar.Parent = MainFrame
Instance.new("UICorner", TabBar).CornerRadius = UDim.new(0, 6)

local TabDungeonBtn = Instance.new("TextButton")
TabDungeonBtn.Size = UDim2.new(0.5, 0, 1, 0)
TabDungeonBtn.Text = "DUNGEON"
TabDungeonBtn.Font = Enum.Font.GothamBold
TabDungeonBtn.TextSize = 11
TabDungeonBtn.BackgroundColor3 = Color3.fromRGB(70, 110, 190)
TabDungeonBtn.Parent = TabBar
Instance.new("UICorner", TabDungeonBtn).CornerRadius = UDim.new(0, 6)

local TabRaidBtn = Instance.new("TextButton")
TabRaidBtn.Size = UDim2.new(0.5, 0, 1, 0)
TabRaidBtn.Position = UDim2.new(0.5, 0, 0, 0)
TabRaidBtn.Text = "RAIDS"
TabRaidBtn.Font = Enum.Font.GothamBold
TabRaidBtn.TextSize = 11
TabRaidBtn.BackgroundColor3 = Color3.fromRGB(150, 90, 190)
TabRaidBtn.Parent = TabBar
Instance.new("UICorner", TabRaidBtn).CornerRadius = UDim.new(0, 6)

local DungeonTab = Instance.new("Frame")
DungeonTab.Size = UDim2.new(1, 0, 1, -85)
DungeonTab.Position = UDim2.new(0, 0, 0, 85)
DungeonTab.BackgroundTransparency = 1
DungeonTab.Visible = false
DungeonTab.Parent = MainFrame

local RaidTab = Instance.new("Frame")
RaidTab.Size = UDim2.new(1, 0, 1, -85)
RaidTab.Position = UDim2.new(0, 0, 0, 85)
RaidTab.BackgroundTransparency = 1
RaidTab.Visible = false
RaidTab.Parent = MainFrame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 18)
StatusLabel.Position = UDim2.new(0, 10, 0, 295)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "..."
StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 10
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Visible = false
StatusLabel.Parent = MainFrame

local colorOn = Color3.fromRGB(70, 170, 110)
local colorOff = Color3.fromRGB(40, 40, 45)
local raidColorOn = Color3.fromRGB(150, 90, 190)

local function createTabButton(parent, text, yPos, category, stateKey, activeColor)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 28)
    btn.Position = UDim2.new(0, 10, 0, yPos)
    btn.Text = text .. ": " .. (State[category][stateKey] and "ON" or "OFF")
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 11
    btn.BackgroundColor3 = State[category][stateKey] and activeColor or colorOff
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    btn.MouseButton1Click:Connect(function()
        State[category][stateKey] = not State[category][stateKey]
        btn.Text = text .. ": " .. (State[category][stateKey] and "ON" or "OFF")
        btn.BackgroundColor3 = State[category][stateKey] and activeColor or colorOff
        saveState()
    end)
    return btn
end

createTabButton(DungeonTab, "Auto-Farm Universal", 0, "Dungeon", "AutoFarm", colorOn)
createTabButton(DungeonTab, "Auto-Cartas", 35, "Dungeon", "AutoCards", colorOn)
createTabButton(DungeonTab, "Auto-Habilidades (No Dash)", 70, "Dungeon", "AutoUlti", colorOn)
createTabButton(DungeonTab, "Romper Cofres", 105, "Dungeon", "BreakObjects", colorOn)
createTabButton(DungeonTab, "Auto-Avanzar Portales", 140, "Dungeon", "AutoNextZone", colorOn)
createTabButton(DungeonTab, "Auto-Seguir Partida", 175, "Dungeon", "AutoContinue", colorOn)

createTabButton(RaidTab, "Auto-Farm Universal", 0, "Raid", "AutoFarm", raidColorOn)
createTabButton(RaidTab, "Auto-Cartas", 35, "Raid", "AutoCards", raidColorOn)
createTabButton(RaidTab, "Auto-Habilidades (No Dash)", 70, "Raid", "AutoUlti", raidColorOn)
createTabButton(RaidTab, "Proteger Spawn (Raid)", 105, "Raid", "AutoTree", raidColorOn)
createTabButton(RaidTab, "Auto-Seguir Partida", 140, "Raid", "AutoContinue", raidColorOn)

local isMinimized = true
local function applyTab()
    local isDungeon = (State.Tab == 1)
    DungeonTab.Visible = (not isMinimized) and isDungeon
    RaidTab.Visible = (not isMinimized) and (not isDungeon)
    TabDungeonBtn.BackgroundTransparency = isDungeon and 0 or 1
    TabDungeonBtn.TextColor3 = isDungeon and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150)
    TabRaidBtn.BackgroundTransparency = isDungeon and 1 or 0
    TabRaidBtn.TextColor3 = isDungeon and Color3.fromRGB(150, 150, 150) or Color3.fromRGB(255, 255, 255)
end
applyTab()

TabDungeonBtn.MouseButton1Click:Connect(function()
    if State.Tab ~= 1 then
        State.Tab = 1
        clearCache() -- Limpia caché al cambiar de pestaña
    end
    applyTab()
    saveState()
end)

TabRaidBtn.MouseButton1Click:Connect(function()
    if State.Tab ~= 2 then
        State.Tab = 2
        clearCache() -- Limpia caché al cambiar de pestaña
    end
    applyTab()
    saveState()
end)

MinimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        MainFrame.Size = UDim2.new(0, 250, 0, 35)
        TabBar.Visible = false
        StatusLabel.Visible = false
        MinimizeBtn.Text = "+"
    else
        MainFrame.Size = UDim2.new(0, 250, 0, 320)
        TabBar.Visible = true
        StatusLabel.Visible = true
        MinimizeBtn.Text = "-"
    end
    applyTab()
end)

CloseBtn.MouseButton1Click:Connect(function()
    genv.ShiroRunId = (genv.ShiroRunId or 0) + 1 -- mata todos los loops
    ScreenGui:Destroy()
end)

-- ==========================================
-- REGISTRO DE OBJETOS AL CACHÉ
-- ==========================================
local function classifyModel(obj)
    if not obj or not obj.Parent then return true end
    if obj == player.Character then return true end
    if Players:GetPlayerFromCharacter(obj) then return true end -- Ignora jugadores reales

    local hum = obj:FindFirstChildOfClass("Humanoid")
    if not hum then return false end
    if hum.MaxHealth <= 5 then return true end
    if hum.Health <= 0 then return true end

    local root = obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart
    if not (root and root:IsA("BasePart")) then return false end

    if isIgnoredName(obj.Name:lower()) then return true end
    if obj:FindFirstChildWhichIsA("ProximityPrompt", true) then return true end
    if obj:FindFirstChildWhichIsA("Dialog", true) then return true end

    WorldCache.Mobs[obj] = {Root = root, Humanoid = hum}
    return true
end

local function tryRegister(model)
    if WorldCache.Mobs[model] or pending[model] then return end
    pending[model] = true
    task.spawn(function()
        for _ = 1, 12 do
            if not alive() or not model.Parent then break end
            local ok, done = pcall(classifyModel, model)
            if ok and done then break end
            task.wait(0.5)
        end
        pending[model] = nil
    end)
end

local function classifyPart(obj)
    pcall(function()
        if not obj or not obj.Parent then return end
        local name = obj.Name:lower()

        if name == "spawn" then
            WorldCache.Spawns[obj] = true
        elseif name:find("portal") or name:find("exit_door") or name:find("door") then
            WorldCache.Portal = obj
        end

        if name:find("chest") and not (name:find("black") or name:find("locked") or name:find("key")) then
            WorldCache.Mobs[obj] = {Root = obj, Humanoid = {Health = 1}, IsChest = true}
        end
    end)
end

local function scanInstance(obj)
    if obj:IsA("Humanoid") then
        local m = obj.Parent
        if m and m:IsA("Model") and not WorldCache.Mobs[m] then tryRegister(m) end
    elseif obj:IsA("BasePart") then
        classifyPart(obj)
    end
end

track(Workspace.DescendantAdded:Connect(function(obj)
    if not alive() then return end
    if obj:IsA("Humanoid") then
        task.defer(function() scanInstance(obj) end)
    elseif obj:IsA("BasePart") then
        task.delay(0.3, function() classifyPart(obj) end)
    end
end))

-- Escaneo inicial + re-escaneo periódico
local function fullScan()
    for i, obj in ipairs(Workspace:GetDescendants()) do
        if not alive() then return end
        scanInstance(obj)
        if i % 400 == 0 then task.wait() end
    end
end

task.spawn(function()
    while alive() do
        pcall(fullScan)
        task.wait(6)
    end
end)

-- ==========================================
-- MOTOR 2: AUTO-BOTONES DE UI
-- ==========================================
local function isGuiVisible(gui)
    local cur = gui
    while cur and cur ~= player.PlayerGui do
        if cur:IsA("GuiObject") and not cur.Visible then return false end
        if cur:IsA("ScreenGui") and not cur.Enabled then return false end
        cur = cur.Parent
    end
    return true
end

local function fireButtonClick(gui)
    local absPos = gui.AbsolutePosition
    local absSize = gui.AbsoluteSize
    if absPos.X > 0 and absSize.X > 0 then
        pcall(function()
            for _, conn in ipairs(getconnections(gui.MouseButton1Click)) do conn:Fire() end
            for _, conn in ipairs(getconnections(gui.Activated)) do conn:Fire() end
        end)
        VirtualInputManager:SendMouseButtonEvent(absPos.X + absSize.X/2, absPos.Y + absSize.Y/2, 0, true, game, 1)
        task.wait(0.05)
        VirtualInputManager:SendMouseButtonEvent(absPos.X + absSize.X/2, absPos.Y + absSize.Y/2, 0, false, game, 1)
    end
end

local continueWords = {"repetir", "replay", "seguir", "continuar", "next", "retry"}
local excludeWords = {"salir", "lobby", "exit", "leave", "quit"}
local function matchAny(text, list)
    for _, w in ipairs(list) do
        if text:find(w, 1, true) then return true end
    end
    return false
end

task.spawn(function()
    while alive() do
        pcall(function()
            if not safeToFarm then return end
            local cfg = getConfig()
            if not (cfg.AutoContinue or cfg.AutoCards) then return end

            local continueBtn = nil
            local cards = {}

            for _, gui in ipairs(player.PlayerGui:GetDescendants()) do
                if (gui:IsA("TextButton") or gui:IsA("ImageButton")) and isGuiVisible(gui) then
                    if cfg.AutoContinue and not continueBtn then
                        local combined = gui.Name:lower()
                        if gui:IsA("TextButton") then combined = combined .. " " .. gui.Text:lower() end
                        for _, desc in ipairs(gui:GetDescendants()) do
                            if desc:IsA("TextLabel") or desc:IsA("TextBox") then
                                combined = combined .. " " .. desc.Text:lower()
                            end
                        end
                        if matchAny(combined, continueWords) and not matchAny(combined, excludeWords) then
                            continueBtn = gui
                        end
                    end

                    if cfg.AutoCards and gui:IsA("TextButton") then
                        local btnText = gui.Text:lower()
                        local btnName = gui.Name:lower()
                        if btnText:find("elegir") or btnText:find("choose") or btnText:find("select")
                           or btnName:find("card") or btnName:find("carta") then
                            table.insert(cards, gui)
                        end
                    end
                end
            end

            if continueBtn then
                fireButtonClick(continueBtn)
                task.wait(0.8)
            end
            if #cards > 0 then
                fireButtonClick(cards[math.random(1, #cards)])
                task.wait(0.8)
            end
        end)
        task.wait(0.4)
    end
end)

-- ==========================================
-- MOTOR 3: COMBATE SEGURO Y EFICIENTE
-- ==========================================
local TARGET_TIMEOUT = 15
local BLACKLIST_TIME = 25
local lastTreeAction = 0
local statusText = "..."

local function isPurple(part)
    local c = part.Color
    return c.R > c.G + 0.08 and c.B > c.G + 0.08
end

local function pickHomeSpawn(refPos)
    if homeSpawn and homeSpawn.Parent then return homeSpawn end
    homeSpawn = nil
    local best, bestD, bestPurple = nil, math.huge, false
    for obj in pairs(WorldCache.Spawns) do
        if obj.Parent then
            local p = isPurple(obj)
            local d = (refPos - obj.Position).Magnitude
            if (p and not bestPurple) or (p == bestPurple and d < bestD) then
                best, bestD, bestPurple = obj, d, p
            end
        else
            WorldCache.Spawns[obj] = nil
        end
    end
    homeSpawn = best
    return best
end

local function interactSpawn(hrp, spawnPart)
    local now = os.clock()
    if now - lastTreeAction < 1 then return end
    lastTreeAction = now

    local prompt = spawnPart:FindFirstChildWhichIsA("ProximityPrompt", true)
    if not prompt and spawnPart.Parent and spawnPart.Parent ~= Workspace then
        for _, d in ipairs(spawnPart.Parent:GetDescendants()) do
            if d:IsA("ProximityPrompt") and d.Parent and d.Parent:IsA("BasePart")
               and (d.Parent.Position - spawnPart.Position).Magnitude < 15 then
                prompt = d
                break
            end
        end
    end

    if prompt and fireproximityprompt then
        pcall(fireproximityprompt, prompt)
    else
        local hold = (prompt and prompt.HoldDuration or 0) + 0.1
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        task.wait(math.max(hold, 0.05))
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
    end
end

task.spawn(function()
    while alive() do
        pcall(function()
            if not safeToFarm then return end
            local cfg = getConfig()

            local char = player.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp or (hum and hum.Health <= 0) then return end

            local hrpPos = hrp.Position
            local now = os.clock()
            local isRaid = (State.Tab == 2)

            local spawnPart = nil
            if isRaid then spawnPart = pickHomeSpawn(hrpPos) end

            local bestObj, bestData, minDistance = nil, nil, math.huge

            if cfg.AutoFarm then
                for obj, data in pairs(WorldCache.Mobs) do
                    local root = data.Root
                    if not obj.Parent or not root or not root.Parent then
                        WorldCache.Mobs[obj] = nil
                    elseif not data.IsChest and data.Humanoid.Health <= 0 then
                        WorldCache.Mobs[obj] = nil
                    elseif root.Position.Y < -50 then
                        WorldCache.Mobs[obj] = nil
                    else
                        local skip = false
                        if blacklist[obj] and blacklist[obj] > now then skip = true end
                        if data.IsChest and (isRaid or not State.Dungeon.BreakObjects) then skip = true end
                        if not data.IsChest and root.Anchored then skip = true end

                        if not skip then
                            local dist
                            if isRaid and cfg.AutoTree and spawnPart then
                                dist = (spawnPart.Position - root.Position).Magnitude
                            else
                                dist = (hrpPos - root.Position).Magnitude
                            end
                            if dist < minDistance then
                                minDistance = dist
                                bestObj, bestData = obj, data
                            end
                        end
                    end
                end
            end

            if WorldCache.Portal and not WorldCache.Portal.Parent then WorldCache.Portal = nil end

            if bestObj then
                local h = bestData.IsChest and 1 or bestData.Humanoid.Health
                if bestObj ~= currentTarget then
                    currentTarget, targetSince, targetLastHealth = bestObj, now, h
                end
                if h < targetLastHealth - 0.01 then
                    targetSince, targetLastHealth = now, h
                end
                if now - targetSince > TARGET_TIMEOUT then
                    blacklist[bestObj] = now + BLACKLIST_TIME
                    currentTarget = nil
                    return
                end

                local target = bestData.Root
                local targetPos = target.Position
                local distToPlayer = (hrpPos - targetPos).Magnitude
                statusText = "Atacando: " .. bestObj.Name

                if distToPlayer > 5 then
                    local offsetDir = Vector3.new(hrpPos.X - targetPos.X, 0, hrpPos.Z - targetPos.Z)
                    if offsetDir.Magnitude < 0.1 then
                        offsetDir = Vector3.new(0, 0, 1)
                    else
                        offsetDir = offsetDir.Unit
                    end
                    local safePos = targetPos + (offsetDir * 3) + Vector3.new(0, 3.5, 0)
                    hrp.CFrame = CFrame.new(safePos, Vector3.new(targetPos.X, safePos.Y, targetPos.Z))
                else
                    hrp.CFrame = CFrame.new(hrpPos, Vector3.new(targetPos.X, hrpPos.Y, targetPos.Z))
                end

                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                task.wait(0.05)
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)

                if cfg.AutoUlti then
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.R, false, game)
                    task.wait(0.03)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.R, false, game)
                end
            else
                currentTarget = nil
                if not isRaid then
                    statusText = "Sin enemigos (Dungeon)"
                    if cfg.AutoNextZone and WorldCache.Portal then
                        if (hrpPos - WorldCache.Portal.Position).Magnitude > 4 then
                            hrp.CFrame = CFrame.new(WorldCache.Portal.Position + Vector3.new(0, 3, 0))
                        end
                    end
                else
                    if cfg.AutoTree and spawnPart then
                        statusText = "Protegiendo spawn"
                        local spawnPos = spawnPart.Position
                        if (hrpPos - spawnPos).Magnitude > 3 then
                            hrp.CFrame = CFrame.new(spawnPos + Vector3.new(0, 3.5, 0))
                        else
                            interactSpawn(hrp, spawnPart)
                        end
                    else
                        statusText = "Esperando oleada..."
                    end
                end
            end
        end)
        task.wait(0.06)
    end
end)

-- ==========================================
-- STATUS UI
-- ==========================================
task.spawn(function()
    while alive() do
        pcall(function()
            if StatusLabel.Visible then
                local mobs, spawns = 0, 0
                for _ in pairs(WorldCache.Mobs) do mobs = mobs + 1 end
                for _ in pairs(WorldCache.Spawns) do spawns = spawns + 1 end
                StatusLabel.Text = string.format("%s | Mobs:%d Spawns:%d %s",
                    State.Tab == 1 and "DUN" or "RAID", mobs, spawns, statusText)
            end
        end)
        task.wait(0.5)
    end
end)
