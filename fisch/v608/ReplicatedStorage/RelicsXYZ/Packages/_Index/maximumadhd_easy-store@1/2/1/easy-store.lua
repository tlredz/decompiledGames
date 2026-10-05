local class = {}
class.__index = class
local class2 = {}
class2.__index = class2
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local parent = script.Parent
local Trove = require(parent.Trove)
local Signal = require(parent.Signal)
local UserId = require(parent.UserId)
local Network = require(parent.Network)
local Promise = require(parent.Promise)
local DeltaTable = require(parent.DeltaTable)
local RunContext = require(parent.RunContext)

-- equivalent calls inferred from this helper; original call sites unknown
local function getProfileKey(p: number)
	return (`{p}`)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function free(p)
	if p._maid then
		p._maid:Clean()
	end
end

local reconcileTable

reconcileTable = function(p, items)
	for k, item in pairs(items) do
		if type(k) ~= "string" then
			continue
		end

		if p[k] == nil then
			if type(item) == "table" then
				p[k] = DeltaTable.DeepCopy(item)
			else
				p[k] = item
			end
		elseif type(p[k]) == "table" and type(item) == "table" then
			reconcileTable(p[k], item)
		end
	end
end

function class2:Save(flag: boolean?)
	return Promise.new(function(callback, callback2)
		if not self.IsLoaded then
			callback2("PlayerData not loaded!")
			return
		end

		if not (RunContext.IsServer or RunContext.IsEdit) then
			callback2("PlayerData.Save can only be called on the server")
			return
		end

		local owner = self.Owner

		if self.IsMock and not self._server._allowMockSave then
			callback2((`Not saving mock PlayerData for userId {owner}`))
		elseif self:IsActive() or flag then
			self._server:GetDataStore():UpdateAsync(`{owner}`, function(_)
				return self.CurrentData
			end)
			callback()
		else
			callback2("PlayerData is read-only!")
		end
	end)
end

function class:Get(playerByUserId)
	if RunContext.IsClient or RunContext.IsEdit then
		playerByUserId = nil
	elseif type(playerByUserId) == "number" then
		playerByUserId = Players:GetPlayerByUserId(playerByUserId)
	end

	local default = self.Default
	local owner, isMock = UserId.Get(playerByUserId)
	local v3

	if isMock then
		v3 = UserId.Get(playerByUserId, true)
	else
		v3 = owner
	end

	if RunContext.IsServer or RunContext.IsEdit then
		local localPlayer

		if RunContext.IsEdit then
			localPlayer = Players.LocalPlayer
		elseif RunContext.IsServer then
			localPlayer = Players:GetPlayerByUserId(v3)
		end

		local _dataCache

		if localPlayer then
			_dataCache = self._dataCache
		else
			_dataCache = self._viewCache
		end

		if _dataCache[owner] then
			return _dataCache[owner]
		end

		local profileKey = getProfileKey(owner) -- equivalent call inferred; original call site unknown
		local maid = Trove.new()
		local object2 = setmetatable({
			CurrentData = DeltaTable.DeepCopy(default),
			_server = self,
			HasPendingChanges = false,
			IsLoaded = false,
			Owner = owner,
			IsMock = isMock,
			Player = localPlayer,
			Updated = Signal.new(),
			Loaded = Signal.new(),
			_maid = maid
		}, class2)
		task.spawn(function()
			local dataStore = self:GetDataStore()

			for i = 1, 5 do
				local v4, copy = xpcall(function()
					return (dataStore:GetAsync(profileKey))
				end, function(p)
					warn("!! Error while loading profile for player", owner, p, debug.traceback())
				end)

				if v4 then
					if copy == nil then
						copy = DeltaTable.DeepCopy(default)
					end

					if copy.RobloxMetaData ~= nil and not rawget(default, "RobloxMetaData") then
						copy = copy.Data
					end

					if copy then
						reconcileTable(copy, default)
						object2.CurrentData = copy
						object2.IsLoaded = true
						object2.Loaded:Fire(true)
						break
					end
				elseif i < 5 then
					task.wait(i / 2)
				end
			end

			local thread = task.spawn(function()
				while task.wait(self._autoSaveInterval) do
					if object2:IsActive() and object2.HasPendingChanges then
						object2:Save():andThen(function()
							object2.HasPendingChanges = false
						end):catch(function(p)
							warn("Failed to autosave profile for player", owner, p)
						end)
					end
				end
			end)
			maid:Add(function()
				task.cancel(thread)
			end)
		end)
		maid:Add(function()
			if owner and _dataCache[owner] then
				_dataCache[owner] = nil
			end

			object2.IsLoaded = false
			object2.Loaded:DisconnectAll()
			object2.Updated:DisconnectAll()
		end)
		_dataCache[owner] = object2
		return _dataCache[owner]
	else
		local v4 = self._dataCache[owner]
		local localPlayer = Players.LocalPlayer or nil

		if not v4 then
			v4 = setmetatable({
				CurrentData = DeltaTable.DeepCopy(default),
				_server = self,
				HasPendingChanges = false,
				Updated = Signal.new(),
				Owner = owner,
				IsMock = isMock,
				Player = localPlayer,
				IsLoaded = false,
				Loaded = Signal.new(),
				_maid = Trove.new()
			}, class2)
			self._dataCache[owner] = v4
		end

		return v4
	end
