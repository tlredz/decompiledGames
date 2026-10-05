local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local StatisticsLibrary = require(ReplicatedStorage.Modules.StatisticsLibrary)
local ContractsLibrary = require(ReplicatedStorage.Modules.ContractsLibrary)
local TaskLibrary = require(ReplicatedStorage.Modules.TaskLibrary)
local ItemLibrary = require(ReplicatedStorage.Modules.ItemLibrary)
local Spring = require(ReplicatedStorage.Modules.Spring)
local ShootingRangeController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("ShootingRangeController"))
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("PlayerDataController"))
local SpectateController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("SpectateController"))
local FighterController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("FighterController"))
local LobbyController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("LobbyController"))
local TimerController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("TimerController"))
local WeaponStatusHandler = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("WeaponStatusHandler"))
local MobileInputs = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface:WaitForChild("MobileInputs"))
local Teleporting = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface:WaitForChild("Teleporting"))
local Equipment = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface:WaitForChild("Equipment"))
local Pages = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface:WaitForChild("Pages"))
local Queue = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface:WaitForChild("Queue"))
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ButtonEffect"))
local RewardSlot = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("RewardSlot"))
local UILibrary = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("UILibrary"))
local sideContractSlot = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("SideContractSlot")
local sideTaskSlot = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("SideTaskSlot")
local uDim = UDim2.new(-1, -10, 0.5, 0)
local uDim2 = UDim2.new(0, 10, 0.5, 0)
local uDim3 = UDim2.new(0.25, 90, 0.208, 75)
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self.Frame = UILibrary:GetTo("MainFrame", "SideTasks")
	self._local_fighter = nil
	self._side_slots = {}
	self._duel_connections = {}
	self._teleport_cooldown = 0
	self._generate_queued = false
	self._center_alert_hash = 0
	self._center_alert_connection = nil
	self._is_open = false
	self:_Init()
	return self
end

function class:_PlayCenterAlertEffect()
	if not (self._local_fighter and self._local_fighter:Get("IsInShootingRange")) or Pages.PageSystem.CurrentPage or not (PlayerDataController:Get("BeginnerTasksCompleted") < TaskLibrary.NUM_BEGINNER_TASKS) then
		return
	end

	if self._center_alert_connection then
		self._center_alert_connection:Disconnect()
		self._center_alert_connection = nil
	end

	self._center_alert_hash += 1
	local _center_alert_hash = self._center_alert_hash
	local v = Spring.new(0, 1, 10)
	self._center_alert_connection = RunService.RenderStepped:Connect(function()
		if self._center_alert_hash ~= _center_alert_hash then
			return
		end

		local value = v.Value
		local v2 = self.Frame.Parent.AbsolutePosition + self.Frame.Parent.AbsoluteSize / 2 - self.Frame.Container.AbsoluteSize.X * Vector2.new(
			0.5,
			0
		) - self.Frame.AbsolutePosition
		local uDim4 = UDim2.new(0, v2.X, 0, v2.Y)
		local uDim5 = UDim2.new(
			uDim2.X.Scale + (uDim4.X.Scale - uDim2.X.Scale) * value,
			uDim2.X.Offset + (uDim4.X.Offset - uDim2.X.Offset) * value,
			uDim2.Y.Scale + (uDim4.Y.Scale - uDim2.Y.Scale) * value,
			uDim2.Y.Offset + (uDim4.Y.Offset - uDim2.Y.Offset) * value
		)
		local container = self.Frame.Container

		if not self._is_open then
			uDim5 = uDim
		end

		container:TweenPosition(uDim5, "InOut", "Linear", 0, true)
		self.Frame.Container.Background.UIGradient.Transparency = NumberSequence.new(0, 1 - value)
	end)
	v.Target = 1
	self.Frame.Container.Size = uDim3
	self.Frame.Container:TweenSize(
		UDim2.new(uDim3.X.Scale * 1.25, uDim3.X.Offset * 1.25, uDim3.Y.Scale * 1.25, uDim3.Y.Offset * 1.25),
		"InOut",
		"Quint",
		0.75,
		true
	)

	for _ = 1, 5 do
		wait(0.06)

		if self._center_alert_hash ~= _center_alert_hash then
			return
		end

		self.Frame.Container.Visible = true
		wait(0.12)

		if self._center_alert_hash ~= _center_alert_hash then
			return
		end
	end

	wait(2)

	if self._center_alert_hash ~= _center_alert_hash then
		return
	end

	v.Target = 0
	self.Frame.Container:TweenSize(uDim3, "Out", "Quint", 0.5, true)
	wait(2)

	if self._center_alert_hash ~= _center_alert_hash then
		return
	end

	self._center_alert_connection:Disconnect()
	self._center_alert_connection = nil
	local container = self.Frame.Container
	local position

	if self._is_open then
		position = uDim2
	else
		position = uDim
	end

	container.Position = position
	self.Frame.Container.Background.UIGradient.Transparency = NumberSequence.new(0, 1)
