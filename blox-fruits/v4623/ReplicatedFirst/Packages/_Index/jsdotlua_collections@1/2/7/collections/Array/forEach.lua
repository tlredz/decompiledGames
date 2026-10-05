local __DEV__ = _G.__DEV__
require(script.Parent.Parent.Parent:WaitForChild("es7-types"))
return function(list, callback, p)
	if __DEV__ then
		if typeof(list) ~= "table" then
			error(string.format("Array.forEach called on %s", (typeof(list))))
		end

		if typeof(callback) ~= "function" then
			error("callback is not a function")
		end
	end

	local count = #list
	local v = 1

	while v <= count do
		local v2 = list[v]

		if p == nil then
			callback(v2, v, list)
		else
			callback(p, v2, v, list)
		end

		count = #list < count and #list or count
		v += 1
	end
end