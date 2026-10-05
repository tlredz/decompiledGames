local RunService = game:GetService("RunService")

if not RunService:IsClient() then
	local AdminPermissions = require(game.ServerScriptService.Admin.AdminPermissions)
	return function(registry)
		registry:RegisterHook("BeforeRun", function(p)
			if AdminPermissions.CanRunCommand(p.Executor, p.Name) then
				return
			else
				return "You don't have permission to run this command"
			end
		end)
	end
end

local Players = game:GetService("Players")
local v = {
	resetdata = true,
	follow = true
}
return function(registry)
	registry:RegisterHook("BeforeRun", function(p)
		if Players.LocalPlayer:GetAttribute("CmdrRole") == "QALEAD" and not v[string.lower(p.Name)] then
			return "QALEAD can only use resetdata and follow."
		end
	end)
end