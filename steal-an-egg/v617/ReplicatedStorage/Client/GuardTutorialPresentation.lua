local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local ArrowPointer3D = require(ReplicatedStorage.Client.WorldFX.ArrowPointer3D)
local GUI = require(ReplicatedStorage.Client.GUI)
local Log = require(ReplicatedStorage.Packages.Log)
local MessageTyper = require(ReplicatedStorage.Client.UI.MessageTyper)
local TutorialBeam = require(ReplicatedStorage.Client.WorldFX.TutorialBeam)
local TutorialHighlightOverlay = require(script.TutorialHighlightOverlay)
local TutorialTapIndicator = require(script.TutorialTapIndicator)
local t = require(ReplicatedStorage.Packages.t)
local frozen = table.freeze({
	CROSSFADE_OUT = TweenInfo.new(0.02),
	CROSSFADE_IN = TweenInfo.new(0.02),
	STROKE_CROSSFADE_OUT = TweenInfo.new(0.02, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
	STROKE_CROSSFADE_IN = TweenInfo.new(0.02, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
	FILL = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	READY_SCALE = TweenInfo.new(0.45, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out, -1, true),
	READY_FLASH = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, -1, true),
	CLICK_PULSE = TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, -1, true)
})

-- equivalent calls inferred from this helper; original call sites unknown
local function wantsAnchorValue(part)
	local v

	if typeof(part) == "Vector3" then
		v = true
	elseif typeof(part) == "Instance" then
		v = part:IsA("BasePart")
	else
		v = false
	end

	assert(v, "a tutorial anchor has to be a BasePart or a Vector3")
end

local strict = t.strict(t.string)
local strict2 = t.strict(t.Color3)
local strict3 = t.strict(t.boolean)
local strict4 = t.strict(t.number)
local strict5 = t.strict(t.optional(t.number))
local strict6 = t.strict(t.instanceIsA("GuiButton"))
local strict7 = t.strict(t.instanceIsA("GuiObject"))
local strict8 = t.strict(t.instanceIsA("BasePart"))
local strict9 = t.strict(t.CFrame)
local strict10 = t.strict(t.optional(t.boolean))
local strict11 = t.strict(t.optional(t.UDim))
local strict12 = t.strict(t.optional(t.UDim2))
local v = Log.new()
local GuardTutorialPresentation = {}
GuardTutorialPresentation.__index = GuardTutorialPresentation
GuardTutorialPresentation.__class = "GuardTutorialPresentation"

local function expect(instance, className: string, p: string)
	assert(instance:IsA(className), (`{p} is not a {className}`))
	return instance
end

local function messageParts(state)
	local message = state.message

	if message then
		return message
	end

	local screenGui = GUI.TutorialInstructions()
	assert(screenGui:IsA("ScreenGui"), "TutorialInstructions is not a ScreenGui")
	local frame = screenGui.Frame
	assert(frame:IsA("Frame"), "TutorialInstructions.Frame is not a Frame")
	local textLabel = frame.TextLabel
	assert(textLabel:IsA("TextLabel"), "TutorialInstructions.Frame.TextLabel is not a TextLabel")
	local uIStroke = textLabel.UIStroke
	assert(uIStroke:IsA("UIStroke"), "the tutorial label stroke is not a UIStroke")
	local uIGradient = textLabel.UIGradient
	assert(uIGradient:IsA("UIGradient"), "the tutorial label gradient is not a UIGradient")
	local message2 = {
		animator = MessageTyper.new(textLabel),
		frame = frame,
		gradient = uIGradient,
		label = textLabel,
		screen = screenGui,
		stroke = uIStroke
	}
	state.message = message2

	if state.messageDefaults == nil then
		state.messageDefaults = {
			framePosition = frame.Position,
			strokeAlpha = textLabel.TextStrokeTransparency,
			textAlpha = textLabel.TextTransparency
		}
	end

	return message2
end

local function progressParts(p)
	local progress = p.progress

	if progress then
		return progress
	end

	local progression = messageParts(p).frame.Progression
	assert(progression:IsA("GuiObject"), "the progression frame is not a GuiObject")
	local fill = progression.Fill
	assert(fill:IsA("GuiObject"), "the progression fill is not a GuiObject")
	local readyLabel = progression.ReadyLabel
	assert(readyLabel:IsA("GuiObject"), "the ready label is not a GuiObject")
	local readyLabelWhite = readyLabel.ReadyLabelWhite
	assert(readyLabelWhite:IsA("TextLabel"), "the ready flash is not a TextLabel")
	local readyScale = readyLabel:FindFirstChildOfClass("UIScale")

	if readyScale == nil then
		readyScale = Instance.new("UIScale")
		readyScale.Parent = readyLabel
		p.ownsReadyScale = true
	end

	local progress2 = {
		fill = fill,
		frame = progression,
		ready = readyLabel,
		readyScale = readyScale,
		white = readyLabelWhite
	}
	p.progress = progress2
	return progress2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function resetMessageInk(p)
	local message = p.message
	local messageDefaults = p.messageDefaults

	if message == nil then
		return
	end

	message.label.TextTransparency = not messageDefaults and 0 or messageDefaults.textAlpha
	message.stroke.Transparency = 0
	message.label.TextStrokeTransparency = not messageDefaults and 1 or messageDefaults.strokeAlpha
