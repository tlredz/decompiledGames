local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HouseTelemetry = require(ReplicatedStorage.Modules.Client.Components.UI.Houses.HouseTelemetry)
require(ReplicatedStorage.Modules.Shared.Components.Housing.PropertyRoot)
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local localPlayer = Players.LocalPlayer
local v = Component.new({
	Tag = "HouseLockButton"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local HouseUtil = require(ReplicatedStorage.Modules.Shared.Game.HouseUtil)
	local LotUtil = require(ReplicatedStorage.Modules.Shared.Housing.LotUtil)
	local game8Settings = localPlayer:WaitForChild("PlayerGui"):WaitForChild("Player8Handler"):WaitForChild("Game8Settings")
	local module = require(game8Settings)
	local playersHouse = module.PlayersHouse
	local PlayerBagUtil = require(ReplicatedStorage.Modules.Shared.PlayerData.PlayerBagUtil)
	local value = PlayerBagUtil.GetPlayerBagInstance(localPlayer, "HouseNumber").Value
	local instance = self.Instance
	self.checkmark = self.Instance:FindFirstChild("GreenCheckMark")
	local property = LotUtil.GetProperty(value)
	self._Janitor:Add(instance.MouseButton1Click:Connect(function()
		HouseTelemetry.Click(self.Tag)
		playersHouse:FireServer("LockDoors")
	end))
	self._Janitor:Add(playersHouse.OnClientEvent:Connect(function(p: string)
		if p == "LockDoorsTrue" then
			self.checkmark.Visible = true
		elseif p == "LockDoorsFalse" then
			self.checkmark.Visible = false
		end
	end))

	if HouseUtil.GetHouseType(value) ~= "Landmark" and property:GetAttribute("AreDoorsLockable") ~= false then
		return
	end

	self.Instance.Visible = false
end

function v:Stop()
	self._Janitor:Destroy()
end

return v