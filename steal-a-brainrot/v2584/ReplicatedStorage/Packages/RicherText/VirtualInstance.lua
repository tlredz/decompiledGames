local v = {
	__index = function(p, p2: string)
		local __v = p.__v

		if __v.lastSet[p2] == nil then
			return __v.instance[p2]
		end

		return __v.lastSet[p2]
	end,
	__newindex = function(p, p2: string, p3)
		assert(p3 ~= nil, "cannot set vinst property to nil")
		local __v = p.__v

		if __v.lastSet[p2] == p3 then
			return
		end

		__v.bufferedChanges[p2] = p3
		__v.lastSet[p2] = p3

		if not __v.hasBuffered then
			__v.hasBuffered = true
			task.defer(function()
				local instance = __v.instance

				if not __v.hasBuffered then
					return
				end

				__v.hasBuffered = false

				for k, bufferedChange in __v.bufferedChanges do
					instance[k] = bufferedChange
				end

				table.clear(__v.bufferedChanges)
			end)
		end
	end
}
local VirtualInstance = {}

function VirtualInstance.wrap(instance)
	return (setmetatable({
		__v = {
			instance = instance,
			lastSet = {},
			bufferedChanges = {},
			hasBuffered = false
		}
	}, v))
end

function VirtualInstance.cancel(p)
	local v2 = rawget(p, "__v")

	if v2 then
		v2.hasBuffered = false
		table.clear(v2.bufferedChanges)
		table.clear(v2.lastSet)
	end
end

return VirtualInstance