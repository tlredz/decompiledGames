local MarketplaceService = game:GetService("MarketplaceService")
local GamepassPrices = {}
local v = {}

function GamepassPrices.GetInfoAsync(p: number)
	if v[p] then
		return v[p]
	end

	local success, productInfoAsync = pcall(
		MarketplaceService.GetProductInfoAsync,
		MarketplaceService,
		p,
		Enum.InfoType.GamePass
	)

	if success and productInfoAsync then
		local v2 = {
			price = productInfoAsync.PriceInRobux,
			isForSale = productInfoAsync.IsForSale == true
		}
		v[p] = v2
		return v2
	else
		return nil
	end
end

function GamepassPrices.GetAsync(p: number)
	local infoAsync = GamepassPrices.GetInfoAsync(p)
	return infoAsync and infoAsync.price or nil
end

GamepassPrices.ROBUX_CHAR = utf8.char(57346)

function GamepassPrices.Format(p: number)
	return tostring(p) .. GamepassPrices.ROBUX_CHAR
end

return GamepassPrices