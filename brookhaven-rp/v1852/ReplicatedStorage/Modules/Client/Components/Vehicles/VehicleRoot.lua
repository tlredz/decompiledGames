local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Signal = require(ReplicatedStorage.Packages.Signal)
local VehicleController = require(ReplicatedStorage.Modules.Client.Vehicles.VehicleController)
local VehicleBoostConstants = require(ReplicatedStorage.Modules.Shared.Game.Vehicles.VehicleBoostConstants)
local v = Component.new({
	Tag = "VehicleRoot"
})

function v:Construct()
	self._Janitor = Janitor.new()
	self.OnBoostChanged = Signal.new()
end

function v:GetVehicleUuid()
	if self.uuid then
		return self.uuid
	end

	local vehicleUuid = self.Instance:GetAttribute("VehicleUuid")

	if not vehicleUuid then
		return ""
	end

	self.uuid = vehicleUuid
	return vehicleUuid
end

function v:Start()
	self._Janitor:Add(VehicleController.OnBoostChanged:Connect(function(p: string, flag: boolean)
		if not (self.Instance:IsDescendantOf(workspace.Vehicles) and p == self:GetVehicleUuid()) then
			return
		end

		self:SetBoost(flag)
	end))
end

function v:SetBoost(boostEnabled: boolean)
	self.boostEnabled = boostEnabled
	self.OnBoostChanged:Fire(boostEnabled)
end

function v.GetBoostMultiplier(p)
	return p.boostEnabled and VehicleBoostConstants.MULTIPLIER or 1
end

function v:Stop()
	self._Janitor:Destroy()
end

return v