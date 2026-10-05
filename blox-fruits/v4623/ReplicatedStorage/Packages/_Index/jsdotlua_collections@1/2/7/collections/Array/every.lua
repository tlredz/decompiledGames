local __DEV__ = _G.__DEV__
require(script.Parent.Parent.Parent:WaitForChild("es7-types"))
return function(list, callback, p)
	if __DEV__ then
		if typeof(list) ~= "table" then
			error(string.format("Array.every called on %s", (typeof(list))))
		end

		if typeof(callback) ~= "function" then
			error("callback is not a function")
		end
	end

	local v = #list
	local v2 = 1

	while v2 <= v do
		local v3 = list[v2]

		if v3 ~= nil then
			local v4

			if p == nil then
				v4 = callback(v3, v2, list)
			else
				v4 = callback(p, v3, v2, list)
			end

			if not v4 then
				return false
			end
		end

		v2 += 1
	end

	return true
end