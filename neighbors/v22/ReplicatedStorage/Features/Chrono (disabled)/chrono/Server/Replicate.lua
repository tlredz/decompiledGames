local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local shared = script.Parent.Parent.Shared
local ApplyMounts = require(shared.ApplyMounts)
local Warn = require(shared.Warn)
local Bin = require(shared.Bin)
local Holder = require(shared.Holder)
local Events = require(shared.Events)
local Ticker = require(shared.Ticker)
local Config = require(shared.Config)
require(shared.Types)
local Entity = require(shared.Entity)
local EntityGrid = require(script.Parent.EntityGrid)
require(script.Parent.Player)
local Sender = require(script.Parent.Sender)
local Receiver = require(script.Parent.Receiver)
local Stats = require(shared.Stats)
local SERVER = Stats.SERVER
local heartbeat = shared.Remotes.Heartbeat
local clientClockRelay = shared.Remotes.ClientClockRelay
local v = 0
local v2 = 0
local TICKERs = {}
Config._WaitForLock(function()
	for _, _EntityConfig in Config._EntityConfigs do
		if _EntityConfig.TICKER then
			table.insert(TICKERs, _EntityConfig.TICKER)
		else
			Warn.high(_EntityConfig, "TICKERS not found on server config load")
		end
	end
end)

local function FireEvent(state, p: string, ...)
	local _events = state._events

	if not _events then
		return
	end

	local _event = _events[p]

	if _event then
		_event:Fire(state, ...)
	end
end

local function MapRotation(p: number)
	return (math.round((p + 3.141592653589793) / 0.00009587526218325454))
end

local function SerializeFull(buf: buffer, latestCFrame: CFrame, offset: number)
	local X = latestCFrame.X
	local Y = latestCFrame.Y
	local Z = latestCFrame.Z
	local orientation, v3, v4 = latestCFrame:ToOrientation()
	buffer.writef32(buf, offset, X)
	local v5 = offset + 4
	buffer.writef32(buf, v5, Y)
	local v6 = v5 + 4
	buffer.writef32(buf, v6, Z)
	local v7 = v6 + 4
	buffer.writeu16(buf, v7, (math.round((orientation + 3.141592653589793) / 0.00009587526218325454)))
	local v8 = v7 + 2
	buffer.writeu16(buf, v8, (math.round((v3 + 3.141592653589793) / 0.00009587526218325454)))
	local v9 = v8 + 2
	buffer.writeu16(buf, v9, (math.round((v4 + 3.141592653589793) / 0.00009587526218325454)))
	return v9 + 2
end

local function SerializeYaw(buf: buffer, cframe: CFrame, offset: number)
	local X = cframe.X
	local Y = cframe.Y
	local Z = cframe.Z
	local _, v3, _ = cframe:ToOrientation()
	buffer.writef32(buf, offset, X)
	local v4 = offset + 4
	buffer.writef32(buf, v4, Y)
	local v5 = v4 + 4
	buffer.writef32(buf, v5, Z)
	local v6 = v5 + 4
	buffer.writeu16(buf, v6, (math.round((v3 + 3.141592653589793) / 0.00009587526218325454)))
	return v6 + 2
end

local function CFrameChanged(vector: CFrame?, cframe: CFrame?)
	return vector ~= cframe and (vector == nil or cframe == nil or vector:FuzzyEq(cframe, 0.0001) == false)
end

local function PushLatest(data, lastTicked: number)
	if data.autoUpdatePosition and data.isContextOwner and data.model then
		local primaryPart = Entity.GetPrimaryPart(data)

		if primaryPart then
			local cFrame = primaryPart.CFrame
			Entity.Push(data, lastTicked, cFrame)
		else
			Warn.low("Entity", data, "has no primary part")
		end
	end
end

local function CheckForChanges(state)
	local lastCheckedCFrame = state.lastCheckedCFrame
	local latestCFrame = state.latestCFrame
	local v3

	if lastCheckedCFrame == latestCFrame then
		v3 = false
	else
		v3 = lastCheckedCFrame == nil or latestCFrame == nil or lastCheckedCFrame:FuzzyEq(latestCFrame, 0.0001) == false
	end

	if not v3 then
		return nil
	end

	state.lastCheckedCFrame = latestCFrame
	return latestCFrame
end

