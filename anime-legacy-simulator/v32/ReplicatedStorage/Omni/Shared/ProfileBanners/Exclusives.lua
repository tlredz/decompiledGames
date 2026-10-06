local parentModule = require(script.Parent)

for _, moduleScript in script:GetChildren() do
	if not moduleScript:IsA("ModuleScript") then
		continue
	end

	local module = require(moduleScript)
	parentModule.Exclusives[moduleScript.Name] = module

	if module.Configured ~= false and module.Icon ~= "" then
		parentModule.Register(moduleScript.Name, table.clone(module))
	end
end

return true