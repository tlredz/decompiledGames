local GlazedFondantBag = {
	Name = "Glazed Fondant Bag",
	Icon = "rbxassetid://105139126066618",
	Rarity = "Rare",
	Description = "Candy items that provide a boost gain 4 seconds to their duration while this Trinket is equipped (BonBon included).",
	TrinketType = "Passive",
	Cost = 350,
	Requirement1 = { "Coin", 350 },
	DurationBonus = 4
}

function GlazedFondantBag.ApplyTrinket(instance, _)
	local playerFromCharacter = game.Players:GetPlayerFromCharacter(instance)

	if not playerFromCharacter then
		return
	end

	instance:SetAttribute("ItemDurationIncrease", GlazedFondantBag.DurationBonus)
	playerFromCharacter:SetAttribute("ItemDurationIncrease", GlazedFondantBag.DurationBonus)
end

function GlazedFondantBag.RemoveTrinket(instance)
	local trinkets = instance:WaitForChild("Trinkets")
	local trinket1 = trinkets:FindFirstChild("Trinket1")
	local trinket2 = trinkets:FindFirstChild("Trinket2")

	if not (trinket1 and trinket2) then
		return "CantRemove"
	end

	local playerFromCharacter = game.Players:GetPlayerFromCharacter(instance)

	if trinket1.Value == script.Name then
		trinket1.Value = "None"
		instance:SetAttribute("ItemDurationIncrease", nil)

		if playerFromCharacter then
			playerFromCharacter:SetAttribute("ItemDurationIncrease", nil)
		end

		return "Slot1"
	else
		if trinket2.Value ~= script.Name then
			return "CantRemove"
		end

		trinket2.Value = "None"
		instance:SetAttribute("ItemDurationIncrease", nil)

		if playerFromCharacter then
			playerFromCharacter:SetAttribute("ItemDurationIncrease", nil)
		end

		return "Slot2"
	end
end

return GlazedFondantBag