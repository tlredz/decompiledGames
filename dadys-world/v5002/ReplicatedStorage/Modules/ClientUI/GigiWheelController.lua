local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Audio = require(ReplicatedStorage.SharedUtils.Audio)
local GigiWheelController = {}
local config = {
	SliceCount = 16,
	QuadrantLeadIndex = 9,
	PointerAngle = -45,
	HiddenPosition = UDim2.new(1, 0, 2, 0),
	ShownPosition = UDim2.new(1, 0, 1, 0),
	SlideInDuration = 0.35,
	SlideOutDuration = 0.35,
	SlideEasingStyle = Enum.EasingStyle.Back,
	SpinDuration = 2,
	SpinTurns = 3,
	SpinEasingStyle = Enum.EasingStyle.Quint,
	SpinEasingDirection = Enum.EasingDirection.Out,
	FlipperKickRotation = -30,
	FlipperReturnSpeed = 14,
	CelebrateDuration = 1,
	CelebratePulses = 3,
	CelebrateScale = 1.1,
	ClickSound = "Sounds.Toon.Gigi.Ability.Click4",
	PulseSound = "Sounds.Toon.Gigi.Ability.Pulse",
	FallbackIcon = ""
}
GigiWheelController.Config = config
local v2 = nil
local renderSteppedConnection = nil
local v3 = {}
local sizesByIndexLabel = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function sliceSize()
	return 360 / config.SliceCount
end

-- equivalent calls inferred from this helper; original call sites unknown
local function sliceAngle(p)
	local v4 = sliceSize() -- equivalent call inferred; original call site unknown
	return -(v4 / 2) - (p - config.QuadrantLeadIndex) * v4
end

-- equivalent calls inferred from this helper; original call sites unknown
local function landingRotation(p)
	local v4 = (config.PointerAngle - sliceAngle(p)) % 360
	return config.SpinTurns * 360 + v4
end

local function getGui(p)
	local localPlayer = Players.LocalPlayer

	if not localPlayer then
		return nil
	end

	local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")

	if not playerGui then
		return nil
	end

	local gigiAbilityUI

	if p then
		gigiAbilityUI = playerGui:WaitForChild("GigiAbilityUI", p)
	else
		gigiAbilityUI = playerGui:FindFirstChild("GigiAbilityUI")
	end

	if not gigiAbilityUI then
		return nil
	end

	local bottomRightCorner = gigiAbilityUI:FindFirstChild("BottomRightCorner")
	local wheel = bottomRightCorner and bottomRightCorner:FindFirstChild("Wheel")
	local flipper = bottomRightCorner and bottomRightCorner:FindFirstChild("Flipper")

	if bottomRightCorner and wheel and flipper then
		return {
			screenGui = gigiAbilityUI,
			corner = bottomRightCorner,
			wheel = wheel,
			flipper = flipper
		}
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getIndexLabel(instance, p)
	return instance:FindFirstChild("Index" .. p)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function resolveIcon(p)
	local child = ReplicatedStorage.ItemModules:FindFirstChild((tostring(p)))

	if not child then
		return config.FallbackIcon
	end

	local success, result = pcall(require, child)

	if success and type(result) == "table" then
		return result.Icon or config.FallbackIcon
	end

	return config.FallbackIcon
end

local function trackTween(object)
	table.insert(v3, object)
	object:Play()
	return object
end

local function stopTweens()
	for _, v4 in ipairs(v3) do
		local v5 = v4
		pcall(function()
			v5:Cancel()
		end)
	end

	table.clear(v3)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopRenderLoop()
	if renderSteppedConnection then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	end
end

