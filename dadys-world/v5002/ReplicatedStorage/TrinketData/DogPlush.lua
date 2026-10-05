local StatModifierManager = require(game.ReplicatedStorage.Modules.Data.StatModifierManager)
local v = {}
local DogPlush = {
	Name = "Dog Plush",
	Icon = "rbxassetid://17653810186",
	Rarity = "Common",
	Description = "Increases Walk Speed by 10%.",
	TrinketType = "Passive",
	MonsterTrinket = true,
	Cost = 350
}
DogPlush.Requirement1 = { "Coin", DogPlush.Cost }

function DogPlush.ApplyTrinket(p)
	v[p] = StatModifierManager.ApplyModifier(p, "SpeedModifier", 1.1, "DogPlush", {
		category = "trinket"
	})
end

function DogPlush.RemoveTrinket(instance)
	local trinkets = instance:WaitForChild("Trinkets")
	local trinket1 = trinkets:FindFirstChild("Trinket1")
	local trinket2 = trinkets:FindFirstChild("Trinket2")

	if not (trinket1 and trinket2) then
		return "CantRemove"
	end

	if v[instance] then
		StatModifierManager.RemoveModifier(instance, "SpeedModifier", v[instance])
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

return DogPlush