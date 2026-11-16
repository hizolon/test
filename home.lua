-- home.lua
local page = getgenv().FCS.pages["Home"]
if not page then return end

local Players = game:GetService("Players")
local Player = Players.LocalPlayer

local Info = Instance.new("Frame")
Info.Position = UDim2.new(0,7,0,7); Info.Size = UDim2.new(1,-14,0,250)
Info.BackgroundColor3 = Color3.fromRGB(40,40,40); Info.Parent = page
local C = Instance.new("UICorner"); C.CornerRadius = UDim.new(0,4); C.Parent = Info

local function row(y, txt)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1,-16,0,20); l.Position = UDim2.new(0,8,0,y); l.BackgroundTransparency = 1
    l.Text = txt; l.TextColor3 = Color3.fromRGB(200,200,200); l.Font = Enum.Font.SourceSans
    l.TextSize = 12; l.TextXAlignment = Enum.TextXAlignment.Left; l.Parent = page
end

row(40, "User ID: " .. tostring(Player.UserId))
row(62, "Display Name: " .. Player.DisplayName)
row(84, "Username: @" .. Player.Name)
row(106, "Place ID: " .. tostring(game.PlaceId))
