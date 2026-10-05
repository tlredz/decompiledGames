local function round(p: number)
	local v = math.round(p)

	if v == 0 then
		return 0
	end

	return v
end

return round