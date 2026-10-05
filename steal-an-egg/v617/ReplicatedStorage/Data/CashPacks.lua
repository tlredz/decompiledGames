local CashPacks = {
	TestName = "ScaledCashPacks",
	AttributeKey = "Economy.CashPacks.Group",
	GroupAttribute = "CashPackGroup",
	ReadyAttribute = "CashPacksReady",
	RevisionAttribute = "CashPackQuoteRevision",
	AmountAttributePrefix = "CashPackAmount",
	Offers = {
		{
			Name = "CashPack1",
			FixedProductName = "Money_24000",
			ProductId = 3714500805,
			DisplayName = "Cash Pack I",
			Minutes = 40,
			Floor = 24000
		},
		{
			Name = "CashPack2",
			FixedProductName = "Money_200000",
			ProductId = 3714500817,
			DisplayName = "Cash Pack II",
			Minutes = 120,
			Floor = 200000
		},
		{
			Name = "CashPack3",
			FixedProductName = "Money_800000",
			ProductId = 3714500825,
			DisplayName = "Cash Pack III",
			Minutes = 360,
			Floor = 800000
		},
		{
			Name = "CashPack4",
			FixedProductName = "Money_4000000",
			ProductId = 3714500832,
			DisplayName = "Cash Pack IV",
			Minutes = 1080,
			Floor = 4000000
		},
		{
			Name = "CashPack5",
			FixedProductName = "Money_8000000",
			ProductId = 3714500837,
			DisplayName = "Cash Pack V",
			Minutes = 2880,
			Floor = 8000000
		}
	}
}
local v = {
	1,
	1.2,
	1.5,
	2,
	2.5,
	3,
	4,
	5,
	6,
	8,
	10
}

function CashPacks.RoundNice(p: number)
	if p <= 0 then
		return 0
	end

	assert(p < 1e999, "Cash pack amount must be finite")
	local v2 = 10 ^ math.floor((math.log10(p)))
	local v3 = p / v2
	local v4 = v[1]
	local v5 = 1e999

	for _, v6 in v do
		local v7 = math.abs(math.log10(v6) - math.log10(v3))

		if not (v7 < v5) then
			continue
		end

		v4 = v6
		v5 = v7
	end

	return v4 * v2
end

function CashPacks.Amount(p, p2: number)
	return (math.max(p.Floor, CashPacks.RoundNice(p.Minutes * 60 * p2)))
end

function CashPacks.RefreshQuote(data, data2)
	if data2.Day <= data.Day then
		return data
	end

	local clone = table.clone(data)
	clone.Day = data2.Day
	local v2 = data2.PeakBaseRate >= data.PeakBaseRate * data2.GrowthMultiplier

	if #data.Amounts ~= 0 and not v2 then
		return clone
	end

	clone.PeakBaseRate = math.max(data.PeakBaseRate, data2.PeakBaseRate)
	clone.Amounts = {}

	for k, offer in data2.Offers do
		clone.Amounts[k] = math.max(data.Amounts[k] or 0, CashPacks.Amount(offer, clone.PeakBaseRate))
	end

	return clone
end

function CashPacks.FindSlot(p: number)
	for k, offer in CashPacks.Offers do
		if offer.ProductId == p then
			return k
		end
	end

	return nil
end

function CashPacks.NormalizeGroup(p)
	if p == "VariantA" or p == "VariantB" then
		return p
	end

	return "Control"
end

function CashPacks.GetCanBuyProduct(p: string?, value: string)
	local v2 = string.sub(value, 1, 10) == "Treadmill_"
	local v3 = string.sub(value, 1, 6) == "Trail_"

	if v2 or v3 then
		if p == nil then
			return false
		end

		return p ~= "VariantB" or value == "Treadmill_AstralTreadmill" or value == "Trail_MoonbloomTrail"
	else
		return true
	end
end

function CashPacks.GetPlayerGroup(instance)
	if instance:GetAttribute(CashPacks.ReadyAttribute) == true then
		return CashPacks.NormalizeGroup(instance:GetAttribute(CashPacks.GroupAttribute))
	end

	return nil
end

function CashPacks.GetShownAmount(instance, p: number)
	if instance:GetAttribute(CashPacks.ReadyAttribute) ~= true then
		return nil
	end

	local attribute = instance:GetAttribute(CashPacks.AmountAttributePrefix .. p)

	if type(attribute) == "number" then
		return attribute
	end

	return nil
end

return CashPacks