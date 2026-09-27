--========================================================--
--              MT7 HUB V3.1 - ECLIPSE                   --
--      FREE | PRO | STRONG FPS BOOST | MOBILE UI        --
--========================================================--

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Stats = game:GetService("Stats")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer
local VERSION = "3.1"
local GUI_NAME = "MT7_HUB_V31"

--========================================================--
--                         CONFIG                         --
--========================================================--

local VALID_KEYS = {
    ["MT-708090"] = true,
    ["MT-123456"] = true,
    ["MT-987654"] = true
}

local MOON_IMAGE = "rbxassetid://7072719740"

local FREE_NAMES = {
    {"🚀 FPS Booster", "FPSBoost"},
    {"🧹 Effect Cleaner", "EffectCleaner"},
    {"🖼️ Texture Optimizer", "TextureOptimizer"},
    {"✨ Particle Reducer", "ParticleReducer"},
    {"💡 Lighting Optimizer", "LightingOptimizer"},
    {"🌍 Terrain Optimizer", "TerrainOptimizer"},
    {"🌫️ Atmosphere Reducer", "AtmosphereReducer"},
    {"📱 Mobile Mode", "MobileMode"},
    {"🧊 Anti Freeze", "AntiFreeze"},
    {"🔋 Power Saver", "PowerSaver"}
}

local PRO_NAMES = {
    {"🚀 Extreme FPS", "ExtremeFPS"},
    {"🌑 Ultra Render", "UltraRender"},
    {"💥 Extreme Particle", "ExtremeParticle"},
    {"💡 Extreme Lighting", "ExtremeLighting"},
    {"🌋 Extreme Terrain", "ExtremeTerrain"},
    {"🧠 Smart Boost PRO", "SmartBoostPRO"},
    {"🌡️ Thermal Guard", "ThermalGuard"},
    {"🎮 Render Optimizer", "RenderOptimizer"},
    {"🔋 Battery Saver", "BatterySaver"},
    {"⚙️ Dynamic Boost", "DynamicBoost"}
}

local FreeState = {}
local ProState = {}
for _, v in ipairs(FREE_NAMES) do FreeState[v[2]] = false end
for _, v in ipairs(PRO_NAMES) do ProState[v[2]] = false end

local ProUnlocked = false
local MonitorEnabled = true
local MoonEnabled = true
local CurrentScale = 1

--========================================================--
--                       HELPERS                         --
--========================================================--

local function safe(fn)
    local ok, result = pcall(fn)
    return ok, result
end

local function setProp(obj, prop, value)
    pcall(function()
        obj[prop] = value
    end)
end

local function getProp(obj, prop)
    local ok, value = pcall(function()
        return obj[prop]
    end)
    return ok and value or nil
end

local function getGuiParent()
    local ok, parent = pcall(function() return gethui() end)
    if ok and parent then return parent end
    return CoreGui
end

pcall(function()
    local old = getGuiParent():FindFirstChild(GUI_NAME)
    if old then old:Destroy() end
end)

--========================================================--
--                 OPTIMIZATION ENGINE                   --
--========================================================--

local Original = {}
local OriginalTerrain = {}
local EffectConnection

local function remember(obj, prop)
    Original[obj] = Original[obj] or {}
    if Original[obj][prop] == nil then
        Original[obj][prop] = getProp(obj, prop)
    end
end

local function change(obj, prop, value)
    if not obj then return end
    remember(obj, prop)
    setProp(obj, prop, value)
end

local function restoreAll()
    for obj, props in pairs(Original) do
        if obj and obj.Parent then
            for prop, value in pairs(props) do
                if value ~= nil then
                    pcall(function() obj[prop] = value end)
                end
            end
        end
    end

    for prop, value in pairs(OriginalTerrain) do
        if value ~= nil then
            pcall(function() workspace.Terrain[prop] = value end)
        end
    end
end

