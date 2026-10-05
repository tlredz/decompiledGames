local createVector = vector.create

local function ScaleParticle(clone, p)
	local numberSequenceKeypoints = {}

	for _, keypoint in next, clone.Size.Keypoints, nil do
		local v = keypoint.Value * p
		table.insert(
			numberSequenceKeypoints,
			NumberSequenceKeypoint.new(keypoint.Time, v, v < keypoint.Envelope and v or keypoint.Envelope)
		)
	end

	clone.Speed = NumberRange.new(clone.Speed.Min * p, clone.Speed.Max * p)
	return NumberSequence.new(numberSequenceKeypoints)
end

local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local effects = ReplicatedStorage["Ope-Ope"].Effects
require(ReplicatedStorage.Util.Tween)
local Effect = require(ReplicatedStorage.Effect)
local Sound = require(game.ReplicatedStorage.Util.Sound)
local _ = workspace.CurrentCamera
return function(list)
	tick()
	local v, cFrame, v3, v4 = unpack(list)
	Sound:Play("Ope.Explosion.Spike", cFrame.p, 2 * v3)
	Effect.new("Ope-Ope.Hit"):replicate({ cFrame, v3 })
	local clone = effects.DustShockwaveColored:Clone()
	clone.CFrame = cFrame * CFrame.Angles(-1.5707963267948966, 0, 0)
	clone.Color = v.Color
	local scale = clone.Mesh.Scale
	clone.Mesh.Scale = Vector3.new()
	clone.Parent = _WorldOrigin
	local attachment = Instance.new("Attachment")
	attachment.CFrame = cFrame
	attachment.Parent = workspace.Terrain
	local clone2 = effects.Parent.Particles.Dust:Clone()
	clone2.SpreadAngle = Vector2.new(180, 180)
	clone2.Enabled = false
	clone2.Color = ColorSequence.new(v.Color)
	clone2.Size = ScaleParticle(clone2, v3)
	clone2.Lifetime = NumberRange.new(v4 * 0.25, v4)
	clone2.Parent = attachment
	clone2:Emit(v3)
	local tweenInfo = TweenInfo.new(v4 * 0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
	local tween = TweenService:Create(clone, tweenInfo, {
		CFrame = cFrame * CFrame.new(0, 0, -v3 / 2) * CFrame.Angles(-1.5707963267948966, 0, 0)
	})
	local tween2 = TweenService:Create(clone.Mesh, tweenInfo, {
		Scale = scale * createVector(0.75, 0.8, 0.75) * v3 / 2
	})
	tween.Completed:Connect(function()
		local tweenInfo2 = TweenInfo.new(v4 * 0.5, Enum.EasingStyle.Circular, Enum.EasingDirection.In)
		local tween3 = TweenService:Create(clone, tweenInfo2, {
			Transparency = 1
		})
		local tween4 = TweenService:Create(clone.Mesh, tweenInfo2, {
			Scale = scale * createVector(0, 0.9, 0) * v3 / 2
		})
		tween4.Completed:Connect(function()
			clone:Destroy()
			attachment:Destroy()
		end)
		tween3:Play()
		tween4:Play()
	end)
	tween:Play()
	tween2:Play()
end