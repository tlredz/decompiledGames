local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Enclave = require(script:FindFirstAncestor("Enclave"))
local isServer = RunService:IsServer()
local isClient = RunService:IsClient()
local v = {}
local parent = nil
local v3 = nil
local class = {}
class.__index = class

function class.new(name: string)
	local object = setmetatable({}, class)
	object._name = name
	object._callbackProcessTimes = {}
	object._callbackArgCache = {}
	object._event = nil
	object._unreliableEvent = nil
	object._function = nil
	v[name] = object

	if not isServer then
		return object
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function registerPlayerArgs(p)
		object._callbackArgCache[p] = {}
		object._callbackProcessTimes[p] = {}
	end

	Players.PlayerAdded:Connect(registerPlayerArgs)

	for _, v4 in pairs(Players:GetPlayers()) do
		registerPlayerArgs(v4) -- equivalent call inferred; original call site unknown
	end

	Players.PlayerRemoving:Connect(function(player)
		object._callbackArgCache[player] = nil
		object._callbackProcessTimes[player] = nil
	end)
	return object
end

function class:_getEventServer()
	if not self._event then
		self._event = Instance.new("RemoteEvent")
		self._event.Name = self._name .. "Event"
		self._event.Parent = parent
	end

	return self._event
end

function class:_getUnreliableEventServer()
	if not self._unreliableEvent then
		self._unreliableEvent = Instance.new("UnreliableRemoteEvent")
		self._unreliableEvent.Name = self._name .. "UnreliableEvent"
		self._unreliableEvent.Parent = parent
	end

	return self._unreliableEvent
end

function class:_getEventClient()
	if not self._event then
		if not game:IsLoaded() then
			game.Loaded:Wait()
		end

		self._event = parent:FindFirstChild(self._name .. "Event")

		if not self._event then
			self._event = v3:InvokeServer(self._name, "Event")
		end
	end

	if not self._event then
		error((`Client failed to get remote '{self._name}', check that it is being created on the server.`))
	end

	return self._event
end

function class:_getUnreliableEventClient()
	if self._unreliableEvent then
		return self._unreliableEvent
	end

	if not game:IsLoaded() then
		game.Loaded:Wait()
	end

	self._unreliableEvent = parent:FindFirstChild(self._name .. "UnreliableEvent")

	if not self._unreliableEvent then
		self._unreliableEvent = v3:InvokeServer(self._name, "UnreliableEvent")
	end

	return self._unreliableEvent
end

function class:_getFunctionServer()
	if not self._function then
		self._function = Instance.new("RemoteFunction")
		self._function.Name = self._name .. "Function"
		self._function.Parent = parent
	end

	return self._function
end

function class:_getFunctionClient()
	if self._function then
		return self._function
	end

	if not game:IsLoaded() then
		game.Loaded:Wait()
	end

	self._function = parent:FindFirstChild(self._name .. "Function")

	if not self._function then
		self._function = v3:InvokeServer(self._name, "Function")
	end

	return self._function
end

function class:_connectRateLimitedCallback(object, callback, value: number)
	if typeof(value) == "number" then
		return object:Connect(function(...)
			local v4 = { ... }
			local v5 = v4[1]
			local nowsByCallback = isServer and self._callbackProcessTimes[v5] or self._callbackProcessTimes
			local v6 = isServer and self._callbackArgCache[v5] or self._callbackArgCache
			local v7 = nowsByCallback[callback] or 0
			local v8 = os.clock() - v7

			if value <= v8 then
				nowsByCallback[callback] = os.clock()
				callback(...)
			else
				local v9 = v6[callback] == nil
				v6[callback] = v4

				if v9 then
					task.delay(value - v8, function()
						local v10 = v6[callback]

						if v10 then
							nowsByCallback[callback] = os.clock()
							v6[callback] = nil
							callback(table.unpack(v10))
						end
					end)
				end
			end
		end)
	end

	warn("Invalid rate limit interval provided to OnUnreliableEvent for remote " .. self._name .. " - expected number, got " .. typeof(value) .. "\n" .. debug.traceback())
	return object:Connect(callback)
end

function class:OnEvent(callback, p: number?)
	task.spawn(function()
		local onServerEvent

		if isServer then
			onServerEvent = self:_getEventServer().OnServerEvent
		else
			onServerEvent = self:_getEventClient().OnClientEvent
		end

		if p then
			return (self:_connectRateLimitedCallback(onServerEvent, callback, p))
		end

		return (onServerEvent:Connect(callback))
	end)
end

class.OnServerEvent = class.OnEvent
class.OnClientEvent = class.OnEvent

function class:OnUnreliableEvent(callback, p: number?)
	task.spawn(function()
		local onServerEvent

		if isServer then
			onServerEvent = self:_getUnreliableEventServer().OnServerEvent
		else
			onServerEvent = self:_getUnreliableEventClient().OnClientEvent
		end

		if p then
			return (self:_connectRateLimitedCallback(onServerEvent, p, callback))
		end

		return (onServerEvent:Connect(callback))
	end)
end

class.OnServerUnreliableEvent = class.OnUnreliableEvent
class.OnClientUnreliableEvent = class.OnUnreliableEvent

function class:FireClient(player, ...)
	assert(isServer, "FireClient can only be called on the server")
	self:_getEventServer():FireClient(player, ...)
end

function class:FireClientUnreliable(player, ...)
	assert(isServer, "FireClientUnreliable can only be called on the server")
	self:_getUnreliableEventServer():FireClient(player, ...)
end

class.FireClientFast = class.FireClientUnreliable

