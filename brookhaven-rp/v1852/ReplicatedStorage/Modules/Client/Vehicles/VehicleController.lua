local VehicleController = {}
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VehicleRequests = require(ReplicatedStorage.Modules.Shared.Game.Vehicles.VehicleRequests)
local VehicleEvents = require(ReplicatedStorage.Modules.Shared.Game.Vehicles.VehicleEvents)
local TurboRatios = require(ReplicatedStorage.Modules.Shared.Game.Vehicles.TurboRatios)
local NotificationController = require(ReplicatedStorage.Modules.Client.UI.NotificationController)
require(ReplicatedStorage.Modules.Shared.Game.Vehicles.VehicleState)
local VehicleSpeedUtil = require(ReplicatedStorage.Modules.Shared.Game.Vehicles.VehicleSpeedUtil)
local GamepassController = require(ReplicatedStorage.Modules.Client.UI.Gamepass.GamepassController)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local Signal = require(ReplicatedStorage.Packages.Signal)
VehicleController.OnVehicleSpawned = Signal.new()
VehicleController.OnVehicleDespawned = Signal.new()
VehicleController.OnPlayerStartedDriving = Signal.new()
VehicleController.OnPlayerStoppedDriving = Signal.new()
VehicleController.OnPlayerStartedDrivingLegacy = Signal.new()
VehicleController.OnPlayerStoppedDrivingLegacy = Signal.new()
VehicleController.OnMaxSpeedChanged = Signal.new()
VehicleController.OnDriftStrengthChanged = Signal.new()
VehicleController.OnLockStateChanged = Signal.new()
VehicleController.OnPromptColorGamepassNeeded = Signal.new()
VehicleController.OnTurboChanged = Signal.new()
VehicleController.OnTextChanged = Signal.new()
VehicleController.OnTextColorChanged = Signal.new()
VehicleController.OnTextEditRequested = Signal.new()
VehicleController.OnSuspensionHeightChanged = Signal.new()
VehicleController.OnUnderglowChanged = Signal.new()
VehicleController.OnUnderglowSizeChanged = Signal.new()
VehicleController.OnNoMotorVehicleSpeedChanged = Signal.new()
VehicleController.OnNoMotorVehicleExited = Signal.new()
VehicleController.OnBoostChanged = Signal.new()
local v = {}
local v2 = nil
local v3 = {}
local v4 = {}

function VehicleController.PredictValue(object, p: number)
	if v2 == nil then
		return
	end

	v3[object] = true
	v4[object] = nil
	object:Fire(v2, p)
end

function VehicleController.AcceptServerValue(object, value: number?)
	v3[object] = false

	if typeof(value) ~= "number" then
		value = v4[object]
	end

	v4[object] = nil

	if typeof(value) == "number" and v2 ~= nil then
		object:Fire(v2, value)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function applyRemoteValue(object, p: string, p2: number)
	if p == v2 and v3[object] == true then
		v4[object] = p2
	else
		object:Fire(p, p2)
	end
end

local v5 = nil

function VehicleController.IsPlayerDriving()
	return not VehicleController.GetCurrentNonMotorVehicle() and v2 ~= nil
end

function VehicleController.IsPlayerDrivingAirVehicle()
	local character = Players.LocalPlayer.Character

	if not character then
		return false
	end

	local humanoid = character:FindFirstChild("Humanoid")

	if not (humanoid and humanoid.SeatPart) then
		return false
	end

	local parent = humanoid.SeatPart.Parent

	if not parent then
		return false
	end

	if parent:HasTag("Helicopter") or parent:HasTag("HotAirBalloon") then
		return true
	end

	return false
end

function VehicleController.GetCurrentSpawnedVehicles()
	return v
end

function VehicleController.IsVehicleSpawned(p: string)
	return v[p] ~= nil
end

function VehicleController.HasVehiclesSpawned()
	return next(v) ~= nil
end

