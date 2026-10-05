local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
require(script.Parent.ModuleDriverTypes)
local AdminAbuseConfig = require(ReplicatedStorage.Shared.AdminAbuseConfig)
local AdminAbuseDoorConfig = require(ReplicatedStorage.Shared.AdminAbuseDoorConfig)
local v = {
	BrothersBossRoom = true,
	ChichineBossRoom = true,
	FoeCakesBossRoom = true,
	LuckymatBossRoom = true,
	MaskedManColorMania = true,
	OverdriveBossRoom = true,
	WCFinaleAdminAbuse = true
}
local v2 = nil

local function getSlotExpiresAt(name: string, isAdminAbuse: boolean, startedAt: number, durationSeconds: number?)
	if durationSeconds == nil then
		return nil
	end

	if isAdminAbuse then
		return startedAt + durationSeconds
	end

	local adminAbuseServerModules = ServerScriptService.Server:FindFirstChild("AdminAbuseServerModules")
	local moduleScript

	if adminAbuseServerModules then
		moduleScript = adminAbuseServerModules:FindFirstChild(name)
	end

	local slotDurationSeconds

	if moduleScript and moduleScript:IsA("ModuleScript") then
		local success, result = pcall(require, moduleScript)

		if not success or type(result) ~= "table" then
			result = nil
		end

		if result and result.GetSlotDurationSeconds then
			local success2
			success2, slotDurationSeconds = pcall(result.GetSlotDurationSeconds, durationSeconds)

			if success2 and type(slotDurationSeconds) == "number" and slotDurationSeconds == slotDurationSeconds and slotDurationSeconds > 0 then
				if not (slotDurationSeconds < 1e999) then
					slotDurationSeconds = durationSeconds
				end
			else
				slotDurationSeconds = durationSeconds
			end
		else
			slotDurationSeconds = durationSeconds
		end
	else
		slotDurationSeconds = durationSeconds
	end

	return startedAt + slotDurationSeconds
end

local function getRuntimeData(name: string, startedAt: number)
	local v3 = v[name]

	if not v3 then
		if AdminAbuseConfig.BossUseTheatreHp == true then
			v3 = name == "LokiiBossRoom" or name == "NextuneBossRoom"
		else
			v3 = false
		end
	end

	if not v3 then
		return {}
	end

	local maskedManOpeningCutsceneSec

	if name == "FoeCakesBossRoom" then
		maskedManOpeningCutsceneSec = (AdminAbuseDoorConfig.TransitionBlackIn or 0) + (AdminAbuseDoorConfig.TransitionBlackHold or 0) + (AdminAbuseDoorConfig.TransitionBlackOut or 0) + (AdminAbuseConfig.FoeCakesOpeningCutsceneSec or 12)
	elseif name == "MaskedManColorMania" then
		maskedManOpeningCutsceneSec = AdminAbuseConfig.MaskedManOpeningCutsceneSec or 10
	elseif name == "WCFinaleAdminAbuse" then
		maskedManOpeningCutsceneSec = AdminAbuseConfig.WCFinaleOpeningCutsceneSec or 10
	else
		maskedManOpeningCutsceneSec = (name == "BrothersBossRoom" or name == "OverdriveBossRoom" or name == "ChichineBossRoom") and 0 or AdminAbuseDoorConfig.TransitionBlackIn + AdminAbuseDoorConfig.TransitionBlackHold + AdminAbuseDoorConfig.TransitionApproachSeconds + AdminAbuseDoorConfig.LobbyDoorOpenExtraDelaySec + AdminAbuseDoorConfig.DoorOpenDuration + 4
	end

	return {
		theatreStartUnix = startedAt + math.ceil(maskedManOpeningCutsceneSec),
		theatreDpsSeed = math.random(1, 2147483647)
	}
end

local function makeDriver(data)
	local name = data.name
	local maxDurationSeconds

	if data.maxDurationSeconds > 0 then
		maxDurationSeconds = data.maxDurationSeconds
	end

	local info = {
		name = name,
		displayName = data.displayName or name,
		source = "legacy",
		slot = data.isAdminAbuse and "main" or "event",
		hidden = false,
		needsDuration = data.needsDuration,
		defaultDurationSeconds = 0,
		maxDurationSeconds = 0,
		loadError = nil
	}
	local defaultDurationSeconds

	if data.defaultDurationSeconds > 0 then
		defaultDurationSeconds = data.defaultDurationSeconds
	else
		defaultDurationSeconds = maxDurationSeconds
	end

	info.defaultDurationSeconds = defaultDurationSeconds
	info.maxDurationSeconds = maxDurationSeconds
	return {
		info = info,
		usesDuration = data.needsDuration,
		prepare = function(p)
			return {
				runtimeData = getRuntimeData(name, p.startedAt),
				expiresAt = getSlotExpiresAt(name, data.isAdminAbuse, p.startedAt, p.durationSeconds)
			}
		end,
		start = function(data2)
			local v6 = v2

			if v6 == nil then
				return false, "Legacy AdminAbuseServer is unavailable"
			end

			local runtimeData = data2.runtimeData
			local success, result = pcall(v6.startLocally, name, data2.durationSeconds, data2.startedAt, runtimeData)

			if success and result == true then
				return true, nil
			end

			local v7 = false

			if success then
				return false, (`Legacy module '{name}' refused to start locally`)
			end

			return v7, (tostring(result))
		end,
		stop = function(_, _)
			local v6 = v2

			if v6 == nil then
				return false, "Legacy AdminAbuseServer is unavailable"
			end

			local success, result = pcall(v6.stopLocally, name)

			if success then
				return success, nil
			end

			return success, (tostring(result))
		end
	}
end

