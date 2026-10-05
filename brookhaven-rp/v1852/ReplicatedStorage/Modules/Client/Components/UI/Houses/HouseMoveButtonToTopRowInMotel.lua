local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "HouseMoveButtonToTopRowInMotel"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v.Start(p)
	local Players = game:GetService("Players")
	local localPlayer = Players.LocalPlayer
	local PlayerBagUtil = require(ReplicatedStorage.Modules.Shared.PlayerData.PlayerBagUtil)
	local HouseUtil = require(ReplicatedStorage.Modules.Shared.Game.HouseUtil)
	local value = PlayerBagUtil.GetPlayerBagInstance(localPlayer, "HouseNumber").Value

	if HouseUtil.GetHouseType(value) ~= "Motel" then
		return
	end

	local topRow = p.Instance.Parent.Parent:FindFirstChild("TopRow")

	if topRow then
		p.Instance.Parent = topRow
	end
end

function v:Stop()
	self._Janitor:Destroy()
end

return v