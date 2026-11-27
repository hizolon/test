-- hp.lua
local page = getgenv().FCS.pages["HP"]
if not page then return end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")
local UIS = game:GetService("UserInputService")
local Player = Players.LocalPlayer
local FCS = getgenv().FCS

local HP_SIDE_PADDING = 7
local HP_GAP = 6
local HP_VALUE_WIDTH = 55
local HP_MIN_VALUE = 1
local HP_MAX_VALUE = 99
local HP_HYSTERESIS = 5
local HP_SHIELD_RESTORE = 10

local HP_RESPAWN_Y_MIN = 100
local HP_RESPAWN_Y_MAX = 2000

local function hpCreateButton(name, yBase)
    local b = Instance.new("TextButton")
    b.Name = name
    b.Position = UDim2.new(0, HP_SIDE_PADDING, 0, yBase)
    b.Size = UDim2.new(1, -14, 0, 28)
    b.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    b.BorderSizePixel = 0
    b.Text = name .. ": OFF"
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Font = Enum.Font.SourceSansBold
    b.TextSize = 12
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.Parent = page

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 8)
    pad.Parent = b

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 4)
    c.Parent = b

    local state = { enabled = false, button = b, name = name }
    b.MouseButton1Click:Connect(function()
        if not FCS.Unlocked then return end
        state.enabled = not state.enabled
        b.Text = name .. ": " .. (state.enabled and "ON" or "OFF")
        b.BackgroundColor3 = state.enabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(60, 60, 60)
        if state.onChanged then state.onChanged(state.enabled) end
    end)
    return state
end

local function hpCreateTapButton(name, yBase, color)
    local b = Instance.new("TextButton")
    b.Name = name
    b.Position = UDim2.new(0, HP_SIDE_PADDING, 0, yBase)
    b.Size = UDim2.new(1, -14, 0, 28)
    b.BackgroundColor3 = color or Color3.fromRGB(180, 0, 0)
    b.BorderSizePixel = 0
    b.Text = name
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Font = Enum.Font.SourceSansBold
    b.TextSize = 12
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.Parent = page

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 8)
    pad.Parent = b

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 4)
    c.Parent = b

    return b
end

