local HeavenIsland = {}

for _, moduleScript in script:GetChildren() do
	if not moduleScript:IsA("ModuleScript") then
		continue
	end

	local name = moduleScript.Name
	local module = require(moduleScript)
	HeavenIsland[name] = module
end

return HeavenIsland