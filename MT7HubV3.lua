--========================================================--
--                 MT7 HUB V3 - ECLIPSE                 --
--        Main Interface / FREE + PRO / Mobile UI       --
--========================================================--

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer
local VERSION = "3.0"
local BASE = "https://raw.githubusercontent.com/maycondograu405-png/MT7-Hub-V/refs/heads/main/"

local function LoadModule(name)
    local ok, result = pcall(function()
        return loadstring(game:HttpGet(BASE .. name))()
    end)
    if ok then return result end
    warn("[MT7] Falha ao carregar " .. name .. ": " .. tostring(result))
    return nil
end

local Settings = LoadModule("MT7Settings.lua")
local Monitor = LoadModule("MT7Monitor.lua")
local Thermal = LoadModule("MT7Thermal.lua")
local Themes = LoadModule("MT7Themes.lua")
local PRO = LoadModule("MT7PROV3.lua")

if not Settings or not Monitor or not Thermal or not Themes or not PRO then
    warn("[MT7] Um ou mais módulos não puderam ser carregados.")
    return
end

--========================================================--
-- KEY SYSTEM
--========================================================--

local VALID_KEYS = {
    ["MT-708090"] = true,
    ["MT-123456"] = true,
    ["MT-987654"] = true
}

local ProUnlocked = false

--========================================================--
-- FREE BOOSTERS
--========================================================--

local FreeStates = {
    FPSBoost = false,
    AntiTexture = false,
    LowGraphics = false,
    ParticleReduce = false,
    LightingOptimize = false,
    TerrainOptimize = false,
    AntiFreeze = false,
    SmartFreeBoost = false,
    MobileMode = false,
    PowerSaver = false
}

local FreeOriginal = {}

local function FreeSave(obj, property)
    if not FreeOriginal[obj] then
        FreeOriginal[obj] = {}
    end

    if FreeOriginal[obj][property] == nil then
        local ok, value = pcall(function()
            return obj[property]
        end)

        if ok then
            FreeOriginal[obj][property] = value
        end
    end
end

local function FreeSet(obj, property, value)
    FreeSave(obj, property)

    pcall(function()
        obj[property] = value
    end)
end

local function FreeRestore()
    for obj, properties in pairs(FreeOriginal) do
        if obj and obj.Parent then
            for property, value in pairs(properties) do
                pcall(function()
                    obj[property] = value
                end)
            end
        end
    end
end

local function ApplyFree()
    FreeRestore()

    if FreeStates.FPSBoost
    or FreeStates.LowGraphics
    or FreeStates.SmartFreeBoost
    or FreeStates.MobileMode
    or FreeStates.PowerSaver then

        FreeSet(Lighting, "GlobalShadows", false)
    end

    if FreeStates.LightingOptimize
    or FreeStates.LowGraphics
    or FreeStates.SmartFreeBoost
    or FreeStates.PowerSaver then

        for _, obj in ipairs(Lighting:GetChildren()) do
            pcall(function()

                if obj:IsA("PostEffect") then
                    FreeSet(obj, "Enabled", false)

                elseif obj:IsA("Atmosphere") then
                    FreeSet(obj, "Density", 0)
                    FreeSet(obj, "Haze", 0)
                    FreeSet(obj, "Glare", 0)
                end

            end)
        end
    end

    if FreeStates.ParticleReduce
    or FreeStates.LowGraphics
    or FreeStates.SmartFreeBoost
    or FreeStates.MobileMode
    or FreeStates.PowerSaver then

        for _, obj in ipairs(game:GetDescendants()) do
            pcall(function()

                if obj:IsA("ParticleEmitter")
                or obj:IsA("Trail")
                or obj:IsA("Beam") then

                    FreeSet(obj, "Enabled", false)
                end

            end)
        end
    end

    if FreeStates.AntiTexture
    or FreeStates.LowGraphics
    or FreeStates.MobileMode then

        for _, obj in ipairs(game:GetDescendants()) do
            pcall(function()

                if obj:IsA("Decal")
                or obj:IsA("Texture") then

                    FreeSet(obj, "Transparency", 1)
                end

            end)
        end
    end

    if FreeStates.TerrainOptimize
    or FreeStates.LowGraphics
    or FreeStates.SmartFreeBoost
    or FreeStates.MobileMode then

        local Terrain = workspace:FindFirstChildOfClass("Terrain")

        if Terrain then
            FreeSet(Terrain, "Decoration", false)
        end
    end

    if FreeStates.PowerSaver then

        for _, obj in ipairs(game:GetDescendants()) do
            pcall(function()

                if obj:IsA("PointLight")
                or obj:IsA("SpotLight")
                or obj:IsA("SurfaceLight") then

                    FreeSet(obj, "Enabled", false)
                end

            end)
        end
    end
end

local function SetFree(name, enabled)

    if FreeStates[name] == nil then
        return false
    end

    FreeStates[name] = enabled == true

    ApplyFree()

    return true
end

--========================================================--
-- GUI ROOT
--========================================================--

local Existing = CoreGui:FindFirstChild("MT7HubV3")

if Existing then
    Existing:Destroy()
end

local Gui = Instance.new("ScreenGui")
Gui.Name = "MT7HubV3"
Gui.ResetOnSpawn = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.Parent = CoreGui

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0.92, 0, 0.74, 0)
Main.Position = UDim2.new(0.04, 0, 0.13, 0)
Main.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
Main.BorderSizePixel = 0
Main.Parent = Gui

local UIScale = Instance.new("UIScale")
UIScale.Scale = Settings.Scale or 1
UIScale.Parent = Main

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 16)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(105, 70, 190)
MainStroke.Thickness = 2
MainStroke.Parent = Main

--========================================================--
-- DRAG
--========================================================--

local Dragging = false
local DragStart
local StartPosition

