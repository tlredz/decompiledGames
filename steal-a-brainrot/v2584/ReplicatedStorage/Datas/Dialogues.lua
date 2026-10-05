local Dialogues = {}

for _, moduleScript in script:GetChildren() do
	if not moduleScript:IsA("ModuleScript") then
		continue
	end

	local module = require(moduleScript)
	Dialogues[moduleScript.Name] = module
end

return Dialogues