function VehicleController.IsDrivingOwnedVehicle()
	local currentDrivingVehicleModel = VehicleController.GetCurrentDrivingVehicleModel()

	if not currentDrivingVehicleModel then
		return false
	end

	local owner = currentDrivingVehicleModel:FindFirstChild("Owner")

	if owner then
		return owner.Value == Players.LocalPlayer.Name
	end

	return false
end

function VehicleController.SetColor(p: string, color: Color3)
	local v6, v7 = Remotes.invokeServer(VehicleRequests.SET_COLOR, p, color)

	if v6 then
		return true
	end

	return false, v7
end

function VehicleController.GetVehicleUuidFromInstance(instance)
	if instance then
		return instance:GetAttribute("VehicleUuid")
	end

	return ""
end

function VehicleController.SpawnVehicle(p: string)
	local v6, v7, v8 = Remotes.invokeServer(VehicleRequests.SPAWN_VEHICLE, p)

	if not v6 then
		NotificationController.Notify(v7)
		return false
	end

	v[v8.uuid] = v8
	VehicleController.OnVehicleSpawned:Fire(v8)
	return true
end

function VehicleController.DespawnVehicle(p: string)
	local v6, v7 = Remotes.invokeServer(VehicleRequests.DESPAWN_VEHICLE, p)

	if not v6 then
		warn("Failed to despawn vehicle: " .. v7)
		return false
	end

	v[p] = nil
	VehicleController.OnVehicleDespawned:Fire(p)
	return true
end

function VehicleController.RepositionVehicle()
	local v6, _ = Remotes.invokeServer(VehicleRequests.REPOSITION_VEHICLE)

	if v6 then
		return true
	end

	return false
end

function VehicleController.SetMaxSpeed(p: number)
	local v6, _, v7 = Remotes.invokeServer(VehicleRequests.SET_MAX_SPEED, p)

	if v6 then
		return true, v7
	end

	return false, 25
end

function VehicleController.GetCurrentMaxSpeed()
	local currentDrivingVehicleModel = VehicleController.GetCurrentDrivingVehicleModel()

	if currentDrivingVehicleModel == nil then
		return 25
	end

	local seats = currentDrivingVehicleModel:FindFirstChild("Seats")
	local vehicleSeat = seats and seats:FindFirstChildOfClass("VehicleSeat")
	local maxSpeed = vehicleSeat and vehicleSeat:FindFirstChild("MaxSpeed")

	if maxSpeed == nil or not maxSpeed:IsA("NumberValue") then
		return 25
	end

	return maxSpeed.Value
end

function VehicleController.GetMaxSpeedAllowed()
	GamepassController.WaitForGamepasses()
	return VehicleSpeedUtil.GetMaxSpeedForPlayer(Players.LocalPlayer)
end

function VehicleController.AddMaxSpeed(p: number)
	local v6, v7, v8, v9 = Remotes.invokeServer(VehicleRequests.ADD_MAX_SPEED, p)

	if v6 then
		return true, v8, v9
	end

	warn("Failed to add max speed: " .. v7)
	return false, 25
end

function VehicleController.SetNextSuspensionHeight()
	local v6, _ = Remotes.invokeServer(VehicleRequests.SET_NEXT_SUSPENSION_HEIGHT)

	if v6 then
		return true
	end

	return false
end

function VehicleController.GetCurrentDriftStrength()
	local currentDrivingVehicleModel = VehicleController.GetCurrentDrivingVehicleModel()

	if not currentDrivingVehicleModel then
		return 1
	end

	local driftStrength = currentDrivingVehicleModel:GetAttribute("DriftStrength")

	if typeof(driftStrength) == "number" then
		return driftStrength
	end

	return 1
end

