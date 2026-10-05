local RunService = game:GetService("RunService")

if RunService:IsServer() then
	return require(script.GameAnalytics)
end

return require(script.GameAnalyticsClient)