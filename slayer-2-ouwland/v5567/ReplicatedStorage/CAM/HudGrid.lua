local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Packages.faye)
local HudGrid = {
	Grid = {
		["1v1"] = {
			Type = 1,
			Players = 1,
			Minigame = "PvP",
			Icon = "rbxassetid://87668657092830",
			Ranked = true,
			PartyFriendly = true,
			Order = 1
		},
		["2v2"] = {
			Type = 1,
			Players = 2,
			Minigame = "PvP",
			Icon = "rbxassetid://107045950745946",
			Ranked = true,
			PartyFriendly = true,
			Order = 2
		},
		["3v3"] = {
			Type = 1,
			Players = 3,
			Minigame = "PvP",
			Icon = "rbxassetid://135744306826995",
			Ranked = true,
			PartyFriendly = true,
			Order = 3
		},
		Tourney = {
			Title = "Zenith",
			Type = 1,
			Players = 1,
			Minigame = "PvP",
			Icon = "rbxassetid://88534951784142",
			Ranked = true,
			RankedOnly = true,
			Order = 4
		},
		Normal = {
			Title = "Ouwigahara Normal",
			Type = 1,
			Players = 5,
			Minigame = "Ouwigahara",
			Icon = "rbxassetid://138772893320087",
			Fill = true,
			Timeout = 30,
			NoFillTimeout = 3,
			Ranked = true,
			UnlockQuest = "Ill find the forge(Lv 65)",
			Order = 5
		},
		Roguelike = {
			Title = "Ouwigahara Roguelike",
			Type = 1,
			Players = 5,
			Minigame = "Ouwigahara",
			Icon = "rbxassetid://113126721532133",
			Fill = true,
			Timeout = 30,
			NoFillTimeout = 3,
			Ranked = true,
			UnlockQuest = "Ill find the forge(Lv 65)",
			Order = 6
		}
	},
	ByName = {},
	ById = {}
}

for k, v in HudGrid.Grid do
	v.Name = k
	HudGrid.ByName[k] = v
end

return HudGrid