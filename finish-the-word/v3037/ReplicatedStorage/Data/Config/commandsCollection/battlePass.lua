local import = _G.import("global")
return {
	setBpPremium = {
		Name = "setBpPremium",
		Description = "Toggle battle pass premium for a player.",
		Category = "Battle Pass",
		Groups = { "Admin" },
		Args = {
			{
				Name = "player",
				Type = "player"
			},
			{
				Name = "premium",
				Type = "bool",
				Provider = "boolString"
			}
		},
		Run = function(_, p)
			import.get("playerSave", p.player).BattlePass:replicate("PremiumUnlocked", p.premium)
			return string.format("Gave %s", p.player.Name)
		end
	},
	setBpLevel = {
		Name = "setBpLevel",
		Description = "Set a player's battle pass level to an exact value.",
		Category = "Battle Pass",
		Groups = { "Admin" },
		Args = {
			{
				Name = "player",
				Type = "player"
			},
			{
				Name = "level",
				Type = "int"
			}
		},
		Run = function(_, p)
			local playerSave = import.get("playerSave", p.player)
			local xpRequiredToReachTier = playerSave:getXpRequiredToReachTier(p.level)
			playerSave.BattlePass:auto_repl(true)
			playerSave.BattlePass.XP = xpRequiredToReachTier
			playerSave.BattlePass.SkippedTiers = 0
			playerSave.BattlePass:auto_repl(false)
			return string.format("Gave %s Battle Pass Level %d", p.player.Name, p.level)
		end
	},
	maxBp = {
		Name = "maxBp",
		Description = "Max a player's battle pass progress.",
		Category = "Battle Pass",
		Groups = { "Admin" },
		Args = {
			{
				Name = "player",
				Type = "player"
			}
		},
		Run = function(_, p)
			local playerSave = import.get("playerSave", p.player)
			local xpRequiredToReachTier = playerSave:getXpRequiredToReachTier(100)
			playerSave.BattlePass:replicate("XP", xpRequiredToReachTier)
			return string.format("Gave %s Maxed Battle Pass", p.player.Name)
		end
	},
	resetBp = {
		Name = "resetBp",
		Description = "Reset a player's battle pass progress.",
		Category = "Battle Pass",
		Groups = { "Admin" },
		Destructive = true,
		Args = {
			{
				Name = "player",
				Type = "player"
			},
			{
				Name = "revokePremium",
				Type = "bool",
				Provider = "boolString",
				Optional = true,
				Default = false
			}
		},
		Run = function(_, p)
			local playerSave = import.get("playerSave", p.player)
			playerSave.BattlePass:auto_repl(true)

			if p.revokePremium then
				playerSave.BattlePass.PremiumUnlocked = false
			end

			playerSave.BattlePass.XP = 0
			playerSave.BattlePass.SkippedTiers = 0
			playerSave.BattlePass.ClaimedRewards = {}
			playerSave.BattlePass:auto_repl(false)
			return string.format("Reset %s's Battle Pass Progress", p.player.Name)
		end
	},
	bpStatus = {
		Name = "bpStatus",
		Description = "Show a player's battle pass status.",
		Category = "Battle Pass",
		Groups = { "Admin" },
		Args = {
			{
				Name = "player",
				Type = "player"
			}
		},
		Run = function(_, p)
			local playerSave = import.get("playerSave", p.player)
			local battlePass = playerSave.BattlePass
			local tierFromXP, v, v2 = playerSave:calculateTierFromXP()
			local v3 = battlePass.PremiumUnlocked and "Premium" or "No Premium"
			local v4 = string.format(
				"%s | %s | XP %d | Tier %d (%d/%d) | Skips %d | Currency %d",
				p.player.Name,
				v3,
				battlePass.XP or 0,
				tierFromXP,
				v or 0,
				v2 or 0,
				battlePass.SkippedTiers or 0,
				battlePass.Currency or 0
			)
			print(v4)
			return v4
		end
	}
}