-- pvp.lua
local page = getgenv().FCS.pages["PVP"]
if not page then return end

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Player = Players.LocalPlayer
local FCS = getgenv().FCS

-- Создаем скролл внутри страницы PVP
local Scroll = Instance.new("ScrollingFrame")
Scroll.Name = "Scroll"
Scroll.Position = UDim2.new(0, 0, 0, 0)
Scroll.Size = UDim2.new(1, 0, 1, 0)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 4
Scroll.ScrollBarImageColor3 = Color3.fromRGB(255, 0, 0)
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.Parent = page

-- ===== Константы =====
local SIDE_PADDING = 7
local GAP = 6
local VALUE_WIDTH = 55
local ROW_H = 24
local SLIDER_1_OFF = 32
local SLIDER_2_OFF = 48
local MIN_RADIUS, MAX_RADIUS = 10, 300
local MIN_TRANSP, MAX_TRANSP = 0, 100

local function makeSlider(parent, yPos)
    local back = Instance.new("Frame")
    back.Position = UDim2.new(0, SIDE_PADDING, 0, yPos)
    back.Size = UDim2.new(1, -(SIDE_PADDING * 2), 0, 8)
    back.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    back.BorderSizePixel = 0
    back.Parent = parent
    local bc = Instance.new("UICorner"); bc.CornerRadius = UDim.new(1, 0); bc.Parent = back
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    fill.BorderSizePixel = 0
    fill.Parent = back
    local fc = Instance.new("UICorner"); fc.CornerRadius = UDim.new(1, 0); fc.Parent = fill
    local knob = Instance.new("Frame")
    knob.Size = UDim2.fromOffset(14, 14)
    knob.Position = UDim2.new(0, -7, 0.5, -7)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.ZIndex = 2
    knob.Parent = back
    local kc = Instance.new("UICorner"); kc.CornerRadius = UDim.new(1, 0); kc.Parent = knob
    return { Back = back, Fill = fill, Knob = knob }
end

-- =========================================================
-- 1) TP PLAYER KILL
-- =========================================================
local tpEnabled = false
local holdingM1 = false
local attackedThisHold = false
local cubeRadius = 10
local cubeTransparencyPct = 50
local CubePart = nil

local function ensureCube()
    if CubePart and CubePart.Parent then return end
    CubePart = Instance.new("Part")
    CubePart.Name = "TpKillCube"
    CubePart.Shape = Enum.PartType.Block
    CubePart.Size = Vector3.new(cubeRadius, cubeRadius, cubeRadius)
    CubePart.Anchored = true
    CubePart.CanCollide = false
    CubePart.CanQuery = false
    CubePart.CanTouch = false
    CubePart.Material = Enum.Material.ForceField
    CubePart.Color = Color3.fromRGB(255, 0, 0)
    CubePart.Transparency = 1 - (cubeTransparencyPct / 100)
    CubePart.Parent = Workspace
end
local function destroyCube()
    if CubePart then CubePart:Destroy(); CubePart = nil end
end
local function updateCubePosition()
    if not tpEnabled then return end
    ensureCube()
    local char = Player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp and CubePart then CubePart.CFrame = hrp.CFrame end
end

local TpButton = Instance.new("TextButton")
TpButton.Position = UDim2.new(0, SIDE_PADDING, 0, 6)
TpButton.Size = UDim2.new(1, -(SIDE_PADDING * 2 + GAP + VALUE_WIDTH), 0, ROW_H)
TpButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
TpButton.BorderSizePixel = 0
TpButton.Text = "Tp player kill: OFF"
TpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
TpButton.Font = Enum.Font.SourceSansBold
TpButton.TextSize = 11
TpButton.TextXAlignment = Enum.TextXAlignment.Left
TpButton.Parent = Scroll
local TpPadding = Instance.new("UIPadding"); TpPadding.PaddingLeft = UDim.new(0, 8); TpPadding.Parent = TpButton
local TpCorner = Instance.new("UICorner"); TpCorner.CornerRadius = UDim.new(0, 4); TpCorner.Parent = TpButton

local ValueFrame = Instance.new("Frame")
ValueFrame.AnchorPoint = Vector2.new(1, 0)
ValueFrame.Position = UDim2.new(1, -SIDE_PADDING, 0, 6)
ValueFrame.Size = UDim2.new(0, VALUE_WIDTH, 0, ROW_H)
ValueFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
ValueFrame.BorderSizePixel = 0
ValueFrame.Parent = Scroll
local ValueFrameCorner = Instance.new("UICorner"); ValueFrameCorner.CornerRadius = UDim.new(0, 4); ValueFrameCorner.Parent = ValueFrame

local ValueLeft = Instance.new("TextLabel")
ValueLeft.Size = UDim2.new(0.5, 0, 1, 0)
ValueLeft.BackgroundTransparency = 1
ValueLeft.Text = "R:10"
ValueLeft.TextColor3 = Color3.fromRGB(255, 255, 255)
ValueLeft.Font = Enum.Font.SourceSansBold
ValueLeft.TextSize = 10
ValueLeft.TextXAlignment = Enum.TextXAlignment.Center
ValueLeft.Parent = ValueFrame

local ValueRight = Instance.new("TextLabel")
ValueRight.Position = UDim2.new(0.5, 0, 0, 0)
ValueRight.Size = UDim2.new(0.5, 0, 1, 0)
ValueRight.BackgroundTransparency = 1
ValueRight.Text = "T:50"
ValueRight.TextColor3 = Color3.fromRGB(255, 255, 255)
ValueRight.Font = Enum.Font.SourceSansBold
ValueRight.TextSize = 10
ValueRight.TextXAlignment = Enum.TextXAlignment.Center
ValueRight.Parent = ValueFrame

local Divider = Instance.new("Frame")
Divider.Position = UDim2.new(0.5, -0.5, 0.15, 0)
Divider.Size = UDim2.new(0, 1, 0.7, 0)
Divider.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
Divider.BorderSizePixel = 0
Divider.Parent = ValueFrame

local CubeRadiusSlider = makeSlider(Scroll, 6 + SLIDER_1_OFF)
local CubeTranspSlider = makeSlider(Scroll, 6 + SLIDER_2_OFF)

local function updateCubeVisuals()
    local a1 = math.clamp((cubeRadius - MIN_RADIUS) / (MAX_RADIUS - MIN_RADIUS), 0, 1)
    CubeRadiusSlider.Fill.Size = UDim2.new(a1, 0, 1, 0)
    CubeRadiusSlider.Knob.Position = UDim2.new(a1, -7, 0.5, -7)
    ValueLeft.Text = "R:" .. tostring(math.floor(cubeRadius + 0.5))
    local a2 = math.clamp((cubeTransparencyPct - MIN_TRANSP) / (MAX_TRANSP - MIN_TRANSP), 0, 1)
    CubeTranspSlider.Fill.Size = UDim2.new(a2, 0, 1, 0)
    CubeTranspSlider.Knob.Position = UDim2.new(a2, -7, 0.5, -7)
    ValueRight.Text = "T:" .. tostring(math.floor(cubeTransparencyPct + 0.5))
    if tpEnabled then ensureCube() end
    if CubePart then
        CubePart.Size = Vector3.new(cubeRadius, cubeRadius, cubeRadius)
        CubePart.Transparency = 1 - (cubeTransparencyPct / 100)
    end
end

local function setCubeFromX(slider, mouseX, which)
    local absPos = slider.Back.AbsolutePosition
    local absSize = slider.Back.AbsoluteSize
    if absSize.X <= 0 then return end
    local alpha = math.clamp((mouseX - absPos.X) / absSize.X, 0, 1)
    if which == 1 then
        cubeRadius = math.floor(MIN_RADIUS + alpha * (MAX_RADIUS - MIN_RADIUS) + 0.5)
    else
        cubeTransparencyPct = math.floor(MIN_TRANSP + alpha * (MAX_TRANSP - MIN_TRANSP) + 0.5)
    end
    updateCubeVisuals()
