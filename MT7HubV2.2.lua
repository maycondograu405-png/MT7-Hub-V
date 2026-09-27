--========================================================--
--                     MT7 HUB V2.2                      --
--              PERFORMANCE & CUSTOMIZATION              --
--========================================================--

repeat task.wait() until game:IsLoaded()

--// SERVICES
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer

--========================================================--
--                         CONFIG                         --
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
local UIScaleValue = 1

--========================================================--
--                       STATES                          --
--========================================================--

local States = {
    AntiLag = false,
    AntiTexture = false,
    FPSBoost = false,
    AntiFreeze = false
}

local Original = {}

--========================================================--
--                  PROPERTY SYSTEM                     --
--========================================================--

local function SaveProperty(Object, Property)
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

local function SetProperty(Object, Property, Value)
    SaveProperty(Object, Property)

    pcall(function()
        Object[Property] = Value
    end)
end

local function RestoreProperties()
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
--                     FREE BOOSTS                      --
--========================================================--

local function ApplyAntiLag()
    if not States.AntiLag then
        return
    end

    SetProperty(Lighting, "GlobalShadows", false)

    for _, Object in ipairs(Lighting:GetChildren()) do
        pcall(function()
            if Object:IsA("PostEffect") then
                SetProperty(Object, "Enabled", false)
            elseif Object:IsA("Atmosphere") then
                SetProperty(Object, "Density", 0)
                SetProperty(Object, "Haze", 0)
                SetProperty(Object, "Glare", 0)
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
                SetProperty(Object, "Transparency", 1)

            elseif Object:IsA("SurfaceAppearance") then
                SetProperty(Object, "Enabled", false)
            end
        end)
    end
end

local function ApplyFPSBoost()
    if not States.FPSBoost then
        return
    end

    SetProperty(Lighting, "GlobalShadows", false)

    for _, Object in ipairs(game:GetDescendants()) do
        pcall(function()
            if Object:IsA("ParticleEmitter")
            or Object:IsA("Trail")
            or Object:IsA("Beam")
            or Object:IsA("Smoke")
            or Object:IsA("Fire")
            or Object:IsA("Sparkles") then

                SetProperty(Object, "Enabled", false)
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
                SetProperty(Object, "Rate", 0)
            end
        end)
    end
end

local function ApplyFreeOptimizations()
    RestoreProperties()

    ApplyAntiLag()
    ApplyAntiTexture()
    ApplyFPSBoost()
    ApplyAntiFreeze()
end

local function SetFreeState(Name, Enabled)
    if States[Name] == nil then
        return
    end

    States[Name] = Enabled == true
    ApplyFreeOptimizations()
end

--========================================================--
--                      FPS CAP                         --
--========================================================--

local function SetFPS(Value)
    CurrentFPS = Value

    if Value == "Unlimited" then
        pcall(function()
            if setfpscap then
                setfpscap(999)
            end
        end)
        return
    end

    pcall(function()
        if setfpscap then
            setfpscap(tonumber(Value))
        end
    end)
end

--========================================================--
--                       PRO SYSTEM                     --
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
            error("Não foi possível carregar MT7PRO.lua")
        end

        return Loader()
    end)

    if Success and type(Result) == "table" then
        PRO = Result
        return true
    end

    warn("MT7 PRO: falha ao carregar.")
    return false
end

local function SetPRO(Name, Enabled)
    if not IsPRO then
        return false
    end

    if not PRO then
        if not LoadPRO() then
            return false
        end
    end

    if PRO.Set then
        return PRO.Set(Name, Enabled)
    end

    return false
end

--========================================================--
--                         GUI                           --
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

--========================================================--
--                      SCALE                           --
--========================================================--

local Scale = Instance.new("UIScale")
Scale.Scale = UIScaleValue
Scale.Parent = ScreenGui

--========================================================--
--                   MOON BUTTON                        --
--========================================================--

local MoonButton = Instance.new("ImageButton")
MoonButton.Name = "MT7Moon"
MoonButton.Size = UDim2.fromOffset(58, 58)
MoonButton.Position = UDim2.new(0, 18, 0.5, -29)
MoonButton.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
MoonButton.BorderSizePixel = 0
MoonButton.Image = MOON_IMAGE
MoonButton.ScaleType = Enum.ScaleType.Crop
MoonButton.AutoButtonColor = true
MoonButton.Parent = ScreenGui