function VehicleController.GetCurrentTurboLevel(p)
	local v6 = p or VehicleController.GetCurrentDrivingVehicleModel()

	if not v6 then
		return 0
	end

	local turboLevel = v6:GetAttribute("TurboLevel")

	if typeof(turboLevel) == "number" then
		return turboLevel
	end

	local seats = v6:FindFirstChild("Seats")
	local vehicleSeat = seats and seats:FindFirstChildOfClass("VehicleSeat")
	local turbo = vehicleSeat and vehicleSeat:FindFirstChild("Turbo")

	if turbo == nil then
		return 0
	end

	local value = tonumber(turbo.Value)

	if value == nil then
		return 0
	end

	local v7 = 1e999
	local v8 = 0

	for k, turboRatio in TurboRatios do
		local v9 = math.abs(value - turboRatio)

		if not (v9 < v7) then
			continue
		end

		v8 = k
		v7 = v9
	end

	return v8
end

function VehicleController.GetSuspensionLevelCount(p)
	local v6 = p or VehicleController.GetCurrentDrivingVehicleModel()

	if not v6 then
		return 1
	end

	local suspensionHeights = v6.Config:FindFirstChild("SuspensionHeights")

	if suspensionHeights == nil then
		return 1
	end

	local v7 = {}

	for _, numberValue in suspensionHeights:GetChildren() do
		if numberValue:IsA("NumberValue") then
			table.insert(v7, numberValue.Value)
		end
	end

	table.sort(v7)
	local v8 = nil
	local count = 0

	for _, v9 in v7 do
		if not (v8 == nil or math.abs(v9 - v8) >= 0.001) then
			continue
		end

		count += 1
		v8 = v9
	end

	if count < 1 then
		return 1
	end

	return count
end

function VehicleController.GetDefaultSuspensionLevel(p)
	local v6 = p or VehicleController.GetCurrentDrivingVehicleModel()

	if not v6 then
		return 1
	end

	local suspensionLevel = v6:GetAttribute("SuspensionLevel")

	if typeof(suspensionLevel) == "number" then
		return suspensionLevel
	end

	local suspensionHeights = v6.Config:FindFirstChild("SuspensionHeights")

	if suspensionHeights == nil then
		return 1
	end

	local v7 = {}
	local value = nil

	for _, numberValue in suspensionHeights:GetChildren() do
		if not numberValue:IsA("NumberValue") then
			continue
		end

		table.insert(v7, numberValue.Value)

		if numberValue:GetAttribute("isDefault") == true then
			value = numberValue.Value
		end
	end

	table.sort(v7)

	if value == nil then
		return 1
	end

	for k, v8 in v7 do
		if math.abs(v8 - value) < 0.001 then
			return k
		end
	end

	return 1
end

function VehicleController.SetSuspensionLevel(p: number)
	local v6, _ = Remotes.invokeServer(VehicleRequests.SET_SUSPENSION_LEVEL, p)

	if v6 then
		return true
	end

	return false
end

function VehicleController.AddSuspensionLevel(p: number)
	local v6, _ = Remotes.invokeServer(VehicleRequests.ADD_SUSPENSION_LEVEL, p)

	if v6 then
		return true
	end

	return false
end

function VehicleController.AddDriftStrength(p: number)
	local v6, _ = Remotes.invokeServer(VehicleRequests.ADD_DRIFT_STRENGTH, p)

	if v6 then
		return true
	end

	return false
end

function VehicleController.SetDriftStrength(p: number)
	local v6, _ = Remotes.invokeServer(VehicleRequests.SET_DRIFT_STRENGTH, p)

	if v6 then
		return true
	end

	return false
end

function VehicleController.SetVehicleState(p: string, p2: string)
	local v6, _ = Remotes.invokeServer(VehicleRequests.SET_VEHICLE_STATE, p, p2)

	if v6 then
		return true
	end

	return false
end

function VehicleController.DetachComponent(p: string)
	local v6, v7 = Remotes.invokeServer(VehicleRequests.DETACH_COMPONENT, p)

	if v6 then
		return true, v7
	end

	return false
end

