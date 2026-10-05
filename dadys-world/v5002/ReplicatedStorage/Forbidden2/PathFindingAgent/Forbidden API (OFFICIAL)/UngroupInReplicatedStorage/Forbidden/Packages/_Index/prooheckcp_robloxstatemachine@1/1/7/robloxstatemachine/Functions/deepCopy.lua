local deepCopy

deepCopy = function(item)
	local self = setmetatable({}, (getmetatable(item)))

	for k, item2 in item do
		if typeof(item2) == "table" then
			self[k] = deepCopy(item2)
		else
			self[k] = item2
		end
	end

	return self
end

return deepCopy