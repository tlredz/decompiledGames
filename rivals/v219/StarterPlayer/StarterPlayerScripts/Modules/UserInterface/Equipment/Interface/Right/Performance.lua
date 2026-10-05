local Players = game:GetService("Players")
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
local EquipmentMetricCard = require(Players.LocalPlayer.PlayerScripts.Modules.EquipmentMetricCard)
local StatisticsList = require(Players.LocalPlayer.PlayerScripts.Modules.StatisticsList)
local Performance = {}
Performance.__index = Performance

function Performance.new(right)
	local self = setmetatable({}, Performance)
	self.Right = right
	self.MetricCard = EquipmentMetricCard.new("Statistics", "rbxassetid://17336063541")
	self.StatisticsList = StatisticsList.new(self.MetricCard.Container, 1, true)
	self:_Init()
	return self
end

function Performance:OnStateChanged()
	self:_UpdateInformation()
end

function Performance:OnOpen()
	self:_UpdateInformation()
end

function Performance:_UpdateInformation()
	if not self.Right.Interface.Equipment.IsOpen or self.Right.Interface.Equipment:IsCustomizing() then
		self.StatisticsList:Clear()
		return
	end

	local isCareerPageOpen = self.Right.Interface.Equipment:IsCareerPageOpen()
	local selectedWeapon = self.Right.Interface.Equipment:GetSelectedWeapon()
	local weaponData = PlayerDataController:GetWeaponData(selectedWeapon)

	if isCareerPageOpen then
		self.StatisticsList:Generate(true, nil, nil)
	elseif weaponData then
		self.StatisticsList:Generate(false, "WeaponStatistics", selectedWeapon)
	else
		self.StatisticsList:Clear()
	end
end

function Performance:_Init()
	self.MetricCard.Clicked:Connect(function()
		self.Right:SetMetricCardVisible("Performance", false)
	end)
	PlayerDataController:GetDataChangedSignal("WeaponInventory"):Connect(function()
		self:_UpdateInformation()
	end)
	self.MetricCard:SetParent(self.Right.Container)
end

return Performance