end

function class:_UpdateBackground()
	self.Frame.Container.Background.Size = UDim2.new(
		1,
		0,
		0,
		self.Frame.Container.Slots.BackgroundEnd.AbsolutePosition.Y - self.Frame.Container.Slots.AbsolutePosition.Y
	)
end

function class:_Generate()
	for _, _side_slot in pairs(self._side_slots) do
		_side_slot:Destroy()
	end

	self._side_slots = {}
	WeaponStatusHandler:ClearStatusElements(self.Frame.Container.Slots.Header.Title)
	self._generate_cooldown = tick() + 0.2
	local statistic = PlayerDataController:GetStatistic("StatisticFavoriteWeapon")
	local name = self._local_fighter and self._local_fighter.EquippedItem and self._local_fighter.EquippedItem.Name or (statistic == "N/A" or not statistic) and "Assault Rifle" or statistic
	local beginnerTasksCompleted = PlayerDataController:Get("BeginnerTasksCompleted")
	local v = TaskLibrary.NUM_BEGINNER_TASKS <= beginnerTasksCompleted
	local localDueler = self._local_fighter and not (Pages.PageSystem.CurrentPage or Equipment.IsOpen) and not (Queue:IsVisible() or Teleporting.Enabled or MobileInputs.EditorEnabled or GuiService.MenuIsOpen)

	if localDueler then
		if PlayerDataController:GetSetting("Hide Tasks In Duels") and SpectateController.CurrentDuelSubject and SpectateController.CurrentDuelSubject:Get("Status") ~= "RoundStarting" then
			localDueler = false
		elseif SpectateController.CurrentDuelSubject then
			localDueler = SpectateController.CurrentDuelSubject.LocalDueler

			if localDueler then
				if SpectateController.CurrentDuelSubject:Get("Status") == "GameOver" then
					localDueler = false
				else
					localDueler = not (SpectateController.CurrentDuelSubject.DuelInterface.Voting:IsOpen() or SpectateController.CurrentDuelSubject.DuelInterface.Scoreboard:IsOpen() or SpectateController.CurrentDuelSubject:Get("HideMostDuelInterfaceElements"))

					if localDueler then
						localDueler = not PlayerDataController:GetSetting("Hide HUD") and (PlayerDataController:GetStatistic("StatisticDuelsPlayed") >= 2 or self._local_fighter and self._local_fighter:Get("IsInShootingRange"))
					end
				end
			end
		else
			localDueler = not PlayerDataController:GetSetting("Hide HUD") and (PlayerDataController:GetStatistic("StatisticDuelsPlayed") >= 2 or self._local_fighter and self._local_fighter:Get("IsInShootingRange"))
		end
	end

	local v2 = localDueler and PlayerDataController:Get("TasksInterfaceOverride") ~= nil
	local v3 = not v2 and localDueler and not PlayerDataController:AreTasksCompleted()
	local v4 = not v2 and not v3 and localDueler and #ContractsLibrary:GetWeaponContracts(name) > 0
	self._is_open = v2 or v3 or v4
	local v5 = CONSTANTS.SHOOTING_RANGE_ACTIVE and v3 and beginnerTasksCompleted <= TaskLibrary.NUM_BEGINNER_TASKS - 2
	local v6 = CONSTANTS.QUEUES_ACTIVE and not (v2 or v5)
	self.Frame.Container.Slots.ToShootingRange.Visible = v5 and self._local_fighter and not (self._local_fighter:Get("IsInShootingRange") or SpectateController.CurrentDuelSubject)
	self.Frame.Container.Slots.ToDuels.Visible = v6 and not SpectateController.CurrentDuelSubject
	self.Frame.Container.Slots.ButtonsBuffer.Visible = self.Frame.Container.Slots.ToShootingRange.Visible or self.Frame.Container.Slots.ToDuels.Visible
	self.Frame.Container.Slots.Header.Title.Text = v2 and "Special Mission" or v4 and name or not v3 and "" or v and "Daily Tasks" or "Beginner Tasks   [" .. beginnerTasksCompleted + 1 .. " / " .. TaskLibrary.NUM_BEGINNER_TASKS .. "]" or ""
	self.Frame.Container.Slots.Header.Title.Icon.Image = not v4 and "rbxassetid://17653923757" or ItemLibrary.ViewModels[name].Image or "rbxassetid://17653923757"
	self.Frame.Container.Slots.Header.Title.Icon.Size = v4 and UDim2.new(6, 0, 4.5, 0) or UDim2.new(2, 0, 1.5, 0)

	if not v2 and v4 then
		WeaponStatusHandler:ApplyItemStatusToText(
			self.Frame.Container.Slots.Header.Title,
			ItemLibrary.Items[name].Status
		)
	end

	local function create_task_slot(layoutOrder, data)
		local taskInfo = data.TaskInfo or TaskLibrary.Info[data.Name]
		local goal = data.Goal or taskInfo.Goal
		local visible = goal <= data.Progress
		local clone = sideTaskSlot:Clone()
		clone.LayoutOrder = layoutOrder
		clone.Container.Progress.Bar.Size = UDim2.new(math.clamp(data.Progress / goal, 0, 1), 0, 1, 2)
		clone.Container.Progress.Bar.BackgroundColor3 = visible and Color3.fromRGB(100, 255, 50) or Color3.fromRGB(
			0,
			190,
			255
		)
		clone.Container.TitleContainer.Title.Text = taskInfo.Title
		clone.Container.Goal.Text = string.format("%s <font size=\"8\">/ %s</font>", data.Progress, goal)
		clone.Container.Goal.Visible = not visible
		clone.Container.Icon.Image = taskInfo.Icon
		clone.Completed.Visible = visible
		clone.Parent = self.Frame.Container.Slots
		table.insert(self._side_slots, clone)
		UILibrary:ScrollingTextLabel(
			clone.Container.TitleContainer,
			clone.Container.TitleContainer.Title,
			clone.Container.Goal
		)

		if not visible then
			for _, v8 in pairs({ taskInfo.Rewards, data.BonusRewards or {} }) do
				for _, v9 in pairs(v8) do
					local v10 = RewardSlot.new(v9)
					v10:SetBubbleAutoCloseDelay(3)
					v10:SetParent(clone.Reward)
				end
			end
		end
	end

	if v2 then
		for k, v7 in pairs(PlayerDataController:Get("TasksInterfaceOverride")) do
			create_task_slot(k, v7)
		end
	end

	if v3 then
		for k, v7 in pairs(PlayerDataController:Get("Tasks")) do
			create_task_slot(k, v7)
		end
	end

	local visible2

	if v4 then
		visible2 = true

		for k, v8 in pairs(ContractsLibrary:GetWeaponContracts(name)) do
			local contract = ContractsLibrary.Contracts[v8]
			local v9 = StatisticsLibrary.Info[contract.StatisticName]
			local weaponStatistic = PlayerDataController:GetWeaponStatistic(
				contract.Identifier,
				contract.StatisticName,
				contract.ExtraStatisticNames
			)

			for _, list in pairs(contract.Milestones) do
				local v11, v12 = table.unpack(list)

				if v11 <= weaponStatistic then
					continue
				end

				visible2 = false
				local clone = sideContractSlot:Clone()
				clone.LayoutOrder = k
				clone.Container.Progress.Bar.Size = UDim2.new(math.clamp(weaponStatistic / v11, 0, 1), 0, 1, 2)
				clone.Container.Goal.Text = string.format(
					"%s <font size=\"8\">/ %s</font>",
					v9.TostringFunction(weaponStatistic),
					v9.TostringFunction(v11)
				)
				clone.Container.TitleContainer.Title.Text = contract.FullDisplayName
				clone.Parent = self.Frame.Container.Slots
				table.insert(self._side_slots, clone)
				UILibrary:ScrollingTextLabel(
					clone.Container.TitleContainer,
					clone.Container.TitleContainer.Title,
					clone.Container.Goal
				)

				if v12 then
					local v13 = RewardSlot.new(v12)
					v13:SetBubbleAutoCloseDelay(3)
					v13.Frame.Parent = clone.Reward
				end

				break
			end
		end
	else
		visible2 = false
	end

	self.Frame.Container.Slots.ContractsCompleted.Visible = visible2
	self.Frame.Container.Slots.ContractsCompleted.Title.Text = "Congratulations! You've completed every " .. name .. " contract!"
	TimerController:OnStep(
		"LobbyTasks",
		"TaskRefresh",
		v3 and v and PlayerDataController:AreTasksCompleted() and function(_, p)
			self.Frame.Container.Slots.Header.Title.Text = "New tasks in " .. p
		end or nil
	)
	local container = self.Frame.Container
	local v8

	if self._is_open then
		v8 = uDim2
	else
		v8 = uDim
	end

	container:TweenPosition(v8, "Out", "Quint", self._is_open and 0.25 or 1.25, true)
	self:_UpdateBackground()
