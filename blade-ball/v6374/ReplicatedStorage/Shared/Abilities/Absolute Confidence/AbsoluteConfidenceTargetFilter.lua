local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
require3(ReplicatedStorage2.Shared.ThreadSafeTargetingHelper)
return function(list, p)
	if p.perspectiveCharacter and p.perspectiveCharacter:GetAttribute("IsConfident") then
		return
	end

	for _, v in list do
		if not v:GetAttribute("IsConfident") then
			continue
		end

		table.clear(list)
		table.insert(list, v)
		break
	end
end