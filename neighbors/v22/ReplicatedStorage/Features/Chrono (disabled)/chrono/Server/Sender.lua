local RunService = game:GetService("RunService")
local EntityGrid = require(script.Parent.EntityGrid)
require(script.Parent.Parent.Shared.Types)
local shared = script.Parent.Parent.Shared
local ModelHelper = require(shared.ModelHelper)
local ClockUnwrap = require(shared.ClockUnwrap)
local Stats = require(shared.Stats)
local SERVER = Stats.SERVER
local total = 0
local count = 0
local buf = buffer.create(951)
local replicate = shared.Remotes.Replicate
local replicateFull = shared.Remotes.ReplicateFull

local function WriteTickerHeader(buf2: buffer, offset: number, p, flag: boolean?)
	local lastTicked = p.lastTicked
	local FULL_ROTATION = p.config.FULL_ROTATION
	buffer.writeu32(buf2, offset, (ClockUnwrap.quantize(lastTicked)))
	local v = offset + 4
	local v2 = flag and 1 or 0

	if FULL_ROTATION then
		v2 += 2
	end

	buffer.writeu8(buf2, v, v2)
	return v + 1
end

-- equivalent calls inferred from this helper; original call sites unknown
local function Flush(player, size: number, p)
	local buf2 = buffer.create(size)
	buffer.copy(buf2, 0, buf, 0, size)
	replicate:FireClient(player, p, buf2)
	total += size
	count += 1
end

local function FlushClientOwned(player, items)
	local v = 0

	for k, item in items do
		local quantize = ClockUnwrap.quantize(k)
		buffer.writeu32(buf, v, quantize)
		local v2 = v + 4
		v = v2 + 1
		local count2 = 0

		for _, v3 in item do
			local v4 = buffer.len(v3)

			if v + v4 > 900 then
				buffer.writeu8(buf, v2, count2)
				Flush(player, v, "O") -- equivalent call inferred; original call site unknown
				local v5 = 0
				buffer.writeu32(buf, v5, quantize)
				v2 = v5 + 4
				v = v2 + 1
				count2 = 0
			end

			buffer.copy(buf, v, v3, 0, v4)
			count2 += 1
			v += v4
		end

		buffer.writeu8(buf, v2, count2)
	end

	if v > 0 then
		Flush(player, v, "O") -- equivalent call inferred; original call site unknown
	end
end

local function FlushEntities(player, items, flag: boolean?)
	local v = buf
	local v2 = 0

	for k, item in items do
		local v3 = k.config.FULL_ROTATION and 20 or 16
		local lastTicked = k.lastTicked
		local FULL_ROTATION = k.config.FULL_ROTATION
		buffer.writeu32(v, v2, (ClockUnwrap.quantize(lastTicked)))
		local v4 = v2 + 4
		local v5 = flag and 1 or 0

		if FULL_ROTATION then
			v5 += 2
		end

		buffer.writeu8(v, v4, v5)
		local v6 = v4 + 1
		v2 = v6 + 1
		local count2 = 0

		for _, source in item do
			if v2 + v3 > 900 then
				buffer.writeu8(v, v6, count2)
				Flush(player, v2, "X") -- equivalent call inferred; original call site unknown
				local v7 = 0
				local lastTicked2 = k.lastTicked
				local FULL_ROTATION2 = k.config.FULL_ROTATION
				buffer.writeu32(v, v7, (ClockUnwrap.quantize(lastTicked2)))
				local v8 = v7 + 4
				local v9 = flag and 1 or 0

				if FULL_ROTATION2 then
					v9 += 2
				end

				buffer.writeu8(v, v8, v9)
				v6 = v8 + 1
				v2 = v6 + 1
				count2 = 0
			end

			count2 += 1
			buffer.copy(v, v2, source, 0, v3)
			v2 += v3
		end

		buffer.writeu8(v, v6, count2)
	end

	if v2 > 0 then
		Flush(player, v2, "X") -- equivalent call inferred; original call site unknown
	end
end

