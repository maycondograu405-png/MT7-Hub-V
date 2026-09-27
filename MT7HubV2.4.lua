--========================================================--
--                    MT7 HUB V2.4                       --
--              PERFORMANCE / OPTIMIZATION               --
--========================================================--

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer
local VERSION = "V2.4"

local PRO_URL =
    "https://raw.githubusercontent.com/maycondograu405-png/MT7-Hub-V/refs/heads/main/MT7PRO.lua"

local VALID_KEYS = {
    ["MT-708090"] = true,
    ["MT-123456"] = true,
    ["MT-987654"] = true
}

local MOON_IMAGE = "rbxassetid://7072719740"

--========================================================--
-- STATES
--========================================================--

local States = {
    AntiLag = false,
    FPSBoost = false,
    AntiTexture = false,
    AntiFreeze = false,
    LowGraphics = false,
    ParticleReduce = false,
    LightingOptimize = false,
    TerrainOptimize = false,
    SmartFreeBoost = false
}

local Settings = {
    FPS = 60,
    Moon = true,
    Scale = 1
}

local PRO = {
    Verified = false,
    Module = nil
}

local Original = {}

--========================================================--
-- PROPERTY SYSTEM
--========================================================--

local function Save(obj, property)
    if not obj then return end

    if not Original[obj] then
        Original[obj] = {}
    end

    if Original[obj][property] == nil then
        local ok, value = pcall(function()
            return obj[property]
        end)

        if ok then
            Original[obj][property] = value
        end
    end
end

local function Set(obj, property, value)
    if not obj then return end

    Save(obj, property)

    pcall(function()
        obj[property] = value
    end)
end

local function Restore()
    for obj, properties in pairs(Original) do
        if obj and obj.Parent then
            for property, value in pairs(properties) do
                pcall(function()
                    obj[property] = value
                end)
            end
        end
    end
end

--========================================================--
-- FPS
--========================================================--

local function SetFPS(value)
    Settings.FPS = value

    if type(setfpscap) == "function" then
        pcall(function()
            setfpscap(value)
        end)
    end
end

local function SetUnlimitedFPS()
    Settings.FPS = 999

    if type(setfpscap) == "function" then
        pcall(function()
            setfpscap(999)
        end)
    end
end

--========================================================--
-- FREE OPTIMIZATION
--========================================================--

local function AntiLag()
    Set(Lighting, "GlobalShadows", false)

    for _, obj in ipairs(Lighting:GetChildren()) do
        pcall(function()
            if obj:IsA("PostEffect") then
                Set(obj, "Enabled", false)
            elseif obj:IsA("Atmosphere") then
                Set(obj, "Density", 0)
                Set(obj, "Haze", 0)
                Set(obj, "Glare", 0)
            end
        end)
    end
end

local function FPSBoost()
    AntiLag()

    local terrain = workspace:FindFirstChildOfClass("Terrain")

    if terrain then
        Set(terrain, "Decoration", false)
    end

    for _, obj in ipairs(game:GetDescendants()) do
        pcall(function()
            if obj:IsA("ParticleEmitter")
            or obj:IsA("Trail")
            or obj:IsA("Beam")
            or obj:IsA("Smoke")
            or obj:IsA("Fire")
            or obj:IsA("Sparkles")
            or obj:IsA("Highlight") then

                Set(obj, "Enabled", false)
            end
        end)
    end
end

local function AntiTexture()
    for _, obj in ipairs(game:GetDescendants()) do
        pcall(function()
            if obj:IsA("Decal")
            or obj:IsA("Texture") then
                Set(obj, "Transparency", 1)

            elseif obj:IsA("SurfaceAppearance") then
                Set(obj, "Enabled", false)
            end
        end)
    end
end

local function AntiFreeze()
    AntiLag()

    for _, obj in ipairs(Lighting:GetChildren()) do
        pcall(function()
            if obj:IsA("PostEffect") then
                Set(obj, "Enabled", false)
            end
        end)
    end
end

local function LowGraphics()
    AntiLag()

    local terrain = workspace:FindFirstChildOfClass("Terrain")

    if terrain then
        Set(terrain, "Decoration", false)
    end
end

local function ParticleReduce()
    for _, obj in ipairs(game:GetDescendants()) do
        pcall(function()
            if obj:IsA("ParticleEmitter")
            or obj:IsA("Trail")
            or obj:IsA("Beam")
            or obj:IsA("Smoke")
            or obj:IsA("Fire")
            or obj:IsA("Sparkles") then

                Set(obj, "Enabled", false)
            end
        end)
    end
