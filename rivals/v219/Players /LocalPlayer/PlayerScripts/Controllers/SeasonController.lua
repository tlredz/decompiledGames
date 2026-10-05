local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local SeasonLibrary = require(ReplicatedStorage.Modules.SeasonLibrary)
local Utility = require(ReplicatedStorage.Modules.Utility)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self._last_update = -1
	self._time_remaining = nil
	self:_Init()
	return self
end

function class:GetTimeRemaining()
	if self._time_remaining then
		return (math.max(0, (math.ceil(self._time_remaining - (tick() - self._last_update)))))
	end

	return nil
end

function class:GetCountdownText()
	local timeRemaining = self:GetTimeRemaining()

	if not timeRemaining then
		return nil
	end

	local v = timeRemaining <= 0 and "" or "in "
	local v2 = timeRemaining <= 0 and "ANY SECOND NOW" or Utility:TimeFormat2((math.ceil(timeRemaining)))
	return string.format(
		"Season %s ends %s<font color=\"rgb(255,50,50)\" weight=\"700\">%s</font>",
		SeasonLibrary.CurrentSeason.Version,
		v,
		v2
	)
end

function class.IsRankedUnlocked(_)
	local statistic = PlayerDataController:GetStatistic("StatisticDuelsWon")
	local level = PlayerDataController:Get("Level")
	local accountAge = Players.LocalPlayer.AccountAge
	local statistic2 = PlayerDataController:GetStatistic("StatisticTasksCompleted")
	return CONSTANTS.BEGINNER_QUEUE_WINS <= statistic and SeasonLibrary.CurrentSeason.LevelRequirement <= level and SeasonLibrary.CurrentSeason.AccountAgeRequirement <= accountAge and SeasonLibrary.CurrentSeason.TasksCompletedRequirement <= statistic2
end

function class:_UpdateTimer(time_remaining)
	self._last_update = tick()
	self._time_remaining = time_remaining
end

function class:_Fetch()
	self:_UpdateTimer(ReplicatedStorage.Remotes.Misc.RequestSeasonTimer:InvokeServer())
end

function class:_Init()
	ReplicatedStorage.Remotes.Misc.UpdateSeasonTimer.OnClientEvent:Connect(function(p)
		self:_UpdateTimer(p)
	end)
	task.defer(self._Fetch, self)
end

return class._new()