local function hpCreateSliderRow(name, yBase)
    local Btn = Instance.new("TextButton")
    Btn.Name = name .. "Button"
    Btn.Position = UDim2.new(0, HP_SIDE_PADDING, 0, yBase)
    Btn.Size = UDim2.new(1, -(HP_SIDE_PADDING * 2 + HP_GAP + HP_VALUE_WIDTH), 0, 24)
    Btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    Btn.BorderSizePixel = 0
    Btn.Text = name .. ": OFF"
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.SourceSansBold
    Btn.TextSize = 12
    Btn.TextXAlignment = Enum.TextXAlignment.Left
    Btn.Parent = page

    local BtnPadding = Instance.new("UIPadding")
    BtnPadding.PaddingLeft = UDim.new(0, 8)
    BtnPadding.Parent = Btn

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 4)
    BtnCorner.Parent = Btn

    local Val = Instance.new("TextLabel")
    Val.Name = name .. "Value"
    Val.AnchorPoint = Vector2.new(1, 0)
    Val.Position = UDim2.new(1, -HP_SIDE_PADDING, 0, yBase)
    Val.Size = UDim2.new(0, HP_VALUE_WIDTH, 0, 24)
    Val.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    Val.BorderSizePixel = 0
    Val.Text = tostring(HP_MIN_VALUE)
    Val.TextColor3 = Color3.fromRGB(255, 255, 255)
    Val.Font = Enum.Font.SourceSansBold
    Val.TextSize = 12
    Val.Parent = page

    local ValCorner = Instance.new("UICorner")
    ValCorner.CornerRadius = UDim.new(0, 4)
    ValCorner.Parent = Val

    local Slider = Instance.new("Frame")
    Slider.Name = name .. "SliderBack"
    Slider.Position = UDim2.new(0, HP_SIDE_PADDING, 0, yBase + 32)
    Slider.Size = UDim2.new(1, -(HP_SIDE_PADDING * 2), 0, 8)
    Slider.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    Slider.BorderSizePixel = 0
    Slider.Parent = page

    local SliderCorner = Instance.new("UICorner")
    SliderCorner.CornerRadius = UDim.new(1, 0)
    SliderCorner.Parent = Slider

    local Fill = Instance.new("Frame")
    Fill.Name = name .. "SliderFill"
    Fill.Position = UDim2.new(0, 0, 0, 0)
    Fill.Size = UDim2.new(0, 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    Fill.BorderSizePixel = 0
    Fill.Parent = Slider

    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(1, 0)
    FillCorner.Parent = Fill

    local Knob = Instance.new("Frame")
    Knob.Name = name .. "SliderKnob"
    Knob.Size = UDim2.fromOffset(14, 14)
    Knob.Position = UDim2.new(0, -7, 0.5, -7)
    Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Knob.BorderSizePixel = 0
    Knob.ZIndex = 2
    Knob.Parent = Slider

    local KnobCorner = Instance.new("UICorner")
    KnobCorner.CornerRadius = UDim.new(1, 0)
    KnobCorner.Parent = Knob

    local row = {
        Button = Btn,
        Value = Val,
        SliderBack = Slider,
        SliderFill = Fill,
        SliderKnob = Knob,
        enabled = false,
        value = HP_MIN_VALUE,
        name = name,
    }

    Btn.MouseButton1Click:Connect(function()
        if not FCS.Unlocked then return end
        row.enabled = not row.enabled
        Btn.Text = name .. ": " .. (row.enabled and "ON" or "OFF")
        Btn.BackgroundColor3 = row.enabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(60, 60, 60)
        if row.onChanged then row.onChanged(row.enabled) end
    end)

    return row
end

local function hpUpdateRowVisual(row)
    local alpha = (row.value - HP_MIN_VALUE) / (HP_MAX_VALUE - HP_MIN_VALUE)
    alpha = math.clamp(alpha, 0, 1)
    row.SliderFill.Size = UDim2.new(alpha, 0, 1, 0)
    row.SliderKnob.Position = UDim2.new(alpha, -7, 0.5, -7)
    row.Value.Text = tostring(math.floor(row.value + 0.5))
end

local function hpSetRowFromX(row, mouseX)
    local absPos = row.SliderBack.AbsolutePosition
    local absSize = row.SliderBack.AbsoluteSize
    if absSize.X <= 0 then return end
    local alpha = math.clamp((mouseX - absPos.X) / absSize.X, 0, 1)
    row.value = math.floor(HP_MIN_VALUE + alpha * (HP_MAX_VALUE - HP_MIN_VALUE) + 0.5)
    row.value = math.clamp(row.value, HP_MIN_VALUE, HP_MAX_VALUE)
    hpUpdateRowVisual(row)
end

local hpDraggingSlider = false
local hpActiveRow = nil
local function hpSetupSliderDrag(row)
    row.SliderBack.InputBegan:Connect(function(input)
        if not FCS.Unlocked then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            hpDraggingSlider = true
            hpActiveRow = row
            hpSetRowFromX(row, input.Position.X)
        end
    end)
end
UIS.InputChanged:Connect(function(input)
    if hpDraggingSlider and hpActiveRow and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        hpSetRowFromX(hpActiveRow, input.Position.X)
    end
end)
UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        hpDraggingSlider = false
        hpActiveRow = nil
    end
end)

-- ===== HP логика =====
local HP_PLATFORM_Y = -1000
local HP_RESET_Y = -400

local HP_DEFAULT_FALL_Y = nil
pcall(function() HP_DEFAULT_FALL_Y = Workspace.FallenPartsDestroyHeight end)
if not HP_DEFAULT_FALL_Y or HP_DEFAULT_FALL_Y == -math.huge then HP_DEFAULT_FALL_Y = -500 end

local function getChar() return Player.Character end
local function getHRP() local c = getChar(); return c and c:FindFirstChild("HumanoidRootPart") end
local function getHum() local c = getChar(); return c and c:FindFirstChildOfClass("Humanoid") end

