-- main.lua
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local UIS = UserInputService
local Workspace = game:GetService("Workspace")
local Player = Players.LocalPlayer

getgenv().FCS = getgenv().FCS or {}
local FCS = getgenv().FCS
FCS.Unlocked = false

local function getGuiParent()
    local ok, parent = pcall(function() return CoreGui end)
    if ok and parent then return parent end
    return Player:WaitForChild("PlayerGui")
end

local function Message(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", { Title = title or "", Text = text or "", Duration = duration or 3 })
    end)
end

-- ===== ОКНО =====
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ID_11979107741"
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

-- ===== ВКЛАДКИ =====
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

local HomePage = registerPage("Home")
local MovementPage = registerPage("Movement")
local PVPPage = registerPage("PVP")
local HPPage = registerPage("HP")
local TelepotsPage = registerPage("Telepots")
local SettingsPage = registerPage("Settings")

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

-- ===== HOME =====
local InfoFrame = Instance.new("Frame")
InfoFrame.Position = UDim2.new(0, 7, 0, 7)
InfoFrame.Size = UDim2.new(1, -14, 0, 250)
InfoFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
InfoFrame.BorderSizePixel = 0
InfoFrame.Parent = HomePage
local InfoCorner = Instance.new("UICorner"); InfoCorner.CornerRadius = UDim.new(0, 4); InfoCorner.Parent = InfoFrame

local function statRow(y, labelText, valueText)
    local row = Instance.new("TextLabel")
    row.Size = UDim2.new(1, -16, 0, 20); row.Position = UDim2.new(0, 8, 0, y)
    row.BackgroundTransparency = 1; row.Text = labelText .. ": " .. valueText
    row.TextColor3 = Color3.fromRGB(200, 200, 200); row.Font = Enum.Font.SourceSans
    row.TextSize = 12; row.TextXAlignment = Enum.TextXAlignment.Left; row.Parent = HomePage
end
statRow(40, "User ID", tostring(Player.UserId))
statRow(62, "Display Name", Player.DisplayName)
statRow(84, "Username", "@" .. Player.Name)
statRow(106, "Place ID", tostring(game.PlaceId))

