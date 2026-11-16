-- movement.lua (Полная оригинальная вкладка Movement со всеми ползунками и Fly)
local page = getgenv().FCS.pages["Movement"]
if not page then return end
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Player = Players.LocalPlayer
local FCS = getgenv().FCS

local MV_SIDE_PADDING = 7
local MV_GAP = 6
local MV_VALUE_WIDTH = 55
local MV_ROW_STEP = 44
local MV_SLIDER_OFFSET = 30
local MV_MIN_SPEED = 0

local function mvCreateSpeedRow(order, labelText, maxSpeed, defaultEnabled)
    local yBase = 7 + (order - 1) * MV_ROW_STEP

    local Btn = Instance.new("TextButton")
    Btn.Name = labelText .. "Button"
    Btn.Position = UDim2.new(0, MV_SIDE_PADDING, 0, yBase)
    Btn.Size = UDim2.new(1, -(MV_SIDE_PADDING * 2 + MV_GAP + MV_VALUE_WIDTH), 0, 24)
    Btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    Btn.BorderSizePixel = 0
    Btn.Text = labelText .. ": OFF"
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
    Val.Name = labelText .. "Value"
    Val.AnchorPoint = Vector2.new(1, 0)
    Val.Position = UDim2.new(1, -MV_SIDE_PADDING, 0, yBase)
    Val.Size = UDim2.new(0, MV_VALUE_WIDTH, 0, 24)
    Val.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    Val.BorderSizePixel = 0
    Val.Text = "0"
    Val.TextColor3 = Color3.fromRGB(255, 255, 255)
    Val.Font = Enum.Font.SourceSansBold
    Val.TextSize = 12
    Val.Parent = page

    local ValCorner = Instance.new("UICorner")
    ValCorner.CornerRadius = UDim.new(0, 4)
    ValCorner.Parent = Val

    local Slider = Instance.new("Frame")
    Slider.Name = labelText .. "SliderBack"
    Slider.Position = UDim2.new(0, MV_SIDE_PADDING, 0, yBase + MV_SLIDER_OFFSET)
    Slider.Size = UDim2.new(1, -(MV_SIDE_PADDING * 2), 0, 8)
    Slider.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    Slider.BorderSizePixel = 0
    Slider.Parent = page

    local SliderCorner = Instance.new("UICorner")
    SliderCorner.CornerRadius = UDim.new(1, 0)
    SliderCorner.Parent = Slider

    local Fill = Instance.new("Frame")
    Fill.Name = labelText .. "SliderFill"
    Fill.Position = UDim2.new(0, 0, 0, 0)
    Fill.Size = UDim2.new(0, 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    Fill.BorderSizePixel = 0
    Fill.Parent = Slider

    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(1, 0)
    FillCorner.Parent = Fill

    local Knob = Instance.new("Frame")
    Knob.Name = labelText .. "SliderKnob"
    Knob.Size = UDim2.fromOffset(14, 14)
    Knob.Position = UDim2.new(0, -7, 0.5, -7)
    Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Knob.BorderSizePixel = 0
    Knob.ZIndex = 2
    Knob.Parent = Slider

    local KnobCorner = Instance.new("UICorner")
    KnobCorner.CornerRadius = UDim.new(1, 0)
    KnobCorner.Parent = Knob

    return {
        Button = Btn,
        Value = Val,
        SliderBack = Slider,
        SliderFill = Fill,
        SliderKnob = Knob,
        maxSpeed = maxSpeed,
        enabled = defaultEnabled or false,
        value = 0,
    }
end

local function mvUpdateRowVisual(row)
    local alpha = (row.value - MV_MIN_SPEED) / (row.maxSpeed - MV_MIN_SPEED)
    alpha = math.clamp(alpha, 0, 1)
    row.SliderFill.Size = UDim2.new(alpha, 0, 1, 0)
    row.SliderKnob.Position = UDim2.new(alpha, -7, 0.5, -7)
    row.Value.Text = tostring(math.floor(row.value + 0.5))
end

local function mvSetRowFromX(row, mouseX)
    local absPos = row.SliderBack.AbsolutePosition
    local absSize = row.SliderBack.AbsoluteSize
    if absSize.X <= 0 then return end
    local alpha = math.clamp((mouseX - absPos.X) / absSize.X, 0, 1)
    row.value = math.floor(MV_MIN_SPEED + alpha * (row.maxSpeed - MV_MIN_SPEED) + 0.5)
    mvUpdateRowVisual(row)
end

local DEFAULT_WALKSPEED = 16
local walkRow = mvCreateSpeedRow(1, "Speed", 300, false)
walkRow.value = DEFAULT_WALKSPEED
local savedOriginalWalkSpeed = nil

local function applyWalkSpeed()
    if not walkRow.enabled then return end
    local char = Player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = walkRow.value end
end

task.spawn(function()
    while true do
        task.wait(0.1)
        if walkRow.enabled then
            local char = Player.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum and hum.WalkSpeed ~= walkRow.value then hum.WalkSpeed = walkRow.value end
        end
    end
end)

local function hookHumanoid(hum)
    hum.StateChanged:Connect(function() if walkRow.enabled then hum.WalkSpeed = walkRow.value end end)
end

local function onCharacter(char)
    local hum = char:WaitForChild("Humanoid", 5)
    if hum then hookHumanoid(hum) end
    task.wait(0.2)
    applyWalkSpeed()
end

Player.CharacterAdded:Connect(onCharacter)
if Player.Character then onCharacter(Player.Character) end

walkRow.Button.MouseButton1Click:Connect(function()
    if not FCS.Unlocked then return end
    local char = Player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    walkRow.enabled = not walkRow.enabled
    walkRow.Button.Text = "Speed: " .. (walkRow.enabled and "ON" or "OFF")
    walkRow.Button.BackgroundColor3 = walkRow.enabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(60, 60, 60)
    if walkRow.enabled then
        if hum then savedOriginalWalkSpeed = hum.WalkSpeed end
        applyWalkSpeed()
    elseif hum then
        hum.WalkSpeed = savedOriginalWalkSpeed or DEFAULT_WALKSPEED
    end
end)

local cframeRow = mvCreateSpeedRow(2, "CFrame Speed", 500, false)
cframeRow.value = 0

local function mvGetMoveDirection()
    local char = Player.Character
    if not char then return Vector3.zero end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return Vector3.zero end
    local moveDir = hum.MoveDirection
    if moveDir.Magnitude > 0.01 then return moveDir.Unit end
    return Vector3.zero
end

RunService.RenderStepped:Connect(function(dt)
    if not cframeRow.enabled then return end
    if cframeRow.value <= 0 then return end
    local char = Player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then return end
    local dir = mvGetMoveDirection()
    if dir.Magnitude < 0.01 then return end
    local distance = cframeRow.value * dt
    local origin = hrp.Position
    local rayDir = dir * distance
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { char }
    params.IgnoreWater = true
    local result = Workspace:Raycast(origin, rayDir, params)
    local targetPos
    if result then
        targetPos = origin + (rayDir.Unit * math.max(0, result.Distance - 0.1))
    else
        targetPos = origin + rayDir
    end
    hrp.CFrame = CFrame.new(targetPos, targetPos + hrp.CFrame.LookVector)
end)

cframeRow.Button.MouseButton1Click:Connect(function()
    if not FCS.Unlocked then return end
    cframeRow.enabled = not cframeRow.enabled
    cframeRow.Button.Text = "CFrame Speed: " .. (cframeRow.enabled and "ON" or "OFF")
    cframeRow.Button.BackgroundColor3 = cframeRow.enabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(60, 60, 60)
end)

local DEFAULT_JUMP = 50
local jumpRow = mvCreateSpeedRow(3, "Jump", 400, false)
jumpRow.value = DEFAULT_JUMP

local function hookJumpHumanoid(hum)
    hum.Jumping:Connect(function(isJumping)
        if not isJumping then return end
        if not jumpRow.enabled then return end
        if jumpRow.value <= 0 then return end
        local hrp = hum.Parent and hum.Parent:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, jumpRow.value, hrp.AssemblyLinearVelocity.Z)
    end)
