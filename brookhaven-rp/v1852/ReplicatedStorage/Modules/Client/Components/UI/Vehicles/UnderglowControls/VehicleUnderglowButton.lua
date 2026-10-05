local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "VehicleUnderglowButton"
})
local VehicleController = require(ReplicatedStorage.Modules.Client.Vehicles.VehicleController)
local flag = false

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local GamepassController = require(ReplicatedStorage.Modules.Client.UI.Gamepass.GamepassController)
	local Gamepasses = require(ReplicatedStorage.Modules.Shared.PlayerData.Gamepasses)
	self._Janitor:Add(self.Instance.MouseButton1Click:Connect(function()
		if flag then
			return
		end

		local currentDrivingVehicleModel = VehicleController.GetCurrentDrivingVehicleModel()

		if currentDrivingVehicleModel == nil then
			return
		end

		local function setUnderglow()
			if VehicleController.GetCurrentDrivingVehicleModel() ~= currentDrivingVehicleModel then
				return
			end

			if currentDrivingVehicleModel:GetAttribute("IsBike") then
				local chassis = currentDrivingVehicleModel:FindFirstChild("Chassis")

				if not chassis then
					warn("VehicleUnderglowButton: Chassis not found")
					return
				end

				local wheelie = chassis:FindFirstChild("Wheelie")

				if not wheelie then
					warn("VehicleUnderglowButton: Wheelie value not found")
					return
				end

				if wheelie.Value == true then
					flag = false
					return
				end
			end

			local v2, v3 = VehicleController.SetUnderglow(self.Instance.Name)

			if not v2 then
				warn("Failed to set vehicle underglow: " .. v3)
			end
		end

		flag = true

		if GamepassController.IsOwned(Gamepasses.VEHICLE_CUSTOMIZATION) then
			setUnderglow()
			flag = false
		else
			local vehicleName = currentDrivingVehicleModel:GetAttribute("vehicleName")
			GamepassController.Show(
				Gamepasses.VEHICLE_CUSTOMIZATION,
				nil,
				"car underglow",
				nil,
				nil,
				nil,
				"Vehicle Underglow",
				vehicleName,
				setUnderglow
			)
			flag = false
		end
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v