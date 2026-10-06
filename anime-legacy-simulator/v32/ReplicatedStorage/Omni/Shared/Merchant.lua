require("@game/ReplicatedStorage/Omni/DataTemplate")
local Merchant = {
	List = {}
}

function Merchant.Register(value: string, p)
	if typeof(value) ~= "string" or typeof(p) ~= "table" then
		return
	end

	if Merchant.List[value] then
		warn((`Repeated Merchant Module: {value}!`))
		return
	end

	local shopProducts = p.ShopProducts or {}

	for k, shopProduct in shopProducts do
		shopProduct.ProductIdentifier = value .. " Merchant Product - " .. k
	end

	p.ShopProducts = shopProducts
	Merchant.List[value] = p
end

function Merchant.GetStockInformationForMerchantProduct(p: string, p2: string, p3)
	local v = Merchant.List[p]

	if not v then
		return
	end

	local product = v.Products[p2]

	if not product then
		return
	end

	local v2 = p3.Merchant[p]

	if not v2 then
		return
	end

	local v3 = v2[p2]

	if not v3 then
		return
	end

	local serverTimeNow = workspace:GetServerTimeNow()
	local stock = v3.Stock
	local v4 = 1e999

	if product.Restock.Type == "Always" then
		local v5 = serverTimeNow - v3.LastRestock
		return stock, (math.max(0, product.Restock.Time - v5))
	end

	if product.Restock.Type == "OnStockout" and stock == 0 and v3.LastStockout then
		local v5 = serverTimeNow - v3.LastStockout
		v4 = math.max(0, product.Restock.Time - v5)
	end

	return stock, v4
end

function Merchant.GetStockInformationForMerchant(p: string, p2)
	local result = {}
	local serverTimeNow = workspace:GetServerTimeNow()
	local v = Merchant.List[p]

	if not v then
		return result
	end

	local v2 = p2.Merchant[p]

	if not v2 then
		return result
	end

	for k, product in v.Products do
		local v3 = v2[k]

		if not v3 then
			continue
		end

		local timeForRestock = nil
		local stock = v3.Stock

		if product.Restock.Type == "Always" then
			local v5 = serverTimeNow - v3.LastRestock
			timeForRestock = math.max(0, product.Restock.Time - v5)
		elseif product.Restock.Type == "OnStockout" and stock == 0 and v3.LastStockout then
			local v5 = serverTimeNow - v3.LastStockout
			timeForRestock = math.max(0, product.Restock.Time - v5)
		end

		result[k] = {
			Stock = stock,
			TimeForRestock = timeForRestock
		}
	end

	return result
end

return Merchant