-- settings.lua
local page = getgenv().FCS.pages["Settings"]
if not page then return end

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local StarterGui = game:GetService("StarterGui")
local Player = Players.LocalPlayer
local FCS = getgenv().FCS

local function notifySettings(text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", { Title = "Settings", Text = text, Duration = duration or 3 })
    end)
end

local settingsBusy = false
local function withSettingsBusy(fn)
    if settingsBusy then return end
    settingsBusy = true
    local ok, err = pcall(fn)
    if not ok then
        warn("[Server] " .. tostring(err))
        notifySettings("Ошибка: " .. tostring(err), 4)
    end
    task.wait(1.5)
    settingsBusy = false
end

local SCRIPT_SOURCE = [[
loadstring(game:HttpGet("https://твой-хостинг/script.lua"))()
]]

local function queueScriptForNextServer()
    local candidates = {
        function() return queue_on_teleport end,
        function() return queueonteleport end,
        function() return rawget(getfenv(0), "queue_on_teleport") end,
        function() return syn and syn.queue_on_teleport end,
        function() return getgenv and getgenv().queue_on_teleport end,
        function() return getgenv and getgenv().queueonteleport end,
    }
    for i, getter in ipairs(candidates) do
        local ok, fn = pcall(getter)
        if ok and type(fn) == "function" then
            local ok2, err = pcall(fn, SCRIPT_SOURCE)
            if ok2 then
                print("[AutoLoad] очередь установлена через вариант #" .. i)
                return true
            else
                warn("[AutoLoad] вариант #" .. i .. " есть, но вызов упал: " .. tostring(err))
            end
        end
    end
    warn("[AutoLoad] ни один queue_on_teleport не найден")
    return false
end

local function makeSettingsButton(text, y, bgColor)
    local b = Instance.new("TextButton")
    b.Position = UDim2.new(0, 7, 0, y)
    b.Size = UDim2.new(1, -14, 0, 28)
    b.BackgroundColor3 = bgColor or Color3.fromRGB(60, 60, 60)
    b.BorderSizePixel = 0
    b.Text = text
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Font = Enum.Font.SourceSansBold
    b.TextSize = 12
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.Parent = page
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 4)
    c.Parent = b
    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 8)
    pad.Parent = b
    return b
end

local BtnRejoin      = makeSettingsButton("Переподключиться на этот сервер", 7)
local BtnAnother     = makeSettingsButton("Подключиться на другой сервер", 39)
local BtnNoShadows   = makeSettingsButton("No shadows: OFF", 77)
local BtnBrightness  = makeSettingsButton("Full brightness: OFF", 109)
local BtnFpsBoost    = makeSettingsButton("FPS BOOST: OFF", 141)
local BtnCopyDiscord = makeSettingsButton("Copy Discord server", 179)   
local BtnClose       = makeSettingsButton("Закрыть скрипт", 228, Color3.fromRGB(180, 0, 0))
BtnClose.TextXAlignment = Enum.TextXAlignment.Center

local DISCORD_LINK = ".gg/uJxKthGVxU"

BtnCopyDiscord.MouseButton1Click:Connect(function()
    if not FCS.Unlocked then return end
    local ok, err = pcall(function()
        if setclipboard then
            setclipboard(DISCORD_LINK)
        elseif toclipboard then
            toclipboard(DISCORD_LINK)
        elseif syn and syn.setclipboard then
            syn.setclipboard(DISCORD_LINK)
        else
            error("clipboard API не найден")
        end
    end)
    if ok then
        notifySettings("Скопировано: " .. DISCORD_LINK, 3)
    else
        notifySettings("Не удалось скопировать: " .. tostring(err), 4)
    end
end)

local closeConfirmActive = false
local closeConfirmGui = nil

local function destroyCloseConfirm()
    if closeConfirmGui then
        closeConfirmGui:Destroy()
        closeConfirmGui = nil
    end
    closeConfirmActive = false
end

local function doClose()
    destroyCloseConfirm()
    if fpsBoostRunning then stopFpsBoost() end
    if FCS.ScreenGui then FCS.ScreenGui:Destroy() end
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Settings",
            Text = "Скрипт закрыт. Спасибо за использование!",
            Duration = 3,
        })
    end)
    if getgenv and getgenv().stop then pcall(getgenv().stop) end
