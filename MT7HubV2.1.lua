--========================================================--
--                    MT7 HUB V2.2                       --
--              PERFORMANCE + PRO SYSTEM                 --
--========================================================--

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer

--========================================================--
--                      KEY SYSTEM                        --
--========================================================--

local VALID_KEYS = {
    ["MT-708090"] = true,
    ["MT-123456"] = true,
    ["MT-987654"] = true
}

local IsPRO = false
local PRO = nil

local PRO_URL =
    "https://raw.githubusercontent.com/maycondograu405-png/MT7-Hub-V/refs/heads/main/MT7PRO.lua"

local function LoadPRO()
    if PRO then
        return true
    end

    local success, result = pcall(function()
        local source = game:HttpGet(PRO_URL)
        return loadstring(source)()
    end)

    if success and type(result) == "table" then
        PRO = result
        IsPRO = true
        return true
    end

    warn("MT7: não foi possível carregar MT7PRO.lua")
    return false
end

--========================================================--
--                       STATES                           --
--========================================================--

local States = {
    AntiLag = false,
    AntiTexture = false,
    FPSBoost = false,
    AntiFreeze = false
}

--========================================================--
--                       THEME                            --
--========================================================--

local Themes = {
    {
        Name = "Azul",
        Main = Color3.fromRGB(20,90,170),
        Light = Color3.fromRGB(70,170,255)
    },

    {
        Name = "Roxo",
        Main = Color3.fromRGB(100,45,180),
        Light = Color3.fromRGB(180,100,255)
    },

    {
        Name = "Ciano",
        Main = Color3.fromRGB(20,130,160),
        Light = Color3.fromRGB(70,230,255)
    },

    {
        Name = "Verde",
        Main = Color3.fromRGB(25,130,70),
        Light = Color3.fromRGB(80,230,130)
    },

    {
        Name = "Vermelho",
        Main = Color3.fromRGB(150,35,45),
        Light = Color3.fromRGB(255,80,90)
    }
}

local ThemeIndex = 1
local CurrentFPS = 60
local MoonEnabled = true

--========================================================--
--                  ORIGINAL VALUES                      --
--========================================================--

local Original = {}

local function SaveOriginal(obj, property)

    if not Original[obj] then
        Original[obj] = {}
    end

    if Original[obj][property] == nil then

        local success, value = pcall(function()
            return obj[property]
        end)

        if success then
            Original[obj][property] = value
        end

    end
end

local function SetProperty(obj, property, value)

    SaveOriginal(obj, property)

    pcall(function()
        obj[property] = value
    end)

end

local function RestoreAll()

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
--                  FREE OPTIMIZATION                    --
--========================================================--

local function ApplyFree()

    RestoreAll()

    -- ANTI LAG
    if States.AntiLag then

        for _, obj in ipairs(game:GetDescendants()) do

            pcall(function()

                if obj:IsA("ParticleEmitter")
                or obj:IsA("Trail")
                or obj:IsA("Beam")
                or obj:IsA("Smoke")
                or obj:IsA("Fire")
                or obj:IsA("Sparkles")
                or obj:IsA("Highlight") then

                    SetProperty(obj,"Enabled",false)

                elseif obj:IsA("PointLight")
                or obj:IsA("SpotLight")
                or obj:IsA("SurfaceLight") then

                    SetProperty(obj,"Enabled",false)

                end

            end)

        end

        SetProperty(Lighting,"GlobalShadows",false)

    end

    -- ANTI TEXTURA
    if States.AntiTexture then

        for _, obj in ipairs(game:GetDescendants()) do

            pcall(function()

                if obj:IsA("Decal")
                or obj:IsA("Texture") then

                    SetProperty(obj,"Transparency",1)

                elseif obj:IsA("MeshPart") then

                    SetProperty(obj,"TextureID","")

                elseif obj:IsA("SpecialMesh") then

                    SetProperty(obj,"TextureId","")

                elseif obj:IsA("SurfaceAppearance") then

                    SetProperty(obj,"Enabled",false)

                end

            end)

        end

    end

    -- FPS BOOST
    if States.FPSBoost then

        SetProperty(Lighting,"GlobalShadows",false)

        for _, obj in ipairs(Lighting:GetChildren()) do

            pcall(function()

                if obj:IsA("PostEffect") then
                    SetProperty(obj,"Enabled",false)
                end

                if obj:IsA("Atmosphere") then
                    SetProperty(obj,"Density",0)
                    SetProperty(obj,"Haze",0)
                    SetProperty(obj,"Glare",0)
                end

            end)

        end

        local terrain =
            workspace:FindFirstChildOfClass("Terrain")

        if terrain then
            SetProperty(terrain,"Decoration",false)
        end

    end

    -- ANTI CONGELAMENTO
    if States.AntiFreeze then

        for _, obj in ipairs(game:GetDescendants()) do

            pcall(function()

                if obj:IsA("ParticleEmitter")
                or obj:IsA("Trail")
                or obj:IsA("Beam")
                or obj:IsA("Smoke")
                or obj:IsA("Fire")
                or obj:IsA("Sparkles")
                or obj:IsA("Highlight") then

                    SetProperty(obj,"Enabled",false)

                end

            end)

        end

    end

end

local function ToggleFree(name)

    States[name] = not States[name]

    ApplyFree()

    return States[name]
end

--========================================================--
--                         GUI                            --
--========================================================--

local ScreenGui = Instance.new("ScreenGui")

ScreenGui.Name = "MT7_HUB_V22"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

pcall(function()
    ScreenGui.Parent = game:GetService("CoreGui")
end)

if not ScreenGui.Parent then
    ScreenGui.Parent = Player:WaitForChild("PlayerGui")
end

--========================================================--
--                       SCALE                            --
--========================================================--

local UIScale = Instance.new("UIScale")
UIScale.Scale = 0.85
UIScale.Parent = ScreenGui

