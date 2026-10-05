local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
local random = Random.new()
local vector2 = Vector3.new()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local explosion = FX:WaitForChild("BuddhaEffects").Explosion
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.MasterClock
local lightningBolt2 = Util.LightningBolt2
local promise = Util.Promise
local heartbeatLoopFor = Util.HeartbeatLoopFor
local heartbeatLoopFor2 = heartbeatLoopFor.HeartbeatLoopFor
local awaitHeartbeatLoopFor = heartbeatLoopFor.AwaitHeartbeatLoopFor
local Shockwave = require(script.Parent:WaitForChild("Shockwave"))

local function RandomVectorOffsetBetween(p, p2, p3)
	return (CFrame.lookAt(Vector3.new(), p) * CFrame.Angles(0, 0, random:NextNumber(0, 6.283185307179586)) * CFrame.Angles(
		math.acos((random:NextNumber(math.cos(p3), (math.cos(p2))))),
		0,
		0
	)).LookVector
end

local function circleCurve(p, position, p2, p3)
	return position + (CFrame.lookAt(Vector3.new(), p3) * CFrame.Angles(0, 0, 6.283185307179586 * p) * CFrame.new(
		p2,
		0,
		0
	)).Position
end

local function buddhaExplosion(position, p, p2, instance)
	local _ = Workspace.CurrentCamera
	local model = Instance.new("Model")
	model.Parent = _WorldOrigin
	local v = {}
	local v2 = {}
	v.WorldPosition = vector2
	v.WorldAxis = vector2
	v2.WorldPosition = vector2
	v2.WorldAxis = vector2
	local color = Color3.fromHSV(0.142417, 0.647059, 1)
	local color2 = Color3.fromHSV(0.166667, 0.501961, 1)

	if instance then
		color = instance.Shifted:GetAttribute("Shifted_Color1")
		color2 = instance.Shifted:GetAttribute("Shifted_Color1"):Lerp(Color3.fromRGB(0, 0, 0), 0.1)
	end

	if not p2 then
		promise.try(function()
			Shockwave(position, p, instance)
		end)
		promise.try(function()
			local v5 = lightningBolt2.new(v, v2, 15)
			v5.MaxRadius = 0
			v5.AnimationSpeed = 0
			v5.Thickness = math.clamp(0.35 * p, 2, 10)
			v5.MinThicknessMultiplier = 1
			v5.MaxThicknessMultiplier = 1
			v5.PulseSpeed = 1000
			v5.Color = color
			local v6 = 2.5 * p
			local lookVector = RandomVectorOffsetBetween(createVector(0, 1, 0), 0.7853981633974483, 1.2217304763960306)

			function v5.SpaceCurveFunction(p3)
				return (circleCurve(p3, position, v6, lookVector))
			end

			heartbeatLoopFor2(0.8, function(p3)
				local v8 = 1 + p3 * 3
				v6 = 2.5 * p * v8
			end)
			promise.delay(0.3):andThen(function()
				v5:DestroyDissipate(0.5, 1)
			end)
		end)
		promise.try(function()
			for _ = 1, 1 do
				local v5 = lightningBolt2.new(v, v2, 12)
				v5.MaxRadius = 0
				v5.AnimationSpeed = 0
				v5.Thickness = math.clamp(0.35 * p, 2, 10)
				v5.MinThicknessMultiplier = 1
				v5.MaxThicknessMultiplier = 1
				v5.PulseSpeed = 1000
				v5.Color = color2
				local v6 = 1.5 * p
				local lookVector = RandomVectorOffsetBetween(
					createVector(0, 1, 0),
					0.7853981633974483,
					1.2217304763960306
				)

				function v5.SpaceCurveFunction(p3)
					return (circleCurve(p3, position, v6, lookVector))
				end

				heartbeatLoopFor2(0.5, function(p3)
					local v9 = 1 + p3 * 3
					v6 = 1.5 * p * v9
				end)
				promise.delay(0.15):andThen(function()
					v5:DestroyDissipate(0.35, 1)
				end)

				for i = 1, 2 do
					local v10 = lightningBolt2.new(v, v2, 3)
					v10.MaxRadius = 0
					v10.AnimationSpeed = 0
					v10.Thickness = math.clamp(0.3 * p, 2, 10)
					v10.MinThicknessMultiplier = 1
					v10.MaxThicknessMultiplier = 1
					v10.PulseSpeed = 1000
					v10.Color = color2
					local v11 = math.random()
					local v13 = v5
					local v14 = 0.5 * (i - 1 + v11) / 5

					function v10.SpaceCurveFunction(p3)
						return v13.SpaceCurveFunction(v14) * (1 + (1.4 + v11) * p3) - position * (1.4 + v11) * p3
					end

					promise.delay(0.15):andThen(function()
						v10:DestroyDissipate(0.35, 1)
					end)
				end
			end
		end)
	end

	local clone = explosion.SmokeMesh:Clone()
	clone.Size = createVector(3, 3, 3) * p
	clone.CFrame = CFrame.new(position) * CFrame.Angles(0, math.random() * 2 * 3.141592653589793, 0)
	clone.Parent = model
	clone.Attachment.Pulse.Size = NumberSequence.new(0, (math.min(200, 10 * p)))
	clone.Attachment.Pulse:Emit(1)
	clone.Attachment.Spikes.Size = NumberSequence.new(0, (math.min(200, 10 * p)))
	clone.Attachment.Spikes:Emit(1)
	clone.Attachment.Rays.Size = NumberSequence.new(0, (math.min(200, 7.5 * p)))
	clone.Attachment.Rays.Enabled = true
	clone.Attachment.Star.Size = NumberSequence.new(0, (math.min(200, 4 * p)))
	clone.Attachment.Star.Enabled = true
	clone.Attachment.Sparkle.Size = NumberSequence.new(0.2 * p, 0)
	clone.Attachment.Sparkle.Speed = NumberRange.new(30 * p, 37 * p)
	clone.Attachment.Sparkle:Emit(27)

	if instance then
		Util.SetParentOverrideWithColor(clone, model, instance.Parent, instance.Name)
	end

	promise.delay(0.2):andThen(function()
		clone.Attachment.Rays.Enabled = false
		clone.Attachment.Star.Enabled = false
	end)
	awaitHeartbeatLoopFor(0.5, function(p3)
		local transparency = p3 / 0.5
		clone.Size = createVector(3, 3, 3) * p * (1 + transparency)
		clone.Transparency = transparency
	end)
	clone.Transparency = 1
	promise.delay(0.5):await()
	model:Destroy()
end

return buddhaExplosion