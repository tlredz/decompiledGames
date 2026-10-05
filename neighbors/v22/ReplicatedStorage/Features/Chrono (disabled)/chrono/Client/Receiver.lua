local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local shared = script.Parent.Parent.Shared
local Warn = require(shared.Warn)
local Entity = require(shared.Entity)
local Events = require(shared.Events)
local Holder = require(shared.Holder)
local ModelHelper = require(shared.ModelHelper)
require(shared.Types)
local ClockUnwrap = require(shared.ClockUnwrap)
local Stats = require(shared.Stats)
local CLIENT = Stats.CLIENT
local ClientClock = require(script.Parent.ClientClock)
local total = 0
local total2 = 0
local total3 = 0
local total4 = 0
local _SetTickMode = Entity._SetTickMode
local replicate = shared.Remotes.Replicate
local replicateFull = shared.Remotes.ReplicateFull
local heartbeat = shared.Remotes.Heartbeat
local clientClockRelay = shared.Remotes.ClientClockRelay
local v = ClockUnwrap.new()
local v2 = {}

local function UnmapRotation(p: number)
	return p / 65535 * 6.283185307179586 - 3.141592653589793
end

local function ReadTickerHeader(buf: buffer, offset: number)
	local unwrapped = ClockUnwrap.unwrap(v, (buffer.readu32(buf, offset)))
	local v3 = buffer.readu8(buf, offset + 4)
	local v4 = bit32.band(v3, 1) == 1
	return unwrapped, bit32.band(v3, 2) == 2, v4
end

local function DeserializeFull(buf: buffer, offset: number)
	local v3 = buffer.readf32(buf, offset)
	local v4 = offset + 4
	local v5 = buffer.readf32(buf, v4)
	local v6 = v4 + 4
	local v7 = buffer.readf32(buf, v6)
	local v8 = v6 + 4
	local v9 = buffer.readu16(buf, v8) / 65535 * 6.283185307179586 - 3.141592653589793
	local v10 = v8 + 2
	local v11 = buffer.readu16(buf, v10) / 65535 * 6.283185307179586 - 3.141592653589793
	local v12 = v10 + 2
	local v13 = buffer.readu16(buf, v12) / 65535 * 6.283185307179586 - 3.141592653589793
	v12 += 2
	return CFrame.new(v3, v5, v7) * CFrame.fromOrientation(v9, v11, v13)
end

local function DeserializeYaw(buf: buffer, offset: number)
	local v3 = buffer.readf32(buf, offset)
	local v4 = offset + 4
	local v5 = buffer.readf32(buf, v4)
	local v6 = v4 + 4
	local v7 = buffer.readf32(buf, v6)
	local v8 = v6 + 4
	local v9 = buffer.readu16(buf, v8) / 65535 * 6.283185307179586 - 3.141592653589793
	v8 += 2
	return CFrame.new(v3, v5, v7) * CFrame.fromOrientation(0, v9, 0)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function HandleRemoved(p: number)
	local entity = Holder.GetEntityFromId(p)

	if entity then
		Entity.Destroy(entity)
	else
		Warn.high("Tried to remove non existent entity with id", p)
	end
end

local function SetMountId(p, mountParentId: number?)
	p.mountParentId = mountParentId
	Events._Signals.EntityMountChanged:Fire(p, mountParentId)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function SetMountOffset(_new, mountOffset: CFrame?)
	_new.mountOffset = mountOffset or CFrame.identity
end

local v3 = {
	networkOwner = Entity["设置网络主控玩家"],
	isHalfTicked = _SetTickMode,
	_data = Entity.SetData,
	entityConfig = Entity.SetConfig,
	autoUpdatePos = Entity.SetAutoUpdatePos,
	mountParentId = SetMountId,
	mountOffset = SetMountOffset,
	broadPhase = Entity.SetBroadPhase
}

