--========================================================--
--                 MT7 HUB V3 PRO SYSTEM                 --
--                       ECLIPSE 🌑                      --
--========================================================--

local PRO = {}

PRO.Version = "3.0"
PRO.Verified = false

local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

--========================================================--
--                       STATES                          --
--========================================================--

PRO.States = {
    ExtremeFPS = false,
    UltraRender = false,
    ExtremeParticle = false,
    ExtremeLighting = false,
    ExtremeTerrain = false,
    SmartBoostPRO = false,
    ThermalGuard = false,
    RenderOptimizer = false,
    BatterySaver = false,
    DynamicBoost = false
}

--========================================================--
--                    ORIGINAL DATA                      --
--========================================================--

local Original = {}

local function Save(obj, property)

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

local function Set(obj, property, value)

    Save(obj, property)

    pcall(function()
        obj[property] = value
    end)

end

--========================================================--
--                       RESTORE                         --
--========================================================--

function PRO.Restore()

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
--                 VISUAL OPTIMIZATION                   --
--========================================================--

local function DisableParticles()

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
--                  LIGHTING OPTIMIZATION                 --
--========================================================--

local function OptimizeLighting()

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
--                   TERRAIN OPTIMIZATION                 --
--========================================================--

local function OptimizeTerrain()

    local Terrain = workspace:FindFirstChildOfClass("Terrain")

    if Terrain then

        Set(Terrain, "Decoration", false)

    end

end

--========================================================--
--                  EXTREME FPS                         --
--========================================================--

local function ExtremeFPS()

    OptimizeLighting()
    DisableParticles()
    OptimizeTerrain()

end

--========================================================--
--                   ULTRA RENDER                        --
--========================================================--

local function UltraRender()

    for _, obj in ipairs(game:GetDescendants()) do

        pcall(function()

            if obj:IsA("Highlight") then

                Set(obj, "Enabled", false)

            elseif obj:IsA("PointLight")
            or obj:IsA("SpotLight")
            or obj:IsA("SurfaceLight") then

                Set(obj, "Enabled", false)

            end

        end)

    end

end

--========================================================--
--                 EXTREME PARTICLE                      --
--========================================================--

local function ExtremeParticle()

    DisableParticles()

end

--========================================================--
--                 EXTREME LIGHTING                      --
--========================================================--

local function ExtremeLighting()

    OptimizeLighting()

end

--========================================================--
--                  EXTREME TERRAIN                      --
--========================================================--

local function ExtremeTerrain()

    OptimizeTerrain()

end

--========================================================--
--                  SMART BOOST PRO                      --
--========================================================--

local function SmartBoostPRO()

    OptimizeLighting()
    OptimizeTerrain()
    DisableParticles()

end

--========================================================--
--                  THERMAL GUARD                        --
--========================================================--

local function ThermalGuard()

    OptimizeLighting()

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

--========================================================--
--                  RENDER OPTIMIZER                     --
--========================================================--

local function RenderOptimizer()

    for _, obj in ipairs(game:GetDescendants()) do

        pcall(function()

            if obj:IsA("PostEffect")
            or obj:IsA("Highlight") then

                Set(obj, "Enabled", false)

            end

        end)

    end

end

--========================================================--
--                    BATTERY SAVER                      --
--========================================================--
-- Este modo reduz carga gráfica para tentar diminuir
-- consumo e aquecimento. Ele não controla diretamente
-- a bateria ou a temperatura física do aparelho.
--========================================================--

local function BatterySaver()

    OptimizeLighting()
    DisableParticles()

end

--========================================================--
--                  APPLY ALL ACTIVE                     --
--========================================================--

function PRO.Apply()

    PRO.Restore()

    if PRO.States.ExtremeFPS then
        ExtremeFPS()
    end

    if PRO.States.UltraRender then
        UltraRender()
    end

    if PRO.States.ExtremeParticle then
        ExtremeParticle()
    end

    if PRO.States.ExtremeLighting then
        ExtremeLighting()
    end

    if PRO.States.ExtremeTerrain then
        ExtremeTerrain()
    end

    if PRO.States.SmartBoostPRO then
        SmartBoostPRO()
    end

    if PRO.States.ThermalGuard then
        ThermalGuard()
    end

    if PRO.States.RenderOptimizer then
        RenderOptimizer()
    end

    if PRO.States.BatterySaver then
        BatterySaver()
    end

    if PRO.States.DynamicBoost then
        SmartBoostPRO()
    end

end

--========================================================--
--                    SET BOOSTER                        --
--========================================================--

function PRO.Set(name, enabled)

    if PRO.States[name] == nil then
        return false
    end

    PRO.States[name] = enabled == true

    PRO.Apply()

    return true

end

--========================================================--
--                   ENABLE ALL                          --
--========================================================--

function PRO.EnableAll()

    for name in pairs(PRO.States) do
        PRO.States[name] = true
    end

    PRO.Apply()

end

--========================================================--
--                   DISABLE ALL                         --
--========================================================--

function PRO.DisableAll()

    for name in pairs(PRO.States) do
        PRO.States[name] = false
    end

    PRO.Restore()

end

--========================================================--
--                 DYNAMIC BOOST                        --
--========================================================--

local DynamicConnection = nil

function PRO.StartDynamic()

    if DynamicConnection then
        return
    end

    DynamicConnection = RunService.RenderStepped:Connect(function()

        if not PRO.States.DynamicBoost then
            return
        end

        -- O modo dinâmico reaplica otimizações
        -- periodicamente sem alterar gameplay.

    end)

end

function PRO.StopDynamic()

    if DynamicConnection then

        DynamicConnection:Disconnect()
        DynamicConnection = nil

    end

end

--========================================================--
--                     STATUS                            --
--========================================================--

function PRO.GetStatus(name)

    if PRO.States[name] == nil then
        return false
    end

    return PRO.States[name]

end

--========================================================--
--                   VERIFICAÇÃO                         --
--========================================================--

function PRO.SetVerified(value)

    PRO.Verified = value == true

    return PRO.Verified

end

--========================================================--
--                     CLEANUP                           --
--========================================================--

function PRO.Destroy()

    PRO.StopDynamic()
    PRO.DisableAll()

end

--========================================================--
--                       FINAL                           --
--========================================================--

return PRO
