return function(callback, callback2, flag: boolean?)
	local v = nil
	local v2 = {
		IsInitialized = false,
		init = function()
			if v ~= nil then
				return function() end
			end

			local v3 = callback()
			v = v3
			assert(v ~= nil, "construction failed")
			return function()
				if v == v3 then
					v = nil
				end

				callback2(v3)
			end
		end
	}
	local v3 = {}
	setmetatable(v3, {
		__index = function(_, p)
			if v == nil then
				return v2[p]
			end

			return v[p]
		end,
		__newindex = function(_, p, p2)
			if v == nil then
				error("you can't write to the init interface")
			else
				v[p] = p2
			end
		end,
		__call = function(_, ...)
			if v ~= nil then
				return v(...)
			end

			error("you can't cal the init interface")
		end,
		_getfenv = function(...)
			if flag then
				return {}
			end

			return getfenv(...)
		end
	})
	return v3
end