end

local function getNearestPlayerInCube()
    local char = Player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local myPos = hrp.Position
    local half = cubeRadius / 2
    local best, bestDist = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= Player and plr.Character then
            local otherHrp = plr.Character:FindFirstChild("HumanoidRootPart")
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if otherHrp and hum and hum.Health > 0 then
                local p = otherHrp.Position
                if math.abs(p.X - myPos.X) <= half and math.abs(p.Y - myPos.Y) <= half and math.abs(p.Z - myPos.Z) <= half then
                    local d = (p - myPos).Magnitude
                    if d < bestDist then bestDist = d; best = plr end
                end
            end
        end
    end
    return best
end

local function getBehindCFrame(targetHRP)
    local targetCF = targetHRP.CFrame
    local behind = targetCF.Position - targetCF.LookVector * 3
    return CFrame.lookAt(behind, targetCF.Position)
end

local function activateTool()
    local char = Player.Character
    if not char then return end
    local tool = char:FindFirstChildOfClass("Tool")
    if tool then pcall(function() tool:Activate() end) end
end

local function performTpKill()
    if not tpEnabled then return false end
    local target = getNearestPlayerInCube()
    if not target then return false end
    local myHrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    local targetHrp = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
    if not myHrp or not targetHrp then return false end
    myHrp.CFrame = getBehindCFrame(targetHrp)
    myHrp.AssemblyLinearVelocity = Vector3.zero
    myHrp.AssemblyAngularVelocity = Vector3.zero
    return true
end

UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if not tpEnabled then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        holdingM1 = true
        attackedThisHold = false
    end
end)
UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        holdingM1 = false
        attackedThisHold = false
    end
end)

TpButton.MouseButton1Click:Connect(function()
    if not FCS.Unlocked then return end
    tpEnabled = not tpEnabled
    TpButton.Text = "Tp player kill: " .. (tpEnabled and "ON" or "OFF")
    TpButton.BackgroundColor3 = tpEnabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(60, 60, 60)
    if tpEnabled then ensureCube(); updateCubeVisuals() else holdingM1 = false; destroyCube() end
end)

RunService.Heartbeat:Connect(function()
    if not tpEnabled then return end
    updateCubePosition()
    if holdingM1 then
        local ok = performTpKill()
        if ok and not attackedThisHold then activateTool(); attackedThisHold = true end
    end
end)

-- =========================================================
-- 2) AUTO MANS
-- =========================================================
local autoMansEnabled = false
local amRadius = 10
local amTransp = 50
local autoMansCube = nil
local amAtSafe = false
local amSavedCFrame = nil
local amSavedCamCFrame = nil
local amLastThreat = 0
local AM_SAFE_POS = Vector3.new(1000, 1000, 1000)
local AM_HOLD = 1.0
local AM_RADIUS_MIN, AM_RADIUS_MAX = 10, 50
local amCam = Workspace.CurrentCamera
local AM_Y = 68

local function ensureAutoMansCube()
    if autoMansCube and autoMansCube.Parent then return end
    autoMansCube = Instance.new("Part")
    autoMansCube.Name = "AutoMansCube"
    autoMansCube.Shape = Enum.PartType.Block
    autoMansCube.Size = Vector3.new(amRadius, amRadius, amRadius)
    autoMansCube.Anchored = true
    autoMansCube.CanCollide = false
    autoMansCube.CanQuery = false
    autoMansCube.CanTouch = false
    autoMansCube.Material = Enum.Material.ForceField
    autoMansCube.Color = Color3.fromRGB(0, 150, 255)
    autoMansCube.Transparency = 1 - (amTransp / 100)
    autoMansCube.Parent = Workspace
end
local function destroyAutoMansCube()
    if autoMansCube then autoMansCube:Destroy(); autoMansCube = nil end
end
local function updateAutoMansCubePosition()
    if not autoMansEnabled then return end
    ensureAutoMansCube()
    local char = Player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp and autoMansCube and not amAtSafe then autoMansCube.CFrame = hrp.CFrame end
end

local AutoMansBtn = Instance.new("TextButton")
AutoMansBtn.Position = UDim2.new(0, SIDE_PADDING, 0, AM_Y)
AutoMansBtn.Size = UDim2.new(1, -(SIDE_PADDING * 2 + GAP + VALUE_WIDTH), 0, ROW_H)
AutoMansBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
AutoMansBtn.BorderSizePixel = 0
AutoMansBtn.Text = "Auto mans: OFF"
AutoMansBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoMansBtn.Font = Enum.Font.SourceSansBold
AutoMansBtn.TextSize = 11
AutoMansBtn.TextXAlignment = Enum.TextXAlignment.Left
AutoMansBtn.Parent = Scroll
local amPad = Instance.new("UIPadding"); amPad.PaddingLeft = UDim.new(0, 8); amPad.Parent = AutoMansBtn
local amCorner = Instance.new("UICorner"); amCorner.CornerRadius = UDim.new(0, 4); amCorner.Parent = AutoMansBtn

local amValueFrame = Instance.new("Frame")
amValueFrame.AnchorPoint = Vector2.new(1, 0)
amValueFrame.Position = UDim2.new(1, -SIDE_PADDING, 0, AM_Y)
amValueFrame.Size = UDim2.new(0, VALUE_WIDTH, 0, ROW_H)
amValueFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
amValueFrame.BorderSizePixel = 0
amValueFrame.Parent = Scroll
local amVFc = Instance.new("UICorner"); amVFc.CornerRadius = UDim.new(0, 4); amVFc.Parent = amValueFrame

local amValueLeft = Instance.new("TextLabel")
amValueLeft.Size = UDim2.new(0.5, 0, 1, 0)
amValueLeft.BackgroundTransparency = 1
amValueLeft.Text = "R:10"
amValueLeft.TextColor3 = Color3.fromRGB(255, 255, 255)
amValueLeft.Font = Enum.Font.SourceSansBold
amValueLeft.TextSize = 10
amValueLeft.TextXAlignment = Enum.TextXAlignment.Center
amValueLeft.Parent = amValueFrame

local amValueRight = Instance.new("TextLabel")
amValueRight.Position = UDim2.new(0.5, 0, 0, 0)
amValueRight.Size = UDim2.new(0.5, 0, 1, 0)
amValueRight.BackgroundTransparency = 1
amValueRight.Text = "T:50"
amValueRight.TextColor3 = Color3.fromRGB(255, 255, 255)
amValueRight.Font = Enum.Font.SourceSansBold
amValueRight.TextSize = 10
amValueRight.TextXAlignment = Enum.TextXAlignment.Center
amValueRight.Parent = amValueFrame

local amDivider = Instance.new("Frame")
amDivider.Position = UDim2.new(0.5, -0.5, 0.15, 0)
amDivider.Size = UDim2.new(0, 1, 0.7, 0)
amDivider.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
amDivider.BorderSizePixel = 0
amDivider.Parent = amValueFrame

local AmRadiusSlider = makeSlider(Scroll, AM_Y + SLIDER_1_OFF)
local AmTranspSlider = makeSlider(Scroll, AM_Y + SLIDER_2_OFF)

