local BrushaSignature = {}
BrushaSignature.__index = BrushaSignature
local v = {
	fxTemplate = nil,
	parent = nil,
	studsOffset = nil,
	flipbookName = "1",
	sheetPixelSize = 712,
	gridSize = 2,
	flipbookInterval = 0.05,
	bobHeight = 0.05,
	bobTweenInfo = TweenInfo.new(0.75, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
	pulseAmount = 0.04,
	pulseTweenInfo = TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
	swipeName = "Swipe",
	swipeStartOffset = Vector2.new(-0.5, 0),
	swipeEndOffset = Vector2.new(0.5, 0),
	swipeTweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
	swipeFadeTweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	introScale = 0.2,
	introTweenInfo = TweenInfo.new(0.55, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
	exitTweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In),
	highlightEnabled = true,
	highlightTarget = nil,
	highlightStyle = "Machine",
	highlightColor = Color3.fromRGB(153, 81, 137),
	highlightDepthMode = Enum.HighlightDepthMode.Occluded,
	highlightPulseHold = 0.5,
	highlightPulseFade = 2.5,
	highlightPulseGap = 5,
	highlightPulseSynced = true,
	autoPlay = true,
	lifetime = nil
}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local tweenHelpers = require(ReplicatedStorage.SharedUtils.tweenHelpers)
local HighlightController = require(ReplicatedStorage.SharedUtils.HighlightController)
local count = 0
local numberSequence = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 1),
	NumberSequenceKeypoint.new(0.5, 0),
	NumberSequenceKeypoint.new(1, 1)
})

local function toCFrame(position)
	if typeof(position) == "CFrame" then
		return position
	end

	if typeof(position) == "Vector3" then
		return CFrame.new(position)
	end

	return nil
end

local function buildCells(sheetPixelSize, gridSize)
	local v2 = sheetPixelSize / gridSize
	local vectors = {}

	for i = 0, gridSize - 1 do
		for i2 = 0, gridSize - 1 do
			table.insert(vectors, Vector2.new(i2 * v2, i * v2))
		end
	end

	return vectors, v2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function scaleUDim2(baseSize, p)
	return UDim2.new(
		baseSize.X.Scale * p,
		math.round(baseSize.X.Offset * p),
		baseSize.Y.Scale * p,
		(math.round(baseSize.Y.Offset * p))
	)
end

function BrushaSignature.new(cframe, options)
	if typeof(cframe) ~= "CFrame" then
		if typeof(cframe) == "Vector3" then
			cframe = CFrame.new(cframe)
		else
			cframe = nil
		end
	end

	assert(cframe, "brushaSignature: a CFrame or Vector3 placement is required")
	local settings = {}

	for k, v3 in v do
		settings[k] = v3
	end

	for k, v3 in options or {} do
		settings[k] = v3
	end

	if not settings.fxTemplate then
		local parts = ReplicatedStorage:FindFirstChild("Parts")
		local renderParts = parts and parts:FindFirstChild("RenderParts")
		local brusha = renderParts and renderParts:FindFirstChild("Brusha")
		settings.fxTemplate = brusha and brusha:FindFirstChild("Signature")
	end

	assert(settings.fxTemplate, "brushaSignature: could not find Parts.RenderParts.Brusha.Signature")
	local clone = settings.fxTemplate:Clone()
	assert(clone:IsA("BasePart"), "brushaSignature: the Signature template must be a part")
	local billboardGui = clone:FindFirstChildWhichIsA("BillboardGui", true)
	assert(billboardGui, "brushaSignature: the Signature part carries no BillboardGui")
	local frame = billboardGui:FindFirstChild("Frame")
	assert(frame and frame:IsA("GuiObject"), "brushaSignature: the BillboardGui needs a Frame")
	local image = frame:FindFirstChild(settings.flipbookName) or frame:FindFirstChildWhichIsA("ImageLabel")
	assert(image, "brushaSignature: the Frame carries no flipbook ImageLabel")
	local self = setmetatable({}, BrushaSignature)
	self.settings = settings
	self.fxPart = clone
	self.billboard = billboardGui
	self.frame = frame
	self.image = image
	self.isDestroyed = false
	self.isPlaying = false
	self.highlightId = nil
	self.introThread = nil
	self.lifetimeThread = nil
	self.flipbookThread = nil
	self.bobThread = nil
	self.pulseThread = nil
	self.swipe = billboardGui:FindFirstChild(settings.swipeName)

	if self.swipe then
		self.swipeGradient = self.swipe:FindFirstChildOfClass("UIGradient")

		if not self.swipeGradient then
			self.swipeGradient = Instance.new("UIGradient")
			self.swipeGradient.Transparency = numberSequence
			self.swipeGradient.Parent = self.swipe
		end

		self.swipe.Visible = false
	end

	local cells, cellPixelSize = buildCells(settings.sheetPixelSize, settings.gridSize)
	self.cells = cells
	self.cellPixelSize = cellPixelSize
	image.ScaleType = Enum.ScaleType.Stretch
	image.ImageRectSize = Vector2.new(self.cellPixelSize, self.cellPixelSize)
	image.ImageRectOffset = self.cells[1]
	self.basePosition = frame.Position
	self.baseSize = frame.Size
	self.baseImageTransparency = image.ImageTransparency
	self:_place(cframe)
	frame.Visible = false

	if settings.autoPlay then
		self:playIntro()
	end

	return self
