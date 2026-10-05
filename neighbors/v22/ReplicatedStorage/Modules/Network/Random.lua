return {
	new = function(value)
		local v = value or 1
		return function(...)
			v = (v * 214013 + 2531011) % 4294967296
			local v2 = (v - v % 65536) / 65536 % 32768 / 32767
			local v3, v4 = ...

			if v3 and v4 then
				local v5 = v3 - v3 % 1
				local v6 = v2 * (1 + v4 - v5 - v4 % 1)
				return v6 + v5 - v6 % 1
			else
				if not v3 then
					return v2
				end

				local v5 = v3 - v3 % 1
				return 1 + v2 * v5 - v2 * v5 % 1
			end
		end
	end
}