local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local v = {
	[1927880506] = true,
	[2790707588] = true
}

if RunService:IsServer() then
	local AdminPanelService = require(ServerScriptService.Controllers.AdminPanelService)
	return function(registry)
		registry:RegisterHook("BeforeRun", function(p)
			local executor = p.Executor
			local _ = p.Group

			if v[executor.UserId] then
				return "You do not have permission to run this function."
			end

			if AdminPanelService.IsAdmin(executor) then
				return
			else
				return "You do not have permission to run this function."
			end
		end)
	end
end

local Remotes = require(ReplicatedStorage.Shared.Remotes)
require(ReplicatedStorage.Shared.Globals.Constants)
local v2 = false
Remotes.StaffConsole.StaffVerdict.OnClientEvent:Connect(function(flag: boolean)
	v2 = flag
end)
Remotes.StaffConsole.ProbeStaffStatus:FireServer()
return function(registry)
	registry:RegisterHook("BeforeRun", function(p)
		local executor = p.Executor
		local _ = p.Group

		if v[executor.UserId] then
			return "You do not have permission to run this function."
		end

		if v2 then
			return
		else
			return "You do not have permission to run this function."
		end
	end)
end