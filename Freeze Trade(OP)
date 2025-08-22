--// Services
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local tweenService = game:GetService("TweenService")
local userInput = game:GetService("UserInputService")

--// GUI
local TradeAssistGUI = Instance.new("ScreenGui")
TradeAssistGUI.Name = "TradeAssistGUI"
TradeAssistGUI.ResetOnSpawn = false
TradeAssistGUI.IgnoreGuiInset = true
TradeAssistGUI.Parent = playerGui

--// Main Frame (Smaller Size)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 240, 0, 320)
MainFrame.Position = UDim2.new(0.5, -120, 0.5, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = TradeAssistGUI
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

--// Drag Support
local dragging = false
local dragStart, startPos
local function updateDrag(input)
	local delta = input.Position - dragStart
	MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end
MainFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = MainFrame.Position
	end
end)
MainFrame.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		updateDrag(input)
	end
end)
userInput.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

--// Top Bar
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 30)
TopBar.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
TopBar.BorderSizePixel = 0
TopBar.ZIndex = 2
TopBar.Parent = MainFrame

--// Title Label
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -30, 1, 0)
TitleLabel.Position = UDim2.new(0, 0, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Trade Freeze"
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 14
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextXAlignment = Enum.TextXAlignment.Center
TitleLabel.ZIndex = 2
TitleLabel.Parent = TopBar

--// Close Button
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -30, 0, 0)
CloseButton.Text = "X"
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 16
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
CloseButton.BorderSizePixel = 0
CloseButton.ZIndex = 3
Instance.new("UICorner", CloseButton).CornerRadius = UDim.new(0, 6)
CloseButton.Parent = TopBar
CloseButton.MouseButton1Click:Connect(function()
	TradeAssistGUI:Destroy()
end)

--// Content Frame
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, 0, 1, -30)
ContentFrame.Position = UDim2.new(0, 0, 0, 30)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

--// Profile Picture
local PlayerIconFrame = Instance.new("Frame")
PlayerIconFrame.Size = UDim2.new(0, 80, 0, 80)
PlayerIconFrame.Position = UDim2.new(0.5, -40, 0, 8)
PlayerIconFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
PlayerIconFrame.BorderSizePixel = 0
PlayerIconFrame.ClipsDescendants = true
PlayerIconFrame.Parent = ContentFrame
Instance.new("UICorner", PlayerIconFrame).CornerRadius = UDim.new(1, 0)

local PlayerIcon = Instance.new("ImageLabel")
PlayerIcon.Size = UDim2.new(0.85, 0, 0.85, 0)
PlayerIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
PlayerIcon.AnchorPoint = Vector2.new(0.5, 0.5)
PlayerIcon.BackgroundTransparency = 1
PlayerIcon.Image = "rbxassetid://0"
PlayerIcon.Parent = PlayerIconFrame

-- Load profile image
local success, thumb = pcall(function()
	return Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size180x180)
end)
if success then
	PlayerIcon.Image = thumb
end

--// Username Box
local UsernameBox = Instance.new("TextBox")
UsernameBox.PlaceholderText = "Enter Username"
UsernameBox.Font = Enum.Font.GothamBold
UsernameBox.TextSize = 13
UsernameBox.Size = UDim2.new(0.85, 0, 0, 30)
UsernameBox.Position = UDim2.new(0.5, 0, 0, 95)
UsernameBox.AnchorPoint = Vector2.new(0.5, 0)
UsernameBox.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
UsernameBox.TextColor3 = Color3.new(1, 1, 1)
UsernameBox.ClearTextOnFocus = false
UsernameBox.Parent = ContentFrame
Instance.new("UICorner", UsernameBox).CornerRadius = UDim.new(0, 8)

UsernameBox.FocusLost:Connect(function(enterPressed)
	if enterPressed and UsernameBox.Text ~= "" then
		local name = UsernameBox.Text
		local ok, id = pcall(function()
			return Players:GetUserIdFromNameAsync(name)
		end)
		if ok then
			local content, _ = Players:GetUserThumbnailAsync(id, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size180x180)
			PlayerIcon.Image = content
		end
	end
end)

--// Button Container
local ButtonContainer = Instance.new("Frame")
ButtonContainer.Size = UDim2.new(1, 0, 0, 100)
ButtonContainer.Position = UDim2.new(0, 0, 0, 135)
ButtonContainer.BackgroundTransparency = 1
ButtonContainer.Parent = ContentFrame

local layout = Instance.new("UIListLayout", ButtonContainer)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 6)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.VerticalAlignment = Enum.VerticalAlignment.Top

local function createButton(text, color)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0.85, 0, 0, 30)
	btn.Text = text
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 13
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.BackgroundColor3 = color
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
	btn.Parent = ButtonContainer
	return btn
end

local FreezeButton = createButton("FREEZE TRADE", Color3.fromRGB(240, 180, 60))
local ForceButton = createButton("FORCE TRADE PETS", Color3.fromRGB(160, 120, 255))
local AcceptButton = createButton("AUTO ACCEPT", Color3.fromRGB(70, 200, 120))

-- Notification Logic
local function notify(txt)
	game.StarterGui:SetCore("SendNotification", {
		Title = "Trade Assist",
		Text = txt,
		Duration = 2,
	})
end

FreezeButton.MouseButton1Click:Connect(function() notify("Trade frozen!") end)
ForceButton.MouseButton1Click:Connect(function() notify("Force trade triggered!") end)
AcceptButton.MouseButton1Click:Connect(function() notify("Auto accept triggered!") end)

--// Credit
local CreditLabel = Instance.new("TextLabel")
CreditLabel.Text = "Tiktok: @yawiyawiyawiz1"
CreditLabel.Font = Enum.Font.GothamBold
CreditLabel.TextSize = 13
CreditLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
CreditLabel.BackgroundTransparency = 1
CreditLabel.Size = UDim2.new(1, 0, 0, 20)
CreditLabel.Position = UDim2.new(0, 0, 1, -22)
CreditLabel.TextXAlignment = Enum.TextXAlignment.Center
CreditLabel.Parent = MainFrame
