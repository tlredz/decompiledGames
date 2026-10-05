local ReplicatedStorage = game:GetService("ReplicatedStorage")
local moonPackHeirloomEffects = ReplicatedStorage.Modules.Zones.MoonPackHeirloomEffects
local MoonPackHeirloom = {}
MoonPackHeirloom.Name = "Moon Pack Heirloom"
MoonPackHeirloom.Icon = "rbxassetid://105132110200706"
MoonPackHeirloom.Rarity = "Common"
MoonPackHeirloom.Description = "Highlights all other teammates' locations for 3 seconds for the user after any user completes a machine."
MoonPackHeirloom.TrinketType = "Passive"
MoonPackHeirloom.MonsterTrinket = true
MoonPackHeirloom.Cost = 0
MoonPackHeirloom.Requirement1 = { "None", 0 }

function MoonPackHeirloom.ApplyTrinket(character)
	local playerFromCharacter = game.Players:GetPlayerFromCharacter(character)

	if not playerFromCharacter then
		return
	end

	ReplicatedStorage.Events.ClientAbilityEvent:FireClient(playerFromCharacter, moonPackHeirloomEffects, character)
end

function MoonPackHeirloom.RemoveTrinket(instance)
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

return MoonPackHeirloom