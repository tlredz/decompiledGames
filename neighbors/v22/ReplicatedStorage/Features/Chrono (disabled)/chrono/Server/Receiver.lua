local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
game:GetService("ReplicatedStorage")
local Receiver = {}
local v = {}
local v2 = {}
local shared = script.Parent.Parent.Shared
local InterpolationMath = require(shared.InterpolationMath)
local Warn = require(shared.Warn)
local ServerClock = require(script.Parent.ServerClock)
require(shared.Types)
local Holder = require(shared.Holder)
local Entity = require(shared.Entity)
local Config = require(shared.Config)
local ClockUnwrap = require(shared.ClockUnwrap)
local Stats = require(shared.Stats)
local SERVER = Stats.SERVER
local v3 = {}
local v4 = 300
Config._WaitForLock(function()
	v4 = Config._GetConfig("MAX_TOTAL_BYTES_PER_FRAME_PER_PLAYER")
end)
local total = 0
local replicate = shared.Remotes.Replicate
local safeReplicate = shared.Remotes.SafeReplicate

local function FireMiddleMans(object, entity, cframe: CFrame, p: number)
	if #v2 == 0 then
		return false
	end

	debug.profilebegin("FireMiddleMans")

	for _, v5 in v2 do
		if v5.func(object, entity, cframe, p) then
			return true
		end
	end

	debug.profileend()
	return false
end

local function UnmapRotation(p: number)
	return p / 65535 * 6.283185307179586 - 3.141592653589793
end

local function DeserializeFull(buf: buffer, offset: number)
	local v5 = buffer.readf32(buf, offset)
	local v6 = offset + 4
	local v7 = buffer.readf32(buf, v6)
	local v8 = v6 + 4
	local v9 = buffer.readf32(buf, v8)
	local v10 = v8 + 4
	local v11 = buffer.readu16(buf, v10) / 65535 * 6.283185307179586 - 3.141592653589793
	local v12 = v10 + 2
	local v13 = buffer.readu16(buf, v12) / 65535 * 6.283185307179586 - 3.141592653589793
	local v14 = v12 + 2
	local v15 = buffer.readu16(buf, v14) / 65535 * 6.283185307179586 - 3.141592653589793
	v14 += 2
	return CFrame.new(v5, v7, v9) * CFrame.fromOrientation(v11, v13, v15)
end

local function DeserializeYaw(buf: buffer, offset: number)
	local v5 = buffer.readf32(buf, offset)
	local v6 = offset + 4
	local v7 = buffer.readf32(buf, v6)
	local v8 = v6 + 4
	local v9 = buffer.readf32(buf, v8)
	local v10 = v8 + 4
	local v11 = buffer.readu16(buf, v10) / 65535 * 6.283185307179586 - 3.141592653589793
	v10 += 2
	return CFrame.new(v5, v7, v9) * CFrame.fromOrientation(0, v11, 0)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function DeserializeEntityPacket(buf: buffer, offset: number)
	local v5 = buffer.readu16(buf, offset)
	local v6 = offset + 2
	local v7 = buffer.readu8(buf, v6)
	local v8 = v6 + 1
	local v9 = bit32.band(v7, 1) == 1
	local v10 = bit32.band(v7, 4) == 4
	local v11, v12

	if v9 then
		v11 = DeserializeFull(buf, v8)
		v12 = v8 + 18
	else
		v11 = DeserializeYaw(buf, v8)
		v12 = v8 + 14
	end

	return v5, v11, v12, v10
end

local function CalculateMaxThroughputForPlayer(p)
	local count = 0

	for _ in Holder._clientOwned[p] or {} do
		count += 1
	end

	return v4 + count * 21
end

