local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Monetization = require(ReplicatedStorage.shared.Monetization)
local DailyShopConfig = {
	RerollSources = {
		["C$"] = {
			Default = 1,
			ConfirmOdds = "IfRestricted",
			Cost = 50000,
			Display = "C$",
			Label = "50,000"
		},
		Paid = {
			Default = 3,
			ConfirmOdds = "Always",
			ProductId = Monetization.products.Others.RefreshDailyShop.ProductId,
			RestrictedByPolicy = true,
			Display = ""
		},
		Ad = {
			Default = 1,
			ConfirmOdds = "IfRestricted",
			Experiment = "DailyShopAdReroll",
			RequiresSpent = "C$",
			RequiresAd = true,
			HideWhenEmpty = true,
			Label = "Watch Ad"
		}
	},
	RefreshButtons = {
		{
			Button = "RefreshC$",
			Sources = { "Ad", "C$" }
		},
		{
			Button = "RefreshPaid",
			Sources = { "Paid" }
		}
	}
}

function DailyShopConfig.IsSourceUnlocked(instance, p: string, p2)
	local rerollSource = DailyShopConfig.RerollSources[p]

	if not rerollSource or rerollSource.Experiment and instance:GetAttribute((`A/B_{rerollSource.Experiment}`)) ~= true or rerollSource.RequiresSpent and (p2[rerollSource.RequiresSpent] or 0) > 0 then
		return false
	end

	if rerollSource.RequiresAd then
		if (instance:GetAttribute("VideoAdsRemaining") or 0) <= 0 or instance:GetAttribute("VideoAdAvailable") ~= true then
			return false
		end
	end

	return not (rerollSource.HideWhenEmpty and (p2[p] or 0) <= 0)
end

function DailyShopConfig.ResolveSource(p, p2, p3)
	for _, source in p2.Sources do
		if DailyShopConfig.IsSourceUnlocked(p, source, p3) then
			return source
		end
	end

	return p2.Sources[#p2.Sources]
end

return DailyShopConfig