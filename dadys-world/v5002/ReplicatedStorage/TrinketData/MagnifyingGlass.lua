local StatModifierManager = require(game.ReplicatedStorage.Modules.Data.StatModifierManager)
local v = {}
local MagnifyingGlass = {
	Name = "Magnifying Glass",
	Icon = "rbxassetid://17651868795",
	Rarity = "Common",
	Description = "Adds slightly more completion when performing a successful Skill Check, but decreases Skill Check size by 33%.",
	TrinketType = "Passive",
	MonsterTrinket = true,
	Cost = 350
}
MagnifyingGlass.Requirement1 = { "Coin", MagnifyingGlass.Cost }
MagnifyingGlass.SkillCheckCompleteEvent = true

function MagnifyingGlass.ApplyTrinket(p)
	v[p] = StatModifierManager.ApplyModifier(p, "BoundarySizeModifier", 0.67, "MagnifyingGlass", {
		category = "trinket"
	})
end

function MagnifyingGlass.RemoveTrinket(instance)
	local trinkets = instance:WaitForChild("Trinkets")
	local trinket1 = trinkets:FindFirstChild("Trinket1")
	local trinket2 = trinkets:FindFirstChild("Trinket2")

	if not (trinket1 and trinket2) then
		return "CantRemove"
	end

	if v[instance] then
		StatModifierManager.RemoveModifier(instance, "BoundarySizeModifier", v[instance])
		v[instance] = nil
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

function MagnifyingGlass.TriggerSkillCheckCompleteEvent(_, p, p2)
	p.Stats.CurrentAmount.Value += p.Stats.RequiredAmount.Value * 0.04
	p.PlayerCompletion[p2.Value.Name].Value += p.Stats.RequiredAmount.Value * 0.04
end

return MagnifyingGlass