end

function class:Load(p: number?)
	local v = self:Get(p)
	return Promise.new(function(callback, callback2)
		if v.IsLoaded then
			task.defer(callback, v)
		else
			v.Loaded:Once(function()
				if v.IsLoaded then
					task.defer(callback, v)
				elseif callback2 then
					warn("DataStore:Load failed for player", p)
					callback2(v)
				end
			end)
		end
	end)
end

function class2:Patch(callback)
	return Promise.new(function(callback2, callback3)
		if not (RunContext.IsServer or RunContext.IsEdit) then
			callback3("PlayerData.Patch can only be called on the server")
			return
		end

		if not self.IsLoaded then
			callback3("PlayerData not loaded!")
			return
		end

		local copy = DeltaTable.DeepCopy(self.CurrentData)
		callback(copy)
		local v, v2 = DeltaTable.Create(self.CurrentData, copy)
		local server = self._server._netPatch:Server()

		if v2 > 0 then
			if self.Player then
				server:Fire(self.Player, v)
			end

			DeltaTable.Apply(self.CurrentData, v, function(list, p)
				self.Updated:Fire({
					Path = table.concat(list, "/"),
					Value = p
				})
			end)
			self.HasPendingChanges = true
		end

		callback2()
	end)
end

function class:Read(p: number?)
	if p == nil or p > 0 then
		local v = self:Get(p)

		if v.IsLoaded then
			return v.CurrentData
		end
	end

	return nil
end

function class:PromiseRead(p: number?)
	return Promise.new(function(callback, callback2)
		local v = self:Get(p)

		if v.IsLoaded then
			callback(v.CurrentData)
		else
			v.Loaded:Once(function()
				if v.IsLoaded then
					callback(v.CurrentData)
				else
					callback2("PlayerData not loaded!")
				end
			end)
		end
	end)
end

function class2:Connect(value: string, callback)
	local v = string.lower(value)
	local updatedConnection = self.Updated:Connect(function(p2)
		if p2.Path:lower() == v then
			callback(p2.Value)
		end
	end)
	self._maid:Add(updatedConnection)
	return updatedConnection
end

function class2:IsActive()
	local owner = self.Owner
	return not self.IsMock and (Players:GetPlayerByUserId(owner) ~= nil or RunContext.IsEdit)
end

function class2.GetOwner(p)
	if RunContext.IsEdit then
		return Players.LocalPlayer
	end

	local owner = p.Owner

	if owner then
		return Players:GetPlayerByUserId(owner)
	end

	return nil
end

function class2:Release(flag: boolean?)
	if self:IsActive() then
		local player = self.Player

		if player and player:IsDescendantOf(game) then
			if flag then
				player:Kick("Your game session was deactivated. Please rejoin!")
			else
				warn("Cannot release active profile for player", player.UserId)
				return false
			end
		end
	end

	free(self) -- equivalent call inferred; original call site unknown
	return true
