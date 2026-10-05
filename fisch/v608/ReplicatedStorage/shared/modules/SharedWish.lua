local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SharedDataHelper = require(ReplicatedStorage.shared.modules.SharedDataHelper)
local SharedWish = {
	StreakTarget = 14,
	CycleDuration = 86400,
	CycleOffset = 0,
	WishTypes = {
		fischmas25 = {
			Id = "fischmas25",
			DisplayName = "Santa's Wish",
			Color = Color3.fromRGB(255, 88, 88),
			Icon = "rbxassetid://89344284714292"
		},
		fischfest26 = {
			Id = "fischfest26",
			DisplayName = "Wish of the Sky",
			Color = Color3.fromRGB(178, 201, 255),
			Icon = "rbxassetid://104986474366291"
		}
	},
	GetCycleNum = function(instance)
		return (os.time() - 0) // 86400 + (instance:GetAttribute("CycleOffsetWishTrial") or 0)
	end
}

function SharedWish.GetCycleSeed(p)
	return SharedWish.GetCycleNum(p) * 33550337 % 2147483647
end

function SharedWish.GetSecondsUntilNextCycle()
	return 86400 - (os.time() - 0) % 86400
end

function SharedWish.GetWishData(p)
	return SharedDataHelper.indexNewFormat(p, { "Skycrest", "Wish" })
end

function SharedWish.GetTrialData(p)
	return SharedDataHelper.indexNewFormat(p, { "Skycrest", "Trial" })
end

function SharedWish.GetPlaytime(p)
	return SharedDataHelper.readLegacyPathValue(p, "Stats.tracker_timeplayed") or 0
end

function SharedWish.HasClaimedWish(p)
	local wishData = SharedWish.GetWishData(p)
	return wishData ~= nil and wishData.Claimed
end

function SharedWish.GetActiveGrant(p)
	local wishData = SharedWish.GetWishData(p)
	return wishData and wishData.ActiveGrant or nil
end

function SharedWish.HasGrantFor(p, p2: string)
	local activeGrant = SharedWish.GetActiveGrant(p)
	return activeGrant ~= nil and activeGrant.Entry == p2
end

function SharedWish.GetStreakGap(p)
	local trialData = SharedWish.GetTrialData(p)

	if trialData and not (trialData.LastCompletedCycle <= 0) then
		return SharedWish.GetCycleNum(p) - trialData.LastCompletedCycle
	end

	return 1e999
end

function SharedWish.IsStreakAlive(p)
	local trialData = SharedWish.GetTrialData(p)

	if not trialData or trialData.LastCompletedCycle <= 0 then
		return false
	end

	local streakGap = SharedWish.GetStreakGap(p)
	return streakGap <= 1 or streakGap == 2 and not trialData.GraceUsed
end

function SharedWish.GetLiveStreak(p)
	local trialData = SharedWish.GetTrialData(p)

	if trialData then
		return SharedWish.IsStreakAlive(p) and trialData.Streak or 0
	end

	return 0
end

function SharedWish.IsTrialDoneToday(p)
	local trialData = SharedWish.GetTrialData(p)

	if trialData then
		return trialData.LastCompletedCycle == SharedWish.GetCycleNum(p)
	end

	return false
end

function SharedWish.GetWishTypeInfo(p)
	return SharedWish.WishTypes[p]
end

return SharedWish