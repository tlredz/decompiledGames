local MemoryStoreService = game:GetService("MemoryStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")
local Replion = require(ReplicatedStorage.packages.Replion)
local Signal = require(ReplicatedStorage.packages.Signal)
require(script.Parent.Types)
local Environments = require(script.Parent.Environments)
local Overrides = require(script.Parent.Overrides)
local random = Random.new()
local v = nil
local server = nil
local FFlags = {
	_loaded = false,
	_loadedSignal = Signal.new(),
	_updatedSignal = Signal.new()
}

local function waitForBudget(p, value: number?)
	local now = os.clock()
	local now2 = now
	local v2 = value or 10

	while DataStoreService:GetRequestBudgetForRequestType(p) < 1 and now2 - now < v2 do
		task.wait()
		now2 = os.clock()
	end

	return now2 - now < v2
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

	local v2 = server:Get({ "Values", p })

	if v2 == nil then
		return p2
	end

	return v2
end

function FFlags.GetInstant(_, p, p2)
	local v2 = server:Get({ "Values", p })

	if v2 == nil then
		return p2
	end

	return v2
end

function FFlags:Set(p, p2, p3)
	if p3 == v or p3 == "all" or p3 == "local" then
		server:Set({ "Values", p }, p2)
		server:Set("LastChange", workspace:GetServerTimeNow())
	end

	if p3 == "local" then
		if not Overrides[v] then
			Overrides[v] = {}
		end

		Overrides[v][p] = p2
		return true
	else
		local function transformData(p4)
			local unixTimestamp = DateTime.now().UnixTimestamp
			local v2 = (not p4 or typeof(p4) ~= "table" or typeof(p4.Values) ~= "table") and {
				Values = {},
				LastUpdate = unixTimestamp
			} or p4
			local v3 = false

			for _, list in v2.Values do
				local v4 = list[1]
				local v5 = list[3]

				if not (p == v4 and p3 == v5) then
					continue
				end

				v3 = true
				list[2] = p2

				if p3 == nil then
					table.remove(list, 3)
				else
					list[3] = p3
				end
			end

			if not v3 then
				local v4 = { p, p2 }

				if p3 ~= nil then
					table.insert(v4, p3)
				end

				table.insert(v2.Values, v4)
			end

			v2.LastUpdate = DateTime.now().UnixTimestamp
			return v2
		end

		for i = 1, 5 do
			local v2 = i
			local success, result = pcall(function()
				return MemoryStoreService:GetHashMap((`FFlags-{v2}`))
			end)

			if success then
				local v3 = result
				local success2, result2 = pcall(function()
					return v3:UpdateAsync("FFlags", transformData, 3888000)
				end)

				if not success2 then
					warn((`Failed to update HashMap FFlags-{i}/FFlags: {result2}`))
				end
			else
				warn((`Failed to save HashMap FFlags-{i}/FFlags: {result}`))
			end
		end

		for i = 1, 3 do
			local v2 = i
			local success, result = pcall(function()
				return DataStoreService:GetDataStore((`FFlags-{v2}`))
			end)

			if success then
				if not waitForBudget(Enum.DataStoreRequestType.UpdateAsync, 30) then
					warn("No DataStore:UpdateAsync() request budget available")
					return false
				end

				local v3 = result
				local success2, result2 = pcall(function()
					return v3:UpdateAsync("FFlags", transformData)
				end)

				if not success2 then
					warn((`Failed to update DataStore FFlags-{i}/FFlags: {result2}`))
				end
			else
				warn((`Failed to save DataStore FFlags-{i}/FFlags: {result}`))
			end
		end

		return true
	end
end

function FFlags:_loadMemoryStore(p)
	local v2 = p or random:NextInteger(1, 5)
	local success, result = pcall(function()
		return MemoryStoreService:GetHashMap((`FFlags-{v2}`))
	end)

	if not success then
		warn((`MemoryStoreService:GetHashMap() failed on 'FFlags-{v2}': {result}`))
		return false
	end

	local success2, result2 = pcall(function()
		return result:GetAsync("FFlags")
	end)

	if not success2 then
		warn((`Failed to load HashMap FFlags-{v2}/FFlags: {result2}`))
		return false
	end

	if typeof(result2) ~= "table" or typeof(result2.Values) ~= "table" then
		local _ = {
			Values = {},
			LastUpdate = 0
		}
		return false
	end

	local unixTimestamp = DateTime.now().UnixTimestamp
	local v3

	if typeof(result2.LastUpdate) == "number" then
		v3 = result2.LastUpdate
	else
		v3 = unixTimestamp
	end

	local _ = unixTimestamp - v3 >= 2592000
	return true, result2
end

function FFlags:_loadDataStore(p)
	local v2 = p or random:NextInteger(1, 3)
	local success, result = pcall(function()
		return DataStoreService:GetDataStore((`FFlags-{v2}`))
	end)

	if not success then
		warn((`DataStoreService:GetDataStore() failed on 'FFlags-{v2}': {result}`))
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

	if success2 then
		return true, (typeof(result2) ~= "table" or typeof(result2.Values) ~= "table") and {
			Values = {},
			LastUpdate = 0
		} or result2
	end

	warn((`Failed to load DataStore FFlags-{v2}/FFlags: {result2}`))
	return false
end

function FFlags:Load()
	local v2, v3

	if RunService:IsStudio() then
		v2, v3 = self:_loadDataStore()
	else
		v2, v3 = self:_loadMemoryStore()
	end

	if not v2 then
		local count = 0

		while count < 3 and not v2 do
			count += 1
			task.wait(count * 1)
			v2, v3 = self:_loadMemoryStore()
		end

		if not v2 then
			warn("All attempts to load FFlags MemoryStore HashMaps failed, loading DataStore instead")
			v2, v3 = self:_loadDataStore()
		end
	end

	if not (v2 and v3) then
		warn("Failed to load FFlags: both MemoryStore and DataStore requests failed!")
		return false
	end

	local values = {}

	for _, value in v3.Values do
		local v5 = value[1]
		local v6 = value[2]
		local v7 = value[3] or "all"

		if v5 and (v7 ~= "all" or not values[v5]) and (v7 == v or v7 == "all") then
			values[v5] = v6
		end
	end

	for k, _ in server.Data.Values do
		if values[k] == nil then
			values[k] = Replion.None
		end
	end

	if Overrides[v] then
		for k, v5 in Overrides[v] do
			values[k] = v5
		end
	end

	local serverTimeNow = workspace:GetServerTimeNow()
	server:Update({
		Loaded = true,
		LastUpdate = serverTimeNow,
		LastChange = serverTimeNow,
		Values = values
	})

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

			v = studioEnvironment
			break
		elseif not environment.UniverseIds or #environment.UniverseIds == 0 and not v then
			v = studioEnvironment
		end
	end

	if not v then
		warn((`Failed to find matching Environment for UniverseId {game.GameId}`))
		return
	end

	local v2 = 0

	while true do
		local serverTimeNow = workspace:GetServerTimeNow()

		if v2 < serverTimeNow then
			v2 = serverTimeNow + 300 * random:NextNumber(0.7, 1.3)
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