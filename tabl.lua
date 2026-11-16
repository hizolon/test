-- main.lua
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local UIS = UserInputService
local Player = Players.LocalPlayer

getgenv().FCS = getgenv().FCS or {}
local FCS = getgenv().FCS
FCS.Unlocked = false

local function getGuiParent()
    local ok, parent = pcall(function() return CoreGui end)
    if ok and parent then return parent end
    return Player:WaitForChild("PlayerGui")
end

local function Message(t, x, d) pcall(function() StarterGui:SetCore("SendNotification", {Title=t, Text=x, Duration=d}) end) end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ID:11979107741"
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
Title.Text = "ID:11979107741 | FCS | Game: TSB"
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

local pages, tabButtons = {}, {}
FCS.pages = pages

local function registerPage(name)
    local page = Instance.new("Frame")
    page.Name = name .. "Page"
    page.Size = UDim2.fromOffset(210, 265)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.Visible = false
    page.ZIndex = 2
    page.Parent = PagesHolder
    pages[name] = page
    return page
end

local function showPage(name)
    for n, p in pairs(pages) do p.Visible = (n == name) end
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

registerPage("Home"); registerPage("Movement"); registerPage("PVP"); registerPage("HP"); registerPage("Telepots"); registerPage("Settings")
makeTab("Home", 1); makeTab("Movement", 2); makeTab("PVP", 3); makeTab("HP", 4); makeTab("Telepots", 5); makeTab("Settings", 6)

local minimized = false
MinimizeButton.MouseButton1Click:Connect(function()
    if not FCS.Unlocked then return end
    minimized = not minimized
    MainFrame.Size = UDim2.fromOffset(315, minimized and 21 or 286)
    MinimizeButton.Text = minimized and "+" or "-"
    Sidebar.Visible = not minimized
    PagesHolder.Visible = not minimized
end)

local Lock = Instance.new("Frame")
Lock.Size = UDim2.new(1,0,1,0); Lock.BackgroundColor3 = Color3.fromRGB(25,25,25); Lock.BackgroundTransparency = 0.05; Lock.ZIndex = 10; Lock.Parent = MainFrame
local LT = Instance.new("TextLabel"); LT.Size = UDim2.new(1,-14,0,20); LT.Position = UDim2.new(0,7,0,16); LT.BackgroundTransparency = 1; LT.Text = "ВВЕДИТЕ КЛЮЧ"; LT.TextColor3 = Color3.fromRGB(255,0,0); LT.Font = Enum.Font.SourceSansBold; LT.ZIndex = 11; LT.Parent = Lock
local Key = Instance.new("TextBox"); Key.Size = UDim2.new(1,-14,0,28); Key.Position = UDim2.new(0,7,0,50); Key.BackgroundColor3 = Color3.fromRGB(40,40,40); Key.PlaceholderText = "Ключ..."; Key.ZIndex = 11; Key.Parent = Lock
local KCorner = Instance.new("UICorner"); KCorner.CornerRadius = UDim.new(0,4); KCorner.Parent = Key
local UnlockBtn = Instance.new("TextButton"); UnlockBtn.Size = UDim2.new(1,-14,0,30); UnlockBtn.Position = UDim2.new(0,7,0,88); UnlockBtn.BackgroundColor3 = Color3.fromRGB(0,180,0); UnlockBtn.Text = "ПОДТВЕРДИТЬ"; UnlockBtn.TextColor3 = Color3.fromRGB(255,255,255); UnlockBtn.ZIndex = 11; UnlockBtn.Parent = Lock
local UCorner = Instance.new("UICorner"); UCorner.CornerRadius = UDim.new(0,4); UCorner.Parent = UnlockBtn

local BASE = "https://raw.githubusercontent.com/ТВОЙ_НИК/fcs-script/main/"
local function loadTab(url, name)
    task.spawn(function()
        local success, code = pcall(game.HttpGet, game, url)
        if success and code then
            local func, err = loadstring(code, name)
            if func then pcall(func) else warn("[FCS] Ошибка компиляции " .. name .. ": " .. tostring(err)) end
        end
    end)
end

UnlockBtn.MouseButton1Click:Connect(function()
    if Key.Text == "ABC" then
        FCS.Unlocked = true
        Key.Visible = false; UnlockBtn.Visible = false; Lock:Destroy()
        MainFrame.Active = true
        showPage("Home")
        Message("Успешно", "Загрузка вкладок...", 3)
        loadTab(BASE .. "home.lua", "Home")
        loadTab(BASE .. "movement.lua", "Movement")
        loadTab(BASE .. "pvp.lua", "PVP")
        loadTab(BASE .. "hp.lua", "HP")
        loadTab(BASE .. "telepots.lua", "Telepots")
        loadTab(BASE .. "settings.lua", "Settings")
    else
        Message("Ошибка", "Неверный ключ", 3)
    end
end)
