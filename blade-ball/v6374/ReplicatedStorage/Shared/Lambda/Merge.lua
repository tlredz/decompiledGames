local function Merge(p, items)
	local clone = table.clone(p)

	for k, item in next, items, nil do
		clone[k] = item
	end

	table.freeze(clone)
	return clone
end

return Merge