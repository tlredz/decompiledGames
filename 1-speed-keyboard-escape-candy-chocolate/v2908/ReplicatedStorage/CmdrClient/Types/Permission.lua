local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AdminPermissions = require(ReplicatedStorage._FRAMEWORK.Features.Admins.AdminPermissions)
return function(registry)
	registry:RegisterHook("BeforeRun", function(p)
		if RunService:IsStudio() then
			return nil
		end

		local permissionForCommand = AdminPermissions.getPermissionForCommand(p.Name)

		if permissionForCommand and AdminPermissions.hasPermission(p.Executor.UserId, permissionForCommand) then
			return nil
		end

		return "You do not have permission to use this command."
	end)
end