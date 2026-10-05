local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "HovercraftOceanDetector"
})
local VehicleRoot = require(ReplicatedStorage.Modules.Client.Components.Vehicles.VehicleRoot)
require(ReplicatedStorage.Modules.Client.Components.Vehicles.VehicleBoatSplash)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local v2 = {
	"OceanFloorHole",
	"OceanBottom",
	"OceanEnd",
	"WaterHole",
	"MainBottomBlue"
}

function v:IsOnOcean()
	local characters = { self.Instance }

	for _, v3 in Players:GetPlayers() do
		if v3.Character then
			table.insert(characters, v3.Character)
		end
	end

	self._raycastParams.FilterDescendantsInstances = characters
	local raycastResult = workspace:Raycast(self.Instance.Position, createVector(0, -10, 0), self._raycastParams)

	if not raycastResult then
		return false
	end

	if table.find(v2, raycastResult.Instance.Name) then
		return true
	end

	return false
end

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	self._raycastParams = RaycastParams.new()
	self._raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	self._raycastParams.FilterDescendantsInstances = { self.Instance }
	self._vehicleRoot = ComponentUtil.FindAndWaitForAncestorComponent(self.Instance, "VehicleRoot", VehicleRoot)

	if not self._vehicleRoot then
		warn("HovercraftOceanDetector has no VehicleRoot component")
		return
	end

	self._wheels = self._vehicleRoot.Instance:WaitForChild("Chassis", 5):FindFirstChild("Wheels")
	self._vehicleBoatSplashComponents = self._vehicleRoot.Instance:WaitForChild("Body", 5):WaitForChild("Splashes", 5):GetDescendants()
	self._Janitor:Add(task.spawn(function()
		while true do
			local isOnOcean = self:IsOnOcean()

			for _, emitter in self._vehicleBoatSplashComponents do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = isOnOcean
				end
			end

			task.wait(0.5)
		end
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v