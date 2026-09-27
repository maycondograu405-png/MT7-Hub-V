--========================================================--
--                     MT7 HUB V2.2                      --
--========================================================--

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer

--========================================================--
-- CONFIG
--========================================================--

local PRO_URL =
    "https://raw.githubusercontent.com/maycondograu405-png/MT7-Hub-V/refs/heads/main/MT7PRO.lua"

local MOON_IMAGE = "rbxassetid://7072719740"

local VALID_KEYS = {
    ["MT-708090"] = true,
    ["MT-123456"] = true,
    ["MT-987654"] = true
}

local IsPRO = false
local MoonEnabled = true
local CurrentFPS = "Unlimited"

--========================================================--
-- STATES
--========================================================--

local States = {
    AntiLag = false,
    AntiTexture = false,
    FPSBoost = false,
    AntiFreeze = false
}

local Original = {}

--========================================================--
-- PROPERTY SYSTEM
--========================================================--

local function Save(Object, Property)
    if not Object then
        return
    end

    Original[Object] = Original[Object] or {}

    if Original[Object][Property] == nil then
        local Success, Value = pcall(function()
            return Object[Property]
        end)

        if Success then
            Original[Object][Property] = Value
        end
    end
end

local function Set(Object, Property, Value)
    Save(Object, Property)

    pcall(function()
        Object[Property] = Value
    end)
end

local function Restore()
    for Object, Properties in pairs(Original) do
        if Object and Object.Parent then
            for Property, Value in pairs(Properties) do
                pcall(function()
                    Object[Property] = Value
                end)
            end
        end
    end
end

--========================================================--
-- FREE OPTIMIZATIONS
--========================================================--

local function ApplyAntiLag()
    if not States.AntiLag then
        return
    end

    Set(Lighting, "GlobalShadows", false)

    for _, Object in ipairs(Lighting:GetChildren()) do
        pcall(function()
            if Object:IsA("PostEffect") then
                Set(Object, "Enabled", false)

            elseif Object:IsA("Atmosphere") then
                Set(Object, "Density", 0)
                Set(Object, "Haze", 0)
                Set(Object, "Glare", 0)
            end
        end)
    end
end

local function ApplyAntiTexture()
    if not States.AntiTexture then
        return
    end

    for _, Object in ipairs(game:GetDescendants()) do
        pcall(function()
            if Object:IsA("Decal")
            or Object:IsA("Texture") then

                Set(Object, "Transparency", 1)

            elseif Object:IsA("SurfaceAppearance") then
                Set(Object, "Enabled", false)
            end
        end)
    end
end

local function ApplyFPSBoost()
    if not States.FPSBoost then
        return
    end

    Set(Lighting, "GlobalShadows", false)

    for _, Object in ipairs(game:GetDescendants()) do
        pcall(function()
            if Object:IsA("ParticleEmitter")
            or Object:IsA("Trail")
            or Object:IsA("Beam")
            or Object:IsA("Smoke")
            or Object:IsA("Fire")
            or Object:IsA("Sparkles") then

                Set(Object, "Enabled", false)
            end
        end)
    end
end

local function ApplyAntiFreeze()
    if not States.AntiFreeze then
        return
    end

    for _, Object in ipairs(game:GetDescendants()) do
        pcall(function()
            if Object:IsA("ParticleEmitter") then
                Set(Object, "Rate", 0)
            end
        end)
    end
end

local function ApplyFree()
    Restore()

    ApplyAntiLag()
    ApplyAntiTexture()
    ApplyFPSBoost()
    ApplyAntiFreeze()
end

local function ToggleFree(Name)
    if States[Name] == nil then
        return
    end

    States[Name] = not States[Name]
    ApplyFree()
end

--========================================================--
-- FPS
--========================================================--

local function SetFPS(Value)
    CurrentFPS = Value

    pcall(function()
        if setfpscap then
            if Value == "Unlimited" then
                setfpscap(999)
            else
                setfpscap(tonumber(Value))
            end
        end
    end)
end

--========================================================--
-- PRO
--========================================================--

local PRO = nil

