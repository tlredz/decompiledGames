local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DevProducts = require(ReplicatedStorage.Modules.Shared.PlayerData.DevProducts)
local GetProductInfo = require(ReplicatedStorage.Modules.Shared.Utils.GetProductInfo)
return function(p: string)
	local v = DevProducts.All[p]

	if v == nil then
		return ""
	end

	local id = DevProducts.GetId(v)

	if id == 0 then
		return ""
	end

	local v2, v3 = GetProductInfo(id, Enum.InfoType.Product)

	if v2 and v3 ~= nil then
		return (tostring(v3.PriceInRobux))
	end

	return ""
end