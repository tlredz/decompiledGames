local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
game:GetService("ServerScriptService")
local v = require3(ReplicatedStorage2.Common.MarketplaceService)
local v2 = require3(ReplicatedStorage2.Packages.Replion)
local v3 = require3(ReplicatedStorage2.Common.VIPPlusInfo)
local v4 = require3(ReplicatedStorage2.Shared.ClanPassesData)
local Subscriptions = {
	VIPPlus = {
		Disabled = true,
		DisplayName = "VIP+",
		Name = "VIPPlus",
		ID = "EXP-3779330262602350693",
		SubscriptionPrice = "$ ???",
		TestServerID = "EXP-6025518231484891237",
		RobuxEquivalent = 999,
		ProductId = 1688955853,
		ProductPrice = "???",
		Duration = 2592000,
		Activate = function(p)
			local replionFor = v2.Server:GetReplionFor(p, "Data")

			if not replionFor or replionFor.Destroyed then
				return false
			end

			local ServerScriptService = game:GetService("ServerScriptService")
			require3(ServerScriptService.Game.CoreGameModules.Datastore).accreditVIP(p, true)
			require3(ServerScriptService.Game.Server.AwardService):AwardFromRewardInfoList(p, v3.Instant)
			return true
		end,
		Revoke = function(p)
			local ServerScriptService = game:GetService("ServerScriptService")
			local v5 = require3(ServerScriptService.Game.Server.AwardService)
			local v6 = v2.Server:WaitReplionFor(p, "Data", 10)

			if not v6 then
				return false
			end

			if v6:Get("Subscriptions.VIPPlus.GrantedOneTimeBenefits") and v5:RevokeFromRewardInfoList(p, v3.Instant) then
				v6:Set("Subscriptions.VIPPlus.GrantedOneTimeBenefits", false)
			end

			for k, monthlyReward in v3.MonthlyRewards do
				if not v6:Get({ "VIPPlusCalendar", "ClaimedRewardsMonth", k }) then
					v6:Set({ "VIPPlusCalendar", "ClaimedRewardsMonth", k }, {})
				end

				for k2, v7 in monthlyReward do
					if not v6:Get({
						"VIPPlusCalendar",
						"ClaimedRewardsMonth",
						k,
						k2
					}) then
						continue
					end

					if v5:RevokeFromRewardInfoList(p, v7) then
						v6:Set({
							"VIPPlusCalendar",
							"ClaimedRewardsMonth",
							k,
							k2
						}, false)
					else
						print("failed to revoke")
						return false
					end
				end
			end

			return true
		end,
		Deactivate = function(_)
			return true
		end
	},
	ClanPointsMonthly = {
		DisplayName = "Clan Points Monthly Pass",
		Name = "ClanPointsMonthly",
		ID = "EXP-7934027470910259309",
		SubscriptionPrice = "$ ???",
		TestServerID = "EXP-3286897663245287638",
		RobuxEquivalent = 499,
		ProductId = 1708274980,
		ProductPrice = "???",
		Duration = 2592000,
		Activate = function(p)
			local replionFor = v2.Server:GetReplionFor(p, "Data")

			if not replionFor or replionFor.Destroyed then
				return false
			end

			local ServerScriptService = game:GetService("ServerScriptService")
			require3(ServerScriptService.Game.CoreGameModules.Datastore)
			local v5 = require3(ServerScriptService.Game.Server.AwardService)

			if not v5:AwardFromRewardInfoList(p, v4.Rewards.Monthly.Instant) then
				return false
			end

			if not replionFor:Get("ClanPointsPass.Monthly.FirstTimeBonusClaimed") then
				if not v5:AwardFromRewardInfoList(p, v4.Rewards.Monthly.FirstSubscriptionBonus) then
					return false
				end

				replionFor:Set("ClanPointsPass.Monthly.FirstTimeBonusClaimed", true)
			end

			require3(ServerScriptService.Game.Services.ClanPointsPassService):ClaimDailyRaw(p, "Monthly", 1)
			return true
		end,
		Revoke = function(p)
			local ServerScriptService = game:GetService("ServerScriptService")
			require3(ServerScriptService.Game.Server.AwardService)

			if v2.Server:WaitReplionFor(p, "Data", 10) then
				return true
			end

			return false
		end,
		Deactivate = function(p)
			local v5 = v2.Server:WaitReplionFor(p, "Data", 10)

			if not v5 then
				return false
			end

			v5:Update("ClanPointsPass.Monthly", {
				ClaimedDays = {}
			})
			return true
		end
	}
}

for k, v5 in Subscriptions do
	v5.Name = k

	if game.GameId ~= 4777817887 and v5.TestServerID ~= nil then
		v5.ID = v5.TestServerID
	end

	local v6 = v5
	task.spawn(pcall, function()
		v6.ProductPrice = v:GetProductInfo(v6.ProductId, Enum.InfoType.Product).PriceInRobux
	end)
	local RunService = game:GetService("RunService")

	if not RunService:IsClient() then
		continue
	end

	local v7 = v5
	task.spawn(pcall, function()
		v7.SubscriptionPrice = v:GetSubscriptionProductInfoAsync(v7.ID).DisplayPrice
	end)
end

return Subscriptions