local function ensurePlatform()
    local old = Workspace:FindFirstChild("AntiFallPlatform")
    if old then
        old.CanCollide = true
        old.Anchored = true
        return old
    end
    local p = Instance.new("Part")
    p.Name = "AntiFallPlatform"
    p.Size = Vector3.new(2000, 4, 2000)
    p.Position = Vector3.new(0, HP_PLATFORM_Y, 0)
    p.Anchored = true
    p.CanCollide = true
    p.Transparency = 0.5
    p.Material = Enum.Material.SmoothPlastic
    p.Color = Color3.fromRGB(0, 255, 255)
    p.Parent = Workspace
    return p
end
local function destroyPlatform()
    local old = Workspace:FindFirstChild("AntiFallPlatform")
    if old then old:Destroy() end
end

local respawnEnabled = false
local POSITION_BUFFER = {}
local BUFFER_SECONDS = 2

local function updatePositionBuffer()
    if not respawnEnabled then return end
    if FCS.saveZonaEnabled then return end
    if FCS.godEnabled then return end
    local hrp = getHRP()
    if not hrp then return end
    local y = hrp.Position.Y
    if y < HP_RESPAWN_Y_MIN or y > HP_RESPAWN_Y_MAX then return end
    local now = os.clock()
    table.insert(POSITION_BUFFER, { t = now, cf = hrp.CFrame })
    while #POSITION_BUFFER > 0 and now - POSITION_BUFFER[1].t > BUFFER_SECONDS do
        table.remove(POSITION_BUFFER, 1)
    end
end

local function getPosition2SecAgo()
    if #POSITION_BUFFER == 0 then return nil end
    return POSITION_BUFFER[1].cf
end

local godHeartbeatConn = nil
local godHealthConns = {}
local godRootConns = {}
local godCharacterConn = nil
local godStateConns = {}

local function hookGodHumanoid(hum)
    table.insert(godHealthConns, hum.HealthChanged:Connect(function(h)
        if FCS.godEnabled and h <= 0 then
            hum.Health = hum.MaxHealth
            hum:ChangeState(Enum.HumanoidStateType.Running)
        end
    end))
    pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false) end)
    table.insert(godStateConns, hum.StateChanged:Connect(function(_, new)
        if FCS.godEnabled and new == Enum.HumanoidStateType.Dead then
            hum.Health = hum.MaxHealth
            hum:ChangeState(Enum.HumanoidStateType.Running)
        end
    end))
end

local function hookGodCharacter(char)
    local hum = char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid", 5)
    if hum then hookGodHumanoid(hum) end

    local hrp = char:FindFirstChild("HumanoidRootPart") or char:WaitForChild("HumanoidRootPart", 5)
    if hrp then
        table.insert(godRootConns, RunService.Heartbeat:Connect(function()
            if FCS.godEnabled and hrp and hrp.Parent == nil then
                hrp = char:FindFirstChild("HumanoidRootPart")
            end
        end))
    end
end

local function enableGodModeHP()
    if FCS.godEnabled then return end
    FCS.godEnabled = true

    godHeartbeatConn = RunService.Heartbeat:Connect(function()
        pcall(function() Workspace.FallenPartsDestroyHeight = -math.huge end)
    end)

    local char = getChar()
    if char then hookGodCharacter(char) end
    godCharacterConn = Player.CharacterAdded:Connect(function(c)
        hookGodCharacter(c)
    end)
end

local function disableGodModeHP()
    if not FCS.godEnabled then return end
    FCS.godEnabled = false

    if godHeartbeatConn then godHeartbeatConn:Disconnect(); godHeartbeatConn = nil end
    if godCharacterConn then godCharacterConn:Disconnect(); godCharacterConn = nil end
    for _, c in ipairs(godHealthConns) do c:Disconnect() end
    godHealthConns = {}
    for _, c in ipairs(godRootConns) do c:Disconnect() end
    godRootConns = {}
    for _, c in ipairs(godStateConns) do c:Disconnect() end
    godStateConns = {}

    pcall(function() Workspace.FallenPartsDestroyHeight = HP_DEFAULT_FALL_Y end)
    local hum = getHum()
    if hum then
        pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true) end)
    end
end

