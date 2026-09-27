--========================================================--
--                 MT7 HUB V3 SETTINGS                   --
--========================================================--

local Settings = {}

Settings.Version = "3.0"

Settings.Scale = 1
Settings.FPSCap = 60

Settings.MoonEnabled = true
Settings.PerformanceMonitor = true
Settings.ThermalGuard = false

Settings.Theme = "Eclipse"

Settings.FPSCaps = {
    30,
    40,
    50,
    60,
    75,
    90,
    120,
    "Unlimited"
}

function Settings.SetScale(value)
    if typeof(value) ~= "number" then
        return false
    end

    Settings.Scale = math.clamp(value, 0.7, 1.15)
    return true
end

function Settings.SetFPSCap(value)
    Settings.FPSCap = value
    return true
end

function Settings.SetMoon(enabled)
    Settings.MoonEnabled = enabled == true
    return true
end

function Settings.SetMonitor(enabled)
    Settings.PerformanceMonitor = enabled == true
    return true
end

function Settings.SetThermal(enabled)
    Settings.ThermalGuard = enabled == true
    return true
end

return Settings
