--[[
    MT7 HUB V2
    Otimização + Personalização
    Free + PRO Key System
]]

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer

--==================================================
-- CONFIG
--==================================================

local VALID_KEYS = {
    ["MT-708090"] = true,
    ["MT-123456"] = true,
    ["MT-987654"] = true
}

local PRO = false
local CurrentFPS = 60
local SelectedTheme = 1

local Themes = {
    {
        Name = "Azul",
        Main = Color3.fromRGB(20, 90, 170),
        Light = Color3.fromRGB(60, 150, 255)
    },
    {
        Name = "Roxo",
        Main = Color3.fromRGB(90, 40, 170),
        Light = Color3.fromRGB(170, 90, 255)
    },
    {
        Name = "Ciano",
        Main = Color3.fromRGB(20, 130, 150),
        Light = Color3.fromRGB(60, 230, 255)
    },
    {
        Name = "Verde",
        Main = Color3.fromRGB(25, 130, 70),
        Light = Color3.fromRGB(70, 220, 120)
    },
    {
        Name = "Vermelho",
        Main = Color3.fromRGB(150, 35, 45),
        Light = Color3.fromRGB(255, 70, 80)
    }
}

--==================================================
-- GUI
--==================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MT7_HUB_V2"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

pcall(function()
    ScreenGui.Parent = game:GetService("CoreGui")
end)

if not ScreenGui.Parent then
    ScreenGui.Parent = Player:WaitForChild("PlayerGui")
end

--==================================================
-- FUNÇÕES VISUAIS
--==================================================

local function New(class, properties)
    local obj = Instance.new(class)

    for property, value in pairs(properties) do
        pcall(function()
            obj[property] = value
        end)
    end

    return obj
end

local function Corner(parent, radius)
    return New("UICorner", {
        Parent = parent,
        CornerRadius = UDim.new(0, radius)
    })
end

local function Stroke(parent, color, thickness)
    return New("UIStroke", {
        Parent = parent,
        Color = color,
        Thickness = thickness
    })
end

local function Gradient(parent, color1, color2)
    return New("UIGradient", {
        Parent = parent,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, color1),
            ColorSequenceKeypoint.new(1, color2)
        })
    })
end

--==================================================
-- BOTÃO FLUTUANTE
--==================================================

local FloatButton = New("TextButton", {
    Parent = ScreenGui,
    Size = UDim2.new(0, 62, 0, 62),
    Position = UDim2.new(0, 18, 0.5, -31),
    BackgroundColor3 = Color3.fromRGB(5, 8, 15),
    BackgroundTransparency = 0.08,
    Text = "🌙",
    TextSize = 30,
    TextColor3 = Color3.fromRGB(220, 235, 255),
    AutoButtonColor = false
})

Corner(FloatButton, 100)

local FloatStroke = Stroke(
    FloatButton,
    Themes[SelectedTheme].Light,
    2
)

--==================================================
-- PAINEL
--==================================================

local Main = New("Frame", {
    Parent = ScreenGui,
    Size = UDim2.new(0, 340, 0, 430),
    Position = UDim2.new(0.5, -170, 0.5, -215),
    BackgroundColor3 = Color3.fromRGB(3, 5, 10),
    BackgroundTransparency = 0.08,
    Visible = false
})

Corner(Main, 14)

local MainStroke = Stroke(
    Main,
    Themes[SelectedTheme].Main,
    2
)

--==================================================
-- HEADER
--==================================================

local Header = New("Frame", {
    Parent = Main,
    Size = UDim2.new(1, 0, 0, 82),
    BackgroundTransparency = 1
})

local Moon = New("ImageLabel", {
    Parent = Header,
    Size = UDim2.new(0, 64, 0, 64),
    Position = UDim2.new(0, 10, 0, 8),
    BackgroundTransparency = 1,
    Image = "rbxassetid://7072719740",
    ScaleType = Enum.ScaleType.Fit
})

local Title = New("TextLabel", {
    Parent = Header,
    Size = UDim2.new(1, -90, 0, 38),
    Position = UDim2.new(0, 82, 0, 13),
    BackgroundTransparency = 1,
    Text = "MT7 HUB",
    Font = Enum.Font.GothamBold,
    TextSize = 26,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextColor3 = Themes[SelectedTheme].Light
})

