local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local SocialService = game:GetService("SocialService")
local Players = game:GetService("Players")
local ServerOsTime = require(ReplicatedStorage.Modules.ServerOsTime)
local Utility = require(ReplicatedStorage.Modules.Utility)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
local LobbyElement = require(Players.LocalPlayer.PlayerScripts.Modules.LobbyElement)
local object = setmetatable({}, LobbyElement)
object.__index = object

function object._new(...)
	local self = setmetatable(LobbyElement.new(...), object)
	self._models = {}
	self._countdown_hash = 0
	self._next_event_details = nil
	self:_Init()
	return self
end

function object:Update(_)
	if not self._next_event_details then
		return
	end

	for _, _model in pairs(self._models) do
		local vector2 = Vector3.new(
			workspace.CurrentCamera.CFrame.X,
			_model.CountdownCFrame.Y + (workspace.CurrentCamera.CFrame.Y - _model.CountdownCFrame.Y) / 2,
			workspace.CurrentCamera.CFrame.Z
		)
		_model.CountdownPart.CFrame = CFrame.new(_model.CountdownCFrame.Position, vector2) * CFrame.Angles(
			0.2617993877991494,
			0,
			0
		)
	end
end

function object:_GetDateTime(data)
	return DateTime.fromUniversalTime(
		data.Year,
		data.Month,
		data.Day,
		data.Hour,
		data.Minute,
		data.Second,
		data.Millisecond
	)
end

function object:_UpdateCountdown()
	for k, _model in pairs(self._models) do
		_model.CountdownModel.Parent = nil
		_model.LogoModel.Parent = k
	end

	self._next_event = nil
	self._countdown_hash += 1
	local _countdown_hash = self._countdown_hash

	if PlayerDataController:GetStatistic("StatisticDuelsPlayed") < 10 then
		return
	end

	local success, upcomingExperienceEventsAsync = pcall(SocialService.GetUpcomingExperienceEventsAsync, SocialService)

	if not success then
		warn("Failed to fetch upcoming events, error:", upcomingExperienceEventsAsync)
		return
	end

	if self._countdown_hash ~= _countdown_hash then
		return
	end

	table.sort(upcomingExperienceEventsAsync, function(a, b)
		local _GetDateTime = self:_GetDateTime(a.StartTime)
		local _GetDateTime2 = self:_GetDateTime(b.StartTime)
		return _GetDateTime.UnixTimestamp < _GetDateTime2.UnixTimestamp
	end)
	local v = nil

	for _, v3 in pairs(upcomingExperienceEventsAsync) do
		if v3.HasStarted or v3.HasEnded or v3.Status ~= Enum.ExperienceEventStatus.Active then
			continue
		end

		v = v3
		break
	end

	if not v then
		return
	end

	local success2, experienceEventAsync = pcall(SocialService.GetExperienceEventAsync, SocialService, v.Id)

	if not success2 then
		warn("Failed to fetch event details, error:", upcomingExperienceEventsAsync)
		return
	end

	if self._countdown_hash ~= _countdown_hash then
		return
	end

	self._next_event_details = experienceEventAsync

	for k, _model in pairs(self._models) do
		_model.CountdownModel.Parent = k
		_model.LogoModel.Parent = nil
		_model.CountdownTitle.Text = string.upper(self._next_event_details.Title)
	end

	local _GetDateTime = self:_GetDateTime(self._next_event_details.StartTime)

	repeat
		local v3 = math.ceil(_GetDateTime.UnixTimestamp - ServerOsTime:Get())

		for _, _model in pairs(self._models) do
			_model.CountdownText.Text = v3 <= 0 and "ANY SECOND NOW" or Utility:TimeFormat2(v3)
		end

		wait(1)
	until self._countdown_hash ~= _countdown_hash
end

function object:_ModelAdded(instance)
	instance:WaitForChild("Countdown"):PivotTo(instance:WaitForChild("Countdown"):GetPivot() + createVector(0, 100, 0))
	local v = {
		CountdownModel = instance:WaitForChild("Countdown"),
		CountdownPart = instance:WaitForChild("Countdown"):WaitForChild("Part"),
		CountdownCFrame = instance:WaitForChild("Countdown"):WaitForChild("Part").CFrame,
		CountdownTitle = instance:WaitForChild("Countdown"):WaitForChild("Part"):WaitForChild("SurfaceGui"):WaitForChild("Title"),
		CountdownText = instance:WaitForChild("Countdown"):WaitForChild("Part"):WaitForChild("SurfaceGui"):WaitForChild("Countdown"),
		LogoModel = instance:WaitForChild("Logo")
	}
	self._models[instance] = v
	instance:WaitForChild("Countdown"):WaitForChild("Prompt"):WaitForChild("ProximityPrompt").Triggered:Connect(function()
		if self._next_event_details then
			local success, result = pcall(
				SocialService.PromptRsvpToEventAsync,
				SocialService,
				self._next_event_details.Id
			)

			if not success then
				warn("Failed to prompt event RSVP, error:", result)
			end
		end
	end)
	self:_UpdateCountdown()
end

function object:_Init()
	PlayerDataController:GetDataChangedSignal("StatisticDuelsPlayed"):Connect(function()
		self:_UpdateCountdown()
	end)
	CollectionService:GetInstanceAddedSignal("LobbyUpdateCountdown"):Connect(function(p)
		self:_ModelAdded(p)
	end)

	for _, v in pairs(CollectionService:GetTagged("LobbyUpdateCountdown")) do
		task.defer(self._ModelAdded, self, v)
	end
end

return object._new()