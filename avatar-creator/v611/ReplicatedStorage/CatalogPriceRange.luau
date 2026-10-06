local CatalogPriceRange = {
	IsOffSale = function(data)
		local v = type(data.PriceStatus) ~= "string" and "" or data.PriceStatus:lower():gsub("[%s_%-]", "") or ""

		if v == "offsale" or v == "noresellers" then
			return true
		end

		local lowestResalePrice = data.LowestResalePrice
		local v2

		if data.HasResellers == true and type(lowestResalePrice) == "number" and lowestResalePrice > 0 then
			v2 = lowestResalePrice < 1e999
		else
			v2 = false
		end

		return data.IsOffSale == true and not v2
	end,
	Price = function(data)
		local price = data.Price
		local itemRestrictions = data.ItemRestrictions or {}

		if (table.find(itemRestrictions, "LimitedUnique") or table.find(itemRestrictions, "Limited") or table.find(
			itemRestrictions,
			"Collectible"
		)) and data.HasResellers and (data.UnitsAvailableForConsumption or 0) == 0 and type(data.LowestResalePrice) == "number" and data.LowestResalePrice > 0 then
			price = data.LowestResalePrice
		end

		if type(price) ~= "number" or price ~= price or price < 0 then
			price = data.LowestPrice
		end

		if type(price) == "number" and price == price and price >= 0 and price < 1e999 then
			return price
		end

		return nil
	end
}

function CatalogPriceRange.IsFreeLimited(p)
	local itemRestrictions = p.ItemRestrictions or {}
	return (table.find(itemRestrictions, "LimitedUnique") or table.find(itemRestrictions, "Limited") or table.find(
		itemRestrictions,
		"Collectible"
	)) ~= nil and (p.Price == 0 or CatalogPriceRange.Price(p) == 0)
end

function CatalogPriceRange.Matches(p, p2, p3, p4)
	if CatalogPriceRange.IsFreeLimited(p) then
		return false
	end

	if CatalogPriceRange.IsOffSale(p) then
		return p4 == true
	end

	if p2 == nil and p3 == nil then
		return true
	end

	local price = CatalogPriceRange.Price(p)
	return price ~= nil and (p2 == nil or p2 <= price) and (p3 == nil or price <= p3)
end

function CatalogPriceRange.Filter(list, p, p2, p3)
	local result = {}

	for _, v in ipairs(list) do
		if CatalogPriceRange.Matches(v, p, p2, p3) then
			table.insert(result, v)
		end
	end

	return result
end

return CatalogPriceRange