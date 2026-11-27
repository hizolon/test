-- hitbox.lua
local page = getgenv().FCS and getgenv().FCS.pages and getgenv().FCS.pages["Hitbox"]
if not page then return end
if page:FindFirstChild("HitboxRoot") then return end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Player = Players.LocalPlayer
local FCS = getgenv().FCS

-- ===== Камера =====
local Camera
repeat task.wait() until Workspace.CurrentCamera
Camera = Workspace.CurrentCamera
Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    Camera = Workspace.CurrentCamera
end)

-- ===== Drawing guard =====
local Drawing = Drawing
local hasDrawing = (Drawing ~= nil and Drawing.new ~= nil)
if not hasDrawing then
    warn("[Hitbox] Drawing API недоступен — ESP будет отключён")
end

-- ===== Корень страницы (для защиты от дублей) =====
local Root = Instance.new("Frame")
Root.Name = "HitboxRoot"
Root.Size = UDim2.fromScale(1, 1)
Root.BackgroundTransparency = 1
Root.BorderSizePixel = 0
Root.Parent = page

-- ===== Стиль =====
local SIDE_PADDING = 7
local GAP = 6
local VALUE_WIDTH = 55
local ROW_H = 24
local SPACING = 8
local XRAY_MIN, XRAY_MAX = 0, 100

local function makeToggle(text, y, height, width)
    local b = Instance.new("TextButton")
    b.Position = UDim2.new(0, SIDE_PADDING, 0, y)
    b.Size = width or UDim2.new(1, -(SIDE_PADDING * 2), 0, height or ROW_H)
    b.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    b.BorderSizePixel = 0
    b.Text = text .. ": OFF"
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Font = Enum.Font.SourceSansBold
    b.TextSize = 12
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.Parent = Root
    local pad = Instance.new("UIPadding"); pad.PaddingLeft = UDim.new(0, 8); pad.Parent = b
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 4); c.Parent = b
    return b
end

local function makeSlider(yPos)
    local back = Instance.new("Frame")
    back.Position = UDim2.new(0, SIDE_PADDING, 0, yPos)
    back.Size = UDim2.new(1, -(SIDE_PADDING * 2), 0, 8)
    back.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    back.BorderSizePixel = 0
    back.Parent = Root
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

-- ===== Кнопки =====
local HitboxPlayerBtn  = makeToggle("Hitbox player", 6, 28)
local XrayPlayerBtn    = makeToggle("Xray player", 6 + 28 + SPACING, 28)
local HitboxNpcBtn     = makeToggle("Hitbox NPC", 6 + 2 * (28 + SPACING), 28)
local XrayNpcBtn       = makeToggle("Xray NPC", 6 + 3 * (28 + SPACING), 28)

local PING_Y = 6 + 4 * (28 + SPACING)
local DevicePingBtn = makeToggle("Ping tag", PING_Y, 28)

local ESP_Y = PING_Y + 28 + SPACING
local espEnabled = false
local espHotkey = Enum.KeyCode.E

local ESPBtn = makeToggle(
    "ESP",
    ESP_Y,
    ROW_H,
    UDim2.new(1, -(SIDE_PADDING * 2 + GAP + VALUE_WIDTH), 0, ROW_H)
)

local ESPKeyBox = Instance.new("TextBox")
ESPKeyBox.AnchorPoint = Vector2.new(1, 0)
ESPKeyBox.Position = UDim2.new(1, -SIDE_PADDING, 0, ESP_Y)
ESPKeyBox.Size = UDim2.new(0, VALUE_WIDTH, 0, ROW_H)
ESPKeyBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
ESPKeyBox.BorderSizePixel = 0
ESPKeyBox.Text = "E"
ESPKeyBox.PlaceholderText = "..."
ESPKeyBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
ESPKeyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
ESPKeyBox.Font = Enum.Font.SourceSansBold
ESPKeyBox.TextSize = 12
ESPKeyBox.ClearTextOnFocus = false
ESPKeyBox.Parent = Root
local ESPKeyCorner = Instance.new("UICorner"); ESPKeyCorner.CornerRadius = UDim.new(0, 4); ESPKeyCorner.Parent = ESPKeyBox

local xrayEnabled = false
local xrayOriginals = {}
local xrayConn = nil
local xrayTransparencyPct = 50
local xrayHotkey = Enum.KeyCode.X

local XRAY_Y = ESP_Y + ROW_H + SPACING

local XRayBtn = makeToggle(
    "X-Ray",
    XRAY_Y,
    ROW_H,
    UDim2.new(1, -(SIDE_PADDING * 2 + GAP + VALUE_WIDTH), 0, ROW_H)
)