end

function class:GetDataStore()
	if RunContext.IsServer or RunContext.IsEdit then
		return assert(self._dataStoreService):GetDataStore(self._dataStoreName)
	end

	error("DataStore is not available on the client!")
end

function class:Start()
	if self._maid then
		return self._maid
	end

	local maid = Trove.new()
	self._maid = maid

	if RunContext.IsServer then
		local server = self._netInit:Server()

		-- equivalent calls inferred from this helper; original call sites unknown
		local function sendInit(p)
			class.Load(self, p.UserId):andThen(function(p2)
				server:Fire(p, (DeltaTable.DeepCopy(p2.CurrentData)))
			end)
		end

		self._netRequest:Server():On(function(p)
			sendInit(p) -- equivalent call inferred; original call site unknown
		end)

		local function onPlayerAdded(p)
			sendInit(p) -- equivalent call inferred; original call site unknown
		end

		local function onPlayerRemoving(p)
			local v = UserId.Get(p)
			local v2 = self._dataCache[v]

			if v2 then
				v2:Save():catch(function(p2)
					if p2 ~= "PlayerData is read-only!" and p2 ~= "PlayerData not loaded!" then
						warn(debug.traceback(p2))
					end
				end)
				free(v2) -- equivalent call inferred; original call site unknown
			end
		end

		maid:Connect(Players.PlayerAdded, onPlayerAdded)
		maid:Connect(Players.PlayerRemoving, onPlayerRemoving)

		for _, v in Players:GetPlayers() do
			local v2 = v
			class.Load(self, v.UserId):andThen(function(p)
				server:Fire(v2, (DeltaTable.DeepCopy(p.CurrentData)))
			end)
		end

		local flag = false
		maid:Add(function()
			flag = true
		end)
		game:BindToClose(function()
			if flag then
				return
			end

			local v = {}

			for _, v2 in pairs(self._dataCache) do
				local v3 = v2
				table.insert(v, (v2:Save(true):andThen(function()
					free(v3) -- equivalent call inferred; original call site unknown
				end)))
			end

			Promise.all(v):expect()
		end)
		return maid
	else
		local client = self._netInit:Client()
		local client2 = self._netPatch:Client()
		local client3 = self._netRequest:Client()
		local v = self:Get()
		client:On(function(currentData)
			v.CurrentData = currentData
			v.Loaded:FireDeferred(true)
			v.IsLoaded = true
		end)
		client2:On(function(p)
			local v2 = self:Get()
			DeltaTable.Apply(v2.CurrentData, p, function(list, p2)
				v2.Updated:FireDeferred({
					Path = table.concat(list, "/"),
					Value = p2
				})
			end)
		end)
		task.spawn(function()
			local count = 0

			while not v.IsLoaded and count < 20 do
				count += 1
				client3:Fire()
				task.wait(0.5)
			end
		end)
		return maid
	end
end

local function create(dataStoreName: string, default, data)
	local mockDataStoreService = data and data.MockDataStoreService or DataStoreService
	local v = {
		Default = default,
		_dataCache = {},
		_viewCache = {},
		_netInit = Network.ReliableEvent(`DataStore_{dataStoreName}_DataInit`, function(p2)
			assert(type(p2) == "table")
			return p2
		end),
		_netPatch = Network.ReliableEvent(`DataStore_{dataStoreName}_DataPatch`, function(p2)
			assert(type(p2) == "table")
			return p2
		end),
		_netRequest = Network.ReliableEvent((`DataStore_{dataStoreName}_DataRequest`)),
		_allowMockSave = 0,
		_dataStoreName = 0,
		_dataStoreService = 0,
		_autoSaveInterval = 0
	}
	local allowMockSave

	if data then
		allowMockSave = data.AllowMockSave or false
	else
		allowMockSave = false
	end

	v._allowMockSave = allowMockSave
	v._dataStoreName = dataStoreName
	v._dataStoreService = mockDataStoreService
	v._autoSaveInterval = data and data.AutoSaveInterval or 15
	return (setmetatable(v, class))
end

return table.freeze({
	Create = create
})