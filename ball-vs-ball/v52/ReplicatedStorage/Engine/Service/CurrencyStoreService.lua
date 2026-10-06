local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Config = require(script.Parent.Config)
local CurrencyService = require(script.Parent.CurrencyService)
local v = {
	["金币"] = CurrencyService.ref.Coins,
	["钻石"] = CurrencyService.ref.Diamonds
}

if RunService:IsServer() then
	local DevProductService = require(ReplicatedStorage.Engine.Market.DevProductService)

	for _, v2 in Config.currencyStore.list do
		if not (v2.exchangeCurrencyType == "Robux" and v2.robloxProductName and v2.robloxProductName ~= "") then
			continue
		end

		local v3 = v[v2.currencyCnId]
		local robloxProductName = v2.robloxProductName
		local count = v2.count

		if v3 then
			local v4 = v3
			local count2 = count
			local robloxProductName2 = robloxProductName
			local v7 = v2
			DevProductService.server.bindProduct(robloxProductName, function(p)
				CurrencyService.server.give(p.plr, v4, count2, {
					type = "recharge",
					arg = robloxProductName2
				}, {
					transactionType = Enum.AnalyticsEconomyTransactionType.IAP.Name,
					sku = string.format("充值:%s:%d", v7.currencyCnId, count2),
					channel = "充值",
					mode = "通用"
				})
			end)
		else
			warn((`[CurrencyStoreService] 商品 {robloxProductName} 的 currencyCnId "{v2.currencyCnId}" 无法映射到货币类型，跳过注册`))
		end
	end
end

return {}