local function shallowEquals(traits, traits2)
	if traits == traits2 then
		return true
	end

	if typeof(traits) ~= typeof(traits2) or typeof(traits) ~= "table" then
		return false
	end

	for k, item in traits do
		if traits2[k] ~= item then
			return false
		end
	end

	for k in traits2 do
		if traits[k] == nil then
			return false
		end
	end

	return true
end

return {
	brainrotMatches = function(data, data2)
		if typeof(data) ~= typeof(data2) and typeof(data) ~= "table" then
			return false
		end

		return data.Index == data2.Index and data.Mutation == data2.Mutation and data.UUID == data2.UUID and shallowEquals(
			data.Traits,
			data2.Traits
		)
	end
}