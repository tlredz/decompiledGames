local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Config = require(script.Parent.Config)
local TimeService = require(script.Parent.TimeService)
local PlayerData = require(script.Parent.PlayerData)
local server = PlayerData.server
local RewardItemService = require(script.Parent.RewardItemService)
local Net = require(ReplicatedStorage.Packages.Net)
local GameFlags = require(ReplicatedStorage.GameFlags)
local v = GameFlags.feature["消费周榜奖励"] == true
local MailService = {
	server = {}
}
local dataStore

if v then
	dataStore = DataStoreService:GetDataStore("WeeklySpendMailHistoryV1")
else
	dataStore = nil
end

local dataStore2 = DataStoreService:GetDataStore("AdminMailQueueV1")
local v2 = false
local v3 = nil
local v4 = {}
local remoteEvent = Net:RemoteEvent("MailService/MarkRead")
local remoteFunction = Net:RemoteFunction("MailService/Claim")

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function weekCloseDayKey(weekBoundaryDayKeyAt: number, weekKeyAt: number, i: number)
	return weekBoundaryDayKeyAt - (weekKeyAt - i - 1) * 7
end

local function rewardLimit()
	local cnId = nil
	local v5 = nil

	for _, v6 in Config.reward.list do
		local v7

		if typeof(v6.cnId) == "string" then
			v7 = string.match(v6.cnId, "^每周消费榜前(%d+)奖励$")
		else
			v7 = false
		end

		if not v7 then
			continue
		end

		local v8 = tonumber(v7)

		if not (v8 and v8 > 0) then
			continue
		end

		if cnId and cnId ~= v6.cnId then
			warn("[MailService] 每周消费榜奖励存在多条不同名次配置")
			return nil, nil
		else
			cnId = v6.cnId
			v5 = v8
		end
	end

	return v5, cnId
end

-- equivalent calls inferred from this helper; original call sites unknown
local function weeklyMail(p: string)
	for _, v5 in Config.mail.list do
		if v5.scope == "自定义" and v5.rewardId == p then
			return v5
		end
	end

	return nil
end

local function dateWindowContains(p, p2: number)
	local configDateToDayKey = TimeService.configDateToDayKey(p.startDate)
	local configDateToDayKey2 = TimeService.configDateToDayKey(p.endDate)
	return configDateToDayKey ~= nil and configDateToDayKey2 ~= nil and configDateToDayKey <= p2 and p2 <= configDateToDayKey2
end

local function firstPossibleWeek(p: number)
	local v5 = p * 86400
	local weekKeyAt = TimeService.getWeekKeyAt(v5, 0, 0, 1)

	if p == TimeService.getWeekBoundaryDayKeyAt(v5, 0, 0, 1) then
		return weekKeyAt - 1
	end

	return weekKeyAt
end

local function loadHistory()
	if v3 then
		return true
	end

	if RunService:IsStudio() then
		v3 = {}
		return true
	end

	local success, result = pcall(function()
		return assert(dataStore):GetAsync("History")
	end)

	if success then
		v3 = typeof(result) ~= "table" and {} or result
		return true
	end

	warn("[MailService] 读取周榜发奖历史失败: " .. tostring(result))
	return false
end

local function readWeekWinners(p: number, p2: number)
	local orderedDataStore = DataStoreService:GetOrderedDataStore("WeeklyRobuxSpentLeaderboardV1-" .. tostring(p))
	local result = {}
	local success, result2 = pcall(function()
		local sortedAsync = orderedDataStore:GetSortedAsync(false, (math.min(p2, 100)))

		while true do
			for _, v6 in sortedAsync:GetCurrentPage() do
				local key = tonumber(v6.key)

				if not key then
					continue
				end

				table.insert(result, key)

				if p2 <= #result then
					return
				end
			end

			if sortedAsync.IsFinished then
				break
			else
				sortedAsync:AdvanceToNextPageAsync()
			end
		end
	end)

	if success then
		return result
	end

	warn("[MailService] 读取第 " .. tostring(p) .. " 周榜失败: " .. tostring(result2))
	return nil
end