local XRayKeyBox = Instance.new("TextBox")
XRayKeyBox.AnchorPoint = Vector2.new(1, 0)
XRayKeyBox.Position = UDim2.new(1, -SIDE_PADDING, 0, XRAY_Y)
XRayKeyBox.Size = UDim2.new(0, VALUE_WIDTH, 0, ROW_H)
XRayKeyBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
XRayKeyBox.BorderSizePixel = 0
XRayKeyBox.Text = "X"
XRayKeyBox.PlaceholderText = "..."
XRayKeyBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
XRayKeyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
XRayKeyBox.Font = Enum.Font.SourceSansBold
XRayKeyBox.TextSize = 12
XRayKeyBox.ClearTextOnFocus = false
XRayKeyBox.Parent = Root
local XRayKeyCorner = Instance.new("UICorner"); XRayKeyCorner.CornerRadius = UDim.new(0, 4); XRayKeyCorner.Parent = XRayKeyBox

local XRaySlider = makeSlider(XRAY_Y + ROW_H + SPACING)

-- ===== X-Ray визуал =====
local function updateXRayVisuals()
    local a = math.clamp((xrayTransparencyPct - XRAY_MIN) / (XRAY_MAX - XRAY_MIN), 0, 1)
    XRaySlider.Fill.Size = UDim2.new(a, 0, 1, 0)
    XRaySlider.Knob.Position = UDim2.new(a, -7, 0.5, -7)
end

local function applyXrayTransparency()
    local t = xrayTransparencyPct / 100
    for inst in pairs(xrayOriginals) do
        if inst.Parent then inst.Transparency = t end
    end
end

local function setXRayFromX(slider, mouseX)
    local absPos = slider.Back.AbsolutePosition
    local absSize = slider.Back.AbsoluteSize
    if absSize.X <= 0 then return end
    local alpha = math.clamp((mouseX - absPos.X) / absSize.X, 0, 1)
    xrayTransparencyPct = math.floor(XRAY_MIN + alpha * (XRAY_MAX - XRAY_MIN) + 0.5)
    updateXRayVisuals()
    if xrayEnabled then applyXrayTransparency() end
end

-- ===== Контур куба =====
local function makeEdges(size, color, transparency)
    local folder = Instance.new("Folder")
    folder.Name = "HitboxEdges"
    folder.Parent = Workspace
    local t = 0.08
    local sx, sy, sz = size.X, size.Y, size.Z
    local edges = {}
    local function addEdge(localCF, sz3)
        local p = Instance.new("Part")
        p.Anchored = true
        p.CanCollide = false
        p.CanQuery = false
        p.CanTouch = false
        p.CastShadow = false
        p.Material = Enum.Material.SmoothPlastic
        p.Color = color
        p.Transparency = transparency or 0
        p.Size = sz3
        p.CFrame = localCF
        p.Parent = folder
        table.insert(edges, { part = p, offset = localCF })
    end
    for _, x in ipairs({-sx/2, sx/2}) do
        for _, z in ipairs({-sz/2, sz/2}) do
            addEdge(CFrame.new(x, 0, z), Vector3.new(t, sy, t))
        end
    end
    for _, y in ipairs({-sy/2, sy/2}) do
        for _, z in ipairs({-sz/2, sz/2}) do
            addEdge(CFrame.new(0, y, z), Vector3.new(sx, t, t))
        end
    end
    for _, y in ipairs({-sy/2, sy/2}) do
        for _, x in ipairs({-sx/2, sx/2}) do
            addEdge(CFrame.new(x, y, 0), Vector3.new(t, t, sz))
        end
    end
    return folder, edges
end

local function updateEdges(edges, baseCF)
    for _, e in ipairs(edges) do
        e.part.CFrame = baseCF * e.offset
    end
end

-- ===== HITBOX PLAYER =====
local hitboxPlayersEnabled = false
local playerBoxes = {}

local function clearPlayerBoxes()
    for plr, data in pairs(playerBoxes) do
        if data.folder then data.folder:Destroy() end
    end
    playerBoxes = {}
end

local function getCharBoxSize(char)
    local ok, msize = pcall(function() return char:GetExtentsSize() end)
    if ok and msize and msize.Magnitude > 0 then
        return msize + Vector3.new(0.2, 0.2, 0.2)
    end
    return Vector3.new(4, 5, 4)
end

local function createPlayerBox(plr)
    local char = plr.Character
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local size = getCharBoxSize(char)
    local folder, edges = makeEdges(size, Color3.fromRGB(255, 255, 255), 0)
    return { folder = folder, edges = edges, lastSize = size }
end

