local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local value = script:WaitForChild("CarValue", 99999).Value
local scripts = value:FindFirstChild("Scripts")
local Chassis = require(scripts:WaitForChild("Chassis"))
Chassis.InitializeDrivingValues()
Chassis.Reset()
local LocalVehicleGui = require(script.Parent:WaitForChild("LocalVehicleGui"))
local v = LocalVehicleGui.new(value)
v:Enable()
v:EnableDriverControls()
v:EnableSpeedo()
local Keymap = require(scripts.Keymap)
local inputTable = Keymap.newInputTable()
local LocalVehicleSeating = require(scripts.LocalVehicleSeating)

-- equivalent calls inferred from this helper; original call sites unknown
local function _clearInput()
	for k, _ in pairs(inputTable) do
		inputTable[k] = 0
	end
end

local driverSeat = Chassis.driverSeat

-- equivalent calls inferred from this helper; original call sites unknown
local function unbindActions()
	ContextActionService:UnbindAction("VehicleChassisRawInput")
	ContextActionService:UnbindAction("VehicleChassisExitVehicle")
end

local onExitSeat

onExitSeat = function(_)
	unbindActions() -- equivalent call inferred; original call site unknown
	_clearInput() -- equivalent call inferred; original call site unknown
	ProximityPromptService.Enabled = true
	LocalVehicleSeating.DisconnectFromSeatExitEvent(onExitSeat)
	script.Disabled = true
end

LocalVehicleSeating.OnSeatExitEvent(onExitSeat)
value.AncestryChanged:Connect(function()
	if not value:IsDescendantOf(Workspace) then
		unbindActions() -- equivalent call inferred; original call site unknown
		LocalVehicleSeating.ExitSeat()
		LocalVehicleSeating.DisconnectFromSeatExitEvent(onExitSeat)
		script.Disabled = true
		ProximityPromptService.Enabled = true
	end
end)

local function exitVehicle(_, p, _)
	if p == Enum.UserInputState.Begin then
		LocalVehicleSeating.ExitSeat()
	end
end

local function _updateRawInput(_, p, p2)
	local keyCode = p2.KeyCode
	local data = Keymap.getData(keyCode)

	if not data then
		return
	end

	local axis = data.Axis
	local v2

	if axis then
		v2 = p2.Position:Dot(axis)
	else
		v2 = (p == Enum.UserInputState.Begin or p == Enum.UserInputState.Change) and 1 or 0
	end

	inputTable[keyCode] = v2 * (data.Sign or 1)

	if data.Pass then
		return Enum.ContextActionResult.Pass
	end
end

local function _calculateInput(p)
	local v2 = Keymap[p]
	local v3 = 0
	local v4 = v3

	for _, v5 in ipairs(v2) do
		local v6 = inputTable[v5.KeyCode]

		if not (v4 < math.abs(v6)) then
			continue
		end

		v4 = math.abs(v6)
		v3 = v6
	end

	return v3
end

ContextActionService:BindAction(
	"VehicleChassisExitVehicle",
	exitVehicle,
	false,
	Keymap.EnterVehicleGamepad,
	Keymap.EnterVehicleKeyboard
)
ContextActionService:BindActionAtPriority(
	"VehicleChassisRawInput",
	_updateRawInput,
	false,
	Enum.ContextActionPriority.High.Value,
	unpack(Keymap.allKeys())
)

local function getInputValues()
	if UserInputService:GetLastInputType() == Enum.UserInputType.Touch then
		script.Throttle.Value = v.throttleInput
		script.Steering.Value = v.steeringInput
		script.HandBrake.Value = v.handBrakeInput
	else
		script.Throttle.Value = _calculateInput("Throttle") - _calculateInput("Brake")
		script.Steering.Value = _calculateInput("SteerLeft") + _calculateInput("SteerRight")
		script.HandBrake.Value = _calculateInput("Handbrake")
	end
end

ProximityPromptService.Enabled = false

while script.Parent ~= nil do
	getInputValues()
	local averageVelocity = Chassis.GetAverageVelocity()
	local value2 = script.Steering.Value
	Chassis.UpdateSteering(value2, averageVelocity)
	local value3 = script.Throttle.Value
	script.AngularMotorVelocity.Value = averageVelocity
	script.ForwardVelocity.Value = driverSeat.CFrame.LookVector:Dot(driverSeat.Velocity)
	Chassis.UpdateThrottle(averageVelocity, value3)

	if script.HandBrake.Value > 0 then
		Chassis.EnableHandbrake()
	end

	task.wait()
end