local function optimizeInstance(obj, level)
    if not obj or not obj.Parent then return end

    local class = obj.ClassName

    if class == "ParticleEmitter" then
        change(obj, "Enabled", false)
        if level >= 2 then change(obj, "Rate", 0) end

    elseif class == "Trail" or class == "Beam" then
        change(obj, "Enabled", false)

    elseif class == "Smoke" or class == "Fire" or class == "Sparkles" then
        change(obj, "Enabled", false)

    elseif class == "PointLight" or class == "SpotLight" or class == "SurfaceLight" then
        change(obj, "Enabled", false)
        if level >= 2 then change(obj, "Shadows", false) end

    elseif class == "BloomEffect"
        or class == "BlurEffect"
        or class == "ColorCorrectionEffect"
        or class == "DepthOfFieldEffect"
        or class == "SunRaysEffect" then
        change(obj, "Enabled", false)

    elseif class == "Atmosphere" then
        change(obj, "Density", 0)
        change(obj, "Haze", 0)
        change(obj, "Glare", 0)

    elseif class == "Clouds" then
        change(obj, "Cover", 0)
        change(obj, "Density", 0)

    elseif class == "Decal" or class == "Texture" then
        change(obj, "Transparency", 1)

    elseif class == "SpecialMesh" and level >= 3 then
        -- Keep geometry intact; only avoid expensive texture IDs where possible.
        change(obj, "TextureId", "")

    elseif class == "BasePart" and level >= 3 then
        change(obj, "CastShadow", false)
    end
end

local function scanWorld(level)
    for _, obj in ipairs(workspace:GetDescendants()) do
        optimizeInstance(obj, level)
    end
end

local function startCleaner(level)
    scanWorld(level)
    if EffectConnection then EffectConnection:Disconnect() end
    EffectConnection = workspace.DescendantAdded:Connect(function(obj)
        task.defer(function()
            optimizeInstance(obj, level)
        end)
    end)
end

local function stopCleaner()
    if EffectConnection then
        EffectConnection:Disconnect()
        EffectConnection = nil
    end
end

local function optimizeLighting(level)
    change(Lighting, "GlobalShadows", false)
    change(Lighting, "FogEnd", 100000)

    if level >= 2 then
        change(Lighting, "Brightness", 1)
        change(Lighting, "EnvironmentDiffuseScale", 0)
        change(Lighting, "EnvironmentSpecularScale", 0)
    end

    if level >= 3 then
        change(Lighting, "Technology", Enum.Technology.Compatibility)
    end

    for _, obj in ipairs(Lighting:GetChildren()) do
        optimizeInstance(obj, level)
    end
end

local function optimizeTerrain(level)
    local terrain = workspace:FindFirstChildOfClass("Terrain")
    if not terrain then return end

    local props = {
        "WaterWaveSize",
        "WaterWaveSpeed",
        "WaterReflectance",
        "WaterTransparency"
    }

    for _, prop in ipairs(props) do
        local value = getProp(terrain, prop)
        if value ~= nil and OriginalTerrain[prop] == nil then
            OriginalTerrain[prop] = value
        end
    end

    change(terrain, "WaterWaveSize", 0)
    change(terrain, "WaterWaveSpeed", 0)
    change(terrain, "WaterReflectance", 0)
    change(terrain, "WaterTransparency", 1)
end

local function applyFPSBoost(level)
    level = level or 2
    optimizeLighting(level)
    startCleaner(level)
    optimizeTerrain(level)

    if level >= 3 then
        pcall(function()
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        end)
    end
end

local function restoreFPSBoost()
    stopCleaner()
    restoreAll()
end

--========================================================--
--                   BOOSTER ACTIONS                     --
--========================================================--