local function refreshPlayerBoxes()
    for plr, data in pairs(playerBoxes) do
        if not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") then
            if data.folder then data.folder:Destroy() end
            playerBoxes[plr] = nil
        end
    end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            if not playerBoxes[plr] then
                local data = createPlayerBox(plr)
                if data then playerBoxes[plr] = data end
            end
        end
    end
end

local function updatePlayerBoxes()
    for plr, data in pairs(playerBoxes) do
        local char = plr.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then
            if data.folder then data.folder:Destroy() end
            playerBoxes[plr] = nil
        else
            local newSize = getCharBoxSize(char)
            if (newSize - data.lastSize).Magnitude > 0.1 then
                if data.folder then data.folder:Destroy() end
                local nd = createPlayerBox(plr)
                if nd then playerBoxes[plr] = nd end
            else
                updateEdges(data.edges, hrp.CFrame)
            end
        end
    end
end

-- ===== HITBOX NPC =====
local hitboxNpcEnabled = false
local npcBoxes = {}

local function isPlayerCharacterModel(model)
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character == model then return true end
    end
    return false
end

local function getModelBoxSize(model)
    local ok, msize = pcall(function() return model:GetExtentsSize() end)
    if ok and msize and msize.Magnitude > 0 then
        return msize + Vector3.new(0.2, 0.2, 0.2)
    end
    return Vector3.new(4, 5, 4)
end

local function createNpcBox(model)
    local primary = model.PrimaryPart or model:FindFirstChild("HumanoidRootPart") or model:FindFirstChildWhichIsA("BasePart")
    if not primary then return nil end
    local size = getModelBoxSize(model)
    local folder, edges = makeEdges(size, Color3.fromRGB(255, 255, 255), 0)
    return { folder = folder, edges = edges, lastSize = size, primary = primary }
end

local function clearNpcBoxes()
    for model, data in pairs(npcBoxes) do
        if data.folder then data.folder:Destroy() end
    end
    npcBoxes = {}
end

local function refreshNpcBoxes()
    for model, data in pairs(npcBoxes) do
        if not model.Parent or not model:FindFirstChildOfClass("Humanoid") or isPlayerCharacterModel(model) then
            if data.folder then data.folder:Destroy() end
            npcBoxes[model] = nil
        end
    end
    for _, inst in ipairs(Workspace:GetDescendants()) do
        if inst:IsA("Model")
            and inst:FindFirstChildOfClass("Humanoid")
            and not isPlayerCharacterModel(inst)
            and not npcBoxes[inst] then
            local data = createNpcBox(inst)
            if data then npcBoxes[inst] = data end
        end
    end
end

local function updateNpcBoxes()
    for model, data in pairs(npcBoxes) do
        local primary = model.PrimaryPart or model:FindFirstChild("HumanoidRootPart") or model:FindFirstChildWhichIsA("BasePart")
        if not model.Parent or not model:FindFirstChildOfClass("Humanoid") or not primary then
            if data.folder then data.folder:Destroy() end
            npcBoxes[model] = nil
        else
            local newSize = getModelBoxSize(model)
            if (newSize - data.lastSize).Magnitude > 0.1 then
                if data.folder then data.folder:Destroy() end
                local nd = createNpcBox(model)
                if nd then npcBoxes[model] = nd end
            else
                updateEdges(data.edges, primary.CFrame)
            end
        end
    end
end

-- ===== XRAY PLAYER =====
local xrayPlayersEnabled = false
local xrayPlayerHighlights = {}

local function clearXrayPlayers()
    for plr, hl in pairs(xrayPlayerHighlights) do
        if hl then hl:Destroy() end
    end
    xrayPlayerHighlights = {}
end

local function createXrayPlayer(plr)
    local char = plr.Character
    if not char then return nil end
    local hl = Instance.new("Highlight")
    hl.Name = "XrayPlayerHighlight"
    hl.FillColor = Color3.fromRGB(255, 0, 0)
    hl.FillTransparency = 0.7
    hl.OutlineColor = Color3.fromRGB(255, 0, 0)
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Adornee = char
    hl.Parent = char
    return hl
end

local function refreshXrayPlayers()
    for plr, hl in pairs(xrayPlayerHighlights) do
        if not plr.Character or not hl or hl.Parent ~= plr.Character then
            if hl then hl:Destroy() end
            xrayPlayerHighlights[plr] = nil
        end
    end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= Player and plr.Character then
            if not xrayPlayerHighlights[plr] then
                local hl = createXrayPlayer(plr)
                if hl then xrayPlayerHighlights[plr] = hl end
            end
        end
    end
end

