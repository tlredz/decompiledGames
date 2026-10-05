local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local MonetizationLibrary = require(ReplicatedStorage.Modules.MonetizationLibrary)
local StatisticsLibrary = require(ReplicatedStorage.Modules.StatisticsLibrary)
local ContractsLibrary = require(ReplicatedStorage.Modules.ContractsLibrary)
local EventLibrary = require(ReplicatedStorage.Modules.EventLibrary)
local ServerOsTime = require(ReplicatedStorage.Modules.ServerOsTime)
local ItemLibrary = require(ReplicatedStorage.Modules.ItemLibrary)
local TaskLibrary = require(ReplicatedStorage.Modules.TaskLibrary)
local DuelLibrary = require(ReplicatedStorage.Modules.DuelLibrary)
local Utility = require(ReplicatedStorage.Modules.Utility)
local ShootingRangeController = require(Players.LocalPlayer.PlayerScripts.Controllers.ShootingRangeController)
local MonetizationController = require(Players.LocalPlayer.PlayerScripts.Controllers.MonetizationController)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
local LobbyController = require(Players.LocalPlayer.PlayerScripts.Controllers.LobbyController)
local TimerController = require(Players.LocalPlayer.PlayerScripts.Controllers.TimerController)
local AdventCalendarSlot = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("AdventCalendarSlot"))
local DropdownSlot = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("DropdownSlot"))
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ButtonEffect"))
local RewardSlot = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("RewardSlot"))
local TaskSlot = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("TaskSlot"))
local Page = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("Page"))
local dailyTaskStreakMilestoneSlot = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("DailyTaskStreakMilestoneSlot")
local taskContractMilestoneDivider = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("TaskContractMilestoneDivider")
local dailyTaskStreakSlot = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("DailyTaskStreakSlot")
local taskContractMilestoneSlot = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("TaskContractMilestoneSlot")
local taskContainer = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("TaskContainer")
local v = {
	{
		"Tasks",
		"Daily Tasks",
		"rbxassetid://17653923757",
		UDim2.new(2, 0, 1.5, 0)
	},
	{
		"LimitedTasks",
		nil,
		nil,
		nil
	},
	{
		"SpecialChallenges",
		"Special Challenge" .. (#(TaskLibrary.SPECIAL_CHALLENGES or {}) == 1 and "" or "s") .. "!",
		"rbxassetid://17860673529",
		UDim2.new(2, 0, 2, 0),
		"Limited time only!"
	},
	{
		"EventTasks",
		"Earn " .. EventLibrary.EVENT_DETAILS.CURRENCY_NAME_PLURAL .. "!",
		EventLibrary.EVENT_DETAILS.CURRENCY_IMAGE,
		UDim2.new(2.25, 0, 2.25, 0),
		"Limited time only!"
	},
	{
		"BonusTasks",
		"Bonus Tasks",
		"rbxassetid://17653923757",
		UDim2.new(2, 0, 1.5, 0)
	}
}
local object = setmetatable({}, Page)
object.__index = object

function object._new()
	local self = setmetatable(Page.new(script.Name), object)
	self.CloseButton = self.PageFrame:WaitForChild("Close")
	self.List = self.PageFrame:WaitForChild("List")
	self.Container = self.List:WaitForChild("Container")
	self.Layout = self.Container:WaitForChild("Layout")
	self.TasksCompletedFrame = self.Container:WaitForChild("TasksCompleted")
	self.TasksCompletedContainer = self.TasksCompletedFrame:WaitForChild("Container")
	self.TasksCompletedTimerText = self.TasksCompletedContainer:WaitForChild("Timer")
	self.TasksCompletedContentsFrame = self.TasksCompletedContainer:WaitForChild("Contents")
	self.TasksCompletedContentsLayout = self.TasksCompletedContentsFrame:WaitForChild("Layout")
	self.TasksCompletedRefreshFrame = self.TasksCompletedContentsFrame:WaitForChild("Refresh")
	self.TasksCompletedRefreshRewardsFrame = self.TasksCompletedRefreshFrame:WaitForChild("Rewards")
	self.TasksCompletedRefreshButton = self.TasksCompletedRefreshFrame:WaitForChild("Button")
	self.TasksCompletedRefreshButtonText = self.TasksCompletedRefreshButton:WaitForChild("Price")
	self.ContractsFrame = self.Container:WaitForChild("Contracts")
	self.ContractsContainer = self.ContractsFrame:WaitForChild("Container")
	self.ContractsFilterButton = self.ContractsContainer:WaitForChild("Filter")
	self.ContractsDropdownFrame = self.ContractsContainer:WaitForChild("Dropdown")
	self.ContractsDropdownButton = self.ContractsDropdownFrame:WaitForChild("Button")
	self.ContractsDropdownTitle = self.ContractsDropdownButton:WaitForChild("Title")
	self.ContractsMilestones = self.ContractsContainer:WaitForChild("Milestones")
	self.ContractsLayout = self.ContractsMilestones:WaitForChild("Layout")
	self.AdventCalendarFrame = self.Container:WaitForChild("AdventCalendar")
	self.AdventCalendarSlot = AdventCalendarSlot.new(self.AdventCalendarFrame)
	self._to_shooting_range_button = nil
	self._to_duels_button = nil
	self._task_containers = {}
	self._task_slots = {}
	self._contract_slots = {}
	self._contract_dividers = {}
	self._daily_task_streak_cleanup = {}
	self._daily_task_streak_reward_slots = {}
	self._daily_task_streak_update_callbacks = {}
	self._percent_contract_goal_enabled = false
	self._while_open_callbacks = {}
	self:_Init()
	return self
end

function object:ScrollTo(p, value)
	local _task_container = self._task_containers[p]

	if not _task_container then
		return
	end

	task.delay(value or 0, function()
		TweenService:Create(self.List, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			CanvasPosition = Vector2.new(0, _task_container.AbsolutePosition.Y - self.Container.AbsolutePosition.Y)
		}):Play()
	end)
