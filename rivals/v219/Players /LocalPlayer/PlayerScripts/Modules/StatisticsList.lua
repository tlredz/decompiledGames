local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local StatisticsLibrary = require(ReplicatedStorage.Modules.StatisticsLibrary)
local ItemLibrary = require(ReplicatedStorage.Modules.ItemLibrary)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
local WeaponStatusHandler = require(Players.LocalPlayer.PlayerScripts.Modules.WeaponStatusHandler)
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules.ButtonEffect)
local UILibrary = require(Players.LocalPlayer.PlayerScripts.Modules.UILibrary)
local statisticParentSlot = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("StatisticParentSlot")
local statisticChildSlot = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("StatisticChildSlot")
local StatisticsList = {}
StatisticsList.__index = StatisticsList

function StatisticsList.new(parent, layout_order, expand_all_statistics)
	local self = setmetatable({}, StatisticsList)
	self._parent = parent
	self._layout_order = layout_order
	self._expand_all_statistics = expand_all_statistics
	self._statistic_slots = {}
	self._dependent_statistic_slots = {}
	self:_Init()
	return self
end

function StatisticsList:Clear()
	for _, _statistic_slot in pairs(self._statistic_slots) do
		_statistic_slot:Destroy()
	end

	self._statistic_slots = {}
	self._dependent_statistic_slots = {}
end

function StatisticsList:Generate(p, p2, p3)
	self:Clear()
	local statisticsDirectoryInfo = StatisticsLibrary:GetStatisticsDirectoryInfo(p2)
	local careerStatistics = p and StatisticsLibrary:GetCareerStatistics(PlayerDataController:GetUnlockedWeapons())

	if not careerStatistics then
		if statisticsDirectoryInfo[2][p3] then
			careerStatistics = statisticsDirectoryInfo[2][p3].DataNames or nil
		else
			careerStatistics = nil
		end
	end

	if not careerStatistics then
		return
	end

	local count = 0
	local generate

	generate = function(p4, p5)
		if self._statistic_slots[p4] then
			return
		end

		local v = StatisticsLibrary.Info[p4]
		local statistic

		if p then
			statistic = PlayerDataController:GetStatistic(p4)
		else
			statistic = PlayerDataController:GetDirectoryStatistic(p2, p3, p4)
		end

		local v2 = p4 == "StatisticFavoriteWeapon" or p4 == "StatisticFavoriteWeaponPrimary" or p4 == "StatisticFavoriteWeaponSecondary" or p4 == "StatisticFavoriteWeaponMelee" or p4 == "StatisticFavoriteWeaponUtility"
		local v3 = v2 or p4 == "StatisticFavoriteMap"

		if v.OnlyDisplayNonZero and (not statistic or statistic == 0) then
			return
		end

		local clone = (v.ParentDataName and statisticChildSlot or statisticParentSlot):Clone()
		clone.TitleContainer.Title.Text = v.DisplayName
		clone.TitleContainer.Position = v.ParentDataName and UDim2.new(0.125, 0, 0.5, 0) or UDim2.new(0.0625, 0, 0.5, 0)
		clone.Value.Text = v.IsStatisticFolder and "" or v.TostringFunction(statistic)
		clone.Value.Size = v3 and UDim2.new(0.35, 0, 1, 0) or clone.Value.Size
		clone.LayoutOrder = self._layout_order + p5
		clone.Visible = not v.IsStatisticFolder and (self._expand_all_statistics or not v.ParentDataName or p)
		clone.Parent = self._parent
		self._statistic_slots[p4] = clone
		count += 1

		if v2 and ItemLibrary.Items[statistic] then
			WeaponStatusHandler:ApplyItemStatusToText(clone.Value, ItemLibrary.Items[statistic].Status)
		end

		if v.ParentDataName then
			self._dependent_statistic_slots[v.ParentDataName] = self._dependent_statistic_slots[v.ParentDataName] or {}
			table.insert(self._dependent_statistic_slots[v.ParentDataName], clone)
			generate(v.ParentDataName, p5 - 1)
		else
			clone.Arrow.Visible = false
		end

		UILibrary:ScrollingTextLabel(clone.TitleContainer, clone.TitleContainer.Title, clone.Value)
	end

	for k, careerStatistic in pairs(careerStatistics) do
		generate(careerStatistic, k * 2)
	end

	for k, _dependent_statistic_slot in pairs(self._dependent_statistic_slots) do
		self._statistic_slots[k].Visible = true
		local _statistic_slot = self._statistic_slots[k]
		local visible = false
		-- equivalent calls inferred from this helper; original call sites unknown
		local v3 = _dependent_statistic_slot

		local function set_visible(_expand_all_statistics)
			visible = _expand_all_statistics
			_statistic_slot.Arrow.Image = visible and "rbxassetid://17654601337" or "rbxassetid://17654548862"

			for k2, v4 in pairs(v3) do
				v4.Visible = visible
			end
		end

		local v4 = _statistic_slot
		local v5 = _dependent_statistic_slot
		_statistic_slot.Button.MouseButton1Click:Connect(function()
			visible = not visible
			v4.Arrow.Image = visible and "rbxassetid://17654601337" or "rbxassetid://17654548862"

			for k2, v6 in pairs(v5) do
				v6.Visible = visible
			end
		end)
		set_visible(self._expand_all_statistics or p) -- equivalent call inferred; original call site unknown
		_statistic_slot.Arrow.Visible = true
		ButtonEffect:Add(_statistic_slot.Button, true, {
			TargetElement = _statistic_slot.Arrow
		})
	end

	return count > 0
end

function StatisticsList:_Init() end

return StatisticsList