local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
workspace:WaitForChild("Map")
ReplicatedStorage:WaitForChild("Assets")
local FX = require(game.ReplicatedStorage.FX)
local dough = FX:WaitForChild("Dough")
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local misc = Util.Misc
local distributedLoop = Util.DistributedLoop
local _ = Util.RayCastWhitelist
local colorSequencer = Util.ColorSequencer
local _ = workspace.CurrentCamera
local vector2 = Vector2.new(4, 24)

local function scaleMark(clone, scale, vector3)
	local v = scale or Vector2.new(1, 1)
	local v2 = vector3 or Vector2.new(1, 1)
	local X = v.X
	local Y = v.Y
	local v3 = X / vector2.X * v2.X
	local v4 = Y / vector2.Y * v2.Y
	local beam = clone:FindFirstChildOfClass("Beam")
	beam.Attachment0.Position = beam.Attachment1.Position * createVector(1, 1, 0) + Vector3.new(0, 0, vector2.Y * v4)
	beam.Width0 = 15 * v3
	beam.Width1 = 5 * v3
end

local function scaleParticles(items, scale, vector3)
	local v = scale or Vector2.new(1, 1)
	local v2 = vector3 or Vector2.new(1, 1)
	local X = v.X
	local Y = v.Y
	local v3 = 0 + X / vector2.X * v2.X
	local v4 = 0 + Y / vector2.Y * v2.Y

	for _, item in pairs(items) do
		local v5 = item.Particle.Name == "FireParticles" and ({ 0.5, 1.25 } or { 0.4, 0.8 }) or { 0.4, 0.8 }
		local v6 = misc.CalculateVelocity(vector2.Y * v4, item.Particle.Lifetime.Max, item.Particle.Drag) or 0
		item.Particle.Speed = NumberRange.new(v6 * v5[1], v6 * v5[2])
		item.Particle.Size = misc.ScaleKeypoints(item.Size, (math.max(0.1, X / 6 * v3)))
		item.Particle.Acceleration = item.Acceleration * X / 7 * v3
	end
end

return function(data)
	local scale = data.Scale or Vector2.new(1, 10)
	local cFrame = data.CFrame
	local hit = data.Hit
	local fadeIn = data.FadeIn or 1
	local fadeOut = data.FadeOut or 1
	local lifetime = data.Lifetime or 1
	local clone = dough.Models.FlameMark:Clone()
	local beam = clone:FindFirstChildOfClass("Beam")
	local v = 0
	local v2 = {}

	for _, emitter in pairs(clone:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		v = math.max(v, emitter.Lifetime.Max)

		if hit and (emitter.Name == "Rocks" or emitter.Name == "Dust") then
			emitter.Color = ColorSequence.new(hit.Color)
		end

		emitter.Enabled = false
		table.insert(v2, {
			Particle = emitter,
			Size = emitter.Size.Keypoints,
			Speed = emitter.Speed,
			Acceleration = emitter.Acceleration
		})
	end

	local v3 = fadeIn * 4
	local v4 = colorSequencer({
		Color3.new(1, 1, 0),
		Color3.new(1, 0.5, 0),
		Color3.new(1, 0, 0),
		Color3.new()
	}, v3, v3 * 0.25)
	beam.Segments = 2 * v4:getSegments()
	scaleMark(clone, scale, Vector2.new(0, 1))
	scaleParticles(v2, scale, Vector2.new(0, 1))
	clone.CFrame = cFrame
	clone.Parent = _WorldOrigin
	Util.Debris:AddItem(clone, v3 + fadeIn + fadeOut + lifetime + v + 0.1)

	for _, v5 in pairs(v2) do
		local emit = v5.Particle:GetAttribute("Emit") or 0
		v5.Particle:Emit(emit + scale.Y / 2)
		v5.Particle.Enabled = true
	end

	distributedLoop:add(function(p, p2)
		local v5 = math.min(1, p / fadeIn)
		local quad = Util.Tween.ease["in"].quad(v5, 0, 1, 1)
		scaleMark(clone, scale, Vector2.new(quad, 1))
		scaleParticles(v2, scale, Vector2.new(quad, 1))
		v4:update(p2)
		beam.Color = v4:toColorSequence(true)

		if v5 == 1 then
			return true
		end
	end)
	task.wait(fadeIn)

	for _, v5 in pairs(v2) do
		v5.Particle.Enabled = false
	end

	distributedLoop:add(function(p, p2)
		local v5 = math.min(1, p / lifetime)
		v4:update(p2)
		beam.Color = v4:toColorSequence(true)

		if v5 == 1 then
			return true
		end
	end)
	task.wait(lifetime)
	distributedLoop:add(function(p, p2)
		local v5 = math.min(1, p / fadeOut)
		local point = Util.Tween.point(0.25, 1, v5)
		v4:update(p2)
		beam.Color = v4:toColorSequence(true)
		beam.Transparency = NumberSequence.new(point)

		if v5 == 1 and v4.finished then
			return true
		end
	end)
	task.wait(fadeOut)
end