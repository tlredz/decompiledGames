local module = require("@game/ReplicatedStorage/Omni/Shared/Fruits")

for _, moduleScript in script:GetChildren() do
	if not moduleScript:IsA("ModuleScript") or module.Register(moduleScript.Name, require(moduleScript)) then
		continue
	end

	warn((`Invalid Fruits configuration: {moduleScript.Name}!`))
end

return true