end

local function stopTween(object)
	if object then
		object:Cancel()
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function beginClickPulse(uIScale)
	uIScale.Scale = 1
	local tween = TweenService:Create(uIScale, frozen.CLICK_PULSE, {
		Scale = 1.3
	})
	tween:Play()
	return tween
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopProgressPulse(state)
	local readyScaleTween = state.readyScaleTween

	if readyScaleTween then
		readyScaleTween:Cancel()
	end

	state.readyScaleTween = nil
	local readyWhiteTween = state.readyWhiteTween

	if readyWhiteTween then
		readyWhiteTween:Cancel()
	end

	state.readyWhiteTween = nil
end

local function setReadyPulse(state, data, flag: boolean)
	if flag then
		if state.readyScaleTween ~= nil and state.readyWhiteTween ~= nil then
			return
		end

		data.ready.Visible = true
		data.readyScale.Scale = 1
		data.white.TextTransparency = 1
		local tween = TweenService:Create(data.readyScale, frozen.READY_SCALE, {
			Scale = 1.2
		})
		local tween2 = TweenService:Create(data.white, frozen.READY_FLASH, {
			TextTransparency = 0
		})
		state.readyScaleTween = tween
		state.readyWhiteTween = tween2
		tween:Play()
		tween2:Play()
	else
		stopProgressPulse(state) -- equivalent call inferred; original call site unknown
		data.ready.Visible = false
		data.readyScale.Scale = 1
		data.white.TextTransparency = 1
	end
end

function GuardTutorialPresentation.new()
	return (setmetatable({
		arrow = nil,
		beam = nil,
		clickPart = nil,
		clickTween = nil,
		dropRingLater = nil,
		dropTapLater = nil,
		fillTween = nil,
		message = nil,
		messageDefaults = nil,
		ownsReadyScale = false,
		progress = nil,
		readyScaleTween = nil,
		readyWhiteTween = nil,
		screenClick = nil,
		screenClickTween = nil,
		transition = 0
	}, GuardTutorialPresentation))
end

function GuardTutorialPresentation:AnnounceTyped(p2: string, color: Color3)
	strict(p2)
	strict2(color)
	local v2 = messageParts(self)
	self.transition += 1
	resetMessageInk(self) -- equivalent call inferred; original call site unknown
	v2.screen.Enabled = true
	v2.animator:Type(p2, color)
end

function GuardTutorialPresentation:AnnounceNow(p2: string, color: Color3)
	strict(p2)
	strict2(color)
	local v2 = messageParts(self)
	self.transition += 1
	resetMessageInk(self) -- equivalent call inferred; original call site unknown
	v2.screen.Enabled = true
	v2.animator:ShowAll(p2, color)
end

function GuardTutorialPresentation:CrossfadeTo(text: string, textColor: Color3)
	strict(text)
	strict2(textColor)
	local v2 = messageParts(self)
	self.transition += 1
	local transition = self.transition
	v2.screen.Enabled = true
	v2.animator:Halt()

	local function fadeIn()
		if transition ~= self.transition then
			return
		end

		local messageDefaults = self.messageDefaults
		v2.label.RichText = true
		v2.label.Text = text
		v2.label.TextColor3 = textColor
		v2.label.MaxVisibleGraphemes = -1
		v2.label.TextTransparency = 1
		v2.label.TextStrokeTransparency = 1
		v2.stroke.Transparency = 1
		TweenService:Create(v2.stroke, frozen.STROKE_CROSSFADE_IN, {
			Transparency = 0
		}):Play()
		TweenService:Create(v2.label, frozen.CROSSFADE_IN, {
			TextTransparency = not messageDefaults and 0 or messageDefaults.textAlpha,
			TextStrokeTransparency = not messageDefaults and 1 or messageDefaults.strokeAlpha
		}):Play()
	end

	if v2.label.Text == "" then
		fadeIn()
		return
	end

	local tween = TweenService:Create(v2.label, frozen.CROSSFADE_OUT, {
		TextTransparency = 1,
		TextStrokeTransparency = 1
	})
	TweenService:Create(v2.stroke, frozen.STROKE_CROSSFADE_OUT, {
		Transparency = 1
	}):Play()
	tween.Completed:Connect(fadeIn)
	tween:Play()
