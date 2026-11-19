-- tabl.lua (Окно + Вкладки + Ключ (без ID) + Stats + Загрузка файлов)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local StarterGui = game:GetService("StarterGui")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local UIS = UserInputService
local Player = Players.LocalPlayer

getgenv().FCS = getgenv().FCS or {}
local FCS = getgenv().FCS
FCS.Unlocked = false
FCS.pages = {}

local function getGuiParent()
    local ok, parent = pcall(function() return CoreGui end)
    if ok and parent then return parent end
    return Player:WaitForChild("PlayerGui")
end

local function Message(t, x, d) pcall(function() StarterGui:SetCore("SendNotification", {Title=t, Text=x, Duration=d}) end) end

-- =========================================================
-- ОКНО
-- =========================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ID:???????"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = getGuiParent()
FCS.ScreenGui = ScreenGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 315, 0, 286)
MainFrame.Position = UDim2.new(0.5, -157, 0.5, -143)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = false
MainFrame.Parent = ScreenGui

local MainFrameStroke = Instance.new("UIStroke")
MainFrameStroke.Color = Color3.fromRGB(255, 0, 0)
MainFrameStroke.Thickness = 1.2
MainFrameStroke.Parent = MainFrame

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 21)
TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
TitleBar.BorderSizePixel = 0
TitleBar.ZIndex = 5
TitleBar.Parent = MainFrame
local TitleBarCorner = Instance.new("UICorner"); TitleBarCorner.CornerRadius = UDim.new(0, 4); TitleBarCorner.Parent = TitleBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -26, 1, 0)
Title.BackgroundTransparency = 1
Title.Text = "FCS | commit a3f9c2e | Game: TSB"
Title.TextColor3 = Color3.fromRGB(255, 0, 0)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 11
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Position = UDim2.new(0, 7, 0, 0)
Title.ZIndex = 6
Title.Parent = TitleBar

local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Position = UDim2.new(1, -21, 0, 0)
MinimizeButton.Size = UDim2.fromOffset(21, 21)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
MinimizeButton.BorderSizePixel = 0
MinimizeButton.Text = "-"
MinimizeButton.TextColor3 = Color3.new(1, 1, 1)
MinimizeButton.Font = Enum.Font.SourceSansBold
MinimizeButton.TextSize = 15
MinimizeButton.ZIndex = 6
MinimizeButton.Parent = TitleBar

local draggingWindow = false
local dragStart, startPos
TitleBar.InputBegan:Connect(function(input)
    if not FCS.Unlocked then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingWindow = true; dragStart = input.Position; startPos = MainFrame.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if not FCS.Unlocked then return end
    if draggingWindow and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then draggingWindow = false end
end)

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.fromOffset(105, 265)
Sidebar.Position = UDim2.fromOffset(0, 21)
Sidebar.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
Sidebar.BorderSizePixel = 0
Sidebar.ZIndex = 3
Sidebar.Parent = MainFrame

local SidebarLayout = Instance.new("UIListLayout")
SidebarLayout.Padding = UDim.new(0, 4)
SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
SidebarLayout.Parent = Sidebar
local SidebarPadding = Instance.new("UIPadding")
SidebarPadding.PaddingTop = UDim.new(0, 6)
SidebarPadding.PaddingLeft = UDim.new(0, 6)
SidebarPadding.PaddingRight = UDim.new(0, 6)
SidebarPadding.Parent = Sidebar

local PagesHolder = Instance.new("Frame")
PagesHolder.Size = UDim2.fromOffset(210, 265)
PagesHolder.Position = UDim2.fromOffset(105, 21)
PagesHolder.BackgroundTransparency = 1
PagesHolder.BorderSizePixel = 0
PagesHolder.ZIndex = 2
PagesHolder.Parent = MainFrame

local tabButtons = {}

local function registerPage(name)
    local page = Instance.new("Frame")
    page.Name = name .. "Page"
    page.Size = UDim2.fromOffset(210, 265)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.Visible = false
    page.ZIndex = 2
    page.Parent = PagesHolder
    FCS.pages[name] = page
    return page
end

