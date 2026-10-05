local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Telemetry = {
	_remote = nil,
	_initialized = false
}

-- equivalent calls inferred from this helper; original call sites unknown
local function erroro(p)
	error("[GameSdk - Telemetry] " .. p)
end

local function _assertInitialized(flag: boolean, p: string)
	if Telemetry._initialized ~= flag then
		erroro(p) -- equivalent call inferred; original call site unknown
	end
end

function Telemetry.Init()
	if Telemetry._initialized ~= false then
		error("[GameSdk - Telemetry] Already initialized")
	end

	Telemetry._remote = ReplicatedStorage:WaitForChild("GameSdkTelemetryRemoteEvent", 20)

	if Telemetry._remote == nil then
		error("[GameSdk - Telemetry] Failed to find remote for client events")
	end

	Telemetry._initialized = true
end

function Telemetry.FireEvent(p: string, p2)
	if Telemetry._initialized ~= true then
		error("[GameSdk - Telemetry] Tried to fire client event before module is initialized, call initialize first")
	end

	Telemetry._remote:FireServer(p, p2)
end

function Telemetry.FireClientEvent(p: string, p2)
	Telemetry.FireEvent(p, p2)
end

function Telemetry.FireSampledEvent(p: number, p2: string, p3)
	if Telemetry._initialized ~= true then
		error("[GameSdk - Telemetry] Tried to fire client event before module is initialized, call initialize first")
	end

	if Players.LocalPlayer.UserId % 100 < p then
		Telemetry._remote:FireServer(p2, p3)
		return true
	else
		return false
	end
end

return Telemetry