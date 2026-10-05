local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local Trove = require(ReplicatedStorage.Packages.Trove)
require(ReplicatedStorage.Packages.Shake)
local ShakePresets = require(ReplicatedStorage.Shared.ShakePresets)
local CreateTween = require(ReplicatedStorage.Packages.CreateTween)
local SkullEmojiEffectController = {}
local maid = Trove.new()
local skullEmoji = Players.LocalPlayer.PlayerGui.SkullEmoji
local canvasGroup = skullEmoji.CanvasGroup
local skull = canvasGroup.Skull
local v = {
	Center = UDim2.fromScale(0.5, 0.65),
	Lower = UDim2.fromScale(0.5, 0.8),
	Bottom = skull.Position
}
TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

-- equivalent calls inferred from this helper; original call sites unknown
local function tweenFast(p, tweenInfo2, p2, p3)
	local tween = CreateTween(p, tweenInfo2, p2, false);
	(p3 or maid):Add(tween)
	tween:Play()
	return tween
end

function SkullEmojiEffectController:_playEffect(duration: number, p: string?)
	local currentCamera = workspace.CurrentCamera
	local exposureCompensation = Lighting.ExposureCompensation
	local position = v[p] or v.Bottom
	canvasGroup.GroupTransparency = 1
	skull.Position = UDim2.fromScale(position.X.Scale * 0.85, position.Y.Scale * 1.1)
	skull.Rotation = -5
	skullEmoji.Enabled = true
	ReplicatedStorage.Sounds.Others.SkullEffect:Play()
	Lighting.ExposureCompensation = 4
	tweenFast(Lighting, tweenInfo, {
		ExposureCompensation = exposureCompensation
	}) -- equivalent call inferred; original call site unknown
	tweenFast(canvasGroup, TweenInfo.new(0.1, Enum.EasingStyle.Quart), {
		GroupTransparency = 0
	}) -- equivalent call inferred; original call site unknown
	skull.ImageTransparency = 0
	tweenFast(skull, TweenInfo.new(0.125, Enum.EasingStyle.Back), {
		Position = position,
		Rotation = 0
	}) -- equivalent call inferred; original call site unknown
	local clone = ShakePresets.Explosion:Clone()
	clone.FadeInTime = 0
	clone.Frequency = 0.3333333333333333
	maid:Add(clone)
	maid:Add(ShakePresets.BindShakeToCamera(clone, currentCamera))
	clone:Start()
	local clone2 = ShakePresets.Bump:Clone()
	clone2.FadeInTime = 0
	clone2.Sustain = true
	maid:Add(clone2)
	maid:Add(ShakePresets.BindShakeToCamera(clone2, currentCamera))
	clone2:Start()
	maid:Add(task.delay(0.125, function()
		local v5 = time()
		maid:Add((RunService.PostSimulation:Connect(function(_)
			debug.profilebegin("SkullEmojiEffect:Update")
			local v6, _ = clone2:Update()

			if not clone2:IsShaking() then
				debug.profileend()
				return
			end

			local v7 = v6 * createVector(1, 1, 1) * 0.075
			skull.Position = UDim2.fromScale((1 + v7.X) * position.X.Scale, (1 + v7.Y) * position.Y.Scale)
			local v8 = time() - v5
			skull.Rotation = math.sin(2 * v8) * 5
			debug.profileend()
		end)))
	end))
	local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
	colorCorrectionEffect.Parent = Lighting
	Debris:AddItem(colorCorrectionEffect, duration)
	tweenFast(colorCorrectionEffect, tweenInfo, {
		Brightness = -0.2,
		Contrast = 0.4,
		Saturation = -0.7000000000000001
	}) -- equivalent call inferred; original call site unknown
	maid:Add(task.delay(duration - 0.5, function()
		Lighting.ExposureCompensation = 2.5
		tweenFast(Lighting, tweenInfo, {
			ExposureCompensation = exposureCompensation
		}) -- equivalent call inferred; original call site unknown
		clone2:StopSustain()
		tweenFast(colorCorrectionEffect, tweenInfo, {
			Brightness = 0,
			Contrast = 0,
			Saturation = 0
		}) -- equivalent call inferred; original call site unknown
		tweenFast(skull, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {
			ImageTransparency = 1
		}) -- equivalent call inferred; original call site unknown
	end))
	task.wait(duration)
	self:Stop()
end

function SkullEmojiEffectController:Play(value, value2)
	if self._isPlaying then
		self:Stop()
	end

	self._isPlaying = true
	task.spawn(self._playEffect, self, math.max(value or 3, 1.5), value2 or "Bottom")
end

function SkullEmojiEffectController:Stop()
	skullEmoji.Enabled = false
	self._isPlaying = false
	maid:Clean()
end

function SkullEmojiEffectController:Start()
	skullEmoji.Enabled = false
end

return SkullEmojiEffectController