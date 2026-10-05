local import = _G.import("global")
local import2 = _G.import("event")
local import3 = _G.import("configuration")
local import4 = _G.import("mathUtil")
local LEVEL = import3.LEVEL
return {
	giveItem = {
		Name = "giveItem",
		Description = "Give a player an inventory item (Pet, Chair, etc).",
		Category = "Inventory",
		Groups = { "Admin" },
		Args = {
			{
				Name = "player",
				Type = "player"
			},
			{
				Name = "itemType",
				Type = "string",
				Provider = "itemType"
			},
			{
				Name = "itemId",
				Type = "string",
				Provider = "itemId",
				DependsOn = "itemType",
				Variadic = true
			}
		},
		Run = function(_, data)
			local playerSave = import.get("playerSave", data.player)
			playerSave:auto_repl(true)

			for _, v in ipairs(data.itemId) do
				playerSave:add("Inventory", data.itemType, v)
			end

			playerSave:auto_repl(false)
			return string.format("Gave %d %s item(s) to %s", #data.itemId, data.itemType, data.player.Name)
		end
	},
	giveCash = {
		Name = "giveCash",
		Description = "Give a player cash.",
		Category = "Stats (Give)",
		Groups = { "Admin" },
		Args = {
			{
				Name = "player",
				Type = "player"
			},
			{
				Name = "amount",
				Type = "string"
			}
		},
		Run = function(_, p)
			local amount = tonumber(p.amount)

			if not amount then
				return "Invalid amount"
			end

			local playerSave = import.get("playerSave", p.player)
			playerSave:auto_repl(true)
			playerSave.Statistics.Cash += amount
			playerSave:auto_repl(false)
			import2.remoteFire(p.player, "gain", {
				Currency = {
					Cash = amount
				}
			})
			return string.format("Gave %d Cash to %s", amount, p.player.Name)
		end
	},
	giveSpecialKey = {
		Name = "giveSpecialKey",
		Description = "Give a player special keys.",
		Category = "Stats (Give)",
		Groups = { "Admin" },
		Args = {
			{
				Name = "player",
				Type = "player"
			},
			{
				Name = "amount",
				Type = "string"
			}
		},
		Run = function(_, p)
			local amount = tonumber(p.amount)

			if not amount then
				return "Invalid amount"
			end

			local playerSave = import.get("playerSave", p.player)
			playerSave:auto_repl(true)
			playerSave.Statistics.SpecialKey += amount
			playerSave:auto_repl(false)
			return string.format("Gave %d SpecialKey to %s", amount, p.player.Name)
		end
	},
	giveWins = {
		Name = "giveWins",
		Description = "Give a player wins.",
		Category = "Stats (Give)",
		Groups = { "Admin" },
		Args = {
			{
				Name = "player",
				Type = "player"
			},
			{
				Name = "amount",
				Type = "string"
			}
		},
		Run = function(_, p)
			local amount = tonumber(p.amount)

			if not amount then
				return "Invalid amount"
			end

			local playerSave = import.get("playerSave", p.player)
			playerSave:auto_repl(true)
			playerSave.Statistics.Wins += amount
			playerSave:auto_repl(false)
			return string.format("Gave %d Wins to %s", amount, p.player.Name)
		end
	},
	giveTimeBoost = {
		Name = "giveTimeBoost",
		Description = "Give a player time boosts.",
		Category = "Stats (Give)",
		Groups = { "Admin" },
		Args = {
			{
				Name = "player",
				Type = "player"
			},
			{
				Name = "amount",
				Type = "string"
			}
		},
		Run = function(_, p)
			local amount = tonumber(p.amount)

			if not amount then
				return "Invalid amount"
			end

			local playerSave = import.get("playerSave", p.player)
			playerSave:auto_repl(true)
			playerSave.Statistics.TimeBoost += amount
			playerSave:auto_repl(false)
			return string.format("Gave %d TimeBoost to %s", amount, p.player.Name)
		end
	},
	giveStreak = {
		Name = "giveStreak",
		Description = "Give a player streak.",
		Category = "Stats (Give)",
		Groups = { "Admin" },
		Args = {
			{
				Name = "player",
				Type = "player"
			},
			{
				Name = "amount",
				Type = "string"
			}
		},
		Run = function(_, p)
			local amount = tonumber(p.amount)

			if not amount then
				return "Invalid amount"
			end

			local playerSave = import.get("playerSave", p.player)
			playerSave:auto_repl(true)
			playerSave.Statistics.Streak += amount
			playerSave:auto_repl(false)
			return string.format("Gave %d Streak to %s", amount, p.player.Name)
		end
	},
	setCash = {
		Name = "setCash",
		Description = "Set a player's cash.",
		Category = "Stats (Set)",
		Groups = { "Admin" },
		Args = {
			{
				Name = "player",
				Type = "player"
			},
			{
				Name = "amount",
				Type = "string"
			}
		},
		Run = function(_, p)
			local amount = tonumber(p.amount)

			if not amount then
				return "Invalid amount"
			end

			local playerSave = import.get("playerSave", p.player)
			playerSave:auto_repl(true)
			playerSave.Statistics.Cash = amount
			playerSave:auto_repl(false)
			return string.format("Set Cash to %d for %s", amount, p.player.Name)
		end
	},
	setSpecialKey = {
		Name = "setSpecialKey",
		Description = "Set a player's special keys.",
		Category = "Stats (Set)",
		Groups = { "Admin" },
		Args = {
			{
				Name = "player",
				Type = "player"
			},
			{
				Name = "amount",
				Type = "string"
			}
		},
		Run = function(_, p)
			local amount = tonumber(p.amount)

			if not amount then
				return "Invalid amount"
			end

			local playerSave = import.get("playerSave", p.player)
			playerSave:auto_repl(true)
			playerSave.Statistics.SpecialKey = amount
			playerSave:auto_repl(false)
			return string.format("Set SpecialKey to %d for %s", amount, p.player.Name)
		end
	},
	setWins = {
		Name = "setWins",
		Description = "Set a player's wins.",
		Category = "Stats (Set)",
		Groups = { "Admin" },
		Args = {
			{
				Name = "player",
				Type = "player"
			},
			{
				Name = "amount",
				Type = "string"
			}
		},
		Run = function(_, p)
			local amount = tonumber(p.amount)

			if not amount then
				return "Invalid amount"
			end

			local playerSave = import.get("playerSave", p.player)
			playerSave:auto_repl(true)
			playerSave.Statistics.Wins = amount
			playerSave:auto_repl(false)
			return string.format("Set Wins to %d for %s", amount, p.player.Name)
		end
	},
	setTimeBoost = {
		Name = "setTimeBoost",
		Description = "Set a player's time boosts.",
		Category = "Stats (Set)",
		Groups = { "Admin" },
		Args = {
			{
				Name = "player",
				Type = "player"
			},
			{
				Name = "amount",
				Type = "string"
			}
		},
		Run = function(_, p)
			local amount = tonumber(p.amount)

			if not amount then
				return "Invalid amount"
			end

			local playerSave = import.get("playerSave", p.player)
			playerSave:auto_repl(true)
			playerSave.Statistics.TimeBoost = amount
			playerSave:auto_repl(false)
			return string.format("Set TimeBoost to %d for %s", amount, p.player.Name)
		end
	},
	setStreak = {
		Name = "setStreak",
		Description = "Set a player's streak.",
		Category = "Stats (Set)",
		Groups = { "Admin" },
		Args = {
			{
				Name = "player",
				Type = "player"
			},
			{
				Name = "amount",
				Type = "string"
			}
		},
		Run = function(_, p)
			local amount = tonumber(p.amount)

			if not amount then
				return "Invalid amount"
			end

			local playerSave = import.get("playerSave", p.player)
			playerSave:auto_repl(true)
			playerSave.Statistics.Streak = amount
			playerSave:auto_repl(false)
			return string.format("Set Streak to %d for %s", amount, p.player.Name)
		end
	},
	setLevel = {
		Name = "setLevel",
		Description = "Set a player's level by converting to XP.",
		Category = "Levels",
		Groups = { "Admin" },
		Args = {
			{
				Name = "player",
				Type = "player"
			},
			{
				Name = "level",
				Type = "string"
			}
		},
		Run = function(_, p)
			local level = tonumber(p.level)

			if not level then
				return "Invalid level"
			end

			local v = math.clamp(math.floor(level), 1, 100)
			local levelToXp = import4.levelToXp(v, LEVEL.LEVEL_MAX_XP, LEVEL.LEVEL_XP_GROWTH)
			local playerSave = import.get("playerSave", p.player)
			playerSave:auto_repl(true)
			playerSave.Statistics.XP = levelToXp
			playerSave:auto_repl(false)
			return string.format("Set Level to %d for %s", v, p.player.Name)
		end
	},
	giveXp = {
		Name = "giveXp",
		Description = "Give a player XP.",
		Category = "Levels",
		Groups = { "Admin" },
		Args = {
			{
				Name = "player",
				Type = "player"
			},
			{
				Name = "amount",
				Type = "string"
			}
		},
		Run = function(_, p)
			local amount = tonumber(p.amount)

			if not amount then
				return "Invalid amount"
			end

			local playerSave = import.get("playerSave", p.player)
			local XP = playerSave.Statistics.XP
			playerSave:auto_repl(true)
			playerSave.Statistics.XP += amount
			playerSave:auto_repl(false)
			import2.remoteFire(p.player, "gain", {
				Xp = {
					Character = {
						Old = XP,
						Gain = amount
					}
				}
			})
			return string.format("Gave %d XP to %s", amount, p.player.Name)
		end
	},
	givePass = {
		Name = "givePass",
		Description = "Give a game pass to a player.",
		Category = "Game Pass",
		Groups = { "Admin" },
		Args = {
			{
				Name = "player",
				Type = "player"
			},
			{
				Name = "gamePassId",
				Type = "string",
				Provider = "gamePassId"
			}
		},
		Run = function(_, p)
			local playerSave = import.get("playerSave", p.player)
			local gamePassId = tonumber(p.gamePassId)
			playerSave:auto_repl(true)
			playerSave:addPass(gamePassId)
			playerSave:auto_repl(false)
			return string.format("Gave %s to %s", gamePassId, p.player.Name)
		end
	}
}