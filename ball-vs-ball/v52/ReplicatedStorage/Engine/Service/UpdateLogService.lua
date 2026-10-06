local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Net = require(ReplicatedStorage.Packages.Net)
local Config = require(ReplicatedStorage.Engine.Service.Config)
local PlayerData = require(ReplicatedStorage.Engine.Service.PlayerData)
local UpdateLogService = {
	server = {},
	client = {}
}
local remoteEvent = Net:RemoteEvent("UpdateLogService/MarkRead")

function UpdateLogService.server.init()
	remoteEvent.OnServerEvent:Connect(function(p, value)
		if typeof(value) ~= "string" or not Config.updateLog.byName[value] then
			return
		end

		PlayerData.server[p].updateLog(value)
	end)
end

function UpdateLogService.client.markRead(p: string)
	remoteEvent:FireServer(p)
end

return UpdateLogService