local function doEnsureHistory()
	if not loadHistory() then
		return false
	end

	if RunService:IsStudio() then
		return true
	end

	local v5, v6 = rewardLimit()

	if not (v5 and v6) then
		return true
	end

	local v7 = weeklyMail(v6) -- equivalent call inferred; original call site unknown

	if not v7 then
		return true
	end

	local configDateToDayKey = TimeService.configDateToDayKey(v7.startDate)

	if not configDateToDayKey then
		return true
	end

	local now = TimeService.now()
	local weekKeyAt = TimeService.getWeekKeyAt(now, 0, 0, 1)
	local weekBoundaryDayKeyAt = TimeService.getWeekBoundaryDayKeyAt(now, 0, 0, 1)
	local v8 = configDateToDayKey * 86400
	local weekKeyAt2 = TimeService.getWeekKeyAt(v8, 0, 0, 1)

	if configDateToDayKey == TimeService.getWeekBoundaryDayKeyAt(v8, 0, 0, 1) then
		weekKeyAt2 -= 1
	end

	for i = weekKeyAt2, weekKeyAt - 1 do
		local v9 = tostring(i)

		if v3[v9] ~= nil then
			continue
		end

		local v10 = weekCloseDayKey(weekBoundaryDayKeyAt, weekKeyAt, i)
		local configDateToDayKey2 = TimeService.configDateToDayKey(v7.startDate)
		local configDateToDayKey3 = TimeService.configDateToDayKey(v7.endDate)
		local v11

		if configDateToDayKey2 == nil or configDateToDayKey3 == nil or not (configDateToDayKey2 <= v10) then
			v11 = false
		else
			v11 = v10 <= configDateToDayKey3
		end

		if not (v11 and v10 * 86400 + 120 <= now) then
			continue
		end

		local v12 = readWeekWinners(i, v5)

		if not v12 then
			return false
		end

		if RunService:IsStudio() then
			v3[v9] = v12
		else
			local v13 = v9
			local v14 = v12
			local success, result = pcall(function()
				return assert(dataStore):UpdateAsync("History", function(p)
					local v15 = typeof(p) ~= "table" and {} or p

					if v15[v13] == nil then
						v15[v13] = v14
					end

					return v15
				end)
			end)

			if success and typeof(result) == "table" then
				v3 = result
			else
				warn("[MailService] 保存第 " .. v9 .. " 周榜结果失败: " .. tostring(result))
				return false
			end
		end
	end

	return true
end

local flag = false

local function ensureHistory()
	while flag do
		task.wait(0.1)
	end

	flag = true
	local success, result = pcall(doEnsureHistory)
	flag = false

	if not success then
		warn("[MailService] 周榜历史检查出错: " .. tostring(result))
		return false
	end

	return result == true
end

local function addMail(p, p2: string, value: number?)
	if p.mailbox.mails[p2]() ~= nil then
		return
	end

	p.mailbox.mails[p2]({
		deliveredAt = TimeService.now(),
		readAt = 0,
		claimedAt = 0,
		rank = value or 0
	})
end

local function adminRow(value)
	local selected

	if typeof(value) == "string" then
		selected = Config.mail.byCnId[value]
	end

	if selected and selected.scope == "管理员发放" then
		return selected
	end

	return nil
end

local function deliverAdminQueue(p, p2, dayKey: number)
	local userId = tostring(p.UserId)
	local success, result = pcall(function()
		return dataStore2:GetAsync(userId)
	end)

	if not success then
		warn("[MailService] 读取管理员邮件队列失败: " .. tostring(result))
		return
	end

	if typeof(result) ~= "table" then
		return
	end

	local v5 = {}
	local v6 = false

	for _, v7 in result do
		local v8

		if typeof(v7) == "table" and typeof(v7.id) == "string" then
			local mailCnId = v7.mailCnId

			if typeof(mailCnId) == "string" then
				v8 = Config.mail.byCnId[mailCnId]
			end

			if not v8 or v8.scope ~= "管理员发放" then
				v8 = nil
			end
		end

		if not v8 then
			continue
		end

		local configDateToDayKey = TimeService.configDateToDayKey(v8.startDate)
		local configDateToDayKey2 = TimeService.configDateToDayKey(v8.endDate)
		local v9

		if configDateToDayKey == nil or configDateToDayKey2 == nil or not (configDateToDayKey <= dayKey) then
			v9 = false
		else
			v9 = dayKey <= configDateToDayKey2
		end

		if not v9 then
			continue
		end

		addMail(p2, v7.id, nil)
		v5[v7.id] = true
		v6 = true
	end

	if not v6 then
		return
	end

	local success2, result2 = pcall(function()
		dataStore2:UpdateAsync(userId, function(items)
			if typeof(items) ~= "table" then
				return nil
			end

			local result3 = {}

			for _, item in items do
				if typeof(item) ~= "table" or not v5[item.id] then
					table.insert(result3, item)
				end
			end

			return result3
		end)
	end)

	if not success2 then
		warn("[MailService] 移出管理员邮件队列失败: " .. tostring(result2))
	end
