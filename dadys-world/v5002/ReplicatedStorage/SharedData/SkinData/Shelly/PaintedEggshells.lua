local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local PaintedEggshells = {}
PaintedEggshells.Name = "Painted Eggshells"
PaintedEggshells.TowerName = "Shelly"
PaintedEggshells.Description = "No description yet"
PaintedEggshells.Mastery = false
PaintedEggshells.Cost = 600
PaintedEggshells.Unlocks = require(ReplicatedStorage2.SharedData.ReleaseTimes).Easter2026_W5
PaintedEggshells.Easter = true
PaintedEggshells.HolidaySkin = true
PaintedEggshells.OverwriteAnimations = {
	Walk = "rbxassetid://97569421338492",
	Idle = "rbxassetid://81739221582887",
	Ability = "rbxassetid://132074253259163",
	Run = "rbxassetid://87952146739155",
	Quirk = "rbxassetid://82843565036740",
	Decode = "rbxassetid://110404137593348"
}
PaintedEggshells.FaceTextures = {
	Normal = "rbxassetid://136407941866211",
	Blink = "rbxassetid://117256428289977",
	Hurt = "rbxassetid://114804754695667"
}
PaintedEggshells.USE_SKIN_MODEL = true

function PaintedEggshells.ApplySkin(instance, instance2)
	local Universe = require(ReplicatedStorage.SharedUtils.Universe)

	if Universe:IsLobby() then
		return
	end

	local clone = instance2:WaitForChild("Head"):WaitForChild("Attachment"):Clone()
	clone.Parent = instance:WaitForChild("Head")
end

function PaintedEggshells.UseAbility(instance)
	instance:WaitForChild("Head"):WaitForChild("Attachment"):WaitForChild("ParticleEmitter"):Emit(2)
end

return PaintedEggshells