local module = require("@game/ReplicatedStorage/Omni/Shared/Gacha")

for _, moduleScript in script:GetChildren() do
	if moduleScript:IsA("ModuleScript") then
		module.RegisterGacha(moduleScript.Name, require(moduleScript))
	end
end

return true