end

local function LightingOptimize()
    AntiLag()
end

local function TerrainOptimize()
    local terrain = workspace:FindFirstChildOfClass("Terrain")

    if terrain then
        Set(terrain, "Decoration", false)
    end
end

local function SmartFreeBoost()
    AntiLag()
    ParticleReduce()
    LightingOptimize()
    TerrainOptimize()
end

local function ApplyFree()
    Restore()

    if States.AntiLag then AntiLag() end
    if States.FPSBoost then FPSBoost() end
    if States.AntiTexture then AntiTexture() end
    if States.AntiFreeze then AntiFreeze() end
    if States.LowGraphics then LowGraphics() end
    if States.ParticleReduce then ParticleReduce() end
    if States.LightingOptimize then LightingOptimize() end
    if States.TerrainOptimize then TerrainOptimize() end
    if States.SmartFreeBoost then SmartFreeBoost() end
end

local function ToggleFree(name)
    if States[name] == nil then return end

    States[name] = not States[name]
    ApplyFree()
end

--========================================================--
-- PRO SYSTEM
--========================================================--

local function LoadPRO()
    if PRO.Module then
        return true
    end

    local success, result = pcall(function()
        local source = game:HttpGet(PRO_URL)
        local module = loadstring(source)

        if not module then
            error("PRO inválido")
        end

        return module()
    end)

    if success and result then
        PRO.Module = result
        return true
    end

    return false
end

local function VerifyKey(key)
    key = tostring(key or "")
    key = key:gsub("^%s+", ""):gsub("%s+$", "")

    if not VALID_KEYS[key] then
        return false
    end

    if not LoadPRO() then
        return false
    end

    PRO.Verified = true
    return true
end

local function SetPRO(name, enabled)
    if not PRO.Verified or not PRO.Module then
        return false
    end

    local success = pcall(function()
        PRO.Module.Set(name, enabled)
    end)

    return success
end

local function PROAll(enabled)
    if not PRO.Verified or not PRO.Module then
        return false
    end

    local success = pcall(function()
        if enabled then
            PRO.Module.EnableAll()
        else
            PRO.Module.DisableAll()
        end
    end)

    return success
end

--========================================================--
-- GUI
--========================================================--

pcall(function()
    local old = CoreGui:FindFirstChild("MT7_HUB_V24")
    if old then old:Destroy() end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MT7_HUB_V24"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = CoreGui

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Parent = ScreenGui
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.Position = UDim2.new(0.5, 0, 0.5, 0)
Main.Size = UDim2.new(0, 340, 0, 490)
Main.BackgroundColor3 = Color3.fromRGB(8, 10, 18)
Main.BorderSizePixel = 0

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 14)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(0, 120, 255)
MainStroke.Thickness = 1.5
MainStroke.Parent = Main

local UIScale = Instance.new("UIScale")
UIScale.Scale = Settings.Scale
UIScale.Parent = Main

local Header = Instance.new("Frame")
Header.Parent = Main
Header.Size = UDim2.new(1, 0, 0, 62)
Header.BackgroundTransparency = 1

local Title = Instance.new("TextLabel")
Title.Parent = Header
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 18, 0, 8)
Title.Size = UDim2.new(1, -70, 0, 28)
Title.Font = Enum.Font.GothamBold
Title.Text = "🌙 MT7 HUB"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 21
Title.TextXAlignment = Enum.TextXAlignment.Left

local Version = Instance.new("TextLabel")
Version.Parent = Header
Version.BackgroundTransparency = 1
Version.Position = UDim2.new(0, 20, 0, 35)
Version.Size = UDim2.new(1, -70, 0, 20)
Version.Font = Enum.Font.Gotham
Version.Text = VERSION .. " • Performance"
Version.TextColor3 = Color3.fromRGB(100, 170, 255)
Version.TextSize = 12
Version.TextXAlignment = Enum.TextXAlignment.Left

local Close = Instance.new("TextButton")
Close.Parent = Header
Close.BackgroundColor3 = Color3.fromRGB(25, 28, 40)
Close.Position = UDim2.new(1, -48, 0, 13)
Close.Size = UDim2.new(0, 34, 0, 34)
Close.Text = "×"
Close.TextColor3 = Color3.fromRGB(255, 255, 255)
Close.TextSize = 22
Close.Font = Enum.Font.GothamBold

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 9)
CloseCorner.Parent = Close

