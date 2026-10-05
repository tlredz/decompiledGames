local Types = require(game.ReplicatedStorage.Definitions.Map.Types)
local DEFINITIONS = {}

for _, moduleScript in script.LIBRARY:GetChildren() do
	assert(moduleScript:IsA("ModuleScript"), (`bad definition: {moduleScript:GetFullName()}`))
	local name = moduleScript.Name
	local mapKey, v = Types.MapKey(name)
	assert(mapKey, (`definition module "{moduleScript:GetFullName()}" isn't a valid map key: {v}`))
	assert(DEFINITIONS[name] == nil, (`already assigned map at key "{name}"`))
	local module = require(moduleScript)
	local mapDefinition, v2 = Types.MapDefinition(module)
	assert(mapDefinition, (`map definition for "{name}" returned an invalid type: {v2}`))
	assert(
		module.Key == name,
		(`map definition for "{name}" is keyed as "{module.Key}", which doesn't match its module name`)
	)
	DEFINITIONS[name] = module
end

table.freeze(DEFINITIONS)
return DEFINITIONS