--========================================================--
--                    UI HELPERS                         --
--========================================================--

local function Corner(parent,radius)

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0,radius)
    c.Parent = parent

    return c
end

local function Stroke(parent,color,thickness)

    local s = Instance.new("UIStroke")
    s.Color = color
    s.Thickness = thickness
    s.Parent = parent

    return s
end

local function Create(class,properties)

    local obj = Instance.new(class)

    for property,value in pairs(properties) do

        pcall(function()
            obj[property] = value
        end)

    end

    return obj
end

--========================================================--
--                  FLOAT BUTTON                        --
--========================================================--

local FloatButton = Create("TextButton",{

    Parent = ScreenGui,

    Size = UDim2.new(0,60,0,60),

    Position =
        UDim2.new(0,15,0.5,-30),

    BackgroundColor3 =
        Color3.fromRGB(4,7,13),

    BackgroundTransparency = 0.05,

    Text = "🌙",

    TextSize = 28,

    AutoButtonColor = false

})

Corner(FloatButton,100)

local FloatStroke =
    Stroke(
        FloatButton,
        Themes[ThemeIndex].Light,
        2
    )

--========================================================--
--                        MAIN                           --
--========================================================--

local Main = Create("Frame",{

    Parent = ScreenGui,

    Size = UDim2.new(0,330,0,440),

    Position =
        UDim2.new(0.5,-165,0.5,-220),

    BackgroundColor3 =
        Color3.fromRGB(3,5,10),

    BackgroundTransparency = 0.05,

    Visible = false

})

Corner(Main,14)

local MainStroke =
    Stroke(
        Main,
        Themes[ThemeIndex].Main,
        2
    )

--========================================================--
--                       HEADER                          --
--========================================================--

local Header = Create("Frame",{

    Parent = Main,

    Size = UDim2.new(1,0,0,70),

    BackgroundTransparency = 1

})

local Moon = Create("ImageLabel",{

    Parent = Header,

    Size = UDim2.new(0,55,0,55),

    Position = UDim2.new(0,8,0,7),

    BackgroundTransparency = 1,

    Image = "rbxassetid://7072719740",

    ScaleType = Enum.ScaleType.Fit

})

local Title = Create("TextLabel",{

    Parent = Header,

    Size = UDim2.new(1,-75,0,35),

    Position = UDim2.new(0,70,0,8),

    BackgroundTransparency = 1,

    Text = "MT7 HUB",

    Font = Enum.Font.GothamBold,

    TextSize = 24,

    TextColor3 =
        Themes[ThemeIndex].Light,

    TextXAlignment =
        Enum.TextXAlignment.Left

})

local SubTitle = Create("TextLabel",{

    Parent = Header,

    Size = UDim2.new(1,-75,0,22),

    Position = UDim2.new(0,70,0,38),

    BackgroundTransparency = 1,

    Text = "Performance • Free + PRO",

    Font = Enum.Font.Gotham,

    TextSize = 12,

    TextColor3 =
        Color3.fromRGB(150,160,180),

    TextXAlignment =
        Enum.TextXAlignment.Left

})

--========================================================--
--                       STATUS                          --
--========================================================--

local Status = Create("TextLabel",{

    Parent = Main,

    Size = UDim2.new(1,-20,0,25),

    Position = UDim2.new(0,10,0,72),

    BackgroundTransparency = 1,

    Text = "FREE • PRO bloqueado",

    Font = Enum.Font.GothamBold,

    TextSize = 12,

    TextColor3 =
        Color3.fromRGB(180,185,200)

})

--========================================================--
--                       SCROLL                           --
--========================================================--

local Scroll = Create("ScrollingFrame",{

    Parent = Main,

    Size = UDim2.new(1,-16,1,-110),

    Position = UDim2.new(0,8,0,100),

    BackgroundTransparency = 1,

    BorderSizePixel = 0,

    ScrollBarThickness = 3,

    CanvasSize = UDim2.new(0,0,0,0)

})

local Layout = Instance.new("UIListLayout")

Layout.Parent = Scroll

Layout.Padding = UDim.new(0,7)

Layout.HorizontalAlignment =
    Enum.HorizontalAlignment.Center

Layout.SortOrder =
    Enum.SortOrder.LayoutOrder

Layout:GetPropertyChangedSignal("AbsoluteContentSize")
    :Connect(function()

        Scroll.CanvasSize =
            UDim2.new(
                0,
                0,
                0,
                Layout.AbsoluteContentSize.Y + 10
            )

    end)

--========================================================--
--                       BUTTON                          --
--========================================================--

local function Button(text,callback)

    local b = Create("TextButton",{

        Parent = Scroll,

        Size = UDim2.new(1,-8,0,42),

        BackgroundColor3 =
            Color3.fromRGB(8,12,20),

        Text = text,

        Font = Enum.Font.GothamBold,

        TextSize = 13,

        TextColor3 =
            Color3.fromRGB(230,235,245),

        AutoButtonColor = false

    })

    Corner(b,9)

    Stroke(
        b,
        Themes[ThemeIndex].Main,
        1
    )

    b.MouseButton1Click:Connect(function()
        callback(b)
    end)

    return b
end

local function UpdateButton(button,title,state,locked)

    if locked then
        button.Text = "🔒 "..title.." [PRO]"
    else
        button.Text =
            title.." ["..(state and "ON" or "OFF").."]"
    end

end

--========================================================--
--                    FREE BUTTONS                       --
--========================================================--

local AntiLagButton =
    Button("⚡ Anti-Lag [OFF]",function(b)

        local state = ToggleFree("AntiLag")

        UpdateButton(
            b,
            "⚡ Anti-Lag",
            state,
            false
        )

    end)

