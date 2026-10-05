local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Net = require(ReplicatedStorage.Packages.Net)

if not RunService:IsServer() then
	return Net:Invoke("FuseBrainrot/RequestList")
end

game:GetService("ServerStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerFuseMachineData = require(ServerScriptService.Services.FuseMachineService.ServerFuseMachineData)
local CommandsService = require(ServerScriptService.Services.CommandsService)
local List = {}

for k in ServerFuseMachineData.BrainrotOutputs do
	table.insert(List, k)
end

Net:Handle("FuseBrainrot/RequestList", function(p)
	local roleAsync = CommandsService:GetRoleAsync(p)

	if roleAsync == "Dev" or roleAsync == "Lead" then
		return List
	end

	return {}
end)
return List