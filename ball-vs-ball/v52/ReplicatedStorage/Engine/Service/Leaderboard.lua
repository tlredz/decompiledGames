local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local engine = ReplicatedStorage:WaitForChild("Engine")
local TimeService = require(script.Parent:WaitForChild("TimeService"))
local PlayerCountryService = require(script.Parent:WaitForChild("PlayerCountryService"))
local v = {}
local v2 = {}
local v3 = {}
local v4 = {}
local emojis = {}
local v5 = {}
local v6 = {}
local v7 = {}
local v8 = {}
local scalesByRig = {}
local v9 = {}

local function resolveKind(value: string?)
	return value or "player"
end

local function notifyClient(p: string)
	local v10 = v9[p]

	if not v10 then
		return
	end

	for k in pairs(v10) do
		task.spawn(k.callback)
	end
end

local function getListSize()
	return 50
end

local function resolveName(p: number)
	local v10 = v8[p]

	if v10 then
		return v10
	end

	local success, result = pcall(function()
		return Players:GetNameFromUserIdAsync(p)
	end)
	local v11 = (not success or typeof(result) ~= "string") and "Unknown" or result
	v8[p] = v11
	return v11
end

local function clearRows(instance)
	for _, frame in ipairs(instance:GetChildren()) do
		if frame:IsA("Frame") then
			frame.Visible = false
		end
	end
end

local function getRow(parent, i: number)
	local frame = parent:FindFirstChild((tostring(i)))

	if frame and frame:IsA("Frame") then
		return frame
	end

	local _4 = parent:FindFirstChild("4")

	if not (_4 and _4:IsA("Frame")) then
		return nil
	end

	local clone = _4:Clone()
	clone.Name = tostring(i)
	clone.Parent = parent
	return clone
end

local function renderBoardRows(model, list, renderRow)
	local firstChild = model:FindFirstChild("排名列表", true)

	if not firstChild then
		warn(string.format("[Leaderboard] 榜单模型 '%s' 缺少 排名列表", model:GetFullName()))
		return
	end

	clearRows(firstChild)

	for i, v10 in ipairs(list) do
		local row = getRow(firstChild, i)

		if not row then
			continue
		end

		row.Name = tostring(i)
		row.LayoutOrder = i
		renderRow(row, {
			rank = i,
			key = v10.key,
			value = v10.value,
			displayName = v10.displayName,
			emoji = v10.emoji
		})
		row.Visible = true
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getStoreName(p, p2: number?)
	if p2 then
		return p.storeName .. "-" .. tostring(p2)
	end

	return p.storeName
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getPeriodKey(period)
	return TimeService.getWeekKey(period.timezoneOffsetSeconds, period.resetHour, period.resetWeekday)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getPeriodSecondsRemaining(period)
	local now = TimeService.now()
	return (math.max(
		0,
		(math.floor((TimeService.getWeekBoundaryDayKeyAt(
			now,
			period.timezoneOffsetSeconds,
			period.resetHour,
			period.resetWeekday
		) + 7) * 86400 - period.timezoneOffsetSeconds + period.resetHour * 3600 - now))
	))
end

local function renderTitleLabel(p)
	local model = p.config.model

	if not model then
		return
	end

	local label = model:FindFirstChild("大标题", true)

	if not (label and label:IsA("TextLabel")) then
		return
	end

	local weeklySpendTestEndsAt = ReplicatedStorage:GetAttribute("WeeklySpendTestEndsAt")

	if p.config.storeName == "WeeklyRobuxSpentLeaderboardV1" and typeof(weeklySpendTestEndsAt) == "number" then
		local v10 = math.max(0, (math.ceil(weeklySpendTestEndsAt - TimeService.now())))
		label.Text = string.format(
			"%s [TEST %s]",
			p.config.title,
			not (v10 > 0) and "Settling..." or TimeService.formatCountdown(v10)
		)
	else
		if not p.config.period then
			label.Text = p.config.title
			return
		end

		local periodSecondsRemaining = getPeriodSecondsRemaining(p.config.period) -- equivalent call inferred; original call site unknown
		label.Text = string.format("%s (%s)", p.config.title, TimeService.formatCountdown(periodSecondsRemaining))
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function hideChampionRig(p)
	local rig = p.rig

	if not rig or rig.Parent == ServerStorage then
		return
	end

	p.rigOriginalParent = rig.Parent
	rig.Parent = ServerStorage
end

