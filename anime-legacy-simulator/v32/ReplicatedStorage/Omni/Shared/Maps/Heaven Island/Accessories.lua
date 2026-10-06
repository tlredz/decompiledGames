local module = require("@game/ReplicatedStorage/Omni/Shared/Accessories")

for _, moduleScript in script:GetChildren() do
	if not moduleScript:IsA("ModuleScript") then
		continue
	end

	local register = module.Register
	local name = script.Parent.Name
	local name2 = moduleScript.Name
	local module2 = require(moduleScript)
	register(name, {
		[name2] = module2
	})
end

return true