local Status = Instance.new("TextLabel")
Status.Parent = Main
Status.BackgroundTransparency = 1
Status.Position = UDim2.new(0, 18, 0, 66)
Status.Size = UDim2.new(1, -36, 0, 22)
Status.Font = Enum.Font.GothamSemibold
Status.Text = "STATUS: READY"
Status.TextColor3 = Color3.fromRGB(100, 255, 150)
Status.TextSize = 12
Status.TextXAlignment = Enum.TextXAlignment.Left

local FPSLabel = Instance.new("TextLabel")
FPSLabel.Parent = Main
FPSLabel.BackgroundTransparency = 1
FPSLabel.Position = UDim2.new(1, -105, 0, 66)
FPSLabel.Size = UDim2.new(0, 87, 0, 22)
FPSLabel.Font = Enum.Font.GothamSemibold
FPSLabel.Text = "FPS: --"
FPSLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
FPSLabel.TextSize = 12
FPSLabel.TextXAlignment = Enum.TextXAlignment.Right

local Scroll = Instance.new("ScrollingFrame")
Scroll.Parent = Main
Scroll.Position = UDim2.new(0, 10, 0, 95)
Scroll.Size = UDim2.new(1, -20, 1, -105)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 3
Scroll.ScrollBarImageColor3 = Color3.fromRGB(0, 120, 255)
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)

local Layout = Instance.new("UIListLayout")
Layout.Parent = Scroll
Layout.Padding = UDim.new(0, 7)
Layout.SortOrder = Enum.SortOrder.LayoutOrder

local Padding = Instance.new("UIPadding")
Padding.Parent = Scroll
Padding.PaddingLeft = UDim.new(0, 6)
Padding.PaddingRight = UDim.new(0, 6)
Padding.PaddingTop = UDim.new(0, 4)
Padding.PaddingBottom = UDim.new(0, 10)

local Order = 0

local function NextOrder()
    Order += 1
    return Order
end

local function Section(text)
    local Label = Instance.new("TextLabel")
    Label.Parent = Scroll
    Label.LayoutOrder = NextOrder()
    Label.Size = UDim2.new(1, 0, 0, 25)
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.GothamBold
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(80, 160, 255)
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left

    return Label
end

local function Button(text, callback, order)
    local B = Instance.new("TextButton")
    B.Parent = Scroll
    B.LayoutOrder = order or NextOrder()
    B.Size = UDim2.new(1, 0, 0, 38)
    B.BackgroundColor3 = Color3.fromRGB(18, 22, 34)
    B.BorderSizePixel = 0
    B.Font = Enum.Font.GothamSemibold
    B.Text = text
    B.TextColor3 = Color3.fromRGB(235, 235, 245)
    B.TextSize = 12

    local C = Instance.new("UICorner")
    C.CornerRadius = UDim.new(0, 9)
    C.Parent = B

    local S = Instance.new("UIStroke")
    S.Color = Color3.fromRGB(35, 45, 65)
    S.Thickness = 1
    S.Parent = B

    B.MouseButton1Click:Connect(function()
        pcall(callback)
    end)

    return B
end

local function ToggleButton(label, stateName)
    local B

    local function Update()
        if States[stateName] then
            B.Text = "🟢 " .. label .. "  [ON]"
            B.TextColor3 = Color3.fromRGB(100, 255, 150)
        else
            B.Text = "⚪ " .. label .. "  [OFF]"
            B.TextColor3 = Color3.fromRGB(235, 235, 245)
        end
    end

    B = Button(label, function()
        ToggleFree(stateName)
        Update()

        if States[stateName] then
            Status.Text = "STATUS: " .. label .. " ON"
        else
            Status.Text = "STATUS: " .. label .. " OFF"
        end
    end)

    Update()
    return B
end

--========================================================--
-- FREE
--========================================================--

Section("⚡ FREE OPTIMIZATION")

ToggleButton("Anti-Lag", "AntiLag")
ToggleButton("FPS Boost", "FPSBoost")
ToggleButton("Anti-Texture", "AntiTexture")
ToggleButton("Anti-Freeze", "AntiFreeze")
ToggleButton("Low Graphics", "LowGraphics")
ToggleButton("Particle Reduce", "ParticleReduce")
ToggleButton("Lighting Optimize", "LightingOptimize")
ToggleButton("Terrain Optimize", "TerrainOptimize")
ToggleButton("Smart Free Boost", "SmartFreeBoost")

