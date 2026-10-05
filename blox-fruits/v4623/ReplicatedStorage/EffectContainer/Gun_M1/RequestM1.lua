local modulesByName = {}

for _, moduleScript in pairs(script:GetChildren()) do
	local name = moduleScript.Name
	local module = require(moduleScript)
	modulesByName[name] = module
end

return function(p)
	task.wait()
	local effectModuleName = p.EffectModuleName or p.Type

	if modulesByName[effectModuleName] then
		modulesByName[effectModuleName](p)
		return
	end

	warn("Gun M1 with type: ", p.Type, " : does not exist!")
	modulesByName.Default(p)
end