local function UpdateDrag(input)

    local Delta = input.Position - DragStart

    Main.Position = UDim2.new(
        StartPosition.X.Scale,
        StartPosition.X.Offset + Delta.X,
        StartPosition.Y.Scale,
        StartPosition.Y.Offset + Delta.Y
    )
end

Main.InputBegan:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then

        Dragging = true
        DragStart = input.Position
        StartPosition = Main.Position
    end
end)

Main.InputEnded:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then

        Dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)

    if Dragging and (
        input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch
    ) then

        UpdateDrag(input)
    end
end)

--========================================================--
-- HEADER
--========================================================--

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, -20, 0, 60)
Header.Position = UDim2.new(0, 10, 0, 10)
Header.BackgroundTransparency = 1
Header.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0.7, 0, 0, 28)
Title.Position = UDim2.new(0, 8, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "🌙 MT7 HUB V3"
Title.TextColor3 = Color3.fromRGB(245, 245, 255)
Title.TextSize = 22
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local Subtitle = Instance.new("TextLabel")
Subtitle.Size = UDim2.new(0.7, 0, 0, 22)
Subtitle.Position = UDim2.new(0, 9, 0, 29)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "ECLIPSE • MOBILE PERFORMANCE"
Subtitle.TextColor3 = Color3.fromRGB(150, 145, 180)
Subtitle.TextSize = 11
Subtitle.Font = Enum.Font.GothamMedium
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.Parent = Header

local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0, 38, 0, 38)
Close.Position = UDim2.new(1, -40, 0, 2)
Close.BackgroundColor3 = Color3.fromRGB(28, 25, 38)
Close.Text = "×"
Close.TextColor3 = Color3.fromRGB(255, 255, 255)
Close.TextSize = 25
Close.Font = Enum.Font.GothamBold
Close.Parent = Header

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 10)
CloseCorner.Parent = Close

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, -20, 0, 25)
Status.Position = UDim2.new(0, 10, 0, 70)
Status.BackgroundTransparency = 1
Status.Text = "STATUS: FREE"
Status.TextColor3 = Color3.fromRGB(100, 220, 140)
Status.TextSize = 13
Status.Font = Enum.Font.GothamBold
Status.TextXAlignment = Enum.TextXAlignment.Center
Status.Parent = Main

--========================================================--
-- PANELS
--========================================================--

local FreePanel = Instance.new("Frame")
FreePanel.Name = "FreePanel"
FreePanel.Size = UDim2.new(0.47, -5, 1, -115)
FreePanel.Position = UDim2.new(0, 10, 0, 105)
FreePanel.BackgroundColor3 = Color3.fromRGB(14, 14, 22)
FreePanel.BorderSizePixel = 0
FreePanel.Parent = Main

local ProPanel = FreePanel:Clone()
ProPanel.Name = "ProPanel"
ProPanel.Position = UDim2.new(0.53, 0, 0, 105)
ProPanel.Parent = Main

local function StylePanel(panel, color)

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 13)
    Corner.Parent = panel

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = color
    Stroke.Thickness = 1.4
    Stroke.Transparency = 0.15
    Stroke.Parent = panel
end

StylePanel(FreePanel, Color3.fromRGB(75, 95, 170))
StylePanel(ProPanel, Color3.fromRGB(115, 75, 210))

local FreeTitle = Instance.new("TextLabel")
FreeTitle.Size = UDim2.new(1, -20, 0, 34)
FreeTitle.Position = UDim2.new(0, 10, 0, 8)
FreeTitle.BackgroundTransparency = 1
FreeTitle.Text = "🆓 FREE"
FreeTitle.TextColor3 = Color3.fromRGB(235, 240, 255)
FreeTitle.TextSize = 18
FreeTitle.Font = Enum.Font.GothamBold
FreeTitle.TextXAlignment = Enum.TextXAlignment.Left
FreeTitle.Parent = FreePanel

local ProTitle = Instance.new("TextLabel")
ProTitle.Size = UDim2.new(1, -20, 0, 34)
ProTitle.Position = UDim2.new(0, 10, 0, 8)
ProTitle.BackgroundTransparency = 1
ProTitle.Text = "🔐 PRO • ECLIPSE"
ProTitle.TextColor3 = Color3.fromRGB(225, 205, 255)
ProTitle.TextSize = 18
ProTitle.Font = Enum.Font.GothamBold
ProTitle.TextXAlignment = Enum.TextXAlignment.Left
ProTitle.Parent = ProPanel

local function CreateScroll(parent)

    local Scroll = Instance.new("ScrollingFrame")
    Scroll.Size = UDim2.new(1, -16, 1, -52)
    Scroll.Position = UDim2.new(0, 8, 0, 45)
    Scroll.BackgroundTransparency = 1
    Scroll.BorderSizePixel = 0
    Scroll.ScrollBarThickness = 3
    Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Scroll.Parent = parent

    local Padding = Instance.new("UIPadding")
    Padding.PaddingBottom = UDim.new(0, 8)
    Padding.PaddingLeft = UDim.new(0, 2)
    Padding.PaddingRight = UDim.new(0, 2)
    Padding.Parent = Scroll

    local Layout = Instance.new("UIListLayout")
    Layout.Padding = UDim.new(0, 7)
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.Parent = Scroll

    return Scroll
end

local FreeScroll = CreateScroll(FreePanel)
local ProScroll = CreateScroll(ProPanel)

local function CreateBoostButton(parent, text, locked)

    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, 0, 0, 40)
    Button.BackgroundColor3 = Color3.fromRGB(23, 23, 34)
    Button.BorderSizePixel = 0
    Button.AutoButtonColor = false
    Button.Text = locked and ("🔒 " .. text) or (text .. "  •  OFF")
    Button.TextColor3 = Color3.fromRGB(230, 230, 245)
    Button.TextSize = 12
    Button.Font = Enum.Font.GothamSemibold
    Button.Parent = parent

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 9)
    Corner.Parent = Button

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(55, 55, 75)
    Stroke.Thickness = 1
    Stroke.Parent = Button

    return Button
