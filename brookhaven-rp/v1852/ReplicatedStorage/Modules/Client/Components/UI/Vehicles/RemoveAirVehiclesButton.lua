local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
require(ReplicatedStorage.Modules.Shared.Game.Vehicles.VehicleRequests)
local v = Component.new({
	Tag = "RemoveAirVehiclesButton"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:RemoveVehicleByType()
	Remotes.fireServer("DespawnAirVehicles")
end

function v:Start()
	self._Janitor:Add(self.Instance.Activated:Connect(function()
		self:RemoveVehicleByType()
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v