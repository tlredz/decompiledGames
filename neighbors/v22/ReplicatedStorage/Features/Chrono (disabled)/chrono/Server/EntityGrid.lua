local createVector = vector.create
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Events = require(script.Parent.Parent.Shared.Events)
local Config = require(script.Parent.Parent.Shared.Config)
local ReplicationRules = require(script.Parent.Parent.Shared.ReplicationRules)
local Stats = require(script.Parent.Parent.Shared.Stats)

for _, _ in { "ALL_ENTITIES" } do

end

local shared = script.Parent.Parent.Shared
require(shared.Types)
local Holder = require(shared.Holder)
local Ticker = require(shared.Ticker)
local Entity = require(shared.Entity)
local Signal = require(shared.Signal)
local _SetTickMode = Entity._SetTickMode
local v = 0.1
local v2 = 0.0005
local now = 0
local count = 0
local count2 = 0
local count3 = 0
local idMap = Holder.idMap
local v3 = {}
local v4 = {}

local function Check(data)
	local primaryPart = Entity.GetPrimaryPart(data)
	local cFrame = primaryPart and primaryPart.CFrame or data.latestCFrame

	if not cFrame or data.destroyed then
		return
	end

	if data.id < 1 then
		warn(data, " has invalid id, cannot check for proximity")
		return
	end

	local position = cFrame.Position
	local entityConfig = data.entityConfig
	local HALF_TICK_DISTANCE = entityConfig.HALF_TICK_DISTANCE or 1e999
	local NORMAL_TICK_DISTANCE = entityConfig.NORMAL_TICK_DISTANCE or 1e999
	local networkOwner = data.networkOwner
	local v5 = networkOwner and v4[networkOwner]
	local _lockedCFReplication = data._lockedCFReplication or data.modelReplicationMode ~= "NATIVE"
	local v6 = false
	local flag = false

	for k, v7 in v3 do
		local PLAYER = k.PLAYER

		if not ReplicationRules.Allows(data, PLAYER) then
			continue
		end

		local v8 = vector.magnitude(position - v7)

		if HALF_TICK_DISTANCE < v8 and _lockedCFReplication then
			if k == v5 then
				table.insert(k._TEMP_NORMAL, data)
			end
		elseif v8 <= NORMAL_TICK_DISTANCE then
			table.insert(k._TEMP_NORMAL, data)
			flag = true
		else
			table.insert(k._TEMP_HALF, data)
			v6 = true
		end
	end

	local TICKER = entityConfig.TICKER

	if not TICKER then
		return
	end

	local _ticker = data._ticker

	if v6 and not flag then
		local _ = data.isHalfTicked == false
		_SetTickMode(data, true)
		count2 += 1
	elseif flag then
		local _ = data.isHalfTicked
		_SetTickMode(data, false)
		count += 1
	else
		count3 += 1
	end

	if (flag or v6) and data._ticker ~= TICKER then
		Ticker.move(data, TICKER)
	elseif not flag and not v6 and _ticker then
		_SetTickMode(data, nil)
		Ticker.Remove(_ticker, data)
	end
end

local thread = nil
local total = 0

local function DoLoop()
	total = 0
	count = 0
	count2 = 0
	count3 = 0

	for k, _ in v3 do
		table.clear(k._TEMP_HALF)
		table.clear(k._TEMP_NORMAL)
	end

	debug.profilebegin("EntityGrid.Update")
	local lastTime = os.clock()
	local count4 = 0
	local v5 = 1

	for _, v6 in idMap do
		debug.profilebegin("Check One")
		Check(v6)
		count4 += 1
		debug.profileend()
		local v7 = os.clock() - lastTime

		if not (v2 < v7) then
			continue
		end

		v5 += 1
		debug.profileend()
		total += os.clock() - lastTime
		thread = coroutine.running()
		coroutine.yield()
		thread = nil
		lastTime = os.clock()
		debug.profilebegin("EntityGrid.ResumeUpdate")
	end

	debug.profileend()
	total += os.clock() - lastTime
	Stats.SERVER.GRID_UPDATE_SECTIONS = v5
	Stats.SERVER.ENTITY_GRID_UPDATE_TIME_MS = total * 1000
	Stats.SERVER.NUMBER_OF_ENTITIES = count4
	Stats.SERVER.ENTITIES_FULL_TICKED = count
	Stats.SERVER.ENTITIES_HALF_TICKED = count2
	Stats.SERVER.NON_TICKED = count3

	for _, v6 in v4 do
		local _TEMP_NORMAL = v6._TEMP_NORMAL
		local _TEMP_HALF = v6._TEMP_HALF
		table.clear(v6.HALF)
		table.clear(v6.NORMAL)

		for _, v7 in _TEMP_NORMAL do
			table.insert(v6.NORMAL, v7)
		end

		for _, v7 in _TEMP_HALF do
			table.insert(v6.HALF, v7)
		end
	end
end

local function Update()
	if thread then
		task.spawn(thread)
		return
	end

	if os.clock() - now < v then
		return
	end

	v = Config._GetConfig("GRID_UPDATE_INTERVAL") or v
	v2 = Config._GetConfig("GRID_MAX_UPDATE_TIME") or v2
	now = os.clock()
	task.spawn(DoLoop)
end

local function UpdatePlayerPosition(p, vector2: Vector3)
	local v5 = v4[p]

	if not v5 then
		return
	end

	v3[v5] = vector2
end

local function GetEntityHolder(p)
	return v4[p]
end

local function PlayerAdded(PLAYER)
	if v4[PLAYER] then
		return
	end

	local v5 = {
		PLAYER = PLAYER,
		HALF = {},
		NORMAL = {},
		REPLICATED = {},
		_TEMP_HALF = {},
		_TEMP_NORMAL = {},
		EntityAdded = Signal.new(),
		EntityRemoving = Signal.new()
	}
	v4[PLAYER] = v5
	v3[v5] = createVector(0, 0, 0)
	Events._Signals.PlayerLoaded:Fire(PLAYER)
end

if RunService:IsServer() then
	shared.Remotes.ClientLoaded.OnServerEvent:Connect(PlayerAdded)
	Players.PlayerRemoving:Connect(function(player)
		local v5 = v4[player]

		if not v5 then
			return
		end

		v5.EntityAdded:DisconnectAll()
		v5.EntityRemoving:DisconnectAll()
		v3[v5] = nil
		v4[player] = nil
	end)
end

return {
	Update = Update,
	UpdatePlayerPosition = UpdatePlayerPosition,
	GetEntityHolder = GetEntityHolder
}