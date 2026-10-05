local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local E = Enum.KeyCode.E
local F3 = Enum.KeyCode.F3
local chrono = script.Parent.chrono
local iris = ReplicatedStorage.Modules.Iris
local shared = chrono.Shared
local Config = require(shared.Config)
local Stats = require(shared.Stats)
require(shared.Types)
local module = require(iris)
local FLAGS = Config.FLAGS
local CLIENT = Stats.CLIENT
local Players = game:GetService("Players")
local userId = Players.LocalPlayer.UserId
module.Init()

local function displayFlagEditor(k, p)
	local typeName = typeof(p)

	if typeName == "boolean" then
		module.SameLine()
		module.Text({ k .. ": " .. tostring(p) })

		if module.Button({ p and "Disable " or "Enable " .. k }).clicked() then
			Stats._updateStat("FFLAG", k, not p)
		end

		module.End()
	elseif typeName == "number" then
		module.SameLine()
		module.Text({ k .. ": " .. tostring(p) })
		local value = module.Input({ (tostring(p)) }).value

		if value and tonumber(value) and tonumber(value) ~= p then
			Stats._updateStat("FFLAG", k, (tonumber(value)))
		end

		module.End()
	end
end

local function displayFlags()
	module.Tree({ "Flags" })

	for k, v in FLAGS do
		displayFlagEditor(k, v)
	end

	module.End()
end

local function displayServerEntityStats(data)
	module.Text({ "ID: " .. tostring(data.id) })
	module.Text({ "Network Owner: " .. tostring(data.networkOwner) })
	module.Text({ "Is Character: " .. tostring(data.isCharacter) })
	module.Text({ "Tick Rate: " .. tostring(data.tickRate) })
	module.Text({ "Last Ticked: " .. tostring(data.lastTicked) })
	module.Text({ "Last Position: " .. tostring(data.lastPosition) })
	module.SameLine()
	module.Text({ "Is Paused: " .. tostring(data.isPaused) })

	if module.Button({ data.isPaused and "Unpause" or "Pause" }).clicked() then
		Stats._fireClientStatsEvent("TOGGLE_PAUSE", data.id)
	end

	module.End()
	module.SameLine()
	module.Text({ "Model Type: " .. tostring(data.modelType) })

	if (data.modelType == "NATIVE" or data.modelType == "NATIVE_WITH_LOCK") and module.Button({ "Change Model Types" }).clicked() then
		Stats._fireClientStatsEvent("CHANGE_NATIVE", data.id)
	end

	module.End()
	module.Text({ "Config: " .. tostring(data.config) })

	if module.Tree({ "Configs" }).state.isUncollapsed.value then
		for k, _ in Config._EntityConfigs do
			if not module.Button({ "Change to " .. k }).clicked() then
				continue
			end

			Stats._fireClientStatsEvent("CHANGE_CONFIG", data.id, k)
		end
	end

	module.End()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function displayVector3(position: Vector3)
	return string.format("X: %.2f, Y: %.2f, Z: %.2f", position.X, position.Y, position.Z)
end

local function cframeToString(cframe: CFrame)
	local eulerAnglesXYZ, v, v2 = cframe:ToEulerAnglesXYZ()
	local v3 = math.deg(eulerAnglesXYZ)
	local v4 = math.deg(v)
	local v5 = math.deg(v2)
	local v6 = displayVector3(cframe.Position) -- equivalent call inferred; original call site unknown
	local vector = Vector3.new(v3, v4, v5)
	return v6 .. ` | rot: {string.format("X: %.2f, Y: %.2f, Z: %.2f", vector.X, vector.Y, vector.Z)}`
end