local function showPage(name)
    for n, p in pairs(FCS.pages) do p.Visible = (n == name) end
    for n, b in pairs(tabButtons) do b.BackgroundColor3 = (n == name) and Color3.fromRGB(80, 0, 0) or Color3.fromRGB(45, 45, 45) end
end
FCS.showPage = showPage

local function makeTab(name, order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 26)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    btn.BorderSizePixel = 0
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 12
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.LayoutOrder = order
    btn.ZIndex = 4
    btn.AutoButtonColor = false
    btn.Parent = Sidebar
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 4); c.Parent = btn
    local pad = Instance.new("UIPadding"); pad.PaddingLeft = UDim.new(0, 8); pad.Parent = btn
    btn.MouseButton1Click:Connect(function() if FCS.Unlocked then showPage(name) end end)
    tabButtons[name] = btn
end

registerPage("Home"); registerPage("Movement"); registerPage("PVP"); registerPage("Hitbox"); registerPage("HP"); registerPage("Telepots"); registerPage("Settings")
makeTab("Home", 1); makeTab("Movement", 2); makeTab("PVP", 3); makeTab("Hitbox", 4); makeTab("HP", 5); makeTab("Telepots", 6); makeTab("Settings", 7)

local minimized = false
local function toggleMinimize()
    if not FCS.Unlocked then return end
    minimized = not minimized
    MainFrame.Size = UDim2.fromOffset(315, minimized and 21 or 286)
    MinimizeButton.Text = minimized and "+" or "-"
    Sidebar.Visible = not minimized
    PagesHolder.Visible = not minimized
end

MinimizeButton.MouseButton1Click:Connect(toggleMinimize)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.CapsLock then
        toggleMinimize()
    end
end)

-- =========================================================
-- СИСТЕМА КЛЮЧА (БЕЗ ПРОВЕРКИ ID)
-- =========================================================
local LockOverlay = Instance.new("Frame")
LockOverlay.Name = "LockOverlay"
LockOverlay.Size = UDim2.new(1, 0, 1, 0)
LockOverlay.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
LockOverlay.BackgroundTransparency = 0.05
LockOverlay.BorderSizePixel = 0
LockOverlay.ZIndex = 10
LockOverlay.Active = true
LockOverlay.Parent = MainFrame

local lockTitle = Instance.new("TextLabel")
lockTitle.Size = UDim2.new(1, -14, 0, 20)
lockTitle.Position = UDim2.new(0, 7, 0, 16)
lockTitle.BackgroundTransparency = 1
lockTitle.Text = "ВВЕДИТЕ КЛЮЧ ДЛЯ ЗАПУСКА"
lockTitle.TextColor3 = Color3.fromRGB(255, 0, 0)
lockTitle.Font = Enum.Font.SourceSansBold
lockTitle.TextSize = 14
lockTitle.ZIndex = 11
lockTitle.Parent = LockOverlay

local KeyInput = Instance.new("TextBox")
KeyInput.Size = UDim2.new(1, -14, 0, 28)
KeyInput.Position = UDim2.new(0, 7, 0, 50)
KeyInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
KeyInput.Text = ""
KeyInput.PlaceholderText = "Введите ключ..."
KeyInput.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyInput.Font = Enum.Font.SourceSans
KeyInput.TextSize = 13
KeyInput.ClearTextOnFocus = false
KeyInput.ZIndex = 11
KeyInput.Parent = LockOverlay
local kc = Instance.new("UICorner"); kc.CornerRadius = UDim.new(0, 4); kc.Parent = KeyInput

local UnlockButton = Instance.new("TextButton")
UnlockButton.Size = UDim2.new(1, -14, 0, 30)
UnlockButton.Position = UDim2.new(0, 7, 0, 88)
UnlockButton.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
UnlockButton.Text = "ПОДТВЕРДИТЬ"
UnlockButton.TextColor3 = Color3.fromRGB(255, 255, 255)
UnlockButton.Font = Enum.Font.SourceSansBold
UnlockButton.TextSize = 13
UnlockButton.ZIndex = 11
UnlockButton.Parent = LockOverlay
local bc = Instance.new("UICorner"); bc.CornerRadius = UDim.new(0, 4); bc.Parent = UnlockButton

