local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Config = require(script.Parent.Config)
local Entity = require(script.Parent.Entity)
local Holder = require(script.Parent.Holder)
require(script.Parent.Types)
local v = {
	REPLICATE_PERMISSIONS = {
		[689602534] = true,
		[1398092537] = true,
		[476745725] = true,
		[265839211] = true
	},
	CLIENT = {
		_PAUSE = false,
		TOTAL_ENTITIES_CULLED = 0,
		ENTITIES_MOVED_THIS_FRAME = 0,
		TOTAL_CLIENT_ENTITIES_CHECKED_THIS_FRAME = 0,
		TOTAL_CLIENT_ENTITIES = 0,
		AVG_INTERPOLATION_TIME_MS = 0,
		BYTES_RECEIVED_PER_SEC = 0,
		NEW_ENTITIES_PER_SEC = 0,
		ENTITY_CHANGES_PER_SEC = 0,
		ENTITY_REMOVALS_PER_SEC = 0,
		CLIENT_ENTITIES = {}
	},
	SERVER = {
		_SHOULD_REPLICATE = false,
		AVG_TICKER_TIME_MS = 0,
		ENTITY_GRID_UPDATE_TIME_MS = 0,
		GRID_UPDATE_SECTIONS = 0,
		NUMBER_OF_ENTITIES = 0,
		NON_TICKED = 0,
		ENTITIES_FULL_TICKED = 0,
		ENTITIES_HALF_TICKED = 0,
		REPLICATE_PLAYER_TIME_MS = 0,
		BYTES_RECEIVED_PER_SEC = 0,
		BYTES_SENT_PER_SEC = 0,
		PACKETS_SENT_PER_SEC = 0,
		SERVER_ENTITIES = {}
	}
}

-- equivalent calls inferred from this helper; original call sites unknown
local function processID(p: number, p2)
	script:SetAttribute(tostring(p), p2)
end

function v.HasPermissionToReplicate(userId)
	if typeof(userId) == "Instance" and userId:IsA("Player") then
		userId = userId.UserId
	end

	return script:GetAttribute((tostring(userId))) == true
end

function v.ReplicateStatsForPlayer(userId)
	if RunService:IsClient() then
		warn("Stats.ReplicateStatsForPlayer should only be called on the server.")
		return
	end

	if typeof(userId) == "Instance" and userId:IsA("Player") then
		userId = userId.UserId
	end

	v.REPLICATE_PERMISSIONS[userId] = true
	processID(userId, true) -- equivalent call inferred; original call site unknown
end

function v.StopReplicatingStatsForPlayer(userId)
	if RunService:IsClient() then
		warn("Stats.StopReplicatingStatsForPlayer should only be called on the server.")
		return
	end

	if typeof(userId) == "Instance" and userId:IsA("Player") then
		userId = userId.UserId
	end

	v.REPLICATE_PERMISSIONS[userId] = nil
	processID(userId, false) -- equivalent call inferred; original call site unknown
end

local v2 = {}

for k, v3 in v.REPLICATE_PERMISSIONS do
	processID(k, v3) -- equivalent call inferred; original call site unknown
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updateStat(p: string, p2: string, p3)
	if p2 == "WARNING_SEVERITY" then
		Config.SetWarningSeverity(p3)
	end

	if p == "FFLAG" then
		Config.FLAGS[p2] = p3
	end
end

local _ = {
	REPLICATE_SERVER_STATS = "REPLICATE_SERVER_STATS",
	UPDATE_STAT = "UPDATE_STAT",
	DEBUGGER_OPENED = "DEBUGGER_OPENED",
	CLIENT_STATS_ACTION = "CLIENT_STATS_ACTION"
}

if RunService:IsServer() then
	local remoteEvent = Instance.new("RemoteEvent", script)
	remoteEvent.Name = "Stats"
	RunService.Heartbeat:Connect(function()
		local v3 = false

		if next(v.REPLICATE_PERMISSIONS) then
			for _, player in Players:GetPlayers() do
				if not (v.REPLICATE_PERMISSIONS[player.UserId] and v2[player.UserId]) then
					continue
				end

				remoteEvent:FireClient(player, "REPLICATE_SERVER_STATS", v.SERVER)
				v3 = true
			end
		end

		v.SERVER._SHOULD_REPLICATE = v3
	end)
	remoteEvent.OnServerEvent:Connect(function(p, p2: string, ...)
		if p2 == "DEBUGGER_OPENED" then
			local v3 = ...
			v2[p.UserId] = v3
		else
			if v.REPLICATE_PERMISSIONS and not v.REPLICATE_PERMISSIONS[p.UserId] then
				return
			end

			if p2 == "UPDATE_STAT" then
				local v3, v4, v5 = ...
				updateStat(v3, v4, v5) -- equivalent call inferred; original call site unknown
				remoteEvent:FireAllClients("UPDATE_STAT", v3, v4, v5)
			elseif p2 == "CLIENT_STATS_ACTION" then
				local v3, v4 = ...
				local entity = Holder.GetEntityFromId(v4)

				if not entity then
					return
				end

				if v3 == "CHANGE_NATIVE" then
					local modelReplicationType = Entity.GetModelReplicationType(entity)

					if modelReplicationType == "NATIVE" then
						Entity.LockNativeServerCFrameReplication(entity)
					elseif modelReplicationType == "NATIVE_WITH_LOCK" then
						Entity.UnlockNativeServerCFrameReplication(entity)
					end
				elseif v3 == "TOGGLE_PAUSE" then
					if entity.paused then
						Entity.ResumeReplication(entity)
					else
						Entity.PauseReplication(entity)
					end
				elseif v3 == "CHANGE_CONFIG" then
					local v5 = select(3, ...)
					Entity.SetConfig(entity, v5)
				end
			end
		end
	end)
	return v
else
	local stats = script:WaitForChild("Stats")

	local function handleServerEvent(p: string, ...)
		if p == "REPLICATE_SERVER_STATS" then
			local v3 = ...

			if v.CLIENT._PAUSE then
				return
			end

			for k, v4 in v3 do
				v.SERVER[k] = v4
			end
		elseif p == "UPDATE_STAT" then
			local v3, v4, v5 = ...
			updateStat(v3, v4, v5) -- equivalent call inferred; original call site unknown
		end
	end

	stats.OnClientEvent:Connect(handleServerEvent)

	function v._openedDebugger()
		v.SERVER._SHOULD_REPLICATE = true
		stats:FireServer("DEBUGGER_OPENED", true)
	end

	function v._closedDebugger()
		v.SERVER._SHOULD_REPLICATE = false
		stats:FireServer("DEBUGGER_OPENED", false)
	end

	function v._updateStat(p: string, p2: string, p3)
		stats:FireServer("UPDATE_STAT", p, p2, p3)
	end

	function v._fireClientStatsEvent(...)
		stats:FireServer("CLIENT_STATS_ACTION", ...)
	end

	return v
end