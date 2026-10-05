local RunService = game:GetService("RunService")
local v = RunService:IsServer() and _G.import("matchRegistry")
local Revive = {}

for k, v2 in pairs({
	p3601565477 = 1,
	p3601565481 = 2,
	p3601565476 = 3
}) do
	local v3 = v2
	Revive[k] = {
		Server = function(instance, p, p2, p3)
			local pendingReviveMatchId = instance:GetAttribute("PendingReviveMatchId")
			local v4 = v.get(pendingReviveMatchId)

			if v4 and v4.Started and v4:getPendingRevival(instance.UserId) + 1 == v3 then
				return v4:revivePlayer(instance)
			end

			return false
		end
	}
end

return Revive