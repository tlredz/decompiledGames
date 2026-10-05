local TargetHandlers = {}

for _, moduleScript in script:GetChildren() do
	local name = moduleScript.Name
	local module = require(moduleScript)
	TargetHandlers[name] = module
end

return TargetHandlers