local PlaceholderController = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CountableDevProductPrice = require(ReplicatedStorage.Modules.Client.Placeholder.Resolvers.CountableDevProductPrice)
local DevProductPrice = require(ReplicatedStorage.Modules.Client.Placeholder.Resolvers.DevProductPrice)
local v = {}

function PlaceholderController.FrameworkInit()
	PlaceholderController.Register("countabledevproductprice", CountableDevProductPrice)
	PlaceholderController.Register("devproductprice", DevProductPrice)
end

function PlaceholderController.FrameworkStart() end

function PlaceholderController.Register(p: string, callback)
	assert(v[p] == nil, "Placeholder type already registered: " .. p)
	v[p] = callback
end

local function findMatches(value: string)
	local v2 = 1
	local result = {}

	while true do
		local startIndex, endIndex, placeholderType, v6 = value:find("%%([%a%d]+)_([^%%]+)%%", v2)

		if startIndex == nil or endIndex == nil then
			break
		end

		table.insert(result, {
			startIndex = startIndex,
			endIndex = endIndex,
			placeholderType = placeholderType,
			key = v6
		})
		v2 = endIndex + 1
	end

	return result
end

local function rebuild(value: string, matches, p)
	local v2 = 1
	local v3 = {}

	for k, item in matches do
		if v2 < item.startIndex then
			table.insert(v3, value:sub(v2, item.startIndex - 1))
		end

		table.insert(v3, p[k])
		v2 = item.endIndex + 1
	end

	if v2 <= #value then
		table.insert(v3, value:sub(v2))
	end

	return table.concat(v3)
end

function PlaceholderController.Substitute(p: string)
	local matches = findMatches(p)

	if #matches == 0 then
		return p
	end

	local v2 = table.create(#matches)

	for k, match in matches do
		local v3 = v[match.placeholderType]

		if v3 == nil then
			v2[k] = ""
		else
			v2[k] = v3(match.key)
		end
	end

	return rebuild(p, matches, v2)
end

function PlaceholderController.StripUnknownTokens(value: string)
	local matches = findMatches(value)

	if #matches == 0 then
		return value
	end

	local v2 = table.create(#matches)

	for k, match in matches do
		if v[match.placeholderType] == nil then
			v2[k] = ""
		else
			v2[k] = value:sub(match.startIndex, match.endIndex)
		end
	end

	return rebuild(value, matches, v2)
end

return PlaceholderController