end

local FreeButtons = {}
local ProButtons = {}

local FreeDefinitions = {
    {"⚡ FPS Boost", "FPSBoost"},
    {"🧹 Anti-Texture", "AntiTexture"},
    {"📉 Low Graphics", "LowGraphics"},
    {"✨ Particle Reduce", "ParticleReduce"},
    {"💡 Lighting Optimize", "LightingOptimize"},
    {"🌋 Terrain Optimize", "TerrainOptimize"},
    {"🧊 Anti-Freeze", "AntiFreeze"},
    {"🧠 Smart Free Boost", "SmartFreeBoost"},
    {"📱 Mobile Mode", "MobileMode"},
    {"🔋 Power Saver", "PowerSaver"}
}

for _, info in ipairs(FreeDefinitions) do

    local Button = CreateBoostButton(
        FreeScroll,
        info[1],
        false
    )

    FreeButtons[info[2]] = Button

    Button.MouseButton1Click:Connect(function()

        local enabled = not FreeStates[info[2]]

        SetFree(
            info[2],
            enabled
        )

        Button.Text = info[1] ..
            (enabled and "  •  ON" or "  •  OFF")

        Button.BackgroundColor3 = enabled
            and Color3.fromRGB(35, 65, 48)
            or Color3.fromRGB(23, 23, 34)
    end)
end

