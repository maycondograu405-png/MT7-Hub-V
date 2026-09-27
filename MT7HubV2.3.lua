--========================================================--
--                     MT7 HUB V2.3                       --
--          PERFORMANCE / OTIMIZAÇÃO / FREE + PRO         --
--========================================================--

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer

local VERSION = "V2.3"

local PRO_URL =
    "https://raw.githubusercontent.com/maycondograu405-png/MT7-Hub-V/refs/heads/main/MT7PRO.lua"

local VALID_KEYS = {
    ["MT-708090"] = true,
    ["MT-123456"] = true,
    ["MT-987654"] = true
}

local MOON_IMAGE = "rbxassetid://7072719740"

--========================================================--
-- ESTADOS
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
-- SALVAR / RESTAURAR PROPRIEDADES
--========================================================--

local function Save(obj, property)
    if not obj then
        return
    end

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
    if not obj then
        return
    end

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
-- FREE: ANTI-LAG
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

--========================================================--
-- FREE: FPS BOOST
--========================================================--

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

--========================================================--
-- FREE: ANTI-TEXTURE
--========================================================--

local function AntiTexture()
    for _, obj in ipairs(game:GetDescendants()) do
        pcall(function()
            if obj:IsA("Decal") or obj:IsA("Texture") then
                Set(obj, "Transparency", 1)

            elseif obj:IsA("SurfaceAppearance") then
                Set(obj, "Enabled", false)
            end
        end)
    end
end

--========================================================--
-- FREE: ANTI-FREEZE
--========================================================--

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

--========================================================--
-- FREE: LOW GRAPHICS
--========================================================--

local function LowGraphics()
    AntiLag()

    local terrain = workspace:FindFirstChildOfClass("Terrain")

    if terrain then
        Set(terrain, "Decoration", false)
    end
end

--========================================================--
-- FREE: PARTICLE REDUCE
--========================================================--

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

--========================================================--
-- FREE: LIGHTING
--========================================================--

local function LightingOptimize()
    AntiLag()
end

--========================================================--
-- FREE: TERRAIN
--========================================================--

local function TerrainOptimize()
    local terrain = workspace:FindFirstChildOfClass("Terrain")

    if terrain then
        Set(terrain, "Decoration", false)
    end
end

--========================================================--
-- FREE: SMART BOOST
--========================================================--

local function SmartFreeBoost()
    AntiLag()
    ParticleReduce()
    LightingOptimize()
    TerrainOptimize()
end

local function ApplyFree()
    Restore()

    if States.AntiLag then
        AntiLag()
    end

    if States.FPSBoost then
        FPSBoost()
    end

    if States.AntiTexture then
        AntiTexture()
    end

    if States.AntiFreeze then
        AntiFreeze()
    end

    if States.LowGraphics then
        LowGraphics()
    end

    if States.ParticleReduce then
        ParticleReduce()
    end

    if States.LightingOptimize then
        LightingOptimize()
    end

    if States.TerrainOptimize then
        TerrainOptimize()
    end

    if States.SmartFreeBoost then
        SmartFreeBoost()
    end
end

local function ToggleFree(name)
    if States[name] == nil then
        return
    end

    States[name] = not States[name]
    ApplyFree()
end

--========================================================--
-- LIMPAR GUI ANTIGA
--========================================================--

pcall(function()
    local old = CoreGui:FindFirstChild("MT7_HUB_V23")

    if old then
        old:Destroy()
    end
end)

--========================================================--
-- GUI PRINCIPAL
--========================================================--

local Gui = Instance.new("ScreenGui")
Gui.Name = "MT7_HUB_V23"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true

pcall(function()
    Gui.Parent = CoreGui
end)

if not Gui.Parent then
    Gui.Parent = Player:WaitForChild("PlayerGui")
end

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.fromOffset(330, 470)
Main.Position = UDim2.new(0.5, -165, 0.5, -235)
Main.BackgroundColor3 = Color3.fromRGB(8, 10, 16)
Main.BorderSizePixel = 0
Main.Parent = Gui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 14)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(40, 120, 255)
MainStroke.Transparency = 0.35
MainStroke.Parent = Main

