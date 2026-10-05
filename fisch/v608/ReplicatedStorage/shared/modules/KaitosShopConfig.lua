local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Monetization = require(ReplicatedStorage.shared.Monetization)
local KaitosShopConfig = {
	MaxItems = 5,
	ShopTime = 604800,
	Currency = "Coins",
	OddsKey = "kaitosShop",
	HuntTotems = {
		"Megalodon Hunt Totem",
		"Kraken Hunt Totem",
		"Scylla Hunt Totem",
		"Colossal Dragon Hunt Totem"
	}
}
KaitosShopConfig.Pool = {
	{
		Id = "Golden Firefly",
		Guaranteed = true,
		RewardType = "ItemOrFish",
		Price = 50000,
		Stock = 1
	},
	{
		Id = "Artisan Rod",
		GuaranteedUntilPurchased = true,
		RewardType = "Rod",
		Price = 80000,
		Stock = 1
	},
	{
		Id = "Artisan Spear",
		GuaranteedUntilPurchased = true,
		RewardType = "Spear",
		Price = 30000,
		Stock = 1
	},
	{
		Id = "Sovereign Relic",
		Weight = 3,
		RewardType = "ItemOrFish",
		Price = 500000,
		Stock = 1,
		WeeklyMax = 2
	},
	{
		Id = "Cosmic Relic",
		Weight = 8,
		RewardType = "ItemOrFish",
		Price = 50000,
		Stock = { 1, 2 },
		WeeklyMax = 4
	},
	{
		Id = "Crested Relic",
		Weight = 15,
		RewardType = "ItemOrFish",
		Price = 90000,
		Stock = 1,
		WeeklyMax = 2
	},
	{
		Id = "Empyrean Relic",
		Weight = 1,
		RewardType = "ItemOrFish",
		Price = 1500000,
		Stock = 1,
		WeeklyMax = 1
	},
	{
		Id = "Tropical Squall Totem",
		Weight = 10,
		RewardType = "ItemOrFish",
		Price = 800000,
		Stock = 1,
		WeeklyMax = 2
	},
	{
		Id = "Aurora Totem",
		Weight = 8,
		RewardType = "ItemOrFish",
		Price = 150000,
		Stock = { 2, 3 },
		WeeklyMax = 6
	},
	{
		Id = "Rainbow Totem",
		Weight = 8,
		RewardType = "ItemOrFish",
		Price = 150000,
		Stock = 1,
		WeeklyMax = 2
	},
	{
		Id = "Disturbance Catalyst",
		Weight = 9,
		RewardType = "ItemOrFish",
		Price = 50000,
		Stock = 1,
		WeeklyMax = 2
	},
	{
		Id = "Exalted Relic",
		Weight = 15,
		RewardType = "ItemOrFish",
		Price = 50000,
		Stock = { 2, 3 },
		WeeklyMax = 6
	},
	{
		Id = "Any Hunt Totem",
		Weight = 12,
		RewardType = "ItemOrFish",
		Price = 80000,
		Stock = { 1, 2 },
		WeeklyMax = 4,
		RandomFrom = KaitosShopConfig.HuntTotems
	}
}
local refreshKaitosShop = Monetization.products.Others.RefreshKaitosShop
KaitosShopConfig.RerollSources = {
	["C$"] = {
		Default = 1,
		ConfirmOdds = "IfRestricted",
		Cost = 350000,
		Display = "C$",
		Label = "350,000"
	},
	Paid = {
		Default = 3,
		ConfirmOdds = "Always",
		ProductId = refreshKaitosShop and refreshKaitosShop.ProductId,
		RestrictedByPolicy = true,
		Display = ""
	}
}
KaitosShopConfig.RefreshButtons = {
	{
		Button = "RefreshC$",
		Sources = { "C$" }
	},
	{
		Button = "RefreshPaid",
		Sources = { "Paid" }
	}
}

function KaitosShopConfig.GetEntry(p: string)
	for _, v in KaitosShopConfig.Pool do
		if v.Id == p then
			return v
		end
	end

	return nil
end

function KaitosShopConfig.IsSourceUnlocked(_, p: string, p2)
	local rerollSource = KaitosShopConfig.RerollSources[p]

	if not rerollSource or rerollSource.ProductId == nil and rerollSource.Cost == nil then
		return false
	end

	return not (rerollSource.HideWhenEmpty and (p2[p] or 0) <= 0)
end

function KaitosShopConfig.ResolveSource(p, p2, p3)
	for _, source in p2.Sources do
		if KaitosShopConfig.IsSourceUnlocked(p, source, p3) then
			return source
		end
	end

	return p2.Sources[#p2.Sources]
end

function KaitosShopConfig.GetNextRefresh(p: number)
	return 1767459600 + (math.floor((p - 1767459600) / KaitosShopConfig.ShopTime) + 1) * KaitosShopConfig.ShopTime
end

return KaitosShopConfig