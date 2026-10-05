local createVector = vector.create
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local SewerSystem = require(game.ReplicatedStorage.Modules.World.SewerSystem)
local Sound = require(game.ReplicatedStorage.Util.Sound)
local v = {
	AUTO_STOP_DELAY = 3,
	BRIGHTNESS_OFFSET = 0.08,
	COLOR_BLEND = 0.6,
	CONTRAST_OFFSET = -0.06,
	FADE_DURATION = 0.55,
	GREEN_TINT = Color3.fromRGB(125, 175, 86),
	MIN_WATER_RISE = 90,
	SATURATION_OFFSET = -0.05,
	SCREEN_DISTANCE = 2,
	WATER_ABOVE_PLAYER = 16,
	WATER_RISE_DURATION = 0.55
}
local v2 = nil
local v3 = {}
local v4 = {}

function v3.tintColor(color: Color3)
	return color:Lerp(v.GREEN_TINT, v.COLOR_BLEND)
end

function v3.tintSequence(sequence)
	local colorSequenceKeypoints = {}

	for _, keypoint in sequence.Keypoints do
		table.insert(colorSequenceKeypoints, ColorSequenceKeypoint.new(keypoint.Time, v3.tintColor(keypoint.Value)))
	end

	return ColorSequence.new(colorSequenceKeypoints)
end

function v3.recolorScreen(folder)
	for _, effect in folder:GetDescendants() do
		if effect:IsA("ParticleEmitter") then
			effect.Color = v3.tintSequence(effect.Color)
		elseif effect:IsA("Beam") then
			effect.Color = v3.tintSequence(effect.Color)
		elseif effect:IsA("Trail") then
			effect.Color = v3.tintSequence(effect.Color)
		end
	end
end

function v3.createColorCorrections(instance)
	local clones = {}

	for _, colorCorrectionEffect in instance:GetChildren() do
		if not colorCorrectionEffect:IsA("ColorCorrectionEffect") then
			continue
		end

		local clone = colorCorrectionEffect:Clone()
		clone.Brightness += v.BRIGHTNESS_OFFSET
		clone.Contrast += v.CONTRAST_OFFSET
		clone.Saturation += v.SATURATION_OFFSET
		clone.TintColor = v3.tintColor(clone.TintColor)
		clone.Parent = Lighting
		table.insert(clones, clone)
	end

	return clones
end

function v3.raiseWater()
	local map = workspace:FindFirstChild("Map")
	local folder

	if map then
		folder = map:FindFirstChild(SewerSystem.MAP_NAME)
	end

	if not folder then
		return {}
	end

	local character = Players.LocalPlayer.Character
	local humanoidRootPart

	if character then
		humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	end

	local v5

	if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
		v5 = humanoidRootPart.Position.Y + v.WATER_ABOVE_PLAYER
	end

	local result = {}

	for _, part in folder:GetDescendants() do
		if not (part:IsA("BasePart") and part.Name == SewerSystem.WATER_PART_NAME) then
			continue
		end

		local MIN_WATER_RISE = v.MIN_WATER_RISE

		if v5 then
			MIN_WATER_RISE = math.max(MIN_WATER_RISE, v5 - part.Position.Y)
		end

		local tween = TweenService:Create(
			part,
			TweenInfo.new(v.WATER_RISE_DURATION, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
			{
				CFrame = part.CFrame + createVector(0, 1, 0) * MIN_WATER_RISE
			}
		)
		table.insert(result, {
			originalCFrame = part.CFrame,
			part = part,
			tween = tween
		})
		tween:Play()
	end

	return result
end

function v3.restoreWater(items)
	for _, item in items do
		item.tween:Cancel()
		item.tween:Destroy()

		if item.part.Parent then
			item.part.CFrame = item.originalCFrame
		end
	end
end

function v3.disableScreen(folder)
	local v5 = 0

	for _, effect in folder:GetDescendants() do
		if effect:IsA("ParticleEmitter") then
			effect.Enabled = false
			v5 = math.max(v5, effect.Lifetime.Max)
		elseif effect:IsA("Beam") then
			effect.Enabled = false
		elseif effect:IsA("Trail") then
			effect.Enabled = false
		end
	end

	return v5
end

function v3:stop()
	if self.stopping then
		return
	end

	self.stopping = true
	v3.restoreWater(self.waterRecords)
	local v5 = math.max(v.FADE_DURATION, v3.disableScreen(self.screen))
	local tweenInfo = TweenInfo.new(v.FADE_DURATION, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

	for _, colorCorrection in self.colorCorrections do
		TweenService:Create(colorCorrection, tweenInfo, {
			Brightness = 0,
			Contrast = 0,
			Saturation = 0,
			TintColor = Color3.new(1, 1, 1)
		}):Play()
	end

	task.delay(v5, function()
		RunService:UnbindFromRenderStep("SewerFloodTransitionEffect")
		self.screen:Destroy()

		for _, colorCorrection in self.colorCorrections do
			colorCorrection:Destroy()
		end

		if v2 == self then
			v2 = nil
		end
	end)
end

function v4.play()
	if v2 then
		return false
	end

	local mapTransitionEffect = script.Parent:FindFirstChild("MapTransitionEffect")
	local screen

	if mapTransitionEffect then
		screen = mapTransitionEffect:FindFirstChild("Screen")
	end

	local lighting

	if mapTransitionEffect then
		lighting = mapTransitionEffect:FindFirstChild("Lighting")
	end

	local currentCamera = workspace.CurrentCamera

	if not (screen and screen:IsA("BasePart") and lighting and currentCamera) then
		return false
	end

	local clone = screen:Clone()
	clone.Anchored = true
	clone.CanCollide = false
	clone.CanQuery = false
	clone.CanTouch = false
	clone.CFrame = currentCamera.CFrame * CFrame.new(0, 0, -v.SCREEN_DISTANCE)
	v3.recolorScreen(clone)
	clone.Parent = workspace
	local v5 = {
		colorCorrections = v3.createColorCorrections(lighting),
		screen = clone,
		stopping = false,
		waterRecords = v3.raiseWater()
	}
	v2 = v5
	pcall(function()
		Sound:Play("BubbleScreen", Players.LocalPlayer.Character)
	end)
	RunService:BindToRenderStep("SewerFloodTransitionEffect", Enum.RenderPriority.Camera.Value + 1, function()
		local currentCamera2 = workspace.CurrentCamera

		if currentCamera2 and clone.Parent then
			clone.CFrame = currentCamera2.CFrame * CFrame.new(0, 0, -v.SCREEN_DISTANCE)
		end
	end)
	task.delay(v.AUTO_STOP_DELAY, function()
		if v2 == v5 then
			v3.stop(v5)
		end
	end)
	return true
end

function v4.stopEarly()
	local v5 = v2

	if v5 then
		v3.stop(v5)
	end
end

return table.freeze(v4)