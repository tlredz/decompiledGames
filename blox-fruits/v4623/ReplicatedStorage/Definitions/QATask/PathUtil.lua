local Types = require(game.ReplicatedStorage.Definitions.QATask.Types)
local PathUtil = {
	ROOT = "/",
	SEPARATOR = "/",
	join = function(p, p2)
		local qATaskKey, v = Types.QATaskKey(p2)
		assert(qATaskKey, (`bad key: {v}`))

		if p == nil or p == "/" then
			return (`/{p2}`)
		end

		local qATaskPath, v2 = Types.QATaskPath(p)
		assert(qATaskPath, (`bad parent path: {v2}`))
		return (`{p}/{p2}`)
	end,
	split = function(value)
		local result = {}

		for k in value:gmatch("[^/]+") do
			table.insert(result, k)
		end

		return result
	end
}

function PathUtil.keyOf(p)
	local parts = PathUtil.split(p)
	local part = parts[#parts]
	assert(part, (`path "{p}" has no key`))
	return part
end

function PathUtil.parentOf(p)
	local parts = PathUtil.split(p)

	if #parts <= 1 then
		return nil
	end

	table.remove(parts)
	return (`/{table.concat(parts, "/")}`)
end

function PathUtil.depthOf(p)
	return #PathUtil.split(p)
end

function PathUtil.isAncestorOf(value, value2)
	return value ~= value2 and value2:sub(1, value:len() + 1) == `{value}/`
end

function PathUtil.isChildOf(p, p2)
	return PathUtil.parentOf(p2) == p
end

function PathUtil.slugify(value: string)
	local v = value:lower():gsub("[^%w%s%-_%.]", ""):gsub("%s+", "-"):gsub("%-+", "-"):gsub("^%-", ""):gsub("%-$", "")
	return v == "" and "task" or v
end

function PathUtil.compare(p, p2)
	local parts = PathUtil.split(p)
	local parts2 = PathUtil.split(p2)

	for i = 1, math.min(#parts, #parts2) do
		if parts[i] ~= parts2[i] then
			return parts[i] < parts2[i]
		end
	end

	return #parts < #parts2
end

return PathUtil