-- ===== MOVEMENT =====
local MV = { PAD = 7, VAL = 55, STEP = 44 }
local function createSlider(page, order, name, max, def)
    local y = 7 + (order - 1) * MV.STEP
    local btn = Instance.new("TextButton")
    btn.Position, btn.Size = UDim2.new(0, MV.PAD, 0, y), UDim2.new(1, -(MV.PAD * 2 + 6 + MV.VAL), 0, 24)
    btn.BackgroundColor3, btn.Text, btn.TextColor3 = Color3.fromRGB(60, 60, 60), name .. ": OFF", Color3.fromRGB(255, 255, 255)
    btn.Font, btn.TextSize, btn.TextXAlignment, btn.Parent = Enum.Font.SourceSansBold, 12, Enum.TextXAlignment.Left, page
    local bp = Instance.new("UIPadding"); bp.PaddingLeft = UDim.new(0, 8); bp.Parent = btn
    local bc = Instance.new("UICorner"); bc.CornerRadius = UDim.new(0, 4); bc.Parent = btn

    local val = Instance.new("TextLabel")
    val.AnchorPoint, val.Position, val.Size = Vector2.new(1, 0), UDim2.new(1, -MV.PAD, 0, y), UDim2.new(0, MV.VAL, 0, 24)
    val.BackgroundColor3, val.Text, val.TextColor3, val.TextSize = Color3.fromRGB(45, 45, 45), tostring(def), Color3.fromRGB(255, 255, 255), 12
    val.Font, val.Parent = Enum.Font.SourceSansBold, page
    local vc = Instance.new("UICorner"); vc.CornerRadius = UDim.new(0, 4); vc.Parent = val

    local slider = Instance.new("Frame")
    slider.Position, slider.Size, slider.BackgroundColor3, slider.Parent = UDim2.new(0, MV.PAD, 0, y + 30), UDim2.new(1, -(MV.PAD * 2), 0, 8), Color3.fromRGB(55, 55, 55), page
    local sc = Instance.new("UICorner"); sc.CornerRadius = UDim.new(1, 0); sc.Parent = slider

    local fill = Instance.new("Frame")
    fill.Size, fill.BackgroundColor3, fill.Parent = UDim2.new(def / max, 0, 1, 0), Color3.fromRGB(255, 0, 0), slider
    local fc = Instance.new("UICorner"); fc.CornerRadius = UDim.new(1, 0); fc.Parent = fill

    local knob = Instance.new("Frame")
    knob.Size, knob.Position, knob.BackgroundColor3, knob.ZIndex, knob.Parent = UDim2.fromOffset(14, 14), UDim2.new(def / max, -7, 0.5, -7), Color3.fromRGB(255, 255, 255), 2, slider
    local kc = Instance.new("UICorner"); kc.CornerRadius = UDim.new(1, 0); kc.Parent = knob

    local state = { enabled = false, value = def, max = max }
    local dragging = false
    local function update(x)
        local alpha = math.clamp((x - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
        state.value = math.floor(alpha * max + 0.5)
        fill.Size = UDim2.new(alpha, 0, 1, 0)
        knob.Position = UDim2.new(alpha, -7, 0.5, -7)
        val.Text = tostring(state.value)
        if state.onChanged then state.onChanged(state.value) end
    end
    slider.InputBegan:Connect(function(input)
        if not FCS.Unlocked then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true; update(input.Position.X) end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then update(input.Position.X) end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
    btn.MouseButton1Click:Connect(function()
        if not FCS.Unlocked then return end
        state.enabled = not state.enabled
        btn.Text = name .. ": " .. (state.enabled and "ON" or "OFF")
        btn.BackgroundColor3 = state.enabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(60, 60, 60)
        if state.onChanged then state.onChanged(state.value) end
    end)
    return state
end

local walk = createSlider(MovementPage, 1, "Speed", 300, 16)
local cfrm = createSlider(MovementPage, 2, "CFrame Speed", 500, 0)
local jump = createSlider(MovementPage, 3, "Jump", 400, 50)
local hip  = createSlider(MovementPage, 4, "Hip Height", 500, 2)
local fov  = createSlider(MovementPage, 5, "Camera FOV", 120, 80)

RunService.Heartbeat:Connect(function()
    local hum = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        if walk.enabled and hum.WalkSpeed ~= walk.value then hum.WalkSpeed = walk.value end
        if hip.enabled and hum.HipHeight ~= hip.value then hum.HipHeight = hip.value end
        if fov.enabled and Workspace.CurrentCamera.FieldOfView ~= fov.value then Workspace.CurrentCamera.FieldOfView = fov.value end
    end
end)

-- ===== PVP =====
local Pvp = { cube = nil, enabled = false }
local function pvpBtn(y, name, onClick)
    local b = Instance.new("TextButton")
    b.Position, b.Size = UDim2.new(0, 7, 0, y), UDim2.new(1, -14, 0, 28)
    b.BackgroundColor3, b.Text, b.TextColor3 = Color3.fromRGB(60, 60, 60), name .. ": OFF", Color3.fromRGB(255, 255, 255)
    b.Font, b.TextSize, b.TextXAlignment, b.Parent = Enum.Font.SourceSansBold, 12, Enum.TextXAlignment.Left, PVPPage
    local p = Instance.new("UIPadding"); p.PaddingLeft = UDim.new(0, 8); p.Parent = b
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 4); c.Parent = b
    local state = false
    b.MouseButton1Click:Connect(function()
        if not FCS.Unlocked then return end
        state = not state
        b.Text = name .. ": " .. (state and "ON" or "OFF")
        b.BackgroundColor3 = state and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(60, 60, 60)
        if onClick then onClick(state) end
    end)
end

pvpBtn(7, "Tp player kill", function(s)
    Pvp.enabled = s
    if s then
        Pvp.cube = Instance.new("Part")
        Pvp.cube.Size, Pvp.cube.Anchored, Pvp.cube.CanCollide, Pvp.cube.Transparency, Pvp.cube.Parent = Vector3.new(10,10,10), true, false, 0.5, Workspace
    else
        if Pvp.cube then Pvp.cube:Destroy(); Pvp.cube = nil end
    end
end)

pvpBtn(40, "Invisibility", function(s)
    if s then
        Pvp.invis = RunService.Heartbeat:Connect(function()
            local char = Player.Character
            if char then for _, v in ipairs(char:GetDescendants()) do
                if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then v.LocalTransparencyModifier = 1 end
            end end
        end)
    else
        if Pvp.invis then Pvp.invis:Disconnect(); Pvp.invis = nil end
    end
end)

-- ===== КЛЮЧ =====
local LockOverlay = Instance.new("Frame")
LockOverlay.Size = UDim2.new(1, 0, 1, 0)
LockOverlay.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
LockOverlay.BackgroundTransparency = 0.05
LockOverlay.ZIndex = 10
LockOverlay.Parent = MainFrame

local lockTitle = Instance.new("TextLabel")
lockTitle.Size, lockTitle.Position, lockTitle.BackgroundTransparency = UDim2.new(1, -14, 0, 20), UDim2.new(0, 7, 0, 16), 1
lockTitle.Text, lockTitle.TextColor3, lockTitle.Font, lockTitle.TextSize = "ВВЕДИТЕ КЛЮЧ", Color3.fromRGB(255, 0, 0), Enum.Font.SourceSansBold, 14
lockTitle.ZIndex, lockTitle.Parent = 11, LockOverlay

local KeyInput = Instance.new("TextBox")
KeyInput.Size, KeyInput.Position = UDim2.new(1, -14, 0, 28), UDim2.new(0, 7, 0, 50)
KeyInput.BackgroundColor3, KeyInput.PlaceholderText, KeyInput.TextColor3 = Color3.fromRGB(40, 40, 40), "Введите ключ...", Color3.fromRGB(255, 255, 255)
KeyInput.Font, KeyInput.TextSize, KeyInput.ZIndex, KeyInput.Parent = Enum.Font.SourceSans, 13, 11, LockOverlay
local kc = Instance.new("UICorner"); kc.CornerRadius = UDim.new(0, 4); kc.Parent = KeyInput

local UnlockButton = Instance.new("TextButton")
UnlockButton.Size, UnlockButton.Position = UDim2.new(1, -14, 0, 30), UDim2.new(0, 7, 0, 88)
UnlockButton.BackgroundColor3, UnlockButton.Text, UnlockButton.TextColor3 = Color3.fromRGB(0, 180, 0), "ПОДТВЕРДИТЬ", Color3.fromRGB(255, 255, 255)
UnlockButton.Font, UnlockButton.TextSize, UnlockButton.ZIndex, UnlockButton.Parent = Enum.Font.SourceSansBold, 13, 11, LockOverlay
local bc = Instance.new("UICorner"); bc.CornerRadius = UDim.new(0, 4); bc.Parent = UnlockButton

UnlockButton.MouseButton1Click:Connect(function()
    if KeyInput.Text == "ABC" then
        FCS.Unlocked = true
        KeyInput.Visible, UnlockButton.Visible = false, false
        LockOverlay:Destroy()
        MainFrame.Active = true
        showPage("Home")
        Message("Успешно", "Меню разблокировано", 3)
    else
        Message("Неверный ключ", "Попробуй ABC", 3)
    end
end)

showPage("Home")
