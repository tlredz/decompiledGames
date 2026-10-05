local import = _G.import("cmdrProviderUtil")
local import2 = _G.import("rankUtil")
local import3 = _G.import("itemModules")
local import4 = _G.import("gamePassData")
local import5 = _G.import("rankData")
local import6 = _G.import("rankedConstants")
local MarketplaceService = game:GetService("MarketplaceService")
local PLAYER_COUNTS = import6.PLAYER_COUNTS
local v = {}

local function getPenultimateContentNode(p)
	local penultimateNode = import3:getPenultimateNode(p)

	if type(penultimateNode) ~= "table" then
		return false
	end

	local content = penultimateNode.Content
	return type(content) == "table" and content
end

local function getGamepassName(p)
	local v2 = v[p]

	if v2 ~= nil then
		return v2
	end

	local success, result = pcall(function()
		return MarketplaceService:GetProductInfo(p, Enum.InfoType.GamePass)
	end)
	local v3

	if type(result) == "table" and type(result.Name) == "string" then
		v3 = result.Name ~= ""
	else
		v3 = false
	end

	if success and v3 then
		v[p] = result.Name
		return result.Name
	end

	v[p] = false
	return false
end

local CmdrAutocompleteProviders = {}

function CmdrAutocompleteProviders.player(p)
	local prefix = p.Prefix:lower()
	local v2 = {}

	for _, v3 in ipairs(game.Players:GetPlayers()) do
		local name = v3.Name
		local displayName = v3.DisplayName

		if not (import.matchesPrefix(name, prefix) or import.matchesPrefix(displayName, prefix)) then
			continue
		end

		v2[#v2 + 1] = v3
	end

	table.sort(v2, function(a, b)
		return a.Name:lower() < b.Name:lower()
	end)
	local maxList = p.MaxList or #v2
	local result = {}

	for i = 1, math.min(#v2, maxList) do
		local v3 = v2[i]
		local v4 = v3.DisplayName == v3.Name and "" or v3.DisplayName or ""
		result[#result + 1] = import.makeSimpleEntry(v3.Name, v4)
	end

	local v3

	if result[1] then
		v3 = result[1].Name or false
	else
		v3 = false
	end

	return result, v3
end

function CmdrAutocompleteProviders.itemType(p)
	local prefix = p.Prefix:lower()
	local listFromPairsKeyString = import.listFromPairsKeyString(import3.rootNode.Content, prefix)
	return import.buildEntriesFromNames(listFromPairsKeyString, p.MaxList, function(p2)
		return import.makeSimpleEntry(p2)
	end)
end

function CmdrAutocompleteProviders.itemId(data)
	local v2 = not data.ArgSpec and "itemType" or data.ArgSpec.DependsOn or "itemType"
	local v3 = data.ArgsSoFar and data.ArgsSoFar[v2]

	if not v3 or v3 == "" then
		return {}, false
	end

	local penultimateNode = import3:getPenultimateNode(v3)
	local content

	if type(penultimateNode) == "table" then
		content = penultimateNode.Content

		if type(content) ~= "table" then
			content = false
		end
	else
		content = false
	end

	if not content then
		return {}, false
	end

	local prefix = data.Prefix:lower()
	local v4 = {}

	for k, v5 in pairs(content) do
		local id = tostring(k)
		local value

		if type(v5) == "table" then
			value = v5.Value
		else
			value = false
		end

		local displayName

		if value then
			displayName = value.DisplayName or id
		else
			displayName = id
		end

		if not (import.matchesPrefix(id, prefix) or import.matchesPrefix(displayName, prefix)) then
			continue
		end

		v4[#v4 + 1] = {
			Id = id,
			DisplayName = displayName
		}
	end

	table.sort(v4, function(a, b)
		return a.DisplayName:lower() < b.DisplayName:lower()
	end)
	local maxList = data.MaxList or #v4
	local result = {}

	for i = 1, math.min(#v4, maxList) do
		local v5 = v4[i]
		result[#result + 1] = {
			Name = v5.DisplayName,
			Description = v3,
			ArgsText = "",
			InsertText = v5.Id,
			Preview = {
				ItemType = v3,
				Id = v5.Id
			}
		}
	end

	local v5

	if result[1] then
		v5 = result[1].InsertText or false
	else
		v5 = false
	end

	return result, v5
end

function CmdrAutocompleteProviders.gamePassId(p)
	local prefix = p.Prefix:lower()
	local v2 = {}

	for k in pairs(import4) do
		local id = tonumber((string.sub(k, 2)))
		local name = getGamepassName(id) or id

		if not (prefix == "" or import.matchesPrefix(name, prefix) or import.matchesPrefix(id, prefix)) then
			continue
		end

		v2[#v2 + 1] = {
			id = id,
			name = name
		}
	end

	table.sort(v2, function(a, b)
		return a.name:lower() < b.name:lower()
	end)
	local maxList = p.MaxList or #v2
	local result = {}

	for i = 1, math.min(#v2, maxList) do
		local v3 = v2[i]
		result[#result + 1] = {
			Name = v3.name,
			Description = "GamePass",
			ArgsText = "",
			InsertText = v3.id
		}
	end

	local v3

	if result[1] then
		v3 = result[1].InsertText or false
	else
		v3 = false
	end

	return result, v3
end

function CmdrAutocompleteProviders.rankId(p)
	local prefix = p.Prefix:lower()
	local orderedRankIds = import2.getOrderedRankIds()
	local result = {}

	for _, orderedRankId in ipairs(orderedRankIds) do
		local v2 = import5[orderedRankId]
		local displayName

		if type(v2) == "table" then
			displayName = v2.DisplayName or orderedRankId
		else
			displayName = orderedRankId
		end

		if not (prefix == "" or import.matchesPrefix(orderedRankId, prefix) or import.matchesPrefix(displayName, prefix)) then
			continue
		end

		result[#result + 1] = {
			Name = displayName,
			Description = "Rank",
			ArgsText = "",
			InsertText = orderedRankId
		}
	end

	local v2

	if result[1] then
		v2 = result[1].InsertText or false
	else
		v2 = false
	end

	return result, v2
end

function CmdrAutocompleteProviders.modeKey(p)
	local prefix = p.Prefix:lower()
	local result = {}

	for _, v2 in ipairs(PLAYER_COUNTS) do
		local name = ""

		for i = 1, v2 do
			name ..= "1" .. (i == v2 and "" or "v")
		end

		if prefix == "" or import.matchesPrefix(name, prefix) then
			result[#result + 1] = {
				Name = name,
				Description = "Player Count",
				ArgsText = ""
			}
		end
	end

	local v2

	if result[1] then
		v2 = result[1].Name or false
	else
		v2 = false
	end

	return result, v2
end

return CmdrAutocompleteProviders