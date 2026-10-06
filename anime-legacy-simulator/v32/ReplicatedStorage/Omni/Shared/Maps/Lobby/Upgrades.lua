local module = require("@game/ReplicatedStorage/Omni/Shared/Upgrade")

for _, moduleScript in script:GetChildren() do
	if moduleScript:IsA("ModuleScript") then
		module.Register(moduleScript.Name, require(moduleScript))
	end
end

return true