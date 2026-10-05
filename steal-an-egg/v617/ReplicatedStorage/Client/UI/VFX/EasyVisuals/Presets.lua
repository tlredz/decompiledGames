require(script.Parent.Layers)

local function collectRecipes()
	local modulesByName = {}

	for _, moduleScript in script:GetDescendants() do
		if not moduleScript:IsA("ModuleScript") then
			continue
		end

		local name = moduleScript.Name
		local module = require(moduleScript)
		modulesByName[name] = module
	end

	return modulesByName
end

return (collectRecipes())