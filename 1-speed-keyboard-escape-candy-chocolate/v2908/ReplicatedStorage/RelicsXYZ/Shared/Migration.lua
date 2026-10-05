local v = {}
local parent = script.Parent
require(parent.Marketplace)
local ModelSquash = require(parent.ModelSquash)
local HttpService = game:GetService("HttpService")
script:ClearAllChildren()

function v.ParseLegacyIds(id)
	local result = {}

	if type(id) == "number" then
		if id > 0 then
			table.insert(result, {
				Id = id,
				InfoType = Enum.InfoType.GamePass
			})
			return result
		end
	elseif type(id) == "string" then
		for k in id:gmatch("[^,]+") do
			local match, v2 = k:match("^%s*(.-)%s*$"):match("^(%d+):?(%w*)$")
			local id2 = tonumber(match)

			if not (id2 and id2 > 0) then
				continue
			end

			local gamePass = Enum.InfoType.GamePass

			if v2 and v2 ~= "" then
				local v4 = v2
				local success, result2 = pcall(function()
					return Enum.InfoType[v4]
				end)

				if success and typeof(result2) == "EnumItem" then
					gamePass = result2
				end
			end

			table.insert(result, {
				Id = id2,
				InfoType = gamePass
			})
		end
	end

	return result
end

function v.Resolve(_: string, _: string, p: number, json: string?)
	local v2 = json and HttpService:JSONDecode(json)
	local deserialized = nil
	local gamePass = 0
	local assetId = 0

	if type(v2) == "buffer" then
		if pcall(function()
			deserialized = ModelSquash.Deserialize(v2)
		end) and deserialized then
			assetId = tonumber(deserialized:GetAttribute("AssetId") or deserialized:GetAttribute("EmoteId") or deserialized:GetAttribute("AccessoryId")) or 0
			gamePass = tonumber(deserialized:GetAttribute("GamePass")) or 0
		end
	elseif type(v2) == "table" then
		assetId = tonumber(v2.AssetId or v2.EmoteId or v2.AccessoryId) or 0
		gamePass = tonumber(v2.GamePass) or 0
	else
		gamePass = p
	end

	if assetId == gamePass then
		gamePass = 0

		if assetId == 0 then
			assetId = p
		end
	end

	return assetId, gamePass
end

return table.freeze(v)