local function resolveDuration(p: number?, p2: number?, p3: number?)
	local v3 = p or p2

	if v3 == nil then
		return nil, nil
	end

	if v3 ~= v3 or v3 == 1e999 or v3 == -1e999 or v3 <= 0 then
		return nil, "durationSeconds must be a finite number greater than zero"
	end

	if p3 == nil then
		return v3, nil
	end

	if p3 == p3 and p3 ~= 1e999 and not (p3 <= 0) then
		return math.min(v3, p3), nil
	end

	return nil, "maxDurationSeconds must be a finite number greater than zero"
end

local function findDriver(p: string)
	local v3 = v2

	if v3 == nil or not v3.getLiveOpsState().initialized then
		return nil
	end

	for _, v4 in v3.getLiveOpsModules() do
		if v4.name == p then
			return (makeDriver(v4))
		end
	end

	return nil
end

local LegacyAdapter = {}

function LegacyAdapter.initialize()
	assert(RunService:IsServer(), "LegacyAdapter.initialize can only be called on the server")
	local success, adminAbuseServer = pcall(require, ServerScriptService.Server.AdminAbuseServer)

	if not success then
		return false, (tostring(adminAbuseServer))
	end

	v2 = adminAbuseServer
	return true, nil
end

function LegacyAdapter.getDrivers()
	local v3 = v2

	if v3 == nil or not v3.getLiveOpsState().initialized then
		return nil
	end

	local result = {}

	for _, v4 in v3.getLiveOpsModules() do
		table.insert(result, (makeDriver(v4)))
	end

	return result
end

function LegacyAdapter.startLocally(name: string, p2: number?)
	local v3 = v2
	local driver = findDriver(name)

	if v3 == nil or driver == nil then
		if v3 == nil then
			return false, "Legacy AdminAbuseServer is unavailable"
		end

		return false, (`Unknown Admin Abuse module '{name}'`)
	else
		local liveOpsState = v3.getLiveOpsState()
		local module

		if driver.info.slot == "main" then
			module = liveOpsState.module
		else
			module = liveOpsState.eventModule
		end

		if module then
			return false, (`Admin Abuse slot '{driver.info.slot}' is occupied by '{module}'`)
		end

		local durationSeconds

		if driver.usesDuration then
			local defaultDurationSeconds = driver.info.defaultDurationSeconds
			local maxDurationSeconds = driver.info.maxDurationSeconds
			durationSeconds = p2 or defaultDurationSeconds

			if durationSeconds == nil or durationSeconds ~= durationSeconds or durationSeconds == 1e999 or durationSeconds == -1e999 or durationSeconds <= 0 then
				durationSeconds = nil
			elseif maxDurationSeconds ~= nil then
				if maxDurationSeconds == maxDurationSeconds and maxDurationSeconds ~= 1e999 and not (maxDurationSeconds <= 0) then
					durationSeconds = math.min(durationSeconds, maxDurationSeconds)
				else
					durationSeconds = nil
				end
			end
		end

		local now = os.time()
		local v5 = {
			id = nil,
			name = name,
			slot = driver.info.slot,
			startedAt = now,
			durationSeconds = durationSeconds,
			isCatchUp = false,
			runtimeData = nil
		}
		local v6 = driver.prepare and driver.prepare(v5)

		if v6 then
			v5.runtimeData = v6.runtimeData
		end

		return driver.start(v5)
	end
end

function LegacyAdapter.stopLocally(p: string)
	local v3 = v2

	if v3 == nil then
		return false, "Legacy AdminAbuseServer is unavailable"
	end

	local liveOpsState = v3.getLiveOpsState()

	if liveOpsState.module ~= p and liveOpsState.eventModule ~= p then
		return false, (`Admin Abuse module '{p}' is not active in this server`)
	end

	local success, result = pcall(v3.stopLocally, p)

	if success and result == true then
		return true, nil
	end

	local v4 = false

	if success then
		return false, (`Legacy module '{p}' refused to stop locally`)
	end

	return v4, (tostring(result))
end

function LegacyAdapter.getActiveStates()
	local v3 = v2

	if v3 == nil then
		return {}
	end

	local liveOpsState = v3.getLiveOpsState()
	local now = os.time()
	local v4 = {}

	if liveOpsState.active and liveOpsState.module then
		local durationSeconds

		if liveOpsState.untilTs then
			durationSeconds = math.max(0, liveOpsState.untilTs - now)
		end

		table.insert(v4, {
			name = liveOpsState.module,
			source = "legacy",
			slot = "main",
			startedAt = now,
			durationSeconds = durationSeconds,
			isGlobal = false
		})
	end

	if liveOpsState.eventActive and liveOpsState.eventModule then
		local durationSeconds

		if liveOpsState.eventUntilTs then
			durationSeconds = math.max(0, liveOpsState.eventUntilTs - now)
		end

		table.insert(v4, {
			name = liveOpsState.eventModule,
			source = "legacy",
			slot = "event",
			startedAt = now,
			durationSeconds = durationSeconds,
			isGlobal = false
		})
	end

	return v4
end

function LegacyAdapter.stopSlotLocally(p)
	if p == "overlay" then
		return true, nil
	end

	local v3 = v2

	if v3 == nil then
		return false, "Legacy AdminAbuseServer is unavailable"
	end

	local liveOpsState = v3.getLiveOpsState()
	local module

	if p == "main" then
		module = liveOpsState.module
	else
		module = liveOpsState.eventModule
	end

	if module == nil then
		return true, nil
	end

	local success, result = pcall(v3.stopLocally, module)

	if success and result == true then
		return true, nil
	end

	local v4 = false

	if success then
		return false, (`Legacy module '{module}' refused to stop locally`)
	end

	return v4, (tostring(result))
end

return LegacyAdapter