local function updateAmVisuals()
    local a1 = math.clamp((amRadius - AM_RADIUS_MIN) / (AM_RADIUS_MAX - AM_RADIUS_MIN), 0, 1)
    AmRadiusSlider.Fill.Size = UDim2.new(a1, 0, 1, 0)
    AmRadiusSlider.Knob.Position = UDim2.new(a1, -7, 0.5, -7)
    amValueLeft.Text = "R:" .. tostring(math.floor(amRadius + 0.5))
    local a2 = math.clamp((amTransp - MIN_TRANSP) / (MAX_TRANSP - MIN_TRANSP), 0, 1)
    AmTranspSlider.Fill.Size = UDim2.new(a2, 0, 1, 0)
    AmTranspSlider.Knob.Position = UDim2.new(a2, -7, 0.5, -7)
    amValueRight.Text = "T:" .. tostring(math.floor(amTransp + 0.5))
    if autoMansEnabled then ensureAutoMansCube() end
    if autoMansCube then
        autoMansCube.Size = Vector3.new(amRadius, amRadius, amRadius)
        autoMansCube.Transparency = 1 - (amTransp / 100)
    end
end

local function setAmFromX(slider, mouseX, which)
    local absPos = slider.Back.AbsolutePosition
    local absSize = slider.Back.AbsoluteSize
    if absSize.X <= 0 then return end
    local alpha = math.clamp((mouseX - absPos.X) / absSize.X, 0, 1)
    if which == 1 then
        amRadius = math.floor(AM_RADIUS_MIN + alpha * (AM_RADIUS_MAX - AM_RADIUS_MIN) + 0.5)
    else
        amTransp = math.floor(MIN_TRANSP + alpha * (MAX_TRANSP - MIN_TRANSP) + 0.5)
    end
    updateAmVisuals()
end

local function enemyInsideAutoMansCube()
    local char = Player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    local myPos = hrp.Position
    local half = amRadius / 2
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= Player and plr.Character then
            local otherHrp = plr.Character:FindFirstChild("HumanoidRootPart")
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if otherHrp and hum and hum.Health > 0 then
                local p = otherHrp.Position
                if math.abs(p.X - myPos.X) <= half and math.abs(p.Y - myPos.Y) <= half and math.abs(p.Z - myPos.Z) <= half then
                    return true
                end
            end
        end
    end
    return false
end

local function markThreat()
    if not autoMansEnabled then return end
    if enemyInsideAutoMansCube() then amLastThreat = tick() end
end

local healthConn = nil
local function watchHealth()
    if healthConn then healthConn:Disconnect(); healthConn = nil end
    local hum = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local lastH = hum.Health
    healthConn = hum.HealthChanged:Connect(function(h)
        if h < lastH then markThreat() end
        lastH = h
    end)
end

local function watchState()
    local hum = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    hum.StateChanged:Connect(function(_, newState)
        if newState == Enum.HumanoidStateType.Physics or newState == Enum.HumanoidStateType.Ragdoll
            or newState == Enum.HumanoidStateType.PlatformStanding or newState == Enum.HumanoidStateType.Seated then
            markThreat()
        end
    end)
    hum:GetPropertyChangedSignal("PlatformStand"):Connect(function() if hum.PlatformStand then markThreat() end end)
    hum:GetPropertyChangedSignal("Sit"):Connect(function() if hum.Sit then markThreat() end end)
end

local function checkBadState()
    if not autoMansEnabled then return end
    local hum = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local st = hum:GetState()
    if st == Enum.HumanoidStateType.Physics or st == Enum.HumanoidStateType.Ragdoll or st == Enum.HumanoidStateType.PlatformStanding then
        amLastThreat = tick()
    end
    if hum.PlatformStand or hum.Sit then amLastThreat = tick() end
end

Player.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid", 5)
    if hum then task.wait(0.2); watchHealth(); watchState() end
end)
if Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") then
    watchHealth(); watchState()
end

AutoMansBtn.MouseButton1Click:Connect(function()
    if not FCS.Unlocked then return end
    autoMansEnabled = not autoMansEnabled
    AutoMansBtn.Text = "Auto mans: " .. (autoMansEnabled and "ON" or "OFF")
    AutoMansBtn.BackgroundColor3 = autoMansEnabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(60, 60, 60)
    if autoMansEnabled then
        ensureAutoMansCube(); updateAmVisuals()
        amSavedCFrame = nil; amSavedCamCFrame = nil; amAtSafe = false
    else
        destroyAutoMansCube()
        if amAtSafe and amSavedCFrame then
            local char = Player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = amSavedCFrame
                hrp.AssemblyLinearVelocity = Vector3.zero
                hrp.AssemblyAngularVelocity = Vector3.zero
            end
        end
        if amCam then amCam.CameraType = Enum.CameraType.Custom end
        amAtSafe = false; amSavedCFrame = nil; amSavedCamCFrame = nil
    end
end)

RunService.Heartbeat:Connect(function()
    if not autoMansEnabled then return end
    updateAutoMansCubePosition()
    checkBadState()
    local char = Player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local now = tick()
    local threat = (now - amLastThreat) <= AM_HOLD
    if threat then
        if not amAtSafe then
            amSavedCFrame = hrp.CFrame
            if amCam then
                amSavedCamCFrame = amCam.CFrame
                amCam.CameraType = Enum.CameraType.Scriptable
                amCam.CFrame = amSavedCamCFrame
            end
            amAtSafe = true
            hrp.CFrame = CFrame.new(AM_SAFE_POS)
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
        end
    else
        if amAtSafe and amSavedCFrame then
            hrp.CFrame = amSavedCFrame
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
            if amCam then
                amCam.CameraType = Enum.CameraType.Custom
                if amSavedCamCFrame then amCam.CFrame = amSavedCamCFrame end
            end
            amAtSafe = false; amSavedCFrame = nil; amSavedCamCFrame = nil
        end
    end
end)

-- =========================================================
-- 3) AIM
-- =========================================================
local aimEnabled = false
local aimCam = Workspace.CurrentCamera
local aimHotkey = Enum.KeyCode.R
local aimTarget = nil
local AIM_Y = 130

local function findClosestToScreenCenter()
    local char = Player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    if not aimCam then aimCam = Workspace.CurrentCamera end
    if not aimCam then return nil end
    local viewport = aimCam.ViewportSize
    local screenCenter = Vector2.new(viewport.X / 2, viewport.Y / 2)
    local best, bestDist = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= Player and plr.Character then
            local otherHrp = plr.Character:FindFirstChild("HumanoidRootPart")
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if otherHrp and hum and hum.Health > 0 then
                local head = plr.Character:FindFirstChild("Head") or otherHrp
                local screenPos, onScreen = aimCam:WorldToViewportPoint(head.Position)
                if onScreen and screenPos.Z > 0 then
                    local screenVec = Vector2.new(screenPos.X, screenPos.Y)
                    local distToCenter = (screenVec - screenCenter).Magnitude
                    if distToCenter < bestDist then bestDist = distToCenter; best = plr end
                end
            end
        end
    end
    return best
end

local function aimUpdate()
    if not aimEnabled then return end
    if not aimCam then aimCam = Workspace.CurrentCamera end
    if not aimCam then return end
    if not aimTarget then
        aimTarget = findClosestToScreenCenter()
        if not aimTarget then return end
    end
    if not aimTarget.Parent then aimTarget = nil; return end
    local targetChar = aimTarget.Character
    local targetHead = targetChar and (targetChar:FindFirstChild("Head") or targetChar:FindFirstChild("HumanoidRootPart"))
    if not targetHead then return end
    local goal = CFrame.lookAt(aimCam.CFrame.Position, targetHead.Position)
    aimCam.CFrame = aimCam.CFrame:Lerp(goal, 0.15)
end