end

function object:Open(...)
	Page.Open(self, ...)
	self.AdventCalendarSlot:SetEnabled(true)
	self.ContractsDropdownFrame.Visible = PlayerDataController:Get("Level") >= 15
	table.insert(self._open_threads, task.spawn(function()
		while true do
			for _, _while_open_callback in pairs(self._while_open_callbacks) do
				_while_open_callback()
			end

			wait(1)
		end
	end))
	table.insert(self._open_threads, task.spawn(function()
		while true do
			wait(3)

			for _, _daily_task_streak_reward_slot in pairs(self._daily_task_streak_reward_slots) do
				_daily_task_streak_reward_slot.Frame:TweenPosition(
					UDim2.new(0.5, 0, -0.125, 0),
					"Out",
					"Quint",
					1,
					true
				)
			end

			wait(0.75)

			for _, _daily_task_streak_reward_slot in pairs(self._daily_task_streak_reward_slots) do
				_daily_task_streak_reward_slot.Frame:TweenPosition(UDim2.new(0.5, 0, 0.5, 0), "Out", "Bounce", 1, true)
			end
		end
	end))
	table.insert(
		self._open_connections,
		PlayerDataController:GetDataChangedSignal("StatisticDuelsPlayed"):Connect(function()
			self:_Generate()
		end)
	)
	table.insert(
		self._open_connections,
		PlayerDataController:GetDataChangedSignal("BeginnerTasksCompleted"):Connect(function()
			self:_Generate()
		end)
	)
	table.insert(self._open_connections, PlayerDataController:GetDataChangedSignal("DailyTaskStreak"):Connect(function()
		self:_Generate()
	end))
	table.insert(self._open_connections, TimerController.TimerUpdated:Connect(function()
		self:_Generate()
	end))

	for _, v2 in pairs(TaskLibrary.TASKS_DATA_NAMES) do
		table.insert(self._open_connections, PlayerDataController:GetDataChangedSignal(v2):Connect(function()
			self:_Generate()
		end))
	end

	self:_Generate()
