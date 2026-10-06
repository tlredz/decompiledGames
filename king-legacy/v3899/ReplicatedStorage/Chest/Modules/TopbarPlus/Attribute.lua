task.defer(function()
	local RunService = game:GetService("RunService")
	local VERSION = require(script.Parent.VERSION)
	VERSION.getAppVersion()
	VERSION.getLatestVersion()
	local _ = not VERSION.isUpToDate()
	RunService:IsStudio()
end)
return {}