local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Synchronizer = require(ReplicatedStorage.Packages.Synchronizer)
local JumpLTMData = require(ReplicatedStorage.Shared.JumpLTMData)
local ServerData = require(ReplicatedStorage.Datas.ServerData)
local localPlayer = Players.LocalPlayer
local tweenInfo = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true)
local color = Color3.fromRGB(123, 253, 70)
local color2 = Color3.fromRGB(0, 0, 0)
local random = Random.new()
local v = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function attachIconToText(imageLabel, textLabel, p: number, p2: number)
	local function reposition()
		local textBounds = textLabel.TextBounds
		local v2 = math.max(textBounds.Y * p2, 1)
		local midpoint = (v2 + p) / 2
		textLabel.Position = UDim2.new(0.5, -midpoint, 0.5, 0)
		imageLabel.Size = UDim2.fromOffset(v2, v2)
		imageLabel.Position = UDim2.new(0.5, textBounds.X / 2 + p - midpoint, 0.5, 0)
	end

	textLabel:GetPropertyChangedSignal("TextBounds"):Connect(reposition)
	reposition()
end

local function animateXPPopup(state)
	if state.AnimConnection then
		state.AnimConnection:Disconnect()
	end

	state.Billboard.StudsOffset = createVector(0, 2.5, 0)
	state.Label.TextTransparency = 0
	state.Stroke.Transparency = 0
	state.Icon.ImageTransparency = 0
	state.Content.Size = UDim2.fromScale(1.25, 1.25)
	TweenService:Create(state.Content, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.fromScale(1, 1)
	}):Play()
	local vector2 = Vector3.new(random:NextNumber(-3.5, 3.5), random:NextNumber(7, 10), 0)
	local number = random:NextNumber(-16, 16)
	local number2 = random:NextNumber(-35, 35)
	local lastTime = os.clock()
	state.AnimConnection = RunService.PostSimulation:Connect(function()
		local v2 = os.clock() - lastTime
		state.Billboard.StudsOffset = createVector(0, 2.5, 0) + Vector3.new(
			vector2.X * v2,
			vector2.Y * v2 + -7 * v2 * v2,
			0
		)
		state.Content.Rotation = number + number2 * v2
	end)
	local tweenInfo3 = TweenInfo.new(
		0.5,
		Enum.EasingStyle.Quint,
		Enum.EasingDirection.Out,
		0,
		false,
		0.7999999999999999
	)
	TweenService:Create(state.Label, tweenInfo3, {
		TextTransparency = 1
	}):Play()
	TweenService:Create(state.Stroke, tweenInfo3, {
		Transparency = 1
	}):Play()
	TweenService:Create(state.Icon, tweenInfo3, {
		ImageTransparency = 1
	}):Play()
end

