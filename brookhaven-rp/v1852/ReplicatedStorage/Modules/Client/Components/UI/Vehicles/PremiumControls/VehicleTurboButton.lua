local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AdFeatures = require(ReplicatedStorage.Modules.Shared.Advertisements.AdFeatures)
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local VehicleUiInteractionTelemetryController = require(ReplicatedStorage.Modules.Client.Telemetry.VehicleUiInteractionTelemetryController)
local v = Component.new({
	Tag = "VehicleTurboButton"
})
local v2 = nil
local v3 = nil
local v4 = nil
local v5 = nil
local flag = false

function v:OnActivated()
	local function activate()
		local currentTurboLevel = (self.currentTurboLevel + 1) % 4

		if not v2.SetTurbo(currentTurboLevel) then
			return
		end

		self.currentTurboLevel = currentTurboLevel
		self.currentTurboLevel = currentTurboLevel

		if self.currentTurboLevel >= 1 then
			VehicleUiInteractionTelemetryController.Fire(
				"Customization",
				"Turbo - " .. tostring(self.currentTurboLevel)
			)
		end

		if self.currentTurboLevel == 0 then
			self.stageNumber.Text = "Off"
		else
			self.stageNumber.Text = tostring(self.currentTurboLevel)
		end
	end

	if v3.IsFeatureUnlocked(AdFeatures.VEHICLE_SPEED_MAX.id, v5.VEHICLE_SPEED_UNLOCKED) then
		activate()
		return
	end

	local currentDrivingVehicleModel = v2.GetCurrentDrivingVehicleModel()

	if not currentDrivingVehicleModel then
		return
	end

	local vehicleName = currentDrivingVehicleModel:GetAttribute("vehicleName")
	v4.Show(
		v5.VEHICLE_SPEED_UNLOCKED,
		nil,
		"turbo",
		nil,
		AdFeatures.VEHICLE_SPEED_MAX,
		nil,
		"Vehicle Controls",
		vehicleName,
		function()
			if v2.GetCurrentDrivingVehicleModel() == currentDrivingVehicleModel then
				activate()
			end
		end
	)
end

function v:OnTurboAcquired()
	flag = true
	self.Instance.Visible = true
	self.stageNumber.Visible = true
	self.gamepassIcon.Visible = false

	if self.currentTurboLevel == 0 then
		self.stageNumber.Text = "Off"
	else
		self.currentTurboLevel = math.min(self.currentTurboLevel, 3)
		self.stageNumber.Text = tostring(self.currentTurboLevel)
	end

	self._Janitor:Add(v2.OnTurboChanged:Connect(function(_: string, currentTurboLevel: number)
		self.currentTurboLevel = currentTurboLevel

		if self.currentTurboLevel == 0 then
			self.stageNumber.Text = "Off"
			return
		end

		self.currentTurboLevel = math.min(self.currentTurboLevel, 3)
		self.stageNumber.Text = tostring(self.currentTurboLevel)
	end))
end

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local VehicleController = require(ReplicatedStorage.Modules.Client.Vehicles.VehicleController)
	v2 = VehicleController
	local UnlockableController = require(ReplicatedStorage.Modules.Client.PlayerData.UnlockableController)
	v3 = UnlockableController
	local GamepassController = require(ReplicatedStorage.Modules.Client.UI.Gamepass.GamepassController)
	v4 = GamepassController
	local Gamepasses = require(ReplicatedStorage.Modules.Shared.PlayerData.Gamepasses)
	v5 = Gamepasses
	self.stageNumber = self.Instance:WaitForChild("StageNumber")
	self.gamepassIcon = self.Instance:WaitForChild("GamepassIcon")
	self.stageNumber.Visible = false
	self.gamepassIcon.Visible = true
	self.currentTurboLevel = 0
	local currentDrivingVehicleModel = v2.GetCurrentDrivingVehicleModel()
	local seats = currentDrivingVehicleModel and currentDrivingVehicleModel:FindFirstChild("Seats")

	if seats then
		local vehicleSeat = seats:FindFirstChildOfClass("VehicleSeat")
		local turbo = vehicleSeat and vehicleSeat:FindFirstChild("Turbo")

		if turbo then
			local value = tonumber(turbo.Value)

			if value > 60 then
				self.currentTurboLevel = 3
			elseif value > 40 then
				self.currentTurboLevel = 2
			elseif value > 20 then
				self.currentTurboLevel = 1
			end
		end
	end

	self.Instance.Visible = true
	self._Janitor:Add(self.Instance.Activated:Connect(function()
		self:OnActivated()
	end))
	v4.WaitForGamepasses()

	if v4.IsOwned(v5.VEHICLE_SPEED_UNLOCKED) or v3.IsFeatureUnlocked(AdFeatures.VEHICLE_SPEED_MAX.id) then
		self:OnTurboAcquired()
		return
	end

	self._Janitor:Add(v3.OnItemUnlocked:Connect(function(p)
		if p == "CarSpeed200" then
			self:OnTurboAcquired()
		end
	end))
	self._Janitor:Add(v4.OnGamepassUnlocked:Connect(function(p)
		if flag then
			return
		end

		if v5.GetById(p) == v5.VEHICLE_SPEED_UNLOCKED then
			self:OnTurboAcquired()
		end
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v