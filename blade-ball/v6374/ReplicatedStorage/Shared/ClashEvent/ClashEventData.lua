local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Packages.Net)
local v2 = require3(ReplicatedStorage2.Common.RewardInfo)
return {
	EndTime = DateTime.fromUniversalTime(2024, 7, 14, 6, 0),
	RaffleDrawHour = 20,
	Remotes = {
		JoinTeam = v:RemoteFunction("ClashEvent/JoinTeam"),
		BuyItem = v:RemoteFunction("ClashEvent/BuyItem"),
		OpenedUI = v:RemoteEvent("ClashEvent/OpenedUI"),
		ClaimMilestone = v:RemoteFunction("ClashEvent/ClaimMilestone"),
		ClaimTeamReward = v:RemoteFunction("ClashEvent/ClaimTeamReward")
	},
	Products = {
		PremiumTrack = 1861224215,
		RefreshQuests = 1861223905
	},
	NumRaffleWinners = {
		Normal = 1000,
		Golden = 50
	},
	RaffleTicketAwardInterval = {
		Normal = 600,
		Golden = 3600
	},
	RaffleRewards = {
		Normal = {
			v2.createSwordReward("Pearl Shard"),
			v2.createExplosionReward("Leviathan's Rage"),
			v2.createEmoteReward("Emote416")
		},
		Golden = { v2.createAbilityReward("Infinity"), v2.createSwordReward("Cosmic Wrath") }
	},
	Shop = {
		{
			Reward = v2.createSwordReward("Buccaneer's Cutlass"),
			Price = 500
		},
		{
			Reward = v2.createSwordReward("Siren's Whisper"),
			Price = 2500
		},
		{
			Reward = v2.createSwordReward("Pearl Trident"),
			Price = 5000
		},
		{
			Reward = v2.createSwordReward("Abyssal Wave"),
			Price = 7500
		},
		{
			Reward = v2.createEmoteReward("Emote413"),
			Price = 300
		},
		{
			Reward = v2.createEmoteReward("Emote417"),
			Price = 1000
		},
		{
			Reward = v2.createExplosionReward("Desert Storm"),
			Price = 500
		},
		{
			Reward = v2.createExplosionReward("Pirate's Treasure"),
			Price = 2000
		},
		{
			Reward = v2.createSeasonPassCurrencyReward(200),
			Price = 250,
			MaxPurchases = 2
		},
		{
			Reward = v2.createAbilityFreeTrialReward("Dragon Spirit", 1800),
			Price = 250,
			MaxPurchases = 2
		},
		{
			Reward = v2.createAbilityFreeTrialReward("Bunny Leap", 1800),
			Price = 250,
			MaxPurchases = 2
		},
		{
			Reward = v2.createAbilityFreeTrialReward("Phantom", 1800),
			Price = 350,
			MaxPurchases = 2
		},
		{
			Reward = v2.createAbilityFreeTrialReward("Slash of Duality", 1800),
			Price = 500,
			MaxPurchases = 2
		}
	},
	Milestones = {
		{
			Basic = v2.createSwordReward("Sailor's Saber"),
			Premium = v2.createSwordReward("Pirate King's Cutlass")
		},
		{
			Basic = v2.createCrateKeyReward("PremiumSword", 1, "Premium Sword Crate", "rbxassetid://15049301853"),
			Premium = v2.createGachaSpinsReward(1, "Haunted Spins")
		},
		{
			Basic = v2.createEmoteReward("Emote418"),
			Premium = v2.createEmoteReward("Emote414")
		},
		{
			Basic = v2.createOctoCoinsReward(100),
			Premium = v2.createExplosionReward("Captain's Curse")
		},
		{
			Basic = v2.createEmoteReward("Emote415"),
			Premium = v2.createEmoteReward("Emote412")
		},
		{
			Basic = v2.createOctoCoinsReward(250),
			Premium = v2.createSwordReward("Scourge of the Seas")
		},
		{
			Basic = v2.createExplosionReward("Buccaneer's Boom"),
			Premium = v2.createExplosionReward("Coral Eruption")
		},
		{
			Basic = v2.createOctoCoinsReward(350),
			Premium = v2.createGachaSpinsReward(1, "Haunted Spins")
		},
		{
			Basic = v2.createOctoCoinsReward(500),
			Premium = v2.createOctoCoinsReward(1000)
		},
		{
			Basic = v2.createSwordReward("Leviathan's Fang"),
			Premium = v2.createSwordReward("Barnacle Blade")
		}
	}
}