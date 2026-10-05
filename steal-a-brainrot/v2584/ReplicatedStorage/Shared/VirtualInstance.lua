local v = {
	__index = function(p, p2: string)
		local __internals = p.__internals

		if __internals.lastSet[p2] == nil then
			return __internals.instance[p2]
		end

		return __internals.lastSet[p2]
	end,
	__newindex = function(p, p2: string, p3)
		assert(p3 ~= nil, "cannot set vinst property to nil")
		local __internals = p.__internals

		if __internals.lastSet[p2] == p3 then
			return
		end

		__internals.bufferedChanges[p2] = p3
		__internals.lastSet[p2] = p3

		if not __internals.hasBuffered then
			__internals.hasBuffered = true
			task.defer(function()
				local instance = __internals.instance

				if not __internals.hasBuffered then
					return
				end

				__internals.hasBuffered = false

				for k, bufferedChange in __internals.bufferedChanges do
					instance[k] = bufferedChange
				end

				table.clear(__internals.bufferedChanges)
			end)
		end
	end
}
return {
	wrap = function(instance)
		return (setmetatable({
			__internals = {
				instance = instance,
				lastSet = {},
				bufferedChanges = {},
				hasBuffered = false
			}
		}, v))
	end
}