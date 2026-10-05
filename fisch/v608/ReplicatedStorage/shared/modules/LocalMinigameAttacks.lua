local LocalMinigameAttacks = {}

for _, moduleScript in script:GetChildren() do
	assert(
		moduleScript:IsA("ModuleScript"),
		(`ModuleScript expected, got {moduleScript.ClassName} for {moduleScript.Name}`)
	)
	local name = moduleScript.Name
	local module = require(moduleScript)
	LocalMinigameAttacks[name] = module
end

return LocalMinigameAttacks