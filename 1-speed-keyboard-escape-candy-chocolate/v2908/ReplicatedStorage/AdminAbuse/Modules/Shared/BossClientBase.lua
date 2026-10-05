local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local playerGui

if RunService:IsClient() then
	playerGui = Players.LocalPlayer.PlayerGui
else
	playerGui = nil
end

local adminAbuse = ReplicatedStorage:WaitForChild("AdminAbuse")
local SharedSyncedEvent = require(adminAbuse:WaitForChild("SharedSyncedEvent"))
local BossClientBase = {}
BossClientBase.__index = BossClientBase

function BossClientBase:new()
	assert(type(self) == "table", "BossClientBase.new: opts required")
	assert(type(self.sseChannelName) == "string", "opts.sseChannelName required")
	assert(type(self.bossDisplayName) == "string", "opts.bossDisplayName required")
	self.bossIcon = self.bossIcon or ""
	self.barTweenDurationSec = self.barTweenDurationSec or 0.38
	self.phaseMarkerCount = self.phaseMarkerCount or 3
	self.screenGuiName = self.screenGuiName or self.sseChannelName .. "HUD"
	self.screenGuiDisplayOrder = self.screenGuiDisplayOrder or 80
	self.colorHpFill = self.colorHpFill or Color3.fromRGB(148, 8, 8)
	self.hideCutsceneUi = self.hideCutsceneUi or false
	local object = setmetatable({}, BossClientBase)
	object._opts = self
	object._sse = nil
	object._screen = nil
	object._barFill = nil
	object._hpLabel = nil
	object._phaseLabel = nil
	object._hpDriver = nil
	object._hpTween = nil
	object._bossMaxRef = 1
	object._lastRevisionSeen = 0
	object._firstSync = false
	object._phaseMarkerFrames = {}
	object._phaseMarkerTexts = {}
	object._endMarkerFrame = nil
	object._endMarkerText = nil
	object._savedUiStates = {}
	object._barGradient = nil
	object._barGradientConn = nil
	return object
end