function class:FireClientList(items, ...)
	if typeof(items) ~= "table" then
		warn((`Attempt to fire Remote to non-table list ({items})\n{debug.traceback()}`))
		return
	end

	for _, player in pairs(items) do
		if player:IsA("Player") then
			self:FireClient(player, ...)
		else
			warn((`Attempt to fire Remote to non-Player in list ({player})\n{debug.traceback()}`))
		end
	end
end

function class:FireClientListUnreliable(items, ...)
	if typeof(items) ~= "table" then
		warn((`Attempt to fire Remote to non-table list ({items})\n{debug.traceback()}`))
		return
	end

	for _, player in pairs(items) do
		if player:IsA("Player") then
			self:FireClientUnreliable(player, ...)
		else
			warn((`Attempt to fire Remote to non-Player in list ({player})\n{debug.traceback()}`))
		end
	end
end

class.FireClientListFast = class.FireClientListUnreliable

function class:FireAllClients(...)
	assert(isServer, "FireAllClients can only be called on the server")
	self:_getEventServer():FireAllClients(...)
end

function class:FireAllClientsUnreliable(...)
	assert(isServer, "FireAllClientsUnreliable can only be called on the server")
	self:_getUnreliableEventServer():FireAllClients(...)
end

class.FireAllClientsFast = class.FireAllClientsUnreliable

function class:FireAllExcept(player, ...)
	if typeof(player) ~= "Instance" or not player:IsA("Player") then
		warn((`Attempt to exclude non-Player from FireAllExcept ({player})\n{debug.traceback()}`))
		return
	end

	local v4 = { player }

	for _, player2 in pairs(Players:GetPlayers()) do
		if not table.find(v4, player2) then
			self:FireClient(player2, ...)
		end
	end
end

class.FireAllClientsExcept = class.FireAllExcept

function class:FireAllExceptUnreliable(player, ...)
	if typeof(player) ~= "Instance" or not player:IsA("Player") then
		warn((`Attempt to exclude non-Player from FireAllExcept ({player})\n{debug.traceback()}`))
		return
	end

	local v4 = { player }

	for _, v5 in pairs(Players:GetPlayers()) do
		if not table.find(v4, v5) then
			self:FireClientUnreliable(v5, ...)
		end
	end
end

class.FireAllExceptFast = class.FireAllExceptUnreliable
class.FireAllClientsExceptUnreliable = class.FireAllExceptUnreliable
class.FireAllClientsExceptFast = class.FireAllExceptUnreliable

function class:FireServer(...)
	assert(isClient, "FireServer can only be called on the client")
	self:_getEventClient():FireServer(...)
end

function class:FireServerUnreliable(...)
	assert(isClient, "FireServerUnreliable can only be called on the client")
	self:_getUnreliableEventClient():FireServer(...)
end

class.FireServerFast = class.FireServerUnreliable

function class:Fire(...)
	if isServer then
		self:_getEventServer():FireAllClients(...)
	else
		self:_getEventClient():FireServer(...)
	end
end

function class:FireUnreliable(...)
	if isServer then
		self:_getUnreliableEventServer():FireAllClients(...)
	else
		self:_getUnreliableEventClient():FireServer(...)
	end
end

class.FireFast = class.FireUnreliable

function class:InvokeClient(player, ...)
	assert(isServer, "InvokeClient can only be called on the server")
	return self:_getFunctionServer():InvokeClient(player, ...)
end

function class:InvokeServer(...)
	assert(isClient, "InvokeServer can only be called on the client")
	return self:_getFunctionClient():InvokeServer(...)
end

function class:Invoke(...)
	if not isServer then
		return self:_getFunctionClient():InvokeServer(...)
	end

	local v4 = { ... }
	local v5 = table.remove(v4, 1)
	return self:_getFunctionServer():InvokeClient(v5, table.unpack(v4))
end

function class:OnInvoke(callback)
	task.spawn(function()
		if isServer then
			local _getFunctionServer = self:_getFunctionServer()
			_getFunctionServer.OnServerInvoke = callback
		else
			local _getFunctionClient = self:_getFunctionClient()
			_getFunctionClient.OnClientInvoke = callback
		end
	end)
end

class.OnServerInvoke = class.OnInvoke
class.OnClientInvoke = class.OnInvoke

if not RunService:IsRunning() then
	return function(p)
		return class.new("Mock" .. p)
	end
end

if isServer then
	return function(value: string)
		assert(type(value) == "string", "Invalid name '" .. tostring(value) .. "' - remote name must be a string")

		if not parent then
			parent = Instance.new("Folder")
			parent.Name = "Remotes"
			parent.Archivable = false
			parent.Parent = Enclave.Assets
			v3 = Instance.new("RemoteFunction")
			v3.Name = "Request"
			v3.Parent = parent

			v3.OnServerInvoke = function(_, p, p2)
				local v4 = v[p]

				if v4 then
					if p2 == "Event" then
						return v4:_getEventServer()
					elseif p2 == "UnreliableEvent" then
						return v4:_getUnreliableEventServer()
					elseif p2 == "Function" then
						return v4:_getFunctionServer()
					end
				end
			end
		end

		if v[value] then
			return v[value]
		end

		return class.new(value)
	end
end

return function(value: string)
	assert(type(value) == "string", "Invalid name '" .. tostring(value) .. "' - remote name must be a string")

	if not parent then
		parent = Enclave.Assets:WaitForChild("Remotes")
	end

	if not v3 then
		v3 = parent:WaitForChild("Request")
	end

	return class.new(value)
end