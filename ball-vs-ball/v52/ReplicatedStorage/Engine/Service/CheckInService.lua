local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Net = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Net"))
local remoteFunction = Net:RemoteFunction("CheckInStateQuery")
local remoteFunction2 = Net:RemoteFunction("CheckInClaim")
local remoteEvent = Net:RemoteEvent("CheckInStateChanged")
local TimeService = require(script.Parent.TimeService)

-- equivalent calls inferred from this helper; original call sites unknown
local function getDayKey()
	return TimeService.getDayKey(0)
end

local function isCycleFullyClaimed(list, p: number)
	for i = 1, p do
		if not list[i] then
			return false
		end
	end

	return true
end

local v = nil
local v2 = {}

local function ensureProgress(p)
	local v3 = v
	local progress = v3.getProgress(p)

	if v3.loop then
		local claimed = progress.claimed
		local flag = true
		local flag2

		for i = 1, v3.totalDays do
			if claimed[i] then
				continue
			end

			flag2 = false
			flag = false
			break
		end

		if flag then
			flag2 = true
		end

		if flag2 then
			progress = {
				progressDays = 0,
				lastDayKey = progress.lastDayKey,
				claimed = {},
				hasEnteredLoop = true
			}
			v3.setProgress(p, progress)
		end
	end

	local dayKey = getDayKey() -- equivalent call inferred; original call site unknown

	if progress.lastDayKey == dayKey then
		return progress
	end

	if dayKey < progress.lastDayKey then
		local v4 = {
			progressDays = progress.progressDays,
			lastDayKey = dayKey,
			claimed = progress.claimed,
			hasEnteredLoop = progress.hasEnteredLoop
		}
		v3.setProgress(p, v4)
		return v4
	else
		local v4 = {
			progressDays = math.min(progress.progressDays + 1, v3.totalDays),
			lastDayKey = dayKey,
			claimed = progress.claimed,
			hasEnteredLoop = progress.hasEnteredLoop
		}
		v3.setProgress(p, v4)
		return v4
	end
end

local function buildState(progress)
	local v3 = v
	local result = {}

	for i = 1, v3.totalDays do
		table.insert(result, {
			dayIndex = i,
			status = progress.claimed[i] and "claimed" or i <= progress.progressDays and "claimable" or "locked",
			rewardCnId = v3.getRewardCnId(i, progress)
		})
	end

	return result
end

-- equivalent calls inferred from this helper; original call sites unknown
local function pushState(player)
	remoteEvent:FireClient(player, (buildState(v.getProgress(player))))
end

local function serverGetState(p)
	return (buildState(ensureProgress(p)))
end

local function serverClaim(player, value: number)
	local v3 = v

	if v2[player] then
		return {
			ok = false,
			reason = "pending"
		}
	end

	if typeof(value) ~= "number" or value % 1 ~= 0 or value < 1 or v3.totalDays < value then
		return {
			ok = false,
			reason = "invalid_day"
		}
	end

	v2[player] = true
	local progress = ensureProgress(player)

	if progress.claimed[value] then
		v2[player] = nil
		return {
			ok = false,
			reason = "already_claimed"
		}
	end

	if progress.progressDays < value then
		v2[player] = nil
		return {
			ok = false,
			reason = "not_unlocked"
		}
	end

	local rewardCnId = v3.getRewardCnId(value, progress)
	local success, result = pcall(v3.grantReward, player, value, rewardCnId)

	if success then
		if typeof(result) == "table" and result.ok == true then
			local clone = table.clone(progress.claimed)
			clone[value] = true

			if v3.loop then
				local flag = true
				local flag2

				for i = 1, v3.totalDays do
					if clone[i] then
						continue
					end

					flag2 = false
					flag = false
					break
				end

				if flag then
					flag2 = true
				end

				if flag2 then
					v3.setProgress(player, {
						progressDays = 0,
						lastDayKey = progress.lastDayKey,
						claimed = {},
						hasEnteredLoop = true
					})
				else
					v3.setProgress(player, {
						progressDays = progress.progressDays,
						lastDayKey = progress.lastDayKey,
						claimed = clone,
						hasEnteredLoop = progress.hasEnteredLoop
					})
				end
			else
				v3.setProgress(player, {
					progressDays = progress.progressDays,
					lastDayKey = progress.lastDayKey,
					claimed = clone,
					hasEnteredLoop = progress.hasEnteredLoop
				})
			end

			v2[player] = nil
			pushState(player) -- equivalent call inferred; original call site unknown
			return {
				ok = true,
				results = result.results
			}
		else
			local reason

			if typeof(result) == "table" then
				reason = result.reason
			end

			warn((`[CheckInService] 发奖未成功: {reason}`))
			v2[player] = nil
			return {
				ok = false,
				reason = reason or "error"
			}
		end
	else
		warn((`[CheckInService] 发奖回调出错: {result}`))
		v2[player] = nil
		return {
			ok = false,
			reason = "error"
		}
	end
end

local function debugEnterLoop(player)
	local v3 = v

	if not (v3 and v3.loop) then
		return
	end

	local progress = ensureProgress(player)
	v3.setProgress(player, {
		progressDays = 1,
		lastDayKey = progress.lastDayKey,
		claimed = {},
		hasEnteredLoop = true
	})
	pushState(player) -- equivalent call inferred; original call site unknown
end

local function debugUnlockAll(player)
	local v3 = v

	if not v3 then
		return
	end

	local progress = ensureProgress(player)
	v3.setProgress(player, {
		progressDays = v3.totalDays,
		lastDayKey = progress.lastDayKey,
		claimed = progress.claimed,
		hasEnteredLoop = progress.hasEnteredLoop
	})
	pushState(player) -- equivalent call inferred; original call site unknown
end

if RunService:IsServer() then
	remoteFunction.OnServerInvoke = function(p)
		if not v then
			return {}
		end

		local success, result = pcall(serverGetState, p)

		if success then
			return result
		end

		warn((`[CheckInService] 查询状态出错: {result}`))
		return {}
	end

	remoteFunction2.OnServerInvoke = function(p, p2)
		if not v then
			return {
				ok = false,
				reason = "not_initialized"
			}
		end

		local success, result = pcall(serverClaim, p, p2)

		if success then
			return result
		end

		warn((`[CheckInService] 处理领取请求出错: {result}`))
		v2[p] = nil
		return {
			ok = false,
			reason = "error"
		}
	end

	Players.PlayerRemoving:Connect(function(player)
		v2[player] = nil
	end)
end

local function initServer(p)
	v = p
end

local function clientGetState()
	local success, result = pcall(function()
		return remoteFunction:InvokeServer()
	end)

	if success then
		return result
	end

	warn((`[CheckInService] 查询状态请求出错: {result}`))
	return {}
end

local function clientClaim(p: number)
	local success, result = pcall(function()
		return remoteFunction2:InvokeServer(p)
	end)

	if success then
		return result
	end

	warn((`[CheckInService] 领取请求出错: {result}`))
	return {
		ok = false,
		reason = "request_failed"
	}
end

local function clientOnStateChanged(onOnClientEvent)
	remoteEvent.OnClientEvent:Connect(onOnClientEvent)
end

return {
	server = {
		init = initServer,
		debugUnlockAll = debugUnlockAll,
		debugEnterLoop = debugEnterLoop
	},
	client = {
		getState = clientGetState,
		claim = clientClaim,
		onStateChanged = clientOnStateChanged
	}
}