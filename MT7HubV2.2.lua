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
    ScreenGui.Parent = Player:WaitForChild("