function VehicleController.SetWheelDecal(p: string)
	local v6, _ = Remotes.invokeServer(VehicleRequests.SET_WHEEL_DECAL, p)

	if v6 then
		return true
	end

	return false
end

function VehicleController.SetVehiclePanel(p)
	if v2 == nil then
		return
	end

	v5 = p
end

function VehicleController.GetVehiclePanel()
	local lastTime = os.clock()

	while not v5 and os.clock() - lastTime < 10 do
		task.wait()
	end

	if v5 then
		return v5
	end

	warn("Failed to get vehicle panel")
	return nil
end

function VehicleController.ToggleOnFire()
	local v6, _ = Remotes.invokeServer(VehicleRequests.TOGGLE_ON_FIRE)

	if v6 then
		return true
	end

	return false
end

function VehicleController.ToggleEngineSmoke()
	local v6, _ = Remotes.invokeServer(VehicleRequests.TOGGLE_ENGINE_SMOKE)

	if v6 then
		return true
	end

	return false
end

function VehicleController.ToggleHazardLights(_: string)
	local v6, _ = Remotes.invokeServer(VehicleRequests.TOGGLE_HAZARD_LIGHTS)

	if v6 then
		return true
	end

	return false
end

function VehicleController.ToggleHeadLights()
	local v6, _ = Remotes.invokeServer(VehicleRequests.TOGGLE_HEAD_LIGHTS)

	if v6 then
		return true
	end

	return false
end

function VehicleController.PlayHorn()
	local v6, _ = Remotes.invokeServer(VehicleRequests.PLAY_HORN)

	if v6 then
		return true
	end

	return false
end

function VehicleController.StopHorn()
	local v6, _ = Remotes.invokeServer(VehicleRequests.STOP_HORN)

	if v6 then
		return true
	end

	return false
end

function VehicleController.PlayDukeSound(p: number)
	local v6, v7 = Remotes.invokeServer(VehicleRequests.PLAY_DUKE_SOUND, p)

	if v6 then
		return true, v7
	end

	return false
end

function VehicleController.ToggleEmergencySiren()
	local v6, v7 = Remotes.invokeServer(VehicleRequests.TOGGLE_EMERGENCY_SIREN)

	if v6 == true then
		return true, v7 == true
	end

	return false
end

function VehicleController.ToggleVehicleMusic()
	local v6, _ = Remotes.invokeServer(VehicleRequests.TOGGLE_VEHICLE_MUSIC)

	if v6 then
		return true
	end

	return false
end

function VehicleController.ToggleEmergencyLights()
	local v6, v7 = Remotes.invokeServer(VehicleRequests.TOGGLE_EMERGENCY_LIGHTS)

	if v6 == true then
		return true, v7 == true
	end

	return false
end

function VehicleController.ToggleLockState(p: string)
	local v6, _ = Remotes.invokeServer(VehicleRequests.TOGGLE_LOCK_STATE, p)

	if v6 then
		return true
	end

	return false
end

function VehicleController.FireTankCannon(p: string)
	local v6, _ = Remotes.invokeServer(VehicleRequests.FIRE_TANK_CANNON, p)

	if v6 then
		return true
	end

	return false
end

function VehicleController.SetTurbo(p: number)
	local v6, _ = Remotes.invokeServer(VehicleRequests.SET_TURBO_APPEARANCE, p)

	if v6 then
		return true
	end

	return false
end

function VehicleController.SetBoost(flag: boolean)
	VehicleController.OnBoostChanged:Fire(VehicleController.GetCurrentDrivingVehicleUuid(), flag)
	Remotes.fireServer(VehicleEvents.SET_BOOST, flag)
	return true
end

function VehicleController.SetThrottleFloat(p: number?)
	Remotes.fireServer(VehicleEvents.SET_THROTTLE_FLOAT, p)
end