end

function BrushaSignature:_place(p)
	local fxPart = self.fxPart
	fxPart.Anchored = true
	fxPart.CanCollide = false
	fxPart.CanQuery = false
	fxPart.CanTouch = false
	fxPart.Transparency = 1
	fxPart.CFrame = p

	if self.settings.studsOffset then
		self.billboard.StudsOffset = self.settings.studsOffset
	end

	self.placementCFrame = p
	fxPart.Parent = self.settings.parent or workspace
end

function BrushaSignature:moveTo(cframe)
	if typeof(cframe) ~= "CFrame" then
		if typeof(cframe) == "Vector3" then
			cframe = CFrame.new(cframe)
		else
			cframe = nil
		end
	end

	if self.isDestroyed or not cframe then
		return
	end

	self.placementCFrame = cframe
	self.fxPart.CFrame = cframe
end

function BrushaSignature.setOffset(data, studsOffset)
	if data.isDestroyed or typeof(studsOffset) ~= "Vector3" then
		return
	end

	data.settings.studsOffset = studsOffset
	data.billboard.StudsOffset = studsOffset
end

function BrushaSignature:_raiseHighlight()
	local settings = self.settings

	if settings.highlightEnabled ~= true then
		return
	end

	local highlightTarget = settings.highlightTarget or settings.parent

	if typeof(highlightTarget) ~= "Instance" then
		return
	end

	self:_clearHighlight()
	count += 1
	local highlightId = "BrushaSignature_" .. count
	self.highlightId = highlightId
	local v3 = {
		FillColor = settings.highlightColor,
		FillTransparency = 1,
		OutlineColor = settings.highlightColor,
		OutlineTransparency = 0,
		DepthMode = settings.highlightDepthMode,
		PulseHold = settings.highlightPulseHold,
		PulseFade = settings.highlightPulseFade,
		PulseGap = settings.highlightPulseGap,
		PulseSync = settings.highlightPulseSynced
	}

	if RunService:IsServer() then
		HighlightController:BroadcastHighlight(highlightTarget, settings.highlightStyle, v3, highlightId)
	else
		HighlightController:PlayHighlight(highlightTarget, settings.highlightStyle, v3, highlightId)
	end
end

function BrushaSignature:_clearHighlight()
	local highlightId = self.highlightId

	if not highlightId then
		return
	end

	self.highlightId = nil

	if RunService:IsServer() then
		HighlightController:BroadcastClear(highlightId)
	else
		HighlightController:ClearHighlight(highlightId)
	end
end

function BrushaSignature.setFlipbookInterval(p, value)
	if p.isDestroyed or type(value) ~= "number" then
		return
	end

	p.settings.flipbookInterval = math.max(value, 0.016666666666666666)
end

function BrushaSignature:playIntro()
	if self.isDestroyed then
		return
	end

	self:_stopThreads()
	local settings = self.settings
	local frame = self.frame
	frame.Position = self.basePosition
	local baseSize = self.baseSize
	local introScale = settings.introScale
	frame.Size = UDim2.new(
		baseSize.X.Scale * introScale,
		math.round(baseSize.X.Offset * introScale),
		baseSize.Y.Scale * introScale,
		(math.round(baseSize.Y.Offset * introScale))
	)
	self.image.ImageTransparency = self.baseImageTransparency
	frame.Visible = true
	self.isPlaying = true
	self:_startFlipbook()
	self:_raiseHighlight()
	tweenHelpers.playTween(frame, settings.introTweenInfo, {
		Size = self.baseSize
	})
	self.introThread = task.spawn(function()
		local swipe = self.swipe

		if swipe then
			self.swipeGradient.Offset = settings.swipeStartOffset
			swipe.ImageTransparency = 0
			swipe.Visible = true
			tweenHelpers.playTween(self.swipeGradient, settings.swipeTweenInfo, {
				Offset = settings.swipeEndOffset
			})
			task.wait(settings.swipeTweenInfo.Time)
			tweenHelpers.playTween(swipe, settings.swipeFadeTweenInfo, {
				ImageTransparency = 1
			})
			task.wait(settings.swipeFadeTweenInfo.Time)
			swipe.Visible = false
		end

		local v2 = swipe and settings.swipeTweenInfo.Time + settings.swipeFadeTweenInfo.Time or 0
		local v3 = settings.introTweenInfo.Time - v2

		if v3 > 0 then
			task.wait(v3)
		end

		self.introThread = nil

		if self.isDestroyed or not self.isPlaying then
			return
		end

		frame.Size = self.baseSize
		frame.Position = self.basePosition
		self:_startIdle()
	end)
	self:_startLifetime()
