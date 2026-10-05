local log = math.log

local function temperature2rgb(p: number)
	local v = p / 100
	local v2, v3, v4

	if v < 66 then
		v2 = 255

		if v < 6 then
			v3 = 0
		else
			local v5 = v - 2
			v3 = -155.25485562709179 - 0.44596950469579133 * v5 + log(v5) * 104.49216199393888
		end

		if v < 20 then
			v4 = 0
		else
			local v5 = v - 10
			v4 = -254.76935184120902 + 0.8274096064007395 * v5 + log(v5) * 115.67994401066147
		end
	else
		local v5 = v - 55
		v2 = 351.97690566805693 + 0.114206453784165 * v5 - log(v5) * 40.25366309332127
		local v6 = v - 50
		v3 = 325.4494125711974 + 0.07943456536662342 * v6 - log(v6) * 28.0852963507957
		v4 = 255
	end

	return {
		v2,
		v3,
		v4,
		1
	}
end

return temperature2rgb