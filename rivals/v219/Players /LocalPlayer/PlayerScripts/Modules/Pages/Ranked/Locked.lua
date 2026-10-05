local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local PlayerDataUtility = require(ReplicatedStorage.Modules.PlayerDataUtility)
local SeasonLibrary = require(ReplicatedStorage.Modules.SeasonLibrary)
local Utility = require(ReplicatedStorage.Modules.Utility)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("PlayerDataController"))
local SeasonController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("SeasonController"))
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ButtonEffect"))
local Locked = {}
Locked.__index = Locked

function Locked.new(page)
	local self = setmetatable({}, Locked)
	self.Page = page
	self.UnlockedFrame = self.Page.PageFrame:WaitForChild("Unlocked")
	self.LockedFrame = self.Page.PageFrame:WaitForChild("Locked")
	self.LockedCloseButton = self.LockedFrame:WaitForChild("Close")
	self.LockedLevelFrame = self.LockedFrame:WaitForChild("Level")
	self.LockedLevelBar = self.LockedLevelFrame:WaitForChild("Progress"):WaitForChild("Bar")
	self.LockedLevelGoalText = self.LockedLevelFrame:WaitForChild("Goal")
	self.LockedLevelCompleted = self.LockedLevelFrame:WaitForChild("Completed")
	self.LockedLevelText = self.LockedLevelFrame:WaitForChild("Title")
	self.LockedWinsFrame = self.LockedFrame:WaitForChild("Wins")
	self.LockedWinsBar = self.LockedWinsFrame:WaitForChild("Progress"):WaitForChild("Bar")
	self.LockedWinsGoalText = self.LockedWinsFrame:WaitForChild("Goal")
	self.LockedWinsCompleted = self.LockedWinsFrame:WaitForChild("Completed")
	self.LockedWinsText = self.LockedWinsFrame:WaitForChild("Title")
	self.LockedAgeFrame = self.LockedFrame:WaitForChild("Age")
	self.LockedAgeBar = self.LockedAgeFrame:WaitForChild("Progress"):WaitForChild("Bar")
	self.LockedAgeGoalText = self.LockedAgeFrame:WaitForChild("Goal")
	self.LockedAgeCompleted = self.LockedAgeFrame:WaitForChild("Completed")
	self.LockedAgeText = self.LockedAgeFrame:WaitForChild("Title")
	self.LockedTasksFrame = self.LockedFrame:WaitForChild("Tasks")
	self.LockedTasksBar = self.LockedTasksFrame:WaitForChild("Progress"):WaitForChild("Bar")
	self.LockedTasksGoalText = self.LockedTasksFrame:WaitForChild("Goal")
	self.LockedTasksCompleted = self.LockedTasksFrame:WaitForChild("Completed")
	self.LockedTasksText = self.LockedTasksFrame:WaitForChild("Title")
	self.LockedTrustedFrame = self.LockedFrame:WaitForChild("Trusted")
	self.LockedTrustedBar = self.LockedTrustedFrame:WaitForChild("Progress"):WaitForChild("Bar")
	self.LockedTrustedGoalText = self.LockedTrustedFrame:WaitForChild("Goal")
	self.LockedTrustedCompleted = self.LockedTrustedFrame:WaitForChild("Completed")
	self.LockedTrustedText = self.LockedTrustedFrame:WaitForChild("Title")
	self._thread = nil
	self:_Init()
	return self
end

function Locked:Open()
	self:_Update()
end

function Locked.Close(_) end

function Locked:_Update()
	local BEGINNER_QUEUE_WINS = CONSTANTS.BEGINNER_QUEUE_WINS
	local statistic = PlayerDataController:GetStatistic("StatisticDuelsWon")
	local levelRequirement = SeasonLibrary.CurrentSeason.LevelRequirement
	local level = PlayerDataController:Get("Level")
	local accountAgeRequirement = SeasonLibrary.CurrentSeason.AccountAgeRequirement
	local accountAge = Players.LocalPlayer.AccountAge
	local tasksCompletedRequirement = SeasonLibrary.CurrentSeason.TasksCompletedRequirement
	local statistic2 = PlayerDataController:GetStatistic("StatisticTasksCompleted")
	local bypassTrustworthySpendRequirement = SeasonLibrary.CurrentSeason.BypassTrustworthySpendRequirement
	local v

	if Players.LocalPlayer:GetAttribute("IsTrustworthy") then
		v = bypassTrustworthySpendRequirement
	else
		v = PlayerDataUtility:GetRobuxSpent(
			PlayerDataController:Get("Receipts"),
			PlayerDataController:Get("Gamepasses"),
			PlayerDataController:Get("CompressedReceipts")
		)
	end

	local v2 = {
		{
			self.LockedWinsBar,
			self.LockedWinsGoalText,
			self.LockedWinsCompleted,
			statistic,
			BEGINNER_QUEUE_WINS
		},
		{
			self.LockedLevelBar,
			self.LockedLevelGoalText,
			self.LockedLevelCompleted,
			level,
			levelRequirement
		},
		{
			self.LockedAgeBar,
			self.LockedAgeGoalText,
			self.LockedAgeCompleted,
			accountAge,
			accountAgeRequirement
		},
		{
			self.LockedTasksBar,
			self.LockedTasksGoalText,
			self.LockedTasksCompleted,
			statistic2,
			tasksCompletedRequirement
		},
		{
			self.LockedTrustedBar,
			self.LockedTrustedGoalText,
			self.LockedTrustedCompleted,
			v,
			bypassTrustworthySpendRequirement
		}
	}

	for _, list in pairs(v2) do
		local v3, v4, v5, v6, v7 = table.unpack(list)
		local v8 = math.clamp(v6 / v7, 0, 1)
		v3.Size = UDim2.new(v8, 0, 1, 2)
		v3.BackgroundColor3 = v8 >= 1 and Color3.fromRGB(100, 255, 50) or Color3.fromRGB(255, 255, 255)
		v4.Text = Utility:PrettyNumber(v6) .. " / " .. Utility:PrettyNumber(v7)
		v4.Visible = v8 < 1
		v5.Visible = v8 >= 1
	end

	self.UnlockedFrame.Visible = SeasonController:IsRankedUnlocked()
	self.LockedFrame.Visible = not self.UnlockedFrame.Visible
end

function Locked:_Setup()
	self.LockedWinsText.Text = "Win " .. CONSTANTS.BEGINNER_QUEUE_WINS .. " duels"
	self.LockedLevelText.Text = "Reach Level " .. SeasonLibrary.CurrentSeason.LevelRequirement
	self.LockedAgeText.Text = "Have a " .. SeasonLibrary.CurrentSeason.AccountAgeRequirement .. " day old Roblox account"
	self.LockedTasksText.Text = "Complete " .. SeasonLibrary.CurrentSeason.TasksCompletedRequirement .. " tasks"
	self.LockedTrustedText.Text = "Spend " .. utf8.char(57346) .. Utility:PrettyNumber(SeasonLibrary.CurrentSeason.BypassTrustworthySpendRequirement) .. " or verify your Roblox account's email, phone, ID, etc"
end

function Locked:_Init()
	self.LockedCloseButton.MouseButton1Click:Connect(function()
		self.Page:CloseRequest()
	end)
	self:_Setup()
	self:_Update()
	ButtonEffect:Add(self.LockedCloseButton)
end

return Locked