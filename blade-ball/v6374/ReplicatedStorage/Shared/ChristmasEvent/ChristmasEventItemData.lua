local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
game:GetService("RunService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Packages.Net)
require3(ReplicatedStorage2.Packages.Replion)
local v2 = require3(ReplicatedStorage2.ServerInfo)
local v3 = require3(ReplicatedStorage2.Common.RewardInfo)
local v4 = require3(ReplicatedStorage2.Shared.ChristmasEvent.ChristmasEventCrate)
local v5 = require3(ReplicatedStorage2.Common.Utils.Utilities.FFlag)
local remoteEvent = v:RemoteEvent("OpenSummerCrate")
local ChristmasEventItemData = {
	EventActive = false,
	GlobalNumberKey = "ChristmasGlobalContributions",
	ExclusiveCurrencyReward = 1000,
	DailyRewards = {
		{
			Reward = v3.createCandyCanesReward(25),
			ExclusiveReward = v3.createSwordReward("Frostbite Dagger")
		},
		{
			Reward = v3.createCandyCanesReward(50),
			ExclusiveReward = v3.createEmoteReward("Aurora Step")
		},
		{
			Reward = v3.createCandyCanesReward(75),
			ExclusiveReward = v3.createExplosionReward("Frozen Pop")
		},
		{
			Reward = v3.createCandyCanesReward(150),
			ExclusiveReward = v3.createSwordReward("Crystal Shard")
		},
		{
			Reward = v3.createCandyCanesReward(200),
			ExclusiveReward = v3.createEmoteReward("Snowstorm Shield")
		},
		{
			Reward = v3.createCandyCanesReward(350),
			ExclusiveReward = v3.createSwordReward("Aurora Carver")
		},
		{
			Reward = v3.createCandyCanesReward(500),
			ExclusiveReward = v3.createEmoteReward("Aurora's Glow")
		}
	},
	ItemShop = {
		{
			Cost = 350,
			Reward = v3.createEmoteReward("Tinsel Dance"),
			ItemType = "Emote"
		},
		{
			Cost = 400,
			Reward = v3.createExplosionReward("Winterplosion"),
			ItemType = "Explosion"
		},
		{
			Cost = 500,
			Reward = v3.createSwordReward("Candycane Cleaver"),
			ItemType = "Sword"
		},
		{
			Cost = 500,
			Reward = v3.createEmoteReward("Winter Wreath Toss"),
			ItemType = "Emote"
		},
		{
			Cost = 1250,
			Reward = v3.createEmoteReward("Sleigh Slap"),
			ItemType = "Emote"
		},
		{
			CustomReward = true,
			CustomImage = "rbxassetid://112563996286110",
			CustomDisplayName = "Santa's Crate",
			Cost = 125,
			Reward = function(player, _)
				local integer = Random.new():NextInteger(1, 1073741823)
				local _, v6 = v4.SpinTable(v4.Items, integer)

				if not v6 then
					return false
				end

				require3(game.ServerScriptService.Game.Server.AwardService):AwardFromRewardInfo(player, v6.Reward, {
					EndTime = math.max(
						v5.GetFFlag("ChristmasEventEndTime", DateTime.fromUniversalTime(2024, 12, 7, 17).UnixTimestamp),
						workspace:GetServerTimeNow()
					)
				}, false)
				remoteEvent:FireClient(player, v6.Reward, integer)
				return true
			end,
			ItemType = "Crate"
		}
	},
	CandyCanesProducts = {},
	Milestones = {
		{
			Reward = v3.createSwordReward("Frosted Slash")
		},
		{
			Reward = v3.createEmoteReward("Polar Roar")
		},
		{
			Reward = v3.createGachaSpinsReward(2, "Christmas Spins")
		},
		{
			Reward = v3.createExplosionReward("Icicle Impact")
		},
		{
			Reward = v3.createCandyCanesReward(500)
		},
		{
			Reward = v3.createGachaSpinsReward(5, "Christmas Spins")
		},
		{
			Reward = v3.createEmoteReward("Winter Serenade")
		},
		{
			Reward = v3.createSwordReward("Aurora Warden")
		}
	},
	GetMilestoneXP = function(p)
		local fFlag = v5.GetFFlag("ChristmasEventLocalMilestones")

		if type(fFlag) == "table" and fFlag[p] then
			return {
				Global = 0,
				Local = fFlag[p]
			}
		end
	end
}

function ChristmasEventItemData.EventEnded()
	if not ChristmasEventItemData.EventActive then
		return true
	end

	if v2.isRankedMatchServer() or v2.isDuelMatchServer() or v2.isTournamentMatchServer() or v2.isDungeonsMatchServer() or v2.isDungeonsLobbyServer() or v2.isTrainingServer() then
		return true
	end

	if v2.isDevPlaceGame() then
		return false
	end

	local serverTimeNow = workspace:GetServerTimeNow()
	return serverTimeNow < v5.GetFFlag("ChristmasEventStartTimeNew", 1e999) or v5.GetFFlag("ChristmasEventEndTime", 0) < serverTimeNow
end

return ChristmasEventItemData