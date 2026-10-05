local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local localPlayer, playerGui

if RunService:IsClient() then
	localPlayer = Players.LocalPlayer
	playerGui = localPlayer.PlayerGui
else
	playerGui = nil
	localPlayer = nil
end

local adminAbuse = ReplicatedStorage:WaitForChild("AdminAbuse")
local SharedSyncedEvent = require(adminAbuse:WaitForChild("SharedSyncedEvent"))
local KeycapScoreBarClient = {}
KeycapScoreBarClient.__index = KeycapScoreBarClient

function KeycapScoreBarClient:new()
	assert(type(self) == "table", "KeycapScoreBarClient.new: opts required")
	assert(type(self.sseChannelName) == "string", "opts.sseChannelName required")
	assert(type(self.keycapTag) == "string", "opts.keycapTag required")
	assert(type(self.keycapColoredTag) == "string", "opts.keycapColoredTag required")
	self.bossIcon = self.bossIcon or ""
	self.durationSec = self.durationSec or 0
	self.screenGuiName = self.screenGuiName or self.sseChannelName .. "ScoreHUD"
	self.screenGuiDisplayOrder = self.screenGuiDisplayOrder or 80
	self.playerAccentColor = self.playerAccentColor or Color3.fromRGB(80, 180, 255)
	self.bossAccentColor = self.bossAccentColor or Color3.fromRGB(230, 60, 60)
	self.pctUpdateStep = self.pctUpdateStep or 2
	local object = setmetatable({}, KeycapScoreBarClient)
	object._opts = self
	object._sse = nil
	object._screen = nil
	object._playerPctLabel = nil
	object._bossPctLabel = nil
	object._playerIcon = nil
	object._timerLabel = nil
	object._startUnix = nil
	object._timerThread = nil
	object._tagConns = {}
	object._totalCount = 0
	object._coloredCount = 0
	object._lastShownPlayerPct = -1
	object._playerPctScale = nil
	object._bossPctScale = nil
	object._punchTweens = {}
	return object
end

local function _buildSide(frame, p, color)
	local frame2 = Instance.new("Frame")
	frame2.BackgroundTransparency = 1
	frame2.AnchorPoint = Vector2.new(p and 1 or 0, 0.5)
	frame2.Position = UDim2.fromScale(p and 0.48 or 0.02, 0.5)
	frame2.Size = UDim2.fromScale(0.46, 0.5)
	frame2.Parent = frame
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.AnchorPoint = Vector2.new(p and 1 or 0, 0.5)
	imageLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	imageLabel.BorderSizePixel = 0
	imageLabel.Position = UDim2.fromScale(p and 1 or 0, 0.5)
	imageLabel.Size = UDim2.fromScale(0.32, 1)
	imageLabel.Parent = frame2
	local uICorner = Instance.new("UICorner", imageLabel)
	uICorner.CornerRadius = UDim.new(1, 0)
	local uIStroke = Instance.new("UIStroke", imageLabel)
	uIStroke.Color = color
	uIStroke.Thickness = 2
	local textLabel = Instance.new("TextLabel")
	textLabel.BackgroundTransparency = 1
	textLabel.AnchorPoint = Vector2.new(p and 1 or 0, 0.5)
	textLabel.Position = UDim2.fromScale(p and 0.64 or 0.36, 0.5)
	textLabel.Size = UDim2.fromScale(0.48, 0.6)
	textLabel.Font = Enum.Font.GothamBlack
	textLabel.Text = "0%"
	textLabel.TextColor3 = Color3.new(1, 1, 1)
	textLabel.TextScaled = true
	local textXAlignment

	if p then
		textXAlignment = Enum.TextXAlignment.Right
	else
		textXAlignment = Enum.TextXAlignment.Left
	end

	textLabel.TextXAlignment = textXAlignment
	textLabel.TextStrokeTransparency = 0.4
	textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
	textLabel.Parent = frame2
	local uIScale = Instance.new("UIScale")
	uIScale.Scale = 1
	uIScale.Parent = textLabel
	return frame2, imageLabel, textLabel, uIScale
end

