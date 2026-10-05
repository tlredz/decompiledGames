local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "VehicleSpeedIncreaseButton"
})
local VehicleSpeedUtil = require(ReplicatedStorage.Modules.Shared.Game.Vehicles.VehicleSpeedUtil)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local Panel = require(ReplicatedStorage.Modules.Client.Components.UI.Panels.Panel)
local VehicleUiInteractionTelemetryController = require(ReplicatedStorage.Modules.Client.Telemetry.VehicleUiInteractionTelemetryController)
local Players = game:GetService("Players")
local v2 = false
local v3 = 0

function v:HideSpeedPanel()
	local waitForAncestorComponent = ComponentUtil.FindAndWaitForAncestorComponent(self.Instance, "Panel", Panel)

	if waitForAncestorComponent then
		waitForAncestorComponent.Instance.Visible = false
	end
end

function v:ShowSpeedPanel()
	local waitForAncestorComponent = ComponentUtil.FindAndWaitForAncestorComponent(self.Instance, "Panel", Panel)

	if waitForAncestorComponent then
		waitForAncestorComponent.Instance.Visible = true
	end
end

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local UnlockableController = require(ReplicatedStorage.Modules.Client.PlayerData.UnlockableController)
	local GamepassController = require(ReplicatedStorage.Modules.Client.UI.Gamepass.GamepassController)
	local Gamepasses = require(ReplicatedStorage.Modules.Shared.PlayerData.Gamepasses)
	local PlayerFlag = require(ReplicatedStorage.Modules.Client.PlayerFlags.PlayerFlag)
	local instance = self.Instance

	if not (instance:IsA("TextButton") or instance:IsA("ImageButton")) then
		warn("VehicleSpeedIncreaseButton must be a TextButton or ImageButton")
		return
	end

	local VehicleController = require(ReplicatedStorage.Modules.Client.Vehicles.VehicleController)
	local AdFeatures = require(ReplicatedStorage.Modules.Shared.Advertisements.AdFeatures)
	self._Janitor:Add(instance.Activated:Connect(function()
		local incrementValue = self.Instance:GetAttribute("IncrementValue")

		if not incrementValue then
			warn("IncrementValue attribute not found")
			return
		end

		if not v2 then
			incrementValue = incrementValue > 0 and 15 or -5
		end

		v2 = true
		local v4, v5, v6 = VehicleController.AddMaxSpeed(incrementValue)

		if not v4 then
			warn("Failed to set max speed")
		elseif v6 and v3 == v5 then
			local currentDrivingVehicleModel = VehicleController.GetCurrentDrivingVehicleModel()

			if currentDrivingVehicleModel == nil then
				return
			end

			local vehicleName = currentDrivingVehicleModel:GetAttribute("vehicleName")

			local function callback()
				if VehicleController.GetCurrentDrivingVehicleModel() ~= currentDrivingVehicleModel then
					return
				end

				local v7, v8, _ = VehicleController.AddMaxSpeed(incrementValue)

				if v7 then
					self:ShowSpeedPanel()
					v3 = v8
					local v9 = incrementValue > 0 and "Increase Speed" or "Decrease Speed"
					VehicleUiInteractionTelemetryController.Fire("Speed", v9)
				end
			end

			if v5 == VehicleSpeedUtil.DEFAULT_MAX_SPEED then
				if not UnlockableController.IsFeatureUnlocked(
					AdFeatures.VEHICLE_SPEED_UPGRADE.id,
					Gamepasses.VEHICLE_UPGRADE
				) then
					self:HideSpeedPanel()

					if PlayerFlag.IsEnabled("vehicle-upgrade-removed") then
						GamepassController.Show(
							Gamepasses.VEHICLE_SPEED_UNLOCKED,
							nil,
							"car speed",
							nil,
							AdFeatures.VEHICLE_SPEED_MAX,
							nil,
							"Vehicle Controls",
							vehicleName,
							callback
						)
					else
						GamepassController.Show(
							Gamepasses.VEHICLE_UPGRADE,
							"5112217484",
							"car speed",
							nil,
							AdFeatures.VEHICLE_SPEED_UPGRADE,
							nil,
							"Vehicle Controls",
							vehicleName,
							callback
						)
					end
				end
			elseif v5 == VehicleSpeedUtil.VEHICLE_UPGRADE_MAX_SPEED then
				if not UnlockableController.IsFeatureUnlocked(
					AdFeatures.VEHICLE_SPEED_MAX.id,
					Gamepasses.VEHICLE_SPEED_UNLOCKED
				) then
					self:HideSpeedPanel()
					GamepassController.Show(
						Gamepasses.VEHICLE_SPEED_UNLOCKED,
						nil,
						"car speed",
						nil,
						AdFeatures.VEHICLE_SPEED_MAX,
						nil,
						"Vehicle Controls",
						vehicleName,
						callback
					)
				end
			elseif v5 == VehicleSpeedUtil.PREMIUM_MAX_SPEED and not UnlockableController.IsFeatureUnlocked(
				AdFeatures.VEHICLE_SPEED_MAX.id,
				Gamepasses.VEHICLE_SPEED_UNLOCKED
			) then
				self:HideSpeedPanel()
				GamepassController.Show(
					Gamepasses.VEHICLE_SPEED_UNLOCKED,
					nil,
					"car speed",
					nil,
					AdFeatures.VEHICLE_SPEED_MAX,
					nil,
					"Vehicle Controls",
					vehicleName,
					callback
				)
			end
		else
			v3 = v5
			local v7 = incrementValue > 0 and "Increase Speed" or "Decrease Speed"
			VehicleUiInteractionTelemetryController.Fire("Speed", v7)
		end
	end))
	local backgroundColor3 = self.Instance.BackgroundColor3

	local function updatePlusColor(p: number)
		if self.Instance:GetAttribute("IncrementValue") <= 0 then
			return
		end

		local maxSpeedForPlayer = VehicleSpeedUtil.GetMaxSpeedForPlayer(Players.LocalPlayer)

		if p == maxSpeedForPlayer and maxSpeedForPlayer < VehicleSpeedUtil.VEHICLE_SPEED_UNLOCKED_MAX_SPEED then
			self.Instance.BackgroundColor3 = Color3.fromRGB(133, 255, 80)
		else
			self.Instance.BackgroundColor3 = backgroundColor3
		end
	end

	self._Janitor:Add(VehicleController.OnMaxSpeedChanged:Connect(function(p: string, p2: number)
		if p ~= VehicleController.GetCurrentDrivingVehicleUuid() then
			return
		end

		updatePlusColor(p2)
	end))

	local function refreshPlusColorFromUnlock()
		if VehicleController.GetCurrentDrivingVehicleUuid() == nil then
			return
		end

		updatePlusColor(VehicleController.GetCurrentMaxSpeed())
	end

	self._Janitor:Add(GamepassController.OnGamepassUnlocked:Connect(refreshPlusColorFromUnlock))
	self._Janitor:Add(UnlockableController.OnItemUnlocked:Connect(refreshPlusColorFromUnlock))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v