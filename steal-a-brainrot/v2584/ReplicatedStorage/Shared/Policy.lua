local PolicyService = game:GetService("PolicyService")
local Players = game:GetService("Players")
local v = {}
local v2 = {}
Players.PlayerRemoving:Connect(function(player)
	v2[player] = nil
end)
return {
	getPolicy = function(instance)
		while v[instance] do
			task.wait()
		end

		local v3 = v2[instance]

		if v3 then
			return v3
		end

		v[instance] = true
		local v4, v5 = xpcall(function()
			return PolicyService:GetPolicyInfoForPlayerAsync(instance)
		end, warn)
		local isDescendant = instance:IsDescendantOf(Players)

		if v4 and isDescendant then
			v2[instance] = v5
		end

		v[instance] = nil

		if isDescendant then
			return v5
		end

		return nil
	end
}