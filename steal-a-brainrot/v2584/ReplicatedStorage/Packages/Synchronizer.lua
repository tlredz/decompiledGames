local RunService = game:GetService("RunService")

if RunService:IsServer() then
	return require("@game/ServerStorage/Packages/ServerSynchronizer")
end

return require("@self/ClientSynchronizer")