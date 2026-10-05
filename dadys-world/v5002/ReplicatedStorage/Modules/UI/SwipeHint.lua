local SwipeHint = {}
SwipeHint.__index = SwipeHint
local v = {
	template = nil,
	templateName = "SwipeHint",
	tapName = "Tap",
	arrowName = "Arrow",
	startScale = 1.6,
	introTweenInfo = TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
	fadeTweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	beat = 0,
	slideDistance = 0.25,
	slideTweenInfo = TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
	gradientStart = Vector2.new(-0.5, 0),
	gradientEnd = Vector2.new(0.2, 0),
	fadeOutAt = 0.6,
	fadeOutTweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
	loopGap = 0.4,
	alternate = true,
	flipRotation = 180,
	startDirection = 1,
	zIndex = nil,
	autoPlay = false
}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local tweenHelpers = require(ReplicatedStorage.SharedUtils.tweenHelpers)
local numberSequence = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 1),
	NumberSequenceKeypoint.new(0.5, 0),
	NumberSequenceKeypoint.new(1, 0)
})

local function scaleUDim2(p, p2)
	return UDim2.new(p.X.Scale * p2, math.round(p.X.Offset * p2), p.Y.Scale * p2, (math.round(p.Y.Offset * p2)))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function resolveTemplate(p)
	if p.template then
		return p.template
	end

	local UI = ReplicatedStorage:FindFirstChild("UI")
	return UI and UI:FindFirstChild(p.templateName)
end

function SwipeHint.new(instance, options)
	if typeof(instance) ~= "Instance" or not (instance:IsA("GuiObject") or instance:IsA("LayerCollector")) then
		warn("[SwipeHint] needs a GuiObject or ScreenGui parent")
		return nil
	end

	local settings = {}

	for k, v3 in v do
		settings[k] = v3
	end

	for k, v3 in options or {} do
		settings[k] = v3
	end

	local template = resolveTemplate(settings) -- equivalent call inferred; original call site unknown

	if not template then
		warn(string.format(
			"[SwipeHint] no template at ReplicatedStorage.UI.%s — prompt skipped",
			(tostring(settings.templateName))
		))
		return nil
	end

	local clone = template:Clone()
	local child = clone:FindFirstChild(settings.tapName)
	local child2 = clone:FindFirstChild(settings.arrowName)

	if child and child2 then
		local gradient = child2:FindFirstChildOfClass("UIGradient")

		if not gradient then
			gradient = Instance.new("UIGradient")
			gradient.Transparency = numberSequence
			gradient.Parent = child2
		end

		local object = setmetatable({}, SwipeHint)
		object.settings = settings
		object.frame = clone
		object.tap = child
		object.arrow = child2
		object.gradient = gradient
		object.isDestroyed = false
		object.isPlaying = false
		object.loopThread = nil
		object.tweens = {}
		object.direction = settings.startDirection == -1 and -1 or 1
		object.tapSize = child.Size
		object.tapPosition = child.Position
		object.frameRotation = clone.Rotation
		object.gradientRotation = gradient.Rotation

		if settings.zIndex then
			clone.ZIndex = settings.zIndex
		end

		clone.Visible = false
		clone.Parent = instance

		if settings.autoPlay then
			object:start()
		end

		return object
	else
		warn(string.format(
			"[SwipeHint] template '%s' needs both a '%s' and an '%s' child — prompt skipped",
			template.Name,
			settings.tapName,
			settings.arrowName
		))
		clone:Destroy()
		return nil
	end
end

function SwipeHint:start()
	if self.isDestroyed then
		return
	end

	self:_stopThreads()
	self:_cancelTweens()
	self.isPlaying = true
	self.paused = false
	self.frame.Visible = true
	self.loopThread = task.spawn(function()
		while true do
			self:_playPass(self.direction)

			if self.settings.alternate then
				self.direction = -self.direction
			end

			task.wait(self.settings.loopGap)
		end
	end)
end

function SwipeHint:stop()
	if self.isDestroyed or not self.isPlaying then
		return
	end

	self:_stopThreads()
	self:_cancelTweens()
	self.isPlaying = false
	self.paused = false
	local fadeOutTweenInfo = self.settings.fadeOutTweenInfo
	self:_track(tweenHelpers.playTween(self.tap, fadeOutTweenInfo, {
		ImageTransparency = 1
	}))
	self:_track(tweenHelpers.playTween(self.arrow, fadeOutTweenInfo, {
		ImageTransparency = 1
	}))
	self.loopThread = task.spawn(function()
		task.wait(fadeOutTweenInfo.Time)
		self.loopThread = nil

		if not self.isDestroyed then
			self.frame.Visible = false
		end
	end)
