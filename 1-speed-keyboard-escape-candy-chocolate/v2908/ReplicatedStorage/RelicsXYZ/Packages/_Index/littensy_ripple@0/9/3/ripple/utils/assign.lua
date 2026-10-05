local function assign(p, ...)
	assert(type(p) == "table", (`Expected a table for first argument, got ${type(p)}`))

	for i = 1, select("#", ...) do
		local v = select(i, ...)

		for k, v2 in v do
			p[k] = v2
		end
	end

	return p
end

return assign