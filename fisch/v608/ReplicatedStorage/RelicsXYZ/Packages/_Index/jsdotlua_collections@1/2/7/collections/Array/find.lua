require(script.Parent.Parent.Parent:WaitForChild("es7-types"))
return function(list, callback)
	for i = 1, #list do
		local v = list[i]

		if callback(v, i, list) then
			return v
		end
	end

	return nil
end