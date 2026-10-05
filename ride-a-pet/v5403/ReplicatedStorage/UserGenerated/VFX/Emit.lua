local EmitOnce = require(game.ReplicatedStorage.UserGenerated.VFX.EmitOnce)
local Emit

Emit = function(emitter)
	local v = 0

	if emitter:IsA("ParticleEmitter") then
		v = math.max(v, EmitOnce(emitter))
	end

	for _, child in ipairs(emitter:GetChildren()) do
		v = math.max(v, Emit(child))
	end

	return v
end

return Emit