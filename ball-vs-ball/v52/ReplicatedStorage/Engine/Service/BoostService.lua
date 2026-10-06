local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TimeService = require(script.Parent.TimeService)
local AuditService = require(script.Parent.AuditService)
local BoostService = {
	definitions = {
		["金币加成"] = {
			field = "coinBoost",
			badge = "双倍金币"
		},
		["经验加成"] = {
			field = "expBoost",
			badge = "双倍经验"
		}
	},
	DAILY_FIRST_MATCH_REWARD_ID = "每日首战奖励",
	DAILY_FIRST_MATCH_GRANTED_EVENT = "DailyFirstMatchBoostGranted"
}

-- equivalent calls inferred from this helper; original call sites unknown
local function finite(value)
	return typeof(value) == "number" and value == value and math.abs(value) < 1e999
end

-- equivalent calls inferred from this helper; original call sites unknown
local function definition(p)
	return assert(BoostService.definitions[p], "Unknown boost: " .. tostring(p))
end

function BoostService.normalizeState(p)
	local v = typeof(p) ~= "table" and {} or p
	return {
		multiplier = not finite(v.multiplier) and 1 or math.max(1, v.multiplier),
		remaining = not finite(v.remaining) and 0 or math.max(0, v.remaining),
		dayKey = not finite(v.dayKey) and 0 or v.dayKey,
		revealToken = typeof(v.revealToken) ~= "string" and "" or v.revealToken
	}
end

function BoostService.normalizeForJoin(p, p2)
	local state = BoostService.normalizeState(p)
	state.revealToken = ""

	if state.dayKey == p2 then
		return state
	end

	return {
		multiplier = 1,
		remaining = 0,
		dayKey = 0
	}
end

function BoostService:preparePlayerData()
	local dayKey = TimeService.getDayKey(0)

	for _, definition2 in BoostService.definitions do
		local state = BoostService.normalizeState(self[definition2.field])
		local normalizeForJoin = BoostService.normalizeForJoin(state, dayKey)
		self[definition2.field] = normalizeForJoin

		if state.remaining > 0 and normalizeForJoin.remaining == 0 then
			self.auditLog = AuditService.append(self.auditLog, {
				assetType = "boost",
				assetId = definition2.field,
				action = "clear",
				source = "Boost:dayReset",
				before = state.remaining,
				after = 0,
				delta = -state.remaining
			}, TimeService.now())
		end
	end
end

function BoostService.getRemainingSeconds(p)
	return BoostService.normalizeState(p).remaining
end

function BoostService.getActiveMultiplier(p)
	local state = BoostService.normalizeState(p)

	if state.remaining > 0 then
		return state.multiplier
	end

	return 1
end

function BoostService.parseRewardArgs(p, value)
	if typeof(p) ~= "table" then
		return nil, nil
	end

	local v

	if typeof(value) == "number" and value == value then
		v = math.abs(value) < 1e999
	else
		v = false
	end

	if not (v and not (value < 1) and value % 1 == 0) then
		return nil, nil
	end

	local v2 = tonumber(p["倍率"])
	local v3 = tonumber(p["持续分钟"])
	local v4

	if typeof(v2) == "number" and v2 == v2 then
		v4 = math.abs(v2) < 1e999
	else
		v4 = false
	end

	if not v4 or v2 <= 1 then
		return nil, nil
	end

	local v5

	if typeof(v3) == "number" and v3 == v3 then
		v5 = math.abs(v3) < 1e999
	else
		v5 = false
	end

	if not (v5 and not (v3 <= 0)) then
		return nil, nil
	end

	local v6 = v3 * 60 * value
	local v7

	if typeof(v6) == "number" and v6 == v6 then
		v7 = math.abs(v6) < 1e999
	else
		v7 = false
	end

	if v7 then
		return v2, v6
	end

	return nil, nil
end

if not RunService:IsServer() then
	return BoostService
end

local Players = game:GetService("Players")
local server = nil
local flag = false
local v2 = {}

local function getData()
	if not server then
		local PlayerData = require(script.Parent.PlayerData)
		server = PlayerData.server
	end

	return server
end

local function tickPlayer(p)
	if not server then
		local PlayerData = require(script.Parent.PlayerData)
		server = PlayerData.server
	end

	local v3 = server
	local now = os.clock()
	local v4 = not v2[p] and 0 or now - v2[p]
	v2[p] = now

	for _, definition2 in BoostService.definitions do
		local state = BoostService.normalizeState(v3[p][definition2.field]())

		if not (state.remaining > 0 and v4 > 0) then
			continue
		end

		state.remaining = math.max(0, state.remaining - v4)

		if state.remaining == 0 then
			state.multiplier = 1
		end

		v3[p][definition2.field](state)
	end
end

