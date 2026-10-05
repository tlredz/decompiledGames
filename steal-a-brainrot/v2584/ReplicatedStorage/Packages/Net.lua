local RunService = game:GetService("RunService")

if RunService:IsServer() then
	local ServerStorage = game:GetService("ServerStorage")
	return require(ServerStorage.Packages.ServerNet)
end

local Net = require(script.Net)
return Net