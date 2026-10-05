local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local t = require(ReplicatedStorage.Packages.t)
local intersection = t.intersection(t.numberMinExclusive(-1e999), t.numberMaxExclusive(1e999))
local AreaEggCycle = require(ReplicatedStorage.Shared.Util.AreaEggCycle)
local Assets = require(ReplicatedStorage.Data.Assets)
local EggActionMovement = require(script.Parent.EggActionMovement)
local EggRecords = require(ReplicatedStorage.Shared.Util.EggRecords)
local Eggs = require(ReplicatedStorage.Shared.Types.Eggs)
local Time = require(ReplicatedStorage.Shared.Utils.Time)
local elapsed = Time.Elapsed
local SwapGradient = require(ReplicatedStorage.Shared.Utils.SwapGradient)
local VisualTransform = require(ReplicatedStorage.Shared.Utils.VisualTransform)
local PlacedEggGrowthPresentationPolicy = require(script.Parent.PlacedEggGrowthPresentationPolicy)
local Trove = require(ReplicatedStorage.Packages.Trove)
local NightEggTimeSkipAnimation = {}
NightEggTimeSkipAnimation.__index = NightEggTimeSkipAnimation
NightEggTimeSkipAnimation.__class = "NightEggTimeSkipAnimation"
local tweenInfo = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(0.5, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out)
local tweenInfo3 = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local nightEggTimeSkip = ReplicatedStorage.Assets.Billboards.NightEggTimeSkip
assert(
	nightEggTimeSkip:IsA("BillboardGui"),
	"ReplicatedStorage.Assets.Billboards.NightEggTimeSkip must be a BillboardGui"
)

function NightEggTimeSkipAnimation.new(model, uid: string, record, basePivot: CFrame, p: number, p2: number, nightStartsAt: number, dayStartsAt: number)
	t.strict(t.instanceIsA("Model"))(model)
	t.strict(t.string)(uid)
	assert(Eggs.SchemaValidation.RuntimeEggRecord(record), "Invalid runtime egg record")
	t.strict(t.CFrame)(basePivot)
	t.strict(intersection)(p)
	t.strict(intersection)(p2)
	t.strict(intersection)(nightStartsAt)
	t.strict(intersection)(dayStartsAt)
	local v

	if p > 0 then
		v = p2 > 0
	else
		v = false
	end

	assert(v, "Egg time skip scales must be positive")
	assert(nightStartsAt < dayStartsAt, "Egg time skip day start must follow night start")
	assert(record.Placement, "Night egg time skip requires a placed egg")
	local v2 = Assets.Directory[record.AssetCategory]
	assert(v2 ~= nil, (`Missing asset config for category {record.AssetCategory}`))
	local growthSpeedMultiplier = record.GrowthSpeedMultiplier
	local periodIndexAt = AreaEggCycle.PeriodIndexAt(dayStartsAt)
	local committedNightCredit = EggRecords.CommittedNightCredit(record, periodIndexAt)
	local remainingAtNightfall = EggRecords.GrowthSecondsRemaining(record, nightStartsAt, growthSpeedMultiplier) + committedNightCredit
	local nightTargetCreditSeconds = math.min(AreaEggCycle.NightGrowthSkipSeconds, remainingAtNightfall)
	local self = setmetatable({}, NightEggTimeSkipAnimation)
	self._model = model
	self._uid = uid
	self._record = record
	self._basePivot = basePivot
	self._startScale = p
	self._targetScale = p2
	self._growthSpeedMultiplier = growthSpeedMultiplier
	self._nightStartsAt = nightStartsAt
	self._dayStartsAt = dayStartsAt
	self._nightPeriodIndex = periodIndexAt
	self._nightTargetCreditSeconds = nightTargetCreditSeconds
	self._committedNightCreditSeconds = committedNightCredit
	self._skipSeconds = math.max(0, nightTargetCreditSeconds - committedNightCredit)
	self._remainingAtNightfall = remainingAtNightfall
	self._nightScaleStart = p
	self._nightScaleEnd = p2
	self._snappedGrowthScale = nil
	assert(self._skipSeconds > 0, "Night egg time skip requires remaining growth time")
	self._appliedSeconds = Instance.new("NumberValue")
	self._billboardFader = VisualTransform.Fader()
	self._lifecycleTrove = Trove.new()
	self._visualTrove = Trove.new()
	self._animation = nil
	self._visualFinishing = false
	self._visualFinished = false
	self._billboardFadeFinished = false
	self._pendingCommit = true
	self._destroyed = false
	self._lastTimerSecond = -1
	self._lastShakeElapsed = 0
	self._lastShakeAlpha = 0
	self._lastShakePitch = 0
	self._lastShakeRoll = 0
	self._billboard = nil
	self._timerLabel = nil
	self._textScale = nil
	self._originalTextColor = nil
	self._rarityGradient = v2.Rarity.RarityGradient
	self:_refreshNightScaleRange()
	self._lifecycleTrove:Add(self._appliedSeconds)
	self:_init()
	return self
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stepPresentation(fn)
	local total = 0
	local preRenderConnection = nil
	preRenderConnection = RunService.PreRender:Connect(function(dt: number)
		total += dt

		if fn(total) then
			preRenderConnection:Disconnect()
		end
	end)
	return preRenderConnection