local Subtitle = New("TextLabel", {
    Parent = Header,
    Size = UDim2.new(1, -90, 0, 24),
    Position = UDim2.new(0, 82, 0, 46),
    BackgroundTransparency = 1,
    Text = "V2 • Performance & Custom",
    Font = Enum.Font.Gotham,
    TextSize = 12,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextColor3 = Color3.fromRGB(150, 160, 175)
})

--==================================================
-- ABAS
--==================================================

local Tabs = New("Frame", {
    Parent = Main,
    Size = UDim2.new(1, -20, 0, 38),
    Position = UDim2.new(0, 10, 0, 84),
    BackgroundTransparency = 1
})

local TabLayout = New("UIListLayout", {
    Parent = Tabs,
    FillDirection = Enum.FillDirection.Horizontal,
    HorizontalAlignment = Enum.HorizontalAlignment.Center,
    Padding = UDim.new(0, 5)
})

local Pages = {}

local function CreatePage()
    local page = New("ScrollingFrame", {
        Parent = Main,
        Size = UDim2.new(1, -20, 1, -135),
        Position = UDim2.new(0, 10, 0, 128),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false
    })

    New("UIListLayout", {
        Parent = page,
        Padding = UDim.new(0, 8),
        HorizontalAlignment = Enum.HorizontalAlignment.Center
    })

    table.insert(Pages, page)

    return page
end

local HomePage = CreatePage()
local ConfigPage = CreatePage()
local PerformancePage = CreatePage()
local KeyPage = CreatePage()

local function CreateTab(text)
    local button = New("TextButton", {
        Parent = Tabs,
        Size = UDim2.new(0, 76, 0, 34),
        BackgroundColor3 = Color3.fromRGB(10, 14, 22),
        Text = text,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextColor3 = Color3.fromRGB(180, 190, 205),
        AutoButtonColor = false
    })

    Corner(button, 8)

    return button
end

local HomeTab = CreateTab("🏠 Principal")
local ConfigTab = CreateTab("⚙️ Config")
local PerfTab = CreateTab("🚀 FPS")
local KeyTab = CreateTab("🔐 Key")

local function ShowPage(page)
    for _, p in ipairs(Pages) do
        p.Visible = false
    end

    page.Visible = true
end

HomeTab.MouseButton1Click:Connect(function()
    ShowPage(HomePage)
end)

ConfigTab.MouseButton1Click:Connect(function()
    ShowPage(ConfigPage)
end)

PerfTab.MouseButton1Click:Connect(function()
    ShowPage(PerformancePage)
end)

KeyTab.MouseButton1Click:Connect(function()
    ShowPage(KeyPage)
end)

--==================================================
-- OTIMIZAÇÃO
--==================================================

local function Optimize()
    for _, obj in ipairs(game:GetDescendants()) do
        pcall(function()

            if obj:IsA("ParticleEmitter")
            or obj:IsA("Trail")
            or obj:IsA("Beam")
            or obj:IsA("Smoke")
            or obj:IsA("Fire")
            or obj:IsA("Sparkles") then

                obj.Enabled = false

            elseif obj:IsA("PointLight")
            or obj:IsA("SpotLight")
            or obj:IsA("SurfaceLight") then

                obj.Enabled = false

            elseif obj:IsA("PostEffect") then

                obj.Enabled = false

            elseif obj:IsA("Highlight") then

                obj.Enabled = false

            elseif obj:IsA("Decal")
            or obj:IsA("Texture") then

                obj.Transparency = 1

            elseif obj:IsA("SurfaceAppearance") then

                obj.Enabled = false
            end
        end)
    end

    pcall(function()
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 100000
    end)

    pcall(function()
        local terrain = workspace:FindFirstChildOfClass("Terrain")

        if terrain then
            terrain.Decoration = false
        end
    end)
end

local function AntiTexture()
    for _, obj in ipairs(game:GetDescendants()) do
        pcall(function()

            if obj:IsA("Decal") or obj:IsA("Texture") then
                obj.Transparency = 1

            elseif obj:IsA("MeshPart") then
                obj.TextureID = ""

            elseif obj:IsA("SpecialMesh") then
                obj.TextureId = ""

            elseif obj:IsA("SurfaceAppearance") then
                obj.Enabled = false
            end
        end)
    end
end

local function FPSBoost()
    pcall(function()
        Lighting.GlobalShadows = false
    end)

    for _, obj in ipairs(Lighting:GetChildren()) do
        pcall(function()
            if obj:IsA("PostEffect") then
                obj.Enabled = false
            end

            if obj:IsA("Atmosphere") then
                obj.Density = 0
            end
        end)
    end

    Optimize()
