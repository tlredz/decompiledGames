local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(script.Parent.Config)
local CurrencyService = require(script.Parent.CurrencyService)
local DevProductService = require(ReplicatedStorage.Engine.Market.DevProductService)
local productId = nil
local v = 0
MarketplaceService.PromptProductPurchaseFinished:Connect(function(p, p2)
	if p == Players.LocalPlayer.UserId and p2 == productId then
		productId = nil
		v = os.clock() + 0.5
	end
end)
return {
	promptIfInsufficient = function(value: number)
		if productId or os.clock() < v then
			return false
		end

		if typeof(value) ~= "number" or value ~= value or value <= 0 or value == 1e999 then
			return false
		end

		local v2 = value - CurrencyService.client.get(CurrencyService.ref.Diamonds)

		if v2 <= 0 then
			return false
		end

		local v3 = nil

		for _, v4 in Config.currencyStore and Config.currencyStore.byCurrencyCnId and Config.currencyStore.byCurrencyCnId["钻石"] or {} do
			local count = v4.count
			local robloxProductName = v4.robloxProductName

			if not (v4.exchangeCurrencyType == "Robux" and typeof(robloxProductName) == "string" and robloxProductName ~= "" and typeof(count) == "number") then
				continue
			end

			if not (count == count and count < 1e999 and v2 <= count and DevProductService.products.byProductKey[robloxProductName]) then
				continue
			end

			if not (not v3 or count < v3.count) then
				continue
			end

			v3 = v4
		end

		if not v3 then
			return false
		end

		productId = DevProductService.products.byProductKey[v3.robloxProductName].ProductId
		local success, result = pcall(DevProductService.client.promptPurchase, v3.robloxProductName)

		if not success then
			productId = nil
			v = os.clock() + 0.5
			warn("[DiamondTopUpService] 无法打开充值窗口: " .. tostring(result))
		end

		return success
	end
}