end

function GuardTutorialPresentation.SetAnnounceGradient(p, enabled: boolean)
	strict3(enabled)
	local messageParts_2 = messageParts(p)
	messageParts_2.gradient.Enabled = enabled
end

function GuardTutorialPresentation.SetAnnounceHeight(p, p2: number?)
	strict5(p2)
	local v2 = messageParts(p)
	local messageDefaults = p.messageDefaults
	local framePosition

	if messageDefaults then
		framePosition = messageDefaults.framePosition
	else
		framePosition = v2.frame.Position
	end

	local frame = v2.frame

	if p2 ~= nil then
		framePosition = UDim2.new(framePosition.X.Scale, framePosition.X.Offset, p2, framePosition.Y.Offset)
	end

	frame.Position = framePosition
end

function GuardTutorialPresentation:DropAnnounce()
	self.transition += 1
	local message = self.message

	if message == nil then
		return
	end

	message.animator:Blank()
	message.label.Text = ""
	resetMessageInk(self) -- equivalent call inferred; original call site unknown
	local messageDefaults = self.messageDefaults

	if messageDefaults then
		message.frame.Position = messageDefaults.framePosition
	end

	message.gradient.Enabled = false
	message.screen.Enabled = false
end

function GuardTutorialPresentation:TrackSpeedGoal(value: number, flag: boolean)
	strict4(value)
	strict3(flag)
	local v2 = progressParts(self)
	v2.frame.Visible = true
	local fillTween = self.fillTween

	if fillTween then
		fillTween:Cancel()
	end

	local size = v2.fill.Size
	local uDim = UDim2.new(math.clamp(value, 0, 1), 0, size.Y.Scale, size.Y.Offset)
	local tween = TweenService:Create(v2.fill, frozen.FILL, {
		Size = uDim
	})
	self.fillTween = tween
	tween:Play()
	setReadyPulse(self, v2, flag)
end

function GuardTutorialPresentation:DropSpeedGoal()
	local fillTween = self.fillTween

	if fillTween then
		fillTween:Cancel()
	end

	self.fillTween = nil
	stopProgressPulse(self) -- equivalent call inferred; original call site unknown
	local progress = self.progress

	if progress == nil then
		return
	end

	local size = progress.fill.Size
	progress.fill.Size = UDim2.new(0, 0, size.Y.Scale, size.Y.Offset)
	progress.ready.Visible = false
	progress.readyScale.Scale = 1
	progress.white.TextTransparency = 1
	progress.frame.Visible = false
end

function GuardTutorialPresentation:PointBeamAt(part)
	wantsAnchorValue(part) -- equivalent call inferred; original call site unknown
	local beam = self.beam

	if beam == nil then
		self.beam = TutorialBeam.Attach(part)
	else
		TutorialBeam.Retarget(beam, part)
	end
end

function GuardTutorialPresentation:RetargetBeam(part)
	wantsAnchorValue(part) -- equivalent call inferred; original call site unknown
	local beam = self.beam

	if beam == nil then
		self.beam = TutorialBeam.Attach(part)
	else
		TutorialBeam.Retarget(beam, part)
	end
end

function GuardTutorialPresentation:DropBeam()
	local beam = self.beam

	if beam ~= nil then
		self.beam = nil
		TutorialBeam.Destroy(beam)
	end
end

function GuardTutorialPresentation:MarkTapTarget(p, flag: boolean?, udim: UDim?, udim2: UDim2?)
	strict6(p)
	strict10(flag)
	strict11(udim)
	strict12(udim2)
	self:DropTapTarget()
	self.dropTapLater = TutorialTapIndicator.Attach(p, flag, udim, udim2)
end

function GuardTutorialPresentation:MarkSurfaceTapTarget(instance, childName: string, flag: boolean?, udim: UDim?, udim2: UDim2?)
	strict8(instance)
	strict(childName)
	strict10(flag)
	strict11(udim)
	strict12(udim2)
	local v2 = nil

	for _, surfaceGui in instance:GetChildren() do
		if not surfaceGui:IsA("SurfaceGui") then
			continue
		end

		local button = surfaceGui:FindFirstChild(childName)

		if not (button ~= nil and button:IsA("GuiButton")) then
			continue
		end

		v2 = button
		break
	end

	self:DropTapTarget()

	if v2 == nil then
		return false
	end

	self.dropTapLater = TutorialTapIndicator.Attach(v2, flag, udim, udim2)
	return true
end

function GuardTutorialPresentation:DropTapTarget()
	local dropTapLater = self.dropTapLater

	if dropTapLater ~= nil then
		self.dropTapLater = nil
		dropTapLater()
	end
end

