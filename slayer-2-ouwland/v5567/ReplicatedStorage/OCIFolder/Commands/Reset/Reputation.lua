local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local ReputationHandler = RunService:IsServer() and require(ServerStorage.SAM.Services.ReputationHandler) or nil
return function(list)
	for _, v in ipairs(list) do
		ReputationHandler.Set(v, 0)
	end
end