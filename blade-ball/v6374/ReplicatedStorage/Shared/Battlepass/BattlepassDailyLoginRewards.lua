local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Common.RewardInfo)
require3(ReplicatedStorage2.Shared.EmoteIds)
local v2 = require3(ReplicatedStorage2.Common.Utils)
local v3 = require3(ReplicatedStorage2.Packages.Replion)
local v4 = require3("@game/ReplicatedStorage/Shared/InfiniteBattlepass/InfiniteBattlepassData")
local name = v4.SeasonData.Currency.Name

local function awardSeasonPassCurrency(p, p2)
	local v5 = require3(ServerScriptService.Game.Services.AnalyticsService)
	local replionFor = v3.Server:GetReplionFor(p, "Data")

	if not replionFor then
		return false
	end

	replionFor:Increase("InfiniteBattlepass.Currency", p2)
	v5:TrackCurrency(p, name, p2, "DailyLogin")
	return true
end

return {
	{
		Icon = v4.SeasonData.Currency.Icon,
		Function = awardSeasonPassCurrency,
		Arguments = { 30 }
	},
	{
		Icon = v2.Icons:GetSwordIcon("Rosewood Saber") or "",
		RewardInfo = v.createSwordReward("Rosewood Saber"),
		Function = function(p)
			return require3(ServerScriptService.Game.Services.Battlepass.BattlepassAwardService):AwardFromRewardInfo(
				p,
				v.createSwordReward("Rosewood Saber"),
				nil,
				true
			)
		end,
		Arguments = {}
	},
	{
		Icon = v4.SeasonData.Currency.Icon,
		Function = awardSeasonPassCurrency,
		Arguments = { 75 }
	},
	{
		Icon = v4.SeasonData.Currency.Icon,
		Function = awardSeasonPassCurrency,
		Arguments = { 30 }
	},
	{
		Icon = v4.SeasonData.Currency.Icon,
		Function = awardSeasonPassCurrency,
		Arguments = { 30 }
	},
	{
		Icon = v4.SeasonData.Currency.Icon,
		Function = awardSeasonPassCurrency,
		Arguments = { 30 }
	},
	{
		Icon = v4.SeasonData.Currency.Icon,
		Function = awardSeasonPassCurrency,
		Arguments = { 100 }
	},
	{
		Icon = v4.SeasonData.Currency.Icon,
		Function = awardSeasonPassCurrency,
		Arguments = { 30 }
	},
	{
		Icon = v4.SeasonData.Currency.Icon,
		Function = awardSeasonPassCurrency,
		Arguments = { 30 }
	},
	{
		Icon = v4.SeasonData.Currency.Icon,
		Function = awardSeasonPassCurrency,
		Arguments = { 30 }
	},
	{
		Icon = v4.SeasonData.Currency.Icon,
		Function = awardSeasonPassCurrency,
		Arguments = { 100 }
	},
	{
		Icon = v4.SeasonData.Currency.Icon,
		Function = awardSeasonPassCurrency,
		Arguments = { 30 }
	},
	{
		Icon = v4.SeasonData.Currency.Icon,
		Function = awardSeasonPassCurrency,
		Arguments = { 75 }
	},
	{
		Icon = v4.SeasonData.Currency.Icon,
		Function = awardSeasonPassCurrency,
		Arguments = { 30 }
	},
	{
		Icon = v4.SeasonData.Currency.Icon,
		Function = awardSeasonPassCurrency,
		Arguments = { 30 }
	},
	{
		Icon = v4.SeasonData.Currency.Icon,
		Function = awardSeasonPassCurrency,
		Arguments = { 30 }
	},
	{
		Icon = v4.SeasonData.Currency.Icon,
		Function = awardSeasonPassCurrency,
		Arguments = { 30 }
	},
	{
		Icon = v4.SeasonData.Currency.Icon,
		Function = awardSeasonPassCurrency,
		Arguments = { 100 }
	},
	{
		Icon = v4.SeasonData.Currency.Icon,
		Function = awardSeasonPassCurrency,
		Arguments = { 45 }
	},
	{
		Icon = v4.SeasonData.Currency.Icon,
		Function = awardSeasonPassCurrency,
		Arguments = { 45 }
	},
	{
		Icon = v4.SeasonData.Currency.Icon,
		Function = awardSeasonPassCurrency,
		Arguments = { 45 }
	},
	{
		Icon = v4.SeasonData.Currency.Icon,
		Function = awardSeasonPassCurrency,
		Arguments = { 100 }
	},
	{
		Icon = v4.SeasonData.Currency.Icon,
		Function = awardSeasonPassCurrency,
		Arguments = { 45 }
	},
	{
		Icon = v4.SeasonData.Currency.Icon,
		Function = awardSeasonPassCurrency,
		Arguments = { 45 }
	},
	{
		Icon = v4.SeasonData.Currency.Icon,
		Function = awardSeasonPassCurrency,
		Arguments = { 45 }
	},
	{
		Icon = v4.SeasonData.Currency.Icon,
		Function = awardSeasonPassCurrency,
		Arguments = { 110 }
	},
	{
		Icon = v4.SeasonData.Currency.Icon,
		Function = awardSeasonPassCurrency,
		Arguments = { 130 }
	},
	{
		Icon = v4.SeasonData.Currency.Icon,
		Function = awardSeasonPassCurrency,
		Arguments = { 175 }
	},
	{
		Icon = v4.SeasonData.Currency.Icon,
		Function = awardSeasonPassCurrency,
		Arguments = { 220 }
	},
	{
		Icon = v2.Icons:GetEmoteIcon("Using a Calc (Calculator)"),
		RewardInfo = v.createEmoteReward("Using a Calc (Calculator)"),
		Function = function(p)
			return require3(ServerScriptService.Game.Services.Battlepass.BattlepassAwardService):AwardFromRewardInfo(
				p,
				v.createEmoteReward("Using a Calc (Calculator)"),
				nil,
				true
			)
		end,
		Arguments = {}
	}
}