local AntiTextureButton =
    Button("🧹 Anti-Textura [OFF]",function(b)

        local state =
            ToggleFree("AntiTexture")

        UpdateButton(
            b,
            "🧹 Anti-Textura",
            state,
            false
        )

    end)

local FPSButton =
    Button("🚀 FPS Boost [OFF]",function(b)

        local state =
            ToggleFree("FPSBoost")

        UpdateButton(
            b,
            "🚀 FPS Boost",
            state,
            false
        )

    end)

local FreezeButton =
    Button("🧊 Anti-Congelamento [OFF]",function(b)

        local state =
            ToggleFree("AntiFreeze")

        UpdateButton(
            b,
            "🧊 Anti-Congelamento",
            state,
            false
        )

    end)

--========================================================--
--                      PRO BUTTONS                      --
--========================================================--

local function ProButton(title,stateName)

    return Button(
        "🔒 "..title.." [PRO]",
        function(b)

            if not IsPRO then

                Status.Text =
                    "🔒 Digite uma Key válida em PRO"

                Status.TextColor3 =
                    Color3.fromRGB(255,180,80)

                return

            end

            local newState =
                not PRO.States[stateName]

            PRO.Set(stateName,newState)

            UpdateButton(
                b,
                title,
                newState,
                false
            )

            Status.Text =
                "💎 PRO • "..title..
                " ["..(newState and "ON" or "OFF").."]"

            Status.TextColor3 =
                Themes[ThemeIndex].Light

        end
    )

end

local UltraFPSButton =
    ProButton(
        "⚡ Ultra FPS",
        "UltraFPS"
    )

local UltraRenderButton =
    ProButton(
        "🚀 Ultra Render",
        "UltraRender"
    )

local SmartButton =
    ProButton(
        "🧠 Smart Boost",
        "SmartBoost"
    )

local ParticleButton =
    ProButton(
        "✨ Particle Boost",
        "ParticleBoost"
    )

local LightingButton =
    ProButton(
        "💡 Lighting Boost",
        "LightingBoost"
    )

local TerrainButton =
    ProButton(
        "🌍 Terrain Boost",
        "TerrainBoost"
    )

--========================================================--
--                         KEY                            --
--========================================================--

local KeyTitle = Create("TextLabel",{

    Parent = Scroll,

    Size = UDim2.new(1,-8,0,30),

    BackgroundTransparency = 1,

    Text = "🔑 SISTEMA PRO",

    Font = Enum.Font.GothamBold,

    TextSize = 15,

    TextColor3 =
        Themes[ThemeIndex].Light

})

local KeyInput = Create("TextBox",{

    Parent = Scroll,

    Size = UDim2.new(1,-8,0,42),

    BackgroundColor3 =
        Color3.fromRGB(8,12,20),

    Text = "",

    PlaceholderText =
        "Digite sua Key: MT-708090",

    Font = Enum.Font.Gotham,

    TextSize = 13,

    TextColor3 =
        Color3.fromRGB(235,240,255),

    PlaceholderColor3 =
        Color3.fromRGB(120,130,145),

    ClearTextOnFocus = false

})

Corner(KeyInput,9)

Stroke(
    KeyInput,
    Themes[ThemeIndex].Main,
    1
)

local VerifyButton =
    Button(
        "🔓 Verificar Key",
        function()

            local key =
                KeyInput.Text:gsub("%s+","")

            if VALID_KEYS[key] then

                Status.Text =
                    "⏳ Carregando MT7 PRO..."

                Status.TextColor3 =
                    Color3.fromRGB(255,200,80)

                if LoadPRO() then

                    IsPRO = true

                    Status.Text =
                        "✅ PRO ATIVADO"

                    Status.TextColor3 =
                        Color3.fromRGB(80,230,120)

                    UpdateButton(
                        UltraFPSButton,
                        "⚡ Ultra FPS",
                        PRO.States.UltraFPS,
                        false
                    )

                    UpdateButton(
                        UltraRenderButton,
                        "🚀 Ultra Render",
                        PRO.States.UltraRender,
                        false
                    )

                    UpdateButton(
                        SmartButton,
                        "🧠 Smart Boost",
                        PRO.States.SmartBoost,
                        false
                    )

                    UpdateButton(
                        ParticleButton,
                        "✨ Particle Boost",
                        PRO.States.ParticleBoost,
                        false
                    )

                    UpdateButton(
                        LightingButton,
                        "💡 Lighting Boost",
                        PRO.States.LightingBoost,
                        false
                    )

                    UpdateButton(
                        TerrainButton,
                        "🌍 Terrain Boost",
                        PRO.States.TerrainBoost,
                        false
                    )

                else

                    IsPRO = false

                    Status.Text =
                        "❌ MT7PRO.lua não carregou"

                    Status.TextColor3 =
                        Color3.fromRGB(255,80,80)

                end

            else

                IsPRO = false

                Status.Text =
                    "❌ Key inválida"

                Status.TextColor3 =
                    Color3.fromRGB(255,80,80)

            end

        end
    )

--========================================================--
--                    FPS SETTINGS                       --
--========================================================--

local FPSTitle = Create("TextLabel",{

    Parent = Scroll,

    Size = UDim2.new(1,-8,0,30),

    BackgroundTransparency = 1,

    Text = "📊 FPS",

    Font = Enum.Font.GothamBold,

    TextSize = 15,

    TextColor3 =
        Themes[ThemeIndex].Light

})

local FPSValues = {
    30,40,50,60,75,90,120
}

for _,fps in ipairs(FPSValues) do

    Button(
        "🎮 "..fps.." FPS",
        function()

            CurrentFPS = fps

            pcall(function()

                if setfpscap then
                    setfpscap(fps)
                end

            end)

            Status.Text =
                "📊 FPS máximo: "..fps

        end
    )

end

