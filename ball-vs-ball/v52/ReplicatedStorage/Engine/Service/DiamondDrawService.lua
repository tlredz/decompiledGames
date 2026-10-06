local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Config = require(script.Parent.Config)
local TimeService = require(script.Parent.TimeService)
local GameFlags = require(ReplicatedStorage.GameFlags)
local Net = require(ReplicatedStorage.Packages.Net)
local DiamondDrawService = {
	server = {},
	MAIL_ID_PREFIX = "diamondDraw:",
	MAIL_CNID = "钻石奖池中奖",
	TICKET_ITEM_ID = "钻石奖池券"
}
local remoteFunction = Net:RemoteFunction("DiamondDraw/GetState")

function DiamondDrawService.isEnabled()
	return GameFlags.feature["全服抽奖活动"] == true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function lockSeconds()
	return math.max(0, tonumber(Config.misc.diamondDrawLockMinutes) or 0) * 60
end

function DiamondDrawService.ticketCost()
	return (math.max(1, (math.floor(tonumber(Config.misc.diamondDrawTicketCost) or 100))))
end

function DiamondDrawService.periodAt(p: number)
	return TimeService.getDayKeyAt(p + lockSeconds(), 0)
end

function DiamondDrawService.drawTimeOf(p: number)
	return (p + 1) * 86400
end

function DiamondDrawService.lockTimeOf(p: number)
	return DiamondDrawService.drawTimeOf(p) - lockSeconds()
end

function DiamondDrawService.prizeName(p: string)
	local v = Config.asset.byCnId["钻石奖池" .. p]

	if v then
		return v.txt, v.cnTxt
	end

	return p, p
end

function DiamondDrawService.mailIdOf(p: number)
	return DiamondDrawService.MAIL_ID_PREFIX .. tostring(p)
end

function DiamondDrawService.parseMailId(value: string)
	local v = string.match(value, "^diamondDraw:(%d+)$")

	if v then
		return (tonumber(v))
	end

	return nil
end

local function validateConfig()
	local list = Config.diamondDrawPrize and Config.diamondDrawPrize.list

	if typeof(list) ~= "table" or #list == 0 then
		return "钻石奖池奖项表为空"
	end

	local total = 0

	for _, v in list do
		local v2 = v.winnerCount ~= -1
		local v3 = v.winnerRatio ~= -1

		if v2 == v3 then
			return (`奖项{v.cnId}：winnerCount 与 winnerRatio 必须恰好一个为 -1`)
		end

		if v2 and (typeof(v.winnerCount) ~= "number" or not (v.winnerCount >= 1) or v.winnerCount % 1 ~= 0) then
			return (`奖项{v.cnId}：winnerCount 必须为正整数`)
		end

		if v3 and (typeof(v.winnerRatio) ~= "number" or not (v.winnerRatio > 0 and v.winnerRatio <= 1)) then
			return (`奖项{v.cnId}：winnerRatio 必须在 (0, 1] 内`)
		end

		if typeof(v.poolShare) ~= "number" or not (v.poolShare > 0 and v.poolShare <= 1) then
			return (`奖项{v.cnId}：poolShare 必须在 (0, 1] 内`)
		end

		if v.splitMode ~= "均分" and v.splitMode ~= "按券比例" then
			return (`奖项{v.cnId}：splitMode 只能是 均分 或 按券比例`)
		end

		if not Config.asset.byCnId["钻石奖池" .. v.cnId] then
			return (`奖项{v.cnId}：资源表缺少 钻石奖池{v.cnId}`)
		end

		total += v.poolShare
	end

	if total > 1.000000001 then
		return "奖项 poolShare 合计超过 1"
	end

	local v = Config.mail.byCnId[DiamondDrawService.MAIL_CNID]

	if not v then
		return (`邮件表缺少 {DiamondDrawService.MAIL_CNID}`)
	end

	local v2 = Config.reward.byCnId[v.rewardId]

	if v2 and #v2 == 1 and v2[1].extraArgs and v2[1].extraArgs["动态数量"] == true then
		return nil
	end

	return (`奖励 {v.rewardId} 必须是一条带 动态数量:true 的奖励`)
end

