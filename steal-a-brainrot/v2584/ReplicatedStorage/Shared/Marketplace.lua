local MarketplaceService = game:GetService("MarketplaceService")
local v = {}
local Marketplace = {}

function Marketplace.RemoveCache(_, p: number)
	v[p] = nil
end

function Marketplace:GetProductInfo(p: number, p2: string)
	local v2 = v[p]

	if not v2 or os.time() - v2.LastUpdate >= 3600 then
		local success, result = pcall(function()
			return MarketplaceService:GetProductInfo(
				p,
				p2 == "Gamepass" and Enum.InfoType.GamePass or Enum.InfoType.Product
			)
		end)
		v[p] = {
			PriceInRobux = not success and 999999999 or result.PriceInRobux or 999999999,
			Title = not success and "Failed to load" or result.Name or "Failed to load",
			Icon = success and result.IconImageAssetId and `rbxassetid://{result.IconImageAssetId}` or "Failed to load",
			LastUpdate = os.time()
		}
	end

	return v[p]
end

return Marketplace