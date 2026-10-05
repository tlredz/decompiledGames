local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local remo = require(ReplicatedStorage.Packages.remo)
require(ReplicatedStorage.Utilities.Promise)
local Signal = require(ReplicatedStorage.Utilities.Signal)
local Config = require(ReplicatedStorage:WaitForChild("Config"))
local GlobalStateManager = require(ReplicatedStorage._FRAMEWORK.Features.GlobalStateManager)
local v = {
	player = true,
	server = true,
	global = true
}
local v2 = {
	XP = true,
	Wins = true
}
local v3 = {
	Default = "0",
	ServerBoost = "1",
	AdminAbuse = "2",
	EventBoost = "3",
	LuckyMinute = "4",
	ChocolateHunt = "5",
	EventRsvp = "6",
	CC = "7"
}
local v4 = { 1, 2 }
local v5 = {}
local v6 = {}
local v7 = {}
local v8 = false
local flag = false
local remotes = remo.createRemotes({
	BonusUpdate = remo.remote()
})
local changed = Signal.new()
local BonusManager = {
	Changed = changed
}

local function assertScope(p: string)
	assert(v[p] == true, "[BonusManager] Invalid scope: " .. tostring(p))
	return p
end

local function assertBonusType(p: string)
	assert(v2[p] == true, "[BonusManager] Invalid bonus type: " .. tostring(p))
	return p
end

local function assertBoostKind(p: string?)
	if p == nil then
		return "Default"
	end

	assert(v3[p] ~= nil, "[BonusManager] Invalid boost kind: " .. tostring(p))
	return p
end

local function assertPositiveNumber(value: number, p: string)
	local v10

	if type(value) == "number" then
		v10 = value >= 1
	else
		v10 = false
	end

	assert(v10, "[BonusManager] " .. p .. " must be a number >= 1")
	return value
end

local function isEventWorld()
	return Config.GetEventDataKey() ~= nil
end

local function isAdminPanelBonusExcludedPlace()
	return Config.GetEventDataKey() ~= nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getGlobalStateKey(p: number)
	return (`GlobalBonuses_Galaxy{p}_State`)
end

local function getTargetGalaxyIndexes(p: number?)
	if p then
		return { p }
	end

	return v4
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getBoostKindFromStoredKind(k: string)
	for k2, v10 in v3 do
		if v10 == k then
			return k2
		end
	end

	return nil
end

local function assertGlobalStatesReady(items)
	for _, item in items do
		assert(
			GlobalStateManager.isReadyToMutate((`GlobalBonuses_Galaxy{item}_State`)),
			"[BonusManager] Global bonus state is still loading"
		)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getNow()
	if RunService:IsClient() then
		return (workspace:GetServerTimeNow())
	end

	return (os.time())
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getRemainingTime(endTime: number?)
	if type(endTime) ~= "number" then
		return 0
	end

	local now = getNow() -- equivalent call inferred; original call site unknown
	return (math.max(0, endTime - now))
end

local function isActive(p)
	if p == nil then
		return false
	else
		local remainingTime = getRemainingTime(p.endTime) -- equivalent call inferred; original call site unknown
		return remainingTime > 0
	end
end

local function getKindMap(p, p2: string, flag2: boolean)
	if p[p2] == nil and flag2 then
		p[p2] = {}
	end

	return p[p2]
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setBonus(p, p2: string, p3: string, p4)
	if p[p3] == nil then
		p[p3] = {}
	end

	local v10 = p[p3]
	assert(v10 ~= nil, "[BonusManager] Failed to create bonus kind map")
	v10[p2] = p4
end

local function getBonus(p, p2: string, p3: string)
	local v10 = p and p[p3]

	if v10 then
		return v10[p2]
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function removeBonus(items, p: string, p2: string?)
	if p2 then
		local item = items[p2]

		if not item then
			return
		end

		item[p] = nil

		if next(item) == nil then
			items[p2] = nil
		end
	else
		for k, item in pairs(items) do
			item[p] = nil

			if next(item) == nil then
				items[k] = nil
			end
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function convertEndTimeToServerClock(p: number)
	return workspace:GetServerTimeNow() + (p - os.time())
end

