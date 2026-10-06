local parentModule = require(script.Parent)

for _, moduleScript in script:GetChildren() do
	if not moduleScript:IsA("ModuleScript") then
		continue
	end

	local module = require(moduleScript)
	parentModule.Exclusives[moduleScript.Name] = module
	parentModule.Register(moduleScript.Name, table.clone(module))
end

return true