end

function MailService.server.enqueueAdmin(value: string, value2: string, sender: number)
	if typeof(value) ~= "string" or value == "" then
		return false, "INVALID_INPUT"
	end

	local v5

	if typeof(value2) == "string" then
		v5 = Config.mail.byCnId[value2]
	end

	if not v5 or v5.scope ~= "管理员发放" then
		v5 = nil
	end

	if not v5 then
		return false, "INVALID_MAIL"
	end

	local success, result = pcall(function()
		return Players:GetUserIdFromNameAsync(value)
	end)

	if not success or typeof(result) ~= "number" then
		return false, "PLAYER_NOT_FOUND"
	end

	local v6 = {
		id = "admin:" .. value2 .. ":" .. HttpService:GenerateGUID(false),
		mailCnId = value2,
		sentAt = TimeService.now(),
		sender = sender
	}
	local success2, result2 = pcall(function()
		dataStore2:UpdateAsync(tostring(result), function(p2)
			local selected = typeof(p2) ~= "table" and {} or p2
			table.insert(selected, v6)
			return selected
		end)
	end)

	if success2 then
		return true, "SENT"
	end

	warn("[MailService] 写入管理员邮件队列失败: " .. tostring(result2))
	return false, "DATASTORE_ERROR"
end

local function refreshPlayer(p)
	local v5 = server.Service:waitForData(p)

	if p.Parent ~= Players then
		return
	end

	local dayKey = TimeService.getDayKey(0)

	for _, v6 in Config.mail.list do
		if not (v6.scope == "全服" and typeof(v6.cnId) == "string") then
			continue
		end

		local configDateToDayKey = TimeService.configDateToDayKey(v6.startDate)
		local configDateToDayKey2 = TimeService.configDateToDayKey(v6.endDate)
		local v7

		if configDateToDayKey == nil or configDateToDayKey2 == nil or not (configDateToDayKey <= dayKey) then
			v7 = false
		else
			v7 = dayKey <= configDateToDayKey2
		end

		if v7 then
			addMail(v5, "global:" .. v6.cnId, nil)
		end
	end

	deliverAdminQueue(p, v5, dayKey)

	if p.Parent == Players then
	end
end

