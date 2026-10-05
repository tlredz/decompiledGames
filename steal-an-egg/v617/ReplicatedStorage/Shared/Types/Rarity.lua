local ReplicatedStorage = game:GetService("ReplicatedStorage")
local t = require(ReplicatedStorage.Packages.t)
local v = {
	Rarity = t.valueOf({
		"Common",
		"Uncommon",
		"Rare",
		"Legendary",
		"Mythic",
		"Prismatic",
		"Divine",
		"Transcendent"
	})
}
return table.freeze(v)