--========================================================--
--                 MT7 HUB V3 THERMAL                   --
--                    THERMAL GUARD                     --
--========================================================--

local Thermal = {}

Thermal.Version = "3.0"
Thermal.Enabled = false
Thermal.Mode = "Balanced"

local Lighting = game:GetService("Lighting")

local Original = {}

--========================================================--
--                     UTILIDADES                       --
--========================================================--

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

--========================================================--
--                    RESTAURAR                          --
--========================================================--

function Thermal.Restore()

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
--                 APLICA THERMAL GUARD                 --
--========================================================--

function Thermal.Apply()

    Thermal.Restore()

    if not Thermal.Enabled then
        return
    end

    -- Redução de sombras
    Set(Lighting, "GlobalShadows", false)

    -- Efeitos de iluminação
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

    -- Modo agressivo
    if Thermal.Mode == "Aggressive" then

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

        -- Otimização do Terrain
        local Terrain = workspace:FindFirstChildOfClass("Terrain")

        if Terrain then
            Set(Terrain, "Decoration", false)
        end

    end

end

--========================================================--
--                     ATIVAR                            --
--========================================================--

function Thermal.Enable(mode)

    Thermal.Enabled = true

    if mode == "Aggressive" then
        Thermal.Mode = "Aggressive"
    else
        Thermal.Mode = "Balanced"
    end

    Thermal.Apply()

    return true
end

--========================================================--
--                     DESATIVAR                         --
--========================================================--

function Thermal.Disable()

    Thermal.Enabled = false

    Thermal.Restore()

    return true
end

--========================================================--
--                    MUDAR MODO                         --
--========================================================--

function Thermal.SetMode(mode)

    if mode ~= "Balanced"
    and mode ~= "Aggressive" then
        return false
    end

    Thermal.Mode = mode

    if Thermal.Enabled then
        Thermal.Apply()
    end

    return true
end

--========================================================--
--                     STATUS                            --
--========================================================--

function Thermal.IsEnabled()
    return Thermal.Enabled
end

function Thermal.GetMode()
    return Thermal.Mode
end

--========================================================--
--                      FINAL                            --
--========================================================--

return Thermal