local function updateChampionRig(data)
	if (data.config.kind or "player") ~= "player" then
		return
	end

	local entry = data.entries[1]
	local rig = data.rig

	if not (entry and rig) then
		return
	end

	local key = tonumber(entry.key)

	if not key then
		return
	end

	if rig.Parent == ServerStorage and data.rigOriginalParent then
		rig.Parent = data.rigOriginalParent
	end

	task.spawn(function()
		local success, result = pcall(function()
			return Players:GetHumanoidDescriptionFromUserId(key)
		end)

		if not (success and result) then
			return
		end

		local humanoid = rig:FindFirstChildOfClass("Humanoid")

		if not humanoid then
			return
		end

		local scale = scalesByRig[rig]

		if scale == nil then
			scale = rig:GetScale()
			scalesByRig[rig] = scale
		end

		local rig2 = rig
		local v11 = key
		local name = v8[v11]

		if not name then
			local success2, result2 = pcall(function()
				return Players:GetNameFromUserIdAsync(v11)
			end)
			name = (not success2 or typeof(result2) ~= "string") and "Unknown" or result2
			v8[v11] = name
		end

		rig2.Name = name
		rig:ScaleTo(1)
		local v13 = pcall(function()
			humanoid:ApplyDescription(result)
		end)
		rig:ScaleTo(scale)

		if not v13 then
			return
		end

		local animation = rig:FindFirstChild("动画")
		local animator = humanoid:FindFirstChildOfClass("Animator")

		if animation and animation:IsA("Animation") and animator then
			animator:LoadAnimation(animation):Play()
		end
	end)
end

local function waitForBudget(getSortedAsync, p: number)
	local count = 0

	while count < 60 do
		local success, requestBudgetForRequestType = pcall(
			DataStoreService.GetRequestBudgetForRequestType,
			DataStoreService,
			getSortedAsync
		)

		if not success or p < requestBudgetForRequestType then
			break
		end

		task.wait(1)
		count += 1
	end
end

local function readTopList(data)
	local kind = data.config.kind or "player"

	for i = 1, 3 do
		waitForBudget(Enum.DataStoreRequestType.GetSortedAsync, 2)
		local success, result = pcall(function()
			return data.store:GetSortedAsync(false, data.listSize):GetCurrentPage()
		end)

		if success then
			local result2 = {}

			for _, v10 in ipairs(result) do
				local key = tostring(v10.key)
				local v11 = tonumber(key) or 0
				local v12 = {
					key = key,
					value = math.floor(v10.value),
					displayName = 0,
					emoji = 0
				}
				local displayName

				if kind == "player" then
					displayName = v8[v11]

					if not displayName then
						local v14 = v11
						local success2, result3 = pcall(function()
							return Players:GetNameFromUserIdAsync(v14)
						end)
						displayName = (not success2 or typeof(result3) ~= "string") and "Unknown" or result3
						v8[v11] = displayName
					end
				end

				v12.displayName = displayName
				local emoji

				if kind == "player" then
					emoji = PlayerCountryService.server.getCountryEmoji(v11)
				end

				v12.emoji = emoji
				table.insert(result2, v12)
			end

			return result2
		elseif i < 3 then
			task.wait(i)
		end
	end

	warn(string.format("[Leaderboard] 读取 '%s' 失败", data.config.storeName))
	return nil
end

local v10 = nil
local v11 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function publishSnapshot(p: string, p2)
	if v10 then
		v10:FireAllClients(p, p2.entries)
	end
end

local flag = false

