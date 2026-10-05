local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local Checklists = require(ReplicatedStorage.CAM.Global.Checklists)
local DataPathService = RunService:IsServer() and require(ServerStorage.SAM.Services.DataPathService) or nil
return function(items, p, p2)
	local v = nil

	for k, checklist in Checklists do
		if k:lower() ~= tostring(p):lower() then
			continue
		end

		v = checklist
	end

	if v == nil then
		warn((`Set/Checklist: no checklist named "{p}"`))
		return
	end

	local v2 = math.clamp(math.floor(tonumber(p2) or 0), 0, v.Goal)

	for _, item in items do
		local v3, v4

		if v2 == 0 then
			v3, v4 = DataPathService.Clear(item, "Slot", v.Path)
		else
			v3, v4 = DataPathService.Set(item, "Slot", v.Path, v2)
		end

		if v3 == false then
			warn((`Set/Checklist: refused for {item.Name}: {v4}`))
		end
	end
end