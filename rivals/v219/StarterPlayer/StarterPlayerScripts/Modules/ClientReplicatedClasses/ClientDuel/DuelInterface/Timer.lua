local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Utility = require(ReplicatedStorage.Modules.Utility)
local Signal = require(ReplicatedStorage.Modules.Signal)
local Timer = {}
Timer.__index = Timer

function Timer.new(duelInterface)
	local self = setmetatable({}, Timer)
	self.TimerChanged = Signal.new()
	self.DuelInterface = duelInterface
	self.Frame = self.DuelInterface.Frame:WaitForChild("Top"):WaitForChild("Timer")
	self.InfiniteIcon = self.Frame:WaitForChild("Infinite")
	self.StopwatchText = self.Frame:WaitForChild("Stopwatch")
	self.NumbersFrame = self.Frame:WaitForChild("Numbers")
	self.NumbersFullFrame = self.NumbersFrame:WaitForChild("Full")
	self.NumbersFullText = self.NumbersFullFrame:WaitForChild("Value")
	self.NumbersSecondsOnesFrame = self.NumbersFrame:WaitForChild("SecondsOnes")
	self.NumbersSecondsOnesText = self.NumbersSecondsOnesFrame:WaitForChild("Value")
	self.NumbersSecondsTensFrame = self.NumbersFrame:WaitForChild("SecondsTens")
	self.NumbersSecondsTensText = self.NumbersSecondsTensFrame:WaitForChild("Value")
	self.NumbersMinutesOnesFrame = self.NumbersFrame:WaitForChild("MinutesOnes")
	self.NumbersMinutesOnesText = self.NumbersMinutesOnesFrame:WaitForChild("Value")
	self.NumbersColonFrame = self.NumbersFrame:WaitForChild("Colon")
	self.NumbersColonText = self.NumbersColonFrame:WaitForChild("Value")
	self.NumbersIconFrame = self.NumbersFrame:WaitForChild("Icon")
	self.NumbersIconIcon = self.NumbersIconFrame:WaitForChild("Icon")
	self._destroyed = false
	self._is_visible = true
	self._time_remaining = 0
	self._countdown_hash = 0
	self._last4sec_sound = nil
	self._last10sec_sound = nil
	self._stopwatch_start = nil
	self._stopwatch_finish = nil
	self._stopwatch_connection = nil
	self:_Init()
	return self
end

function Timer:GetTimeRemaining()
	return self._time_remaining
end

function Timer:SetVisible(is_visible)
	self._is_visible = is_visible
	self:Update()
end

function Timer:Set(p)
	self.NumbersFrame.Visible = p ~= nil
	self.InfiniteIcon.Visible = p == nil
	self._countdown_hash += 1

	if not p then
		self:_ClearSounds()
		return
	end

	local _countdown_hash = self._countdown_hash
	local lastTime = tick()

	while _countdown_hash == self._countdown_hash and tick() - lastTime < p do
		self:_SetText(p - (tick() - lastTime))
		RunService.RenderStepped:Wait()
	end

	if _countdown_hash ~= self._countdown_hash then
		return
	end

	self:_SetText(0)
end

function Timer:Pause(p)
	self._countdown_hash += 1

	if p then
		self:_SetText(p)
	end

	self:_ClearSounds()
end

function Timer:UpdateSizeAndPosition()
	local v

	if self.DuelInterface.ClientDuel:Get("ScoresBehavior") == "Duelers" then
		v = not self.DuelInterface.ClientDuel:Get("VoteOptions")
	else
		v = false
	end

	local uDim = v and UDim2.new(0.5, 0, 0.03, 7.5) or UDim2.new(0.5, 0, 0.04, 10)
	local uDim2 = v and UDim2.new(0.075, 30, 0.0375, 15) or UDim2.new(0.1, 40, 0.05, 20)

	if self.Frame:IsDescendantOf(Players) then
		self.Frame:TweenSizeAndPosition(uDim2, uDim, "Out", "Quint", 0.25, true)
		return
	end

	self.Frame.Size = uDim2
	self.Frame.Position = uDim
end

function Timer:StopwatchStart()
	self:StopwatchFinish()
	self.InfiniteIcon.Position = UDim2.new(0.5, 0, 0.4, 0)
	self.NumbersFrame.Position = UDim2.new(0.5, 0, 0.4, 0)
	self._stopwatch_start = tick()
	self._stopwatch_finish = nil
	self._stopwatch_connection = RunService.RenderStepped:Connect(function()
		self.StopwatchText.Text = string.format("%.3f", tick() - self._stopwatch_start)
	end)