local ProDefinitions = {
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

for _, info in ipairs(ProDefinitions) do

    local Button = CreateBoostButton(
        ProScroll,
        info[1],
        true
    )

    ProButtons[info[2]] = Button

    Button.MouseButton1Click:Connect(function()

        if not ProUnlocked then
            return
        end

        local current = PRO.GetStatus(info[2])
        local enabled = not current

        PRO.Set(
            info[2],
            enabled
        )

        Button.Text = info[1] ..
            (enabled and "  •  ON" or "  •  OFF")

        Button.BackgroundColor3 = enabled
            and Color3.fromRGB(48, 35, 70)
            or Color3.fromRGB(23, 23, 34)
    end)
end

--========================================================--
-- KEY PANEL
--========================================================--

local KeyFrame = Instance.new("Frame")
KeyFrame.Size = UDim2.new(1, -20, 0, 105)
KeyFrame.Position = UDim2.new(0, 10, 1, -115)
KeyFrame.BackgroundColor3 = Color3.fromRGB(12, 11, 18)
KeyFrame.BorderSizePixel = 0
KeyFrame.Parent = Main

local KeyCorner = Instance.new("UICorner")
KeyCorner.CornerRadius = UDim.new(0, 12)
KeyCorner.Parent = KeyFrame

local KeyStroke = Instance.new("UIStroke")
KeyStroke.Color = Color3.fromRGB(75, 55, 120)
KeyStroke.Thickness = 1
KeyStroke.Parent = KeyFrame

local KeyTitle = Instance.new("TextLabel")
KeyTitle.Size = UDim2.new(0.28, 0, 0, 24)
KeyTitle.Position = UDim2.new(0, 12, 0, 8)
KeyTitle.BackgroundTransparency = 1
KeyTitle.Text = "🔑 PRO KEY"
KeyTitle.TextColor3 = Color3.fromRGB(220, 205, 245)
KeyTitle.TextSize = 13
KeyTitle.Font = Enum.Font.GothamBold
KeyTitle.TextXAlignment = Enum.TextXAlignment.Left
KeyTitle.Parent = KeyFrame

local KeyBox = Instance.new("TextBox")
KeyBox.Size = UDim2.new(0.42, 0, 0, 36)
KeyBox.Position = UDim2.new(0.28, 0, 0, 7)
KeyBox.BackgroundColor3 = Color3.fromRGB(24, 23, 34)
KeyBox.BorderSizePixel = 0
KeyBox.PlaceholderText = "Digite sua chave..."
KeyBox.PlaceholderColor3 = Color3.fromRGB(115, 110, 130)
KeyBox.Text = ""
KeyBox.TextColor3 = Color3.fromRGB(240, 240, 255)
KeyBox.TextSize = 12
KeyBox.Font = Enum.Font.GothamMedium
KeyBox.ClearTextOnFocus = false
KeyBox.Parent = KeyFrame

local KeyBoxCorner = Instance.new("UICorner")
KeyBoxCorner.CornerRadius = UDim.new(0, 8)
KeyBoxCorner.Parent = KeyBox

local Verify = Instance.new("TextButton")
Verify.Size = UDim2.new(0.23, 0, 0, 36)
Verify.Position = UDim2.new(0.73, 0, 0, 7)
Verify.BackgroundColor3 = Color3.fromRGB(72, 45, 120)
Verify.BorderSizePixel = 0
Verify.Text = "VERIFICAR"
Verify.TextColor3 = Color3.fromRGB(255, 255, 255)
Verify.TextSize = 11
Verify.Font = Enum.Font.GothamBold
Verify.Parent = KeyFrame

local VerifyCorner = Instance.new("UICorner")
VerifyCorner.CornerRadius = UDim.new(0, 8)
VerifyCorner.Parent = Verify

local KeyStatus = Instance.new("TextLabel")
KeyStatus.Size = UDim2.new(1, -24, 0, 25)
KeyStatus.Position = UDim2.new(0, 12, 0, 50)
KeyStatus.BackgroundTransparency = 1
KeyStatus.Text = "🔒 PRO bloqueado"
KeyStatus.TextColor3 = Color3.fromRGB(155, 145, 175)
KeyStatus.TextSize = 11
KeyStatus.Font = Enum.Font.GothamMedium
KeyStatus.TextXAlignment = Enum.TextXAlignment.Left
KeyStatus.Parent = KeyFrame

--========================================================--
-- ECLIPSE EFFECT
--========================================================--

local Eclipse = Instance.new("Frame")
Eclipse.Size = UDim2.new(1, 0, 1, 0)
Eclipse.Position = UDim2.new(0, 0, 0, 0)
Eclipse.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Eclipse.BackgroundTransparency = 1
Eclipse.BorderSizePixel = 0
Eclipse.Visible = false
Eclipse.ZIndex = 100
Eclipse.Parent = Gui

local EclipseCircle = Instance.new("ImageLabel")
EclipseCircle.AnchorPoint = Vector2.new(0.5, 0.5)
EclipseCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
EclipseCircle.Size = UDim2.new(0, 80, 0, 80)
EclipseCircle.BackgroundTransparency = 1
EclipseCircle.Image = "rbxassetid://7072719740"
EclipseCircle.ImageTransparency = 1
EclipseCircle.ZIndex = 101
EclipseCircle.Parent = Eclipse

local EclipseText = Instance.new("TextLabel")
EclipseText.AnchorPoint = Vector2.new(0.5, 0.5)
EclipseText.Position = UDim2.new(0.5, 0, 0.68, 0)
EclipseText.Size = UDim2.new(0.8, 0, 0, 45)
EclipseText.BackgroundTransparency = 1
EclipseText.Text = "MT7 PRO UNLOCKED"
EclipseText.TextColor3 = Color3.fromRGB(255, 255, 255)
EclipseText.TextTransparency = 1
EclipseText.TextSize = 22
EclipseText.Font = Enum.Font.GothamBold
EclipseText.ZIndex = 102
EclipseText.Parent = Eclipse

local function PlayEclipse()

    Eclipse.Visible = true
    Eclipse.BackgroundTransparency = 1
    EclipseCircle.Size = UDim2.new(0, 60, 0, 60)
    EclipseCircle.ImageTransparency = 1
    EclipseText.TextTransparency = 1

    local FadeIn = TweenService:Create(
        Eclipse,
        TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {
            BackgroundTransparency = 0.08
        }
    )

    local CircleIn = TweenService:Create(
        EclipseCircle,
        TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {
            Size = UDim2.new(0, 230, 0, 230),
            ImageTransparency = 0
        }
    )

    local TextIn = TweenService:Create(
        EclipseText,
        TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {
            TextTransparency = 0
        }
    )

    FadeIn:Play()
    CircleIn:Play()

    task.wait(0.35)
    TextIn:Play()

    task.wait(1.2)

    local FadeOut = TweenService:Create(
        Eclipse,
        TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        {
            BackgroundTransparency = 1
        }
    )

    local CircleOut = TweenService:Create(
        EclipseCircle,
        TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        {
            ImageTransparency = 1,
            Size = UDim2.new(0, 300, 0, 300)
        }
    )

    local TextOut = TweenService:Create(
        EclipseText,
        TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        {
            TextTransparency = 1
        }
    )

    FadeOut:Play()
    CircleOut:Play()
    TextOut:Play()

    task.wait(0.65)

    Eclipse.Visible = false
end

--========================================================--
-- PRO UNLOCK
--========================================================--

local function UnlockPRO()

    ProUnlocked = true

    PRO.SetVerified(true)

    Status.Text = "STATUS: PRO • ECLIPSE"
    Status.TextColor3 = Color3.fromRGB(205, 150, 255)

    KeyStatus.Text = "✅ PRO desbloqueado!"
    KeyStatus.TextColor3 = Color3.fromRGB(120, 230, 160)

    Verify.Text = "ATIVO"
    Verify.BackgroundColor3 = Color3.fromRGB(35, 95, 60)

    for _, info in ipairs(ProDefinitions) do

        local Button = ProButtons[info[2]]

        if Button then
            local enabled = PRO.GetStatus(info[2])

            Button.Text = info[1] ..
                (enabled and "  •  ON" or "  •  OFF")

            Button.BackgroundColor3 = enabled
                and Color3.fromRGB(48, 35, 70)
                or Color3.fromRGB(23, 23, 34)
        end
    end

    task.spawn(PlayEclipse)
end

Verify.MouseButton1Click:Connect(function()

    if ProUnlocked then
        return
    end

    local entered = tostring(KeyBox.Text)
    entered = entered:gsub("^%s+", ""):gsub("%s+$", "")

    if VALID_KEYS[entered] then

        UnlockPRO()

    else

        KeyStatus.Text = "❌ Chave inválida"
        KeyStatus.TextColor3 = Color3.fromRGB(240, 100, 110)

        KeyBox.Text = ""

        task.delay(2, function()

            if not ProUnlocked then
                KeyStatus.Text = "🔒 PRO bloqueado"
                KeyStatus.TextColor3 = Color3.fromRGB(155, 145, 175)
            end

        end)
    end
end)

--========================================================--
-- CLOSE BUTTON
--========================================================--

Close.MouseButton1Click:Connect(function()

    Main.Visible = false

end)

--========================================================--
-- FLOATING MT7 BUTTON
--========================================================--

local FloatButton = Instance.new("TextButton")
FloatButton.Name = "MT7Float"
FloatButton.Size = UDim2.new(0, 54, 0, 54)
FloatButton.Position = UDim2.new(0, 18, 0.65, 0)
FloatButton.BackgroundColor3 = Color3.fromRGB(15, 13, 22)
FloatButton.BorderSizePixel = 0
FloatButton.Text = "MT7"
FloatButton.TextColor3 = Color3.fromRGB(220, 190, 255)
FloatButton.TextSize = 15
FloatButton.Font = Enum.Font.GothamBold
FloatButton.ZIndex = 50
FloatButton.Parent = Gui

local FloatCorner = Instance.new("UICorner")
FloatCorner.CornerRadius = UDim.new(1, 0)
FloatCorner.Parent = FloatButton

local FloatStroke = Instance.new("UIStroke")
FloatStroke.Color = Color3.fromRGB(110, 70, 190)
FloatStroke.Thickness = 2
FloatStroke.Parent = FloatButton

FloatButton.MouseButton1Click:Connect(function()

    Main.Visible = not Main.Visible

end)

--========================================================--
-- FLOAT BUTTON DRAG
--========================================================--

local FloatDragging = false
local FloatStart
local FloatPosition

FloatButton.InputBegan:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then

        FloatDragging = true
        FloatStart = input.Position
        FloatPosition = FloatButton.Position
    end
end)