end

function object:Close(...)
	TimerController:OnStep("TaskPage", nil, nil)
	self.AdventCalendarSlot:SetEnabled(false)
	self:_StopDropdown()
	Page.Close(self, ...)
end

function object:_StopDropdown()
	if self._dropdown_slot then
		self._dropdown_slot:Cancel()
		self._dropdown_slot = nil
	end

	self.ContractsDropdownButton.Visible = true
end

function object:_StartDropdown()
	self:_StopDropdown()
	self.ContractsDropdownButton.Visible = false
	self._dropdown_slot = DropdownSlot.new(self.ContractsDropdownFrame, { "Near Completion", "Most Played" })
	self._dropdown_slot.Selected:Connect(function(text)
		if text then
			self.ContractsDropdownTitle.Text = text
			self:_Generate()
		end

		self:_StopDropdown()
	end)
end

function object:_SetPercentContractGoalEnabled(percent_contract_goal_enabled)
	self._percent_contract_goal_enabled = percent_contract_goal_enabled

	for _, _contract_slot in pairs(self._contract_slots) do
		_contract_slot.GoalPercent.Visible = self._percent_contract_goal_enabled
		_contract_slot.Goal.Visible = not self._percent_contract_goal_enabled
	end
end

function object:_CreateDailyTaskStreakSlot(p)
	local v2 = p or false
	local clone = dailyTaskStreakSlot:Clone()

	local function update(p2, p3)
		clone.Visible = p2 and v2 == p3

		if not clone.Visible then
			return
		end

		local dailyTaskStreak = PlayerDataController:Get("DailyTaskStreak")
		local v3 = math.floor(dailyTaskStreak / TaskLibrary.NUM_DAILY_TASK_STREAK_REWARD_MILESTONES) * TaskLibrary.NUM_DAILY_TASK_STREAK_REWARD_MILESTONES + 1

		for i = v3, v3 + TaskLibrary.NUM_DAILY_TASK_STREAK_REWARD_MILESTONES - 1 do
			local dailyTaskStreakReward = TaskLibrary.DailyTaskStreakRewards[(i - 1) % TaskLibrary.NUM_DAILY_TASK_STREAK_REWARD_MILESTONES + 1]
			local v4 = not dailyTaskStreakReward.CanMultiplyRewards and 1 or math.min(
				TaskLibrary.DAILY_TASK_STREAK_REWARD_MAX_MULTIPLIER,
				(math.ceil(i / TaskLibrary.NUM_DAILY_TASK_STREAK_REWARD_MILESTONES))
			)
			local visible = i <= dailyTaskStreak
			local v6 = i == dailyTaskStreak + 1
			local _ = dailyTaskStreak + 1 < i
			local v7 = (v6 and not p3 or visible) and 0 or 0.9
			local clone2 = dailyTaskStreakMilestoneSlot:Clone()
			clone2.LayoutOrder = i
			clone2.Completed.Visible = visible
			clone2.Date.Visible = not visible
			clone2.Date.Value.Text = i
			clone2.Date.Value.TextTransparency = v7
			clone2.Date.Title.TextTransparency = v7
			clone2.Background.Circle.BackgroundTransparency = visible and 0 or 1
			clone2.Background.Circle.UIStroke.Transparency = v7
			clone2.Background.Circle.UIStroke.Thickness = visible and 2 or v6 and 2 or 1
			clone2.Background.Dash.BackgroundTransparency = v7
			clone2.Background.Dash.Visible = i ~= v3
			clone2.Reward.Visible = not visible
			clone2.Parent = clone.Container.Milestones
			table.insert(self._daily_task_streak_cleanup, clone2)

			for _, v8 in pairs(dailyTaskStreakReward.Rewards or {}) do
				local table2 = Utility:CloneTable(v8)
				table2.Quantity = (table2.Quantity or 1) * v4
				local v9 = RewardSlot.new(table2)
				v9:SetParent(clone2.Reward)
				table.insert(self._daily_task_streak_cleanup, v9)
				table.insert(self._daily_task_streak_reward_slots, v9)
			end
		end
	end

	table.insert(self._daily_task_streak_update_callbacks, update)
	update()
	return clone
