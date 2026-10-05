local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Net = require(ReplicatedStorage.Packages.Net)

if not RunService:IsServer() then
	return Net:Invoke("BrainrotToTrade/RequestList")
end

local ServerStorage = game:GetService("ServerStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local BrainrotTraderData = require(ServerStorage.Modules.BrainrotTraderData)
local CommandsService = require(ServerScriptService.Services.CommandsService)
local List = {}

for _, brainrot in BrainrotTraderData.Brainrots do
	table.insert(List, brainrot.Name)
end

Net:Handle("BrainrotToTrade/RequestList", function(p)
	local roleAsync = CommandsService:GetRoleAsync(p)

	if roleAsync == "Dev" or roleAsync == "Lead" then
		return List
	end

	return {}
end)
return List