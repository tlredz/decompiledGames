local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local random = Random.new()
local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local v = nil
local sound = nil

local function buildGui()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "ProductPurchaseGui"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.DisplayOrder = 10
	local frame = Instance.new("Frame")
	frame.Name = "Frame"
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.Position = UDim2.new(0, 0, 0, 0)
	frame.BackgroundColor3 = Color3.new(0, 0, 0)
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	frame.Active = false
	frame.Visible = false
	frame.Parent = screenGui
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "TextLabel"
	textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	textLabel.Size = UDim2.new(0.25, 0, 0.25, 0)
	textLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
	textLabel.BackgroundColor3 = Color3.new(1, 1, 1)
	textLabel.BackgroundTransparency = 1
	textLabel.TextColor3 = Color3.new(1, 1, 1)
	textLabel.TextTransparency = 0
	textLabel.TextScaled = true
	textLabel.Text = utf8.char(57346)
	textLabel.Active = false
	textLabel.Parent = frame
	sound = Instance.new("Sound")
	sound.Name = "BellDing"
	sound.SoundId = "rbxassetid://138558683512812"
	sound.Parent = frame
	screenGui.Parent = Players.LocalPlayer.PlayerGui
	return frame
end

if RunService:IsClient() then
	v = buildGui()
end

local PurchaseVisual = {}

function PurchaseVisual.play()
	v.Visible = true
	v.BackgroundTransparency = 1
	TweenService:Create(v, tweenInfo, {
		BackgroundTransparency = 0.3
	}):Play()
	sound.PlaybackSpeed = random:NextNumber(1, 1.5)
	sound:Play()
	task.spawn(function()
		local textLabel = v.TextLabel

		while v.Visible do
			textLabel.Rotation += task.wait() * 100
		end
	end)
end

function PurchaseVisual.stop()
	local tween = TweenService:Create(v, tweenInfo, {
		BackgroundTransparency = 1
	})
	tween:Play()
	tween.Completed:Once(function()
		if v.BackgroundTransparency >= 1 then
			v.Visible = false
		end
	end)
end

return PurchaseVisual