local function HandleEntity(object, p: number, now: number, lastClientClock: number, cframe: CFrame, buf: buffer, flag: boolean)
	local entity = Holder.GetEntityFromId(p)

	if not entity or entity.networkOwner ~= object then
		return
	end

	local _teleport = entity._teleport
	local v5 = math.max(object:GetNetworkPing(), 0) + 0.05
	local v6 = _teleport and os.clock() - _teleport < v5 + 0.5

	if flag then
		if v6 then
			entity._teleport = nil
		else
			buffer.writeu8(buf, 2, (bit32.band(buffer.readu8(buf, 2), 4294967291)))
		end
	elseif v6 then
		return
	end

	if entity.lastClientClock and lastClientClock < entity.lastClientClock then
		return
	end

	debug.profilebegin("HandleEntity.FireMiddleMans")

	if FireMiddleMans(object, entity, cframe, now) then
		debug.profileend()
		return
	end

	debug.profileend()
	local v7 = nil

	if Config.FLAGS.SERVER_VELOCITY_FIX and entity.snapshot then
		local latest = entity.snapshot:GetLatest()
		local lastClientClock2 = entity.lastClientClock or lastClientClock
		local TICK_RATE = entity.entityConfig.TICK_RATE

		if entity.isHalfTicked then
			TICK_RATE *= 2
		end

		if latest then
			v7 = InterpolationMath.CalculateVelocity(
				latest.value.Position,
				lastClientClock2,
				cframe.Position,
				lastClientClock,
				TICK_RATE
			)
		end
	end

	if Entity.Push(entity, now, cframe, v7) then
		task.spawn(function()
			RunService.PreAnimation:Wait()
			entity.arriveFrame = time()
		end)
		entity.lastClientClock = lastClientClock
		entity.cframeBuffer = buf

		if entity.modelReplicationMode == "NATIVE" and not entity._lockedCFReplication then
			return
		else
			Entity._SetPartCFrame(entity, cframe)
		end
	end
end

local v5 = {}

local function OnReceive(p, buf: buffer)
	if not buf then
		return
	end

	v5[p] = (v5[p] or 0) + buffer.len(buf)
	total += buffer.len(buf)
	local count = 0

	for _ in Holder._clientOwned[p] or {} do
		count += 1
	end

	local v6 = v4 + count * 21

	if v6 < v5[p] then
		Warn.medium("Player", p.Name, "exceeded max bytes per frame:", v5[p], "max:", v6)
		return
	end

	debug.profilebegin("Receiver.OnReceive")
	local v7 = 0
	local unwrapFor = ClockUnwrap.unwrapFor(v3, p, (buffer.readu32(buf, v7)))
	local v8 = v7 + 4
	local now = os.clock()
	local v9 = buffer.len(buf)
	ServerClock.Store(p, unwrapFor)

	while v8 < v9 do
		local v10, v11, v12, v13 = DeserializeEntityPacket(buf, v8) -- equivalent call inferred; original call site unknown
		local buf2 = buffer.create(v12 - v8)
		buffer.copy(buf2, 0, buf, v8, v12 - v8)
		HandleEntity(p, v10, now, unwrapFor, v11, buf2, v13)
		v8 = v12
	end

	debug.profileend()
end

function Receiver.RegisterMiddleMan(p: string, priority: number, func)
	v[p] = {
		priority = priority,
		func = func
	}
	v2 = {}

	for _, v6 in v do
		table.insert(v2, v6)
	end

	table.sort(v2, function(a, b)
		return a.priority > b.priority
	end)
end

function Receiver.UnregisterMiddleMan(p: string)
	v[p] = nil
	v2 = {}

	for _, v6 in v do
		table.insert(v2, v6)
	end

	table.sort(v2, function(a, b)
		return a.priority > b.priority
	end)
end

if RunService:IsServer() then
	local now = 0
	RunService.Heartbeat:Connect(function(_: number)
		table.clear(v5)

		if os.clock() - now > 1 then
			SERVER.BYTES_RECEIVED_PER_SEC = total
			total = 0
			now = os.clock()
		end
	end)
	replicate.OnServerEvent:Connect(OnReceive)
	safeReplicate.OnServerEvent:Connect(OnReceive)
	shared.Remotes.ClientHeartbeat.OnServerEvent:Connect(function(p, value: number)
		if type(value) ~= "number" then
			return
		end

		local seatFullFor = ClockUnwrap.seatFullFor(v3, p, value)
		ServerClock.Store(p, seatFullFor)
	end)
	Players.PlayerRemoving:Connect(function(player)
		v3[player] = nil
	end)
end

function Receiver._GetClientClockRaws()
	local result = {}

	for k, v6 in v3 do
		if v6.lastRaw then
			table.insert(result, {
				player = k,
				raw = v6.lastRaw,
				offset = v6.offset
			})
		end
	end

	return result
end

return Receiver