local function refresh(p: string, state)
	if state.refreshing then
		state.refreshDirty = true
		return
	end

	state.refreshing = true

	while true do
		state.refreshDirty = false
		local v12 = 30 - time()

		if v12 > 0 then
			task.wait(v12)
		end

		while flag do
			task.wait(1)
		end

		flag = true
		local store = state.store
		local success, result = pcall(readTopList, state)
		flag = false

		if success then
			if result and state.store == store then
				state.entries = result
				updateChampionRig(state)
				publishSnapshot(p, state) -- equivalent call inferred; original call site unknown
			end
		else
			warn(string.format("[Leaderboard] 拉取 '%s' 出错: %s", p, (tostring(result))))
		end

		if state.refreshDirty then
			continue
		end

		state.refreshing = false
		break
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function canReachTopList(p, p2: number)
	if #p.entries < p.listSize then
		return true
	end

	local entry = p.entries[#p.entries]
	return entry == nil or entry.value <= p2
end

local function writeValue(p: string, p2, p3: string, p4: number, object)
	if p4 <= 0 and not p2.config.allowZero then
		return
	end

	for i = 1, 3 do
		local success, result = pcall(function()
			object:SetAsync(p3, (math.floor(p4)))
		end)

		if success then
			if p2.store == object then
				-- equivalent call inferred; original call site unknown
				if canReachTopList(p2, p4) then
					refresh(p, p2)
				end
			end

			break
		elseif i < 3 then
			task.wait(i)
		else
			warn(string.format("[Leaderboard] 写入 '%s' 失败（%s）: %s", p, p3, (tostring(result))))
		end
	end
end

local function scheduleWrite(p: string, data, userId: string, p2: number, stillHere)
	local v12

	if data.config.period then
		local period = data.config.period
		v12 = TimeService.getWeekKey(period.timezoneOffsetSeconds, period.resetHour, period.resetWeekday)
	else
		v12 = nil
	end

	local orderedDataStore

	if v12 then
		local storeName = getStoreName(data.config, v12) -- equivalent call inferred; original call site unknown
		orderedDataStore = DataStoreService:GetOrderedDataStore(storeName)
	else
		orderedDataStore = data.store
	end

	local v13

	if v12 then
		v13 = userId .. ":" .. tostring(v12)
	else
		v13 = userId
	end

	local pendingWrite = data.pendingWrites[v13]

	if pendingWrite then
		task.cancel(pendingWrite)
	end

	data.pendingWrites[v13] = task.delay(1, function()
		data.pendingWrites[v13] = nil

		if v12 or not stillHere or stillHere() then
			writeValue(p, data, userId, p2, orderedDataStore)
		end
	end)
end

local function incrementValue(p: string, p2, p3: string, delta: number)
	for i = 1, 3 do
		local success, result = pcall(function()
			return p2.store:IncrementAsync(p3, delta)
		end)

		if success then
			if typeof(result) == "number" then
				-- equivalent call inferred; original call site unknown
				if canReachTopList(p2, result) then
					refresh(p, p2)
				end
			end

			break
		elseif i < 3 then
			task.wait(i)
		else
			warn(string.format("[Leaderboard] 计数器写入 '%s' 失败（%s）: %s", p, p3, (tostring(result))))
		end
	end
end

local function scheduleIncrement(p: string, p2, p3: string, delta: number)
	local pendingIncrement = p2.pendingIncrements[p3]

	if pendingIncrement then
		pendingIncrement.delta += delta
		return
	end

	local v12 = {
		delta = delta
	}
	p2.pendingIncrements[p3] = v12
	task.delay(1, function()
		p2.pendingIncrements[p3] = nil
		incrementValue(p, p2, p3, v12.delta)
	end)
end

local function rotateToNewPeriod(p: string, p2, periodKey: number)
	p2.periodKey = periodKey
	local storeName = getStoreName(p2.config, periodKey) -- equivalent call inferred; original call site unknown
	p2.store = DataStoreService:GetOrderedDataStore(storeName)
	p2.entries = {}
	hideChampionRig(p2) -- equivalent call inferred; original call site unknown
	publishSnapshot(p, p2) -- equivalent call inferred; original call site unknown
	task.spawn(refresh, p, p2)
end

local function runPeriodLoop(p: string, p2)
	local period = p2.config.period

	while true do
		local periodKey = getPeriodKey(period) -- equivalent call inferred; original call site unknown

		if p2.periodKey ~= periodKey then
			rotateToNewPeriod(p, p2, periodKey)
		end

		renderTitleLabel(p2)
		task.wait(1)
	end
end

local function ensureRemotes()
	local leaderboardSnapshot = engine:FindFirstChild("LeaderboardSnapshot")

	if leaderboardSnapshot and leaderboardSnapshot:IsA("RemoteEvent") then
		v10 = leaderboardSnapshot
	else
		v10 = Instance.new("RemoteEvent")
		v10.Name = "LeaderboardSnapshot"
		v10.Parent = engine
	end

	local leaderboardGetSnapshot = engine:FindFirstChild("LeaderboardGetSnapshot")

	if leaderboardGetSnapshot and leaderboardGetSnapshot:IsA("RemoteFunction") then
		v11 = leaderboardGetSnapshot
	else
		v11 = Instance.new("RemoteFunction")
		v11.Name = "LeaderboardGetSnapshot"
		v11.Parent = engine
	end

	v11.OnServerInvoke = function(_, p: string)
		local v12 = v[p]

		if v12 then
			return v12.entries
		end

		return {}
	end
end

local Leaderboard = {}

function Leaderboard.RegisterServer(items)
	assert(RunService:IsServer(), "Leaderboard.RegisterServer 只能由服务器调用")
	ensureRemotes()

	for k, item in pairs(items) do
		assert(v[k] == nil, string.format("排行榜 '%s' 已注册", k))
		local kind = item.kind or "player"

		if kind == "player" then
			assert(
				item.getValue and item.connectValueChanged,
				string.format("排行榜 '%s' 是 kind=player，必须提供 getValue/connectValueChanged", k)
			)
		end

		local periodKey

		if item.period then
			local period = item.period
			periodKey = TimeService.getWeekKey(period.timezoneOffsetSeconds, period.resetHour, period.resetWeekday)
		end

		local model

		if kind == "player" and item.model then
			model = item.model:FindFirstChild("冠军模型")
		end

		local storeName = getStoreName(item, periodKey) -- equivalent call inferred; original call site unknown
		local v13 = {
			config = item,
			store = DataStoreService:GetOrderedDataStore(storeName),
			periodKey = periodKey,
			listSize = 50,
			entries = {},
			pendingWrites = {},
			pendingIncrements = {},
			connections = {},
			refreshing = false,
			refreshDirty = false,
			rig = 0,
			rigOriginalParent = nil
		}

		if not (model and model:IsA("Model")) then
			model = nil
		end

		v13.rig = model
		v[k] = v13
		renderTitleLabel(v13)
		task.spawn(refresh, k, v13)

		if item.period then
			task.spawn(runPeriodLoop, k, v13)
		end

		if kind ~= "player" then
			continue
		end

		local getValue = item.getValue
		local connectValueChanged = item.connectValueChanged
		local v16 = k
		local v17 = v13

		local function bindPlayer(player)
			task.spawn(function()
				local function stillHere()
					return player.Parent == Players
				end

				local v19 = connectValueChanged(player, function(p: number)
					scheduleWrite(v16, v17, tostring(player.UserId), p, stillHere)
				end)
				v17.connections[player] = v19
				scheduleWrite(v16, v17, tostring(player.UserId), getValue(player), stillHere)

				if v10 then
					v10:FireClient(player, v16, v17.entries)
				end
			end)
		end

		Players.PlayerAdded:Connect(bindPlayer)
		local v19 = v13
		local v20 = k
		local v21 = getValue
		Players.PlayerRemoving:Connect(function(player)
			local userId = tostring(player.UserId)
			local pendingWrite = v19.pendingWrites[userId]

			if pendingWrite then
				task.cancel(pendingWrite)
				v19.pendingWrites[userId] = nil
				writeValue(v20, v19, userId, v21(player))
			end

			local connection = v19.connections[player]

			if connection then
				connection()
				v19.connections[player] = nil
			end
		end)

		for _, v22 in ipairs(Players:GetPlayers()) do
			local v23 = v22
			local v24 = connectValueChanged
			local v25 = k
			local v26 = v13
			local v27 = getValue
			task.spawn(function()
				local function stillHere()
					return v23.Parent == Players
				end

				local v28 = v24(v23, function(p: number)
					scheduleWrite(v25, v26, tostring(v23.UserId), p, stillHere)
				end)
				v26.connections[v23] = v28
				scheduleWrite(v25, v26, tostring(v23.UserId), v27(v23), stillHere)

				if v10 then
					v10:FireClient(v23, v25, v26.entries)
				end
			end)
		end
	end
end

function Leaderboard.Increment(p: string, p2: string, delta: number)
	assert(RunService:IsServer(), "Leaderboard.Increment 只能由服务器调用")
	local v12 = v[p]

	if not v12 then
		warn(string.format("[Leaderboard] Increment 目标榜单 '%s' 未注册", p))
		return
	end

	assert(
		(v12.config.kind or "player") == "item",
		string.format("[Leaderboard] '%s' 不是 kind=item 的计数器型榜单，不能用 Increment", p)
	)
	scheduleIncrement(p, v12, p2, delta)
end

function Leaderboard.RegisterClient(items)
	assert(RunService:IsClient(), "Leaderboard.RegisterClient 只能由客户端调用")
	local leaderboardSnapshot = engine:WaitForChild("LeaderboardSnapshot")
	local leaderboardGetSnapshot = engine:WaitForChild("LeaderboardGetSnapshot")

	local function resolvePanel(p: string)
		local v12 = v7[p]

		if v12 and v12.Parent then
			return v12
		end

		local item = items[p]

		if not (item and item.model) then
			return nil
		end

		local v13 = item.model:WaitForChild("看板界面"):WaitForChild("主界面"):WaitForChild("玩家列表"):WaitForChild("我的排名")
		v13.Visible = false
		v7[p] = v13
		return v13
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function renderMyPanel(p: string)
		task.spawn(function()
			local item = items[p]

			if not item then
				return
			end

			local panel = resolvePanel(p)

			if not panel then
				return
			end

			if not (v5[p] and v6[p]) then
				panel.Visible = false
				return
			end

			local v12 = v4[p] or string.format("%d+", 50)
			item.renderRow(panel, {
				rank = tonumber(v12) or 50 + 1,
				key = tostring(Players.LocalPlayer.UserId),
				value = v3[p] or 0,
				displayName = Players.LocalPlayer.Name,
				emoji = emojis[p]
			})
			panel.Visible = true
		end)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function renderBoard(p: string, p2)
		local item = items[p]

		if item and item.model then
			renderBoardRows(item.model, p2, item.renderRow)
		end
	end

	local function refreshMyRank(p: string)
		local v12 = string.format("%d+", 50)
		local emoji = nil

		for i, v14 in ipairs(v2[p] or {}) do
			if v14.key ~= tostring(Players.LocalPlayer.UserId) then
				continue
			end

			v12 = tostring(i)
			emoji = v14.emoji
			break
		end

		v4[p] = v12
		emojis[p] = emoji
		v6[p] = true
		renderMyPanel(p) -- equivalent call inferred; original call site unknown
		notifyClient(p)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function setClientValue(p: string, result: number)
		if items[p] then
			v3[p] = math.max(0, result)
			v5[p] = true
			renderMyPanel(p) -- equivalent call inferred; original call site unknown
			notifyClient(p)
		end
	end

	leaderboardSnapshot.OnClientEvent:Connect(function(p: string, p2)
		local item = items[p]

		if not item then
			return
		end

		v2[p] = p2
		renderBoard(p, p2) -- equivalent call inferred; original call site unknown

		if (item.kind or "player") == "player" then
			refreshMyRank(p)
		else
			notifyClient(p)
		end
	end)

	for k, item in pairs(items) do
		v2[k] = {}

		if (item.kind or "player") ~= "player" then
			continue
		end

		assert(item.getValue, string.format("排行榜 '%s' 是 kind=player，必须提供 getValue", k))
		v4[k] = string.format("%d+", 50)
		v5[k] = false
		v6[k] = false
		local v12 = k
		task.spawn(function()
			local item2 = items[v12]

			if not item2 then
				return
			end

			local panel = resolvePanel(v12)

			if not panel then
				return
			end

			if not (v5[v12] and v6[v12]) then
				panel.Visible = false
				return
			end

			local v13 = v4[v12] or string.format("%d+", 50)
			item2.renderRow(panel, {
				rank = tonumber(v13) or 50 + 1,
				key = tostring(Players.LocalPlayer.UserId),
				value = v3[v12] or 0,
				displayName = Players.LocalPlayer.Name,
				emoji = emojis[v12]
			})
			panel.Visible = true
		end)
		local getValue = item.getValue
		local v14 = k
		task.spawn(function()
			local success, result = pcall(getValue)

			if success and typeof(result) == "number" then
				setClientValue(v14, result) -- equivalent call inferred; original call site unknown
			end
		end)
	end

	for k in pairs(items) do
		local v12 = k
		task.spawn(function()
			local success, result = pcall(function()
				return leaderboardGetSnapshot:InvokeServer(v12)
			end)

			if success and typeof(result) == "table" then
				v2[v12] = result
				renderBoard(v12, result) -- equivalent call inferred; original call site unknown

				if (items[v12].kind or "player") == "player" then
					refreshMyRank(v12)
				end
			end
		end)
	end

	return {
		setClientValue = setClientValue
	}
end

function Leaderboard.GetEntries(p: string)
	local v12 = v[p]

	if v12 then
		return v12.entries
	end

	return v2[p] or {}
end

function Leaderboard.GetMyStanding(p: string)
	assert(RunService:IsClient(), "Leaderboard.GetMyStanding 只能由客户端调用")

	if v5[p] and v6[p] then
		return {
			rank = v4[p] or string.format("%d+", 50),
			value = v3[p] or 0
		}
	end

	return nil
end

function Leaderboard.OnChanged(p: string, callback)
	assert(RunService:IsClient(), "Leaderboard.OnChanged 只能由客户端调用")
	local v12 = v9[p]

	if not v12 then
		v12 = {}
		v9[p] = v12
	end

	local v13 = {
		callback = callback
	}
	v12[v13] = true
	return function()
		local v14 = v9[p]

		if v14 then
			v14[v13] = nil
		end
	end
end

return Leaderboard