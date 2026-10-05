local Styles = {}

for _, moduleScript in ipairs(script.Parent.Parent.Styles:GetChildren()) do
	if moduleScript.ClassName ~= "ModuleScript" then
		continue
	end

	local name = moduleScript.Name
	local module = require(moduleScript)
	Styles[name] = module
end

return Styles