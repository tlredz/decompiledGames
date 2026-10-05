local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Network = require(ReplicatedStorage.Modules.Network)
Network:listen("Tool/EmitParticles", function(object, instance)
	if not object then
		return
	end

	for _, v in object:QueryDescendants("ParticleEmitter") do
		local v2 = v
		task.spawn(function()
			local emitDelay = v2:GetAttribute("EmitDelay")
			local emitDuration = v2:GetAttribute("EmitDuration")
			local emitCount = v2:GetAttribute("EmitCount")
			local decal = v2.Name == "Card" and instance and instance:FindFirstChild("Decal", true)

			if decal then
				v2.Texture = decal.Texture
			end

			if emitDelay then
				task.wait(emitDelay)
			end

			if emitCount then
				v2:Emit(emitCount)
			else
				v2.Enabled = true
			end

			task.wait(emitDuration or 1.5)
			v2.Enabled = false
		end)
	end
end)