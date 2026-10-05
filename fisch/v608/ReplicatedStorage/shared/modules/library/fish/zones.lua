local ReplicatedStorage = game:GetService("ReplicatedStorage")
return {
	DevTest = {
		Pool = { "Skolopendra" },
		CantBeWormholed = true,
		Priority = 2
	},
	["Obsidian Trench"] = {
		Pool = {
			"Obsidian Gaveltooth",
			"Cinder-Crust Gar",
			"Scoria Scorpionfish",
			"Shatter-Tooth Shark",
			"Magma-Glass Marlin",
			"Tectonic Toadfish",
			"Ash-Cloud Angelfish",
			"Shatterjaw Shark",
			"Pumice Puffer",
			"Basalt Behemoth"
		},
		CantBeWormholed = true,
		Priority = 3
	},
	["Obsidian Trench - Charybdis"] = {
		Pool = {
			"Obsidian Gaveltooth",
			"Cinder-Crust Gar",
			"Scoria Scorpionfish",
			"Shatter-Tooth Shark",
			"Magma-Glass Marlin",
			"Tectonic Toadfish",
			"Ash-Cloud Angelfish",
			"Shatterjaw Shark",
			"Pumice Puffer",
			"Basalt Behemoth",
			"Charybdis"
		},
		CantBeWormholed = true,
		Priority = 4,
		IsHunt = true
	},
	["Obsidian Trench - Skolopendra"] = {
		Pool = {
			"Obsidian Gaveltooth",
			"Cinder-Crust Gar",
			"Scoria Scorpionfish",
			"Shatter-Tooth Shark",
			"Magma-Glass Marlin",
			"Tectonic Toadfish",
			"Ash-Cloud Angelfish",
			"Shatterjaw Shark",
			"Pumice Puffer",
			"Basalt Behemoth",
			"Skolopendra"
		},
		CantBeWormholed = true,
		Priority = 4,
		IsHunt = true
	},
	["Abaia Hunt"] = {
		Pool = {
			"Crested Relic",
			"Empyrean Relic",
			"Celestial Pearl Danio",
			"Endler's Livebearer",
			"Ruby Neon Eviota",
			"Danionella Cerebrum",
			"Parotocinclus Halys",
			"Moenkhausia Pitanga",
			"Dwarf Pea Puffer",
			"Pink-Spotted Shrimpgoby",
			"Myloplus Sauron",
			"Populi Blind Catfish",
			"African Butterflyfish",
			"Blackcap Basslet",
			"Hawaiian Ventralis Anthias",
			"Vibranium Fairy Wrasse",
			"Aphrodite Anthias",
			"Rose-Veiled Fairy Wrasse"
		},
		Priority = 5,
		CantBeWormholed = true,
		IsHunt = true
	},
	Skycrest = {
		Pool = {
			"Crested Relic",
			"Empyrean Relic",
			"Celestial Pearl Danio",
			"Endler's Livebearer",
			"Ruby Neon Eviota",
			"Danionella Cerebrum",
			"Parotocinclus Halys",
			"Moenkhausia Pitanga",
			"Dwarf Pea Puffer",
			"Pink-Spotted Shrimpgoby",
			"Myloplus Sauron",
			"Populi Blind Catfish",
			"African Butterflyfish",
			"Blackcap Basslet",
			"Hawaiian Ventralis Anthias",
			"Vibranium Fairy Wrasse",
			"Aphrodite Anthias",
			"Rose-Veiled Fairy Wrasse"
		},
		Priority = 2,
		CantBeWormholed = true
	},
	["Abaia's Chamber"] = {
		Pool = {
			"Crested Relic",
			"Empyrean Relic",
			"Celestial Pearl Danio",
			"Endler's Livebearer",
			"Ruby Neon Eviota",
			"Danionella Cerebrum",
			"Parotocinclus Halys",
			"Moenkhausia Pitanga",
			"Dwarf Pea Puffer",
			"Pink-Spotted Shrimpgoby",
			"Myloplus Sauron",
			"Populi Blind Catfish",
			"African Butterflyfish",
			"Blackcap Basslet",
			"Hawaiian Ventralis Anthias",
			"Vibranium Fairy Wrasse",
			"Aphrodite Anthias",
			"Rose-Veiled Fairy Wrasse"
		},
		Priority = 2
	},
	["Sei Whale Pool"] = {
		Pool = {
			"Sei Whale",
			"Tire",
			"Boot",
			"Common Crate",
			"Seaweed",
			"Carbon Crate",
			"Quality Bait Crate",
			"Common Crate",
			"Bait Crate",
			"Mackerel",
			"Cod",
			"Amberjack",
			"Sardine",
			"Halibut",
			"Salmon",
			"Mullet",
			"Bluefin Tuna",
			"Yellowfin Tuna",
			"Barracuda",
			"Sea Bass",
			"Chinook Salmon",
			"Sea Pickle",
			"Swordfish",
			"Anglerfish",
			"Coelacanth",
			"Sailfish",
			"Stingray",
			"Sawfish",
			"Moonfish",
			"Dolphin",
			"Flying Fish",
			"Colossal Squid",
			"Oarfish",
			"Crown Bass",
			"Mythic Fish",
			"Long Pike",
			"Mustard"
		},
		Priority = 40,
		CantBeWormholed = true,
		IsHunt = true
	},
	["Goliath Siphonophore Hunt"] = {
		Pool = {
			"Goliath Siphonophore",
			"Starlit Seahorse",
			"Boreal Man o' War",
			"Celestial Crab",
			"Peacock Squid",
			"Nebulous Comb Jelly"
		},
		Priority = 5,
		CantBeWormholed = true,
		IsHunt = true
	},
	["Monstrous Cusk Hunt"] = {
		Pool = { "Monstrous Cusk" },
		Priority = 5,
		CantBeWormholed = true,
		IsHunt = true,
		FishingStatsMultiply = {
			Lure = 0.5
		}
	},
	["Outer Deep"] = {
		Pool = {
			"Snipefish",
			"Tripod Fish",
			"Broken Flashlight",
			"Mantis Shrimp",
			"Pistol Shrimp",
			"Sacabambaspis",
			"Papillated Redbait",
			"Abadhah Chromis",
			"Mero Goby",
			"Nkosi Pygmy Pipehorse",
			"Banded Dragonfish",
			"Formosa Seabass",
			"Longnose Lancetfish",
			"Pacific Blackdragon",
			"Greater Silver Hatchetfish",
			"Deep-sea Lizardfish",
			"Whalefish",
			"Pacific Hatchetfish",
			"Japanese Linebelly Swallower"
		},
		Priority = 2,
		FishingStatsMultiply = {
			Lure = 0.5
		}
	},
	["Lower Deep"] = {
		Pool = {
			"Bigfin Squid",
			"X-ray Tetra",
			"Bent Harpoon",
			"West Australian Lanternshark",
			"Dark Snailfish",
			"Sleek Snailfish",
			"Andaman Shortnose Chimaera",
			"Devil Scorpionfish",
			"Common Fangtooth",
			"Pacific Footballfish",
			"Paresca Whipnose Anglerfish",
			"Black-mouth Beardfish",
			"Stout Blacksmelt",
			"Atlantic Dragonfish",
			"Lepidion",
			"Pacific Longnose Chimaera",
			"Jaco Eelpout",
			"Bigspine Spookfish",
			"Arbiter Snailfish",
			"Icelus Hypselopterus",
			"Banded Snailfish",
			"Luminous Hake"
		},
		Priority = 2,
		FishingStatsMultiply = {
			Lure = 0.5
		}
	},
	["Gloomy Crevice"] = {
		Pool = {
			"Crushed Diving Helmet",
			"Bluntnose Sixgill Shark",
			"Greenland Shark",
			"Humpback Anglerfish",
			"Deep-sea Anglerfish",
			"One-jaw Eel",
			"Shortspine Thornyhead",
			"Pacific Flatnose",
			"Pacific Sleeper Shark",
			"Pelagic Stingray",
			"Longnose Spiny Eel",
			"Long-Barbel Snailfish",
			"Spiny Snailfish",
			"Delangle's Eelpout",
			"Renate's Eelpout",
			"Argosgeorgiae Snailfish",
			"Slender Snipe Eel",
			"Yeti Crab",
			"Abyssal Skate",
			"Faceless Cusk"
		},
		Priority = 2,
		Disturbs = "MonstrousCuskHunt",
		FishingStatsMultiply = {
			Lure = 0.5
		}
	},
	Claypans = {
		Pool = {
			"Rock",
			"Boot",
			"Dryskin Minnow",
			"Cactus-Feeder Barb",
			"Torrential Catfish",
			"Claypan Guppy",
			"Sun-Blistered Perch"
		},
		Priority = 2,
		CantBeWormholed = true
	},
	["Sunken Reservoir"] = {
		Pool = {
			"Rock",
			"Driftwood",
			"Boot",
			"Stalactite",
			"Sandbar Loach",
			"Mirage Fin",
			"Dustveil Ray",
			"Prickly Gurnard",
			"Reservoir Squalus"
		},
		Priority = 2
	},
	["Drylands Sand"] = {
		Pool = {
			"Rock",
			"Bone",
			"Destroyed Fossil",
			"Calcified Trilobite",
			"Petrified Ammonite",
			"Bone-Plate Dace",
			"Silt-Crusted Carp",
			"Shard-Tooth Salmon",
			"Marrow Pike",
			"Duneseat Crustacean",
			"Strata-Bound Bass",
			"Dune-Stalker Eel"
		},
		Disturbs = { "DustStorm" },
		Priority = 1,
		CustomCondition = function(_, p, instance)
			local value = instance:FindFirstChild("Stats") and instance.Stats:FindFirstChild("rod") and instance.Stats.rod.Value
			local v = value == "Marrow Rod" or value == "Terrotrapper" or value == "Masterline Rod"

			if v and (instance.Stats:FindFirstChild("bobber") and instance.Stats.bobber.Value) == "Sand Sifter" then
				return true
			end

			local rod = p.Data.NewFormat.Rods[value]
			local v2 = v and "You'll need to equip the <b>Sand Sifter</b> bobber to fish here." or "Your current rod can't catch anything here..."

			if not (value and rod) then
				return false, v2
			end

			if rod.keeperboundActive then
				if rod.keeperboundAffixes and table.find(rod.keeperboundAffixes, "Sifting") then
					return true
				end
			elseif rod.secondaryEnchant == "Dune" then
				return true
			end

			return false, v2
		end
	},
	["Terrosunder Pool"] = {
		Pool = {
			"Rock",
			"Bone",
			"Destroyed Fossil",
			"Calcified Trilobite",
			"Petrified Ammonite",
			"Bone-Plate Dace",
			"Silt-Crusted Carp",
			"Shard-Tooth Salmon",
			"Marrow Pike",
			"Duneseat Crustacean",
			"Strata-Bound Bass",
			"Dune-Stalker Eel",
			"Ancient Coelacanth",
			"Sunder-Whelp Jaw",
			"Terrosunder Skull",
			"Terrosunder"
		},
		CantBeWormholed = true,
		Priority = 3,
		IsHunt = true,
		CustomCondition = function(_, p, instance)
			local value = instance:FindFirstChild("Stats") and instance.Stats:FindFirstChild("rod") and instance.Stats.rod.Value
			local v = value == "Marrow Rod" or value == "Terrotrapper" or value == "Masterline Rod"

			if v and (instance.Stats:FindFirstChild("bobber") and instance.Stats.bobber.Value) == "Sand Sifter" then
				return true
			end

			local rod = p.Data.NewFormat.Rods[value]
			local v2 = v and "You'll need to equip the <b>Sand Sifter</b> bobber to fish here." or "Your current rod can't catch anything here..."

			if not (value and rod) then
				return false, v2
			end

			if rod.keeperboundActive then
				if rod.keeperboundAffixes and table.find(rod.keeperboundAffixes, "Sifting") then
					return true
				end
			elseif rod.secondaryEnchant == "Dune" then
				return true
			end

			return false, v2
		end
	},
	["Photic Terrosunder Pool"] = {
		Pool = {
			"Rock",
			"Driftwood",
			"Boot",
			"Stalactite",
			"Sandbar Loach",
			"Mirage Fin",
			"Dustveil Ray",
			"Prickly Gurnard",
			"Reservoir Squalus",
			"Photic Terrosunder"
		},
		CantBeWormholed = true,
		Priority = 3,
		IsHunt = true
	},
	["Patriot Shark Hunt"] = {
		Pool = {
			"Firecracker Crab",
			"Liberty Lobster",
			"Starry Snapper",
			"Sparkfin Salmon",
			"Patriot Great White Shark",
			"Patriot Hammerhead Shark",
			"Patriot Whale Shark"
		},
		Priority = 10,
		CantBeWormholed = true,
		IsHunt = true
	},
	["King Crabstle Hunt"] = {
		Pool = {
			"King Crabstle",
			"Flipflopper",
			"Beach Towel",
			"Chillin' Crab",
			"Ice Cream Carp",
			"Lifeguard Lobster",
			"Lemonade",
			"Water Balloon",
			"Pool Noodle Eel",
			"Crabby Coconut",
			"Popsicle Pike",
			"BBQ Bass",
			"Floatie Fugu",
			"Tiki Trout",
			"Slushy",
			"Tanning Trout",
			"Cooler Catfish",
			"Picnic Pufferfish",
			"Sand-Sculpted Shark",
			"Coastal Crate",
			"Sunslasher",
			"Beached Relic",
			"Tropical Relic",
			"Paradise Relic"
		},
		Priority = 5,
		CantBeWormholed = true,
		IsHunt = true
	},
	["Glitched Pool"] = {
		Pool = {
			"Tire",
			"Carbon Crate",
			"Common Crate",
			"Bait Crate",
			"Fish Barrel",
			"Titanic Black Seadevil",
			"Leviathan Humpback Anglerfish",
			"Abyssal Bearded Seadevil",
			"Radiant Triplewart Seadevil",
			"Twilight Glowfish",
			"Anglerfish",
			"Orchid Anglerfish",
			"Infant Giant Seadevil",
			"Giant Seadevil",
			"Compact Disc"
		},
		CantBeWormholed = true,
		Priority = 5
	},
	["Livyatan Hunt"] = {
		Pool = {
			"Livyatan",
			"Tire",
			"Carbon Crate",
			"Common Crate",
			"Bait Crate",
			"Fish Barrel",
			"Cod",
			"Sardine",
			"Sea Bass",
			"Mullet",
			"Piranha",
			"Anomalocaris",
			"Starfish",
			"Onychodus",
			"Acanthodii",
			"Xiphactinus",
			"Hyneria",
			"Cobia",
			"Ginsu Shark",
			"Dunkleosteus",
			"Colossal Squid",
			"Helicoprion",
			"Mosasaurus",
			"Banana",
			"Ancient Fragment",
			"Meg's Fang",
			"Meg's Spine"
		},
		Priority = 5,
		CantBeWormholed = true,
		IsHunt = true
	},
	["Megamouth Hunt"] = {
		Pool = {
			"Megamouth Shark",
			"Tire",
			"Boot",
			"Common Crate",
			"Seaweed",
			"Carbon Crate",
			"Quality Bait Crate",
			"Common Crate",
			"Bait Crate",
			"Mackerel",
			"Cod",
			"Amberjack",
			"Sardine",
			"Halibut",
			"Salmon",
			"Mullet",
			"Bluefin Tuna",
			"Yellowfin Tuna",
			"Barracuda",
			"Sea Bass",
			"Chinook Salmon",
			"Sea Pickle",
			"Swordfish",
			"Anglerfish",
			"Coelacanth",
			"Sailfish",
			"Stingray",
			"Sawfish",
			"Moonfish",
			"Dolphin",
			"Flying Fish",
			"Colossal Squid",
			"Oarfish",
			"Crown Bass",
			"Mythic Fish",
			"Long Pike",
			"Mustard"
		},
		Priority = 5,
		CantBeWormholed = true,
		IsHunt = true
	},
	["Enchanted Crevice"] = {
		Pool = {
			"Tire",
			"Boot",
			"Seaweed",
			"Crackfin Minnow",
			"Dustscale Dace",
			"Pale Crevice Tang",
			"Glassblue Herring",
			"Lapisjaw Jack",
			"Crevice Sturgeon",
			"Altarfin Grouper",
			"Adumbral Shark",
			"Sovereign Oarfish"
		},
		Priority = 2
	},
	["Bellona's Frenzy of War"] = {
		Pool = {
			"Common Crate",
			"Bait Crate",
			"Fish Barrel",
			"Rusty Hook",
			"Rustscale Minnow",
			"Splinterfin Carp",
			"Ironjaw Guppy",
			"Speartail Pike",
			"Warstripe Bass",
			"Shieldbearer Koi",
			"Gladiator Eel",
			"Bloodfang Barracuda"
		},
		Priority = 3,
		Disturbs = { "WarSurge", "LegionnaireLampreyHunt" }
	},
	["Apollo's Song of Light"] = {
		Pool = {
			"Common Crate",
			"Bait Crate",
			"Fish Barrel",
			"Broken Arrow",
			"Gleamfin Minnow",
			"Sunscale Tetra",
			"Beamtail Koi",
			"Lumen Bass",
			"Prismfin Trout",
			"Auric Angelfish",
			"Dawnflare Eel",
			"Solstice Ray"
		},
		Priority = 3,
		Disturbs = { "SolarChorus", "HeliosRayHunt" },
		CustomCondition = function(_, p, _)
			if p.Data.NewFormat.WrathOfOlympus.DivineSealsBroken.Bellona then
				return true
			end

			return false, "You must break Bellona's seal before fishing here."
		end
	},
	["Poseidon's Storm of Floods"] = {
		Pool = {
			"Common Crate",
			"Bait Crate",
			"Fish Barrel",
			"Chipped Crown",
			"Tidepool Minnow",
			"Ripplefin Carp",
			"Currenttail Bass",
			"Surftail Guppy",
			"Foamcrest Koi",
			"King's Crest Eel"
		},
		Priority = 3,
		Disturbs = { "StormFlood", "TidecrasherArchonHunt" },
		CustomCondition = function(_, p, _)
			if p.Data.NewFormat.WrathOfOlympus.DivineSealsBroken.Apollo then
				return true
			end

			return false, "You must break Apollo's seal before fishing here."
		end
	},
	["Zeus's Thunder of Chaos"] = {
		Pool = {
			"Common Crate",
			"Bait Crate",
			"Fish Barrel",
			"Broken Gear",
			"Sparkfin Minnow",
			"Static Guppy",
			"Voltstripe Carp",
			"Chargeback Bass",
			"Ion Pike",
			"Arcflash Koi",
			"Thunderclap Crab"
		},
		Priority = 4,
		Disturbs = "KeraunoWyrmHunt",
		CustomCondition = function(_, p, _)
			if p.Data.NewFormat.WrathOfOlympus.DivineSealsBroken.Poseidon then
				return true
			end

			return false, "You must break Poseidon's seal before fishing here."
		end
	},
	["Hades' Underworld of Indefinite"] = {
		Pool = {
			"Common Crate",
			"Bait Crate",
			"Fish Barrel",
			"Skull",
			"Wispfin Minnow",
			"Duskscale Carp",
			"Murkback Bass",
			"Hollow Pike",
			"Veilfin Koi",
			"Revenant Eel",
			"Shadow Ray",
			"Grave Serpent"
		},
		Priority = 3,
		CustomCondition = function(_, p, _)
			if p.Data.NewFormat.WrathOfOlympus.DivineSealsBroken.Zeus then
				return true
			end

			return false, "You must break Zeus's seal before fishing here."
		end
	},
	["Olympian Fissure"] = {
		Pool = {
			"Boot",
			"Common Crate",
			"Bait Crate",
			"Fractured Minnow",
			"Splitfin Koi",
			"Divine Aberrant",
			"Aegisbreaker Ray",
			"Titanspawn Serpent",
			"Primordial Devourer"
		},
		Priority = 3,
		CustomCondition = function(_, p, _)
			if p.Data.NewFormat.WrathOfOlympus.DivineSealsBroken.Hades then
				return true
			end

			return false, "You must break Hades' seal before fishing here."
		end
	},
	["Tidecrasher Archon Hunt"] = {
		Pool = {
			"Common Crate",
			"Bait Crate",
			"Fish Barrel",
			"Chipped Crown",
			"Tidepool Minnow",
			"Ripplefin Carp",
			"Currenttail Bass",
			"Surftail Guppy",
			"Surge Pickerel",
			"Foamcrest Koi",
			"Tridentfish",
			"Whirlpool Snapper",
			"King's Crest Eel",
			"Tsunami Whale"
		},
		Priority = 5,
		CantBeWormholed = true,
		IsHunt = true,
		CustomCondition = function(_, p, _)
			if p.Data.NewFormat.WrathOfOlympus.DivineSealsBroken.Apollo then
				return true
			end

			return false, "You must break Apollo's seal before fishing here."
		end
	},
	["Soul Pool"] = {
		Pool = {
			"Common Crate",
			"Bait Crate",
			"Fish Barrel",
			"Skull",
			"Wispfin Minnow",
			"Duskscale Carp",
			"Fading Guppy",
			"Murkback Bass",
			"Hollow Pike",
			"Veilfin Koi",
			"Revenant Eel",
			"Shadow Ray",
			"Grave Serpent",
			"Spectral Whale"
		},
		Priority = 3,
		CantBeWormholed = true,
		CustomCondition = function(_, p, _)
			if p.Data.NewFormat.WrathOfOlympus.DivineSealsBroken.Zeus then
				return true
			end

			return false, "You must break Zeus's seal before fishing here."
		end
	},
	["Helios Sunray Hunt"] = {
		Pool = {
			"Common Crate",
			"Bait Crate",
			"Fish Barrel",
			"Broken Arrow",
			"Gleamfin Minnow",
			"Sunscale Tetra",
			"Radiant Guppy",
			"Beamtail Koi",
			"Lumen Bass",
			"Prismfin Trout",
			"Auric Angelfish",
			"Dawnflare Eel",
			"Solstice Ray",
			"Empyrean Sunwhale",
			"Helios Sunray"
		},
		Priority = 6,
		CantBeWormholed = true,
		IsHunt = true,
		CustomCondition = function(_, p, _)
			if p.Data.NewFormat.WrathOfOlympus.DivineSealsBroken.Bellona then
				return true
			end

			return false, "You must break Bellona's seal before fishing here."
		end
	},
	["Styx Angler Hunt"] = {
		Pool = {
			"Common Crate",
			"Bait Crate",
			"Fish Barrel",
			"Skull",
			"Wispfin Minnow",
			"Duskscale Carp",
			"Fading Guppy",
			"Murkback Bass",
			"Hollow Pike",
			"Veilfin Koi",
			"Revenant Eel",
			"Shadow Ray",
			"Grave Serpent",
			"Spectral Whale"
		},
		Priority = 5,
		CantBeWormholed = true,
		IsHunt = true,
		CustomCondition = function(_, p, _)
			if p.Data.NewFormat.WrathOfOlympus.DivineSealsBroken.Zeus then
				return true
			end

			return false, "You must break Zeus's seal before fishing here."
		end
	},
	["Wisp Haunt"] = {
		Pool = {
			"Common Crate",
			"Bait Crate",
			"Fish Barrel",
			"Skull",
			"Wispfin Minnow",
			"Duskscale Carp",
			"Fading Guppy",
			"Murkback Bass",
			"Hollow Pike",
			"Veilfin Koi",
			"Revenant Eel",
			"Shadow Ray",
			"Grave Serpent",
			"Spectral Whale"
		},
		Priority = 3,
		CantBeWormholed = true,
		CustomCondition = function(_, p, _)
			if p.Data.NewFormat.WrathOfOlympus.DivineSealsBroken.Zeus then
				return true
			end

			return false, "You must break Zeus's seal before fishing here."
		end
	},
	["Legionnaire Lamprey Hunt"] = {
		Pool = {
			"Common Crate",
			"Bait Crate",
			"Fish Barrel",
			"Rusty Hook",
			"Rustscale Minnow",
			"Splinterfin Carp",
			"Bladeback Perch",
			"Ironjaw Guppy",
			"Speartail Pike",
			"Warstripe Bass",
			"Shieldbearer Koi",
			"Gladiator Eel",
			"Bloodfang Barracuda",
			"Warlord Sturgeon"
		},
		Priority = 5,
		CantBeWormholed = true,
		IsHunt = true
	},
	["Olympian Devil Hunt"] = {
		Pool = {
			"Boot",
			"Common Crate",
			"Bait Crate",
			"Fractured Minnow",
			"Splitfin Koi",
			"Divine Aberrant",
			"Aegisbreaker Ray",
			"Titanspawn Serpent",
			"Primordial Devourer",
			"Olympian Devil"
		},
		Priority = 5,
		IsHunt = true,
		CantBeWormholed = true,
		CustomCondition = function(_, p, _)
			if p.Data.NewFormat.WrathOfOlympus.DivineSealsBroken.Hades then
				return true
			end

			return false, "You must break Hades' seal before fishing here."
		end
	},
	["Atlantean Storm"] = {
		Pool = {
			"Void Angler",
			"Tempest Ray",
			"Abyss Snapper",
			"Whirlpool Marlin",
			"Vortex Barracuda",
			"Typhoon Tuna",
			"Cyclone Mako",
			"Maelstorm Shark"
		},
		Priority = 4
	},
	["Kerauno Wyrm Pool"] = {
		Pool = {
			"Common Crate",
			"Bait Crate",
			"Fish Barrel",
			"Broken Gear",
			"Sparkfin Minnow",
			"Static Guppy",
			"Voltstripe Carp",
			"Chargeback Bass",
			"Ion Pike",
			"Arcflash Koi",
			"Stormscale Eel",
			"Thunderclap Crab",
			"Fulmina Serpent",
			"Skybreaker Leviathan",
			"Kerauno Wyrm"
		},
		IsHunt = true,
		Priority = 10,
		CantBeWormholed = true,
		CustomCondition = function(_, p, _)
			if p.Data.NewFormat.WrathOfOlympus.DivineSealsBroken.Poseidon then
				return true
			end

			return false, "You must break Poseidon's seal before fishing here."
		end
	},
	["Everturn Forest"] = {
		Pool = {
			"Boot",
			"Common Crate",
			"Bait Crate",
			"Fish Barrel",
			"Seaweed",
			"Frostpetal Minnow",
			"Icebloom Koi",
			"Hoarfrost Pike",
			"Glacial Bark Gar",
			"Glaciaseer Sturgeon",
			"Petaldrift Koi",
			"Pollen Guppy",
			"Bloomfin Trout",
			"Verdant Spiritfish",
			"Floraseer Sturgeon",
			"Sunleaf Sunfish",
			"Canopy Dartfish",
			"Sapflow Eel",
			"Thicket Leviabass",
			"Solarseer Sturgeon",
			"Amberleaf Carp",
			"Rotwood Perch",
			"Harvest Sunfish",
			"Duskbriar Gar",
			"Umbraleaf Sturgeon",
			"Baby Oakling",
			"Oakling"
		},
		Priority = 2
	},
	["Dreadfin Hunt"] = {
		Pool = {
			"Tire",
			"Boot",
			"Common Crate",
			"Bait Crate",
			"Fish Barrel",
			"Seaweed",
			"Boots",
			"Bone",
			"Mackerel",
			"Cod",
			"Amberjack",
			"Nurse Shark",
			"Porgy",
			"Sardine",
			"Halibut",
			"Mullet",
			"Salmon",
			"Yellowfin Tuna",
			"Sea Bass",
			"Chinook Salmon",
			"Haddock",
			"Barracuda",
			"Sea Pickle",
			"Pufferfish",
			"Swordfish",
			"Bluefin Tuna",
			"Sailfish",
			"Stingray",
			"Sawfish",
			"Moonfish",
			"Crown Bass",
			"Dolphin",
			"Flying Fish",
			"Mythic Fish",
			"Long Pike",
			"Mustard",
			"Dreadfin"
		},
		Priority = 5,
		CantBeWormholed = true,
		IsHunt = true
	},
	["Lucky Gold"] = {
		Pool = {
			"Tire",
			"Boot",
			"Common Crate",
			"Bait Crate",
			"Fish Barrel",
			"Seaweed",
			"Boots",
			"Mackerel",
			"Cod",
			"Amberjack",
			"Nurse Shark",
			"Porgy",
			"Sardine",
			"Halibut",
			"Mullet",
			"Salmon",
			"Yellowfin Tuna",
			"Sea Bass",
			"Chinook Salmon",
			"Haddock",
			"Barracuda",
			"Pufferfish",
			"Swordfish",
			"Bluefin Tuna",
			"Sailfish",
			"Stingray",
			"Sawfish",
			"Moonfish",
			"Crown Bass",
			"Dolphin",
			"Flying Fish",
			"Shamrock Salmon",
			"Clover Carp",
			"Rainbow Ribbonfish",
			"Fortune Flounder",
			"Rainbow Leviathan"
		},
		Priority = 5,
		CantBeWormholed = true,
		RarityLuckFactorBoosts = {
			Mythical = 2,
			Exotic = 3,
			Secret = 3
		}
	},
	["Rotbloom Hunt"] = {
		Pool = {
			"Bone",
			"Spore Lurker",
			"Mire Krakenling",
			"Widow Bloom",
			"Rotcoil Eel",
			"Bog Skulker",
			"Chlorophage",
			"Toxic Jellymass",
			"Blight Idol"
		},
		Priority = 5,
		CantBeWormholed = true,
		IsHunt = true,
		RequiredDurability = 150,
		RarityBaseChanceBoosts = {
			Common = 0.25
		}
	},
	["Flower Guardian Hunt"] = {
		Pool = {
			"Driftwood",
			"Petal Ray",
			"Garden Snail",
			"Oversized Leaf",
			"Colossal Flower",
			"Thorn Ribbon Eel",
			"Bloomback Turtle",
			"Flower Flounder",
			"Diamond Daisy",
			"Butterfly",
			"Orchid Anglerfish",
			"Leafscale Lemon Shark",
			"🦋"
		},
		Priority = 5,
		CantBeWormholed = true,
		IsHunt = true
	},
	["Toxic Boil"] = {
		Pool = {
			"Spore Lurker",
			"Mire Krakenling",
			"Widow Bloom",
			"Rotcoil Eel",
			"Bog Skulker",
			"Chlorophage",
			"Toxic Jellymass",
			"Mycotide Serpent",
			"Venom Maw",
			"Blight Idol"
		},
		Priority = 100,
		CantBeWormholed = true,
		Disturbs = "RotbloomHunt",
		RequiredDurability = 150,
		RarityBaseChanceBoosts = {
			Common = 0.25
		}
	},
	["Above the Clouds"] = {
		Pool = {
			"Sky Bass",
			"Winged Carp",
			"Flying Pufferfish",
			"Flying Fish",
			"Harmonic Dove"
		},
		CantBeWormholed = true,
		Priority = 1,
		Disturbs = "WyvernHunt",
		MutationIndicatorEnabled = true,
		RarityLuckFactorBoosts = {
			Mythical = 0.5,
			Exotic = 0.5,
			Secret = 0.5
		},
		CustomCondition = function(_, p, _)
			local aboveTheClouds = p.Data.NewFormat.TimeTrials.AboveTheClouds

			if aboveTheClouds and aboveTheClouds.CompleteCount and not (aboveTheClouds.CompleteCount < 1) then
				return true
			end

			return false, "You must complete the gliding challenge before fishing here."
		end
	},
	["Above the Clouds Roaming"] = {
		Pool = {
			"Sky Bass",
			"Winged Carp",
			"Flying Pufferfish",
			"Flying Fish",
			"Harmonic Dove"
		},
		CantBeWormholed = true,
		Priority = 1,
		Disturbs = "WyvernHunt",
		MutationIndicatorEnabled = true,
		RarityLuckFactorBoosts = {
			Mythical = 0.5,
			Exotic = 0.5,
			Secret = 0.5
		},
		CustomCondition = function(_, p, _)
			local aboveTheClouds = p.Data.NewFormat.TimeTrials.AboveTheClouds

			if aboveTheClouds and aboveTheClouds.CompleteCount and not (aboveTheClouds.CompleteCount < 1) then
				return true
			end

			return false, "You must complete the gliding challenge before fishing here."
		end
	},
	["Wyvern Hunt"] = {
		Pool = {
			"Sky Bass",
			"Winged Carp",
			"Flying Pufferfish",
			"Flying Fish",
			"Harmonic Dove",
			"Wyvern"
		},
		CantBeWormholed = true,
		Priority = 2,
		IsHunt = true,
		MutationIndicatorEnabled = true,
		RarityLuckFactorBoosts = {
			Mythical = 0.5,
			Secret = 0.5
		},
		CustomCondition = function(_, p, _)
			local aboveTheClouds = p.Data.NewFormat.TimeTrials.AboveTheClouds

			if aboveTheClouds and aboveTheClouds.CompleteCount and not (aboveTheClouds.CompleteCount < 1) then
				return true
			end

			return false, "You must complete the gliding challenge before fishing here."
		end
	},
	["Skeletal Leviathan Hunt"] = {
		Pool = {
			"Volcanic Geode",
			"Rock",
			"Basalt",
			"Basalt Loach",
			"Scoria Swordfish",
			"Coalfin Darter",
			"Lava Clam",
			"Obsidian Ray",
			"Slag",
			"Smeltjaw Snapper",
			"Magmatic Hermit Crab",
			"Molten Serpent",
			"Infernal Isonade",
			"Cindercoil Eel",
			"Skeletal Leviathan"
		},
		Priority = 5,
		CantBeWormholed = true,
		RequiredDurability = 100,
		IsHunt = true
	},
	["Scoria Reach"] = {
		Pool = {
			"Volcanic Geode",
			"Rock",
			"Basalt",
			"Basalt Loach",
			"Scoria Swordfish",
			"Coalfin Darter",
			"Lava Clam",
			"Obsidian Ray",
			"Slag",
			"Smeltjaw Snapper",
			"Magmatic Hermit Crab"
		},
		Priority = 2,
		RequiredDurability = 100
	},
	["Scoria Reach Volcano"] = {
		Pool = {
			"Volcanic Geode",
			"Rock",
			"Basalt",
			"Basalt Loach",
			"Scoria Swordfish",
			"Coalfin Darter",
			"Lava Clam",
			"Obsidian Ray",
			"Slag",
			"Smeltjaw Snapper",
			"Magmatic Hermit Crab"
		},
		Disturbs = "SkeletalLeviathanHunt",
		Priority = 4,
		RequiredDurability = 100
	},
	["Streamer Hideout"] = {
		Pool = {
			"Rock",
			"Common Crate",
			"Bait Crate",
			"Fish Barrel",
			"Seaweed",
			"Boots",
			"Mackerel",
			"Cod",
			"Amberjack",
			"Nurse Shark",
			"Porgy",
			"Sardine",
			"Halibut",
			"Mullet",
			"Salmon",
			"Yellowfin Tuna",
			"Sea Bass",
			"Chinook Salmon",
			"Haddock",
			"Barracuda",
			"Clout Carp"
		},
		Priority = 2,
		CantBeWormholed = true
	},
	["Sweet Stream"] = {
		Pool = {
			"Salmon",
			"Sand Dollar",
			"Sardine",
			"Cod",
			"Chinook Salmon",
			"Kissing Gourami",
			"Cupid Crab",
			"Rose Bouquet",
			"Stuffed Bear",
			"Heart Cookie",
			"Heart Sand Dollar",
			"Sweetheart Seahorse",
			"Cupid Relic"
		},
		Priority = 2,
		CantBeWormholed = true
	},
	["Sweetheart Shores"] = {
		Pool = {
			"Salmon",
			"Sand Dollar",
			"Sardine",
			"Cod",
			"Chinook Salmon",
			"Kissing Gourami",
			"Cupid Crab",
			"Rose Bouquet",
			"Stuffed Bear",
			"Heart Cookie",
			"Heart Sand Dollar",
			"Cupid Relic"
		},
		Priority = 1,
		CantBeWormholed = true,
		RarityBaseChanceBoosts = {
			Common = 0.3,
			Rare = 0.5
		}
	},
	["Sweetheart Shores Waterfall"] = {
		Pool = {
			"Rock",
			"Driftwood",
			"Trout",
			"Common Crate",
			"Bait Crate",
			"Carbon Crate",
			"Bream",
			"Carp",
			"Eel",
			"Kissing Gourami",
			"Cupid Crab",
			"Rose Bouquet",
			"Stuffed Bear",
			"Heart Cookie",
			"Heart Sand Dollar",
			"Cupid Relic"
		},
		Priority = 2,
		CantBeWormholed = true,
		RarityBaseChanceBoosts = {
			Common = 0.3,
			Rare = 0.5
		}
	},
	["Sweetheart Shores Pond"] = {
		Pool = {
			"Driftwood",
			"Trout",
			"Minnow",
			"Bait Crate",
			"Quality Bait Crate",
			"Bream",
			"Carp",
			"Eel",
			"Kissing Gourami",
			"Cupid Crab",
			"Rose Bouquet",
			"Stuffed Bear",
			"Heart Cookie",
			"Heart Sand Dollar",
			"Cupid Relic"
		},
		Priority = 2,
		CantBeWormholed = true,
		RarityBaseChanceBoosts = {
			Common = 0.3,
			Rare = 0.5
		}
	},
	["Sweetheart Shores Well"] = {
		Pool = {
			"Rock",
			"Log",
			"Seaweed",
			"Tire",
			"Boot",
			"Common Crate",
			"Bait Crate",
			"Quality Bait Crate"
		},
		Priority = 2,
		CantBeWormholed = true
	},
	Lovestorm = {
		Pool = {
			"Tire",
			"Boot",
			"Common Crate",
			"Seaweed",
			"Carbon Crate",
			"Quality Bait Crate",
			"Common Crate",
			"Bait Crate",
			"Mackerel",
			"Cod",
			"Amberjack",
			"Sardine",
			"Halibut",
			"Salmon",
			"Mullet",
			"Bluefin Tuna",
			"Yellowfin Tuna",
			"Barracuda",
			"Sea Bass",
			"Chinook Salmon",
			"Sea Pickle",
			"Swordfish",
			"Anglerfish",
			"Coelacanth",
			"Sailfish",
			"Stingray",
			"Sawfish",
			"Moonfish",
			"Dolphin",
			"Flying Fish",
			"Colossal Squid",
			"Oarfish",
			"Crown Bass",
			"Mythic Fish",
			"Heartbreak Herring",
			"Rose Rockfish",
			"Pink Betta",
			"Lovestorm Turtle"
		},
		Priority = 100,
		CantBeWormholed = true,
		IsHunt = true,
		RarityBaseChanceBoosts = {
			Trash = 0.1,
			Common = 0.3,
			Rare = 0.5
		}
	},
	["Supercharged Lovestorm"] = {
		Pool = {
			"Tire",
			"Boot",
			"Common Crate",
			"Seaweed",
			"Carbon Crate",
			"Quality Bait Crate",
			"Common Crate",
			"Bait Crate",
			"Mackerel",
			"Cod",
			"Amberjack",
			"Sardine",
			"Halibut",
			"Salmon",
			"Mullet",
			"Bluefin Tuna",
			"Yellowfin Tuna",
			"Barracuda",
			"Sea Bass",
			"Chinook Salmon",
			"Sea Pickle",
			"Swordfish",
			"Anglerfish",
			"Coelacanth",
			"Sailfish",
			"Stingray",
			"Sawfish",
			"Moonfish",
			"Dolphin",
			"Flying Fish",
			"Colossal Squid",
			"Oarfish",
			"Crown Bass",
			"Mythic Fish",
			"Heartbreak Herring",
			"Rose Rockfish",
			"Pink Betta",
			"Lovestorm Turtle Supercharged"
		},
		Priority = 101,
		CantBeWormholed = true,
		IsHunt = true,
		RarityBaseChanceBoosts = {
			Trash = 0.1,
			Common = 0.3,
			Rare = 0.5
		}
	},
	["Sacred Lovestorm"] = {
		Pool = {
			"Tire",
			"Boot",
			"Common Crate",
			"Seaweed",
			"Carbon Crate",
			"Quality Bait Crate",
			"Common Crate",
			"Bait Crate",
			"Mackerel",
			"Cod",
			"Amberjack",
			"Sardine",
			"Halibut",
			"Salmon",
			"Mullet",
			"Bluefin Tuna",
			"Yellowfin Tuna",
			"Barracuda",
			"Sea Bass",
			"Chinook Salmon",
			"Sea Pickle",
			"Swordfish",
			"Anglerfish",
			"Coelacanth",
			"Sailfish",
			"Stingray",
			"Sawfish",
			"Moonfish",
			"Dolphin",
			"Flying Fish",
			"Colossal Squid",
			"Oarfish",
			"Crown Bass",
			"Mythic Fish",
			"Heartbreak Herring",
			"Rose Rockfish",
			"Pink Betta",
			"Sacred Lovestorm Turtle"
		},
		Priority = 102,
		CantBeWormholed = true,
		IsHunt = true,
		RarityBaseChanceBoosts = {
			Trash = 0.1,
			Common = 0.3,
			Rare = 0.5
		}
	},
	Tidefall = {
		Pool = {
			"Rock",
			"Stalactite",
			"Dripstone",
			"Sixgill Shark",
			"Lanternfish",
			"Giant Grouper",
			"Pelagic Cod",
			"Bumpy Snailfish",
			"Metal Strongbox",
			"Forbidden Plesiosaur"
		},
		AdditionalPossibleRoamers = { "Moray Eel", "Conger Eel", "Gulper Eel" },
		CantBeWormholed = false,
		Priority = 1,
		Disturbs = "TidefallDripstoneCollapse"
	},
	["Tidefall Castle"] = {
		Pool = {
			"Rock",
			"Stalactite",
			"Dripstone",
			"Sixgill Shark",
			"Lanternfish",
			"Giant Grouper",
			"Pelagic Cod",
			"Bumpy Snailfish",
			"Metal Strongbox",
			"Gold Piece",
			"Forbidden Plesiosaur"
		},
		CantBeWormholed = true,
		Priority = 1,
		Disturbs = "Plesiosaur",
		AdditionalPossibleRoamers = { "Moray Eel", "Conger Eel", "Gulper Eel" },
		CustomCondition = function(_, p)
			if p.Data.NewFormat.Tidefall.Obelisks.GateOpen then
				return true
			end

			return false, "You have not yet unlocked this area."
		end
	},
	["Coral Bastion"] = {
		Pool = {
			"Sand Dollar",
			"Stalactite",
			"Seaweed",
			"Batfish",
			"Sand Tiger Shark",
			"Emperor Angelfish",
			"Regal Angelfish",
			"Bigeye Trevally",
			"Atlantic Goliath Grouper"
		},
		AdditionalPossibleRoamers = { "Lizardfish", "Wobbegong Shark" },
		Disturbs = "ReefTitan",
		CantBeWormholed = false,
		Priority = 2
	},
	["Sunken Reliquary"] = {
		Pool = {
			"Rock",
			"Stalactite",
			"Dripstone",
			"Deepwater Stingray",
			"Flying Gurnard",
			"Small-Spotted Catshark",
			"Oilfish",
			"Escolar",
			"Cusk Eel",
			"Porcupinefish",
			"John Dory",
			"Cornetfish"
		},
		Disturbs = "Omnithal",
		CantBeWormholed = false,
		Priority = 2
	},
	["Collapsed Ruins"] = {
		Pool = {
			"Rock",
			"Dripstone",
			"Scrap Metal",
			"Copper Rockfish",
			"Roughhead Grenadier",
			"Longnose Chimaera",
			"Bigeye Houndshark",
			"Atlantic Halosaur",
			"Blackfin Barracuda",
			"Black Scabbardfish"
		},
		AdditionalPossibleRoamers = { "Blackfin Icefish", "Shortnose Chimaera" },
		Disturbs = "Pliosaur",
		CantBeWormholed = false,
		Priority = 2
	},
	["Crowned Ruins"] = {
		Pool = {
			"Scrap Metal",
			"Gnomefish",
			"Blackmouth Catshark",
			"Silver Roughy",
			"Roundnose Grenadier",
			"Armorhead",
			"Blackspot Tuskfish",
			"Spotted Drum",
			"Greater Weever",
			"Black Snoek"
		},
		AdditionalPossibleRoamers = { "Warty Oreo" },
		Disturbs = "Goldwraith",
		CantBeWormholed = false,
		Priority = 3
	},
	["Plesiosaur Hunt"] = {
		Pool = {
			"Rock",
			"Stalactite",
			"Dripstone",
			"Sixgill Shark",
			"Lanternfish",
			"Pelagic Cod",
			"Bumpy Snailfish",
			"Metal Strongbox",
			"Forbidden Plesiosaur"
		},
		Priority = 4,
		CantBeWormholed = true,
		IsHunt = true,
		CustomCondition = function(_, p)
			if p.Data.NewFormat.Tidefall.Obelisks.GateOpen then
				return true
			end

			return false, "You have not yet unlocked this area."
		end
	},
	["Reef Titan Hunt"] = {
		Pool = {
			"Sand Dollar",
			"Stalactite",
			"Seaweed",
			"Batfish",
			"Sand Tiger Shark",
			"Emperor Angelfish",
			"Regal Angelfish",
			"Bigeye Trevally",
			"Atlantic Goliath Grouper"
		},
		Priority = 4,
		CantBeWormholed = true,
		IsHunt = true
	},
	["Omnithal Hunt"] = {
		Pool = {
			"Rock",
			"Stalactite",
			"Dripstone",
			"Deepwater Stingray",
			"Flying Gurnard",
			"Small-Spotted Catshark",
			"Oilfish",
			"Escolar",
			"Cusk Eel",
			"Porcupinefish",
			"John Dory",
			"Cornetfish"
		},
		Priority = 4,
		CantBeWormholed = true,
		IsHunt = true
	},
	["Pliosaur Hunt"] = {
		Pool = {
			"Rock",
			"Dripstone",
			"Scrap Metal",
			"Copper Rockfish",
			"Roughhead Grenadier",
			"Longnose Chimaera",
			"Bigeye Houndshark",
			"Atlantic Halosaur",
			"Blackfin Barracuda",
			"Black Scabbardfish"
		},
		Priority = 4,
		CantBeWormholed = true,
		IsHunt = true
	},
	["Goldwraith Hunt"] = {
		Pool = {
			"Scrap Metal",
			"Gnomefish",
			"Blackmouth Catshark",
			"Silver Roughy",
			"Roundnose Grenadier",
			"Armorhead",
			"Blackspot Tuskfish",
			"Spotted Drum",
			"Greater Weever",
			"Black Snoek"
		},
		Priority = 4,
		CantBeWormholed = true,
		IsHunt = true
	},
	["New Years"] = {
		Pool = {
			"Eonshell",
			"Confetti Carp",
			"Party Pufferfish",
			"Party Popperfish",
			"Sparkler Sardine",
			"Sparkling Corkfin"
		},
		CantBeWormholed = true,
		Priority = 5
	},
	["Glacial Ridge"] = {
		Pool = {
			"Ice",
			"Tire",
			"Carbon Crate",
			"Common Crate",
			"Bait Crate",
			"Fish Barrel",
			"Cod",
			"Sardine",
			"Salmon",
			"Sea Bass",
			"Porgy",
			"Arctic Char",
			"Pollock",
			"Red Drum",
			"Herring",
			"Bluegill",
			"Lingcod",
			"Mullet",
			"Skipjack Tuna",
			"Glacierfish",
			"Moonfish",
			"Colossal Squid",
			"Ringle",
			"Snowball"
		},
		Priority = 104,
		CantBeWormholed = true
	},
	["Northstar Village"] = {
		Pool = {
			"Peppermint Pike",
			"Stockingfish",
			"Wreath Wrasse",
			"Holly Haddock",
			"Tinsel Trout",
			"Candy Cane Cod",
			"Candy Cane",
			"Hot Cocoa",
			"Gingerbread Man",
			"Glass of Eggnog",
			"Snowball",
			"Ornament Pufferfish",
			"Mistletoe Minnow",
			"Carol Carp",
			"Reindeer Ray",
			"Elf Eel",
			"Nutcracker Catfish",
			"Fruitcake Flounder",
			"Bauble Bass",
			"Bellfin",
			"Jolly Bait Crate",
			"Present",
			"Snowy Present",
			"Santa's Present",
			"Merry Manta Ray",
			"Santa Whale Shark",
			"Northstar Whale",
			"Festive Relic"
		},
		Priority = 105,
		CantBeWormholed = true
	},
	["Cryoshock Serpent"] = {
		ExclusiveRods = {
			AllowedRods = {
				"Christmas Tree Rod",
				"Gingerbread Rod",
				"Peppermint Rod",
				"Jinglestar Rod",
				"Santa's Miracle Rod",
				"Maelstrom",
				"Boreal Rod",
				"Cryolash",
				"North Pole",
				"Candy Cane Rod",
				"North-Star Rod",
				"Antler Rod",
				"Krampus's Rod",
				"Frost Warden Rod",
				"Fischmas Rod",
				"Frostfire Rod"
			},
			ErrorMessage = "Your rod lacks the magic of Fischmas..."
		},
		Pool = {
			"Peppermint Pike",
			"Stockingfish",
			"Wreath Wrasse",
			"Holly Haddock",
			"Tinsel Trout",
			"Candy Cane Cod",
			"Candy Cane",
			"Hot Cocoa",
			"Gingerbread Man",
			"Glass of Eggnog",
			"Snowball",
			"Ornament Pufferfish",
			"Mistletoe Minnow",
			"Carol Carp",
			"Reindeer Ray",
			"Elf Eel",
			"Nutcracker Catfish",
			"Fruitcake Flounder",
			"Bauble Bass",
			"Bellfin",
			"Jolly Bait Crate",
			"Present",
			"Snowy Present",
			"Santa's Present",
			"Merry Manta Ray",
			"Santa Whale Shark",
			"Northstar Whale",
			"Festive Relic",
			"Cryoshock Serpent"
		},
		Priority = 106,
		CantBeWormholed = true,
		CustomCondition = function(instance, p, instance2)
			if not instance:GetAttribute("CanCatchCryoshock") or ReplicatedStorage.world.weather.meteorological.Value ~= "Frost Moon" then
				return false, "You have not yet awakened the serpent."
			end

			local stats = instance2:FindFirstChild("Stats")
			local rod = stats and stats:FindFirstChild("rod")

			if not rod then
				return false, "Your rod lacks the magic of Fischmas..."
			end

			local rod2 = p.Data.NewFormat.Rods[rod.Value]

			if not rod2 then
				return false, "Your rod lacks the magic of Fischmas..."
			end

			if rod2.enchant == "Merry" or rod2.enchant == "Gingerbread" or rod2.secondaryEnchant == "Peppermint" then
				return true
			end

			return false, "Your rod lacks the magic of Fischmas..."
		end
	},
	MapleMeadows = {
		Pool = {
			"Cod",
			"Tire",
			"Boot",
			"Common Crate",
			"Bait Crate",
			"Fish Barrel",
			"Seaweed",
			"Boots",
			"Amberjack",
			"Nurse Shark",
			"Porgy",
			"Sardine",
			"Halibut",
			"Mullet",
			"Salmon",
			"Yellowfin Tuna",
			"Sea Bass",
			"Chinook Salmon",
			"Haddock",
			"Barracuda",
			"Sea Pickle",
			"Bountiful Bait Crate",
			"Poseidon Turkey",
			"Coral Turkey",
			"Magma Turkey",
			"Sunny Turkey",
			"Pirate Turkey",
			"Lost Turkey",
			"Slate Turkey",
			"Ghost Turkey",
			"Mossy Turkey",
			"Frosty Turkey",
			"Murky Turkey",
			"Pioneer Turkey"
		},
		CantBeWormholed = true,
		Priority = 2
	},
	HallOfWhispers = {
		Pool = {
			"Rock",
			"Destroyed Fossil",
			"Bone",
			"Stalactite",
			"Typhleotris",
			"Gollum Snakehead",
			"Stoplight Loosejaw",
			"Garra Andruzzii",
			"Blind Swamp Eel",
			"Key of Oaths",
			"Cathulid"
		},
		CantBeWormholed = true,
		Priority = 2,
		CustomCondition = function(_, p)
			if p.Data.NewFormat.TerrapinExpansion.HasUnlockedInitialHiddenArea then
				return true
			end

			return false, "The fish ignore you completely... Maybe it's best to get here <b>normally</b>."
		end
	},
	PassageOfOaths = {
		Pool = {
			"Rock",
			"Destroyed Fossil",
			"Bone",
			"Stalactite",
			"Sloane's Viperfish",
			"Spiny Hatchetfish",
			"Swampfish",
			"Garra Typhlops",
			"Abyssal Grenadier",
			"Cathulith"
		},
		CantBeWormholed = true,
		Priority = 2,
		CustomCondition = function(_, p)
			for _, passageRequirement in p.Data.NewFormat.TerrapinExpansion.HallOfWhispers.PassageRequirements do
				if not passageRequirement then
					return false, "The fish ignore you completely... Maybe it's best to get here <b>normally</b>."
				end
			end

			return true
		end
	},
	MossjawHunt = {
		Pool = {
			"Bronze Corydoras",
			"Neon Tetra",
			"Cardinal Tetra",
			"Redeye Piranha",
			"Black Ghost Knifefish",
			"Electric Eel",
			"Pirarucu"
		},
		CantBeWormholed = true,
		Priority = 4,
		IsHunt = true,
		CustomCondition = function(_, p)
			local count = 0

			for _, v in p.Data.NewFormat.LostJungle.Runes.Placed do
				if v then
					count += 1
				end
			end

			if count < 5 then
				return false, "You must place all 5 runes before fishing here."
			end

			return true
		end
	},
	["Frostwyrm Hunt"] = {
		Pool = {
			"Ice",
			"Bone",
			"Stalactite",
			"Antarctic Icefish",
			"Saffron Cod",
			"Greenland Halibut",
			"Glacial Squid"
		},
		Priority = 4,
		CantBeWormholed = true,
		IsHunt = true,
		CustomCondition = function(_, _)
			return true
		end
	},
	["Boreal Pines"] = {
		Pool = {
			"Ice",
			"Antarctic Icefish",
			"Saffron Cod",
			"Greenland Halibut"
		},
		CantBeWormholed = false,
		Priority = 1
	},
	["Boreal Pines - Ice Fishing"] = {
		Pool = {
			"Ice",
			"Antarctic Icefish",
			"Saffron Cod",
			"Greenland Halibut",
			"Eelpout",
			"Fourhorn Sculpin"
		},
		CantBeWormholed = false,
		Priority = 2
	},
	["Boreal Pines - Cave"] = {
		Pool = {
			"Ice",
			"Bone",
			"Stalactite",
			"Antarctic Icefish",
			"Saffron Cod",
			"Greenland Halibut",
			"Glacial Squid"
		},
		Disturbs = "FrostwyrmHunt",
		CantBeWormholed = false,
		Priority = 2
	},
	["Boreal Pines - Peak"] = {
		Pool = {
			"Ice",
			"Antarctic Icefish",
			"Polar Cod",
			"Saffron Cod",
			"Greenland Halibut",
			"Lake Whitefish"
		},
		CantBeWormholed = false,
		Priority = 2
	},
	["Luminescent Cavern"] = {
		Pool = {
			"Rock",
			"Stalactite",
			"Hawaiian Bobtail Squid",
			"Blue Ribbon Eel",
			"Bluelip Batfish",
			"Kitefin Shark",
			"Atolla Jellyfish"
		},
		CantBeWormholed = false,
		Priority = 2,
		Disturbs = { "ColossalEtherealDragon", "ColossalBlueDragon" }
	},
	["Lost Jungle"] = {
		Pool = {
			"Driftwood",
			"Neon Tetra",
			"Cardinal Tetra",
			"Bronze Corydoras",
			"Freshwater Pacu",
			"Redeye Piranha",
			"Black Ghost Knifefish",
			"Payara",
			"Electric Eel",
			"Pirarucu",
			"Goliath Tigerfish",
			"Paradox Piranha"
		},
		AdditionalPossibleRoamers = {
			"Silver Arowana",
			"Oscar Cichlid",
			"Northern Snakehead",
			"Piraiba",
			"Motoro Stingray"
		},
		CantBeWormholed = false,
		Priority = 2
	},
	["Mossjaw Rest"] = {
		Pool = {
			"Driftwood",
			"Rock",
			"Stalactite",
			"Redeye Piranha",
			"Black Ghost Knifefish",
			"Payara",
			"Electric Eel",
			"Pirarucu",
			"Goliath Tigerfish",
			"Paradox Piranha"
		},
		Disturbs = "MossjawHunt",
		CantBeWormholed = false,
		Priority = 3
	},
	["Crimson Cavern"] = {
		Pool = {
			"Rock",
			"Stalactite",
			"Sea Raven",
			"Red Fangtooth",
			"Viperfish",
			"Japanese Dragon Eel",
			"Vampire Squid"
		},
		CantBeWormholed = false,
		Priority = 2,
		Disturbs = { "ColossalAncientDragon", "ColossalEtherealDragon" },
		CustomCondition = function(_, p)
			if p.Data.NewFormat.LuminescentCavern.KeystoneData.CrimsonCavernUnlocked then
				return true
			end

			return false, "You must unlock the Crimson Cavern before fishing here."
		end
	},
	["Cultist Lair"] = {
		Pool = {
			"Rock",
			"Destroyed Fossil",
			"Bone",
			"Stalactite",
			"Mexican Tetra",
			"Abyssal Slickhead",
			"Cave Loach",
			"Scaly Dragonfish",
			"Sinocyclocheilus",
			"Key of Whispers"
		},
		CantBeWormholed = false,
		Priority = 2,
		CustomCondition = function(_, p)
			if p.Data.NewFormat.TerrapinExpansion.HasUnlockedInitialHiddenArea then
				return true
			end

			return false, "The fish ignore you completely... Maybe it's best to get here <b>normally</b>."
		end
	},
	["Hall of Whispers"] = {
		Pool = {
			"Rock",
			"Destroyed Fossil",
			"Bone",
			"Stalactite",
			"Typhleotris",
			"Gollum Snakehead",
			"Stoplight Loosejaw",
			"Garra Andruzzii",
			"Blind Swamp Eel",
			"Key of Oaths"
		},
		CantBeWormholed = false,
		Priority = 2,
		CustomCondition = function(_, p)
			if p.Data.NewFormat.TerrapinExpansion.HasUnlockedInitialHiddenArea then
				return true
			end

			return false, "The fish ignore you completely... Maybe it's best to get here <b>normally</b>."
		end
	},
	["Passage of Oaths"] = {
		Pool = {
			"Rock",
			"Destroyed Fossil",
			"Bone",
			"Stalactite",
			"Sloane's Viperfish",
			"Spiny Hatchetfish",
			"Swampfish",
			"Garra Typhlops",
			"Abyssal Grenadier"
		},
		CantBeWormholed = false,
		Priority = 2,
		CustomCondition = function(_, p)
			for _, passageRequirement in p.Data.NewFormat.TerrapinExpansion.HallOfWhispers.PassageRequirements do
				if not passageRequirement then
					return false, "The fish ignore you completely... Maybe it's best to get here <b>normally</b>."
				end
			end

			return true
		end
	},
	["The Sanctum"] = {
		Pool = {
			"Rock",
			"Cave Angel Fish",
			"Ozark Cavefish",
			"Cave Loach",
			"Stoplight Loosejaw",
			"Scaly Dragonfish",
			"Spiny Hatchetfish",
			"Swampfish"
		},
		CantBeWormholed = false,
		Priority = 2,
		Disturbs = "The Sanctum Hunt",
		CustomCondition = function(_, p)
			if p.Data.NewFormat.TerrapinExpansion.UnlockedSanctum then
				return true
			end

			return false, "The fish ignore you completely... Maybe it's best to get here <b>normally</b>."
		end
	},
	["The Sanctum Hunt"] = {
		Pool = {
			"Cave Angel Fish",
			"Ozark Cavefish",
			"Cave Loach",
			"Stoplight Loosejaw",
			"Scaly Dragonfish",
			"Spiny Hatchetfish",
			"Swampfish",
			"Leviathan"
		},
		CantBeWormholed = true,
		Priority = 3,
		IsHunt = true,
		CustomCondition = function(_, p)
			if p.Data.NewFormat.TerrapinExpansion.UnlockedSanctum then
				return true
			end

			return false, "The fish ignore you completely... Maybe it's best to get here <b>normally</b>."
		end
	},
	["The Sanctum Profane Hunt"] = {
		Pool = {
			"Cave Angel Fish",
			"Ozark Cavefish",
			"Cave Loach",
			"Stoplight Loosejaw",
			"Scaly Dragonfish",
			"Spiny Hatchetfish",
			"Swampfish",
			"Profane Leviathan"
		},
		CantBeWormholed = true,
		Priority = 3,
		IsHunt = true,
		CustomCondition = function(_, p)
			if p.Data.NewFormat.TerrapinExpansion.UnlockedSanctum then
				return true
			end

			return false, "The fish ignore you completely... Maybe it's best to get here <b>normally</b>."
		end
	},
	["The Sanctum Shamrock Hunt"] = {
		Pool = {
			"Cave Angel Fish",
			"Ozark Cavefish",
			"Cave Loach",
			"Stoplight Loosejaw",
			"Scaly Dragonfish",
			"Spiny Hatchetfish",
			"Swampfish",
			"Shamrock Leviathan"
		},
		CantBeWormholed = true,
		Priority = 3,
		IsHunt = true,
		CustomCondition = function(_, p)
			if p.Data.NewFormat.TerrapinExpansion.UnlockedSanctum then
				return true
			end

			return false, "The fish ignore you completely... Maybe it's best to get here <b>normally</b>."
		end
	},
	["Carrot Garden"] = {
		Pool = {
			"Carrot Turtle",
			"Carrot Pufferfish",
			"Carrot Minnow",
			"Carrot Eel",
			"Carrot Salmon",
			"Carrot Goldfish",
			"Carrot Snapper",
			"Carrot Shark"
		},
		Priority = 102,
		CantBeWormholed = false,
		MutationIndicatorEnabled = true
	},
	["Gilded Arch"] = {
		Pool = {
			"Squirrelfish",
			"French Grunt",
			"Sergeant Major",
			"Coney Grouper",
			"Doctorfish Tang",
			"Bluehead Wrasse",
			"Islandhopper Butterflyfish",
			"Stoplight Parrotfish",
			"Scrawled Filefish",
			"Spadefish",
			"Ocean Triggerfish",
			"Rock Hind",
			"Rainbow Grouper",
			"Spotted Moray Eel",
			"Great Barracuda",
			"Tilefish",
			"Black Grouper"
		},
		CantBeWormholed = true,
		Priority = 2
	},
	["Castaway Cliffs"] = {
		Pool = {
			"Clowned Triggerfish",
			"Flamekissed Hawkfish",
			"Mandarinfish",
			"Cobalt Angelfish",
			"Trevally",
			"Warty Frogfish",
			"Hidden Pipefish",
			"Mirage Toadfish",
			"Scalloped Hammerhead",
			"Great Goldcursed Shark",
			"Razorfin"
		},
		CantBeWormholed = false,
		Priority = 2
	},
	["Magician Narwhal - Sea 2"] = {
		Pool = {
			"Cursed Thread",
			"Hogchoker",
			"Rock Gunnel",
			"Pupfish",
			"Four Eyes Fish",
			"Black Swallower",
			"Warty Angler",
			"Tropical Bait Crate",
			"Lumpclinger",
			"Snipefish",
			"Boarfish",
			"Telescopefish",
			"Fangtooth",
			"Velvet Belly Lanternshark",
			"Snakehead",
			"Sarcastic Fringehead",
			"Knifefish",
			"Tripod Fish",
			"Pelican Eel",
			"Bigfin Squid",
			"X-ray Tetra",
			"Psychedelic Frogfish",
			"Dogefin",
			"Toilet Fish",
			"Magician Narwhal"
		},
		CantBeWormholed = true,
		Priority = 5
	},
	["Magician Narwhal - Sea 1"] = {
		Pool = {
			"Tire",
			"Boot",
			"Common Crate",
			"Bait Crate",
			"Fish Barrel",
			"Seaweed",
			"Boots",
			"Mackerel",
			"Cod",
			"Amberjack",
			"Nurse Shark",
			"Porgy",
			"Sardine",
			"Halibut",
			"Mullet",
			"Salmon",
			"Yellowfin Tuna",
			"Sea Bass",
			"Chinook Salmon",
			"Haddock",
			"Barracuda",
			"Sea Pickle",
			"Pufferfish",
			"Swordfish",
			"Bluefin Tuna",
			"Sailfish",
			"Stingray",
			"Sawfish",
			"Moonfish",
			"Crown Bass",
			"Dolphin",
			"Flying Fish",
			"Mythic Fish",
			"Long Pike",
			"Mustard",
			"Magician Narwhal"
		},
		CantBeWormholed = true,
		Priority = 5
	},
	["Beluga - Sea 2"] = {
		Pool = {
			"Cursed Thread",
			"Hogchoker",
			"Rock Gunnel",
			"Pupfish",
			"Four Eyes Fish",
			"Black Swallower",
			"Warty Angler",
			"Tropical Bait Crate",
			"Lumpclinger",
			"Snipefish",
			"Boarfish",
			"Telescopefish",
			"Fangtooth",
			"Velvet Belly Lanternshark",
			"Snakehead",
			"Sarcastic Fringehead",
			"Knifefish",
			"Tripod Fish",
			"Pelican Eel",
			"Bigfin Squid",
			"X-ray Tetra",
			"Psychedelic Frogfish",
			"Dogefin",
			"Toilet Fish",
			"Beluga"
		},
		CantBeWormholed = true,
		Priority = 5
	},
	["Beluga - Sea 1"] = {
		Pool = {
			"Tire",
			"Boot",
			"Common Crate",
			"Bait Crate",
			"Fish Barrel",
			"Seaweed",
			"Boots",
			"Mackerel",
			"Cod",
			"Amberjack",
			"Nurse Shark",
			"Porgy",
			"Sardine",
			"Halibut",
			"Mullet",
			"Salmon",
			"Yellowfin Tuna",
			"Sea Bass",
			"Chinook Salmon",
			"Haddock",
			"Barracuda",
			"Sea Pickle",
			"Pufferfish",
			"Swordfish",
			"Bluefin Tuna",
			"Sailfish",
			"Stingray",
			"Sawfish",
			"Moonfish",
			"Crown Bass",
			"Dolphin",
			"Flying Fish",
			"Mythic Fish",
			"Long Pike",
			"Mustard",
			"Beluga"
		},
		CantBeWormholed = true,
		Priority = 5
	},
	["Narwhal - Sea 2"] = {
		Pool = {
			"Cursed Thread",
			"Hogchoker",
			"Rock Gunnel",
			"Pupfish",
			"Four Eyes Fish",
			"Black Swallower",
			"Warty Angler",
			"Tropical Bait Crate",
			"Lumpclinger",
			"Snipefish",
			"Boarfish",
			"Telescopefish",
			"Fangtooth",
			"Velvet Belly Lanternshark",
			"Snakehead",
			"Sarcastic Fringehead",
			"Knifefish",
			"Tripod Fish",
			"Pelican Eel",
			"Bigfin Squid",
			"X-ray Tetra",
			"Psychedelic Frogfish",
			"Dogefin",
			"Toilet Fish",
			"Narwhal"
		},
		CantBeWormholed = true,
		Priority = 5
	},
	["Narwhal - Sea 1"] = {
		Pool = {
			"Tire",
			"Boot",
			"Common Crate",
			"Bait Crate",
			"Fish Barrel",
			"Seaweed",
			"Boots",
			"Mackerel",
			"Cod",
			"Amberjack",
			"Nurse Shark",
			"Porgy",
			"Sardine",
			"Halibut",
			"Mullet",
			"Salmon",
			"Yellowfin Tuna",
			"Sea Bass",
			"Chinook Salmon",
			"Haddock",
			"Barracuda",
			"Sea Pickle",
			"Pufferfish",
			"Swordfish",
			"Bluefin Tuna",
			"Sailfish",
			"Stingray",
			"Sawfish",
			"Moonfish",
			"Crown Bass",
			"Dolphin",
			"Flying Fish",
			"Mythic Fish",
			"Long Pike",
			"Mustard",
			"Narwhal"
		},
		CantBeWormholed = true,
		Priority = 5
	},
	["Apex Leviathan"] = {
		Pool = {
			"Cursed Thread",
			"Hogchoker",
			"Rock Gunnel",
			"Pupfish",
			"Four Eyes Fish",
			"Black Swallower",
			"Warty Angler",
			"Tropical Bait Crate",
			"Lumpclinger",
			"Snipefish",
			"Boarfish",
			"Telescopefish",
			"Fangtooth",
			"Velvet Belly Lanternshark",
			"Snakehead",
			"Sarcastic Fringehead",
			"Knifefish",
			"Tripod Fish",
			"Pelican Eel",
			"Bigfin Squid",
			"X-ray Tetra",
			"Psychedelic Frogfish",
			"Dogefin",
			"Toilet Fish",
			"Apex Leviathan"
		},
		CantBeWormholed = true,
		Priority = 5
	},
	Mosslurker = {
		Pool = {
			"Tire",
			"Boot",
			"Common Crate",
			"Bait Crate",
			"Fish Barrel",
			"Seaweed",
			"Boots",
			"Mackerel",
			"Cod",
			"Amberjack",
			"Nurse Shark",
			"Porgy",
			"Sardine",
			"Halibut",
			"Mullet",
			"Salmon",
			"Yellowfin Tuna",
			"Sea Bass",
			"Chinook Salmon",
			"Haddock",
			"Barracuda",
			"Sea Pickle",
			"Pufferfish",
			"Swordfish",
			"Bluefin Tuna",
			"Sailfish",
			"Stingray",
			"Sawfish",
			"Moonfish",
			"Crown Bass",
			"Dolphin",
			"Flying Fish",
			"Mythic Fish",
			"Long Pike",
			"Mustard",
			"Mosslurker"
		},
		CantBeWormholed = true,
		Priority = 5
	},
	["Bloop Fish"] = {
		Pool = {
			"Tire",
			"Boot",
			"Common Crate",
			"Bait Crate",
			"Fish Barrel",
			"Seaweed",
			"Boots",
			"Mackerel",
			"Cod",
			"Amberjack",
			"Nurse Shark",
			"Porgy",
			"Sardine",
			"Halibut",
			"Mullet",
			"Salmon",
			"Yellowfin Tuna",
			"Sea Bass",
			"Chinook Salmon",
			"Haddock",
			"Barracuda",
			"Sea Pickle",
			"Pufferfish",
			"Swordfish",
			"Bluefin Tuna",
			"Sailfish",
			"Stingray",
			"Sawfish",
			"Moonfish",
			"Crown Bass",
			"Dolphin",
			"Flying Fish",
			"Mythic Fish",
			"Long Pike",
			"Mustard",
			"Device Display",
			"Bloop Fish"
		},
		CantBeWormholed = true,
		Priority = 5,
		IsHunt = true,
		CustomCondition = function(player)
			if player.Character and (player.Character:HasTag("BloopContributor") or workspace:GetAttribute("BloopFromSnapshot")) then
				return true
			end

			return false, "The Bloop Fish shows little interest in you..."
		end
	},
	["Baby Bloop Fish"] = {
		Pool = {
			"Tire",
			"Boot",
			"Common Crate",
			"Bait Crate",
			"Fish Barrel",
			"Seaweed",
			"Boots",
			"Mackerel",
			"Cod",
			"Amberjack",
			"Nurse Shark",
			"Porgy",
			"Sardine",
			"Halibut",
			"Mullet",
			"Salmon",
			"Yellowfin Tuna",
			"Sea Bass",
			"Chinook Salmon",
			"Haddock",
			"Barracuda",
			"Sea Pickle",
			"Pufferfish",
			"Swordfish",
			"Bluefin Tuna",
			"Sailfish",
			"Stingray",
			"Sawfish",
			"Moonfish",
			"Crown Bass",
			"Dolphin",
			"Flying Fish",
			"Mythic Fish",
			"Long Pike",
			"Mustard",
			"Device Display",
			"Baby Bloop Fish"
		},
		CantBeWormholed = true,
		Priority = 4,
		IsHunt = true
	},
	["Shamrock Bloop Fish"] = {
		Pool = {
			"Tire",
			"Boot",
			"Common Crate",
			"Bait Crate",
			"Fish Barrel",
			"Seaweed",
			"Boots",
			"Mackerel",
			"Cod",
			"Amberjack",
			"Nurse Shark",
			"Porgy",
			"Sardine",
			"Halibut",
			"Mullet",
			"Salmon",
			"Yellowfin Tuna",
			"Sea Bass",
			"Chinook Salmon",
			"Haddock",
			"Barracuda",
			"Sea Pickle",
			"Pufferfish",
			"Swordfish",
			"Bluefin Tuna",
			"Sailfish",
			"Stingray",
			"Sawfish",
			"Moonfish",
			"Crown Bass",
			"Dolphin",
			"Flying Fish",
			"Mythic Fish",
			"Long Pike",
			"Mustard",
			"Device Display",
			"Shamrock Bloop Fish"
		},
		CantBeWormholed = true,
		Priority = 50,
		IsHunt = true
	},
	["Colossal Ethereal Dragon"] = {
		Pool = {
			"Rock",
			"Stalactite",
			"Hawaiian Bobtail Squid",
			"Blue Ribbon Eel",
			"Bluelip Batfish",
			"Kitefin Shark",
			"Atolla Jellyfish"
		},
		CantBeWormholed = true,
		Priority = 3,
		IsHunt = true
	},
	["Colossal Blue Dragon"] = {
		Pool = {
			"Rock",
			"Stalactite",
			"Hawaiian Bobtail Squid",
			"Blue Ribbon Eel",
			"Bluelip Batfish",
			"Kitefin Shark",
			"Atolla Jellyfish"
		},
		CantBeWormholed = true,
		Priority = 3,
		IsHunt = true
	},
	["Colossal Ancient Dragon"] = {
		Pool = {
			"Rock",
			"Stalactite",
			"Sea Raven",
			"Red Fangtooth",
			"Viperfish",
			"Japanese Dragon Eel",
			"Vampire Squid"
		},
		CantBeWormholed = true,
		Priority = 3,
		IsHunt = true,
		CustomCondition = function(_, p)
			if p.Data.NewFormat.LuminescentCavern.KeystoneData.CrimsonCavernUnlocked then
				return true
			end

			return false, "You must unlock the Crimson Cavern before fishing here."
		end
	},
	["Animal Pool"] = {
		Pool = {
			"Cluckfin",
			"Zebrafishlet",
			"Piglet Pike",
			"Squirrelray",
			"Duckfin Tuna",
			"Porcufish",
			"Piranhamunk",
			"Salmoose",
			"Mained Lionfish",
			"Seacow"
		},
		Priority = 102,
		CantBeWormholed = true
	},
	["Animal Pool - Second Sea"] = {
		Pool = {
			"Minnowse",
			"Kittyfish",
			"Parrotfish",
			"Pengwhal",
			"Racuda",
			"Crocokoi",
			"Krabbit",
			"Siren Sheep",
			"Capybass"
		},
		Priority = 102,
		CantBeWormholed = true
	},
	["Octophant Pool Without Elephant"] = {
		Pool = {
			"Shrimpanzee",
			"Royal Tigerfish",
			"Slurpfloth",
			"Flamangler",
			"Orcanda"
		},
		Priority = 4,
		CantBeWormholed = true
	},
	["Octophant Pool With Elephant"] = {
		Pool = {
			"Shrimpanzee",
			"Royal Tigerfish",
			"Slurpfloth",
			"Flamangler",
			"Orcanda",
			"Octophant"
		},
		Priority = 4,
		CantBeWormholed = true
	},
	["Sea Leviathan Pool"] = {
		Pool = {
			"Sea Leviathan",
			"Hogchoker",
			"Rock Gunnel",
			"Pupfish",
			"Four Eyes Fish",
			"Black Swallower",
			"Warty Angler",
			"Tropical Bait Crate",
			"Lumpclinger",
			"Snipefish",
			"Boarfish",
			"Telescopefish",
			"Fangtooth",
			"Velvet Belly Lanternshark",
			"Snakehead",
			"Sarcastic Fringehead",
			"Knifefish",
			"Tripod Fish",
			"Pelican Eel",
			"Bigfin Squid",
			"X-ray Tetra",
			"Psychedelic Frogfish",
			"Dogefin",
			"Toilet Fish"
		},
		Priority = 4,
		CantBeWormholed = true
	},
	["Smurf Pool"] = {
		ExclusiveRods = {
			AllowedRods = { "Smurf Rod" },
			ErrorMessage = "<font color=\"rgb(255,0,0)\">You must use the Smurf Rod in this pool!</font>"
		},
		Pool = {
			"Tire",
			"Boot",
			"Common Crate",
			"Bait Crate",
			"Fish Barrel",
			"Seaweed",
			"Boots",
			"Mackerel",
			"Cod",
			"Amberjack",
			"Nurse Shark",
			"Porgy",
			"Sardine",
			"Halibut",
			"Mullet",
			"Salmon",
			"Yellowfin Tuna",
			"Sea Bass",
			"Chinook Salmon",
			"Haddock",
			"Barracuda",
			"Sea Pickle",
			"Pufferfish",
			"Swordfish",
			"Bluefin Tuna",
			"Sailfish",
			"Stingray",
			"Sawfish",
			"Moonfish",
			"Crown Bass",
			"Dolphin",
			"Flying Fish",
			"Mythic Fish",
			"Long Pike",
			"Mustard",
			"Ken",
			"No Name",
			"Moxie",
			"Hefty",
			"Clumsy Smurf",
			"Brainy Smurf",
			"Mama Poot",
			"Vanity",
			"Grouchy Smurf"
		},
		CantBeWormholed = true
	},
	["Smurf Storm Pool"] = {
		ExclusiveRods = {
			AllowedRods = { "Smurf Rod" },
			ErrorMessage = "<font color=\"rgb(255,0,0)\">You must use the Smurf Rod in this pool!</font>"
		},
		Pool = {
			"Tire",
			"Boot",
			"Common Crate",
			"Bait Crate",
			"Fish Barrel",
			"Seaweed",
			"Boots",
			"Mackerel",
			"Pufferfish",
			"Swordfish",
			"Sawfish",
			"Moonfish",
			"Mythic Fish",
			"Long Pike",
			"Mustard",
			"Ken",
			"No Name",
			"Moxie",
			"Hefty",
			"Clumsy Smurf",
			"Brainy Smurf",
			"Mama Poot",
			"Vanity",
			"Papa Smurf",
			"Grouchy Smurf"
		},
		CantBeWormholed = true
	},
	["Sunny O'Coin"] = {
		Pool = {
			"Tire",
			"Boot",
			"Common Crate",
			"Bait Crate",
			"Fish Barrel",
			"Seaweed",
			"Boots",
			"Mackerel",
			"Cod",
			"Amberjack",
			"Nurse Shark",
			"Porgy",
			"Sardine",
			"Halibut",
			"Mullet",
			"Salmon",
			"Yellowfin Tuna",
			"Sea Bass",
			"Chinook Salmon",
			"Haddock",
			"Barracuda",
			"Sea Pickle",
			"Pufferfish",
			"Swordfish",
			"Bluefin Tuna",
			"Sailfish",
			"Stingray",
			"Sawfish",
			"Moonfish",
			"Crown Bass",
			"Dolphin",
			"Flying Fish",
			"Mythic Fish",
			"Long Pike",
			"Mustard",
			"Sunny O'Coin"
		},
		CantBeWormholed = true,
		Priority = 5
	},
	["Rowdy McCharm"] = {
		Pool = {
			"Tire",
			"Boot",
			"Common Crate",
			"Bait Crate",
			"Fish Barrel",
			"Seaweed",
			"Boots",
			"Mackerel",
			"Cod",
			"Amberjack",
			"Nurse Shark",
			"Porgy",
			"Sardine",
			"Halibut",
			"Mullet",
			"Salmon",
			"Yellowfin Tuna",
			"Sea Bass",
			"Chinook Salmon",
			"Haddock",
			"Barracuda",
			"Sea Pickle",
			"Pufferfish",
			"Swordfish",
			"Bluefin Tuna",
			"Sailfish",
			"Stingray",
			"Sawfish",
			"Moonfish",
			"Crown Bass",
			"Dolphin",
			"Flying Fish",
			"Mythic Fish",
			"Long Pike",
			"Mustard",
			"Rowdy McCharm"
		},
		CantBeWormholed = true,
		Priority = 5
	},
	["Plumrick O'Luck"] = {
		Pool = {
			"Tire",
			"Boot",
			"Common Crate",
			"Bait Crate",
			"Fish Barrel",
			"Seaweed",
			"Boots",
			"Mackerel",
			"Cod",
			"Amberjack",
			"Nurse Shark",
			"Porgy",
			"Sardine",
			"Halibut",
			"Mullet",
			"Salmon",
			"Yellowfin Tuna",
			"Sea Bass",
			"Chinook Salmon",
			"Haddock",
			"Barracuda",
			"Sea Pickle",
			"Pufferfish",
			"Swordfish",
			"Bluefin Tuna",
			"Sailfish",
			"Stingray",
			"Sawfish",
			"Moonfish",
			"Crown Bass",
			"Dolphin",
			"Flying Fish",
			"Mythic Fish",
			"Long Pike",
			"Mustard",
			"Plumrick O'Luck"
		},
		CantBeWormholed = true,
		Priority = 5
	},
	["O'Mango Goldgrin"] = {
		Pool = {
			"Tire",
			"Boot",
			"Common Crate",
			"Bait Crate",
			"Fish Barrel",
			"Seaweed",
			"Boots",
			"Mackerel",
			"Cod",
			"Amberjack",
			"Nurse Shark",
			"Porgy",
			"Sardine",
			"Halibut",
			"Mullet",
			"Salmon",
			"Yellowfin Tuna",
			"Sea Bass",
			"Chinook Salmon",
			"Haddock",
			"Barracuda",
			"Sea Pickle",
			"Pufferfish",
			"Swordfish",
			"Bluefin Tuna",
			"Sailfish",
			"Stingray",
			"Sawfish",
			"Moonfish",
			"Crown Bass",
			"Dolphin",
			"Flying Fish",
			"Mythic Fish",
			"Long Pike",
			"Mustard",
			"O'Mango Goldgrin"
		},
		CantBeWormholed = true,
		Priority = 5
	},
	["Clover McRich"] = {
		Pool = {
			"Tire",
			"Boot",
			"Common Crate",
			"Bait Crate",
			"Fish Barrel",
			"Seaweed",
			"Boots",
			"Mackerel",
			"Cod",
			"Amberjack",
			"Nurse Shark",
			"Porgy",
			"Sardine",
			"Halibut",
			"Mullet",
			"Salmon",
			"Yellowfin Tuna",
			"Sea Bass",
			"Chinook Salmon",
			"Haddock",
			"Barracuda",
			"Sea Pickle",
			"Pufferfish",
			"Swordfish",
			"Bluefin Tuna",
			"Sailfish",
			"Stingray",
			"Sawfish",
			"Moonfish",
			"Crown Bass",
			"Dolphin",
			"Flying Fish",
			"Mythic Fish",
			"Long Pike",
			"Mustard",
			"Clover McRich"
		},
		CantBeWormholed = true,
		Priority = 5
	},
	["Blarney McBreeze"] = {
		Pool = {
			"Tire",
			"Boot",
			"Common Crate",
			"Bait Crate",
			"Fish Barrel",
			"Seaweed",
			"Boots",
			"Mackerel",
			"Cod",
			"Amberjack",
			"Nurse Shark",
			"Porgy",
			"Sardine",
			"Halibut",
			"Mullet",
			"Salmon",
			"Yellowfin Tuna",
			"Sea Bass",
			"Chinook Salmon",
			"Haddock",
			"Barracuda",
			"Sea Pickle",
			"Pufferfish",
			"Swordfish",
			"Bluefin Tuna",
			"Sailfish",
			"Stingray",
			"Sawfish",
			"Moonfish",
			"Crown Bass",
			"Dolphin",
			"Flying Fish",
			"Mythic Fish",
			"Long Pike",
			"Mustard",
			"Blarney McBreeze"
		},
		CantBeWormholed = true,
		Priority = 5
	},
	["Ashfall Pool"] = {
		Pool = {
			"Ember Catfish",
			"Blistered Eel",
			"Lava Lamprey",
			"Molten Minnow",
			"Pyro Pike",
			"Cinder Carp",
			"Coelacanth",
			"Scooty Salmon",
			"Burnt Betta",
			"Ashcloud Archerfish"
		},
		CantBeWormholed = true,
		Priority = 1
	},
	["Cults Curse Pool"] = {
		Pool = {
			"The Whispering One",
			"Profane Ray",
			"Veilborn Parasite",
			"Bloodscript Eel",
			"Abyssal Maw",
			"Eldritch Spineback",
			"Hollow Gazer",
			"Wretched Guppy"
		},
		CantBeWormholed = true,
		Priority = 1
	},
	["Ancient Orcas Pool"] = {
		Pool = {
			"Ancient Orca",
			"Tire",
			"Boot",
			"Common Crate",
			"Seaweed",
			"Carbon Crate",
			"Quality Bait Crate",
			"Common Crate",
			"Bait Crate",
			"Mackerel",
			"Cod",
			"Amberjack",
			"Sardine",
			"Halibut",
			"Salmon",
			"Mullet",
			"Bluefin Tuna",
			"Yellowfin Tuna",
			"Barracuda",
			"Sea Bass",
			"Chinook Salmon",
			"Sea Pickle",
			"Swordfish",
			"Anglerfish",
			"Coelacanth",
			"Sailfish",
			"Stingray",
			"Sawfish",
			"Moonfish",
			"Dolphin",
			"Flying Fish",
			"Colossal Squid",
			"Oarfish",
			"Crown Bass",
			"Mythic Fish",
			"Long Pike",
			"Mustard"
		},
		CantBeWormholed = true,
		Priority = 4
	},
	["Orcas Pool"] = {
		Pool = {
			"Orca",
			"Tire",
			"Boot",
			"Common Crate",
			"Seaweed",
			"Carbon Crate",
			"Quality Bait Crate",
			"Common Crate",
			"Bait Crate",
			"Mackerel",
			"Cod",
			"Amberjack",
			"Sardine",
			"Halibut",
			"Salmon",
			"Mullet",
			"Bluefin Tuna",
			"Yellowfin Tuna",
			"Barracuda",
			"Sea Bass",
			"Chinook Salmon",
			"Sea Pickle",
			"Swordfish",
			"Anglerfish",
			"Coelacanth",
			"Sailfish",
			"Stingray",
			"Sawfish",
			"Moonfish",
			"Dolphin",
			"Flying Fish",
			"Colossal Squid",
			"Oarfish",
			"Crown Bass",
			"Mythic Fish",
			"Long Pike",
			"Mustard"
		},
		CantBeWormholed = true,
		Priority = 4
	},
	["Whales Pool"] = {
		Pool = {
			"Tire",
			"Boot",
			"Common Crate",
			"Seaweed",
			"Carbon Crate",
			"Quality Bait Crate",
			"Common Crate",
			"Bait Crate",
			"Mackerel",
			"Cod",
			"Amberjack",
			"Sardine",
			"Halibut",
			"Salmon",
			"Mullet",
			"Bluefin Tuna",
			"Yellowfin Tuna",
			"Barracuda",
			"Sea Bass",
			"Chinook Salmon",
			"Sea Pickle",
			"Swordfish",
			"Anglerfish",
			"Coelacanth",
			"Sailfish",
			"Stingray",
			"Sawfish",
			"Moonfish",
			"Dolphin",
			"Flying Fish",
			"Colossal Squid",
			"Oarfish",
			"Crown Bass",
			"Mythic Fish",
			"Long Pike",
			"Mustard"
		},
		Priority = 40,
		CantBeWormholed = true,
		IsHunt = true
	},
	["Humpback Whale Pool"] = {
		Pool = {
			"Humpback Whale",
			"Tire",
			"Boot",
			"Common Crate",
			"Seaweed",
			"Carbon Crate",
			"Quality Bait Crate",
			"Common Crate",
			"Bait Crate",
			"Mackerel",
			"Cod",
			"Amberjack",
			"Sardine",
			"Halibut",
			"Salmon",
			"Mullet",
			"Bluefin Tuna",
			"Yellowfin Tuna",
			"Barracuda",
			"Sea Bass",
			"Chinook Salmon",
			"Sea Pickle",
			"Swordfish",
			"Anglerfish",
			"Coelacanth",
			"Sailfish",
			"Stingray",
			"Sawfish",
			"Moonfish",
			"Dolphin",
			"Flying Fish",
			"Colossal Squid",
			"Oarfish",
			"Crown Bass",
			"Mythic Fish",
			"Long Pike",
			"Mustard"
		},
		Priority = 100,
		CantBeWormholed = true,
		IsHunt = true
	},
	["Fin Whale Pool"] = {
		Pool = {
			"Tire",
			"Boot",
			"Common Crate",
			"Seaweed",
			"Carbon Crate",
			"Quality Bait Crate",
			"Common Crate",
			"Bait Crate",
			"Mackerel",
			"Cod",
			"Amberjack",
			"Sardine",
			"Halibut",
			"Salmon",
			"Mullet",
			"Bluefin Tuna",
			"Yellowfin Tuna",
			"Barracuda",
			"Sea Bass",
			"Chinook Salmon",
			"Sea Pickle",
			"Swordfish",
			"Anglerfish",
			"Coelacanth",
			"Sailfish",
			"Stingray",
			"Sawfish",
			"Moonfish",
			"Dolphin",
			"Flying Fish",
			"Colossal Squid",
			"Oarfish",
			"Crown Bass",
			"Mythic Fish",
			"Long Pike",
			"Mustard",
			"Fin Whale"
		},
		Priority = 40,
		CantBeWormholed = true,
		IsHunt = true
	},
	["Notes Island Pool"] = {
		Pool = {
			"Rotfin Eel",
			"Wraithfin",
			"Siren’s Guppy",
			"Black Veil Ray",
			"Hexeye Snapper",
			"Bone Lanternfish",
			"Harbinger Koi",
			"Slain Maw"
		},
		CantBeWormholed = true,
		Priority = 4
	},
	["The Depths - Serpent"] = {
		Pool = {
			"Destroyed Fossil",
			"Scrap Metal",
			"Deep-sea Dragonfish",
			"Deep-sea Hatchetfish",
			"Frilled Shark",
			"Depth Octopus",
			"Three-eyed Fish",
			"Luminescent Minnow",
			"Goblin Shark",
			"Black Dragon Fish",
			"Spider Crab",
			"Nautilus",
			"Small Spine Chimera",
			"Ancient Eel",
			"Mutated Shark",
			"Barreleye Fish",
			"Sea Snake",
			"Ancient Depth Serpent",
			"Enchant Relic"
		},
		Priority = 2,
		Disturbs = "MoonlitMirage",
		CustomCondition = function(_, _, instance)
			if instance:FindFirstChild("Cache") and instance.Cache:FindFirstChild("Door.TheDepthsGate") then
				return true
			end

			return false, "You must unlock the gate to The Depths before fishing here."
		end
	},
	["The Depths"] = {
		Pool = {
			"Destroyed Fossil",
			"Scrap Metal",
			"Deep-sea Dragonfish",
			"Deep-sea Hatchetfish",
			"Frilled Shark",
			"Depth Octopus",
			"Three-eyed Fish",
			"Luminescent Minnow",
			"Goblin Shark",
			"Black Dragon Fish",
			"Spider Crab",
			"Nautilus",
			"Small Spine Chimera",
			"Ancient Eel",
			"Mutated Shark",
			"Barreleye Fish",
			"Sea Snake",
			"Enchant Relic"
		},
		Priority = 1,
		Disturbs = { "DepthsAbsoluteDarkness", "MoonlitMirage" },
		CustomCondition = function(_, _, instance)
			if instance:FindFirstChild("Cache") and instance.Cache:FindFirstChild("Door.TheDepthsGate") then
				return true
			end

			return false, "You must unlock the gate to The Depths before fishing here."
		end
	},
	Shimmer = {
		Pool = { "Sockeye Salmon" },
		CantBeWormholed = true,
		Priority = 10000000
	},
	["Mutated Sharky Whirlpool"] = {
		Pool = {
			"Goblin Shark",
			"Black Dragon Fish",
			"Spider Crab",
			"Nautilus",
			"Small Spine Chimera",
			"Ancient Eel",
			"Mutated Shark",
			"Barreleye Fish",
			"Sea Snake",
			"Enchant Relic"
		},
		Priority = 10,
		CantBeWormholed = true,
		CustomCondition = function(_, p, instance)
			if instance:FindFirstChild("Cache") and instance.Cache:FindFirstChild("Door.TheDepthsGate") and p.Data.NewFormat.Companions.Equipped == "Mutated Sharky" then
				return true
			end

			return false, nil
		end
	},
	["Crystal Cove"] = {
		Pool = {
			"Destroyed Fossil",
			"Scrap Metal",
			"Deep-sea Dragonfish",
			"Deep-sea Hatchetfish",
			"Frilled Shark",
			"Depth Octopus",
			"Three-eyed Fish",
			"Luminescent Minnow",
			"Opalescent Catfish",
			"Pufferflute",
			"Stringed Grouper",
			"Crystal Frilled Shark",
			"DJ Spinopus"
		},
		Priority = 1,
		RarityBaseChanceBoosts = {
			Common = 0.25
		},
		CustomCondition = function(_, _, instance)
			if instance:FindFirstChild("Cache") and instance.Cache:FindFirstChild("Door.TheDepthsGate") then
				return true
			end

			return false, "You must unlock the gate to The Depths before fishing here."
		end
	},
	Fischfest = {
		Pool = {
			"Sunsquid",
			"Surfboard Ray",
			"Beach Ball Pufferfish",
			"Sandslasher",
			"Tidepopper",
			"Coconut",
			"Shellphone",
			"Popsicle",
			"Message in a Bottle",
			"Tiki Mask"
		},
		Priority = 1,
		CantBeWormholed = true
	},
	["Fischfest 2"] = {
		Pool = {
			"Flipflopper",
			"Beach Towel",
			"Chillin' Crab",
			"Ice Cream Carp",
			"Lifeguard Lobster",
			"Lemonade",
			"Water Balloon",
			"Pool Noodle Eel",
			"Crabby Coconut",
			"Popsicle Pike",
			"BBQ Bass",
			"Floatie Fugu",
			"Tiki Trout",
			"Slushy",
			"Tanning Trout",
			"Cooler Catfish",
			"Picnic Pufferfish",
			"Sand-Sculpted Shark",
			"Coastal Crate",
			"Sunslasher",
			"Beached Relic",
			"Tropical Relic",
			"Paradise Relic"
		},
		Priority = 1,
		CantBeWormholed = true
	},
	["Heart of the Island"] = {
		ExclusiveRods = {
			AllowedRods = { "Starshell Rod" },
			ErrorMessage = "Only the <b>Starshell Rod</b> can withstand this immense heat."
		},
		Pool = {
			"Basalt",
			"Rock",
			"Stalactite",
			"Flameslasher"
		},
		Priority = 2,
		CantBeWormholed = true,
		CustomCondition = function(_, p, _)
			if p.Data.NewFormat.Fischfest2026.GateOpen then
				return true
			end

			return false, "You have not yet opened the hatch."
		end
	},
	["Waterpark Slides"] = {
		Pool = {
			"Crab Floatie",
			"Lifeguppy",
			"Noodle Newt",
			"Snorkel Snook",
			"Buoy Bass",
			"Goggled Goby"
		},
		Priority = 2,
		CantBeWormholed = true
	},
	["Waterpark Pool"] = {
		Pool = {
			"Pufferfish Floatie",
			"Lifeguppy",
			"Noodle Newt",
			"Snorkel Snook",
			"Buoy Bass",
			"Goggled Goby"
		},
		Priority = 2,
		CantBeWormholed = true
	},
	["Waterpark Lazy River"] = {
		Pool = {
			"Dumbo Octopus Floatie",
			"Lifeguppy",
			"Noodle Newt",
			"Snorkel Snook",
			"Buoy Bass",
			"Goggled Goby"
		},
		Priority = 2,
		CantBeWormholed = true
	},
	["Ocean Greedy"] = {
		Pool = {
			"Tire",
			"Boot",
			"Common Crate",
			"Bait Crate",
			"Fish Barrel",
			"Seaweed",
			"Mackerel",
			"Cod",
			"Amberjack",
			"Nurse Shark",
			"Porgy",
			"Sardine",
			"Halibut",
			"Mullet",
			"Salmon",
			"Yellowfin Tuna",
			"Sea Bass",
			"Chinook Salmon",
			"Haddock",
			"Barracuda",
			"Sea Pickle",
			"Pufferfish",
			"Swordfish",
			"Bluefin Tuna",
			"Sailfish",
			"Stingray",
			"Sawfish",
			"Moonfish",
			"Crown Bass",
			"Dolphin",
			"Flying Fish",
			"Mythic Fish",
			"Long Pike",
			"Mustard"
		},
		Priority = 4,
		CantBeWormholed = true
	},
	Ocean = {
		Pool = {
			"Tire",
			"Boot",
			"Common Crate",
			"Bait Crate",
			"Fish Barrel",
			"Seaweed",
			"Boots",
			"Mackerel",
			"Cod",
			"Amberjack",
			"Nurse Shark",
			"Porgy",
			"Sardine",
			"Halibut",
			"Mullet",
			"Salmon",
			"Yellowfin Tuna",
			"Sea Bass",
			"Chinook Salmon",
			"Haddock",
			"Barracuda",
			"Sea Pickle",
			"Pufferfish",
			"Swordfish",
			"Bluefin Tuna",
			"Sailfish",
			"Stingray",
			"Sawfish",
			"Moonfish",
			"Crown Bass",
			"Dolphin",
			"Flying Fish",
			"Mythic Fish",
			"Long Pike",
			"Mustard",
			"Device Display",
			"Tuskmaw"
		},
		Priority = 0,
		Disturbs = { "BabyBloopHunt", "Shark Hunt" }
	},
	["Deep Ocean"] = {
		Pool = {
			"Tire",
			"Boot",
			"Common Crate",
			"Seaweed",
			"Carbon Crate",
			"Quality Bait Crate",
			"Common Crate",
			"Bait Crate",
			"Mackerel",
			"Cod",
			"Amberjack",
			"Sardine",
			"Halibut",
			"Salmon",
			"Mullet",
			"Bluefin Tuna",
			"Yellowfin Tuna",
			"Barracuda",
			"Sea Bass",
			"Chinook Salmon",
			"Sea Pickle",
			"Swordfish",
			"Anglerfish",
			"Coelacanth",
			"Sailfish",
			"Stingray",
			"Sawfish",
			"Moonfish",
			"Dolphin",
			"Flying Fish",
			"Colossal Squid",
			"Oarfish",
			"Crown Bass",
			"Mythic Fish",
			"Long Pike",
			"Mustard",
			"Blobfish",
			"Device Display",
			"Tuskmaw"
		},
		Priority = 1,
		Disturbs = { "BabyBloopHunt", "Shark Hunt" }
	},
	Earthquake = {
		Pool = {
			"Tire",
			"Boot",
			"Common Crate",
			"Bait Crate",
			"Fish Barrel",
			"Seaweed",
			"Boots",
			"Mackerel",
			"Cod",
			"Amberjack",
			"Nurse Shark",
			"Porgy",
			"Sardine",
			"Halibut",
			"Mullet",
			"Salmon",
			"Yellowfin Tuna",
			"Sea Bass",
			"Chinook Salmon",
			"Haddock",
			"Barracuda",
			"Sea Pickle",
			"Pufferfish",
			"Swordfish",
			"Bluefin Tuna",
			"Sailfish",
			"Stingray",
			"Sawfish",
			"Moonfish",
			"Crown Bass",
			"Dolphin",
			"Flying Fish",
			"Mythic Fish",
			"Long Pike",
			"Mustard",
			"Akkorokamui",
			"Lusca",
			"Charybdis",
			"Tuskmaw"
		},
		Priority = 0,
		CantBeWormholed = true,
		Disturbs = { "BabyBloopHunt", "Shark Hunt" }
	},
	["Atlantis Ocean"] = {
		Pool = {
			"Tire",
			"Boot",
			"Common Crate",
			"Seaweed",
			"Carbon Crate",
			"Quality Bait Crate",
			"Common Crate",
			"Bait Crate",
			"Mackerel",
			"Cod",
			"Amberjack",
			"Sardine",
			"Halibut",
			"Salmon",
			"Mullet",
			"Bluefin Tuna",
			"Yellowfin Tuna",
			"Barracuda",
			"Sea Bass",
			"Chinook Salmon",
			"Sea Pickle",
			"Swordfish",
			"Anglerfish",
			"Coelacanth",
			"Sailfish",
			"Stingray",
			"Sawfish",
			"Moonfish",
			"Dolphin",
			"Flying Fish",
			"Colossal Squid",
			"Oarfish",
			"Crown Bass",
			"Mythic Fish",
			"Long Pike",
			"Mustard"
		},
		Priority = 1,
		CantBeWormholed = true
	},
	["Grand Reef"] = {
		Pool = {
			"Tire",
			"Boot",
			"Common Crate",
			"Bait Crate",
			"Fish Barrel",
			"Seaweed",
			"Reef Minnow",
			"Reef Goby",
			"Coral Chromis",
			"Coral Guard",
			"Crystal Wrasse",
			"Reef Parrotfish",
			"Coral Emperor",
			"Grand Reef Guardian"
		},
		Priority = 3
	},
	["Forsaken Shores"] = {
		Pool = {
			"Tire",
			"Boot",
			"Common Crate",
			"Bait Crate",
			"Fish Barrel",
			"Seaweed",
			"Corsair Grouper",
			"Scurvy Sailfish",
			"Cutlass Fish",
			"Reefrunner Snapper"
		},
		Priority = 1
	},
	["Forsaken Shores Ocean"] = {
		Pool = {
			"Tire",
			"Boot",
			"Common Crate",
			"Bait Crate",
			"Fish Barrel",
			"Seaweed",
			"Corsair Grouper",
			"Scurvy Sailfish",
			"Cutlass Fish",
			"Reefrunner Snapper",
			"Shortfin Mako Shark",
			"Galleon Goliath",
			"Buccaneer Barracuda",
			"Cursed Eel",
			"Shipwreck Barracuda",
			"Golden Seahorse"
		},
		Priority = 2
	},
	["Forsaken Shores Pond"] = {
		Pool = {
			"Tire",
			"Boot",
			"Common Crate",
			"Bait Crate",
			"Fish Barrel",
			"Seaweed",
			"Corsair Grouper",
			"Scurvy Sailfish",
			"Cutlass Fish",
			"Reefrunner Snapper",
			"Captain's Goldfish",
			"Pirate Captain's Goldfish"
		},
		Priority = 3
	},
	["Moosewood Ocean"] = {
		Pool = {
			"Tire",
			"Boot",
			"Common Crate",
			"Bait Crate",
			"Fish Barrel",
			"Seaweed",
			"Trout",
			"Barracuda",
			"Flounder",
			"Yellowfin Tuna",
			"Sockeye Salmon",
			"Red Snapper",
			"Mackerel",
			"Anchovy",
			"Eel",
			"Moonfish",
			"Bull Shark",
			"Cataclysm Carp"
		},
		Priority = 1
	},
	["Moosewood Ocean Mythical"] = {
		Pool = {
			"Tire",
			"Boot",
			"Common Crate",
			"Bait Crate",
			"Fish Barrel",
			"Seaweed",
			"Trout",
			"Barracuda",
			"Flounder",
			"Yellowfin Tuna",
			"Sockeye Salmon",
			"Red Snapper",
			"Anchovy",
			"Eel",
			"Whisker Bill",
			"Treble Bass",
			"Cataclysm Carp"
		},
		Priority = 4
	},
	["Moosewood Docks"] = {
		Pool = {
			"Driftwood",
			"Seaweed",
			"Bait Crate",
			"Common Crate",
			"Flounder",
			"Red Snapper",
			"Trout",
			"Snook",
			"Mackerel",
			"Sockeye Salmon",
			"Anchovy",
			"Pike",
			"Cataclysm Carp"
		},
		Priority = 2
	},
	["Moosewood Pond"] = {
		Pool = {
			"Tire",
			"Driftwood",
			"Common Crate",
			"Largemouth Bass",
			"Trout",
			"Goldfish",
			"Carp",
			"Bream",
			"Pike",
			"Eel",
			"Whiptail Catfish",
			"Cataclysm Carp"
		},
		Priority = 2
	},
	Lava = {
		Pool = {
			"Volcanic Geode",
			"Rock",
			"Basalt",
			"Quality Bait Crate",
			"Inferno Wood",
			"Ember Snapper",
			"Pyrogrub",
			"Ember Perch",
			"Magma Tang",
			"Obsidian Salmon",
			"Obsidian Swordfish",
			"Molten Banshee",
			"Molten Ripple"
		},
		Priority = 2,
		RequiredDurability = 100
	},
	Eruption = {
		Pool = {
			"Volcanic Geode",
			"Rock",
			"Basalt",
			"Quality Bait Crate",
			"Inferno Wood",
			"Ember Snapper",
			"Pyrogrub",
			"Ember Perch",
			"Magma Tang",
			"Obsidian Salmon",
			"Obsidian Swordfish",
			"Molten Banshee",
			"Molten Ripple",
			"Ashclaw"
		},
		Priority = 3,
		CantBeWormholed = true,
		RequiredDurability = 100,
		IsHunt = true
	},
	["Roslit Pond"] = {
		Pool = {
			"Driftwood",
			"Alligator Gar",
			"Perch",
			"Minnow",
			"Pumpkinseed",
			"Chub",
			"Arapaima",
			"Axolotl",
			"Aetherfin"
		},
		Priority = 2
	},
	["Roslit Pond Seaweed"] = {
		Pool = {
			"Driftwood",
			"Seaweed",
			"Alligator Gar",
			"Perch",
			"Minnow",
			"Pumpkinseed",
			"Trout",
			"Arapaima",
			"Suckermouth Catfish",
			"Axolotl",
			"Aetherfin"
		},
		Priority = 3
	},
	["Roslit Bay"] = {
		Pool = {
			"Driftwood",
			"Common Crate",
			"Log",
			"Butterflyfish",
			"Angelfish",
			"Clownfish",
			"Blue Tang",
			"Yellow Boxfish",
			"Ribbon Eel",
			"Nurse Shark",
			"Pufferfish",
			"Bull Shark",
			"Crown Bass",
			"Manta Ray",
			"Dumbo Octopus",
			"Reef Triggerfish",
			"Translator Core",
			"Aetherfin"
		},
		Priority = 3
	},
	["Roslit Bay Alien"] = {
		Pool = {
			"Driftwood",
			"Common Crate",
			"Log",
			"Butterflyfish",
			"Angelfish",
			"Clownfish",
			"Blue Tang",
			"Yellow Boxfish",
			"Ribbon Eel",
			"Nurse Shark",
			"Pufferfish",
			"Bull Shark",
			"Crown Bass",
			"Manta Ray",
			"Dumbo Octopus",
			"Translator Core",
			"Aetherfin"
		},
		Priority = 8000
	},
	["Roslit Bay Ocean"] = {
		Pool = {
			"Driftwood",
			"Common Crate",
			"Log",
			"Mackerel",
			"Cod",
			"Amberjack",
			"Nurse Shark",
			"Sardine",
			"Halibut",
			"Salmon",
			"Sea Bass",
			"Chinook Salmon",
			"Haddock",
			"Mullet",
			"Yellow Boxfish",
			"Pufferfish",
			"Squid",
			"Swordfish",
			"Nurse Shark",
			"Crown Bass",
			"Dumbo Octopus",
			"Flying Fish",
			"Mythic Fish",
			"Manta Ray",
			"Translator Core",
			"Aetherfin"
		},
		Priority = 2
	},
	["Roslit Bay Clam"] = {
		Pool = { "Clam", "Aetherfin" },
		Priority = 10000
	},
	["Desolate Deep"] = {
		Pool = {
			"Log",
			"Rock",
			"Common Crate",
			"Stalactite",
			"String",
			"Coral Geode",
			"Slate Tuna",
			"Phantom Ray",
			"Rockstar Hermit Crab",
			"Horseshoe Crab",
			"Grandpa Horseshoe Crab",
			"Banditfish",
			"Cockatoo Squid",
			"Midnight Axolotl",
			"Barbed Shark",
			"Blue Galapagos Octopus",
			"Emperor Jellyfish",
			"Lumilotl"
		},
		Priority = 2
	},
	["Brine Storm"] = {
		Pool = {
			"Dissolved Bone",
			"Stormgazer",
			"Brine Sovereign",
			"Caustic Starwyrm"
		},
		Priority = 10,
		RequiredDurability = 200,
		CantBeWormholed = true,
		FishingStatsMultiply = {
			Lure = 0.5
		}
	},
	["Brine Pool Water"] = {
		Pool = {
			"Rock",
			"Stalactite",
			"Bone",
			"Coral Geode",
			"Common Crate",
			"Stalactite",
			"Gazerfish",
			"Brine Shrimp",
			"Globe Jellyfish",
			"Dweller Catfish",
			"Brine Phantom",
			"Spectral Serpent"
		},
		Disturbs = "BrineStorm",
		Priority = 2,
		RequiredDurability = 200,
		CantBeWormholed = true
	},
	["Ancient Isle Ocean"] = {
		Pool = {
			"Tire",
			"Carbon Crate",
			"Common Crate",
			"Bait Crate",
			"Fish Barrel",
			"Cod",
			"Sardine",
			"Sea Bass",
			"Mullet",
			"Piranha",
			"Anomalocaris",
			"Starfish",
			"Onychodus",
			"Acanthodii",
			"Xiphactinus",
			"Hyneria",
			"Cobia",
			"Ginsu Shark",
			"Dunkleosteus",
			"Colossal Squid",
			"Helicoprion",
			"Mosasaurus",
			"Banana",
			"Ancient Fragment",
			"Meg's Fang",
			"Meg's Spine"
		},
		Disturbs = { "MegHunt", "LivyatanHunt" },
		Priority = 2,
		RarityLuckFactorBoosts = {
			Legendary = 1.5,
			Mythical = 2
		}
	},
	["Ancient Isle Pond"] = {
		Pool = {
			"Log",
			"Piranha",
			"Cladoselache",
			"Anomalocaris",
			"Xiphactinus",
			"Hyneria",
			"Hallucigenia",
			"Floppy",
			"Banana"
		},
		Disturbs = "LivyatanHunt",
		Priority = 3,
		RarityLuckFactorBoosts = {
			Legendary = 1.5,
			Mythical = 2
		}
	},
	["Ancient Isle Waterfall"] = {
		Pool = {
			"Log",
			"Piranha",
			"Cladoselache",
			"Anomalocaris",
			"Xiphactinus",
			"Hyneria",
			"Hallucigenia",
			"Leedsichthys",
			"Banana"
		},
		Disturbs = "LivyatanHunt",
		Priority = 4,
		RarityLuckFactorBoosts = {
			Legendary = 1.5,
			Mythical = 2
		}
	},
	["Ancient Archives"] = {
		Pool = {
			"Tire",
			"Boot",
			"Common Crate",
			"Bait Crate",
			"Fish Barrel",
			"Seaweed",
			"Palaeoniscum",
			"Birgeria",
			"Phanerorhynchus",
			"Diplurus",
			"Lepidotes",
			"Amblypterus"
		},
		Disturbs = "LivyatanHunt",
		Priority = 1
	},
	["Terrapin Ocean"] = {
		Pool = {
			"Log",
			"Driftwood",
			"Common Crate",
			"Fish Barrel",
			"Sea Bass",
			"Largemouth Bass",
			"Smallmouth Bass",
			"White Bass",
			"Redeye Bass",
			"Chinook Salmon",
			"Gudgeon",
			"Walleye",
			"Golden Smallmouth Bass",
			"Sea Turtle",
			"Manatee"
		},
		Priority = 2
	},
	["Terrapin Olm"] = {
		Pool = {
			"Log",
			"Driftwood",
			"Common Crate",
			"Fish Barrel",
			"Sea Bass",
			"Largemouth Bass",
			"Smallmouth Bass",
			"White Bass",
			"Redeye Bass",
			"Chinook Salmon",
			"Gudgeon",
			"Walleye",
			"Olm"
		},
		Priority = 3
	},
	["Mushgrove Water"] = {
		Pool = {
			"Carbon Crate",
			"Common Crate",
			"Bait Crate",
			"Log",
			"Driftwood",
			"Resin",
			"Swamp Bass",
			"Grey Carp",
			"Bowfin",
			"White Perch",
			"Fungal Cluster",
			"Marsh Gar",
			"Catfish",
			"Alligator",
			"Handfish",
			"RocketFuel",
			"Hogchoker"
		},
		Priority = 2
	},
	Vertigo = {
		Pool = {
			"Carbon Crate",
			"Rock",
			"Quality Bait Crate",
			"Common Crate",
			"Bait Crate",
			"Twilight Eel",
			"Fangborn Gar",
			"Spiderfish",
			"The Depths Key",
			"Abyssacuda",
			"Voidfin Mahi",
			"Rubber Ducky"
		},
		Priority = 2
	},
	["Snowcap Pond"] = {
		Pool = {
			"Common Crate",
			"Quality Bait Crate",
			"Ice",
			"Boot",
			"Blackfish",
			"Burbot",
			"Grayling",
			"Glacier Pike",
			"Sturgeon",
			"Pond Emperor",
			"Baby Pond Emperor"
		},
		Priority = 2
	},
	["Snowcap Ocean"] = {
		Pool = {
			"Ice",
			"Tire",
			"Carbon Crate",
			"Common Crate",
			"Bait Crate",
			"Fish Barrel",
			"Moon Wood",
			"Cod",
			"Sardine",
			"Salmon",
			"Sea Bass",
			"Porgy",
			"Arctic Char",
			"Pollock",
			"Red Drum",
			"Herring",
			"Bluegill",
			"Lingcod",
			"Mullet",
			"Skipjack Tuna",
			"Glacierfish",
			"Moonfish",
			"Colossal Squid",
			"Ringle",
			"Walrus"
		},
		Priority = 2
	},
	Snowburrow = {
		Pool = {
			"Ice",
			"Stalactite",
			"Freezing Shroom",
			"Cod",
			"Sardine",
			"Salmon",
			"Sea Bass",
			"Porgy",
			"Arctic Char",
			"Pollock",
			"Red Drum",
			"Herring",
			"Bluegill",
			"Lingcod",
			"Mullet",
			"Skipjack Tuna",
			"Glacierfish",
			"Moonfish",
			"Colossal Squid",
			"Ringle",
			"White Sturgeon",
			"Glacial Fragment"
		},
		Priority = 2
	},
	Sunstone = {
		Pool = {
			"Seaweed",
			"Driftwood",
			"Quality Bait Crate",
			"Ancient Wood",
			"Trumpetfish",
			"Glassfish",
			"Longtail Bass",
			"Sweetfish",
			"Red Tang",
			"Mahi Mahi",
			"Napoleonfish",
			"Chinfish",
			"Sailfish",
			"Sunfish",
			"Wiifish",
			"Voltfish",
			"Tartaruga",
			"Speed Core",
			"Communication Circuit",
			"Crustal Colossus"
		},
		Priority = 2
	},
	Mineshaft = {
		Pool = {
			"Stalactite",
			"Rock",
			"Boot",
			"Scrap Metal",
			"Common Crate",
			"Carbon Crate",
			"Rusty Bolt",
			"Iron Chunk",
			"Gold Piece",
			"Crystal Geode",
			"Radiant Crystal"
		},
		Priority = 3,
		RarityLuckFactorBoosts = {
			Legendary = 0.75,
			Mythical = 0.5
		},
		CustomCondition = function(_, p)
			if p.Data.NewFormat.SunstoneExpansion.MerlinQuestProgress < 3 then
				return false, "You must complete Merlin's quest before fishing here."
			end

			return true
		end
	},
	["Sunstone Hidden"] = {
		Pool = {
			"Common Crate",
			"Carbon Crate",
			"Bait Crate",
			"Fish Barrel",
			"Quality Bait Crate",
			"Tire",
			"Seaweed",
			"Driftwood",
			"Boot",
			"Rock"
		},
		Priority = 2
	},
	["Keepers Altar"] = {
		Pool = {
			"Tire",
			"Boot",
			"Seaweed",
			"Void Wood",
			"Bluefish",
			"Keepers Guardian",
			"Lapisjack",
			"Pale Tang",
			"Umbral Shark",
			"Boulder"
		},
		Priority = 3
	},
	["Harvesters Spike"] = {
		Pool = {
			"Carbon Crate",
			"Common Crate",
			"Bait Crate",
			"Mackerel",
			"Cod",
			"Amberjack",
			"Nurse Shark",
			"Sardine",
			"Halibut",
			"Salmon",
			"Bluefin Tuna",
			"Sockeye Salmon",
			"Mullet",
			"Barracuda",
			"Sea Bass",
			"Chinook Salmon",
			"Sea Pickle",
			"Pufferfish",
			"Swordfish",
			"Sawfish"
		},
		Priority = 3
	},
	["The Arch"] = {
		Pool = {
			"Tire",
			"Boot",
			"Common Crate",
			"Bait Crate",
			"Fish Barrel",
			"Seaweed",
			"Mackerel",
			"Cod",
			"Amberjack",
			"Sardine",
			"Halibut",
			"Salmon",
			"Yellowfin Tuna",
			"Mullet",
			"Sea Bass",
			"Chinook Salmon",
			"Haddock",
			"Bluefin Tuna",
			"Barracuda",
			"Sea Pickle",
			"Sailfish",
			"Rabbitfish",
			"Moonfish"
		},
		Priority = 3
	},
	["Scallop Ocean"] = {
		Pool = {
			"Tire",
			"Boot",
			"Seaweed",
			"Scallop"
		},
		Priority = 3
	},
	["Lovestorm Eel"] = {
		Pool = {
			"Tire",
			"Boot",
			"Common Crate",
			"Seaweed",
			"Carbon Crate",
			"Quality Bait Crate",
			"Common Crate",
			"Bait Crate",
			"Mackerel",
			"Cod",
			"Amberjack",
			"Sardine",
			"Halibut",
			"Salmon",
			"Mullet",
			"Bluefin Tuna",
			"Yellowfin Tuna",
			"Barracuda",
			"Sea Bass",
			"Chinook Salmon",
			"Sea Pickle",
			"Swordfish",
			"Anglerfish",
			"Coelacanth",
			"Sailfish",
			"Stingray",
			"Sawfish",
			"Moonfish",
			"Dolphin",
			"Flying Fish",
			"Colossal Squid",
			"Oarfish",
			"Crown Bass",
			"Mythic Fish",
			"Lovestorm Eel"
		},
		CantBeWormholed = true,
		Priority = 100,
		IsHunt = true
	},
	["Lovestorm Eel Supercharged"] = {
		Pool = {
			"Tire",
			"Boot",
			"Common Crate",
			"Seaweed",
			"Carbon Crate",
			"Quality Bait Crate",
			"Common Crate",
			"Bait Crate",
			"Mackerel",
			"Cod",
			"Amberjack",
			"Sardine",
			"Halibut",
			"Salmon",
			"Mullet",
			"Bluefin Tuna",
			"Yellowfin Tuna",
			"Barracuda",
			"Sea Bass",
			"Chinook Salmon",
			"Sea Pickle",
			"Swordfish",
			"Anglerfish",
			"Coelacanth",
			"Sailfish",
			"Stingray",
			"Sawfish",
			"Moonfish",
			"Dolphin",
			"Flying Fish",
			"Colossal Squid",
			"Oarfish",
			"Crown Bass",
			"Mythic Fish",
			"Lovestorm Eel Supercharged"
		},
		CantBeWormholed = true,
		Priority = 100,
		IsHunt = true
	},
	["Birthday Megalodon"] = {
		Pool = {
			"Tire",
			"Boot",
			"Common Crate",
			"Seaweed",
			"Carbon Crate",
			"Quality Bait Crate",
			"Common Crate",
			"Bait Crate",
			"Mackerel",
			"Cod",
			"Amberjack",
			"Sardine",
			"Halibut",
			"Salmon",
			"Mullet",
			"Bluefin Tuna",
			"Yellowfin Tuna",
			"Barracuda",
			"Sea Bass",
			"Chinook Salmon",
			"Sea Pickle",
			"Swordfish",
			"Anglerfish",
			"Coelacanth",
			"Sailfish",
			"Stingray",
			"Sawfish",
			"Moonfish",
			"Dolphin",
			"Flying Fish",
			"Colossal Squid",
			"Oarfish",
			"Crown Bass",
			"Mythic Fish",
			"Birthday Squid",
			"Birthday Dumbo Octopus",
			"Birthday Goldfish",
			"Birthday Megalodon"
		},
		CantBeWormholed = true,
		Priority = 100,
		IsHunt = true
	},
	["Megalodon Default"] = {
		Pool = {
			"Tire",
			"Boot",
			"Common Crate",
			"Seaweed",
			"Carbon Crate",
			"Quality Bait Crate",
			"Common Crate",
			"Bait Crate",
			"Mackerel",
			"Cod",
			"Amberjack",
			"Sardine",
			"Halibut",
			"Salmon",
			"Mullet",
			"Bluefin Tuna",
			"Yellowfin Tuna",
			"Barracuda",
			"Sea Bass",
			"Chinook Salmon",
			"Sea Pickle",
			"Swordfish",
			"Anglerfish",
			"Coelacanth",
			"Sailfish",
			"Stingray",
			"Sawfish",
			"Moonfish",
			"Dolphin",
			"Flying Fish",
			"Colossal Squid",
			"Oarfish",
			"Crown Bass",
			"Mythic Fish",
			"Megalodon",
			"Ancient Megalodon"
		},
		CantBeWormholed = true,
		Priority = 100,
		IsHunt = true
	},
	["Megalodon Ancient"] = {
		Pool = {
			"Tire",
			"Boot",
			"Common Crate",
			"Seaweed",
			"Carbon Crate",
			"Quality Bait Crate",
			"Common Crate",
			"Bait Crate",
			"Mackerel",
			"Cod",
			"Amberjack",
			"Sardine",
			"Halibut",
			"Salmon",
			"Mullet",
			"Bluefin Tuna",
			"Yellowfin Tuna",
			"Barracuda",
			"Sea Bass",
			"Chinook Salmon",
			"Sea Pickle",
			"Swordfish",
			"Anglerfish",
			"Coelacanth",
			"Sailfish",
			"Stingray",
			"Sawfish",
			"Moonfish",
			"Dolphin",
			"Flying Fish",
			"Colossal Squid",
			"Oarfish",
			"Crown Bass",
			"Mythic Fish",
			"Megalodon",
			"Phantom Megalodon",
			"Ancient Megalodon"
		},
		CantBeWormholed = true,
		Priority = 100,
		IsHunt = true
	},
	["Shamrock Megalodon"] = {
		Pool = {
			"Tire",
			"Boot",
			"Common Crate",
			"Seaweed",
			"Carbon Crate",
			"Quality Bait Crate",
			"Common Crate",
			"Bait Crate",
			"Mackerel",
			"Cod",
			"Amberjack",
			"Sardine",
			"Halibut",
			"Salmon",
			"Mullet",
			"Bluefin Tuna",
			"Yellowfin Tuna",
			"Barracuda",
			"Sea Bass",
			"Chinook Salmon",
			"Sea Pickle",
			"Swordfish",
			"Anglerfish",
			"Coelacanth",
			"Sailfish",
			"Stingray",
			"Sawfish",
			"Moonfish",
			"Dolphin",
			"Flying Fish",
			"Colossal Squid",
			"Oarfish",
			"Crown Bass",
			"Mythic Fish",
			"Shamrock Megalodon"
		},
		CantBeWormholed = true,
		Priority = 100,
		IsHunt = true
	},
	["Great White Shark"] = {
		Pool = {
			"Great White Shark",
			"Mackerel",
			"Cod",
			"Amberjack",
			"Sardine",
			"Sea Bass",
			"Barracuda",
			"Haddock",
			"Sailfish",
			"Porgy",
			"Mullet",
			"Cookiecutter Shark",
			"Driftwood",
			"Common Crate"
		},
		Priority = 100
	},
	["Great Hammerhead Shark"] = {
		Pool = {
			"Great Hammerhead Shark",
			"Mackerel",
			"Cod",
			"Amberjack",
			"Sardine",
			"Sea Bass",
			"Barracuda",
			"Haddock",
			"Sailfish",
			"Porgy",
			"Mullet",
			"Cookiecutter Shark",
			"Driftwood",
			"Common Crate"
		},
		Priority = 100
	},
	["Whale Shark"] = {
		Pool = {
			"Whale Shark",
			"Mackerel",
			"Cod",
			"Amberjack",
			"Sardine",
			"Sea Bass",
			"Barracuda",
			"Haddock",
			"Sailfish",
			"Porgy",
			"Mullet",
			"Cookiecutter Shark",
			"Driftwood",
			"Common Crate"
		},
		Priority = 100
	},
	Isonade = {
		Pool = {
			"Isonade",
			"Tire",
			"Boot",
			"Common Crate",
			"Bait Crate",
			"Fish Barrel",
			"Seaweed",
			"Carbon Crate",
			"Quality Bait Crate",
			"Mackerel",
			"Cod",
			"Amberjack",
			"Sardine",
			"Sea Bass",
			"Barracuda",
			"Haddock",
			"Mullet",
			"Cookiecutter Shark",
			"The Depths Key"
		},
		Priority = 101
	},
	FischFright24 = {
		Pool = {
			"Lurkerfish",
			"Skelefish",
			"Candy Fish",
			"Ghoulfish",
			"Zombiefish",
			"Nessie",
			"Tire",
			"Boot",
			"Common Crate",
			"Seaweed",
			"Carbon Crate",
			"Quality Bait Crate",
			"Common Crate",
			"Bait Crate",
			"Mackerel",
			"Cod",
			"Amberjack",
			"Sardine",
			"Halibut",
			"Salmon",
			"Bluefin Tuna",
			"Yellowfin Tuna",
			"Barracuda",
			"Sea Bass",
			"Chinook Salmon",
			"Sea Pickle",
			"Swordfish",
			"Anglerfish",
			"Coelacanth",
			"Sailfish",
			"Stingray"
		},
		Priority = 102,
		CantBeWormholed = true
	},
	FischFright25 = {
		Pool = {
			"Kelpie",
			"Phantom Jellyfish",
			"Vampire Perch",
			"Spider Salmon",
			"Werewolf Walleye",
			"Tire",
			"Boot",
			"Common Crate",
			"Seaweed",
			"Carbon Crate",
			"Quality Bait Crate",
			"Common Crate",
			"Bait Crate",
			"Mackerel",
			"Cod",
			"Amberjack",
			"Sardine",
			"Halibut",
			"Salmon",
			"Bluefin Tuna",
			"Yellowfin Tuna",
			"Barracuda",
			"Sea Bass",
			"Chinook Salmon",
			"Sea Pickle",
			"Swordfish",
			"Anglerfish",
			"Coelacanth",
			"Sailfish",
			"Stingray"
		},
		Priority = 102,
		CantBeWormholed = true
	},
	FrightfulVillage = {
		Pool = {
			"Coffin Crab",
			"Pumpkin Pufferfish",
			"Ectoplasm Eel",
			"Frankenshrimp",
			"Ghost Minnow",
			"Potion Perch",
			"Mourning Manta Ray",
			"Candle Carp",
			"Gravestone Stingray",
			"Frightful Crate"
		},
		Priority = 102,
		CantBeWormholed = true
	},
	NessieCatacomb = {
		Pool = {
			"Skeletal Nessie",
			"Coffin Crab",
			"Pumpkin Pufferfish",
			"Ectoplasm Eel",
			"Frankenshrimp",
			"Ghost Minnow",
			"Potion Perch",
			"Mourning Manta Ray",
			"Candle Carp",
			"Gravestone Stingray"
		},
		Priority = 102,
		CantBeWormholed = true
	},
	Fischmas24 = {
		Pool = {
			"Icicle",
			"Basic Present",
			"Unique Present",
			"Supreme Present",
			"Festive Bait Crate",
			"Cookie",
			"Candy Cane Carp",
			"Santa Salmon",
			"Gingerbread Fish",
			"Snowflake Flounder",
			"Olmdeer",
			"Santa Pufferfish",
			"Northstar Serpent",
			"Glass of Milk",
			"Ornament Fish"
		},
		Priority = 104,
		CantBeWormholed = true
	},
	["Overgrowth Caves"] = {
		Pool = {
			"Tire",
			"Boot",
			"Common Crate",
			"Bait Crate",
			"Fish Barrel",
			"Seaweed",
			"Ice Anchovy",
			"Icy Salmon",
			"Icy Carp",
			"Frigid Crab",
			"Icy Tuna",
			"Icy Goldfish",
			"Frigid Antlers",
			"Frozen Walnut",
			"Glass Diamond"
		},
		Priority = 2
	},
	["Frigid Cavern"] = {
		Pool = {
			"Tire",
			"Boot",
			"Common Crate",
			"Bait Crate",
			"Fish Barrel",
			"Seaweed",
			"Ice Eel",
			"Frigid Shrimp",
			"Ice Jellyfish",
			"Ice Octopus",
			"Frigid Taco",
			"Snowfish",
			"Polar Alligator",
			"Frigid Mammoth Tusk",
			"Glass Diamond"
		},
		Priority = 2
	},
	["Cryogenic Canal"] = {
		Pool = {
			"Tire",
			"Boot",
			"Common Crate",
			"Bait Crate",
			"Fish Barrel",
			"Seaweed",
			"Frost Minnow",
			"Snowflake Smelt",
			"Iced Perch",
			"Snowback Char",
			"Chillfin Herring",
			"Frozen Pike",
			"Icebreaker Haddock",
			"Frostjaw Cod",
			"Aurora Trout",
			"Glacial Sturgeon"
		},
		Priority = 2
	},
	["Glacial Grotto"] = {
		Pool = {
			"Tire",
			"Boot",
			"Common Crate",
			"Bait Crate",
			"Fish Barrel",
			"Seaweed",
			"Snowgill Dace",
			"Frostling Goby",
			"Chillback Whitefish",
			"Icy Walleye",
			"Shiverfin Haddock",
			"Frostbite Flounder",
			"Glacier Swordfish",
			"Icefang Barracuda",
			"Borealis Snapper",
			"Icebeard Shark"
		},
		Priority = 2
	},
	["The Summit Ocean"] = {
		Pool = {
			"Tire",
			"Boot",
			"Common Crate",
			"Bait Crate",
			"Fish Barrel",
			"Seaweed",
			"Mackerel",
			"Cod",
			"Amberjack",
			"Nurse Shark",
			"Porgy",
			"Sardine",
			"Halibut",
			"Mullet",
			"Salmon",
			"Yellowfin Tuna",
			"Sea Bass",
			"Chinook Salmon",
			"Haddock",
			"Barracuda",
			"Sea Pickle",
			"Pufferfish",
			"Swordfish",
			"Bluefin Tuna",
			"Sailfish",
			"Stingray",
			"Sawfish",
			"Moonfish",
			"Crown Bass",
			"Dolphin",
			"Flying Fish",
			"Mythic Fish",
			"Glass Diamond"
		},
		Priority = 2,
		CantBeWormholed = true
	},
	["Forsaken Algae Pool"] = {
		Pool = {
			"Tire",
			"Boot",
			"Common Crate",
			"Seaweed",
			"Carbon Crate",
			"Quality Bait Crate",
			"Common Crate",
			"Bait Crate",
			"Mackerel",
			"Cod",
			"Amberjack",
			"Sardine",
			"Halibut",
			"Salmon",
			"Mullet",
			"Bluefin Tuna",
			"Yellowfin Tuna",
			"Barracuda",
			"Sea Bass",
			"Chinook Salmon",
			"Sea Pickle",
			"Swordfish",
			"Anglerfish",
			"Coelacanth",
			"Sailfish",
			"Stingray",
			"Sawfish",
			"Moonfish",
			"Dolphin",
			"Flying Fish",
			"Colossal Squid",
			"Oarfish",
			"Crown Bass",
			"Mythic Fish",
			"Forsaken Algae"
		},
		Priority = 100,
		CantBeWormholed = true
	},
	["Ancient Algae Pool"] = {
		Pool = {
			"Tire",
			"Boot",
			"Common Crate",
			"Seaweed",
			"Carbon Crate",
			"Quality Bait Crate",
			"Common Crate",
			"Bait Crate",
			"Mackerel",
			"Cod",
			"Amberjack",
			"Sardine",
			"Halibut",
			"Salmon",
			"Mullet",
			"Bluefin Tuna",
			"Yellowfin Tuna",
			"Barracuda",
			"Sea Bass",
			"Chinook Salmon",
			"Sea Pickle",
			"Swordfish",
			"Anglerfish",
			"Coelacanth",
			"Sailfish",
			"Stingray",
			"Sawfish",
			"Moonfish",
			"Dolphin",
			"Flying Fish",
			"Colossal Squid",
			"Oarfish",
			"Crown Bass",
			"Mythic Fish",
			"Ancient Algae"
		},
		Priority = 100,
		CantBeWormholed = true
	},
	["Mushgrove Algae Pool"] = {
		Pool = {
			"Tire",
			"Boot",
			"Common Crate",
			"Seaweed",
			"Carbon Crate",
			"Quality Bait Crate",
			"Common Crate",
			"Bait Crate",
			"Mackerel",
			"Cod",
			"Amberjack",
			"Sardine",
			"Halibut",
			"Salmon",
			"Mullet",
			"Bluefin Tuna",
			"Yellowfin Tuna",
			"Barracuda",
			"Sea Bass",
			"Chinook Salmon",
			"Sea Pickle",
			"Swordfish",
			"Anglerfish",
			"Coelacanth",
			"Sailfish",
			"Stingray",
			"Sawfish",
			"Moonfish",
			"Dolphin",
			"Flying Fish",
			"Colossal Squid",
			"Oarfish",
			"Crown Bass",
			"Mythic Fish",
			"Mushgrove Algae"
		},
		Priority = 100,
		CantBeWormholed = true
	},
	["Snowcap Algae Pool"] = {
		Pool = {
			"Tire",
			"Boot",
			"Common Crate",
			"Seaweed",
			"Carbon Crate",
			"Quality Bait Crate",
			"Common Crate",
			"Bait Crate",
			"Mackerel",
			"Cod",
			"Amberjack",
			"Sardine",
			"Halibut",
			"Salmon",
			"Mullet",
			"Bluefin Tuna",
			"Yellowfin Tuna",
			"Barracuda",
			"Sea Bass",
			"Chinook Salmon",
			"Sea Pickle",
			"Swordfish",
			"Anglerfish",
			"Coelacanth",
			"Sailfish",
			"Stingray",
			"Sawfish",
			"Moonfish",
			"Dolphin",
			"Flying Fish",
			"Colossal Squid",
			"Oarfish",
			"Crown Bass",
			"Mythic Fish",
			"Snowcap Algae"
		},
		Priority = 100,
		CantBeWormholed = true
	},
	["Golden Tide"] = {
		Pool = {
			"Confetti Shark",
			"Countdown Perch",
			"Eternal Frostwhale",
			"Hourglass Bass",
			"Tidal Pike",
			"Tire",
			"Boot",
			"Common Crate",
			"Seaweed",
			"Carbon Crate",
			"Quality Bait Crate",
			"Common Crate",
			"Bait Crate",
			"Mackerel",
			"Cod",
			"Amberjack",
			"Sardine",
			"Halibut",
			"Salmon",
			"Bluefin Tuna",
			"Yellowfin Tuna",
			"Barracuda",
			"Sea Bass",
			"Chinook Salmon",
			"Sea Pickle",
			"Swordfish",
			"Anglerfish",
			"Coelacanth",
			"Sailfish",
			"Stingray"
		},
		Priority = 102,
		CantBeWormholed = true
	},
	["Zeus Pool"] = {
		Pool = {
			"Tire",
			"Boot",
			"Common Crate",
			"Seaweed",
			"Carbon Crate",
			"Quality Bait Crate",
			"Common Crate",
			"Bait Crate",
			"Lightning Minnow",
			"Voltfin Carp",
			"Sparkfin Tetra",
			"Static Ray",
			"Lightning Pike",
			"Stormcloud Angelfish",
			"Thunder Bass",
			"Storm Eel",
			"Thunder Serpent",
			"Zeus' Herald"
		},
		Priority = 1,
		CustomCondition = function(_, _, instance)
			if instance:FindFirstChild("Cache") and instance.Cache:FindFirstChild("Door.ZeusPuzzleDoor") then
				return true
			end

			return false, "You must complete the Zeus Trials before fishing here."
		end
	},
	["Poseidon Pool"] = {
		Pool = {
			"Tire",
			"Boot",
			"Common Crate",
			"Seaweed",
			"Carbon Crate",
			"Quality Bait Crate",
			"Common Crate",
			"Bait Crate",
			"Colossal Carp",
			"Titan Tuna",
			"Giant Manta",
			"Leviathan Bass",
			"Massive Marlin",
			"Titanic Sturgeon",
			"Titanfang Grouper",
			"Deep Emperor",
			"Deep Behemoth",
			"Abyssal Goliath"
		},
		Priority = 1,
		CustomCondition = function(_, _, instance)
			if instance:FindFirstChild("Cache") and instance.Cache:FindFirstChild("Door.PoseidonPuzzleDoor") then
				return true
			end

			return false, "You must complete the Poseidon Trial before fishing here."
		end
	},
	["Sunken's Depth"] = {
		Pool = {
			"Tire",
			"Boot",
			"Common Crate",
			"Seaweed",
			"Carbon Crate",
			"Quality Bait Crate",
			"Common Crate",
			"Bait Crate",
			"Sunken Silverscale",
			"Atlantean Anchovy",
			"Oracle Minnow",
			"Poseidon's Perch",
			"Marble Maiden",
			"Crystal Chorus",
			"Helios Ray",
			"Philosopher's Fish",
			"Atlantean Guardian",
			"Triton's Herald",
			"Twilight Glowfish",
			"Atlantean Alchemist",
			"Deep Crownfish",
			"Celestial Koi"
		},
		Priority = 1,
		CustomCondition = function(_, _, instance)
			if instance:FindFirstChild("Cache") and instance.Cache:FindFirstChild("Door.SunkenDepthDoor") then
				return true
			end

			return false, "You must unlock the Sunken Depths before fishing here."
		end
	},
	["Ethereal Abyss"] = {
		Pool = {
			"Tire",
			"Boot",
			"Common Crate",
			"Seaweed",
			"Carbon Crate",
			"Quality Bait Crate",
			"Common Crate",
			"Bait Crate",
			"Column Crawler",
			"Atlantean Sardine",
			"Neptune's Nibbler",
			"Aqua Scribe",
			"Temple Drifter",
			"Mosaic Swimmer",
			"Echo Fisher",
			"Oracle's Eye",
			"Siren Singer",
			"Chronos Deep Swimmer",
			"Voidscale Guppy",
			"Starlit Weaver",
			"Mage Marlin",
			"King Jellyfish"
		},
		Priority = 1,
		CustomCondition = function(_, _, instance)
			if instance:FindFirstChild("Cache") and instance.Cache:FindFirstChild("Door.EtherealAbyssDoor") then
				return true
			end

			return false, "You must unlock the Ethereal Abyss before fishing here."
		end
	},
	["Kraken Pool"] = {
		Pool = {
			"Tire",
			"Boot",
			"Common Crate",
			"Seaweed",
			"Carbon Crate",
			"Quality Bait Crate",
			"Common Crate",
			"Bait Crate",
			"Shadowfang Snapper",
			"Tentacled Horror",
			"Tentacle Eel",
			"Deep One",
			"Eldritch Horror",
			"Kraken's Herald",
			"Abyssal King",
			"Void Emperor",
			"Abyssal Devourer"
		},
		Disturbs = "KrakenHunt",
		Priority = 1,
		CustomCondition = function(_, _, instance)
			if instance:FindFirstChild("Cache") and instance.Cache:FindFirstChild("Door.KrakenPuzzleDoor2") then
				return true
			end

			return false, "You must unlock the Kraken Pool before fishing here."
		end
	},
	["The Kraken Pool"] = {
		Pool = {
			"Tire",
			"Boot",
			"Common Crate",
			"Seaweed",
			"Carbon Crate",
			"Quality Bait Crate",
			"Common Crate",
			"Bait Crate",
			"Shadowfang Snapper",
			"Tentacled Horror",
			"Tentacle Eel",
			"Deep One",
			"Eldritch Horror",
			"Kraken's Herald",
			"Abyssal King",
			"Void Emperor",
			"Abyssal Devourer",
			"The Kraken"
		},
		CantBeWormholed = true,
		Priority = 1,
		IsHunt = true,
		CustomCondition = function(_, _, instance)
			if instance:FindFirstChild("Cache") and instance.Cache:FindFirstChild("Door.KrakenPuzzleDoor2") then
				return true
			end

			return false, "You must unlock the Kraken Pool before fishing here."
		end
	},
	["Ancient Kraken Pool"] = {
		Pool = {
			"Tire",
			"Boot",
			"Common Crate",
			"Seaweed",
			"Carbon Crate",
			"Quality Bait Crate",
			"Common Crate",
			"Bait Crate",
			"Shadowfang Snapper",
			"Tentacled Horror",
			"Tentacle Eel",
			"Deep One",
			"Eldritch Horror",
			"Kraken's Herald",
			"Abyssal King",
			"Void Emperor",
			"Abyssal Devourer",
			"Ancient Kraken"
		},
		CantBeWormholed = true,
		Priority = 1,
		IsHunt = true,
		CustomCondition = function(_, _, instance)
			if instance:FindFirstChild("Cache") and instance.Cache:FindFirstChild("Door.KrakenPuzzleDoor2") then
				return true
			end

			return false, "You must unlock the Kraken Pool before fishing here."
		end
	},
	["Shamrock Kraken Pool"] = {
		Pool = {
			"Tire",
			"Boot",
			"Common Crate",
			"Seaweed",
			"Carbon Crate",
			"Quality Bait Crate",
			"Common Crate",
			"Bait Crate",
			"Shadowfang Snapper",
			"Tentacled Horror",
			"Tentacle Eel",
			"Deep One",
			"Eldritch Horror",
			"Kraken's Herald",
			"Abyssal King",
			"Void Emperor",
			"Abyssal Devourer",
			"Shamrock Kraken"
		},
		CantBeWormholed = true,
		Priority = 1,
		IsHunt = true,
		CustomCondition = function(_, _, instance)
			if instance:FindFirstChild("Cache") and instance.Cache:FindFirstChild("Door.KrakenPuzzleDoor2") then
				return true
			end

			return false, "You must unlock the Kraken Pool before fishing here."
		end
	},
	["Volcanic Vents"] = {
		Pool = {
			"Inferno Hide",
			"Hellfire Haddock",
			"Embertail Eel",
			"Infernal Iguanafish",
			"Obsidian-Plated Piranha",
			"Smoldering Stingray",
			"Pyrite Pufferfish",
			"Molten Moray",
			"Charred Coelacanth",
			"Scalding Swordfish",
			"Blisterback Blenny",
			"Magma Leviathan"
		},
		CantBeWormholed = false,
		Priority = 3
	},
	["Challengers Deep"] = {
		Pool = {
			"Frozen Leviathan",
			"Frostscale Fangtooth",
			"Subzero Stargazer",
			"Chillshadow Chub",
			"Deep Freeze Devilfish",
			"Iceberg Isopod",
			"Polar Prowler",
			"Chillfin Chimaera",
			"Cryoskin",
			"Cryo Coelacanth",
			"Glacial Gulper",
			"Hoarfrost Halibut"
		},
		CantBeWormholed = false,
		Priority = 3
	},
	["Abyssal Zenith"] = {
		Pool = {
			"Titanic Black Seadevil",
			"Leviathan Humpback Anglerfish",
			"Abyssal Bearded Seadevil",
			"Colossal Saccopharynx",
			"Radiant Triplewart Seadevil",
			"Deeplight Footballfish",
			"Voidglow Ghostfish",
			"Infant Giant Seadevil",
			"Giant Seadevil",
			"Crowned Anglerfish",
			"Lumin-Lure Lanternfish",
			"Void-Drifter Jelly"
		},
		CantBeWormholed = false,
		Priority = 3
	},
	["Calm Zone"] = {
		Pool = {
			"Quartzfin Queenfish",
			"Pearl-Plated Pleco",
			"Diamond Discus",
			"Emerald Elephantnose",
			"Sapphire Stargazer",
			"Ruby Rasbora",
			"Prismatic Parrotfish",
			"Geode Grouper",
			"Crystal Corydoras",
			"Shimmering Silverside",
			"Crystallized Seadragon"
		},
		CantBeWormholed = false,
		Priority = 3
	},
	["Forsaken Veil"] = {
		Pool = {
			"Hydra Haddock",
			"Gargoyle Goby",
			"Serpent Surgeonfish",
			"Kraken Koi",
			"Gorgon Grouper",
			"Cyclone Scorpionfish",
			"Siren Sculpin",
			"Typhoon Tailfin",
			"Wraith-Whisper Ray",
			"Twilight Tentaclefish"
		},
		CantBeWormholed = false,
		Priority = 3,
		Disturbs = "ScyllaHunt",
		CustomCondition = function(_, _, instance)
			if instance:FindFirstChild("Cache") and instance.Cache:FindFirstChild("ScyllaBossfight") then
				return true
			end

			return false, "You must complete the Scylla bossfight to fish here."
		end
	},
	["Forsaken Veil - Scylla"] = {
		Pool = {
			"Hydra Haddock",
			"Gargoyle Goby",
			"Serpent Surgeonfish",
			"Kraken Koi",
			"Gorgon Grouper",
			"Cyclone Scorpionfish",
			"Siren Sculpin",
			"Typhoon Tailfin",
			"Wraith-Whisper Ray",
			"Twilight Tentaclefish",
			"Scylla"
		},
		CantBeWormholed = true,
		Priority = 4,
		IsHunt = true,
		CustomCondition = function(_, _, instance)
			if instance:FindFirstChild("Cache") and instance.Cache:FindFirstChild("ScyllaBossfight") then
				return true
			end

			return false, "You must complete the Scylla bossfight to fish here."
		end
	},
	["Forsaken Veil - Shamrock Scylla"] = {
		Pool = {
			"Hydra Haddock",
			"Gargoyle Goby",
			"Serpent Surgeonfish",
			"Kraken Koi",
			"Gorgon Grouper",
			"Cyclone Scorpionfish",
			"Siren Sculpin",
			"Typhoon Tailfin",
			"Wraith-Whisper Ray",
			"Twilight Tentaclefish",
			"Shamrock Scylla"
		},
		CantBeWormholed = true,
		Priority = 4,
		IsHunt = true,
		CustomCondition = function(_, _, instance)
			if instance:FindFirstChild("Cache") and instance.Cache:FindFirstChild("ScyllaBossfight") then
				return true
			end

			return false, "You must complete the Scylla bossfight to fish here."
		end
	},
	Waveborne = {
		Pool = {
			"Gale Snapper",
			"Drift Claw",
			"Tropical Bait Crate",
			"Foamrunner",
			"Sprayfin",
			"Ripple Spine",
			"Depth Lurker",
			"Surge Pike",
			"Abyss Dart",
			"Breaker Moth",
			"Tide Fang",
			"Wave Piercer",
			"Gust Tail",
			"Vortex Ray",
			"Storm Skipper"
		},
		CantBeWormholed = true,
		Priority = 2
	},
	["Pine Shoal"] = {
		Pool = {
			"Watching Glowfin",
			"Drifting Gildfin",
			"Blue Foamtail",
			"Tropical Bait Crate",
			"Redwood Duskray",
			"Oak Stripetail",
			"Pine Zephyrfish",
			"Parktail Spinesnapper",
			"Sunray Sunscale",
			"Thornfish"
		},
		CantBeWormholed = true,
		Priority = 2
	},
	Lushgrove = {
		Pool = {
			"Bogscale",
			"Murkdrifter",
			"Vinefish",
			"Canopy Tetra",
			"Tropical Bait Crate",
			"Hollow Snapper",
			"Fogstripe",
			"Temple Perch",
			"Relic Dart",
			"Echo Koi",
			"Glade Lurker",
			"Jungle Phantom",
			"Idolfish",
			"Primordial Levi"
		},
		CantBeWormholed = true,
		Priority = 2
	},
	Emberreach = {
		Pool = {
			"Ashscale Minnow",
			"Glowfin Skipper",
			"Moltenstripe",
			"Tropical Bait Crate",
			"Sunflare Tetra",
			"Furnace Leaper",
			"Smolderfang",
			"Volcanic Prowler",
			"Inferno Chaser",
			"Cinder Dart",
			"Scorchray",
			"Brimstone Angler",
			"Obsidian Koi"
		},
		CantBeWormholed = true,
		Priority = 2
	},
	["Emberreach Ponds"] = {
		Pool = {
			"Pyre Fang",
			"Firecrest",
			"Tropical Bait Crate",
			"Sulfur Snapper",
			"Smogfish",
			"Blazebelly",
			"Cragscale",
			"Tropicspike"
		},
		CantBeWormholed = true,
		Priority = 3
	},
	["Emberreach Lava"] = {
		Pool = {
			"Lava Bream",
			"Magma Pike",
			"Hellmaw Eel",
			"Searfin",
			"Basalt Pike",
			"Emberwing",
			"Molten Ripple"
		},
		CantBeWormholed = true,
		Priority = 3,
		RequiredDurability = 100
	},
	["Isle of New Beginnings"] = {
		Pool = {
			"Tidallow",
			"Reefdart",
			"Crestscale",
			"Tropical Bait Crate",
			"Horizon Tetra",
			"Driftfin",
			"Lantern Snapper",
			"Abyss Flicker",
			"Whisper Eel",
			"Phantom Koi",
			"Tartaruga"
		},
		CantBeWormholed = true,
		Priority = 2
	},
	["Cursed Isle"] = {
		Pool = {
			"Blisterfish",
			"Gloombiter",
			"Rotjaw",
			"Murkslither",
			"Tropical Bait Crate",
			"Split Eye Snapper",
			"Tumor Pike",
			"Hollowfin",
			"Crawling Angler",
			"Veinspawn",
			"Screaming Fluke",
			"Chasm Leech",
			"Dreaming Aberration",
			"Abyssborn Monstrosity"
		},
		CantBeWormholed = false,
		Priority = 2
	},
	["Open Ocean"] = {
		Pool = {
			"Cursed Thread",
			"Hogchoker",
			"Rock Gunnel",
			"Pupfish",
			"Four Eyes Fish",
			"Black Swallower",
			"Warty Angler",
			"Tropical Bait Crate",
			"Lumpclinger",
			"Snipefish",
			"Boarfish",
			"Telescopefish",
			"Fangtooth",
			"Velvet Belly Lanternshark",
			"Snakehead",
			"Sarcastic Fringehead",
			"Knifefish",
			"Tripod Fish",
			"Pelican Eel",
			"Bigfin Squid",
			"X-ray Tetra",
			"Psychedelic Frogfish",
			"Dogefin",
			"Toilet Fish",
			"Device Display"
		},
		CantBeWormholed = true,
		Priority = 0
	},
	["Azure Lagoon"] = {
		Pool = {
			"Murkfin",
			"Brackscale",
			"Lagoon Dart",
			"Tropical Bait Crate",
			"Glimmer Guppy",
			"Swampjaw",
			"Algae Lurker",
			"Reed Striker",
			"Azure Prowler",
			"Phantom Brine",
			"Bloomtail",
			"Depth Drifter",
			"Verdant Mirage"
		},
		CantBeWormholed = true,
		Priority = 2
	},
	["Blue Moon - First Sea"] = {
		Pool = {
			"Moon Arctic Char",
			"Silver Scuttler",
			"Pale Ghost Lumpfish",
			"Frost Ray",
			"Blue Langanose",
			"Starbellied Wolf Fish",
			"Icy Daggerfish",
			"Lunar Monkfish",
			"Moon Idol",
			"Moonveil Killifish",
			"Gloamfin Gar",
			"Lurking Crescent Pike",
			"Moonridge Catfish",
			"Crescent Madtom",
			"Bog Lantern Goby",
			"Tarnished Moongill"
		},
		Priority = 3,
		CantBeWormholed = false,
		CustomCondition = function(_, _)
			if ReplicatedStorage:GetAttribute("BlueMoonEvent") == true then
				return true
			end

			return false, "<font color=\"#D20103\">You can only fish here during a Blue Moon event.</font>"
		end
	},
	["Jurassic Island Pool"] = {
		ExclusiveRods = {
			AllowedRods = {
				"Developers Rod",
				"Mission Specialist's Rod",
				"Fixer's Rod",
				"Paleontologist's Rod"
			},
			ErrorMessage = "<font color=\"rgb(255,0,0)\">You must use a Jurassic World rod in this pool!</font>"
		},
		Pool = {
			"Gillicus",
			"Oreochima",
			"Diplomystus",
			"Giant Lamprey",
			"Edestus",
			"Jurassic Helicoprion",
			"Dasyatis",
			"Rhizodus"
		},
		Priority = 6,
		CantBeWormholed = true
	},
	["Jurassic Island Ocean Pool"] = {
		ExclusiveRods = {
			AllowedRods = {
				"Developers Rod",
				"Mission Specialist's Rod",
				"Fixer's Rod",
				"Paleontologist's Rod"
			},
			ErrorMessage = "<font color=\"rgb(255,0,0)\">You must use a Jurassic World rod in this pool!</font>"
		},
		Pool = {
			"Gillicus",
			"Oreochima",
			"Diplomystus",
			"Giant Lamprey",
			"Edestus",
			"Jurassic Helicoprion",
			"Dasyatis",
			"Rhizodus"
		},
		Priority = 5,
		CantBeWormholed = true
	},
	LEGO = {
		ExclusiveRods = {
			AllowedRods = { "Brick Built Rod", "Developers Rod" },
			ErrorMessage = "<font color=\"rgb(255,0,0)\">You must use the Brick Built Rod in this pool!</font>"
		},
		Pool = {
			"Tentabrick",
			"Studphin",
			"Studling Crab",
			"Stud Shark",
			"Stud Koi",
			"Jellystud",
			"Glow Brick",
			"Crab Stud",
			"Cardinal Studfish",
			"Brickhorse",
			"Stud Turtle",
			"Yellow Studfish",
			"Goldbrick",
			"Clown Brickfish",
			"Azure Studfish"
		},
		Priority = 5,
		CantBeWormholed = true
	},
	["LEGO - Studolodon"] = {
		ExclusiveRods = {
			AllowedRods = { "Brick Built Rod", "Developers Rod" },
			ErrorMessage = "<font color=\"rgb(255,0,0)\">You must use the Brick Built Rod in this pool!</font>"
		},
		Pool = {
			"Studolodon",
			"Tire",
			"Boot",
			"Common Crate",
			"Seaweed",
			"Carbon Crate",
			"Quality Bait Crate",
			"Common Crate",
			"Bait Crate",
			"Mackerel",
			"Cod",
			"Amberjack",
			"Sardine",
			"Halibut",
			"Salmon",
			"Mullet",
			"Bluefin Tuna",
			"Yellowfin Tuna",
			"Barracuda",
			"Sea Bass",
			"Chinook Salmon",
			"Sea Pickle",
			"Swordfish",
			"Anglerfish",
			"Coelacanth",
			"Sailfish",
			"Stingray",
			"Sawfish",
			"Moonfish",
			"Dolphin",
			"Flying Fish",
			"Colossal Squid",
			"Oarfish",
			"Crown Bass",
			"Mythic Fish",
			"Long Pike",
			"Mustard"
		},
		Priority = 5,
		CantBeWormholed = true
	},
	["Whale Interior"] = {
		Pool = {
			"Bearded Toadfish",
			"Giant Moray",
			"Gulf Toadfish",
			"Oyster toadfish",
			"Smooth toadfish",
			"Splendid toadfish"
		},
		CantBeWormholed = true,
		Priority = 2
	},
	["Treasure Island"] = {
		Pool = {
			"Bluegem Angelfish",
			"Coin Triggerfish",
			"Crowned Royal Gramma",
			"Emerald Angelfish",
			"Gemscale Mandarinfish",
			"Gemstone Whale Shark",
			"Goldband Butterflyfish",
			"Golden Dorado",
			"Goldfin Octopus",
			"Hidden Filefish",
			"Net Wolffish",
			"Queen Angelfish",
			"Ruby Lionfish",
			"Coin Piranha",
			"Coin Squid",
			"Gem Anchovy",
			"Gem Blobfish",
			"Gem Dolphin",
			"Gem Eel",
			"Gem Marlin",
			"Gem Salmon"
		},
		CantBeWormholed = false,
		Priority = 2
	},
	["Nectar Den"] = {
		Pool = {
			"Honey Drifter",
			"Stinger Skipper",
			"Comb Cluster",
			"Combscale Bass",
			"Honey Clump",
			"Bee"
		},
		Priority = 1,
		Disturbs = "NectarBloom",
		FishingStats = {
			Lure = -50
		}
	},
	["Nectar Den Roaming"] = {
		Pool = { "Bee" },
		Priority = 1,
		Disturbs = "NectarBloom",
		CantBeWormholed = true
	},
	["Nectar Den - Serpent"] = {
		Pool = {
			"Honey Drifter",
			"Stinger Skipper",
			"Comb Cluster",
			"Combscale Bass",
			"Honey Clump",
			"Bee",
			"Queen Bee Serpent"
		},
		Priority = 2,
		FishingStats = {
			Lure = -50
		}
	},
	["Living Garden"] = {
		Pool = {
			"Driftwood",
			"Petal Ray",
			"Garden Snail",
			"Oversized Leaf",
			"Colossal Flower",
			"Thorn Ribbon Eel",
			"Bloomback Turtle",
			"Flower Flounder",
			"Diamond Daisy",
			"Butterfly",
			"Orchid Anglerfish",
			"Leafscale Lemon Shark",
			"🦋"
		},
		Priority = 1,
		Disturbs = "FlowerGuardianHunt"
	},
	["Living Garden Roaming"] = {
		Pool = { "Butterfly" },
		CantBeWormholed = true,
		Priority = 1,
		Disturbs = "FlowerGuardianHunt"
	},
	["Toxic Grove"] = {
		Pool = {
			"Bone",
			"Spore Lurker",
			"Mire Krakenling",
			"Widow Bloom",
			"Rotcoil Eel",
			"Bog Skulker",
			"Chlorophage",
			"Toxic Jellymass",
			"Blight Idol"
		},
		Priority = 1,
		Disturbs = "RotbloomHunt",
		RequiredDurability = 150,
		RarityBaseChanceBoosts = {
			Common = 0.25
		}
	},
	["Basketback Tortoise Hunt"] = {
		Pool = {
			"Tire",
			"Boot",
			"Common Crate",
			"Bait Crate",
			"Fish Barrel",
			"Seaweed",
			"Mackerel",
			"Cod",
			"Amberjack",
			"Nurse Shark",
			"Porgy",
			"Sardine",
			"Halibut",
			"Mullet",
			"Salmon",
			"Yellowfin Tuna",
			"Sea Bass",
			"Chinook Salmon",
			"Haddock",
			"Barracuda",
			"Sea Pickle",
			"Pufferfish",
			"Swordfish",
			"Bluefin Tuna",
			"Sailfish",
			"Stingray",
			"Sawfish",
			"Moonfish",
			"Crown Bass",
			"Dolphin",
			"Flying Fish",
			"Mythic Fish",
			"Basketback Tortoise"
		},
		Priority = 100,
		IsHunt = true,
		CantBeWormholed = true
	},
	["Astral Observatory - Abyssal Zenith"] = {
		Pool = {
			"Hardened Glass",
			"Comb Jelly",
			"Riftia",
			"Hagfish",
			"Stabilizer Core"
		},
		CantBeWormholed = false,
		Priority = 3
	},
	["Boreal Hollow"] = {
		Pool = {
			"Starlit Seahorse",
			"Boreal Man o' War",
			"Celestial Crab",
			"Peacock Squid",
			"Nebulous Comb Jelly"
		},
		Disturbs = { "GoliathSiphonophoreHunt" },
		CantBeWormholed = false,
		Priority = 3
	},
	["Astral Observatory - Boreal Pines"] = {
		Pool = {
			"Starfall Glass",
			"Frozen Char",
			"Northern Pike",
			"Antarctic Whitefish",
			"Aurora Gar",
			"Unstable Crystal"
		},
		CantBeWormholed = false,
		Priority = 3
	},
	["Astral Observatory - Everturn Forest"] = {
		Pool = {
			"Seasonal Glass",
			"Sea Bunny",
			"Leopard Shark",
			"Cuttlefish",
			"Umbral Matrix"
		},
		CantBeWormholed = false,
		Priority = 3
	},
	["Astral Observatory - Northern Expedition"] = {
		Pool = {
			"Quartz Glass",
			"Phytoplankton",
			"Heleobia",
			"Golden Trout",
			"Singularity Control Unit"
		},
		CantBeWormholed = false,
		Priority = 3
	},
	["Astral Observatory - Snowcap Island"] = {
		Pool = {
			"Frozen Glass",
			"Moon Jellyfish",
			"Crescent Fish",
			"Brinicle",
			"Fairy Penguin",
			"Stellar Wiring"
		},
		CantBeWormholed = false,
		Priority = 3
	},
	Default = {
		Pool = {
			"Rock",
			"Log",
			"Seaweed",
			"Tire",
			"Boot"
		},
		CantBeWormholed = true,
		Priority = 2
	}
}