local AimBtn = Instance.new("TextButton")
AimBtn.Position = UDim2.new(0, SIDE_PADDING, 0, AIM_Y)
AimBtn.Size = UDim2.new(1, -(SIDE_PADDING * 2 + GAP + VALUE_WIDTH), 0, ROW_H)
AimBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
AimBtn.BorderSizePixel = 0
AimBtn.Text = "Aim: OFF"
AimBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AimBtn.Font = Enum.Font.SourceSansBold
AimBtn.TextSize = 12
AimBtn.TextXAlignment = Enum.TextXAlignment.Left
AimBtn.Parent = Scroll
local aimPad = Instance.new("UIPadding"); aimPad.PaddingLeft = UDim.new(0, 8); aimPad.Parent = AimBtn
local aimCorner = Instance.new("UICorner"); aimCorner.CornerRadius = UDim.new(0, 4); aimCorner.Parent = AimBtn

local AimKeyBox = Instance.new("TextBox")
AimKeyBox.AnchorPoint = Vector2.new(1, 0)
AimKeyBox.Position = UDim2.new(1, -SIDE_PADDING, 0, AIM_Y)
AimKeyBox.Size = UDim2.new(0, VALUE_WIDTH, 0, ROW_H)
AimKeyBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
AimKeyBox.BorderSizePixel = 0
AimKeyBox.Text = "R"
AimKeyBox.PlaceholderText = "..."
AimKeyBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
AimKeyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
AimKeyBox.Font = Enum.Font.SourceSansBold
AimKeyBox.TextSize = 12
AimKeyBox.ClearTextOnFocus = false
AimKeyBox.Parent = Scroll
local aimKeyCorner = Instance.new("UICorner"); aimKeyCorner.CornerRadius = UDim.new(0, 4); aimKeyCorner.Parent = AimKeyBox

local function normalizeKey(s)
    s = string.upper(s)
    s = string.gsub(s, "[^A-Z0-9]", "")
    return s
end

local function keyFromString(s)
    s = normalizeKey(s)
    if s == "" then return nil end
    local digitNames = { ["1"]="One", ["2"]="Two", ["3"]="Three", ["4"]="Four", ["5"]="Five", ["6"]="Six", ["7"]="Seven", ["8"]="Eight", ["9"]="Nine", ["0"]="Zero" }
    local name = digitNames[s] or s
    local ok, key = pcall(function() return Enum.KeyCode[name] end)
    if ok and key then return key end
    return nil
end

local function refreshHotkey()
    local raw = AimKeyBox.Text
    local normalized = normalizeKey(raw)
    if normalized ~= raw then AimKeyBox.Text = normalized; return end
    if normalized == "" then aimHotkey = nil; return end
    local key = keyFromString(normalized)
    if key then aimHotkey = key else AimKeyBox.Text = ""; aimHotkey = nil end
end
AimKeyBox:GetPropertyChangedSignal("Text"):Connect(refreshHotkey)

local function setAimState(state)
    aimEnabled = state
    AimBtn.Text = "Aim: " .. (aimEnabled and "ON" or "OFF")
    AimBtn.BackgroundColor3 = aimEnabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(60, 60, 60)
    aimTarget = nil
end
AimBtn.MouseButton1Click:Connect(function() if FCS.Unlocked then setAimState(not aimEnabled) end end)
UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if aimHotkey and input.KeyCode == aimHotkey then setAimState(not aimEnabled) end
end)
AimKeyBox.FocusLost:Connect(function() AimKeyBox:ReleaseFocus() end)
RunService.RenderStepped:Connect(aimUpdate)

-- =========================================================
-- 4) FLASH-STEP
-- =========================================================
local flashEnabled = false
local flashHotkey = Enum.KeyCode.T
local FLASH_Y = 160
local Mouse = Player:GetMouse()
local MAX_TELEPORT_DIST = 500

local FlashBtn = Instance.new("TextButton")
FlashBtn.Position = UDim2.new(0, SIDE_PADDING, 0, FLASH_Y)
FlashBtn.Size = UDim2.new(1, -(SIDE_PADDING * 2 + GAP + VALUE_WIDTH), 0, ROW_H)
FlashBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
FlashBtn.BorderSizePixel = 0
FlashBtn.Text = "Flash-step: OFF"
FlashBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FlashBtn.Font = Enum.Font.SourceSansBold
FlashBtn.TextSize = 12
FlashBtn.TextXAlignment = Enum.TextXAlignment.Left
FlashBtn.Parent = Scroll
local flashPad = Instance.new("UIPadding"); flashPad.PaddingLeft = UDim.new(0, 8); flashPad.Parent = FlashBtn
local flashCorner = Instance.new("UICorner"); flashCorner.CornerRadius = UDim.new(0, 4); flashCorner.Parent = FlashBtn

local FlashKeyBox = Instance.new("TextBox")
FlashKeyBox.AnchorPoint = Vector2.new(1, 0)
FlashKeyBox.Position = UDim2.new(1, -SIDE_PADDING, 0, FLASH_Y)
FlashKeyBox.Size = UDim2.new(0, VALUE_WIDTH, 0, ROW_H)
FlashKeyBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
FlashKeyBox.BorderSizePixel = 0
FlashKeyBox.Text = "T"
FlashKeyBox.PlaceholderText = "..."
FlashKeyBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
FlashKeyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
FlashKeyBox.Font = Enum.Font.SourceSansBold
FlashKeyBox.TextSize = 12
FlashKeyBox.ClearTextOnFocus = false
FlashKeyBox.Parent = Scroll
local flashKeyCorner = Instance.new("UICorner"); flashKeyCorner.CornerRadius = UDim.new(0, 4); flashKeyCorner.Parent = FlashKeyBox

local function refreshFlashHotkey()
    local raw = FlashKeyBox.Text
    local normalized = normalizeKey(raw)
    if normalized ~= raw then FlashKeyBox.Text = normalized; return end
    if normalized == "" then flashHotkey = nil; return end
    local key = keyFromString(normalized)
    if key then flashHotkey = key else FlashKeyBox.Text = ""; flashHotkey = nil end
end
FlashKeyBox:GetPropertyChangedSignal("Text"):Connect(refreshFlashHotkey)
FlashKeyBox.FocusLost:Connect(function() FlashKeyBox:ReleaseFocus() end)

local function doFlashStep()
    if not flashEnabled then return end
    local char = Player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local cam = Workspace.CurrentCamera
    if not cam then return end

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { char }

    local unitRay = Mouse.UnitRay
    local result = Workspace:Raycast(unitRay.Origin, unitRay.Direction * 3000, params)

    local targetPos
    local lookDir

    if result then
        local dist = (result.Position - hrp.Position).Magnitude
        if dist > MAX_TELEPORT_DIST then
            targetPos = hrp.Position + (result.Position - hrp.Position).Unit * MAX_TELEPORT_DIST + Vector3.new(0, 3, 0)
        else
            targetPos = result.Position + result.Normal * 3
            if math.abs(result.Normal.Y) < 0.3 then
                targetPos = result.Position + Vector3.new(0, 3, 0)
            end
        end
    else
        targetPos = hrp.Position + cam.CFrame.LookVector * 15
    end

    lookDir = targetPos - hrp.Position
    lookDir = Vector3.new(lookDir.X, 0, lookDir.Z)
    if lookDir.Magnitude < 0.1 then lookDir = cam.CFrame.LookVector end
    lookDir = lookDir.Unit

    local oldVel = hrp.AssemblyLinearVelocity
    hrp.CFrame = CFrame.new(targetPos) * CFrame.Angles(0, math.atan2(-lookDir.X, -lookDir.Z), 0)
    hrp.AssemblyLinearVelocity = oldVel
    hrp.AssemblyAngularVelocity = Vector3.zero

    FlashBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    task.delay(0.1, function()
        if flashEnabled then FlashBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        else FlashBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60) end
    end)
end

