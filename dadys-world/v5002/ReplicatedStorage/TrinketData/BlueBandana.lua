local StatModifierManager = require(game.ReplicatedStorage.Modules.Data.StatModifierManager)
local v = {}
local v2 = {}
local BlueBandana = {
	Name = "Blue Bandana",
	Icon = "rbxassetid://17653809331",
	Rarity = "Common",
	Description = "Increases your Extraction Speed by 7.5%, but decreases Skill Check chance by 5%.",
	TrinketType = "Passive",
	MonsterTrinket = true,
	Cost = 350
}
BlueBandana.Requirement1 = { "Coin", BlueBandana.Cost }

function BlueBandana.ApplyTrinket(instance)
	instance:WaitForChild("Stats"):WaitForChild("SkillCheckChance")
	v[instance] = StatModifierManager.ApplyModifier(instance, "DecodeSpeedModifier", 1.075, "BlueBandana", {
		category = "trinket"
	})
	v2[instance] = StatModifierManager.ApplyAdditiveSkillCheckChance(instance, -5, "BlueBandana")
end

function BlueBandana.RemoveTrinket(instance)
	local trinkets = instance:WaitForChild("Trinkets")
	instance:WaitForChild("Stats")
	local trinket1 = trinkets:FindFirstChild("Trinket1")
	local trinket2 = trinkets:FindFirstChild("Trinket2")

	if not (trinket1 and trinket2) then
		return "CantRemove"
	end

	if v[instance] then
		StatModifierManager.RemoveModifier(instance, "DecodeSpeedModifier", v[instance])
		v[instance] = nil
	end

	if v2[instance] then
		StatModifierManager.RemoveAdditiveSkillCheckChance(instance, v2[instance])
		v2[instance] = nil
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

return BlueBandana