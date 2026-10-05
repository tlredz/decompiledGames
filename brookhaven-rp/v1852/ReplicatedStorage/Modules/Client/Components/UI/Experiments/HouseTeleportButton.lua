local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local HouseViewCamera = require(ReplicatedStorage.Modules.Client.Components.UI.Panels.House.HouseViewCamera)
local TelemetryController = require(ReplicatedStorage.Modules.Client.Telemetry.TelemetryController)
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local NewUserDataController = require(ReplicatedStorage.Modules.Client.Util.NewUserDataController)
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local GameSdkShared = require(ReplicatedStorage.Packages.GameSdkShared)
local ABTest = require(GameSdkShared.Modules.ABTest)
local v = Component.new({
	Tag = "HouseTeleportButton"
})
local _1Gettin1gHous1e = nil

function v:Construct()
	self._Janitor = Janitor.new()
	_1Gettin1gHous1e = ReplicatedStorage.RE:WaitForChild("1Gettin1gHous1e")
end

function v:Start()
	if not NewUserDataController.IsFirstSession() then
		return
	end

	local v2, v3 = ABTest.GetExperimentVariable("house-click-teleport", "teleport"):timeout(3):await()

	if not (v2 and v3) then
		return
	end

	local instance = self.Instance

	if not instance:IsA("GuiButton") then
		return
	end

	instance:RemoveTag("TogglePanelButton")
	local Workspace = game:GetService("Workspace")
	local _001_MapCameras = Workspace:WaitForChild("WorkspaceCom"):WaitForChild("001_MapCameras")
	self._Janitor:Add(instance.Activated:Connect(function()
		if instance:HasTag("TogglePanelButton") then
			return
		end

		if PanelController.IsOpen("MainGUIHandler", "MainNoHouseMenu") then
			PanelController.Close("MainGUIHandler", "MainNoHouseMenu")
			return
		end

		local lotId = 1

		while _001_MapCameras["House" .. lotId].HouseOwned.Value do
			lotId += 1

			if not (lotId > 14) then
				continue
			end

			PanelController.OpenPanelByContext("MainGUIHandler", "MainNoHouseMenu")
			return
		end

		local localPlayer = Players.LocalPlayer
		local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()

		if character == nil then
			return
		end

		local position = character:GetPivot().Position

		if not HouseViewCamera.TeleportPlayerToCameraStatic(_001_MapCameras["House" .. lotId]) then
			return
		end

		TelemetryController.SendClientInteraction("teleportLot", {
			lotId = lotId,
			playerLocaition = position
		})
	end))
	self._Janitor:Add(_1Gettin1gHous1e.OnClientEvent:Connect(function(p2: string, _, _: string)
		if p2 == "HouseSold" then
			instance:RemoveTag("TogglePanelButton")
		elseif p2 == "BuyHouseSetUpUI" then
			instance:AddTag("TogglePanelButton")
		end
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v