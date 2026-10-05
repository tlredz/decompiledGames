local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "NoMotorVehicleSpeedUpsellDetector"
})
local NoMotorVehicleSpeedUtil = require(ReplicatedStorage.Modules.Shared.Game.Vehicles.NoMotorVehicleSpeedUtil)
local localPlayer = Players.LocalPlayer

function v:CheckIfShouldShowUpsell(p: number, instance)
	local maxSpeedForPlayer = NoMotorVehicleSpeedUtil.GetMaxSpeedForPlayer(localPlayer)

	if not maxSpeedForPlayer then
		warn("Max speed not found")
	elseif maxSpeedForPlayer == NoMotorVehicleSpeedUtil.VEHICLE_SPEED_UNLOCKED_MAX_SPEED then
		instance.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		instance:SetAttribute("ShouldShowUpsell", false)
	elseif maxSpeedForPlayer <= p then
		instance.BackgroundColor3 = Color3.fromRGB(133, 255, 80)
		instance:SetAttribute("ShouldShowUpsell", true)
	else
		instance.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		instance:SetAttribute("ShouldShowUpsell", false)
	end
end

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local GamepassController = require(ReplicatedStorage.Modules.Client.UI.Gamepass.GamepassController)
	local VehicleController = require(ReplicatedStorage.Modules.Client.Vehicles.VehicleController)
	local UnlockableController = require(ReplicatedStorage.Modules.Client.PlayerData.UnlockableController)
	local instance = self.Instance
	self._Janitor:Add(VehicleController.OnNoMotorVehicleSpeedChanged:Connect(function(p: number)
		self:CheckIfShouldShowUpsell(p, instance)
	end))
	self._Janitor:Add(GamepassController.OnGamepassUnlocked:Connect(function(_)
		self:CheckIfShouldShowUpsell(VehicleController.GetNoMotorVehicleSpeed(), instance)
	end))
	self._Janitor:Add(UnlockableController.OnItemUnlocked:Connect(function(_)
		self:CheckIfShouldShowUpsell(VehicleController.GetNoMotorVehicleSpeed(), instance)
	end))
	local noMotorVehicleSpeed = VehicleController.GetNoMotorVehicleSpeed()

	if noMotorVehicleSpeed then
		self:CheckIfShouldShowUpsell(noMotorVehicleSpeed, instance)
	else
		warn("Speed not found")
	end
end

function v:Stop()
	self._Janitor:Destroy()
end

return v