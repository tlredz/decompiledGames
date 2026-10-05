local StatModifierManager = require(game.ReplicatedStorage.Modules.Data.StatModifierManager)
local v = {}
local PinkBow = {}
PinkBow.Name = "Pink Bow"
PinkBow.Icon = "rbxassetid://17651848463"
PinkBow.Rarity = "Common"
PinkBow.Description = "Increases Run Speed by 7.5%."
PinkBow.TrinketType = "Passive"
PinkBow.MonsterTrinket = true
PinkBow.Cost = 325
PinkBow.Requirement1 = { "Coin", 325 }

function PinkBow.ApplyTrinket(p)
	v[p] = StatModifierManager.ApplyModifier(p, "RunSpeedModifier", 1.075, "PinkBow", {
		category = "trinket"
	})
end

function PinkBow.RemoveTrinket(instance)
	local trinkets = instance:WaitForChild("Trinkets")
	local trinket1 = trinkets:FindFirstChild("Trinket1")
	local trinket2 = trinkets:FindFirstChild("Trinket2")

	if not (trinket1 and trinket2) then
		return "CantRemove"
	end

	if v[instance] then
		StatModifierManager.RemoveModifier(instance, "RunSpeedModifier", v[instance])
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

return PinkBow