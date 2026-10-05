local createVector = vector.create
workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Effect = require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.MasterClock
local _WorldOrigin = workspace._WorldOrigin
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
	return NumberSequence.new(numberSequenceKeypoints)
end

return function(data)
	local HRP = data.HRP
	local part = data.Part
	local mousePos = data.MousePos

	if not data.Active or (part.Position - workspace.CurrentCamera.CFrame.Position).Magnitude > 1200 then
		return
	end

	local clone = script.Beam:Clone()
	clone.CFrame = part.CFrame
	clone.Parent = _WorldOrigin

	for _, emitter in pairs(clone.Attachment:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter.Rate / 10)
		end
	end

	local position = part.Position
	local part2 = Instance.new("Part")
	part2.Color = Color3.fromRGB(255, 255, 175)
	part2.Shape = "Ball"
	part2.Size = createVector(10, 10, 10)
	part2.Material = "Neon"
	part2.Position = position
	part2.Anchored = true
	part2.CanQuery = false
	part2.CanCollide = false
	part2.Parent = _WorldOrigin
	Effect.new("SuperhumanV2.Travel"):replicate({
		Anchor = part2,
		Scale = 3,
		Duration = 1,
		Color = Color3.fromRGB(255, 255, 100)
	})
	Util.Sound:Play("TrailLightInit", position)
	local v = Util.Sound:Play("TrailLightLoop", part2)
	local lastTime = tick()
	local lastTime2 = tick()
	local v2 = 0.016666666666666666

	while not (tick() - lastTime2 > 0.5) or data.Active:IsDescendantOf(workspace) and tick() - lastTime2 < 3 do
		local _, v3, _ = Util.Ray(part.Position, mousePos.Value - part.Position, { HRP.Parent })
		position = position:Lerp(v3, v2 * 6.6)

		if tick() - lastTime > 0.35 then
			lastTime = tick()
			Effect.new("SuperhumanV2.Travel"):replicate({
				Anchor = part2,
				Scale = 3,
				Duration = 0.36666666666666664,
				Color = Color3.fromRGB(255, 255, 100)
			})
		end

		local v4

		if (position - HRP.Position).Magnitude > 300 then
			v4 = CFrame.new(HRP.Position, position) * createVector(0, 0, -300)
		else
			v4 = position
		end

		part2.Position = v4
		clone.CFrame = part.CFrame
		clone.Attachment2.WorldPosition = v4
		v2 = task.wait()
	end

	Util.Sound:FadeOut(v, 0.4)
	TweenService:Create(part2, TweenInfo.new(0.4), {
		Size = createVector(0, 0, 0)
	}):Play()

	for _, effect in pairs(clone:GetDescendants()) do
		if effect:IsA("Beam") then
			TweenService:Create(effect, TweenInfo.new(0.4), {
				Width0 = 0,
				Width1 = 0
			}):Play()
		elseif effect:IsA("ParticleEmitter") then
			Util.ScaleParticle({
				Emitter = effect,
				Time = 0.4,
				Scale = 0.01
			})
			effect.Enabled = false
		end
	end

	task.wait(0.5)
	clone:Destroy()
	wait(0.3)
	part2:Destroy()
end