end

function Timer:StopwatchFinish(stopwatch_finish)
	self._stopwatch_start = nil
	self._stopwatch_finish = stopwatch_finish

	if self._stopwatch_connection then
		self._stopwatch_connection:Disconnect()
		self._stopwatch_connection = nil
	end

	self.StopwatchText.Text = self._stopwatch_finish and string.format("%.3f", self._stopwatch_finish) or ""
end

function Timer:ClearStopwatch()
	self:StopwatchFinish()
	self.InfiniteIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
	self.NumbersFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
end

function Timer:Update()
	self.Frame.Visible = self._is_visible and not (self.DuelInterface:IsPageOpen() or self.DuelInterface.ClientDuel:Get("HideMostDuelInterfaceElements"))
end

function Timer:Destroy()
	self._destroyed = true
	self._countdown_hash += 1
	self.TimerChanged:Destroy()
	self:ClearStopwatch()
	self:_ClearSounds()
end

function Timer:_UpdateLayouts()
	self.NumbersFullFrame.Size = UDim2.new(0.1, self.NumbersFullText.TextBounds.X, 0.6, 0)
end

function Timer:_ClearSounds()
	if self._last4sec_sound then
		self._last4sec_sound:Destroy()
		self._last4sec_sound = nil
	end

	if self._last10sec_sound then
		self._last10sec_sound:Destroy()
		self._last10sec_sound = nil
	end
end

function Timer:_SetText(p)
	self._time_remaining = math.max(0, p)
	self.TimerChanged:Fire(self._time_remaining)
	local _time_remaining = math.ceil(self._time_remaining)
	local color = self._time_remaining <= 0.05 and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(255, 255, 255)
	local v = self._time_remaining < 10
	local timeFormat = Utility:TimeFormat(_time_remaining)
	self.NumbersFullFrame.Visible = false
	self.NumbersSecondsOnesFrame.Visible = not v
	self.NumbersSecondsTensFrame.Visible = true
	self.NumbersMinutesOnesFrame.Visible = true
	self.NumbersColonFrame.Visible = true
	local numbersFullText = self.NumbersFullText

	if v then
		timeFormat = string.format("%.1f", (math.abs(self._time_remaining)))
	end

	numbersFullText.Text = timeFormat
	self.NumbersSecondsOnesText.Text = _time_remaining % 10
	local numbersSecondsTensText = self.NumbersSecondsTensText
	local text

	if v then
		text = math.floor(self._time_remaining % 1 * 10)
	else
		text = math.floor(_time_remaining % 60 / 10)
	end

	numbersSecondsTensText.Text = text
	local numbersMinutesOnesText = self.NumbersMinutesOnesText
	local text2

	if v then
		text2 = math.floor(self._time_remaining % 10)
	else
		text2 = math.floor(_time_remaining / 60) % 10
	end

	numbersMinutesOnesText.Text = text2
	self.NumbersColonText.Text = v and "." or ":"
	self.NumbersFullText.TextColor3 = color
	self.NumbersSecondsOnesText.TextColor3 = color
	self.NumbersSecondsTensText.TextColor3 = color
	self.NumbersColonText.TextColor3 = color
	self.NumbersMinutesOnesText.TextColor3 = color
	self.NumbersIconIcon.ImageColor3 = color

	if self._time_remaining <= 4 then
		if not self._last4sec_sound and self.DuelInterface.ClientDuel:Get("Status") == "RoundStarted" then
			self._last4sec_sound = self.DuelInterface:CreateSound("rbxassetid://17826390328", 1.25, 1, script, true, 15)
		end
	elseif self._time_remaining <= 10 then
		if not self._last10sec_sound and self.DuelInterface.ClientDuel:Get("Status") == "RoundStarted" then
			self._last10sec_sound = self.DuelInterface:CreateSound("rbxassetid://17826470563", 0.5, 1, script, true, 15)
		end
	else
		self:_ClearSounds()
	end
end

function Timer:_Init()
	self.NumbersFullText:GetPropertyChangedSignal("TextBounds"):Connect(function()
		self:_UpdateLayouts()
	end)
	self:_UpdateLayouts()
	self:UpdateSizeAndPosition()
	self:ClearStopwatch()
	task.defer(self._SetText, self, 0)
end

return Timer