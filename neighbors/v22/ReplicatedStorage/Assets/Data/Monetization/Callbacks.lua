local RunService = game:GetService("RunService")

if not RunService:IsServer() then
	return {}
end

require(game.ServerStorage.Modules.Network)
require(game.ReplicatedStorage.Modules.Money)
return {}