local function LoadPRO()
    if PRO then
        return true
    end

    local Success, Result = pcall(function()
        local Source = game:HttpGet(PRO_URL)
        local Loader = loadstring(Source)

        if not Loader then
            error("MT7PRO.lua inválido")
        end

        return Loader()
    end)

    if Success and type(Result) == "table" then
        PRO = Result
        return true
    end

    warn("MT7 PRO não carregou.")
    return false
end

local function TogglePRO(Name)
    if not IsPRO then
        return false
    end

    if not LoadPRO() then
        return false
    end

    if PRO.States and PRO.States[Name] ~= nil then
        return PRO.Set(Name, not PRO.States[Name])
    end

    return false
end

--========================================================--
-- GUI
--========================================================--

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MT7HubV22"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true

pcall(function()
    ScreenGui.Parent = game:GetService("CoreGui")
end)

if not ScreenGui.Parent then
    ScreenGui.Parent = Player:WaitForChild("PlayerGui")
end

local Scale = Instance.new("UIScale")
Scale.Scale = 1
Scale.Parent = ScreenGui

--========================================================--
-- MOON
--========================================================--

local Moon = Instance.new("ImageButton")
Moon.Name = "MT7Moon"
Moon.Size = UDim2.fromOffset(58, 58)
Moon.Position = UDim2.new(0, 18, 0.5, -29)
Moon.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
Moon.BorderSizePixel = 0
Moon.Image = MOON_IMAGE
Moon.ScaleType = Enum.ScaleType.Crop
Moon.Parent = ScreenGui

local MoonCorner = Instance.new("UICorner")
MoonCorner.CornerRadius = UDim.new(1, 0)
MoonCorner.Parent = Moon

local MoonStroke = Instance.new("UIStroke")
MoonStroke.Thickness = 2
MoonStroke.Color = Color3.fromRGB(40, 120, 255)
MoonStroke.Parent = Moon

--========================================================--
-- MAIN
--========================================================--

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.fromOffset(340, 450)
Main.Position = UDim2.new(0.5, -170, 0.5, -225)
Main.BackgroundColor3 = Color3.fromRGB(8, 9, 14)
Main.BorderSizePixel = 0
Main.Visible = false
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 14)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Thickness = 1.5
MainStroke.Color = Color3.fromRGB(35, 100, 220)
MainStroke.Parent = Main

--========================================================--
-- HEADER
--========================================================--

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 62)
Header.BackgroundTransparency = 1
Header.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -80, 0, 32)
Title.Position = UDim2.fromOffset(18, 8)
Title.BackgroundTransparency = 1
Title.Text = "MT7 HUB"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 22
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local Version = Instance.new("TextLabel")
Version.Size = UDim2.new(1, -80, 0, 20)
Version.Position = UDim2.fromOffset(19, 35)
Version.BackgroundTransparency = 1
Version.Text = "V2.2 • Performance"
Version.TextColor3 = Color3.fromRGB(100, 150, 255)
Version.Font = Enum.Font.Gotham
Version.TextSize = 11
Version.TextXAlignment = Enum.TextXAlignment.Left
Version.Parent = Header

local Close = Instance.new("TextButton")
Close.Size = UDim2.fromOffset(38, 38)
Close.Position = UDim2.new(1, -48, 0, 12)
Close.BackgroundColor3 = Color3.fromRGB(25, 27, 35)
Close.Text = "×"
Close.TextColor3 = Color3.fromRGB(255, 255, 255)
Close.Font = Enum.Font.GothamBold
Close.TextSize = 24
Close.Parent = Header

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 10)
CloseCorner.Parent = Close

--========================================================--
-- STATUS
--========================================================--

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, -30, 0, 30)
Status.Position = UDim2.fromOffset(15, 66)
Status.BackgroundColor3 = Color3.fromRGB(15, 17, 25)
Status.Text = "FREE • FPS: Unlimited"
Status.TextColor3 = Color3.fromRGB(120, 180, 255)
Status.Font = Enum.Font.GothamSemibold
Status.TextSize = 12
Status.Parent = Main

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(0, 8)
StatusCorner.Parent = Status

--========================================================--
-- SCROLL
--========================================================--

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -20, 1, -112)
Scroll.Position = UDim2.fromOffset(10, 105)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 4
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Scroll.Parent = Main

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 7)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
Layout.Parent = Scroll

