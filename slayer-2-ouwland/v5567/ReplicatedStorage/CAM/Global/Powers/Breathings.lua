local Breathings = {}

for _, moduleScript in pairs(script:GetChildren()) do
	local name = moduleScript.Name
	local module = require(moduleScript)
	Breathings[name] = module
end

return Breathings