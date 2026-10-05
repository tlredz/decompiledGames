local FpUtils = {}

function FpUtils.keyBy(list, callback)
	local count = #list
	local helper

	helper = function(options, value)
		local selected = options or {}
		local v2 = value or 1

		if count < v2 then
			return selected
		end

		local v3 = list[v2]
		selected[callback(v3)] = v3
		return helper(selected, v2 + 1)
	end

	return helper({}, 1)
end

function FpUtils.map(list, callback)
	local count = #list
	local helper

	helper = function(p, list2)
		if count < p then
			return list2
		end

		local v = list[p]
		table.insert(list2, callback(v))
		return helper(p + 1, list2)
	end

	return helper(1, {})
end

function FpUtils.filter(list, callback)
	local count = #list
	local helper

	helper = function(p, list2)
		if count < p then
			return list2
		end

		local v = list[p]

		if callback(v) then
			table.insert(list2, v)
		end

		return helper(p + 1, list2)
	end

	return helper(1, {})
end

function FpUtils.filterMap(list, callback, callback2)
	local count = #list
	local helper

	helper = function(p, list2)
		if count < p then
			return list2
		end

		local v = list[p]

		if callback(v) then
			table.insert(list2, callback2(v))
		end

		return helper(p + 1, list2)
	end

	return helper(1, {})
end

return FpUtils