FlashBtn.MouseButton1Click:Connect(function()
    if not FCS.Unlocked then return end
    flashEnabled = not flashEnabled
    FlashBtn.Text = "Flash-step: " .. (flashEnabled and "ON" or "OFF")
    FlashBtn.BackgroundColor3 = flashEnabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(60, 60, 60)
end)

UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if flashHotkey and input.KeyCode == flashHotkey then
        doFlashStep()
    end
end)

-- =========================================================
-- 5) ANTI RAGDOLL
-- =========================================================
local antiRagdollEnabled = false
local defaultGravity = workspace.Gravity
local AR_Y = 190

local function isRagdollState(hum)
    local st = hum:GetState()
    return st == Enum.HumanoidStateType.Physics or st == Enum.HumanoidStateType.FallingDown or st == Enum.HumanoidStateType.Ragdoll
end

local function applyAntiRagdoll()
    local char = Player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then
        if workspace.Gravity ~= defaultGravity then workspace.Gravity = defaultGravity end
        return
    end
    if not antiRagdollEnabled then
        if workspace.Gravity ~= defaultGravity then workspace.Gravity = defaultGravity end
        return
    end
    if isRagdollState(hum) then
        workspace.Gravity = 0
        if hum.PlatformStand then hum.PlatformStand = false end
        pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end)
    else
        if workspace.Gravity ~= defaultGravity then workspace.Gravity = defaultGravity end
    end
end

-- =========================================================
-- 6) NOCLIP
-- =========================================================
local noclipEnabled = false
local NoclipConnection = nil
local floatName = "HumanoidRootPart"
local NC_Y = 220

local function setAllCollide(state)
    local char = Player.Character
    if not char then return end
    for _, v in ipairs(char:GetDescendants()) do
        if v:IsA("BasePart") then
            v.CanCollide = state; v.CanTouch = state; v.CanQuery = state
        end
    end
end

local function noclipEnable()
    if noclipEnabled then return end
    noclipEnabled = true
    NoclipConnection = RunService.Heartbeat:Connect(function()
        if not noclipEnabled then return end
        local char = Player.Character
        if not char then return end
        for _, v in ipairs(char:GetDescendants()) do
            if v:IsA("BasePart") then
                if v.CanCollide then v.CanCollide = false end
                if v.CanTouch then v.CanTouch = false end
                if v.CanQuery then v.CanQuery = false end
            end
        end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:SetStateEnabled(Enum.HumanoidStateType.Landed, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, false)
        end
        local hrp = char:FindFirstChild(floatName)
        if hrp and hrp.Position.Y < -100 then
            local params = RaycastParams.new()
            params.FilterType = Enum.RaycastFilterType.Exclude
            params.FilterDescendantsInstances = { char }
            local result = Workspace:Raycast(Vector3.new(hrp.Position.X, 500, hrp.Position.Z), Vector3.new(0, -1000, 0), params)
            if result then
                hrp.CFrame = CFrame.new(hrp.Position.X, result.Position.Y + 3, hrp.Position.Z)
                hrp.AssemblyLinearVelocity = Vector3.zero
            end
        end
    end)
end

local function noclipDisable()
    noclipEnabled = false
    if NoclipConnection then NoclipConnection:Disconnect(); NoclipConnection = nil end
    setAllCollide(true)
    local char = Player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum:SetStateEnabled(Enum.HumanoidStateType.Landed, true)
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
        hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
        hum:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, true)
    end
end

local function makeToggle(text, y)
    local b = Instance.new("TextButton")
    b.Position = UDim2.new(0, SIDE_PADDING, 0, y)
    b.Size = UDim2.new(1, -(SIDE_PADDING * 2), 0, ROW_H)
    b.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    b.BorderSizePixel = 0
    b.Text = text .. ": OFF"
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Font = Enum.Font.SourceSansBold
    b.TextSize = 12
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.Parent = Scroll
    local pad = Instance.new("UIPadding"); pad.PaddingLeft = UDim.new(0, 8); pad.Parent = b
    local bc = Instance.new("UICorner"); bc.CornerRadius = UDim.new(0, 4); bc.Parent = b
    return b
end

-- =========================================================
-- 7) INVISIBILITY (перемещена выше, с горячей клавишей Z)
-- =========================================================
local INVIS_Y = 190
local invisActive = false
local invisModel = Instance.new("Model", Workspace)
local invisHumanoid = Instance.new("Humanoid", invisModel)
local invisPart = Instance.new("Part", invisModel)
invisPart.Name = "HumanoidRootPart"
invisPart.CanCollide = false
invisPart.Transparency = 1
invisPart.Anchored = true
invisPart.Size = Vector3.new(2, 2, 1)

local invisConnections = {}
local invisAnimation = nil
local lastInvisHumanoid = nil
local savedRootCFrame = nil
local invisProcessing = false
local isReviving = false
local invisHotkey = Enum.KeyCode.Z

local InvisButton = makeToggle("Invisibility", INVIS_Y)
InvisButton.Size = UDim2.new(1, -(SIDE_PADDING * 2 + GAP + VALUE_WIDTH), 0, ROW_H)

local InvisKeyBox = Instance.new("TextBox")
InvisKeyBox.AnchorPoint = Vector2.new(1, 0)
InvisKeyBox.Position = UDim2.new(1, -SIDE_PADDING, 0, INVIS_Y)
InvisKeyBox.Size = UDim2.new(0, VALUE_WIDTH, 0, ROW_H)
InvisKeyBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
InvisKeyBox.BorderSizePixel = 0
InvisKeyBox.Text = "Z"
InvisKeyBox.PlaceholderText = "..."
InvisKeyBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
InvisKeyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
InvisKeyBox.Font = Enum.Font.SourceSansBold
InvisKeyBox.TextSize = 12
InvisKeyBox.ClearTextOnFocus = false
InvisKeyBox.Parent = Scroll
local invisKeyCorner = Instance.new("UICorner"); invisKeyCorner.CornerRadius = UDim.new(0, 4); invisKeyCorner.Parent = InvisKeyBox

local function refreshInvisHotkey()
    local raw = InvisKeyBox.Text
    local normalized = normalizeKey(raw)
    if normalized ~= raw then InvisKeyBox.Text = normalized; return end
    if normalized == "" then invisHotkey = nil; return end
    local key = keyFromString(normalized)
    if key then invisHotkey = key else InvisKeyBox.Text = ""; invisHotkey = nil end
end
InvisKeyBox:GetPropertyChangedSignal("Text"):Connect(refreshInvisHotkey)
InvisKeyBox.FocusLost:Connect(function() InvisKeyBox:ReleaseFocus() end)

local function setInvisButtonVisual(on)
    if not InvisButton then return end
    InvisButton.Text = "Invisibility: " .. (on and "ON" or "OFF")
    InvisButton.BackgroundColor3 = on and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(60, 60, 60)
end

local function makeSemiTransparent(part)
    if not part:IsA("BasePart") then return end
    if part.Name == "HumanoidRootPart" then return end
    if part.Transparency == 1 then return end
    if part.Name:lower():find("hitbox") then return end
    part.LocalTransparencyModifier = 0.5
    table.insert(invisConnections, part:GetPropertyChangedSignal("LocalTransparencyModifier"):Connect(function()
        if not invisActive then return end
        if part.LocalTransparencyModifier ~= 0.5 then part.LocalTransparencyModifier = 0.5 end
    end))
end

local function hookTransparencyHandlers(model)
    for _, descendant in pairs(model:GetDescendants()) do
        makeSemiTransparent(descendant)
    end
    table.insert(invisConnections, model.DescendantAdded:Connect(function(newDescendant)
        if invisActive then makeSemiTransparent(newDescendant) end
    end))
end