function BossClientBase:_buildUi()
	if not playerGui then
		warn("BossClientBase: PlayerGui not found; cannot build UI.")
		return
	end

	if self._barGradientConn then
		self._barGradientConn:Disconnect()
		self._barGradientConn = nil
	end

	if self._barGradient then
		self._barGradient:Destroy()
		self._barGradient = nil
	end

	if self._screen then
		self._screen:Destroy()
	end

	self._barFill = nil
	self._hpLabel = nil
	self._phaseLabel = nil
	self._hpDriver = nil
	self._endMarkerFrame = nil
	self._endMarkerText = nil
	table.clear(self._phaseMarkerFrames)
	table.clear(self._phaseMarkerTexts)
	local _opts = self._opts
	local phaseMarkerCount = _opts.phaseMarkerCount
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
	frame.Position = UDim2.new(0.5, 0, 0, 45)
	frame.Size = UDim2.new(0.6, 0, 0.08, 0)
	frame.Parent = screenGui
	local frame2 = Instance.new("Frame")
	frame2.Name = "ProgressBg"
	frame2.AnchorPoint = Vector2.new(0.5, 0.5)
	frame2.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
	frame2.BackgroundTransparency = 0.4
	frame2.Position = UDim2.new(0.5, 0, 0.5, 0)
	frame2.Size = UDim2.new(1, 0, 0.65, 0)
	frame2.Parent = frame
	local uICorner = Instance.new("UICorner", frame2)
	uICorner.CornerRadius = UDim.new(0.5, 0)
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.AnchorPoint = Vector2.new(0, 0.5)
	imageLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	imageLabel.BorderSizePixel = 0
	imageLabel.Position = UDim2.new(0, -65, 0.5, 0)
	imageLabel.Size = UDim2.new(0, 60, 0, 60)
	imageLabel.Image = _opts.bossIcon
	imageLabel.Parent = frame2
	local uICorner_2 = Instance.new("UICorner", imageLabel)
	uICorner_2.CornerRadius = UDim.new(1, 0)
	local uIStroke = Instance.new("UIStroke", imageLabel)
	uIStroke.Color = _opts.colorHpFill
	uIStroke.Thickness = 2
	local frame3 = Instance.new("Frame", frame2)
	frame3.Name = "Fill"
	frame3.BackgroundColor3 = _opts.colorHpFill
	frame3.Size = UDim2.new(0, 0, 1, 0)
	frame3.BorderSizePixel = 0
	local uICorner_3 = Instance.new("UICorner", frame3)
	uICorner_3.CornerRadius = UDim.new(0.5, 0)
	self._barFill = frame3
	local phaseThresholds = _opts.phaseThresholds
	local v

	if type(phaseThresholds) == "table" then
		v = #phaseThresholds > 0
	else
		v = false
	end

	local v2 = {}

	if v then
		for _, phaseThreshold in ipairs(phaseThresholds) do
			table.insert(v2, phaseThreshold)
		end
	else
		for i = 1, phaseMarkerCount - 1 do
			table.insert(v2, i / phaseMarkerCount)
		end
	end

	for i, v3 in ipairs(v2) do
		local frame4 = Instance.new("Frame")
		frame4.Name = "Phase" .. tostring(i + 1) .. "Marker"
		frame4.AnchorPoint = Vector2.new(0.5, 0.5)
		frame4.Position = UDim2.new(v3, 0, 0.5, 0)
		frame4.Size = UDim2.new(0, 6, 1, 0)
		frame4.BorderSizePixel = 0
		frame4.ZIndex = frame3.ZIndex + 2
		frame4.Parent = frame2
		local uIStroke_2 = Instance.new("UIStroke", frame4)
		uIStroke_2.Thickness = 1
		local textLabel = Instance.new("TextLabel")
		textLabel.Name = "Phase" .. tostring(i + 1) .. "Text"
		textLabel.AnchorPoint = Vector2.new(0.5, 0)
		textLabel.BackgroundTransparency = 1
		textLabel.Position = UDim2.new(v3, 0, 0.5, 16)
		textLabel.Size = UDim2.new(0, 64, 0, 22)
		textLabel.ZIndex = frame3.ZIndex + 3
		textLabel.Font = Enum.Font.GothamBold
		textLabel.Text = "P" .. tostring(i + 1)
		textLabel.TextScaled = true
		textLabel.TextStrokeTransparency = 0.55
		textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
		textLabel.TextColor3 = Color3.fromRGB(190, 190, 200)
		textLabel.Parent = frame2
		table.insert(self._phaseMarkerFrames, frame4)
		table.insert(self._phaseMarkerTexts, textLabel)
	end

	local frame4 = Instance.new("Frame")
	frame4.Name = "EndMarker"
	frame4.AnchorPoint = Vector2.new(0.5, 0.5)
	frame4.Position = UDim2.new(1, 0, 0.5, 0)
	frame4.Size = UDim2.new(0, 6, 1, 0)
	frame4.BorderSizePixel = 0
	frame4.ZIndex = frame3.ZIndex + 2
	frame4.Parent = frame2
	local uIStroke_3 = Instance.new("UIStroke", frame4)
	uIStroke_3.Thickness = 1
	self._endMarkerFrame = frame4
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "EndText"
	textLabel.AnchorPoint = Vector2.new(0.5, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.Position = UDim2.new(1, 0, 0.5, 16)
	textLabel.Size = UDim2.new(0, 64, 0, 22)
	textLabel.ZIndex = frame3.ZIndex + 3
	textLabel.Font = Enum.Font.GothamBold
	textLabel.Text = "???"
	textLabel.TextScaled = true
	textLabel.TextStrokeTransparency = 0.55
	textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	textLabel.TextColor3 = Color3.fromRGB(190, 190, 200)
	textLabel.Parent = frame2
	self._endMarkerText = textLabel
	local textLabel2 = Instance.new("TextLabel", frame2)
	textLabel2.BackgroundTransparency = 1
	textLabel2.Size = UDim2.new(0.45, 0, 1, 0)
	textLabel2.Font = Enum.Font.GothamBold
	textLabel2.Text = _opts.bossDisplayName:upper() .. " BOSS EVENT"
	textLabel2.TextColor3 = Color3.new(1, 1, 1)
	textLabel2.TextScaled = true
	textLabel2.TextXAlignment = Enum.TextXAlignment.Left
	local uIPadding = Instance.new("UIPadding", textLabel2)
	uIPadding.PaddingLeft = UDim.new(0.04, 0)
	local textLabel3 = Instance.new("TextLabel", frame2)
	textLabel3.AnchorPoint = Vector2.new(1, 0)
	textLabel3.BackgroundTransparency = 1
	textLabel3.Position = UDim2.new(1, 0, 0, 0)
	textLabel3.Size = UDim2.new(0.4, 0, 1, 0)
	textLabel3.Font = Enum.Font.GothamBold
	textLabel3.Text = "0 / 0"
	textLabel3.TextColor3 = Color3.new(1, 1, 1)
	textLabel3.TextScaled = true
	textLabel3.TextXAlignment = Enum.TextXAlignment.Right
	local uIPadding_2 = Instance.new("UIPadding", textLabel3)
	uIPadding_2.PaddingRight = UDim.new(0.04, 0)
	self._hpLabel = textLabel3
	local numberValue = Instance.new("NumberValue")
	numberValue.Value = 0
	numberValue.Changed:Connect(function()
		self:_refreshBar()
	end)
	self._hpDriver = numberValue
	local textLabel4 = Instance.new("TextLabel", screenGui)
	textLabel4.Name = "PhaseLabel"
	textLabel4.AnchorPoint = Vector2.new(0.5, 0)
	textLabel4.BackgroundTransparency = 1
	textLabel4.Position = UDim2.new(0.5, 0, 0.08, 52)
	textLabel4.Size = UDim2.new(0.12, 0, 0, 20)
	textLabel4.Font = Enum.Font.GothamBold
	textLabel4.Text = "PHASE 1"
	textLabel4.TextColor3 = Color3.new(1, 1, 1)
	textLabel4.TextScaled = true
	textLabel4.TextStrokeTransparency = 0.5
	textLabel4.TextStrokeColor3 = Color3.new(0, 0, 0)
	self._phaseLabel = textLabel4
	self:_applyPhaseMarkerStyle(1)

	if _opts.animatedGradient then
		self:_applyBarGradient()
	end
end

function BossClientBase:_applyBarGradient()
	local _barFill = self._barFill

	if not _barFill then
		return
	end

	_barFill.BackgroundColor3 = Color3.fromRGB(155, 0, 190)

	if self._barGradientConn then
		self._barGradientConn:Disconnect()
		self._barGradientConn = nil
	end

	if self._barGradient then
		self._barGradient:Destroy()
	end

	local uIGradient = Instance.new("UIGradient")
	uIGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(235, 30, 255)),
		ColorSequenceKeypoint.new(0.32, Color3.fromRGB(20, 8, 30)),
		ColorSequenceKeypoint.new(0.68, Color3.fromRGB(195, 16, 240)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 0, 12))
	})
	uIGradient.Rotation = 0
	uIGradient.Parent = _barFill
	self._barGradient = uIGradient
	self._barGradientConn = RunService.Heartbeat:Connect(function()
		local _barGradient = self._barGradient

		if _barGradient and _barGradient.Parent then
			_barGradient.Offset = Vector2.new(math.sin(os.clock() * 0.85) * 0.65, 0)
		elseif self._barGradientConn then
			self._barGradientConn:Disconnect()
			self._barGradientConn = nil
		end
	end)
