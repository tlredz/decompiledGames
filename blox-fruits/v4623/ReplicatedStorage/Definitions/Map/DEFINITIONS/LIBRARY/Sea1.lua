local Builders = require(game.ReplicatedStorage.Definitions.Map.Builders)
require(game.ReplicatedStorage.Definitions.Map.Types)
local moduleScripts = {}

for _, moduleScript in script:GetChildren() do
	assert(moduleScript:IsA("ModuleScript"), (`bad island definition: {moduleScript:GetFullName()}`))
	table.insert(moduleScripts, moduleScript)
end

table.sort(moduleScripts, function(a, b)
	return a.Name < b.Name
end)
local builder = Builders.Map.Builder.new(script.Name)

for _, v in moduleScripts do
	builder = builder:insertIsland(require(v))
end

return builder:build()