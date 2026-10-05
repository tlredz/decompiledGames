local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local localPlayer = Players.LocalPlayer
local chickenOrHero = game.ReplicatedStorage:WaitForChild("ChickenOrHero")
local events = chickenOrHero:WaitForChild("Audio"):WaitForChild("Events")
local VerifiedName = require(chickenOrHero.Presentation:WaitForChild("VerifiedName"))
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CatchConfirmation"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 28
screenGui.Parent = localPlayer:WaitForChild("PlayerGui")
local canvasGroup = Instance.new("CanvasGroup")
canvasGroup.Name = "Confirmed"
canvasGroup.BackgroundTransparency = 1
canvasGroup.AnchorPoint = Vector2.new(0.5, 0.5)
canvasGroup.Position = UDim2.fromScale(0.5, 0.46)
canvasGroup.Size = UDim2.fromScale(0.45, 0.2)
canvasGroup.Visible = false
canvasGroup.Parent = screenGui
local frame = Instance.new("Frame")
frame.BackgroundTransparency = 1
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.Position = UDim2.fromScale(0.5, 0.5)
frame.Size = UDim2.fromOffset(38, 38)
frame.Parent = canvasGroup

for _, v in {
	{ -1, -1 },
	{ 1, -1 },
	{ -1, 1 },
	{ 1, 1 }
} do
	local frame2 = Instance.new("Frame")
	frame2.BorderSizePixel = 0
	frame2.BackgroundColor3 = Color3.fromRGB(255, 247, 220)
	frame2.AnchorPoint = Vector2.new(0.5, 0.5)
	frame2.Size = UDim2.fromOffset(11, 3)
	frame2.Position = UDim2.new(0.5, v[1] * 11, 0.5, v[2] * 11)
	frame2.Rotation = v[1] * v[2] * 45
	frame2.Parent = frame
end

local textLabel = Instance.new("TextLabel")
textLabel.BackgroundTransparency = 1
textLabel.Size = UDim2.fromScale(1, 0.28)
textLabel.Position = UDim2.fromScale(0, 0.72)
textLabel.Font = Enum.Font.GothamBold
textLabel.TextColor3 = Color3.fromRGB(255, 247, 220)
textLabel.TextStrokeTransparency = 0.4
textLabel.TextScaled = true
textLabel.Parent = canvasGroup
local uITextSizeConstraint = Instance.new("UITextSizeConstraint")
uITextSizeConstraint.MinTextSize = 12
uITextSizeConstraint.MaxTextSize = 20
uITextSizeConstraint.Parent = textLabel
local count = 0
local v = nil
events.OnClientEvent:Connect(function(p, data)
	if p ~= "CatchConfirmed" or type(data) ~= "table" or data.catcher ~= localPlayer.UserId then
		return
	end

	count += 1
	local v2 = count

	if v then
		v:Cancel()
	end

	textLabel.RichText = true
	textLabel.Text = "CAUGHT · " .. VerifiedName.format(data.name or "Runner", data.verified)
	canvasGroup.Visible = true
	canvasGroup.GroupTransparency = 0
	frame.Size = UDim2.fromOffset(48, 48)
	TweenService:Create(frame, TweenInfo.new(0.12, Enum.EasingStyle.Quad), {
		Size = UDim2.fromOffset(38, 38)
	}):Play()
	task.delay(0.6, function()
		if count ~= v2 then
			return
		end

		v = TweenService:Create(canvasGroup, TweenInfo.new(0.25), {
			GroupTransparency = 1
		})
		v:Play()
		v.Completed:Once(function()
			if count == v2 then
				canvasGroup.Visible = false
			end
		end)
	end)
end)