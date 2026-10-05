local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
require(ReplicatedStorage.UserGenerated.ABTests.SharedABTests)

if RunService:IsServer() then
	local ServerABTests = require(ServerScriptService.UserGenerated.Server.ServerABTests)
	return ServerABTests
end

local ClientABTests = require(ReplicatedStorage.UserGenerated.Client.ClientABTests)
return ClientABTests