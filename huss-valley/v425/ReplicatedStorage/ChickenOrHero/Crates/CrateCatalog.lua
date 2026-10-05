local CrateCatalog = {
	Order = { "Ember", "Celestial" },
	DuplicateGems = {
		Common = 10,
		Rare = 20,
		Epic = 40,
		Legendary = 75
	},
	Crates = {
		Ember = {
			Name = "Ember & Shadow Crate",
			WorldModel = "EmberCrate",
			Gems = 2200,
			ProductId = 3715710929,
			Accent = Color3.fromRGB(245, 164, 82),
			Entries = {
				{
					Skin = "CopperBite",
					Weight = 3000,
					Rarity = "Common",
					DuplicateGems = 10
				},
				{
					Skin = "Ashsteel",
					Weight = 3000,
					Rarity = "Common",
					DuplicateGems = 10
				},
				{
					Skin = "AmberSting",
					Weight = 1250,
					Rarity = "Rare",
					DuplicateGems = 20
				},
				{
					Skin = "RoseQuartz",
					Weight = 1250,
					Rarity = "Rare",
					DuplicateGems = 20
				},
				{
					Skin = "MoltenFang",
					Weight = 600,
					Rarity = "Epic",
					DuplicateGems = 40
				},
				{
					Skin = "SpectralReaper",
					Weight = 600,
					Rarity = "Epic",
					DuplicateGems = 40
				},
				{
					Skin = "SolarPhoenix",
					Weight = 150,
					Rarity = "Legendary",
					DuplicateGems = 75
				},
				{
					Skin = "VoidSovereign",
					Weight = 150,
					Rarity = "Legendary",
					DuplicateGems = 75
				}
			}
		},
		Celestial = {
			Name = "Celestial Crate",
			WorldModel = "CelestialCrate",
			Gems = 2200,
			ProductId = 3715710934,
			Accent = Color3.fromRGB(152, 181, 250),
			Entries = {
				{
					Skin = "IronFang",
					Weight = 3000,
					Rarity = "Common",
					DuplicateGems = 10
				},
				{
					Skin = "ForestEdge",
					Weight = 3000,
					Rarity = "Common",
					DuplicateGems = 10
				},
				{
					Skin = "TidalShard",
					Weight = 1250,
					Rarity = "Rare",
					DuplicateGems = 20
				},
				{
					Skin = "VenomThorn",
					Weight = 1250,
					Rarity = "Rare",
					DuplicateGems = 20
				},
				{
					Skin = "StormTalon",
					Weight = 600,
					Rarity = "Epic",
					DuplicateGems = 40
				},
				{
					Skin = "Moonfang",
					Weight = 600,
					Rarity = "Epic",
					DuplicateGems = 40
				},
				{
					Skin = "GlacialCrown",
					Weight = 150,
					Rarity = "Legendary",
					DuplicateGems = 75
				},
				{
					Skin = "CelestialDragon",
					Weight = 150,
					Rarity = "Legendary",
					DuplicateGems = 75
				}
			}
		}
	},
	ProductGrants = {
		[3715710929] = {
			UniverseId = 10764627709,
			Crate = "Ember"
		},
		[3715710934] = {
			UniverseId = 10764627709,
			Crate = "Celestial"
		}
	}
}

function CrateCatalog.get(value)
	return type(value) == "string" and CrateCatalog.Crates[value] or nil
end

function CrateCatalog.pick(p, value)
	local v = CrateCatalog.get(p)
	local v2

	if v then
		if type(value) == "number" and value % 1 == 0 and value >= 1 then
			v2 = value <= 10000
		else
			v2 = false
		end
	else
		v2 = v
	end

	assert(v2, "Invalid crate roll")
	local total = 0

	for _, entry in v.Entries do
		total += entry.Weight

		if value <= total then
			return entry
		end
	end

	error("Crate weights must total 10000")
end

return CrateCatalog