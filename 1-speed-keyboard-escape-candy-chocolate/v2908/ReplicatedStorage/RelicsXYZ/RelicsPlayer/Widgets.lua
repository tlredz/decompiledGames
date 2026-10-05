local parent = script.Parent
require(parent.State)
local Widgets = {}

for _, moduleScript in ipairs(script:GetChildren()) do
	if not moduleScript:IsA("ModuleScript") then
		continue
	end

	local name = moduleScript.Name
	local module = require(moduleScript)
	Widgets[name] = module
end

return Widgets