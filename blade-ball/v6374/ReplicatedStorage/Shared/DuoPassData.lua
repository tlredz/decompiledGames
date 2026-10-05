local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Packages.Net)
local v2 = require3(ReplicatedStorage2.Common.RewardInfo)

local function getEvent(p: string)
	return v:RemoteEvent((`DuoPass/{p}`))
end

local function getFunction(p: string)
	return v:RemoteFunction((`DuoPass/{p}`))
end

return {
	NumberId = 5,
	Id = string.lower("pixel01"),
	NormalPresentCredits = 2000,
	NormalPresent = {
		[v2.createCoinsReward(500, "Med")] = 35,
		[v2.createWheelSpinReward(1)] = 10,
		[v2.createWheelSpinReward(5)] = 5,
		[v2.createWheelSpinReward(3)] = 10,
		[v2.createCoinsReward(1000, "Med")] = 30,
		[v2.createCoinsReward(3000, "Big")] = 10
	},
	RobuxPresent = {
		[v2.createCoinsReward(500, "Med")] = 25,
		[v2.createWheelSpinReward(1)] = 10,
		[v2.createWheelSpinReward(5)] = 20,
		[v2.createWheelSpinReward(5)] = 15,
		[v2.createCoinsReward(2500, "Med")] = 20,
		[v2.createCoinsReward(5000, "Big")] = 10
	},
	RewardsPerKills = {
		[50] = v2.createCoinsReward(250, "Big"),
		[250] = v2.createCrateKeyReward("PremiumExplosion", 1, "Premium Explosion Crate", "rbxassetid://15049303003"),
		[500] = v2.createCoinsReward(2500, "Big"),
		[1000] = v2.createWheelSpinReward(2),
		[1500] = v2.createSwordReward("Enchanted Cleaver"),
		[2000] = v2.createWheelSpinReward(5),
		[3000] = v2.createSwordReward("Onyx Katana"),
		[5000] = v2.createExplosionReward("Chroma Voltplosion")
	},
	Remotes = {
		PurchaseNormalGift = v:RemoteFunction("DuoPass/PurchaseNormalGift"),
		OpenRobuxGift = v:RemoteFunction("DuoPass/OpenRobuxGift"),
		Disband = v:RemoteFunction("DuoPass/Disband"),
		SendInvite = v:RemoteFunction("DuoPass/SendInvite"),
		InviteReceived = v:RemoteEvent("DuoPass/InviteReceived"),
		RemoveInvite = v:RemoteEvent("DuoPass/RemoveInvite"),
		SetReplication = v:RemoteEvent("DuoPass/SetReplication"),
		ClaimLeaderboardRewards = v:RemoteFunction("DuoPass/ClaimLeaderboardRewards")
	},
	LeaderboardRewards = {
		{
			Rank = 3,
			Reward = v2.createListReward({
				v2.createSwordReward("Moonlight Bow"),
				v2.createSwordReward("Dual Moonlight Blade")
			})
		},
		{
			Rank = 50,
			Reward = v2.createListReward({ v2.createSwordReward("Dual Moonlight Blade") })
		}
	},
	GetFFlagKey = function(p: string)
		return (`PixelDuoPass{p}`)
	end
}