Button(
    "♾️ FPS Ilimitado",
    function()

        CurrentFPS = 9--========================================================--
--                    MT7 HUB V2.2                       --
--              PERFORMANCE + PRO SYSTEM                 --
--========================================================--

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer

--========================================================--
--                      KEY SYSTEM                        --
--========================================================--

local VALID_KEYS = {
    ["MT-708090"] = true,
    ["MT-123456"] = true,
    ["MT-987654"] = true
}

local IsPRO = false
local PRO = nil

local PRO_URL =
    "https://raw.githubusercontent.com/maycondograu405-png/MT7-Hub-V/refs/heads/main/MT7PRO.lua"

local function LoadPRO()
    if PRO then
        return true
    end

    local success, result = pcall(function()
        local source = game:HttpGet(PRO_URL)
        return loadstring(source)()
    end)

    if success and type(result) == "table" then
        PRO = result
        IsPRO = true
        return true
    end

    warn("MT7: não foi possível carregar MT7PRO.lua")
    return false
end

--========================================================--
--                       STATES                           --
--========================================================--

local States = {
    AntiLag = false,
    AntiTexture = false,
    FPSBoost = false,
    AntiFreeze = false
}

--========================================================--
--                       THEME                            --
--========================================================--

local Themes = {
    {
        Name = "Azul",
        Main = Color3.fromRGB(20,90,170),
        Light = Color3.fromRGB(70,170,255)
    },

    {
        Name = "Roxo",
        Main = Color3.fromRGB(100,45,180),
        Light = Color3.fromRGB(180,100,255)
    },

    {
        Name = "Ciano",
        Main = Color3.fromRGB(20,130,160),
        Light = Color3.fromRGB(70,230,255)
    },

    {
        Name = "Verde",
        Main = Color3.fromRGB(25,130,70),
        Light = Color3.fromRGB(80,230,130)
    },

    {
        Name = "Vermelho",
        Main = Color3.fromRGB(150,35,45),
        Light = Color3.fromRGB(255,80,90)
    }
}

local ThemeIndex = 1
local CurrentFPS = 60
local MoonEnabled = true

--========================================================--
--                  ORIGINAL VALUES                      --
--========================================================--

local Original = {}

local function SaveOriginal(obj, property)

    if not Original[obj] then
        Original[obj] = {}
    end

    if Original[obj][property] == nil then

        local success, value = pcall(function()
            return obj[property]
        end)

        if success then
            Original[obj][property] = value
        end

    end
end

local function SetProperty(obj, property, value)

    SaveOriginal(obj, property)

    pcall(function()
        obj[property] = value
    end)

end

local function RestoreAll()

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
--                  FREE OPTIMIZATION                    --
--========================================================--

local function ApplyFree()

    RestoreAll()

    -- ANTI LAG
    if States.AntiLag then

        for _, obj in ipairs(game:GetDescendants()) do

            pcall(function()

                if obj:IsA("ParticleEmitter")
                or obj:IsA("Trail")
                or obj:IsA("Beam")
                or obj:IsA("Smoke")
                or obj:IsA("Fire")
                or obj:IsA("Sparkles")
                or obj:IsA("Highlight") then

                    SetProperty(obj,"Enabled",false)

                elseif obj:IsA("PointLight")
                or obj:IsA("SpotLight")
                or obj:IsA("SurfaceLight") then

                    SetProperty(obj,"Enabled",false)

                end

            end)

        end

        SetProperty(Lighting,"GlobalShadows",false)

    end

    -- ANTI TEXTURA
    if States.AntiTexture then

        for _, obj in ipairs(game:GetDescendants()) do

            pcall(function()

                if obj:IsA("Decal")
                or obj:IsA("Texture") then

                    SetProperty(obj,"Transparency",1)

                elseif obj:IsA("MeshPart") then

                    SetProperty(obj,"TextureID","")

                elseif obj:IsA("SpecialMesh") then

                    SetProperty(obj,"TextureId","")

                elseif obj:IsA("SurfaceAppearance") then

                    SetProperty(obj,"Enabled",false)

                end

            end)

        end

    end

    -- FPS BOOST
    if States.FPSBoost then

        SetProperty(Lighting,"GlobalShadows",false)

        for _, obj in ipairs(Lighting:GetChildren()) do

            pcall(function()

                if obj:IsA("PostEffect") then
                    SetProperty(obj,"Enabled",false)
                end

                if obj:IsA("Atmosphere") then
                    SetProperty(obj,"Density",0)
                    SetProperty(obj,"Haze",0)
                    SetProperty(obj,"Glare",0)
                end

            end)

        end

        local terrain =
            workspace:FindFirstChildOfClass("Terrain")

        if terrain then
            SetProperty(terrain,"Decoration",false)
        end

    end

    -- ANTI CONGELAMENTO
    if States.AntiFreeze then

        for _, obj in ipairs(game:GetDescendants()) do

            pcall(function()

                if obj:IsA("ParticleEmitter")
                or obj:IsA("Trail")
                or obj:IsA("Beam")
                or obj:IsA("Smoke")
                or obj:IsA("Fire")
                or obj:IsA("Sparkles")
                or obj:IsA("Highlight") then

                    SetProperty(obj,"Enabled",false)

                end

            end)

        end

    end

end

local function ToggleFree(name)

    States[name] = not States[name]

    ApplyFree()

    return States[name]
end

--========================================================--
--                         GUI                            --
--========================================================--

local ScreenGui = Instance.new("ScreenGui")

ScreenGui.Name = "MT7_HUB_V22"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

pcall(function()
    ScreenGui.Parent = game:GetService("CoreGui")
end)

if not ScreenGui.Parent then
    ScreenGui.Parent = Player:WaitForChild("PlayerGui")
end

--========================================================--
--                       SCALE                            --
--========================================================--

local UIScale = Instance.new("UIScale")
UIScale.Scale = 0.85
UIScale.Parent = ScreenGui

--========================================================--
--                    UI HELPERS                         --
--========================================================--

local function Corner(parent,radius)

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0,radius)
    c.Parent = parent

    return c
