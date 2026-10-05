local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local Pool = require(ReplicatedStorage:WaitForChild("Pool"))
workspace:WaitForChild("Map")
local FX = require(game.ReplicatedStorage.FX)
ReplicatedStorage:WaitForChild("Assets")
local dough = FX:WaitForChild("Dough")
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local misc = Util.Misc
local _ = Util.DistributedLoop
local _ = Util.RayCastWhitelist
local currentCamera = workspace.CurrentCamera
local v = Pool.new(string.format("Dough/%s%s", script.Parent.Name, script.Name))
v:setAction(function(object, _)
	local now = tick()

	for _, v2 in pairs(object.Pool) do
		local scale = v2.Scale
		local v3 = math.min(1, (now - v2.Start) / v2.Duration)
		local quad = Util.Tween.ease.inout.quad(v3, 0, 1, 1)
		v2.Particle.Acceleration = v2.Data.Acceleration * scale + v2.AccelerationInfluence * scale * quad

		if v3 == 1 then
			object:remove(v2)
		end
	end
end)
return function(data)
	local cFrame = data.CFrame
	local scale = data.Scale or 1
	local mode = data.Mode or ""
	local duration = data.Duration or data.DurationInfluence or 1
	local generic = 1
	local rocks = 1
	local dust = 1

	if typeof(duration) == "number" then
		dust = generic
		rocks = dust
		dust = rocks
	elseif typeof(duration) == "table" then
		if duration.Rocks then
			rocks = duration.Rocks
		end

		if duration.Dust then
			dust = duration.Dust
		end

		if duration.Generic then
			generic = duration.Generic
		end
	end

	local magnitude = (currentCamera.CFrame.p - cFrame.p).Magnitude

	if 100 + 3 * scale < magnitude then
		return
	end

	local rayCastWhitelist = Util.RayCastWhitelist(
		cFrame * createVector(0, 1, 0),
		-cFrame.UpVector * (2 + scale),
		{ workspace.Map }
	)
	local color

	if rayCastWhitelist then
		color = rayCastWhitelist.Color
	end

	local clone = dough.Models.RadialDebris:Clone()
	local scale2 = clone:GetAttribute("Scale") or 1
	local duration2 = 0
	local v3 = {}

	for _, emitter in pairs(clone:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local v4 = emitter.Name:find("Rock")
		local v5 = emitter.Name:find("Dust")

		if v4 then
			emitter.Lifetime = NumberRange.new(emitter.Lifetime.Min * rocks, emitter.Lifetime.Max * rocks)
		elseif v5 then
			emitter.Lifetime = NumberRange.new(emitter.Lifetime.Min * dust, emitter.Lifetime.Max * dust)
		else
			emitter.Lifetime = NumberRange.new(emitter.Lifetime.Min * generic, emitter.Lifetime.Max * generic)
		end

		duration2 = math.max(duration2, emitter.Lifetime.Max)
		emitter.Enabled = false
		table.insert(v3, {
			Particle = emitter,
			Data = {
				Size = emitter.Size.Keypoints,
				Speed = emitter.Speed,
				Acceleration = emitter.Acceleration
			}
		})
	end

	clone.Size *= scale / scale2
	clone.CFrame = cFrame + cFrame.UpVector * clone.Size.Y / 2 * (rayCastWhitelist and 1 or 0)

	for _, v4 in pairs(v3) do
		misc.ScaleParticle(v4.Particle, scale * (1 / scale2), v4.Data)
	end

	clone.Parent = _WorldOrigin
	local v4 = 0

	for _, particle in pairs(v3) do
		local v6 = false
		local v7 = particle.Particle.Name:find("Rock")
		local v8 = particle.Particle.Name:find("Dust")

		if v7 then
			local match = particle.Particle.Name:match("[%w]+(.+)")
			v6 = mode ~= "" and match ~= mode or false
		end

		if v6 then
			continue
		end

		if v7 then
			v:add({
				Scale = scale * (1 / scale2),
				Particle = particle,
				Data = particle.Data,
				Duration = duration2,
				AccelerationInfluence = createVector(0, -80, 0),
				Start = tick()
			})
		elseif v8 then
			v:add({
				Scale = scale * (1 / scale2),
				Particle = particle,
				Data = particle.Data,
				Duration = duration2,
				AccelerationInfluence = createVector(0, -10, 0),
				Start = tick()
			})
		end

		if color then
			local v9

			if v7 then
				v9 = color
			else
				v9 = color:Lerp(Color3.new(), 0.2)
			end

			particle.Particle.Color = ColorSequence.new(v9)
		end

		local enable = particle.Particle:GetAttribute("Enable")
		local emit = particle.Particle:GetAttribute("Emit")

		if enable and typeof(enable) == "number" then
			v4 = math.max(v4, enable)
			particle.Particle.Enabled = true
			local v9 = particle
			task.delay(enable, function()
				v9.Particle.Enabled = false
			end)
		end

		if emit then
			particle.Particle:Emit(emit)
		end
	end

	Util.Debris:AddItem(clone, duration2 * 2 + v4 + 0.1, function()
		v3 = {}
	end)
end