function GuardTutorialPresentation:PinWorldClickHint(cFrame: CFrame)
	strict9(cFrame)
	local clickPart = self.clickPart

	if clickPart ~= nil then
		clickPart.CFrame = cFrame
		return
	end

	local billboardTutorialClick = ReplicatedStorage.Assets.Billboards.BillboardTutorialClick
	assert(billboardTutorialClick:IsA("BasePart"), "Assets.Billboards.BillboardTutorialClick is not a BasePart")
	local clone = billboardTutorialClick:Clone()
	clone.CFrame = cFrame
	clone.Parent = workspace
	local billboardGui = clone.BillboardGui
	assert(billboardGui:IsA("BillboardGui"), "the click-hint billboard is not a BillboardGui")
	local image = billboardGui.Image
	assert(image:IsA("ImageLabel"), "the click-hint image is not a ImageLabel")
	local uIScale = image.UIScale
	assert(uIScale:IsA("UIScale"), "the click-hint scale is not a UIScale")
	self.clickPart = clone
	self.clickTween = beginClickPulse(uIScale)
end

function GuardTutorialPresentation:DropWorldClickHint()
	local clickTween = self.clickTween

	if clickTween then
		clickTween:Cancel()
	end

	self.clickTween = nil
	local clickPart = self.clickPart

	if clickPart ~= nil then
		clickPart:Destroy()
		self.clickPart = nil
	end
end

function GuardTutorialPresentation:SetScreenClickHint(flag: boolean)
	strict3(flag)
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	assert(playerGui:IsA("PlayerGui"), "LocalPlayer.PlayerGui is not a PlayerGui")
	local tutorialClick = playerGui:WaitForChild("TutorialClick")
	assert(tutorialClick:IsA("ScreenGui"), "PlayerGui.TutorialClick is not a ScreenGui")
	local image = tutorialClick.Image
	assert(image:IsA("ImageLabel"), "TutorialClick.Image is not a ImageLabel")
	local uIScale = image.UIScale
	assert(uIScale:IsA("UIScale"), "TutorialClick.Image.UIScale is not a UIScale")
	self.screenClick = tutorialClick

	if not flag then
		self:DropScreenClickHint()
		return
	end

	tutorialClick.Enabled = true

	if self.screenClickTween == nil then
		self.screenClickTween = beginClickPulse(uIScale)
	end
end

function GuardTutorialPresentation:DropScreenClickHint()
	local screenClickTween = self.screenClickTween

	if screenClickTween then
		screenClickTween:Cancel()
	end

	self.screenClickTween = nil
	local screenClick = self.screenClick

	if screenClick ~= nil then
		screenClick.Enabled = false
	end
end

function GuardTutorialPresentation:RingButton(p)
	strict7(p)
	self:DropRing()
	self.dropRingLater = TutorialHighlightOverlay.Attach(p)
end

function GuardTutorialPresentation:DropRing()
	local dropRingLater = self.dropRingLater

	if dropRingLater ~= nil then
		self.dropRingLater = nil
		dropRingLater()
	end
end

function GuardTutorialPresentation:PointArrowAt(part, part2, p)
	wantsAnchorValue(part) -- equivalent call inferred; original call site unknown
	wantsAnchorValue(part2) -- equivalent call inferred; original call site unknown
	assert(ArrowPointer3D.__types.OptionalConfig(p))
	self:DropArrow()
	local arrow = ArrowPointer3D.new(part, part2, p)
	arrow:Start()
	self.arrow = arrow
end

function GuardTutorialPresentation.RetargetArrow(p, part)
	wantsAnchorValue(part) -- equivalent call inferred; original call site unknown
	assert(p.arrow, "there is no tutorial arrow to retarget"):PointAt(part)
end

function GuardTutorialPresentation.RebaseArrow(p, part)
	wantsAnchorValue(part) -- equivalent call inferred; original call site unknown
	assert(p.arrow, "there is no tutorial arrow to rebase"):PointFrom(part)
end

function GuardTutorialPresentation:DropArrow()
	local arrow = self.arrow

	if arrow ~= nil then
		self.arrow = nil
		arrow:Destroy()
	end
end

function GuardTutorialPresentation:DropEverything()
	self:DropArrow()
	self:DropBeam()
	self:DropWorldClickHint()
	self:DropRing()
	self:DropTapTarget()
	self:DropScreenClickHint()
	self:DropSpeedGoal()
	self:DropAnnounce()
end

function GuardTutorialPresentation:Destroy()
	v:AtTrace():Log("Tearing down the guard tutorial presentation layer")
	self:DropEverything()
	local progress = self.progress

	if self.ownsReadyScale and progress ~= nil then
		progress.readyScale:Destroy()
		self.progress = nil
	end
end

return GuardTutorialPresentation