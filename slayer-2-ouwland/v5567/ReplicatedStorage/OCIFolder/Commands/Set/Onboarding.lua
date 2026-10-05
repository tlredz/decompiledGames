local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local DataPathService = RunService:IsServer() and require(ServerStorage.SAM.Services.DataPathService) or nil
return function(items, p)
	local v = tonumber(p)

	if v == nil or v % 1 ~= 0 or v < 0 or v > 6 then
		warn((`Set/Onboarding: "{p}" is not a step (0 to {6})`))
		return
	end

	for _, item in items do
		local v2, v3

		if v == 0 then
			v2, v3 = DataPathService.Clear(item, "Slot", "Misc/Onboarding")
		else
			v2, v3 = DataPathService.Set(item, "Slot", "Misc/Onboarding", v)
		end

		if v2 == false then
			warn((`Set/Onboarding: refused for {item.Name}: {v3}`))
		end
	end
end