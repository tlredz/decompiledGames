local function merge(p, items)
	local clone = table.clone(p)

	for k, item in pairs(items) do
		clone[k] = item
	end

	return clone
end

return merge