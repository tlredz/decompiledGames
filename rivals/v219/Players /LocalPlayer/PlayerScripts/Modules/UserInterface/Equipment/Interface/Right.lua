local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local StatisticsLibrary = require(ReplicatedStorage.Modules.StatisticsLibrary)
local SeasonLibrary = require(ReplicatedStorage.Modules.SeasonLibrary)
require(ReplicatedStorage.Modules.Utility)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
local EquipmentMetricCard = require(Players.LocalPlayer.PlayerScripts.Modules.EquipmentMetricCard)
local UILibrary = require(Players.LocalPlayer.PlayerScripts.Modules.UILibrary)
local SecondaryActions = require(script:WaitForChild("SecondaryActions"))
local PrimaryActions = require(script:WaitForChild("PrimaryActions"))
local LockedActions = require(script:WaitForChild("LockedActions"))
local Performance = require(script:WaitForChild("Performance"))
local Overview = require(script:WaitForChild("Overview"))
local Details = require(script:WaitForChild("Details"))
local Level = require(script:WaitForChild("Level"))
local uDim = UDim2.new(1.375, 0, 0.5, 0)
local uDim2 = UDim2.new(1, 0, 0.5, 0)
local Right = {}
Right.__index = Right

function Right.new(interface)
	local self = setmetatable({}, Right)
	self.Interface = interface
	self.Frame = self.Interface.Frame:WaitForChild("Right")
	self.List = self.Frame:WaitForChild("List")
	self.Container = self.List:WaitForChild("Container")
	self.Layout = self.Container:WaitForChild("Layout")
	self.TopBufferFrame = self.Container:WaitForChild("TopBuffer")
	self.SecondaryActions = SecondaryActions.new(self)
	self.PrimaryActions = PrimaryActions.new(self)
	self.LockedActions = LockedActions.new(self)
	self.Performance = Performance.new(self)
	self.Overview = Overview.new(self)
	self.Details = Details.new(self)
	self.Level = Level.new(self)
	self._is_visible = false
	self._last_state = nil
	self._metric_cards = {
		Performance = self.Performance.MetricCard,
		Overview = self.Overview.MetricCard
	}
	self:_Init()
	return self
end

function Right:SetVisible(is_visible)
	self._is_visible = is_visible
	self.Frame:TweenPosition(self._is_visible and uDim2 or uDim, "Out", "Quint", 0.25, true)
end

function Right:SetMetricCardVisible(p, p2)
	self._metric_cards[p]:SetOpened(p2)
	self.PrimaryActions:SetMetricActionVisible(p, not p2)
	self.SecondaryActions:SetMetricActionVisible(p, not p2)
end

function Right:ResetMetricCards()
	for k in pairs(self._metric_cards) do
		self:SetMetricCardVisible(k, false)
	end
end

function Right:ScrollTo(p2, value)
	task.delay(value or 0, function()
		local v = math.min(
			self.List.AbsoluteCanvasSize.Y,
			p2.AbsolutePosition.Y + UILibrary.MainGui.AbsolutePosition.Y * 2 - self.Container.AbsolutePosition.Y
		)
		TweenService:Create(self.List, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			CanvasPosition = Vector2.new(0, v)
		}):Play()
	end)
end

function Right:OnStateChanged(...)
	self.SecondaryActions:OnStateChanged(...)
	self.PrimaryActions:OnStateChanged(...)
	self.LockedActions:OnStateChanged(...)
	self.Performance:OnStateChanged(...)
	self.Overview:OnStateChanged(...)
	self.Details:OnStateChanged(...)
	self.Level:OnStateChanged(...)
	self:_OpenEffect()
end

function Right:OnOpen(...)
	self.SecondaryActions:OnOpen(...)
	self.PrimaryActions:OnOpen(...)
	self.Performance:OnOpen(...)
	self.Overview:OnOpen(...)
end

function Right:_OpenEffect()
	local selectedWeapon = self.Interface.Equipment:GetSelectedWeapon()
	local weaponData = PlayerDataController:GetWeaponData(selectedWeapon)
	self.List:TweenSize(
		selectedWeapon and not weaponData and UDim2.new(1, 0, 1, 0) or UDim2.new(0.7, 0, 1, 0),
		"Out",
		"Quint",
		0.25,
		true
	)
	local stateID = self.Interface.Equipment:GetStateID()

	if stateID ~= self._last_state then
		self._last_state = stateID
		self.Frame.Position = uDim
		self:SetVisible(self._is_visible)
	end
