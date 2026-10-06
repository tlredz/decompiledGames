local ReplicatedStorage = game:GetService("ReplicatedStorage")
local WorldsId = require(ReplicatedStorage.Chest.Modules.WorldsId)
local v = {
	FirstSea = {
		Easy = {
			MapName = "Forgotten Prison",
			Image = "rbxassetid://76237483236084",
			Info = "Dungeon - Easy Mode [5 Floors]",
			TimeRecordString = "FirstSeaDungeonEasyRecord",
			TotalClearedString = "FirstSeaDungeon"
		}
	},
	SecondSea = {
		Easy = {
			MapName = "Lavahold Prison",
			Image = "rbxassetid://133736912305435",
			Info = "Dungeon - Easy Mode [5 Floors]",
			TimeRecordString = "SecondSeaDungeonEasyRecord",
			TotalClearedString = "SecondSeaDungeon"
		}
	},
	ThirdSea = {
		Easy = {
			MapName = "The Warden’s Domain",
			Image = "rbxassetid://77803150677832",
			Info = "Dungeon - Easy Mode [5 Floors]",
			TimeRecordString = "ThirdSeaDungeonEasyRecord",
			TotalClearedString = "ThirdSeaDungeon"
		},
		Normal = {
			MapName = "Thunder Ruins",
			Image = "rbxassetid://108103322528198",
			Info = "Dungeon - Normal Mode [5 Floors]",
			TimeRecordString = "ThirdSeaDungeonNormalRecord",
			TotalClearedString = "ThirdSeaDungeon"
		},
		Hard = {
			MapName = "Crustacean Cataclysm",
			Image = "rbxassetid://133759466234329",
			Info = "Dungeon - Hard Mode [5 Floors]",
			TimeRecordString = "ThirdSeaDungeonHardRecord",
			TotalClearedString = "ThirdSeaDungeon"
		}
	}
}
return {
	[WorldsId.Testing.FirstSea] = v.FirstSea,
	[WorldsId.Testing.SecondSea] = v.SecondSea,
	[WorldsId.Testing.ThirdSea] = v.ThirdSea,
	[WorldsId.KingLegacy.FirstSea] = v.FirstSea,
	[WorldsId.KingLegacy.SecondSea] = v.SecondSea,
	[WorldsId.KingLegacy.ThirdSea] = v.ThirdSea
}