end

-- equivalent calls inferred from this helper; original call sites unknown
local function easeOutQuad(p: number)
	return TweenService:GetValue(p, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
end

function NightEggTimeSkipAnimation:_getAppliedSecondsAt(p: number)
	return EggRecords.NightCreditAt(
		self._record,
		p,
		self._growthSpeedMultiplier,
		self._nightStartsAt,
		self._nightPeriodIndex
	)
end

function NightEggTimeSkipAnimation:_getGrowthScaleAt(p: number)
	local growthAlpha = EggRecords.GrowthAlpha(
		self._record,
		p,
		self._growthSpeedMultiplier,
		self:_getAppliedSecondsAt(p)
	)
	return (math.lerp(self._startScale, self._targetScale, growthAlpha))
end

function NightEggTimeSkipAnimation:_refreshNightScaleRange()
	local _getGrowthScaleAt = self:_getGrowthScaleAt(self._nightStartsAt)
	local _getGrowthScaleAt2 = self:_getGrowthScaleAt(self._dayStartsAt)
	local v = math.abs(self._nightScaleStart - _getGrowthScaleAt) > 0.001 or math.abs(self._nightScaleEnd - _getGrowthScaleAt2) > 0.001
	self._nightScaleStart = _getGrowthScaleAt
	self._nightScaleEnd = _getGrowthScaleAt2

	if v then
		self._snappedGrowthScale = nil
	end
end

function NightEggTimeSkipAnimation:_createPresentation()
	local primaryPart = self._model.PrimaryPart
	t.strict(t.instanceIsA("BasePart"))(primaryPart)
	local v = math.min(
		5,
		(math.max(
			0.1,
			(primaryPart.Size.X / 6.388999938964844 * (primaryPart.Size.Y / 7.507999897003174) * (primaryPart.Size.Z / 6.367000102996826)) ^ 0.3333333333333333 * 0.9
		))
	)
	local attachment = Instance.new("Attachment")
	attachment.Name = "NightEggTimeSkipAttachment"
	attachment.Parent = primaryPart
	self._visualTrove:Add(attachment)
	local clone = nightEggTimeSkip:Clone()
	local main = clone.Main
	assert(main:IsA("Frame"), "NightEggTimeSkip.Main must be a Frame")
	local v2 = nil

	for _, frame in main:GetChildren() do
		if not frame:IsA("Frame") then
			continue
		end

		assert(v2 == nil, "NightEggTimeSkip.Main must contain exactly one content Frame")
		v2 = frame
	end

	local v3 = assert(v2, "NightEggTimeSkip.Main must contain a content Frame")
	local timer = v3.Timer
	assert(timer:IsA("Frame"), "NightEggTimeSkip.Main.Frame.Timer must be a Frame")
	local timer2 = timer.Timer
	assert(timer2:IsA("TextLabel"), "NightEggTimeSkip.Main.Frame.Timer.Timer must be a TextLabel")
	local multiplier = timer.Multiplier
	assert(multiplier:IsA("TextLabel"), "NightEggTimeSkip.Main.Frame.Timer.Multiplier must be a TextLabel")
	local displayName = v3.DisplayName
	assert(displayName:IsA("TextLabel"), "NightEggTimeSkip.Main.Frame.DisplayName must be a TextLabel")
	displayName.Text = "Egg"
	SwapGradient(displayName, self._rarityGradient)
	local size = clone.Size
	clone.Size = UDim2.new(size.X.Scale * v, size.X.Offset * v, size.Y.Scale * v, size.Y.Offset * v)
	clone.StudsOffsetWorldSpace = createVector(0, -2, 0)
	clone.Adornee = attachment
	clone.Parent = attachment
	self._billboard = clone
	self._timerLabel = timer2
	self._originalTextColor = timer2.TextColor3
	self._visualTrove:Add(clone)
	local uIScale = Instance.new("UIScale")
	uIScale.Name = "NightEggTimeSkipScale"
	uIScale.Scale = 1
	uIScale.Parent = timer2
	self._textScale = uIScale
	local _billboardFader = self._billboardFader
	self._visualTrove:Add(function()
		_billboardFader:Hide(clone, 0)
	end)
	_billboardFader:Hide(clone, 1)
	local v4 = math.max(0, (math.floor(self._remainingAtNightfall - self._committedNightCreditSeconds + 0.5)))
	timer2.Text = v4 == 0 and "READY!" or elapsed(v4)
	multiplier.Text = `(x{math.round(AreaEggCycle.NightGrowthRate() * 10) / 10})`
end

function NightEggTimeSkipAnimation:_setAppliedSeconds(value: number)
	local v = math.clamp(value, 0, self._skipSeconds)
	self._appliedSeconds.Value = v
	local lastTimerSecond = math.max(
		0,
		(math.floor(self._remainingAtNightfall - self._committedNightCreditSeconds - v + 0.5))
	)

	if lastTimerSecond == self._lastTimerSecond then
		return
	end

	self._lastTimerSecond = lastTimerSecond
	local _timerLabel = self._timerLabel

	if _timerLabel ~= nil then
		_timerLabel.Text = lastTimerSecond == 0 and "READY!" or elapsed(lastTimerSecond)
	end
end

function NightEggTimeSkipAnimation:_applyShake(lastShakeElapsed: number, lastShakeAlpha: number)
	local lastShakePitch = math.sin(lastShakeElapsed * 3.141592653589793 * 2 * 1.75) * 0.039269908169872414 * lastShakeAlpha
	local lastShakeRoll = math.cos(lastShakeElapsed * 3.141592653589793 * 2 * 2.25) * 0.05672320068981571 * lastShakeAlpha
	self._lastShakeElapsed = lastShakeElapsed
	self._lastShakeAlpha = lastShakeAlpha
	self._lastShakePitch = lastShakePitch
	self._lastShakeRoll = lastShakeRoll
	EggActionMovement.SetPivot(self._model, self._basePivot * CFrame.Angles(lastShakePitch, 0, lastShakeRoll))
end

function NightEggTimeSkipAnimation:_updateModel(p: number)
	local _model = self._model
	self:_setAppliedSeconds((self:_getAppliedSecondsAt(p)))
	local growthScaleDeltaSkipReason = PlacedEggGrowthPresentationPolicy.GetGrowthScaleDeltaSkipReason(
		self._nightScaleStart,
		self._nightScaleEnd
	)

	if growthScaleDeltaSkipReason == nil then
		self._snappedGrowthScale = nil
		_model:ScaleTo(self:_getGrowthScaleAt(p))
	elseif self._snappedGrowthScale ~= self._nightScaleEnd then
		_model:ScaleTo(self._nightScaleEnd)
		self._snappedGrowthScale = self._nightScaleEnd
		PlacedEggGrowthPresentationPolicy.LogSkipped(
			self._uid,
			"night growth scale channel",
			growthScaleDeltaSkipReason
		)
	end

	local v = math.max(0, p - self._nightStartsAt)
	self:_applyShake(
		v,
		(TweenService:GetValue(math.clamp(v / 5, 0, 1), Enum.EasingStyle.Quad, Enum.EasingDirection.Out))
	)
	local _billboard = self._billboard

	if _billboard == nil then
		self._billboardFadeFinished = true
		return
	end

	local v4 = easeOutQuad(math.clamp(v / 1, 0, 1)) -- equivalent call inferred; original call site unknown
	_billboard.StudsOffsetWorldSpace = (createVector(0, -2, 0)):Lerp(createVector(0, 0, 0), v4)
	self._billboardFader:Hide(_billboard, 1 - v4)
end

function NightEggTimeSkipAnimation:_fadeVisuals()
	local _billboard = self._billboard

	if _billboard == nil then
		self._billboardFadeFinished = true
		return
	end

	local _billboardFader = self._billboardFader
	local _lastShakeElapsed = self._lastShakeElapsed
	local _lastShakeAlpha = self._lastShakeAlpha
	local v = 0

	while v < 5 do
		local v2 = RunService.PreRender:Wait()

		if self._destroyed then
			break
		end

		v = math.min(v + v2, 5)
		local v3 = math.clamp(v / 1, 0, 1)
		local v4 = easeOutQuad(v3) -- equivalent call inferred; original call site unknown
		local v6 = easeOutQuad(v / 5) -- equivalent call inferred; original call site unknown
		_billboardFader:Hide(_billboard, v4)

		if v3 >= 1 then
			self._billboardFadeFinished = true
		end

		self:_applyShake(_lastShakeElapsed + v, _lastShakeAlpha * (1 - v6))
	end
end

function NightEggTimeSkipAnimation:_playTextFinish()
	local _timerLabel = self._timerLabel
	local _textScale = self._textScale
	local _originalTextColor = self._originalTextColor

	if _timerLabel == nil or _textScale == nil or _originalTextColor == nil then
		return
	end

	local tween = TweenService:Create(_textScale, tweenInfo, {
		Scale = 1.5
	})
	local tween2 = TweenService:Create(_timerLabel, tweenInfo3, {
		TextColor3 = Color3.new(1, 1, 1)
	})
	self._visualTrove:Add(tween)
	self._visualTrove:Add(tween2)
	tween:Play()
	tween2:Play()
	tween.Completed:Wait()

	if self._destroyed then
		return
	end

	local tween3 = TweenService:Create(_textScale, tweenInfo2, {
		Scale = 1
	})
	local tween4 = TweenService:Create(_timerLabel, tweenInfo3, {
		TextColor3 = _originalTextColor
	})
	self._visualTrove:Add(tween3)
	self._visualTrove:Add(tween4)
	tween3:Play()
	tween4:Play()
	tween3.Completed:Wait()

	if not self._destroyed then
		_timerLabel.TextColor3 = _originalTextColor
	end
end

function NightEggTimeSkipAnimation:_finishVisuals(flag: boolean)
	if self._visualFinishing or self._visualFinished or self._destroyed then
		return
	end

	self._visualFinishing = true
	local _animation = self._animation

	if _animation ~= nil then
		_animation:Disconnect()
		self._animation = nil
	end

	local v

	if flag then
		v = self._skipSeconds
	else
		v = self:_getAppliedSecondsAt(Workspace:GetServerTimeNow())
	end

	self:_setAppliedSeconds(v)

	if flag then
		local _lastShakeElapsed = self._lastShakeElapsed
		local _lastShakeAlpha = self._lastShakeAlpha

		local function fn(p: number)
			if self._destroyed then
				return true
			end

			self:_applyShake(_lastShakeElapsed + p, _lastShakeAlpha)
			return nil
		end

		local connection = stepPresentation(fn) -- equivalent call inferred; original call site unknown
		self._animation = connection
		self:_playTextFinish()
		connection:Disconnect()

		if self._animation == connection then
			self._animation = nil
		end
	end

	if not self._destroyed then
		self:_fadeVisuals()
	end

	if self._destroyed then
		return
	end

	self._lastShakeAlpha = 0
	self._lastShakePitch = 0
	self._lastShakeRoll = 0
	EggActionMovement.SetPivot(self._model, self._basePivot)
	self._visualTrove:Clean()
	self._billboard = nil
	self._timerLabel = nil
	self._textScale = nil
	self._visualFinishing = false
	self._visualFinished = true
end

function NightEggTimeSkipAnimation:_start()
	self:_createPresentation()

	local function fn(_: number)
		if self._destroyed or self._model.Parent == nil then
			return true
		end

		local serverTimeNow = Workspace:GetServerTimeNow()
		self:_updateModel(serverTimeNow)

		if EggRecords.GrowthSecondsRemaining(
			self._record,
			serverTimeNow,
			self._growthSpeedMultiplier,
			self._appliedSeconds.Value
		) <= 0 and serverTimeNow < self._dayStartsAt then
			task.spawn(self._finishVisuals, self, false)
			return true
		end

		if self._dayStartsAt <= serverTimeNow then
			task.spawn(self._finishVisuals, self, true)
			return true
		else
			return nil
		end
	end

	self._animation = stepPresentation(fn)
end

function NightEggTimeSkipAnimation:_init()
	self:_start()
end

function NightEggTimeSkipAnimation:GetAppliedSecondsValue()
	return self._appliedSeconds
end

function NightEggTimeSkipAnimation:IsComplete()
	return self._visualFinished and not self._pendingCommit
end

function NightEggTimeSkipAnimation:IsBillboardFadeFinished()
	return self._billboardFadeFinished
end

function NightEggTimeSkipAnimation:SetTransform(basePivot: CFrame, startScale: number, targetScale: number)
	t.strict(t.CFrame)(basePivot)
	t.strict(intersection)(startScale)
	t.strict(intersection)(targetScale)
	self._basePivot = basePivot
	self._startScale = startScale
	self._targetScale = targetScale
	self:_refreshNightScaleRange()
end

function NightEggTimeSkipAnimation:AcknowledgeRecord(record)
	assert(Eggs.SchemaValidation.RuntimeEggRecord(record), "Invalid runtime egg record")
	self._record = record
	self._growthSpeedMultiplier = record.GrowthSpeedMultiplier
	local placement = record.Placement

	if placement == nil or placement.ReadyAt ~= nil then
		self:_setAppliedSeconds(0)
		self._pendingCommit = false
	else
		local committedNightCredit = EggRecords.CommittedNightCredit(record, self._nightPeriodIndex)
		self._committedNightCreditSeconds = committedNightCredit
		local remainingAtNightfall = EggRecords.GrowthSecondsRemaining(
			record,
			self._nightStartsAt,
			self._growthSpeedMultiplier
		) + committedNightCredit
		self._remainingAtNightfall = remainingAtNightfall
		self._nightTargetCreditSeconds = math.min(AreaEggCycle.NightGrowthSkipSeconds, remainingAtNightfall)
		self._skipSeconds = math.max(0, self._nightTargetCreditSeconds - committedNightCredit)
		self:_refreshNightScaleRange()
		self:_setAppliedSeconds(self:_getAppliedSecondsAt(Workspace:GetServerTimeNow()))

		if self._nightTargetCreditSeconds - 0.05 <= committedNightCredit then
			self._pendingCommit = false
		end
	end
end

function NightEggTimeSkipAnimation:CancelVisual()
	if self._visualFinished or self._visualFinishing then
		return
	end

	task.spawn(self._finishVisuals, self, false)
end

function NightEggTimeSkipAnimation:Destroy()
	if self._destroyed then
		return
	end

	self._destroyed = true
	local _animation = self._animation

	if _animation ~= nil then
		_animation:Disconnect()
		self._animation = nil
	end

	self._visualTrove:Destroy()
	self._lifecycleTrove:Destroy()

	if self._model.Parent ~= nil then
		EggActionMovement.SetPivot(self._model, self._basePivot)
	end
end

return NightEggTimeSkipAnimation