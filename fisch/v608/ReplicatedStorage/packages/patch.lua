local validate = require(script.validate)
local __DEV__ = _G.__DEV__
local v = {
	__none = "__none"
}

local function stringifySparseArray(clone)
	local v2 = table.maxn(clone)

	if v2 == 0 or v2 == #clone then
		return clone
	end

	local result = {}

	for k, v3 in next, clone, nil do
		result[tostring(k)] = v3
	end

	return result
end

local diff

diff = function(list, list2, flag: boolean?)
	local v2 = flag ~= false
	local clone = table.clone(list2)

	for k, v3 in next, list, nil do
		local v4 = list2[k]

		if v3 == v4 then
			clone[k] = nil
		elseif v4 == nil then
			clone[k] = v
		elseif type(v3) == "table" and type(v4) == "table" then
			local v5 = diff(v3, v4, v2)

			if next(v5) then
				clone[k] = v5
			else
				clone[k] = nil
			end
		end
	end

	if v2 and (list[1] ~= nil or list2[1] ~= nil) then
		clone = stringifySparseArray(clone)
	end

	if v2 and __DEV__ then
		for k, v3 in next, clone, nil do
			validate(v3, k)
		end
	end

	return clone
end

local apply

apply = function(list, p)
	if type(p) == "table" and p.__none == "__none" then
		return nil
	end

	if type(list) ~= "table" or type(p) ~= "table" then
		return p
	end

	local clone = table.clone(list)
	local v2 = list[1] ~= nil

	for k, v3 in next, p, nil do
		if v2 and type(k) == "string" then
			k = tonumber(k) or k
		end

		clone[k] = apply(clone[k], v3)
	end

	return clone
end

return {
	isNone = function(p)
		return type(p) == "table" and p.__none == "__none"
	end,
	diff = diff,
	apply = apply
}