local __DEV__ = _G.__DEV__
require(script.Parent.Parent.Parent:WaitForChild("es7-types"))
return function(list, callback, p)
	if __DEV__ then
		if typeof(list) ~= "table" then
			error(string.format("Array.filter called on %s", (typeof(list))))
		end

		if typeof(callback) ~= "function" then
			error("callback is not a function")
		end
	end

	local count = #list
	local result = {}
	local v = 1

	if p == nil then
		for i = 1, count do
			local v2 = list[i]

			if not (v2 ~= nil and callback(v2, i, list)) then
				continue
			end

			result[v] = v2
			v += 1
		end
	else
		for i = 1, count do
			local v2 = list[i]

			if not (v2 ~= nil and callback(p, v2, i, list)) then
				continue
			end

			result[v] = v2
			v += 1
		end
	end

	return result
end