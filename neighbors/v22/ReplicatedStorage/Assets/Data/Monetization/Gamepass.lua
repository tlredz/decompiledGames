require(script.Parent.Callbacks)
local Gamepass = {}
local RunService = game:GetService("RunService")

if not RunService:IsClient() then
	return Gamepass
end

local MarketplaceService = game:GetService("MarketplaceService")

for _, v in next, Gamepass, nil do
	local v2 = v
	local success, result = pcall(function()
		return MarketplaceService:GetProductInfo(v2.Id, Enum.InfoType.GamePass)
	end)

	if not success then
		continue
	end

	v.Price = result.PriceInRobux
	v.Description = result.Description
	v.Icon = result.IconImageAssetId
end

return Gamepass