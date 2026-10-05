local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Network = require(ReplicatedStorage.SharedUtils:WaitForChild("Network"))
local FriendsLeaderboard = {}
FriendsLeaderboard.__index = FriendsLeaderboard

local function now()
	return os.clock()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getReadBudget()
	local success, result = pcall(function()
		return DataStoreService:GetRequestBudgetForRequestType(Enum.DataStoreRequestType.GetAsync)
	end)
	return success and result or 0
end

local function toUserId(value)
	if type(value) == "number" then
		return value
	end

	if type(value) == "table" then
		return (tonumber(value.Id or value.UserId or value.userId or value.id))
	end

	return (tonumber(value))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function pruneCache(items, p)
	for k, item in pairs(items) do
		if item.t < p then
			items[k] = nil
		end
	end
end

function FriendsLeaderboard:_breakerOpen()
	return os.clock() < self.BreakerUntil
end

function FriendsLeaderboard:_recordSuccess()
	self.FailStreak = 0
end

function FriendsLeaderboard:_recordFailure()
	self.FailStreak += 1

	if self.FailStreak >= 5 then
		self.BreakerUntil = os.clock() + 30
		self.FailStreak = 0
		warn(("[FriendsLeaderboard] circuit breaker tripped; pausing reads for %ds"):format(30))
	end
end

function FriendsLeaderboard:_readWithBackoff(callback)
	for i = 1, 3 do
		local success, result = pcall(callback)

		if success then
			self:_recordSuccess()
			return true, result
		end

		warn(("[FriendsLeaderboard] read attempt %d failed: %s"):format(i, (tostring(result))))
		self:_recordFailure()

		if i < 3 then
			task.wait(2 ^ (i - 1))
		end
	end

	return false, nil
end

function FriendsLeaderboard:_getFriendIds(object)
	local userId = object.UserId
	local v = self.FriendListCache[userId]

	if v and os.clock() - v.t < 300 then
		return v.ids
	end

	local success, result = pcall(function()
		return object:GetFriendsWhoPlayedAsync()
	end)

	if success and type(result) == "table" then
		local v2 = {
			[userId] = true
		}
		local ids = { userId }

		for _, id in ipairs(result) do
			if type(id) ~= "number" then
				if type(id) == "table" then
					id = tonumber(id.Id or id.UserId or id.userId or id.id)
				else
					id = tonumber(id)
				end
			end

			if not id or not (id > 0) or v2[id] then
				continue
			end

			v2[id] = true
			table.insert(ids, id)
		end

		if next(result) ~= nil and #ids == 1 then
			warn("[FriendsLeaderboard] GetFriendsWhoPlayedAsync returned a non-empty result with no usable userIds — unexpected shape?")
		end

		self.FriendListCache[userId] = {
			ids = ids,
			t = os.clock()
		}
		return ids
	else
		warn(("[FriendsLeaderboard] GetFriendsWhoPlayedAsync failed for %d: %s"):format(userId, (tostring(result))))

		if v then
			return v.ids
		end

		return { userId }
	end
end

function FriendsLeaderboard:_getScore(p)
	if Players:GetPlayerByUserId(p) then
		return self.GetOnlineScore(p)
	end

	local v = self.ScoreCache[p]

	if v and os.clock() - v.t < 300 then
		return v.value
	end

	if not (self.DataStore and not self:_breakerOpen() and not (getReadBudget() < 15)) then
		return v and v.value
	end

	local _readWithBackoff, v2 = self:_readWithBackoff(function()
		return self.DataStore:GetAsync((tostring(p)))
	end)

	if not _readWithBackoff then
		return v and v.value
	end

	self.ScoreCache[p] = {
		value = v2,
		t = os.clock()
	}
	return v2
end

function FriendsLeaderboard:_mapBounded(list, callback)
	local count = #list
	local count2 = 0
	local v = 0
	local count3 = 0
	local v2 = {}

	while count2 < count do
		while v < 12 and count3 < count do
			count3 += 1
			v += 1
			local v4 = list[count3]
			local v5 = count3
			task.spawn(function()
				local success, result = pcall(callback, v4)
				v2[v5] = success and result or nil
				v -= 1
				count2 += 1
			end)
		end

		task.wait()
	end

	return v2
