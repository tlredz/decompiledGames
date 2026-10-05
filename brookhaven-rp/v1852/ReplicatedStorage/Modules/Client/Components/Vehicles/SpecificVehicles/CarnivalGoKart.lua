local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local VehicleController = require(ReplicatedStorage.Modules.Client.Vehicles.VehicleController)
local v = Component.new({
	Tag = "CarnivalGoKart"
})
local v2 = { "VehicleHornButton", "VehicleRepositionButton" }

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	self._Janitor:Add(VehicleController.OnPlayerStartedDriving:Connect(function(p2: string)
		if VehicleController.GetVehicleUuidFromInstance(self.Instance) ~= p2 then
			return
		end

		task.defer(function()
			local vehiclePanel = VehicleController.GetVehiclePanel()

			if vehiclePanel == nil then
				return
			end

			vehiclePanel:SetVisibleCarButtonTags(v2)
			vehiclePanel:SetBoostDisabled(true)
		end)
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v