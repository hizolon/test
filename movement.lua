-- movement.lua
local page = getgenv().FCS.pages["Movement"]
if not page then return end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
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

    return { Button = Btn, Value = Val, SliderBack = Slider, SliderFill = Fill, SliderKnob = Knob, maxSpeed = maxSpeed, enabled = defaultEnabled or false, value = 0 }
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
    else
        if hum then hum.WalkSpeed = savedOriginalWalkSpeed or DEFAULT_WALKSPEED end
    end
end)

local cframeRow = mvCreateSpeedRow(2, "CFrame Speed", 500, false)
cframeRow.value = 0

RunService.RenderStepped:Connect(function(dt)
    if not cframeRow.enabled or cframeRow.value <= 0 then return end
    local char = Player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then return end
    local moveDir = hum.MoveDirection
    if moveDir.Magnitude < 0.01 then return end
    local dir = moveDir.Unit
    local distance = cframeRow.value * dt
    local origin = hrp.Position
    local rayDir = dir * distance
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { char }
    params.IgnoreWater = true
    local result = workspace:Raycast(origin, rayDir, params)
    local targetPos = result and (origin + (rayDir.Unit * math.max(0, result.Distance - 0.1))) or (origin + rayDir)
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
        if not isJumping or not jumpRow.enabled or jumpRow.value <= 0 then return end
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
    else
        if hum then hum.HipHeight = savedOriginalHipHeight or DEFAULT_HIPHEIGHT end
    end
end)

local DEFAULT_FOV = 80
local fovRow = mvCreateSpeedRow(5, "Camera FOV", 120, false)
fovRow.value = DEFAULT_FOV
local savedOriginalFOV = nil

local function applyFOV()
    if not fovRow.enabled then return end
    local cam = workspace.CurrentCamera
    if cam then cam.FieldOfView = fovRow.value end
end

task.spawn(function()
    while true do
        task.wait(0.1)
        if fovRow.enabled then
            local cam = workspace.CurrentCamera
            if cam and math.abs(cam.FieldOfView - fovRow.value) > 0.01 then cam.FieldOfView = fovRow.value end
        end
    end
end)

fovRow.Button.MouseButton1Click:Connect(function()
    if not FCS.Unlocked then return end
    local cam = workspace.CurrentCamera
    fovRow.enabled = not fovRow.enabled
    fovRow.Button.Text = "Camera FOV: " .. (fovRow.enabled and "ON" or "OFF")
    fovRow.Button.BackgroundColor3 = fovRow.enabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(60, 60, 60)
    if fovRow.enabled then
        if cam then savedOriginalFOV = cam.FieldOfView end
        applyFOV()
    else
        if cam then cam.FieldOfView = savedOriginalFOV or DEFAULT_FOV end
    end
end)

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
