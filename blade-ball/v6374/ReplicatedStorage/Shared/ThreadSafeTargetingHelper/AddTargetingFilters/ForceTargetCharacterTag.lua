local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)(script.Parent.Parent)
return function(list, p)
	if p.perspectiveCharacter then
		local forceTargetCharacter = p.perspectiveCharacter:FindFirstChild("ForceTargetCharacter")

		if forceTargetCharacter and forceTargetCharacter:IsA("ObjectValue") then
			table.clear(list)

			if forceTargetCharacter.Value and forceTargetCharacter.Value:IsA("Model") then
				table.insert(list, forceTargetCharacter.Value)
			end
		end
	end
end