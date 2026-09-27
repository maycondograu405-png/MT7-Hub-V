--========================================================--
--                  MT7 HUB V3 MONITOR                   --
--                    FPS + PING                         --
--========================================================--

local Monitor = {}

Monitor.Version = "3.0"

local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")

local Connection = nil
local Frame = nil
local FPSLabel = nil
local PingLabel = nil

local FPS = 0
local Frames = 0
local LastUpdate = tick()

--========================================================--
--                    CRIAR MONITOR                      --
--========================================================--

function Monitor.Create(parent)

    if Frame then
        return Frame
    end

    Frame = Instance.new("Frame")
    Frame.Name = "MT7PerformanceMonitor"
    Frame.Size = UDim2.new(0, 150, 0, 58)
    Frame.Position = UDim2.new(1, -160, 0, 15)
    Frame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
    Frame.BackgroundTransparency = 0.08
    Frame.BorderSizePixel = 0
    Frame.Parent = parent

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 10)
    Corner.Parent = Frame

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(100, 70, 180)
    Stroke.Thickness = 1.5
    Stroke.Transparency = 0.15
    Stroke.Parent = Frame

    -- FPS
    FPSLabel = Instance.new("TextLabel")
    FPSLabel.Name = "FPS"
    FPSLabel.Size = UDim2.new(1, -10, 0.5, 0)
    FPSLabel.Position = UDim2.new(0, 5, 0, 2)
    FPSLabel.BackgroundTransparency = 1
    FPSLabel.Text = "FPS: --"
    FPSLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    FPSLabel.TextSize = 15
    FPSLabel.Font = Enum.Font.GothamBold
    FPSLabel.TextXAlignment = Enum.TextXAlignment.Left
    FPSLabel.Parent = Frame

    -- PING
    PingLabel = Instance.new("TextLabel")
    PingLabel.Name = "Ping"
    PingLabel.Size = UDim2.new(1, -10, 0.5, 0)
    PingLabel.Position = UDim2.new(0, 5, 0.5, -2)
    PingLabel.BackgroundTransparency = 1
    PingLabel.Text = "PING: --"
    PingLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    PingLabel.TextSize = 15
    PingLabel.Font = Enum.Font.GothamBold
    PingLabel.TextXAlignment = Enum.TextXAlignment.Left
    PingLabel.Parent = Frame

    return Frame
end

--========================================================--
--                     PEGAR PING                        --
--========================================================--

local function GetPing()

    local Ping = "--"

    pcall(function()

        local Network = Stats:FindFirstChild("Network")

        if Network then

            local ServerStats =
                Network:FindFirstChild("ServerStatsItem")

            if ServerStats then

                local DataPing =
                    ServerStats:FindFirstChild("Data Ping")

                if DataPing then

                    local Value =
                        DataPing:GetValueString()

                    Ping = Value
                end
            end
        end

    end)

    return Ping
end

--========================================================--
--                     ATUALIZAR                         --
--========================================================--

local function Update()

    if not FPSLabel or not PingLabel then
        return
    end

    FPSLabel.Text = "FPS: " .. math.floor(FPS)

    PingLabel.Text = "PING: " .. tostring(GetPing())

end

--========================================================--
--                      INICIAR                          --
--========================================================--

function Monitor.Start(parent)

    if not Frame then
        Monitor.Create(parent)
    end

    if Connection then
        return
    end

    Frames = 0
    FPS = 0
    LastUpdate = tick()

    Connection = RunService.RenderStepped:Connect(function()

        Frames += 1

        local Now = tick()
        local Difference = Now - LastUpdate

        if Difference >= 1 then

            FPS = Frames / Difference

            Frames = 0
            LastUpdate = Now

            Update()
        end

    end)

end

--========================================================--
--                       PARAR                           --
--========================================================--

function Monitor.Stop()

    if Connection then
        Connection:Disconnect()
        Connection = nil
    end

end

--========================================================--
--                      VISIBILIDADE                     --
--========================================================--

function Monitor.SetVisible(enabled)

    if Frame then
        Frame.Visible = enabled == true
    end

end

--========================================================--
--                     DESTRUIR                          --
--========================================================--

function Monitor.Destroy()

    Monitor.Stop()

    if Frame then
        Frame:Destroy()
        Frame = nil
    end

    FPSLabel = nil
    PingLabel = nil

end

return Monitor
