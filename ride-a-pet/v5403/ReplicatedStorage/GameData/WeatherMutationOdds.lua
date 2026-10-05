local rarityStrikeMultiplier = {
	Common = 2,
	Rare = 1.75,
	Epic = 1.5,
	Legendary = 1.4,
	Mythic = 1.25,
	Divine = 1.1,
	Ethereal = 1
}
local perPetStormChance = {
	Thunder = 0.12,
	Volt = 0.1,
	Raging = 0.05,
	Dreadful = 0.035,
	Eternal = 0.02
}
return {
	RarityStrikeMultiplier = rarityStrikeMultiplier,
	PerPetStormChance = perPetStormChance,
	ChanceFor = function(p, p2)
		local v3 = p2 == "Mythical" and "Mythic" or p2
		return (math.clamp((perPetStormChance[p] or 0) * (rarityStrikeMultiplier[v3] or 1), 0, 1))
	end
}