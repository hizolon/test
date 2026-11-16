-- logic.lua
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local Workspace = game:GetService("Workspace")
local Player = Players.LocalPlayer
local FCS = getgenv().FCS

if not FCS then return end

local function Message(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", { Title = title or "", Text = text or "", Duration = duration or 3 })
    end)
end

-- Ждём, пока main.lua создаст страницы
while not (FCS.pages and FCS.pages["HP"]) do task.wait(0.1) end
local HPPage = FCS.pages["HP"]
local TelepotsPage = FCS.pages["Telepots"]
local SettingsPage = FCS.pages["Settings"]

local Unlocked = false
-- Слушаем разблокировку (чтобы кнопки работали только после ввода ключа)
task.spawn(function()
    while true do
        task.wait(0.1)
        Unlocked = FCS.Unlocked
    end
end)

-- =========================================================
--  HP
-- =========================================================
local Hp = { god = false }
local HP_PAD = 7
local HP_VAL = 55
local HP_STEP = 44
local HP_MIN = 1
local HP_MAX = 99

local function hpBtn(y, name, onClick)
    local b = Instance.new("TextButton")
    b.Position, b.Size = UDim2.new(0, HP_PAD, 0, y), UDim2.new(1, -14, 0, 28)
    b.BackgroundColor3, b.Text, b.TextColor3 = Color3.fromRGB(60, 60, 60), name .. ": OFF", Color3.fromRGB(255, 255, 255)
    b.Font, b.TextSize, b.TextXAlignment, b.Parent = Enum.Font.SourceSansBold, 12, Enum.TextXAlignment.Left, HPPage
    local p = Instance.new("UIPadding"); p.PaddingLeft = UDim.new(0, 8); p.Parent = b
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 4); c.Parent = b
    local state = false
    b.MouseButton1Click:Connect(function()
        if not Unlocked then return end
        state = not state
        b.Text = name .. ": " .. (state and "ON" or "OFF")
        b.BackgroundColor3 = state and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(60, 60, 60)
        if onClick then onClick(state) end
    end)
end

local function hpSlider(y, name, def)
    local btn = Instance.new("TextButton")
    btn.Position, btn.Size = UDim2.new(0, HP_PAD, 0, y), UDim2.new(1, -(HP_PAD * 2 + 6 + HP_VAL), 0, 24)
    btn.BackgroundColor3, btn.Text, btn.TextColor3 = Color3.fromRGB(60, 60, 60), name .. ": OFF", Color3.fromRGB(255, 255, 255)
    btn.Font, btn.TextSize, btn.TextXAlignment, btn.Parent = Enum.Font.SourceSansBold, 12, Enum.TextXAlignment.Left, HPPage
    local bp = Instance.new("UIPadding"); bp.PaddingLeft = UDim.new(0, 8); bp.Parent = btn
    local bc = Instance.new("UICorner"); bc.CornerRadius = UDim.new(0, 4); bc.Parent = btn

    local val = Instance.new("TextLabel")
    val.AnchorPoint, val.Position, val.Size = Vector2.new(1, 0), UDim2.new(1, -HP_PAD, 0, y), UDim2.new(0, HP_VAL, 0, 24)
    val.BackgroundColor3, val.Text, val.TextColor3, val.TextSize = Color3.fromRGB(45, 45, 45), tostring(def), Color3.fromRGB(255, 255, 255), 12
    val.Font, val.Parent = Enum.Font.SourceSansBold, HPPage
    local vc = Instance.new("UICorner"); vc.CornerRadius = UDim.new(0, 4); vc.Parent = val

    local slider = Instance.new("Frame")
    slider.Position, slider.Size, slider.BackgroundColor3, slider.Parent = UDim2.new(0, HP_PAD, 0, y + 30), UDim2.new(1, -(HP_PAD * 2), 0, 8), Color3.fromRGB(55, 55, 55), HPPage
    local sc = Instance.new("UICorner"); sc.CornerRadius = UDim.new(1, 0); sc.Parent = slider

    local fill = Instance.new("Frame")
    fill.Size, fill.BackgroundColor3, fill.Parent = UDim2.new((def - HP_MIN) / (HP_MAX - HP_MIN), 0, 1, 0), Color3.fromRGB(255, 0, 0), slider
    local fc = Instance.new("UICorner"); fc.CornerRadius = UDim.new(1, 0); fc.Parent = fill

    local knob = Instance.new("Frame")
    knob.Size, knob.Position, knob.BackgroundColor3, knob.ZIndex, knob.Parent = UDim2.fromOffset(14, 14), UDim2.new((def - HP_MIN) / (HP_MAX - HP_MIN), -7, 0.5, -7), Color3.fromRGB(255, 255, 255), 2, slider
    local kc = Instance.new("UICorner"); kc.CornerRadius = UDim.new(1, 0); kc.Parent = knob

    local state = { enabled = false, value = def }
    local dragging = false
    local function update(x)
        local alpha = math.clamp((x - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
        state.value = math.floor(HP_MIN + alpha * (HP_MAX - HP_MIN) + 0.5)
        fill.Size = UDim2.new(alpha, 0, 1, 0)
        knob.Position = UDim2.new(alpha, -7, 0.5, -7)
        val.Text = tostring(state.value)
    end
    slider.InputBegan:Connect(function(input)
        if not Unlocked then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true; update(input.Position.X) end
    end)
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then update(input.Position.X) end
    end)
    game:GetService("UserInputService").InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
    btn.MouseButton1Click:Connect(function()
        if not Unlocked then return end
        state.enabled = not state.enabled
        btn.Text = name .. ": " .. (state.enabled and "ON" or "OFF")
        btn.BackgroundColor3 = state.enabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(60, 60, 60)
    end)
    return state
end

hpBtn(7, "Save zona", function(s)
    if s then
        local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.CFrame = CFrame.new(0, -990, 0) end
    end
end)
local autoSave = hpSlider(40, "Auto save zona", 30)
hpBtn(88, "Reset", function(s)
    if s then
        local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.CFrame = CFrame.new(0, -400, 0) end
    end
end)
local autoReset = hpSlider(122, "Auto reset", 30)
hpBtn(170, "Respawn last pos", function(s) end)
hpBtn(204, "God Mode", function(s)
    Hp.god = s
    if s then
        Hp.godConn = RunService.Heartbeat:Connect(function()
            pcall(function() Workspace.FallenPartsDestroyHeight = -math.huge end)
            local hum = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health <= 0 then hum.Health = hum.MaxHealth end
        end)
    else
        if Hp.godConn then Hp.godConn:Disconnect(); Hp.godConn = nil end
    end
end)

-- =========================================================
--  TELEPOTS
-- =========================================================
local function tpBtn(y, name, x, yy, z)
    local b = Instance.new("TextButton")
    b.Position, b.Size = UDim2.new(0, 7, 0, y), UDim2.new(1, -14, 0, 28)
    b.BackgroundColor3, b.Text, b.TextColor3 = Color3.fromRGB(60, 60, 60), name, Color3.fromRGB(255, 255, 255)
    b.Font, b.TextSize, b.TextXAlignment, b.Parent = Enum.Font.SourceSansBold, 12, Enum.TextXAlignment.Left, TelepotsPage
    local p = Instance.new("UIPadding"); p.PaddingLeft = UDim.new(0, 8); p.Parent = b
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 4); c.Parent = b
    b.MouseButton1Click:Connect(function()
        if not Unlocked then return end
        local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.CFrame = CFrame.new(x, yy, z) end
    end)
