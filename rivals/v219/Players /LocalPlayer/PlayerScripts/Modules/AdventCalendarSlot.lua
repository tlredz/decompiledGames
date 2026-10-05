local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local AdventCalendarLibrary = require(ReplicatedStorage.Modules.AdventCalendarLibrary)
local TaskLibrary = require(ReplicatedStorage.Modules.TaskLibrary)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
local TimerController = require(Players.LocalPlayer.PlayerScripts.Controllers.TimerController)
local RewardSlot = require(Players.LocalPlayer.PlayerScripts.Modules.RewardSlot)
local adventCalendarSlot = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("AdventCalendarSlot")
local AdventCalendarSlot = {}
AdventCalendarSlot.__index = AdventCalendarSlot

function AdventCalendarSlot.new(container)
	local self = setmetatable({}, AdventCalendarSlot)
	self.Container = container
	self.Frame = adventCalendarSlot:Clone()
	self.TitleText = self.Frame:WaitForChild("Title")
	self.Icon = self.TitleText:WaitForChild("ImageLabel")
	self.TimerText = self.Frame:WaitForChild("Timer")
	self.RewardsFrame = self.Frame:WaitForChild("Rewards")
	self._connections = {}
	self._reward_slots = {}
	self:_Init()
	return self
end

function AdventCalendarSlot:SetEnabled(p)
	for _, _connection in pairs(self._connections) do
		_connection:Disconnect()
	end

	self._connections = {}

	if not p then
		return
	end

	table.insert(self._connections, PlayerDataController:GetDataChangedSignal("Tasks"):Connect(function()
		self:_Update()
	end))
	table.insert(self._connections, PlayerDataController:GetDataChangedSignal("BonusTasks"):Connect(function()
		self:_Update()
	end))
	table.insert(self._connections, PlayerDataController:GetDataChangedSignal("StatisticDuelsPlayed"):Connect(function()
		self:_Update()
	end))
	table.insert(self._connections, PlayerDataController:GetDataChangedSignal("SpecialChallenges"):Connect(function()
		self:_Update()
	end))
	table.insert(
		self._connections,
		PlayerDataController:GetDataChangedSignal("BeginnerTasksCompleted"):Connect(function()
			self:_Update()
		end)
	)
	table.insert(self._connections, TimerController.TimerUpdated:Connect(function()
		self:_Update()
	end))
	self:_Update()
end

function AdventCalendarSlot:_Update()
	for _, _reward_slot in pairs(self._reward_slots) do
		_reward_slot:Destroy()
	end

	self._reward_slots = {}
	local reward = AdventCalendarLibrary:GetReward()
	local v = PlayerDataController:Get("BeginnerTasksCompleted") >= TaskLibrary.NUM_BEGINNER_TASKS
	self.Container.Visible = v and reward ~= nil

	if not self.Container.Visible then
		return
	end

	local reward2 = AdventCalendarLibrary:GetReward(1)
	local v2 = PlayerDataController:Get("AdventCalendarLastDayClaimed") >= reward.Day
	self.TitleText.Text = "Advent Calendar - Day " .. reward.Day
	self.Icon.Image = v2 and "rbxassetid://17588806026" or "rbxassetid://71486631710031"
	self.Icon.ImageColor3 = v2 and Color3.fromRGB(100, 255, 50) or Color3.fromRGB(255, 255, 255)
	self.TimerText.Text = v2 and (reward2 and "" or "Advent Calendar completed!") or "Complete your Daily Tasks to claim!"
	TimerController:OnStep("TaskPageAdventCalendar", "AdventCalendar", v2 and reward and reward2 and function(_, p)
		self.TimerText.Text = "next reward in " .. p
	end or nil)

	for _, reward3 in pairs(reward.Rewards) do
		local v3 = RewardSlot.new(reward3)
		v3:SetParent(self.RewardsFrame)
		table.insert(self._reward_slots, v3)
	end
end

function AdventCalendarSlot:_Setup()
	self.Frame.Parent = self.Container
end

function AdventCalendarSlot:_Init()
	self:_Setup()
end

return AdventCalendarSlot