end

local function onCharacterJump(char)
    local hum = char:WaitForChild("Humanoid", 5)
    if hum then hookJumpHumanoid(hum) end
end

Player.CharacterAdded:Connect(onCharacterJump)
if Player.Character then onCharacterJump(Player.Character) end

jumpRow.Button.MouseButton1Click:Connect(function()
    if not FCS.Unlocked then return end
    jumpRow.enabled = not jumpRow.enabled
    jumpRow.Button.Text = "Jump: " .. (jumpRow.enabled and "ON" or "OFF")
    jumpRow.Button.BackgroundColor3 = jumpRow.enabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(60, 60, 60)
end)

local DEFAULT_HIPHEIGHT = 2
local hipRow = mvCreateSpeedRow(4, "Hip Height", 500, false)
hipRow.value = DEFAULT_HIPHEIGHT
local savedOriginalHipHeight = nil

local function applyHipHeight()
    if not hipRow.enabled then return end
    local char = Player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.HipHeight = hipRow.value end
end

task.spawn(function()
    while true do
        task.wait(0.1)
        if hipRow.enabled then
            local char = Player.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum and hum.HipHeight ~= hipRow.value then hum.HipHeight = hipRow.value end
        end
    end
end)

hipRow.Button.MouseButton1Click:Connect(function()
    if not FCS.Unlocked then return end
    local char = Player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    hipRow.enabled = not hipRow.enabled
    hipRow.Button.Text = "Hip Height: " .. (hipRow.enabled and "ON" or "OFF")
    hipRow.Button.BackgroundColor3 = hipRow.enabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(60, 60, 60)
    if hipRow.enabled then
        if hum then savedOriginalHipHeight = hum.HipHeight end
        applyHipHeight()
    elseif hum then
        hum.HipHeight = savedOriginalHipHeight or DEFAULT_HIPHEIGHT
    end
end)