local function disableInvis(silent)
    if not invisActive then
        if not silent then setInvisButtonVisual(false) end
        return
    end
    invisActive = false
    invisProcessing = false
    if invisAnimation then
        pcall(function() if invisAnimation.IsPlaying then invisAnimation:Stop() end end)
        invisAnimation = nil
    end
    lastInvisHumanoid = nil
    local myChar = Player.Character
    if myChar then
        local myRootPart = myChar:FindFirstChild("HumanoidRootPart")
        if myRootPart and savedRootCFrame then pcall(function() myRootPart.CFrame = savedRootCFrame end) end
        savedRootCFrame = nil
        local myHumanoid = myChar:FindFirstChildOfClass("Humanoid")
        if myHumanoid then pcall(function() Workspace.CurrentCamera.CameraSubject = myHumanoid end) end
        pcall(function() myChar:SetAttribute("NoHeadLerp", false) end)
        for _, val in pairs(invisConnections) do pcall(function() val:Disconnect() end) end
        invisConnections = {}
        for _, val2 in pairs(myChar:GetDescendants()) do
            if val2:IsA("BasePart") and val2.Name ~= "HumanoidRootPart" then
                val2.LocalTransparencyModifier = 0
            end
        end
    end
    if not silent then setInvisButtonVisual(false) end
end

local function enableInvis()
    if invisActive then disableInvis(); return end
    local myChar = Player.Character
    if not myChar then
        myChar = Player.CharacterAdded:Wait()
    end
    local myHumanoid = myChar and myChar:FindFirstChildOfClass("Humanoid")
    local myRootPart = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHumanoid or not myRootPart then
        setInvisButtonVisual(false)
        return
    end
    invisActive = true
    invisProcessing = false
    hookTransparencyHandlers(myChar)
    setInvisButtonVisual(true)
end

InvisButton.MouseButton1Click:Connect(function()
    if not FCS.Unlocked then return end
    if invisActive then disableInvis() else enableInvis() end
end)

UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if invisHotkey and input.KeyCode == invisHotkey then
        if FCS.Unlocked then
            if invisActive then disableInvis() else enableInvis() end
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if isReviving then return end
    if not invisActive then return end
    if invisProcessing then return end
    invisProcessing = true
    local myChar = Player.Character
    local myHumanoid = myChar and myChar:FindFirstChildOfClass("Humanoid")
    local myRootPart = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myChar or not myHumanoid or not myRootPart then invisProcessing = false; return end
    if myHumanoid.Health <= 0 then
        if invisActive then disableInvis(true) end
        invisProcessing = false
        return
    end
    local myRootCFrame = myRootPart.CFrame
    local myVelocity = myRootPart.Velocity
    savedRootCFrame = myRootCFrame
    local currentCamera = Workspace.CurrentCamera
    if currentCamera then
        myChar:SetAttribute("NoHeadLerp", true)
        currentCamera.CameraSubject = invisHumanoid
    end
    invisPart.CFrame = myRootCFrame
    local currentInvisAnim = nil
    if lastInvisHumanoid ~= myHumanoid then
        if invisAnimation then
            pcall(function()
                if invisAnimation.IsPlaying then invisAnimation:Stop() end
                invisAnimation:Destroy()
            end)
            invisAnimation = nil
        end
        lastInvisHumanoid = myHumanoid
    end
    local animator = myHumanoid:FindFirstChildOfClass("Animator")
    if animator then
        if not invisAnimation or invisAnimation.Parent == nil then
            local invisAnimAsset = Instance.new("Animation")
            invisAnimAsset.AnimationId = "rbxassetid://71181015443030"
            invisAnimation = animator:LoadAnimation(invisAnimAsset)
            invisAnimation.Priority = Enum.AnimationPriority.Action4
            invisAnimation:Play()
            invisAnimation:AdjustSpeed(0)
            invisAnimation:AdjustWeight(2e9)
        end
        currentInvisAnim = invisAnimation
        currentInvisAnim.TimePosition = 13.45
    end
    RunService.RenderStepped:Wait()
    invisHumanoid.CameraOffset = myHumanoid.CameraOffset
    if currentCamera and currentCamera.CameraSubject == invisHumanoid then
        myChar:SetAttribute("NoHeadLerp", false)
        currentCamera.CameraSubject = myHumanoid
    end
    if currentInvisAnim and currentInvisAnim.IsPlaying then pcall(function() currentInvisAnim:Stop() end) end
    myRootPart.CFrame = myRootCFrame
    myRootPart.Velocity = myVelocity
    invisProcessing = false
end)

-- =========================================================
-- 8) ANTI RAGDOLL (перемещена ниже Invisibility)
-- =========================================================
local AntiRagdollBtn = makeToggle("Anti ragdoll", AR_Y)
AntiRagdollBtn.MouseButton1Click:Connect(function()
    if not FCS.Unlocked then return end
    antiRagdollEnabled = not antiRagdollEnabled
    AntiRagdollBtn.Text = "Anti ragdoll: " .. (antiRagdollEnabled and "ON" or "OFF")
    AntiRagdollBtn.BackgroundColor3 = antiRagdollEnabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(60, 60, 60)
    if not antiRagdollEnabled and workspace.Gravity ~= defaultGravity then
        workspace.Gravity = defaultGravity
    end
end)

-- =========================================================
-- 9) NOCLIP (кнопка)
-- =========================================================
local NoclipBtn = makeToggle("Noclip", NC_Y)
NoclipBtn.MouseButton1Click:Connect(function()
    if not FCS.Unlocked then return end
    if noclipEnabled then
        noclipDisable()
        NoclipBtn.Text = "Noclip: OFF"
        NoclipBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    else
        noclipEnable()
        NoclipBtn.Text = "Noclip: ON"
        NoclipBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    end
end)

task.spawn(function()
    while true do
        task.wait(0.05)
        applyAntiRagdoll()
    end
end)

-- =========================================================
-- 10) УВЕДОМЛЕНИЕ (для Anti Dead Counter)
-- =========================================================
local notifGui = Instance.new("ScreenGui")
notifGui.Name = "ID:11915758727_Notif"
notifGui.ResetOnSpawn = false
notifGui.IgnoreGuiInset = true
notifGui.DisplayOrder = 999
notifGui.Parent = CoreGui

local notifFrame = Instance.new("Frame")
notifFrame.Name = "DeathCounterNotif"
notifFrame.Size = UDim2.new(0, 340, 0, 40)
notifFrame.Position = UDim2.new(0.5, -170, 0, 16)
notifFrame.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
notifFrame.BorderSizePixel = 0
notifFrame.Visible = false
notifFrame.Parent = notifGui

local notifStroke = Instance.new("UIStroke")
notifStroke.Color = Color3.fromRGB(255, 0, 0)
notifStroke.Thickness = 1.5
notifStroke.Parent = notifFrame

local notifCorner = Instance.new("UICorner")
notifCorner.CornerRadius = UDim.new(0, 6)
notifCorner.Parent = notifFrame

local notifIcon = Instance.new("TextLabel")
notifIcon.Size = UDim2.new(0, 32, 1, 0)
notifIcon.Position = UDim2.new(0, 6, 0, 0)
notifIcon.BackgroundTransparency = 1
notifIcon.Text = "⚠"
notifIcon.TextColor3 = Color3.fromRGB(255, 60, 60)
notifIcon.Font = Enum.Font.SourceSansBold
notifIcon.TextSize = 20
notifIcon.Parent = notifFrame

local notifLabel = Instance.new("TextLabel")
notifLabel.Size = UDim2.new(1, -80, 1, 0)
notifLabel.Position = UDim2.new(0, 40, 0, 0)
notifLabel.BackgroundTransparency = 1
notifLabel.Text = ""
notifLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
notifLabel.Font = Enum.Font.SourceSansBold
notifLabel.TextSize = 13
notifLabel.TextXAlignment = Enum.TextXAlignment.Left
notifLabel.Parent = notifFrame