end

--==================================================
-- BOTÕES
--==================================================

local function CreateAction(parent, text, callback)
    local button = New("TextButton", {
        Parent = parent,
        Size = UDim2.new(1, -12, 0, 43),
        BackgroundColor3 = Color3.fromRGB(9, 13, 21),
        Text = text,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextColor3 = Color3.fromRGB(220, 230, 245),
        AutoButtonColor = false
    })

    Corner(button, 9)

    local stroke = Stroke(
        button,
        Themes[SelectedTheme].Main,
        1
    )

    button.MouseButton1Click:Connect(function()
        callback(button)
    end)

    return button
end

--==================================================
-- PRINCIPAL
--==================================================

CreateAction(HomePage, "⚡ Anti-Lag", function()
    Optimize()
end)

CreateAction(HomePage, "🧹 Anti-Textura", function()
    AntiTexture()
end)

CreateAction(HomePage, "🚀 FPS Boost", function()
    FPSBoost()
end)

CreateAction(HomePage, "🧊 Anti-Congelamento", function()
    Optimize()
end)

CreateAction(HomePage, "💎 ULTRA BOOST [PRO]", function()
    if not PRO then
        ShowPage(KeyPage)
        return
    end

    FPSBoost()
    AntiTexture()

    pcall(function()
        if setfpscap then
            setfpscap(120)
        end
    end)
end)

CreateAction(HomePage, "🔄 Restaurar Iluminação", function()
    pcall(function()
        Lighting.GlobalShadows = true
        Lighting.FogEnd = 1000
    end)
end)

--==================================================
-- CONFIGURAÇÕES
--==================================================

CreateAction(ConfigPage, "🎨 Trocar Tema", function()
    SelectedTheme += 1

    if SelectedTheme > #Themes then
        SelectedTheme = 1
    end

    local theme = Themes[SelectedTheme]

    MainStroke.Color = theme.Main
    FloatStroke.Color = theme.Light
    Title.TextColor3 = theme.Light
end)

CreateAction(ConfigPage, "🌙 Personalizar Lua", function()
    local Input = New("TextBox", {
        Parent = ScreenGui,
        Size = UDim2.new(0, 280, 0, 48),
        Position = UDim2.new(0.5, -140, 0.5, -24),
        BackgroundColor3 = Color3.fromRGB(5, 8, 14),
        Text = "",
        PlaceholderText = "Digite o ID da imagem...",
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextColor3 = Color3.fromRGB(235, 240, 255),
        PlaceholderColor3 = Color3.fromRGB(120, 130, 145),
        ClearTextOnFocus = false
    })

    Corner(Input, 10)
    Stroke(Input, Themes[SelectedTheme].Main, 2)

    Input.FocusLost:Connect(function()
        local id = Input.Text:gsub("%D", "")

        if id ~= "" then
            Moon.Image = "rbxassetid://" .. id
        end

        Input:Destroy()
    end)
end)

CreateAction(ConfigPage, "✨ Lua ON/OFF", function()
    Moon.Visible = not Moon.Visible
end)

CreateAction(ConfigPage, "🎬 Animações ON/OFF", function()
    -- Controle visual reservado para futuras animações
end)

CreateAction(ConfigPage, "📐 Interface Compacta", function()
    if Main.Size.Y.Offset == 430 then
        Main.Size = UDim2.new(0, 310, 0, 390)
    else
        Main.Size = UDim2.new(0, 340, 0, 430)
    end
end)

--==================================================
-- FPS
--==================================================

local FPSLabel = New("TextLabel", {
    Parent = PerformancePage,
    Size = UDim2.new(1, -12, 0, 40),
    BackgroundTransparency = 1,
    Text = "FPS Máximo: 60",
    Font = Enum.Font.GothamBold,
    TextSize = 15,
    TextColor3 = Themes[SelectedTheme].Light
})

local FPSValues = {
    30, 40, 50, 60, 75, 90, 120
}

for _, fps in ipairs(FPSValues) do
    CreateAction(PerformancePage, "🎮 " .. fps .. " FPS", function()
        CurrentFPS = fps
        FPSLabel.Text = "FPS Máximo: " .. fps

        pcall(function()
            if setfpscap then
                setfpscap(fps)
            end
        end)
    end)
end