local function applyFree(name, enabled)
    FreeState[name] = enabled

    if name == "FPSBoost" then
        if enabled then applyFPSBoost(2) else restoreFPSBoost() end

    elseif name == "EffectCleaner" then
        if enabled then startCleaner(2) else stopCleaner() end

    elseif name == "TextureOptimizer" then
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Decal") or obj:IsA("Texture") then
                if enabled then
                    change(obj, "Transparency", 1)
                end
            end
        end

    elseif name == "ParticleReducer" then
        if enabled then startCleaner(2) end

    elseif name == "LightingOptimizer" then
        if enabled then optimizeLighting(2) else restoreAll() end

    elseif name == "TerrainOptimizer" then
        if enabled then optimizeTerrain(2) else restoreAll() end

    elseif name == "AtmosphereReducer" then
        if enabled then
            for _, obj in ipairs(Lighting:GetChildren()) do
                if obj:IsA("Atmosphere") then optimizeInstance(obj, 2) end
            end
        end

    elseif name == "MobileMode" then
        if enabled then
            applyFPSBoost(2)
            pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
        end

    elseif name == "AntiFreeze" then
        if enabled then startCleaner(1) else stopCleaner() end

    elseif name == "PowerSaver" then
        if enabled then
            applyFPSBoost(2)
        end
    end
end

local function applyPro(name, enabled)
    if not ProUnlocked then return end
    ProState[name] = enabled

    if name == "ExtremeFPS" then
        if enabled then applyFPSBoost(3) else restoreFPSBoost() end

    elseif name == "UltraRender" then
        if enabled then
            pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
            optimizeLighting(3)
        end

    elseif name == "ExtremeParticle" then
        if enabled then startCleaner(3) else stopCleaner() end

    elseif name == "ExtremeLighting" then
        if enabled then optimizeLighting(3) end

    elseif name == "ExtremeTerrain" then
        if enabled then optimizeTerrain(3) end

    elseif name == "SmartBoostPRO" then
        if enabled then
            applyFPSBoost(3)
        end

    elseif name == "ThermalGuard" then
        if enabled then
            applyFPSBoost(2)
        end

    elseif name == "RenderOptimizer" then
        if enabled then
            startCleaner(3)
            optimizeLighting(3)
            optimizeTerrain(3)
        end

    elseif name == "BatterySaver" then
        if enabled then
            applyFPSBoost(3)
        end

    elseif name == "DynamicBoost" then
        -- Dynamic mode is handled by the heartbeat loop below.
    end
end

--========================================================--
--                         GUI                           --
--========================================================--

local Gui = Instance.new("ScreenGui")
Gui.Name = GUI_NAME
Gui.ResetOnSpawn = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.Parent = getGuiParent()

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0.94, 0, 0.72, 0)
Main.Position = UDim2.new(0.03, 0, 0.14, 0)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
Main.BorderSizePixel = 0
Main.Parent = Gui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 16)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(125, 70, 255)
MainStroke.Thickness = 2
MainStroke.Parent = Main

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 54)
Header.BackgroundTransparency = 1
Header.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0.65, 0, 1, 0)
Title.Position = UDim2.new(0.03, 0, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "🌙 MT7 HUB V3.1"
Title.TextColor3 = Color3.fromRGB(240, 240, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local Monitor = Instance.new("TextLabel")
Monitor.Size = UDim2.new(0.32, 0, 1, 0)
Monitor.Position = UDim2.new(0.65, 0, 0, 0)
Monitor.BackgroundTransparency = 1
Monitor.Text = "FPS: -- | Ping: --"
Monitor.TextColor3 = Color3.fromRGB(180, 180, 200)
Monitor.Font = Enum.Font.Gotham
Monitor.TextSize = 11
Monitor.Parent = Header

local Body = Instance.new("Frame")
Body.Size = UDim2.new(1, -18, 1, -70)
Body.Position = UDim2.new(0, 9, 0, 60)
Body.BackgroundTransparency = 1
Body.Parent = Main

local FreePanel = Instance.new("Frame")
FreePanel.Size = UDim2.new(0.485, -5, 1, 0)
FreePanel.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
FreePanel.BorderSizePixel = 0
FreePanel.Parent = Body

local FreeCorner = Instance.new("UICorner")
FreeCorner.CornerRadius = UDim.new(0, 12)
FreeCorner.Parent = FreePanel

local ProPanel = FreePanel:Clone()
ProPanel.Parent = Body
ProPanel.Position = UDim2.new(0.515, 5, 0, 0)

local Divider = Instance.new("Frame")
Divider.Size = UDim2.new(0, 2, 1, 0)
Divider.Position = UDim2.new(0.5, -1, 0, 0)
Divider.BackgroundColor3 = Color3.fromRGB(125, 70, 255)
Divider.BorderSizePixel = 0
Divider.Parent = Body

local function makePanelTitle(parent, text, subtitle)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -12, 0, 42)
    label.Position = UDim2.new(0, 6, 0, 4)
    label.BackgroundTransparency = 1
    label.Text = text .. "\n" .. subtitle
    label.TextColor3 = Color3.fromRGB(235, 235, 250)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 13
    label.TextWrapped = true
    label.Parent = parent
    return label
end

makePanelTitle(FreePanel, "🆓 FREE", "10 boosters disponíveis")
makePanelTitle(ProPanel, "🔒 PRO", "10 boosters • Key")

local function createScroll(parent)
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -10, 1, -54)
    scroll.Position = UDim2.new(0, 5, 0, 50)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 3
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.Parent = parent

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 5)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.Parent = scroll

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 8)
    end)

    return scroll
