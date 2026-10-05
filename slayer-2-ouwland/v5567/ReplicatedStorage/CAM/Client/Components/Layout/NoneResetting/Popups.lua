local ReplicatedStorage = game:GetService("ReplicatedStorage")
local modules = {}

for _, moduleScript in ipairs(script:GetChildren()) do
	table.insert(modules, require(moduleScript))
end

local faye = require(ReplicatedStorage.Packages.faye)
return function(p)
	local v = faye.new()

	for _, v2 in ipairs(modules) do
		v2(v, p)
	end

	return function()
		v:Destroy()
	end
end