end

local function requestClose()
    if closeConfirmActive then return end
    if not FCS.Unlocked then return end
    closeConfirmActive = true

    local gui = Instance.new("ScreenGui")
    gui.Name = "CloseConfirm_11979107741"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 9999
    gui.Parent = game:GetService("CoreGui")
    closeConfirmGui = gui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 200, 0, 110)
    frame.Position = UDim2.new(1, -210, 1, -120)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BorderSizePixel = 0
    frame.Parent = gui

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 0, 0)
    stroke.Thickness = 1.2
    stroke.Parent = frame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -14, 0, 20)
    title.Position = UDim2.new(0, 7, 0, 8)
    title.BackgroundTransparency = 1
    title.Text = "Settings"
    title.TextColor3 = Color3.fromRGB(255, 0, 0)
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 13
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = frame

    local msg = Instance.new("TextLabel")
    msg.Size = UDim2.new(1, -14, 0, 30)
    msg.Position = UDim2.new(0, 7, 0, 30)
    msg.BackgroundTransparency = 1
    msg.Text = "Закрыть скрипт?"
    msg.TextColor3 = Color3.fromRGB(255, 255, 255)
    msg.Font = Enum.Font.SourceSans
    msg.TextSize = 13
    msg.TextXAlignment = Enum.TextXAlignment.Left
    msg.TextWrapped = true
    msg.Parent = frame

    local yes = Instance.new("TextButton")
    yes.Size = UDim2.new(0.5, -10, 0, 28)
    yes.Position = UDim2.new(0, 7, 1, -35)
    yes.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    yes.BorderSizePixel = 0
    yes.Text = "Да"
    yes.TextColor3 = Color3.fromRGB(255, 255, 255)
    yes.Font = Enum.Font.SourceSansBold
    yes.TextSize = 12
    yes.Parent = frame
    local yc = Instance.new("UICorner"); yc.CornerRadius = UDim.new(0, 4); yc.Parent = yes

    local no = Instance.new("TextButton")
    no.Size = UDim2.new(0.5, -10, 0, 28)
    no.Position = UDim2.new(0.5, 3, 1, -35)
    no.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
    no.BorderSizePixel = 0
    no.Text = "Нет"
    no.TextColor3 = Color3.fromRGB(255, 255, 255)
    no.Font = Enum.Font.SourceSansBold
    no.TextSize = 12
    no.Parent = frame
    local nc = Instance.new("UICorner"); nc.CornerRadius = UDim.new(0, 4); nc.Parent = no

    yes.MouseButton1Click:Connect(function()
        doClose()
    end)

    no.MouseButton1Click:Connect(function()
        destroyCloseConfirm()
    end)

    task.delay(8, function()
        if closeConfirmGui == gui then
            destroyCloseConfirm()
        end
    end)
end

BtnClose.MouseButton1Click:Connect(requestClose)

BtnRejoin.MouseButton1Click:Connect(function()
    if not FCS.Unlocked then return end
    withSettingsBusy(function()
        local queued = queueScriptForNextServer()
        notifySettings(queued and "Переподключение и авто-загрузка" or "Переподключение без авто-загрузки")
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, Player)
    end)
end)

BtnAnother.MouseButton1Click:Connect(function()
    if not FCS.Unlocked then return end
    withSettingsBusy(function()
        local queued = queueScriptForNextServer()
        notifySettings(queued and "Другой сервер и авто-загрузка" or "Другой сервер без авто-загрузки")
        TeleportService:Teleport(game.PlaceId, Player)
    end)
end)

-- ===== Full brightness =====
local brightnessEnabled = false
local originalLighting = {
    Brightness = Lighting.Brightness,
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    TimeOfDay = Lighting.TimeOfDay,
    FogEnd = Lighting.FogEnd,
    FogStart = Lighting.FogStart,
    GlobalShadows = Lighting.GlobalShadows
}