--========================================================--
-- CABEÇALHO
--========================================================--

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 58)
Header.BackgroundTransparency = 1
Header.Parent = Main

local Title = Instance.new("TextLabel")
Title.BackgroundTransparency = 1
Title.Position = UDim2.fromOffset(15, 7)
Title.Size = UDim2.new(1, -70, 0, 28)
Title.Font = Enum.Font.GothamBold
Title.Text = "🌙 MT7 HUB"
Title.TextColor3 = Color3.fromRGB(235, 240, 255)
Title.TextSize = 21
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local Version = Instance.new("TextLabel")
Version.BackgroundTransparency = 1
Version.Position = UDim2.fromOffset(16, 34)
Version.Size = UDim2.new(1, -70, 0, 18)
Version.Font = Enum.Font.Gotham
Version.Text = VERSION .. " • Performance"
Version.TextColor3 = Color3.fromRGB(100, 145, 220)
Version.TextSize = 11
Version.TextXAlignment = Enum.TextXAlignment.Left
Version.Parent = Header

local Close = Instance.new("TextButton")
Close.Size = UDim2.fromOffset(38, 38)
Close.Position = UDim2.new(1, -46, 0, 10)
Close.BackgroundColor3 = Color3.fromRGB(20, 24, 34)
Close.Text = "×"
Close.TextColor3 = Color3.fromRGB(230, 235, 245)
Close.TextSize = 25
Close.Font = Enum.Font.GothamBold
Close.Parent = Header

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 10)
CloseCorner.Parent = Close

--========================================================--
-- STATUS
--========================================================--

local Status = Instance.new("TextLabel")
Status.BackgroundTransparency = 1
Status.Position = UDim2.fromOffset(16, 61)
Status.Size = UDim2.new(1, -32, 0, 25)
Status.Font = Enum.Font.GothamSemibold
Status.Text = "● FREE ATIVO"
Status.TextColor3 = Color3.fromRGB(70, 220, 120)
Status.TextSize = 12
Status.TextXAlignment = Enum.TextXAlignment.Left
Status.Parent = Main

local FPSLabel = Instance.new("TextLabel")
FPSLabel.BackgroundTransparency = 1
FPSLabel.Position = UDim2.new(1, -120, 0, 61)
FPSLabel.Size = UDim2.fromOffset(105, 25)
FPSLabel.Font = Enum.Font.GothamBold
FPSLabel.Text = "FPS: --"
FPSLabel.TextColor3 = Color3.fromRGB(150, 190, 255)
FPSLabel.TextSize = 12
FPSLabel.TextXAlignment = Enum.TextXAlignment.Right
FPSLabel.Parent = Main

--========================================================--
-- ÁREA DE ROLAGEM
--========================================================--

local Scroll = Instance.new("ScrollingFrame")
Scroll.Position = UDim2.fromOffset(10, 90)
Scroll.Size = UDim2.new(1, -20, 1, -100)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 4
Scroll.ScrollBarImageColor3 = Color3.fromRGB(45, 120, 255)
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Scroll.Parent = Main

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 7)
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Parent = Scroll

local Padding = Instance.new("UIPadding")
Padding.PaddingBottom = UDim.new(0, 10)
Padding.Parent = Scroll

--========================================================--
-- FUNÇÕES DA INTERFACE
--========================================================--

local function Section(text, order)
    local Label = Instance.new("TextLabel")

    Label.Size = UDim2.new(1, -4, 0, 27)
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.GothamBold
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(75, 145, 255)
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.LayoutOrder = order or 1
    Label.Parent = Scroll

    return Label
end

local function Button(text, callback, order)
    local B = Instance.new("TextButton")

    B.Size = UDim2.new(1, -4, 0, 40)
    B.BackgroundColor3 = Color3.fromRGB(17, 21, 30)
    B.BorderSizePixel = 0
    B.Font = Enum.Font.GothamSemibold
    B.Text = text
    B.TextColor3 = Color3.fromRGB(220, 225, 235)
    B.TextSize = 12
    B.AutoButtonColor = false
    B.LayoutOrder = order or 1
    B.Parent = Scroll

    local C = Instance.new("UICorner")
    C.CornerRadius = UDim.new(0, 9)
    C.Parent = B

    B.MouseEnter:Connect(function()
        B.BackgroundColor3 = Color3.fromRGB(25, 32, 48)
    end)

    B.MouseLeave:Connect(function()
        B.BackgroundColor3 = Color3.fromRGB(17, 21, 30)
    end)

    B.MouseButton1Click:Connect(function()
        pcall(callback)
    end)

    return B
