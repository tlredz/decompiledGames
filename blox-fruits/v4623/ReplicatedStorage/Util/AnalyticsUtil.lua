local RunService = game:GetService("RunService")
local Net = require(game.ReplicatedStorage.Modules.Net)
local remoteEvent = Net:RemoteEvent("OnAnalyticsActivity")
return {
	_OnAnalyticsActivity = remoteEvent,
	reportActivity = function(p: string)
		assert(RunService:IsClient(), "fireClientActivity can only be called from the client!")
		task.spawn(function()
			remoteEvent:FireServer(p)
		end)
	end
}