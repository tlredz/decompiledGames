local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local GameSdkShared = require(ReplicatedStorage.Packages.GameSdkShared)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local ABTest = require(GameSdkShared.Modules.ABTest)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local VehicleEvents = require(ReplicatedStorage.Modules.Shared.Game.Vehicles.VehicleEvents)
local VehicleControlsTestController = {}
local scope = Fusion.scoped(Fusion)
local value = scope:Value(true)
local value2 = scope:Value(false)
local computed = scope:Computed(function(use)
	return use(value) and use(value2)
end)
local pedals = false
local steerbuttons = false

-- equivalent calls inferred from this helper; original call sites unknown
local function getDriveSetting()
	if Fusion.peek(computed) ~= true or UserInputService.PreferredInput ~= Enum.PreferredInput.Touch then
		return "default"
	end

	if pedals == true and steerbuttons == true then
		return "pedalsAndSteerButtons"
	end

	if pedals == true then
		return "pedals"
	end

	if steerbuttons == true then
		return "steerButtons"
	end

	return "default"
end

-- equivalent calls inferred from this helper; original call sites unknown
local function reportDriveSetting()
	Remotes.fireServer(VehicleEvents.SET_DRIVE_SETTING, getDriveSetting())
end

function VehicleControlsTestController.HasPedals()
	return pedals
end

function VehicleControlsTestController.HasSteerButtons()
	return steerbuttons
end

function VehicleControlsTestController.SetEnabled(flag: boolean)
	value:set(flag)
	reportDriveSetting() -- equivalent call inferred; original call site unknown
end

function VehicleControlsTestController.IsEnabledValue()
	return value
end

function VehicleControlsTestController.IsVisibleValue()
	return computed
end

function VehicleControlsTestController.IsSettingVisibleValue()
	return value2
end

function VehicleControlsTestController.FrameworkInit() end

function VehicleControlsTestController.FrameworkStart()
	if not UserInputService.TouchEnabled then
		return
	end

	UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(reportDriveSetting)
	VehicleControlsTestController.SetupVariables()
	VehicleControlsTestController.SetupCharacterListener()
end

function VehicleControlsTestController.SetupCharacterListener()
	if not Fusion.peek(value2) then
		return
	end

	local maid = Janitor.new()
	local maid2 = maid:Add(Janitor.new())

	local function onCharacterAdded(character)
		local humanoid = character:WaitForChild("Humanoid")

		-- equivalent calls inferred from this helper; original call sites unknown
		local function checkSeat(_)
			local seatPart = humanoid.SeatPart

			if seatPart ~= nil and seatPart:IsA("VehicleSeat") and seatPart:HasTag("VehicleDriverSeatClient") then
				PanelController.Open("MainGUIHandler", "VehicleControls")
				maid:Destroy()
			end
		end

		maid2:Cleanup()
		maid2:Add(humanoid:GetPropertyChangedSignal("SeatPart"):Connect(function()
			checkSeat() -- equivalent call inferred; original call site unknown
		end))
		checkSeat() -- equivalent call inferred; original call site unknown
	end

	local localPlayer = Players.LocalPlayer
	maid:Add(localPlayer.CharacterAdded:Connect(onCharacterAdded))
	maid:Add(localPlayer.CharacterRemoving:Connect(function()
		maid2:Cleanup()
	end))

	if localPlayer.Character ~= nil then
		onCharacterAdded(localPlayer.Character)
	end
end

function VehicleControlsTestController.SetupVariables()
	local v, v2 = ABTest.GetExperimentVariables("vehicle-controls"):timeout(10):await()

	if not (v and v2.enabled) then
		return
	end

	pedals = v2.pedals
	steerbuttons = v2["steer-buttons"]
	value2:set(true)
	reportDriveSetting() -- equivalent call inferred; original call site unknown
end

return VehicleControlsTestController