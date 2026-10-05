local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local v = require3(ReplicatedStorage2.Packages.Replion)
local v2 = require3(ReplicatedStorage2.Common.RewardInfo)
local v3 = require3("@game/ReplicatedStorage/Shared/InfiniteBattlepass/InfiniteBattlepassData")
local v4 = {
	Items = {
		Jeweled_Blade = {
			Reward = v2.createSwordReward("Jeweled Blade"),
			Price = 1500,
			Limit = 1,
			ClanLevel = 3,
			Type = "Permament",
			Rarity = "Epic",
			Description = ""
		},
		[`BattlepassCrate_Season{v3.Season}`] = {
			Reward = v2.createBattlepassExplosionCrateReward(1),
			Price = 25,
			Limit = 15,
			ClanLevel = 3,
			Type = "Weekly",
			Rarity = "Epic",
			Description = `Get a free {v3.SeasonData.Crate.DisplayName}!`
		},
		[`Gacha_Season{v3.Season}`] = {
			Reward = v2.createGachaSpinsReward(1),
			Price = 55,
			Limit = 8,
			ClanLevel = 3,
			Type = "Weekly",
			Rarity = "Epic",
			Description = `Get a free roll in the {v3.SeasonData.Gacha}!`
		},
		PremiumSwordCrate = {
			Reward = v2.createCrateKeyReward("PremiumSword", 1, "Premium Sword Crate", "rbxassetid://16039967646"),
			Price = 15,
			Limit = 40,
			ClanLevel = 3,
			Type = "Weekly",
			Rarity = "Common",
			Description = " A premium crate that contains cool swords."
		},
		Waypoint = {
			Reward = v2.createAbilityReward("Waypoint"),
			Price = 1500,
			Limit = 1,
			ClanLevel = 5,
			Type = "Permament",
			Rarity = "Common",
			Description = "Place a sword marker on the ground. You can then re-use the ability to teleport to the sword marker."
		},
		LimitedStockSword_7 = {
			Reward = v2.createSwordReward("Starshooter Rapier"),
			Price = 20000,
			Limit = 1,
			ClanLevel = 3,
			Description = "",
			Type = "Permament",
			Rarity = "Legendary",
			IsLimitedStock = true,
			LimitedStockId = "Starshooter Rapier",
			CanBePurchased = function(_)
				local v6

				if RunService:IsClient() then
					v6 = v.Client:WaitReplion("LimitedStockItems")
				else
					v6 = v.Server:WaitReplion("LimitedStockItems")
				end

				if not (v6 and v6:Get("Loaded")) then
					return false
				end

				local v7 = v6:Get({ "Stock", "Starshooter Rapier" })

				if v7 and not (v7 <= 0) then
					return true
				end

				return false
			end
		},
		Solaris_Halo = {
			Reward = v2.createSwordReward("Solaris Halo"),
			Price = 5000,
			Limit = 1,
			ClanLevel = 6,
			Type = "Permament",
			Rarity = "Legendary",
			Description = ""
		}
	},
	RefreshTimes = {
		Weekly = 604800,
		Monthly = 2678400
	},
	MinClanLevel = 3
}
return table.freeze(v4)