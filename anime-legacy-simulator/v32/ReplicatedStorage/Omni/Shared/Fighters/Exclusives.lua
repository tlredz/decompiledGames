local parentModule = require(script.Parent)

for _, moduleScript in script:GetChildren() do
	if not moduleScript:IsA("ModuleScript") then
		continue
	end

	local module = require(moduleScript)
	parentModule.Exclusives[moduleScript.Name] = module

	if module.Configured == false then
		continue
	end

	if not (module.CopyStrongest or not (module.Damage <= 0) and not (module.SPA <= 0) and not (module.UltHits <= 0) and not (module.UltMultiplier <= 0) and next(module.Ultimate)) then
		continue
	end

	local name = module.Name or moduleScript.Name

	if name == "" then
		continue
	end

	local model

	if module.Model == nil then
		model = name
	else
		model = module.Model
	end

	if not (module.PlayerAvatar or typeof(model) == "string" and model ~= "") then
		continue
	end

	local clone = table.clone(module)
	clone.Model = model
	clone.Ultimate = table.clone(module.Ultimate)
	parentModule.Register(module.MapName or "", {
		[name] = clone
	})
end

return true