local TrainWhistle = {
	Name = "Train Whistle",
	Icon = "rbxassetid://105084994736734",
	Rarity = "Common",
	Description = "Makes the user immune to the Slowness Debuff.",
	TrinketType = "Passive",
	MonsterTrinket = true,
	SlownessImmunity = true,
	TrinketState = "Other",
	Cost = 350
}
TrainWhistle.Requirement1 = { "Coin", TrainWhistle.Cost }

function TrainWhistle.ApplyTrinket(instance)
	instance:SetAttribute("SlownessImmunity", true)
end

function TrainWhistle.RemoveTrinket(instance)
	local trinkets = instance:WaitForChild("Trinkets")
	local trinket1 = trinkets:FindFirstChild("Trinket1")
	local trinket2 = trinkets:FindFirstChild("Trinket2")

	if not (trinket1 and trinket2) then
		return "CantRemove"
	end

	if trinket1.Value == script.Name then
		trinket1.Value = "None"
		instance:SetAttribute("SlownessImmunity", false)
		return "Slot1"
	else
		if trinket2.Value ~= script.Name then
			return "CantRemove"
		end

		trinket2.Value = "None"
		instance:SetAttribute("SlownessImmunity", false)
		return "Slot2"
	end
end

return TrainWhistle