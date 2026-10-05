return function(callback, flag: boolean?)
	local v = {}
	setmetatable(v, {
		__index = function(_, p)
			return callback()[p]
		end,
		__newindex = function(_, p, p2)
			local callback_2 = callback()
			callback_2[p] = p2
			return nil
		end,
		__call = function(_, ...)
			return callback()(...)
		end,
		_getfenv = function(...)
			if flag then
				return {}
			end

			return getfenv(...)
		end
	})
	return v
end