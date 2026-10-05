local Result = require(game.ReplicatedStorage.Packages.Result)
local Types = require(script.Parent.Types)
local ItemId = require(game.ReplicatedStorage.Economy.ItemId)
local Index = require(script.Parent.Data.Index)
local Spritesheets = require(game.ReplicatedStorage.Spritesheets)
local v = {
	{ "Display", "Sprite" },
	{ "Display", "OutlineSprite" },
	{ "Display", "CornerIcon" },
	{ "Display", "CategoryIcon" },
	{ "Inventory", "StackCategoryIcon" },
	{ "Skin", "EquippedAdorneeSprite" }
}

local function isSpriteField(p: string, p2: string)
	for _, v2 in v do
		if v2[1] == p and v2[2] == p2 then
			return true
		end
	end

	return false
end

local function sortedKeys(items)
	local result = {}

	for k in items do
		table.insert(result, k)
	end

	table.sort(result, function(a, b)
		local typeName = type(a)
		local typeName2 = type(b)

		if typeName == typeName2 then
			if typeName == "boolean" then
				return a == false
			end

			return a < b
		else
			return typeName == "number" or typeName2 ~= "number" and typeName < typeName2
		end
	end)
	return result
end

local function formatNumber(p: number)
	assert(p == p, "cannot bake nan")

	if p == 1e999 then
		return "math.huge"
	elseif p == -1e999 then
		return "-math.huge"
	end

	if p == math.floor(p) and math.abs(p) < 1000000000000000 then
		return string.format("%d", p)
	end

	return string.format("%.17g", p)
end

local function formatKey(p)
	local typeName = type(p)

	if typeName == "string" then
		return (`[{string.format("%q", p)}]`)
	elseif typeName == "number" then
		return (`[{formatNumber(p)}]`)
	elseif typeName == "boolean" then
		return (`[{tostring(p)}]`)
	end

	error((`cannot bake key of type "{typeName}"`))
end

local function formatColor3(color: Color3)
	local v2 = math.round(color.R * 255)
	local v3 = math.round(color.G * 255)
	local v4 = math.round(color.B * 255)

	if Color3.fromRGB(v2, v3, v4) == color then
		return (`Color3.fromRGB({v2}, {v3}, {v4})`)
	end

	return string.format("Color3.new(%.9g, %.9g, %.9g)", color.R, color.G, color.B)
end

local writeValue

writeValue = function(p, p2, p3: string, list)
	local lines = p.Lines
	local typeName = typeof(p2)

	if typeName == "string" then
		table.insert(lines, string.format("%q", p2))
		return
	elseif typeName == "number" then
		table.insert(lines, formatNumber(p2))
		return
	elseif typeName == "boolean" then
		table.insert(lines, (tostring(p2)))
		return
	elseif typeName == "Color3" then
		table.insert(lines, formatColor3(p2))
		return
	end

	if typeName ~= "table" then
		error((`cannot bake value of type "{typeName}" at "{table.concat(list, ".")}"`))
		return
	end

	local spriteKey = p.SpriteKeys[p2]

	if spriteKey then
		local v2

		if #list == 2 then
			local v3 = list[1]
			local v4 = list[2]
			local flag = true

			for _, v5 in v do
				if not (v5[1] == v3 and v5[2] == v4) then
					continue
				end

				v2 = true
				flag = false
				break
			end

			if flag then
				v2 = false
			end
		else
			v2 = false
		end

		assert(v2, (`sprite found at unexpected path "{table.concat(list, ".")}"`))
		table.insert(lines, string.format("%q", spriteKey))
	else
		table.insert(lines, "{\n")
		local v2 = p3 .. "\t"

		for _, v3 in sortedKeys(p2) do
			table.insert(lines, (`{v2}{formatKey(v3)} = `))
			table.insert(list, (tostring(v3)))
			writeValue(p, p2[v3], v2, list)
			table.remove(list)
			table.insert(lines, ",\n")
		end

		table.insert(lines, (`{p3}}`))
	end
