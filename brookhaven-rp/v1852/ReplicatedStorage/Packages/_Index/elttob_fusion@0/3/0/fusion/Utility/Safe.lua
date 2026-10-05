local _ = script.Parent.Parent

local function Safe(p)
	local _, v = xpcall(p.try, p.fallback)
	return v
end

return Safe