local KeyStatus = Instance.new("TextLabel")
KeyStatus.Size = UDim2.new(1, -14, 0, 18)
KeyStatus.Position = UDim2.new(0, 7, 0, 126)
KeyStatus.BackgroundTransparency = 1
KeyStatus.Text = "Введите ключ для доступа"
KeyStatus.TextColor3 = Color3.fromRGB(200, 200, 200)
KeyStatus.Font = Enum.Font.SourceSans
KeyStatus.TextSize = 11
KeyStatus.ZIndex = 11
KeyStatus.Parent = LockOverlay

task.wait(0.1)
KeyInput:ReleaseFocus()

-- =========================================================
-- ССЫЛКИ НА ФАЙЛЫ
-- =========================================================
local files = {
    Home = "https://raw.githubusercontent.com/hizolon/test/refs/heads/main/home.lua",
    Movement = "https://raw.githubusercontent.com/hizolon/test/refs/heads/main/movement.lua",
    PVP = "https://raw.githubusercontent.com/hizolon/test/refs/heads/main/pvp.lua",
    Hitbox = "https://raw.githubusercontent.com/hizolon/test/refs/heads/main/hitbox.lua",
    HP = "https://raw.githubusercontent.com/hizolon/test/refs/heads/main/hp.lua",
    Telepots = "https://raw.githubusercontent.com/hizolon/test/refs/heads/main/telepots.lua",
    Settings = "https://raw.githubusercontent.com/hizolon/test/refs/heads/main/settings.lua"
}

local function loadTab(name)
    local url = files[name]
    if not url then return end
    task.spawn(function()
        local success, code = pcall(game.HttpGet, game, url)
        if success and code then
            local func, err = loadstring(code, name)
            if func then
                local ok, err2 = pcall(func)
                if not ok then warn("[FCS] Ошибка выполнения " .. name .. ": " .. tostring(err2)) end
            else
                warn("[FCS] Ошибка компиляции " .. name .. ": " .. tostring(err))
            end
        else
            warn("[FCS] Не удалось скачать " .. name)
        end
    end)
end

UnlockButton.MouseButton1Click:Connect(function()
    KeyStatus.Text = "Ключ для доступа"
    KeyStatus.TextColor3 = Color3.fromRGB(200, 200, 200)

    if KeyInput.Text == "ABC" then
        FCS.Unlocked = true
        KeyStatus.Text = "Скрипт разблокирован! ;3"
        KeyStatus.TextColor3 = Color3.fromRGB(0, 255, 0)
        KeyInput.Visible = false
        UnlockButton.Visible = false
        task.wait(0.4)
        if LockOverlay then LockOverlay:Destroy(); LockOverlay = nil end

        MainFrame.Active = true
        showPage("Home")
        Message("Скрипт успешно разблокирован :D", "Нихуя ты молодец", 5)
        for name, _ in pairs(files) do loadTab(name) end
    else
        KeyStatus.Text = "Неверный ключ!"
        KeyStatus.TextColor3 = Color3.fromRGB(255, 80, 80)
        Message("НЕВЕРНЫЙ КЛЮЧ", ">_<", 5)
    end
end)

KeyInput:GetPropertyChangedSignal("Text"):Connect(function()
    if not FCS.Unlocked then
        KeyStatus.Text = "Ключ для доступа"
        KeyStatus.TextColor3 = Color3.fromRGB(200, 200, 200)
    end
end)