end

local v = {
	{ 1e18, "Qi" },
	{ 1000000000000000, "Qa" },
	{ 1000000000000, "T" },
	{ 1000000000, "B" },
	{ 1000000, "M" },
	{ 1000, "K" }
}

local function _fmtHp(p: number, p2: number, p3: string)
	if p2 == 1 then
		return (tostring((math.floor(p + 0.5))))
	end

	local v2 = p / p2

	if v2 >= 100 then
		return string.format("%d%s", math.floor(v2 + 0.5), p3)
	end

	if v2 >= 10 then
		return string.format("%.1f%s", v2, p3)
	end

	return string.format("%.2f%s", v2, p3)
end

function BossClientBase:_refreshBar()
	local _barFill = self._barFill
	local _hpLabel = self._hpLabel
	local _hpDriver = self._hpDriver

	if not _hpDriver or not _barFill or self._bossMaxRef <= 0 then
		return
	end

	local v2 = math.clamp(_hpDriver.Value, 0, self._bossMaxRef)
	_barFill.Size = UDim2.new(math.clamp(v2 / self._bossMaxRef, 0, 1), 0, 1, 0)

	if _hpLabel then
		local v3 = 1
		local v4 = ""

		for _, v6 in v do
			if not (self._bossMaxRef >= v6[1]) then
				continue
			end

			v3 = v6[1]
			v4 = v6[2]
			break
		end

		_hpLabel.Text = _fmtHp(v2, v3, v4) .. " / " .. _fmtHp(self._bossMaxRef, v3, v4)
	end

	local _endMarkerFrame = self._endMarkerFrame

	if _endMarkerFrame then
		local v3 = v2 / self._bossMaxRef >= 0.999
		local backgroundColor

		if v3 then
			backgroundColor = Color3.fromRGB(255, 30, 80)
		else
			backgroundColor = Color3.fromRGB(95, 95, 105)
		end

		_endMarkerFrame.BackgroundColor3 = backgroundColor
		_endMarkerFrame.BackgroundTransparency = v3 and 0.05 or 0.35

		if self._endMarkerText then
			local _endMarkerText = self._endMarkerText
			local textColor

			if v3 then
				textColor = Color3.fromRGB(255, 200, 210)
			else
				textColor = Color3.fromRGB(190, 190, 200)
			end

			_endMarkerText.TextColor3 = textColor
		end
	end
