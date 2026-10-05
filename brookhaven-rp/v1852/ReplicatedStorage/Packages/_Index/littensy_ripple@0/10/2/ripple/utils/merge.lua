local function merge(p, items)
	local clone = p

	for k, item in items do
		if p[k] == item then
			continue
		end

		if clone == p then
			clone = table.clone(p)
		end

		clone[k] = item
	end

	return clone
end

return merge