local function CheckEntity(object, data, FULL_ROTATION: boolean, tickedHalf: boolean)
	if object.destroyed then
		Ticker.Remove(data, object)
		return
	end

	if not object.isContextOwner then
		return
	end

	local isHalfTicked = object.isHalfTicked

	if isHalfTicked and not tickedHalf or object.paused then
		object.cframeBuffer = nil
		return
	end

	if isHalfTicked then
		FireEvent(object, "Ticked", data.halfdt)
	else
		FireEvent(object, "Ticked", data.dt)
	end

	PushLatest(object, data.lastTicked)
	local lastCheckedCFrame = object.lastCheckedCFrame
	local latestCFrame = object.latestCFrame
	local v3

	if lastCheckedCFrame == latestCFrame then
		v3 = false
	else
		v3 = lastCheckedCFrame == nil or latestCFrame == nil or lastCheckedCFrame:FuzzyEq(latestCFrame, 0.0001) == false
	end

	if v3 then
		object.lastCheckedCFrame = latestCFrame
	else
		latestCFrame = nil
	end

	if not latestCFrame then
		object.cframeBuffer = nil
		return
	end

	if object.id == 0 then
		error("Entity Should not have and id of 0")
	end

	if FULL_ROTATION then
		local buf = buffer.create(20)
		buffer.writeu16(buf, 0, object.id)
		SerializeFull(buf, latestCFrame, 2)
		object.cframeBuffer = buf
	else
		local buf = buffer.create(16)
		buffer.writeu16(buf, 0, object.id)
		local v4 = 2
		local X = latestCFrame.X
		local Y = latestCFrame.Y
		local Z = latestCFrame.Z
		local _, v5, _ = latestCFrame:ToOrientation()
		buffer.writef32(buf, v4, X)
		local v6 = v4 + 4
		buffer.writef32(buf, v6, Y)
		local v7 = v6 + 4
		buffer.writef32(buf, v7, Z)
		local v8 = v7 + 4
		buffer.writeu16(buf, v8, (math.round((v5 + 3.141592653589793) / 0.00009587526218325454)))
		v8 += 2
		object.cframeBuffer = buf
	end
end

local v3 = {}

local function CheckEntityChanges()
	for k, _Change in Entity._Changes do
		local changes = {
			id = k.id,
			data = {}
		}

		for k2, v5 in _Change do
			local v6 = v5 or k[k2]
			table.insert(changes.data, { k2, v6 })
		end

		Entity._Changes[k] = nil
		k._changes = changes
		table.insert(v3, k)
	end
end

local total = 0
local count = 0

local function UpdateTickers()
	debug.profilebegin("UpdateTickers")
	local lastTime = os.clock()

	for _, v4 in TICKERs do
		if not next(v4.objects) then
			continue
		end

		debug.profilebegin((`{v4.config.NAME}`))

		if Ticker.CheckUpdate(v4) then
			local FULL_ROTATION = v4.config.FULL_ROTATION == true
			local tickedHalf = v4.tickedHalf

			for _, object in v4.objects do
				CheckEntity(object, v4, FULL_ROTATION, tickedHalf)
			end
		end

		debug.profileend()
	end

	debug.profileend()
	local v4 = os.clock() - lastTime
	total += v4
	count += 1
	SERVER.AVG_TICKER_TIME_MS = total / count * 1000

	if count >= 60 then
		total = 0
		count = 0
	end
end

local function UpdatePlayerPositions()
	for _, _playerChar in Holder._playerChars do
		local networkOwner = _playerChar.networkOwner
		local primaryPart = Entity.GetPrimaryPart(_playerChar)
		local cFrame = primaryPart and primaryPart.CFrame or _playerChar.latestCFrame

		if networkOwner and cFrame then
			EntityGrid.UpdatePlayerPosition(networkOwner, cFrame.Position)
		end
	end
end