local Padding = Instance.new("UIPadding")
Padding.PaddingTop = UDim.new(0, 5)
Padding.PaddingBottom = UDim.new(0, 10)
Padding.Parent = Scroll

--========================================================--
-- HELPERS
--========================================================--

local function Section(Text)
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -10, 0, 28)
    Label.BackgroundTransparency = 1
    Label.Text = Text
    Label.TextColor3 = Color3.fromRGB(90, 145, 255)
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Scroll
end

local function Button(Text)
    local B = Instance.new("TextButton")
    B.Size = UDim2.new(1, -10, 0, 40)
    B.BackgroundColor3 = Color3.fromRGB(17, 19, 27)
    B.BorderSizePixel = 0
    B.Text = Text
    B.TextColor3 = Color3.fromRGB(235, 235, 240)
    B.Font = Enum.Font.GothamSemibold
    B.TextSize = 12
    B.Parent = Scroll

    local C = Instance.new("UICorner")
    C.CornerRadius = UDim.new(0, 9)
    C.Parent = B

    return B
end

local function UpdateStatus()
    Status.Text =
        (IsPRO and "PRO" or "FREE")
        .. " • FPS: "
        .. tostring(CurrentFPS)
end

local function UpdateFreeButton(B, Name)
    B.Text =
        Name
        .. "  ["
        .. (States[Name] and "ON" or "OFF")
        .. "]"
end

--========================================================--
-- FREE
--========================================================--

Section("⚡ OTIMIZAÇÃO FREE")

local AntiLagButton = Button("AntiLag  [OFF]")
AntiLagButton.MouseButton1Click:Connect(function()
    ToggleFree("AntiLag")
    UpdateFreeButton(AntiLagButton, "AntiLag")
end)

local TextureButton = Button("AntiTexture  [OFF]")
TextureButton.MouseButton1Click:Connect(function()
    ToggleFree("AntiTexture")
    UpdateFreeButton(TextureButton, "AntiTexture")
end)

local FPSBoostButton = Button("FPSBoost  [OFF]")
FPSBoostButton.MouseButton1Click:Connect(function()
    ToggleFree("FPSBoost")
    UpdateFreeButton(FPSBoostButton, "FPSBoost")
end)

local FreezeButton = Button("AntiFreeze  [OFF]")
FreezeButton.MouseButton1Click:Connect(function()
    ToggleFree("AntiFreeze")
    UpdateFreeButton(FreezeButton, "AntiFreeze")
end)

--========================================================--
-- PRO
--========================================================--

Section("🔒 OTIMIZAÇÃO PRO")

local PROButtons = {}

local function PROButton(Name)
    local B = Button("🔒 " .. Name .. "  [PRO]")
    PROButtons[Name] = B

    B.MouseButton1Click:Connect(function()
        if not IsPRO then
            Status.Text = "🔒 PRO bloqueado"
            task.delay(2, UpdateStatus)
            return
        end

        TogglePRO(Name)

        if PRO and PRO.States and PRO.States[Name] ~= nil then
            B.Text =
                Name
                .. "  ["
                .. (PRO.States[Name] and "ON" or "OFF")
                .. "]"
        end
    end)

    return B
end

PROButton("UltraFPS")
PROButton("UltraRender")
PROButton("SmartBoost")
PROButton("ParticleBoost")
PROButton("LightingBoost")
PROButton("TerrainBoost")

--========================================================--
-- FPS
--========================================================--

Section("🎯 LIMITE DE FPS")

for _, Value in ipairs({
    "30",
    "40",
    "50",
    "60",
    "75",
    "90",
    "120",
    "Unlimited"
}) do

    local B = Button("FPS " .. Value)

    B.MouseButton1Click:Connect(function()
        SetFPS(Value)
        UpdateStatus()
    end)
end

--========================================================--
-- SETTINGS
--========================================================--

Section("⚙ CONFIGURAÇÕES")

local MoonToggle = Button("🌙 Moon Button  [ON]")

MoonToggle.MouseButton1Click:Connect(function()
    MoonEnabled = not MoonEnabled
    Moon.Visible = MoonEnabled

    MoonToggle.Text =
        "🌙 Moon Button  ["
        .. (MoonEnabled and "ON" or "OFF")
        .. "]"
end)

local RestoreButton = Button("♻ Restaurar otimizações")

