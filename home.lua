-- home.lua
local page = getgenv().FCS.pages["Home"]
if not page then return end
local Players = game:GetService("Players")
local Player = Players.LocalPlayer

local InfoFrame = Instance.new("Frame")
InfoFrame.Name = "UserInfo"
InfoFrame.Position = UDim2.new(0, 7, 0, 7)
InfoFrame.Size = UDim2.new(1, -14, 0, 250)
InfoFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
InfoFrame.BorderSizePixel = 0
InfoFrame.Parent = page

local InfoCorner = Instance.new("UICorner")
InfoCorner.CornerRadius = UDim.new(0, 4)
InfoCorner.Parent = InfoFrame

local InfoPadding = Instance.new("UIPadding")
InfoPadding.PaddingTop = UDim.new(0, 6)
InfoPadding.PaddingLeft = UDim.new(0, 8)
InfoPadding.PaddingRight = UDim.new(0, 8)
InfoPadding.Parent = InfoFrame

local InfoLayout = Instance.new("UIListLayout")
InfoLayout.Padding = UDim.new(0, 4)
InfoLayout.SortOrder = Enum.SortOrder.LayoutOrder
InfoLayout.Parent = InfoFrame

local HeaderRow = Instance.new("Frame")
HeaderRow.Size = UDim2.new(1, 0, 0, 44)
HeaderRow.BackgroundTransparency = 1
HeaderRow.LayoutOrder = 1
HeaderRow.Parent = InfoFrame

local AvatarFrame = Instance.new("Frame")
AvatarFrame.Size = UDim2.fromOffset(40, 40)
AvatarFrame.Position = UDim2.new(0, 0, 0, 0)
AvatarFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
AvatarFrame.BorderSizePixel = 0
AvatarFrame.Parent = HeaderRow

local AvatarCorner = Instance.new("UICorner")
AvatarCorner.CornerRadius = UDim.new(1, 0)
AvatarCorner.Parent = AvatarFrame

local AvatarStroke = Instance.new("UIStroke")
AvatarStroke.Color = Color3.fromRGB(255, 0, 0)
AvatarStroke.Thickness = 1.2
AvatarStroke.Parent = AvatarFrame

local AvatarImage = Instance.new("ImageLabel")
AvatarImage.Size = UDim2.new(1, -2, 1, -2)
AvatarImage.Position = UDim2.new(0, 1, 0, 1)
AvatarImage.BackgroundTransparency = 1
AvatarImage.Image = ""
AvatarImage.ScaleType = Enum.ScaleType.Crop
AvatarImage.Parent = AvatarFrame

local AvatarImageCorner = Instance.new("UICorner")
AvatarImageCorner.CornerRadius = UDim.new(1, 0)
AvatarImageCorner.Parent = AvatarImage

local Header = Instance.new("TextLabel")
Header.Size = UDim2.new(1, -48, 1, 0)
Header.Position = UDim2.new(0, 48, 0, 0)
Header.BackgroundTransparency = 1
Header.Text = "USER INFO"
Header.TextColor3 = Color3.fromRGB(255, 0, 0)
Header.Font = Enum.Font.SourceSansBold
Header.TextSize = 12
Header.TextXAlignment = Enum.TextXAlignment.Left
Header.TextYAlignment = Enum.TextYAlignment.Center
Header.Parent = HeaderRow

local function loadAvatar(userId)
    local url = string.format(
        "https://www.roblox.com/headshot-thumbnail/image?userId=%d&width=150&height=150&format=png",
        userId
    )
    AvatarImage.Image = url
end

loadAvatar(Player.UserId)

local function makeStatRow(order, labelText)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 20)
    row.BackgroundTransparency = 1
    row.LayoutOrder = order
    row.Parent = InfoFrame

    local key = Instance.new("TextLabel")
    key.Size = UDim2.new(0.5, 0, 1, 0)
    key.BackgroundTransparency = 1
    key.Text = labelText
    key.TextColor3 = Color3.fromRGB(160, 160, 160)
    key.Font = Enum.Font.SourceSans
    key.TextSize = 11
    key.TextXAlignment = Enum.TextXAlignment.Left
    key.Parent = row

    local value = Instance.new("TextLabel")
    value.Size = UDim2.new(0.5, 0, 1, 0)
    value.Position = UDim2.new(0.5, 0, 0, 0)
    value.BackgroundTransparency = 1
    value.Text = "..."
    value.TextColor3 = Color3.fromRGB(255, 255, 255)
    value.Font = Enum.Font.SourceSansBold
    value.TextSize = 11
    value.TextXAlignment = Enum.TextXAlignment.Right
    value.TextTruncate = Enum.TextTruncate.AtEnd
    value.Parent = row

    return value
end

local IdValue         = makeStatRow(2, "User ID")
local PlaceIdValue    = makeStatRow(3, "Place ID")
local DisplayValue    = makeStatRow(4, "Display Name")
local UsernameValue   = makeStatRow(5, "Username")
local AccountAgeValue = makeStatRow(6, "Account Age")
local CreatedValue    = makeStatRow(7, "Created")

IdValue.Text       = tostring(Player.UserId)
DisplayValue.Text  = Player.DisplayName
UsernameValue.Text = "@" .. Player.Name

local function updatePlaceId()
    local ok, id = pcall(function() return game.PlaceId end)
    PlaceIdValue.Text = ok and tostring(id) or "n/a"
end
updatePlaceId()

local function fetchAccountInfo()
    local ok, created = pcall(function() return Player.AccountAge end)
    if ok and created then
        local days = created
        local years = math.floor(days / 365)
        local months = math.floor((days % 365) / 30)
        AccountAgeValue.Text = string.format("%d d (%dy %dm)", days, years, months)

        local now = os.time()
        local reg = now - days * 86400
        CreatedValue.Text = os.date("%d.%m.%Y", reg)
    else
        AccountAgeValue.Text = "n/a"
        CreatedValue.Text = "n/a"
    end
end

task.spawn(fetchAccountInfo)

Player.CharacterAdded:Connect(function()
    IdValue.Text       = tostring(Player.UserId)
    DisplayValue.Text  = Player.DisplayName
    UsernameValue.Text = "@" .. Player.Name
    updatePlaceId()
end)
