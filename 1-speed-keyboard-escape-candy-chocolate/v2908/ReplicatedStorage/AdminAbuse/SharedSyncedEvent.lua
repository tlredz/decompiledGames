local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local v = { "AdminAbuse", "Remotes", "SSE" }

local function getOrCreateSseFolder()
	local parent = ReplicatedStorage

	for _, childName in v do
		local v3 = parent:FindFirstChild(childName)

		if not v3 then
			v3 = Instance.new("Folder")
			v3.Name = childName
			v3.Parent = parent
		end

		parent = v3
	end

	return parent
end

local function waitForSseFolder()
	local child = ReplicatedStorage

	for _, childName in v do
		child = child:WaitForChild(childName, 15)

		if child then
			continue
		end

		warn("[SharedSyncedEvent] Dossier SSE introuvable dans le chemin:", childName)
		return nil
	end

	return child
end

local function createRemote(name: string)
	local sseFolder = getOrCreateSseFolder()
	local remoteEvent = sseFolder:FindFirstChild(name)

	if remoteEvent and remoteEvent:IsA("RemoteEvent") then
		return remoteEvent
	end

	local remoteEvent2 = Instance.new("RemoteEvent")
	remoteEvent2.Name = name
	remoteEvent2.Parent = sseFolder
	return remoteEvent2
end

local function waitForRemote(childName: string)
	local v2 = waitForSseFolder()

	if not v2 then
		return nil
	end

	local remoteEvent = v2:WaitForChild(childName, 15)

	if remoteEvent and remoteEvent:IsA("RemoteEvent") then
		return remoteEvent
	end

	warn("[SharedSyncedEvent] Remote '", childName, "' introuvable après", 15, "s")
	return nil
end

local SharedSyncedEvent = {}
SharedSyncedEvent.__index = SharedSyncedEvent

function SharedSyncedEvent:set(p: string, p2)
	self._snapshot[p] = p2
	self._dirty[p] = true
	self._hasDirty = true
end

function SharedSyncedEvent:setSilent(p2: string, p3)
	self._snapshot[p2] = p3
end

function SharedSyncedEvent:fire(p2: string, p3)
	local v2 = self._eventQueue[p2]

	if not v2 then
		v2 = {}
		self._eventQueue[p2] = v2
	end

	table.insert(v2, p3)
	self._hasEvents = true
end

function SharedSyncedEvent:get(p2: string)
	return self._snapshot[p2]
end

function SharedSyncedEvent:syncTo(player)
	if not next(self._snapshot) then
		return
	end

	local _remote = self._remote

	if not _remote then
		return
	end

	pcall(function()
		_remote:FireClient(player, {
			d = self._snapshot
		})
	end)
end

function SharedSyncedEvent:_flush()
	if not (self._hasDirty or self._hasEvents) then
		return
	end

	local v2 = {}

	if self._hasDirty then
		self._hasDirty = false
		local v3 = {}

		for k, _ in pairs(self._dirty) do
			v3[k] = self._snapshot[k]
		end

		self._dirty = {}

		if next(v3) then
			v2.d = v3
		end
	end

	if self._hasEvents then
		self._hasEvents = false
		v2.e = self._eventQueue
		self._eventQueue = {}
	end

	local _remote = self._remote

	if _remote and next(v2) then
		_remote:FireAllClients(v2)
	end
end

function SharedSyncedEvent:onChange(p2: string, callback)
	if not self._onChange[p2] then
		self._onChange[p2] = {}
	end

	table.insert(self._onChange[p2], callback)
end

function SharedSyncedEvent:onFire(p2: string, callback)
	if not self._onFire[p2] then
		self._onFire[p2] = {}
	end

	table.insert(self._onFire[p2], callback)
end

function SharedSyncedEvent:off(p2: string)
	self._onChange[p2] = nil
	self._onFire[p2] = nil
end

function SharedSyncedEvent:_applyPacket(p)
	if type(p) ~= "table" then
		return
	end

	if type(p.d) == "table" then
		for k, v2 in pairs(p.d) do
			self._snapshot[k] = v2
			local v3 = self._onChange[k]

			if not v3 then
				continue
			end

			for _, v4 in ipairs(v3) do
				v4(v2)
			end
		end
	end

	if type(p.e) == "table" then
		for k, list in pairs(p.e) do
			local v2 = self._onFire[k]

			if not v2 then
				continue
			end

			for _, v3 in ipairs(list) do
				for _, v4 in ipairs(v2) do
					v4(v3)
				end
			end
		end
	end
end

function SharedSyncedEvent:destroy()
	local _flushConn = self._flushConn
	local _clientConn = self._clientConn
	self._flushConn = nil
	self._clientConn = nil

	if _flushConn then
		_flushConn:Disconnect()
	end

	if _clientConn then
		_clientConn:Disconnect()
	end

	local _remote = self._isServer and self._remote

	if _remote then
		_remote:Destroy()
	end

	self._remote = nil
	self._snapshot = {}
	self._dirty = {}
	self._eventQueue = {}
	self._onChange = {}
	self._onFire = {}
end

function SharedSyncedEvent.new(name: string, value: number?)
	local isServer = RunService:IsServer()
	local flushRate = (type(value) ~= "number" or not (value > 0)) and 0.05 or 1 / value
	local remote

	if isServer then
		local sseFolder = getOrCreateSseFolder()
		remote = sseFolder:FindFirstChild(name)

		if not (remote and remote:IsA("RemoteEvent")) then
			remote = Instance.new("RemoteEvent")
			remote.Name = name
			remote.Parent = sseFolder
		end
	else
		local v4 = waitForSseFolder()

		if v4 then
			remote = v4:WaitForChild(name, 15)

			if not (remote and remote:IsA("RemoteEvent")) then
				warn("[SharedSyncedEvent] Remote '", name, "' introuvable après", 15, "s")
				remote = nil
			end
		end
	end

	if not remote then
		error("[SharedSyncedEvent] Impossible d'obtenir la remote '" .. name .. "'")
	end

	local object = setmetatable({
		_remote = remote,
		_isServer = isServer,
		_flushRate = flushRate,
		_flushAccum = 0,
		_snapshot = {},
		_dirty = {},
		_hasDirty = false,
		_eventQueue = {},
		_hasEvents = false,
		_flushConn = nil,
		_clientConn = nil,
		_onChange = {},
		_onFire = {}
	}, SharedSyncedEvent)

	if isServer then
		object._flushConn = RunService.Heartbeat:Connect(function(dt: number)
			object._flushAccum += dt

			if object._flushAccum < object._flushRate then
				return
			end

			object._flushAccum -= object._flushRate
			object:_flush()
		end)
		return object
	end

	object._clientConn = remote.OnClientEvent:Connect(function(p)
		object:_applyPacket(p)
	end)
	return object
end

return SharedSyncedEvent