function VehicleController.SetBoostColor(p: number, color: Color3)
	local v6, _ = Remotes.invokeServer(VehicleRequests.SET_BOOST_COLOR, p, color)

	if v6 then
		return true
	end

	return false
end

function VehicleController.SetDefaultBoostColor()
	local v6, _ = Remotes.invokeServer(VehicleRequests.SET_DEFAULT_BOOST_COLOR)

	if v6 then
		return true
	end

	return false
end

function VehicleController.SetText(p: string, p2: string)
	local v6, _ = Remotes.invokeServer(VehicleRequests.SET_TEXT, p, p2)

	if v6 then
		return true
	end

	return false
end

function VehicleController.SetTextColor(p: string, color: Color3)
	local v6, _ = Remotes.invokeServer(VehicleRequests.SET_TEXT_COLOR, p, color)

	if v6 then
		return true
	end

	return false
end

function VehicleController.SetUnderglow(p: string)
	local v6, v7 = Remotes.invokeServer(VehicleRequests.SET_UNDERGLOW, p)

	if v6 then
		return true
	end

	return false, v7
end

function VehicleController.SetUnderglowColor(p: number, color: Color3)
	local v6, v7 = Remotes.invokeServer(VehicleRequests.SET_UNDERGLOW_COLOR, p, color)

	if v6 then
		return true
	end

	NotificationController.Notify(v7)
	return false
end

function VehicleController.SetUnderglowSize(p: number, p2: number)
	local v6, v7 = Remotes.invokeServer(VehicleRequests.SET_UNDERGLOW_SIZE, p, p2)

	if v6 then
		return true
	end

	NotificationController.Notify(v7)
	return false
end

function VehicleController.GetCurrentDrivingVehicleUuid()
	return v2
end

function VehicleController.GetVehicleModelFromInstance(instance)
	if not instance then
		return nil
	end

	if instance:HasTag("VehicleRoot") then
		return instance
	end

	return VehicleController.GetVehicleModelFromInstance(instance.Parent)
end

function VehicleController.GetCurrentDrivingVehicleModel()
	local localPlayer = Players.LocalPlayer

	if not localPlayer.Character then
		return nil
	end

	local humanoid = localPlayer.Character:FindFirstChild("Humanoid")

	if not humanoid then
		return nil
	end

	local seatPart = humanoid.SeatPart

	if seatPart then
		local parent = seatPart.Parent.Parent

		if not parent then
			return nil
		end

		if parent:HasTag("VehicleRoot") then
			return parent
		end

		return nil
	else
		local noMotorVehicleModel = localPlayer.Character:FindFirstChild("NoMotorVehicleModel")

		if not noMotorVehicleModel then
			return
		end

		if not noMotorVehicleModel:IsA("Model") then
			noMotorVehicleModel = noMotorVehicleModel.Value
		end

		return noMotorVehicleModel or nil
	end
end

function VehicleController.GetCurrentVehicleHorse()
	local localPlayer = Players.LocalPlayer

	if not (localPlayer.Character and localPlayer.Character:FindFirstChild("Humanoid")) then
		return nil
	end

	local character = localPlayer.Character

	if not character then
		return nil
	end

	for _, model in character:GetChildren() do
		if model:IsA("Model") and model:HasTag("HorseControl") then
			return model
		end
	end

	return nil
end

function VehicleController.GetCurrentNonMotorVehicle()
	local character = Players.LocalPlayer.Character

	if not character then
		return nil
	end

	local noMotorVehicleModel = character:FindFirstChild("NoMotorVehicleModel")

	if not noMotorVehicleModel then
		return nil
	end

	if noMotorVehicleModel:IsA("ObjectValue") then
		return noMotorVehicleModel.Value
	end

	return noMotorVehicleModel
end

function VehicleController.IsCurrentDrivingVehiclePorted()
	local currentDrivingVehicleModel = VehicleController.GetCurrentDrivingVehicleModel()

	if currentDrivingVehicleModel then
		return currentDrivingVehicleModel:FindFirstChild("Config") ~= nil
	end

	return false
