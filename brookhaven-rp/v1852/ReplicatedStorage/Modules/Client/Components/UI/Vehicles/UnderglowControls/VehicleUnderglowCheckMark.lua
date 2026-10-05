local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "VehicleUnderglowCheckMark"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local VehicleController = require(ReplicatedStorage.Modules.Client.Vehicles.VehicleController)
	self._Janitor:Add(VehicleController.OnUnderglowChanged:Connect(function(_: string, p2: string)
		self.Instance.Visible = p2 == self.Instance.Parent.Name
	end))
	self._Janitor:Add(VehicleController.OnPlayerStartedDriving:Connect(function(p2: string)
		if VehicleController.GetCurrentDrivingVehicleUuid() ~= p2 then
			return
		end

		local underglow = VehicleController.GetUnderglow()

		if not (underglow and self.Instance.Parent) then
			return
		end

		self.Instance.Visible = underglow == self.Instance.Parent.Name
	end))
	self._Janitor:Add(VehicleController.OnPlayerStoppedDriving:Connect(function()
		self.Instance.Visible = false
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v