-- ===== XRAY NPC =====
local xrayNpcEnabled = false
local xrayNpcHighlights = {}

local function clearXrayNpcs()
    for model, hl in pairs(xrayNpcHighlights) do
        if hl then hl:Destroy() end
    end
    xrayNpcHighlights = {}
end

local function createXrayNpc(model)
    if not model or not model.Parent then return nil end
    local hl = Instance.new("Highlight")
    hl.Name = "XrayNpcHighlight"
    hl.FillColor = Color3.fromRGB(0, 0, 255)
    hl.FillTransparency = 0.7
    hl.OutlineColor = Color3.fromRGB(0, 0, 255)
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Adornee = model
    hl.Parent = model
    return hl
end

local function refreshXrayNpcs()
    for model, hl in pairs(xrayNpcHighlights) do
        if not model.Parent or not model:FindFirstChildOfClass("Humanoid") or isPlayerCharacterModel(model) or not hl or hl.Parent ~= model then
            if hl then hl:Destroy() end
            xrayNpcHighlights[model] = nil
        end
    end
    for _, inst in ipairs(Workspace:GetDescendants()) do
        if inst:IsA("Model") and inst:FindFirstChildOfClass("Humanoid") and not isPlayerCharacterModel(inst) then
            if not xrayNpcHighlights[inst] then
                local hl = createXrayNpc(inst)
                if hl then xrayNpcHighlights[inst] = hl end
            end
        end
    end
end

-- ===== HITBOX OBJECT =====
local hitboxObjectEnabled = false
local objectBoxes = {}
local objectConn = nil
local OBJECT_RADIUS = 250
local OBJECT_RADIUS_SQ = OBJECT_RADIUS * OBJECT_RADIUS
local OBJECT_RADIUS_CLEAN_SQ = (OBJECT_RADIUS * 1.5) * (OBJECT_RADIUS * 1.5)
local MAX_OBJECTS_PER_FRAME = 40
local MAX_ACTIVE_OBJECTS = 400

local function isPlayerCharacterPart(inst)
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character and inst:IsDescendantOf(plr.Character) then return true end
    end
    return false
end

local function isNpcPart(inst)
    local model = inst:FindFirstAncestorOfClass("Model")
    if model and model:FindFirstChildOfClass("Humanoid") then return true end
    return false
end

local function isExcludedFromObjects(inst)
    return isPlayerCharacterPart(inst) or isNpcPart(inst)
end

local function getPlayerPos()
    local char = Player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    return hrp and hrp.Position or Vector3.zero
end

local function isWithinRadius(part)
    local myPos = getPlayerPos()
    if myPos == Vector3.zero then return true end
    local d = part.Position - myPos
    return d:Dot(d) <= OBJECT_RADIUS_SQ
end

local function countBoxes()
    local n = 0
    for _ in pairs(objectBoxes) do n += 1 end
    return n
end

local function createObjectBox(part)
    local size = part.Size
    if size.Magnitude < 0.5 or size.Magnitude > 200 then return nil end
    local folder, edges = makeEdges(size, Color3.fromRGB(255, 255, 255), 0)
    return { folder = folder, edges = edges, lastSize = size }
end

local pendingQueue = {}
local queueIndex = 1
local queuedSet = {}

