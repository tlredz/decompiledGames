local RunService = game:GetService("RunService")

if RunService:IsServer() then
	local Server = require(script.Server)
	return Server
end

local Client = require(script.Client)
return Client