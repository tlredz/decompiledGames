local Builders = require(game.ReplicatedStorage.Definitions.Stat.Builders)
require(game.ReplicatedStorage.Definitions.Stat.Types)
local v = Builders.Stat.Builder.new(script.Name):setDisplayName("NPC Damage"):setValueForm("Multiply")
local moduleScripts = {}

for _, moduleScript in script.Variants:GetChildren() do
	assert(moduleScript:IsA("ModuleScript"), (`bad variant definition: {moduleScript:GetFullName()}`))
	table.insert(moduleScripts, moduleScript)
end

table.sort(moduleScripts, function(a, b)
	return a.Name < b.Name
end)

for _, v2 in moduleScripts do
	v = v:insertVariant(require(v2))
end

return v:build()