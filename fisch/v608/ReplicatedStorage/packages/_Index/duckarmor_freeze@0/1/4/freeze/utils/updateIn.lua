local parent = script.Parent.Parent
local None = require(parent.None)
local isDataStructure = require(script.Parent.Parent.utils.isDataStructure)
local slice = require(script.Parent.slice)
local get = require(script.Parent.get)
local remove = require(script.Parent:FindFirstChild("remove"))
local set = require(script.Parent.set)

local function toString(list)
	return table.concat(list, ", ")
end

local updateInDeeply

updateInDeeply = function(p, list, p2: number, callback, p3)
	local v = p == None

	if p2 == #list + 1 then
		if not v then
			p3 = p
		end

		local v2 = callback(p3)

		if v2 == p3 then
			return p
		end

		return v2
	else
		if not (v or isDataStructure(p)) then
			local v2 = slice(list, 1, p2 - 1)
			error("Cannot update within non-data-structure value in path [" .. table.concat(v2, ", ") .. "]: " .. tostring(p))
		end

		local v2 = list[p2]
		local v3

		if v then
			v3 = None
		else
			v3 = get(p, v2, None)
		end

		local v4 = updateInDeeply(v3, list, p2 + 1, callback, p3)

		if v4 == v3 then
			return p
		end

		if v4 == None then
			return (remove(p, v2))
		end

		return (set(v and {} or p, v2, v4))
	end
end

return function(p, p2, callback, p3)
	local v = updateInDeeply(p, p2, 1, callback, p3)

	if v == None then
		return p3
	end

	return v
end