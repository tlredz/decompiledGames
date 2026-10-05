local function mergeTables(p, items)
	for k, item in items do
		if not (typeof(p[k]) ~= typeof(item) or p[k] == (getmetatable(p) or {})[k]) then
			continue
		end

		if type(item) == "table" then
			p[k] = table.clone(item)
		else
			p[k] = item
		end
	end

	return p
end

return mergeTables