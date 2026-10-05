local RunService = game:GetService("RunService")
return {
	GetTime = function(_)
		if RunService:IsServer() then
			return DateTime.now().UnixTimestamp
		end

		return workspace:GetServerTimeNow()
	end
}