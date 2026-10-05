local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
require(ReplicatedStorage.UserGenerated.FastFlags.SharedFastFlags)
local v = nil

if RunService:IsClient() then
	local ClientFastFlags = require(ReplicatedStorage.UserGenerated.Client.ClientFastFlags)
	return ClientFastFlags
end

if not RunService:IsServer() then
	error("RunContext")
	return v
end

local ServerScriptService = game:GetService("ServerScriptService")
local ServerFastFlags = require(ServerScriptService.UserGenerated.Server.ServerFastFlags)
return ServerFastFlags