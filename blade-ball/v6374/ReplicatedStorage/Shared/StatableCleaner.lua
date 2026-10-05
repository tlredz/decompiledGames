local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
require3(ReplicatedStorage2.Shared.Statable)
local StatableCleaner = {}
StatableCleaner.__index = StatableCleaner

function StatableCleaner.new()
	local self = setmetatable({}, StatableCleaner)
	self._statables = {}
	return self
end

function StatableCleaner:Add(p2)
	table.insert(self._statables, 1, p2)
	return p2
end

function StatableCleaner:Destroy()
	local clone = table.clone(self._statables)
	table.clear(self._statables)

	for _, v in clone do
		if type(v.Destroy) == "function" then
			v:Destroy()
		end
	end
end

return StatableCleaner