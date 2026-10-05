local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local playerGui

if RunService:IsClient() then
	playerGui = Players.LocalPlayer.PlayerGui
else
	playerGui = nil
end

local adminAbuse = ReplicatedStorage:WaitForChild("AdminAbuse")
local SharedSyncedEvent = require(adminAbuse:WaitForChild("SharedSyncedEvent"))
local Numbers = require(ReplicatedStorage.Utilities.Numbers)
local WCFinaleScoreBarClient = {}
WCFinaleScoreBarClient.__index = WCFinaleScoreBarClient

function WCFinaleScoreBarClient:new()
	assert(type(self) == "table", "WCFinaleScoreBarClient.new: opts required")
	assert(type(self.sseChannelName) == "string", "opts.sseChannelName required")
	self.durationSec = self.durationSec or 0
	self.screenGuiName = self.screenGuiName or self.sseChannelName .. "ScoreHUD"
	self.screenGuiDisplayOrder = self.screenGuiDisplayOrder or 80
	local object = setmetatable({}, WCFinaleScoreBarClient)
	object._opts = self
	object._sse = nil
	object._screen = nil
	object._winsLabel = nil
	object._winsScale = nil
	object._timerLabel = nil
	object._startUnix = nil
	object._timerThread = nil
	object._totalWins = 0
	object._displayedWins = 0
	object._countThread = nil
	object._punchTween = nil
	object._winsRemoteConn = nil
	return object
end

function WCFinaleScoreBarClient:_buildUi()
	if not playerGui then
		warn("WCFinaleScoreBarClient: PlayerGui not found; cannot build UI.")
		return
	end

	if self._screen then
		self._screen:Destroy()
	end

	self._winsLabel = nil
	self._winsScale = nil
	self._timerLabel = nil
	local _opts = self._opts
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = _opts.screenGuiName
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.DisplayOrder = _opts.screenGuiDisplayOrder
	screenGui.Parent = playerGui
	self._screen = screenGui
	local frame = Instance.new("Frame")
	frame.AnchorPoint = Vector2.new(0.5, 0)
	frame.BackgroundTransparency = 1
	frame.Position = UDim2.fromScale(0.5, 0.095)
	frame.Size = UDim2.fromScale(0.24, 0.1)
	frame.Parent = screenGui
	local textLabel = Instance.new("TextLabel")
	textLabel.BackgroundTransparency = 1
	textLabel.AnchorPoint = Vector2.new(0.5, 0)
	textLabel.Position = UDim2.fromScale(0.5, 0)
	textLabel.Size = UDim2.fromScale(1, 0.6)
	textLabel.Font = Enum.Font.GothamBlack
	textLabel.Text = "0 WINS"
	textLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
	textLabel.TextScaled = true
	textLabel.TextXAlignment = Enum.TextXAlignment.Center
	textLabel.TextStrokeTransparency = 0.4
	textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
	textLabel.Parent = frame
	local uIScale = Instance.new("UIScale")
	uIScale.Scale = 1
	uIScale.Parent = textLabel
	self._winsLabel = textLabel
	self._winsScale = uIScale
	local textLabel2 = Instance.new("TextLabel")
	textLabel2.Name = "Timer"
	textLabel2.BackgroundTransparency = 1
	textLabel2.AnchorPoint = Vector2.new(0.5, 0)
	textLabel2.Position = UDim2.fromScale(0.5, 0.66)
	textLabel2.Size = UDim2.fromScale(1, 0.3)
	textLabel2.Font = Enum.Font.GothamBold
	textLabel2.Text = "00:00"
	textLabel2.TextColor3 = Color3.new(1, 1, 1)
	textLabel2.TextScaled = true
	textLabel2.TextXAlignment = Enum.TextXAlignment.Center
	textLabel2.TextStrokeTransparency = 0.4
	textLabel2.TextStrokeColor3 = Color3.new(0, 0, 0)
	textLabel2.Parent = frame
	self._timerLabel = textLabel2
end

function WCFinaleScoreBarClient:_playPunch()
	local _winsLabel = self._winsLabel
	local _winsScale = self._winsScale

	if not (_winsLabel and _winsScale) then
		return
	end

	if self._punchTween then
		self._punchTween.up:Cancel()
		self._punchTween.down:Cancel()
	end

	_winsScale.Scale = 1
	local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	local tweenInfo2 = TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.In)
	local tween = TweenService:Create(_winsScale, tweenInfo, {
		Scale = 1.25
	})
	local tween2 = TweenService:Create(_winsScale, tweenInfo2, {
		Scale = 1
	})
	self._punchTween = {
		up = tween,
		down = tween2
	}
	tween.Completed:Connect(function()
		tween2:Play()
	end)
	tween:Play()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function _countUpDuration(p: number)
	if p <= 0 then
		return 0
	end

	return (math.clamp(p * 0.03, 0.15, 0.8))
