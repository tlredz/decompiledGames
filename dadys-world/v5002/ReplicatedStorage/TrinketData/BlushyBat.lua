local BlushyBat = {}
BlushyBat.Name = "Blushy Bat"
BlushyBat.Icon = "rbxassetid://17826624660"
BlushyBat.Rarity = "Common"
BlushyBat.Description = "Increases the Attack Cooldown of any Twisted that attacks the user by 3 seconds. Earned by joining the Blush Crunch Studio ROBLOX Group."
BlushyBat.TrinketType = "Passive"
BlushyBat.Cost = 250
BlushyBat.Requirement1 = { "Coin", 250 }

function BlushyBat.ApplyTrinket(instance)
	instance:WaitForChild("Trinkets")
	instance:WaitForChild("Stats")
end

function BlushyBat.RemoveTrinket(instance)
	local trinkets = instance:WaitForChild("Trinkets")
	local trinket1 = trinkets:FindFirstChild("Trinket1")
	local trinket2 = trinkets:FindFirstChild("Trinket2")

	if not (trinket1 and trinket2) then
		return "CantRemove"
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

return BlushyBat