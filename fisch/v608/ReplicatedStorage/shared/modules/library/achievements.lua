local module = require("./locations")
local v = {
	firstShiny = {
		DisplayName = "Special Someone",
		Rarity = "Uncommon",
		Description = "Catch your first <i>Shiny</i> fish.",
		TargetType = "stat",
		TargetData = { "shinyCaught" },
		TargetValue = 1,
		Visible = true
	},
	firstSparkling = {
		DisplayName = "Glimmering Beauty",
		Rarity = "Uncommon",
		Description = "Catch your first <i>Sparkling</i> fish.",
		TargetType = "stat",
		TargetData = { "sparklingCaught" },
		TargetValue = 1,
		Visible = true
	},
	firstSold = {
		DisplayName = "Economy Expert",
		Rarity = "Common",
		Description = "Sell a fish for the first time.",
		TargetType = "stat",
		TargetData = { "sparklingCaught" },
		TargetValue = 1,
		Visible = true
	},
	firstLegendary = {
		DisplayName = "Rare Hunter",
		Rarity = "Uncommon",
		Description = "Catch a Legendary fish.",
		TargetType = "substat",
		TargetData = { "fishCaught", "Legendary" },
		TargetValue = 1,
		Visible = true
	},
	firstAppraise = {
		DisplayName = "Attempted Upgrade",
		Rarity = "Common",
		Description = "Get the 'Aquatic Appraiser' to appraise a fish.",
		TargetType = "stat",
		TargetData = { "fishAppraised" },
		TargetValue = 1,
		Visible = true
	},
	firstRelic = {
		DisplayName = "Divine Relic",
		Rarity = "Uncommon",
		Description = "Catch your first Relic.",
		TargetType = "substat",
		TargetData = { "fishCaught", "Relic" },
		TargetValue = 1,
		Visible = false
	},
	catches50 = {
		DisplayName = "Junior Angler",
		Rarity = "Common",
		Description = "Catch 50 fish.",
		TargetType = "stat",
		TargetId = "fishCaught",
		TargetData = { "fishCaught" },
		TargetValue = 50,
		Visible = true
	},
	catches100 = {
		DisplayName = "Expert Angler",
		Rarity = "Uncommon",
		Description = "Catch 100 fish.",
		TargetType = "stat",
		TargetData = { "fishCaught" },
		TargetValue = 100,
		Visible = "catches50"
	},
	catches500 = {
		DisplayName = "Master Fischer",
		Rarity = "Unusual",
		Description = "Catch 500 fish.",
		TargetType = "stat",
		TargetData = { "fishCaught" },
		TargetValue = 500,
		Visible = "catches100"
	},
	catches1k = {
		DisplayName = "Lord Of The Sea",
		Rarity = "Rare",
		Description = "Catch 1,000 fish.",
		TargetType = "stat",
		TargetData = { "fishCaught" },
		TargetValue = 1000,
		Visible = "catches500"
	},
	catches2k = {
		DisplayName = "Mythical Angler",
		Rarity = "Rare",
		Description = "Catch 2,000 fish.",
		TargetType = "stat",
		TargetData = { "fishCaught" },
		TargetValue = 2000,
		Visible = "catches1k"
	},
	catches3k = {
		DisplayName = "Eternal Fischer",
		Rarity = "Legendary",
		Description = "Catch 3,000 fish.",
		TargetType = "stat",
		TargetData = { "fishCaught" },
		TargetValue = 3000,
		Visible = "catches2k"
	},
	catches4k = {
		DisplayName = "Top Fischer",
		Rarity = "Legendary",
		Description = "Catch 4,000 fish.",
		TargetType = "stat",
		TargetData = { "fishCaught" },
		TargetValue = 4000,
		Visible = "catches3k"
	},
	catches5k = {
		DisplayName = "God Of The Seas",
		Rarity = "Exotic",
		Description = "Catch 5,000 fish.",
		TargetType = "stat",
		TargetData = { "fishCaught" },
		TargetValue = 5000,
		Visible = "catches4k"
	},
	catches10k = {
		DisplayName = "Fish Overlord",
		Rarity = "Exotic",
		Description = "Catch 10,000 fish.",
		TargetType = "stat",
		TargetData = { "fishCaught" },
		TargetValue = 10000,
		Visible = "catches5k"
	},
	catches100k = {
		DisplayName = "Are they extinct yet?",
		Rarity = "Secret",
		Description = "Catch 100,000 fish.",
		TargetType = "stat",
		TargetData = { "fishCaught" },
		TargetValue = 100000,
		Visible = false
	},
	catches1M = {
		DisplayName = "John Fisch",
		Rarity = "Divine Secret",
		Description = "Catch 1,000,000 fish.",
		TargetType = "stat",
		TargetData = { "fishCaught" },
		TargetValue = 1000000,
		Visible = false
	},
	lavaCaster = {
		DisplayName = "Lava Caster",
		Rarity = "Common",
		Description = "Catch a fish in a pool of lava.",
		TargetType = "substat",
		TargetData = { "locationCatches", "Roslit Volcano" },
		TargetValue = 1,
		Visible = true
	},
	sandSifter = {
		DisplayName = "Working as Intended",
		Rarity = "Common",
		Description = "Catch a fish in the sands of Drylands.",
		TargetType = "substat",
		TargetData = { "locationCatches", "Drylands" },
		TargetValue = 1,
		Visible = false
	},
	useFishRadar = {
		DisplayName = "Recon Expert",
		Rarity = "Common",
		Description = "Use a Fish Abundance Radar for the first time.",
		TargetType = "useFishRadar",
		TargetValue = true,
		Visible = true
	},
	firstEnchant = {
		DisplayName = "True Power",
		Rarity = "Uncommon",
		Description = "Enchant a rod at the Keeper's Altar.",
		TargetType = "stat",
		TargetData = { "rodsEnchanted" },
		TargetValue = 1,
		Visible = true
	},
	firstFurniture = {
		DisplayName = "I am an Architect!",
		Rarity = "Common",
		Description = "Customize your Personal Aquarium.",
		TargetType = "personalAquariumCustomized",
		TargetValue = true,
		Visible = true
	},
	firstAurora = {
		DisplayName = "Experienced True Beauty",
		Rarity = "Rare",
		Description = "Witness the start of an Aurora Borealis.",
		TargetType = "firstWeather",
		TargetData = { "Aurora Borealis" },
		TargetValue = true,
		Visible = true
	},
	firstRainbow = {
		DisplayName = "Where's the Gold?",
		Rarity = "Rare",
		Description = "Witness the start of a Rainbow.",
		TargetType = "firstWeather",
		TargetData = { "Rainbow" },
		TargetValue = true,
		Visible = true
	},
	firstStarfall = {
		DisplayName = "Watch Your Head!",
		Rarity = "Rare",
		Description = "Witness the start of a Starfall.",
		TargetType = "firstWeather",
		TargetData = { "Starfall" },
		TargetValue = true,
		Visible = true
	},
	firstEclipse = {
		DisplayName = "Don't Forget Your Sunglasses",
		Rarity = "Rare",
		Description = "Witness the start of an Eclipse.",
		TargetType = "firstWeather",
		TargetData = { "Eclipse" },
		TargetValue = true,
		Visible = true
	},
	firstFrostMoon = {
		DisplayName = "Chilled Revelation",
		Rarity = "Limited",
		Description = "Witness the start of a Frost Moon.",
		TargetType = "firstWeather",
		TargetData = { "Frost Moon" },
		TargetValue = true,
		Visible = true
	},
	firstTropicalSun = {
		DisplayName = "Sunlit Paradise",
		Rarity = "Limited",
		Description = "Witness the start of a Tropical Sun.",
		TargetType = "firstWeather",
		TargetData = { "Tropical Sun" },
		TargetValue = true,
		Visible = true
	},
	firstSovereign = {
		DisplayName = "Divine Reckoning",
		Rarity = "Rare",
		Description = "Witness the start of a Sovereign Reckoning.",
		TargetType = "firstWeather",
		TargetData = { "Sovereign Reckoning" },
		TargetValue = true,
		Visible = true
	},
	firstAnomaly = {
		DisplayName = "Anomalous Atmosphere",
		Rarity = "Rare",
		Description = "Summon any Astral Anomaly.",
		TargetType = "stat",
		TargetData = { "anomaliesActivated" },
		TargetValue = 1,
		Visible = true
	},
	volleyball10 = {
		DisplayName = "Volleyball Novice",
		Rarity = "Limited",
		Description = "Achieve a score of 10+ in Beach Volleyball.",
		TargetType = "beachVolleyball",
		TargetValue = 10,
		Visible = false
	},
	volleyball50 = {
		DisplayName = "Beach Volleyballer",
		Rarity = "Limited",
		Description = "Achieve a score of 50+ in Beach Volleyball.",
		TargetType = "beachVolleyball",
		TargetValue = 50,
		Visible = false
	},
	volleyball100 = {
		DisplayName = "Beach Volleyball Professional",
		Rarity = "Limited",
		Description = "Achieve a score of 100+ in Beach Volleyball.",
		TargetType = "beachVolleyball",
		TargetValue = 100,
		Visible = false,
		ShowOverflow = "Highest Score"
	},
	streak10 = {
		DisplayName = "Starting Streak",
		Rarity = "Rare",
		Description = "Reach a Catch Streak of 10.",
		TargetType = "stat",
		TargetData = { "catchStreakLifetime" },
		TargetValue = 10,
		Visible = true
	},
	streak100 = {
		DisplayName = "Superb Streak",
		Rarity = "Legendary",
		Description = "Reach a Catch Streak of 100.",
		TargetType = "stat",
		TargetData = { "catchStreakLifetime" },
		TargetValue = 100,
		Visible = "streak10"
	},
	streak1k = {
		DisplayName = "Stellar Streak",
		Rarity = "Mythical",
		Description = "Reach a Catch Streak of 1,000.",
		TargetType = "stat",
		TargetData = { "catchStreakLifetime" },
		TargetValue = 1000,
		Visible = false
	},
	streak10k = {
		DisplayName = "Staggering Streak",
		Rarity = "Exotic",
		Description = "Reach a Catch Streak of 10,000.",
		TargetType = "stat",
		TargetData = { "catchStreakLifetime" },
		TargetValue = 10000,
		Visible = false,
		ShowOverflow = "Highest Streak"
	},
	streak100k = {
		DisplayName = "Superhuman Streak",
		Rarity = "Divine Secret",
		Description = "Reach a Catch Streak of 100,000.",
		TargetType = "stat",
		TargetData = { "catchStreakLifetime" },
		TargetValue = 100000,
		Visible = false,
		ShowOverflow = "Highest Streak"
	},
	divineBellona = {
		DisplayName = "Divine Conqueror: Bellona",
		Rarity = "Exotic",
		Description = "Complete the Bellona God Fight with at at least 90% Health remaining.",
		TargetType = "godFight",
		TargetData = { "Bellona" },
		TargetValue = 90,
		Visible = false,
		ShowOverflow = "Best Record"
	},
	divineApollo = {
		DisplayName = "Divine Conqueror: Apollo",
		Rarity = "Exotic",
		Description = "Complete the Apollo God Fight with at at least 90% Health remaining.",
		TargetType = "godFight",
		TargetData = { "Apollo" },
		TargetValue = 90,
		Visible = false,
		ShowOverflow = "Best Record"
	},
	divinePoseidon = {
		DisplayName = "Divine Conqueror: Poseidon",
		Rarity = "Exotic",
		Description = "Complete the Poseidon God Fight with at at least 90% Health remaining.",
		TargetType = "godFight",
		TargetData = { "Poseidon" },
		TargetValue = 90,
		Visible = false,
		ShowOverflow = "Best Record"
	},
	divineZeus = {
		DisplayName = "Divine Conqueror: Zeus",
		Rarity = "Exotic",
		Description = "Complete the Zeus God Fight with at at least 90% Health remaining.",
		TargetType = "godFight",
		TargetData = { "Zeus" },
		TargetValue = 90,
		Visible = false,
		ShowOverflow = "Best Record"
	},
	divineHades = {
		DisplayName = "Divine Conqueror: Hades",
		Rarity = "Exotic",
		Description = "Complete the Hades God Fight with at at least 90% Health remaining.",
		TargetType = "godFight",
		TargetData = { "Hades" },
		TargetValue = 90,
		Visible = false,
		ShowOverflow = "Best Record"
	},
	sealBellona = {
		DisplayName = "The Frenzy of War",
		Rarity = "Legendary",
		Description = "Defeat Bellona.",
		TargetType = "breakSeal",
		TargetData = { "Bellona" },
		TargetValue = true,
		Visible = true
	},
	sealApollo = {
		DisplayName = "The Song of Light",
		Rarity = "Legendary",
		Description = "Defeat Apollo.",
		TargetType = "breakSeal",
		TargetData = { "Apollo" },
		TargetValue = true,
		Visible = "sealBellona"
	},
	sealPoseidon = {
		DisplayName = "The Storm of Floods",
		Rarity = "Legendary",
		Description = "Defeat Poseidon.",
		TargetType = "breakSeal",
		TargetData = { "Poseidon" },
		TargetValue = true,
		Visible = "sealApollo"
	},
	sealZeus = {
		DisplayName = "The Thunder of Chaos",
		Rarity = "Legendary",
		Description = "Defeat Zeus.",
		TargetType = "breakSeal",
		TargetData = { "Zeus" },
		TargetValue = true,
		Visible = "sealPoseidon"
	},
	sealHades = {
		DisplayName = "The Underworld of Indefinite",
		Rarity = "Legendary",
		Description = "Defeat Hades.",
		TargetType = "breakSeal",
		TargetData = { "Hades" },
		TargetValue = true,
		Visible = "sealZeus"
	},
	catchDevil = {
		DisplayName = "Devil of the Fissure",
		Rarity = "Mythical",
		Description = "Catch the Olympian Devil.",
		TargetType = "bestiary_fish",
		TargetData = { "Olympian Devil" },
		TargetValue = true,
		Visible = "sealHades"
	},
	marianasHeat = {
		DisplayName = "Heat-Proof",
		Rarity = "Rare",
		Description = "Complete the Heat Upgrade for your Submarine.",
		TargetType = "submarineTier",
		TargetValue = 2,
		Visible = true,
		HideProgress = true
	},
	marianasIce = {
		DisplayName = "Cold-Proof",
		Rarity = "Rare",
		Description = "Complete the Ice Upgrade for your Submarine.",
		TargetType = "submarineTier",
		TargetValue = 3,
		Visible = "marianasHeat",
		HideProgress = true
	},
	marianasDeep = {
		DisplayName = "Angler-Proof...?",
		Rarity = "Rare",
		Description = "Complete the Deep Upgrade for your Submarine.",
		TargetType = "submarineTier",
		TargetValue = 4,
		Visible = "marianasIce",
		HideProgress = true
	},
	scyllaBoss = {
		DisplayName = "Terror of the Veil",
		Rarity = "Legendary",
		Description = "Defeat Scylla.",
		TargetType = "scyllaBoss",
		TargetValue = true,
		Visible = "marianasDeep"
	},
	phineasQuest = {
		DisplayName = "Baited and Hooked",
		Rarity = "Common",
		Description = "Complete Phineas' Bait Quest.",
		TargetType = "legacyQuestTracker",
		TargetData = { "baitQuest_Closed" },
		TargetValue = true,
		Visible = true
	},
	wilsonQuest = {
		DisplayName = "Lost and Found",
		Rarity = "Uncommon",
		Description = "Locate and return Wilson's lost rod.",
		TargetType = "questComplete",
		TargetData = { "WilsonLostRod" },
		TargetValue = true,
		Visible = true
	},
	agaricQuest = {
		DisplayName = "The Vigilante",
		Rarity = "Uncommon",
		Description = "Help Agaric avenge their family.",
		TargetType = "legacyQuestTracker",
		TargetData = { "agaric" },
		TargetValue = true,
		Visible = true
	},
	tridentRodUnlock = {
		DisplayName = "Desolate Ritual",
		Rarity = "Unusual",
		Description = "Open the hidden vault in the Desolate Deep.",
		TargetType = "rodUnlock",
		TargetData = { "Trident Rod" },
		TargetValue = true,
		Visible = "desolateDiscover"
	},
	chapelComplete = {
		DisplayName = "A Memory",
		Rarity = "Limited",
		SortRarity = "Exotic",
		Description = "Obtain \"Sanctuarium Lucis Seraphim.\"",
		TargetType = "questComplete",
		TargetData = { "ChapelMasterline2" },
		TargetValue = true,
		Visible = false
	},
	restlessQuest = {
		DisplayName = "Broken Dreamer",
		Rarity = "Legendary",
		Description = "Complete The Restless One's quest and obtain the Dreambreaker.",
		TargetType = "questComplete",
		TargetData = { "cultistDiscover" },
		TargetValue = true,
		Visible = "cultistDiscover"
	},
	merlinStaff = {
		DisplayName = "Fishing with Magic",
		Rarity = "Rare",
		Description = "Obtain Merlin's Staff.",
		TargetType = "rodUnlock",
		TargetData = { "Merlin's Staff" },
		TargetValue = true,
		Visible = "mineshaftDiscover"
	},
	drylandsQuest = {
		DisplayName = "Scourge of the Sands",
		Rarity = "Rare",
		Description = "Complete Paleontologist Petri's quests and tame the scourge of the sands.",
		TargetType = "companionUnlock",
		TargetData = { "Terroscuttler" },
		TargetValue = true,
		Visible = true
	},
	captConchQuest = {
		DisplayName = "Savior of Fischfest",
		Rarity = "Limited",
		SortRarity = "Legendary",
		Description = "Complete Captain Conch's quests and defeat the Flameslasher.",
		TargetType = "questComplete",
		TargetData = { "CaptConch6_Flameslasher" },
		TargetValue = true,
		Visible = false
	},
	waterparkQuest = {
		DisplayName = "Waterpark Engineer",
		Rarity = "Limited",
		SortRarity = "Rare",
		Description = "Help Waterpark Wade's get the Water Park up and running again.",
		TargetType = "questComplete",
		TargetData = { "Waterpark_TestRun" },
		TargetValue = true,
		Visible = false
	},
	compCarterQuest = {
		DisplayName = "Casually Competetive",
		Rarity = "Limited",
		SortRarity = "Unusual",
		Description = "Complete Competitive Carter's quest.",
		TargetType = "questComplete",
		TargetData = { "CompetitiveCarter" },
		TargetValue = true,
		Visible = false
	},
	sandCasterUnlock = {
		DisplayName = "Tactical Sand Castle Building",
		Rarity = "Limited",
		SortRarity = "Rare",
		Description = "Obtain the Sand Castle Caster.",
		TargetType = "rodUnlock",
		TargetData = { "Sand Castle Caster" },
		TargetValue = true,
		Visible = false
	},
	pumpkinKingQuest = {
		DisplayName = "Pumpkin King's Favor",
		Rarity = "Limited",
		SortRarity = "Rare",
		Description = "Complete the Pumpkin King's quests.",
		TargetType = "questComplete",
		TargetData = { "PumpkinKing2" },
		TargetValue = true,
		Visible = false
	},
	fischmas26Quest = {
		DisplayName = "Savior of Fischmas",
		Rarity = "Limited",
		SortRarity = "Rare",
		Description = "Complete Santa's quests and save Fischmas!",
		TargetType = "questComplete",
		TargetData = { "Fischmas25_Santa_StrangeWhale" },
		TargetValue = true,
		Visible = false
	},
	maelstromUnlock = {
		DisplayName = "Cryoshock Champion",
		Rarity = "Limited",
		SortRarity = "Legendary",
		Description = "Catch a Cryoshock Serpent and obtain the Maelstrom",
		TargetType = "rodUnlock",
		TargetData = { "Maelstrom" },
		TargetValue = true,
		Visible = false
	},
	frostwhaleFumbled = {
		DisplayName = "Frostwhale Fumbled",
		Rarity = "Limited",
		SortRarity = "Unusual",
		Description = "Obtain the Frostwhale bobber.",
		TargetType = "bobberUnlock",
		TargetData = { "Frostwhale" },
		TargetValue = true,
		Visible = false
	},
	boulderRescueQuest = {
		DisplayName = "Frostwhale Fumbled",
		Rarity = "Limited",
		SortRarity = "Unusual",
		Description = "Obtain the Frostwhale bobber.",
		TargetType = "bobberUnlock",
		TargetData = { "Frostwhale" },
		TargetValue = true,
		Visible = false
	},
	crimsonGuardQuest = {
		DisplayName = "Cool Dragon Bro",
		Rarity = "Rare",
		Description = "Complete the Crimson Guard's quest and unlock the Crimson Cavern.",
		TargetType = "bobberUnlock",
		TargetData = { "Frostwhale" },
		TargetValue = true,
		Visible = false
	},
	desolateDiscover = {
		DisplayName = "A Lone Buoy",
		Rarity = "Unusual",
		Description = "Enter the Desolate Deep.",
		TargetType = "discover",
		TargetData = { "Desolate Deep" },
		TargetValue = true,
		Visible = true
	},
	cultistDiscover = {
		DisplayName = "Corrupt Heart",
		Rarity = "Unusual",
		Description = "Find the Cultist Lair within the heart of Terrapin.",
		TargetType = "discover",
		TargetData = { "Cultist Lair" },
		TargetValue = true,
		Visible = true
	},
	mineshaftDiscover = {
		DisplayName = "Yearning for the Mines",
		Rarity = "Unusual",
		Description = "Help solve Merlin's dilemma and enter The Chasm.",
		TargetType = "discover",
		TargetData = { "Mineshaft" },
		TargetValue = true,
		Visible = true
	},
	lumiCavernDiscover = {
		DisplayName = "Spontaneous Demolition",
		Rarity = "Unusual",
		Description = "Unlock the Luminescent Cavern.",
		TargetType = "discover",
		TargetData = { "Luminescent Cavern" },
		TargetValue = true,
		Visible = "desolateDiscover"
	},
	redMarlinsMax = {
		DisplayName = "Mythwalker",
		Rarity = "Rare",
		Description = "Reach the maximum rank with the Red Marlins faction.",
		TargetType = "factionRank",
		TargetData = { "Red Marlins", "Mythwalker" },
		TargetValue = true,
		Visible = true
	},
	midasMatesMax = {
		DisplayName = "Vaultkeeper",
		Rarity = "Rare",
		Description = "Reach the maximum rank with the Midas' Mates faction.",
		TargetType = "factionRank",
		TargetData = { "Midas' Mates", "Vaultkeeper" },
		TargetValue = true,
		Visible = true
	},
	ghostsUnlock = {
		DisplayName = "Lost Soul",
		Rarity = "Legendary",
		Description = "Enter the Ghosts Tavern.",
		TargetType = "discover",
		TargetData = { "Ghosts Tavern" },
		TargetValue = true,
		Visible = true
	},
	ghostsMax = {
		DisplayName = "Eternal Reaver",
		Rarity = "Mythical",
		Description = "Reach the maximum rank with the Ghosts faction.",
		TargetType = "factionRank",
		TargetData = { "Ghosts", "Eternal Reaver" },
		TargetValue = true,
		Visible = "ghostsUnlock"
	}
}

