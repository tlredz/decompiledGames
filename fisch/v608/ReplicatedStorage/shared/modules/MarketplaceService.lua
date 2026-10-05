local MarketplaceService = game:GetService("MarketplaceService")
local MarketplaceService2 = {}
setmetatable(MarketplaceService2, {
	__index = MarketplaceService
})
local productInfos = {}

function MarketplaceService2:GetProductInfo(p: number, p2)
	local v = p2 or Enum.InfoType.Asset
	local formatted = `{v.Value}_{tostring(p):match("%d+")}`

	if productInfos[formatted] then
		return productInfos[formatted]
	end

	local productInfo = MarketplaceService:GetProductInfo(p, v)
	productInfos[formatted] = productInfo
	return productInfo
end

return MarketplaceService2