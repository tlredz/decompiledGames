local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local boostRequest = game.ReplicatedStorage:WaitForChild("ChickenOrHero"):WaitForChild("Presentation"):WaitForChild("BoostRequest")
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PerfectDodgeFeedback"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 65
screenGui:SetAttribute("UIProportionalExclude", true)
screenGui.Parent = playerGui
local sound = Instance.new("Sound")
sound.Name = "PerfectDodgeSound"
sound.SoundId = "rbxassetid://132570658772029"
sound.Volume = 0.35
sound.Parent = screenGui
local frame = Instance.new("Frame")
frame.BackgroundTransparency = 1
frame.AnchorPoint = Vector2.new(0.5, 1)
frame.Parent = screenGui
local textLabel = Instance.new("TextLabel")
textLabel.Size = UDim2.fromScale(1, 1)
textLabel.BackgroundTransparency = 1
textLabel.Text = "PERFECT DODGE"
textLabel.TextColor3 = Color3.fromRGB(255, 218, 111)
textLabel.TextStrokeColor3 = Color3.fromRGB(16, 27, 35)
textLabel.TextStrokeTransparency = 0.3
textLabel.TextScaled = true
textLabel.Font = Enum.Font.GothamBold
textLabel.Visible = false
textLabel.Parent = frame
local count = 0
local v = nil

local function place()
	local currentCamera = workspace.CurrentCamera

	if not currentCamera then
		return
	end

	local viewportSize = currentCamera.ViewportSize
	local v2 = 1e999
	local v3 = -1e999
	local v4 = 1e999

	for _, childName in { "AbilityControls", "GearControls" } do
		local child = playerGui:FindFirstChild(childName)

		if not (child and child.Enabled) then
			continue
		end

		for _, button in child:GetChildren() do
			if not (button:IsA("GuiButton") and button.Visible) then
				continue
			end

			local absolutePosition = button.AbsolutePosition
			local absoluteSize = button.AbsoluteSize
			v2 = math.min(v2, absolutePosition.X)
			v3 = math.max(v3, absolutePosition.X + absoluteSize.X)
			v4 = math.min(v4, absolutePosition.Y)
		end
	end

	local v5 = math.clamp(viewportSize.X * 0.18, 125, 210)
	local v6 = math.clamp(viewportSize.Y * 0.025, 16, 24)
	local v7 = v4 < 1e999 and (v2 + v3) * 0.5 or viewportSize.X * 0.5
	local v8 = v4 < 1e999 and v4 - 8 or viewportSize.Y * 0.76
	frame.Size = UDim2.fromOffset(v5, v6)
	frame.Position = UDim2.fromOffset(math.clamp(v7, v5 / 2 + 4, viewportSize.X - v5 / 2 - 4), (math.max(v6 + 4, v8)))
end

local onClientEventConnection = boostRequest.OnClientEvent:Connect(function(p)
	if p ~= "PerfectDodge" then
		return
	end

	sound:Stop()
	sound:Play()
	count += 1
	local v2 = count

	if v then
		v:Cancel()
	end

	place()
	textLabel.Visible = true
	textLabel.Position = UDim2.fromScale(0, 0.3)
	textLabel.TextTransparency = 1
	textLabel.TextStrokeTransparency = 1
	v = TweenService:Create(textLabel, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Position = UDim2.fromScale(0, 0),
		TextTransparency = 0,
		TextStrokeTransparency = 0.3
	})
	v:Play()
	task.delay(0.85, function()
		if v2 ~= count or not screenGui.Parent then
			return
		end

		v = TweenService:Create(textLabel, TweenInfo.new(0.22), {
			TextTransparency = 1,
			TextStrokeTransparency = 1
		})
		v:Play()
		task.delay(0.22, function()
			if v2 == count then
				textLabel.Visible = false
			end
		end)
	end)
end)
local renderSteppedConnection = RunService.RenderStepped:Connect(function()
	if textLabel.Visible then
		place()
	end
end)
script.Destroying:Connect(function()
	count += 1
	onClientEventConnection:Disconnect()
	renderSteppedConnection:Disconnect()

	if v then
		v:Cancel()
	end

	screenGui:Destroy()
end)