local notifTimer = Instance.new("TextLabel")
notifTimer.Size = UDim2.new(0, 40, 1, 0)
notifTimer.Position = UDim2.new(1, -46, 0, 0)
notifTimer.BackgroundTransparency = 1
notifTimer.Text = ""
notifTimer.TextColor3 = Color3.fromRGB(255, 120, 120)
notifTimer.Font = Enum.Font.SourceSansBold
notifTimer.TextSize = 14
notifTimer.TextXAlignment = Enum.TextXAlignment.Right
notifTimer.Parent = notifFrame

local notifHideThread = 0
local function showCounterNotification(nick, duration)
    notifHideThread = notifHideThread + 1
    local myThread = notifHideThread
    notifLabel.Text = "Death Counter used by " .. tostring(nick)
    notifTimer.Text = tostring(duration) .. "s"
    notifFrame.Visible = true
    notifFrame.BackgroundTransparency = 0
    notifStroke.Transparency = 0
    notifIcon.TextTransparency = 0
    notifLabel.TextTransparency = 0
    notifTimer.TextTransparency = 0
    task.spawn(function()
        local left = duration
        while left > 0 and myThread == notifHideThread do
            if notifTimer.Parent then notifTimer.Text = tostring(math.max(0, math.ceil(left))) .. "s" end
            task.wait(0.25)
            left = left - 0.25
        end
        if myThread ~= notifHideThread then return end
        for i = 0, 1, 0.1 do
            if myThread ~= notifHideThread then return end
            notifFrame.BackgroundTransparency = i
            notifStroke.Transparency = i
            notifIcon.TextTransparency = i
            notifLabel.TextTransparency = i
            notifTimer.TextTransparency = i
            task.wait(0.03)
        end
        if myThread == notifHideThread then notifFrame.Visible = false end
    end)
end

-- =========================================================
-- 11) УДАЛЕНИЕ "0" ПОСЛЕ DEATH COUNTER
-- =========================================================
local function looksLikeZero(text)
    if type(text) ~= "string" then return false end
    local t = text:gsub("%s", "")
    return t == "0" or t == "0s" or t == "0.0" or t == "0.00" or t == "0%" or t == "0/0"
end

local function isZeroLabel(label)
    if not label:IsA("TextLabel") and not label:IsA("TextButton") then return false end
    if looksLikeZero(label.Text) then return true end
    local ok, stripped = pcall(function() return label.Text:gsub("<.->", "") end)
    if ok and looksLikeZero(stripped) then return true end
    return false
end

local function cleanupCounterVisuals(character)
    if not character or not character.Parent then return end
    local names = { "__DeadCounterHighlight", "__DeadCounterHighlightBox", "__DeadCounterHighlightTimer" }
    for _, n in ipairs(names) do
        local obj = character:FindFirstChild(n, true)
        if obj then obj:Destroy() end
    end
    for _, d in ipairs(character:GetDescendants()) do
        if d:IsA("BillboardGui") then
            local hasZero = false
            for _, c in ipairs(d:GetDescendants()) do
                if isZeroLabel(c) then hasZero = true; break end
            end
            if hasZero then
                local onlyZero = true
                for _, c in ipairs(d:GetDescendants()) do
                    if (c:IsA("TextLabel") or c:IsA("TextButton")) and c.Text ~= "" and not isZeroLabel(c) then
                        onlyZero = false; break
                    end
                end
                if onlyZero then pcall(function() d:Destroy() end) end
            end
        elseif isZeroLabel(d) then
            pcall(function() d:Destroy() end)
        end
    end
    pcall(function()
        character:SetAttribute("DeadCounter", nil)
        character:SetAttribute("DeathCounter", nil)
        character:SetAttribute("CounterActive", nil)
    end)
end

local function applyHighlight(character, color, name, duration)
    if not character or not character.Parent then return end
    local old = character:FindFirstChild(name); if old then old:Destroy() end
    local oldBox = character:FindFirstChild(name .. "Box"); if oldBox then oldBox:Destroy() end
    local oldTimer = character:FindFirstChild(name .. "Timer"); if oldTimer then oldTimer:Destroy() end
    local hl = Instance.new("Highlight")
    hl.Name = name
    hl.FillColor = color
    hl.FillTransparency = 0.75
    hl.OutlineColor = color
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Adornee = character
    hl.Parent = character
    local box = Instance.new("SelectionBox")
    box.Name = name .. "Box"
    box.Color3 = color
    box.LineThickness = 0.2
    box.Transparency = 0.1
    box.Adornee = character
    box.Parent = character
    local blinkConn
    blinkConn = RunService.Heartbeat:Connect(function()
        if not box.Parent then
            if blinkConn then blinkConn:Disconnect() end
            return
        end
        local on = (math.floor(tick() * 4) % 2 == 0)
        box.Transparency = on and 0.1 or 0.7
        hl.OutlineTransparency = on and 0 or 0.6
    end)
    local head = character:FindFirstChild("Head")
    if head and duration and duration > 0 then
        local bbgui = Instance.new("BillboardGui")
        bbgui.Name = name .. "Timer"
        bbgui.Size = UDim2.new(0, 60, 0, 30)
        bbgui.StudsOffset = Vector3.new(0, 2.5, 0)
        bbgui.AlwaysOnTop = true
        bbgui.Parent = head
        local timerLabel = Instance.new("TextLabel")
        timerLabel.Size = UDim2.new(1, 0, 1, 0)
        timerLabel.BackgroundTransparency = 1
        timerLabel.Text = tostring(math.ceil(duration))
        timerLabel.TextColor3 = color
        timerLabel.TextStrokeTransparency = 0
        timerLabel.Font = Enum.Font.SourceSansBold
        timerLabel.TextScaled = true
        timerLabel.Parent = bbgui
        task.spawn(function()
            local timeLeft = duration
            while timeLeft > 0 and bbgui.Parent do
                task.wait(1)
                timeLeft = timeLeft - 1
                if timerLabel.Parent then timerLabel.Text = tostring(math.max(0, math.ceil(timeLeft))) end
            end
        end)
    end
    if duration and duration > 0 then
        task.delay(duration, function()
            if blinkConn then blinkConn:Disconnect() end
            if hl then hl:Destroy() end
            if box then box:Destroy() end
            local timer = character:FindFirstChild(name .. "Timer")
            if timer then timer:Destroy() end
            cleanupCounterVisuals(character)
        end)
    end
end

-- =========================================================
-- 12) ANTI DEAD COUNTER
-- =========================================================
local ADC_Y = NC_Y + ROW_H + 6
local antiCounterActive = false
local tsbWatchers = {}
local counterCooldown = {}
local reviveAnimConn = nil
local REVIVE_ANIM_ID = "11343250001"

local function onCounterDetected(casterPlayer, char)
    if not antiCounterActive then return end
    if not char then return end
    local now = tick()
    if not counterCooldown[casterPlayer] or (now - counterCooldown[casterPlayer]) > 2 then
        counterCooldown[casterPlayer] = now
        applyHighlight(char, Color3.fromRGB(255, 0, 0), "__DeadCounterHighlight", 10)
        local nick = "?"
        pcall(function() nick = casterPlayer.DisplayName or casterPlayer.Name end)
        showCounterNotification(nick, 10)
    end
end

