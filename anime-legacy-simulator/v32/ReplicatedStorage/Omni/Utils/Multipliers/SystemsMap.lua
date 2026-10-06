local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = require(ReplicatedStorage.Omni.Shared)
require("@game/ReplicatedStorage/Omni/Settings")
require("@game/ReplicatedStorage/Omni/DataTemplate")
local v = {
	Weather = {
		Resolver = Shared.Weather.SystemSolver
	},
	Fighters = {
		Resolver = Shared.Fighters.SystemSolver
	},
	["Player Level"] = {
		Resolver = Shared.PlayerLevel.SystemSolver
	},
	Achievements = {
		Resolver = Shared.Achievements.SystemSolver
	},
	["Index Rewards"] = {
		Resolver = Shared.Index.SystemSolver
	},
	Accessories = {
		Resolver = Shared.Accessories.SystemSolver
	},
	Progression = {
		Resolver = Shared.Progression.SystemSolver
	},
	Prestige = {
		Resolver = Shared.Prestige.SystemSolver
	},
	Profession = {
		Resolver = Shared.Profession.SystemSolver
	},
	SacredArtefacts = {
		Resolver = Shared.SacredArtefacts.SystemSolver
	},
	Upgrade = {
		Resolver = Shared.Upgrade.SystemSolver
	},
	Quests = {
		Resolver = Shared.Quests.SystemSolver
	},
	Weapons = {
		Resolver = Shared.Weapons.SystemSolver
	},
	Guilds = {
		Resolver = Shared.Guilds.SystemSolver
	},
	Gacha = {
		Resolver = Shared.Gacha.SystemSolver
	},
	Gamepasses = {
		Resolver = Shared.CommerceEffects.GetPerks
	},
	Potions = {
		Resolver = function(p: string, p2)
			local multiplier, amount = Shared.Potions.GetMultiplier(p, p2)
			return {
				{
					Type = "Add",
					Amount = multiplier
				},
				{
					Type = "Multi",
					Amount = amount
				}
			}
		end
	}
}
return table.freeze(v)