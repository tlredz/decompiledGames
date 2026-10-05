local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Packages.Net)
local v2 = require3(ReplicatedStorage2.Common.RewardInfo)

local function getEvent(p: string)
	return v:RemoteEvent((`HalloweenEvent/{p}`))
end

local function getFunction(p: string)
	return v:RemoteFunction((`HalloweenEvent/{p}`))
end

return {
	RewardsPerKills = {
		v2.createSwordReward("Bonecrusher"),
		v2.createCandyReward(300),
		v2.createCandyReward(350),
		v2.createCandyReward(500),
		v2.createCandyReward(600),
		v2.createCandyReward(750),
		v2.createCandyReward(1000),
		v2.createCandyReward(1250),
		v2.createCandyReward(1500),
		v2.createCandyReward(2000),
		(v2.createSwordReward("Nightmare Cleaver"))
	},
	Shop = {
		{
			Cost = 250,
			Reward = v2.createExplosionReward("Phantom Burst")
		},
		{
			Cost = 500,
			Reward = v2.createExplosionReward("Spectral Detonation")
		},
		{
			Cost = 350,
			Reward = v2.createEmoteReward("Haunted Chuckle")
		},
		{
			Cost = 750,
			Reward = v2.createEmoteReward("Wraith's Howl")
		},
		{
			Cost = 500,
			Reward = v2.createSwordReward("Bone Shredder")
		},
		{
			Cost = 1500,
			Reward = v2.createSwordReward("Shadow Blade")
		}
	},
	Remotes = {
		BuyShopItem = v:RemoteFunction("HalloweenEvent/BuyShopItem")
	},
	GetFFlagKey = function(p: string)
		return (`HalloweenEvent{p}`)
	end
}