FloatButton.InputEnded:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then

        FloatDragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)

    if FloatDragging and (
        input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch
    ) then

        local Delta = input.Position - FloatStart

        FloatButton.Position = UDim2.new(
            FloatPosition.X.Scale,
            FloatPosition.X.Offset + Delta.X,
            FloatPosition.Y.Scale,
            FloatPosition.Y.Offset + Delta.Y
        )
    end
end)

--========================================================--
--                    MT7 MONITOR                        --
--========================================================--

local MonitorEnabled = true

pcall(function()
    Monitor.SetVisible(true)
end)

pcall(function()
    Monitor.Start()
end)

--========================================================--
--                 MONITOR FALLBACK                      --
--========================================================--

local MonitorFrame = Instance.new("Frame")
MonitorFrame.Name = "PerformanceMonitor"
MonitorFrame.Size = UDim2.new(0, 150, 0, 58)
MonitorFrame.Position = UDim2.new(1, -160, 0, 12)
MonitorFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
MonitorFrame.BackgroundTransparency = 0.12
MonitorFrame.BorderSizePixel = 0
MonitorFrame.ZIndex = 40
MonitorFrame.Parent = Gui

local MonitorCorner = Instance.new("UICorner")
MonitorCorner.CornerRadius = UDim.new(0, 10)
MonitorCorner.Parent = MonitorFrame

local MonitorStroke = Instance.new("UIStroke")
MonitorStroke.Color = Color3.fromRGB(85, 65, 145)
MonitorStroke.Thickness = 1
MonitorStroke.Parent = MonitorFrame

local FPSLabel = Instance.new("TextLabel")
FPSLabel.Size = UDim2.new(1, -12, 0, 23)
FPSLabel.Position = UDim2.new(0, 6, 0, 4)
FPSLabel.BackgroundTransparency = 1
FPSLabel.Text = "FPS: --"
FPSLabel.TextColor3 = Color3.fromRGB(125, 235, 160)
FPSLabel.TextSize = 12
FPSLabel.Font = Enum.Font.GothamBold
FPSLabel.TextXAlignment = Enum.TextXAlignment.Left
FPSLabel.Parent = MonitorFrame

local PingLabel = Instance.new("TextLabel")
PingLabel.Size = UDim2.new(1, -12, 0, 23)
PingLabel.Position = UDim2.new(0, 6, 0, 28)
PingLabel.BackgroundTransparency = 1
PingLabel.Text = "PING: --"
PingLabel.TextColor3 = Color3.fromRGB(170, 195, 255)
PingLabel.TextSize = 12
PingLabel.Font = Enum.Font.GothamBold
PingLabel.TextXAlignment = Enum.TextXAlignment.Left
PingLabel.Parent = MonitorFrame

local FPSValue = 60
local FrameCounter = 0
local LastFPSUpdate = os.clock()

RunService = game:GetService("RunService")

RunService.RenderStepped:Connect(function()

    if not MonitorEnabled then
        return
    end

    FrameCounter += 1

    local Now = os.clock()

    if Now - LastFPSUpdate >= 1 then

        FPSValue = math.floor(
            FrameCounter / (Now - LastFPSUpdate)
        )

        FrameCounter = 0
        LastFPSUpdate = Now

        FPSLabel.Text = "FPS: " .. tostring(FPSValue)

        if FPSValue >= 55 then
            FPSLabel.TextColor3 = Color3.fromRGB(120, 235, 155)

        elseif FPSValue >= 30 then
            FPSLabel.TextColor3 = Color3.fromRGB(240, 210, 100)

        else
            FPSLabel.TextColor3 = Color3.fromRGB(240, 105, 110)
        end
    end
end)

task.spawn(function()

    while Gui.Parent do

        if MonitorEnabled then

            local Ping = "--"

            pcall(function()

                local Stats = game:GetService("Stats")
                local Network = Stats:FindFirstChild("Network")

                if Network then

                    local ServerStats =
                        Network:FindFirstChild("ServerStatsItem")

                    if ServerStats then

                        local DataPing =
                            ServerStats:FindFirstChild("Data Ping")

                        if DataPing then
                            Ping = tostring(
                                math.floor(
                                    DataPing:GetValue()
                                )
                            ) .. " ms"
                        end
                    end
                end
            end)

            PingLabel.Text = "PING: " .. Ping
        end

        task.wait(1)
    end
end)

--========================================================--
--                  SETTINGS PANEL                       --
--========================================================--

local SettingsButton = Instance.new("TextButton")
SettingsButton.Size = UDim2.new(0, 42, 0, 42)
SettingsButton.Position = UDim2.new(1, -52, 0, 72)
SettingsButton.BackgroundColor3 = Color3.fromRGB(23, 21, 32)
SettingsButton.BorderSizePixel = 0
SettingsButton.Text = "⚙"
SettingsButton.TextColor3 = Color3.fromRGB(225, 215, 250)
SettingsButton.TextSize = 20
SettingsButton.Font = Enum.Font.GothamBold
SettingsButton.ZIndex = 45
SettingsButton.Parent = Gui

local SettingsCorner = Instance.new("UICorner")
SettingsCorner.CornerRadius = UDim.new(0, 10)
SettingsCorner.Parent = SettingsButton

