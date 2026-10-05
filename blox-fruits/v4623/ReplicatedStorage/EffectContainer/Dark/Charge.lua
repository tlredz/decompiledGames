local Util = require(game.ReplicatedStorage:WaitForChild("Util"))
local FX = require(game.ReplicatedStorage.FX)
local charge = FX:WaitForChild("Dark").Charge
local sound = Util.Sound
local _ = Util.Misc
local _ = Util.Debris
local particleScaler = Util.ParticleScaler
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local v = {}

local function findByID(p)
	for k, v2 in pairs(v) do
		if v2.Id == p then
			return v2, k
		end
	end
end

return function(data)
	local effectId = data.EffectId

	if data.Toggle then
		local root = data.Root
		local scale = data.Scale or 1
		local v2 = {}
		local clone = charge.Charge:Clone()
		clone.Anchored = false
		clone.Weld.Part0 = root
		v2.Id = effectId
		v2.Effect = clone
		v2.Event = root.Destroying:Connect(function()
			clone:Destroy()
			v2.Event:Disconnect()
			local id = v2.Id
			local v3 = nil
			local v4 = nil

			for k, v6 in pairs(v) do
				if v6.Id ~= id then
					continue
				end

				v3, v4 = k, v6 -- parallel
				break
			end

			if v4 then
				v[v3] = nil
			end
		end)
		clone.Parent = _WorldOrigin
		sound:Play("DarkStartup", clone, nil, 1.25)
		table.insert(v, v2)

		for _, descendant in pairs(clone:GetDescendants()) do
			if descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") then
				descendant.Enabled = true
			end

			if descendant:IsA("ParticleEmitter") then
				particleScaler.Particle(descendant, scale)
			end

			if descendant:IsA("Attachment") then
				descendant.Position *= scale
			end

			if not descendant:IsA("Beam") then
				continue
			end

			descendant.CurveSize0 *= scale
			descendant.CurveSize1 *= scale
			descendant.Width0 *= scale
			descendant.Width1 *= scale
		end
	else
		local v3, v4

		for k, v5 in pairs(v) do
			if v5.Id ~= effectId then
				continue
			end

			v3, v4 = k, v5 -- parallel
			break
		end

		if not v4 then
			return
		end

		v4.Effect.Weld:Destroy()
		v4.Effect.Anchored = true
		local v5 = 0

		for _, emitter in pairs(v4.Effect:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local max = emitter.Lifetime.Max
			v5 = math.max(v5, max)
			emitter.Enabled = false
		end

		Util.DistributedLoop:add(function(p, _)
			local v6 = math.min(1, p / v5)
			local sine = Util.Tween.ease.out.sine(v6, 0, 1, 1)

			for _, beam in pairs(v4.Effect:GetDescendants()) do
				if beam:IsA("Beam") then
					beam.Transparency = NumberSequence.new(sine)
				end
			end

			if v6 == 1 then
				return true
			end
		end)
		task.delay(v5 + 0.1, function()
			v4.Effect:Destroy()
		end)
		v4.Event:Disconnect()
		v[v3] = nil
	end
end