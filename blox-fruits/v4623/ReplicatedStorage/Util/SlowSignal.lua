local ListCache = require(script.Parent.ListCache)
return {
	new = function(_: number?, _: number?)
		local flag = true
		local v = ListCache.new()
		local count = 0
		local v2 = {
			GetIfAlive = function(_)
				return flag
			end,
			Destroy = function(_)
				if not flag then
					return
				end

				flag = false
				v:clear()
			end,
			Connect = function(_, callback)
				assert(flag, "dead signal")
				count += 1
				local v3 = count
				local v4 = {
					callback = callback
				}
				v:set(v3, v4)
				return function()
					v4.dead = true
					v:set(v3, nil)
				end
			end,
			FireAsync = function(_, ...)
				local v3 = table.pack(...)
				assert(flag, "dead signal")

				for _, v4 in v:dump() do
					if not flag then
						break
					end

					if not v4.dead then
						v4.callback(table.unpack(v3, 1, v3.n))
					end
				end
			end
		}
		table.freeze(v2)
		return v2
	end
}