local function pushToQueue(part)
    if queuedSet[part] then return end
    queuedSet[part] = true
    pendingQueue[#pendingQueue + 1] = part
end

local function scanForMissing()
    local myPos = getPlayerPos()
    for _, inst in ipairs(Workspace:GetDescendants()) do
        if inst:IsA("BasePart")
            and not objectBoxes[inst]
            and not queuedSet[inst]
            and not isExcludedFromObjects(inst) then
            if myPos == Vector3.zero then
                pushToQueue(inst)
            else
                local d = inst.Position - myPos
                if d:Dot(d) <= OBJECT_RADIUS_SQ then
                    pushToQueue(inst)
                end
            end
        end
    end
end

local function processQueue()
    if not hitboxObjectEnabled then return end
    local processed = 0
    while queueIndex <= #pendingQueue and processed < MAX_OBJECTS_PER_FRAME do
        local part = pendingQueue[queueIndex]
        queueIndex += 1
        processed += 1
        queuedSet[part] = nil
        if part and part.Parent
            and not objectBoxes[part]
            and not isExcludedFromObjects(part)
            and isWithinRadius(part) then
            if countBoxes() < MAX_ACTIVE_OBJECTS then
                local data = createObjectBox(part)
                if data then objectBoxes[part] = data end
            end
        end
    end
    if queueIndex > #pendingQueue then
        pendingQueue = {}
        queueIndex = 1
        queuedSet = {}
    end
end

local function cleanupFarObjects()
    local myPos = getPlayerPos()
    if myPos == Vector3.zero then return end
    for part, data in pairs(objectBoxes) do
        if not part.Parent then
            if data.folder then data.folder:Destroy() end
            objectBoxes[part] = nil
        else
            local d = part.Position - myPos
            if d:Dot(d) > OBJECT_RADIUS_CLEAN_SQ then
                if data.folder then data.folder:Destroy() end
                objectBoxes[part] = nil
            end
        end
    end
end

local function updateObjectBoxes()
    for part, data in pairs(objectBoxes) do
        if not part.Parent then
            if data.folder then data.folder:Destroy() end
            objectBoxes[part] = nil
        elseif part.Size ~= data.lastSize then
            if data.folder then data.folder:Destroy() end
            local nd = createObjectBox(part)
            if nd then objectBoxes[part] = nd else objectBoxes[part] = nil end
        else
            updateEdges(data.edges, part.CFrame)
        end
    end
end

local function startObjectHitbox()
    scanForMissing()
    objectConn = Workspace.DescendantAdded:Connect(function(inst)
        if not hitboxObjectEnabled then return end
        if inst:IsA("BasePart") then
            task.defer(function()
                if not isExcludedFromObjects(inst) and isWithinRadius(inst) then
                    pushToQueue(inst)
                end
            end)
        end
    end)
end

local function stopObjectHitbox()
    if objectConn then objectConn:Disconnect(); objectConn = nil end
    for part, data in pairs(objectBoxes) do
        if data.folder then data.folder:Destroy() end
    end
    objectBoxes = {}
    pendingQueue = {}
    queueIndex = 1
    queuedSet = {}
end

-- ===== X-RAY =====
local function isAnyPlayerCharacter(inst)
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character and inst:IsDescendantOf(plr.Character) then return true end
    end
    return false
end

local function applyXray(inst)
    if not inst:IsA("BasePart") then return end
    if isAnyPlayerCharacter(inst) then return end
    if xrayOriginals[inst] == nil then
        xrayOriginals[inst] = inst.Transparency
    end
    inst.Transparency = xrayTransparencyPct / 100
end

local function clearXray()
    for inst, orig in pairs(xrayOriginals) do
        if inst.Parent then inst.Transparency = orig end
    end
    xrayOriginals = {}
    if xrayConn then xrayConn:Disconnect(); xrayConn = nil end
end

local function startXray()
    for _, inst in ipairs(Workspace:GetDescendants()) do
        applyXray(inst)
    end
    xrayConn = Workspace.DescendantAdded:Connect(function(inst)
        if not xrayEnabled then return end
        if inst:IsA("BasePart") then
            task.defer(function() applyXray(inst) end)
        end
    end)
end

-- ===== PING TAG =====
local pingEnabled = false
local MAX_DISTANCE = 200
local pingTags = {}
local charConns = {}

local function getMyPing()
    local ok, stats = pcall(function() return game:GetService("Stats") end)
    if ok and stats then
        local item = stats.Network.ServerStatsItem["Data Ping"]
        if item then return math.floor(item:GetValue()) end
    end
    return 0
end

local function removePingTag(plr)
    local tag = pingTags[plr]
    if tag and tag.billboard then tag.billboard:Destroy() end
    pingTags[plr] = nil
end

local function createPingTag(plr)
    local char = plr.Character
    if not char then return nil end
    local head = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
    if not head then return nil end
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "PingTag"
    billboard.Size = UDim2.new(0, 90, 0, 18)
    billboard.StudsOffset = Vector3.new(0, 4.5, 0)
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = MAX_DISTANCE
    billboard.Adornee = head
    billboard.Parent = head
    local infoLabel = Instance.new("TextLabel")
    infoLabel.Size = UDim2.new(1, 0, 1, 0)
    infoLabel.BackgroundTransparency = 1
    infoLabel.Text = getMyPing() .. " ms"
    infoLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    infoLabel.TextStrokeTransparency = 0
    infoLabel.Font = Enum.Font.SourceSansBold
    infoLabel.TextSize = 13
    infoLabel.Parent = billboard
    return { billboard = billboard, infoLabel = infoLabel, head = head, plr = plr }
end

local function watchPlayerCharacter(plr)
    if charConns[plr] then return end
    charConns[plr] = plr.CharacterAdded:Connect(function()
        if not pingEnabled then return end
        removePingTag(plr)
        task.spawn(function()
            local char = plr.Character or plr.CharacterAdded:Wait()
            char:WaitForChild("Head", 5)
            task.wait(0.1)
            if pingEnabled and not pingTags[plr] then
                local data = createPingTag(plr)
                if data then pingTags[plr] = data end
            end
        end)
    end)
end

local function unwatchPlayerCharacter(plr)
    local c = charConns[plr]
    if c then c:Disconnect(); charConns[plr] = nil end
end

local function refreshPingTags()
    for plr, tag in pairs(pingTags) do
        if not plr.Character or not tag.billboard.Parent then
            removePingTag(plr)
        else
            local head = plr.Character:FindFirstChild("Head") or plr.Character:FindFirstChild("HumanoidRootPart")
            if head and tag.head ~= head then
                tag.billboard.Adornee = head
                tag.head = head
            end
            if tag.infoLabel then
                tag.infoLabel.Text = getMyPing() .. " ms"
            end
        end
    end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= Player and plr.Character then
            if not pingTags[plr] then
                local data = createPingTag(plr)
                if data then pingTags[plr] = data end
            end
        end
    end
end

local function clearPingTags()
    for plr in pairs(pingTags) do
        removePingTag(plr)
    end
    for plr in pairs(charConns) do
        unwatchPlayerCharacter(plr)
    end
end

local function startPing()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= Player then watchPlayerCharacter(plr) end
    end
    refreshPingTags()
end

local function stopPing()
    clearPingTags()
end

-- ===== ESP =====
local espBoxes = {}
local espTracers = {}
local espNameTags = {}
local espDistanceTags = {}
local espPlayerAddedConn = nil
local espPlayerConns = {}

local function getDisplayName(plr)
    if plr.DisplayName and plr.DisplayName ~= "" then return plr.DisplayName end
    return plr.Name
end

local function espCreateText(size)
    if not hasDrawing then return nil end
    local text = Drawing.new("Text")
    text.Size = size
    text.Center = true
    text.Outline = false
    text.Visible = false
    return text
end

local function espCreate(character, plr)
    if not hasDrawing then return end
    if not character or espBoxes[character] then return end
    if plr == Player then return end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local head = character:FindFirstChild("Head")
    local humanoid = character:FindFirstChild("Humanoid")
    if not hrp or not head then return end
    local box = Drawing.new("Square")
    box.Visible = false; box.Color = Color3.fromRGB(255, 255, 255); box.Filled = false; box.Transparency = 1; box.Thickness = 1
    local line = Drawing.new("Line")
    line.Visible = false; line.Color = Color3.fromRGB(255, 255, 255); line.Thickness = 1; line.Transparency = 1
    local nameTag = espCreateText(11)
    local distTag = espCreateText(11)
    local conn = RunService.RenderStepped:Connect(function()
        if not espEnabled then
            box.Visible = false; line.Visible = false
            if nameTag then nameTag.Visible = false end
            if distTag then distTag.Visible = false end
            return
        end
        hrp = character:FindFirstChild("HumanoidRootPart")
        head = character:FindFirstChild("Head")
        humanoid = character:FindFirstChild("Humanoid")
        if not hrp or not head or not humanoid then return end
        if not Camera then return end
        local pos, visible = Camera:WorldToViewportPoint(hrp.Position)
        local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.3, 0))
        local legPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 2.5, 0))
        local distance = (Camera.CFrame.Position - hrp.Position).Magnitude
        if visible and distance <= 1000 then
            local scale = 1 / (pos.Z * math.tan(math.rad(Camera.FieldOfView * 0.5)) * 2) * 100
            local width, height = math.floor(40 * scale), math.floor(62 * scale)
            local position = Vector2.new(pos.X - width / 2, pos.Y - height / 2)
            box.Size = Vector2.new(width, height); box.Position = position; box.Visible = true
            line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y - 50)
            line.To = Vector2.new(pos.X, pos.Y); line.Visible = true
            if nameTag then
                nameTag.Position = Vector2.new(headPos.X, headPos.Y - 20)
                nameTag.Text = getDisplayName(plr)
                nameTag.Color = Color3.fromRGB(255, 255, 255)
                nameTag.Visible = true
            end
            if distTag then
                if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                    local dist = math.floor((hrp.Position - Player.Character.HumanoidRootPart.Position).Magnitude)
                    distTag.Position = Vector2.new(legPos.X, legPos.Y + 5)
                    distTag.Text = tostring(dist) .. "m"
                    distTag.Color = Color3.fromRGB(255, 255, 255)
                    distTag.Visible = true
                else
                    distTag.Visible = false
                end
            end
        else
            box.Visible = false; line.Visible = false
            if nameTag then nameTag.Visible = false end
            if distTag then distTag.Visible = false end
        end
    end)
    espBoxes[character] = { Box = box, Connection = conn }
    espTracers[character] = { Line = line }
    if nameTag then espNameTags[plr] = nameTag end
    if distTag then espDistanceTags[plr] = distTag end
