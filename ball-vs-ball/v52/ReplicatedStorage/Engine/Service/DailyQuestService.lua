local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Net = require(ReplicatedStorage.Packages.Net)
local Config = require(script.Parent.Config)
local CurrencyService = require(script.Parent.CurrencyService)
local PlayerData = require(script.Parent.PlayerData)
local TimeService = require(script.Parent.TimeService)

-- equivalent calls inferred from this helper; original call sites unknown
local function getDayKey()
	return TimeService.getDayKey(0)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getQuest(p: string)
	return Config.dailyQuest.byCnId[p]
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getPlayerData(p)
	return PlayerData.server[p]
end

local function ensureCurrentDay(p)
	local playerData = getPlayerData(p) -- equivalent call inferred; original call site unknown

	if not playerData then
		return nil
	end

	local dayKey = getDayKey() -- equivalent call inferred; original call site unknown
	local dailyQuest = playerData.dailyQuest()

	if dailyQuest.dayKey == dayKey then
		return dailyQuest
	end

	if typeof(dailyQuest.dayKey) == "number" and dayKey < dailyQuest.dayKey then
		playerData.dailyQuest({
			dayKey = dayKey,
			progress = dailyQuest.progress or {},
			claimed = dailyQuest.claimed or {}
		})
		return playerData.dailyQuest()
	end

	playerData.dailyQuest({
		dayKey = dayKey,
		progress = {},
		claimed = {}
	})
	return playerData.dailyQuest()
end

local function addProgress(p, p2: string)
	local quest = getQuest(p2) -- equivalent call inferred; original call site unknown

	if not (quest and ensureCurrentDay(p)) then
		return
	end

	local playerData = getPlayerData(p) -- equivalent call inferred; original call site unknown

	if not playerData then
		return
	end

	playerData.dailyQuest(function(p3)
		local clone = table.clone(p3.progress or {})
		clone[p2] = math.min((clone[p2] or 0) + 1, quest.requireCount)
		return {
			dayKey = TimeService.getDayKey(0),
			progress = clone,
			claimed = p3.claimed or {}
		}
	end)
end

local remoteFunction = Net:RemoteFunction("DailyQuestClaim")

remoteFunction.OnServerInvoke = function(p, value)
	if typeof(value) ~= "string" then
		return {
			ok = false,
			reason = "invalidQuest"
		}
	end

	local quest = getQuest(value) -- equivalent call inferred; original call site unknown

	if not quest then
		return {
			ok = false,
			reason = "unknownQuest"
		}
	end

	if not ensureCurrentDay(p) then
		return {
			ok = false,
			reason = "noData"
		}
	end

	local v = false
	local playerData = getPlayerData(p) -- equivalent call inferred; original call site unknown

	if not playerData then
		return {
			ok = false,
			reason = "noData"
		}
	end

	playerData.dailyQuest(function(p2)
		local progress = p2.progress or {}
		local claimed = p2.claimed or {}

		if claimed[value] or (progress[value] or 0) < quest.requireCount then
			return p2
		end

		local clone = table.clone(claimed)
		clone[value] = true
		v = true
		return {
			dayKey = TimeService.getDayKey(0),
			progress = progress,
			claimed = clone
		}
	end)

	if not v then
		return {
			ok = false,
			reason = "notClaimable"
		}
	end

	CurrencyService.server.give(p, CurrencyService.ref.Coins, quest.rewardCoins, {
		type = "dailyQuest",
		arg = value
	}, {
		transactionType = Enum.AnalyticsEconomyTransactionType.Gameplay.Name,
		sku = "每日任务:" .. value,
		channel = "每日任务",
		mode = "通用"
	})
	return {
		ok = true,
		rewardCoins = quest.rewardCoins
	}
end

local server = {
	finishAllQuests = function(p)
		if not ensureCurrentDay(p) then
			return
		end

		local playerData = getPlayerData(p) -- equivalent call inferred; original call site unknown

		if not playerData then
			return
		end

		playerData.dailyQuest(function(p2)
			local clone = table.clone(p2.progress or {})

			for _, v2 in ipairs(Config.dailyQuest.list) do
				clone[v2.cnId] = v2.requireCount
			end

			return {
				dayKey = TimeService.getDayKey(0),
				progress = clone,
				claimed = p2.claimed or {}
			}
		end)
	end
}

-- equivalent calls inferred from this helper; original call sites unknown
local function areFriends(list)
	if #list ~= 2 then
		return false
	end

	local success, result = pcall(function()
		return list[1]:IsFriendsWith(list[2].UserId)
	end)
	return success and result == true
end

function server.recordCompletedMatch(list, _: string, p: number, p2: number?)
	local v2 = areFriends(list) -- equivalent call inferred; original call site unknown

	for _, v3 in ipairs(list) do
		if not v3.Parent then
			continue
		end

		if v2 then
			addProgress(v3, "好友单挑")
		end

		if p == 3 then
			addProgress(v3, "3血模式")
		end

		if p2 == v3.UserId then
			addProgress(v3, "胜利")
		end
	end
end

function server.recordForfeitWin(p, p2, _: string, p3: number)
	if not p.Parent then
		return
	end

	-- equivalent call inferred; original call site unknown
	if areFriends({ p, p2 }) then
		addProgress(p, "好友单挑")
	end

	if p3 == 3 then
		addProgress(p, "3血模式")
	end

	addProgress(p, "胜利")
end

return {
	server = server
}