function KeycapScoreBarClient:_buildUi()
	if not playerGui then
		warn("KeycapScoreBarClient: PlayerGui not found; cannot build UI.")
		return
	end

	if self._screen then
		self._screen:Destroy()
	end

	self._playerPctLabel = nil
	self._bossPctLabel = nil
	self._playerIcon = nil
	self._timerLabel = nil
	self._playerPctScale = nil
	self._bossPctScale = nil
	table.clear(self._punchTweens)
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
	frame.Position = UDim2.fromScale(0.5, 0.04)
	frame.Size = UDim2.fromScale(0.95, 0.1)
	frame.Parent = screenGui
	local frame2 = Instance.new("Frame")
	frame2.Name = "Divider"
	frame2.AnchorPoint = Vector2.new(0.5, 0.5)
	frame2.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
	frame2.BorderSizePixel = 0
	frame2.Position = UDim2.fromScale(0.5, 0.58)
	frame2.Size = UDim2.fromScale(0.005, 0.63)
	frame2.Parent = frame
	local uIStroke = Instance.new("UIStroke", frame2)
	uIStroke.Color = Color3.new(0, 0, 0)
	uIStroke.Thickness = 1
	local _, playerIcon, playerPctLabel, playerPctScale = _buildSide(frame, false, _opts.playerAccentColor)
	self._playerIcon = playerIcon
	self._playerPctLabel = playerPctLabel
	self._playerPctScale = playerPctScale
	local _, v4, bossPctLabel, bossPctScale = _buildSide(frame, true, _opts.bossAccentColor)
	v4.Image = _opts.bossIcon
	self._bossPctLabel = bossPctLabel
	self._bossPctScale = bossPctScale
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "Timer"
	textLabel.AnchorPoint = Vector2.new(0.5, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.Position = UDim2.fromScale(0.5, 0.82)
	textLabel.Size = UDim2.fromScale(0.25, 0.2)
	textLabel.Font = Enum.Font.GothamBold
	textLabel.Text = "00:00"
	textLabel.TextColor3 = Color3.new(1, 1, 1)
	textLabel.TextScaled = true
	textLabel.TextStrokeTransparency = 0.4
	textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
	textLabel.Parent = frame
	self._timerLabel = textLabel
	task.spawn(function()
		local success, result = pcall(function()
			return Players:GetUserThumbnailAsync(
				localPlayer.UserId,
				Enum.ThumbnailType.HeadShot,
				Enum.ThumbnailSize.Size150x150
			)
		end)

		if success and result and self._playerIcon then
			self._playerIcon.Image = result
		end
	end)
end

function KeycapScoreBarClient:_playPunch(p2, p3, textColor, rotation)
	if not (p2 and p3) then
		return
	end

	local _punchTween = self._punchTweens[p2]

	if _punchTween then
		_punchTween.up:Cancel()
		_punchTween.down:Cancel()
		_punchTween.rotUp:Cancel()
		_punchTween.rotDown:Cancel()
		_punchTween.color:Cancel()
	end

	p3.Scale = 1
	p2.Rotation = 0
	p2.TextColor3 = textColor
	local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	local tweenInfo2 = TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.In)
	local tween = TweenService:Create(p3, tweenInfo, {
		Scale = 1.35
	})
	local tween2 = TweenService:Create(p3, tweenInfo2, {
		Scale = 1
	})
	local tween3 = TweenService:Create(p2, tweenInfo, {
		Rotation = rotation
	})
	local tween4 = TweenService:Create(p2, tweenInfo2, {
		Rotation = 0
	})
	local tween5 = TweenService:Create(p2, TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		TextColor3 = Color3.new(1, 1, 1)
	})
	self._punchTweens[p2] = {
		up = tween,
		down = tween2,
		rotUp = tween3,
		rotDown = tween4,
		color = tween5
	}
	tween.Completed:Connect(function()
		tween2:Play()
	end)
	tween3.Completed:Connect(function()
		tween4:Play()
	end)
	tween:Play()
	tween3:Play()
	tween5:Play()
end

function KeycapScoreBarClient:_recountAll()
	local _opts = self._opts
	self._totalCount = #CollectionService:GetTagged(_opts.keycapTag)
	self._coloredCount = #CollectionService:GetTagged(_opts.keycapColoredTag)