end

function BossClientBase:_applyPhaseMarkerStyle(p)
	local v2 = math.clamp(math.floor(p), 1, 100)

	for i, _phaseMarkerFrame in ipairs(self._phaseMarkerFrames) do
		local v3 = i + 1 <= v2
		local backgroundColor

		if v3 then
			backgroundColor = Color3.fromRGB(185, 110, 255)
		else
			backgroundColor = Color3.fromRGB(95, 95, 105)
		end

		_phaseMarkerFrame.BackgroundColor3 = backgroundColor
		_phaseMarkerFrame.BackgroundTransparency = v3 and 0.05 or 0.35
		local _phaseMarkerText = self._phaseMarkerTexts[i]

		if not _phaseMarkerText then
			continue
		end

		local textColor

		if v3 then
			textColor = Color3.fromRGB(235, 205, 255)
		else
			textColor = Color3.fromRGB(190, 190, 200)
		end

		_phaseMarkerText.TextColor3 = textColor
	end

	local _endMarkerFrame = self._endMarkerFrame

	if _endMarkerFrame then
		_endMarkerFrame.BackgroundColor3 = Color3.fromRGB(95, 95, 105)
		_endMarkerFrame.BackgroundTransparency = 0.35

		if self._endMarkerText then
			self._endMarkerText.TextColor3 = Color3.fromRGB(190, 190, 200)
		end
	end
end

function BossClientBase:_onBossHp(data)
	if type(data) ~= "table" then
		return
	end

	local hp = data.hp
	local max = data.max

	if type(hp) ~= "number" or type(max) ~= "number" or max <= 0 then
		return
	end

	if type(data.rev) == "number" and data.rev < self._lastRevisionSeen then
		return
	end

	if type(data.rev) == "number" then
		self._lastRevisionSeen = data.rev
	end

	self._bossMaxRef = max

	if self._hpTween then
		self._hpTween:Cancel()
		self._hpTween = nil
	end

	local v2 = math.clamp(hp, 0, max)

	if self._firstSync then
		local _hpDriver = self._hpDriver

		if not _hpDriver then
			return
		end

		local tween = TweenService:Create(
			_hpDriver,
			TweenInfo.new(self._opts.barTweenDurationSec, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				Value = v2
			}
		)
		self._hpTween = tween
		tween:Play()
	else
		self._firstSync = true

		if self._hpDriver then
			self._hpDriver.Value = v2
		end

		self:_refreshBar()
	end
