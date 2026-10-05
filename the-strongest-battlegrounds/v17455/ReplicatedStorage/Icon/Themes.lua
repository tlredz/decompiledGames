local Themes = {}

for _, moduleScript in pairs(script:GetChildren()) do
	if not moduleScript:IsA("ModuleScript") then
		continue
	end

	local name = moduleScript.Name
	local module = require(moduleScript)
	Themes[name] = module
end

return Themes