local MoonCorner = Instance.new("UICorner")
MoonCorner.CornerRadius = UDim.new(1, 0)
MoonCorner.Parent = MoonButton

local MoonStroke = Instance.new("UIStroke")
MoonStroke.Thickness = 2
MoonStroke.Color = Color3.fromRGB(40, 120, 255)
MoonStroke.Parent = MoonButton

--========================================================--
--                      MAIN FRAME                      --
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
--                       HEADER                         --
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
--                       STATUS                         --
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
--                    SCROLL AREA                      --
--========================================================--

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -20, 1, -112)
Scroll.Position = UDim2.fromOffset(10, 105)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 4
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
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
--                    UI HELPERS                       --
--========================================================--

local function CreateSection(Text)
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -10, 0, 28)
    Label.BackgroundTransparency = 1
    Label.Text = Text
    Label.TextColor3 = Color3.fromRGB(90, 145, 255)
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Scroll

    return Label
end

local function CreateButton(Text)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -10, 0, 40)
    Button.BackgroundColor3 = Color3.fromRGB(17, 19, 27)
    Button.BorderSizePixel = 0
    Button.Text = Text
    Button.TextColor3 = Color3.fromRGB(235, 235, 240)
    Button.Font = Enum.Font.GothamSemibold
    Button.TextSize = 12
    Button.AutoButtonColor = true
    Button.Parent = Scroll

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 9)
    Corner.Parent = Button

    local Stroke = Instance.new("UIStroke")
    Stroke.Thickness = 1
    Stroke.Color = Color3.fromRGB(30, 35, 50)
    Stroke.Parent = Button

    return Button
end

local function UpdateStatus()
    local Mode = IsPRO and "PRO" or "FREE"
    Status.Text = Mode .. " • FPS: " .. tostring(CurrentFPS)
end

local function ToggleText(Button, Name, Enabled)
    Button.Text = Name .. "  [" .. (Enabled and "ON" or "OFF") .. "]"
end

--========================================================--
--                    FREE OPTIONS                     --
--========================================================--

CreateSection("⚡ OTIMIZAÇÃO FREE")

local AntiLagButton = CreateButton("Anti-Lag  [OFF]")
AntiLagButton.MouseButton1Click:Connect(function()
    SetFreeState("AntiLag", not States.AntiLag)
    ToggleText(AntiLagButton, "Anti-Lag", States.AntiLag)
end)

local TextureButton = CreateButton("Anti-Texture  [OFF]")
TextureButton.MouseButton1Click:Connect(function()
    SetFreeState("AntiTexture", not States.AntiTexture)
    ToggleText(TextureButton, "Anti-Texture", States.AntiTexture)
end)

local FPSButton = CreateButton("FPS Boost  [OFF]")
FPSButton.MouseButton1Click:Connect(function()
    SetFreeState("FPSBoost", not States.FPSBoost)
    ToggleText(FPSButton, "FPS Boost", States.FPSBoost)
end)

local FreezeButton = CreateButton("Anti-Freeze  [OFF]")
FreezeButton.MouseButton1Click:Connect(function()
    SetFreeState("AntiFreeze", not States.AntiFreeze)
    ToggleText(FreezeButton, "Anti-Freeze", States.AntiFreeze)
end)

--========================================================--
--                     PRO OPTIONS                      --
--========================================================--

CreateSection("🔒 OTIMIZAÇÃO PRO")

local PROButtons = {}

local function CreatePROButton(Name)
    local Button = CreateButton("🔒 " .. Name .. "  [PRO]")
    PROButtons[Name] = Button

    Button.MouseButton1Click:Connect(function()
        if not IsPRO then
            Status.Text = "🔒 PRO bloqueado • Insira a chave"
            task.delay(2, UpdateStatus)
            return
        end

        local Enabled = false

        if PRO and PRO.States and PRO.States[Name] ~= nil then
            Enabled = not PRO.States[Name]
        else
            Enabled = true
        end

        SetPRO(Name, Enabled)

        if PRO and PRO.States and PRO.States[Name] ~= nil then
            ToggleText(Button, Name, PRO.States[Name])
        end
    end)

    return Button
