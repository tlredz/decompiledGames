local DeepCopy

DeepCopy = function(p)
	local clone = table.clone(p)

	for k, v in clone do
		if type(v) == "table" then
			clone[k] = DeepCopy(v)
		end
	end

	return clone
end

return DeepCopy