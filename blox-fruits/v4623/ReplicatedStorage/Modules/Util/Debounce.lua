return {
	private = function(flag: boolean?)
		local v = {}
		return {
			clear = function()
				table.clear(v)
			end,
			is = function(p: string)
				assert(p)
				return v[p]
			end,
			try = function(p: string, callback, callback2)
				assert(p)
				task.spawn(function()
					local v2 = nil

					if v[p] == nil then
						v[p] = true
						local success, result = pcall(function()
							v2 = callback()
						end)

						if not success then
							warn(result)
						end

						v[p] = nil
					elseif flag then
						task.spawn(print, (`Debounced : {p}`))
					end

					if callback2 then
						task.spawn(callback2, v2)
					end
				end)
			end
		}
	end
}