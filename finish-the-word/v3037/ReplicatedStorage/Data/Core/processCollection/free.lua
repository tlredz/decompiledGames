local RunService = game:GetService("RunService")
local isServer = RunService:IsServer()
local import = _G.import("rewardListData")
_G.import("rewardData")
return {
	claimRewardList = function(p, state, object, p2)
		local v = import[p2]

		if state.RewardListsClaimed[p2] then
			return false
		end

		if v.TimeRequired then
			local sessionTime = isServer and state.SessionTime or time()
			local v2 = state.Playtime + sessionTime

			if v.TimeRequired - v2 > 0 then
				return false
			end
		end

		if v.Condition and v.Condition(p, state, object) ~= true then
			return false
		end

		if v.StreakRequired then
			if state.LoginStreak < v.StreakRequired then
				return false
			end

			state.StreakClaim[v.StreakRequired] = true

			if v.StreakRequired == 7 then
				state.StreakClaim = {}
			end
		end

		for _, reward in pairs(v.Rewards) do
			object:award(reward)
		end

		state.RewardListsClaimed[p2] = true
		return true
	end
}