end
tpBtn(7, "Центр", 148, 442, 27)
tpBtn(40, "Гора 1", 241, 702, 460)
tpBtn(73, "Гора 2", -107, 642, -328)
tpBtn(106, "Далёкая", 10000, 1000, 10000)

-- =========================================================
--  SETTINGS
-- =========================================================
local function setBtn(y, name, onClick, color)
    local b = Instance.new("TextButton")
    b.Position, b.Size = UDim2.new(0, 7, 0, y), UDim2.new(1, -14, 0, 28)
    b.BackgroundColor3, b.Text, b.TextColor3 = color or Color3.fromRGB(60, 60, 60), name, Color3.fromRGB(255, 255, 255)
    b.Font, b.TextSize, b.TextXAlignment, b.Parent = Enum.Font.SourceSansBold, 12, Enum.TextXAlignment.Left, SettingsPage
    local p = Instance.new("UIPadding"); p.PaddingLeft = UDim.new(0, 8); p.Parent = b
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 4); c.Parent = b
    b.MouseButton1Click:Connect(function() if Unlocked and onClick then onClick(b) end end)
    return b
end
setBtn(7, "Переподключиться", function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, Player) end)
setBtn(40, "Другой сервер", function() TeleportService:Teleport(game.PlaceId, Player) end)
setBtn(73, "No shadows: OFF", function(b)
    Lighting.GlobalShadows = not Lighting.GlobalShadows
    b.Text = "No shadows: " .. (Lighting.GlobalShadows and "OFF" or "ON")
    b.BackgroundColor3 = Lighting.GlobalShadows and Color3.fromRGB(60, 60, 60) or Color3.fromRGB(0, 150, 0)
end)
setBtn(106, "FPS BOOST: OFF", function(b)
    if settings().Rendering.QualityLevel == 1 then settings().Rendering.QualityLevel = 5; b.Text = "FPS BOOST: OFF"
    else settings().Rendering.QualityLevel = 1; b.Text = "FPS BOOST: ON" end
end)
local closeBtn = setBtn(139, "Закрыть скрипт", function() if FCS.ScreenGui then FCS.ScreenGui:Destroy() end end, Color3.fromRGB(180, 0, 0))
closeBtn.TextXAlignment = Enum.TextXAlignment.Center
