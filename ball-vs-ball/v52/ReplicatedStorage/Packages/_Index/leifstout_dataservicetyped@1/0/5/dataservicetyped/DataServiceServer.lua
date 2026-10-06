local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

if RunService:IsClient() then
	return {}
end

local parent = script.Parent.Parent
local Value = require(script.Parent.Value)
require(script.Parent.DataServiceUtils)
local Signal = require(parent.Signal)
local Networker = require(parent.Networker)
local ProfileStore

if RunService:IsServer() then
	ProfileStore = require(parent.ProfileStore)
else
	ProfileStore = nil
end

local DataServiceServer = {
	_profiles = {},
	_waitSignals = {},
	_removalFunctions = {},
	_globalCallbacks = {},
	_globalCallbackAdded = Signal.new(),
	data = {},
	init = function(service, options)
		assert(RunService:IsServer(), "DataServiceServer can only be used on the server.")
		assert(not service.playerStore, "DataServiceServer has already been initialized.")
		Value.shouldRecordPath = true
		service.options = options
		service.networker = Networker.server.new("DataService", service, {})
		service.playerStore = ProfileStore.New(options.profileStoreIndex or "Default", options.template)

		for _, v in Players:GetPlayers() do
			local v2 = v
			task.spawn(function()
				service:_playerAdded(v2)
			end)
		end

		Players.PlayerAdded:Connect(function(player)
			service:_playerAdded(player)
		end)
		Players.PlayerRemoving:Connect(function(player)
			service:_playerRemoving(player)
		end)
		service.data.Service = service
		return service.data
	end
}

local function storeCancel(p)
	return {
		Cancel = function()
			return p.Parent ~= Players
		end
	}
end

function DataServiceServer:resetData(object2)
	local _getProfileKey = self:_getProfileKey(object2.UserId)
	self:_playerRemoving(object2)
	self.playerStore:RemoveAsync(_getProfileKey)
	object2:Kick("Your data has been reset. Please rejoin.")
end

function DataServiceServer:_playerAdded(instance)
	local overridenUserId = self.options.overridenUserId or self.options.viewedUserId or instance.UserId
	local _getProfileKey = self:_getProfileKey(overridenUserId)

	if self.options.resetData and not self.options.viewedUserId then
		self.playerStore:RemoveAsync(_getProfileKey)
	end

	local async

	if self.options.useMock then
		async = self.playerStore.Mock:StartSessionAsync(_getProfileKey, {
			Cancel = function()
				return instance.Parent ~= Players
			end
		})
	elseif self.options.viewedUserId or self.options.dontSave then
		async = self.playerStore:GetAsync(_getProfileKey)
	else
		async = self.playerStore:StartSessionAsync(_getProfileKey, {
			Cancel = function()
				return instance.Parent ~= Players
			end
		})
	end

	async:AddUserId(overridenUserId)
	async:Reconcile()
	async.OnSessionEnd:Connect(function()
		self._profiles[instance] = nil
		instance:Kick("Profile session end - Please rejoin")
	end)

	if not instance:IsDescendantOf(Players) then
		instance:Kick("Profile load fail - Please rejoin")
		return
	end

	self._profiles[instance] = async
	self:_initPlayer(instance, async.Data)

	if instance:IsDescendantOf(Players) then
		async:MessageHandler(function(p, callback)
			local _globalCallback = self._globalCallbacks[p.key]

			if _globalCallback then
				if _globalCallback(instance, p.data) ~= false then
					callback()
				end
			else
				local connection = nil
				connection = self._globalCallbackAdded:Connect(function(p2: string)
					if p2 ~= p.key then
						return
					end

					if self._globalCallbacks[p.key](instance, p.data) ~= false then
						callback()
					end

					connection:Disconnect()
				end)
			end
		end)
	else
		instance:Kick("Profile load fail - Please rejoin")
	end
end

function DataServiceServer:sendGlobalMessage(p: string, p2, p3)
	return self.playerStore:MessageAsync(self:_getProfileKey(p2), {
		key = p,
		data = p3
	})
end

function DataServiceServer:addGlobalCallback(p2: string, callback)
	assert(self._globalCallbacks[p2] == nil, "Global callback already exists for key: " .. p2)
	self._globalCallbacks[p2] = callback
	self._globalCallbackAdded:Fire(p2)
end

function DataServiceServer:_getProfileKey(p)
	return self:_getDataPrefix() .. tostring(p)
end

function DataServiceServer:_getDataPrefix()
	return self.options.profileStoreDataPrefix or "PLAYER_"
end

function DataServiceServer:onPlayerInit(_, _) end

function DataServiceServer:_initPlayer(p, p2)
	self:onPlayerInit(p, p2)
	self.networker:fire(p, "load", p2)
	self.data[p] = Value.new(p2, nil, nil, function(p3: string, p4, ...)
		self.networker:fire(p, p3, p4, ...)
	end)
	local _waitSignal = self._waitSignals[p]

	if _waitSignal then
		_waitSignal:Fire()
		_waitSignal:Destroy()
		self._waitSignals[p] = nil
	end
end

function DataServiceServer:_playerRemoving(p)
	local _profile = self._profiles[p]

	if not _profile then
		return
	end

	for _, callback in self._removalFunctions do
		local success, result = pcall(callback, p, _profile.Data)

		if not success then
			warn(result or "Error in removal function for " .. p.Name)
		end
	end

	_profile:EndSession()
	self._profiles[p] = nil
	local _waitSignal = self._waitSignals[p]

	if _waitSignal then
		_waitSignal:Destroy()
		self._waitSignals[p] = nil
	end

	self.data[p] = nil
end

function DataServiceServer:addPlayerRemovingCallback(callback)
	table.insert(self._removalFunctions, callback)
	return function()
		local index = table.find(self._removalFunctions, callback)

		if index then
			table.remove(self._removalFunctions, index)
		end
	end
end

function DataServiceServer:asyncGetProfile(p)
	return self.playerStore:GetAsync(self:_getProfileKey(p))
end

function DataServiceServer:getProfile(p2)
	return self._profiles[p2]
end

function DataServiceServer:waitForData(p2)
	local v = self.data[p2]

	if v then
		return v
	end

	local _waitSignal = self._waitSignals[p2]

	if not _waitSignal then
		_waitSignal = Signal.new()
		self._waitSignals[p2] = _waitSignal
	end

	_waitSignal:Wait()
	return self.data[p2]
end

return DataServiceServer