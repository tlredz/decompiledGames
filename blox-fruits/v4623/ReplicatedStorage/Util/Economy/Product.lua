local Product = require(game.ReplicatedStorage.Economy.EconomyItem.Product)
local Settlement = require(script.Settlement)
local TierInfo = require(game.ReplicatedStorage.Economy.EconomyItem.Product.TierInfo)
local all = TierInfo.Templates.all()
local Product2 = {
	Modules = {
		Settlement = Settlement
	},
	Templates = {}
}
Product2.Templates.Simple = {}

function Product2.Templates.Simple.new(p)
	return (Product.Class.new({
		[all] = p
	}))
end

Product2.Templates.Tiered = {}

function Product2.Templates.Tiered.new(items)
	local v = {}

	for k, _ in items do
		table.insert(v, k)
	end

	table.sort(v, function(a: number, b: number)
		return a < b
	end)
	local v2 = {}

	for k, v3 in v do
		local v4 = v[k - 1]
		local v5 = v[k + 1]
		local v6

		if v4 then
			if v5 then
				v6 = TierInfo.Templates.range(v4 + 1, v3)
			else
				v6 = TierInfo.Templates.min(v3)
			end
		else
			v6 = TierInfo.Templates.max(v3)
		end

		v2[v6] = items[v3]
	end

	return (Product.Class.new(v2))
end

function Product2.Templates.Tiered.complex(items)
	local v = {}

	for k, _ in items do
		table.insert(v, k)
	end

	table.sort(v, function(a: NumberRange, b: NumberRange)
		return a.Min < b.Min
	end)
	local v2 = {}

	for _, v3 in v do
		local max = v3.Max
		local min = v3.Min
		v2[TierInfo.Templates.range(min, max)] = items[v3]
	end

	return (Product.Class.new(v2))
end

return Product2