end

function WCFinaleScoreBarClient:_animateWinsTo(p: number)
	if self._countThread then
		task.cancel(self._countThread)
		self._countThread = nil
	end

	local _winsLabel = self._winsLabel

	if not _winsLabel then
		return
	end

	local _displayedWins = self._displayedWins

	if _displayedWins == p then
		_winsLabel.Text = Numbers.formatNumber(p) .. " WINS"
		return
	end

	local v2 = _countUpDuration(math.abs(p - _displayedWins)) -- equivalent call inferred; original call site unknown
	self._countThread = task.spawn(function()
		local lastTime = os.clock()

		while true do
			local v3 = not (v2 > 0) and 1 or math.clamp((os.clock() - lastTime) / v2, 0, 1)
			local v4 = 1 - (1 - v3) ^ 3
			local displayedWins = math.floor(_displayedWins + (p - _displayedWins) * v4 + 0.5)
			self._displayedWins = displayedWins
			_winsLabel.Text = Numbers.formatNumber(displayedWins) .. " WINS"

			if v3 >= 1 then
				break
			end

			task.wait()
		end

		self._countThread = nil
	end)
end

function WCFinaleScoreBarClient:_onTotalWins(totalWins)
	if type(totalWins) ~= "number" then
		return
	end

	self._totalWins = totalWins

	if self._winsLabel then
		self:_animateWinsTo(totalWins)
		self:_playPunch()
	end
end

function WCFinaleScoreBarClient:_refreshTimer()
	local _timerLabel = self._timerLabel

	if not (_timerLabel and self._startUnix) then
		return
	end

	local v = math.max(0, self._opts.durationSec - (os.time() - self._startUnix))
	local v2 = math.floor(v / 60)
	local v3 = math.floor(v % 60)
	_timerLabel.Text = string.format("%02d:%02d", v2, v3)
end

function WCFinaleScoreBarClient:_onStartUnix(startUnix)
	if type(startUnix) ~= "number" then
		return
	end

	self._startUnix = startUnix
	self:_refreshTimer()

	if self._timerThread then
		task.cancel(self._timerThread)
		self._timerThread = nil
	end

	self._timerThread = task.spawn(function()
		while true do
			task.wait(1)
			self:_refreshTimer()
		end
	end)
end

function WCFinaleScoreBarClient:bindWinsRemote(p)
	if self._winsRemoteConn then
		self._winsRemoteConn:Disconnect()
		self._winsRemoteConn = nil
	end

	self._winsRemoteConn = p.OnClientEvent:Connect(function(p2)
		self:_onTotalWins(p2)
	end)
end

function WCFinaleScoreBarClient:fire()
	if self._sse then
		self._sse:destroy()
		self._sse = nil
	end

	self:_buildUi()

	if self._countThread then
		task.cancel(self._countThread)
		self._countThread = nil
	end

	self._totalWins = 0
	self._displayedWins = 0
	local _opts = self._opts
	local sse = SharedSyncedEvent.new(_opts.sseChannelName)
	self._sse = sse
	sse:onChange("StartUnix", function(p)
		self:_onStartUnix(p)
	end)
	sse:onFire("Fx", function(p)
		if type(p) ~= "table" then
			return
		end

		if _opts.onFx then
			_opts.onFx(p.cmd, p)
		end
	end)
end

function WCFinaleScoreBarClient:stop()
	if self._sse then
		self._sse:destroy()
		self._sse = nil
	end

	if self._winsRemoteConn then
		self._winsRemoteConn:Disconnect()
		self._winsRemoteConn = nil
	end

	if self._timerThread then
		task.cancel(self._timerThread)
		self._timerThread = nil
	end

	if self._countThread then
		task.cancel(self._countThread)
		self._countThread = nil
	end

	if self._punchTween then
		self._punchTween.up:Cancel()
		self._punchTween.down:Cancel()
		self._punchTween = nil
	end

	if self._screen then
		self._screen:Destroy()
		self._screen = nil
	end

	self._winsLabel = nil
	self._winsScale = nil
	self._timerLabel = nil
	self._startUnix = nil
	self._totalWins = 0
	self._displayedWins = 0
end

return WCFinaleScoreBarClient