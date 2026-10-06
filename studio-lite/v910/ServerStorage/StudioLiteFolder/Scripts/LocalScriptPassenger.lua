local ContextActionService = game:GetService("ContextActionService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local localPlayer = Players.LocalPlayer
local value = script:WaitForChild("CarValue", 99999).Value
local LocalVehicleSeating = require(value.Scripts.LocalVehicleSeating)
local Keymap = require(value.Scripts.Keymap)
local LocalVehicleGui = require(script.Parent:WaitForChild("LocalVehicleGui"))
LocalVehicleGui.new(value):Enable()

-- equivalent calls inferred from this helper; original call sites unknown
local function getLocalHumanoid()
	if localPlayer.Character then
		return localPlayer.Character:FindFirstChildOfClass("Humanoid")
	end
end

local function exitVehicle(_, p, _)
	if not (p == Enum.UserInputState.Begin and script:IsDescendantOf(game)) then
		return Enum.ContextActionResult.Pass
	end

	LocalVehicleSeating.ExitSeat()
	return Enum.ContextActionResult.Sink
end

local onExitSeat

onExitSeat = function(_)
	ContextActionService:UnbindAction("VehicleChassisExitVehiclePassenger")
	local localHumanoid = getLocalHumanoid() -- equivalent call inferred; original call site unknown

	if localHumanoid then
		Workspace.CurrentCamera.CameraSubject = localHumanoid
	end

	ProximityPromptService.Enabled = true
	LocalVehicleSeating.DisconnectFromSeatExitEvent(onExitSeat)
	script.Disabled = true
end

LocalVehicleSeating.OnSeatExitEvent(onExitSeat)
ContextActionService:BindAction(
	"VehicleChassisExitVehiclePassenger",
	exitVehicle,
	false,
	Keymap.EnterVehicleGamepad,
	Keymap.EnterVehicleKeyboard,
	Enum.KeyCode.ButtonA,
	Enum.KeyCode.Space
)

-- equivalent calls inferred from this helper; original call sites unknown
local function updateCameraSubject()
	local localHumanoid = getLocalHumanoid() -- equivalent call inferred; original call site unknown

	if localHumanoid then
		local _ = localHumanoid.SeatPart
	end
end

updateCameraSubject() -- equivalent call inferred; original call site unknown
ProximityPromptService.Enabled = false