Player.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid", 5)
    if hum then task.wait(0.2); applyHipHeight() end
end)

local DEFAULT_FOV = 80
local fovRow = mvCreateSpeedRow(5, "Camera FOV", 120, false)
fovRow.value = DEFAULT_FOV
local savedOriginalFOV = nil

local function applyFOV()
    if not fovRow.enabled then return end
    local cam = Workspace.CurrentCamera
    if cam then cam.FieldOfView = fovRow.value end
end

task.spawn(function()
    while true do
        task.wait(0.1)
        if fovRow.enabled then
            local cam = Workspace.CurrentCamera
            if cam and math.abs(cam.FieldOfView - fovRow.value) > 0.01 then cam.FieldOfView = fovRow.value end
        end
    end
end)

fovRow.Button.MouseButton1Click:Connect(function()
    if not FCS.Unlocked then return end
    local cam = Workspace.CurrentCamera
    fovRow.enabled = not fovRow.enabled
    fovRow.Button.Text = "Camera FOV: " .. (fovRow.enabled and "ON" or "OFF")
    fovRow.Button.BackgroundColor3 = fovRow.enabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(60, 60, 60)
    if fovRow.enabled then
        if cam then savedOriginalFOV = cam.FieldOfView end
        applyFOV()
    elseif cam then
        cam.FieldOfView = savedOriginalFOV or DEFAULT_FOV
    end
end)

-- =========================================================
-- FLY GUI (полный оригинал)
-- =========================================================
local FlyButton = Instance.new("TextButton")
FlyButton.Name = "FlyButton"
FlyButton.Position = UDim2.new(0, MV_SIDE_PADDING, 0, 7 + 5 * MV_ROW_STEP + 6)
FlyButton.Size = UDim2.new(1, -14, 0, 24)
FlyButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
FlyButton.BorderSizePixel = 0
FlyButton.Text = "Fly: OFF"
FlyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
FlyButton.Font = Enum.Font.SourceSansBold
FlyButton.TextSize = 12
FlyButton.Parent = page
local FlyCorner = Instance.new("UICorner"); FlyCorner.CornerRadius = UDim.new(0, 4); FlyCorner.Parent = FlyButton
local FlyPad = Instance.new("UIPadding"); FlyPad.PaddingLeft = UDim.new(0, 8); FlyPad.Parent = FlyButton

local flyGui = nil
local flyActive = false
local flyToggleCallback = nil
local flyHotkey = Enum.KeyCode.V
local flyHotkeyCapturing = false
local flyHotkeyCaptureConn = nil

local function destroyFlyGui()
    if flyGui then flyGui:Destroy(); flyGui = nil end
    flyActive = false
    flyToggleCallback = nil
end

local function getGuiParent()
    local ok, parent = pcall(function() return game:GetService("CoreGui") end)
    if ok and parent then return parent end
    return Player:WaitForChild("PlayerGui")
end