end

function object:_UpdateDailyTaskStreak(...)
	for _, v2 in pairs(self._daily_task_streak_cleanup) do
		v2:Destroy()
	end

	self._daily_task_streak_cleanup = {}
	self._daily_task_streak_reward_slots = {}

	for _, _daily_task_streak_update_callback in pairs(self._daily_task_streak_update_callbacks) do
		_daily_task_streak_update_callback(...)
	end
end

function object:_Generate()
	for _, _task_slot in pairs(self._task_slots) do
		_task_slot:Destroy()
	end

	for _, _contract_slot in pairs(self._contract_slots) do
		_contract_slot:Destroy()
	end

	for _, _contract_divider in pairs(self._contract_dividers) do
		_contract_divider:Destroy()
	end

	self._task_slots = {}
	self._contract_slots = {}
	self._contract_dividers = {}
	local beginnerTasksCompleted = PlayerDataController:Get("BeginnerTasksCompleted")
	local visible = TaskLibrary.NUM_BEGINNER_TASKS <= beginnerTasksCompleted
	local areTasksCompleted = PlayerDataController:AreTasksCompleted()
	local v3 = EventLibrary.IS_ACTIVE and PlayerDataController:GetStatistic("StatisticDuelsPlayed") >= EventLibrary.NUM_GAMES_NEEDED_TO_PARTICIPATE
	local visible2 = #(PlayerDataController:Get("LimitedTasks") or {}) > 0
	self.TasksCompletedFrame.Visible = areTasksCompleted
	self.ContractsFrame.Visible = visible

	if self._to_shooting_range_button then
		self._to_shooting_range_button.Visible = CONSTANTS.SHOOTING_RANGE_ACTIVE and beginnerTasksCompleted <= TaskLibrary.NUM_BEGINNER_TASKS - 2
	end

	if self._to_duels_button then
		self._to_duels_button.Visible = CONSTANTS.QUEUES_ACTIVE and TaskLibrary.NUM_BEGINNER_TASKS - 1 <= beginnerTasksCompleted
	end

	local specialChallenges = self._task_containers.SpecialChallenges
	specialChallenges.Visible = PlayerDataController:Get("SpecialChallenges") ~= nil and not PlayerDataController:AreTasksCompleted("SpecialChallenges")
	self._task_containers.EventTasks.Visible = areTasksCompleted and v3
	self._task_containers.LimitedTasks.Visible = visible2
	self._task_containers.BonusTasks.Visible = areTasksCompleted
	self._task_containers.Tasks.Visible = not areTasksCompleted
	self._task_containers.Tasks.Container.Title.Text = visible and "Daily Tasks" or "Beginner Tasks   [" .. beginnerTasksCompleted + 1 .. " / " .. TaskLibrary.NUM_BEGINNER_TASKS .. "]"
	TimerController:OnStep("TaskPageTaskRefresh", "TaskRefresh", areTasksCompleted and function(_, p)
		self.TasksCompletedTimerText.Text = "new tasks in " .. p
	end or nil)
	self:_GenerateTasks(areTasksCompleted, visible, v3, visible2)

	if visible then
		self:_GenerateContracts()
	end
end

