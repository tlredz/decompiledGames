local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ShellyDino = {}
ShellyDino.Name = "Dino Snore"
ShellyDino.Cost = 600
ShellyDino.DandyStore = true
ShellyDino.OverwriteAnimations = {
	Walk = "rbxassetid://73020193119336",
	Idle = "rbxassetid://100849345213447",
	Ability = "rbxassetid://112530194612519",
	Run = "rbxassetid://77057435398906",
	Quirk = "rbxassetid://134568535005501",
	Decode = "rbxassetid://125231549786789"
}
ShellyDino.FaceTextures = {
	Normal = "rbxassetid://100694837221367",
	Blink = "rbxassetid://111716001445477",
	Hurt = "rbxassetid://129696024562724"
}
ShellyDino.USE_SKIN_MODEL = true

function ShellyDino.ApplySkin(instance, instance2)
	local Universe = require(ReplicatedStorage.SharedUtils.Universe)

	if Universe:IsLobby() then
		return
	end

	local clone = instance2:WaitForChild("Head"):WaitForChild("Attachment"):Clone()
	clone.Parent = instance:WaitForChild("Head")
end

function ShellyDino.UseAbility(instance)
	instance:WaitForChild("Head"):WaitForChild("Attachment"):WaitForChild("ParticleEmitter"):Emit(2)
end

return ShellyDino