local function copyForClient(items)
	local v10 = {}

	if items == nil then
		return v10
	end

	for k, item in pairs(items) do
		for k2, v11 in pairs(item) do
			local v12

			if v11 == nil then
				v12 = false
			else
				local remainingTime = getRemainingTime(v11.endTime) -- equivalent call inferred; original call site unknown
				v12 = remainingTime > 0
			end

			if not v12 then
				continue
			end

			local v13 = {
				mult = v11.mult,
				endTime = 0
			}
			local endTime

			if RunService:IsServer() then
				endTime = convertEndTimeToServerClock(v11.endTime)
			else
				endTime = v11.endTime
			end

			v13.endTime = endTime
			setBonus(v10, k2, k, v13) -- equivalent call inferred; original call site unknown
		end
	end

	return v10
end

local function copyActiveMap(items)
	local v10 = {}

	if items == nil then
		return v10
	end

	for k, item in pairs(items) do
		for k2, v11 in pairs(item) do
			local v12

			if v11 == nil then
				v12 = false
			else
				local remainingTime = getRemainingTime(v11.endTime) -- equivalent call inferred; original call site unknown
				v12 = remainingTime > 0
			end

			if not v12 then
				continue
			end

			setBonus(v10, k2, k, {
				mult = v11.mult,
				endTime = v11.endTime
			}) -- equivalent call inferred; original call site unknown
		end
	end

	return v10
end

local function replaceMap(items, items2)
	for k in pairs(items) do
		items[k] = nil
	end

	if items2 == nil then
		return
	end

	for k, item in pairs(items2) do
		for k2, v10 in pairs(item) do
			setBonus(items, k2, k, {
				mult = v10.mult,
				endTime = v10.endTime
			}) -- equivalent call inferred; original call site unknown
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function buildClientData(p)
	return {
		serverBonuses = copyForClient(v6),
		globalBonuses = copyForClient(v7),
		playerBonuses = copyForClient(v5[p.UserId])
	}
end

local function applyClientData(data)
	replaceMap(v6, data.serverBonuses)
	replaceMap(v7, data.globalBonuses)

	for k in pairs(v5) do
		v5[k] = nil
	end

	local localPlayer = Players.LocalPlayer

	if localPlayer then
		v5[localPlayer.UserId] = {}
		replaceMap(v5[localPlayer.UserId], data.playerBonuses)
	end
end

local function getBestEntryForKind(p: number, p2: string, k: string)
	local v10 = nil

	-- equivalent calls inferred from this helper; original call sites unknown
	local function check(p3)
		if not p3 then
			return
		end

		local v11

		if p3 == nil then
			v11 = false
		else
			local remainingTime = getRemainingTime(p3.endTime) -- equivalent call inferred; original call site unknown
			v11 = remainingTime > 0
		end

		if v11 and (v10 == nil or p3.mult > v10.mult or p3.mult == v10.mult and p3.endTime > v10.endTime) then
			v10 = p3
		end
	end

	local v11 = v5[p]
	local v12 = v11 and v11[k]
	local v13

	if v12 then
		v13 = v12[p2]
	end

	check(v13) -- equivalent call inferred; original call site unknown
	local v15 = v6 and v6[k]
	local v16

	if v15 then
		v16 = v15[p2]
	end

	check(v16) -- equivalent call inferred; original call site unknown
	local v18 = v7 and v7[k]
	local v19

	if v18 then
		v19 = v18[p2]
	end

	check(v19) -- equivalent call inferred; original call site unknown
	return v10
end

local function getCombinedMultiplier(userId: number, p: string)
	local v10 = 1
	local v11 = 1e999
	local result = {}

	for k in v3 do
		local bestEntryForKind = getBestEntryForKind(userId, p, k)

		if not (bestEntryForKind and bestEntryForKind.mult > 1) then
			continue
		end

		v10 *= bestEntryForKind.mult
		v11 = math.min(v11, bestEntryForKind.endTime)
		table.insert(result, {
			kind = k,
			mult = bestEntryForKind.mult,
			endTime = bestEntryForKind.endTime
		})
	end

	if v10 <= 1 then
		return 1, 0, {}
	end

	table.sort(result, function(a, b)
		return v3[a.kind] < v3[b.kind]
	end)
	return v10, v11, result
end