CreateAction(PerformancePage, "♾️ FPS Ilimitado", function()
    FPSLabel.Text = "FPS Máximo: Ilimitado"

    pcall(function()
        if setfpscap then
            setfpscap(999)
        end
    end)
end)

CreateAction(PerformancePage, "🤖 Smart Boost [PRO]", function()
    if not PRO then
        ShowPage(KeyPage)
        return
    end

    FPSBoost()

    pcall(function()
        if setfpscap then
            setfpscap(120)
        end
    end)
end)

--==================================================
-- FPS MONITOR
--==================================================

local Monitor = New("TextLabel", {
    Parent = ScreenGui,
    Size = UDim2.new(0, 105, 0, 30),
    Position = UDim2.new(1, -115, 0, 15),
    BackgroundColor3 = Color3.fromRGB(4, 7, 12),
    BackgroundTransparency = 0.15,
    Text = "FPS: --",
    Font = Enum.Font.GothamBold,
    TextSize = 12,
    TextColor3 = Themes[SelectedTheme].Light
})

Corner(Monitor, 8)
Stroke(Monitor, Themes[SelectedTheme].Main, 1)

local frames = 0
local lastTime = tick()

RunService.RenderStepped:Connect(function()
    frames += 1

    if tick() - lastTime >= 1 then
        Monitor.Text = "FPS: " .. frames
        frames = 0
        lastTime = tick()
    end
end)

--==================================================
-- KEY SYSTEM
--==================================================

local KeyStatus = New("TextLabel", {
    Parent = KeyPage,
    Size = UDim2.new(1, -12, 0, 40),
    BackgroundTransparency = 1,
    Text = "🔒 PRO bloqueado",
    Font = Enum.Font.GothamBold,
    TextSize = 14,
    TextColor3 = Color3.fromRGB(220, 225, 235)
})

local KeyInput = New("TextBox", {
    Parent = KeyPage,
    Size = UDim2.new(1, -12, 0, 45),
    BackgroundColor3 = Color3.fromRGB(8, 11, 18),
    Text = "",
    PlaceholderText = "Digite sua key: MT-708090",
    Font = Enum.Font.Gotham,
    TextSize = 13,
    TextColor3 = Color3.fromRGB(235, 240, 255),
    PlaceholderColor3 = Color3.fromRGB(120, 130, 145),
    ClearTextOnFocus = false
})

Corner(KeyInput, 9)
Stroke(KeyInput, Themes[SelectedTheme].Main, 1)

CreateAction(KeyPage, "🔓 Verificar Key", function()
    local key = KeyInput.Text:gsub("%s+", "")

    if VALID_KEYS[key] then
        PRO = true
        KeyStatus.Text = "✅ PRO desbloqueado!"
        KeyStatus.TextColor3 = Color3.fromRGB(80, 230, 120)
    else
        PRO = false
        KeyStatus.Text = "❌ Key inválida"
        KeyStatus.TextColor3 = Color3.fromRGB(255, 80, 80)
    end
end)

CreateAction(KeyPage, "💎 Funções PRO", function()
    if PRO then
        KeyStatus.Text = "✅ Você possui acesso PRO"
    else
        KeyStatus.Text = "🔒 Insira uma key válida"
    end
end)

--==================================================
-- ABRIR / FECHAR
--==================================================

local Open = false

local function TogglePanel()
    Open = not Open

    if Open then
        Main.Visible = true
        Main.Size = UDim2.new(0, 300, 0, 380)

        TweenService:Create(
            Main,
            TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
            {
                Size = UDim2.new(0, 340, 0, 430)
            }
        ):Play()
    else
        local tween = TweenService:Create(
            Main,
            TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
            {
                Size = UDim2.new(0, 300, 0, 380)
            }
        )

        tween:Play()

        task.delay(0.2, function()
            if not Open then
                Main.Visible = false
            end
        end)
    end
end

FloatButton.MouseButton1Click:Connect(TogglePanel)

--==================================================
-- BOTÃO FLUTUANTE ARRASTÁVEL
--==================================================

local dragging = false
local dragStart
local startPos

FloatButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then

        dragging = true
        dragStart = input.Position
        startPos = FloatButton.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not dragging then return end

    if input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch then

        local delta = input.Position - dragStart

        FloatButton.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

--==================================================
-- INICIALIZAÇÃO
--==================================================

ShowPage(HomePage)

print("MT7 HUB V2 carregado!")
