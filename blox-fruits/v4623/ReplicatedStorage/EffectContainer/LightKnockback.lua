local createVector = vector.create
local util = game.ReplicatedStorage:WaitForChild("Util")
require(util.Sound)
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
local _ = game.ReplicatedStorage.Assets.Models.LightSword
local _WorldOrigin = workspace._WorldOrigin
local _ = workspace.Map
local FX = require(game.ReplicatedStorage.FX)

local function ScaleParticle(state, p)
	local numberSequenceKeypoints = {}

	for _, keypoint in next, state.Size.Keypoints, nil do
		table.insert(
			numberSequenceKeypoints,
			NumberSequenceKeypoint.new(keypoint.Time, keypoint.Value * p, keypoint.Envelope)
		)
	end

	state.Speed = NumberRange.new(state.Speed.Min * p, state.Speed.Max * p)
	state.Drag *= p
	return NumberSequence.new(numberSequenceKeypoints)
end

local function func(data)
	local cFrame = data.CFrame
	local length = data.Length or 80
	local scale = data.Scale or 1
	local weak = data.Weak

	if (workspace.CurrentCamera.CFrame.p - cFrame.p).Magnitude > 600 then
		return
	end

	local clone = FX:WaitForChild("Attachments").LightExplosion3:Clone()
	clone.Position = cFrame.p
	clone.Parent = workspace.Terrain
	clone.Star.Size = ScaleParticle(clone.Star, 2 * scale)
	clone.Star_Color.Size = ScaleParticle(clone.Star_Color, 4 * scale)
	clone.Explosion.Size = ScaleParticle(clone.Explosion, 3 * scale)

	if scale == 1 then
		clone.Explosion.Drag = 0
	end

	clone.Star:Emit(3)
	clone.Star_Color:Emit(3)

	if weak then
		local v = math.random(1, 360)
		clone.Star.Rotation = NumberRange.new(v)
		clone.Star_Color.Rotation = NumberRange.new(v)
		clone.Star.Lifetime = NumberRange.new(0.25)
		clone.Star_Color.Lifetime = NumberRange.new(0.25)
		clone.Star.RotSpeed = NumberRange.new(0, 0)
		clone.Star_Color.RotSpeed = NumberRange.new(0)
	else
		clone.Explosion:Emit(32 * scale)
	end

	local part = Instance.new("Part")
	part.Size = createVector(1, 1, 1)
	part.Anchored = true
	part.CanCollide = false
	part.Material = "Neon"
	part.Color = Color3.new(1, 1, 0.5)
	part.CFrame = cFrame
	local specialMesh = Instance.new("SpecialMesh", part)
	specialMesh.MeshType = "Sphere"
	specialMesh.Scale = createVector(25, 25, 25) * scale * (weak and 0.5 or 1)
	part.Parent = _WorldOrigin
	TweenService:Create(part, TweenInfo.new(0.22), {
		Transparency = 1
	}):Play()
	TweenService:Create(specialMesh, TweenInfo.new(0.22, Enum.EasingStyle.Exponential), {
		Scale = Vector3.new(0, 0, length),
		Offset = Vector3.new(0, 0, -length / 2)
	}):Play()

	if not weak then
		for i = 2, 5 do
			local cFrame2 = cFrame * CFrame.new(0, 0, -length / 7 * i) * CFrame.Angles(1.5707963267948966, 0, 0)
			local clone2 = game.ReplicatedStorage.Assets.Models.ThinnerWind:Clone()
			clone2.Size = createVector(4, 2, 4)
			clone2.Transparency = 0.5
			clone2.CFrame = cFrame2
			clone2.Parent = _WorldOrigin
			local tween = TweenService:Create(clone2, TweenInfo.new(0.55 - i * 0.08, Enum.EasingStyle.Circular), {
				Transparency = 1,
				Size = createVector(10, 0.15, 10) * scale * 7 * (1 - i / 6 * 0.9),
				CFrame = cFrame2 * CFrame.new(0, scale * 25, 0)
			})
			tween.Completed:Connect(function()
				clone2:Destroy()
			end)
			tween:Play()
		end
	end

	wait(1)
	clone:Destroy()
	part:Destroy()
end

return func