function object:_GenerateTasks(p, p2, p3, _)
	local v2 = p and { "BonusTasks" } or { "Tasks" }

	if p and p3 then
		table.insert(v2, "EventTasks")
	end

	if TaskLibrary.SPECIAL_CHALLENGES then
		table.insert(v2, "SpecialChallenges")
	end

	table.insert(v2, "LimitedTasks")
	local currentlyActiveLimitedTasks = TaskLibrary:GetCurrentlyActiveLimitedTasks()

	for _, v3 in pairs(v2) do
		local _task_container = self._task_containers[v3]
		local v4 = PlayerDataController:Get(v3)

		if not v4 then
			continue
		end

		local SPECIAL_CHALLENGES_MUST_BE_COMPLETED_IN_ORDER = v3 == "SpecialChallenges" and TaskLibrary.SPECIAL_CHALLENGES_MUST_BE_COMPLETED_IN_ORDER

		if not SPECIAL_CHALLENGES_MUST_BE_COMPLETED_IN_ORDER then
			if v3 == "LimitedTasks" then
				SPECIAL_CHALLENGES_MUST_BE_COMPLETED_IN_ORDER = currentlyActiveLimitedTasks and currentlyActiveLimitedTasks.RequiresPreviousTaskCompleted
			else
				SPECIAL_CHALLENGES_MUST_BE_COMPLETED_IN_ORDER = false
			end
		end

		local v5 = false

		for k, v6 in pairs(v4) do
			local v7

			if SPECIAL_CHALLENGES_MUST_BE_COMPLETED_IN_ORDER then
				if k > 1 then
					v7 = not v4[k - 1].Completed
				else
					v7 = false
				end
			else
				v7 = SPECIAL_CHALLENGES_MUST_BE_COMPLETED_IN_ORDER
			end

			local v8 = TaskSlot.new(v6)
			v8:SetLocked(v7, v5)
			v8:SetParent(_task_container.Container.Contents.Slots.Container)
			table.insert(self._task_slots, v8)
			v5 = v7
		end
	end

	self:_UpdateDailyTaskStreak(p2, p)
end