for k, v2 in module do
	if not (not v2.Worlds or table.find(v2.Worlds, "Sea 1")) then
		continue
	end

	local v3 = k == "All" and "ENTIRE" or v2.Name
	v[`bestiaryBase_{k}`] = {
		DisplayName = `Bestiary: {v2.Name}`,
		Rarity = k == "All" and "Exotic" or v2.Limited and "Limited" or "Rare",
		SortRarity = k == "All" and "Exotic" or "Rare",
		Description = `Complete the {v3} Bestiary!`,
		TargetType = "bestiary",
		TargetId = `base_{k}`,
		TargetData = {
			Location = k,
			Type = "base"
		},
		TargetValue = 100,
		Visible = not v2.Limited
	}
	v[`bestiaryShiny_{k}`] = {
		DisplayName = `Shiny Bestiary: {v2.Name}`,
		Rarity = k == "All" and "Secret" or v2.Limited and "Limited" or "Legendary",
		SortRarity = k == "All" and "Secret" or "Legendary",
		Description = `Complete the {v3} <i>Shiny</i> Bestiary!`,
		TargetType = "bestiary",
		TargetId = `shiny_{k}`,
		TargetData = {
			Location = k,
			Type = "shiny"
		},
		TargetValue = 100,
		Visible = false
	}
	v[`bestiarySparkling_{k}`] = {
		DisplayName = `Sparkling Bestiary: {v2.Name}`,
		Rarity = k == "All" and "Secret" or v2.Limited and "Limited" or "Legendary",
		SortRarity = k == "All" and "Secret" or "Legendary",
		Description = `Complete the {v3} <i>Sparkling</i> Bestiary!`,
		TargetType = "bestiary",
		TargetId = `sparkling_{k}`,
		TargetData = {
			Location = k,
			Type = "sparkling"
		},
		TargetValue = 100,
		Visible = false
	}
	v[`bestiaryShinySparkling_{k}`] = {
		DisplayName = `Shiny Sparkling Bestiary: {v2.Name}`,
		Rarity = k == "All" and "Divine Secret" or v2.Limited and "Limited" or "Mythical",
		SortRarity = k == "All" and "Divine Secret" or "Mythical",
		Description = `Complete the {v3} <i>Shiny</i> AND <i>Sparkling</i> Bestiary!`,
		TargetType = "bestiary",
		TargetId = `shinySparkling_{k}`,
		TargetData = {
			Location = k,
			Type = "shinySparkling"
		},
		TargetValue = 100,
		Visible = false
	}
end

for k, v2 in v do
	v2.Id = k
end

return {}