BtnBrightness.MouseButton1Click:Connect(function()
    if not FCS.Unlocked then return end
    brightnessEnabled = not brightnessEnabled
    if brightnessEnabled then
        BtnBrightness.Text = "Full brightness: ON"
        BtnBrightness.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        Lighting.Brightness = 3
        Lighting.Ambient = Color3.fromRGB(200, 200, 200)
        Lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
        Lighting.TimeOfDay = "12:00:00"
        Lighting.FogEnd = 9e9
        Lighting.FogStart = 0
        Lighting.GlobalShadows = false
        notifySettings("Full brightness: ON", 2)
    else
        BtnBrightness.Text = "Full brightness: OFF"
        BtnBrightness.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        Lighting.Brightness = originalLighting.Brightness
        Lighting.Ambient = originalLighting.Ambient
        Lighting.OutdoorAmbient = originalLighting.OutdoorAmbient
        Lighting.TimeOfDay = originalLighting.TimeOfDay
        Lighting.FogEnd = originalLighting.FogEnd
        Lighting.FogStart = originalLighting.FogStart
        Lighting.GlobalShadows = originalLighting.GlobalShadows
        notifySettings("Full brightness: OFF", 2)
    end
end)

-- ===== No shadows =====
local noShadowsEnabled = false
local shadowsOriginal = {
    GlobalShadows = Lighting.GlobalShadows,
    ShadowSoftness = Lighting.ShadowSoftness,
    FogEnd = Lighting.FogEnd,
}

local function enableNoShadows()
    if noShadowsEnabled then return end
    noShadowsEnabled = true
    Lighting.GlobalShadows = false
    Lighting.ShadowSoftness = 0
    Lighting.FogEnd = 9e9
    notifySettings("No shadows: ON", 2)
end

local function disableNoShadows()
    if not noShadowsEnabled then return end
    noShadowsEnabled = false
    Lighting.GlobalShadows = shadowsOriginal.GlobalShadows
    Lighting.ShadowSoftness = shadowsOriginal.ShadowSoftness
    Lighting.FogEnd = shadowsOriginal.FogEnd
    notifySettings("No shadows: OFF", 2)
end

BtnNoShadows.MouseButton1Click:Connect(function()
    if not FCS.Unlocked then return end
    if noShadowsEnabled then
        disableNoShadows()
        BtnNoShadows.Text = "No shadows: OFF"
        BtnNoShadows.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    else
        enableNoShadows()
        BtnNoShadows.Text = "No shadows: ON"
        BtnNoShadows.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    end
end)

local OPT = {
    Players = { ["Ignore Me"] = true, ["Ignore Others"] = true, ["Ignore Tools"] = true },
    Meshes = { NoMesh = false, NoTexture = false, Destroy = false },
    Images = { Invisible = true, Destroy = false },
    Explosions = { Smaller = true, Invisible = false, Destroy = false },
    Particles = { Invisible = true, Destroy = false },
    TextLabels = { LowerQuality = false, Invisible = false, Destroy = false },
    MeshParts = { LowerQuality = true, Invisible = false, NoTexture = false, NoMesh = false, Destroy = false },
    Other = {
        ["FPS Cap"] = true,
        ["No Camera Effects"] = true,
        ["No Clothes"] = true,
        ["Low Water Graphics"] = true,
        ["Low Rendering"] = true,
        ["Low Quality Parts"] = true,
        ["Low Quality Models"] = true,
        ["Lower Quality MeshParts"] = true,
    },
}

local fpsBoostRunning = false
local fpsAddedConn = nil

local originals = {
    parts = {},
    meshparts = {},
    particles = {},
    textlabels = {},
    models = {},
    faceinstances = {},
    shirtgraphics = {},
    explosions = {},
    rendering = {
        QualityLevel = settings().Rendering.QualityLevel,
        MeshPartDetailLevel = settings().Rendering.MeshPartDetailLevel,
    },
    water = nil,
}

local function isPlayerCharacter(inst)
    for _, v in ipairs(Players:GetPlayers()) do
        if v.Character and inst:IsDescendantOf(v.Character) then
            return true
        end
    end
    return false
end

