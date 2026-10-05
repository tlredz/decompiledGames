local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("Players")
local Component = require(ReplicatedStorage.Packages.Component)
require(ReplicatedStorage.Modules.Client.Data.ReplicatedDataController)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local HouseTelemetry = require(ReplicatedStorage.Modules.Client.Components.UI.Houses.HouseTelemetry)
require(ReplicatedStorage.Packages.Remotes)
local v = Component.new({
	Tag = "HouseHolidayDecorationsButton"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local Players = game:GetService("Players")
	local localPlayer = Players.LocalPlayer
	local PlayerBagUtil = require(ReplicatedStorage.Modules.Shared.PlayerData.PlayerBagUtil)
	local HouseUtil = require(ReplicatedStorage.Modules.Shared.Game.HouseUtil)
	local LotUtil = require(ReplicatedStorage.Modules.Shared.Housing.LotUtil)
	local value = PlayerBagUtil.GetPlayerBagInstance(localPlayer, "HouseNumber").Value

	if HouseUtil.GetHouseType(value) ~= "House" then
		self.Instance.Visible = false
		return
	end

	local propertyRoot = LotUtil.GetPropertyRoot(value)

	if propertyRoot == nil then
		self.Instance.Visible = false
		return
	end

	if not propertyRoot.Instance:HasTag("PropertyHoliday") then
		self.Instance.Visible = false
		return
	end

	self.Instance.Visible = true
	self.isOn = true
	self._Janitor:Add(self.Instance.MouseButton1Click:Connect(function()
		HouseTelemetry.Click(self.Tag)
		self.isOn = not self.isOn
		self.Instance.GreenCheckMark.Visible = self.isOn
		ReplicatedStorage.RE:WaitForChild("1Player1sHous1e"):FireServer("HolidayDecorations", self.isOn)
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v