local function createFlyGui()
    if flyGui then return end
    local main = Instance.new("ScreenGui")
    main.Name = "Fly_gay_v42_11979107741"
    main.ResetOnSpawn = false
    main.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    main.Parent = getGuiParent()
    flyGui = main

    local Frame = Instance.new("Frame")
    Frame.Parent = main
    Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Frame.BorderSizePixel = 0
    Frame.Position = UDim2.new(0.1, 0, 0.38, 0)
    Frame.Size = UDim2.new(0, 190, 0, 180)
    Frame.Active = true

    local FrameStroke = Instance.new("UIStroke")
    FrameStroke.Color = Color3.fromRGB(255, 0, 0)
    FrameStroke.Thickness = 1.2
    FrameStroke.Parent = Frame

    local FrameCorner = Instance.new("UICorner")
    FrameCorner.CornerRadius = UDim.new(0, 4)
    FrameCorner.Parent = Frame

    local TitleBarFly = Instance.new("Frame")
    TitleBarFly.Size = UDim2.new(1, 0, 0, 21)
    TitleBarFly.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    TitleBarFly.BorderSizePixel = 0
    TitleBarFly.Parent = Frame

    local TitleBarFlyCorner = Instance.new("UICorner")
    TitleBarFlyCorner.CornerRadius = UDim.new(0, 4)
    TitleBarFlyCorner.Parent = TitleBarFly

    local TitleFly = Instance.new("TextLabel")
    TitleFly.Size = UDim2.new(1, -26, 1, 0)
    TitleFly.BackgroundTransparency = 1
    TitleFly.Text = "Fly gay v42"
    TitleFly.TextColor3 = Color3.fromRGB(255, 0, 0)
    TitleFly.Font = Enum.Font.SourceSansBold
    TitleFly.TextSize = 12
    TitleFly.TextXAlignment = Enum.TextXAlignment.Left
    TitleFly.Position = UDim2.new(0, 7, 0, 0)
    TitleFly.Parent = TitleBarFly

    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.fromOffset(21, 21)
    CloseButton.Position = UDim2.new(1, -21, 0, 0)
    CloseButton.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
    CloseButton.BorderSizePixel = 0
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.Font = Enum.Font.SourceSansBold
    CloseButton.TextSize = 12
    CloseButton.Parent = TitleBarFly

    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 4)
    CloseCorner.Parent = CloseButton

    local OnOffButton = Instance.new("TextButton")
    OnOffButton.Size = UDim2.new(1, -14, 0, 26)
    OnOffButton.Position = UDim2.new(0, 7, 0, 28)
    OnOffButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    OnOffButton.BorderSizePixel = 0
    OnOffButton.Text = "fly: OFF"
    OnOffButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    OnOffButton.Font = Enum.Font.SourceSansBold
    OnOffButton.TextSize = 12
    OnOffButton.Parent = Frame

    local OnOffCorner = Instance.new("UICorner")
    OnOffCorner.CornerRadius = UDim.new(0, 4)
    OnOffCorner.Parent = OnOffButton

    local UpButton = Instance.new("TextButton")
    UpButton.Size = UDim2.new(0.5, -10, 0, 24)
    UpButton.Position = UDim2.new(0, 7, 0, 60)
    UpButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    UpButton.BorderSizePixel = 0
    UpButton.Text = "UP"
    UpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    UpButton.Font = Enum.Font.SourceSansBold
    UpButton.TextSize = 12
    UpButton.Parent = Frame

    local UpCorner = Instance.new("UICorner")
    UpCorner.CornerRadius = UDim.new(0, 4)
    UpCorner.Parent = UpButton

    local DownButton = Instance.new("TextButton")
    DownButton.Size = UDim2.new(0.5, -10, 0, 24)
    DownButton.Position = UDim2.new(0.5, 3, 0, 60)
    DownButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    DownButton.BorderSizePixel = 0
    DownButton.Text = "DOWN"
    DownButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    DownButton.Font = Enum.Font.SourceSansBold
    DownButton.TextSize = 12
    DownButton.Parent = Frame

    local DownCorner = Instance.new("UICorner")
    DownCorner.CornerRadius = UDim.new(0, 4)
    DownCorner.Parent = DownButton

    local HotkeyButton = Instance.new("TextButton")
    HotkeyButton.Size = UDim2.new(1, -14, 0, 24)
    HotkeyButton.Position = UDim2.new(0, 7, 0, 90)
    HotkeyButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    HotkeyButton.BorderSizePixel = 0
    HotkeyButton.Text = "Горячая клавиша: V"
    HotkeyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    HotkeyButton.Font = Enum.Font.SourceSansBold
    HotkeyButton.TextSize = 12
    HotkeyButton.Parent = Frame

    local HotkeyCorner = Instance.new("UICorner")
    HotkeyCorner.CornerRadius = UDim.new(0, 4)
    HotkeyCorner.Parent = HotkeyButton

    local SpeedLabel = Instance.new("TextLabel")
    SpeedLabel.Size = UDim2.new(1, -14, 0, 18)
    SpeedLabel.Position = UDim2.new(0, 7, 0, 120)
    SpeedLabel.BackgroundTransparency = 1
    SpeedLabel.Text = "Speed: 50"
    SpeedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    SpeedLabel.Font = Enum.Font.SourceSans
    SpeedLabel.TextSize = 11
    SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
    SpeedLabel.Parent = Frame

    local SpeedSliderBack = Instance.new("Frame")
    SpeedSliderBack.Size = UDim2.new(1, -14, 0, 8)
    SpeedSliderBack.Position = UDim2.new(0, 7, 0, 142)
    SpeedSliderBack.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    SpeedSliderBack.BorderSizePixel = 0
    SpeedSliderBack.Parent = Frame

    local SliderCorner2 = Instance.new("UICorner")
    SliderCorner2.CornerRadius = UDim.new(1, 0)
    SliderCorner2.Parent = SpeedSliderBack

    local SpeedFill = Instance.new("Frame")
    SpeedFill.Size = UDim2.new(0.25, 0, 1, 0)
    SpeedFill.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    SpeedFill.BorderSizePixel = 0
    SpeedFill.Parent = SpeedSliderBack

    local FillCorner2 = Instance.new("UICorner")
    FillCorner2.CornerRadius = UDim.new(1, 0)
    FillCorner2.Parent = SpeedFill

    local SpeedKnob = Instance.new("Frame")
    SpeedKnob.Size = UDim2.fromOffset(14, 14)
    SpeedKnob.Position = UDim2.new(0.25, -7, 0.5, -7)
    SpeedKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SpeedKnob.BorderSizePixel = 0
    SpeedKnob.ZIndex = 2
    SpeedKnob.Parent = SpeedSliderBack

    local KnobCorner2 = Instance.new("UICorner")
    KnobCorner2.CornerRadius = UDim.new(1, 0)
    KnobCorner2.Parent = SpeedKnob

    local HintLabel = Instance.new("TextLabel")
    HintLabel.Size = UDim2.new(1, -14, 0, 16)
    HintLabel.Position = UDim2.new(0, 7, 0, 158)
    HintLabel.BackgroundTransparency = 1
    HintLabel.Text = "WASD • Space ↑ • Ctrl ↓"
    HintLabel.TextColor3 = Color3.fromRGB(120, 120, 120)
    HintLabel.Font = Enum.Font.SourceSans
    HintLabel.TextSize = 10
    HintLabel.TextXAlignment = Enum.TextXAlignment.Left
    HintLabel.Parent = Frame

    local dragging = false
    local dragStart2, startPos2
    TitleBarFly.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart2 = input.Position
            startPos2 = Frame.Position
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart2
            Frame.Position = UDim2.new(startPos2.X.Scale, startPos2.X.Offset + delta.X, startPos2.Y.Scale, startPos2.Y.Offset + delta.Y)
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)

    local function updateHotkeyText() HotkeyButton.Text = "Горячая клавиша: " .. tostring(flyHotkey.Name) end
    updateHotkeyText()

    HotkeyButton.MouseButton1Click:Connect(function()
        if flyHotkeyCapturing then return end
        flyHotkeyCapturing = true
        HotkeyButton.Text = "Нажми клавишу..."
        HotkeyButton.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
        if flyHotkeyCaptureConn then flyHotkeyCaptureConn:Disconnect() end
        flyHotkeyCaptureConn = UIS.InputBegan:Connect(function(input, gp)
            if not flyHotkeyCapturing then return end
            if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
            flyHotkey = input.KeyCode
            flyHotkeyCapturing = false
            HotkeyButton.Text = "Горячая клавиша: " .. tostring(flyHotkey.Name)
            HotkeyButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
            task.wait(0.3)
            HotkeyButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            if flyHotkeyCaptureConn then flyHotkeyCaptureConn:Disconnect(); flyHotkeyCaptureConn = nil end
        end)
    end)

    local flySpeed = 50
    local maxFlySpeed = 5555
    local minFlySpeed = 10
    local upPressed, downPressed, spacePressed, ctrlPressed = false, false, false, false
    local bodyGyro, bodyVel, flyAnimSaved = nil, nil, nil

    local function setSpeedLabel() SpeedLabel.Text = "Speed: " .. tostring(math.floor(flySpeed)) end
    setSpeedLabel()

    local function updateSlider()
        local alpha = (flySpeed - minFlySpeed) / (maxFlySpeed - minFlySpeed)
        alpha = math.clamp(alpha, 0, 1)
        SpeedFill.Size = UDim2.new(alpha, 0, 1, 0)
        SpeedKnob.Position = UDim2.new(alpha, -7, 0.5, -7)
    end
    updateSlider()

    local draggingSpeed = false
    local function setSpeedFromX(mouseX)
        local absPos = SpeedSliderBack.AbsolutePosition
        local absSize = SpeedSliderBack.AbsoluteSize
        if absSize.X <= 0 then return end
        local alpha = math.clamp((mouseX - absPos.X) / absSize.X, 0, 1)
        flySpeed = minFlySpeed + alpha * (maxFlySpeed - minFlySpeed)
        updateSlider()
        setSpeedLabel()
    end
    SpeedSliderBack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then draggingSpeed = true; setSpeedFromX(input.Position.X) end
    end)
    UIS.InputChanged:Connect(function(input)
        if draggingSpeed and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then setSpeedFromX(input.Position.X) end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then draggingSpeed = false end
    end)

    local function getCharParts()
        local char = Player.Character
        if not char then return nil end
        local hum = char:FindFirstChildOfClass("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hum or not hrp then return nil end
        return char, hum, hrp
    end

    local function removePhysics()
        if bodyGyro then bodyGyro:Destroy(); bodyGyro = nil end
        if bodyVel then bodyVel:Destroy(); bodyVel = nil end
    end

    local function stopFly()
        flyActive = false
        upPressed, downPressed, spacePressed, ctrlPressed = false, false, false, false
        removePhysics()
        local char, hum = getCharParts()
        if hum then
            pcall(function() hum.PlatformStand = false end)
            pcall(function() hum.AutoRotate = true end)
        end
        if char and char:FindFirstChild("Animate") then char.Animate.Disabled = flyAnimSaved or false end
        OnOffButton.Text = "fly: OFF"
        OnOffButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    end

    local function startFly()
        if flyActive then return end
        local char, hum, hrp = getCharParts()
        if not char or not hum or not hrp then
            OnOffButton.Text = "нет персонажа"
            task.wait(1)
            OnOffButton.Text = "fly: OFF"
            return
        end
        flyActive = true
        OnOffButton.Text = "fly: ON"
        OnOffButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        removePhysics()
        bodyGyro = Instance.new("BodyGyro")
        bodyGyro.P = 3e4
        bodyGyro.D = 500
        bodyGyro.MaxTorque = Vector3.new(4e4, 4e4, 4e4)
        bodyGyro.CFrame = CFrame.lookAt(hrp.Position, hrp.Position + hrp.CFrame.LookVector)
        bodyGyro.Parent = hrp
        bodyVel = Instance.new("BodyVelocity")
        bodyVel.Velocity = Vector3.zero
        bodyVel.MaxForce = Vector3.new(4e4, 4e4, 4e4)
        bodyVel.Parent = hrp
        pcall(function() hum.PlatformStand = true end)
        pcall(function() hum.AutoRotate = false end)
        if char:FindFirstChild("Animate") then
            flyAnimSaved = char.Animate.Disabled
            char.Animate.Disabled = true
        end
        task.spawn(function()
            while flyActive do
                RunService.RenderStepped:Wait()
                local c, h, r = getCharParts()
                if not c or not h or not r or h.Health <= 0 then stopFly(); break end
                if bodyVel and bodyVel.Parent ~= r then bodyVel.Parent = r end
                if bodyGyro and bodyGyro.Parent ~= r then bodyGyro.Parent = r end
                local cam = Workspace.CurrentCamera
                local look = cam.CFrame.LookVector
                local right = cam.CFrame.RightVector
                local forwardFlat = Vector3.new(look.X, 0, look.Z)
                if forwardFlat.Magnitude > 0.001 then forwardFlat = forwardFlat.Unit else forwardFlat = Vector3.new(0, 0, -1) end
                local rightFlat = Vector3.new(right.X, 0, right.Z)
                if rightFlat.Magnitude > 0.001 then rightFlat = rightFlat.Unit else rightFlat = Vector3.new(1, 0, 0) end
                local move = h.MoveDirection
                local fwdAmount = move:Dot(forwardFlat)
                local rightAmount = move:Dot(rightFlat)
                local horizontal = forwardFlat * fwdAmount + rightFlat * rightAmount
                if horizontal.Magnitude > 1 then horizontal = horizontal.Unit end
                horizontal = horizontal * flySpeed
                local vertical = 0
                if upPressed or spacePressed then vertical = flySpeed end
                if downPressed or ctrlPressed then vertical = -flySpeed end
                if bodyVel then bodyVel.Velocity = horizontal + Vector3.new(0, vertical, 0) end
                if bodyGyro then bodyGyro.CFrame = CFrame.lookAt(r.Position, r.Position + forwardFlat) end
            end
        end)
    end

    flyToggleCallback = function()
        if flyActive then stopFly() else startFly() end
    end

    OnOffButton.MouseButton1Click:Connect(flyToggleCallback)
    UpButton.MouseButton1Down:Connect(function() upPressed = true end)
    UpButton.MouseButton1Up:Connect(function() upPressed = false end)
    UpButton.MouseLeave:Connect(function() upPressed = false end)
    DownButton.MouseButton1Down:Connect(function() downPressed = true end)
    DownButton.MouseButton1Up:Connect(function() downPressed = false end)
    DownButton.MouseLeave:Connect(function() downPressed = false end)

    UIS.InputBegan:Connect(function(input, gp)
        if gp then return end
        if not flyActive then return end
        if input.KeyCode == Enum.KeyCode.Space then spacePressed = true end
        if input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.RightControl then ctrlPressed = true end
    end)
    UIS.InputEnded:Connect(function(input, gp)
        if input.KeyCode == Enum.KeyCode.Space then spacePressed = false end
        if input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.RightControl then ctrlPressed = false end
    end)

    Player.CharacterAdded:Connect(function()
        if flyActive then task.wait(0.5); stopFly() end
    end)

    CloseButton.MouseButton1Click:Connect(function()
        stopFly()
        destroyFlyGui()
        FlyButton.Text = "Fly: OFF"
        FlyButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    end)
end

FlyButton.MouseButton1Click:Connect(function()
    if not FCS.Unlocked then return end
    if flyGui then
        destroyFlyGui()
        FlyButton.Text = "Fly: OFF"
        FlyButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    else
        createFlyGui()
        FlyButton.Text = "Fly: ON"
        FlyButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    end
end)

UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if not FCS.Unlocked then return end
    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
    if flyHotkeyCapturing then return end
    if input.KeyCode ~= flyHotkey then return end
    if not flyGui then
        createFlyGui()
        FlyButton.Text = "Fly: ON"
        FlyButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    end
    if flyToggleCallback then flyToggleCallback() end
end)

