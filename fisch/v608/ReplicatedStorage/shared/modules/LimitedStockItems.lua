local ReplicatedStorage = game:GetService("ReplicatedStorage")
local OfficialCommerceProducts = require(ReplicatedStorage.shared.modules.OfficialCommerceProducts)
local LimitedStockItems = {
	Frostpiercer = {
		InitialStock = 15000
	},
	["Poseidon’s Wrath"] = {
		InitialStock = 15000
	},
	["Hollywave Cruiser"] = {
		InitialStock = 10000
	},
	["Celestial Cruiser"] = {
		InitialStock = 10000
	},
	["Depth Growler"] = {
		InitialStock = 15000
	},
	Hellbringer = {
		InitialStock = 15000
	},
	["Fishscale Waverider"] = {
		InitialStock = 10000
	},
	["Atlantean Jetski"] = {
		InitialStock = 15000
	},
	["Dionysus’s Chalice"] = {
		InitialStock = 15000
	},
	["Love Specter"] = {
		InitialStock = 8000
	},
	["Love Crasher"] = {
		InitialStock = 8000
	},
	["Volcanic Speedboat"] = {
		InitialStock = 5000
	},
	["Forgotten Doomspire"] = {
		InitialStock = 8000
	},
	["Skeletal Death"] = {
		InitialStock = 8000
	},
	["The Mawrider"] = {
		InitialStock = 5000
	},
	Slimebound = {
		InitialStock = 10000
	},
	["Toro Veloce"] = {
		InitialStock = 15000
	},
	["Fang of the Abyss"] = {
		InitialStock = 15000
	},
	["Banana Rod"] = {
		InitialStock = 5000
	},
	["Lucky Racer"] = {
		InitialStock = 15000
	},
	["Seraphic Rainbow"] = {
		InitialStock = 5000
	},
	["Arcane Elegance"] = {
		InitialStock = 8000
	},
	["Curse III"] = {
		InitialStock = 10000
	},
	["Rainbow Revolution"] = {
		InitialStock = 25000
	},
	["Cyanic Demonride"] = {
		InitialStock = 7500
	},
	["Lion's Fury"] = {
		InitialStock = 15000
	},
	["Silverback Dreamer"] = {
		InitialStock = 15000
	},
	["Celestial Prismheart"] = {
		InitialStock = 8000
	},
	["Eternal Shears"] = {
		InitialStock = 12000
	},
	["Desolate Dragon"] = {
		InitialStock = 25000
	},
	Dumbo = {
		InitialStock = 25000
	},
	["Emerald Lagoon"] = {
		InitialStock = 20000
	},
	["Victors Grace"] = {
		InitialStock = 10000
	},
	Puffernaut = {
		InitialStock = 20000
	},
	["Banana of the Depths"] = {
		InitialStock = 15000,
		Disabled = true
	},
	["Galactic Tentacles"] = {
		InitialStock = 15000,
		Disabled = true
	},
	["Pineapple Play"] = {
		InitialStock = 5000,
		Disabled = true
	},
	["Silent Speeder"] = {
		InitialStock = 20000,
		Disabled = true
	},
	["Orange Unicycle"] = {
		InitialStock = 20000
	},
	["Tri-Brick Rider"] = {
		InitialStock = 40000,
		Disabled = true
	},
	["Obsidian Key"] = {
		InitialStock = 5000,
		Disabled = true
	},
	["Shiny Nessie"] = {
		InitialStock = 5000,
		Disabled = true
	},
	["Lunar Prism"] = {
		InitialStock = 5000,
		Disabled = true
	},
	["Starry Tempest"] = {
		InitialStock = 10000,
		Disabled = true
	},
	["Rainbow Spirit"] = {
		InitialStock = 12000,
		Disabled = true
	},
	Hoverslime = {
		InitialStock = 20000,
		Disabled = true
	},
	["Popsicle Jetski"] = {
		InitialStock = 2500,
		Disabled = true
	},
	Stellarweaver = {
		InitialStock = 1500,
		Disabled = true
	},
	["Elysian Jolt"] = {
		InitialStock = 1200,
		Disabled = true
	},
	["Wings of Ruin"] = {
		InitialStock = 1250,
		Disabled = true
	},
	["Curse IV"] = {
		InitialStock = 1000,
		Disabled = true
	},
	["Grandmaster Key"] = {
		InitialStock = 1250,
		Disabled = true
	},
	["Kraken of the Void"] = {
		InitialStock = 1500,
		Disabled = true
	},
	["Black Comet"] = {
		InitialStock = 1250,
		Disabled = true
	},
	Blightwing = {
		InitialStock = 1250,
		Disabled = true
	},
	Demonwake = {
		InitialStock = 1500,
		Disabled = true
	},
	["Pond Splasher"] = {
		InitialStock = 1500,
		Disabled = true
	},
	Nocturne = {
		InitialStock = 1250,
		Disabled = true
	},
	["Aurelia's Grace"] = {
		InitialStock = 1250,
		Disabled = true
	},
	Evangeline = {
		InitialStock = 1500,
		Disabled = true
	},
	["Raijin's Wrath"] = {
		InitialStock = 1500,
		Disabled = true
	},
	Dreadmarrow = {
		InitialStock = 1650,
		Disabled = true
	},
	Dreamline = {
		InitialStock = 1500,
		Disabled = true
	},
	["Pastel Impulse"] = {
		InitialStock = 1500,
		Disabled = true
	},
	["Fuchsia Fidelity"] = {
		InitialStock = 1500,
		Disabled = true
	},
	["Violet Viper"] = {
		InitialStock = 2000,
		Disabled = true
	},
	Scarwing = {
		InitialStock = 2250,
		Disabled = true
	},
	Pantheress = {
		InitialStock = 5000,
		Disabled = true
	},
	["The Reaper"] = {
		InitialStock = 5000,
		Disabled = true
	},
	Novaris = {
		InitialStock = 7500,
		Disabled = true
	},
	["Raven's Hush"] = {
		InitialStock = 5500,
		Disabled = true
	},
	["Mecha Ray"] = {
		InitialStock = 15000,
		Disabled = true
	},
	["Celestial Cadence"] = {
		InitialStock = 12500,
		Disabled = true
	},
	["Macabre Mistress"] = {
		InitialStock = 15000,
		Disabled = true
	},
	["Somber Oath"] = {
		InitialStock = 12500,
		Disabled = true
	},
	["Widow's Veil"] = {
		InitialStock = 12500,
		Disabled = true
	},
	["Soulful Omen"] = {
		InitialStock = 12500,
		Disabled = true
	},
	Gravedigger = {
		InitialStock = 12000,
		Disabled = true
	},
	["Witchy Ember"] = {
		InitialStock = 13500,
		Disabled = true
	},
	Nemesis = {
		InitialStock = 11000,
		Disabled = true
	},
	Runeflare = {
		InitialStock = 17500,
		Disabled = true
	},
	Riptide = {
		InitialStock = 7500,
		Disabled = true
	},
	["Meowtastic Tower"] = {
		InitialStock = 10000,
		Disabled = true
	},
	Ivorous = {
		InitialStock = 10000,
		Disabled = true
	},
	["Crypted Ivory"] = {
		InitialStock = 17500,
		Disabled = true
	},
	Scorpferno = {
		InitialStock = 10000,
		Disabled = true
	},
	["Sanzu's Embrace"] = {
		InitialStock = 12500,
		Disabled = true
	},
	Corruptor = {
		InitialStock = 9000,
		Disabled = true
	},
	["Umbral Vengeance"] = {
		InitialStock = 12500,
		Disabled = true
	},
	["Gleeb 9000"] = {
		InitialStock = 6300,
		Disabled = true
	},
	["Heavyblade of Glory"] = {
		InitialStock = 8700,
		Disabled = true
	},
	Frostbite = {
		InitialStock = 7000,
		Disabled = true
	},
	Evergreene = {
		InitialStock = 7500,
		Disabled = true
	},
	["Krampus Curse"] = {
		InitialStock = 15000,
		Disabled = true
	},
	["Sickle of Krampus"] = {
		InitialStock = 15000,
		Disabled = true
	},
	Nullprawn = {
		InitialStock = 7500
	},
	Icedolon = {
		InitialStock = 9000,
		Disabled = true
	},
	["Timeless Steel"] = {
		InitialStock = 5000,
		Disabled = true
	},
	["Gothic Archer"] = {
		InitialStock = 10000,
		Disabled = true
	},
	["Thief of Time"] = {
		InitialStock = 7000,
		Disabled = true
	},
	["Stygian Winter"] = {
		InitialStock = 11000,
		Disabled = true
	},
	Razorella = {
		InitialStock = 10000,
		Disabled = true
	},
	["Phantom Pawster"] = {
		InitialStock = 8000,
		Disabled = true
	},
	["Purr of Rebellion"] = {
		InitialStock = 10000,
		Disabled = true
	},
	["Decadent Cutlass"] = {
		InitialStock = 9000,
		Disabled = true
	},
	["S'more Speedster"] = {
		InitialStock = 7000,
		Disabled = true
	},
	Arachne = {
		InitialStock = 8888,
		Disabled = true
	},
	["Imperial Mauve"] = {
		InitialStock = 7000,
		Disabled = true
	},
	Coquette = {
		InitialStock = 10000,
		Disabled = true
	},
	["Cupid's Cut"] = {
		InitialStock = 13000,
		Disabled = true
	},
	Arteria = {
		InitialStock = 7000,
		Disabled = true
	},
	["Sweetheart Scissors"] = {
		InitialStock = 10000,
		Disabled = true
	},
	Starliner = {
		InitialStock = 6000,
		Disabled = true
	},
	Starcrusher = {
		InitialStock = 8000,
		Disabled = true
	},
	["Lily of Glacia"] = {
		InitialStock = 6000,
		Disabled = true
	},
	["Bloom of Delicacy"] = {
		InitialStock = 7500,
		Disabled = true
	},
	["Frutiger Tunes"] = {
		InitialStock = 10000,
		Disabled = true
	},
	["Shadowfell's Reckoning"] = {
		InitialStock = 14000,
		Disabled = true
	},
	Iridescence = {
		InitialStock = 7000,
		Disabled = true
	},
	Malevolence = {
		InitialStock = 8000,
		Disabled = true
	},
	Bunvoyage = {
		InitialStock = 5000,
		Disabled = true
	},
	["Cobalt Crusader"] = {
		InitialStock = 6000,
		Disabled = true
	},
	Sunfyre = {
		InitialStock = 5000,
		Disabled = true
	},
	["Radiant Executioner"] = {
		InitialStock = 7000,
		Disabled = true
	},
	Jettling = {
		InitialStock = 5000,
		Disabled = true
	},
	Bunblade = {
		InitialStock = 8000,
		Disabled = true
	},
	Spiritflutter = {
		InitialStock = 8000,
		Disabled = true
	},
	Melodii = {
		InitialStock = 10000,
		Disabled = true
	},
	Velocitide = {
		InitialStock = 4000,
		Disabled = true
	},
	["Bubbly Benediction"] = {
		InitialStock = 7000,
		Disabled = true
	},
	["Phoenix Skate"] = {
		InitialStock = 3000,
		Disabled = true
	},
	["Dutchman's Penance"] = {
		InitialStock = 7500,
		Disabled = true
	},
	Diablo = {
		InitialStock = 3000,
		Disabled = true
	},
	["Pyre of Mercy"] = {
		InitialStock = 8000,
		Disabled = true
	},
	Mechanexus = {
		InitialStock = 3000,
		Disabled = true
	},
	Echolocator = {
		InitialStock = 8000,
		Disabled = true
	},
	["Jet of the Exalted"] = {
		InitialStock = 5500,
		Disabled = true
	},
	Seastrum = {
		InitialStock = 10500,
		Disabled = true
	},
	["Summer Gary"] = {
		InitialStock = 10000
	},
	Nightfaller = {
		InitialStock = 6500,
		Disabled = true
	},
	Celestiana = {
		InitialStock = 10000,
		Disabled = true
	},
	Zephyrmantis = {
		InitialStock = 7000,
		Disabled = true
	},
	CritSlasher = {
		InitialStock = 10000,
		Disabled = true
	},
	Wavestrummer = {
		InitialStock = 6000,
		Disabled = true
	},
	["Platinum Menace"] = {
		InitialStock = 10500,
		Disabled = true
	},
	Shinigami = {
		InitialStock = 6000,
		Disabled = true
	},
	["Final Census"] = {
		InitialStock = 10000,
		Disabled = true
	},
	Vitalica = {
		InitialStock = 15000,
		Disabled = true
	},
	Kaboom = {
		InitialStock = 25000,
		Disabled = true
	},
	["Baby Atlanti"] = {
		InitialStock = 10000,
		Disabled = true
	},
	Botanica = {
		InitialStock = 8000,
		Disabled = true
	},
	Archangelite = {
		InitialStock = 18500,
		Disabled = true
	},
	Nevermore = {
		InitialStock = 6000,
		Disabled = true
	},
	Poltergeist = {
		InitialStock = 18000,
		Disabled = true
	},
	Raingokart = {
		InitialStock = 7000,
		Disabled = true
	},
	RoboChomp = {
		InitialStock = 13000,
		Disabled = true
	},
	["Jelly Sharkling"] = {
		InitialStock = 10000,
		Disabled = true
	},
	Transcendence = {
		InitialStock = 5000,
		Disabled = true
	},
	["Martyr's Battleaxe"] = {
		InitialStock = 12000,
		Disabled = true
	},
	Draconica = {
		InitialStock = 5000,
		Disabled = true
	},
	["Infrared Tunes"] = {
		InitialStock = 11000,
		Disabled = true
	},
	Astropod = {
		InitialStock = 7000,
		Disabled = true
	},
	Amouria = {
		InitialStock = 14000,
		Disabled = true
	},
	Onyxum = {
		InitialStock = 7000,
		Disabled = true
	},
	["Mango Tango"] = {
		InitialStock = 13000,
		Disabled = true
	},
	Koutetsu = {
		InitialStock = 8000,
		Disabled = true
	},
	["Brutal Redemption"] = {
		InitialStock = 12500,
		Disabled = true
	},
	Xanthos = {
		InitialStock = 7000,
		Disabled = true
	},
	["Crest of Galactica"] = {
		InitialStock = 12500,
		Disabled = true
	},
	Infrarana = {
		InitialStock = 7000,
		Disabled = true
	},
	["Party Puffer"] = {
		InitialStock = 13000,
		Disabled = true
	},
	Dragonico = {
		InitialStock = 10000,
		Disabled = true
	},
	["Winged Royalty"] = {
		InitialStock = 6000,
		Disabled = true
	},
	AntiMatter = {
		InitialStock = 14000,
		Disabled = true
	},
	["Guardian Angel"] = {
		InitialStock = 8000,
		Disabled = true
	},
	["Stars Highways"] = {
		InitialStock = 18000,
		Disabled = true
	},
	["Plushy Duomo"] = {
		InitialStock = 4000,
		Disabled = true
	},
	Petrichor = {
		InitialStock = 15000,
		Disabled = true
	},
	["Coco Capy"] = {
		InitialStock = 7000
	},
	["KR ROAR"] = {
		InitialStock = 4000
	},
	Caelinfernum = {
		InitialStock = 17000
	}
}

for _, officialCommerceProduct in OfficialCommerceProducts do
	if officialCommerceProduct.Disabled or not officialCommerceProduct.LimitedStockKey or not officialCommerceProduct.LimitedStockAmount then
		continue
	end

	LimitedStockItems[officialCommerceProduct.LimitedStockKey] = {
		InitialStock = officialCommerceProduct.LimitedStockAmount
	}
end

return LimitedStockItems