local modulesByName = {}

for _, folder in script:GetChildren() do
	if not folder:IsA("Folder") then
		continue
	end

	local name = folder.Name

	for _, moduleScript in folder:GetChildren() do
		if not moduleScript:IsA("ModuleScript") then
			continue
		end

		local module = require(moduleScript)

		if not module then
			continue
		end

		module.MapName = name
		module.Name = moduleScript.Name
		modulesByName[moduleScript.Name] = module
	end
end

return table.freeze(modulesByName)