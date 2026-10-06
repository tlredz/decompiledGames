local CursedAcademy = {}

for _, moduleScript in script:GetChildren() do
	if not moduleScript:IsA("ModuleScript") then
		continue
	end

	local name = moduleScript.Name
	local module = require(moduleScript)
	CursedAcademy[name] = module
end

return CursedAcademy