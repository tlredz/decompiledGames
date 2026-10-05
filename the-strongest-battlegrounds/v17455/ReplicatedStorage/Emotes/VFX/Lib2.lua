local modulesByName = {}
return function(p)
	for _, moduleScript in script:GetChildren() do
		if not modulesByName[moduleScript.Name] then
			modulesByName[moduleScript.Name] = moduleScript:IsA("ModuleScript") and require(moduleScript) or nil
		end
	end

	return modulesByName[p] or modulesByName
end