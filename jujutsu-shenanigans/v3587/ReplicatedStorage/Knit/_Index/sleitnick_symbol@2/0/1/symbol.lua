local function Symbol(value: string?)
	local v = newproxy(true)
	local v2 = value or ""

	getmetatable(v).__tostring = function()
		return "Symbol(" .. v2 .. ")"
	end

	return v
end

return Symbol