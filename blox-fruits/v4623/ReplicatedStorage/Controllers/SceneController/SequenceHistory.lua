local v = {}
return function(p)
	return {
		WasSequencePlayedFromAny = function(p2: string)
			for k, v2 in pairs(v) do
				if p ~= k then
					continue
				end

				for _, v3 in pairs(v2) do
					if v3[p2] == true then
						return true
					end
				end
			end

			return false
		end,
		WasSequencePlayedFromLocation = function(p2: string, p3: string)
			if v[p] and v[p][p2] then
				return v[p][p2][p3]
			end

			return false
		end,
		SetSequencePlayedFromLocation = function(p2: string, p3: string)
			if v[p] == nil then
				v[p] = {}
			end

			if v[p][p2] == nil then
				v[p][p2] = {}
			end

			v[p][p2][p3] = true
		end
	}
end