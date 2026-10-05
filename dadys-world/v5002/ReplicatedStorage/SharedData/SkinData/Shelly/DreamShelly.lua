local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DreamShelly = {}
DreamShelly.Name = "Star-Time Shelly"
DreamShelly.OverwriteAnimations = {
	Walk = "rbxassetid://97569421338492",
	Idle = "rbxassetid://81739221582887",
	Ability = "rbxassetid://132074253259163",
	Run = "rbxassetid://87952146739155",
	Quirk = "rbxassetid://82843565036740",
	Decode = "rbxassetid://110404137593348"
}
DreamShelly.FaceTextures = {
	Normal = "rbxassetid://74210666376037",
	Blink = "rbxassetid://84527293798215",
	Hurt = "rbxassetid://79073924529831"
}
DreamShelly.USE_SKIN_MODEL = true

function DreamShelly.ApplySkin(instance, instance2)
	local Universe = require(ReplicatedStorage.SharedUtils.Universe)

	if Universe:IsLobby() then
		return
	end

	local clone = instance2:WaitForChild("Head"):WaitForChild("Attachment"):Clone()
	clone.Parent = instance:WaitForChild("Head")
end

function DreamShelly.UseAbility(instance)
	instance:WaitForChild("Head"):WaitForChild("Attachment"):WaitForChild("ParticleEmitter"):Emit(1)
end

return DreamShelly