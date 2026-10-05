local v = {}

local function typeFn(p)
	return v[tostring(p)] or "object"
end

return typeFn