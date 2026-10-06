local module = require("@game/ReplicatedStorage/Omni/Shared/Weapons")

for _, moduleScript in script:GetChildren() do
	if not moduleScript:IsA("ModuleScript") then
		continue
	end

	local register = module.Register
	local name = moduleScript.Name
	local module2 = require(moduleScript)
	register(name, module2, script.Parent.Name)
end

return true