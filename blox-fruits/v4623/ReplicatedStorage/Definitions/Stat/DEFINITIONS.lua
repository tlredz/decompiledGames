local Types = require(game.ReplicatedStorage.Definitions.Stat.Types)
local DEFINITIONS = {}

for _, moduleScript in script.LIBRARY:GetChildren() do
	assert(moduleScript:IsA("ModuleScript"), (`bad definition: {moduleScript:GetFullName()}`))
	local name = moduleScript.Name
	local fullType, v = Types.FullType(name)
	assert(fullType, (`definition module "{moduleScript:GetFullName()}" isn't a valid stat key: {v}`))
	assert(DEFINITIONS[name] == nil, (`already assigned stat at key "{name}"`))
	local module = require(moduleScript)
	local statDefinition, v2 = Types.StatDefinition(module)
	assert(statDefinition, (`stat definition for "{name}" returned an invalid type: {v2}`))
	assert(
		module.Key == name,
		(`stat definition for "{name}" is keyed as "{module.Key}", which doesn't match its module name`)
	)
	DEFINITIONS[name] = module
end

table.freeze(DEFINITIONS)
return DEFINITIONS