local function weightedSample(list, p: number, random)
	if p <= 0 or #list == 0 then
		return {}, list
	end

	local v = table.create(#list)

	for k, entry in list do
		v[k] = {
			entry = entry,
			key = math.log(1 - random:NextNumber()) / entry.t
		}
	end

	table.sort(v, function(a, b)
		if a.key == b.key then
			return a.entry.userId < b.entry.userId
		end

		return a.key > b.key
	end)
	local entries = {}
	local v2 = {}

	for i = 1, math.min(p, #v) do
		table.insert(entries, v[i].entry)
		v2[v[i].entry.userId] = true
	end

	local result = {}

	for _, v3 in list do
		if not v2[v3.userId] then
			table.insert(result, v3)
		end
	end

	return entries, result
end

function DiamondDrawService.computeDraw(period: number, items, drawnAt: number)
	local total = 0
	local total2 = 0
	local v = {}

	for _, item in items do
		total += item.c

		if not (item.t > 0) then
			continue
		end

		total2 += item.t
		table.insert(v, item)
	end

	table.sort(v, function(a, b)
		return a.userId < b.userId
	end)
	local pool = math.floor(total)
	local random = Random.new(period)
	local v3 = v
	local result = {}
	local total3 = 0
	local prizes = {}

	for _, v5 in Config.diamondDrawPrize.list do
		local v6 = math.floor(pool * v5.poolShare)
		local winnerCount

		if v5.winnerCount == -1 then
			winnerCount = math.floor(#v3 * v5.winnerRatio)
		else
			winnerCount = v5.winnerCount
		end

		local v7
		v7, v3 = weightedSample(v3, math.min(winnerCount, #v3), random)
		local total4 = 0

		for _, v8 in v7 do
			total4 += v8.t
		end

		local v8 = {
			count = 0,
			total = 0,
			winners = {}
		}

		for _, v9 in v7 do
			local amount

			if v5.splitMode == "均分" then
				amount = math.floor(v6 / math.max(winnerCount, 1))
			else
				amount = math.floor(v6 * v9.t / math.max(total4, 1))
			end

			if not (amount > 0) then
				continue
			end

			table.insert(result, {
				userId = v9.userId,
				prize = v5.cnId,
				amount = amount
			})
			v8.count += 1
			v8.total += amount
			total3 += amount

			if #v8.winners < 5 then
				table.insert(v8.winners, {
					u = v9.userId,
					n = v9.n,
					d = v9.d,
					a = amount,
					t = v9.t
				})
			end
		end

		prizes[v5.cnId] = v8
	end

	return result, {
		period = period,
		drawnAt = drawnAt,
		pool = pool,
		totalTickets = total2,
		participants = #v,
		unclaimedAmount = pool - total3,
		prizes = prizes
	}
end

if not RunService:IsServer() then
	function DiamondDrawService.getState()
		local success, result = pcall(function()
			return remoteFunction:InvokeServer()
		end)

		if success then
			return result
		end

		return nil
	end

	return DiamondDrawService
end

local MemoryStoreService = game:GetService("MemoryStoreService")
local DataStoreService = game:GetService("DataStoreService")
local MessagingService = game:GetService("MessagingService")
local PlayerData = require(script.Parent.PlayerData)
local server = PlayerData.server
local CurrencyService = require(script.Parent.CurrencyService)
local jobId

if game.JobId == "" then
	jobId = HttpService:GenerateGUID(false)
else
	jobId = game.JobId
end

local v = false
local v2 = nil
local hashMap = MemoryStoreService:GetHashMap("DiamondDraw_Meta")
local dataStore = DataStoreService:GetDataStore("DiamondDraw")
local v3 = {}
local v4 = {}
local history = {}
local v6 = {}
local v7 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function entryMap(p: number)
	return MemoryStoreService:GetSortedMap("DiamondDraw_" .. tostring(p))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function winMap(p: number)
	return MemoryStoreService:GetHashMap("DiamondDraw_Win_" .. tostring(p))
end

local function retry(p: string, fn)
	local v8 = nil

	for i = 1, 3 do
		local v9 = table.pack(pcall(fn))

		if v9[1] then
			return true, table.unpack(v9, 2, v9.n)
		end

		v8 = v9[2]
		task.wait(i)
	end

	warn((`[DiamondDrawService] {p} 失败: {tostring(v8)}`))
	return false
end

local function queueSnapshot(player, data)
	if data.period <= 0 or data.tickets <= 0 and data.contribution <= 0 then
		return
	end

	v3[tostring(player.UserId) .. ":" .. tostring(data.period)] = {
		period = data.period,
		key = tostring(player.UserId),
		value = {
			t = data.tickets,
			c = data.contribution,
			n = player.Name,
			d = player.DisplayName
		}
	}
end

local function ensurePeriod(p)
	local v8 = server[p]
	local diamondDraw = v8.diamondDraw()
	local periodAt = DiamondDrawService.periodAt(TimeService.now())

	if diamondDraw.period == periodAt then
		return diamondDraw
	end

	queueSnapshot(p, diamondDraw)
	local clone = table.clone(diamondDraw)
	clone.period = periodAt
	clone.tickets = 0
	clone.contribution = 0
	v8.diamondDraw(clone)
	return clone
end

local function mutate(p, fn)
	if p.Parent ~= Players then
		return
	end

	server.Service:waitForData(p)
	ensurePeriod(p)
	queueSnapshot(p, server[p].diamondDraw(function(p2)
		local clone = table.clone(p2)
		fn(clone)
		return clone
	end))
end

local function flush()
	local v8 = v3
	v3 = {}
	local now = TimeService.now()

	for k, v9 in v8 do
		if DiamondDrawService.drawTimeOf(v9.period) - 30 <= now then
			warn((`[DiamondDrawService] 第 {v9.period} 期已截止，丢弃未同步的条目 {v9.key}`))
		else
			local v10 = v9

			if not pcall(function()
				local period = v10.period
				MemoryStoreService:GetSortedMap("DiamondDraw_" .. tostring(period)):SetAsync(
					v10.key,
					v10.value,
					259200,
					v10.value.t
				)
			end) and v3[k] == nil then
				v3[k] = v9
			end
		end
	end
end

local function scanPeriod(p: number)
	local v8 = entryMap(p) -- equivalent call inferred; original call site unknown
	local v9 = nil
	local result = {}

	while true do
		local v10, v11 = retry(`读取第 {p} 期参与者`, function()
			return v8:GetRangeAsync(Enum.SortDirection.Ascending, 200, v9)
		end)

		if not v10 then
			break
		end

		for _, v12 in v11 do
			local key = tonumber(v12.key)
			local value = v12.value

			if not (key and typeof(value) == "table" and typeof(value.t) == "number" and typeof(value.c) == "number") then
				continue
			end

			table.insert(result, {
				userId = key,
				t = math.max(0, (math.floor(value.t))),
				c = math.max(0, value.c),
				n = value.n,
				d = value.d
			})
		end

		if #v11 < 200 then
			return result
		end

		local v12 = v11[#v11]
		v9 = {
			key = v12.key,
			sortKey = v12.sortKey
		}
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function tryLock(p: string, p2: number)
	local success, result = pcall(function()
		return hashMap:UpdateAsync(p, function(p3)
			if p3 == nil or p3 == jobId then
				return jobId
			end

			return nil
		end, p2)
	end)
	return success and result == jobId
end

local function summarize(items)
	local total = 0
	local total2 = 0
	local count = 0

	for _, item in items do
		total += item.c
		total2 += item.t

		if item.t > 0 then
			count += 1
		end
	end

	return {
		pool = math.floor(total),
		tickets = total2,
		participants = count,
		at = TimeService.now()
	}
end

local function loadHistory()
	local v8, v9 = retry("读取钻石奖池历史", function()
		return dataStore:GetAsync("Recent")
	end)

	if v8 and typeof(v9) == "table" then
		history = v9

		for _, v10 in history do
			v6[v10.period] = true
		end
	end
end

local fn

local function onDrawn(p: number, flag: boolean)
	v6[p] = true
	task.spawn(function()
		if flag then
			task.wait(math.random() * 300)
		end

		loadHistory()
		fn(nil)
	end)
end

local function runDraw(p: number, flag: boolean?)
	if v7[p] then
		return false
	end

	if not flag then
		local v8 = "drawLock_" .. tostring(p)
		local v9 = 180
		local success, result = pcall(function()
			return hashMap:UpdateAsync(v8, function(p2)
				if p2 == nil or p2 == jobId then
					return jobId
				end

				return nil
			end, v9)
		end)

		if not success or result ~= jobId then
			return false
		end
	end

	v7[p] = true
	local flag2 = false
	local success, result = pcall(function()
		local v8, v9 = retry(`检查第 {p} 期是否已提交`, function()
			return dataStore:GetAsync("Period_" .. tostring(p))
		end)

		if not v8 then
			return
		end

		if v9 == nil then
			local v10 = scanPeriod(p)

			if not v10 then
				return
			end

			local draw, v11 = DiamondDrawService.computeDraw(p, v10, TimeService.now())
			local v12 = winMap(p) -- equivalent call inferred; original call site unknown
			local threads = {}
			local flag3 = false
			local count = 0

			for _ = 1, 20 do
				table.insert(threads, task.spawn(function()
					while not flag3 do
						count += 1
						local v13 = draw[count]

						if not v13 then
							break
						end

						if retry(`写入第 {p} 期中奖 {v13.userId}`, function()
							v12:SetAsync(tostring(v13.userId), {
								p = v13.prize,
								a = v13.amount
							}, 604800)
						end) then
							continue
						end

						flag3 = true
					end
				end))
			end

			for _, v13 in threads do
				while coroutine.status(v13) ~= "dead" do
					task.wait(0.1)
				end
			end

			if flag3 then
				return
			end

			if not retry(`提交第 {p} 期结果`, function()
				dataStore:UpdateAsync("Period_" .. tostring(p), function(p2)
					if p2 == nil then
						return v11
					end

					return nil
				end)
			end) then
				return
			end

			retry("更新钻石奖池历史", function()
				dataStore:UpdateAsync("Recent", function(p2)
					local v13 = typeof(p2) ~= "table" and {} or p2

					for _, v14 in v13 do
						if v14.period == p then
							return nil
						end
					end

					table.insert(v13, 1, v11)

					while #v13 > 30 do
						table.remove(v13)
					end

					return v13
				end)
			end)
			pcall(function()
				hashMap:SetAsync("drawn_" .. tostring(p), true, 691200)
			end)
			pcall(function()
				MessagingService:PublishAsync("DiamondDraw", p)
			end)
			print((`[DiamondDrawService] 第 {p} 期开奖完成：奖池 {v11.pool}，参与 {v11.participants} 人，中奖 {#draw} 人，回收 {v11.unclaimedAmount}`))
			flag2 = true
		else
			pcall(function()
				hashMap:SetAsync("drawn_" .. tostring(p), true, 691200)
			end)
			flag2 = true
		end
	end)
	v7[p] = nil

	if not success then
		warn((`[DiamondDrawService] 第 {p} 期开奖出错: {tostring(result)}`))
	end

	if flag2 then
		v6[p] = true
		local flag3 = false
		task.spawn(function()
			if flag3 then
				task.wait(math.random() * 300)
			end

			loadHistory()
			fn(nil)
		end)
	end

	return flag2
end

local function deliverPeriod(p, p2: number)
	local success, result = pcall(function()
		return MemoryStoreService:GetHashMap("DiamondDraw_Win_" .. tostring(p2)):GetAsync((tostring(p.UserId)))
	end)

	if not success then
		return false
	end

	if typeof(result) == "table" and typeof(result.a) == "number" and result.a > 0 and typeof(result.p) == "string" then
		local MailService = require(script.Parent.MailService)
		MailService.server.deliverCustom(p, DiamondDrawService.mailIdOf(p2), {
			prize = result.p,
			amount = result.a
		})
	end

	return true
end

local function deliver(p)
	local v8 = server.Service:waitForData(p)

	if p.Parent ~= Players then
		return
	end

	local v9 = TimeService.getDayKeyAt(TimeService.now(), 0) - 1
	local checkedPeriod = v8.diamondDraw.checkedPeriod()

	for i = math.max(checkedPeriod + 1, v9 - 6), v9 do
		if i == v9 and not v6[i] or not deliverPeriod(p, i) then
			break
		else
			checkedPeriod = i
		end
	end

	if v8.diamondDraw.checkedPeriod() < checkedPeriod then
		v8.diamondDraw.checkedPeriod(checkedPeriod)
	end
end

fn = function(p: number?)
	for _, v8 in Players:GetPlayers() do
		local v9 = v8
		task.spawn(function()
			if p then
				deliverPeriod(v9, p)
			else
				deliver(v9)
			end
		end)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function currentSummary()
	return v4[DiamondDrawService.periodAt(TimeService.now())] or {
		pool = 0,
		tickets = 0,
		participants = 0,
		at = 0
	}
end

local function summaryLoop()
	local v8 = 0
	local v9 = 0

	while true do
		local now = TimeService.now()
		local periodAt = DiamondDrawService.periodAt(now)

		if now - v8 >= 300 and tryLock("summaryLeader", 330) then
			local v12 = scanPeriod(periodAt)

			if not v12 then
				task.wait(60 + math.random() * 10)
				continue
			end

			local v13 = summarize(v12)
			v4[periodAt] = v13
			local v14 = periodAt
			pcall(function()
				hashMap:SetAsync("summary_" .. tostring(v14), v13, 172800)
			end)
			v9 = now
			v8 = v9
			v9 = v8
			task.wait(60 + math.random() * 10)
			continue
		end

		if now - v9 >= 120 then
			local v10 = periodAt
			local success, result = pcall(function()
				return hashMap:GetAsync("summary_" .. tostring(v10))
			end)

			if success and typeof(result) == "table" then
				v4[periodAt] = result
			end

			v9 = now
			task.wait(60 + math.random() * 10)
		else
			task.wait(60 + math.random() * 10)
		end
	end
end

local function drawLoop()
	while true do
		local now = TimeService.now()
		local v8 = TimeService.getDayKeyAt(now, 0) - 1

		if not v6[v8] then
			local v9 = v8
			local success, result = pcall(function()
				return hashMap:GetAsync("drawn_" .. tostring(v9))
			end)

			if success and result == true then
				v6[v8] = true
				local v11 = true
				task.spawn(function()
					if v11 then
						task.wait(math.random() * 300)
					end

					loadHistory()
					fn(nil)
				end)
			elseif DiamondDrawService.drawTimeOf(v8) + 15 <= now then
				runDraw(v8)
			end
		end

		task.wait(30 + math.random() * 30)
	end
end

local function onSpent(p, p2: string, p3: number)
	if p2 ~= CurrencyService.ref.Diamonds then
		return
	end

	local ticketCost = DiamondDrawService.ticketCost()
	local diamondDrawSpendRate = tonumber(Config.misc.diamondDrawSpendRate) or 0
	mutate(p, function(state)
		local v8 = state.spendProgress + p3
		local v9 = math.floor(v8 / ticketCost)
		state.spendProgress = v8 - v9 * ticketCost
		state.tickets += v9
		state.contribution += p3 * diamondDrawSpendRate
	end)
end

local function onFee(p, p2: string, p3: number)
	if p2 ~= CurrencyService.ref.Diamonds then
		return
	end

	local diamondDrawFeeRate = tonumber(Config.misc.diamondDrawFeeRate) or 0
	mutate(p, function(p4)
		p4.contribution += p3 * diamondDrawFeeRate
	end)
end

local function addTickets(p, p2: number)
	if v and not (v2 or p2 <= 0) then
		mutate(p, function(p3)
			p3.tickets += math.floor(p2)
		end)
	end
end

DiamondDrawService.server.addTickets = addTickets

function DiamondDrawService.server.debugAddContribution(p, p2: number)
	mutate(p, function(p3)
		p3.contribution += p2
	end)
end

local function debugDrawNow()
	local periodAt = DiamondDrawService.periodAt(TimeService.now())
	flush()
	local v8

	if v7[periodAt] then
		v8 = false
	else
		v7[periodAt] = true
		local flag = false
		local success, result = pcall(function()
			local v9, v10 = retry(`检查第 {periodAt} 期是否已提交`, function()
				return dataStore:GetAsync("Period_" .. tostring(periodAt))
			end)

			if not v9 then
				return
			end

			if v10 == nil then
				local v11 = scanPeriod(periodAt)

				if not v11 then
					return
				end

				local draw, v12 = DiamondDrawService.computeDraw(periodAt, v11, TimeService.now())
				local v13 = winMap(periodAt) -- equivalent call inferred; original call site unknown
				local threads = {}
				local flag2 = false
				local count = 0

				for _ = 1, 20 do
					table.insert(threads, task.spawn(function()
						while not flag2 do
							count += 1
							local v14 = draw[count]

							if not v14 then
								break
							end

							if retry(`写入第 {periodAt} 期中奖 {v14.userId}`, function()
								v13:SetAsync(tostring(v14.userId), {
									p = v14.prize,
									a = v14.amount
								}, 604800)
							end) then
								continue
							end

							flag2 = true
						end
					end))
				end

				for _, v14 in threads do
					while coroutine.status(v14) ~= "dead" do
						task.wait(0.1)
					end
				end

				if flag2 then
					return
				end

				if not retry(`提交第 {periodAt} 期结果`, function()
					dataStore:UpdateAsync("Period_" .. tostring(periodAt), function(p)
						if p == nil then
							return v12
						end

						return nil
					end)
				end) then
					return
				end

				retry("更新钻石奖池历史", function()
					dataStore:UpdateAsync("Recent", function(p)
						local v14 = typeof(p) ~= "table" and {} or p

						for _, v15 in v14 do
							if v15.period == periodAt then
								return nil
							end
						end

						table.insert(v14, 1, v12)

						while #v14 > 30 do
							table.remove(v14)
						end

						return v14
					end)
				end)
				pcall(function()
					hashMap:SetAsync("drawn_" .. tostring(periodAt), true, 691200)
				end)
				pcall(function()
					MessagingService:PublishAsync("DiamondDraw", periodAt)
				end)
				print((`[DiamondDrawService] 第 {periodAt} 期开奖完成：奖池 {v12.pool}，参与 {v12.participants} 人，中奖 {#draw} 人，回收 {v12.unclaimedAmount}`))
				flag = true
			else
				pcall(function()
					hashMap:SetAsync("drawn_" .. tostring(periodAt), true, 691200)
				end)
				flag = true
			end
		end)
		v7[periodAt] = nil

		if not success then
			warn((`[DiamondDrawService] 第 {periodAt} 期开奖出错: {tostring(result)}`))
		end

		if flag then
			v6[periodAt] = true
			local flag2 = false
			task.spawn(function()
				if flag2 then
					task.wait(math.random() * 300)
				end

				loadHistory()
				fn(nil)
			end)
		end

		v8 = flag
	end

	if v8 then
		fn(periodAt)
	end

	return v8
end

DiamondDrawService.server.debugDrawNow = debugDrawNow

local function init()
	assert(RunService:IsServer(), "DiamondDrawService.server.init 只能在服务端调用")

	if v or not DiamondDrawService.isEnabled() then
		return
	end

	v = true
	v2 = validateConfig()

	if v2 then
		warn("[DiamondDrawService] 配置错误，钻石奖池已停用: " .. v2)
		return
	end

	CurrencyService.server.onSpent(onSpent)
	CurrencyService.server.onFeeCollected(onFee)

	remoteFunction.OnServerInvoke = function()
		local now = TimeService.now()
		local periodAt = DiamondDrawService.periodAt(now)
		return {
			period = periodAt,
			drawAt = DiamondDrawService.drawTimeOf(periodAt),
			lockAt = DiamondDrawService.lockTimeOf(periodAt),
			summary = currentSummary(),
			history = history
		}
	end

	pcall(function()
		MessagingService:SubscribeAsync("DiamondDraw", function(p)
			local data = tonumber(p.Data)

			if data and not v6[data] then
				v6[data] = true
				local flag = true
				task.spawn(function()
					if flag then
						task.wait(math.random() * 300)
					end

					loadHistory()
					fn(nil)
				end)
			end
		end)
	end)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function onPlayerAdded(p)
		task.spawn(function()
			server.Service:waitForData(p)

			if p.Parent ~= Players then
				return
			end

			queueSnapshot(p, ensurePeriod(p))
			deliver(p)
		end)
	end

	Players.PlayerAdded:Connect(onPlayerAdded)

	for _, v8 in Players:GetPlayers() do
		onPlayerAdded(v8) -- equivalent call inferred; original call site unknown
	end

	game:BindToClose(flush)
	task.spawn(function()
		while true do
			task.wait(60)
			flush()
		end
	end)
	task.spawn(function()
		loadHistory()
		task.spawn(summaryLoop)
		drawLoop()
	end)
end

DiamondDrawService.server.init = init
return DiamondDrawService