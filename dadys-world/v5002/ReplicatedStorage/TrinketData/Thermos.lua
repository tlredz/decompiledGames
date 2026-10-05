local StatModifierManager = require(game.ReplicatedStorage.Modules.Data.StatModifierManager)
local v = {}
local Thermos = {}
Thermos.Name = "Thermos"
Thermos.Icon = "rbxassetid://17660030143"
Thermos.Rarity = "Common"
Thermos.Description = "Increases Stamina regeneration by 15%."
Thermos.TrinketType = "Passive"
Thermos.Cost = 250
Thermos.Requirement1 = { "Coin", 250 }

function Thermos.ApplyTrinket(p)
	v[p] = StatModifierManager.ApplyModifier(p, "StaminaRegenModifier", 1.15, "Thermos", {
		category = "trinket"
	})
end

function Thermos.RemoveTrinket(instance)
	local trinkets = instance:WaitForChild("Trinkets")
	local trinket1 = trinkets:FindFirstChild("Trinket1")
	local trinket2 = trinkets:FindFirstChild("Trinket2")

	if not (trinket1 and trinket2) then
		return "CantRemove"
	end

	if v[instance] then
		StatModifierManager.RemoveModifier(instance, "StaminaRegenModifier", v[instance])
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

return Thermos