--========================================================--
-- FPS
--========================================================--

Section("🎯 FPS CAP")

local function FPSButton(label, value)
    Button("FPS " .. label, function()
        if value == 999 then
            SetUnlimitedFPS()
            Status.Text = "STATUS: FPS UNLIMITED"
        else
            SetFPS(value)
            Status.Text = "STATUS: FPS " .. tostring(value)
        end
    end)
end

FPSButton("30", 30)
FPSButton("40", 40)
FPSButton("50", 50)
FPSButton("60", 60)
FPSButton("75", 75)
FPSButton("90", 90)
FPSButton("120", 120)
FPSButton("UNLIMITED", 999)

-- FIM DA PARTE 1
--========================================================--
-- PRO KEY
--========================================================--

Section("🔐 MT7 PRO")

local KeyBox = Instance.new("TextBox")
KeyBox.Parent = Scroll
KeyBox.LayoutOrder = NextOrder()
KeyBox.Size = UDim2.new(1, 0, 0, 38)
KeyBox.BackgroundColor3 = Color3.fromRGB(15, 19, 30)
KeyBox.BorderSizePixel = 0
KeyBox.PlaceholderText = "Digite sua chave PRO..."
KeyBox.PlaceholderColor3 = Color3.fromRGB(120, 125, 140)
KeyBox.Text = ""
KeyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyBox.Font = Enum.Font.Gotham
KeyBox.TextSize = 12
KeyBox.ClearTextOnFocus = false

local KeyCorner = Instance.new("UICorner")
KeyCorner.CornerRadius = UDim.new(0, 9)
KeyCorner.Parent = KeyBox

Button("🔑 VERIFICAR CHAVE", function()
    local ok = VerifyKey(KeyBox.Text)

    if ok then
        Status.Text = "STATUS: PRO ATIVADO ✓"
        Status.TextColor3 = Color3.fromRGB(100, 255, 150)
    else
        Status.Text = "STATUS: CHAVE INVÁLIDA"
        Status.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
end)

--========================================================--
-- PRO BUTTONS
--========================================================--

local function PROButton(label, stateName)
    local B

    B = Button("🔒 " .. label .. "  [PRO]", function()
        if not PRO.Verified then
            Status.Text = "STATUS: ATIVE O PRO PRIMEIRO"
            Status.TextColor3 = Color3.fromRGB(255, 190, 80)
            return
        end

        local current = false

        if PRO.Module and PRO.Module.States then
            current = PRO.Module.States[stateName] == true
        end

        local newState = not current

        if SetPRO(stateName, newState) then
            if newState then
                B.Text = "🟢 " .. label .. "  [ON]"
                B.TextColor3 = Color3.fromRGB(100, 255, 150)
                Status.Text = "STATUS: " .. label .. " ON"
            else
                B.Text = "⚪ " .. label .. "  [OFF]"
                B.TextColor3 = Color3.fromRGB(235, 235, 245)
                Status.Text = "STATUS: " .. label .. " OFF"
            end
        else
            Status.Text = "STATUS: ERRO NO PRO"
            Status.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
    end)

    B:SetAttribute("MT7PRO", true)

    return B
end

PROButton("Ultra FPS", "UltraFPS")
PROButton("Ultra Render", "UltraRender")
PROButton("Particle Boost", "ParticleBoost")
PROButton("Lighting Boost", "LightingBoost")
PROButton("Terrain Boost", "TerrainBoost")
PROButton("Smart Boost", "SmartBoost")

Button("⚡ ATIVAR TODOS PRO", function()
    if not PRO.Verified then
        Status.Text = "STATUS: ATIVE O PRO PRIMEIRO"
        Status.TextColor3 = Color3.fromRGB(255, 190, 80)
        return
    end

    if PROAll(true) then
        Status.Text = "STATUS: TODOS PRO ATIVADOS"
        Status.TextColor3 = Color3.fromRGB(100, 255, 150)
    end
end)

Button("↩ RESTAURAR PRO", function()
    if not PRO.Verified then
        Status.Text = "STATUS: ATIVE O PRO PRIMEIRO"
        return
    end

    if PROAll(false) then
        Status.Text = "STATUS: PRO RESTAURADO"
    end
end)