local function watchPlayer(casterPlayer)
    if casterPlayer == Player then return end
    if tsbWatchers[casterPlayer] then return end
    local conns = {}
    local function onChar(char)
        if not char then return end
        table.insert(conns, char.ChildAdded:Connect(function(c)
            local cName = c.Name:lower()
            local cClass = c.ClassName
            if cClass == "Tool" and (cName:find("death counter") or cName == "death counter" or cName:find("dead counter")) then
                onCounterDetected(casterPlayer, char)
            end
        end))
    end
    if casterPlayer.Character then onChar(casterPlayer.Character) end
    table.insert(conns, casterPlayer.CharacterAdded:Connect(onChar))
    tsbWatchers[casterPlayer] = { conns = conns }
end

local function unwatchPlayer(casterPlayer)
    local w = tsbWatchers[casterPlayer]
    if w then
        for _, c in ipairs(w.conns) do pcall(function() c:Disconnect() end) end
        tsbWatchers[casterPlayer] = nil
    end
end

local function startWatchers()
    for _, p in ipairs(Players:GetPlayers()) do watchPlayer(p) end
end

local function stopWatchers()
    for p, w in pairs(tsbWatchers) do
        for _, c in ipairs(w.conns) do pcall(function() c:Disconnect() end) end
        tsbWatchers[p] = nil
    end
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then
            local hl = p.Character:FindFirstChild("__DeadCounterHighlight"); if hl then hl:Destroy() end
            local box = p.Character:FindFirstChild("__DeadCounterHighlightBox"); if box then box:Destroy() end
            local head = p.Character:FindFirstChild("Head")
            if head then
                local timer = head:FindFirstChild("__DeadCounterHighlightTimer")
                if timer then timer:Destroy() end
            end
            cleanupCounterVisuals(p.Character)
        end
    end
end

local function setRootCFrame(cframe)
    local value = Player.Character
    local rootPart = value and value:FindFirstChild("HumanoidRootPart")
    if not (value and rootPart) then return end
    task.spawn(function()
        RunService.RenderStepped:Once(function()
            rootPart.Velocity = Vector3.new()
            RunService.Heartbeat:Wait()
            rootPart.Velocity = Vector3.new()
        end)
        RunService.Heartbeat:Once(function() rootPart.CFrame = cframe end)
    end)
end

local function resetCamera()
    local myChar = Player.Character
    local myHumanoid = myChar and myChar:FindFirstChildOfClass("Humanoid")
    if myChar and myHumanoid and Workspace.CurrentCamera then
        local camCFrame = Workspace.CurrentCamera.CFrame
        Workspace.CurrentCamera:Destroy()
        local newCamera = Instance.new("Camera", Workspace)
        newCamera.CameraType = Enum.CameraType.Custom
        newCamera.CameraSubject = myHumanoid
        newCamera.CFrame = camCFrame
        Player.CameraMode = Enum.CameraMode.Classic
        local head = myChar:FindFirstChild("Head")
        if head then head.Anchored = false end
    end
end

local function watchReviveAnim(humanoid)
    if reviveAnimConn then reviveAnimConn:Disconnect(); reviveAnimConn = nil end
    if not humanoid then return end
    reviveAnimConn = humanoid.AnimationPlayed:Connect(function(track)
        if not antiCounterActive then return end
        if not track.Animation.AnimationId:match(REVIVE_ANIM_ID) then return end
        isReviving = true
        local wasInvis = invisActive
        if wasInvis then disableInvis() end
        task.spawn(function()
            task.wait(0.2)
            pcall(function() track:Stop() end)
            task.spawn(resetCamera)
            local myChar = Player.Character
            myChar:WaitForChild("AbsoluteImmortal", 1)
            local myRoot = myChar:FindFirstChild("HumanoidRootPart")
            local savedCFrame = myRoot.CFrame
            local oldSubject = Workspace.CurrentCamera and Workspace.CurrentCamera.CameraSubject
            if Workspace.CurrentCamera then Workspace.CurrentCamera.CameraSubject = nil end
            local myHumanoid = myChar:FindFirstChildOfClass("Humanoid")
            local sinkCFrame = CFrame.new(0, -10000, 0) * CFrame.Angles(math.rad(90), 0, 0)
            local startTick = tick()
            repeat
                setRootCFrame(sinkCFrame)
                RunService.RenderStepped:Wait()
            until tick() >= startTick + 1
            if Workspace.CurrentCamera then Workspace.CurrentCamera.CameraSubject = oldSubject end
            setRootCFrame(savedCFrame)
            task.wait(0.5)
            local myChar2 = Player.Character
            if myChar2 then
                local freeze = myChar2:FindFirstChild("Freeze"); if freeze then freeze:Destroy() end
                local noRotate = myChar2:FindFirstChild("NoRotate"); if noRotate then noRotate:Destroy() end
            end
            task.spawn(resetCamera)
            isReviving = false
            if wasInvis then enableInvis() end
        end)
    end)
end

local function hookCharacterRevive(character)
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        watchReviveAnim(humanoid)
    else
        task.spawn(function()
            local h = character:WaitForChild("Humanoid", 5)
            if h then watchReviveAnim(h) end
        end)
    end
end

local AntiCounterBtn = makeToggle("Anti dead counter", ADC_Y)
AntiCounterBtn.MouseButton1Click:Connect(function()
    if not FCS.Unlocked then return end
    antiCounterActive = not antiCounterActive
    if antiCounterActive then
        AntiCounterBtn.Text = "Anti dead counter: ON"
        AntiCounterBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        startWatchers()
        local char = Player.Character
        if char then
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid then watchReviveAnim(humanoid) end
        end
    else
        AntiCounterBtn.Text = "Anti dead counter: OFF"
        AntiCounterBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        stopWatchers()
        if reviveAnimConn then reviveAnimConn:Disconnect(); reviveAnimConn = nil end
    end
end)

Players.PlayerAdded:Connect(function(p)
    if antiCounterActive then watchPlayer(p) end
end)
Players.PlayerRemoving:Connect(function(p)
    unwatchPlayer(p)
    counterCooldown[p] = nil
end)

-- =========================================================
-- 13) СЛАЙДЕРЫ
-- =========================================================
local draggingSlider = false
local activeSlider = nil

local function bindSlider(kindRef)
    kindRef.Back.InputBegan:Connect(function(input)
        if not FCS.Unlocked then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingSlider = true
            activeSlider = kindRef
            if kindRef == CubeRadiusSlider then setCubeFromX(CubeRadiusSlider, input.Position.X, 1)
            elseif kindRef == CubeTranspSlider then setCubeFromX(CubeTranspSlider, input.Position.X, 2)
            elseif kindRef == AmRadiusSlider then setAmFromX(AmRadiusSlider, input.Position.X, 1)
            elseif kindRef == AmTranspSlider then setAmFromX(AmTranspSlider, input.Position.X, 2) end
        end
    end)
end

bindSlider(CubeRadiusSlider); bindSlider(CubeTranspSlider)
bindSlider(AmRadiusSlider); bindSlider(AmTranspSlider)

UIS.InputChanged:Connect(function(input)
    if draggingSlider and activeSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        if activeSlider == CubeRadiusSlider then setCubeFromX(CubeRadiusSlider, input.Position.X, 1)
        elseif activeSlider == CubeTranspSlider then setCubeFromX(CubeTranspSlider, input.Position.X, 2)
        elseif activeSlider == AmRadiusSlider then setAmFromX(AmRadiusSlider, input.Position.X, 1)
        elseif activeSlider == AmTranspSlider then setAmFromX(AmTranspSlider, input.Position.X, 2) end
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingSlider = false
        activeSlider = nil
    end
end)

updateCubeVisuals()
updateAmVisuals()

-- CanvasSize: до конца Anti dead counter
Scroll.CanvasSize = UDim2.new(0, 0, 0, ADC_Y + ROW_H + 10)
