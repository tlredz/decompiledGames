local class = require(game.ReplicatedStorage:WaitForChild("Classes"):WaitForChild("DataTypes"):WaitForChild("class"))
local dictUtil = require(game.ReplicatedStorage:WaitForChild("Services"):WaitForChild("Utility"):WaitForChild("dictUtil"))
local v = class.new()

function v.get(p, p2)
	local cachedModule = p.CachedModules[p2]
	return cachedModule and require(cachedModule)
end

function v:new(p2)
	self.CachedModules = {}
	dictUtil.runDescendantsOfType(p2, "ModuleScript", function(p3)
		self.CachedModules[p3.Name] = p3
	end)
end

return v