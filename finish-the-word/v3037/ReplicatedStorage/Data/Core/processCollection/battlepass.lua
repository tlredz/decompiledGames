local import = _G.import("seasonCollection")
local Battlepass = {}

function Battlepass.claimBattlepassReward(p, object, _, p2, p3)
	if p3 ~= "free" and p3 ~= "premium" then
		return "Invalid track type"
	end

	if p3 == "premium" and not object.BattlePass.PremiumUnlocked then
		return "Premium pass not unlocked"
	end

	local battlePass = import:getSeasonData().BattlePass

	if not (battlePass[p2] and battlePass[p2][p3]) then
		return "Invalid tier or reward"
	end

	if object:calculateTierFromXP() < p2 then
		return "Tier not reached yet"
	end

	if object:isBattlepassRewardClaimed(p2, p3) then
		return "Reward already claimed"
	end

	local battlePass2 = object.BattlePass
	battlePass2.ClaimedRewards[p2] = battlePass2.ClaimedRewards[p2] or {}
	battlePass2.ClaimedRewards[p2][p3] = true
	return true, p, object, p2, p3
end

function Battlepass.claimAllBattlepassRewards(p, object, _)
	local battlePass = import:getSeasonData().BattlePass
	local tierFromXP = object:calculateTierFromXP()
	local battlePass2 = object.BattlePass
	local result = {}

	for i = 1, tierFromXP do
		if not battlePass[i] then
			continue
		end

		if not object:isBattlepassRewardClaimed(i, "free") then
			battlePass2.ClaimedRewards[i] = battlePass2.ClaimedRewards[i] or {}
			battlePass2.ClaimedRewards[i].free = true
			table.insert(result, {
				tier = i,
				track = "free"
			})
		end

		if not object.BattlePass.PremiumUnlocked or object:isBattlepassRewardClaimed(i, "premium") then
			continue
		end

		local battlePass3 = object.BattlePass
		battlePass3.ClaimedRewards[i] = battlePass3.ClaimedRewards[i] or {}
		battlePass3.ClaimedRewards[i].premium = true
		table.insert(result, {
			tier = i,
			track = "premium"
		})
	end

	if #result <= 0 then
		return "No rewards available to claim"
	end

	return true, p, object, result
end

return Battlepass