local function applyToInstance(inst)
    if not inst or not inst.Parent then return end
    if inst:IsDescendantOf(Players) then return end
    if isPlayerCharacter(inst) then return end

    if inst:IsA("BasePart") and not inst:IsA("MeshPart") then
        if OPT.Other["Low Quality Parts"] then
            if not originals.parts[inst] then
                originals.parts[inst] = { Material = inst.Material, Reflectance = inst.Reflectance }
            end
            inst.Material = Enum.Material.Plastic
            inst.Reflectance = 0
        end
    elseif inst:IsA("MeshPart") then
        if not originals.meshparts[inst] then
            originals.meshparts[inst] = {
                RenderFidelity = inst.RenderFidelity,
                Reflectance = inst.Reflectance,
                Material = inst.Material,
                Transparency = inst.Transparency,
                TextureID = inst.TextureID,
                MeshId = inst.MeshId,
            }
        end
        if OPT.MeshParts.LowerQuality then
            inst.RenderFidelity = 2
            inst.Reflectance = 0
            inst.Material = Enum.Material.Plastic
        end
        if OPT.MeshParts.NoTexture then inst.TextureID = "" end
        if OPT.MeshParts.NoMesh then inst.MeshId = "" end
    elseif inst:IsA("ParticleEmitter") or inst:IsA("Trail") or inst:IsA("Smoke")
        or inst:IsA("Fire") or inst:IsA("Sparkles") then
        if not originals.particles[inst] then
            originals.particles[inst] = { Enabled = inst.Enabled }
        end
        if OPT.Particles.Invisible then inst.Enabled = false end
    elseif inst:IsA("TextLabel") and inst:IsDescendantOf(workspace) then
        if not originals.textlabels[inst] then
            originals.textlabels[inst] = {
                Font = inst.Font,
                TextScaled = inst.TextScaled,
                RichText = inst.RichText,
                TextSize = inst.TextSize,
                Visible = inst.Visible,
            }
        end
        if OPT.TextLabels.LowerQuality then
            inst.Font = Enum.Font.SourceSans
            inst.TextScaled = false
            inst.RichText = false
            inst.TextSize = 14
        end
    elseif inst:IsA("Model") then
        if not originals.models[inst] then
            originals.models[inst] = { LevelOfDetail = inst.LevelOfDetail }
        end
        if OPT.Other["Low Quality Models"] then inst.LevelOfDetail = 1 end
    elseif inst:IsA("PostEffect") then
        if OPT.Other["No Camera Effects"] then inst.Enabled = false end
    elseif inst:IsA("Explosion") then
        if not originals.explosions[inst] then
            originals.explosions[inst] = {
                BlastPressure = inst.BlastPressure,
                BlastRadius = inst.BlastRadius,
                Visible = inst.Visible,
            }
        end
        if OPT.Explosions.Smaller then
            inst.BlastPressure = 1
            inst.BlastRadius = 1
        end
        if OPT.Explosions.Invisible then
            inst.BlastPressure = 1
            inst.BlastRadius = 1
            inst.Visible = false
        end
    elseif inst:IsA("FaceInstance") then
        if not originals.faceinstances[inst] then
            originals.faceinstances[inst] = { Transparency = inst.Transparency, Shiny = inst.Shiny }
        end
        if OPT.Images.Invisible then
            inst.Transparency = 1
            inst.Shiny = 1
        end
    elseif inst:IsA("ShirtGraphic") then
        if not originals.shirtgraphics[inst] then
            originals.shirtgraphics[inst] = { Graphic = inst.Graphic }
        end
        if OPT.Images.Invisible then inst.Graphic = "" end
    end
end

local function applyRendering()
    if OPT.Other["Low Rendering"] then
        pcall(function()
            settings().Rendering.QualityLevel = 1
            settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level04
        end)
    end
end

local function applyWater()
    if not OPT.Other["Low Water Graphics"] then return end
    local terrain = workspace:FindFirstChildOfClass("Terrain")
    if not terrain then return end
    if not originals.water then
        originals.water = {
            WaterWaveSize = terrain.WaterWaveSize,
            WaterWaveSpeed = terrain.WaterWaveSpeed,
            WaterReflectance = terrain.WaterReflectance,
            WaterTransparency = terrain.WaterTransparency,
        }
    end
    terrain.WaterWaveSize = 0
    terrain.WaterWaveSpeed = 0
    terrain.WaterReflectance = 0
    terrain.WaterTransparency = 0