local function displaySnapShots(snapshots)
	module.Text({ "Snapshots:" })

	for _, item in snapshots do
		local text = module.Text
		local t = item.t
		local value = item.value

		if value then
			local value2 = item.value
			local eulerAnglesXYZ, v3, v4 = value2:ToEulerAnglesXYZ()
			local v5 = math.deg(eulerAnglesXYZ)
			local v6 = math.deg(v3)
			local v7 = math.deg(v4)
			local v8 = displayVector3(value2.Position) -- equivalent call inferred; original call site unknown
			local vector = Vector3.new(v5, v6, v7)
			value = v8 .. ` | rot: {string.format("X: %.2f, Y: %.2f, Z: %.2f", vector.X, vector.Y, vector.Z)}`
		end

		local velocity = item.velocity

		if velocity then
			local velocity2 = item.velocity
			velocity = string.format("X: %.2f, Y: %.2f, Z: %.2f", velocity2.X, velocity2.Y, velocity2.Z)
		end

		text({ (`t: {t}, value: {value} | velocity: {velocity}`) })
	end
end

local function displayClientEntityStats(data)
	module.Text({ "ID: " .. tostring(data.id) })
	module.Text({ "Network Owner: " .. tostring(data.networkOwner) })
	module.Text({ "Is Character: " .. tostring(data.isCharacter) })
	module.Text({ "Config: " .. tostring(data.config) })
	module.Text({ "Last Received Time: " .. tostring(data.lastReceivedTime) })
	module.Text({ "Last Replicated Time: " .. tostring(data.lastReplicatedTime) })
	module.Text({ "Current Position: " .. tostring(data.currentPosition) })
	module.Text({ "Average Latency: " .. tostring(data.averageLatency) })
	module.Text({ "Target Time: " .. tostring(data.targetTime) })
	module.Text({ "Deviation: " .. tostring(data.deviation) })
	module.Text({ "Buffered Time: " .. tostring(data.bufferedTime) })

	if module.Button({ "Clear client clock" }).clicked() then
		local entity = data.entity
		local _clientClock = entity._clientClock

		if not _clientClock then
			local CLIENT_CLOCK = entity.entityConfig.CLIENT_CLOCK

			if CLIENT_CLOCK then
				_clientClock = entity.isHalfTicked and CLIENT_CLOCK.HALF or CLIENT_CLOCK.NORMAL
			end
		end

		if _clientClock then
			_clientClock:Clear()
		end
	end

	if module.Tree({ "Snapshots" }).state.isUncollapsed.value then
		if module.Button({ "Clear Snapshots" }).clicked() then
			data.entity.snapshot:Clear()
		end

		displaySnapShots(data.snapshots)
	end

	module.End()
end

local function displayLineHeader()
	local _GetConfig = Config._GetConfig("WARNING_SEVERITY")

	if module.Button({ Stats.CLIENT._PAUSE and "Unpause" or "Pause" }).clicked() then
		Stats.CLIENT._PAUSE = not Stats.CLIENT._PAUSE
	end

	module.SameLine()
	module.Text({ "Warning Severity: " })

	if module.Button({ (tostring(_GetConfig)) }).clicked() then
		local v = {
			"NONE",
			"LOW",
			"MEDIUM",
			"HIGH"
		}
		local v2 = (table.find(v, _GetConfig) or 1) % #v + 1
		Stats._updateStat("", "WARNING_SEVERITY", v[v2])
	end

	module.End()
end

local state = module.State(false)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed or not Stats.HasPermissionToReplicate(userId) then
		return
	end

	if input.KeyCode == E then
		Stats.CLIENT._PAUSE = not Stats.CLIENT._PAUSE
	end

	if input.KeyCode == F3 then
		state:set(not state.value)
	end