local saveShieldEnabled = false
local saveShieldHealthConn = nil
local saveShieldStateConn = nil
local saveShieldCharacterConn = nil
local saveShieldTargetHP = nil

local function hookSaveShieldHum(hum)
    if saveShieldHealthConn then saveShieldHealthConn:Disconnect() end
    if saveShieldStateConn then saveShieldStateConn:Disconnect() end

    saveShieldHealthConn = hum.HealthChanged:Connect(function(h)
        if not saveShieldEnabled then return end
        if h <= 0 then
            hum.Health = hum.MaxHealth
            hum:ChangeState(Enum.HumanoidStateType.Running)
        elseif saveShieldTargetHP and h < saveShieldTargetHP then
            hum.Health = saveShieldTargetHP
        end
    end)
    pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false) end)
    saveShieldStateConn = hum.StateChanged:Connect(function(_, new)
        if saveShieldEnabled and new == Enum.HumanoidStateType.Dead then
            hum.Health = hum.MaxHealth
            hum:ChangeState(Enum.HumanoidStateType.Running)
        end
    end)
end

local function enableSaveShield(targetHPPercent)
    if saveShieldEnabled then
        local hum = getHum()
        saveShieldTargetHP = targetHPPercent and hum and (hum.MaxHealth * targetHPPercent / 100) or nil
        return
    end
    saveShieldEnabled = true

    pcall(function() Workspace.FallenPartsDestroyHeight = -math.huge end)

    local hum = getHum()
    if hum then
        saveShieldTargetHP = targetHPPercent and (hum.MaxHealth * targetHPPercent / 100) or nil
        if saveShieldTargetHP and hum.Health < saveShieldTargetHP then
            hum.Health = saveShieldTargetHP
        end
        hookSaveShieldHum(hum)
    end

    if saveShieldCharacterConn then saveShieldCharacterConn:Disconnect() end
    saveShieldCharacterConn = Player.CharacterAdded:Connect(function(c)
        if not saveShieldEnabled then return end
        local h = c:WaitForChild("Humanoid", 5)
        if h then
            if saveShieldTargetHP and h.Health < saveShieldTargetHP then
                h.Health = saveShieldTargetHP
            end
            hookSaveShieldHum(h)
        end
    end)
end

local function disableSaveShield()
    if not saveShieldEnabled then return end
    saveShieldEnabled = false
    saveShieldTargetHP = nil

    if saveShieldHealthConn then saveShieldHealthConn:Disconnect(); saveShieldHealthConn = nil end
    if saveShieldStateConn then saveShieldStateConn:Disconnect(); saveShieldStateConn = nil end
    if saveShieldCharacterConn then saveShieldCharacterConn:Disconnect(); saveShieldCharacterConn = nil end

    if not FCS.godEnabled then
        pcall(function() Workspace.FallenPartsDestroyHeight = HP_DEFAULT_FALL_Y end)
    end

    local hum = getHum()
    if hum then
        pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true) end)
    end
end

Player.CharacterAdded:Connect(function(char)
    if not respawnEnabled then return end
    local savedCF = getPosition2SecAgo()
    if not savedCF then return end
    local hrp = char:WaitForChild("HumanoidRootPart", 5)
    if hrp then
        task.wait(0.3)
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        hrp.CFrame = savedCF
        task.wait(0.05)
        local hrp2 = char:FindFirstChild("HumanoidRootPart")
        if hrp2 then
            hrp2.AssemblyLinearVelocity = Vector3.zero
            hrp2.CFrame = savedCF
        end
    end
    POSITION_BUFFER = {}
end)

local savedCFrame = nil
local saveZonaThreshold = 0

local function enableSaveZona(restoreHPPercent)
    local hrp = getHRP()
    if not hrp then return end

    savedCFrame = hrp.CFrame
    enableSaveShield(restoreHPPercent)

    POSITION_BUFFER = {}
    if respawnEnabled then
        table.insert(POSITION_BUFFER, { t = os.clock(), cf = savedCFrame })
    end

    ensurePlatform()

    hrp.AssemblyLinearVelocity = Vector3.zero
    hrp.AssemblyAngularVelocity = Vector3.zero
    hrp.CFrame = CFrame.new(0, HP_PLATFORM_Y + 10, 0)
    task.wait(0.1)
    local hrp2 = getHRP()
    if hrp2 then
        hrp2.AssemblyLinearVelocity = Vector3.zero
        hrp2.AssemblyAngularVelocity = Vector3.zero
    end

    FCS.saveZonaEnabled = true
