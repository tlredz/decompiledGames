local modulesByName = {}
local TransformationController = {}

for _, moduleScript in pairs(script:GetChildren()) do
	local name = moduleScript.Name
	local module = require(moduleScript)
	modulesByName[name] = module
end

function TransformationController.get(instance)
	if instance:FindFirstChild("DragonHybrid") then
		return modulesByName.DragonHybrid
	end
end

function TransformationController.execute(p, p2, ...)
	local v = TransformationController.get(p)
	local v2 = v and v[p2]

	if v2 then
		return v2(p, ...)
	end
end

return TransformationController