end

local function espRemove(character, plr)
    if espBoxes[character] then
        if espBoxes[character].Connection then espBoxes[character].Connection:Disconnect() end
        if espBoxes[character].Box then espBoxes[character].Box:Remove() end
        espBoxes[character] = nil
    end
    if espTracers[character] then
        if espTracers[character].Line then espTracers[character].Line:Remove() end
        espTracers[character] = nil
    end
    if espNameTags[plr] then espNameTags[plr]:Remove(); espNameTags[plr] = nil end
    if espDistanceTags[plr] then espDistanceTags[plr]:Remove(); espDistanceTags[plr] = nil end
end

local function espSetupPlayer(plr)
    if plr == Player then return end
    if espPlayerConns[plr] then return end
    espPlayerConns[plr] = true
    plr.CharacterAdded:Connect(function(char)
        espRemove(char, plr)
        task.wait(0.1)
        char:WaitForChild("HumanoidRootPart", 5)
        char:WaitForChild("Head", 5)
        char:WaitForChild("Humanoid", 5)
        espCreate(char, plr)
    end)
    plr.CharacterRemoving:Connect(function(char) espRemove(char, plr) end)
    if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChild("Head") and plr.Character:FindFirstChild("Humanoid") then
        espCreate(plr.Character, plr)
    end
