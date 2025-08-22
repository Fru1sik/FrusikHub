local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

-- GUI setup
local gui = Instance.new("ScreenGui")
gui.Name = "KuniHubPremiumGUI"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player:WaitForChild("PlayerGui")

-- Main frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 226)
frame.Position = UDim2.new(0.5, -110, 0.5, -113)
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
frame.BackgroundTransparency = 0.1
frame.BorderSizePixel = 0
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

-- Warning message at startup
local warningLabel = Instance.new("TextLabel")
warningLabel.Size = UDim2.new(1, 0, 0, 20)
warningLabel.Position = UDim2.new(0, 0, 0, -24)
warningLabel.BackgroundTransparency = 0.2
warningLabel.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
warningLabel.Text = "вљ GUI is still loading..."
warningLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
warningLabel.Font = Enum.Font.GothamBold
warningLabel.TextSize = 14
warningLabel.Parent = frame
Instance.new("UICorner", warningLabel).CornerRadius = UDim.new(0, 6)

-- Fade out warning after 5 seconds
spawn(function()
    wait(5)
    TweenService:Create(warningLabel, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        TextTransparency = 1,
        BackgroundTransparency = 1
    }):Play()
    wait(0.6)
    warningLabel:Destroy()
end)

-- RGB glow border
local glow = Instance.new("Frame")
glow.Size = UDim2.new(1, 8, 1, 8)
glow.Position = UDim2.new(0, -4, 0, -4)
glow.BackgroundColor3 = Color3.fromHSV(0, 1, 1)
glow.BorderSizePixel = 0
glow.ZIndex = 0
glow.Parent = frame
Instance.new("UICorner", glow).CornerRadius = UDim.new(0, 16)

spawn(function()
    local hue = 0
    while gui.Parent do
        hue = (hue + 0.007) % 1
        glow.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
        wait(0.03)
    end
end)

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -70, 0, 32)
title.Position = UDim2.new(0, 10, 0, 10)
title.BackgroundTransparency = 1
title.Text = "Yawi Library"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBlack
title.TextSize = 22
title.TextStrokeTransparency = 0.6
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

-- Footer
local footer = Instance.new("TextLabel")
footer.Size = UDim2.new(1, 0, 0, 16)
footer.Position = UDim2.new(0, 0, 1, -20)
footer.BackgroundTransparency = 1
footer.Text = "Tiktok: @yawiyawiyawiz1"
footer.TextColor3 = Color3.fromRGB(160, 160, 160)
footer.Font = Enum.Font.Gotham
footer.TextSize = 12
footer.TextXAlignment = Enum.TextXAlignment.Center
footer.Parent = frame

-- Tween helper
local function TweenInOut(obj, goal, duration)
    TweenService:Create(obj, TweenInfo.new(duration or 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), goal):Play()
end

-- Create button (reusable)
local function createButton(parent, posY, text)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 26)
    btn.Position = UDim2.new(0, 0, 0, posY)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 15
    btn.ZIndex = 1
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)

    btn.MouseEnter:Connect(function()
        TweenInOut(btn, {BackgroundTransparency = 0.3}, 0.2)
    end)
    btn.MouseLeave:Connect(function()
        TweenInOut(btn, {BackgroundTransparency = 0}, 0.2)
    end)

    return btn
end

-- Button 1: Dark Spawner
local button1 = createButton(frame, 50, "Run Dark Spawner")
button1.MouseButton1Click:Connect(function()
	button1.Text = "Loading..."
	button1.BackgroundTransparency = 0.5
	local success, err = pcall(function()
		local Spawner = loadstring(game:HttpGet("https://gitlab.com/darkiedarkie/dark/-/raw/main/Spawner.lua"))()
		Spawner.Load()
	end)
	button1.Text = success and "Loaded!" or "Failed!"
	if not success then warn("[Kuni Hub] Error: " .. tostring(err)) end
	wait(2)
	button1.Text = "Run Dark Spawner"
	button1.BackgroundTransparency = 0
end)
-- Button 2
local button2 = createButton(frame, 82, "Run Project Reverse")
button2.MouseButton1Click:Connect(function()
    button2.Text = "Loading..."
    button2.BackgroundTransparency = 0.5
    local success, err = pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/veryimportantrr/x/refs/heads/main/gag_visual.lua", true))("discord.gg/csxu2nCkw9")
    end)
    button2.Text = success and "Loaded!" or "Failed!"
    if not success then warn("[Kuni Hub] Error: "..tostring(err)) end
    wait(2)
    button2.Text = "Run Project Reverse"
    button2.BackgroundTransparency = 0
