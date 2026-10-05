local IndexUtil = require(game.ReplicatedStorage.Packages.IndexUtil)
local Option = require(game.ReplicatedStorage.Packages.Option)
local Future = require(game.ReplicatedStorage.Packages.Future)
return {
	read = function(p, p2: number?)
		local v = Option.from(p2)
		return {
			Stars = {
				BloxFruit = Future.from(function()
					return (IndexUtil.matchLocalPathAsync(p, "Data/Stars/Blox Fruit", v):await():unwrap())
				end),
				Gun = Future.from(function()
					return (IndexUtil.matchLocalPathAsync(p, "Data/Stars/Gun", v):await():unwrap())
				end),
				Max = Future.from(function()
					return (IndexUtil.matchLocalPathAsync(p, "Data/Stars/Max", v):await():unwrap())
				end),
				Melee = Future.from(function()
					return (IndexUtil.matchLocalPathAsync(p, "Data/Stars/Melee", v):await():unwrap())
				end),
				Sword = Future.from(function()
					return (IndexUtil.matchLocalPathAsync(p, "Data/Stars/Sword", v):await():unwrap())
				end)
			},
			Stats = {
				Defense = {
					Exp = Future.from(function()
						return (IndexUtil.matchLocalPathAsync(p, "Data/Stats/Defense/Exp", v):await():unwrap())
					end),
					Level = Future.from(function()
						return (IndexUtil.matchLocalPathAsync(p, "Data/Stats/Defense/Level", v):await():unwrap())
					end)
				},
				DemonFruit = {
					Exp = Future.from(function()
						return (IndexUtil.matchLocalPathAsync(p, "Data/Stats/Demon Fruit/Exp", v):await():unwrap())
					end),
					Level = Future.from(function()
						return (IndexUtil.matchLocalPathAsync(p, "Data/Stats/Demon Fruit/Level", v):await():unwrap())
					end)
				},
				Gun = {
					Exp = Future.from(function()
						return (IndexUtil.matchLocalPathAsync(p, "Data/Stats/Gun/Exp", v):await():unwrap())
					end),
					Level = Future.from(function()
						return (IndexUtil.matchLocalPathAsync(p, "Data/Stats/Gun/Level", v):await():unwrap())
					end)
				},
				Melee = {
					Exp = Future.from(function()
						return (IndexUtil.matchLocalPathAsync(p, "Data/Stats/Melee/Exp", v):await():unwrap())
					end),
					Level = Future.from(function()
						return (IndexUtil.matchLocalPathAsync(p, "Data/Stats/Melee/Level", v):await():unwrap())
					end)
				},
				Sword = {
					Exp = Future.from(function()
						return (IndexUtil.matchLocalPathAsync(p, "Data/Stats/Sword/Exp", v):await():unwrap())
					end),
					Level = Future.from(function()
						return (IndexUtil.matchLocalPathAsync(p, "Data/Stats/Sword/Level", v):await():unwrap())
					end)
				}
			},
			Beli = Future.from(function()
				return (IndexUtil.matchLocalPathAsync(p, "Data/Beli", v):await():unwrap())
			end),
			CrewID = Future.from(function()
				return (IndexUtil.matchLocalPathAsync(p, "Data/CrewID", v):await():unwrap())
			end),
			DevilFruit = Future.from(function()
				return (IndexUtil.matchLocalPathAsync(p, "Data/DevilFruit", v):await():unwrap())
			end),
			Exp = Future.from(function()
				return (IndexUtil.matchLocalPathAsync(p, "Data/Exp", v):await():unwrap())
			end),
			Fragments = Future.from(function()
				return (IndexUtil.matchLocalPathAsync(p, "Data/Fragments", v):await():unwrap())
			end),
			FruitCap = Future.from(function()
				return (IndexUtil.matchLocalPathAsync(p, "Data/FruitCap", v):await():unwrap())
			end),
			LastSpawnPoint = Future.from(function()
				return (IndexUtil.matchLocalPathAsync(p, "Data/LastSpawnPoint", v):await():unwrap())
			end),
			Level = Future.from(function()
				return (IndexUtil.matchLocalPathAsync(p, "Data/Level", v):await():unwrap())
			end),
			Points = Future.from(function()
				return (IndexUtil.matchLocalPathAsync(p, "Data/Points", v):await():unwrap())
			end),
			Race = {
				Value = Future.from(function()
					return (IndexUtil.matchLocalPathAsync(p, "Data/Race", v):await():unwrap())
				end),
				A = Future.from(function()
					return (IndexUtil.matchLocalPathAsync(p, "Data/RaceA", v):await():unwrap())
				end),
				B = Future.from(function()
					return (IndexUtil.matchLocalPathAsync(p, "Data/RaceB", v):await():unwrap())
				end),
				C = Future.from(function()
					return (IndexUtil.matchLocalPathAsync(p, "Data/RaceC", v):await():unwrap())
				end)
			},
			RaceRerolls = Future.from(function()
				return (IndexUtil.matchLocalPathAsync(p, "Data/RaceRerolls", v):await():unwrap())
			end),
			SeaEventsCleared = Future.from(function()
				return (IndexUtil.matchLocalPathAsync(p, "Data/SeaEventsCleared", v):await():unwrap())
			end),
			SpawnPoint = Future.from(function()
				return (IndexUtil.matchLocalPathAsync(p, "Data/SpawnPoint", v):await():unwrap())
			end),
			StatRefunds = Future.from(function()
				return (IndexUtil.matchLocalPathAsync(p, "Data/StatRefunds", v):await():unwrap())
			end),
			Subclass = Future.from(function()
				return (IndexUtil.matchLocalPathAsync(p, "Data/Subclass", v):await():unwrap())
			end),
			Valor = Future.from(function()
				return (IndexUtil.matchLocalPathAsync(p, "Data/Valor", v):await():unwrap())
			end)
		}
	end
}