end

function Right:_Update()
	self.TopBufferFrame.Size = UDim2.new(
		1,
		0,
		0,
		(math.max(
			self.List.AbsoluteSize.Y * 0.375,
			self.List.AbsoluteSize.Y - (self.Layout.AbsoluteContentSize.Y - self.TopBufferFrame.AbsoluteSize.Y)
		))
	)
	self.List.CanvasSize = UDim2.new(0, 0, 0, self.Layout.AbsoluteContentSize.Y)
end

function Right:_SetupPreviousSeasons()
	local seasons = PlayerDataController:Get("Seasons")
	local v = {}

	for k in pairs(SeasonLibrary.Seasons) do
		if seasons[k] then
			table.insert(v, k)
		end
	end

	table.sort(v, function(a, b)
		return SeasonLibrary.Seasons[a].Version < SeasonLibrary.Seasons[b].Version
	end)

	for _, v2 in pairs(v) do
		local v3 = seasons[v2] and seasons[v2].RankedPerformances and seasons[v2].RankedPerformances[SeasonLibrary.UNIVERSAL_ELO_NAME]

		if not v3 or (v3.DuelsPlayed or 0) <= 0 then
			continue
		end

		local season = SeasonLibrary.Seasons[v2]
		local v4 = "season_" .. v2
		local v5 = "Season " .. season.Version
		local v6 = "The " .. season.Name .. " Season"
		local v7 = EquipmentMetricCard.new(v5, "rbxassetid://117835427046796")
		v7:SetParent(self.Container)
		self._metric_cards[v4] = v7
		v7.Opened:Connect(function()
			self:ScrollTo(v7:GetScrollToElement())
		end)
		v7.Clicked:Connect(function()
			self:SetMetricCardVisible(v4, false)
		end)

		if v3.DuelsPlayed then
			v7:Add("Duels Played", StatisticsLibrary.Info.StatisticRankedDuelsPlayed.TostringFunction(v3.DuelsPlayed))
		end

		if v3.DuelsWon then
			v7:Add("Duels Won", StatisticsLibrary.Info.StatisticRankedDuelsWon.TostringFunction(v3.DuelsWon))
		end

		if v3.DuelsLost then
			v7:Add("Duels Lost", StatisticsLibrary.Info.StatisticRankedDuelsLost.TostringFunction(v3.DuelsLost))
		end

		if v3.DuelsWinPercent then
			v7:Add(
				"Duels Win %",
				StatisticsLibrary.Info.StatisticRankedDuelsWinPercent.TostringFunction(v3.DuelsWinPercent)
			)
		end

		if v3.CurrentELO then
			v7:Add("Final ELO", StatisticsLibrary.Info.StatisticRankedDuelsPlayed.TostringFunction(v3.CurrentELO))
		end

		if v3.HighestELO then
			v7:Add("Highest ELO", StatisticsLibrary.Info.StatisticRankedDuelsPlayed.TostringFunction(v3.HighestELO))
		end

		if v3.LowestELO then
			v7:Add("Lowest ELO", StatisticsLibrary.Info.StatisticRankedDuelsPlayed.TostringFunction(v3.LowestELO))
		end

		if v3.EndOfSeasonRewardsClaimed then
			v7:AddSeasonRewards(v3.EndOfSeasonRewardsClaimed)
		end

		self.SecondaryActions:CreateMetricAction(v4, "rbxassetid://117835427046796", v5, v6)
	end
end

function Right:_Setup()
	self.Visible = true
end

function Right:_Init()
	self.List:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self:_Update()
	end)
	self.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self:_Update()
	end)
	self.TopBufferFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self:_Update()
	end)
	self.Performance.MetricCard.Opened:Connect(function()
		self:ScrollTo(self.Performance.MetricCard:GetScrollToElement())
	end)
	self.Overview.MetricCard.Opened:Connect(function()
		self:ScrollTo(self.Overview.MetricCard:GetScrollToElement())
	end)
	PlayerDataController:GetDataChangedSignal("WeaponInventory"):Connect(function()
		self:_OpenEffect()
	end)
	self:_Setup()
	self:_SetupPreviousSeasons()
	self:_Update()
end

return Right