local SettingsStroke = Instance.new("UIStroke")
SettingsStroke.Color = Color3.fromRGB(90, 70, 145)
SettingsStroke.Thickness = 1
SettingsStroke.Parent = SettingsButton

local SettingsPanel = Instance.new("Frame")
SettingsPanel.Size = UDim2.new(0, 260, 0, 330)
SettingsPanel.Position = UDim2.new(0.5, -130, 0.5, -165)
SettingsPanel.BackgroundColor3 = Color3.fromRGB(10, 10, 16)
SettingsPanel.BorderSizePixel = 0
SettingsPanel.Visible = false
SettingsPanel.ZIndex = 70
SettingsPanel.Parent = Gui

local SettingsPanelCorner = Instance.new("UICorner")
SettingsPanelCorner.CornerRadius = UDim.new(0, 15)
SettingsPanelCorner.Parent = SettingsPanel

local SettingsPanelStroke = Instance.new("UIStroke")
SettingsPanelStroke.Color = Color3.fromRGB(105, 75, 175)
SettingsPanelStroke.Thickness = 2
SettingsPanelStroke.Parent = SettingsPanel

local SettingsTitle = Instance.new("TextLabel")
SettingsTitle.Size = UDim2.new(1, -20, 0, 38)
SettingsTitle.Position = UDim2.new(0, 10, 0, 8)
SettingsTitle.BackgroundTransparency = 1
SettingsTitle.Text = "⚙ MT7 SETTINGS"
SettingsTitle.TextColor3 = Color3.fromRGB(240, 230, 255)
SettingsTitle.TextSize = 17
SettingsTitle.Font = Enum.Font.GothamBold
SettingsTitle.TextXAlignment = Enum.TextXAlignment.Left
SettingsTitle.ZIndex = 71
SettingsTitle.Parent = SettingsPanel

local SettingsClose = Instance.new("TextButton")
SettingsClose.Size = UDim2.new(0, 30, 0, 30)
SettingsClose.Position = UDim2.new(1, -38, 0, 8)
SettingsClose.BackgroundColor3 = Color3.fromRGB(30, 27, 40)
SettingsClose.BorderSizePixel = 0
SettingsClose.Text = "×"
SettingsClose.TextColor3 = Color3.fromRGB(255, 255, 255)
SettingsClose.TextSize = 20
SettingsClose.Font = Enum.Font.GothamBold
SettingsClose.ZIndex = 72
SettingsClose.Parent = SettingsPanel

local SettingsCloseCorner = Instance.new("UICorner")
SettingsCloseCorner.CornerRadius = UDim.new(0, 8)
SettingsCloseCorner.Parent = SettingsClose

local SettingsScroll = Instance.new("ScrollingFrame")
SettingsScroll.Size = UDim2.new(1, -20, 1, -58)
SettingsScroll.Position = UDim2.new(0, 10, 0, 50)
SettingsScroll.BackgroundTransparency = 1
SettingsScroll.BorderSizePixel = 0
SettingsScroll.ScrollBarThickness = 3
SettingsScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
SettingsScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
SettingsScroll.ZIndex = 71
SettingsScroll.Parent = SettingsPanel

local SettingsLayout = Instance.new("UIListLayout")
SettingsLayout.Padding = UDim.new(0, 7)
SettingsLayout.SortOrder = Enum.SortOrder.LayoutOrder
SettingsLayout.Parent = SettingsScroll

local function CreateSettingButton(text)

    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, 0, 0, 38)
    Button.BackgroundColor3 = Color3.fromRGB(22, 21, 31)
    Button.BorderSizePixel = 0
    Button.Text = text
    Button.TextColor3 = Color3.fromRGB(225, 225, 240)
    Button.TextSize = 11
    Button.Font = Enum.Font.GothamSemibold
    Button.ZIndex = 72
    Button.Parent = SettingsScroll

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = Button

    return Button
end

local MoonButton = CreateSettingButton("🌙 Moon: ON")

local MonitorButton = CreateSettingButton("📊 Monitor: ON")

local ThermalButton = CreateSettingButton("🌡️ Thermal Guard: OFF")

local ScaleButton = CreateSettingButton("📐 UI Scale: " ..
    tostring(Settings.Scale or 1))

local FPSCapButton = CreateSettingButton("🎯 FPS Cap: " ..
    tostring(Settings.FPSCap or 60))

--========================================================--
--                  SETTINGS ACTIONS                     --
--========================================================--

MoonButton.MouseButton1Click:Connect(function()

    local Current = true

    pcall(function()
        Current = Settings.MoonEnabled
    end)

    Current = not Current

    pcall(function()
        Settings.SetMoon(Current)
    end)

    Settings.MoonEnabled = Current

    MoonButton.Text =
        "🌙 Moon: " .. (Current and "ON" or "OFF")
end)

MonitorButton.MouseButton1Click:Connect(function()

    MonitorEnabled = not MonitorEnabled

    if MonitorEnabled then

        MonitorFrame.Visible = true

        pcall(function()
            Monitor.SetVisible(true)
        end)

        pcall(function()
            Monitor.Start()
        end)

        MonitorButton.Text = "📊 Monitor: ON"

    else

        MonitorFrame.Visible = false

        pcall(function()
            Monitor.SetVisible(false)
        end)

        pcall(function()
            Monitor.Stop()
        end)

        MonitorButton.Text = "📊 Monitor: OFF"
    end
end)

ThermalButton.MouseButton1Click:Connect(function()

    local Enabled = false

    pcall(function()
        Enabled = Settings.ThermalGuard
    end)

    Enabled = not Enabled

    Settings.ThermalGuard = Enabled

    if Enabled then

        pcall(function()
            Thermal.Enable()
        end)

        pcall(function()
            Thermal.Apply()
        end)

        ThermalButton.Text = "🌡️ Thermal Guard: ON"

    else

        pcall(function()
            Thermal.Disable()
        end)

        ThermalButton.Text = "🌡️ Thermal Guard: OFF"
    end
end)