end

function SwipeHint:pause()
	if self.isDestroyed or not self.isPlaying or self.paused then
		return
	end

	self.paused = true
	self:_stopThreads()
	self:_cancelTweens()
end

function SwipeHint:resume()
	if self.isDestroyed or not self.paused then
		return
	end

	self:start()
end

function SwipeHint.setZIndex(data, zIndex)
	if data.isDestroyed or type(zIndex) ~= "number" or data.frame.ZIndex == zIndex then
		return
	end

	data.settings.zIndex = zIndex
	data.frame.ZIndex = zIndex
end

function SwipeHint.setSlideDistance(p, slideDistance)
	if p.isDestroyed or type(slideDistance) ~= "number" or p.settings.slideDistance == slideDistance then
		return
	end

	p.settings.slideDistance = slideDistance
end

function SwipeHint:destroy()
	if self.isDestroyed then
		return
	end

	self.isDestroyed = true
	self.isPlaying = false
	self.paused = false
	self:_stopThreads()
	self:_cancelTweens()

	if self.frame then
		self.frame:Destroy()
		self.frame = nil
	end
end

function SwipeHint:_track(p2)
	if p2 then
		table.insert(self.tweens, p2)
	end

	return p2
end

function SwipeHint:_cancelTweens()
	for _, tween in self.tweens do
		local v2 = tween
		pcall(function()
			v2:Cancel()
		end)
	end

	table.clear(self.tweens)
end

function SwipeHint:_stopThreads()
	local thread = coroutine.running()
	local loopThread = self.loopThread
	self.loopThread = nil

	if loopThread and loopThread ~= thread then
		task.cancel(loopThread)
	end
end

function SwipeHint:_reset(p)
	local settings = self.settings
	local tap = self.tap
	local tapSize = self.tapSize
	local startScale = settings.startScale
	tap.Size = UDim2.new(
		tapSize.X.Scale * startScale,
		math.round(tapSize.X.Offset * startScale),
		tapSize.Y.Scale * startScale,
		(math.round(tapSize.Y.Offset * startScale))
	)
	self.tap.Position = self.tapPosition
	self.tap.ImageTransparency = 1
	self.arrow.ImageTransparency = 1
	self.gradient.Offset = settings.gradientStart
	self.frame.Rotation = p == 1 and self.frameRotation or self.frameRotation + settings.flipRotation
end

function SwipeHint:_playPass(p)
	self:_cancelTweens()
	self:_reset(p)
	local settings = self.settings
	local introTweenInfo = settings.introTweenInfo
	local fadeTweenInfo = settings.fadeTweenInfo
	self:_track(tweenHelpers.playTween(self.tap, introTweenInfo, {
		Size = self.tapSize
	}))
	self:_track(tweenHelpers.playTween(self.tap, fadeTweenInfo, {
		ImageTransparency = 0
	}))
	self:_track(tweenHelpers.playTween(self.arrow, fadeTweenInfo, {
		ImageTransparency = 0
	}))
	task.wait(introTweenInfo.Time + settings.beat)
	local tapPosition = self.tapPosition
	local uDim = UDim2.new(
		tapPosition.X.Scale + settings.slideDistance,
		tapPosition.X.Offset,
		tapPosition.Y.Scale,
		tapPosition.Y.Offset
	)
	local slideTweenInfo = settings.slideTweenInfo
	self:_track(tweenHelpers.playTween(self.tap, slideTweenInfo, {
		Position = uDim
	}))
	self:_track(tweenHelpers.playTween(self.gradient, slideTweenInfo, {
		Offset = settings.gradientEnd
	}))
	task.wait(slideTweenInfo.Time * settings.fadeOutAt)
	local fadeOutTweenInfo = settings.fadeOutTweenInfo
	self:_track(tweenHelpers.playTween(self.tap, fadeOutTweenInfo, {
		ImageTransparency = 1
	}))
	self:_track(tweenHelpers.playTween(self.arrow, fadeOutTweenInfo, {
		ImageTransparency = 1
	}))
	task.wait(fadeOutTweenInfo.Time)
end

return SwipeHint