end

function class:_GenerateThrottled()
	if tick() > self._generate_cooldown then
		self:_Generate()
		return
	end

	if self._generate_queued then
		return
	end

	self._generate_queued = true
	task.delay(self._generate_cooldown - tick(), function()
		self._generate_queued = false
		self:_Generate()
	end)
end

function class:_UpdateCurrentDuelSubject()
	for _, _duel_connection in pairs(self._duel_connections) do
		_duel_connection:Disconnect()
	end

	self._duel_connections = {}

	if not SpectateController.CurrentDuelSubject then
		self:_Generate()
		return
	end

	table.insert(
		self._duel_connections,
		SpectateController.CurrentDuelSubject:GetDataChangedSignal("Status"):Connect(function()
			self:_Generate()
		end)
	)
	table.insert(
		self._duel_connections,
		SpectateController.CurrentDuelSubject:GetDataChangedSignal("HideMostDuelInterfaceElements"):Connect(function()
			self:_Generate()
		end)
	)
	table.insert(
		self._duel_connections,
		SpectateController.CurrentDuelSubject.DuelInterface.Voting.VisibilityChanged:Connect(function()
			self:_Generate()
		end)
	)
	table.insert(
		self._duel_connections,
		SpectateController.CurrentDuelSubject.DuelInterface.Scoreboard.VisibilityChanged:Connect(function()
			self:_Generate()
		end)
	)
	self:_Generate()
