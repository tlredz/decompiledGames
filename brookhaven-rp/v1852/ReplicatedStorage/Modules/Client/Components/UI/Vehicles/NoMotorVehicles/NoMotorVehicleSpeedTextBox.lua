local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "NoMotorVehicleSpeedTextBox"
})
local NoMotorVehicleSpeedUtil = require(ReplicatedStorage.Modules.Shared.Game.Vehicles.NoMotorVehicleSpeedUtil)
local GamepassController = require(ReplicatedStorage.Modules.Client.UI.Gamepass.GamepassController)
local localPlayer = Players.LocalPlayer

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local VehicleController = require(ReplicatedStorage.Modules.Client.Vehicles.VehicleController)
	self._Janitor:Add(VehicleController.OnNoMotorVehicleSpeedChanged:Connect(function(p2: number)
		self.Instance.Text = tostring(p2)
	end))
	self._Janitor:Add(self.Instance.FocusLost:Connect(function()
		local text = tonumber(self.Instance.Text)

		if text then
			VehicleController.SetNoMotorVehicleSpeed(text)
		else
			VehicleController.SetNoMotorVehicleSpeed(NoMotorVehicleSpeedUtil.DEFAULT_MAX_SPEED)
		end
	end))
	self._Janitor:Add(GamepassController.OnGamepassUnlocked:Connect(function(_)
		self.Instance.PlaceholderText = "Enter 25-" .. tostring(NoMotorVehicleSpeedUtil.GetMaxSpeedForPlayer(localPlayer))
	end))
	local noMotorVehicleSpeed = VehicleController.GetNoMotorVehicleSpeed()

	if not noMotorVehicleSpeed then
		warn("Speed not found")
		return
	end

	self.Instance.PlaceholderText = "Enter 25-" .. tostring(NoMotorVehicleSpeedUtil.GetMaxSpeedForPlayer(localPlayer))
	self.Instance.Text = tostring(noMotorVehicleSpeed)
end

function v:Stop()
	self._Janitor:Destroy()
end

return v