--========================================================--
--                    MT7 PRO SYSTEM                     --
--========================================================--

local MT7PRO = {}

MT7PRO.Version = "1.0"

local Lighting = game:GetService("Lighting")

MT7PRO.States = {
    UltraFPS = false,
    UltraRender = false,
    SmartBoost = false,
    ParticleBoost = false,
    LightingBoost = false,
    TerrainBoost = false
}

local Original = {}

local function Save(obj, property)
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
    Save(obj, property)

    pcall(function()
        obj[property] = value
    end)
end

function MT7PRO.Restore()
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

function MT7PRO.Apply()
    MT7PRO.Restore()

    -- ULTRA FPS
    if MT7PRO.States.UltraFPS then
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

    -- ULTRA RENDER
    if MT7PRO.States.UltraRender then
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

                elseif obj:IsA("PointLight")
                or obj:IsA("SpotLight")
                or obj:IsA("SurfaceLight") then

                    Set(obj, "Enabled", false)
                end
            end)
        end
    end

    -- PARTICLE BOOST
    if MT7PRO.States.ParticleBoost then
        for _, obj in ipairs(game:GetDescendants()) do
            pcall(function()
                if obj:IsA("ParticleEmitter")
                or obj:IsA("Trail")
                or obj:IsA("Beam") then

                    Set(obj, "Enabled", false)
                end
            end)
        end
    end

    -- LIGHTING BOOST
    if MT7PRO.States.LightingBoost then
        Set(Lighting, "GlobalShadows", false)

        for _, obj in ipairs(Lighting:GetChildren()) do
            pcall(function()
                if obj:IsA("PostEffect") then
                    Set(obj, "Enabled", false)
                elseif obj:IsA("Atmosphere") then
                    Set(obj, "Density", 0)
                    Set(obj, "Haze", 0)
                end
            end)
        end
    end

    -- TERRAIN BOOST
    if MT7PRO.States.TerrainBoost then
        local terrain = workspace:FindFirstChildOfClass("Terrain")

        if terrain then
            Set(terrain, "Decoration", false)
        end
    end

    -- SMART BOOST
    if MT7PRO.States.SmartBoost then
        Set(Lighting, "GlobalShadows", false)

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
                or obj:IsA("Highlight")
                or obj:IsA("PostEffect") then

                    Set(obj, "Enabled", false)
                end
            end)
        end
    end

    return true
end

function MT7PRO.Set(name, enabled)
    if MT7PRO.States[name] == nil then
        return false
    end

    MT7PRO.States[name] = enabled == true
    MT7PRO.Apply()

    return true
end

function MT7PRO.EnableAll()
    for name in pairs(MT7PRO.States) do
        MT7PRO.States[name] = true
    end

    MT7PRO.Apply()
end

function MT7PRO.DisableAll()
    for name in pairs(MT7PRO.States) do
        MT7PRO.States[name] = false
    end

    MT7PRO.Restore()
end

return MT7PRO
