local CherishedBlanket = {
	Name = "Cherished Blanket",
	Icon = "rbxassetid://131685216415869",
	Rarity = "Common",
	Description = "Increases the duration of Trails created by your Abilities by 4 seconds. Has no effect on Toons without a Trail Ability.",
	TrinketType = "Passive",
	MonsterTrinket = true,
	TrinketState = "Other",
	TrailLifetimeBonus = 4
}

function CherishedBlanket.ApplyTrinket(instance)
	local playerFromCharacter = game.Players:GetPlayerFromCharacter(instance)

	if not playerFromCharacter then
		return
	end

	instance:SetAttribute("EmberTrailLifetimeBonus", CherishedBlanket.TrailLifetimeBonus)
	playerFromCharacter:SetAttribute("EmberTrailLifetimeBonus", CherishedBlanket.TrailLifetimeBonus)
end

function CherishedBlanket.RemoveTrinket(instance)
	local trinkets = instance:WaitForChild("Trinkets")
	local trinket1 = trinkets:FindFirstChild("Trinket1")
	local trinket2 = trinkets:FindFirstChild("Trinket2")

	if not (trinket1 and trinket2) then
		return "CantRemove"
	end

	local playerFromCharacter = game.Players:GetPlayerFromCharacter(instance)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function clearBonus()
		instance:SetAttribute("EmberTrailLifetimeBonus", nil)

		if playerFromCharacter then
			playerFromCharacter:SetAttribute("EmberTrailLifetimeBonus", nil)
		end
	end

	if trinket1.Value == script.Name then
		trinket1.Value = "None"
		clearBonus() -- equivalent call inferred; original call site unknown
		return "Slot1"
	else
		if trinket2.Value ~= script.Name then
			return "CantRemove"
		end

		trinket2.Value = "None"
		clearBonus() -- equivalent call inferred; original call site unknown
		return "Slot2"
	end
end

return CherishedBlanket