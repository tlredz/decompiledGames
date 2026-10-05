local type2 = type

local function num2rgb(p)
	if type2(p) == "number" and p >= 0 and p <= 16777215 then
		return {
			bit32.arshift(p, 16),
			bit32.band(bit32.arshift(p, 8), 255),
			bit32.band(p, 255),
			1
		}
	end

	error((`unknown num color: {p}'`))
end

return num2rgb