local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FallStroll = {}
FallStroll.Name = "Fall Stroll"
FallStroll.Cost = 600
FallStroll.DandyStore = true
FallStroll.OverwriteAnimations = {
	Walk = "rbxassetid://137832441767081",
	Idle = "rbxassetid://140637612317120",
	Ability = "rbxassetid://118342764296824",
	Run = "rbxassetid://137476700597860",
	Quirk = "rbxassetid://84170898174857",
	Decode = "rbxassetid://117848938225873"
}
FallStroll.FaceTextures = {
	Normal = "rbxassetid://107798079376234",
	Blink = "rbxassetid://125201282576086",
	Hurt = "rbxassetid://71906519503839"
}
FallStroll.USE_SKIN_MODEL = true

function FallStroll.ApplySkin(instance, instance2)
	local Universe = require(ReplicatedStorage.SharedUtils.Universe)

	if Universe:IsLobby() then
		return
	end

	local clone = instance2:WaitForChild("Head"):WaitForChild("Attachment"):Clone()
	clone.Parent = instance:WaitForChild("Head")
end

function FallStroll.UseAbility(instance)
	instance:WaitForChild("Head"):WaitForChild("Attachment"):WaitForChild("ParticleEmitter"):Emit(2)
end

return FallStroll