end

local function UpdateStatus()
    local active = 0

    for _, value in pairs(States) do
        if value then
            active += 1
        end
    end

    if PRO.Verified then
        Status.Text = "● PRO ATIVO • " .. active .. " FREE"
        Status.TextColor3 = Color3.fromRGB(80, 180, 255)
    else
        Status.Text = "● FREE ATIVO • " .. active .. " otimizações"
        Status.TextColor3 = Color3.fromRGB(70, 220, 120)
    end
end

--========================================================--
-- FREE
--========================================================--

Section("FREE • OTIMIZAÇÃO", 1)

local FreeButtons = {}

local function FreeToggle(name, display, order)
    local B

    local function Refresh()
        if States[name] then
            B.Text = "🟢 " .. display .. "   [ON]"
            B.TextColor3 = Color3.fromRGB(90, 230, 130)
        else
            B.Text = "⚪ " .. display .. "   [OFF]"
            B.TextColor3 = Color3.fromRGB(220, 225, 235)
        end
    end

    B = Button("", function()
        ToggleFree(name)
        Refresh()
        UpdateStatus()
    end, order)

    FreeButtons[name] = Refresh
    Refresh()

    return B
end

FreeToggle("AntiLag", "Anti-Lag", 2)
FreeToggle("FPSBoost", "FPS Boost", 3)
FreeToggle("AntiTexture", "Anti-Texture", 4)
FreeToggle("AntiFreeze", "Anti-Freeze", 5)
FreeToggle("LowGraphics", "Low Graphics", 6)
FreeToggle("ParticleReduce", "Particle Reduce", 7)
FreeToggle("LightingOptimize", "Lighting Optimize", 8)
FreeToggle("TerrainOptimize", "Terrain Optimize", 9)
FreeToggle("SmartFreeBoost", "Smart Free Boost", 10)

--========================================================--
-- FPS
--========================================================--

Section("FPS • LIMITADOR", 20)

local FPSButtons = {}

local function FPSButton(label, value)
    local B = Button("⚡ FPS " .. label, function()
        if value == 999 then
            SetUnlimitedFPS()
        else
            SetFPS(value)
        end

        for _, other in ipairs(FPSButtons) do
            other.BackgroundColor3 = Color3.fromRGB(17, 21, 30)
        end

        B.BackgroundColor3 = Color3.fromRGB(25, 65, 115)
    end)

    table.insert(FPSButtons, B)
end

FPSButton("30", 30)
FPSButton("40", 40)
FPSButton("50", 50)
FPSButton("60", 60)
FPSButton("75", 75)
FPSButton("90", 90)
FPSButton("120", 120)
FPSButton("Unlimited", 999)
--========================================================--
-- PRO KEY
--========================================================--

Section("🔒 PRO • SISTEMA", 40)

local KeyBox = Instance.new("TextBox")
KeyBox.Size = UDim2.new(1, -4, 0, 40)
KeyBox.BackgroundColor3 = Color3.fromRGB(14, 18, 27)
KeyBox.BorderSizePixel = 0
KeyBox.PlaceholderText = "Digite sua chave PRO..."
KeyBox.PlaceholderColor3 = Color3.fromRGB(100, 110, 125)
KeyBox.Text = ""
KeyBox.TextColor3 = Color3.fromRGB(235, 240, 250)
KeyBox.Font = Enum.Font.Gotham
KeyBox.TextSize = 12
KeyBox.ClearTextOnFocus = false
KeyBox.LayoutOrder = 41
KeyBox.Parent = Scroll

local KeyCorner = Instance.new("UICorner")
KeyCorner.CornerRadius = UDim.new(0, 9)
KeyCorner.Parent = KeyBox

local VerifyButton