local function describeGuiObject(p, image)
	local v4 = nil

	for i, child in ipairs(image.Parent:GetChildren()) do
		if child ~= image then
			continue
		end

		v4 = i
		break
	end

	local v6 = string.format(
		"[GigiWheel] %s abs pos=(%.0f, %.0f) size=(%.0f, %.0f) rot=%.1f z=%d childOrder=%s visible=%s",
		p,
		image.AbsolutePosition.X,
		image.AbsolutePosition.Y,
		image.AbsoluteSize.X,
		image.AbsoluteSize.Y,
		image.AbsoluteRotation,
		image.ZIndex,
		tostring(v4),
		(tostring(image.Visible))
	)

	if image:IsA("ImageLabel") then
		v6 ..= string.format(
			" image=%s loaded=%s transparency=%.2f",
			image.Image,
			tostring(image.IsLoaded),
			image.ImageTransparency
		)
	end

	print(v6)
end

local function logLayout(_) end

local function scaledSize(p, p2)
	return UDim2.new(p.X.Scale * p2, p.X.Offset * p2, p.Y.Scale * p2, p.Y.Offset * p2)
end

local function levelIcons(wheel, rotation)
	for i = 1, config.SliceCount do
		local indexLabel = getIndexLabel(wheel, i) -- equivalent call inferred; original call site unknown

		if indexLabel then
			indexLabel.Rotation = -rotation
		end
	end
end

local function resetWheel(gui)
	stopTweens()
	stopRenderLoop() -- equivalent call inferred; original call site unknown
	gui.wheel.Rotation = 0
	gui.flipper.Rotation = 0
	gui.corner.Position = config.HiddenPosition
	gui.screenGui.Enabled = false

	for k, size in pairs(sizesByIndexLabel) do
		if k.Parent then
			k.Size = size
		end
	end

	table.clear(sizesByIndexLabel)
	local wheel = gui.wheel

	for i = 1, config.SliceCount do
		local indexLabel = getIndexLabel(wheel, i) -- equivalent call inferred; original call site unknown

		if indexLabel then
			indexLabel.Rotation = -0
		end
	end
end

local function populate(gui, entries)
	for i = 1, config.SliceCount do
		local indexLabel = getIndexLabel(gui.wheel, i) -- equivalent call inferred; original call site unknown

		if not indexLabel then
			continue
		end

		local uICorner = indexLabel:FindFirstChildOfClass("UICorner")

		if uICorner then
			uICorner:Destroy()
		end

		local icon = resolveIcon(entries[i]) -- equivalent call inferred; original call site unknown
		indexLabel.Image = icon
		indexLabel.Rotation = 0
		sizesByIndexLabel[indexLabel] = indexLabel.Size
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function startRenderLoop(gui)
	local v4 = 0
	local flipperKickRotation = 0
	renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
		local rotation = gui.wheel.Rotation
		levelIcons(gui.wheel, rotation)
		local v5 = math.floor(rotation / (360 / config.SliceCount))

		if v4 < v5 then
			v4 = v5
			flipperKickRotation = config.FlipperKickRotation

			if config.ClickSound then
				Audio:Play(config.ClickSound)
			end
		end

		flipperKickRotation += (0 - flipperKickRotation) * math.min(dt * config.FlipperReturnSpeed, 1)
		gui.flipper.Rotation = flipperKickRotation
	end)
end

local function celebrate(gui, p)
	local indexLabel = getIndexLabel(gui.wheel, p) -- equivalent call inferred; original call site unknown

	if not indexLabel then
		return
	end

	local size = sizesByIndexLabel[indexLabel] or indexLabel.Size
	local v5 = config.CelebrateDuration / (config.CelebratePulses * 2)

	if config.PulseSound then
		Audio:Play(config.PulseSound)
	end

	local tweenInfo = TweenInfo.new(
		v5,
		Enum.EasingStyle.Quad,
		Enum.EasingDirection.InOut,
		config.CelebratePulses - 1,
		true
	)
	local celebrateScale = config.CelebrateScale
	local v8 = TweenService:Create(indexLabel, tweenInfo, {
		Size = UDim2.new(
			size.X.Scale * celebrateScale,
			size.X.Offset * celebrateScale,
			size.Y.Scale * celebrateScale,
			size.Y.Offset * celebrateScale
		)
	})
	table.insert(v3, v8)
	v8:Play()
	task.wait(config.CelebrateDuration)
	indexLabel.Size = size
