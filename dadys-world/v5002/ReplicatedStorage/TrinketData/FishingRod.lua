local FishingRod = {
	Name = "Fishing Rod",
	Icon = "rbxassetid://18727299610",
	Rarity = "Common",
	Description = "Highlights all Machine locations for the user when a new Floor arrives for 5 seconds.",
	TrinketType = "Passive",
	MonsterTrinket = true,
	Cost = 350
}
FishingRod.Requirement1 = { "Coin", FishingRod.Cost }
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local fishingRodEffects = ReplicatedStorage.Modules.Zones.FishingRodEffects

function FishingRod.ApplyTrinket(character, _)
	local playerFromCharacter = Players:GetPlayerFromCharacter(character)

	if not playerFromCharacter then
		return
	end

	ReplicatedStorage.Events.ClientAbilityEvent:FireClient(playerFromCharacter, fishingRodEffects, character)
end

function FishingRod.RemoveTrinket(instance)
	local trinkets = instance:WaitForChild("Trinkets")
	local trinket1 = trinkets:FindFirstChild("Trinket1")
	local trinket2 = trinkets:FindFirstChild("Trinket2")

	if not (trinket1 and trinket2) then
		return "CantRemove"
	end

	if trinket1.Value == script.Name then
		trinket1.Value = "None"
		return "Slot1"
	end

	if trinket2.Value ~= script.Name then
		return "CantRemove"
	end

	trinket2.Value = "None"
	return "Slot2"
end

return FishingRod