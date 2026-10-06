return {
	new = function(data)
		local v = {}
		return {
			claim = function(p)
				if v[p] then
					return {
						ok = false,
						reason = "pending"
					}
				end

				if data.hasClaimed(p) then
					return {
						ok = false,
						reason = "already_claimed"
					}
				end

				v[p] = true
				local success, result = pcall(data.grantReward, p)
				v[p] = nil

				if not success then
					warn((`[OneTimeRewardService] 发奖回调出错: {result}`))
					return {
						ok = false,
						reason = "error"
					}
				end

				if typeof(result) == "table" and result.ok == true then
					data.markClaimed(p)
					return {
						ok = true,
						results = result.results
					}
				end

				local reason

				if typeof(result) == "table" then
					reason = result.reason
				end

				warn((`[OneTimeRewardService] 发奖未成功: {reason}`))
				return {
					ok = false,
					reason = reason or "error"
				}
			end,
			cleanup = function(p)
				v[p] = nil
			end
		}
	end
}