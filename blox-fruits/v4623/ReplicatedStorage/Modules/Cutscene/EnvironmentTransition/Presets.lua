local parentModule = require(script.Parent)
require(script.Parent.Parent.Types)
local modulesByName = {}
local v = {}

for _, moduleScript in script:GetChildren() do
	if not moduleScript:IsA("ModuleScript") then
		continue
	end

	local module = require(moduleScript)
	assert(
		parentModule.is(module),
		(`Environment transition preset "{moduleScript.Name}" must return EnvironmentTransition.new()`)
	)
	modulesByName[moduleScript.Name] = module
end

function v.get(p)
	local v2 = modulesByName[(p == "Default" or p == "Fade to black") and "FadeToBlack" or p]
	assert(v2, (`Unknown environment transition preset "{p}"`))
	return v2
end

return table.freeze(v)