end

local FreeScroll = createScroll(FreePanel)
local ProScroll = createScroll(ProPanel)

local function makeButton(parent, text)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -8, 0, 34)
    b.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
    b.BorderSizePixel = 0
    b.Text = text .. "  OFF"
    b.TextColor3 = Color3.fromRGB(225, 225, 235)
    b.Font = Enum.Font.GothamSemibold
    b.TextSize = 11
    b.AutoButtonColor = false
    b.Parent = parent

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 8)
    c.Parent = b

    local s = Instance.new("UIStroke")
    s.Color = Color3.fromRGB(55, 55, 70)
    s.Thickness = 1
    s.Parent = b

    return b
end

local function setButtonState(button, enabled, locked)
    if locked then
        button.Text = button:GetAttribute("BaseText") .. "  🔒"
        button.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
        button.TextColor3 = Color3.fromRGB(130, 130, 140)
    elseif enabled then
        button.Text = button:GetAttribute("BaseText") .. "  ON"
        button.BackgroundColor3 = Color3.fromRGB(42, 28, 70)
        button.TextColor3 = Color3.fromRGB(220, 205, 255)
    else
        button.Text = button:GetAttribute("BaseText") .. "  OFF"
        button.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
        button.TextColor3 = Color3.fromRGB(225, 225, 235)
    end
end

for _, info in ipairs(FREE_NAMES) do
    local b = makeButton(FreeScroll, info[1])
    b:SetAttribute("BaseText", info[1])
    setButtonState(b, false, false)
    b.MouseButton1Click:Connect(function()
        local key = info[2]
        applyFree(key, not FreeState[key])
        setButtonState(b, FreeState[key], false)
    end)
end

--========================================================--
--                       PRO KEY                         --
--========================================================--

local KeyBox = Instance.new("TextBox")
KeyBox.Size = UDim2.new(1, -12, 0, 34)
KeyBox.Position = UDim2.new(0, 6, 0, 0)
KeyBox.PlaceholderText = "Digite sua Key..."
KeyBox.Text = ""
KeyBox.TextColor3 = Color3.fromRGB(235, 235, 245)
KeyBox.PlaceholderColor3 = Color3.fromRGB(110, 110, 125)
KeyBox.BackgroundColor3 = Color3.fromRGB(20, 20, 27)
KeyBox.BorderSizePixel = 0
KeyBox.Font = Enum.Font.Gotham
KeyBox.TextSize = 11
KeyBox.ClearTextOnFocus = false
KeyBox.Parent = ProScroll

