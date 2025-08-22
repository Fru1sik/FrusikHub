local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

-- Add Blur Effect
local blur = Instance.new("BlurEffect")
blur.Size = 12
blur.Parent = Lighting

-- Create ScreenGui
local gui = Instance.new("ScreenGui", playerGui)
gui.Name = "KuniLoading"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true

-- Main Panel
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 460, 0, 160)
frame.Position = UDim2.new(0.5, -230, 0.5, -80)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BackgroundTransparency = 0.05
frame.BorderSizePixel = 0

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 14)
Instance.new("UIStroke", frame).ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- Shadow
local shadow = Instance.new("ImageLabel", frame)
shadow.Image = "rbxassetid://1316045217"
shadow.ImageTransparency = 0.75
shadow.Size = UDim2.new(1, 80, 1, 80)
shadow.Position = UDim2.new(0.5, -240, 0.5, -90)
shadow.BackgroundTransparency = 1
shadow.ZIndex = -1

-- Glowing Title
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, -40, 0, 60)
title.Position = UDim2.new(0, 20, 0, 10)
title.Text = "Yawi Hub X"
title.TextColor3 = Color3.fromRGB(0, 200, 255)
title.TextTransparency = 0.2
title.TextStrokeTransparency = 0.6
title.Font = Enum.Font.FredokaOne
title.TextScaled = true
title.BackgroundTransparency = 1

-- Title Pulse
task.spawn(function()
	while title and title.Parent do
		TweenService:Create(title, TweenInfo.new(1), {TextTransparency = 0.05}):Play()
		task.wait(1)
		TweenService:Create(title, TweenInfo.new(1), {TextTransparency = 0.25}):Play()
		task.wait(1)
	end
end)

-- Loading Dots Animation
local loading = Instance.new("TextLabel", frame)
loading.Size = UDim2.new(1, -40, 0, 30)
loading.Position = UDim2.new(0, 20, 0, 70)
loading.Text = "Loading"
loading.TextColor3 = Color3.fromRGB(200, 200, 200)
loading.Font = Enum.Font.FredokaOne
loading.TextScaled = true
loading.BackgroundTransparency = 1
loading.TextStrokeTransparency = 1

-- Dots Cycle
task.spawn(function()
	local dots = {"", ".", "..", "..."}
	local index = 1
	while loading and loading.Parent do
		loading.Text = "Loading" .. dots[index]
		index = (index % #dots) + 1
		task.wait(0.4)
	end
end)

-- Loading Bar BG
local barBg = Instance.new("Frame", frame)
barBg.Size = UDim2.new(1, -40, 0, 18)
barBg.Position = UDim2.new(0, 20, 1, -40)
barBg.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
barBg.BorderSizePixel = 0
Instance.new("UICorner", barBg).CornerRadius = UDim.new(0, 10)

-- Loading Bar Fill
local barFill = Instance.new("Frame", barBg)
barFill.Size = UDim2.new(0, 0, 1, 0)
barFill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
barFill.BorderSizePixel = 0
Instance.new("UICorner", barFill).CornerRadius = UDim.new(0, 10)

-- Gradient Fill
local grad = Instance.new("UIGradient", barFill)
grad.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 170, 255))
}
grad.Transparency = NumberSequence.new{
	NumberSequenceKeypoint.new(0, 0),
	NumberSequenceKeypoint.new(1, 0.2)
}

-- Animate Fill
TweenService:Create(barFill, TweenInfo.new(5, Enum.EasingStyle.Sine), {
	Size = UDim2.new(1, 0, 1, 0)
}):Play()

-- Optional: Play soft chime sound
local sound = Instance.new("Sound", frame)
sound.SoundId = "rbxassetid://9118823106"
sound.Volume = 0.5
sound:Play()

-- Optional: Star Particle Twinkle
--[[
local particle = Instance.new("ParticleEmitter", frame)
particle.Texture = "rbxassetid://243660364"
particle.LightEmission = 1
particle.Rate = 3
particle.Lifetime = NumberRange.new(3)
particle.Speed = NumberRange.new(0.5)
particle.Size = NumberSequence.new(0.3)
]]

-- Fade out and destroy
task.delay(5, function()
	TweenService:Create(frame, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
	TweenService:Create(title, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
	TweenService:Create(loading, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
	TweenService:Create(barFill, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
	TweenService:Create(barBg, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
	TweenService:Create(shadow, TweenInfo.new(0.5), {ImageTransparency = 1}):Play()
	wait(0.6)
	blur:Destroy()
	gui:Destroy()
end)
