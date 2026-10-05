local ContentProvider = game:GetService("ContentProvider")
local v = {}

local function asContent(p)
	local typeName = typeof(p)

	if typeName == "number" then
		return (`rbxassetid://{p}`)
	end

	if typeName == "string" or typeName == "Instance" then
		return p
	end

	error(`cannot preload a {typeName} value`, 3)
end

local function describe(instance)
	if typeof(instance) == "Instance" then
		return (instance:GetFullName())
	end

	return instance
end

local function requestSlice(items)
	local result = {}
	local success, result2 = pcall(ContentProvider.PreloadAsync, ContentProvider, items, function(p: string, p2)
		if p2 ~= Enum.AssetFetchStatus.Success then
			table.insert(result, p)
		end
	end)

	if success then
		return result
	end

	warn((`preload request failed outright: {result2}`))

	for _, fullName in items do
		if typeof(fullName) == "Instance" then
			fullName = fullName:GetFullName()
		end

		table.insert(result, fullName)
	end

	return result
end

function v.Queue(list)
	local v2 = table.create(#list)

	for _, v3 in list do
		table.insert(v2, asContent(v3))
	end

	for i = 1, #v2, 48 do
		local v3 = table.move(v2, i, math.min(i + 48 - 1, #v2), 1, {})
		local v4 = requestSlice(v3)

		if #v4 ~= 0 then
			task.wait(0.75)
			v4 = requestSlice(v3)
		end

		if #v4 > 0 then
			warn((`{#v4} asset(s) still unavailable after a retry: {table.concat(v4, ", ")}`))
		end
	end
end

local function asOneList(...)
	local result = {}

	for _, v2 in { ... } do
		if type(v2) == "table" then
			for _, v3 in v2 do
				table.insert(result, v3)
			end
		else
			table.insert(result, v2)
		end
	end

	return result
end

function v.WarmAssets(...)
	v.Queue(asOneList(...))
end

v.WarmSounds = v.WarmAssets
return table.freeze(v)