end

function class:_HookLocalFighter()
	self._local_fighter = FighterController:WaitForLocalFighter()
	self._local_fighter:GetDataChangedSignal("IsInShootingRange"):Connect(function()
		self:_Generate()
		self:_PlayCenterAlertEffect()
	end)
	self._local_fighter:GetDataChangedSignal("IsInDuel"):Connect(function()
		self:_Generate()
	end)
	self._local_fighter.EquippedItemChanged:Connect(function()
		self:_GenerateThrottled()
	end)
	self:_Generate()
	self:_PlayCenterAlertEffect()
end

function class:_Init()
	self.Frame.Container.Slots.ToShootingRange.Button.MouseButton1Click:Connect(function()
		if tick() < self._teleport_cooldown then
			return
		end

		self._teleport_cooldown = tick() + 1
		ShootingRangeController:Enter(true)
	end)
	self.Frame.Container.Slots.ToDuels.Button.MouseButton1Click:Connect(function()
		if tick() < self._teleport_cooldown then
			return
		end

		self._teleport_cooldown = tick() + 1
		LobbyController:ToDuels()
	end)
	self.Frame.Container.Slots:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
		self:_UpdateBackground()
	end)
	self.Frame.Container.Slots.BackgroundEnd:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
		self:_UpdateBackground()
	end)
	PlayerDataController:GetDataChangedSignal("BeginnerTasksCompleted"):Connect(function()
		self:_Generate()
		self:_PlayCenterAlertEffect()
	end)
	PlayerDataController:GetDataChangedSignal("Tasks"):Connect(function()
		self:_Generate()
	end)
	PlayerDataController:GetSettingChangedSignal("Hide Tasks In Duels"):Connect(function()
		self:_Generate()
	end)
	PlayerDataController:GetSettingChangedSignal("Hide HUD"):Connect(function()
		self:_Generate()
	end)
	PlayerDataController:GetDataChangedSignal("StatisticDuelsPlayed"):Connect(function()
		self:_Generate()
	end)
	PlayerDataController:GetDataChangedSignal("TasksInterfaceOverride"):Connect(function()
		self:_Generate()
	end)
	PlayerDataController.StatisticsUpdated:Connect(function()
		self:_Generate()
	end)
	Equipment.Opened:Connect(function()
		self:_Generate()
	end)
	Pages.PageSystem.PagesActivity:Connect(function()
		self:_Generate()
		self:_PlayCenterAlertEffect()
	end)
	Queue.VisibilityChanged:Connect(function()
		self:_Generate()
	end)
	Teleporting.EnabledChanged:Connect(function()
		self:_Generate()
	end)
	MobileInputs.EditorEnabledChanged:Connect(function()
		self:_Generate()
	end)
	SpectateController.DuelSubjectChanged:Connect(function()
		self:_UpdateCurrentDuelSubject()
	end)
	GuiService:GetPropertyChangedSignal("MenuIsOpen"):Connect(function()
		self:_Generate()
	end)
	self:_Generate()
	self:_UpdateCurrentDuelSubject()
	self:_UpdateBackground()
	task.spawn(self._HookLocalFighter, self)
	ButtonEffect:Add(self.Frame.Container.Slots.ToDuels.Button)
	ButtonEffect:Add(self.Frame.Container.Slots.ToShootingRange.Button)
end

return class._new()