local function showXPPopup(amount: number)
	local character = localPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local v2 = v

	if v2 and v2.Billboard.Parent and os.clock() - v2.StartTime < 0.7 then
		v2.Amount += amount
		v2.Label.Text = `+{v2.Amount}`
		v2.StartTime = os.clock()

		if v2.CleanupThread then
			task.cancel(v2.CleanupThread)
		end

		animateXPPopup(v2)
		v2.CleanupThread = task.delay(1.4, function()
			if v == v2 then
				v = nil
			end

			if v2.AnimConnection then
				v2.AnimConnection:Disconnect()
			end

			v2.Billboard:Destroy()
		end)
	else
		if v2 then
			if v2.CleanupThread then
				task.cancel(v2.CleanupThread)
			end

			if v2.AnimConnection then
				v2.AnimConnection:Disconnect()
			end

			v2.Billboard:Destroy()
		end

		local billboardGui = Instance.new("BillboardGui")
		billboardGui.Name = "XPPopup"
		billboardGui.Size = UDim2.fromScale(5, 1.6)
		billboardGui.StudsOffset = createVector(0, 2.5, 0)
		billboardGui.AlwaysOnTop = true
		billboardGui.MaxDistance = 100
		billboardGui.ResetOnSpawn = false
		local frame = Instance.new("Frame")
		frame.Name = "Content"
		frame.AnchorPoint = Vector2.new(0.5, 0.5)
		frame.Position = UDim2.fromScale(0.5, 0.5)
		frame.Size = UDim2.fromScale(1, 1)
		frame.BackgroundTransparency = 1
		frame.Parent = billboardGui
		local textLabel = Instance.new("TextLabel")
		textLabel.Name = "Amount"
		textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
		textLabel.Position = UDim2.fromScale(0.5, 0.5)
		textLabel.Size = UDim2.fromScale(1, 1)
		textLabel.BackgroundTransparency = 1
		textLabel.Text = `+{amount}`
		textLabel.TextColor3 = color
		textLabel.TextScaled = true
		textLabel.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.ExtraBold)
		textLabel.Parent = frame
		local uIStroke = Instance.new("UIStroke")
		uIStroke.Color = color2
		uIStroke.Thickness = 0.05
		uIStroke.StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize
		uIStroke.Parent = textLabel
		local imageLabel = Instance.new("ImageLabel")
		imageLabel.Name = "Icon"
		imageLabel.Image = "rbxassetid://107900278444265"
		imageLabel.BackgroundTransparency = 1
		imageLabel.AnchorPoint = Vector2.new(0, 0.5)
		imageLabel.ScaleType = Enum.ScaleType.Fit
		imageLabel.Parent = frame
		attachIconToText(imageLabel, textLabel, 4, 1.5) -- equivalent call inferred; original call site unknown
		billboardGui.Parent = humanoidRootPart
		local v5 = {
			Billboard = billboardGui,
			Content = frame,
			Label = textLabel,
			Stroke = uIStroke,
			Icon = imageLabel,
			Amount = amount,
			StartTime = os.clock(),
			CleanupThread = nil,
			AnimConnection = nil
		}
		v = v5
		animateXPPopup(v5)
		v5.CleanupThread = task.delay(1.4, function()
			if v == v5 then
				v = nil
			end

			if v5.AnimConnection then
				v5.AnimConnection:Disconnect()
			end

			billboardGui:Destroy()
		end)
	end
end

local function getBar()
	local jumpLTMLevel = localPlayer:WaitForChild("PlayerGui"):WaitForChild("JumpLTMLevel")
	local bar = jumpLTMLevel:WaitForChild("Bar")
	local fill = bar:WaitForChild("FillClip"):WaitForChild("Fill")
	local label = bar:WaitForChild("Frame"):WaitForChild("Label")
	local uIScale = bar:WaitForChild("UIScale")
	jumpLTMLevel.Enabled = true
	return bar, fill, label, uIScale
end

return {
	Start = function(_)
		if not ServerData.IsJumpLTMServer() then
			return
		end

		task.spawn(function()
			local v2 = Synchronizer:Wait(localPlayer)

			if not v2 then
				return
			end

			local bar, v3, v4, v5 = getBar()
			local v6 = -1
			local v7 = -1

			local function update()
				local v8 = v2:Get({ "JumpLTMEvent", "XP" }) or 0
				local levelInfo, v9, v10 = JumpLTMData.GetLevelInfo(v8)

				if v7 >= 0 and v7 < v8 then
					showXPPopup(v8 - v7)
				end

				v7 = v8
				local v11 = 1 - (not v10 and 1 or math.clamp(v9 / v10, 0, 1))
				TweenService:Create(v3, tweenInfo, {
					Position = UDim2.fromScale(v11, 0.5)
				}):Play()
				TweenService:Create(v3.Parent, tweenInfo, {
					Position = UDim2.fromScale(-v11, 0.5)
				}):Play()
				local v12 = v4
				local text

				if v10 then
					text = `Level {levelInfo} <font color="rgb(123, 253, 70)">{v9}/{v10} XP</font>`
				else
					text = `Level {levelInfo} <font color="rgb(123, 253, 70)">MAX</font>`
				end

				v12.Text = text

				if v6 ~= -1 and v6 < levelInfo then
					TweenService:Create(v5, tweenInfo2, {
						Scale = 1.12
					}):Play()
				end

				v6 = levelInfo
			end

			v2:OnChanged({ "JumpLTMEvent", "XP" }, update)
			update()
			bar.Visible = true
		end)
	end
}