-- equivalent calls inferred from this helper; original call sites unknown
local function sendToPlayer(p)
	remotes.BonusUpdate:fire(p, buildClientData(p))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function broadcastToAll()
	for _, v10 in ipairs(Players:GetPlayers()) do
		sendToPlayer(v10) -- equivalent call inferred; original call site unknown
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function scheduleExpirationNotify(p: number, p2)
	local v10 = math.max(1, p - os.time() + 1)
	task.delay(v10, function()
		if p2 then
			if p2.Parent then
				sendToPlayer(p2) -- equivalent call inferred; original call site unknown
			end
		else
			broadcastToAll() -- equivalent call inferred; original call site unknown
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function observeGlobalMutation(p: string, globalStateKey: string, object)
	object:catch(function(p2)
		warn(string.format("[BonusManager] Failed to %s for %s: %s", p, globalStateKey, (tostring(p2))))
	end)
end

local function updateGlobalBonus(p: string, p2: string, p3: number, p4: number, p5: number, flag2: boolean?)
	local globalStateKey = getGlobalStateKey(p5) -- equivalent call inferred; original call site unknown
	local v10, v11 = GlobalStateManager.updateState(globalStateKey, function(items)
		local result = {}

		if items then
			for k, item in items do
				-- equivalent call inferred; original call site unknown
				if getBoostKindFromStoredKind(k) then
					result[k] = table.clone(item)
				end
			end
		end

		local v12 = v3[p2]
		local v13 = result[v12]

		if not v13 then
			v13 = {}
			result[v12] = v13
		end

		v13[p] = { p3, p4, flag2 == true or nil }
		return result
	end)
	observeGlobalMutation("broadcast update", globalStateKey, v10) -- equivalent call inferred; original call site unknown
	observeGlobalMutation("persist update", globalStateKey, v11) -- equivalent call inferred; original call site unknown
end

local function removeGlobalBonus(p: string, p2: string?, p3: number)
	local globalStateKey = getGlobalStateKey(p3) -- equivalent call inferred; original call site unknown
	local v10, v11 = GlobalStateManager.updateState(globalStateKey, function(items)
		local clones = {}

		if not items then
			return clones
		end

		for k, item in items do
			local boostKindFromStoredKind = getBoostKindFromStoredKind(k) -- equivalent call inferred; original call site unknown

			if boostKindFromStoredKind and (p2 == nil or boostKindFromStoredKind == p2) then
				local clone = table.clone(item)
				clone[p] = nil

				if next(clone) ~= nil then
					clones[v3[boostKindFromStoredKind]] = clone
				end
			elseif boostKindFromStoredKind then
				clones[v3[boostKindFromStoredKind]] = table.clone(item)
			end
		end

		return clones
	end)
	observeGlobalMutation("broadcast removal", globalStateKey, v10) -- equivalent call inferred; original call site unknown
	observeGlobalMutation("persist removal", globalStateKey, v11) -- equivalent call inferred; original call site unknown
end

local function applyStoredGlobalState(p: number, items)
	if p ~= Config.GALAXY_INDEX then
		return
	end

	local v10 = {}

	for k, item in items do
		local boostKindFromStoredKind = getBoostKindFromStoredKind(k) -- equivalent call inferred; original call site unknown

		if not boostKindFromStoredKind then
			continue
		end

		for k2, v11 in item do
			local mult = v11[1]
			local endTime = v11[2]
			local v14 = v11[3]

			if not (v2[k2] == true and type(mult) == "number" and type(endTime) == "number" and os.time() < endTime) then
				continue
			end

			if not (v14 ~= true or Config.GetEventDataKey() == nil) then
				continue
			end

			setBonus(v10, k2, boostKindFromStoredKind, {
				mult = mult,
				endTime = endTime
			}) -- equivalent call inferred; original call site unknown
			local v16 = math.max(1, endTime - os.time() + 1)
			local v18 = nil
			task.delay(v16, function()
				if v18 then
					if v18.Parent then
						sendToPlayer(v18) -- equivalent call inferred; original call site unknown
					end
				else
					broadcastToAll() -- equivalent call inferred; original call site unknown
				end
			end)
		end
	end

	replaceMap(v7, v10)
	v8 = true
	broadcastToAll() -- equivalent call inferred; original call site unknown
end

local function activateBonus(p: string, p2: string, mult: number, p4: number, p5, p6: string, p7)
	local v10

	if p7 == nil then
		v10 = false
	else
		v10 = p7.excludeEventWorlds == true
	end

	local galaxyIndex

	if p7 then
		galaxyIndex = p7.galaxyIndex
	end

	local v11 = galaxyIndex == nil or galaxyIndex == Config.GALAXY_INDEX
	local v12 = v10 and Config.GetEventDataKey() ~= nil

	if not v12 then
		if p == "global" then
			v12 = not v11
		else
			v12 = false
		end
	end

	local v13 = galaxyIndex and { galaxyIndex } or v4

	if p == "global" then
		assertGlobalStatesReady(v13)
	end

	local endTime = os.time() + p4

	if not v12 then
		local v15

		if p == "player" then
			assert(p5 ~= nil, "[BonusManager] Player bonus requires a target player")
			local userId = p5.UserId
			v5[userId] = v5[userId] or {}
			v15 = v5[userId]
		elseif p == "server" then
			v15 = v6
		else
			v15 = v7
		end

		local v16 = v15 and v15[p6]
		local v17

		if v16 then
			v17 = v16[p2]
		end

		if v17 then
			local v18

			if v17 == nil then
				v18 = false
			else
				local remainingTime = getRemainingTime(v17.endTime) -- equivalent call inferred; original call site unknown
				v18 = remainingTime > 0
			end

			if v18 and v17.mult == mult then
				endTime = v17.endTime + p4
			end
		end

		setBonus(v15, p2, p6, {
			mult = mult,
			endTime = endTime
		}) -- equivalent call inferred; original call site unknown
	end

	if p == "global" then
		for _, v15 in v13 do
			updateGlobalBonus(p2, p6, mult, endTime, v15, v10)
		end
	end

	if not v12 then
		if p5 then
			sendToPlayer(p5) -- equivalent call inferred; original call site unknown
		else
			broadcastToAll() -- equivalent call inferred; original call site unknown
		end

		scheduleExpirationNotify(endTime, p5) -- equivalent call inferred; original call site unknown
	end
end

local function stopGlobalBonus(p: string, p2: string?)
	assertGlobalStatesReady(v4)

	if p2 then
		removeBonus(v7, p, p2)

		for _, v10 in v4 do
			removeGlobalBonus(p, p2, v10)
		end
	else
		removeBonus(v7, p) -- equivalent call inferred; original call site unknown

		for _, v11 in v4 do
			removeGlobalBonus(p, nil, v11)
		end
	end
end

local function clearExpiredBonuses()
	local now = os.time()

	local function clearMap(items)
		for k, item in pairs(items) do
			for k2, v10 in pairs(item) do
				if v10.endTime <= now then
					item[k2] = nil
				end
			end

			if next(item) == nil then
				items[k] = nil
			end
		end
	end

	clearMap(v6)
	clearMap(v7)

	for k, v10 in pairs(v5) do
		clearMap(v10)

		if next(v10) == nil then
			v5[k] = nil
		end
	end
end

function BonusManager.GetXPMultiplier(_, p)
	return getCombinedMultiplier(p.UserId, "XP")
end

function BonusManager.GetWinsMultiplier(_, p)
	return getCombinedMultiplier(p.UserId, "Wins")
end

function BonusManager.GetServerBonusSource(_, p: string, kind: string?)
	assert(v2[p] == true, "[BonusManager] Invalid bonus type: " .. tostring(p))

	if kind == nil then
		kind = "Default"
	else
		assert(v3[kind] ~= nil, "[BonusManager] Invalid boost kind: " .. tostring(kind))
	end

	local v11 = v6 and v6[kind]
	local v12

	if v11 then
		v12 = v11[p]
	end

	local v13

	if v12 == nil then
		v13 = false
	else
		local remainingTime = getRemainingTime(v12.endTime) -- equivalent call inferred; original call site unknown
		v13 = remainingTime > 0
	end

	if v13 then
		return {
			kind = kind,
			mult = v12.mult,
			endTime = v12.endTime
		}
	end

	return nil
end

function BonusManager.GetActiveServerBonuses(_)
	return (copyActiveMap(v6))
end

function BonusManager.GetActiveGlobalBonuses(_)
	return (copyActiveMap(v7))
end

function BonusManager.GetActivePlayerBonuses(_, p)
	if v5[p.UserId] then
		return (copyActiveMap(v5[p.UserId]))
	end

	return {}
end

function BonusManager.GetRemainingTime(_, value)
	if type(value) == "table" then
		local endTime = value.endTime

		if type(endTime) ~= "number" then
			return 0
		end

		local now = getNow() -- equivalent call inferred; original call site unknown
		return (math.max(0, endTime - now))
	else
		if type(value) ~= "number" then
			return 0
		end

		local now = getNow() -- equivalent call inferred; original call site unknown
		return (math.max(0, value - now))
	end
end

function BonusManager.IsServerWinsBonusActive(_)
	for k in v3 do
		local v11 = v6 and v6[k]
		local wins

		if v11 then
			wins = v11.Wins
		end

		local v12

		if wins == nil then
			v12 = false
		else
			local remainingTime = getRemainingTime(wins.endTime) -- equivalent call inferred; original call site unknown
			v12 = remainingTime > 0
		end

		if v12 then
			return true
		end

		local v14 = v7 and v7[k]
		local wins2

		if v14 then
			wins2 = v14.Wins
		end

		local v15

		if wins2 == nil then
			v15 = false
		else
			local remainingTime = getRemainingTime(wins2.endTime) -- equivalent call inferred; original call site unknown
			v15 = remainingTime > 0
		end

		if not v15 then
			continue
		end

		return true
	end

	return false
end

function BonusManager.ActivateBonus(_, p: string, p2: string, mult: number, value2: number, p3, p4: string?, p5)
	assert(v[p] == true, "[BonusManager] Invalid scope: " .. tostring(p))
	assert(v2[p2] == true, "[BonusManager] Invalid bonus type: " .. tostring(p2))
	local v11

	if type(mult) == "number" then
		v11 = mult >= 1
	else
		v11 = false
	end

	assert(v11, "[BonusManager] multiplier must be a number >= 1")
	local v12

	if type(value2) == "number" then
		v12 = value2 >= 1
	else
		v12 = false
	end

	assert(v12, "[BonusManager] durationSeconds must be a number >= 1")

	if p4 == nil then
		p4 = "Default"
	else
		assert(v3[p4] ~= nil, "[BonusManager] Invalid boost kind: " .. tostring(p4))
	end

	activateBonus(p, p2, mult, value2, p3, p4, p5)
end

function BonusManager.StopBonus(_, p: string, p2: string, p3, p4: string?)
	assert(v[p] == true, "[BonusManager] Invalid scope: " .. tostring(p))
	assert(v2[p2] == true, "[BonusManager] Invalid bonus type: " .. tostring(p2))

	if p4 then
		if p4 == nil then
			p4 = "Default"
		else
			assert(v3[p4] ~= nil, "[BonusManager] Invalid boost kind: " .. tostring(p4))
		end
	else
		p4 = nil
	end

	if p == "player" then
		assert(p3 ~= nil, "[BonusManager] Player bonus requires a target player")
		local v10 = v5[p3.UserId]

		if v10 then
			removeBonus(v10, p2, p4)
		end

		sendToPlayer(p3) -- equivalent call inferred; original call site unknown
	else
		if p == "server" then
			removeBonus(v6, p2, p4)
		else
			stopGlobalBonus(p2, p4)
		end

		broadcastToAll() -- equivalent call inferred; original call site unknown
	end
end

function BonusManager.BroadcastToClients(_)
	broadcastToAll() -- equivalent call inferred; original call site unknown
end

function BonusManager.SendToPlayer(_, p)
	sendToPlayer(p) -- equivalent call inferred; original call site unknown
end

function BonusManager.Init(_)
	if flag then
		return
	end

	flag = true

	if RunService:IsClient() then
		remotes.BonusUpdate:connect(function(p)
			applyClientData(p)
			changed:Fire()
		end)
		return
	end

	for _, v10 in v4 do
		local v11 = v10
		GlobalStateManager.subscribeToState(`GlobalBonuses_Galaxy{v10}_State`, function(p)
			applyStoredGlobalState(v11, p)
		end)
	end

	task.spawn(function()
		while true do
			task.wait(300)
			clearExpiredBonuses()
		end
	end)
	Players.PlayerAdded:Connect(function(player)
		task.spawn(function()
			local total = 0

			while not v8 and total < 8 do
				task.wait(0.5)
				total += 0.5
			end

			task.wait(1)

			if player.Parent then
				sendToPlayer(player) -- equivalent call inferred; original call site unknown
			end
		end)
	end)
	Players.PlayerRemoving:Connect(function(player)
		v5[player.UserId] = nil
	end)
end

return BonusManager