-- =========================================================
-- ПЕРЕТАСКИВАНИЕ СЛАЙДЕРОВ MOVEMENT
-- =========================================================
local mvDraggingSlider = false
local mvActiveRow = nil

local function mvSetupSliderDrag(row)
    row.SliderBack.InputBegan:Connect(function(input)
        if not FCS.Unlocked then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            mvDraggingSlider = true
            mvActiveRow = row
            mvSetRowFromX(row, input.Position.X)
        end
    end)
end

mvSetupSliderDrag(walkRow)
mvSetupSliderDrag(cframeRow)
mvSetupSliderDrag(jumpRow)
mvSetupSliderDrag(hipRow)
mvSetupSliderDrag(fovRow)

UIS.InputChanged:Connect(function(input)
    if mvDraggingSlider and mvActiveRow and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        mvSetRowFromX(mvActiveRow, input.Position.X)
        if mvActiveRow == walkRow then applyWalkSpeed()
        elseif mvActiveRow == hipRow then applyHipHeight()
        elseif mvActiveRow == fovRow then applyFOV() end
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        mvDraggingSlider = false
        mvActiveRow = nil
    end
end)

mvUpdateRowVisual(walkRow)
mvUpdateRowVisual(cframeRow)
mvUpdateRowVisual(jumpRow)
mvUpdateRowVisual(hipRow)
mvUpdateRowVisual(fovRow)
