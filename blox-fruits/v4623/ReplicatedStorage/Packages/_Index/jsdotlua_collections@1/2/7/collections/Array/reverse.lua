require(script.Parent.Parent.Parent:WaitForChild("es7-types"))
return function(list)
	local count = #list
	local v = 1

	while v < count do
		local v2 = list[count]
		local v3 = list[v]
		list[v] = v2
		list[count] = v3
		v += 1
		count -= 1
	end

	return list
end