end

function FriendsLeaderboard:_compute(p)
	local userId = p.UserId
	local _getFriendIds = self:_getFriendIds(p)
	local _mapBounded = self:_mapBounded(_getFriendIds, function(p2)
		return self:_getScore(p2)
	end)
	local v = {}

	for i, _getFriendId in ipairs(_getFriendIds) do
		local v2 = _mapBounded[i]

		if v2 ~= nil and v2 > 0 then
			table.insert(v, {
				UserId = _getFriendId,
				Value = v2
			})
		end
	end

	table.sort(v, function(a, b)
		return a.Value > b.Value
	end)
	local you = nil

	for i, v4 in ipairs(v) do
		if v4.UserId ~= userId then
			continue
		end

		you = {
			Rank = i,
			Value = v4.Value
		}
		break
	end

	local entries = {}

	for i = 1, math.min(10, #v) do
		entries[i] = v[i]
	end

	return {
		status = "ready",
		entries = entries,
		you = you
	}
end

function FriendsLeaderboard:_startRefresh(p, p2)
	local userId = p.UserId

	if self.InFlight[userId] then
		return
	end

	self.InFlight[userId] = true
	task.spawn(function()
		local success, result = pcall(function()
			return self:_compute(p)
		end)
		self.InFlight[userId] = nil

		if not success then
			warn(("[FriendsLeaderboard] refresh failed for %d: %s"):format(userId, (tostring(result))))
			return
		end

		self.Snapshot[userId] = {
			payload = result,
			t = os.clock()
		}

		if p and p.Parent then
			Network:Post(p, "FriendsLeaderboardUpdate", p2, result)
		end
	end)
end

function FriendsLeaderboard:Get(p, p2)
	local userId = p.UserId
	local v = self.Snapshot[userId]

	if v and os.clock() - v.t < 120 then
		return v.payload
	end

	self:_startRefresh(p, p2)

	if v then
		return v.payload
	end

	return {
		status = "computing",
		entries = {}
	}
end

function FriendsLeaderboard:Set(p, p2)
	self.ScoreCache[p] = {
		value = p2,
		t = os.clock()
	}
	self.Snapshot[p] = nil

	if not self.DataStore then
		return false
	end

	for i = 1, 3 do
		local success, result = pcall(function()
			self.DataStore:SetAsync(tostring(p), p2)
		end)

		if success then
			self:_recordSuccess()
			return true
		end

		warn(("[FriendsLeaderboard] SetAsync failed for %s (attempt %d): %s"):format(tostring(p), i, (tostring(result))))
		self:_recordFailure()

		if i < 3 then
			task.wait(2 ^ (i - 1))
		end
	end

	return false
end

function FriendsLeaderboard._janitor(data)
	while not data.Destroyed do
		task.wait(120)

		if data.Destroyed then
			break
		end

		local v = os.clock() - 600
		pruneCache(data.ScoreCache, v) -- equivalent call inferred; original call site unknown
		pruneCache(data.FriendListCache, v) -- equivalent call inferred; original call site unknown
		pruneCache(data.Snapshot, v) -- equivalent call inferred; original call site unknown
	end
end

function FriendsLeaderboard:Destroy()
	self.Destroyed = true
end

function FriendsLeaderboard.new(value: string, p)
	assert(type(value) == "string", "FriendsLeaderboard requires a string datastore key")
	assert(RunService:IsServer(), "FriendsLeaderboard is server-only")
	local self = setmetatable({}, FriendsLeaderboard)
	local success, result = pcall(function()
		return DataStoreService:GetOrderedDataStore(value)
	end)

	if not success then
		warn(("[FriendsLeaderboard] failed to open OrderedDataStore '%s': %s"):format(value, (tostring(result))))
		result = nil
	end

	self.Key = value
	self.DataStore = result
	self.GetOnlineScore = p and p.getOnlineScore or function()
		return nil
	end
	self.FriendListCache = {}
	self.ScoreCache = {}
	self.Snapshot = {}
	self.InFlight = {}
	self.FailStreak = 0
	self.BreakerUntil = 0
	self.Destroyed = false
	task.spawn(self._janitor, self)
	return self
end

return FriendsLeaderboard