local function HandleChanges(p)
	local entity = Holder.GetEntityFromId(p.id)

	if not entity then
		return
	end

	local v4 = nil
	local modelMetaData = nil

	for _, v6 in p.data do
		local v7 = v6[1]
		local lockedCFReplication = v6[2]
		local v9 = v3[v7]

		if v9 then
			v9(entity, lockedCFReplication)
		elseif v7 == "latestCFrame" then
			Entity.SetCFrame(entity, lockedCFReplication)
		elseif v7 == "_modelMetaData" then
			modelMetaData = lockedCFReplication
		elseif v7 == "model" then
			v4 = lockedCFReplication
		elseif v7 == "_player" then
			if lockedCFReplication then
				Holder.SetAsCharacter(lockedCFReplication, entity)
			else
				Holder.RemovePlayerCharacter(entity)
			end
		elseif v7 == "paused" then
			if lockedCFReplication then
				Entity.PauseReplication(entity)
			else
				Entity.ResumeReplication(entity)
			end
		elseif v7 == "_lockedCFReplication" then
			entity._lockedCFReplication = lockedCFReplication

			if lockedCFReplication then
				Entity.SyncOwnerShip(entity)
			else
				local _GetPart = Entity._GetPart(entity)

				if _GetPart then
					Entity._UnlockPartPhysicsReplication(_GetPart)
				end
			end
		else
			Warn.high("Unhandled entity change key:", v7)
		end
	end

	if v4 ~= nil then
		local modelFromData, v6 = ModelHelper.CreateModelFromData(v4)
		Entity.SetModel(entity, modelFromData, v6)
		entity._modelMetaData = modelMetaData
	end
end

local function HandleNewEntity(data)
	local modelFromData, v4 = ModelHelper.CreateModelFromData(data.model)
	local _new = Entity._new(data.config, modelFromData, v4, data.cframe)
	_new.id = data.id
	_new._player = data._player
	_new._modelMetaData = data._modelMetaData
	_new.paused = data.paused or false
	_new.isHalfTicked = data.isHalfTicked
	_new._data = data._data
	_new.mountParentId = data.mountParentId
	SetMountOffset(_new, data.mountOffset) -- equivalent call inferred; original call site unknown
	_new.broadPhase = data.broadPhase or _new.broadPhase
	_new._lockedCFReplication = data._lockedCFReplication or false
	Entity.Push(_new, data.time, data.cframe)
	Entity["设置网络主控玩家"](_new, data.networkOwner)
	_SetTickMode(_new, data.isHalfTicked)
	Holder.RegisterEntity(_new)
end

local function PushCFrameFor(p: number, flag: boolean, cframe: CFrame, p2: number, isHalfTicked: boolean, flag2: boolean?)
	local entity = Holder.GetEntityFromId(p)

	if not entity then
		Warn.high("Received update for non existent entity with id", p)
		return false
	end

	if entity._teleport and os.clock() - entity._teleport < 0.5 then
		if not flag2 then
			return false
		end

		entity._teleport = nil
	end

	if flag then
		local _clientClock = entity._clientClock

		if _clientClock then
			if isHalfTicked then
				_clientClock:SetTickRate(_clientClock._baseTickRate * 2)
			else
				_clientClock:SetTickRate(_clientClock._baseTickRate)
			end

			_clientClock:OnSnapShot(p2)
		end
	else
		local CLIENT_CLOCK = entity.entityConfig.CLIENT_CLOCK
		local HALF = CLIENT_CLOCK and (isHalfTicked and CLIENT_CLOCK.HALF or CLIENT_CLOCK.NORMAL)

		if HALF then
			HALF:OnSnapShot(p2)
		end
	end

	if entity.isHalfTicked ~= isHalfTicked then
		_SetTickMode(entity, isHalfTicked)
	end

	entity.isHalfTicked = isHalfTicked
	Entity.Push(entity, p2, cframe)
	return true
end

