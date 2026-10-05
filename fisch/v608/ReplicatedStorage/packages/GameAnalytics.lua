local RunService = game:GetService("RunService")

if RunService:IsServer() then
	return require(script.GameAnalyticsServer)
end

return require(script.GameAnalyticsClient)