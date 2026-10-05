local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
require3(ReplicatedStorage2.Shared.ThreadSafeTargetingHelper)
return function(list, p)
	if not p.perspectiveCharacter then
		return
	end

	if p.perspectiveCharacter:GetAttribute("IsDoppelganger") then
		local doppelgangerOwner = p.perspectiveCharacter:GetAttribute("DoppelgangerOwner")

		for k, v in list do
			if v.Name ~= doppelgangerOwner then
				continue
			end

			table.remove(list, k)
			return
		end
	end
end