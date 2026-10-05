local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local EventLibrary = require(ReplicatedStorage.Modules.EventLibrary)
local TaskLibrary = require(ReplicatedStorage.Modules.TaskLibrary)
local Utility = require(ReplicatedStorage.Modules.Utility)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
local RewardSlot = require(Players.LocalPlayer.PlayerScripts.Modules.RewardSlot)
local taskSlot = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("TaskSlot")
local TaskSlot = {}
TaskSlot.__index = TaskSlot

function TaskSlot.new(taskData)
	local self = setmetatable({}, TaskSlot)
	self.TaskData = taskData
	self.Info = TaskLibrary.Info[self.TaskData.Name]
	self.Frame = taskSlot:Clone()
	self._connections = {}
	self._reward_slots = {}
	self._notification_visible = false
	self:_Init()
	return self
end

function TaskSlot:SetParent(parent)
	self.Frame.Parent = parent
end

function TaskSlot:SetLocked(visible, _)
	self.Frame.Unlocked.Visible = not visible
	self.Frame.Locked.Visible = visible
	self.Frame.Locked.Icon.Position = UDim2.new(0.5, 0, 0.375, 0)
	self.Frame.Locked.Title.Visible = false
end

function TaskSlot:ShowNotification(p2)
	self.Frame.Unlocked.Title.Notification.Visible = p2 and not self.TaskData.Completed
end

function TaskSlot:Destroy()
	for _, _connection in pairs(self._connections) do
		_connection:Disconnect()
	end

	self:_ClearRewards()
	self.Frame:Destroy()
end

function TaskSlot:_UpdateNotification()
	self.Frame.Unlocked.Title.Notification.Position = UDim2.new(
		0.5,
		self.Frame.Unlocked.Title.TextBounds.X / 2 + self.Frame.Unlocked.Title.Notification.AbsoluteSize.X / 2,
		0.5,
		0
	)
end

function TaskSlot:_ClearRewards()
	for _, _reward_slot in pairs(self._reward_slots) do
		_reward_slot:Destroy()
	end

	self._reward_slots = {}
end

function TaskSlot:_UpdateRewards()
	self:_ClearRewards()
	local v = { self.Info.Rewards, self.TaskData.BonusRewards or {} }

	for _, v2 in pairs(v) do
		for _, v3 in pairs(v2) do
			local table2 = Utility:CloneTable(v3)

			if table2.Name == "EventCurrency" and PlayerDataController:Get("EventCurrencyRushProgress") < EventLibrary.CURRENCY_RUSH_DAILY_LIMIT and self.Info.CanBeMultipliedByEventBoost then
				table2.Quantity *= EventLibrary.CURRENCY_RUSH_MULTIPLIER
			end

			local v4 = RewardSlot.new(table2)
			v4:SetParent(self.Frame.Reward)
			table.insert(self._reward_slots, v4)
		end
	end
end

function TaskSlot:_UpdateName()
	local v = PlayerDataController:Get("TasksCompletedToday")[self.TaskData.Name] or 0
	local v2 = not (self.Info.MaxCompletionsPerDay and v < self.Info.MaxCompletionsPerDay) and "" or " [" .. v + 1 .. "/" .. self.Info.MaxCompletionsPerDay .. "]"
	self.Frame.Unlocked.Title.Text = self.Info.Title .. v2
end

function TaskSlot:_Setup()
	local goal = self.TaskData.Goal or self.Info.Goal
	local completed = self.TaskData.Completed
	local v = #self.Info.Title > 20 and 1.5 or 1
	self.Frame.Unlocked.Progress.Bar.Size = UDim2.new(math.clamp(self.TaskData.Progress / goal, 0, 1), 0, 1, 2)
	self.Frame.Unlocked.Progress.Bar.BackgroundColor3 = completed and Color3.fromRGB(100, 255, 50) or Color3.fromRGB(
		0,
		190,
		255
	)
	self.Frame.Unlocked.Progress.Title.Text = self.TaskData.Progress .. " / " .. goal
	self.Frame.Unlocked.Progress.Title.Visible = not completed
	self.Frame.Unlocked.Progress.Completed.Visible = completed
	self.Frame.Unlocked.Title.Size = UDim2.new(0.8, 0, v * 0.1, 0)
	self.Frame.Unlocked.Title.Notification.Size = UDim2.new(1 / v, 0, 1 / v, 0)
	self.Frame.Unlocked.Title.TextColor3 = completed and Color3.fromRGB(100, 255, 50) or Color3.fromRGB(255, 255, 255)
	self.Frame.Unlocked.Icon.Image = self.Info.Icon
	self.Frame.Unlocked.Icon.ImageColor3 = completed and Color3.fromRGB(100, 255, 50) or Color3.fromRGB(255, 255, 255)
	self.Frame.Background.BackgroundColor3 = completed and Color3.fromRGB(100, 255, 50) or Color3.fromRGB(255, 255, 255)
	self.Frame.Background.UIStroke.Color = completed and Color3.fromRGB(100, 255, 50) or Color3.fromRGB(255, 255, 255)
end

function TaskSlot:_Init()
	self.Frame.Unlocked.Title:GetPropertyChangedSignal("TextBounds"):Connect(function()
		self:_UpdateNotification()
	end)
	self.Frame.Unlocked.Title:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self:_UpdateNotification()
	end)
	self.Frame.Unlocked.Title.Notification:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self:_UpdateNotification()
	end)
	table.insert(
		self._connections,
		PlayerDataController:GetDataChangedSignal("EventCurrencyRushProgress"):Connect(function()
			self:_UpdateRewards()
		end)
	)
	table.insert(self._connections, PlayerDataController:GetDataChangedSignal("TasksCompletedToday"):Connect(function()
		self:_UpdateName()
	end))
	self:_Setup()
	self:_UpdateName()
	self:_UpdateRewards()
	self:_UpdateNotification()
	self:ShowNotification(false)
	self:SetLocked(false)
end

return TaskSlot