end

function BrushaSignature:playExit(p)
	if self.isDestroyed or not self.isPlaying then
		return
	end

	self:_stopThreads()
	self.isPlaying = false
	local settings = self.settings
	local exitTweenInfo = settings.exitTweenInfo
	local playTween = tweenHelpers.playTween
	local frame = self.frame
	local baseSize = self.baseSize
	local introScale = settings.introScale
	playTween(frame, exitTweenInfo, {
		Size = UDim2.new(
			baseSize.X.Scale * introScale,
			math.round(baseSize.X.Offset * introScale),
			baseSize.Y.Scale * introScale,
			(math.round(baseSize.Y.Offset * introScale))
		)
	})
	tweenHelpers.playTween(self.image, exitTweenInfo, {
		ImageTransparency = 1
	})
	self.introThread = task.spawn(function()
		task.wait(exitTweenInfo.Time)
		self.introThread = nil

		if self.isDestroyed then
			return
		end

		self:_clearHighlight()
		self.frame.Visible = false

		if p then
			self:destroy()
		end
	end)
end

function BrushaSignature:destroy()
	if self.isDestroyed then
		return
	end

	self.isDestroyed = true
	self.isPlaying = false
	self:_stopThreads()
	self:_clearHighlight()

	if self.fxPart then
		self.fxPart:Destroy()
		self.fxPart = nil
	end
end

function BrushaSignature:_stopThreads()
	local thread = coroutine.running()

	for _, v2 in {
		"introThread",
		"lifetimeThread",
		"flipbookThread",
		"bobThread",
		"pulseThread"
	} do
		local v3 = self[v2]
		self[v2] = nil

		if v3 and v3 ~= thread then
			task.cancel(v3)
		end
	end
end

function BrushaSignature:_startLifetime()
	local lifetime = self.settings.lifetime

	if type(lifetime) ~= "number" or lifetime <= 0 then
		return
	end

	self.lifetimeThread = task.spawn(function()
		task.wait(lifetime)
		self.lifetimeThread = nil

		if not self.isDestroyed then
			self:playExit(true)
		end
	end)
end

function BrushaSignature:_startFlipbook()
	if self.flipbookThread then
		return
	end

	local cells = self.cells
	local image = self.image
	self.flipbookThread = task.spawn(function()
		local v2 = 0

		while true do
			v2 = v2 % #cells + 1
			image.ImageRectOffset = cells[v2]
			task.wait(self.settings.flipbookInterval)
		end
	end)
end

function BrushaSignature:_startIdle()
	local settings = self.settings
	local frame = self.frame
	local basePosition = self.basePosition
	local bobTweenInfo = settings.bobTweenInfo
	local uDim = UDim2.new(
		basePosition.X.Scale,
		basePosition.X.Offset,
		basePosition.Y.Scale + settings.bobHeight,
		basePosition.Y.Offset
	)
	local uDim2 = UDim2.new(
		basePosition.X.Scale,
		basePosition.X.Offset,
		basePosition.Y.Scale - settings.bobHeight,
		basePosition.Y.Offset
	)
	self.bobThread = task.spawn(function()
		while true do
			tweenHelpers.playTween(frame, bobTweenInfo, {
				Position = uDim
			})
			task.wait(bobTweenInfo.Time)
			tweenHelpers.playTween(frame, bobTweenInfo, {
				Position = uDim2
			})
			task.wait(bobTweenInfo.Time)
		end
	end)
	local pulseTweenInfo = settings.pulseTweenInfo
	local size = scaleUDim2(self.baseSize, 1 + settings.pulseAmount) -- equivalent call inferred; original call site unknown
	local size2 = scaleUDim2(self.baseSize, 1 - settings.pulseAmount) -- equivalent call inferred; original call site unknown
	self.pulseThread = task.spawn(function()
		while true do
			tweenHelpers.playTween(frame, pulseTweenInfo, {
				Size = size
			})
			task.wait(pulseTweenInfo.Time)
			tweenHelpers.playTween(frame, pulseTweenInfo, {
				Size = size2
			})
			task.wait(pulseTweenInfo.Time)
		end
	end)
end

return BrushaSignature