end

local function disableSaveZona(restore)
    if not FCS.saveZonaEnabled then return end
    FCS.saveZonaEnabled = false
    local restoreCF = savedCFrame
    if restoreCF and restore ~= false then
        local hrp = getHRP()
        if hrp then
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.CFrame = restoreCF
        end
    end
    savedCFrame = nil

    disableSaveShield()
    destroyPlatform()

    if respawnEnabled and restoreCF then
        POSITION_BUFFER = { { t = os.clock(), cf = restoreCF } }
    else
        POSITION_BUFFER = {}
    end
end

local resetInProgress = false
local function doReset()
    if resetInProgress then return end
    resetInProgress = true
    local hrp = getHRP()
    if hrp then
        pcall(function() Workspace.FallenPartsDestroyHeight = HP_DEFAULT_FALL_Y end)
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.CFrame = CFrame.new(0, HP_RESET_Y, 0)
    end
    task.delay(2, function()
        resetInProgress = false
        if FCS.godEnabled or saveShieldEnabled then
            pcall(function() Workspace.FallenPartsDestroyHeight = -math.huge end)
        end
    end)
end

-- UI сборка HP
local saveZonaBtn = hpCreateButton("Save zona", 6)
saveZonaBtn.button.Size = UDim2.new(1, -(HP_SIDE_PADDING * 2 + HP_GAP + HP_VALUE_WIDTH), 0, 24)
saveZonaBtn.onChanged = function(en)
    if en then enableSaveZona(50) else disableSaveZona() end
end

-- Горячая клавиша Save zona (стиль как у Aim)
local SaveZonaKeyBox = Instance.new("TextBox")
SaveZonaKeyBox.Name = "SaveZonaKeyBox"
SaveZonaKeyBox.AnchorPoint = Vector2.new(1, 0)
SaveZonaKeyBox.Position = UDim2.new(1, -HP_SIDE_PADDING, 0, 6)
SaveZonaKeyBox.Size = UDim2.new(0, HP_VALUE_WIDTH, 0, 24)
SaveZonaKeyBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
SaveZonaKeyBox.BorderSizePixel = 0
SaveZonaKeyBox.Text = "H"
SaveZonaKeyBox.PlaceholderText = "..."
SaveZonaKeyBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
SaveZonaKeyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SaveZonaKeyBox.Font = Enum.Font.SourceSansBold
SaveZonaKeyBox.TextSize = 12
SaveZonaKeyBox.ClearTextOnFocus = false
SaveZonaKeyBox.Parent = page

local saveZonaKeyCorner = Instance.new("UICorner")
saveZonaKeyCorner.CornerRadius = UDim.new(0, 4)
saveZonaKeyCorner.Parent = SaveZonaKeyBox

local function hpNormalizeKey(s)
    s = string.upper(s)
    s = string.gsub(s, "[^A-Z0-9]", "")
    return s
end

local function hpKeyFromString(s)
    s = hpNormalizeKey(s)
    if s == "" then return nil end
    local digitNames = { ["1"]="One", ["2"]="Two", ["3"]="Three", ["4"]="Four", ["5"]="Five", ["6"]="Six", ["7"]="Seven", ["8"]="Eight", ["9"]="Nine", ["0"]="Zero" }
    local name = digitNames[s] or s
    local ok, key = pcall(function() return Enum.KeyCode[name] end)
    if ok and key then return key end
    return nil
end

local saveZonaHotkey = Enum.KeyCode.H

local function hpRefreshSaveZonaHotkey()
    local raw = SaveZonaKeyBox.Text
    local normalized = hpNormalizeKey(raw)
    if normalized ~= raw then SaveZonaKeyBox.Text = normalized; return end
    if normalized == "" then saveZonaHotkey = nil; return end
    local key = hpKeyFromString(normalized)
    if key then saveZonaHotkey = key else SaveZonaKeyBox.Text = ""; saveZonaHotkey = nil end