local KeyCorner = Instance.new("UICorner")
KeyCorner.CornerRadius = UDim.new(0, 8)
KeyCorner.Parent = KeyBox

local UnlockButton = Instance.new("TextButton")
UnlockButton.Size = UDim2.new(1, -12, 0, 34)
UnlockButton.BackgroundColor3 = Color3.fromRGB(38, 28, 58)
UnlockButton.Text = "🔓 DESBLOQUEAR PRO"
UnlockButton.TextColor3 = Color3.fromRGB(230, 220, 255)
UnlockButton.Font = Enum.Font.GothamBold
UnlockButton.TextSize = 11
UnlockButton.BorderSizePixel = 0
UnlockButton.Parent = ProScroll

local UnlockCorner = Instance.new("UICorner")
UnlockCorner.CornerRadius = UDim.new(0, 8)
UnlockCorner.Parent = UnlockButton

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, -12, 0, 28)
Status.BackgroundTransparency = 1
Status.Text = "🔒 PRO bloqueado"
Status.TextColor3 = Color3.fromRGB(150, 150, 165)
Status.Font = Enum.Font.Gotham
Status.TextSize = 10
Status.Parent = ProScroll

local ProButtons = {}

for _, info in ipairs(PRO_NAMES) do
    local b = makeButton(ProScroll, info[1])
    b:SetAttribute("BaseText", info[1])
    setButtonState(b, false, true)
    ProButtons[info[2]] = b

    b.MouseButton1Click:Connect(function()
        if not ProUnlocked then return end
        local key = info[2]
        applyPro(key, not ProState[key])
        setButtonState(b, ProState[key], false)
    end)
end

--========================================================--
--                     ECLIPSE EFFECT                    --
--========================================================--

local Eclipse = Instance.new("Frame")
Eclipse.Size = UDim2.new(1, 0, 1, 0)
Eclipse.Position = UDim2.new(0, 0, 0, 0)
Eclipse.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Eclipse.BackgroundTransparency = 1
Eclipse.Visible = false
Eclipse.ZIndex = 50
Eclipse.Parent = Main

local EclipseCircle = Instance.new("Frame")
EclipseCircle.Size = UDim2.new(0, 30, 0, 30)
EclipseCircle.AnchorPoint = Vector2.new(0.5, 0.5)
EclipseCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
EclipseCircle.BackgroundColor3 = Color3.fromRGB(115, 65, 210)
EclipseCircle.BackgroundTransparency = 0
EclipseCircle.ZIndex = 51
EclipseCircle.Parent = Eclipse

local EC = Instance.new("UICorner")
EC.CornerRadius = UDim.new(1, 0)
EC.Parent = EclipseCircle

local function playEclipse()
    Eclipse.Visible = true
    Eclipse.BackgroundTransparency = 1
    EclipseCircle.Size = UDim2.new(0, 30, 0, 30)
    EclipseCircle.BackgroundTransparency = 0

    TweenService:Create(
        Eclipse,
        TweenInfo.new(0.25, Enum.EasingStyle.Quad),
        {BackgroundTransparency = 0.25}
    ):Play()

    local grow = TweenService:Create(
        EclipseCircle,
        TweenInfo.new(0.75, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        {Size = UDim2.new(0, 700, 0, 700)}
    )
    grow:Play()
    grow.Completed:Wait()

    TweenService:Create(
        Eclipse,
        TweenInfo.new(0.45, Enum.EasingStyle.Quad),
        {BackgroundTransparency = 1}
    ):Play()

    task.wait(0.45)
    Eclipse.Visible = false
end

local function unlockPro()
    local key = tostring(KeyBox.Text):upper():gsub("%s+", "")
    if VALID_KEYS[key] then
        ProUnlocked = true
        Status.Text = "✅ PRO desbloqueado"
        Status.TextColor3 = Color3.fromRGB(170, 255, 190)
     
