local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local ReputationHandler = RunService:IsServer() and require(ServerStorage.SAM.Services.ReputationHandler) or nil
return function(list, p)
	local v = tonumber(p)

	if v == nil then
		return
	end

	for _, v2 in ipairs(list) do
		ReputationHandler.Set(v2, v)
	end
end