local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Janitor = require(ReplicatedStorage.Utilities.Janitor)
local LoggerManager = require(ReplicatedStorage._FRAMEWORK.Libraries.LoggerManager)
local Signal = require(ReplicatedStorage.Utilities.Signal)
local BannedLeaderboardUsers = require(ReplicatedStorage._FRAMEWORK.Libraries.leaderboard.BannedLeaderboardUsers)
local logger = LoggerManager.createLogger(script.Name, {
	feature = script:GetFullName()
})
local OrderedLeaderboard = {}
OrderedLeaderboard.__index = OrderedLeaderboard

local function decodeIdentity(p: number)
	return p
end

local function encodeFloor(p: number)
	if p == p and math.abs(p) ~= 1e999 and not (p <= 0) then
		return (math.floor(p))
	end

	return 0
end

local function collectEntries(list, _decodeValue)
	local result = {}

	for _, v in ipairs(list) do
		local key = tonumber(v.key)

		if key == nil or BannedLeaderboardUsers.isBanned(key) then
			continue
		end

		table.insert(result, {
			userId = key,
			stored = v.value,
			value = _decodeValue(v.value)
		})
	end

	return result
end

local function checkSortedPage(object, flag: boolean, p: number, p2: number?, p3: number?)
	local success, result = pcall(function()
		if p2 ~= nil and p3 ~= nil then
			return object:GetSortedAsync(flag, p, p2, p3)
		end

		if p2 == nil then
			return object:GetSortedAsync(flag, p)
		end

		return object:GetSortedAsync(flag, p, p2)
	end)

	if success then
		return true, result, ""
	end

	return false, nil, string.format("GetSortedAsync failed: %s", (tostring(result)))
end

local function checkAdvance(result)
	local success, result2 = pcall(function()
		result:AdvanceToNextPageAsync()
	end)

	if success then
		return true, result:GetCurrentPage(), ""
	end

	return false, nil, string.format("AdvanceToNextPageAsync failed: %s", (tostring(result2)))
end

local function checkWrite(object, p: string, p2: number)
	local success, result = pcall(function()
		if p2 <= 0 then
			object:RemoveAsync(p)
		else
			object:SetAsync(p, p2)
		end
	end)

	if success then
		return true, ""
	end

	return false, string.format("ODS write failed: %s", (tostring(result)))
end

local function checkRemove(object, p: string)
	local success, result = pcall(function()
		object:RemoveAsync(p)
	end)

	if success then
		return true, ""
	end

	return false, string.format("ODS remove failed: %s", (tostring(result)))
end