local function GetEntityFullData(player, data)
	if data.destroyed then
		return nil
	end

	local readyModelFromRep, modelMetaData = ModelHelper.ReadyModelFromRep(data, player)
	local NAME = data.entityConfig.NAME

	if NAME == "DEFAULT" then
		NAME = nil
	end

	return {
		id = data.id,
		_player = data._player,
		networkOwner = data.networkOwner,
		cframe = data.latestCFrame or CFrame.new(),
		time = data.lastClientClock or 0,
		config = NAME,
		model = readyModelFromRep,
		_modelMetaData = modelMetaData,
		paused = data.paused,
		isHalfTicked = data.isHalfTicked,
		_data = data._data,
		_lockedCFReplication = data._lockedCFReplication,
		mountParentId = data.mountParentId,
		mountOffset = data.mountOffset,
		broadPhase = data.broadPhase
	}
end

local total2 = 0
local count2 = 0

local function ReplicatePlayer(player)
	local entityHolder = EntityGrid.GetEntityHolder(player)

	if not entityHolder then
		return
	end

	debug.profilebegin("ReplicatePlayer")
	local REPLICATED = entityHolder.REPLICATED
	local clone = table.clone(REPLICATED)
	entityHolder.REPLICATED = clone
	local entityAdded = entityHolder.EntityAdded
	local entityRemoving = entityHolder.EntityRemoving
	local NORMAL = entityHolder.NORMAL
	local HALF = entityHolder.HALF
	local v = {}
	local v2 = {}
	local _changes = {}
	local v3 = {}
	local v4 = {}
	local v5 = time()

	-- equivalent calls inferred from this helper; original call sites unknown
	local function HandleClientEntities(data)
		if not (data.arriveFrame == v5 and data.networkOwner ~= player) then
			return
		end

		local lastClientClock = data.lastClientClock or 0

		if not v2[lastClientClock] then
			v2[lastClientClock] = {}
		end

		table.insert(v2[lastClientClock], data.cframeBuffer)
	end

	local function Handle(data, flag: boolean)
		if data.destroyed then
			return
		end

		clone[data] = true

		if REPLICATED[data] then
			if data._changes then
				table.insert(_changes, data._changes)
			end

			REPLICATED[data] = nil

			if data.paused then
				return
			end

			if data.isContextOwner then
				local _ticker = data._ticker

				if not _ticker or _ticker.tickedFrame ~= v5 or not data.cframeBuffer then
					return
				end

				local isHalfTicked = data.isHalfTicked or not flag

				if isHalfTicked and not _ticker.tickedHalf then
					return
				end

				local v6

				if isHalfTicked then
					v6 = v4
				else
					v6 = v3
				end

				local cframeBuffers = v6[_ticker]

				if not cframeBuffers then
					cframeBuffers = {}
					v6[_ticker] = cframeBuffers
				end

				table.insert(cframeBuffers, data.cframeBuffer)
			else
				HandleClientEntities(data) -- equivalent call inferred; original call site unknown
			end
		else
			entityAdded:Fire(data)
			table.insert(v, (GetEntityFullData(player, data)))
		end
	end

	local now = os.clock()
	local _lastIds = {}

	for _, v6 in NORMAL do
		Handle(v6, true)
	end

	for _, v6 in HALF do
		Handle(v6, false)
	end

	for k, _ in REPLICATED do
		clone[k] = nil
		entityRemoving:Fire(k)
		table.insert(_lastIds, k._lastId or k.id)
	end

	FlushClientOwned(player, v2)
	FlushEntities(player, v3)
	FlushEntities(player, v4, true)

	if #_lastIds > 0 or #v > 0 or #_changes > 0 then
		replicateFull:FireClient(player, v, _lastIds, _changes)
	end

	debug.profileend()
	local now2 = os.clock()
	total2 += now2 - now
	count2 += 1
end

local lastTime = os.clock()
RunService.Heartbeat:Connect(function()
	SERVER.REPLICATE_PLAYER_TIME_MS = total2 / math.max(count2, 1) * 1000

	if os.clock() - lastTime > 1 then
		SERVER.BYTES_SENT_PER_SEC = total
		SERVER.PACKETS_SENT_PER_SEC = count
		total = 0
		count = 0
		lastTime = os.clock()
		total2 = 0
		count2 = 0
	end
end)
return {
	ReplicatePlayer = ReplicatePlayer
}