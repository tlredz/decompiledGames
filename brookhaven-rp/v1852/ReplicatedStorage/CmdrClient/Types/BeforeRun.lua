local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CmdrPermissions = require(ReplicatedStorage.Modules.Shared.Cmdr.CmdrPermissions)
return function(registry)
	registry:RegisterHook("BeforeRun", function(p)
		if CmdrPermissions.hasCommandAccess(p.Executor, p.Name) then
			return nil
		end

		return "Sorry, you don't have permissions to use that command!"
	end)
end