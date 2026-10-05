local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)(game.ReplicatedStorage.ServerInfo).isDevPlaceGame()
return {
	Height_Fight = {
		Image = "rbxassetid://17316961495",
		HoverImage = "rbxassetid://17316963053",
		DisplayName = "Height Fight",
		RankedImage = "rbxassetid://17316961920",
		Thumbnail = "rbxassetid://17316961920",
		RankedMap = true,
		Tix = true
	},
	Arena = {
		Image = "rbxassetid://15122127147",
		HoverImage = "rbxassetid://15122126711",
		DisplayName = "Arena",
		RankedImage = "rbxassetid://15874170676",
		Thumbnail = "rbxassetid://15874170676",
		RankedMap = false,
		Tix = true
	},
	RingOfFire = {
		Image = "rbxassetid://15122132021",
		HoverImage = "rbxassetid://15122131610",
		DisplayName = "Ring Of Fire",
		RankedImage = "rbxassetid://15874168591",
		Thumbnail = "rbxassetid://15874168591",
		RankedMap = true
	},
	Olympus = {
		Image = "rbxassetid://15122465790",
		HoverImage = "rbxassetid://15122465534",
		DisplayName = "Olympus",
		RankedImage = "rbxassetid://15874168767",
		Thumbnail = "rbxassetid://15874168767",
		RankedMap = true,
		Tix = true
	},
	Desert = {
		Image = "rbxassetid://15122129270",
		HoverImage = "rbxassetid://15122129068",
		DisplayName = "Desert",
		RankedImage = "rbxassetid://15874169885",
		Thumbnail = "rbxassetid://15874169885",
		RankedMap = true
	},
	Grassy_Classic = {
		Image = "rbxassetid://15122129728",
		HoverImage = "rbxassetid://15122129483",
		DisplayName = "Grassy Classic",
		RankedImage = "rbxassetid://15874169605",
		RankedMap = true
	},
	Classic = {
		Image = "rbxassetid://15122128274",
		HoverImage = "rbxassetid://15122128067",
		DisplayName = "Classic",
		RankedImage = "rbxassetid://15874170417",
		Thumbnail = "rbxassetid://15874170417",
		RankedMap = true
	},
	Enchanted_Desert = {
		Image = "rbxassetid://15384830711",
		HoverImage = "rbxassetid://15384830021",
		DisplayName = "Enchanted Desert",
		Thumbnail = "rbxassetid://16559970719",
		Tix = true
	},
	Classic_V2 = {
		Image = "rbxassetid://15122128747",
		HoverImage = "rbxassetid://15122128523",
		DisplayName = "Classic V2",
		RankedImage = "rbxassetid://15874170144",
		Thumbnail = "rbxassetid://16559971260",
		RankedMap = true
	},
	["Beach Map"] = {
		Image = "rbxassetid://109787332265688",
		HoverImage = "rbxassetid://79051223467156",
		DisplayName = "Beach Map",
		RankedImage = "rbxassetid://103441068391730",
		Thumbnail = "rbxassetid://120800144371244",
		RankedMap = true
	},
	["Shipreck Map"] = {
		Image = "rbxassetid://134906176692861",
		HoverImage = "rbxassetid://135736415626208",
		DisplayName = "Shipreck Map",
		RankedImage = "rbxassetid://98604352837710",
		Thumbnail = "rbxassetid://70712564437088",
		RankedMap = false
	},
	Halloween_Graveyard = {
		Image = "rbxassetid://15122130764",
		HoverImage = "rbxassetid://15122130539",
		DisplayName = "Graveyard",
		DisabledInTraining = true
	},
	Halloween_Colloseum = {
		Image = "rbxassetid://15122130326",
		HoverImage = "rbxassetid://15122130029",
		DisplayName = "Colloseum",
		DisabledInTraining = true
	},
	RBBattles = {
		Image = "",
		HoverImage = "",
		DisplayName = "RB Battles Arena",
		MinHeightOffset = 2.5,
		DisabledInTraining = true
	},
	Underworld = {
		Image = "rbxassetid://15246719141",
		HoverImage = "rbxassetid://15246730284",
		DisplayName = "Underworld",
		Thumbnail = "rbxassetid://16559969404",
		Tix = true
	},
	Ocean = {
		Image = "rbxassetid://15246674490",
		HoverImage = "rbxassetid://15246710974",
		DisplayName = "Ocean",
		RankedImage = "rbxassetid://15874168988",
		Thumbnail = "rbxassetid://15874168988",
		RankedMap = true,
		Tix = true
	},
	Jungle = {
		Image = "rbxassetid://17316936059",
		HoverImage = "rbxassetid://17316943219",
		DisplayName = "Jungle",
		Thumbnail = "rbxassetid://17316938284"
	},
	Heaven = {
		Image = "rbxassetid://15384828790",
		HoverImage = "rbxassetid://15384828387",
		DisplayName = "Heaven",
		RankedImage = "rbxassetid://15874169362",
		Thumbnail = "rbxassetid://15874169362",
		RankedMap = true
	},
	TrainingMode = {
		Image = "rbxassetid://15467112488",
		HoverImage = "rbxassetid://15467080348",
		DisplayName = "Training Mode"
	},
	TimesSquare = {
		Image = "rbxassetid://15875224627",
		HoverImage = "rbxassetid://15875224835",
		DisplayName = "Times Square",
		Thumbnail = "rbxassetid://16560393121",
		Tix = true
	},
	EnchantedForest = {
		Image = "rbxassetid://15998452562",
		HoverImage = "rbxassetid://15998454367",
		DisplayName = "Enchanted Forest",
		Thumbnail = "rbxassetid://16560393321",
		Tix = true
	},
	MoonMap = {
		Image = "rbxassetid://16138346803",
		HoverImage = "rbxassetid://16138348985",
		DisplayName = "Moon Map",
		Thumbnail = "rbxassetid://16559970274",
		Tix = true
	},
	AncientWaypoint = {
		DisplayName = "Ancient Map",
		Thumbnail = "rbxassetid://17095726485",
		Image = "rbxassetid://17095726335",
		HoverImage = "rbxassetid://17095726195",
		Tix = true
	},
	SciFiStadium = {
		Image = "rbxassetid://17442373598",
		HoverImage = "rbxassetid://17442373439",
		DisplayName = "Sci-Fi Stadium",
		Thumbnail = "rbxassetid://17442373791",
		DisabledInTraining = true
	},
	KrakenIsland = {
		Image = "rbxassetid://18260441031",
		HoverImage = "rbxassetid://18260440665",
		DisplayName = "Kraken Island",
		Thumbnail = "rbxassetid://18260441447"
	},
	BirdCage = {
		Image = "rbxassetid://17860747694",
		HoverImage = "rbxassetid://17860748032",
		DisplayName = "Bird Cage",
		Thumbnail = "rbxassetid://17860747419",
		ReleaseDate = DateTime.fromUniversalTime(2024, 7, 1).UnixTimestamp
	},
	Atlantis = {
		Image = "rbxassetid://18579954932",
		HoverImage = "rbxassetid://18579954015",
		DisplayName = "Atlantis",
		Thumbnail = "rbxassetid://18579953479",
		ReleaseDate = DateTime.fromUniversalTime(2024, 7, 20).UnixTimestamp
	},
	LavaMap_Construction = {
		Image = "",
		HoverImage = "",
		DisplayName = "Construction Site",
		DisabledInTraining = true,
		RequiredGameMode = "LavaFloor"
	},
	LavaMap_Doomspire = {
		Image = "",
		HoverImage = "",
		DisplayName = "The Doomspire",
		DisabledInTraining = true,
		RequiredGameMode = "LavaFloor"
	},
	LavaMap_Jungle = {
		Image = "",
		HoverImage = "",
		DisplayName = "Towering Jungle",
		DisabledInTraining = true,
		RequiredGameMode = "LavaFloor"
	},
	FloodSurvival_Tropical = {
		Thumbnail = "rbxassetid://18361820781",
		Image = "",
		HoverImage = "",
		DisplayName = "Tropical Island",
		DisabledInTraining = true,
		RequiredGameMode = "FloodSurvival",
		ReleaseDate = DateTime.fromUniversalTime(2024, 7, 7).UnixTimestamp
	},
	FloodSurvival_Kraken = {
		Thumbnail = "rbxassetid://18361821025",
		Image = "",
		HoverImage = "",
		DisplayName = "Kraken Despair",
		DisabledInTraining = true,
		RequiredGameMode = "FloodSurvival",
		ReleaseDate = DateTime.fromUniversalTime(2024, 7, 7).UnixTimestamp
	},
	FloodSurvival_Pillars = {
		Thumbnail = "rbxassetid://18361821226",
		Image = "",
		HoverImage = "",
		DisplayName = "Ancient Pillars",
		DisabledInTraining = true,
		RequiredGameMode = "FloodSurvival",
		ReleaseDate = DateTime.fromUniversalTime(2024, 7, 7).UnixTimestamp
	},
	FallingPlateSkyfall = {
		Image = "",
		HoverImage = "",
		DisplayName = "Sky Fall",
		DisabledInTraining = true,
		RequiredGameMode = "FallingPlate"
	},
	ZeroGravityArena = {
		Image = "",
		HoverImage = "",
		DisplayName = "Zero Gravity Arena",
		DisabledInTraining = true,
		RequiredGameMode = "Flying"
	},
	BattleRoyale_GrassPlain = {
		Image = "",
		HoverImage = "",
		DisplayName = "Meadows",
		Thumbnail = "rbxassetid://17010800755",
		DisabledInTraining = true,
		RequiredGameMode = "SquadRoyale"
	},
	BattleRoyale_DesertPlain = {
		Image = "",
		HoverImage = "",
		DisplayName = "Egypt",
		Thumbnail = "rbxassetid://17014559869",
		DisabledInTraining = true,
		RequiredGameMode = "SquadRoyale"
	},
	BattleRoyale_LavaArena = {
		Image = "",
		HoverImage = "",
		DisplayName = "Lava Arena",
		Thumbnail = "rbxassetid://17014559736",
		DisabledInTraining = true,
		RequiredGameMode = "SquadRoyale"
	},
	DesertEXPANDED = {
		Image = "rbxassetid://15122129270",
		HoverImage = "rbxassetid://15122129068",
		DisplayName = "Desert",
		RankedImage = "rbxassetid://15874169885",
		Thumbnail = "rbxassetid://15874169885",
		ReleaseDate = DateTime.fromUniversalTime(2024, 8, 24).UnixTimestamp,
		DisabledInTraining = true,
		RequiredGameMode = "SquadRoyale"
	},
	ClassicEXPANDED = {
		Image = "rbxassetid://15122128274",
		HoverImage = "rbxassetid://15122128067",
		DisplayName = "Classic",
		RankedImage = "rbxassetid://15874170417",
		Thumbnail = "rbxassetid://15874170417",
		ReleaseDate = DateTime.fromUniversalTime(2024, 8, 24).UnixTimestamp,
		DisabledInTraining = true,
		RequiredGameMode = "SquadRoyale"
	},
	RingOfFireEXPANDED = {
		Image = "rbxassetid://15122132021",
		HoverImage = "rbxassetid://15122131610",
		DisplayName = "Ring Of Fire",
		RankedImage = "rbxassetid://15874168591",
		Thumbnail = "rbxassetid://15874168591",
		ReleaseDate = DateTime.fromUniversalTime(2024, 8, 24).UnixTimestamp,
		DisabledInTraining = true,
		RequiredGameMode = "SquadRoyale"
	},
	BirdCageEXPANDED = {
		Image = "rbxassetid://17860747694",
		HoverImage = "rbxassetid://17860748032",
		DisplayName = "Bird Cage",
		Thumbnail = "rbxassetid://17860747419",
		ReleaseDate = DateTime.fromUniversalTime(2024, 8, 24).UnixTimestamp,
		DisabledInTraining = true,
		RequiredGameMode = "SquadRoyale"
	},
	HeavenEXPANDED = {
		Image = "rbxassetid://15384828790",
		HoverImage = "rbxassetid://15384828387",
		DisplayName = "Heaven",
		RankedImage = "rbxassetid://15874169362",
		Thumbnail = "rbxassetid://15874169362",
		ReleaseDate = DateTime.fromUniversalTime(2024, 8, 24).UnixTimestamp,
		DisabledInTraining = true,
		RequiredGameMode = "SquadRoyale"
	},
	Golden_Map = {
		Image = "",
		HoverImage = "",
		DisplayName = "Golden Map",
		Thumbnail = "",
		DisabledInTraining = true
	},
	HovergoalArena = {
		Image = "",
		HoverImage = "",
		DisplayName = "Hovergoal Arena",
		Thumbnail = "",
		DisabledInTraining = true
	},
	WorldCup = {
		Image = "",
		HoverImage = "",
		DisplayName = "World Cup",
		Thumbnail = "",
		DisabledInTraining = true,
		RequiredGameMode = "Soccer"
	},
	ChestBaseplate = {
		Image = "",
		HoverImage = "",
		DisplayName = "Chest Baseplate",
		Thumbnail = "",
		DisabledInTraining = true
	},
	Northpole = {
		Image = "rbxassetid://15122132021",
		HoverImage = "rbxassetid://15122131610",
		DisplayName = "Northpole",
		Thumbnail = "rbxassetid://77653224347850",
		Tix = false
	},
	WinterMap = {
		Image = "rbxassetid://15122132021",
		HoverImage = "rbxassetid://15122131610",
		DisplayName = "Winter Map",
		Thumbnail = "rbxassetid://86242264869385",
		Tix = false
	},
	NorthwindCastle = {
		Image = "rbxassetid://15122132021",
		HoverImage = "rbxassetid://15122131610",
		DisplayName = "Northwind Castle",
		Thumbnail = "rbxassetid://110010015828101",
		Tix = false
	},
	FrostlightVillage = {
		Image = "rbxassetid://15122132021",
		HoverImage = "rbxassetid://15122131610",
		DisplayName = "Frostlight Village",
		Thumbnail = "rbxassetid://111139700508974",
		Tix = false
	},
	NewYear_Map = {
		Image = "rbxassetid://15122132021",
		HoverImage = "rbxassetid://15122131610",
		DisplayName = "New Year's Map",
		Thumbnail = "rbxassetid://102054504662006",
		Tix = false
	},
	BlackHole = {
		Image = "rbxassetid://15122132021",
		HoverImage = "rbxassetid://15122131610",
		DisplayName = "Black Hole",
		Thumbnail = "rbxassetid://113927619034896",
		Tix = false
	},
	OtherWorldArena = {
		Image = "rbxassetid://15122132021",
		HoverImage = "rbxassetid://15122131610",
		DisplayName = "Other World Arena",
		Thumbnail = "rbxassetid://97084351043152",
		Tix = false
	},
	CrystalRealm = {
		Image = "rbxassetid://15122132021",
		HoverImage = "rbxassetid://15122131610",
		DisplayName = "Crystal Realm",
		Thumbnail = "rbxassetid://138229571282155",
		Tix = false
	},
	ValentinesMap = {
		Image = "rbxassetid://15122132021",
		HoverImage = "rbxassetid://15122131610",
		DisplayName = "Valentines Map",
		Thumbnail = "rbxassetid://73265531513768",
		Tix = false
	},
	AncientChinese = {
		Image = "rbxassetid://15122132021",
		HoverImage = "rbxassetid://15122131610",
		DisplayName = "Ancient Chinese Map",
		Thumbnail = "rbxassetid://83965912258380"
	},
	GreekMap = {
		Image = "rbxassetid://15122132021",
		HoverImage = "rbxassetid://15122131610",
		DisplayName = "Greek Map",
		Thumbnail = "rbxassetid://77650304857161"
	},
	AncientPyramids = {
		Image = "rbxassetid://15122132021",
		HoverImage = "rbxassetid://15122131610",
		DisplayName = "Ancient Pyramids",
		Thumbnail = "rbxassetid://71319848596896"
	},
	CowboyVillage = {
		Image = "rbxassetid://15122132021",
		HoverImage = "rbxassetid://15122131610",
		DisplayName = "Cowboy Village",
		Thumbnail = "rbxassetid://122319239729983"
	},
	Barn = {
		Image = "rbxassetid://15122132021",
		HoverImage = "rbxassetid://15122131610",
		DisplayName = "Barn",
		Thumbnail = "rbxassetid://84274601203916"
	}
}