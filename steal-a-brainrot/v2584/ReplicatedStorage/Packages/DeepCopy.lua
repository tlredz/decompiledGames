local deepCopy

deepCopy = function(p)
	local clone = table.clone(p)

	for k, v in clone do
		if typeof(v) == "table" then
			clone[k] = deepCopy(v)
		end
	end

	return clone
end

return deepCopy