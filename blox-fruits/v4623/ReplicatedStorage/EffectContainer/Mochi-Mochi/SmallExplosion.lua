local createVector = vector.create

local function ScaleParticle(p, p2)
	local numberSequenceKeypoints = {}

	for _, keypoint in next, p.Size.Keypoints, nil do
		numberSequenceKeypoints[#numberSequenceKeypoints + 1] = NumberSequenceKeypoint.new(
			keypoint.Time,
			keypoint.Value * p2,
			keypoint.Envelope
		)
	end

	return NumberSequence.new(numberSequenceKeypoints)
end

local FX = require(game.ReplicatedStorage.FX)
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local mochiMochi = FX:WaitForChild("Mochi-Mochi")
local Effect = require(ReplicatedStorage.Effect)
local mochiMochiShockwave = Effect.new("Mochi-Mochi.Shockwave")
return function(list)
	local cFrame, v2, v3 = unpack(list)
	local clone = mochiMochi.SmallExplosion:Clone()
	clone.CFrame = cFrame
	local speed = clone.Center.Fire.Speed
	local _ = clone.Center.Fire.Lifetime
	clone.Center.Fire.Size = ScaleParticle(clone.Center.Fire, 2 * v2)
	clone.Center.Fire.Speed = NumberRange.new(speed.Min + 5 * (1 - v2), speed.Max + 5 * (1 - v2))
	clone.Center.Fire.Lifetime = NumberRange.new(v3 * 0.25, v3)
	local speed2 = clone.Center.FireParticles.Speed
	local _ = clone.Center.FireParticles.Lifetime
	clone.Center.FireParticles.Size = ScaleParticle(clone.Center.FireParticles, 1.5 * v2)
	clone.Center.FireParticles.Speed = NumberRange.new(speed2.Min + 2 * (1 - v2), speed2.Max + 2 * (1 - v2))
	clone.Center.FireParticles.Lifetime = NumberRange.new(v3 * 0.1, v3 * 0.5)
	clone.Parent = _WorldOrigin
	spawn(function()
		for i = 1, 3 do
			mochiMochiShockwave:replicate({ cFrame * CFrame.new(0, v2 * 0.1, 0), v2 * (i + 0.75), v3 / 4 })
			wait(v3 / 4 * 0.75)
		end
	end)
	clone.Center.FireParticles:Emit((math.min(36, 10 + 2 * (v2 - 1))))
	local tweenInfo = TweenInfo.new(v3 * 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	local tween = TweenService:Create(clone, tweenInfo, {
		Color = Color3.fromRGB(255, 93, 0)
	})
	local tween2 = TweenService:Create(clone.Mesh, tweenInfo, {
		Scale = createVector(1, 1, 1) * v2 * 1.25
	})
	tween:play()
	tween2:Play()
	wait(v3 * 0.5)
	clone.Center.Fire:Emit((math.min(60, 40 + 1 * (v2 - 1))))
	TweenService:Create(clone, TweenInfo.new(v3 * 0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Transparency = 1
	}):Play()
	wait(v3 * 0.5)
	wait(clone.Center.Fire.Lifetime.Max)
	clone:Destroy()
end