local parentModule = require(script.Parent)

for _, moduleScript in script:GetChildren() do
	if not moduleScript:IsA("ModuleScript") then
		continue
	end

	local module = require(moduleScript)
	parentModule.Exclusives[moduleScript.Name] = module

	if module.Configured == false or module.Model == "" or module.Icon == "" or module.MaxSpeed <= 0 then
		continue
	end

	parentModule.Register(moduleScript.Name, table.clone(module))
end

return true