local function HandleClientOwned(buf: buffer)
	total += buffer.len(buf)
	local v4 = buffer.len(buf)
	local v5 = 0

	while v5 < v4 do
		local v6 = buffer.readu32(buf, v5)
		local v7 = v5 + 4
		local v8 = buffer.readu8(buf, v7)
		v5 = v7 + 1

		for _ = 1, v8 do
			local v9 = buffer.readu16(buf, v5)
			local v10 = v5 + 2
			local v11 = buffer.readu8(buf, v10)
			local v12 = v10 + 1
			local v13 = bit32.band(v11, 1) == 1
			local isHalfTicked = bit32.band(v11, 2) == 2
			local v15 = bit32.band(v11, 4) == 4
			local v16

			if v13 then
				v16 = DeserializeFull(buf, v12)
				v5 = v12 + 18
			else
				v16 = DeserializeYaw(buf, v12)
				v5 = v12 + 14
			end

			local entity = Holder.GetEntityFromId(v9)

			if entity then
				PushCFrameFor(
					v9,
					true,
					v16,
					ClockUnwrap.unwrapFor(v2, entity.networkOwner or "__unknown", v6),
					isHalfTicked,
					v15
				)
			else
				Warn.medium("Received update for non existent entity with id", v9)
			end
		end
	end
end

local function HandleServerOwned(buf: buffer)
	local v4 = buffer.len(buf)
	total += v4
	local v5 = 0

	while v5 < v4 do
		local unwrapped = ClockUnwrap.unwrap(v, (buffer.readu32(buf, v5)))
		local v6 = buffer.readu8(buf, v5 + 4)
		local v7 = bit32.band(v6, 1) == 1
		local v8 = bit32.band(v6, 2) == 2
		local v9 = v5 + 5
		local v10 = buffer.readu8(buf, v9)
		v5 = v9 + 1

		for _ = 1, v10 do
			local v11 = buffer.readu16(buf, v5)
			local v12 = v5 + 2
			local v13

			if v8 then
				v13 = DeserializeFull(buf, v12)
				v5 = v12 + 18
			else
				v13 = DeserializeYaw(buf, v12)
				v5 = v12 + 14
			end

			PushCFrameFor(v11, false, v13, unwrapped, v7)
		end
	end
end

local function HandleUnreliable(p: string, buf: buffer)
	if p == "X" then
		HandleServerOwned(buf)
	elseif p == "O" then
		HandleClientOwned(buf)
	else
		Warn.high("Unknown unreliable replicate id", p)
	end
end

local function HandleReliable(list, list2, list3)
	if list2 then
		for _, v4 in list2 do
			HandleRemoved(v4) -- equivalent call inferred; original call site unknown
		end

		total3 += #list2
	end

	if list then
		for _, v4 in list do
			HandleNewEntity(v4)
		end

		total2 += #list
	end

	if list3 then
		for _, v4 in list3 do
			HandleChanges(v4)
		end

		total4 += #list3
	end
end

replicate.OnClientEvent:Connect(HandleUnreliable)
replicateFull.OnClientEvent:Connect(HandleReliable)
heartbeat.OnClientEvent:Connect(function(p: number)
	local unwrapped = ClockUnwrap.unwrap(v, ClockUnwrap.quantize(p))

	for k in ClientClock.serverOwnedClocks do
		k:Refresh(unwrapped)
	end
end)
clientClockRelay.OnClientEvent:Connect(function(items)
	if type(items) ~= "table" then
		return
	end

	for _, item in items do
		local player = item.player
		local raw = item.raw
		local offset = item.offset

		if not (player and type(raw) == "number" and type(offset) == "number") then
			continue
		end

		local v4 = v2[player]

		if not v4 then
			v4 = ClockUnwrap.new()
			v2[player] = v4
		end

		v4.lastRaw = raw
		v4.offset = math.max(v4.offset, offset)
	end
end)
Players.PlayerRemoving:Connect(function(player)
	v2[player] = nil
end)
local now = 0
RunService.Heartbeat:Connect(function()
	if os.clock() - now > 1 then
		if not CLIENT._PAUSE then
			CLIENT.BYTES_RECEIVED_PER_SEC = total
			CLIENT.NEW_ENTITIES_PER_SEC = total2
			CLIENT.ENTITY_CHANGES_PER_SEC = total4
			CLIENT.ENTITY_REMOVALS_PER_SEC = total3
		end

		total2 = 0
		total3 = 0
		total4 = 0
		total = 0
		now = os.clock()
	end
end)
return nil