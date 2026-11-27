-- telepots.lua
local page = getgenv().FCS.pages["Telepots"]
if not page then return end

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local Player = Players.LocalPlayer
local FCS = getgenv().FCS

local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Name = "TeleportScroll"
ScrollFrame.Position = UDim2.new(0, 0, 0, 0)
ScrollFrame.Size = UDim2.new(1, 0, 1, 0)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 4
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(255, 80, 80)
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.ScrollingDirection = Enum.ScrollingDirection.Y
ScrollFrame.Parent = page

local savedTPCFrame = nil

local function makeActionButton(name, order, onClick)
    local btn = Instance.new("TextButton")
    btn.Name = "TP_" .. name
    btn.Position = UDim2.new(0, 7, 0, 7 + (order - 1) * 32)
    btn.Size = UDim2.new(1, -14, 0, 28)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.BorderSizePixel = 0
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 12
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = ScrollFrame

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 8)
    pad.Parent = btn

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = btn

    local busy = false
    btn.MouseButton1Click:Connect(function()
        if not FCS.Unlocked then return end
        if busy then return end
        busy = true
        onClick()
        task.wait(0.3)
        busy = false
    end)

    return btn
end

makeActionButton("Сохранить позицию", 1, function()
    local char = Player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        savedTPCFrame = hrp.CFrame
        local p = hrp.Position
        StarterGui:SetCore("SendNotification", {
            Title = "Позиция сохранена",
            Text = string.format("X: %d  Y: %d  Z: %d", math.floor(p.X), math.floor(p.Y), math.floor(p.Z)),
            Duration = 3,
        })
    end
end)

makeActionButton("Телепорт на сохранённую", 2, function()
    if not savedTPCFrame then
        StarterGui:SetCore("SendNotification", {
            Title = "Нет сохранённой позиции",
            Text = "Сначала нажми «Сохранить позицию»",
            Duration = 3,
        })
        return
    end
    local char = Player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = savedTPCFrame
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        StarterGui:SetCore("SendNotification", {
            Title = "Телепорт выполнен",
            Text = "На сохранённую позицию",
            Duration = 3,
        })
    end
end)

local function makeTeleportButton(name, x, y, z, order)
    local btn = Instance.new("TextButton")
    btn.Name = "TP_" .. name
    btn.Position = UDim2.new(0, 7, 0, 7 + (order - 1) * 32)
    btn.Size = UDim2.new(1, -14, 0, 28)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.BorderSizePixel = 0
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 12
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = ScrollFrame

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 8)
    pad.Parent = btn

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = btn

    local busy = false
    btn.MouseButton1Click:Connect(function()
        if not FCS.Unlocked then return end
        if busy then return end
        busy = true
        local char = Player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = CFrame.new(Vector3.new(x, y, z), hrp.Position + (hrp.CFrame.LookVector * 10))
            StarterGui:SetCore("SendNotification", {
                Title = "Телепорт",
                Text = name,
                Duration = 3,
            })
        end
        task.wait(0.3)
        busy = false
    end)

    return btn
end

local teleports = {
    { "Центр",                      148, 442,  27 },
    { "На гору 1",                  241, 702, 460 },
    { "На гору 2",                 -107, 642, -328 },
    { "На гору 3",                  543, 631, -264 },
    { "Угол карты 1",               461, 442, 225 },
    { "Угол карты 2",               223, 442, -334 },
    { "Угол карты 3",              -163, 442, -177 },
    { "Угол карты 4",                70, 442, 390 },
    { "Коробка смерти",             -92,  30, 20347 },
    { "Крыша коробки смерти",       -92,  80, 20347 },
    { "Платформа (верхняя)",        -46, 1861, 25194 },
    { "Atomic (кругляшке)",         -52, 1586, 25250 },
    { "Платформа (нижняя)",         -52, 1472, 25252 },
    { "Далёкая точка",            10000, 1000, 10000 },
    { "Далёкая точка +Y10000",   10000, 10000, 10000 },
}

for i, data in ipairs(teleports) do
    makeTeleportButton(data[1], data[2], data[3], data[4], i + 2)
end

ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 7 + (2 + #teleports) * 32 + 7)