end

function VehicleController.GetVehicleIcon(p: string)
	local v6 = v[p]

	if v6 then
		return v6.icon
	end

	warn("Vehicle not found")
end

function VehicleController.PutBabyInVehicle()
	local v6, v7 = Remotes.invokeServer(VehicleRequests.PUT_BABY_IN_VEHICLE)

	if v6 then
		return true
	end

	warn("Failed to put baby in vehicle: " .. v7)
	return false
end

function VehicleController.IncrementNoMotorVehicleSpeed(p: number)
	local v6, v7 = Remotes.invokeServer(VehicleRequests.INCREMENT_NO_MOTOR_VEHICLE_SPEED, p)

	if v6 then
		return true
	end

	warn("Failed to increment no motor vehicle speed: " .. v7)
	return false
end

function VehicleController.GetNoMotorVehicleSpeed()
	local v6 = Remotes.invokeServer(VehicleRequests.GET_NO_MOTOR_VEHICLE_SPEED)

	if v6 ~= nil then
		return v6
	end

	warn("Failed to get no motor vehicle speed")
end

function VehicleController.GetUnderglow()
	local currentDrivingVehicleUuid = VehicleController.GetCurrentDrivingVehicleUuid()

	if not currentDrivingVehicleUuid then
		return ""
	end

	if v[currentDrivingVehicleUuid] then
		return v[currentDrivingVehicleUuid].underglow or ""
	end

	return ""
end

function VehicleController.GetUnderglowColorsAmount()
	local currentDrivingVehicleUuid = VehicleController.GetCurrentDrivingVehicleUuid()

	if currentDrivingVehicleUuid then
		return v[currentDrivingVehicleUuid].underglowColorsAmount or 3
	end

	return 3
end

function VehicleController.SetNoMotorVehicleSpeed(p: number)
	local v6, v7 = Remotes.invokeServer(VehicleRequests.SET_NO_MOTOR_VEHICLE_SPEED, p)

	if v6 then
		return true
	end

	warn("Failed to set no motor vehicle speed: " .. v7)
	return false
end

function VehicleController.ExitNoMotorVehicle()
	VehicleController.OnNoMotorVehicleExited:Fire()
end

local function waitForVehiclePanel()
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local mainGUIHandler = playerGui:FindFirstChild("MainGUIHandler") or playerGui:WaitForChild("MainGUIHandler", 5)

	if not mainGUIHandler then
		warn("VehicleController: MainGUIHandler not found")
		return nil
	end

	local vehicleControl = mainGUIHandler:WaitForChild("VehicleControl", 5)

	if vehicleControl then
		return vehicleControl
	end

	warn("VehicleController: Vehicle panel did not arrive within timeout")
	return nil
end

function VehicleController.FrameworkInit() end

