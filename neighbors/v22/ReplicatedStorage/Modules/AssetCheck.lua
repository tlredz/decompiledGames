local MarketplaceService = game:GetService("MarketplaceService")
local assetTypeIds = {}

local function isValidAssetId(value: number)
	if value then
		if typeof(value) == "number" and value >= 0 then
			value = math.floor(value) == value
		else
			value = false
		end
	end

	return value
end

local function getAssetTypeId(value: number)
	local v = tostring(value)

	if assetTypeIds[v] then
		return assetTypeIds[v]
	end

	local assetTypeId = nil
	local success, result = pcall(function()
		assetTypeId = MarketplaceService:GetProductInfo(value, Enum.InfoType.Asset).AssetTypeId
	end)

	if not success then
		warn((`Failed to check asset type. Id: {value} -- Error: {tostring(result)}`))
	end

	if assetTypeId then
		assetTypeIds[v] = assetTypeId
	end

	return assetTypeId
end

local AssetCheck = {}

function AssetCheck.IsValidImage(_, value: number)
	local v

	if value then
		if typeof(value) == "number" and value >= 0 then
			v = math.floor(value) == value
		else
			v = false
		end
	else
		v = value
	end

	if v then
		return getAssetTypeId(value) == 13
	end

	return false
end

function AssetCheck.IsValidSound(_, value: number)
	local v

	if value then
		if typeof(value) == "number" and value >= 0 then
			v = math.floor(value) == value
		else
			v = false
		end
	else
		v = value
	end

	if v then
		return getAssetTypeId(value) == 3
	end

	return false
end

return AssetCheck