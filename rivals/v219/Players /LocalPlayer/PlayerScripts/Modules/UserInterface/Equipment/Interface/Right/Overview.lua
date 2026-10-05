local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ItemLibrary = require(ReplicatedStorage.Modules.ItemLibrary)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
local EquipmentMetricCard = require(Players.LocalPlayer.PlayerScripts.Modules.EquipmentMetricCard)
local MetricsGuide = require(script:WaitForChild("MetricsGuide"))
Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("EquipmentMetricSlot")
local Overview = {}
Overview.__index = Overview

function Overview.new(right)
	local self = setmetatable({}, Overview)
	self.Right = right
	self.MetricCard = EquipmentMetricCard.new("Overview", "rbxassetid://18404346057")
	self._set_opened_hash = 0
	self._cleanup = {}
	self._last_weapon_data = nil
	self:_Init()
	return self
end

function Overview:OnStateChanged()
	self:_UpdateInformation()
end

function Overview:OnOpen()
	self:_UpdateInformation()
end

function Overview:_UpdateInformation()
	if not self.Right.Interface.Equipment.IsOpen or self.Right.Interface.Equipment:IsCustomizing() then
		return
	end

	local selectedWeapon = self.Right.Interface.Equipment:GetSelectedWeapon()
	local weaponData = PlayerDataController:GetWeaponData(selectedWeapon)

	if weaponData == self._last_weapon_data then
		return
	end

	self.MetricCard:Clear()
	self._last_weapon_data = weaponData

	if not weaponData then
		return
	end

	local item = ItemLibrary.Items[selectedWeapon]

	for _, list in pairs(MetricsGuide) do
		local v, v2, v3, v4 = table.unpack(list)
		local v5 = nil

		for _, v7 in pairs(v2) do
			if not item[v7] then
				continue
			end

			v5 = item[v7]
			break
		end

		if not (v5 or not (#v2 > 0)) then
			continue
		end

		local v7

		if v3 == "Custom" then
			v7 = v4(selectedWeapon, v5)
		elseif v3 == "Time" then
			v7 = string.format("%.2f", v5) .. "s"
		elseif v3 == nil then
			v7 = string.format("%.0f", v5)
		else
			v7 = assert(false, v)
		end

		if v7 then
			self.MetricCard:Add(v, v7)
		end
	end
end

function Overview:_Init()
	self.MetricCard.Clicked:Connect(function()
		self.Right:SetMetricCardVisible("Overview", false)
	end)
	PlayerDataController:GetDataChangedSignal("WeaponInventory"):Connect(function()
		self:_UpdateInformation()
	end)
	self.MetricCard:SetParent(self.Right.Container)
end

return Overview