end

local UltraFPSButton = CreatePROButton("UltraFPS")
local UltraRenderButton = CreatePROButton("UltraRender")
local SmartButton = CreatePROButton("SmartBoost")
local ParticleButton = CreatePROButton("ParticleBoost")
local LightingButton = CreatePROButton("LightingBoost")
local TerrainButton = CreatePROButton("TerrainBoost")

--========================================================--
--                       FPS CAP                        --
--========================================================--

CreateSection("🎯 LIMITE DE FPS")

local FPSValues = {
    "30",
    "40",
    "50",
    "60",
    "75",
    "90",
    "120",
    "Unlimited"
}

for _, Value in ipairs(FPSValues) do
    local Button = CreateButton("FPS " .. Value)

    Button.MouseButton1Click:Connect(function()
        SetFPS(Value)
        UpdateStatus()
    end)
end

--========================================================--
--                       SETTINGS                       --
--========================================================--

CreateSection("⚙ CONFIGURAÇÕES")

local MoonToggle = CreateButton("🌙 Moon Button  [ON]")

MoonToggle.MouseButton1Click:Connect(function()
    MoonEnabled = not MoonEnabled
    MoonButton.Visible = MoonEnabled
    MoonToggle.Text = "🌙 Moon Button  [" .. (MoonEnabled and "ON" or "OFF") .. "]"
end)

local RestoreButton = CreateButton("♻ Restaurar otimizações")

RestoreButton.MouseButton1Click:Connect(function()
    States.AntiLag = false
    States.AntiTexture = false
    States.FPSBoost = false
    States.AntiFreeze = false

    if PRO and PRO.DisableAll then
        pcall(function()
            PRO.DisableAll()
        end)
    end

    RestoreProperties()

    ToggleText(AntiLagButton, "Anti-Lag", false)
    ToggleText(TextureButton, "Anti-Texture", false)
    ToggleText(FPSButton, "FPS Boost", false)
    ToggleText(FreezeButton, "Anti-Freeze", false)

    for Name, Button in pairs(PROButtons) do
        if IsPRO then
            ToggleText(Button, Name, false)
        else
            Button.Text = "🔒 " .. Name .. "  [PRO]"
        end
    end

    Status.Text = "Otimizações restauradas"
    task.delay(2, UpdateStatus)
end)

--========================================================--
--                     UI SCALE                        --
--========================================================--

CreateSection("📐 TAMANHO DA INTERFACE")

local ScaleValues = {
    {"70%", 0.70},
    {"85%", 0.85},
    {"100%", 1},
    {"115%", 1.15}
}

for _, Data in ipairs(ScaleValues) do
    local Text = Data[1]
    local Value = Data[2]

    local Button = CreateButton("Interface " .. Text)

    Button.MouseButton1Click:Connect(function()
        UIScaleValue = Value
        Scale.Scale = Value
    end)
end

--========================================================--
--                     PRO KEY                          --
--========================================================--

CreateSection("🔑 MT7 PRO")

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

local VerifyButton = CreateButton("🔓 Ativar PRO")

VerifyButton.MouseButton1Click:Connect(function()
    local Key = tostring(KeyBox.Text):gsub("%s+", "")

    if VALID_KEYS[Key] then
        IsPRO = true

        LoadPRO()

        Status.Text = "✓ MT7 PRO ativado"

        for Name, Button in pairs(PROButtons) do
            if PRO and PRO.States and PRO.States[Name] ~= nil then
                ToggleText(Button, Name, PRO.States[Name])
            else
                Button.Text = Name .. "  [OFF]"
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
--                    FPS MONITOR                       --
--========================================================--

local FPSMonitor = CreateButton("📊 FPS Monitor  [ON]")

local Monitoring = true
local LastUpdate = 0
local Frames = 0

FPSMonitor.MouseButton1Click:Connect(function()
    Monitoring = not Monitoring
    FPSMonitor.Text = "📊 FPS Monitor  [" .. (Monitoring and "ON" or "OFF") .. "]"
end)

RunService.RenderStepped:Connect(function()
    Frames += 1

    local Now = os.clock()

    if Now - LastUpdate >= 1 then
        loc