end)

-- Button 3
local button3 = createButton(frame, 114, "Run Yawi X Hub")
button3.MouseButton1Click:Connect(function()
    button3.Text = "Loading..."
    button3.BackgroundTransparency = 0.5
    local success, err = pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/KuniDevLua/GrowAGarden/refs/heads/main/FullFeaturesObsa"))()
    end)
    button3.Text = success and "Loaded!" or "Failed!"
    if not success then warn("[Kuni Hub] Error: "..tostring(err)) end
    wait(2)
    button3.Text = "Run Yawi X Hub"
    button3.BackgroundTransparency = 0
end)

-- Button 4
local button4 = createButton(frame, 146, "Open Egg Detector")
button4.MouseButton1Click:Connect(function()
    button4.Text = "Loading..."
    button4.BackgroundTransparency = 0.5
    local success, err = pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/KuniDevLua/GrowAGarden/refs/heads/main/EGG%20DETECTOR1"))()
    end)
    button4.Text = success and "Loaded!" or "Failed!"
    if not success then warn("[Kuni Hub] Error: "..tostring(err)) end
    wait(2)
    button4.Text = "Open Egg Detector"
    button4.BackgroundTransparency = 0
end)

-- Button 5: Run Pet Weight Changer
local button5 = createButton(frame, 178, "Run Pet Weight Changer")
button5.MouseButton1Click:Connect(function()
    button5.Text = "Loading..."
    button5.BackgroundTransparency = 0.5
    local success, err = pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/KuniDevLua/GrowAGarden/refs/heads/main/petsizechanger"))()
    end)
    button5.Text = success and "Loaded!" or "Failed!"
    if not success then warn("[Kuni Hub] Error: "..tostring(err)) end
    wait(2)
    button5.Text = "Run Pet Weight Changer"
    button5.BackgroundTransparency = 0
end)

-- Minimize button
local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 26, 0, 22)
minBtn.Position = UDim2.new(1, -60, 0, 10)
minBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
minBtn.BorderSizePixel = 0
minBtn.Text = "вЂ“"
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 22
minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minBtn.Parent = frame
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 6)

minBtn.MouseEnter:Connect(function() TweenInOut(minBtn, {BackgroundTransparency = 0.3}, 0.2) end)
minBtn.MouseLeave:Connect(function() TweenInOut(minBtn, {BackgroundTransparency = 0}, 0.2) end)

local visible = true
minBtn.MouseButton1Click:Connect(function()
    visible = not visible
    button1.Visible = visible
    button2.Visible = visible
    button3.Visible = visible
    button4.Visible = visible
    footer.Visible = visible
    minBtn.Text = visible and "вЂ“" or "+"
    frame.Size = visible and UDim2.new(0, 220, 0, 226) or UDim2.new(0, 220, 0, 45)
end)

-- Exit button
local exitBtn = Instance.new("TextButton")
exitBtn.Size = UDim2.new(0, 26, 0, 22)
exitBtn.Position = UDim2.new(1, -30, 0, 10)
exitBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
exitBtn.BorderSizePixel = 0
exitBtn.Text = "Г—"
exitBtn.Font = Enum.Font.GothamBold
exitBtn.TextSize = 22
exitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
exitBtn.Parent = frame
Instance.new("UICorner", exitBtn).CornerRadius = UDim.new(0, 6)

exitBtn.MouseEnter:Connect(function() TweenInOut(exitBtn, {BackgroundTransparency = 0.3}, 0.2) end)
exitBtn.MouseLeave:Connect(function() TweenInOut(exitBtn, {BackgroundTransparency = 0}, 0.2) end)
exitBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

-- Draggable logic
local dragging = false
local dragStart, startPos

frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

frame.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                   startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
