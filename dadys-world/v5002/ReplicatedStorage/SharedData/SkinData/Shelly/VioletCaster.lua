local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VioletCaster = {}
VioletCaster.Name = "Violet Caster"
VioletCaster.TowerName = "Shelly"
VioletCaster.Description = "No description yet"
VioletCaster.Mastery = false
VioletCaster.Cost = 600
VioletCaster.Halloween = true
VioletCaster.HolidaySkin = true
VioletCaster.HolidayYear = 2025
VioletCaster.OverwriteAnimations = {
	Walk = "rbxassetid://97569421338492",
	Idle = "rbxassetid://81739221582887",
	Ability = "rbxassetid://132074253259163",
	Run = "rbxassetid://87952146739155",
	Quirk = "rbxassetid://82843565036740",
	Decode = "rbxassetid://110404137593348"
}
VioletCaster.FaceTextures = {
	Normal = "rbxassetid://104349109931004",
	Blink = "rbxassetid://122275771077633",
	Hurt = "rbxassetid://139286824938198"
}
VioletCaster.USE_SKIN_MODEL = true

function VioletCaster.ApplySkin(instance, instance2)
	local Universe = require(ReplicatedStorage.SharedUtils.Universe)

	if Universe:IsLobby() then
		return
	end

	local clone = instance2:WaitForChild("Head"):WaitForChild("Attachment"):Clone()
	clone.Parent = instance:WaitForChild("Head")
end

function VioletCaster.UseAbility(instance)
	instance:WaitForChild("Head"):WaitForChild("Attachment"):WaitForChild("ParticleEmitter"):Emit(2)
end

return VioletCaster