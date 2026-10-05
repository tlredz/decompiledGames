local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ServerOsTime = require(ReplicatedStorage.Modules.ServerOsTime)
local ClientMap = require(Players.LocalPlayer.PlayerScripts.Modules.ClientReplicatedClasses.ClientDuel.ClientMap)
local filmGrain = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("FilmGrain")
local object = setmetatable({}, ClientMap)
object.__index = object

function object.new(...)
	local self = setmetatable(ClientMap.new(...), object)
	self._film_grain = filmGrain:Clone()
	self._film_grain_loop_active = false
	self._last_hour = self:_GetBellRingHour()
	self._arcade_status = nil
	self:_Init()
	return self
end

function object:Destroy()
	self._film_grain:Destroy()
	ClientMap.Destroy(self)
end

function object:_GetBellRingHour()
	return (math.floor(ServerOsTime:Get() / 60 / 60))
end

function object:_UpdateFilmGrainLoop()
	if self._film_grain_loop_active or self:Get("IsHidden") then
		return
	end

	self._film_grain_loop_active = true

	while not (self._destroyed or self:Get("IsHidden")) do
		self._film_grain.Position = UDim2.new(math.random(), 0, math.random(), 0)
		local _GetBellRingHour = self:_GetBellRingHour()

		if self._last_hour ~= _GetBellRingHour then
			self._last_hour = _GetBellRingHour
			self:CreateSound("rbxassetid://125988297033633", 1, 1, script, true, 15)
		end

		wait(0.06666666666666667)
	end

	self._film_grain_loop_active = false
end

function object:_UpdateLightingProfile()
	local _arcade_status

	if self.ClientDuel:Get("ArcadeMode") then
		_arcade_status = self._arcade_status
	else
		_arcade_status = self.ClientDuel:Get("LastRoundStartingStatus")
	end

	self:SetReplicate(
		"LightingProfileOverride",
		_arcade_status == "SuddenDeath" and "Graveyard - SuddenDeath" or _arcade_status == "MatchPoint" and "Graveyard - MatchPoint" or "Graveyard"
	)

	if _arcade_status == "SuddenDeath" and self.ClientDuel:Get("IsSpectating") then
		self:CreateSound("rbxassetid://115990126225378", 1, 1, script, true, 15)
	end

	if _arcade_status == "MatchPoint" then
		local _film_grain = self._film_grain
		local parent

		if "MatchPoint" == "MatchPoint" then
			parent = self.ClientDuel.DuelInterface.Frame or nil
		end

		_film_grain.Parent = parent
	end
end

function object:_UpdateLightingProfileFromTimer()
	local timeRemaining = self.ClientDuel.DuelInterface.Timer:GetTimeRemaining()
	local arcade_status

	if timeRemaining and (self.ClientDuel:Get("Status") == "RoundStarted" or self.ClientDuel:Get("Status") == "RoundFinished") then
		arcade_status = timeRemaining < 10 and "SuddenDeath" or timeRemaining < 30 and "MatchPoint" or nil
	end

	if arcade_status == self._arcade_status then
		return
	end

	self._arcade_status = arcade_status
	self:_UpdateLightingProfile()
end

function object:_Setup()
	if self.ClientDuel:Get("ArcadeMode") then
		self.ClientDuel.DuelInterface.Timer.TimerChanged:Connect(function()
			self:_UpdateLightingProfileFromTimer()
		end)
		self:_UpdateLightingProfileFromTimer()
	else
		self.ClientDuel:GetDataChangedSignal("LastRoundStartingStatus"):Connect(function()
			self:_UpdateLightingProfile()
		end)
		self:_UpdateLightingProfile()
	end
end

function object:_Init()
	self.ClientDuel:GetDataChangedSignal("IsHidden"):Connect(function()
		self:_UpdateFilmGrainLoop()
	end)
	self:_Setup()
	task.defer(self._UpdateFilmGrainLoop, self)
end

return object