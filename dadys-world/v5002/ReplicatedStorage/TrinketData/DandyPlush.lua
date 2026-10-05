local DandyPlush = {
	Name = "Dandy Plush",
	Icon = "rbxassetid://17653810491",
	Rarity = "Common",
	Description = "Grants the user a 50% discount on all Dandy's Shop items.",
	TrinketType = "Passive",
	MonsterTrinket = true,
	Cost = 350
}
DandyPlush.Requirement1 = { "Coin", DandyPlush.Cost }

function DandyPlush.ApplyTrinket(instance)
	instance:WaitForChild("Trinkets")
	local stats = instance:WaitForChild("Stats")
	stats:WaitForChild("WalkSpeed")
	stats:WaitForChild("RunSpeed")
	stats:WaitForChild("SpeedModifier")
	instance:WaitForChild("Humanoid")
	stats:WaitForChild("Sprinting")
end

function DandyPlush.RemoveTrinket(instance)
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

return DandyPlush