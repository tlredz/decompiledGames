local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local PrehistoricPeppermint = {}
PrehistoricPeppermint.Name = "Prehistoric Peppermint"
PrehistoricPeppermint.TowerName = "Shelly"
PrehistoricPeppermint.Description = "No description yet"
PrehistoricPeppermint.Mastery = false
PrehistoricPeppermint.Cost = 600
PrehistoricPeppermint.Unlocks = require(ReplicatedStorage2.SharedData.ReleaseTimes).Christmas2025_W3
PrehistoricPeppermint.Christmas = true
PrehistoricPeppermint.HolidaySkin = true
PrehistoricPeppermint.OverwriteAnimations = {
	Walk = "rbxassetid://98998508147559",
	Idle = "rbxassetid://93618167673642",
	Ability = "rbxassetid://74903520747920",
	Run = "rbxassetid://97609426396066",
	Quirk = "rbxassetid://117141874193816",
	Decode = "rbxassetid://95025351030595"
}
PrehistoricPeppermint.FaceTextures = {
	Normal = "rbxassetid://126219870457245",
	Blink = "rbxassetid://82042445122833",
	Hurt = "rbxassetid://88530054101306"
}
PrehistoricPeppermint.USE_SKIN_MODEL = true

function PrehistoricPeppermint.ApplySkin(instance, instance2)
	local Universe = require(ReplicatedStorage.SharedUtils.Universe)

	if Universe:IsLobby() then
		return
	end

	local clone = instance2:WaitForChild("Head"):WaitForChild("Attachment"):Clone()
	clone.Parent = instance:WaitForChild("Head")
end

function PrehistoricPeppermint.UseAbility(instance)
	instance:WaitForChild("Head"):WaitForChild("Attachment"):WaitForChild("ParticleEmitter"):Emit(2)
end

return PrehistoricPeppermint