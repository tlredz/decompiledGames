local parent = script.Parent
local RunContext = require(parent.RunContext)
local Players = game:GetService("Players")
local Client = require(script.Client)
local Server = require(script.Server)
require(script.Types)
local Remotes = require(script.Remotes)
local unreliable = Remotes.Unreliable
local reliable = Remotes.Reliable
local class = {}
class.__index = class

function class:Server()
	return assert(self._server, "Server events can only be accessed from the server!")
end

function class:Client()
	return assert(self._client, "Client events can only be accessed from the client!")
end

local v = {}

local function fn(...)
	return ...
end

local function newEvent(value, callback)
	local name, reliable2

	if type(value) == "string" then
		name = value
		reliable2 = true
	else
		name = value.Name

		if value.Reliable == nil then
			if value.Unreliable == nil then
				reliable2 = true
			else
				reliable2 = not value.Unreliable
			end
		else
			reliable2 = value.Reliable
		end
	end

	assert(name, "Event name must be provided!")
	assert(callback, "Event validator must be provided!")
	local object = setmetatable({
		Id = name,
		Reliable = reliable2,
		_client = nil,
		_server = nil
	}, class)

	if v[name] then
		error((`Event with name {name} already exists!`))
	end

	v[name] = object

	if RunContext.IsEdit then
		local server = Server.new(name, callback)
		local client = Client.new(name, callback)
		server.Dispatch:Connect(function(_, ...)
			if pcall(callback, ...) and client.Receiver then
				client.Receiver(...)
			end
		end)
		client.Dispatch:Connect(function(...)
			if pcall(callback, ...) then
				local localPlayer = Players.LocalPlayer

				if localPlayer and server.Receiver then
					server.Receiver(localPlayer, ...)
				end
			end
		end)
		object._server = server
		object._client = client
	elseif RunContext.IsServer then
		local server = Server.new(name, callback)
		server.Dispatch:Connect(function(player, ...)
			if pcall(callback, ...) then
				if reliable2 then
					reliable:FireClient(player, name, ...)
				else
					unreliable:FireClient(player, name, ...)
				end
			end
		end)
		object._server = server
	elseif RunContext.IsClient then
		local client = Client.new(name, callback)
		client.Dispatch:Connect(function(...)
			if pcall(callback, ...) then
				if reliable2 then
					reliable:FireServer(name, ...)
				else
					unreliable:FireServer(name, ...)
				end
			end
		end)
		object._client = client
	end

	return object
end

local function newReliableEventImpl(name: string, p2)
	return (newEvent({
		Name = name,
		Reliable = true
	}, p2 or fn))
end

local function newUnreliableEventImpl(name: string, p2)
	return (newEvent({
		Name = name,
		Unreliable = true
	}, p2 or fn))
end

local function createEventReceiver(flag: boolean, p: number, callback)
	return function(...)
		local v2 = { ... }
		local v3 = table.remove(v2, p)
		local v4 = v3 and v[v3]

		if v4 and v4.Reliable == flag then
			callback(v4, table.unpack(v2))
		end
	end
end

if RunContext.IsServer then
	local function onServerReceive(object, p, ...)
		local server = object:Server()

		if server.Receiver then
			server.Receiver(p, ...)
		end
	end

	local v2 = 2
	local v3 = false
	unreliable.OnServerEvent:Connect(function(...)
		local v4 = { ... }
		local v5 = table.remove(v4, v2)
		local v6 = v5 and v[v5]

		if v6 and v6.Reliable == v3 then
			onServerReceive(v6, table.unpack(v4))
		end
	end)
	local v4 = 2
	local v5 = true
	reliable.OnServerEvent:Connect(function(...)
		local v6 = { ... }
		local v7 = table.remove(v6, v4)
		local v8 = v7 and v[v7]

		if v8 and v8.Reliable == v5 then
			onServerReceive(v8, table.unpack(v6))
		end
	end)
elseif RunContext.IsClient then
	local function onClientReceive(object, ...)
		local client = object:Client()

		if client.Receiver then
			client.Receiver(...)
		end
	end

	local v2 = 1
	local v3 = false
	unreliable.OnClientEvent:Connect(function(...)
		local v4 = { ... }
		local v5 = table.remove(v4, v2)
		local v6 = v5 and v[v5]

		if v6 and v6.Reliable == v3 then
			onClientReceive(v6, table.unpack(v4))
		end
	end)
	local v4 = 1
	local v5 = true
	reliable.OnClientEvent:Connect(function(...)
		local v6 = { ... }
		local v7 = table.remove(v6, v4)
		local v8 = v7 and v[v7]

		if v8 and v8.Reliable == v5 then
			onClientReceive(v8, table.unpack(v6))
		end
	end)
end

return table.freeze({
	Event = newEvent,
	ReliableEvent = newReliableEventImpl,
	UnreliableEvent = newUnreliableEventImpl
})