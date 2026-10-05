local MarketplaceService = game:GetService("MarketplaceService")
local v = {}
return function(p, p2, value: number?)
	local result = v[p]

	if result then
		return true, result
	end

	local success = false
	local v2 = value or 3
	local count = 0

	while not success do
		success, result = pcall(function()
			return MarketplaceService:GetProductInfoAsync(p, p2)
		end)

		if success or v2 and v2 <= count then
			break
		end

		warn("[GetProductInfo] Failed to get product info for " .. tostring(p) .. ". retrying:", result)
		task.wait(1)
		count += 1
	end

	if success then
		v[p] = result
		return success, result
	end

	warn("[GetProductInfo] Failed to get product info", result)
	print("AssetId: " .. p)
	return success, result
end