local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local AdFeatures = require(ReplicatedStorage.Modules.Shared.Advertisements.AdFeatures)
local Gamepasses = require(ReplicatedStorage.Modules.Shared.PlayerData.Gamepasses)
local GamepassController = require(ReplicatedStorage.Modules.Client.UI.Gamepass.GamepassController)
local UnlockableController = require(ReplicatedStorage.Modules.Client.PlayerData.UnlockableController)
local v = Component.new({
	Tag = "VehicleBoostControlsButton"
})
local VehicleController = require(ReplicatedStorage.Modules.Client.Vehicles.VehicleController)
local flag = false

function v:IsBoostUnlocked()
	return UnlockableController.IsFeatureUnlocked(AdFeatures.VEHICLE_BOOST.id, Gamepasses.VEHICLE_BOOST)
end

function v:OnBoostAcquired()
	if flag then
		return
	end

	flag = true
	self.Instance.Visible = true
end

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	self.Instance.Visible = false
	GamepassController.WaitForGamepasses()

	if self:IsBoostUnlocked() then
		self:OnBoostAcquired()
	end

	self._Janitor:Add(UnlockableController.OnItemUnlocked:Connect(function(p)
		if p == AdFeatures.VEHICLE_BOOST.id then
			self:OnBoostAcquired()
		end
	end))
	self._Janitor:Add(GamepassController.OnGamepassUnlocked:Connect(function(p)
		if flag then
			return
		end

		if Gamepasses.GetById(p) == Gamepasses.VEHICLE_BOOST then
			self:OnBoostAcquired()
		end
	end))
	self._Janitor:Add(VehicleController.OnPlayerStartedDriving:Connect(function(p)
		local currentDrivingVehicleModel = VehicleController.GetCurrentDrivingVehicleModel()

		if not (currentDrivingVehicleModel and VehicleController.GetVehicleUuidFromInstance(currentDrivingVehicleModel) == p) then
			return
		end

		self.vehiclePanel = VehicleController.GetVehiclePanel()

		if not self.vehiclePanel then
			return
		end

		self.boostControlsPanel = self.Instance.Panel.Value

		if not self.boostControlsPanel then
			return
		end

		if not flag then
			self.Instance.Visible = false
			return
		end

		self.boostControlsPanel:AddTag("Panel")
		self.Instance.Visible = true
	end))
	self._Janitor:Add(VehicleController.OnPlayerStoppedDriving:Connect(function()
		if not self.boostControlsPanel then
			return
		end

		self.boostControlsPanel:RemoveTag("Panel")
	end))
	self._Janitor:Add(self.Instance.MouseButton1Click:Connect(function()
		self.vehiclePanel:SetCurrentOpenPanel(self.boostControlsPanel)
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v