end

function KeycapScoreBarClient:_applyPctIfNeeded()
	local _opts = self._opts
	local _totalCount = self._totalCount
	local lastShownPlayerPct = not (_totalCount > 0) and 0 or self._coloredCount / _totalCount * 100
	local v2 = math.abs(lastShownPlayerPct - self._lastShownPlayerPct)
	local v3 = lastShownPlayerPct <= 0 or lastShownPlayerPct >= 100

	if v2 < _opts.pctUpdateStep and not v3 then
		return
	end

	self._lastShownPlayerPct = lastShownPlayerPct
	local v4 = 100 - lastShownPlayerPct

	if self._playerPctLabel then
		self._playerPctLabel.Text = string.format("%d%%", (math.floor(lastShownPlayerPct + 0.5)))
		self:_playPunch(self._playerPctLabel, self._playerPctScale, _opts.playerAccentColor, -8)
	end

	if self._bossPctLabel then
		self._bossPctLabel.Text = string.format("%d%%", (math.floor(v4 + 0.5)))
		self:_playPunch(self._bossPctLabel, self._bossPctScale, _opts.bossAccentColor, 8)
	end
end

function KeycapScoreBarClient:_refreshTimer()
	local _timerLabel = self._timerLabel

	if not (_timerLabel and self._startUnix) then
		return
	end

	local v = math.max(0, self._opts.durationSec - (os.time() - self._startUnix))
	local v2 = math.floor(v / 60)
	local v3 = math.floor(v % 60)
	_timerLabel.Text = string.format("%02d:%02d", v2, v3)
end

function KeycapScoreBarClient:_onStartUnix(startUnix)
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

function KeycapScoreBarClient:fire()
	if self._sse then
		self._sse:destroy()
		self._sse = nil
	end

	self:_buildUi()
	local _opts = self._opts
	self._lastShownPlayerPct = -1
	self:_recountAll()

	for _, _tagConn in self._tagConns do
		_tagConn:Disconnect()
	end

	table.clear(self._tagConns)
	table.insert(self._tagConns, CollectionService:GetInstanceAddedSignal(_opts.keycapTag):Connect(function()
		self._totalCount += 1
		self:_applyPctIfNeeded()
	end))
	table.insert(self._tagConns, CollectionService:GetInstanceRemovedSignal(_opts.keycapTag):Connect(function()
		self._totalCount = math.max(0, self._totalCount - 1)
		self:_applyPctIfNeeded()
	end))
	table.insert(self._tagConns, CollectionService:GetInstanceAddedSignal(_opts.keycapColoredTag):Connect(function()
		self._coloredCount += 1
		self:_applyPctIfNeeded()
	end))
	table.insert(self._tagConns, CollectionService:GetInstanceRemovedSignal(_opts.keycapColoredTag):Connect(function()
		self._coloredCount = math.max(0, self._coloredCount - 1)
		self:_applyPctIfNeeded()
	end))
	self:_applyPctIfNeeded()
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

function KeycapScoreBarClient:stop()
	if self._sse then
		self._sse:destroy()
		self._sse = nil
	end

	if self._timerThread then
		task.cancel(self._timerThread)
		self._timerThread = nil
	end

	for _, _tagConn in self._tagConns do
		_tagConn:Disconnect()
	end

	table.clear(self._tagConns)

	for _, _punchTween in self._punchTweens do
		_punchTween.up:Cancel()
		_punchTween.down:Cancel()
		_punchTween.rotUp:Cancel()
		_punchTween.rotDown:Cancel()
		_punchTween.color:Cancel()
	end

	table.clear(self._punchTweens)

	if self._screen then
		self._screen:Destroy()
		self._screen = nil
	end

	self._playerPctLabel = nil
	self._bossPctLabel = nil
	self._playerIcon = nil
	self._timerLabel = nil
	self._playerPctScale = nil
	self._bossPctScale = nil
	self._startUnix = nil
	self._totalCount = 0
	self._coloredCount = 0
	self._lastShownPlayerPct = -1
end

return KeycapScoreBarClient