end

local function startESP()
    if not hasDrawing then
        warn("[Hitbox] ESP недоступен: нет Drawing API")
        return
    end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= Player then espSetupPlayer(plr) end
    end
    if not espPlayerAddedConn then
        espPlayerAddedConn = Players.PlayerAdded:Connect(espSetupPlayer)
    end
end

local function stopESP()
    if espPlayerAddedConn then espPlayerAddedConn:Disconnect(); espPlayerAddedConn = nil end
    for char, data in pairs(espBoxes) do
        if data.Connection then data.Connection:Disconnect() end
        if data.Box then data.Box:Remove() end
    end
    for char, data in pairs(espTracers) do
        if data.Line then data.Line:Remove() end
    end
    for plr, tag in pairs(espNameTags) do tag:Remove() end
    for plr, tag in pairs(espDistanceTags) do tag:Remove() end
    espBoxes = {}; espTracers = {}; espNameTags = {}; espDistanceTags = {}
    espPlayerConns = {}
end

-- ===== ПЕРЕКЛЮЧАТЕЛИ =====
HitboxPlayerBtn.MouseButton1Click:Connect(function()
    hitboxPlayersEnabled = not hitboxPlayersEnabled
    HitboxPlayerBtn.Text = "Hitbox player: " .. (hitboxPlayersEnabled and "ON" or "OFF")
    HitboxPlayerBtn.BackgroundColor3 = hitboxPlayersEnabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(60, 60, 60)
    if hitboxPlayersEnabled then refreshPlayerBoxes() else clearPlayerBoxes() end
end)

XrayPlayerBtn.MouseButton1Click:Connect(function()
    xrayPlayersEnabled = not xrayPlayersEnabled
    XrayPlayerBtn.Text = "Xray player: " .. (xrayPlayersEnabled and "ON" or "OFF")
    XrayPlayerBtn.BackgroundColor3 = xrayPlayersEnabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(60, 60, 60)
    if xrayPlayersEnabled then refreshXrayPlayers() else clearXrayPlayers() end
end)

HitboxNpcBtn.MouseButton1Click:Connect(function()
    hitboxNpcEnabled = not hitboxNpcEnabled
    HitboxNpcBtn.Text = "Hitbox NPC: " .. (hitboxNpcEnabled and "ON" or "OFF")
    HitboxNpcBtn.BackgroundColor3 = hitboxNpcEnabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(60, 60, 60)
    if hitboxNpcEnabled then refreshNpcBoxes() else clearNpcBoxes() end
end)

XrayNpcBtn.MouseButton1Click:Connect(function()
    xrayNpcEnabled = not xrayNpcEnabled
    XrayNpcBtn.Text = "Xray NPC: " .. (xrayNpcEnabled and "ON" or "OFF")
    XrayNpcBtn.BackgroundColor3 = xrayNpcEnabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(60, 60, 60)
    if xrayNpcEnabled then refreshXrayNpcs() else clearXrayNpcs() end
end)