end

local function Stroke(parent,color,thickness)

    local s = Instance.new("UIStroke")
    s.Color = color
    s.Thickness = thickness
    s.Parent = parent

    return s
end

local function Create(class,properties)

    local obj = Instance.new(class)

    for property,value in pairs(properties) do

        pcall(function()
            obj[property] = value
        end)

    end

    return obj
end

--========================================================--
--                  FLOAT BUTTON                        --
--========================================================--

local FloatButton = Create("TextButton",{

    Parent = ScreenGui,

    Size = UDim2.new(0,60,0,60),

    Position =
        UDim2.new(0,15,0.5,-30),

    BackgroundColor3 =
        Color3.fromRGB(4,7,13),

    BackgroundTransparency = 0.05,

    Text = "🌙",

    TextSize = 28,

    AutoButtonColor = false

})

Corner(FloatButton,100)

local FloatStroke =
    Stroke(
        FloatButton,
        Themes[ThemeIndex].Light,
        2
    )

--========================================================--
--                        MAIN                           --
--========================================================--

local Main = Create("Frame",{

    Parent = ScreenGui,

    Size = UDim2.new(0,330,0,440),

    Position =
        UDim2.new(0.5,-165,0.5,-220),

    BackgroundColor3 =
        Color3.fromRGB(3,5,10),

    BackgroundTransparency = 0.05,

    Visible = false

})

Corner(Main,14)

local MainStroke =
    Stroke(
        Main,
        Themes[ThemeIndex].Main,
        2
    )

--========================================================--
--                       HEADER                          --
--========================================================--

local Header = Create("Frame",{

    Parent = Main,

    Size = UDim2.new(1,0,0,70),

    BackgroundTransparency = 1

})

local Moon = Create("ImageLabel",{

    Parent = Header,

    Size = UDim2.new(0,55,0,55),

    Position = UDim2.new(0,8,0,7),

    BackgroundTransparency = 1,

    Image = "rbxassetid://7072719740",

    ScaleType = Enum.ScaleType.Fit

})

local Title = Create("TextLabel",{

    Parent = Header,

    Size = UDim2.new(1,-75,0,35),

    Position = UDim2.new(0,70,0,8),

    BackgroundTransparency = 1,

    Text = "MT7 HUB",

    Font = Enum.Font.GothamBold,

    TextSize = 24,

    TextColor3 =
        Themes[ThemeIndex].Light,

    TextXAlignment =
        Enum.TextXAlignment.Left

})

local SubTitle = Create("TextLabel",{

    Parent = Header,

    Size = UDim2.new(1,-75,0,22),

    Position = UDim2.new(0,70,0,38),

    BackgroundTransparency = 1,

    Text = "Performance • Free + PRO",

    Font = Enum.Font.Gotham,

    TextSize = 12,

    TextColor3 =
        Color3.fromRGB(150,160,180),

    TextXAlignment =
        Enum.TextXAlignment.Left

})

--========================================================--
--                       STATUS                          --
--========================================================--

local Status = Create("TextLabel",{

    Parent = Main,

    Size = UDim2.new(1,-20,0,25),

    Position = UDim2.new(0,10,0,72),

    BackgroundTransparency = 1,

    Text = "FREE • PRO bloqueado",

    Font = Enum.Font.GothamBold,

    TextSize = 12,

    TextColor3 =
        Color3.fromRGB(180,185,200)

})

--========================================================--
--                       SCROLL                           --
--========================================================--

local Scroll = Create("ScrollingFrame",{

    Parent = Main,

    Size = UDim2.new(1,-16,1,-110),

    Position = UDim2.new(0,8,0,100),

    BackgroundTransparency = 1,

    BorderSizePixel = 0,

    ScrollBarThickness = 3,

    CanvasSize = UDim2.new(0,0,0,0)

})

local Layout = Instance.new("UIListLayout")

Layout.Parent = Scroll

Layout.Padding = UDim.new(0,7)

Layout.HorizontalAlignment =
    Enum.HorizontalAlignment.Center

Layout.SortOrder =
    Enum.SortOrder.LayoutOrder

Layout:GetPropertyChangedSignal("AbsoluteContentSize")
    :Connect(function()

        Scroll.CanvasSize =
            UDim2.new(
                0,
                0,
                0,
                Layout.AbsoluteContentSize.Y + 10
            )

    end)

--========================================================--
--                       BUTTON                          --
--========================================================--

local function Button(text,callback)

    local b = Create("TextButton",{

        Parent = Scroll,

        Size = UDim2.new(1,-8,0,42),

        BackgroundColor3 =
            Color3.fromRGB(8,12,20),

        Text = text,

        Font = Enum.Font.GothamBold,

        TextSize = 13,

        TextColor3 =
            Color3.fromRGB(230,235,245),

        AutoButtonColor = false

    })

    Corner(b,9)

    Stroke(
        b,
        Themes[ThemeIndex].Main,
        1
    )

    b.MouseButton1Click:Connect(function()
        callback(b)
    end)

    return b
end

local function UpdateButton(button,title,state,locked)

    if locked then
        button.Text = "🔒 "..title.." [PRO]"
    else
        button.Text =
            title.." ["..(state and "ON" or "OFF").."]"
    end

end

--========================================================--
--                    FREE BUTTONS                       --
--========================================================--

local AntiLagButton =
    Button("⚡ Anti-Lag [OFF]",function(b)

        local state = ToggleFree("AntiLag")

        UpdateButton(
            b,
            "⚡ Anti-Lag",
            state,
            false
        )

    end)

