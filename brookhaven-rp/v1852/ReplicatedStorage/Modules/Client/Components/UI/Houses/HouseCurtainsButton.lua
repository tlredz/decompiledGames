local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HouseTelemetry = require(ReplicatedStorage.Modules.Client.Components.UI.Houses.HouseTelemetry)
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local LotUtil = require(ReplicatedStorage.Modules.Shared.Housing.LotUtil)
local PlayerBagUtil = require(ReplicatedStorage.Modules.Shared.PlayerData.PlayerBagUtil)
local localPlayer = Players.LocalPlayer
local _1Player1sHous1e = ReplicatedStorage.RE:WaitForChild("1Player1sHous1e")
local v = Component.new({
	Tag = "HouseCurtainsButton"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local value = PlayerBagUtil.GetPlayerBagInstance(localPlayer, "HouseNumber").Value
	local property = LotUtil.GetProperty(value)
	local instance = self.Instance
	self._Janitor:Add(instance.MouseButton1Click:Connect(function()
		HouseTelemetry.Click(self.Tag)
		_1Player1sHous1e:FireServer("Curtains")
		instance.GreenCheckMark.Visible = not instance.GreenCheckMark.Visible
	end))

	if property:GetAttribute("AreCurtainsClosable") ~= false then
		return
	end

	self.Instance.Visible = false
end

function v:Stop()
	self._Janitor:Destroy()
end

return v