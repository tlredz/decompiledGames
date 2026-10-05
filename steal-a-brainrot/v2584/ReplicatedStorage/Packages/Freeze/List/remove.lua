local maybeFreeze = require(script.Parent.Parent.utils.maybeFreeze)

local function removeSingle(list, total: number)
	local count = #list
	local result = table.create(count - 1)

	if total < 1 then
		total += count + 1
	end

	if total <= 0 or count < total then
		return list
	end

	local v = 1

	for k, v2 in list do
		if k == total then
			continue
		end

		result[v] = v2
		v += 1
	end

	return result
end

local function remove(list, ...)
	local v = { ... }

	if #v == 1 then
		return (removeSingle(list, v[1]))
	end

	local count = #list
	local v2 = {}
	local count2 = 0

	for _, total in v do
		if total < 1 then
			total += count + 1
		end

		if total <= 0 or count < total then
			continue
		end

		v2[total] = true
		count2 += 1
	end

	if count2 == 0 then
		return list
	end

	local v3 = table.create((math.max(1, count - count2)))
	local v4 = 1

	for k, v5 in list do
		if v2[k] then
			continue
		end

		v3[v4] = v5
		v4 += 1
	end

	return maybeFreeze(v3)
end

return remove