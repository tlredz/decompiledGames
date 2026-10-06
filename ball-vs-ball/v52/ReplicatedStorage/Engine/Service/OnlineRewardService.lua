local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Net = require(ReplicatedStorage.Packages.Net)
local PlayerData = require(script.Parent.PlayerData)
local server = PlayerData.server
local TimeService = require(script.Parent.TimeService)
local OnlineRewardConfig = require(script.Parent.OnlineRewardConfig)
local GameFlags = require(ReplicatedStorage.GameFlags)
local OnlineRewardService = {}
local remoteFunction = Net:RemoteFunction("OnlineRewardClaim")
local remoteFunction2 = Net:RemoteFunction("OnlineRewardMarkNotified")
local v = {}
local v2 = {}
local remoteFunction3 = Net:RemoteFunction("OnlineRewardNotifications")
local fn

local function normalize(p)
	local v3 = server[p]
	local clone = v3.onlineReward()
	local dayKey = TimeService.getDayKey(0)

	if typeof(clone) == "table" and typeof(clone.dayKey) == "number" and dayKey < clone.dayKey then
		clone = table.clone(clone)
		clone.dayKey = dayKey
		v3.onlineReward(clone)
	end

	if typeof(clone) ~= "table" or clone.dayKey ~= dayKey then
		clone = {
			dayKey = dayKey,
			onlineSeconds = 0,
			claimed = {},
			notified = {}
		}
		v3.onlineReward(clone)
	end

	return clone
end

-- equivalent calls inferred from this helper; original call sites unknown
local function markKey(p, p2: string, p3: string, dayKey: number)
	server[p].onlineReward(function(p4)
		if typeof(p4) ~= "table" or p4.dayKey ~= dayKey then
			return p4
		end

		local clone = table.clone(p4)
		local clone2 = table.clone(typeof(p4[p2]) ~= "table" and {} or p4[p2])
		clone2[p3] = true
		clone[p2] = clone2
		return clone
	end)
end

local function claimAvailable(p)
	local v3 = normalize(p)

	for _, v4 in OnlineRewardConfig.getTiers() do
		if p.Parent ~= Players or not server[p] then
			break
		end

		if not (v3.onlineSeconds >= v4.seconds) or v3.claimed[tostring(v4.index)] then
			continue
		end

		fn(p, v4.index, true)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function tickPlayer(p)
	task.spawn(function()
		server.Service:waitForData(p)

		while p.Parent == Players and server[p] do
			local v3 = normalize(p)
			claimAvailable(p)
			task.wait(1)
			local v4 = server[p]

			if p.Parent ~= Players or not v4 then
				break
			end

			if TimeService.getDayKey(0) == v3.dayKey then
				v4.onlineReward.onlineSeconds(function(value)
					return (typeof(value) ~= "number" and 0 or value) + 1
				end)
			else
				normalize(p)
			end
		end
	end)
end

fn = function(p, value, flag: boolean?)
	if v[p] then
		return {
			ok = false,
			reason = "pending"
		}
	end

	if typeof(value) ~= "number" or value % 1 ~= 0 then
		return {
			ok = false,
			reason = "invalid_index"
		}
	end

	local tier = OnlineRewardConfig.getTier(value)

	if not tier then
		return {
			ok = false,
			reason = "invalid_index"
		}
	end

	v[p] = true
	local success, result = pcall(function()
		local v3 = normalize(p)
		local v4 = tostring(value)

		if v3.claimed[v4] then
			return {
				ok = false,
				reason = "already_claimed"
			}
		end

		if v3.onlineSeconds < tier.seconds then
			return {
				ok = false,
				reason = "locked"
			}
		end

		local RewardItemService = require(script.Parent.RewardItemService)
		local v5 = RewardItemService.grant(p, tier.rewardCnId)

		if not v5.ok then
			return v5
		end

		if TimeService.getDayKey(0) == v3.dayKey then
			markKey(p, "claimed", v4, v3.dayKey) -- equivalent call inferred; original call site unknown
		end

		local v6 = v2[p]

		if not v6 then
			v6 = {}
			v2[p] = v6
		end

		local v7 = {
			index = value,
			dayKey = v3.dayKey,
			results = 0
		}
		local results

		if flag then
			results = v5.results
		end

		v7.results = results
		table.insert(v6, v7)
		return {
			ok = true,
			results = v5.results
		}
	end)
	v[p] = nil

	if success then
		return result
	end

	warn("[OnlineRewardService] 领取失败: " .. tostring(result))
	return {
		ok = false,
		reason = "error"
	}
end

local function markNotified(p)
	local v3 = normalize(p)
	local v4 = false

	for _, v5 in OnlineRewardConfig.getTiers() do
		local index = tostring(v5.index)

		if not (v3.onlineSeconds >= v5.seconds) or (v3.claimed[index] or v3.notified[index]) then
			continue
		end

		markKey(p, "notified", index, v3.dayKey) -- equivalent call inferred; original call site unknown
		v4 = true
	end

	return v4
end

function OnlineRewardService.addMinutes(p, value: number)
	if not OnlineRewardService.isEnabled() then
		return false
	end

	if typeof(value) ~= "number" or value ~= value or value <= 0 or value == 1e999 then
		return false
	end

	local v3 = math.floor(value * 60 + 0.5)

	if v3 < 1 or v3 == 1e999 then
		return false
	end

	server.Service:waitForData(p)
	normalize(p)
	server[p].onlineReward.onlineSeconds(function(value2)
		return (typeof(value2) ~= "number" and 0 or value2) + v3
	end)
	return true
end

function OnlineRewardService.isEnabled()
	return GameFlags.feature["在线奖励"] == true
end

function OnlineRewardService.init()
	if not OnlineRewardService.isEnabled() then
		return
	end

	remoteFunction.OnServerInvoke = function(p, p2)
		return fn(p, p2, false)
	end

	remoteFunction2.OnServerInvoke = markNotified

	remoteFunction3.OnServerInvoke = function(p)
		local v3 = v2[p] or {}
		v2[p] = {}
		return v3
	end

	Players.PlayerAdded:Connect(tickPlayer)
	Players.PlayerRemoving:Connect(function(player)
		v[player] = nil
		v2[player] = nil
	end)

	for _, v3 in Players:GetPlayers() do
		tickPlayer(v3) -- equivalent call inferred; original call site unknown
	end
end

return OnlineRewardService