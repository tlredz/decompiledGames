_G.import("global")
local import = _G.import("class")
local import2 = _G.import("seasonCollection")
_G.import("dictUtil")
local v = import.new()

local function getMaxXp(object)
	local seasonData = import2:getSeasonData()

	if not seasonData then
		return 0
	end

	local total = 0

	for i = 1, #seasonData.BattlePass do
		total += object:calculateTierXp(i)
	end

	return total
end

function v:hasUnclaimedBattlepassRewards()
	local tierFromXP = self:calculateTierFromXP()
	local seasonData = import2:getSeasonData()

	if not seasonData then
		return
	end

	local battlePass = seasonData.BattlePass

	for i = 1, tierFromXP do
		if not battlePass[i] then
			continue
		end

		if not self:isBattlepassRewardClaimed(i, "free") or self.BattlePass.PremiumUnlocked and not self:isBattlepassRewardClaimed(
			i,
			"premium"
		) then
			return true
		end
	end

	return false
end

function v:isBattlepassRewardClaimed(p2, p3)
	local claimedReward = self.BattlePass.ClaimedRewards[p2]
	return claimedReward and claimedReward[p3]
end

function v.getXpRequiredToReachTier(object, value)
	local seasonData = import2:getSeasonData()

	if not seasonData then
		return
	end

	local total = 0

	for i = 1, math.clamp(value, 0, #(seasonData and seasonData.BattlePass or {})) do
		total += object:calculateTierXp(i)
	end

	return total
end

function v.calculateTierXp(_, p)
	return 100 + (p - 1) * 100
end

function v:calculateTierFromXP()
	local seasonData = import2:getSeasonData()

	if not seasonData then
		return 0, 0, 0
	end

	local count = #seasonData.BattlePass
	local XP = self.BattlePass.XP or 0
	local count2 = 0
	local total = 0

	while count2 < count do
		local tierXp = self:calculateTierXp(count2 + 1)

		if XP < total + tierXp then
			break
		end

		total += tierXp
		count2 += 1
	end

	local skippedTiers = self.BattlePass.SkippedTiers or 0

	if skippedTiers > 0 and count2 < count then
		local v2 = math.min(count, count2 + skippedTiers)

		for i = count2 + 1, v2 do
			XP += self:calculateTierXp(i)
		end
	end

	local count3 = 0
	local total2 = 0

	while count3 < count do
		local tierXp = self:calculateTierXp(count3 + 1)

		if XP < total2 + tierXp then
			return count3, XP - total2, tierXp
		end

		total2 += tierXp
		count3 += 1
	end

	if count == 0 then
		return 0, 0, 0
	end

	local tierXp = self:calculateTierXp(count)
	return count, tierXp, tierXp
end

function v.increaseBpXp(p, p2)
	if p2 <= 0 then
		return
	end

	local maxXp = getMaxXp(p)
	p.BattlePass.XP = math.min(maxXp, p.BattlePass.XP + p2)
end

function v:_reset()
	self.BattlePass = {
		XP = 0,
		PremiumUnlocked = false,
		ClaimedRewards = {
			_Insertable = true
		},
		SkippedTiers = 0,
		Currency = 0,
		SeasonId = import2:getCurrentSeason()
	}
end

function v:bpReset(p)
	self:auto_repl(p or false)
	self:_reset()
	self:auto_repl(false)
end

function v:scheduleBpReset()
	if self:hasTimedProcess("BpReset") then
		return
	end

	self:timeProcess("BpReset", import2:getSeasonTimeRemaining(), true)
end

function v:new()
	self:_reset()
end

function v:postShell()
	self:scheduleBpReset()
end

return v