VerifyButton = Button("🔑 VERIFICAR KEY", function()
    local key = tostring(KeyBox.Text)

    if not VALID_KEYS[key] then
        PRO.Verified = false
        VerifyButton.Text = "❌ KEY INVÁLIDA"

        task.delay(1.5, function()
            if VerifyButton.Parent then
                VerifyButton.Text = "🔑 VERIFICAR KEY"
            end
        end)

        UpdateStatus()
        return
    end

    PRO.Verified = true
    VerifyButton.Text = "⏳ CARREGANDO PRO..."

    task.spawn(function()
        local ok, result = pcall(function()
            local source = game:HttpGet(PRO_URL)
            local loader = loadstring(source)

            if not loader then
                error("Falha ao carregar MT7PRO.lua")
            end

            return loader()
        end)

        if ok and result then
            PRO.Module = result
            VerifyButton.Text = "✅ PRO ATIVO"
        else
            PRO.Verified = false
            PRO.Module = nil
            VerifyButton.Text = "❌ FALHA AO CARREGAR PRO"
        end

        UpdateStatus()

        task.delay(2, function()
            if VerifyButton.Parent then
                VerifyButton.Text = "🔑 VERIFICAR KEY"
            end
        end)
    end)
end, 42)

--========================================================--
-- PRO
--========================================================--

Section("PRO • PERFORMANCE AVANÇADA", 50)

local PROButtons = {}

local function PROToggle(name, display, order)
    local B

    local function Refresh()
        if not PRO.Verified then
            B.Text = "🔒 " .. display .. "   [PRO]"
            B.TextColor3 = Color3.fromRGB(130, 135, 150)
            return
        end

        if PRO.Module and PRO.Module.States then
            if PRO.Module.States[name] then
                B.Text = "🟢 " .. display .. "   [ON]"
                B.TextColor3 = Color3.fromRGB(90, 230, 130)
            else
                B.Text = "⚪ " .. display .. "   [OFF]"
                B.TextColor3 = Color3.fromRGB(130, 190, 255)
            end
        else
            B.Text = "🔒 " .. display .. "   [PRO]"
        end
    end

    B = Button("", function()
        if not PRO.Verified or not PRO.Module then
            B.Text = "🔒 KEY NECESSÁRIA"
            task.delay(1.2, Refresh)
            return
        end

        if type(PRO.Module.Set) == "function" then
            local current = PRO.Module.States[name]
            PRO.Module.Set(name, not current)
        end

        Refresh()
    end, order)

    PROButtons[name] = Refresh
    Refresh()

    return B
end

PROToggle("UltraFPS", "Ultra FPS", 51)
PROToggle("UltraRender", "Ultra Render", 52)
PROToggle("ParticleBoost", "Ultra Particles", 53)
PROToggle("LightingBoost", "Ultra Lighting", 54)
PROToggle("TerrainBoost", "Ultra Terrain", 55)
PROToggle("SmartBoost", "Smart PRO Boost", 56)

Button("🔒 APLICAR TODAS PRO", function()
    if not PRO.Verified or not PRO.Module then
        return
    end

    if type(PRO.Module.EnableAll) == "function" then
        PRO.Module.EnableAll()
    end

    for _, refresh in pairs(PROButtons) do
        refresh()
    end
end, 57)

Button("🔒 RESTAURAR PRO", function()
    if not PRO.Verified or not PRO.Module then
        return
    end

    if type(PRO.Module.DisableAll) == "function" then
        PRO.Module.DisableAll()
    end

    for _, refresh in pairs(PROButtons) do
        refresh()
    end
end, 58)

--========================================================--
-- SISTEMA
--========================================================--

Section("SISTEMA", 70)

local SettingsFrame

Button("⚙️ CONFIGURAÇÕES", function()
    if SettingsFrame then
        SettingsFrame.Visible = not SettingsFrame.Visible
    end
end, 71)

Button("♻️ RESTAURAR TUDO", function()
    for name in pairs(States) do
        States[name] = false
    end

    Restore()

    if PRO.Module and type(PRO.Module.DisableAll) == "function" then
        PRO.Module.DisableAll()
    end

    for _, refresh in pairs(FreeButtons) do
        refresh()
    end

    for _, refresh in pairs(PROButtons) do
        refresh()
    end

    UpdateStatus()
end, 72)

--========================================================--
-- JANELA DE CONFIGURAÇÕES
--========================================================--

