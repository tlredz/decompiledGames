local HttpService = game:GetService("HttpService")

local function GenerateEntropy()
	local GUID = HttpService:GenerateGUID(false)
	return
		tonumber(string.sub(GUID, 1, 8), 16),
		tonumber(string.sub(GUID, 10, 13) .. string.sub(GUID, 25, 28), 16),
		(tonumber(string.sub(GUID, 29, 36), 16))
end

local function GenerateSeed(p: number)
	local result = table.create(p, 0)
	local v = p // 3

	for i = 0, v - 1 do
		local v2 = i * 3 + 1
		local v3 = i * 3 + 2
		local v4 = i * 3 + 3
		local GUID = HttpService:GenerateGUID(false)
		local v5 = tonumber(string.sub(GUID, 1, 8), 16)
		local v6 = tonumber(string.sub(GUID, 10, 13) .. string.sub(GUID, 25, 28), 16)
		local v7 = tonumber(string.sub(GUID, 29, 36), 16)
		result[v2] = v5
		result[v3] = v6
		result[v4] = v7
	end

	local v2 = p - v * 3

	if v2 == 1 then
		local GUID = HttpService:GenerateGUID(false)
		local v3 = tonumber(string.sub(GUID, 1, 8), 16)
		tonumber(string.sub(GUID, 10, 13) .. string.sub(GUID, 25, 28), 16)
		tonumber(string.sub(GUID, 29, 36), 16)
		result[p] = v3
		return result
	else
		if v2 ~= 2 then
			return result
		end

		local v3 = p - 1
		local GUID = HttpService:GenerateGUID(false)
		local v4 = tonumber(string.sub(GUID, 1, 8), 16)
		local v5 = tonumber(string.sub(GUID, 10, 13) .. string.sub(GUID, 25, 28), 16)
		tonumber(string.sub(GUID, 29, 36), 16)
		result[v3] = v4
		result[p] = v5
		return result
	end
end

return GenerateSeed