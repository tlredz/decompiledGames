local ReplicatedStorage = game:GetService("ReplicatedStorage")
local adRewards = require(ReplicatedStorage.Shared.Flags.GameplayBalance).AdRewards
require(script.Parent.Parent.Internal.ProductTypes)
local CollectionService = game:GetService("CollectionService")
game:GetService("Players")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local t = require(ReplicatedStorage2.Packages.t)

local function CreateBillboardRewardConfig(p: string, productId: number)
	t.strict(t.string)(p)
	t.strict(t.number)(productId)

	local function authorize(p3)
		local Database = require(ServerScriptService.Library.Database)
		local unsafeGetProfileAwait, v = Database.UnsafeGetProfileAwait(p3)

		if unsafeGetProfileAwait and v then
			return true
		end

		return false, "Player data is not loaded yet."
	end

	local function grant(instance)
		local leaderstats = instance:FindFirstChild("leaderstats")
		local moneys = leaderstats and leaderstats:FindFirstChild("Money/s")

		if not (moneys and moneys:IsA("NumberValue")) then
			warn("[BillboardReward] No Money/s leaderstat for " .. instance.Name)
			return false, "Missing leaderstat"
		end

		local tagged = CollectionService:GetTagged("RVBillboard")
		local v = 0

		for _, v3 in tagged do
			local serverCode = v3:FindFirstChild("ServerCode")
			local rewardSelector = serverCode and serverCode:FindFirstChild("RewardSelector")

			if not rewardSelector then
				continue
			end

			local success, result = pcall(require, rewardSelector)

			if not (success and result and result.CalculateReward) then
				continue
			end

			v = result:CalculateReward(moneys.Value, productId)
			break
		end

		if v <= 0 then
			v = moneys.Value * adRewards.FALLBACK_DURATION
		end

		if v <= 0 then
			warn("[BillboardReward] Calculated reward is 0 for " .. instance.Name)
			return false, "Reward amount is zero"
		end

		local MoneyService = require(ServerScriptService.Controllers.MoneyService)
		MoneyService.AddMoney(instance, v, {
			source = "BillboardReward",
			feature = "Ads"
		})
		local NotifyItem = require(ServerScriptService.Library.Functions.NotifyItem)
		NotifyItem(instance, {
			Kind = "Currency",
			Id = "Money",
			Amount = math.round(v)
		})
		return true
	end

	return {
		Name = p,
		ProductId = productId,
		DisplayName = p,
		Desc = "Rewarded video billboard cash reward.",
		Giftable = false,
		HoldWhilePending = true,
		Silent = true,
		Authorize = authorize,
		Grant = grant
	}
end

return CreateBillboardRewardConfig