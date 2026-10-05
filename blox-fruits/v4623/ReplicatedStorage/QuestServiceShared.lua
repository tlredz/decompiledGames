local RunService = game:GetService("RunService")
RunService:IsClient()
local RunService2 = game:GetService("RunService")
RunService2:IsServer()
local Net = require(game.ReplicatedStorage.Modules.Net)
Net:RemoteEvent("QuestUpdate", true)
return {}