end

function GigiWheelController.getSequenceDuration()
	return config.SlideInDuration + config.SpinDuration + config.CelebrateDuration + config.SlideOutDuration
end

function GigiWheelController.getSpinEndOffset()
	return config.SlideInDuration + config.SpinDuration
end

function GigiWheelController.previewIndex(p)
	local gui = getGui()

	if not gui then
		warn("[GigiWheel] GigiAbilityUI not found — cast the ability once so the server provisions it")
		return
	end

	stopTweens()
	stopRenderLoop() -- equivalent call inferred; original call site unknown
	gui.screenGui.Enabled = true
	gui.corner.Position = config.ShownPosition
	local wheel = gui.wheel
	wheel.Rotation = landingRotation(p) % 360
	gui.flipper.Rotation = 0
	levelIcons(gui.wheel, gui.wheel.Rotation)
end

function GigiWheelController.play(p)
	if type(p) ~= "table" or type(p.Entries) ~= "table" then
		warn("[GigiWheel] Malformed payload; skipping the spin")
		return
	end

	local v4 = {}
	v2 = v4

	local function cancelled()
		return v2 ~= v4
	end

	local gui = getGui(5)

	if v2 ~= v4 then
		return
	end

	if gui then
		local v5 = math.clamp(tonumber(p.WinningIndex) or 1, 1, config.SliceCount)
		resetWheel(gui)
		populate(gui, p.Entries)
		gui.corner.Position = config.HiddenPosition
		gui.screenGui.Enabled = true
		local tween = TweenService:Create(
			gui.corner,
			TweenInfo.new(config.SlideInDuration, config.SlideEasingStyle, Enum.EasingDirection.Out),
			{
				Position = config.ShownPosition
			}
		)
		table.insert(v3, tween)
		tween:Play()
		task.wait(config.SlideInDuration)

		if v2 ~= v4 then
			return
		end

		startRenderLoop(gui) -- equivalent call inferred; original call site unknown
		local v8 = TweenService:Create(
			gui.wheel,
			TweenInfo.new(config.SpinDuration, config.SpinEasingStyle, config.SpinEasingDirection),
			{
				Rotation = landingRotation(v5)
			}
		)
		table.insert(v3, v8)
		v8:Play()
		task.wait(config.SpinDuration)

		if v2 ~= v4 then
			return
		end

		stopRenderLoop() -- equivalent call inferred; original call site unknown
		local tween2 = TweenService:Create(
			gui.flipper,
			TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				Rotation = 0
			}
		)
		table.insert(v3, tween2)
		tween2:Play()
		celebrate(gui, v5)

		if v2 ~= v4 then
			return
		end

		local tween3 = TweenService:Create(
			gui.corner,
			TweenInfo.new(config.SlideOutDuration, config.SlideEasingStyle, Enum.EasingDirection.In),
			{
				Position = config.HiddenPosition
			}
		)
		table.insert(v3, tween3)
		tween3:Play()
		task.wait(config.SlideOutDuration)

		if v2 ~= v4 then
			return
		end

		resetWheel(gui)
		v2 = nil
	else
		warn("[GigiWheel] GigiAbilityUI not found; skipping the spin")
		v2 = nil
	end
end

function GigiWheelController.cancel()
	if not v2 then
		return
	end

	v2 = nil
	local gui = getGui()

	if gui then
		resetWheel(gui)
	end
end

function GigiWheelController.ClientAbility(_, _, p)
	if type(p) == "table" and p.Cancel then
		GigiWheelController.cancel()
	else
		task.spawn(GigiWheelController.play, p)
	end
end

return GigiWheelController