local VehicleHudTestController = {}
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local VisibilityController = require(ReplicatedStorage.Modules.Client.UI.VisibilityController)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local maid = nil
local v = nil

function VehicleHudTestController.FrameworkInit() end

function VehicleHudTestController.Show()
	PanelController.Open("MainGUIHandler", "MainButtons")
	maid:Cleanup()
end

function VehicleHudTestController.Hide()
	maid:Cleanup()
	PanelController.Close("MainGUIHandler", "StarterInstructions")
	PanelController.Close("NoResetGUIHandler", "AvatarEditorMenu")
	PanelController.ToggleGroup("RightSide", false)
	PanelController.Close("MainGUIHandler", "MainButtons")
	local instance = PanelController.GetPanel("NoResetGUIHandler", "TopCornerDetails"):GetInstance()
	maid:Add(VisibilityController.AddHideTicket(instance.CamOpen))
	maid:Add(VisibilityController.AddHideTicket(instance.FamilyOpenButton))
end

function VehicleHudTestController.FrameworkStart()
	maid = Janitor.new()
	v = false
	local localPlayer = Players.LocalPlayer

	-- equivalent calls inferred from this helper; original call sites unknown
	local function onCharacterAdded(character)
		character:WaitForChild("Humanoid").Seated:Connect(function(flag: boolean, instance)
			if flag and instance ~= nil and (instance:HasTag("TrackTimeSpentInVehicleSeat") or instance:HasTag("TrackTimeSpentInAirVehiclePilotSeat")) then
				VehicleHudTestController.Hide()
				v = true
			elseif not flag and v then
				VehicleHudTestController.Show()
				v = false
			end
		end)
	end

	if localPlayer.Character ~= nil then
		onCharacterAdded(localPlayer.Character) -- equivalent call inferred; original call site unknown
	end

	localPlayer.CharacterAdded:Connect(onCharacterAdded)
end

return VehicleHudTestController