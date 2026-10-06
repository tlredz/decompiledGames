local ReplicatedStorage = game:GetService("ReplicatedStorage")
return {
	GravityGravity = {
		GravityZ = 10,
		GravityX = 15,
		GravityC = 20,
		GravityV = 30,
		GravityB = 50
	},
	VenomVenom = {
		VenomZ = 5,
		VenomX = 15,
		VenomC = 20,
		VenomV = 30,
		VenomB = 75,
		VenomE = 40
	},
	BombBomb = {
		BombZ = 5,
		BombX = 15,
		BombC = 25,
		BombV = 50,
		BombE = 10
	},
	QuakeQuake = {
		QuakeZ = {
			Price = 20,
			RequirementsText = function(p)
				return "Clear 2nd sea dungeon with <font color =\"#aaffff\">Quake.</font> (" .. (_G.GetStatisticClient(
					p,
					"SecondSeaDungeon",
					"QuakeQuake"
				) or 0) .. "/1)"
			end,
			Requirements = function(player)
				local getDungeonNumber = _G.GetStatistic(player, "SecondSeaDungeon", "QuakeQuake") or 0

				if getDungeonNumber >= 1 then
					return true
				end

				ReplicatedStorage.Chest.Remotes.Events.TextAlert:FireClient(player, "Dungeon Awake Progress", {
					GetDungeonNumber = getDungeonNumber,
					RequireNumber = 1,
					FruitName = "Quake",
					FruitTextColor = "<font color=\"#aaffff\">",
					DungeonWorld = 2,
					Overlay = true
				})
			end
		},
		QuakeX = {
			Price = 50,
			RequirementsText = function(p)
				return "Clear 2nd sea dungeon with <font color =\"#aaffff\">Quake.</font> (" .. (_G.GetStatisticClient(
					p,
					"SecondSeaDungeon",
					"QuakeQuake"
				) or 0) .. "/2)"
			end,
			Requirements = function(player)
				local getDungeonNumber = _G.GetStatistic(player, "SecondSeaDungeon", "QuakeQuake") or 0

				if getDungeonNumber >= 2 then
					return true
				end

				ReplicatedStorage.Chest.Remotes.Events.TextAlert:FireClient(player, "Dungeon Awake Progress", {
					GetDungeonNumber = getDungeonNumber,
					RequireNumber = 2,
					FruitName = "Quake",
					FruitTextColor = "<font color=\"#aaffff\">",
					DungeonWorld = 2,
					Overlay = true
				})
			end
		},
		QuakeC = {
			Price = 100,
			RequirementsText = function(p)
				return "Clear 2nd sea dungeon with <font color =\"#aaffff\">Quake.</font> (" .. (_G.GetStatisticClient(
					p,
					"SecondSeaDungeon",
					"QuakeQuake"
				) or 0) .. "/3)"
			end,
			Requirements = function(player)
				local getDungeonNumber = _G.GetStatistic(player, "SecondSeaDungeon", "QuakeQuake") or 0

				if getDungeonNumber >= 3 then
					return true
				end

				ReplicatedStorage.Chest.Remotes.Events.TextAlert:FireClient(player, "Dungeon Awake Progress", {
					GetDungeonNumber = getDungeonNumber,
					RequireNumber = 3,
					FruitName = "Quake",
					FruitTextColor = "<font color=\"#aaffff\">",
					DungeonWorld = 2,
					Overlay = true
				})
			end
		},
		QuakeV = {
			Price = 150,
			RequirementsText = function(p)
				return "Clear 2nd sea dungeon with <font color =\"#aaffff\">Quake.</font> (" .. (_G.GetStatisticClient(
					p,
					"SecondSeaDungeon",
					"QuakeQuake"
				) or 0) .. "/4)"
			end,
			Requirements = function(player)
				local getDungeonNumber = _G.GetStatistic(player, "SecondSeaDungeon", "QuakeQuake") or 0

				if getDungeonNumber >= 4 then
					return true
				end

				ReplicatedStorage.Chest.Remotes.Events.TextAlert:FireClient(player, "Dungeon Awake Progress", {
					GetDungeonNumber = getDungeonNumber,
					RequireNumber = 4,
					FruitName = "Quake",
					FruitTextColor = "<font color=\"#aaffff\">",
					DungeonWorld = 2,
					Overlay = true
				})
			end
		},
		QuakeB = {
			Price = 175,
			RequirementsText = function(p)
				return "Clear 2nd sea dungeon with <font color =\"#aaffff\">Quake.</font> (" .. (_G.GetStatisticClient(
					p,
					"SecondSeaDungeon",
					"QuakeQuake"
				) or 0) .. "/5)"
			end,
			Requirements = function(player)
				local getDungeonNumber = _G.GetStatistic(player, "SecondSeaDungeon", "QuakeQuake") or 0

				if getDungeonNumber >= 5 then
					return true
				end

				ReplicatedStorage.Chest.Remotes.Events.TextAlert:FireClient(player, "Dungeon Awake Progress", {
					GetDungeonNumber = getDungeonNumber,
					RequireNumber = 5,
					FruitName = "Quake",
					FruitTextColor = "<font color=\"#aaffff\">",
					DungeonWorld = 2,
					Overlay = true
				})
			end
		}
	},
	IceIce = {
		IceZ = 15,
		IceX = 75,
		IceC = 125,
		IceV = 175,
		IceE = 140
	},
	MagmaMagma = {
		MagmaZ = 15,
		MagmaX = 75,
		MagmaC = 125,
		MagmaV = 140,
		MagmaE = 130
	},
	LightLight = {
		LightZ = 15,
		LightX = 75,
		LightC = 150,
		LightV = 170,
		LightE = 140
	},
	DarkDark = {
		DarkZ = 10,
		DarkX = 70,
		DarkC = 95,
		DarkV = 125,
		DarkB = 150
	},
	FlameFlame = {
		FlameZ = 25,
		FlameX = 75,
		FlameC = 100,
		FlameV = 150,
		FlameE = 50
	},
	LoveLove = {
		LoveZ = 11,
		LoveX = 33,
		LoveC = 55,
		LoveV = 111
	},
	SnowSnow = {
		SnowZ = 15,
		SnowX = 35,
		SnowC = 70,
		SnowV = 140,
		SnowE = 65
	},
	DoughDough = {
		DoughZ = {
			Price = 9,
			RequirementsText = function(p)
				return "Clear 2nd sea dungeon with <font color =\"#ffaaff\">Dough.</font> (" .. (_G.GetStatisticClient(
					p,
					"SecondSeaDungeon",
					"DoughDough"
				) or 0) .. "/1)"
			end,
			Requirements = function(player)
				local getDungeonNumber = _G.GetStatistic(player, "SecondSeaDungeon", "DoughDough") or 0

				if getDungeonNumber >= 1 then
					return true
				end

				ReplicatedStorage.Chest.Remotes.Events.TextAlert:FireClient(player, "Dungeon Awake Progress", {
					GetDungeonNumber = getDungeonNumber,
					RequireNumber = 1,
					FruitName = "Dough",
					FruitTextColor = "<font color=\"#ffaaff\">",
					DungeonWorld = 2,
					Overlay = true
				})
			end
		},
		DoughX = {
			Price = 49,
			RequirementsText = function(p)
				return "Clear 2nd sea dungeon with <font color =\"#ffaaff\">Dough.</font> (" .. (_G.GetStatisticClient(
					p,
					"SecondSeaDungeon",
					"DoughDough"
				) or 0) .. "/2)"
			end,
			Requirements = function(player)
				local getDungeonNumber = _G.GetStatistic(player, "SecondSeaDungeon", "DoughDough") or 0

				if getDungeonNumber >= 2 then
					return true
				end

				ReplicatedStorage.Chest.Remotes.Events.TextAlert:FireClient(player, "Dungeon Awake Progress", {
					GetDungeonNumber = getDungeonNumber,
					RequireNumber = 2,
					FruitName = "Dough",
					FruitTextColor = "<font color=\"#ffaaff\">",
					DungeonWorld = 2,
					Overlay = true
				})
			end
		},
		DoughC = {
			Price = 99,
			RequirementsText = function(p)
				return "Clear 2nd sea dungeon with <font color =\"#ffaaff\">Dough.</font> (" .. (_G.GetStatisticClient(
					p,
					"SecondSeaDungeon",
					"DoughDough"
				) or 0) .. "/3)"
			end,
			Requirements = function(player)
				local getDungeonNumber = _G.GetStatistic(player, "SecondSeaDungeon", "DoughDough") or 0

				if getDungeonNumber >= 3 then
					return true
				end

				ReplicatedStorage.Chest.Remotes.Events.TextAlert:FireClient(player, "Dungeon Awake Progress", {
					GetDungeonNumber = getDungeonNumber,
					RequireNumber = 3,
					FruitName = "Dough",
					FruitTextColor = "<font color=\"#ffaaff\">",
					DungeonWorld = 2,
					Overlay = true
				})
			end
		},
		DoughV = {
			Price = 144,
			RequirementsText = function(p)
				return "Clear 2nd sea dungeon with <font color =\"#ffaaff\">Dough.</font> (" .. (_G.GetStatisticClient(
					p,
					"SecondSeaDungeon",
					"DoughDough"
				) or 0) .. "/4)"
			end,
			Requirements = function(player)
				local getDungeonNumber = _G.GetStatistic(player, "SecondSeaDungeon", "DoughDough") or 0

				if getDungeonNumber >= 4 then
					return true
				end

				ReplicatedStorage.Chest.Remotes.Events.TextAlert:FireClient(player, "Dungeon Awake Progress", {
					GetDungeonNumber = getDungeonNumber,
					RequireNumber = 4,
					FruitName = "Dough",
					FruitTextColor = "<font color=\"#ffaaff\">",
					DungeonWorld = 2,
					Overlay = true
				})
			end
		},
		DoughE = {
			Price = 69,
			RequirementsText = function(p)
				return "Clear 2nd sea dungeon with <font color =\"#ffaaff\">Dough.</font> (" .. (_G.GetStatisticClient(
					p,
					"SecondSeaDungeon",
					"DoughDough"
				) or 0) .. "/5)"
			end,
			Requirements = function(player)
				local getDungeonNumber = _G.GetStatistic(player, "SecondSeaDungeon", "DoughDough") or 0

				if getDungeonNumber >= 5 then
					return true
				end

				ReplicatedStorage.Chest.Remotes.Events.TextAlert:FireClient(player, "Dungeon Awake Progress", {
					GetDungeonNumber = getDungeonNumber,
					RequireNumber = 5,
					FruitName = "Dough",
					FruitTextColor = "<font color=\"#ffaaff\">",
					DungeonWorld = 2,
					Overlay = true
				})
			end
		},
		DoughB = {
			Price = 222,
			RequirementsText = function(p)
				return "Clear 2nd sea dungeon with <font color =\"#ffaaff\">Dough.</font> (" .. (_G.GetStatisticClient(
					p,
					"SecondSeaDungeon",
					"DoughDough"
				) or 0) .. "/6)"
			end,
			Requirements = function(player)
				local getDungeonNumber = _G.GetStatistic(player, "SecondSeaDungeon", "DoughDough") or 0

				if getDungeonNumber >= 6 then
					return true
				end

				ReplicatedStorage.Chest.Remotes.Events.TextAlert:FireClient(player, "Dungeon Awake Progress", {
					GetDungeonNumber = getDungeonNumber,
					RequireNumber = 6,
					FruitName = "Dough",
					FruitTextColor = "<font color=\"#ffaaff\">",
					DungeonWorld = 2,
					Overlay = true
				})
			end
		}
	},
	BuddhaBuddha = {
		BuddhaZ = 5,
		BuddhaX = 35,
		BuddhaC = 75,
		BuddhaV = 200,
		BuddhaE = 100
	},
	OpOp = {
		OpZ = 5,
		OpX = 25,
		OpC = 100,
		OpV = 120,
		OpE = 200,
		OpB = 50
	},
	PhoenixPhoenix = {
		PhoenixZ = {
			Price = 25,
			RequirementsText = function(p)
				return "Clear 3rd sea dungeon with <font color =\"#00ffff\">Phoenix.</font> (" .. (_G.GetStatisticClient(
					p,
					"ThirdSeaDungeon",
					"PhoenixPhoenix"
				) or 0) .. "/1)"
			end,
			Requirements = function(player)
				local getDungeonNumber = _G.GetStatistic(player, "ThirdSeaDungeon", "PhoenixPhoenix") or 0

				if getDungeonNumber >= 1 then
					return true
				end

				ReplicatedStorage.Chest.Remotes.Events.TextAlert:FireClient(player, "Dungeon Awake Progress", {
					GetDungeonNumber = getDungeonNumber,
					RequireNumber = 1,
					FruitName = "Phoenix",
					FruitTextColor = "<font color=\"#00ffff\">",
					DungeonWorld = 3,
					Overlay = true
				})
			end
		},
		PhoenixX = {
			Price = 75,
			RequirementsText = function(p)
				return "Clear 3rd sea dungeon with <font color =\"#00ffff\">Phoenix.</font> (" .. (_G.GetStatisticClient(
					p,
					"ThirdSeaDungeon",
					"PhoenixPhoenix"
				) or 0) .. "/3)"
			end,
			Requirements = function(player)
				local getDungeonNumber = _G.GetStatistic(player, "ThirdSeaDungeon", "PhoenixPhoenix") or 0

				if getDungeonNumber >= 3 then
					return true
				end

				ReplicatedStorage.Chest.Remotes.Events.TextAlert:FireClient(player, "Dungeon Awake Progress", {
					GetDungeonNumber = getDungeonNumber,
					RequireNumber = 3,
					FruitName = "Phoenix",
					FruitTextColor = "<font color=\"#00ffff\">",
					DungeonWorld = 3,
					Overlay = true
				})
			end
		},
		PhoenixC = {
			Price = 199,
			RequirementsText = function(p)
				return "Clear 3rd sea dungeon with <font color =\"#00ffff\">Phoenix.</font> (" .. (_G.GetStatisticClient(
					p,
					"ThirdSeaDungeon",
					"PhoenixPhoenix"
				) or 0) .. "/5)"
			end,
			Requirements = function(player)
				local getDungeonNumber = _G.GetStatistic(player, "ThirdSeaDungeon", "PhoenixPhoenix") or 0

				if getDungeonNumber >= 5 then
					return true
				end

				ReplicatedStorage.Chest.Remotes.Events.TextAlert:FireClient(player, "Dungeon Awake Progress", {
					GetDungeonNumber = getDungeonNumber,
					RequireNumber = 5,
					FruitName = "Phoenix",
					FruitTextColor = "<font color=\"#00ffff\">",
					DungeonWorld = 3,
					Overlay = true
				})
			end
		},
		PhoenixV = {
			Price = 499,
			RequirementsText = function(p)
				return "Clear 3rd sea dungeon with <font color =\"#00ffff\">Phoenix.</font> (" .. (_G.GetStatisticClient(
					p,
					"ThirdSeaDungeon",
					"PhoenixPhoenix"
				) or 0) .. "/9)"
			end,
			Requirements = function(player)
				local getDungeonNumber = _G.GetStatistic(player, "ThirdSeaDungeon", "PhoenixPhoenix") or 0

				if getDungeonNumber >= 9 then
					return true
				end

				ReplicatedStorage.Chest.Remotes.Events.TextAlert:FireClient(player, "Dungeon Awake Progress", {
					GetDungeonNumber = getDungeonNumber,
					RequireNumber = 9,
					FruitName = "Phoenix",
					FruitTextColor = "<font color=\"#00ffff\">",
					DungeonWorld = 3,
					Overlay = true
				})
			end
		},
		PhoenixE = {
			Price = 349,
			RequirementsText = function(p)
				return "Clear 3rd sea dungeon with <font color =\"#00ffff\">Phoenix.</font> (" .. (_G.GetStatisticClient(
					p,
					"ThirdSeaDungeon",
					"PhoenixPhoenix"
				) or 0) .. "/7)"
			end,
			Requirements = function(player)
				local getDungeonNumber = _G.GetStatistic(player, "ThirdSeaDungeon", "PhoenixPhoenix") or 0

				if getDungeonNumber >= 7 then
					return true
				end

				ReplicatedStorage.Chest.Remotes.Events.TextAlert:FireClient(player, "Dungeon Awake Progress", {
					GetDungeonNumber = getDungeonNumber,
					RequireNumber = 7,
					FruitName = "Phoenix",
					FruitTextColor = "<font color=\"#00ffff\">",
					DungeonWorld = 3,
					Overlay = true
				})
			end
		}
	},
	RumbleRumble = {
		RumbleZ = {
			Price = 35,
			RequirementsText = function(p)
				return "Clear normal dungeon with <font color =\"#00ffff\">Rumble.</font> (" .. (_G.GetStatisticClient(
					p,
					"ThirdSeaDungeonNormal",
					"RumbleRumble"
				) or 0) .. "/1)"
			end,
			Requirements = function(player)
				local getDungeonNumber = _G.GetStatistic(player, "ThirdSeaDungeonNormal", "RumbleRumble") or 0

				if getDungeonNumber >= 1 then
					return true
				end

				ReplicatedStorage.Chest.Remotes.Events.TextAlert:FireClient(player, "Dungeon Awake Progress", {
					GetDungeonNumber = getDungeonNumber,
					RequireNumber = 1,
					FruitName = "Rumble",
					FruitTextColor = "<font color=\"#00ffff\">",
					DungeonWorld = 3,
					Overlay = true
				})
			end
		},
		RumbleX = {
			Price = 125,
			RequirementsText = function(p)
				return "Clear normal dungeon with <font color =\"#00ffff\">Rumble.</font> (" .. (_G.GetStatisticClient(
					p,
					"ThirdSeaDungeonNormal",
					"RumbleRumble"
				) or 0) .. "/3)"
			end,
			Requirements = function(player)
				local getDungeonNumber = _G.GetStatistic(player, "ThirdSeaDungeonNormal", "RumbleRumble") or 0

				if getDungeonNumber >= 3 then
					return true
				end

				ReplicatedStorage.Chest.Remotes.Events.TextAlert:FireClient(player, "Dungeon Awake Progress", {
					GetDungeonNumber = getDungeonNumber,
					RequireNumber = 3,
					FruitName = "Rumble",
					FruitTextColor = "<font color=\"#00ffff\">",
					DungeonWorld = 3,
					Overlay = true
				})
			end
		},
		RumbleC = {
			Price = 150,
			RequirementsText = function(p)
				return "Clear normal dungeon with <font color =\"#00ffff\">Rumble.</font> (" .. (_G.GetStatisticClient(
					p,
					"ThirdSeaDungeonNormal",
					"RumbleRumble"
				) or 0) .. "/5)"
			end,
			Requirements = function(player)
				local getDungeonNumber = _G.GetStatistic(player, "ThirdSeaDungeonNormal", "RumbleRumble") or 0

				if getDungeonNumber >= 5 then
					return true
				end

				ReplicatedStorage.Chest.Remotes.Events.TextAlert:FireClient(player, "Dungeon Awake Progress", {
					GetDungeonNumber = getDungeonNumber,
					RequireNumber = 5,
					FruitName = "Rumble",
					FruitTextColor = "<font color=\"#00ffff\">",
					DungeonWorld = 3,
					Overlay = true
				})
			end
		},
		RumbleV = {
			Price = 500,
			RequirementsText = function(p)
				return "Clear normal dungeon with <font color =\"#00ffff\">Rumble.</font> (" .. (_G.GetStatisticClient(
					p,
					"ThirdSeaDungeonNormal",
					"RumbleRumble"
				) or 0) .. "/9)"
			end,
			Requirements = function(player)
				local getDungeonNumber = _G.GetStatistic(player, "ThirdSeaDungeonNormal", "RumbleRumble") or 0

				if getDungeonNumber >= 9 then
					return true
				end

				ReplicatedStorage.Chest.Remotes.Events.TextAlert:FireClient(player, "Dungeon Awake Progress", {
					GetDungeonNumber = getDungeonNumber,
					RequireNumber = 9,
					FruitName = "Rumble",
					FruitTextColor = "<font color=\"#00ffff\">",
					DungeonWorld = 3,
					Overlay = true
				})
			end
		},
		RumbleE = {
			Price = 425,
			RequirementsText = function(p)
				return "Clear normal dungeon with <font color =\"#00ffff\">Rumble.</font> (" .. (_G.GetStatisticClient(
					p,
					"ThirdSeaDungeonNormal",
					"RumbleRumble"
				) or 0) .. "/7)"
			end,
			Requirements = function(player)
				local getDungeonNumber = _G.GetStatistic(player, "ThirdSeaDungeonNormal", "RumbleRumble") or 0

				if getDungeonNumber >= 7 then
					return true
				end

				ReplicatedStorage.Chest.Remotes.Events.TextAlert:FireClient(player, "Dungeon Awake Progress", {
					GetDungeonNumber = getDungeonNumber,
					RequireNumber = 7,
					FruitName = "Rumble",
					FruitTextColor = "<font color=\"#00ffff\">",
					DungeonWorld = 3,
					Overlay = true
				})
			end
		}
	}
}