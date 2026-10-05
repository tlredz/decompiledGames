local StatModifierManager = require(game.ReplicatedStorage.Modules.Data.StatModifierManager)
local v = {}
local WaterCooler = {}
WaterCooler.Name = "Cooler"
WaterCooler.Icon = "rbxassetid://131395889117086"
WaterCooler.Rarity = "Common"
WaterCooler.Description = "Grants the user 50 more Stamina, but lowers Movement Speed by 5%."
WaterCooler.TrinketType = "Passive"
WaterCooler.Cost = 375
WaterCooler.Requirement1 = { "Coin", 375 }

function WaterCooler.ApplyTrinket(instance)
	local stats = instance:WaitForChild("Stats")
	local originalStamina = stats:WaitForChild("OriginalStamina")
	local currentStamina = stats:WaitForChild("CurrentStamina")
	originalStamina.Value += 50
	currentStamina.Value += 50
	v[instance] = StatModifierManager.ApplySpeedModifiers(instance, 0.95, "Cooler", {
		category = "trinket"
	})
end

function WaterCooler.RemoveTrinket(instance)
	local trinkets = instance:WaitForChild("Trinkets")
	local stats = instance:WaitForChild("Stats")
	local originalStamina = stats:WaitForChild("OriginalStamina")
	local currentStamina = stats:WaitForChild("CurrentStamina")
	local trinket1 = trinkets:FindFirstChild("Trinket1")
	local trinket2 = trinkets:FindFirstChild("Trinket2")

	if not (trinket1 and trinket2) then
		return "CantRemove"
	end

	if trinket1.Value == script.Name then
		trinket1.Value = "None"
		originalStamina.Value -= 50
		currentStamina.Value -= 50

		if v[instance] then
			StatModifierManager.RemoveSpeedModifiers(instance, v[instance])
			v[instance] = nil
		end

		return "Slot1"
	else
		if trinket2.Value ~= script.Name then
			return "CantRemove"
		end

		trinket2.Value = "None"
		originalStamina.Value -= 50
		currentStamina.Value -= 50

		if v[instance] then
			StatModifierManager.RemoveSpeedModifiers(instance, v[instance])
			v[instance] = nil
		end

		return "Slot2"
	end
end

return WaterCooler