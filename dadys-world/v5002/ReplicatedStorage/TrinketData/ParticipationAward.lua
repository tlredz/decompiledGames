local StatModifierManager = require(game.ReplicatedStorage.Modules.Data.StatModifierManager)
local ParticipationAward = {
	Name = "Participation Award",
	Icon = "rbxassetid://18200131495",
	Rarity = "Common",
	Description = "Increases Skill Check chance by 25%, but decreases Skill Check size by 10%.",
	TrinketType = "Passive",
	MonsterTrinket = true,
	Cost = 350
}
ParticipationAward.Requirement1 = { "Coin", ParticipationAward.Cost }
local v = {}
local v2 = {}

function ParticipationAward.ApplyTrinket(instance)
	instance:WaitForChild("Stats"):WaitForChild("SkillCheckChance")
	v[instance] = StatModifierManager.ApplyModifier(instance, "BoundarySizeModifier", 0.9, "ParticipationAward", {
		category = "trinket"
	})
	v2[instance] = StatModifierManager.ApplyAdditiveSkillCheckChance(instance, 25, "ParticipationAward")
end

function ParticipationAward.RemoveTrinket(instance)
	local trinkets = instance:WaitForChild("Trinkets")
	local stats = instance:WaitForChild("Stats")
	local trinket1 = trinkets:FindFirstChild("Trinket1")
	local trinket2 = trinkets:FindFirstChild("Trinket2")

	if not (trinket1 and trinket2) then
		return "CantRemove"
	end

	stats:WaitForChild("SkillCheckChance")

	if v[instance] then
		StatModifierManager.RemoveModifier(instance, "BoundarySizeModifier", v[instance])
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

return ParticipationAward