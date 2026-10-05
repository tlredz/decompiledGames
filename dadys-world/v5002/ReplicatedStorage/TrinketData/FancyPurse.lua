local FancyPurse = {
	Name = "Fancy Purse",
	Icon = "rbxassetid://18192716174",
	Rarity = "Common",
	Description = "Start with 100 extra Tapes.",
	TrinketType = "Passive",
	MonsterTrinket = true,
	Cost = 250
}
FancyPurse.Requirement1 = { "Coin", FancyPurse.Cost }

function FancyPurse.ApplyTrinket(p)
	local child = workspace.Info.PlayerStats:FindFirstChild(p.Name)

	if child then
		local survivalPoints = child:WaitForChild("SurvivalPoints")
		survivalPoints.Value += 100
	end
end

function FancyPurse.RemoveTrinket(instance)
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

return FancyPurse