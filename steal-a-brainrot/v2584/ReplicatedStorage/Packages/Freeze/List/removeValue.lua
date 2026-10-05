local maybeFreeze = require(script.Parent.Parent.utils.maybeFreeze)
local toSet = require(script.Parent.toSet)

local function removeValues(list, ...)
	local v = toSet({ ... })
	local v2 = {}
	local v3 = 1
	local flag = false

	for _, v4 in ipairs(list) do
		if v[v4] then
			flag = true
		else
			v2[v3] = v4
			v3 += 1
		end
	end

	if flag then
		return (maybeFreeze(v2))
	end

	return list
end

local function removeValue(list, ...)
	local v = { ... }

	if #v ~= 1 then
		return removeValues(list, ...)
	end

	local v2 = v[1]
	local v3 = table.create(#list)
	local flag = false

	for _, v4 in list do
		if v4 == v2 then
			flag = true
		else
			table.insert(v3, v4)
		end
	end

	if flag then
		return (maybeFreeze(v3))
	end

	return list
end

return removeValue