-- =========================================================
-- STATS
-- =========================================================
local function startStatsGui()
    local W, H, SP, Y = 64, 24, 6, 10
    local guiParent = Player:WaitForChild("PlayerGui", 10)
    if not guiParent then return end
    local old = guiParent:FindFirstChild("ServerStatsGUI")
    if old then old:Destroy() end
    local StatsScreenGui = Instance.new("ScreenGui")
    StatsScreenGui.Name = "ServerStatsGUI"
    StatsScreenGui.ResetOnSpawn = false
    StatsScreenGui.IgnoreGuiInset = true
    StatsScreenGui.DisplayOrder = 999
    StatsScreenGui.Parent = guiParent
    local COUNT = 5
    local totalW = COUNT * W + (COUNT - 1) * SP
    local container = Instance.new("Frame")
    container.Name = "StatsRow"
    container.Size = UDim2.fromOffset(totalW, H)
    container.Position = UDim2.new(0.75, 0, 0, Y)
    container.AnchorPoint = Vector2.new(0.5, 0)
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0
    container.Parent = StatsScreenGui
    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, SP)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.Parent = container
    local function makePlate(index)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.fromOffset(W, H)
        frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        frame.BackgroundTransparency = 0.5
        frame.BorderSizePixel = 0
        frame.LayoutOrder = index
        frame.Parent = container
        local corner = Instance.new("UICorner"); corner.CornerRadius = UDim.new(0, 6); corner.Parent = frame
        local label = Instance.new("TextLabel")
        label.Size = UDim2.fromScale(1, 1)
        label.BackgroundTransparency = 1
        label.Text = "..."
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextSize = 12
        label.Font = Enum.Font.SourceSansBold
        label.TextXAlignment = Enum.TextXAlignment.Center
        label.TextYAlignment = Enum.TextYAlignment.Center
        label.Parent = frame
        return label
    end
    local pingLabel = makePlate(1)
    local fpsLabel = makePlate(2)
    local timeLabel = makePlate(3)
    local playersLabel = makePlate(4)
    local creditFrame = Instance.new("Frame")
    creditFrame.Size = UDim2.fromOffset(W, H)
    creditFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    creditFrame.BackgroundTransparency = 0.5
    creditFrame.BorderSizePixel = 0
    creditFrame.LayoutOrder = 5
    creditFrame.Parent = container
    local creditCorner = Instance.new("UICorner"); creditCorner.CornerRadius = UDim.new(0, 6); creditCorner.Parent = creditFrame
    local creditStroke = Instance.new("UIStroke"); creditStroke.Color = Color3.fromRGB(255, 255, 255); creditStroke.Thickness = 1.5; creditStroke.Parent = creditFrame
    local creditLabel = Instance.new("TextLabel")
    creditLabel.Size = UDim2.fromScale(1, 1)
    creditLabel.BackgroundTransparency = 1
    creditLabel.Text = "By: Flarnux"
    creditLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    creditLabel.TextSize = 12
    creditLabel.Font = Enum.Font.SourceSansBold
    creditLabel.TextXAlignment = Enum.TextXAlignment.Center
    creditLabel.TextYAlignment = Enum.TextYAlignment.Center
    creditLabel.Parent = creditFrame
    local startTime = tick(); local fpsFrames = 0; local fpsLast = tick(); local fpsValue = 0; local accum = 0
    RunService.RenderStepped:Connect(function()
        fpsFrames = fpsFrames + 1
        local now = tick()
        if now - fpsLast >= 1 then fpsValue = math.floor(fpsFrames / (now - fpsLast) + 0.5); fpsFrames = 0; fpsLast = now end
    end)
    RunService.Heartbeat:Connect(function(dt)
        accum = accum + dt
        local elapsed = math.floor(tick() - startTime)
        local h = math.floor(elapsed / 3600); local m = math.floor((elapsed % 3600) / 60); local s = elapsed % 60
        timeLabel.Text = string.format("%d:%02d:%02d", h, m, s)
        if accum >= 0.25 then
            accum = 0
            local ping = 0
            local ok, val = pcall(function() return Stats.Network.ServerStatsItem["Data Ping"]:GetValue() end)
            if ok and tonumber(val) then ping = tonumber(val) end
            pingLabel.Text = string.format("%d ms", math.floor(ping + 0.5))
            fpsLabel.Text = string.format("%d FPS", fpsValue)
            local cur = #Players:GetPlayers(); local max = 0
            local okMax, mv = pcall(function() return Players.MaxPlayers end)
            if okMax and type(mv) == "number" and mv > 0 then max = mv end
            playersLabel.Text = max > 0 and string.format("%d/%d plrs", cur, max) or string.format("%d plrs", cur)
        end
    end)
end

startStatsGui()