function VehicleController.FrameworkStart()
	Remotes.connect(VehicleEvents.PLAYER_SPAWNED_VEHICLE, function(p)
		v[p.uuid] = p
		VehicleController.OnVehicleSpawned:Fire(p)
	end)
	Remotes.connect(VehicleEvents.PLAYER_STARTED_DRIVING, function(p: string)
		v2 = p

		if VehicleController.GetCurrentNonMotorVehicle() then
			local noMotorVehicleSpeed = VehicleController.GetNoMotorVehicleSpeed()
			local humanoid = Players.LocalPlayer.Character:FindFirstChild("Humanoid")

			if noMotorVehicleSpeed and humanoid then
				humanoid.WalkSpeed = noMotorVehicleSpeed
				VehicleController.SetNoMotorVehicleSpeed(noMotorVehicleSpeed)
			end
		else
			waitForVehiclePanel()
			task.wait()
		end

		VehicleController.OnPlayerStartedDriving:Fire(p)
	end)
	Remotes.connect(VehicleEvents.PLAYER_STOPPED_DRIVING, function(p: string)
		VehicleController.SetBoost(false)
		v2 = nil
		table.clear(v3)
		table.clear(v4)
		VehicleController.OnPlayerStoppedDriving:Fire(p)
	end)
	Remotes.connect(VehicleEvents.PLAYER_STARTED_DRIVING_LEGACY, function(p: string)
		v2 = p
		VehicleController.OnPlayerStartedDrivingLegacy:Fire(p)
	end)
	Remotes.connect(VehicleEvents.PLAYER_STOPPED_DRIVING_LEGACY, function(p: string)
		v2 = nil
		VehicleController.OnPlayerStoppedDrivingLegacy:Fire(p)
	end)
	Remotes.connect(VehicleEvents.MAX_SPEED_CHANGED, function(p: string, p2: number)
		applyRemoteValue(VehicleController.OnMaxSpeedChanged, p, p2) -- equivalent call inferred; original call site unknown
	end)
	Remotes.connect(VehicleEvents.DRIFT_STRENGTH_CHANGED, function(p: string, p2: number)
		applyRemoteValue(VehicleController.OnDriftStrengthChanged, p, p2) -- equivalent call inferred; original call site unknown
	end)
	Remotes.connect(VehicleEvents.LOCK_STATE_CHANGED, function(p: string, flag: boolean)
		VehicleController.OnLockStateChanged:Fire(p, flag)
	end)
	Remotes.connect(VehicleEvents.PROMPT_COLOR_GAMEPASS_NEEDED, function(p: string, color: Color3)
		VehicleController.OnPromptColorGamepassNeeded:Fire(p, color)
	end)
	Remotes.connect(VehicleEvents.TEXT_CHANGED, function(p: string, p2: string)
		VehicleController.OnTextChanged:Fire(p, p2)
	end)
	Remotes.connect(VehicleEvents.TEXT_COLOR_CHANGED, function(p: string, color: Color3)
		VehicleController.OnTextColorChanged:Fire(p, color)
	end)
	Remotes.connect(VehicleEvents.TEXT_EDIT_REQUESTED, function(p: string)
		VehicleController.OnTextEditRequested:Fire(p)
	end)
	Remotes.connect(VehicleEvents.SUSPENSION_HEIGHT_CHANGED, function(p: string, p2: number)
		applyRemoteValue(VehicleController.OnSuspensionHeightChanged, p, p2) -- equivalent call inferred; original call site unknown
	end)
	Remotes.connect(VehicleEvents.VEHICLE_DESTROYED, function(p: string, _: string, _)
		v[p] = nil
	end)
	Remotes.connect(VehicleEvents.TURBO_CHANGED, function(p: string, p2: number)
		applyRemoteValue(VehicleController.OnTurboChanged, p, p2) -- equivalent call inferred; original call site unknown
	end)
	Remotes.connect(
		VehicleEvents.UNDERGLOW_CHANGED,
		function(p: string, underglow: string, underglowColorsAmount: number)
			if not p then
				return
			end

			if v[p] then
				v[p].underglow = underglow
				v[p].underglowColorsAmount = underglowColorsAmount
			end

			VehicleController.OnUnderglowChanged:Fire(p, underglow, underglowColorsAmount)
		end
	)
	Remotes.connect(VehicleEvents.UNDERGLOW_SIZE_CHANGED, function(p: string, p2: number, p3: number)
		if not p then
			return
		end

		VehicleController.OnUnderglowSizeChanged:Fire(p, p2, p3)
	end)
	Remotes.connect(VehicleEvents.NO_MOTOR_VEHICLE_SPEED_CHANGED, function(p: number)
		VehicleController.OnNoMotorVehicleSpeedChanged:Fire(p)
	end)
end

function VehicleController.GetVehicleVelocity(p: string)
	local v6 = v[p]

	if v6 then
		return v6.velocity
	end

	return 0
end

return VehicleController