local MemoryStoreService = game:GetService("MemoryStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local MessagingService = game:GetService("MessagingService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Replion = require(ReplicatedStorage.Packages.Replion)
local Signal = require(ReplicatedStorage.Packages.Signal)
require(script.Parent.Types)
local Environments = require(script.Parent.Environments)
local Overrides = require(script.Parent.Overrides)
local v = game.GameId == 7709344486 and not RunService:IsStudio() and 100 or 2
local v2 = game.GameId == 7709344486 and not RunService:IsStudio() and 25 or 2
local random = Random.new()
local v3 = 0
local serverTimeNow = 0
local v4 = nil
local server = nil
local FFlags = {
	_loaded = false,
	_loadedSignal = Signal.new(),
	_updatedSignal = Signal.new()
}

local function waitForBudget(getAsync, value: number?)
	local now = os.clock()
	local now2 = now
	local v5 = value or 10

	while DataStoreService:GetRequestBudgetForRequestType(getAsync) < 1 and now2 - now < v5 do
		task.wait()
		now2 = os.clock()
	end

	return now2 - now < v5
end

local v5 = {
	301,
	302,
	303,
	304,
	305,
	306,
	500,
	501,
	502,
	503,
	504,
	505
}

local function dsRetry(callback)
	local v6 = nil

	for i = 1, 6 do
		local v7 = table.pack(pcall(callback))

		if v7[1] then
			return table.unpack(v7, 2, v7.n)
		end

		v6 = v7[2]
		local v8 = tonumber(string.match(v6, "^(%d+)"))

		if v8 and table.find(v5, v8) then
			task.wait(2 ^ (i - 1))
		else
			error(v6)
		end
	end

	if v6 then
		error((`Too many retries.\n{v6}`))
	end
end

local v6 = {
	"TotalRequestsOverLimit",
	"InternalError",
	"RequestThrottled",
	"PartitionRequestsOverLimit",
	"Throttled",
	"Timeout"
}

local function hashMapRetry(callback)
	local v7 = nil

	for i = 1, 6 do
		local v8 = table.pack(pcall(callback))

		if v8[1] then
			return table.unpack(v8, 2, v8.n)
		end

		v7 = tostring(v8[2])
		local flag = false

		for _, v10 in v6 do
			if not string.find(v7, v10, 1, true) then
				continue
			end

			flag = true
			break
		end

		if flag then
			task.wait(2 ^ (i - 1))
		else
			error(v7)
		end
	end

	if v7 then
		error((`Too many retries.\n{v7}`))
	end
end

local deepEquals

deepEquals = function(items, items2)
	if items == items2 then
		return true
	end

	if type(items) ~= "table" or type(items2) ~= "table" then
		return false
	end

	for k, item in items do
		if not deepEquals(item, items2[k]) then
			return false
		end
	end

	for k in items2 do
		if items[k] == nil then
			return false
		end
	end

	return true
end

local function valuesEqual(values, items)
	for k, item in items do
		if item == Replion.None then
			item = nil
		end

		if not deepEquals(values[k], item) then
			return false
		end
	end

	for k in values do
		if items[k] == nil then
			return false
		end
	end

	return true
end

function FFlags:IsLoaded()
	return self._loaded
end

function FFlags:OnLoad(on_loadedSignal)
	return self._loadedSignal:Connect(on_loadedSignal)
end

function FFlags:OnUpdate(on_updatedSignal)
	return self._updatedSignal:Connect(on_updatedSignal)
end

function FFlags:OnChange(p, p2)
	return server:OnChange({ "Values", p }, p2)
end

function FFlags:Get(p, p2)
	if not self:IsLoaded() then
		self._loadedSignal:Wait()
	end

	local v7 = server:Get({ "Values", p })

	if v7 == nil then
		return p2
	end

	return v7
end

function FFlags:GetInstant(p, p2)
	local v7 = server:Get({ "Values", p })

	if v7 == nil then
		return p2
	end

	return v7
end

function FFlags:Set(p, p2, environment, callback)
	if callback then
		p2 = callback(self:GetInstant(p))
	end

	if environment == v4 or environment == "all" or environment == "local" then
		server:Set({ "Values", p }, p2)
		server:Set("LastChange", workspace:GetServerTimeNow())
	end

	if environment == "local" then
		if not Overrides[v4] then
			Overrides[v4] = {}
		end

		Overrides[v4][p] = p2
		return true
	else
		serverTimeNow = workspace:GetServerTimeNow()

		if not self:GetInstant("FFlagUpdateMessageDisabled", false) then
			local success, result = pcall(function()
				return MessagingService:PublishAsync("FFlagUpdate", {
					Key = p,
					Value = p2,
					Environment = environment
				})
			end)

			if not success then
				warn((`Failed to send message for FFlag update: {result}`))
			end
		end

		local function transformData(p4)
			local unixTimestamp = DateTime.now().UnixTimestamp
			local v7 = (not p4 or typeof(p4) ~= "table" or typeof(p4.Values) ~= "table") and {
				Values = {},
				LastUpdate = unixTimestamp
			} or p4
			local v8 = nil

			for k, value in v7.Values do
				local v10 = value[1]
				local v11 = value[3]

				if not (p == v10 and environment == v11) then
					continue
				end

				v8 = k
				break
			end

			local v10

			if v8 then
				v10 = v7.Values[v8][2]
			end

			local v11

			if callback then
				v11 = callback(v10)
			else
				v11 = p2
			end

			if v11 == nil then
				if v8 then
					table.remove(v7.Values, v8)
				end

				v7.LastUpdate = unixTimestamp
			else
				if v8 then
					local value = v7.Values[v8]
					value[2] = v11

					if environment == nil then
						table.remove(value, 3)
					else
						value[3] = environment
					end
				else
					local v12 = { p, v11 }

					if environment ~= nil then
						table.insert(v12, environment)
					end

					table.insert(v7.Values, v12)
				end

				v7.LastUpdate = DateTime.now().UnixTimestamp
			end

			return v7
		end

		local v7 = {}
		local v8 = 0
		local thread = coroutine.running()
		local v9 = false

		-- equivalent calls inferred from this helper; original call sites unknown
		local function resetQueue()
			v9 = false
			table.clear(v7)
			v8 = 0
		end

		local runNext

		runNext = function()
			while v8 < 10 and #v7 > 0 do
				local v10 = assert(table.remove(v7, 1))
				v8 += 1
				task.spawn(function()
					local success, result = pcall(v10)
					v8 -= 1

					if not success then
						warn("Queue task failed:", result)
					end

					runNext()

					if #v7 == 0 and v8 == 0 then
						v9 = true

						if coroutine.status(thread) == "suspended" then
							task.spawn(thread)
						end
					end
				end)
			end
		end

		local function queueUpdateThread(p4)
			table.insert(v7, p4)
			runNext()
		end

		for i = 1, v do
			local v10 = i
			table.insert(v7, function()
				local success, result = pcall(hashMapRetry, function()
					return MemoryStoreService:GetHashMap((`FFlags-{v10}`)):UpdateAsync("FFlags", transformData, 3888000)
				end)

				if not success then
					warn((`Failed to update HashMap FFlags-{v10}/FFlags: {result}`))
				end
			end)
			runNext()
		end

		if not v9 then
			coroutine.yield()
		end

		resetQueue() -- equivalent call inferred; original call site unknown

		for i = 1, v2 do
			local v10 = i
			table.insert(v7, function()
				local success, result = pcall(dsRetry, function()
					return DataStoreService:GetDataStore((`FFlags-{v10}`)):UpdateAsync("FFlags", transformData)
				end)

				if not success then
					warn((`Failed to update DataStore FFlags-{v10}/FFlags: {result}`))
				end
			end)
			runNext()
		end

		if not v9 then
			coroutine.yield()
		end

		return true
	end
end

function FFlags:_loadMemoryStore(p)
	local v7 = p or random:NextInteger(1, v)
	local success, result = pcall(function()
		return MemoryStoreService:GetHashMap((`FFlags-{v7}`))
	end)

	if not success then
		warn((`MemoryStoreService:GetHashMap() failed on 'FFlags-{v7}': {result}`))
		return false
	end

	local success2, result2 = pcall(function()
		return result:GetAsync("FFlags")
	end)

	if not success2 then
		warn((`Failed to load HashMap FFlags-{v7}/FFlags: {result2}`))
		return false
	end

	if typeof(result2) == "table" and typeof(result2.Values) == "table" then
		local unixTimestamp = DateTime.now().UnixTimestamp
		local v8

		if typeof(result2.LastUpdate) == "number" then
			v8 = result2.LastUpdate
		else
			v8 = unixTimestamp
		end

		local _ = unixTimestamp - v8 >= 2592000
		return true, result2
	else
		warn((`Invalid data format in HashMap FFlags-{v7}/FFlags: {result2}`))
		local _ = {
			Values = {},
			LastUpdate = 0
		}
		return false
	end
end

function FFlags:_loadDataStore(p)
	local v7 = p or random:NextInteger(1, v2)
	local success, result = pcall(function()
		return DataStoreService:GetDataStore((`FFlags-{v7}`))
	end)

	if not success then
		warn((`DataStoreService:GetDataStore() failed on 'FFlags-{v7}': {result}`))
		return false
	end

	local dataStoreGetOptions = Instance.new("DataStoreGetOptions")
	dataStoreGetOptions.UseCache = false

	if not waitForBudget(Enum.DataStoreRequestType.GetAsync) then
		warn("No DataStore:GetAsync() request budget available")
		return false
	end

	local success2, result2 = pcall(function()
		return result:GetAsync("FFlags", dataStoreGetOptions)
	end)

	if not success2 then
		warn((`Failed to load DataStore FFlags-{v7}/FFlags: {result2}`))
		return false
	end

	if typeof(result2) ~= "table" or typeof(result2.Values) ~= "table" then
		warn((`Invalid data format in DataStore FFlags-{v7}/FFlags: {result2}`))
		result2 = {
			Values = {},
			LastUpdate = 0
		}
	end

	return true, result2
end

function FFlags:Load()
	local v7, v8

	if RunService:IsStudio() then
		v7, v8 = self:_loadDataStore()
	else
		v7, v8 = self:_loadMemoryStore()
	end

	if not v7 then
		local count = 0

		while count < 3 and not v7 do
			warn((`Failed to load FFlags {RunService:IsStudio() and "DataStore" or "MemoryStore HashMap"}, retrying...`))
			count += 1
			task.wait(count * 1)
			v7, v8 = self:_loadMemoryStore()
		end

		if not v7 then
			warn("All attempts to load FFlags MemoryStore HashMaps failed, loading DataStore instead")
			v7, v8 = self:_loadDataStore()
		end
	end

	if not (v7 and v8) then
		warn("Failed to load FFlags: both MemoryStore and DataStore requests failed!")
		return false
	end

	local v9 = typeof(v8.LastUpdate) ~= "number" and 0 or v8.LastUpdate

	if self._loaded and (v9 < v3 or v9 < serverTimeNow - 30) then
		warn((`Skipping stale FFlags shard (LastUpdate {v9}, newest known {math.max(v3, serverTimeNow)})`))
		return false
	end

	v3 = math.max(v3, v9)
	local values = {}

	for _, value in v8.Values do
		local v11 = value[1]
		local v12 = value[2]
		local v13 = value[3] or "all"

		if v11 and (v13 ~= "all" or not values[v11]) and (v13 == v4 or v13 == "all") then
			values[v11] = v12
		end
	end

	for k, _ in server.Data.Values do
		if values[k] == nil then
			values[k] = Replion.None
		end
	end

	if Overrides[v4] then
		for k, v11 in Overrides[v4] do
			values[k] = v11
		end
	end

	local serverTimeNow2 = workspace:GetServerTimeNow()
	local v11 = server
	local v12 = {
		Loaded = true,
		LastUpdate = serverTimeNow2,
		LastChange = 0,
		Values = 0
	}

	if valuesEqual(server.Data.Values, values) then
		serverTimeNow2 = server.Data.LastChange
	end

	v12.LastChange = serverTimeNow2
	v12.Values = values
	v11:Update(v12)

	if not self._loaded then
		self._loaded = true
		self._loadedSignal:Fire(server.Data)
	end

	self._updatedSignal:Fire(server.Data)
	return true
end

function FFlags:Start()
	for studioEnvironment, environment in Environments do
		if environment.UniverseIds and table.find(environment.UniverseIds, game.GameId) then
			if RunService:IsStudio() and environment.StudioEnvironment then
				studioEnvironment = environment.StudioEnvironment
			end

			v4 = studioEnvironment
			break
		elseif not environment.UniverseIds or #environment.UniverseIds == 0 and not v4 then
			v4 = studioEnvironment
		end
	end

	if not v4 then
		warn((`Failed to find matching Environment for UniverseId {game.GameId}`))
		return
	end

	task.spawn(function()
		MessagingService:SubscribeAsync("FFlagUpdate", function(json)
			if typeof(json) == "string" then
				local success, result = pcall(function()
					json = HttpService:JSONDecode(json)
				end)

				if not success then
					warn((`Failed to JSONDecode FFlagUpdate message data {json}: {result}`))
					return
				end
			end

			local data = json.Data

			if typeof(data) ~= "table" or not data.Key then
				warn((`Invalid FFlagUpdate message data {json}`))
				return
			end

			print(`FFlag update received - updating: {data.Key} to`, data.Value, (`({typeof(data.Value)})`))

			if data.Key and (data.Environment == nil or data.Environment == v4 or data.Environment == "all") then
				server:Set({ "Values", data.Key }, data.Value)
				server:Set("LastChange", workspace:GetServerTimeNow())
				serverTimeNow = workspace:GetServerTimeNow()
				self._updatedSignal:Fire(server.Data)
			end
		end)
	end)
	local v7 = 0

	while true do
		local serverTimeNow2 = workspace:GetServerTimeNow()

		if v7 < serverTimeNow2 then
			v7 = serverTimeNow2 + 600 * random:NextNumber(0.7, 1.3)
			self:Load()
		end

		task.wait(1)
	end
end

server = Replion.Server.new({
	Channel = "FFlags",
	ReplicateTo = "All",
	Data = {
		Values = {},
		Loaded = false,
		LastUpdate = 0,
		LastChange = 0
	}
})
task.spawn(FFlags.Start, FFlags)
return FFlags