local AntiTextureButton =
    Button("🧹 Anti-Textura [OFF]",function(b)

        local state =
            ToggleFree("AntiTexture")

        UpdateButton(
            b,
            "🧹 Anti-Textura",
            state,
            false
        )

    end)

local FPSButton =
    Button("🚀 FPS Boost [OFF]",function(b)

        local state =
            ToggleFree("FPSBoost")

        UpdateButton(
            b,
            "🚀 FPS Boost",
            state,
            false
        )

    end)

local FreezeButton =
    Button("🧊 Anti-Congelamento [OFF]",function(b)

        local state =
            ToggleFree("AntiFreeze")

        UpdateButton(
            b,
            "🧊 Anti-Congelamento",
            state,
            false
        )

    end)

--========================================================--
--                      PRO BUTTONS                      --
--========================================================--

local function ProButton(title,stateName)

    return Button(
        "🔒 "..title.." [PRO]",
        function(b)

            if not IsPRO then

                Status.Text =
                    "🔒 Digite uma Key válida em PRO"

                Status.TextColor3 =
                    Color3.fromRGB(255,180,80)

                return

            end

            local newState =
                not PRO.States[stateName]

            PRO.Set(stateName,newState)

            UpdateButton(
                b,
                title,
                newState,
                false
            )

            Status.Text =
                "💎 PRO • "..title..
                " ["..(newState and "ON" or "OFF").."]"

            Status.TextColor3 =
                Themes[ThemeIndex].Light

        end
    )

end

local UltraFPSButton =
    ProButton(
        "⚡ Ultra FPS",
        "UltraFPS"
    )

local UltraRenderButton =
    ProButton(
        "🚀 Ultra Render",
        "UltraRender"
    )

local SmartButton =
    ProButton(
        "🧠 Smart Boost",
        "SmartBoost"
    )

local ParticleButton =
    ProButton(
        "✨ Particle Boost",
        "ParticleBoost"
    )

local LightingButton =
    ProButton(
        "💡 Lighting Boost",
        "LightingBoost"
    )

local TerrainButton =
    ProButton(
        "🌍 Terrain Boost",
        "TerrainBoost"
    )

--========================================================--
--                         KEY                            --
--========================================================--

local KeyTitle = Create("TextLabel",{

    Parent = Scroll,

    Size = UDim2.new(1,-8,0,30),

    BackgroundTransparency = 1,

    Text = "🔑 SISTEMA PRO",

    Font = Enum.Font.GothamBold,

    TextSize = 15,

    TextColor3 =
        Themes[ThemeIndex].Light

})

local KeyInput = Create("TextBox",{

    Parent = Scroll,

    Size = UDim2.new(1,-8,0,42),

    BackgroundColor3 =
        Color3.fromRGB(8,12,20),

    Text = "",

    PlaceholderText =
        "Digite sua Key: MT-708090",

    Font = Enum.Font.Gotham,

    TextSize = 13,

    TextColor3 =
        Color3.fromRGB(235,240,255),

    PlaceholderColor3 =
        Color3.fromRGB(120,130,145),

    ClearTextOnFocus = false

})

Corner(KeyInput,9)

Stroke(
    KeyInput,
    Themes[ThemeIndex].Main,
    1
)

local VerifyButton =
    Button(
        "🔓 Verificar Key",
        function()

            local key =
                KeyInput.Text:gsub("%s+","")

            if VALID_KEYS[key] then

                Status.Text =
                    "⏳ Carregando MT7 PRO..."

                Status.TextColor3 =
                    Color3.fromRGB(255,200,80)

                if LoadPRO() then

                    IsPRO = true

                    Status.Text =
                        "✅ PRO ATIVADO"

                    Status.TextColor3 =
                        Color3.fromRGB(80,230,120)

                    UpdateButton(
                        UltraFPSButton,
                        "⚡ Ultra FPS",
                        PRO.States.UltraFPS,
                        false
                    )

                    UpdateButton(
                        UltraRenderButton,
                        "🚀 Ultra Render",
                        PRO.States.UltraRender,
                        false
                    )

                    UpdateButton(
                        SmartButton,
                        "🧠 Smart Boost",
                        PRO.States.SmartBoost,
                        false
                    )

                    UpdateButton(
                        ParticleButton,
                        "✨ Particle Boost",
                        PRO.States.ParticleBoost,
                        false
                    )

                    UpdateButton(
                        LightingButton,
                        "💡 Lighting Boost",
                        PRO.States.LightingBoost,
                        false
                    )

                    UpdateButton(
                        TerrainButton,
                        "🌍 Terrain Boost",
                        PRO.States.TerrainBoost,
                        false
                    )

                else

                    IsPRO = false

                    Status.Text =
                        "❌ MT7PRO.lua não carregou"

                    Status.TextColor3 =
                        Color3.fromRGB(255,80,80)

                end

            else

                IsPRO = false

                Status.Text =
                    "❌ Key inválida"

                Status.TextColor3 =
                    Color3.fromRGB(255,80,80)

            end

        end
    )

--========================================================--
--                    FPS SETTINGS                       --
--========================================================--

local FPSTitle = Create("TextLabel",{

    Parent = Scroll,

    Size = UDim2.new(1,-8,0,30),

    BackgroundTransparency = 1,

    Text = "📊 FPS",

    Font = Enum.Font.GothamBold,

    TextSize = 15,

    TextColor3 =
        Themes[ThemeIndex].Light

})

local FPSValues = {
    30,40,50,60,75,90,120
}

for _,fps in ipairs(FPSValues) do

    Button(
        "🎮 "..fps.." FPS",
        function()

            CurrentFPS = fps

            pcall(function()

                if setfpscap then
                    setfpscap(fps)
                end

            end)

            Status.Text =
                "📊 FPS máximo: "..fps

        end
    )

end

