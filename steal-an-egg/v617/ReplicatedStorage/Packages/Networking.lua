local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Signal = require(ReplicatedStorage.Packages.Signal)
local environment = require(ReplicatedStorage.Shared.environment)
local isServer = RunService:IsServer()
assert(RunService:IsRunning(), "Networking should not be required outside of a runtime context (got Studio edit mode).")
local name = nil
local env = nil

local function ErrorSignal(message: string)
	local v = Signal.new()

	function v.Connect()
		error(message)
	end

	return v
end

local function WarnOnInvoked(p: string)
	return function()
		warn(p)
	end
end

local function ErrorOnInvoked(message: string)
	return function()
		error(message)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function WaitFor(childName: string, p: number)
	local v = false
	task.delay(3, function()
		if not v then
			warn((`Waited longer than {3} second for Networking.{childName} to exist.`))
		end
	end)
	local child = script:WaitForChild(childName, p)
	v = true
	return child
end

local function ExtendRemoteEvent(object)
	return {
		OnServerEvent = object.OnServerEvent,
		OnClientEvent = object.OnClientEvent,
		FireClient = function(self, player, ...)
			object:FireClient(player, ...)
		end,
		FireAllClients = function(self, ...)
			object:FireAllClients(...)
		end,
		FireServer = function(self, ...)
			object:FireServer(...)
		end,
		FireAllExcept = function(_, player, ...)
			local v

			if typeof(player) == "Instance" then
				v = player:IsA("Player")
			else
				v = false
			end

			assert(v, (`invalid player to ignore "{player}"`))

			for _, player2 in Players:GetPlayers() do
				if player2 ~= player then
					object:FireClient(player2, ...)
				end
			end
		end
	}
end

local function AssertNamespaceOpen(p: string, p2: string)
	local v

	if type(name) == "string" then
		v = type(env) == "string"
	else
		v = false
	end

	assert(
		v,
		(`Networking.{p}("{p2}") called outside of an open namespace -- did you forget Networking.namespace(\{\{...}}) above?`)
	)
end

local function RemoteEvent(p: string)
	local v

	if type(name) == "string" then
		v = type(env) == "string"
	else
		v = false
	end

	assert(
		v,
		(`Networking.remoteEvent("{p}") called outside of an open namespace -- did you forget Networking.namespace(\{\{...}}) above?`)
	)
	local formatted = `RE/{name}/{p}`

	if isServer then
		local remoteEvent = Instance.new("RemoteEvent")
		remoteEvent.Name = formatted
		remoteEvent.Parent = script

		if env == "all" or environment.placeType == env then
			return (ExtendRemoteEvent(remoteEvent))
		end

		local formatted2 = `tried to FireClient with mock remote {formatted}`
		local v2 = {
			FireClient = function()
				warn(formatted2)
			end,
			FireAllClients = 0,
			FireAllExcept = 0,
			OnServerEvent = 0,
			OnClientEvent = 0,
			FireServer = 0
		}
		local formatted3 = `tried to FireAllClients with mock remote {formatted}`

		function v2.FireAllClients()
			warn(formatted3)
		end

		local formatted4 = `tried to FireAllExcept with mock remote {formatted}`

		function v2.FireAllExcept()
			warn(formatted4)
		end

		v2.OnServerEvent = Signal.new()
		local onClientEvent = Signal.new()
		local v4 = "tried to use OnClientEvent on the server on a mock remote."

		function onClientEvent.Connect()
			error(v4)
		end

		v2.OnClientEvent = onClientEvent
		local formatted5 = `tried to FireServer {formatted} on the server`

		function v2.FireServer()
			error(formatted5)
		end

		remoteEvent.OnServerEvent:Connect(function(p2)
			error((`Remote invocation from {p2} for remote {formatted} was filtered.`))
		end)
		return v2
	else
		local waitFor = WaitFor(formatted, 10) -- equivalent call inferred; original call site unknown
		assert(waitFor, (`Server did not create RemoteEvent "{formatted}"`))
		return waitFor
	end
end

local function UnreliableRemoteEvent(p: string)
	local v

	if type(name) == "string" then
		v = type(env) == "string"
	else
		v = false
	end

	assert(
		v,
		(`Networking.unreliableRemoteEvent("{p}") called outside of an open namespace -- did you forget Networking.namespace(\{\{...}}) above?`)
	)
	local formatted = `URE/{name}/{p}`

	if isServer then
		local unreliableRemoteEvent = Instance.new("UnreliableRemoteEvent")
		unreliableRemoteEvent.Name = formatted
		unreliableRemoteEvent.Parent = script

		if env == "all" or environment.placeType == env then
			return (ExtendRemoteEvent(unreliableRemoteEvent))
		end

		local unreliableRemoteEvent2 = Instance.new("UnreliableRemoteEvent")
		unreliableRemoteEvent2.Name = formatted
		return (ExtendRemoteEvent(unreliableRemoteEvent2))
	else
		local waitFor = WaitFor(formatted, 10) -- equivalent call inferred; original call site unknown
		assert(waitFor, (`Server did not create UnreliableRemoteEvent "{formatted}"`))
		return waitFor
	end
end

local function RemoteFunction(p: string)
	local v

	if type(name) == "string" then
		v = type(env) == "string"
	else
		v = false
	end

	assert(
		v,
		(`Networking.remoteFunction("{p}") called outside of an open namespace -- did you forget Networking.namespace(\{\{...}}) above?`)
	)
	local formatted = `RF/{name}/{p}`

	if isServer then
		local remoteFunction = Instance.new("RemoteFunction")
		remoteFunction.Name = formatted
		remoteFunction.Parent = script

		if env == "all" or environment.placeType == env then
			return remoteFunction
		end

		local remoteFunction2 = Instance.new("RemoteFunction")
		remoteFunction2.Name = formatted
		return remoteFunction2
	else
		local waitFor = WaitFor(formatted, 10) -- equivalent call inferred; original call site unknown
		assert(waitFor, (`Server did not create RemoteFunction "{formatted}"`))
		return waitFor
	end
end

return table.freeze({
	namespace = function(p)
		name = p.name
		env = p.env
	end,
	close = function()
		name = nil
		env = nil
	end,
	remoteEvent = RemoteEvent,
	unreliableRemoteEvent = UnreliableRemoteEvent,
	remoteFunction = RemoteFunction
})