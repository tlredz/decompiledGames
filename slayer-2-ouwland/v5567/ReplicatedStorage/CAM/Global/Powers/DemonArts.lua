local DemonArts = {}

for _, moduleScript in pairs(script:GetChildren()) do
	local name = moduleScript.Name
	local module = require(moduleScript)
	DemonArts[name] = module
end

return DemonArts