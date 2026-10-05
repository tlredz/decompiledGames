local Tape = {
	Name = "Tape",
	PointCost = 5,
	DandyStoreItem = false,
	FloorItem = true,
	Rarity = "Common",
	Icon = "rbxassetid://89728211828595",
	Description = "This gives you 10 Tapes."
}
game:GetService("Debris")

function Tape.UseItem(instance, _)
	local humanoid = instance:WaitForChild("Humanoid")

	if humanoid.Health >= humanoid.MaxHealth then
		return {
			Outcome = false,
			Reason = "Can't use that item at full Health!"
		}
	end

	return {
		Outcome = true,
		Reason = "Can't use that item at full Health!"
	}
end

return Tape