RestoreButton.MouseButton1Click:Connect(function()
    States.AntiLag = false
    States.AntiTexture = false
    States.FPSBoost = false
    States.AntiFreeze = false

    Restore()

    if PRO and PRO.DisableAll then
        pcall(function()
            PRO.DisableAll()
        end)
    end

    UpdateFreeButton(AntiLagButton, "AntiLag")
    UpdateFreeButton(TextureButton, "AntiTexture")
    UpdateFreeButton(FPSBoostButton, "FPSBoost")
    UpdateFreeButton(FreezeButton, "AntiFreeze")

    for Name, B in pairs(PROButtons) do
        if IsPRO then
            B.Text = Name .. "  [OFF]"
        else
            B.Text = "🔒 " .. Name .. "  [PRO]"
        end
    end

    Status.Text = "Otimizações restauradas"
    task.delay(2, UpdateStatus)
end)

--========================================================--
-- SCALE
--========================================================--

Section("📐 TAMANHO DA INTERFACE")

for _, Data in ipairs({
    {"70%", 0.70},
    {"85%", 0.85},
    {"100%", 1},
    {"115%", 1.15}
}) do

    local B = Button("Interface " .. Data[1])

    B.MouseButton1Click:Connect(function()
        Scale.Scale = Data[2]
    end)
end

--========================================================--
-- KEY
--========================================================--

Section("🔑 MT7 PRO")

local KeyBox = Instance.new("TextBox")
KeyBox.Size = UDim2.new(1, -10, 0, 40)
KeyBox.BackgroundColor3 = Color3.fromRGB(17, 19, 27)
KeyBox.BorderSizePixel = 0
KeyBox.PlaceholderText = "Digite sua chave PRO..."
KeyBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 130)
KeyBox.Text = ""
KeyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyBox.Font = Enum.Font.Gotham
KeyBox.TextSize = 12
KeyBox.ClearTextOnFocus = false
KeyBox.Parent = Scroll

local KeyCorner = Instance.new("UICorner")
KeyCorner.CornerRadius = UDim.new(0, 9)
KeyCorner.Parent = KeyBox

local Verify = Button("🔓 Ativar PRO")

Verify.MouseButton1Click:Connect(function()
    local Key = tostring(KeyBox.Text):gsub("%s+", "")

    if VALID_KEYS[Key] then
        IsPRO = true

        LoadPRO()

        Status.Text = "✓ MT7 PRO ativado"

        for Name, B in pairs(PROButtons) do
            if PRO and PRO.States and PRO.States[Name] ~= nil then
                B.Text = Name .. "  [OFF]"
            else
                B.Text = Name .. "  [OFF]"
            end
        end

        task.delay(2, UpdateStatus)
    else
        IsPRO = false
        Status.Text = "✕ Chave inválida"

        task.delay(2, UpdateStatus)
    end
end)

--========================================================--
-- FPS MONITOR
--========================================================--

local Monitor = Button("📊 FPS Monitor  [ON]")

local MonitorEnabled = true
local Frames = 0
local LastTime = os.clock()

Monitor.MouseButton1Click:Connect(function()
    MonitorEnabled = not MonitorEnabled

    Monitor.Text =
        "📊 FPS Monitor  ["
        .. (MonitorEnabled and "ON" or "OFF")
        .. "]"
end)

RunService.RenderStepped:Connect(function()
    Frames += 1

    local Now = os.clock()

    if Now - LastTime >= 1 then
        local FPS = Frames

        Frames = 0
        LastTime = Now

        if MonitorEnabled then
            Status.Text =
                (IsPRO and "PRO" or "FREE")
                .. " • FPS: "
                .. tostring(CurrentFPS)
                .. " • LIVE: "
                .. tostring(FPS)
        end
    end
end)

--========================================================--
-- OPEN / CLOSE
--========================================================--

local Open = false

local function OpenMenu()
    if Open then
        return
    end

    Open = true
    Main.Visible = true

    Main.Size = UDim2.fromOffset(300, 400)

    TweenService:Create(
        Main,
        TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {
            Size = UDim2.fromOffset(340, 450)
        }
    ):Play()
end

local function CloseMenu()
    if not Open then
        return
    end

    Open = false

    local Tween = TweenService:Create(
       