end

SaveZonaKeyBox:GetPropertyChangedSignal("Text"):Connect(hpRefreshSaveZonaHotkey)
SaveZonaKeyBox.FocusLost:Connect(function() SaveZonaKeyBox:ReleaseFocus() end)

local function toggleSaveZona()
    if not saveZonaBtn then return end
    saveZonaBtn.enabled = not saveZonaBtn.enabled
    saveZonaBtn.button.Text = saveZonaBtn.name .. ": " .. (saveZonaBtn.enabled and "ON" or "OFF")
    saveZonaBtn.button.BackgroundColor3 = saveZonaBtn.enabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(60, 60, 60)
    if saveZonaBtn.onChanged then saveZonaBtn.onChanged(saveZonaBtn.enabled) end
end

UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if saveZonaHotkey and input.KeyCode == saveZonaHotkey then
        if FCS.Unlocked then toggleSaveZona() end
    end
end)

local autoSaveRow = hpCreateSliderRow("Auto save zona", 40)
autoSaveRow.value = 30
hpUpdateRowVisual(autoSaveRow)
hpSetupSliderDrag(autoSaveRow)
autoSaveRow.onChanged = function(_) end

local resetBtn = hpCreateTapButton("Reset", 88, Color3.fromRGB(180, 0, 0))
resetBtn.MouseButton1Click:Connect(function()
    if not FCS.Unlocked then return end
    resetBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    task.delay(0.2, function()
        resetBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
    end)
    doReset()
end)

local autoResetRow = hpCreateSliderRow("Auto reset", 122)
autoResetRow.value = 30
hpUpdateRowVisual(autoResetRow)
hpSetupSliderDrag(autoResetRow)
autoResetRow.onChanged = function(_) end

local respawnBtn = hpCreateButton("Respawn last pos", 170)
respawnBtn.onChanged = function(en)
    respawnEnabled = en
    if not en then POSITION_BUFFER = {} end
end

local godBtn = hpCreateButton("God Mode", 204)
godBtn.onChanged = function(en)
    if en then enableGodModeHP() else disableGodModeHP() end
end

local HPFooter = Instance.new("TextLabel")
HPFooter.Name = "Footer"
HPFooter.AnchorPoint = Vector2.new(0.5, 0)
HPFooter.Position = UDim2.new(0.5, 0, 0, 236)
HPFooter.Size = UDim2.new(1, -14, 0, 22)
HPFooter.BackgroundTransparency = 1
HPFooter.Text = "(>'-'<)"
HPFooter.TextColor3 = Color3.fromRGB(255, 255, 255)
HPFooter.TextTransparency = 0.75
HPFooter.Font = Enum.Font.SourceSansBold
HPFooter.TextSize = 12
HPFooter.TextXAlignment = Enum.TextXAlignment.Center
HPFooter.Parent = page

local lastAutoReset = 0

RunService.Heartbeat:Connect(function()
    updatePositionBuffer()

    local hum = getHum()
    if not hum then return end
    local now = os.clock()
    local hpPercent = (hum.Health / hum.MaxHealth) * 100

    if autoSaveRow.enabled then
        local threshold = autoSaveRow.value
        if not FCS.saveZonaEnabled then
            if hpPercent <= threshold then
                saveZonaThreshold = threshold
                local restoreTo = math.min(threshold + HP_SHIELD_RESTORE, 100)
                enableSaveZona(restoreTo)
            end
        else
            if hpPercent >= (saveZonaThreshold + HP_HYSTERESIS) then
                disableSaveZona(true)
            else
                local hrp = getHRP()
                if hrp and (hrp.Position - Vector3.new(0, HP_PLATFORM_Y + 10, 0)).Magnitude > 50 then
                    hrp.CFrame = CFrame.new(0, HP_PLATFORM_Y + 10, 0)
                end
            end
        end
    end

    if autoResetRow.enabled and hpPercent <= autoResetRow.value then
        if now - lastAutoReset >= 3 then
            lastAutoReset = now
            doReset()
        end
    end
end)
