--========================================================--
--                   MT7 HUB V3 THEMES                   --
--========================================================--

local Themes = {}

Themes.Version = "3.0"

Themes.Current = "Eclipse"

Themes.List = {

    Eclipse = {
        Background = Color3.fromRGB(8, 8, 12),
        Panel = Color3.fromRGB(14, 14, 22),
        Secondary = Color3.fromRGB(22, 22, 32),

        Primary = Color3.fromRGB(120, 80, 220),
        SecondaryAccent = Color3.fromRGB(75, 55, 150),

        Text = Color3.fromRGB(245, 245, 255),
        SubText = Color3.fromRGB(165, 165, 180),

        Success = Color3.fromRGB(80, 220, 130),
        Warning = Color3.fromRGB(255, 190, 70),
        Error = Color3.fromRGB(255, 80, 90)
    },

    Moon = {
        Background = Color3.fromRGB(10, 12, 18),
        Panel = Color3.fromRGB(18, 21, 30),
        Secondary = Color3.fromRGB(27, 31, 42),

        Primary = Color3.fromRGB(90, 150, 255),
        SecondaryAccent = Color3.fromRGB(55, 95, 180),

        Text = Color3.fromRGB(245, 248, 255),
        SubText = Color3.fromRGB(170, 180, 200),

        Success = Color3.fromRGB(80, 220, 130),
        Warning = Color3.fromRGB(255, 190, 70),
        Error = Color3.fromRGB(255, 80, 90)
    },

    Dark = {
        Background = Color3.fromRGB(5, 5, 5),
        Panel = Color3.fromRGB(12, 12, 12),
        Secondary = Color3.fromRGB(20, 20, 20),

        Primary = Color3.fromRGB(150, 150, 150),
        SecondaryAccent = Color3.fromRGB(80, 80, 80),

        Text = Color3.fromRGB(255, 255, 255),
        SubText = Color3.fromRGB(160, 160, 160),

        Success = Color3.fromRGB(80, 220, 130),
        Warning = Color3.fromRGB(255, 190, 70),
        Error = Color3.fromRGB(255, 80, 90)
    }

}

--========================================================--
--                    PEGAR TEMA                         --
--========================================================--

function Themes.Get(name)

    if Themes.List[name] then
        return Themes.List[name]
    end

    return Themes.List.Eclipse
end

--========================================================--
--                    MUDAR TEMA                         --
--========================================================--

function Themes.Set(name)

    if not Themes.List[name] then
        return false
    end

    Themes.Current = name

    return true
end

--========================================================--
--                    TEMA ATUAL                         --
--========================================================--

function Themes.GetCurrent()

    return Themes.Get(Themes.Current)

end

--========================================================--
--                    LISTAR TEMAS                       --
--========================================================--

function Themes.GetNames()

    local Names = {}

    for Name in pairs(Themes.List) do
        table.insert(Names, Name)
    end

    table.sort(Names)

    return Names

end

return Themes