--========================================================--
-- CONTROLES
--========================================================--

Section("🛠 CONTROLES")

Button("↩ RESTAURAR TODA OTIMIZAÇÃO", function()
    Restore()

    if PRO.Verified and PRO.Module then
        pcall(function()
            PRO.Module.DisableAll()
        end)
    end

    Status.Text = "STATUS: RESTAURADO"
    Status.TextColor3 = Color3.fromRGB(100, 255, 150)
end)

--========================================================--
-- SETTINGS
--========================================================--

local SettingsFrame

Button("⚙️ ABRIR SETTINGS", function()
    if SettingsFrame then
        SettingsFrame.Visible = true
    end
end)

SettingsFrame = Instance.new("Frame")
SettingsFrame.Name = "Settings"
SettingsFrame.Parent = ScreenGui
SettingsFrame.AnchorPoint = Vector2.new(0.5, 0.5)
SettingsFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
SettingsFrame.Size = UDim2.new(0, 300, 0, 300)
SettingsFrame.BackgroundColor3 = Color3.fromRGB(8, 10, 18)
SettingsFrame.BorderSizePixel = 0
SettingsFrame.Visible = false
SettingsFrame.ZIndex = 10

local SettingsCorner = Instance.new("UICorner")
SettingsCorner.CornerRadius = UDim.new(0, 14)
SettingsCorner.Parent = SettingsFrame

local SettingsStroke = Instance.new("UIStroke")
SettingsStroke.Color = Color3.fromRGB(0, 120, 255)
SettingsStroke.Thickness = 1.5
SettingsStroke.Parent = SettingsFrame

local ST = Instance.new("TextLabel")
ST.Parent = SettingsFrame
ST.BackgroundTransparency = 1
ST.Position = UDim2.new(0, 18, 0, 12)
ST.Size = UDim2.new(1, -65, 0, 30)
ST.Font = Enum.Font.GothamBold
ST.Text = "⚙️ SETTINGS"
ST.TextColor3 = Color3.fromRGB(255, 255, 255)
ST.TextSize = 18
ST.TextXAlignment = Enum.TextXAlignment.Left
ST.ZIndex = 11

local SCLOSE = Instance.new("TextButton")
SCLOSE.Parent = SettingsFrame
SCLOSE.BackgroundColor3 = Color3.fromRGB(25, 28, 40)
SCLOSE.Position = UDim2.new(1, -48, 0, 10)
SCLOSE.Size = UDim2.new(0, 34, 0, 34)
SCLOSE.Text = "×"
SCLOSE.TextColor3 = Color3.fromRGB(255, 255, 255)
SCLOSE.TextSize = 22
SCLOSE.Font = Enum.Font.GothamBold
SCLOSE.ZIndex = 11

local SCC = Instance.new("UICorner")
SCC.CornerRadius = UDim.new(0, 9)
SCC.Parent = SCLOSE

local SettingsContent = Instance.new("Frame")
SettingsContent.Parent = SettingsFrame
SettingsContent.BackgroundTransparency = 1
SettingsContent.Position = UDim2.new(0, 14, 0, 58)
SettingsContent.Size = UDim2.new(1, -28, 1, -70)
SettingsContent.ZIndex = 11

local SLayout = Instance.new("UIListLayout")
SLayout.Parent = SettingsContent
SLayout.Padding = UDim.new(0, 8)
SLayout.SortOrder = Enum.SortOrder.LayoutOrder

local function SettingsButton(text, callback)
    local B = Instance.new("TextButton")
    B.Parent = SettingsContent
    B.Size = UDim2.new(1, 0, 0, 40)
    B.BackgroundColor3 = Color3.fromRGB(18, 22, 34)
    B.BorderSizePixel = 0
    B.Font = Enum.Font.GothamSemibold
    B.Text = text
    B.TextColor3 = Color3.fromRGB(235, 235, 245)
    B.TextSize = 12
    B.ZIndex = 11

    local C = Instance.new("UICorner")
    C.CornerRadius = UDim.new(0, 9)
    C.Parent = B

    B.MouseButton1Click:Connect(function()
        pcall(callback)
    end)

    return B
end

local MoonToggle

MoonToggle = SettingsButton("🌙 MOON: ON", function()
    Settings.Moon = not Settings.Moon

    if Settings.Moon then
        MoonToggle.Text = "🌙 MOON: ON"
        MoonToggle.TextColor3 = Color3.fromRGB(100, 255, 150)
    else
        MoonToggle.Text = "🌙 MOON: OFF"
        MoonToggle.TextColor3 = Color3.fromRGB(235, 235, 245)
    end
end)