local function applyEntries(state, entries, flag: boolean)
	if flag then
		state._entries = entries
		table.clear(state._listed)
	else
		for _, entry in ipairs(entries) do
			table.insert(state._entries, entry)
		end
	end

	for _, _entry in ipairs(state._entries) do
		state._listed[_entry.userId] = true
	end

	local _entry = state._entries[#state._entries]
	local lowestStored

	if _entry then
		lowestStored = _entry.stored
	end

	state._lowestStored = lowestStored
	state._hasListed = true
	state.entriesChanged:Fire(state._entries)
end

local function applyListedBans(object)
	for k in object._pending do
		if BannedLeaderboardUsers.isBanned(k) then
			object._pending[k] = nil
		end
	end

	task.spawn(function()
		object:requestRefresh()
	end)
end

local function shouldWrite(data, p: number, p2: number)
	if BannedLeaderboardUsers.isBanned(p) then
		return false
	end

	if data._listed[p] or not data._cutoffEnabledFor(p) then
		return true
	end

	return not not data._hasListed and (#data._entries < data._pageSize or data._lowestStored <= p2)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function jitteredInterval(p, p2: number, p3: number)
	return p2 + p._rng:NextNumber(0, p2 * p3)
end

function OrderedLeaderboard.new(data)
	local now = os.clock()
	local random = Random.new()
	local entriesChanged = Signal.new()
	local onEntriesChanged = data.onEntriesChanged
	local connection

	if onEntriesChanged then
		connection = entriesChanged:Connect(onEntriesChanged)
	end

	local refreshInterval = data.refreshInterval
	local writeInterval = data.writeInterval
	local pollStartDelayMin = data.pollStartDelayMin
	local pollStartDelayMax = data.pollStartDelayMax
	local nextRefreshAt = refreshInterval == nil and 1e999 or now + random:NextNumber(
		pollStartDelayMin,
		pollStartDelayMax
	)
	local nextWriteAt = writeInterval == nil and 1e999 or now + writeInterval + random:NextNumber(
		0,
		writeInterval * data.writeJitterFraction
	)
	local object = setmetatable({
		_alive = true,
		_store = data.store,
		_ascending = data.ascending == true,
		_pageSize = math.floor(data.initialKeyCount),
		_minValue = data.minValue,
		_maxValue = data.maxValue,
		_refreshInterval = refreshInterval,
		_refreshJitterFraction = data.refreshJitterFraction,
		_writeInterval = writeInterval,
		_writeJitterFraction = data.writeJitterFraction,
		_writeStaggerMin = data.writeStaggerMin,
		_writeStaggerMax = data.writeStaggerMax,
		_waitForPlayer = data.waitForPlayer ~= false,
		_cutoffEnabledFor = data.cutoffEnabledFor or function()
			return true
		end,
		_decodeValue = data.decodeValue or decodeIdentity,
		_encodeValue = data.encodeValue or encodeFloor,
		_rng = random,
		_nextRefreshAt = nextRefreshAt,
		_nextWriteAt = nextWriteAt,
		_pages = nil,
		_entries = {},
		_listed = {},
		_lowestStored = nil,
		_hasListed = false,
		_pending = {},
		entriesChanged = entriesChanged
	}, OrderedLeaderboard)
	local playerRemovingConnection

	if writeInterval ~= nil then
		playerRemovingConnection = Players.PlayerRemoving:Connect(function(player)
			object:flushUser(player.UserId)
		end)
	end

	if writeInterval ~= nil then
		game:BindToClose(function()
			object:flushPending()
		end)
	end

	object._janitor = Janitor.new()
	object._janitor:Add(entriesChanged, "Destroy")

	if connection then
		object._janitor:Add(connection)
	end

	if playerRemovingConnection then
		object._janitor:Add(playerRemovingConnection)
	end

	object._janitor:Add(BannedLeaderboardUsers.onChanged(function()
		applyListedBans(object)
	end))
	applyListedBans(object)
	return object
end

function OrderedLeaderboard:tick(p: number)
	if not self._alive then
		return
	end

	if self._refreshInterval ~= nil and self._nextRefreshAt <= p and (not self._waitForPlayer or #Players:GetPlayers() > 0) then
		self._nextRefreshAt = p + jitteredInterval(self, self._refreshInterval, self._refreshJitterFraction)
		task.spawn(function()
			self:refresh()
		end)
	end

	if self._writeInterval ~= nil and self._nextWriteAt <= p then
		self._nextWriteAt = p + jitteredInterval(self, self._writeInterval, self._writeJitterFraction)
		task.spawn(function()
			self:flushPending()
		end)
	end
end

function OrderedLeaderboard:requestRefresh()
	if self._alive then
		self:refresh()

		if self._refreshInterval ~= nil then
			self._nextRefreshAt = os.clock() + jitteredInterval(
				self,
				self._refreshInterval,
				self._refreshJitterFraction
			)
		end
	end
end

function OrderedLeaderboard:requestFlush()
	if self._alive then
		self:flushPending()

		if self._writeInterval ~= nil then
			self._nextWriteAt = os.clock() + jitteredInterval(self, self._writeInterval, self._writeJitterFraction)
		end
	end
end

function OrderedLeaderboard:refresh()
	local _store = self._store
	local _ascending = self._ascending
	local _pageSize = self._pageSize
	local _minValue = self._minValue
	local _maxValue = self._maxValue
	local success, result = pcall(function()
		if _minValue ~= nil and _maxValue ~= nil then
			return _store:GetSortedAsync(_ascending, _pageSize, _minValue, _maxValue)
		end

		if _minValue == nil then
			return _store:GetSortedAsync(_ascending, _pageSize)
		end

		return _store:GetSortedAsync(_ascending, _pageSize, _minValue)
	end)
	local v, v2

	if success then
		v = true
		v2 = ""
	else
		v2 = string.format("GetSortedAsync failed: %s", (tostring(result)))
		v = false
		result = nil
	end

	if not v then
		logger:warn(v2)
		return
	end

	self._pages = result
	local entries = collectEntries(result:GetCurrentPage(), self._decodeValue)

	while #entries < self._pageSize and not result.IsFinished do
		local v4, v5, v6 = checkAdvance(result)

		if not v4 then
			logger:warn(v6)
			break
		end

		for _, v7 in ipairs((collectEntries(v5, self._decodeValue))) do
			if #entries < self._pageSize then
				table.insert(entries, v7)
			end
		end
	end

	self._entries = entries
	table.clear(self._listed)

	for _, _entry in ipairs(self._entries) do
		self._listed[_entry.userId] = true
	end

	local _entry = self._entries[#self._entries]
	local lowestStored

	if _entry then
		lowestStored = _entry.stored
	end

	self._lowestStored = lowestStored
	self._hasListed = true
	self.entriesChanged:Fire(self._entries)
end

function OrderedLeaderboard:loadMore()
	self:requestRefresh()
end

function OrderedLeaderboard:queueWrite(p2: number, p3: number)
	if BannedLeaderboardUsers.isBanned(p2) then
		self._pending[p2] = nil
	else
		self._pending[p2] = p3
	end
end

function OrderedLeaderboard:dropUser(p2: number)
	self._pending[p2] = nil
end

function OrderedLeaderboard:removeUser(p: number)
	self:dropUser(p)
	local _store = self._store
	local v = tostring(p)
	local success, result = pcall(function()
		_store:RemoveAsync(v)
	end)
	local v2, v3

	if success then
		v2 = true
		v3 = ""
	else
		v3 = string.format("ODS remove failed: %s", (tostring(result)))
		v2 = false
	end

	task.spawn(function()
		self:requestRefresh()
	end)
	return v2, v3
end

function OrderedLeaderboard:flushUser(p: number)
	local v = self._pending[p]

	if v == nil or BannedLeaderboardUsers.isBanned(p) then
		self._pending[p] = nil
		return false
	end

	local _encodeValue = self._encodeValue(v)
	local v2

	if BannedLeaderboardUsers.isBanned(p) then
		v2 = false
	elseif self._listed[p] or not self._cutoffEnabledFor(p) then
		v2 = true
	elseif self._hasListed then
		v2 = #self._entries < self._pageSize or self._lowestStored <= _encodeValue
	else
		v2 = false
	end

	if v2 then
		local _store = self._store
		local v3 = tostring(p)
		local success, result = pcall(function()
			if _encodeValue <= 0 then
				_store:RemoveAsync(v3)
			else
				_store:SetAsync(v3, _encodeValue)
			end
		end)
		local flag, v4

		if success then
			flag = true
			v4 = ""
		else
			v4 = string.format("ODS write failed: %s", (tostring(result)))
			flag = false
		end

		if flag then
			if self._pending[p] == v then
				self._pending[p] = nil
			end
		else
			logger:warn(v4)
		end

		return true
	else
		if self._hasListed then
			self._pending[p] = nil
		end

		return false
	end
end

function OrderedLeaderboard:flushPending()
	local v = {}

	for k in self._pending do
		table.insert(v, k)
	end

	for _, v2 in ipairs(v) do
		if self:flushUser(v2) then
			task.wait(self._rng:NextNumber(self._writeStaggerMin, self._writeStaggerMax))
		end
	end
end

function OrderedLeaderboard:getEntries()
	return self._entries
end

function OrderedLeaderboard:getLowestStored()
	return self._lowestStored
end

function OrderedLeaderboard:Destroy()
	self._alive = false
	self._janitor:Cleanup()
end

return OrderedLeaderboard