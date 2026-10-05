local StatModifierManager = require(game.ReplicatedStorage.Modules.Data.StatModifierManager)
local v = {}
local Diary = {
	Name = "Diary",
	Icon = "rbxassetid://18250684398",
	Rarity = "Common",
	Description = "Increases Stealth by 25%.",
	TrinketType = "Passive",
	MonsterTrinket = true,
	Cost = 350
}
Diary.Requirement1 = { "Coin", Diary.Cost }

function Diary.ApplyTrinket(p)
	v[p] = StatModifierManager.ApplyModifier(p, "StealthModifier", 1.25, "Diary", {
		category = "trinket"
	})
end

function Diary.RemoveTrinket(instance)
	local trinkets = instance:WaitForChild("Trinkets")
	local trinket1 = trinkets:FindFirstChild("Trinket1")
	local trinket2 = trinkets:FindFirstChild("Trinket2")

	if not (trinket1 and trinket2) then
		return "CantRemove"
	end

	if v[instance] then
		StatModifierManager.RemoveModifier(instance, "StealthModifier", v[instance])
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

return Diary