DevicePingBtn.MouseButton1Click:Connect(function()
    pingEnabled = not pingEnabled
    DevicePingBtn.Text = "Ping tag: " .. (pingEnabled and "ON" or "OFF")
    DevicePingBtn.BackgroundColor3 = pingEnabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(60, 60, 60)
    if pingEnabled then startPing() else stopPing() end
end)

local function setESPState(state)
    espEnabled = state
    ESPBtn.Text = "ESP: " .. (espEnabled and "ON" or "OFF")
    ESPBtn.BackgroundColor3 = espEnabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(60, 60, 60)
    if espEnabled then startESP() else stopESP() end
end

ESPBtn.MouseButton1Click:Connect(function()
    setESPState(not espEnabled)
end)

local function setXRayState(state)
    xrayEnabled = state
    XRayBtn.Text = "X-Ray: " .. (xrayEnabled and "ON" or "OFF")
    XRayBtn.BackgroundColor3 = xrayEnabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(60, 60, 60)
    if xrayEnabled then startXray() else clearXray() end
end

XRayBtn.MouseButton1Click:Connect(function()
    setXRayState(not xrayEnabled)
end)

UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if xrayHotkey and input.KeyCode == xrayHotkey then
        setXRayState(not xrayEnabled)
    end
end)

-- ===== ХОТКЕИ =====
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

local function refreshXRayHotkey()
    local raw = XRayKeyBox.Text
    local normalized = normalizeKey(raw)
    if normalized ~= raw then XRayKeyBox.Text = normalized; return end
    if normalized == "" then xrayHotkey = nil; return end
    local key = keyFromString(normalized)
    if key then xrayHotkey = key else XRayKeyBox.Text = ""; xrayHotkey = nil end
end
XRayKeyBox:GetPropertyChangedSignal("Text"):Connect(refreshXRayHotkey)

local function refreshESPHotkey()
    local raw = ESPKeyBox.Text
    local normalized = normalizeKey(raw)
    if normalized ~= raw then ESPKeyBox.Text = normalized; return end
    if normalized == "" then espHotkey = nil; return end
    local key = keyFromString(normalized)
    if key then espHotkey = key else ESPKeyBox.Text = ""; espHotkey = nil end
end
ESPKeyBox:GetPropertyChangedSignal("Text"):Connect(refreshESPHotkey)

UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if espHotkey and input.KeyCode == espHotkey then
        setESPState(not espEnabled)
    end
end)

-- ===== СЛАЙДЕР X-RAY =====
local draggingXRaySlider = false

XRaySlider.Back.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingXRaySlider = true
        setXRayFromX(XRaySlider, input.Position.X)
    end
end)

UIS.InputChanged:Connect(function(input)
    if draggingXRaySlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        setXRayFromX(XRaySlider, input.Position.X)
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingXRaySlider = false
    end
end)

updateXRayVisuals()

-- ===== ФОНОВЫЕ ОБНОВЛЕНИЯ =====
Players.PlayerAdded:Connect(function(plr)
    if pingEnabled and plr ~= Player then watchPlayerCharacter(plr) end
    if hitboxPlayersEnabled then task.wait(0.5); refreshPlayerBoxes() end
    if xrayPlayersEnabled then task.wait(0.5); refreshXrayPlayers() end
end)
Players.PlayerRemoving:Connect(function(plr)
    local pb = playerBoxes[plr]
    if pb and pb.folder then pb.folder:Destroy() end
    playerBoxes[plr] = nil
    local hl = xrayPlayerHighlights[plr]
    if hl then hl:Destroy() end
    xrayPlayerHighlights[plr] = nil
    removePingTag(plr)
    unwatchPlayerCharacter(plr)
    espPlayerConns[plr] = nil
end)
Player.CharacterAdded:Connect(function()
    task.wait(0.5)
    if pingEnabled then refreshPingTags() end
    if hitboxPlayersEnabled then refreshPlayerBoxes() end
    if xrayPlayersEnabled then refreshXrayPlayers() end
end)

RunService.RenderStepped:Connect(function()
    if hitboxPlayersEnabled then updatePlayerBoxes() end
    if hitboxNpcEnabled then updateNpcBoxes() end
    if hitboxObjectEnabled then
        processQueue()
        updateObjectBoxes()
    end
end)

task.spawn(function()
    while true do
        task.wait(1)
        if pingEnabled then refreshPingTags() end
        if hitboxPlayersEnabled then refreshPlayerBoxes() end
        if hitboxNpcEnabled then refreshNpcBoxes() end
        if xrayPlayersEnabled then refreshXrayPlayers() end
        if xrayNpcEnabled then refreshXrayNpcs() end
        if hitboxObjectEnabled then
            scanForMissing()
            cleanupFarObjects()
        end
    end
end)
