local v = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FastSignal = require(ReplicatedStorage.Modules.FastSignal)
return (setmetatable({}, {
	__index = function(_, p)
		if v[p] then
			return v[p]
		end

		local result = {}
		local v2 = {}
		local class2 = {}
		v2.Events = {
			Global = FastSignal.new()
		}
		v2.OnUpdate = v2.Events

		function v2.GetPropertyChangedSignal(_, p2)
			if not v2.Events[p2] then
				v2.Events[p2] = FastSignal.new()
			end

			return v2.Events[p2]
		end

		function v2.UpdateProperty(_, p2)
			if not v2.Events[p2] then
				return
			end

			v2.Events[p2]:Fire(result[p2])
		end

		function v2.WaitFor(_, p2)
			while not result[p2] do
				task.wait()
			end
		end

		function v2.Dump(_)
			return result
		end

		function v2.Set(_, items)
			for k, _ in next, result, nil do
				if not items[k] then
					result[k] = nil
				end
			end

			for k, item in next, items, nil do
				result[k] = item

				if v2.Events[k] then
					v2.Events[k]:Fire(item)
				end
			end

			v2.Events.Global:Fire()
		end

		function class2.__index(_, p2)
			return result[p2] or v2[p2]
		end

		function class2.__newindex(_, p2, p3)
			local v3 = result[p2]

			if v3 == p3 then
				return
			end

			result[p2] = p3
			v2.Events.Global:Fire(p2, p3)

			if v2.Events[p2] then
				v2.Events[p2]:Fire(p3, v3)
			end
		end

		v[p] = setmetatable({}, class2)
		return v[p]
	end,
	__newindex = function(p, p2, items)
		local v2 = p[p2]

		if typeof(items) == "table" then
			for k, item in next, items, nil do
				v2[k] = item
			end
		end
	end
}))