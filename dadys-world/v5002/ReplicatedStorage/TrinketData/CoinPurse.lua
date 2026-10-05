local CoinPurse = {
	Name = "Coin Purse",
	Icon = "rbxassetid://17660030392",
	Rarity = "Common",
	Description = "Start with 30 extra Tapes.",
	TrinketType = "Passive",
	Cost = 500
}
CoinPurse.Requirement1 = { "Coin", CoinPurse.Cost }

function CoinPurse.ApplyTrinket(p)
	local child = workspace.Info.PlayerStats:FindFirstChild(p.Name)

	if child then
		local survivalPoints = child:WaitForChild("SurvivalPoints")
		survivalPoints.Value += 30
	end
end

function CoinPurse.RemoveTrinket(instance)
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

return CoinPurse