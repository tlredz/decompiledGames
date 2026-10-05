local StatModifierManager = require(game.ReplicatedStorage.Modules.Data.StatModifierManager)
local v = {}
local MachineManual = {}
MachineManual.Name = "Machine Manual"
MachineManual.Icon = "rbxassetid://17660030293"
MachineManual.Rarity = "Common"
MachineManual.Description = "Increases your Extraction Speed by 5%."
MachineManual.TrinketType = "Passive"
MachineManual.Cost = 250
MachineManual.Requirement1 = { "Coin", 250 }

function MachineManual.ApplyTrinket(p)
	v[p] = StatModifierManager.ApplyModifier(p, "DecodeSpeedModifier", 1.05, "MachineManual", {
		category = "trinket"
	})
end

function MachineManual.RemoveTrinket(instance)
	local trinkets = instance:WaitForChild("Trinkets")
	local trinket1 = trinkets:FindFirstChild("Trinket1")
	local trinket2 = trinkets:FindFirstChild("Trinket2")

	if not (trinket1 and trinket2) then
		return "CantRemove"
	end

	if v[instance] then
		StatModifierManager.RemoveModifier(instance, "DecodeSpeedModifier", v[instance])
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

return MachineManual