end

local function getSpriteKeys()
	local result = {}

	for k, v2 in Spritesheets.MAP_WITH_EXT do
		result[v2] = k
	end

	for k, v2 in Spritesheets.MAP do
		if result[v2] == nil then
			result[v2] = k
		end
	end

	return result
end

local Bake = {
	resolveSprite = function(p: string)
		local selected = Spritesheets.MAP_WITH_EXT[p] or Spritesheets.MAP[p]
		assert(selected, (`no sprite found for key "{p}"`))
		return selected
	end
}

function Bake.swapSprites(p)
	for _, v2 in v do
		local v3 = p[v2[1]]

		if v3 == nil then
			continue
		end

		local v4 = v3[v2[2]]

		if v4 == nil then
			continue
		end

		assert(type(v4) == "string", (`expected string sprite key at {v2[1]}.{v2[2]}, got {typeof(v4)}`))
		v3[v2[2]] = Bake.resolveSprite(v4)
	end
end

function Bake.parse()
	local result = {}

	for k, v2 in ItemId._IDS:unwrap() do
		if #Index < k then
			break
		end

		local id = ItemId.getId(v2.Id.StorageKey, v2.Id.Type)

		if id:isErr() then
			table.insert(result, Result.err((`bad id: #{v2.Id.ItemId}`)))
		else
			local unwrapped = id:unwrap()
			local v3, v4 = Types.from(unwrapped)

			if v3 then
				table.insert(result, Result.ok(v3))
			else
				assert(v4, (`Item #{unwrapped} failed to load config but did not provide an error message`))

				if not v4:find("skip") then
					warn((`failed to to construct Item #{unwrapped}: {v4}`))
				end

				table.insert(result, Result.err((`Item #{unwrapped}: {v4}`)))
			end
		end
	end

	return result
end

function Bake.collectItems(items)
	local result = {}

	for k, item in items do
		if not item:isOk() then
			continue
		end

		local unwrapped = item:unwrap()

		if unwrapped.Index.ItemId == k then
			table.insert(result, unwrapped)
		end
	end

	return result
end

function Bake.isFresh(p)
	if p.IndexCount ~= #Index then
		return false
	end

	for _, config in p.Configs do
		local v2 = Index[config.Index.ItemId]

		if v2 == nil or v2["Storage Key"] ~= config.Index.StorageKey or v2["Id Type"] ~= config.Index.IdType or v2["Do Not Use"] ~= "FALSE" then
			return false
		end
	end

	return true
end

function Bake.load(data)
	local result = table.create(data.Count)

	for i = 1, data.Count do
		local config = data.Configs[i]

		if config then
			Bake.swapSprites(config)
			result[i] = Result.ok(Types.finalize(config))
		else
			result[i] = Result.err(data.Errors[i] or `missing baked config #{i}`)
		end
	end

	return result
end

function Bake.serialize(list)
	local v2 = {
		Lines = {
			"-- DO NOT EDIT, GENERATED DURING BUILD WORKFLOW (scripts/build/data/bake-item-config.lune.luau)",
			[[

return {
]],
			`\tIndexCount = {#Index},\n`,
			`\tCount = {#list},\n`,
			"\tErrors = {\n"
		},
		SpriteKeys = getSpriteKeys()
	}
	local lines = v2.Lines

	for k, v3 in list do
		if v3:isErr() then
			table.insert(lines, (`\t\t[{k}] = {string.format("%q", v3:unwrapErr())},\n`))
		end
	end

	table.insert(lines, [[
	},
	Configs = {
]])

	for k, v3 in list do
		if not v3:isOk() then
			continue
		end

		table.insert(lines, (`\t\t[{k}] = `))
		writeValue(v2, v3:unwrap(), "\t\t", {})
		table.insert(lines, ",\n")
	end

	table.insert(lines, [[
	},
}
]])
	return table.concat(lines)
end

return Bake