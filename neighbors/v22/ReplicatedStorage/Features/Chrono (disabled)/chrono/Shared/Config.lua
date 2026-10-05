require(script.Parent.Types)
local RunService = game:GetService("RunService")
local isServer = RunService:IsServer()
local flag = false
local base_Config = {
	__VERSION = "v2.1.4",
	CHECK_NEW_VERSION = true,
	MAX_TOTAL_BYTES_PER_FRAME_PER_PLAYER = 300,
	MIN_BUFFER = 0.09,
	MAX_BUFFER = 0.5,
	GRID_UPDATE_INTERVAL = 0.1,
	GRID_MAX_UPDATE_TIME = 0.0005,
	WARNING_SEVERITY = "MEDIUM",
	DEFAULT_NORMAL_TICK_DISTANCE = 50,
	DEFAULT_HALF_TICK_DISTANCE = 100,
	REPLICATE_DEATHS = "PLAYER_CHARACTERS",
	REPLICATE_CFRAME_SETTERS = "PLAYER_ENTITIES",
	PLAYER_REPLICATION = "AUTOMATIC",
	DEFAULT_MODEL_REPLICATION_MODE = "NATIVE",
	MAX_SNAPSHOT_COUNT = 30
}
local values = {
	DEFAULT = {
		NAME = "DEFAULT",
		TICK_RATE = 0.05,
		BUFFER = 0.1
	},
	WITH_ROT = {
		NAME = "WITH_ROT",
		TICK_RATE = 0.05,
		BUFFER = 0.1,
		FULL_ROTATION = true
	},
	PLAYER = {
		NAME = "PLAYER",
		MODEL_REPLICATION_MODE = "NATIVE",
		BUFFER = 0,
		TICK_RATE = 0.05,
		ASSEMBLY_ROOT_PART_CHECK = true
	}
}
local models = {}
local v2 = {}

local function GetEntityType(p: string?)
	return p and values[p] or values.DEFAULT
end

local function GetEntityModel(p: string)
	if models[p] ~= nil then
		return models[p]
	end

	warn((`Entity model {p} not found in Config.`))
	return nil
end

local function GetBroadPhase(p: string)
	return v2[p]
end

local function GetConfig(p: string)
	return base_Config[p]
end

local callbacks = {}

local function WaitForLock(callback)
	if flag then
		callback()
	else
		table.insert(callbacks, callback)
	end
end

local function Lock()
	local Warn = require(script.Parent.Warn)
	Warn.low("Config is now locked")
	flag = true
	local DEFAULT_NORMAL_TICK_DISTANCE = base_Config.DEFAULT_NORMAL_TICK_DISTANCE
	local DEFAULT_HALF_TICK_DISTANCE = base_Config.DEFAULT_HALF_TICK_DISTANCE

	for k, v3 in values do
		local clone = table.clone(v3)
		clone.NAME = k
		clone.AUTO_UPDATE_POSITION = clone.AUTO_UPDATE_POSITION ~= false
		clone.FULL_ROTATION = clone.FULL_ROTATION or false
		clone.NORMAL_TICK_DISTANCE = clone.NORMAL_TICK_DISTANCE or DEFAULT_NORMAL_TICK_DISTANCE
		clone.HALF_TICK_DISTANCE = clone.HALF_TICK_DISTANCE or DEFAULT_HALF_TICK_DISTANCE
		clone.MODEL_REPLICATION_MODE = clone.MODEL_REPLICATION_MODE or base_Config.DEFAULT_MODEL_REPLICATION_MODE

		if isServer then
			local Ticker = require(script.Parent.Ticker)
			clone.TICKER = Ticker.new(clone)
		else
			clone.CLIENT_CLOCK = {}
		end

		values[k] = table.freeze(clone)
	end

	for _, v3 in callbacks do
		v3()
	end
end

local Config = {}

function Config.SetConfig(p, p2)
	assert(not flag, "Config is locked and cannot be modified after startup.")
	base_Config[p] = p2
end

function Config.RegisterEntityType(p: string, p2)
	assert(not flag, "Config is locked and cannot be modified after startup.")
	values[p] = p2
end

function Config.RegisterEntityModel(p: string, model, vector: Vector3?)
	if model ~= false and model:IsA("Model") and not model.PrimaryPart then
		error(p .. " must have a PrimaryPart to be registered as an entity model.")
	end

	models[p] = model
	v2[p] = vector
end

Config.FLAGS = {
	SERVER_VELOCITY_FIX = true,
	VELOCITY_CALC_FIX = true,
	SNAPSHOT_INTERPOLATION_FIX = true,
	SET_CFRAME_FIX = true,
	FIX_TELEPORT_JITTER = true
}
Config._EntityConfigs = values
Config._GetEntityType = GetEntityType
Config._GetEntityModel = GetEntityModel
Config._GetConfig = GetConfig
Config._Lock = Lock
Config._WaitForLock = WaitForLock
Config._GetBroadPhase = GetBroadPhase
Config._Base_Config = base_Config

function Config.SetModelPrimaryForChrono(instance, CHRONO_PRIMARY: string)
	instance:SetAttribute("__CHRONO_PRIMARY", CHRONO_PRIMARY)
end

function Config.SetWarningSeverity(WARNING_SEVERITY: string)
	if WARNING_SEVERITY ~= "NONE" and WARNING_SEVERITY ~= "LOW" and WARNING_SEVERITY ~= "MEDIUM" and WARNING_SEVERITY ~= "HIGH" then
		error("Invalid warning level: " .. tostring(WARNING_SEVERITY))
	end

	base_Config.WARNING_SEVERITY = WARNING_SEVERITY
end

return Config