ScaleButton.MouseButton1Click:Connect(function()

    local Current = tonumber(Settings.Scale) or 1

    local NewScale

    if Current >= 1.2 then
        NewScale = 0.85

    elseif Current >= 1 then
        NewScale = 1.1

    else
        NewScale = 1.2
    end

    Settings.Scale = NewScale

    UIScale.Scale = NewScale

    pcall(function()
        Settings.SetScale(NewScale)
    end)

    ScaleButton.Text =
        "📐 UI Scale: " .. tostring(NewScale)
end)

--========================================================--
--                  FPS CAP SYSTEM                       --
--========================================================--

local FPSCaps = {
    30,
    40,
    50,
    60,
    75,
    90,
    120,
    0
}

local FPSCapIndex = 4

local function SetFPSCap(value)

    Settings.FPSCap = value

    pcall(function()
        Settings.SetFPSCap(value)
    end)

    if type(setfpscap) == "function" then

        pcall(function()

            if value == 0 then
                setfpscap(999)

            else
                setfpscap(value)
            end

        end)
    end

    FPSCapButton.Text =
        "🎯 FPS Cap: " ..
        (value == 0 and "UNLIMITED" or tostring(value))
end

FPSCapButton.MouseButton1Click:Connect(function()

    FPSCapIndex += 1

    if FPSCapIndex > #FPSCaps then
        FPSCapIndex = 1
    end

    SetFPSCap(
        FPSCaps[FPSCapIndex]
    )
end)

--========================================================--
--                  SETTINGS WINDOW                      --
--========================================================--

SettingsButton.MouseButton1Click:Connect(function()

    SettingsPanel.Visible =
        not SettingsPanel.Visible
end)

SettingsClose.MouseButton1Click:Connect(function()

    SettingsPanel.Visible = false
end)

--========================================================--
--                    THEMES                             --
--========================================================--

local function ApplyTheme(themeName)

    local ThemeData

    pcall(function()

        if Themes.Get then
            ThemeData = Themes.Get(themeName)

        elseif Themes.Apply then
            Themes.Apply(themeName)
        end

    end)

    if type(ThemeData) ~= "table" then
        return
    end

    if ThemeData.Background then
        Main.BackgroundColor3 =
            ThemeData.Background
    end

    if ThemeData.Panel then
        FreePanel.BackgroundColor3 =
            ThemeData.Panel

        ProPanel.BackgroundColor3 =
            ThemeData.Panel
    end

    if ThemeData.Accent then
        MainStroke.Color =
            ThemeData.Accent
    end
end

--========================================================--
--                ECLIPSE THEME                         --
--========================================================--

pcall(function()

    if Themes.Set then
        Themes.Set("Eclipse")
    end

end)

pcall(function()

    if Themes.Apply then
        Themes.Apply("Eclipse")
    end

end)

--========================================================--
--                THERMAL DEFAULT                       --
--========================================================--

pcall(function()

    if Settings.ThermalGuard then
        Thermal.Enable()
        Thermal.Apply()
    end

end)

--========================================================--
--              PRO INITIAL STATE                       --
--========================================================--

pcall(function()

    PRO.SetVerified(false)

end)

--========================================================--
--               RESPAWN SUPPORT                        --
--========================================================--

local function ReapplyAll()

    task.wait(1)

    pcall(function()
        ApplyFree()
    end)

    if ProUnlocked then

        pcall(function()
            PRO.Apply()
        end)
    end

    if MonitorEnabled then

        pcall(function()
            Monitor.Start()
        end)
    end

    if Settings.ThermalGuard then

        pcall(function()
            Thermal.Enable()
            Thermal.Apply()
        end)
    end
end

Player.CharacterAdded:Connect(function()

    task.spawn(ReapplyAll)

end)

--========================================================--
--             SMART FREE BOOST                         --
--========================================================--

task.spawn(function()

    while Gui.Parent do

        if FreeStates.SmartFreeBoost then

            pcall(function()

                local FPS = FPSValue

                if FPS < 30 then

                    FreeStates.ParticleReduce = true
                    FreeStates.LightingOptimize = true

                    ApplyFree()

                elseif FPS > 55 then

                    FreeStates.ParticleReduce = false
                    FreeStates.LightingOptimize = false

                    ApplyFree()
                end

            end)
        end

        task.wait(4)
    end
end)

--========================================================--
--             MOBILE MODE                              --
--========================================================--

task.spawn(function()

    while Gui.Parent do

        if FreeStates.MobileMode then

            pcall(function()

                for _, obj in ipairs(game:GetDescendants()) do

                    if obj:IsA("ParticleEmitter")
                    or obj:IsA("Trail")
                    or obj:IsA("Beam") then

                        obj.Enabled = false
                    end
                end

            end)
        end

        task.wait(8)
    end
end)
--========================================================--
--                  FINAL CHECKS                         --
--========================================================--

local function RefreshFreeButtons()

    for _, info in ipairs(FreeDefinitions) do

        local Button = FreeButtons[info[2]]

        if Button then

            local enabled = FreeStates[info[2]]

            Button.Text = info[1] ..
                (enabled and "  •  ON" or "  •  OFF")

            Button.BackgroundColor3 = enabled
                and Color3.fromRGB(35, 65, 48)
                or Color3.fromRGB(23, 23, 34)
        end
    end
end

local function RefreshProButtons()

    for _, info in ipairs(ProDefinitions) do

        local Button = ProButtons[info[2]]

        if Button then

            local enabled = false

            pcall(function()
                enabled = PRO.GetStatus(info[2])
            end)

            Button.Text = info[1] ..
                (enabled and "  •  ON" or "  •  OFF")

            Button.BackgroundColor3 = enabled
                and Color3.fromRGB(48, 35, 70)
                or Color3.fromRGB(23, 23, 34)
        end
    end