Button(
    "♾️ FPS Ilimitado",
    function()

        CurrentFPS = 9--========================================================--
--                    MT7 HUB V2.1                       --
--             PERFORMANCE + CUSTOM UI                  --
--========================================================--

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer

--========================================================--
--                    KEY SYSTEM                         --
--========================================================--

local VALID_KEYS = {
    ["MT-708090"] = true,
    ["MT-123456"] = true,
    ["MT-987654"] = true
}

local PRO = false

--========================================================--
--                    ESTADOS                            --
--========================================================--

local States = {
    AntiLag = false,
    AntiTexture = false,
    FPSBoost = false,
    AntiFreeze = false,

    UltraFPS = false,
    UltraRender = false,
    SmartBoost = false,
    ParticleBoost = false,
    LightingBoost = false,
    TerrainBoost = false
}

--========================================================--
--                    TEMAS                              --
--========================================================--

local Themes = {
    {
        Name = "Azul",
        Main = Color3.fromRGB(20, 90, 170),
        Light = Color3.fromRGB(70, 170, 255)
    },

    {
        Name = "Roxo",
        Main = Color3.fromRGB(100, 45, 180),
        Light = Color3.fromRGB(180, 100, 255)
    },

    {
        Name = "Ciano",
        Main = Color3.fromRGB(20, 130, 160),
        Light = Color3.fromRGB(70, 230, 255)
    },

    {
        Name = "Verde",
        Main = Color3.fromRGB(25, 130, 70),
        Light = Color3.fromRGB(80, 230, 130)
    },

    {
        Name = "Vermelho",
        Main = Color3.fromRGB(150, 35, 45),
        Light = Color3.fromRGB(255, 80, 90)
    }
}

local ThemeIndex = 1

--========================================================--
--                    FPS                               --
--========================================================--

local CurrentFPS = 60

--========================================================--
--                ORIGINAL VALUES                       --
--========================================================--

local Original = {}

local function SaveOriginal(obj, property)
    if not Original[obj] then
        Original[obj] = {}
    end

    if Original[obj][property] == nil then
        local success, value = pcall(function()
            return obj[property]
        end)

        if success then
            Original[obj][property] = value
        end
    end
end

local function SetProperty(obj, property, value)
    SaveOriginal(obj, property)

    pcall(function()
        obj[property] = value
    end)
end

local function RestoreProperty(obj, property)
    if Original[obj] and Original[obj][property] ~= nil then
        pcall(function()
            obj[property] = Original[obj][property]
        end)
    end
end

--========================================================--
--                REAPLICAR OTIMIZAÇÕES                  --
--========================================================--

local function RestoreOptimized()
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

local function ApplyOptimization()

    -- Primeiro volta ao estado original
    RestoreOptimized()

    --==================================================
    -- ANTI-LAG
    --==================================================

    if States.AntiLag then

        for _, obj in ipairs(game:GetDescendants()) do
            pcall(function()

                if obj:IsA("ParticleEmitter")
                or obj:IsA("Trail")
                or obj:IsA("Beam")
                or obj:IsA("Smoke")
                or obj:IsA("Fire")
                or obj:IsA("Sparkles") then

                    SetProperty(obj, "Enabled", false)

                elseif obj:IsA("PointLight")
                or obj:IsA("SpotLight")
                or obj:IsA("SurfaceLight") then

                    SetProperty(obj, "Enabled", false)

                elseif obj:IsA("PostEffect") then

                    SetProperty(obj, "Enabled", false)

                elseif obj:IsA("Highlight") then

                    SetProperty(obj, "Enabled", false)

                end

            end)
        end

        SetProperty(Lighting, "GlobalShadows", false)
    end

    --==================================================
    -- ANTI TEXTURA
    --==================================================

    if States.AntiTexture then

        for _, obj in ipairs(game:GetDescendants()) do
            pcall(function()

                if obj:IsA("Decal")
                or obj:IsA("Texture") then

                    SetProperty(obj, "Transparency", 1)

                elseif obj:IsA("MeshPart") then

                    SetProperty(obj, "TextureID", "")

                elseif obj:IsA("SpecialMesh") then

                    SetProperty(obj, "TextureId", "")

                elseif obj:IsA("SurfaceAppearance") then

                    SetProperty(obj, "Enabled", false)

                end

            end)
        end
    end

    --==================================================
    -- FPS BOOST
    --==================================================

    if States.FPSBoost then

        SetProperty(Lighting, "GlobalShadows", false)

        for _, obj in ipairs(Lighting:GetChildren()) do
            pcall(function()

                if obj:IsA("PostEffect") then
                    SetProperty(obj, "Enabled", false)
                end

                if obj:IsA("Atmosphere") then
                    SetProperty(obj, "Density", 0)
                    SetProperty(obj, "Haze", 0)
                end

            end)
        end

        local terrain = workspace:FindFirstChildOfClass("Terrain")

        if terrain then
            SetProperty(terrain, "Decoration", false)
        end
    end

    --==================================================
    -- ANTI CONGELAMENTO
    --==================================================

    if States.AntiFreeze then

        for _, obj in ipairs(game:GetDescendants()) do
            pcall(function()

                if obj:IsA("ParticleEmitter")
                or obj:IsA("Trail")
                or obj:IsA("Beam")
                or obj:IsA("Smoke")
                or obj:IsA("Fire")
                or obj:IsA("Sparkles")
                or obj:IsA("Highlight") then

                    SetProperty(obj, "Enabled", false)

                end

            end)
        end
    end

    --==================================================
    -- PRO: ULTRA FPS
    --==================================================

    if States.UltraFPS then

        SetProperty(Lighting, "GlobalShadows", false)

        for _, obj in ipairs(Lighting:GetChildren()) do
            pcall(function()

                if obj:IsA("PostEffect") then
                    SetProperty(obj, "Enabled", false)
                end

                if obj:IsA("Atmosphere") then
                    SetProperty(obj, "Density", 0)
                    SetProperty(obj, "Haze", 0)
                    SetProperty(obj, "Glare", 0)
                end

            end)
        end
    end

    --==================================================
    -- PRO: ULTRA RENDER
    --==================================================

    if States.UltraRender then

        for _, obj in ipairs(game:GetDescendants()) do
            pcall(function()

                if obj:IsA("ParticleEmitter")
                or obj:IsA("Trail")
                or obj:IsA("Beam")
                or obj:IsA("Smoke")
                or obj:IsA("Fire")
                or obj:IsA("Sparkles")
                or obj:IsA("Highlight") then

                    SetProperty(obj, "Enabled", false)

                elseif obj:IsA("PointLight")
                or obj:IsA("SpotLight")
                or obj:IsA("SurfaceLight") then

                    SetProperty(obj, "Enabled", false)

                end

            end)
        end
    end

    --==================================================
    -- PRO: PARTICLE BOOST
    --==================================================

    if States.ParticleBoost then

        for _, obj in ipairs(game:GetDescendants()) do
            pcall(function()

                if obj:IsA("ParticleEmitter") then
                    SetProperty(obj, "Enabled", false)
                end

                if obj:IsA("Trail") then
                    SetProperty(obj, "Enabled", false)
                end

                if obj:IsA("Beam") then
                    SetProperty(obj, "Enabled", false)
                end

            end)
        end
    end

    --==================================================
    -- PRO: LIGHTING BOOST
    --==================================================

    if States.LightingBoost then

        SetProperty(Lighting, "GlobalShadows", false)

        for _, obj in ipairs(Lighting:GetChildren()) do
            pcall(function()

                if obj:IsA("PostEffect") then
                    SetProperty(obj, "Enabled", false)
                end

                if obj:IsA("Atmosphere") then
                    SetProperty(obj, "Density", 0)
                    SetProperty(obj, "Haze", 0)
                end

            end)
        end
    end

    --==================================================
    -- PRO: TERRAIN BOOST
    --==================================================

    if States.TerrainBoost then

        local terrain = workspace:FindFirstChildOfClass("Terrain")

        if terrain then
            SetProperty(terrain, "Decoration", false)
        end
    end

    --==================================================
    -- PRO: SMART BOOST
    --==================================================

    if States.SmartBoost then

        SetProperty(Lighting, "GlobalShadows", false)

        local terrain = workspace:FindFirstChildOfClass("Terrain")

        if terrain then
            SetProperty(terrain, "Decoration", false)
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

                    SetProperty(obj, "Enabled", false)

                elseif obj:IsA("PostEffect") then

                    SetProperty(obj, "Enabled", false)

                end

            end)
        end
    end

    --==================================================
    -- FPS CAP
    --==================================================

    pcall(function()
        if setfpscap then
            setfpscap(CurrentFPS)
        end
    end)
