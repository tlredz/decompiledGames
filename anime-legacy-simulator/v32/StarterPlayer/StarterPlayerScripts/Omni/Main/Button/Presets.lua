local Presets = {}

function ModuleLoader(moduleScript)
	if not moduleScript:IsA("ModuleScript") or Presets[moduleScript.Name] then
		return
	end

	local v = Presets
	local name = moduleScript.Name
	local module = require(moduleScript)
	v[name] = module
end

for _, child in script:GetChildren() do
	ModuleLoader(child)
end

return Presets