end

--========================================================--
--                  INITIAL SETTINGS                    --
--========================================================--

pcall(function()

    if Settings.SetScale then
        Settings.SetScale(
            Settings.Scale or 1
        )
    end

end)

pcall(function()

    if Settings.SetFPSCap then
        Settings.SetFPSCap(
            Settings.FPSCap or 60
        )
    end

end)

--========================================================--
--                 INITIAL FREE STATE                   --
--========================================================--

FreeStates.FPSBoost = false
FreeStates.AntiTexture = false
FreeStates.LowGraphics = false
FreeStates.ParticleReduce = false
FreeStates.LightingOptimize = false
FreeStates.TerrainOptimize = false
FreeStates.AntiFreeze = false
FreeStates.SmartFreeBoost = false
FreeStates.MobileMode = false
FreeStates.PowerSaver = false

RefreshFreeButtons()

--========================================================--
--                 INITIAL PRO STATE                    --
--========================================================--

pcall(function()

    PRO.DisableAll()

end)

RefreshProButtons()

--========================================================--
--                 ANTI DUPLICATE                      --
--========================================================--

local MT7Marker = Instance.new("BoolValue")
MT7Marker.Name = "MT7_V3_ACTIVE"
MT7Marker.Value = true
MT7Marker.Parent = Gui

--========================================================--
--                 OPEN ANIMATION                       --
--========================================================--

Main.Size = UDim2.new(
    0.88,
    0,
    0.68,
    0
)

local OpenTween = TweenService:Create(
    Main,
    TweenInfo.new(
        0.45,
        Enum.EasingStyle.Back,
        Enum.EasingDirection.Out
    ),
    {
        Size = UDim2.new(
            0.92,
            0,
            0.74,
            0
        )
    }
)

OpenTween:Play()

--========================================================--
--                 FLOAT ANIMATION                      --
--========================================================--

task.spawn(function()

    while Gui.Parent do

        local Up = TweenService:Create(
            FloatButton,
            TweenInfo.new(
                1.2,
                Enum.EasingStyle.Sine,
                Enum.EasingDirection.InOut
            ),
            {
                Position = UDim2.new(
                    FloatButton.Position.X.Scale,
                    FloatButton.Position.X.Offset,
                    FloatButton.Position.Y.Scale,
                    FloatButton.Position.Y.Offset - 5
                )
            }
        )

        Up:Play()
        Up.Completed:Wait()

        if not Gui.Parent then
            break
        end

        local Down = TweenService:Create(
            FloatButton,
            TweenInfo.new(
                1.2,
                Enum.EasingStyle.Sine,
                Enum.EasingDirection.InOut
            ),
            {
                Position = UDim2.new(
                    FloatButton.Position.X.Scale,
                    FloatButton.Position.X.Offset,
                    FloatButton.Position.Y.Scale,
                    FloatButton.Position.Y.Offset + 5
                )
            }
        )

        Down:Play()
        Down.Completed:Wait()
    end
end)

--========================================================--
--                 CLOSE / CLEANUP                      --
--========================================================--

local function Cleanup()

    pcall(function()
        Monitor.Stop()
    end)

    pcall(function()
        Thermal.Disable()
    end)

    pcall(function()
        PRO.StopDynamic()
    end)

    pcall(function()
        PRO.Destroy()
    end)

    pcall(function()
        FreeRestore()
    end)
end

Gui.AncestryChanged:Connect(function(_, parent)

    if not parent then
        Cleanup()
    end

end)

--========================================================--
--                 SAFE KEY FEEDBACK                   --
--========================================================--

KeyBox.FocusLost:Connect(function(enterPressed)

    if enterPressed and not ProUnlocked then

        local entered = tostring(KeyBox.Text)

        if VALID_KEYS[entered] then
            UnlockPRO()
        end
    end
end)

--========================================================--
--                 VERSION LABEL                       --
--========================================================--

local VersionLabel = Instance.new("TextLabel")
VersionLabel.Size = UDim2.new(0, 100, 0, 18)
VersionLabel.Position = UDim2.new(
    0,
    12,
    1,
    -22
)
VersionLabel.BackgroundTransparency = 1
VersionLabel.Text = "MT7 V" .. VERSION
VersionLabel.TextColor3 = Color3.fromRGB(105, 100, 125)
VersionLabel.TextSize = 9
VersionLabel.Font = Enum.Font.GothamMedium
VersionLabel.TextXAlignment = Enum.TextXAlignment.Left
VersionLabel.ZIndex = 10
VersionLabel.Parent = Main

--========================================================--
--                 FINAL STATUS                         --
--========================================================--

Status.Text = "STATUS: FREE"
Status.TextColor3 = Color3.fromRGB(
    100,
    220,
    140
)

KeyStatus.Text = "🔒 PRO bloqueado"

--========================================================--
--                 STARTUP                              --
--========================================================--

task.spawn(function()

    task.wait(0.5)

    pcall(function()
        ApplyFree()
    end)

    pcall(function()
        Monitor.Start()
    end)

    print("====================================")
    print("        🌙 MT7 HUB V3")
    print("        ECLIPSE EDITION")
    print("====================================")
    print("Version: " .. VERSION)
    print("FREE: ONLINE")
    print("PRO: LOCKED")
    print("Monitor: ONLINE")
    print("Thermal: READY")
    print("Themes: READY")
    print("====================================")

end)

--========================================================--
--                 MT7 HUB V3 READY                     --
--========================================================--

print("🚀 Sistema FREE + PRO pronto!")
print("🌑 Eclipse System pronto!")
print("📊 FPS + Ping Monitor pronto!")
print("🌡️ Thermal Guard pronto!")
print("⚙️ Settings pronto!")
print("🎨 Themes pronto!")
print("🌙 MT7 HUB V3 carregado com sucesso!")
