return {
	new = function()
		local v = {}
		local v2 = {}
		local v3 = {}
		local v4 = {
			dump = function(_)
				return table.clone(v3)
			end,
			get = function(_, p)
				local v5 = v[p]
				return v3[v5]
			end,
			set = function(_, p, p2)
				local v5 = v[p]

				if v5 then
					if p2 == nil then
						local count = #v3

						if v5 ~= count then
							local v6 = v2[count]
							v3[v5] = v3[count]
							v2[v5] = v6
							v[v6] = v5
						end

						v3[count] = nil
						v2[count] = nil
						v[p] = nil
					else
						v3[v5] = p2
					end
				elseif p2 ~= nil then
					local v6 = #v3 + 1
					v[p] = v6
					v2[v6] = p
					v3[v6] = p2
				end

				return #v3
			end,
			clear = function(_)
				local v5 = v
				local v6 = v2
				local v7 = v3
				v = {}
				v2 = {}
				v3 = {}
				table.clear(v5)
				table.clear(v6)
				table.clear(v7)
			end
		}
		table.freeze(v4)
		return v4
	end
}