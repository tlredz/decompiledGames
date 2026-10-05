local SpareBulb = {
	Name = "Spare Bulb",
	Icon = "rbxassetid://17653809409",
	Rarity = "Common",
	Description = "Increases Blackout light radius by 25%. Also increases light radius for light-producing Toons.",
	TrinketType = "Passive",
	MonsterTrinket = true,
	Cost = 350
}
SpareBulb.Requirement1 = { "Coin", SpareBulb.Cost }

function SpareBulb.ApplyTrinket(instance)
	instance:WaitForChild("Trinkets")
	local stats = instance:WaitForChild("Stats")
	stats:WaitForChild("WalkSpeed")
	stats:WaitForChild("RunSpeed")
	stats:WaitForChild("SpeedModifier")
	instance:WaitForChild("Humanoid")
	stats:WaitForChild("Sprinting")
	local humanoidRootPart = instance:WaitForChild("HumanoidRootPart")

	if humanoidRootPart:FindFirstChild("ToonLight") then
		humanoidRootPart:WaitForChild("ToonLight").PointLight.Range *= 1.25
	end
end

function SpareBulb.RemoveTrinket(instance)
	local trinkets = instance:WaitForChild("Trinkets")
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")
	local trinket1 = trinkets:FindFirstChild("Trinket1")
	local trinket2 = trinkets:FindFirstChild("Trinket2")

	if not (trinket1 and trinket2) then
		return "CantRemove"
	end

	if trinket1.Value == script.Name then
		trinket1.Value = "None"

		if humanoidRootPart and humanoidRootPart:FindFirstChild("ToonLight") then
			humanoidRootPart.ToonLight.PointLight.Range /= 1.25
		end

		return "Slot1"
	else
		if trinket2.Value ~= script.Name then
			return "CantRemove"
		end

		trinket2.Value = "None"

		if humanoidRootPart and humanoidRootPart:FindFirstChild("ToonLight") then
			humanoidRootPart.ToonLight.PointLight.Range /= 1.25
		end

		return "Slot2"
	end
end

return SpareBulb