function object:_GenerateContracts()
	local v2 = self.ContractsDropdownTitle.Text == "Near Completion" and "FilterProgress" or "FilterPlaytime"
	local count = 0

	local function get_layout_order_from_group(p)
		return p * 99999
	end

	local function generate(p, value, contractName, progress)
		local contract = ContractsLibrary.Contracts[contractName]
		local v3 = StatisticsLibrary.Info[contract.StatisticName]
		local v4 = string.find(contractName, " Rounds Won") and 6 or string.find(contractName, " Playtime") and 4 or 2
		local v5 = p or value or "???"

		for k, list in pairs(contract.Milestones) do
			local v6, v7 = table.unpack(list)
			local visible = v6 <= progress

			if visible and k < #contract.Milestones then
				continue
			end

			count += 1
			local clone = taskContractMilestoneSlot:Clone()
			clone.Progress.Bar.Size = UDim2.new(math.clamp(progress / v6, 0, 1), 0, 1, 2)
			clone.Progress.Bar.BackgroundColor3 = visible and Color3.fromRGB(100, 255, 50) or Color3.fromRGB(
				0,
				190,
				255
			)
			clone.Completed.Visible = visible
			clone.Goal.Text = visible and "" or string.format(
				"%s <font size=\"8\">/ %s</font>",
				v3.TostringFunction(progress),
				v3.TostringFunction(v6)
			)
			clone.GoalPercent.Text = visible and "" or string.format("%.1f", progress / v6 * 100) .. "%"
			clone.Title.Text = v5 .. "  •  " .. v3.FullDisplayName
			clone.Weapon.Image = p and ItemLibrary.Items[p].Image or ""
			clone.Map.Image = value and DuelLibrary.Maps[value].Image or ""
			clone.LayoutOrder = v4 * 99999
			clone.Parent = self.ContractsMilestones
			table.insert(self._contract_slots, clone)

			if v7 and not visible then
				RewardSlot.new(v7):SetParent(clone.Reward)
				break
			else
				break
			end
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function get_current_milestone_info(contract, weaponStatistic)
		for _, list in pairs(contract.Milestones) do
			local v3, _ = table.unpack(list)

			if not (v3 <= weaponStatistic) then
				return list
			end
		end

		return contract.Milestones[#contract.Milestones]
	end

	local function get_sorted_contracts(items, p, p2)
		local result = {}

		for _, item in pairs(items) do
			local weaponContracts

			if p2 then
				weaponContracts = ContractsLibrary:GetWeaponContracts(item)
			else
				weaponContracts = ContractsLibrary:GetMapContracts(item)
			end

			local contractName = weaponContracts and weaponContracts[p]

			if not contractName then
				continue
			end

			local contract = ContractsLibrary.Contracts[contractName]
			local weaponStatistic

			if p2 then
				weaponStatistic = PlayerDataController:GetWeaponStatistic(
					contract.Identifier,
					contract.StatisticName,
					contract.ExtraStatisticNames
				)
			else
				weaponStatistic = PlayerDataController:GetMapStatistic(
					contract.Identifier,
					contract.StatisticName,
					contract.ExtraStatisticNames
				)
			end

			local v4 = get_current_milestone_info(contract, weaponStatistic) -- equivalent call inferred; original call site unknown
			local goal = v4[1]
			local filterPlaytime

			if p2 then
				filterPlaytime = PlayerDataController:GetWeaponStatistic(item, "StatisticPlaytime")
			else
				filterPlaytime = PlayerDataController:GetMapStatistic(item, "StatisticPlaytime")
			end

			local v6 = {
				Name = item,
				ContractName = contractName,
				Progress = weaponStatistic,
				Goal = goal,
				FilterPlaytime = filterPlaytime,
				FilterProgress = -(goal - weaponStatistic)
			}
			table.insert(result, v6)
		end

		table.sort(result, function(a, b)
			local v3 = a.Progress >= a.Goal
			local selected = b.Progress >= b.Goal

			if v3 ~= selected then
				return selected
			end

			if math.abs(a[v2] - b[v2]) > 0.001 then
				return a[v2] > b[v2]
			end

			return Utility:StringLessThan(a.Name, b.Name)
		end)
		return result
	end

	for _, v3 in pairs({ 3, 5 }) do
		local clone = taskContractMilestoneDivider:Clone()
		clone.LayoutOrder = v3 * 99999
		clone.Parent = self.ContractsMilestones
		table.insert(self._contract_dividers, clone)
	end

	local function get_sorted_weapons(i, i2)
		local names = {}

		for _, v3 in pairs(PlayerDataController:Get("WeaponInventory")) do
			local name = v3.Name

			if ItemLibrary.Classes[ItemLibrary.Items[name].Class].Slot == i then
				table.insert(names, name)
			end
		end

		return (get_sorted_contracts(names, i2, true))
	end

	for i = 1, 2 do
		for i2 = 1, 4 do
			local v3 = get_sorted_weapons(i2, i)

			for _, v5 in pairs(v3) do
				generate(v5.Name, nil, v5.ContractName, v5.Progress)
				break
			end
		end
	end

	local function get_sorted_maps(p)
		local v3 = {}

		for _, v4 in pairs(DuelLibrary.MapOrder) do
			table.insert(v3, v4)
		end

		return (get_sorted_contracts(v3, p, false))
	end

	local v3 = get_sorted_maps(1)

	for i = 1, 4 do
		local v4 = v3[i]
		generate(nil, v4.Name, v4.ContractName, v4.Progress)
	end

	self:_SetPercentContractGoalEnabled(self._percent_contract_goal_enabled)
end

function object:_Setup()
	self.ContractsDropdownTitle.Text = "Near Completion"

	for k, list in pairs(v) do
		local v2, displayName, image, imageSize, description = table.unpack(list)

		if v2 == "LimitedTasks" then
			local currentlyActiveLimitedTasks = TaskLibrary:GetCurrentlyActiveLimitedTasks()

			if currentlyActiveLimitedTasks then
				displayName = currentlyActiveLimitedTasks.DisplayName
				image = currentlyActiveLimitedTasks.Image
				imageSize = currentlyActiveLimitedTasks.ImageSize
				description = currentlyActiveLimitedTasks.Description
			end
		end

		local clone = taskContainer:Clone()
		clone.Container.Buttons.Visible = v2 == "Tasks"
		clone.Container.Title.Text = displayName or ""
		clone.Container.Title.ImageLabel.Image = image or ""
		clone.Container.Title.ImageLabel.Size = imageSize or UDim2.new(1.5, 0, 1, 0)
		clone.Container.Description.Text = description or ""
		clone.LayoutOrder = -999 + k
		clone.Parent = self.Container
		self._task_containers[v2] = clone

		-- equivalent calls inferred from this helper; original call sites unknown
		local function update_slots()
			clone.Container.Contents.Slots.Size = UDim2.new(
				1,
				0,
				0,
				clone.Container.Contents.Slots.Container.Layout.AbsoluteContentSize.Y
			)
		end

		clone.Container.Contents.Slots.Container.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(update_slots)
		update_slots() -- equivalent call inferred; original call site unknown
		local v4 = clone

		local function update_frame()
			pcall(function()
				v4.Size = UDim2.new(
					1,
					0,
					0,
					v4.Container.AbsoluteSize.Y * 0.2 + v4.Container.Contents.Layout.AbsoluteContentSize.Y
				)
				v4.Visible = v4.Container.Contents.Layout.AbsoluteContentSize.Y > 1 and #v4.Container.Contents.Slots.Container:GetChildren() > 1
			end)
		end

		clone.Container.Contents.Slots.Container.ChildAdded:Connect(update_frame)
		clone.Container.Contents.Slots.Container.ChildRemoved:Connect(update_frame)
		clone.Container.Contents.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(update_frame)
		clone.Container:GetPropertyChangedSignal("AbsoluteSize"):Connect(update_frame)
		local v5 = clone
		pcall(function()
			v5.Size = UDim2.new(
				1,
				0,
				0,
				v5.Container.AbsoluteSize.Y * 0.2 + v5.Container.Contents.Layout.AbsoluteContentSize.Y
			)
			v5.Visible = v5.Container.Contents.Layout.AbsoluteContentSize.Y > 1 and #v5.Container.Contents.Slots.Container:GetChildren() > 1
		end)

		if v2 == "Tasks" then
			local _CreateDailyTaskStreakSlot = self:_CreateDailyTaskStreakSlot(false)
			_CreateDailyTaskStreakSlot.Parent = clone.Container.Contents
			self._to_shooting_range_button = clone.Container.Buttons.ToShootingRange
			self._to_duels_button = clone.Container.Buttons.ToDuels
			self._to_shooting_range_button.Button.MouseButton1Click:Connect(function()
				self:CloseRequest()
				ShootingRangeController:Enter(true)
			end)
			self._to_duels_button.Button.MouseButton1Click:Connect(function()
				self:CloseRequest()
				LobbyController:ToDuels()
			end)
			ButtonEffect:Add(self._to_duels_button.Button, nil, {
				HoverRatio = UDim2.new(0, 10, 0, 10),
				ReleaseRatio = UDim2.new(0, 10, 0, 10)
			})
			ButtonEffect:Add(self._to_shooting_range_button.Button, nil, {
				HoverRatio = UDim2.new(0, 10, 0, 10),
				ReleaseRatio = UDim2.new(0, 10, 0, 10)
			})
		elseif v2 == "LimitedTasks" then
			local v6 = clone
			table.insert(self._while_open_callbacks, function()
				local currentlyActiveLimitedTasks = TaskLibrary:GetCurrentlyActiveLimitedTasks()
				local v7 = currentlyActiveLimitedTasks and math.floor(currentlyActiveLimitedTasks.FinishTimestamp - ServerOsTime:Get())
				v6.Container.Description.Text = v7 and v7 > 0 and Utility:TimeFormat2(v7) or "• • •"
			end)
		end
	end

	local _CreateDailyTaskStreakSlot_2 = self:_CreateDailyTaskStreakSlot(true)
	_CreateDailyTaskStreakSlot_2.Parent = self.TasksCompletedContentsFrame
	RewardSlot.new({
		Name = "Key",
		Quantity = TaskLibrary.Info.Core1.Rewards[1].Quantity + TaskLibrary.Info.Core2.Rewards[1].Quantity + TaskLibrary.Info.Core3.Rewards[1].Quantity
	}):SetParent(self.TasksCompletedRefreshRewardsFrame)
	local v2 = RewardSlot.new({
		Name = TaskLibrary.DAILY_TASKS_RARE_REWARD,
		Weapon = "IsRandom"
	})
	v2.CosmeticSlot.Frame.Button.Title.Size = UDim2.new(0.9, 0, 0.4, 0)
	v2.CosmeticSlot.Frame.Button.Title.Text = math.floor(TaskLibrary.DAILY_TASKS_RARE_REWARD_CHANCE * 1000) / 10 .. "%"
	v2:SetParent(self.TasksCompletedRefreshRewardsFrame)
	local v3 = RewardSlot.new({
		Name = TaskLibrary.DAILY_TASKS_LEGENDARY_REWARD,
		Weapon = "IsRandom"
	})
	v3.CosmeticSlot.Frame.Button.Title.Size = UDim2.new(0.9, 0, 0.4, 0)
	v3.CosmeticSlot.Frame.Button.Title.Text = math.floor(TaskLibrary.DAILY_TASKS_LEGENDARY_REWARD_CHANCE * 1000) / 10 .. "%"
	v3:SetParent(self.TasksCompletedRefreshRewardsFrame)
	MonetizationController:SetRobuxText(
		self.TasksCompletedRefreshButtonText,
		MonetizationLibrary.Products.RefreshTasks.ProductID
	)
end

function object:_Init()
	self.CloseButton.MouseButton1Click:Connect(function()
		self:CloseRequest()
	end)
	self.TasksCompletedRefreshButton.MouseButton1Click:Connect(function()
		MonetizationController:PromptProductPurchase(MonetizationLibrary.Products.RefreshTasks.ProductID)
	end)
	self.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self.List.CanvasSize = UDim2.new(0, 0, 0, self.Layout.AbsoluteContentSize.Y)
		self.List.Active = self.List.CanvasSize.Y.Offset > self.List.AbsoluteSize.Y
		self.List.Position = self.List.Active and UDim2.new(0.5, 0, 0, 0) or UDim2.new(0.5, 0, 0.2, 0)
		self.CloseButton.Position = self.List.Active and UDim2.new(1.075, 16, 0.0375, 0) or UDim2.new(
			1.075,
			16,
			0.2375,
			0
		)
	end)
	self.TasksCompletedContentsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self.TasksCompletedFrame.Size = UDim2.new(1, 0, 0, self.TasksCompletedContentsLayout.AbsoluteContentSize.Y)
	end)
	self.ContractsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self.ContractsFrame.Size = UDim2.new(
			1,
			0,
			0,
			self.ContractsContainer.AbsoluteSize.Y * 0.15 + self.ContractsLayout.AbsoluteContentSize.Y
		)
	end)
	self.ContractsFilterButton.MouseButton1Click:Connect(function()
		self:_SetPercentContractGoalEnabled(not self._percent_contract_goal_enabled)
	end)
	self.ContractsDropdownButton.MouseButton1Click:Connect(function()
		self:_StartDropdown()
	end)
	self:_Setup()
	ButtonEffect:Add(self.CloseButton)
	ButtonEffect:Add(self.ContractsFilterButton)
	ButtonEffect:Add(self.TasksCompletedRefreshButton, nil, {
		HoverRatio = UDim2.new(0, 8, 0, 8),
		ReleaseRatio = UDim2.new(0, 8, 0, 8)
	})
	ButtonEffect:Add(self.ContractsDropdownButton, nil, {
		ReleaseRatio = 1.025,
		HoverRatio = 1.025
	})
end

return object._new()