local function updateEntityStats()
	if not SERVER._SHOULD_REPLICATE then
		SERVER.SERVER_ENTITIES = {}
		return
	end

	local v4 = {}

	for _, v5 in Holder.idMap do
		local networkOwner = v5.networkOwner
		local isCharacter = v5._player ~= nil
		local entityConfig = v5.entityConfig
		local config = not entityConfig and "DEFAULT" or entityConfig.NAME or "DEFAULT"
		local v8 = 1 / entityConfig.TICK_RATE
		local isHalfTicked = v5.isHalfTicked
		local position

		if v5.latestCFrame then
			position = v5.latestCFrame.Position or nil
		end

		local v9

		if isHalfTicked == true then
			v9 = v8 / 2
		else
			v9 = isHalfTicked == nil and 0 or v8
		end

		local v10 = v9 // 1
		local tickRate = (v10 ~= v10 or v10 == 1e999) and 0 or v10
		local latestTime = v5.latestTime
		table.insert(v4, {
			isPaused = v5.paused,
			id = v5.id,
			networkOwner = networkOwner,
			isCharacter = isCharacter,
			config = config,
			tickRate = tickRate,
			lastTicked = latestTime,
			lastPosition = position,
			modelType = Entity.GetModelReplicationType(v5)
		})
	end

	SERVER.SERVER_ENTITIES = v4
end

local function UpdateHeartbeat()
	local now = os.clock()

	if now - v >= 0.1 then
		v = now

		for _, player in Players:GetPlayers() do
			if EntityGrid.GetEntityHolder(player) then
				heartbeat:FireClient(player, now)
			end
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function UpdateClientClockRelay()
	local now = os.clock()

	if now - v2 < 60 then
		return
	end

	v2 = now
	local _GetClientClockRaws = Receiver._GetClientClockRaws()

	if #_GetClientClockRaws == 0 then
		return
	end

	clientClockRelay:FireAllClients(_GetClientClockRaws)
end

local function Update()
	EntityGrid.Update()
	UpdatePlayerPositions()
	ApplyMounts()
	UpdateTickers()
	CheckEntityChanges()
	UpdateHeartbeat()
	UpdateClientClockRelay() -- equivalent call inferred; original call site unknown

	for _, v4 in Players:GetPlayers() do
		Sender.ReplicatePlayer(v4)
	end

	for _, v4 in v3 do
		v4._changes = nil
	end

	table.clear(v3)
	updateEntityStats()
end

local function HandleEntity(_, p)
	local v4, v5 = Bin()

	local function HandleModel(p2)
		if not p2.model then
			return
		end

		local _GetRootPart = Entity._GetRootPart(p2)

		if not _GetRootPart then
			return
		end

		local function CFrameChanged2()
			local cFrame = _GetRootPart.CFrame

			if cFrame == p2.latestCFrame then
				return
			end

			Entity.SetCFrame(p2, cFrame)
		end

		v4(_GetRootPart:GetPropertyChangedSignal("CFrame"):Connect(CFrameChanged2))
	end

	local v6, v7 = Bin()
	v6(Entity.GetEvent(p, "ModelChanged"):Connect(function()
		v5()
		HandleModel(p)
	end))
	v6(Entity.GetEvent(p, "LockChanged"):Connect(function()
		v5()
		HandleModel(p)
	end))
	local connection = nil
	local connection2 = Entity.GetEvent(p, "NetworkOwnerChanged"):Once(function()
		v5()
		v7()
		connection:Disconnect()
	end)
	connection = Entity.GetEvent(p, "Destroying"):Once(function()
		v5()
		v7()
		connection2:Disconnect()
	end)
	HandleModel(p)
end

local function HandleCFrameSetters()
	local _GetConfig = Config._GetConfig("REPLICATE_CFRAME_SETTERS")

	if _GetConfig == "NONE" then
		return
	end

	if _GetConfig == "PLAYER_ENTITIES" then
		Events.PlayerOwnedAdded:Connect(HandleEntity, true)
	else
		Events.PlayerCharacterRegistered:Connect(HandleEntity, true)
	end

	for _, v4 in Holder.idMap do
		if _GetConfig == "PLAYER_ENTITIES" and v4.networkOwner then
			HandleEntity(v4.networkOwner, v4)
		elseif _GetConfig == "PLAYER_CHARACTERS" and v4._player then
			HandleEntity(v4._player, v4)
		end
	end
end

local function PlayerAdded(_)
	clientClockRelay:FireAllClients((Receiver._GetClientClockRaws()))
end

Config._WaitForLock(function()
	if not RunService:IsServer() then
		return
	end

	HandleCFrameSetters()
	Events._Signals.PlayerLoaded.Event:Connect(PlayerAdded)
	RunService.PostSimulation:Connect(Update)
end)
return nil