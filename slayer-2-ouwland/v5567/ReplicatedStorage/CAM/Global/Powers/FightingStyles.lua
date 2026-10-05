local FightingStyles = {}

for _, moduleScript in pairs(script:GetChildren()) do
	local name = moduleScript.Name
	local module = require(moduleScript)
	FightingStyles[name] = module
end

return FightingStyles