local function deliverWeeklyResult(p, userId: number, items, list: string, p2)
	for k, item in items do
		if item ~= userId then
			continue
		end

		for k2 in p.mailbox.mails() do
			if string.sub(k2, 1, #list) == list then
				return false
			end
		end

		addMail(p, list .. p2.cnId, k)
		return true
	end

	return false
end

local v5 = nil

local function endWeeklySettlementTest()
	v5 = nil
	ReplicatedStorage:SetAttribute("WeeklySpendTestEndsAt", nil)
	return true, "Weekly leaderboard test ended. Delivered mail is kept."
end

MailService.server.endWeeklySettlementTest = endWeeklySettlementTest

local function startWeeklySettlementTest(duration: number)
	if not v then
		return false, "Weekly spend rewards are disabled."
	end

	if typeof(duration) ~= "number" or duration ~= duration or duration < 0 or duration > 3600 then
		return false, "Enter a delay from 0 to 3600 seconds."
	end

	if v5 then
		return false, "A weekly leaderboard test is already running. End it first."
	end

	local v6, v7 = rewardLimit()
	local v8

	if v7 then
		for _, v10 in Config.mail.list do
			if not (v10.scope == "自定义" and v10.rewardId == v7) then
				continue
			end

			v8 = v10
			break
		end
	else
		v8 = nil
	end

	if not (v6 and v8) then
		return false, "Weekly reward or mail configuration is missing."
	end

	local v9 = {
		id = HttpService:GenerateGUID(false),
		week = TimeService.getWeekKeyAt(TimeService.now(), 0, 0, 1)
	}
	v5 = v9
	ReplicatedStorage:SetAttribute("WeeklySpendTestEndsAt", TimeService.now() + duration)
	task.delay(duration, function()
		if v5 ~= v9 then
			return
		end

		local success, result = pcall(function()
			local v10 = readWeekWinners(v9.week, v6)

			if v5 ~= v9 then
				return
			end

			if not v10 then
				error("Could not read the weekly leaderboard; start the test again to retry.")
			end

			local v11 = "weeklyTest:" .. tostring(v9.week) .. ":" .. v9.id .. ":"
			local v12 = {}
			local count = 0
			local count2 = 0

			for k, v13 in v10 do
				v12[v13] = k
				local playerByUserId = Players:GetPlayerByUserId(v13)
				print(string.format(
					"[MailService] 周榜测试名单：名次 %d，UserId %s，本服在线 %s，批次 %s",
					k,
					tostring(v13),
					tostring(playerByUserId ~= nil),
					v9.id
				))
			end

			for _, v13 in Players:GetPlayers() do
				if v5 ~= v9 then
					return
				end

				local v14 = v13
				local success2, result2 = pcall(function()
					-- equivalent calls inferred from this helper; original call sites unknown
					local function report(p: string)
						print(string.format(
							"[MailService] 周榜测试玩家：%s (%s)，周次 %s，名次 %s，结果 %s，批次 %s",
							v14.Name,
							tostring(v14.UserId),
							tostring(v9.week),
							tostring(v12[v14.UserId] or "未入奖励名单"),
							p,
							v9.id
						))
					end

					if not server.Service:getProfile(v14) then
						report("跳过：玩家存档尚未加载") -- equivalent call inferred; original call site unknown
						return
					end

					local v15 = server.Service:waitForData(v14)

					if v5 ~= v9 or v14.Parent ~= Players then
						report("跳过：测试已取消或玩家已离服") -- equivalent call inferred; original call site unknown
						return
					end

					local v16 = v15.weeklyRobuxSpent()[tostring(v9.week)]

					if typeof(v16) == "number" and not (v16 <= 0) then
						if v12[v14.UserId] then
							if not deliverWeeklyResult(v15, v14.UserId, v10, v11, v8) then
								report("跳过：本测试批次已投递") -- equivalent call inferred; original call site unknown
								return
							end

							count += 1
							report("已投递，周消费=" .. tostring(v16)) -- equivalent call inferred; original call site unknown
						else
							report("跳过：未入本期奖励名单，周消费=" .. tostring(v16)) -- equivalent call inferred; original call site unknown
						end
					else
						report("跳过：该周消费记录不是正数，记录值=" .. tostring(v16)) -- equivalent call inferred; original call site unknown
					end
				end)

				if success2 then
					continue
				end

				count2 += 1
				warn("[MailService] 周榜测试投递失败 (" .. tostring(v13.UserId) .. "): " .. tostring(result2))
			end

			print(string.format(
				"[MailService] 周榜测试结算完成：周次 %s，榜单人数 %d，本服投递 %d，失败 %d，批次 %s",
				tostring(v9.week),
				#v10,
				count,
				count2,
				v9.id
			))
		end)

		if not success then
			warn("[MailService] 周榜测试结算失败: " .. tostring(result))
		end

		if v5 == v9 then
			v5 = nil
			ReplicatedStorage:SetAttribute("WeeklySpendTestEndsAt", nil)
		end
	end)
	return
		true,
		string.format(
			"Weekly leaderboard test started: %.1fs. Online winners receive claimable mail. Batch: %s",
			duration,
			v9.id
		)
end

MailService.server.startWeeklySettlementTest = startWeeklySettlementTest

local function refreshWeeklyRewards(p, flag2: boolean?)
	local v6 = server.Service:waitForData(p)

	if not (p.Parent == Players and (flag2 or ensureHistory()) and p.Parent == Players) then
		return
	end

	local v7, v8 = rewardLimit()
	local v9

	if v8 then
		for _, v11 in Config.mail.list do
			if not (v11.scope == "自定义" and v11.rewardId == v8) then
				continue
			end

			v9 = v11
			break
		end
	end

	if not (v7 and v9) then
		return
	end

	local weeklyRobuxSpent = v6.weeklyRobuxSpent()

	for k, v10 in weeklyRobuxSpent do
		if not (typeof(v10) == "number" and v10 > 0) then
			continue
		end

		local v11 = v3[k]

		if typeof(v11) == "table" then
			deliverWeeklyResult(v6, p.UserId, v11, "weekly:" .. k .. ":", v9)
		end
	end
end

function MailService.server.deliverCustom(p, p2: string, items)
	local v6 = server.Service:waitForData(p)

	if v6.mailbox.mails[p2]() ~= nil then
		return
	end

	local v7 = {
		deliveredAt = TimeService.now(),
		readAt = 0,
		claimedAt = 0,
		rank = 0
	}

	for k, item in items do
		v7[k] = item
	end

	v6.mailbox.mails[p2](v7)
end

local function parseMailId(value: string)
	if string.match(value, "^diamondDraw:%d+$") then
		local v6 = Config.mail.byCnId["钻石奖池中奖"]

		if v6 and v6.scope == "自定义" then
			return v6
		end

		return nil
	else
		local v6 = string.match(value, "^global:(.+)$")

		if v6 then
			local v7 = Config.mail.byCnId[v6]

			if v7 and v7.scope == "全服" then
				return v7
			end

			return nil
		else
			local v7 = string.match(value, "^weeklyTest:%d+:[%w%-]+:(.+)$")

			if v7 then
				if not v then
					return nil
				end

				local v8 = Config.mail.byCnId[v7]

				if v8 and v8.scope == "自定义" then
					return v8
				end

				return nil
			else
				local v8, v9 = string.match(value, "^weekly:(%d+):(.+)$")

				if v8 and v9 then
					if not v then
						return nil
					end

					local v10 = Config.mail.byCnId[v9]

					if v10 and v10.scope == "自定义" then
						return v10
					end

					return nil
				else
					local v10 = string.match(value, "^admin:(.+):[%w%-]+$")

					if not v10 then
						return nil
					end

					local selected

					if typeof(v10) == "string" then
						selected = Config.mail.byCnId[v10]
					end

					if selected and selected.scope == "管理员发放" then
						return selected
					end

					return nil
				end
			end
		end
	end
end

local function claimOne(p, value: string)
	if typeof(value) ~= "string" then
		return {
			ok = false,
			reason = "invalid_id"
		}
	end

	local v6 = parseMailId(value)

	if not v6 then
		return {
			ok = false,
			reason = "missing_config"
		}
	end

	local v7 = server.Service:waitForData(p)
	local v8 = v7.mailbox.mails[value]()

	if not v8 then
		return {
			ok = false,
			reason = "missing_mail"
		}
	end

	if v8.claimedAt > 0 then
		return {
			ok = true,
			alreadyClaimed = true
		}
	end

	local v9

	if typeof(v8.amount) == "number" then
		v9 = v8.amount
	end

	local v10 = RewardItemService.grant(p, v6.rewardId, v9)

	if not v10.ok then
		return v10
	end

	v7.mailbox.mails[value].claimedAt(TimeService.now())
	return {
		ok = true,
		results = v10.results
	}
end

local function init()
	remoteEvent.OnServerEvent:Connect(function(p, value)
		if typeof(value) ~= "string" or not parseMailId(value) then
			return
		end

		local v6 = server.Service:waitForData(p)
		local v7 = v6.mailbox.mails[value]()

		if v7 and v7.readAt == 0 then
			v6.mailbox.mails[value].readAt(TimeService.now())
		end
	end)

	remoteFunction.OnServerInvoke = function(p, p2)
		if v4[p] then
			return {
				ok = false,
				reason = "busy"
			}
		end

		v4[p] = true
		local success, result = pcall(function()
			if p2 ~= "ALL" then
				return (claimOne(p, p2))
			end

			local count = 0

			for k, v6 in server.Service:waitForData(p).mailbox.mails() do
				if not (v6.claimedAt == 0 and parseMailId(k) and claimOne(p, k).ok) then
					continue
				end

				count += 1
			end

			return {
				ok = true,
				claimed = count
			}
		end)
		v4[p] = nil

		if success then
			return result
		end

		warn("[MailService] 领取失败: " .. tostring(result))
		return {
			ok = false,
			reason = "error"
		}
	end

	Players.PlayerRemoving:Connect(function(player)
		v4[player] = nil
	end)
	Players.PlayerAdded:Connect(function(player)
		task.spawn(refreshPlayer, player)
	end)

	for _, v6 in Players:GetPlayers() do
		task.spawn(refreshPlayer, v6)
	end

	if v then
		Players.PlayerAdded:Connect(function(player)
			task.spawn(refreshWeeklyRewards, player)
		end)

		for _, v6 in Players:GetPlayers() do
			task.spawn(refreshWeeklyRewards, v6)
		end

		if not v2 then
			v2 = true
			task.spawn(function()
				while true do
					task.wait(30)
					local success, result = pcall(function()
						if #Players:GetPlayers() == 0 or not ensureHistory() then
							return
						end

						for _, v6 in Players:GetPlayers() do
							if not server.Service:getProfile(v6) then
								continue
							end

							local success2, result2 = pcall(refreshWeeklyRewards, v6, true)

							if not success2 then
								warn("[MailService] 在线周榜邮件检查失败 (" .. tostring(v6.UserId) .. "): " .. tostring(result2))
							end
						end
					end)

					if not success then
						warn("[MailService] 在线周榜检查失败: " .. tostring(result))
					end
				end
			end)
		end
	end
end

MailService.server.init = init
return MailService