local server2 = {
	addBoost = function(p, p2, value, value2, value3, value4)
		local v3 = definition(p2) -- equivalent call inferred; original call site unknown
		local v4

		if typeof(value) == "number" and value == value then
			v4 = math.abs(value) < 1e999
		else
			v4 = false
		end

		if v4 then
			if value > 1 then
				v4 = finite(value2) and value2 > 0
			else
				v4 = false
			end
		end

		assert(v4, "Invalid boost")
		tickPlayer(p)

		if not server then
			local PlayerData = require(script.Parent.PlayerData)
			server = PlayerData.server
		end

		local v5 = server
		local state = BoostService.normalizeState(v5[p][v3.field]())
		local v6 = {
			multiplier = math.max(BoostService.getActiveMultiplier(state), value),
			remaining = state.remaining + value2,
			dayKey = TimeService.getDayKey(0),
			revealToken = state.remaining <= 0 and (value4 or "") or state.revealToken
		}
		local remaining = v6.remaining
		local v7

		if typeof(remaining) == "number" and remaining == remaining then
			v7 = math.abs(remaining) < 1e999
		else
			v7 = false
		end

		assert(v7, "Boost duration overflow")
		v5[p][v3.field](v6)
		AuditService.record(p, {
			assetType = "boost",
			assetId = v3.field,
			action = "grant",
			before = state.remaining,
			after = v6.remaining,
			delta = value2,
			multiplier = v6.multiplier,
			source = value3 or "Boost:add"
		})
	end,
	apply = function(p, p2, p3)
		local v3 = definition(p2) -- equivalent call inferred; original call site unknown
		tickPlayer(p)
		local getActiveMultiplier = BoostService.getActiveMultiplier

		if not server then
			local PlayerData = require(script.Parent.PlayerData)
			server = PlayerData.server
		end

		return (math.floor(p3 * getActiveMultiplier(server[p][v3.field]())))
	end,
	clearBoost = function(p, p2, value)
		local v3 = definition(p2) -- equivalent call inferred; original call site unknown
		tickPlayer(p)

		if not server then
			local PlayerData = require(script.Parent.PlayerData)
			server = PlayerData.server
		end

		local v4 = server
		local state = BoostService.normalizeState(v4[p][v3.field]())
		v4[p][v3.field]({
			multiplier = 1,
			remaining = 0,
			dayKey = 0
		})

		if state.remaining > 0 then
			AuditService.record(p, {
				assetType = "boost",
				assetId = v3.field,
				action = "clear",
				before = state.remaining,
				after = 0,
				delta = -state.remaining,
				source = value or "CMD:clearBoost"
			})
		end
	end,
	hasClaimedDailyFirstMatch = function(p)
		if not server then
			local PlayerData = require(script.Parent.PlayerData)
			server = PlayerData.server
		end

		return server[p].dailyFirstMatchDayKey() == TimeService.getDayKey(0)
	end,
	markDailyFirstMatch = function(p)
		if not server then
			local PlayerData = require(script.Parent.PlayerData)
			server = PlayerData.server
		end

		server[p].dailyFirstMatchDayKey(TimeService.getDayKey(0))
	end,
	resetDailyFirstMatch = function(p)
		if not server then
			local PlayerData = require(script.Parent.PlayerData)
			server = PlayerData.server
		end

		server[p].dailyFirstMatchDayKey(0)
	end
}

-- equivalent calls inferred from this helper; original call sites unknown
local function grantedRemote()
	local Net = require(ReplicatedStorage.Packages.Net)
	return Net:RemoteEvent(BoostService.DAILY_FIRST_MATCH_GRANTED_EVENT)
end

function server2.notifyDailyFirstMatchGranted(player, p)
	(grantedRemote()):FireClient(player, BoostService.DAILY_FIRST_MATCH_REWARD_ID, p)
end

function server2.init()
	if flag then
		return
	end

	flag = true

	if not server then
		local PlayerData = require(script.Parent.PlayerData)
		server = PlayerData.server
	end

	local v3 = server
	local Net = require(ReplicatedStorage.Packages.Net)
	Net:RemoteEvent(BoostService.DAILY_FIRST_MATCH_GRANTED_EVENT)
	v3.Service:addPlayerRemovingCallback(function(p, statesByField)
		local v4 = not v2[p] and 0 or os.clock() - v2[p]

		for _, definition2 in BoostService.definitions do
			local state = BoostService.normalizeState(statesByField[definition2.field])
			state.remaining = math.max(0, state.remaining - v4)

			if state.remaining == 0 then
				state.multiplier = 1
			end

			statesByField[definition2.field] = state
		end

		v2[p] = nil
	end)
	task.spawn(function()
		while true do
			for _, v4 in Players:GetPlayers() do
				if v3.Service:getProfile(v4) then
					tickPlayer(v4)
				end
			end

			task.wait(1)
		end
	end)
end

BoostService.server = server2
return BoostService