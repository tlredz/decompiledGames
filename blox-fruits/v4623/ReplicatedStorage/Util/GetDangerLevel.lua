return function(value: number?)
	local percent = 0
	local level = 0

	if value then
		local v3 = {
			0,
			80,
			160,
			240,
			300,
			400,
			500
		}

		for k, v4 in pairs(v3) do
			if not (v4 <= value) then
				continue
			end

			percent = (value - v4) / ((v3[k + 1] or 1e999) - v4)
			level = k
		end
	end

	return {
		danger = value or 0,
		level = level,
		percent = percent
	}
end