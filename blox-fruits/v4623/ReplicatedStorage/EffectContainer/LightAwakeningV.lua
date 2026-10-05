local createVector = vector.create
workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Effect = require(game.ReplicatedStorage:WaitForChild("Effect"))
Effect.new("RingWind")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local FX = require(game.ReplicatedStorage.FX)
local _ = Util.Sound
local _ = Util.MasterClock
local _ = workspace._WorldOrigin
local TweenService = game:GetService("TweenService")
game:GetService("RunService")

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

return function(p)
	local cFrame = p.CFrame

	if (cFrame.p - workspace.CurrentCamera.CFrame.p).magnitude > 600 then
		return
	end

	Util.Sound:Play("BlastCharge", cFrame.p)
	local v = math.random(1, 360)
	local clone = FX:WaitForChild("Attachments").LightExplosion2:Clone()
	clone.PointLight:Destroy()
	clone.Star.Rotation = NumberRange.new(v)
	clone.Star_Color.Rotation = NumberRange.new(v)
	clone.Parent = workspace.Terrain
	clone.CFrame = cFrame + createVector(0, 80, 0)
	clone.Star.Size = ScaleParticle(clone.Star, 6)
	clone.Star_Color.Size = ScaleParticle(clone.Star_Color, 6)
	clone.Star:Emit(1)
	clone.Star_Color:Emit(1)
	wait()
	clone.Star:Emit(1)
	clone.Star_Color:Emit(1)
	wait()
	clone.Star:Emit(1)
	clone.Star_Color:Emit(1)
	wait()
	clone.Star:Emit(1)
	clone.Star_Color:Emit(1)
	wait()
	clone.Star:Emit(1)
	clone.Star_Color:Emit(1)
	wait(0.2)
	Util.Debris:AddItem(clone, 1)

	for i = 1, 45 do
		local v2 = i * 0.8 + 45

		for i2 = 1, math.random(2, 3) do
			local v3 = cFrame * CFrame.new(v2 * (math.random() - 0.5) * 2, 80, v2 * (math.random() - 0.5) * 2)
			Effect.new("LightKnockback"):replicate({
				CFrame = CFrame.new(v3.p, v3.p - createVector(0, 80, 0)),
				Length = 85,
				Scale = 0.6,
				Weak = true
			})
			local v4 = i2
			local v5 = i
			coroutine.resume(coroutine.create(function()
				if v4 == 1 and v5 % 3 == 0 then
					Util.Sound:Play("DiscFire2", v3)
				end

				wait(0.2)

				if v4 == 1 and v5 % 2 == 0 then
					Util.Sound:Play("LightBoomShort", v3 - createVector(0, 80, 0))
				end

				local v7 = math.random(1, 360)
				local clone2 = FX:WaitForChild("Attachments").LightExplosion2:Clone()
				clone2.PointLight.Range = 80
				clone2.PointLight.Brightness = 5
				clone2.Star.Rotation = NumberRange.new(v7)
				clone2.Star_Color.Rotation = NumberRange.new(v7)
				clone2.Parent = workspace.Terrain
				clone2.CFrame = v3 - createVector(0, 80, 0)
				clone2.Explosion.Drag = 2
				clone2.Explosion.Size = ScaleParticle(clone2.Explosion, 10)
				clone2.Star.Size = ScaleParticle(clone2.Star, 10)
				clone2.Star_Color.Size = ScaleParticle(clone2.Star_Color, 10)
				clone2.Explosion:Emit(5)
				clone2.Star:Emit(1)
				clone2.Star_Color:Emit(1)
				TweenService:Create(clone2.PointLight, TweenInfo.new(0.35), {
					Range = 0,
					Brightness = 0
				}):Play()
				wait(0.5)
				clone2:Destroy()
			end))
		end

		wait()
	end
end