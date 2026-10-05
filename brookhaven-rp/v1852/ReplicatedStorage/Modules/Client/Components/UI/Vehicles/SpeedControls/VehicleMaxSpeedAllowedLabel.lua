local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "VehicleMaxSpeedAllowedLabel"
})
local VehicleSpeedUtil = require(ReplicatedStorage.Modules.Shared.Game.Vehicles.VehicleSpeedUtil)
local GamepassController = require(ReplicatedStorage.Modules.Client.UI.Gamepass.GamepassController)
local Gamepasses = require(ReplicatedStorage.Modules.Shared.PlayerData.Gamepasses)
local UnlockableController = require(ReplicatedStorage.Modules.Client.PlayerData.UnlockableController)
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	GamepassController.WaitForGamepasses()
	local maxSpeedForPlayer = VehicleSpeedUtil.GetMaxSpeedForPlayer(localPlayer)
	self.Instance.Text = `Max Speed {maxSpeedForPlayer}`
	self._Janitor:Add(GamepassController.OnGamepassUnlocked:Connect(function(p2)
		local v2 = Gamepasses.GetById(p2)

		if v2 == Gamepasses.VEHICLE_UPGRADE or v2 == Gamepasses.VEHICLE_SPEED_UNLOCKED or v2 == Gamepasses.PREMIUM then
			local maxSpeedForPlayer2 = VehicleSpeedUtil.GetMaxSpeedForPlayer(localPlayer)
			self.Instance.Text = `Max Speed {maxSpeedForPlayer2}`
		end
	end))
	self._Janitor:Add(UnlockableController.OnItemUnlocked:Connect(function(p2)
		if p2 == "CarSpeed200" then
			local maxSpeedForPlayer2 = VehicleSpeedUtil.GetMaxSpeedForPlayer(localPlayer)
			self.Instance.Text = `Max Speed {maxSpeedForPlayer2}`
		end
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v