local RewardsDatabase = {}

for _, moduleScript in pairs(script:GetChildren()) do
	if not moduleScript:IsA("ModuleScript") then
		continue
	end

	local name = moduleScript.Name
	local module = require(moduleScript)
	RewardsDatabase[name] = module
end

return RewardsDatabase