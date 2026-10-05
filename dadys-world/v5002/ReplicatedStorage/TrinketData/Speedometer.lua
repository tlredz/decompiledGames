local Speedometer = {}
Speedometer.Name = "Speedometer"
Speedometer.Icon = "rbxassetid://17660146057"
Speedometer.Rarity = "Common"
Speedometer.Description = "Grants the user 15 more Stamina."
Speedometer.TrinketType = "Passive"
Speedometer.Cost = 375
Speedometer.Requirement1 = { "Coin", 375 }

function Speedometer.ApplyTrinket(instance)
	instance:WaitForChild("Trinkets")
	local stats = instance:WaitForChild("Stats")
	local originalStamina = stats:WaitForChild("OriginalStamina")
	local currentStamina = stats:WaitForChild("CurrentStamina")
	originalStamina.Value += 15
	currentStamina.Value += 15
end

function Speedometer.RemoveTrinket(instance)
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
		originalStamina.Value -= 15
		currentStamina.Value -= 15
		return "Slot1"
	else
		if trinket2.Value ~= script.Name then
			return "CantRemove"
		end

		trinket2.Value = "None"
		originalStamina.Value -= 15
		currentStamina.Value -= 15
		return "Slot2"
	end
end

return Speedometer