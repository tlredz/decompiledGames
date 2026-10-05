local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Network = require(ReplicatedStorage.Modules.Network)
Network:listen("Tool/SetParticlesEnabled", function(object, enabled: boolean)
	for _, v in object:QueryDescendants("ParticleEmitter") do
		v.Enabled = enabled
	end
end)