SettingsFrame = Instance.new("Frame")
SettingsFrame.Name = "Settings"
SettingsFrame.Size = UDim2.fromOffset(285, 330)
SettingsFrame.Position = UDim2.new(0.5, -142, 0.5, -165)
SettingsFrame.BackgroundColor3 = Color3.fromRGB(8, 10, 16)
SettingsFrame.BorderSizePixel = 0
SettingsFrame.Visible = false
SettingsFrame.ZIndex = 20
SettingsFrame.Parent = Gui

local SC = Instance.new("UICorner")
SC.CornerRadius = UDim.new(0, 14)
SC.Parent = SettingsFrame

local SS = Instance.new("UIStroke")
SS.Color = Color3.fromRGB(40, 120, 255)
SS.Parent = SettingsFrame

local ST = Instance.new("TextLabel")
ST.Size = UDim2.new(1, -55, 0, 42)
ST.Position = UDim2.fromOffset(15, 7)
ST.BackgroundTransparency = 1
ST.Text = "⚙️ CONFIGURAÇÕES"
ST.TextColor3 = Color3.fromRGB(235, 240, 255)
ST.Font = Enum.Font.GothamBold
ST.TextSize = 17
ST.TextXAlignment = Enum.TextXAlignment.Left
ST.ZIndex = 21
ST.Parent = SettingsFrame

local SCLOSE = Instance.new("TextButton")
SCLOSE.Size = UDim2.fromOffset(35, 35)
SCLOSE.Position = UDim2.new(1, -43, 0, 8)
SCLOSE.BackgroundColor3 = Color3.fromRGB(20, 24, 34)
SCLOSE.Text = "×"
SCLOSE.TextColor3 = Color3.fromRGB(235, 240, 250)
SCLOSE.Font = Enum.Font.GothamBold
SCLOSE.TextSize = 22
SCLOSE.ZIndex = 21
SCLOSE.Parent = SettingsFrame

SCLOSE.MouseButton1Click:Connect(function()
    SettingsFrame.Visible = false
end)

local SLayout = Instance.new("UIListLayout")
SLayout.Padding = UDim.new(0, 8)
SLayout.SortOrder = Enum.SortOrder.LayoutOrder
SLayout.Parent = SettingsFrame

local SPadding = Instance.new("UIPadding")
SPadding.PaddingTop = UDim.new(0, 55)
SPadding.PaddingLeft = UDim.new(0, 15)
SPadding.PaddingRight = UDim.new(0, 15)
SPadding.PaddingBottom = UDim.new(0, 10)
SPadding.Parent = SettingsFrame

local MoonToggle = Instance.new("TextButton")
MoonToggle.Size = UDim2.new(1, 0, 0, 38)
MoonToggle.BackgroundColor3 = Color3.fromRGB(17, 21, 30)
MoonToggle.BorderSizePixel = 0
MoonToggle.Font = Enum.Font.GothamSemibold
MoonToggle.TextSize = 12
MoonToggle.ZIndex = 21
MoonToggle.LayoutOrder = 1
MoonToggle.Parent = SettingsFrame

local Floating

local function UpdateMoon()
    if Settings.Moon then
        MoonToggle.Text = "🌙 Moon Button   [ON]"
        MoonToggle.TextColor3 = Color3.fromRGB(100, 190, 255)
    else
        MoonToggle.Text = "🌙 Moon Button   [OFF]"
        MoonToggle.TextColor3 = Color3.fromRGB(160, 165, 175)
    end

    if Floating then
        Floating.Visible = Settings.Moon
    end
end

MoonToggle.MouseButton1Click:Connect(function()
    Settings.Moon = not Settings.Moon
    UpdateMoon()
end)

local function ScaleButton(label, scale, order)
    local B = Instance.new("TextButton")

    B.Size = UDim2.new(1, 0, 0, 38)
    B.BackgroundColor3 = Color3.fromRGB(17, 21, 30)
    B.BorderSizePixel = 0
    B.Text = "📐 Escala " .. label
    B.TextColor3 = Color3.fromRGB(220, 225, 235)
    B.Font = Enum.Font.GothamSemibold
    B.TextSize = 12
    B.ZIndex = 21
    B.LayoutOrder = order
    B.Parent = SettingsFrame

    B.MouseButton1Click:Connect(function()
        Settings.Scale = scale

        Main.Size = UDim2.fromOffset(
            math.floor(330 * scale),
            math.floor(470 * scale)
        )
    end)