end

local function applyFpsCap()
    if OPT.Other["FPS Cap"] and setfpscap then
        pcall(setfpscap, 1e6)
    end
end

local function startFpsBoost()
    if fpsBoostRunning then return end
    fpsBoostRunning = true

    applyRendering()
    applyWater()
    applyFpsCap()

    for _, inst in ipairs(game:GetDescendants()) do
        pcall(applyToInstance, inst)
    end

    fpsAddedConn = game.DescendantAdded:Connect(function(inst)
        if fpsBoostRunning then
            pcall(applyToInstance, inst)
        end
    end)

    notifySettings("FPS BOOST: ON", 2)
end

local function stopFpsBoost()
    if not fpsBoostRunning then return end
    fpsBoostRunning = false

    if fpsAddedConn then fpsAddedConn:Disconnect(); fpsAddedConn = nil end

    for inst, o in pairs(originals.parts) do
        pcall(function()
            inst.Material = o.Material
            inst.Reflectance = o.Reflectance
        end)
    end
    originals.parts = {}

    for inst, o in pairs(originals.meshparts) do
        pcall(function()
            inst.RenderFidelity = o.RenderFidelity
            inst.Reflectance = o.Reflectance
            inst.Material = o.Material
            inst.Transparency = o.Transparency
            inst.TextureID = o.TextureID
            inst.MeshId = o.MeshId
        end)
    end
    originals.meshparts = {}

    for inst, o in pairs(originals.particles) do
        pcall(function() inst.Enabled = o.Enabled end)
    end
    originals.particles = {}

    for inst, o in pairs(originals.textlabels) do
        pcall(function()
            inst.Font = o.Font
            inst.TextScaled = o.TextScaled
            inst.RichText = o.RichText
            inst.TextSize = o.TextSize
            inst.Visible = o.Visible
        end)
    end
    originals.textlabels = {}

    for inst, o in pairs(originals.models) do
        pcall(function() inst.LevelOfDetail = o.LevelOfDetail end)
    end
    originals.models = {}

    for inst, o in pairs(originals.faceinstances) do
        pcall(function()
            inst.Transparency = o.Transparency
            inst.Shiny = o.Shiny
        end)
    end
    originals.faceinstances = {}

    for inst, o in pairs(originals.shirtgraphics) do
        pcall(function() inst.Graphic = o.Graphic end)
    end
    originals.shirtgraphics = {}

    for inst, o in pairs(originals.explosions) do
        pcall(function()
            inst.BlastPressure = o.BlastPressure
            inst.BlastRadius = o.BlastRadius
            inst.Visible = o.Visible
        end)
    end
    originals.explosions = {}

    pcall(function()
        settings().Rendering.QualityLevel = originals.rendering.QualityLevel
        settings().Rendering.MeshPartDetailLevel = originals.rendering.MeshPartDetailLevel
    end)

    local terrain = workspace:FindFirstChildOfClass("Terrain")
    if terrain and originals.water then
        terrain.WaterWaveSize = originals.water.WaterWaveSize
        terrain.WaterWaveSpeed = originals.water.WaterWaveSpeed
        terrain.WaterReflectance = originals.water.WaterReflectance
        terrain.WaterTransparency = originals.water.WaterTransparency
    end
    originals.water = nil

    if setfpscap then pcall(setfpscap, 1e6) end

    notifySettings("FPS BOOST: OFF", 2)
end

BtnFpsBoost.MouseButton1Click:Connect(function()
    if not FCS.Unlocked then return end
    if fpsBoostRunning then
        stopFpsBoost()
        BtnFpsBoost.Text = "FPS BOOST: OFF"
        BtnFpsBoost.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    else
        startFpsBoost()
        BtnFpsBoost.Text = "FPS BOOST: ON"
        BtnFpsBoost.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    end
end)
