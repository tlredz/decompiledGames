local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local RunService = game:GetService("RunService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Packages.Net)
require3(ReplicatedStorage2.Packages.Replion)
local v2 = require3(ReplicatedStorage2.ServerInfo)
local v3 = require3(ReplicatedStorage2.Common.RewardInfo)
require3(ReplicatedStorage2.Shared.CNYEvent.CNYEventCrate)
local v4 = require3(ReplicatedStorage2.Common.Utils.Utilities.FFlag)
v:RemoteEvent("OpenSummerCrate")
local CNYEventItemData = {
	EventActive = true,
	GlobalNumberKey = "CNYEventGlobalContributions",
	ExclusiveCurrencyReward = 1000,
	DailyRewards = {
		{
			Reward = v3.createLanternsReward(50),
			ExclusiveReward = v3.createSwordReward("Dunestrike Scimitar")
		},
		{
			Reward = v3.createLanternsReward(100),
			ExclusiveReward = v3.createEmoteReward("Frying Windmill")
		},
		{
			Reward = v3.createLanternsReward(250),
			ExclusiveReward = v3.createEmoteReward("Pumpin")
		},
		{
			Reward = v3.createLanternsReward(350),
			ExclusiveReward = v3.createEmoteReward("Swoosh")
		},
		{
			Reward = v3.createLanternsReward(500),
			ExclusiveReward = v3.createSwordReward("Titanbreaker Zweilhander")
		},
		{
			Reward = v3.createLanternsReward(750),
			ExclusiveReward = v3.createSwordReward("Solaredge Longsword")
		},
		{
			Reward = v3.createLanternsReward(1000),
			ExclusiveReward = v3.createAbilityFreeTrialReward("Dragon Spirit", 7200)
		}
	},
	ItemShop = {},
	LanternProducts = {
		[2661551374] = v3.createLanternsReward(200),
		[2661551375] = v3.createLanternsReward(500),
		[2661551379] = v3.createLanternsReward(1000),
		[2661551378] = v3.createLanternsReward(3000),
		[2661551377] = v3.createLanternsReward(7500)
	},
	Milestones = {
		{
			Reward = v3.createExplosionReward("Sparkburst")
		},
		{
			Reward = v3.createExplosionReward("Frost Bloom")
		},
		{
			Reward = v3.createExplosionReward("Ember Splash")
		},
		{
			Reward = v3.createExplosionReward("Static Pulse")
		},
		{
			Reward = v3.createExplosionReward("Solar Shockwave")
		},
		{
			Reward = v3.createEmoteReward("Lush")
		},
		{
			Reward = v3.createSwordReward("Chrono Edge")
		},
		{
			Reward = v3.createSwordReward("Astral Riftblade")
		}
	},
	GetMilestoneXP = function(p)
		local fFlag = v4.GetFFlag("CNYEventGlobalMilestones")
		local fFlag2 = v4.GetFFlag("CNYEventLocalMilestones")

		if type(fFlag) == "table" and type(fFlag2) == "table" and fFlag[p] and fFlag2[p] then
			return {
				Global = fFlag[p] * 1000000,
				Local = fFlag2[p]
			}
		end
	end
}

function CNYEventItemData.EventEnded()
	if not CNYEventItemData.EventActive then
		return true
	end

	if v2.isDevPlaceGame() then
		return false
	end

	if v2.isRankedMatchServer() or v2.isDuelMatchServer() or v2.isTournamentMatchServer() or v2.isDungeonsMatchServer() or v2.isDungeonsLobbyServer() or v2.isTrainingServer() then
		return true
	end

	if v2.isTestGame() or RunService:IsStudio() then
		return false
	end

	local serverTimeNow = workspace:GetServerTimeNow()
	return serverTimeNow < v4.GetFFlag("CNYEventStartTime") or v4.GetFFlag("CNYEventEndTime") < serverTimeNow
end

return CNYEventItemData