local function xtypeof(p)
	local typeName = typeof(p)

	if typeName == "table" and typeof(p.type) == "string" then
		return p.type
	end

	return typeName
end

return xtypeof