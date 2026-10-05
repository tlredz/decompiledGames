local Util = require(game.ReplicatedStorage.Util)
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local _ = Util.TweenModel
local particleScaler = Util.ParticleScaler
local currentCamera = workspace.CurrentCamera
return function(data)
	local cFrame = data.CFrame
	local scale = data.Scale or 1
	local duration = data.Duration or data.TimeInfluence or 1
	local magnitude = (currentCamera.CFrame.p - cFrame.p).Magnitude

	if 1000 + 4 * scale < magnitude then
		return
	end

	local clone = script.SwimSplash:Clone()
	clone.CFrame = cFrame
	clone.Parent = _WorldOrigin
	Util.Sound:Play("Other.WaterSplash", data.Root or cFrame.p, 2 * scale, 0.9 / duration, data.Volume)
	local v = 0

	for _, emitter in pairs(clone:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		v = math.max(v, emitter.Lifetime.Max)
		particleScaler.Particle(emitter, scale, true)
		emitter.Lifetime = particleScaler.NumberRange(emitter.Lifetime, duration)
		local emitCount = emitter:GetAttribute("EmitCount")
		local emitDelay = emitter:GetAttribute("EmitDelay")
		-- equivalent calls inferred from this helper; original call sites unknown
		local v3 = emitter

		local function fn()
			if emitCount then
				v3:Emit(emitCount)
			end
		end

		if emitDelay and emitDelay > 0 then
			task.delay(emitDelay, fn)
		else
			fn() -- equivalent call inferred; original call site unknown
		end
	end

	Util.Debris:AddItem(clone, v + 0.1)
end