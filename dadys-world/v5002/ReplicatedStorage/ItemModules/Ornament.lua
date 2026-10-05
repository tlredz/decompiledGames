local Ornament = {
	Name = "Ornament",
	PointCost = 5,
	DandyStoreItem = false,
	FloorItem = false,
	Rarity = "Common",
	Icon = "rbxassetid://86064499339405",
	Description = "A festive ornament that gives you 5 baubles when collected."
}
game:GetService("Debris")

function Ornament.UseItem(_, _)
	return {
		Outcome = true,
		Reason = "Collected an ornament!"
	}
end

return Ornament