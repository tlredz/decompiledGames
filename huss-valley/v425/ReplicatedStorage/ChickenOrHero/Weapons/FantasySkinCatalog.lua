local v = {
	Common = Color3.fromRGB(175, 185, 192),
	Rare = Color3.fromRGB(92, 173, 238),
	Epic = Color3.fromRGB(183, 123, 244),
	Legendary = Color3.fromRGB(242, 191, 89)
}
local v2 = {
	Order = {},
	Skins = {}
}

for _, list in {
	{
		"CopperBite",
		"Copper Bite",
		"Common",
		"Ember"
	},
	{
		"Ashsteel",
		"Ashsteel",
		"Common",
		"Ember"
	},
	{
		"AmberSting",
		"Amber Sting",
		"Rare",
		"Ember"
	},
	{
		"RoseQuartz",
		"Rose Quartz",
		"Rare",
		"Ember"
	},
	{
		"MoltenFang",
		"Molten Fang",
		"Epic",
		"Ember"
	},
	{
		"SpectralReaper",
		"Spectral Reaper",
		"Epic",
		"Ember"
	},
	{
		"SolarPhoenix",
		"Solar Phoenix",
		"Legendary",
		"Ember"
	},
	{
		"VoidSovereign",
		"Void Sovereign",
		"Legendary",
		"Ember"
	},
	{
		"IronFang",
		"Iron Fang",
		"Common",
		"Celestial"
	},
	{
		"ForestEdge",
		"Forest Edge",
		"Common",
		"Celestial"
	},
	{
		"TidalShard",
		"Tidal Shard",
		"Rare",
		"Celestial"
	},
	{
		"VenomThorn",
		"Venom Thorn",
		"Rare",
		"Celestial"
	},
	{
		"StormTalon",
		"Storm Talon",
		"Epic",
		"Celestial"
	},
	{
		"Moonfang",
		"Moonfang",
		"Epic",
		"Celestial"
	},
	{
		"GlacialCrown",
		"Glacial Crown",
		"Legendary",
		"Celestial"
	},
	{
		"CelestialDragon",
		"Celestial Dragon",
		"Legendary",
		"Celestial"
	}
} do
	local model, sourceName, rarity, crate = table.unpack(list)
	local v7 = crate == "Ember" and "Ember & Shadow" or crate
	local description = rarity == "Legendary" and "+0.85 movement speed · 0.85 seconds shorter item, ability and dodge cooldowns." or rarity == "Epic" and "+0.35 movement speed · 0.35 seconds shorter item, ability and dodge cooldowns." or "A permanent knife skin."
	table.insert(v2.Order, model)
	v2.Skins[model] = table.freeze({
		Name = string.upper(sourceName),
		SourceName = sourceName,
		Subtitle = rarity .. " · " .. v7 .. " collection",
		Description = description,
		Model = model,
		SoundProfile = crate .. rarity,
		Accent = v[rarity],
		Collection = string.upper(v7) .. " CRATE",
		Rarity = rarity,
		Crate = crate,
		Available = false,
		EquipReady = true
	})
end

table.freeze(v2.Order)
table.freeze(v2.Skins)
return table.freeze(v2)