end

function BossClientBase:_onPhase(value)
	local v2 = type(value) ~= "number" and 1 or value
	self:_applyPhaseMarkerStyle(v2)

	if self._phaseLabel then
		self._phaseLabel.Text = "PHASE " .. tostring((math.clamp(math.floor(v2), 1, 100)))
	end
end

function BossClientBase:_onFxEvent(p)
	if type(p) ~= "table" then
		return
	end

	local cmd = p.cmd
	local _opts = self._opts

	if cmd == "PhaseChange" then
		self:_onPhase(type(p.phase) ~= "number" and 1 or p.phase)
	elseif cmd == "CutsceneBegin" then
		if _opts.hideCutsceneUi then
			self:hideCutsceneUi()
		end
	elseif cmd == "CutsceneEnd" and _opts.hideCutsceneUi then
		self:showCutsceneUi()
	end

	if _opts.onFx then
		_opts.onFx(cmd, p, self)
	end
end

function BossClientBase:fire()
	if self._sse then
		self._sse:destroy()
		self._sse = nil
	end

	self:_buildUi()
	local sse = SharedSyncedEvent.new(self._opts.sseChannelName)
	self._sse = sse
	sse:onChange("BossHp", function(p)
		self:_onBossHp(p)
	end)
	sse:onChange("Phase", function(p)
		self:_onPhase(p)
	end)
	sse:onFire("Fx", function(p)
		self:_onFxEvent(p)
	end)
	sse:onChange("StartUnix", function(p)
		self:_onStartUnix(p)
	end)
end

function BossClientBase:_onStartUnix(_) end

function BossClientBase:stop()
	if self._sse then
		self._sse:destroy()
		self._sse = nil
	end

	if self._barGradientConn then
		self._barGradientConn:Disconnect()
		self._barGradientConn = nil
	end

	if self._barGradient then
		self._barGradient:Destroy()
		self._barGradient = nil
	end

	if self._hpTween then
		self._hpTween:Cancel()
		self._hpTween:Destroy()
		self._hpTween = nil
	end

	if self._hpDriver then
		self._hpDriver:Destroy()
		self._hpDriver = nil
	end

	if self._opts.hideCutsceneUi then
		self:showCutsceneUi()
	end

	if self._screen then
		self._screen:Destroy()
		self._screen = nil
	end

	self._barFill = nil
	self._hpLabel = nil
	self._phaseLabel = nil
	self._bossMaxRef = 1
	self._lastRevisionSeen = 0
	self._firstSync = false
	self._endMarkerFrame = nil
	self._endMarkerText = nil
	table.clear(self._phaseMarkerFrames)
	table.clear(self._phaseMarkerTexts)
	table.clear(self._savedUiStates)
end

function BossClientBase:hideCutsceneUi()
	local localPlayer = Players.LocalPlayer
	local playerGui2 = localPlayer and localPlayer:FindFirstChildOfClass("PlayerGui")

	if not playerGui2 then
		return
	end

	table.clear(self._savedUiStates)

	for _, frame in ipairs(CollectionService:GetTagged("UI")) do
		if not (frame:IsA("Frame") and frame:IsDescendantOf(playerGui2)) then
			continue
		end

		self._savedUiStates[frame] = frame.Visible
		frame.Visible = false
	end
end

function BossClientBase:showCutsceneUi()
	for k, _savedUiState in pairs(self._savedUiStates) do
		if k.Parent then
			k.Visible = _savedUiState
		end
	end

	table.clear(self._savedUiStates)
end

return BossClientBase