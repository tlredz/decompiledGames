local v = {
	__index = function(p, p2)
		table.insert(p.__paths__, p2)
		return p
	end,
	__call = function(p)
		local __obj__ = p.__obj__

		for _, childName in pairs(p.__paths__) do
			__obj__ = __obj__:WaitForChild(childName, 1000000)
		end

		return __obj__
	end
}
return (setmetatable({}, {
	__index = function(_, instance)
		if typeof(instance) == "Instance" then
			return (setmetatable({
				__obj__ = instance,
				__paths__ = {}
			}, v))
		end

		return (setmetatable({
			__obj__ = game,
			__paths__ = { instance == "workspace" and "Workspace" or instance }
		}, v))
	end
}))