end)
state:onChange(function(p)
	if p then
		Stats._openedDebugger()
	else
		Stats._closedDebugger()
	end
end)
module:Connect(function()
	if module.Window({ (`Chrono Debug {Stats.CLIENT._PAUSE and " (Paused)" or ""}`) }, {
		isOpened = state
	}) then
		module.Text({ "Version: " .. tostring(Config._GetConfig("__VERSION")) })
		displayLineHeader()

		if module.Tree({ "Client Network Stats" }).state.isUncollapsed.value then
			module.Text({ "Received (Non-Compressed): " .. tostring(CLIENT.BYTES_RECEIVED_PER_SEC / 1000) .. " KB/s" })
			module.Text({ "Entities Added: " .. tostring(CLIENT.NEW_ENTITIES_PER_SEC) .. "/s" })
			module.Text({ "Entity Changes: " .. tostring(CLIENT.ENTITY_CHANGES_PER_SEC) .. "/s" })
			module.Text({ "Entity Removals: " .. tostring(CLIENT.ENTITY_REMOVALS_PER_SEC) .. "/s" })
			module.Tree({ "Client Entities" })

			for _, v in Stats.CLIENT.CLIENT_ENTITIES do
				if module.Tree({ "Entity " .. tostring(v.id) }).state.isUncollapsed.value then
					displayClientEntityStats(v)
				end

				module.End()
			end

			module.End()
		end

		module.End()

		if module.Tree({ "Client Render Stats" }).state.isUncollapsed.value then
			module.Text({ "Avg Interpolation Time (ms): " .. tostring(CLIENT.AVG_INTERPOLATION_TIME_MS) })
			module.Text({ "Total Entities Culled: " .. tostring(CLIENT.TOTAL_ENTITIES_CULLED) })
			module.Text({ "Entities Moved This Frame: " .. tostring(CLIENT.ENTITIES_MOVED_THIS_FRAME) })
			module.Text({ "Total Client Entities Checked This Frame: " .. tostring(CLIENT.TOTAL_CLIENT_ENTITIES_CHECKED_THIS_FRAME) })
			module.Text({ "Total Client Entities: " .. tostring(CLIENT.TOTAL_CLIENT_ENTITIES) })
		end

		module.End()

		if module.Tree({ "Server Stats" }).state.isUncollapsed.value then
			module.Text({ "Avg Ticker Time Per Frame (ms): " .. tostring(Stats.SERVER.AVG_TICKER_TIME_MS) })
			module.Text({ "Entity Grid Total Update Time (ms): " .. tostring(Stats.SERVER.ENTITY_GRID_UPDATE_TIME_MS) })
			module.Text({ "Entity Grid Section Time (ms): " .. tostring(Stats.SERVER.ENTITY_GRID_UPDATE_TIME_MS / Stats.SERVER.GRID_UPDATE_SECTIONS) })
			module.Text({ "Grid Update Sections: " .. tostring(Stats.SERVER.GRID_UPDATE_SECTIONS) })
			module.Text({ "Number of Entities: " .. tostring(Stats.SERVER.NUMBER_OF_ENTITIES) })
			module.Text({ "Entities Non-Ticked: " .. tostring(Stats.SERVER.NON_TICKED) })
			module.Text({ "Entities Full-Ticked: " .. tostring(Stats.SERVER.ENTITIES_FULL_TICKED) })
			module.Text({ "Entities Half-Ticked: " .. tostring(Stats.SERVER.ENTITIES_HALF_TICKED) })
			module.Text({ "Bytes Received (Non-Compressed): " .. tostring(Stats.SERVER.BYTES_RECEIVED_PER_SEC / 1000) .. " KB/s" })
			module.Text({ "Bytes Sent (Non-Compressed): " .. tostring(Stats.SERVER.BYTES_SENT_PER_SEC / 1000) .. " KB/s" })
			module.Text({ "Packets Sent: " .. tostring(Stats.SERVER.PACKETS_SENT_PER_SEC) .. "/s" })
			module.Text({ "Replicate Player Time (ms): " .. tostring(Stats.SERVER.REPLICATE_PLAYER_TIME_MS) })
			module.Tree({ "Server Entities" })

			for _, v in Stats.SERVER.SERVER_ENTITIES do
				if module.Tree({ "Entity " .. tostring(v.id) }).state.isUncollapsed.value then
					displayServerEntityStats(v)
				end

				module.End()
			end

			module.End()
		end

		module.End()
		displayFlags()
		module.End()
	end
end)