end

--========================================================--
--                    GUI                               --
--========================================================--

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MT7_HUB_V21"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

pcall(function()
    ScreenGui.Parent = game:GetService("CoreGui")
end)

if not ScreenGui.Parent then
    ScreenGui.Parent = Player:WaitForChild("PlayerGui")
end

--========================================================--
--                    UI SCALE                           --
--========================================================--

local UIScale = Instance.new("UIScale")
UIScale.Scale = 0.85
UIScale.Parent = ScreenGui

--========================================================--
--                    FUNÇÕES UI                         --
--========================================================--

local function Corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius)
    c.Parent = parent
    return c
end

local function Stroke(parent, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color
    s.Thickness = thickness
    s.Parent = parent
    return s
end

local function Create(class, properties)
    local object = Instance.new(class)

    for property, value in pairs(properties) do
        pcall(function()
            object[property] = value
        end)
    end

    return object
end

--========================================================--
--                BOTÃO FLUTUANTE                       --
--========================================================--

local FloatButton = Create("TextButton", {
    Parent = ScreenGui,
    Size = UDim2.new(0, 60, 0, 60),
    Position = UDim2.new(0, 15, 0.5, -30),
    BackgroundColor3 = Color3.fromRGB(4, 7, 13),
    BackgroundTransparency = 0.05,
    Text = "🌙",
    TextSize = 28,
    AutoButtonColor = false
})

Corner(FloatButton, 100)

local FloatStroke = Stroke(
    FloatButton,
    Themes[ThemeIndex].Light,
    2
)

--========================================================--
--                    MAIN                               --
--========================================================--

local Main = Create("Frame", {
    Parent = ScreenGui,
    Size = UDim2.new(0, 330, 0, 425),
    Position = UDim2.new(0.5, -165, 0.5, -212),
    BackgroundColor3 = Color3.fromRGB(3, 5, 10),
    BackgroundTransparency = 0.05,
    Visible = false
})

Corner(Main, 14)

local MainStroke = Stroke(
    Main,
    Themes[ThemeIndex].Main,
    2
)

--========================================================--
--                    HEADER                             --
--========================================================--

local Header = Create("Frame", {
    Parent = Main,
    Size = UDim2.new(1, 0, 0, 75),
    BackgroundTransparency = 1
})

local Moon = Create("ImageLabel", {
    Parent = Header,
    Size = UDim2.new(0, 58, 0, 58),
    Position = UDim2.new(0, 8, 0, 8),
    BackgroundTransparency = 1,
    Image = "rbxassetid://7072719740",
    ScaleType = Enum.ScaleType.Fit
})

local Title = Create("TextLabel", {
    Parent = Header,
    Size = UDim2.new(1, -75, 0, 35),
    Position = UDim2.new(0, 72, 0, 10),
    BackgroundTransparency = 1,
    Text = "MT7 HUB",
    Font = Enum.Font.GothamBold,
    TextSize = 25,
    TextXAlignment--[[
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

print("MT7 HUB V2.2 carregado!")