local ScaleLabel = Instance.new("TextLabel")
ScaleLabel.Parent = SettingsContent
ScaleLabel.Size = UDim2.new(1, 0, 0, 25)
ScaleLabel.BackgroundTransparency = 1
ScaleLabel.Font = Enum.Font.GothamBold
ScaleLabel.Text = "UI SCALE"
ScaleLabel.TextColor3 = Color3.fromRGB(100, 170, 255)
ScaleLabel.TextSize = 12
ScaleLabel.ZIndex = 11

local function ScaleButton(label, scale)
    SettingsButton(label, function()
        Settings.Scale = scale
        UIScale.Scale = scale
        Status.Text = "STATUS: UI " .. label
    end)
end

ScaleButton("70%", 0.70)
ScaleButton("85%", 0.85)
ScaleButton("100%", 1)
ScaleButton("115%", 1.15)

-- FIM DA PARTE 2
--========================================================--
-- SETTINGS CLOSE
--========================================================--

SCLOSE.MouseButton1Click:Connect(function()
    SettingsFrame.Visible = false
end)

--========================================================--
-- FLOATING MOON
--========================================================--

local MoonButtonFloat = Instance.new("ImageButton")
MoonButtonFloat.Name = "MoonButton"
MoonButtonFloat.Parent = ScreenGui
MoonButtonFloat.AnchorPoint = Vector2.new(0.5, 0.5)
MoonButtonFloat.Position = UDim2.new(0, 55, 0.5, 0)
MoonButtonFloat.Size = UDim2.new(0, 58, 0, 58)
MoonButtonFloat.BackgroundColor3 = Color3.fromRGB(8, 10, 18)
MoonButtonFloat.Image = MOON_IMAGE
MoonButtonFloat.ImageTransparency = 0
MoonButtonFloat.ZIndex = 20

local MoonCorner = Instance.new("UICorner")
MoonCorner.CornerRadius = UDim.new(1, 0)
MoonCorner.Parent = MoonButtonFloat

local MoonStroke = Instance.new("UIStroke")
MoonStroke.Color = Color3.fromRGB(0, 120, 255)
MoonStroke.Thickness = 1.5
MoonStroke.Parent = MoonButtonFloat

--========================================================--
-- DRAG SYSTEM
--========================================================--

local function MakeDraggable(obj)
    local dragging = false
    local dragStart
    local startPos

    obj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

            dragging = true
            dragStart = input.Position
            startPos = obj.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging then
            return
        end

        if input.UserInputType ~= Enum.UserInputType.MouseMovement
        and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end

        local delta = input.Position - dragStart

        obj.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end)
end

MakeDraggable(Main)
MakeDraggable(SettingsFrame)
MakeDraggable(MoonButtonFloat)

--========================================================--
-- OPEN / CLOSE
--========================================================--

local Opened = true

local function OpenMenu()
    Opened = true
    Main.Visible = true
end

local function CloseMenu()
    Opened = false
    Main.Visible = false
    SettingsFrame.Visible = false
end

Close.MouseButton1Click:Connect(CloseMenu)

MoonButtonFloat.MouseButton1Click:Connect(function()
    if Opened then
        CloseMenu()
    else
        OpenMenu()
    end
end)

--========================================================--
-- FPS MONITOR
--========================================================--

local Frames = 0
local LastTime = os.clock()

RunService.RenderStepped:Connect(function()
    Frames += 1

    local now = os.clock()

    if now - LastTime >= 1 then
        local fps = Frames

        Frames = 0
        LastTime = now

        FPSLabel.Text = "FPS: " .. tostring(fps)
    end
end)

--========================================================--
-- CHARACTER RESPAWN
--========================================================--

Player.CharacterAdded:Connect(function()
    task.wait(1)

    pcall(function()
        ApplyFree()
    end)

    if PRO.Verified and PRO.Module then
        pcall(function()
            PRO.Module.Apply()
        end)
    end
end)

--========================================================--
-- INITIALIZE
--========================================================--

SetFPS(60)

Status.Text = "STATUS: MT7 V2.4 READY"
Status.TextColor3 = Color3.fromRGB(100, 255, 150)

print("🌙 MT7 HUB V2.4 carregado!")
