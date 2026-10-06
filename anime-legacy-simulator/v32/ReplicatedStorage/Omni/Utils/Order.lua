local v = {
	Rarities = {
		"Common",
		"Uncommon",
		"Rare",
		"Epic",
		"Legendary",
		"Mythical",
		"Secret",
		"Exclusive"
	}
}

function v.Rarity(_, p: string)
	if p == "Gems" then
		return #v.Rarities + 1
	end

	return table.find(v.Rarities, p) or 1
end

return table.freeze(v)