local function limit(p: number, p2: number?, p3: number?)
	local v = p2 == nil and 0 or p2
	local selected = p3 == nil and 1 or p3

	if p < v then
		return v
	end

	if selected < p then
		return selected
	end

	return p
end

return limit