local entries = {
	AxeOfRhoads = {
		Id = "AxeOfRhoads",
		DisplayName = "Noctone",
		Rod = "Noctone",
		Icon = "rbxassetid://86080334936308",
		IconColor = Color3.fromRGB(255, 255, 255),
		Quests = { "AxeOfRhoads1", "AxeOfRhoads2", "AxeOfRhoads3" },
		EchoNpc = "Fayelie",
		OriginEvent = "Underground Music Venue",
		WorldDeps = { "NpcOnly" },
		Mode = "Echo",
		Feasible = true
	},
	Chrysalis = {
		Id = "Chrysalis",
		DisplayName = "Chrysalis",
		Rod = "Chrysalis",
		Icon = "rbxassetid://104890116657151",
		IconColor = Color3.fromRGB(240, 164, 255),
		Quests = { "Chrysalis1", "Chrysalis2", "Chrysalis3" },
		EchoNpc = "Hex",
		OriginEvent = "Underground Music Venue",
		WorldDeps = { "NpcOnly" },
		Mode = "Echo",
		Feasible = true
	},
	Cinderstring = {
		Id = "Cinderstring",
		DisplayName = "Cinderstring",
		Rod = "Cinderstring",
		Icon = "rbxassetid://92198090110083",
		IconColor = Color3.fromRGB(255, 85, 0),
		Quests = { "Cinderstring1", "Cinderstring2", "Cinderstring3" },
		EchoNpc = "Rick",
		OriginEvent = "Underground Music Venue",
		WorldDeps = { "NpcOnly" },
		Mode = "Echo",
		Feasible = true
	},
	Eardrum = {
		Id = "Eardrum",
		DisplayName = "Eardrum",
		Rod = "Eardrum",
		Icon = "rbxassetid://90514644330726",
		IconColor = Color3.fromRGB(152, 115, 90),
		Quests = { "Eardrum1", "Eardrum2", "Eardrum3" },
		EchoNpc = "Holladay",
		OriginEvent = "Underground Music Venue",
		WorldDeps = { "NpcOnly" },
		Mode = "Echo",
		Feasible = true
	},
	PolarisSerenade = {
		Id = "PolarisSerenade",
		DisplayName = "Polaris Serenade",
		Rod = "Polaris Serenade",
		Icon = "rbxassetid://85076538937599",
		IconColor = Color3.fromRGB(45, 206, 255),
		Quests = { "PolarisSerenade1", "PolarisSerenade2", "PolarisSerenade3" },
		EchoNpc = "NickPolaris",
		OriginEvent = "Underground Music Venue",
		WorldDeps = { "NpcOnly" },
		Mode = "Echo",
		Feasible = true
	},
	TestRod = {
		Id = "TestRod",
		DisplayName = "Test Rod",
		Rod = "Test Rod",
		Icon = "rbxassetid://115679557871754",
		IconColor = Color3.fromRGB(251, 255, 0),
		Quests = { "LightningFish" },
		EchoNpc = "Buildaroo",
		OriginEvent = "Underground Music Venue",
		WorldDeps = { "NpcOnly" },
		Mode = "Echo",
		Feasible = true
	},
	Wingripper = {
		Id = "Wingripper",
		DisplayName = "Wingripper",
		Rod = "Wingripper",
		Icon = "rbxassetid://131957160459539",
		IconColor = Color3.fromRGB(60, 60, 60),
		Quests = { "Wingripper1", "Wingripper2", "Wingripper3" },
		EchoNpc = "Goth",
		OriginEvent = "Underground Music Venue",
		WorldDeps = { "NpcOnly" },
		Mode = "Echo",
		Feasible = true
	},
	MiguRod = {
		Id = "MiguRod",
		DisplayName = "MiguRod",
		Rod = "MiguRod",
		Icon = "rbxassetid://119449004351627",
		IconColor = Color3.fromRGB(255, 43, 71),
		Quests = {},
		EchoNpc = "Migura",
		OriginEvent = "Underground Music Venue",
		WorldDeps = { "SecretHandler", "WorldObjects" },
		Mode = "Restore",
		Hint = {
			"This one is not mine to hand over. It was never a wish, it was a joke that got out of hand.",
			"Go down beneath the music venue. Three of them are still down there arguing, and one of them is lying to you.",
			"Bring the fish they ask for. You will need to be strong enough that they bother finishing a sentence."
		},
		Feasible = true
	},
	Acidgrinder = {
		Id = "Acidgrinder",
		DisplayName = "Acidgrinder",
		Rod = "Acidgrinder",
		Icon = "rbxassetid://0",
		IconColor = Color3.fromRGB(140, 255, 50),
		Quests = {
			"Axel1",
			"Axel2",
			"Axel3",
			"Axel4"
		},
		EchoNpc = "Axel",
		OriginEvent = "Venue Takeover",
		WorldDeps = { "NpcOnly", "ZoneContent" },
		Mode = "Echo",
		Feasible = true
	},
	Castbound = {
		Id = "Castbound",
		DisplayName = "Castbound",
		Rod = "Castbound",
		Icon = "rbxassetid://101267106505092",
		IconColor = Color3.fromRGB(207, 255, 94),
		Quests = { "TheGuide_GettingStarted", "TheGuide_Shimmer", "TheGuide_Final" },
		EchoNpc = "The Guide",
		OriginEvent = "Venue Takeover",
		WorldDeps = { "NpcOnly" },
		Mode = "Echo",
		Feasible = true
	},
	Part = {
		Id = "Part",
		DisplayName = "Part",
		Rod = "Part",
		Icon = "rbxassetid://72444096547318",
		IconColor = Color3.fromRGB(195, 195, 195),
		Quests = { "BasePart1", "BasePart2", "BasePart3" },
		EchoNpc = "BasePart",
		OriginEvent = "Venue Takeover",
		WorldDeps = { "SecretHandler", "WorldObjects" },
		Mode = "Echo",
		Feasible = true
	},
	Remembrance = {
		Id = "Remembrance",
		DisplayName = "Remembrance",
		Rod = "Remembrance",
		Icon = "rbxassetid://102878317629151",
		IconColor = Color3.fromRGB(255, 255, 255),
		Quests = { "Remembrance1", "Remembrance2" },
		EchoNpc = "Luneth",
		OriginEvent = "Venue Takeover",
		WorldDeps = { "SecretHandler", "ZoneContent" },
		Mode = "Echo",
		Feasible = true
	},
	Soulreaper = {
		Id = "Soulreaper",
		DisplayName = "SOULREAPER",
		Rod = "SOULREAPER",
		Icon = "rbxassetid://0",
		IconColor = Color3.fromRGB(120, 80, 180),
		Quests = {
			"Soulreaper1",
			"Soulreaper2",
			"Soulreaper3",
			"Soulreaper4",
			"Soulreaper5",
			"Soulreaper6"
		},
		EchoNpc = "Reaper",
		OriginEvent = "Venue Takeover",
		WorldDeps = { "NpcOnly", "WorldObjects" },
		Mode = "Echo",
		Props = { "SoulreaperGhosts" },
		Feasible = true
	},
	SteampunkRod = {
		Id = "SteampunkRod",
		DisplayName = "Steampunk Rod",
		Rod = "Steampunk Rod",
		Icon = "rbxassetid://77215890862281",
		IconColor = Color3.fromRGB(220, 160, 60),
		Quests = { "RivetRod1", "RivetRod2", "RivetRod3" },
		EchoNpc = "Rivet",
		OriginEvent = "Venue Takeover",
		WorldDeps = { "NpcOnly" },
		Mode = "Echo",
		Feasible = true
	},
	Wingkeeper = {
		Id = "Wingkeeper",
		DisplayName = "Wingkeeper",
		Rod = "Wingkeeper",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(255, 248, 200),
		Quests = {
			"Wingkeeper1",
			"Wingkeeper2",
			"Wingkeeper3",
			"Wingkeeper4"
		},
		EchoNpc = "Seraphel",
		OriginEvent = "Venue Takeover",
		WorldDeps = { "NpcOnly" },
		Mode = "Echo",
		Feasible = true
	},
	AstraeusSerenade = {
		Id = "AstraeusSerenade",
		DisplayName = "Astraeus Serenade",
		Rod = "Astraeus Serenade",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(255, 140, 0),
		Quests = {
			"Astraeus1_Emberpile",
			"Astraeus2_MoonWood",
			"Astraeus3_Serenade",
			"Astraeus4_Offering"
		},
		EchoNpc = "Astraeus",
		EchoNpcType = "AstraeusHerald",
		EchoNpcTypes = {
			Astraeus4_Offering = "Astraeus"
		},
		OriginEvent = "Astraeus' Wish",
		WorldDeps = { "SecretHandler", "WorldObjects" },
		Mode = "Echo",
		Feasible = true
	},
	FallenSnowblade = {
		Id = "FallenSnowblade",
		DisplayName = "Fallen Snowblade",
		Rod = "Fallen Snowblade",
		Icon = "rbxassetid://139914327883023",
		IconColor = Color3.fromRGB(217, 240, 255),
		Quests = { "Snowblade1", "Snowblade2", "Snowblade3" },
		EchoNpc = "Sno",
		OriginEvent = "Snowcap Island / Shamrock Seas",
		WorldDeps = { "NpcOnly" },
		Mode = "Echo",
		Feasible = true
	},
	Noiseform = {
		Id = "Noiseform",
		DisplayName = "Noiseform",
		Rod = "Noiseform",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(0, 255, 60),
		Quests = {
			"Noiseform1",
			"Noiseform2",
			"Noiseform3",
			"Noiseform4",
			"Noiseform5"
		},
		EchoNpc = "Mysterious Shadow",
		EchoNpcType = "Noiseform",
		EchoNpcTypes = {
			Noiseform4 = "NoiseformWitch"
		},
		OriginEvent = "Mysterious Shadow",
		WorldDeps = { "SecretHandler", "WorldObjects" },
		Mode = "Echo",
		Feasible = true
	},
	SillyFunHappyRod = {
		Id = "SillyFunHappyRod",
		DisplayName = "Silly Fun Happy Rod",
		Rod = "Silly Fun Happy Rod",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(221, 210, 0),
		Quests = { "ClownQuest1", "ClownQuest2" },
		EchoNpc = "Silly Clown",
		OriginEvent = "Silly Clown",
		WorldDeps = { "WorldObjects" },
		Mode = "Echo",
		Props = { "BalloonAnimals" },
		Feasible = true
	},
	Lullaby = {
		Id = "Lullaby",
		DisplayName = "Lullaby",
		Rod = "Lullaby",
		Icon = "rbxassetid://70822794044383",
		IconColor = Color3.fromRGB(255, 34, 133),
		Quests = {
			"Lullaby1",
			"Lullaby2",
			"Lullaby3",
			"Lullaby4_1",
			"Lullaby4_2",
			"Lullaby5_1",
			"Lullaby5_2",
			"Lullaby6_1",
			"Lullaby6_2",
			"Lullaby7_1",
			"Lullaby7_2",
			"Lullaby8",
			"Lullaby_Quickening",
			"Lullaby_Strengthening",
			"Lullaby_Fortuitous",
			"Lullaby_Prismatic"
		},
		ChainStop = "Lullaby8",
		EchoNpc = "Simon",
		OriginEvent = "Venue Takeover",
		WorldDeps = {
			"NpcOnly",
			"WorldObjects",
			"SecretHandler",
			"ZoneContent"
		},
		Mode = "Restore",
		Hint = {
			"This one ends a long way from here, and I cannot carry it that far.",
			"There is water near the venue that leads somewhere it should not. Go through it.",
			"Simon is on the other side. He remembers exactly where you stopped."
		},
		Feasible = true
	}
}
local WishCatalog = {}
WishCatalog.Entries = entries

function WishCatalog.Get(p: string)
	return entries[p]
end

function WishCatalog.IsComingSoon(p)
	return p.ComingSoonAt ~= nil and os.time() < p.ComingSoonAt
end

function WishCatalog.FindByQuestId(p: string)
	for _, v2 in entries do
		if table.find(v2.Quests, p) then
			return v2
		end
	end

	return nil
end

function WishCatalog.FindByRod(p: string)
	for _, v2 in entries do
		if v2.Rod == p then
			return v2
		end
	end

	return nil
end

function WishCatalog.AllQuestIds()
	local result = {}

	for k, v2 in entries do
		for _, quest in v2.Quests do
			result[quest] = k
		end
	end

	return result
end

return WishCatalog