end

ScaleButton("70%", 0.70, 2)
ScaleButton("85%", 0.85, 3)
ScaleButton("100%", 1, 4)
ScaleButton("115%", 1.15, 5)

--========================================================--
-- BOTÃO FLUTUANTE DA LUA
--========================================================--

Floating = Instance.new("ImageButton")
Floating.Name = "MT7Floating"
Floating.Size = UDim2.fromOffset(58, 58)
Floating.Position = UDim2.new(0, 18, 0.5, -29)
Floating.BackgroundColor3 = Color3.fromRGB(8, 10, 16)
Floating.Image = MOON_IMAGE
Floating.ScaleType = Enum.ScaleType.Fit
Floating.Visible = Settings.Moon
Floating.ZIndex = 50
Floating.Parent = Gui

local FC = Instance.new("UICorner")
FC.CornerRadius = UDim.new(1, 0)
FC.Parent = Floating

local FS = Instance.new("UIStroke")
FS.Color = Color3.fromRGB(55, 135, 255)
FS.Thickness = 2
FS.Parent = Floating

--========================================================--
-- SISTEMA DE ARRASTAR
--========================================================--

local function MakeDraggable(object)
    local dragging = false
    local dragStart
    local startPosition

    object.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then

            dragging = true
            dragStart = input.Position
            startPosition = object.Position

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

        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then

            local delta = input.Position - dragStart

            object.Position = UDim2.new(
                startPosition.X.Scale,
                startPosition.X.Offset + delta.X,
                startPosition.Y.Scale,
                startPosition.Y.Offset + delta.Y
            )
        end
    end)
end

MakeDraggable(Main)
MakeDraggable(SettingsFrame)
MakeDraggable(Floating)

--========================================================--
-- ABRIR / FECHAR
--========================================================--

local Open = true

local function CloseMenu()
    if not Open then
        return
    end

    Open = false

    local tween = TweenService:Create(
        Main,
        TweenInfo.new(
            0.15,
            Enum.EasingStyle.Quad,
            Enum.EasingDirection.In
        ),
        {
            Position = UDim2.new(0.5, -165, 1.2, 0)
        }
    )

    tween:Play()

    tween.Completed:Connect(function()
        if not Open then
            Main.Visible = false
        end
    end)
end

local function OpenMenu()
    if Open then
        return
    end

    Open = true
    Main.Visible = true

    Main.Position = UDim2.new(0.5, -165, 1.2, 0)

    TweenService:Create(
        Main,
        TweenInfo.new(
            0.18,
            Enum.EasingStyle.Quad,
            Enum.EasingDirection.Out
        ),
        {
            Position = UDim2.new(0.5, -165, 0.5, -235)
        }
    ):Play()
end

Close.MouseButton1Click:Connect(CloseMenu)

Floating.MouseButton1Click:Connect(function()
    if Open then
        CloseMenu()
    else
        OpenMenu()
    end
end)

--========================================================--
-- MONITOR DE FPS
--========================================================--

local frames = 0
local last = os.clock()

RunService.RenderStepped:Connect(function()
    frames += 1

    local now = os.clock()

    if now - last >= 1 then
        local fps = math.floor(frames / (now - last))

        FPSLabel.Text = "FPS: " .. tostring(fps)

        frames = 0
        last = now
    end
end)

--========================================================--
-- AO RENASCER
--========================================================--

Player.CharacterAdded:Connect(function()
    task.wait(1)

    ApplyFree()

    if PRO.Verified
        and PRO.Module
        and type(PRO.Module.Apply) == "function" then

        pcall(function()
            PRO.Module.Apply()
        end)
    end
end)

--========================================================--
-- INICIALIZAÇÃO
--========================================================--

SetFPS(Settings.FPS)
UpdateMoon()
UpdateStatus()

print("========================================")
print("MT7 HUB V2.3 carregado!")
print("FREE + PRO PERFORMANCE")
print("========================================")
