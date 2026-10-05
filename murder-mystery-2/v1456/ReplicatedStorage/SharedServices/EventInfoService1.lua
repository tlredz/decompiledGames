local EventInfoService1 = {}
script:WaitForChild("BattlePasses")
script:WaitForChild("MysteryBoxes")
script:WaitForChild("ShopData")
script:WaitForChild("EventList")
local v = {
	Inactive = "Inactive",
	PreUpdate = "PreUpdate",
	PreLiveEvent = "PreLiveEvent",
	Active = "Active",
	PostUpdate = "PostUpdate"
}
local currentEventState = script:GetAttribute("CurrentEventState")

function EventInfoService1.GetCurrentEvent(_)
	return nil
end

function EventInfoService1.GetCurrentItemPack(_)
	return nil
end

function EventInfoService1.GetEventState(_)
	return currentEventState
end

function EventInfoService1:IsInState(p: string)
	if v[p] then
		return currentEventState == p
	end

	warn("Invalid event state: ", p)
	return false
end

function EventInfoService1:IsEventActive()
	return false
end

function EventInfoService1.AreItemsCurrentlyPurchasable(_)
	return EventInfoService1:IsInState("Active") or EventInfoService1:IsInState("PostUpdate")
end

function EventInfoService1.GetEventName(_)
	return nil
end

function EventInfoService1.GetEventTitle(_)
	return nil
end

function EventInfoService1.GetEventCurrency(_)
	return nil
end

function EventInfoService1.GetEventKey(_)
	return nil
end

function EventInfoService1.GetEventRemotes(_)
	return nil
end

function EventInfoService1.GetBattlePass(_)
	return (nil).BattlePass
end

function EventInfoService1.GetMysteryBoxData(_)
	if (nil).MysteryBox then
		return (nil).MysteryBox
	end

	return nil
end

function EventInfoService1.GetShopItems(_)
	if (nil).ShopItems then
		return (nil).ShopItems
	end

	return {}
end

function EventInfoService1.GetCurrencyDevProducts(_)
	return {}
end

function EventInfoService1.GetLeaderboardInfo(_)
	return (nil).Leaderboards
end

function EventInfoService1:GetLeaderboardStatus()
	local serverTimeNow = math.floor((workspace:GetServerTimeNow()))
	local v2 = nil
	local pauseStartTime = (nil).Leaderboards.Points.PauseStartTime
	local pauseEndTime = (nil).Leaderboards.Points.PauseEndTime
	local leaderboardEndTime = (nil).Leaderboards.Points.LeaderboardEndTime
	local v3 = nil

	if serverTimeNow < pauseStartTime then
		v2 = pauseStartTime - serverTimeNow
		v3 = "pausingSoon"
	elseif pauseStartTime <= serverTimeNow and serverTimeNow < pauseEndTime then
		v2 = pauseEndTime - serverTimeNow
		v3 = "paused"
	elseif pauseEndTime <= serverTimeNow and serverTimeNow <= leaderboardEndTime then
		v2 = leaderboardEndTime - serverTimeNow
		v3 = "endingSoon"
	elseif leaderboardEndTime <= serverTimeNow then
		v3 = "ended"
		v2 = 0
	end

	return v3, v2
end

function EventInfoService1:IsLiveEventLaunch()
	return nil
end

function EventInfoService1.GetLiveEventTimeLeft(_)
	if EventInfoService1:IsLiveEventLaunch() then
		local unixTimestamp = DateTime.now().UnixTimestamp
		return (nil).LiveLaunchEvent - unixTimestamp
	end

	warn("Not live event!")
	return nil
end

function EventInfoService1.OnEventStarted(_, onEvent)
	if EventInfoService1:IsLiveEventLaunch() then
		if EventInfoService1:IsEventActive() then
			onEvent()
			return true
		end

		(nil).LiveEventStarted.Event:Connect(onEvent)
	else
		if not EventInfoService1:IsEventActive() then
			return false
		end

		onEvent()
	end

	return true
end

function EventInfoService1.IsLeaderboardActive(_)
	if not (nil).Leaderboards then
		return false
	end

	local leaderboardStatus, _ = EventInfoService1:GetLeaderboardStatus()
	return leaderboardStatus == "pausingSoon" or leaderboardStatus == "endingSoon"
end

script:GetAttributeChangedSignal("CurrentEventState"):Connect(function()
	currentEventState = script:GetAttribute("CurrentEventState")
end)
return EventInfoService1