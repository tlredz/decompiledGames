local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
require3(ReplicatedStorage2.Packages.Freeze)
local v = require3(ReplicatedStorage2.Common.Utils.Utilities.FFlag)
local v2 = require3(script.Parent.TradeInfo)
local v3 = require3(ReplicatedStorage2.Shared.LimitedSwordPacksData)
local v4 = require3(ReplicatedStorage2.Shared.GiftProductsId)
local v5 = {}
local v6 = {}
local v7 = {
	has = function(value, p)
		return string.find(value, p) ~= nil
	end
}
local v8 = {}

for _, v9 in pairs(v3) do
	for _, reward in pairs(v9.Rewards) do
		for _, reward2 in pairs(reward.Rewards) do
			if not (reward2.Stock or reward.Stock) then
				continue
			end

			v5[reward2.ProductId] = true

			if reward2.GiftId then
				v5[reward2.GiftId] = true
			end

			if reward2.GiftName and v4[reward2.GiftName] then
				v5[v4[reward2.GiftName].productId] = true
			end
		end
	end
end

function v8.canBePurchasedWithTokens(data)
	local productId = data.ProductId or data.productId
	local name = data.Name or data.name

	if not (name and productId) then
		task.spawn(error, (`No .Name/.name or .ProductId/.productId for {HttpService:JSONEncode(data)}`))
		return false
	end

	if not v.GetFFlag("BuyLimitedStockWithTradingTokens", false) and v5[productId] then
		return false
	end

	local fFlag = v.GetFFlag("TradingTokensBuyProductsDisabledList")

	if fFlag and table.find(fFlag, productId) or (v6[productId] or v6[name]) then
		return false
	end

	for _, disabledTokensProduct in v2.DisabledTokensProducts do
		local v9 = false

		if type(disabledTokensProduct) == "number" then
			v9 = productId == disabledTokensProduct
		elseif type(disabledTokensProduct) == "string" then
			local v10, v11 = string.match(disabledTokensProduct, "^(%w+)=(.+)")

			if v10 and v11 then
				local v12 = v7[v10]

				if not v12 then
					error((`"{v10}" is not a valid DisabledProduct validator!`))
				end

				v9 = v12(string.lower(name), string.lower(v11))
			else
				v9 = name == disabledTokensProduct
			end
		else
			error((`"{type(disabledTokensProduct)}" is not a valid DisabledProduct identifier!`))
		end

		if not v9 then
			continue
		end

		v6[productId] = true
		v6[name] = true
		return false
	end

	return true
end

return table.freeze(v8)