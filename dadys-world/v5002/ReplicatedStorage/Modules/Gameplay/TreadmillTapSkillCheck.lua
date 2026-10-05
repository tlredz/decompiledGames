local createVector = vector.create
local TreadmillTapSkillCheck = {}
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local InputService = require(ReplicatedStorage.SharedUtils.InputService)
local RunService = game:GetService("RunService")
game:GetService("Players")
local SoundService = game:GetService("SoundService")
require(script.Parent.CircleSkillCheckHandler)
local SkillCheckTouchButton = require(script.Parent.SkillCheckTouchButton)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Audio = require(ReplicatedStorage2.SharedUtils.Audio)
local v = nil
local sharedUtils = ReplicatedStorage2:FindFirstChild("SharedUtils")

if sharedUtils and sharedUtils:FindFirstChild("HapticEffectsController") then
	local success, hapticEffectsController = pcall(require, sharedUtils.HapticEffectsController)

	if success then
		v = hapticEffectsController
	end
end

local SoundPool = require(script.Parent.Parent.Audio.SoundPool)
local _ = SoundPool.SoundPool
local soundPoolManager = SoundPool.SoundPoolManager
TreadmillTapSkillCheck.ActiveSkillCheck = nil
local v2 = {
	EMPTY = Color3.fromRGB(50, 50, 50),
	FILL_START = Color3.fromRGB(0, 100, 150),
	FILL_END = Color3.fromRGB(100, 200, 255)
}

local function createSound(soundId, value, value2)
	local sound = Instance.new("Sound")
	sound.SoundId = soundId
	sound.Volume = value or 0.5
	sound.Pitch = value2 or 1
	sound.Parent = SoundService
	return sound
end

local sound = Instance.new("Sound")
sound.SoundId = "rbxasset://sounds/electronicpingshort.wav"
sound.Volume = 0.4
sound.Pitch = 1.3
sound.Parent = SoundService
local pools = {}

for k, v4 in pairs({
	tap = sound
}) do
	local v5 = (k == "tap" or k == "tick") and 15 or 5
	pools[k] = soundPoolManager:GetPool("TreadmillTap_" .. k, v4, v5)
end

local function getRequiredTaps(p)
	if p <= 63 then
		return 8
	end

	if p <= 125 then
		return 7
	end

	if p <= 188 then
		return 6
	end

	if p <= 250 then
		return 5
	end

	return 4
end

local function createSweatDrops(instance)
	local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
	local drops = ReplicatedStorage3:FindFirstChild("Parts") and ReplicatedStorage3.Parts:FindFirstChild("Drops")
	local particleEmitter = drops and drops:FindFirstChildOfClass("ParticleEmitter")
	local v4

	if particleEmitter then
		v4 = particleEmitter:Clone()
	else
		v4 = Instance.new("ParticleEmitter")
		v4.Name = "SweatDrops"
		v4.Texture = "rbxasset://textures/particles/sparkles_main.dds"
		v4.Rate = 5
		v4.Lifetime = NumberRange.new(0.5, 1)
		v4.VelocityInheritance = 0.2
		v4.EmissionDirection = Enum.NormalId.Top
		v4.Speed = NumberRange.new(2, 4)
		v4.SpreadAngle = Vector2.new(15, 15)
		v4.Color = ColorSequence.new(Color3.fromRGB(173, 216, 230))
		v4.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.3),
			NumberSequenceKeypoint.new(0.5, 0.5),
			NumberSequenceKeypoint.new(1, 0.1)
		})
	end

	local head = instance:FindFirstChild("Head")
	local parent

	if head then
		parent = head:FindFirstChild("HatAttachment") or head:FindFirstChild("HairAttachment") or head:FindFirstChild("FaceFrontAttachment") or head:FindFirstChild("Attachment")

		if not parent then
			parent = Instance.new("Attachment")
			parent.Name = "TreadmillParticleAttachment"
			parent.Position = createVector(0, 0.5, 0)
			parent.Parent = head
		end
	else
		local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart") or instance.PrimaryPart

		if not humanoidRootPart then
			warn("[TreadmillTapSkillCheck] No suitable parent found for particles")
			return nil
		end

		parent = humanoidRootPart:FindFirstChild("RootAttachment") or humanoidRootPart:FindFirstChild("SweatDropAttachment")

		if not parent then
			parent = Instance.new("Attachment")
			parent.Name = "SweatDropAttachment"
			parent.Position = createVector(0, 2, 0)
			parent.Parent = humanoidRootPart
		end
	end

	v4.Parent = parent
	v4.Enabled = true
	v4:Emit(20)
	return v4
end

local function getOrCreateTapUI(parent)
	local v4 = parent:FindFirstChild("TreadmillTapSkillCheckGui")

	if v4 then
		return v4
	end

	v4 = Instance.new("ScreenGui")
	v4.Name = "TreadmillTapSkillCheckGui"
	v4.ResetOnSpawn = false
	v4.DisplayOrder = 10
	v4.Parent = parent
	return v4
end

local function createIchorDropUI(playerGui, p)
	local IMAGE_ID = "rbxassetid://95476818934749"
	local v4 = playerGui:FindFirstChild("TreadmillTapSkillCheckGui")

	if not v4 then
		v4 = Instance.new("ScreenGui")
		v4.Name = "TreadmillTapSkillCheckGui"
		v4.ResetOnSpawn = false
		v4.DisplayOrder = 10
		v4.Parent = playerGui
	end

	v4:ClearAllChildren()
	local isTouchOnly = InputService:IsTouchOnly()
	local v5 = isTouchOnly and 173 or 230
	local frame = Instance.new("Frame")
	frame.Name = "TapSkillCheckFrame"
	frame.Size = UDim2.new(0, v5, 0, v5 * 1.3)
	frame.Position = UDim2.new(0.5, 0, isTouchOnly and 0.35 or 0.45, 0)
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.BackgroundTransparency = 1
	frame.Visible = false
	frame.Parent = v4
	local frame2 = Instance.new("Frame")
	frame2.Name = "Container"
	frame2.Size = UDim2.new(1, 0, 1, 0)
	frame2.BackgroundTransparency = 1
	frame2.Parent = frame
	local frame3 = Instance.new("Frame")
	frame3.Name = "DropContainer"
	frame3.Size = UDim2.new(0.65, 0, 0.65, 0)
	frame3.Position = UDim2.new(0.5, 0, 0.32, 0)
	frame3.AnchorPoint = Vector2.new(0.5, 0.5)
	frame3.BackgroundTransparency = 1
	frame3.Parent = frame2
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = "OutlineDrop"
	imageLabel.Size = UDim2.new(1.2, 0, 1.2, 0)
	imageLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
	imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	imageLabel.Image = IMAGE_ID
	imageLabel.ImageColor3 = Color3.fromRGB(255, 255, 255)
	imageLabel.BackgroundTransparency = 1
	imageLabel.ScaleType = Enum.ScaleType.Fit
	imageLabel.ZIndex = 4
	imageLabel.Parent = frame3
	local imageLabel2 = Instance.new("ImageLabel")
	imageLabel2.Name = "BackgroundDrop"
	imageLabel2.Size = UDim2.new(1, 0, 1, 0)
	imageLabel2.Position = UDim2.new(0.5, 0, 0.5, 0)
	imageLabel2.AnchorPoint = Vector2.new(0.5, 0.5)
	imageLabel2.Image = IMAGE_ID
	imageLabel2.ImageColor3 = v2.EMPTY
	imageLabel2.BackgroundTransparency = 1
	imageLabel2.ScaleType = Enum.ScaleType.Fit
	imageLabel2.ZIndex = 5
	imageLabel2.Parent = frame3
	local imageLabel3 = Instance.new("ImageLabel")
	imageLabel3.Name = "FillingDrop"
	imageLabel3.Size = UDim2.new(1, 0, 1, 0)
	imageLabel3.Position = UDim2.new(0.5, 0, 0.5, 0)
	imageLabel3.AnchorPoint = Vector2.new(0.5, 0.5)
	imageLabel3.Image = IMAGE_ID
	imageLabel3.ImageColor3 = v2.FILL_START
	imageLabel3.BackgroundTransparency = 1
	imageLabel3.ScaleType = Enum.ScaleType.Fit
	imageLabel3.ZIndex = 6
	imageLabel3.Parent = frame3
	local uIGradient = Instance.new("UIGradient")
	uIGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, v2.EMPTY),
		ColorSequenceKeypoint.new(0.999, v2.EMPTY),
		ColorSequenceKeypoint.new(1, v2.FILL_START)
	})
	uIGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.999, 1),
		NumberSequenceKeypoint.new(1, 0)
	})
	uIGradient.Rotation = 90
	uIGradient.Parent = imageLabel3
	local numberValue = Instance.new("NumberValue")
	numberValue.Name = "FillValue"
	numberValue.Value = 0
	numberValue.Parent = imageLabel3
	local frame4 = Instance.new("Frame")
	frame4.Name = "Timer"
	frame4.Size = UDim2.new(0.65, 0, 0.05, 0)
	frame4.Position = UDim2.new(0.5, 0, 0.75, 0)
	frame4.AnchorPoint = Vector2.new(0.5, 0.5)
	frame4.BackgroundTransparency = 1
	frame4.BorderSizePixel = 0
	frame4.ZIndex = 7
	frame4.Parent = frame2
	local imageLabel4 = Instance.new("ImageLabel")
	imageLabel4.Name = "Background"
	imageLabel4.Size = UDim2.new(1, 0, 1, 0)
	imageLabel4.Position = UDim2.new(0, 0, 0, 0)
	imageLabel4.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	imageLabel4.ImageColor3 = Color3.fromRGB(255, 255, 255)
	imageLabel4.BackgroundTransparency = 1
	imageLabel4.BorderSizePixel = 0
	imageLabel4.Image = "rbxassetid://73423191314763"
	imageLabel4.ScaleType = Enum.ScaleType.Stretch
	imageLabel4.ImageTransparency = 0
	imageLabel4.ZIndex = 8
	imageLabel4.Parent = frame4
	local imageLabel5 = Instance.new("ImageLabel")
	imageLabel5.Name = "TimeLeft"
	imageLabel5.Size = UDim2.new(1, 0, 1, 0)
	imageLabel5.Position = UDim2.new(0, 0, 0, 0)
	imageLabel5.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	imageLabel5.ImageColor3 = Color3.fromRGB(255, 255, 255)
	imageLabel5.BackgroundTransparency = 1
	imageLabel5.BorderSizePixel = 0
	imageLabel5.Image = "rbxassetid://93238691527930"
	imageLabel5.ScaleType = Enum.ScaleType.Stretch
	imageLabel5.ImageTransparency = 0
	imageLabel5.ZIndex = 9
	imageLabel5.Parent = frame4
	local uIGradient2 = Instance.new("UIGradient")
	uIGradient2.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(200, 200, 200)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(160, 160, 160)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 120, 120))
	})
	uIGradient2.Transparency = NumberSequence.new(0)
	uIGradient2.Rotation = -90
	uIGradient2.Parent = imageLabel5
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "TapCounter"
	textLabel.Size = UDim2.new(0.8, 0, 0.12, 0)
	textLabel.Position = UDim2.new(0.5, 0, 0.92, 0)
	textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	textLabel.BackgroundTransparency = 1
	textLabel.Text = "0/" .. p
	textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	textLabel.TextScaled = true
	textLabel.Font = Enum.Font.SourceSansBold
	textLabel.TextStrokeTransparency = 0
	textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	textLabel.TextTransparency = 0
	textLabel.ZIndex = 15
	textLabel.Parent = frame2
	local textButton = Instance.new("TextButton")
	textButton.Name = "TapButton"
	textButton.Size = UDim2.new(1, 20, 1, 20)
	textButton.Position = UDim2.new(0.5, 0, 0.35, 0)
	textButton.AnchorPoint = Vector2.new(0.5, 0.5)
	textButton.BackgroundTransparency = 1
	textButton.Text = ""
	textButton.ZIndex = 10
	textButton.AutoButtonColor = false
	textButton.Parent = frame2
	local uIStroke = Instance.new("UIStroke")
	uIStroke.Color = Color3.fromRGB(100, 200, 255)
	uIStroke.Thickness = 4
	uIStroke.Transparency = 1
	uIStroke.Parent = textButton
	local uICorner = Instance.new("UICorner")
	uICorner.CornerRadius = UDim.new(0.3, 0)
	uICorner.Parent = textButton

	local function animateToFillLevel(value)
		local v6 = 1 - math.clamp(value, 0, 1)
		local colorSequence = ColorSequence.new({
			ColorSequenceKeypoint.new(0, v2.EMPTY),
			ColorSequenceKeypoint.new(math.max(0, v6 - 0.001), v2.EMPTY),
			ColorSequenceKeypoint.new(v6, v2.FILL_START),
			ColorSequenceKeypoint.new(1, v2.FILL_END)
		})
		local numberSequence = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(math.max(0, v6 - 0.001), 1),
			NumberSequenceKeypoint.new(v6, 0),
			NumberSequenceKeypoint.new(1, 0)
		})
		uIGradient.Color = colorSequence
		uIGradient.Transparency = numberSequence
	end

	return {
		GUI = v4,
		Frame = frame,
		Container = frame2,
		DropContainer = frame3,
		TapButton = textButton,
		TapCounter = textLabel,
		FillValue = numberValue,
		AnimateToFillLevel = animateToFillLevel,
		FillingDrop = imageLabel3,
		BackgroundDrop = imageLabel2,
		OutlineDrop = imageLabel,
		TimerBarContainer = frame4,
		TimerBackground = imageLabel4,
		TimerBarFill = imageLabel5,
		Outline = uIStroke
	}
end

function TreadmillTapSkillCheck.HandleSkillCheck(player, p, text, p2)
	if TreadmillTapSkillCheck.ActiveSkillCheck then
		warn("[TreadmillTapSkillCheck] Skill check already active, forcing cleanup first")
		TreadmillTapSkillCheck.CleanUp()
	end

	local character = player.Character

	if not character then
		warn("[TreadmillTapSkillCheck] No character found")
		return false
	end

	TreadmillTapSkillCheck.ActiveSkillCheck = {
		forceStop = function() end
	}
	local playerGui = player:WaitForChild("PlayerGui")
	local screenGui = playerGui:WaitForChild("ScreenGui")
	local skillCheck = screenGui and screenGui:FindFirstChild("SkillCheck")
	local calibrate = screenGui and screenGui:FindFirstChild("Menu") and screenGui.Menu:FindFirstChild("Calibrate")
	local spaceBarPromptText = screenGui and screenGui:FindFirstChild("Menu") and screenGui.Menu:FindFirstChild("SpaceBarPromptText")
	local correct = screenGui and screenGui:FindFirstChild("Correct")
	local pitch

	if correct then
		pitch = correct.Pitch or nil
	else
		pitch = nil
	end

	local boundarySize = p.boundarySize or 188
	local v4

	if boundarySize >= 250 then
		v4 = 4
	elseif boundarySize >= 200 then
		v4 = 5
	elseif boundarySize >= 150 then
		v4 = 6
	elseif boundarySize >= 120 then
		v4 = 4
	elseif boundarySize >= 100 then
		v4 = 7
	else
		local _ = boundarySize >= 50
		v4 = 8
	end

	local ichorDropUI = createIchorDropUI(playerGui, v4)

	if not ichorDropUI then
		warn("[TreadmillTapSkillCheck] Failed to create UI")
		return false
	end

	local position

	if calibrate then
		position = calibrate.Position
		calibrate.Visible = true
		InputService:IsTouchOnly()
	else
		position = nil
	end

	if spaceBarPromptText then
		spaceBarPromptText.Visible = true
		spaceBarPromptText.TextTransparency = 0
		spaceBarPromptText.TextStrokeTransparency = 0
	end

	Audio:PlayOne("Sounds.UI.SkillCheck.SkillCheck")
	ichorDropUI.Frame.Visible = true
	local size = ichorDropUI.Frame.Size
	ichorDropUI.Frame.Size = UDim2.new(0, 0, 0, 0)
	TweenService:Create(ichorDropUI.Frame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = size
	}):Play()
	local count = 0
	local flag = true
	local connections = {}
	local v6 = false
	local flag2 = false
	local messageFadeTask = nil
	local skillCheckMessage = screenGui and screenGui:FindFirstChild("Menu") and screenGui.Menu:FindFirstChild("SkillCheckMessage")
	TreadmillTapSkillCheck.ActiveSkillCheck = {
		ui = ichorDropUI,
		sweatParticles = nil,
		connections = connections,
		character = character,
		calibrateButton = calibrate,
		originalButtonPosition = position,
		spaceBarPromptText = spaceBarPromptText,
		skillCheckMessage = skillCheckMessage,
		messageFadeTask = messageFadeTask,
		correctSound = correct,
		originalCorrectPitch = pitch,
		isActive = function()
			return flag
		end,
		forceStop = function()
			flag2 = true
			flag = false
			v6 = "forcestopped"

			if correct and pitch then
				correct.Pitch = pitch
			end
		end
	}

	local function handleTap()
		if not flag or v4 <= count then
			return
		end

		count += 1
		local v8 = count / v4

		if skillCheck and screenGui:FindFirstChild("Correct") then
			Audio:PlayOne("Sounds.UI.SkillCheck.Correct", {
				PlaybackSpeed = 1.2 + v8 * 0.8
			})
		elseif pools.tap then
			pools.tap:PlaySound({
				Pitch = 1.2 + v8 * 0.8,
				Volume = 0.5 + v8 * 0.3
			})
		end

		ichorDropUI.TapCounter.Text = count .. "/" .. v4
		ichorDropUI.AnimateToFillLevel(v8)
		TweenService:Create(ichorDropUI.Outline, TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Transparency = 0.3
		}):Play()
		task.spawn(function()
			task.wait(0.05)
			TweenService:Create(
				ichorDropUI.Outline,
				TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					Transparency = 1
				}
			):Play()
		end)
		local size2 = ichorDropUI.FillingDrop.Size
		local size3 = ichorDropUI.OutlineDrop.Size
		local uDim = UDim2.new(size2.X.Scale * 1.15, size2.X.Offset * 1.15, size2.Y.Scale * 1.15, size2.Y.Offset * 1.15)
		local uDim2 = UDim2.new(
			size3.X.Scale * 1.15,
			size3.X.Offset * 1.15,
			size3.Y.Scale * 1.15,
			size3.Y.Offset * 1.15
		)
		TweenService:Create(
			ichorDropUI.FillingDrop,
			TweenInfo.new(0.08, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
			{
				Size = uDim
			}
		):Play()
		TweenService:Create(
			ichorDropUI.BackgroundDrop,
			TweenInfo.new(0.08, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
			{
				Size = uDim
			}
		):Play()
		TweenService:Create(
			ichorDropUI.OutlineDrop,
			TweenInfo.new(0.08, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
			{
				Size = uDim2
			}
		):Play()
		task.spawn(function()
			task.wait(0.08)
			TweenService:Create(
				ichorDropUI.FillingDrop,
				TweenInfo.new(0.12, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
				{
					Size = size2
				}
			):Play()
			TweenService:Create(
				ichorDropUI.BackgroundDrop,
				TweenInfo.new(0.12, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
				{
					Size = size2
				}
			):Play()
			TweenService:Create(
				ichorDropUI.OutlineDrop,
				TweenInfo.new(0.12, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
				{
					Size = size3
				}
			):Play()
		end)
		local v9 = 100 + v8 * 155
		local color = Color3.fromRGB(v9, 200 + v8 * 55, 255)
		TweenService:Create(
			ichorDropUI.FillingDrop,
			TweenInfo.new(0.06, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				ImageColor3 = color
			}
		):Play()
		local color2 = Color3.fromRGB(200, 230, 255)
		TweenService:Create(
			ichorDropUI.OutlineDrop,
			TweenInfo.new(0.06, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				ImageColor3 = color2
			}
		):Play()
		task.spawn(function()
			task.wait(0.06)
			TweenService:Create(
				ichorDropUI.FillingDrop,
				TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					ImageColor3 = v2.FILL_START
				}
			):Play()
			TweenService:Create(
				ichorDropUI.OutlineDrop,
				TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					ImageColor3 = Color3.fromRGB(255, 255, 255)
				}
			):Play()
		end)
		local size4 = ichorDropUI.TapCounter.Size
		local uDim3 = UDim2.new(size4.X.Scale * 1.2, size4.X.Offset * 1.2, size4.Y.Scale * 1.2, size4.Y.Offset * 1.2)
		TweenService:Create(
			ichorDropUI.TapCounter,
			TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
			{
				Size = uDim3
			}
		):Play()
		task.spawn(function()
			task.wait(0.1)
			TweenService:Create(
				ichorDropUI.TapCounter,
				TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
				{
					Size = size4
				}
			):Play()
		end)
		task.spawn(function()
			for _ = 1, math.floor(v8 * 3) + 3 do
				local frame = Instance.new("Frame")
				frame.Size = UDim2.new(0, math.random(4, 8), 0, math.random(4, 8))
				frame.Position = UDim2.new(0.5, math.random(-20, 20), 0.35, math.random(-20, 20))
				frame.AnchorPoint = Vector2.new(0.5, 0.5)
				frame.BackgroundColor3 = color
				frame.BorderSizePixel = 0
				frame.ZIndex = 10
				frame.Parent = ichorDropUI.Container
				local uICorner = Instance.new("UICorner")
				uICorner.CornerRadius = UDim.new(0.5, 0)
				uICorner.Parent = frame
				local v10 = math.random() * 3.141592653589793 * 2
				local v11 = math.random(30, 60)
				local v12 = math.cos(v10) * v11
				local v13 = math.sin(v10) * v11
				TweenService:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Position = UDim2.new(0.5, v12, 0.35, v13),
					Size = UDim2.new(0, 0, 0, 0),
					BackgroundTransparency = 1
				}):Play()
				task.spawn(function()
					task.wait(0.4)
					frame:Destroy()
				end)
			end

			for _ = 1, math.floor(v8 * 2) + 2 do
				local imageLabel = Instance.new("ImageLabel")
				imageLabel.Size = UDim2.new(0, math.random(8, 12), 0, math.random(10, 14))
				imageLabel.Position = UDim2.new(0.5, math.random(-15, 15), 0.35, math.random(-10, 10))
				imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
				imageLabel.Image = "rbxassetid://95476818934749"
				imageLabel.ImageColor3 = v2.FILL_START
				imageLabel.ImageTransparency = 0.3
				imageLabel.BackgroundTransparency = 1
				imageLabel.ScaleType = Enum.ScaleType.Fit
				imageLabel.ZIndex = 9
				imageLabel.Parent = ichorDropUI.Container
				local v10 = math.random(40, 80)
				local v11 = math.random(-10, 10)
				TweenService:Create(imageLabel, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
					Position = UDim2.new(
						0.5,
						imageLabel.Position.X.Offset + v11,
						0.35,
						imageLabel.Position.Y.Offset + v10
					),
					ImageTransparency = 1,
					Size = UDim2.new(0, imageLabel.Size.X.Offset * 0.5, 0, imageLabel.Size.Y.Offset * 0.5)
				}):Play()
				task.spawn(function()
					task.wait(0.6)
					imageLabel:Destroy()
				end)
			end
		end)
		local position2 = ichorDropUI.Container.Position
		task.spawn(function()
			for _ = 1, 3 do
				local v10 = math.random(-3, 3)
				local v11 = math.random(-3, 3)
				TweenService:Create(ichorDropUI.Container, TweenInfo.new(0.03, Enum.EasingStyle.Linear), {
					Position = UDim2.new(
						position2.X.Scale,
						position2.X.Offset + v10,
						position2.Y.Scale,
						position2.Y.Offset + v11
					)
				}):Play()
				task.wait(0.03)
			end

			TweenService:Create(
				ichorDropUI.Container,
				TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					Position = position2
				}
			):Play()
		end)

		if not (v4 <= count) then
			return
		end

		flag = false
		v6 = true
		ichorDropUI.TapCounter.TextColor3 = Color3.fromRGB(0, 255, 0)
		ichorDropUI.TapCounter.Text = "SUCCESS!"

		if ichorDropUI.OutlineDrop then
			TweenService:Create(
				ichorDropUI.OutlineDrop,
				TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					ImageColor3 = Color3.fromRGB(200, 255, 200)
				}
			):Play()
		end
	end

	connections.tapConnection = SkillCheckTouchButton.bind(ichorDropUI.TapButton, function()
		return flag
	end, handleTap)
	local lastTime = tick()
	connections.timerConnection = RunService.Heartbeat:Connect(function()
		if not flag then
			return
		end

		local v8 = math.max(0, 3 - (tick() - lastTime)) / 3

		if ichorDropUI.TimerBarFill then
			ichorDropUI.TimerBarFill.Size = UDim2.new(v8, 0, 1, 0)
		end
	end)

	if calibrate then
		connections.calibrateConnection = SkillCheckTouchButton.bind(calibrate, function()
			return flag
		end, handleTap)
	end

	connections.inputConnection = InputService:OnAction("SkillCheckTap", function()
		if InputService:IsTyping() or not flag then
			return
		end

		handleTap()
	end)
	connections.timeoutConnection = task.spawn(function()
		task.wait(3)

		if flag then
			flag = false
			v6 = false
		end
	end)

	while flag do
		task.wait(0.1)
	end

	if flag2 then
		if messageFadeTask then
			task.cancel(messageFadeTask)
		end

		for _, connection in pairs(connections) do
			if not connection then
				continue
			end

			if typeof(connection) == "RBXScriptConnection" then
				connection:Disconnect()
			elseif typeof(connection) == "thread" then
				task.cancel(connection)
			elseif type(connection) == "table" and connection.Disconnect then
				connection:Disconnect()
			end
		end

		if calibrate then
			calibrate.Visible = false

			if position then
				calibrate.Position = position
			end
		end

		if spaceBarPromptText then
			spaceBarPromptText.Visible = false
		end

		if skillCheckMessage then
			skillCheckMessage.Visible = false
		end

		if ichorDropUI and ichorDropUI.GUI then
			ichorDropUI.GUI:Destroy()
		end

		if correct and pitch then
			correct.Pitch = pitch
		end

		TreadmillTapSkillCheck.ActiveSkillCheck = nil
		return "forcestopped"
	else
		if v6 == true then
			if v then
				v:Play("PulseSingle")
			end

			Audio:PlayOne("Sounds.UI.SkillCheck.Correct")
			Audio:PlayOne("Sounds.UI.SkillCheck.GoldAreaHit")

			if skillCheckMessage then
				if messageFadeTask then
					task.cancel(messageFadeTask)
				end

				skillCheckMessage.Text = "Great Job!"
				skillCheckMessage.Visible = true
				skillCheckMessage.TextTransparency = 0
				skillCheckMessage.TextStrokeTransparency = 0

				if skillCheckMessage:FindFirstChild("UIGradient") and skillCheckMessage:FindFirstChild("UIGradientWin") then
					skillCheckMessage.UIGradient.Enabled = false
					skillCheckMessage.UIGradientWin.Enabled = true
				end

				task.spawn(function()
					task.wait(1)

					if not flag2 then
						TweenService:Create(
							skillCheckMessage,
							TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								TextTransparency = 1,
								TextStrokeTransparency = 1
							}
						):Play()
						task.wait(1)

						if not flag2 then
							skillCheckMessage.Visible = false
						end
					end
				end)
			end

			task.wait(0.5)
		elseif v6 == false then
			if p2 then
				Audio:Play(p2, {
					Volume = 0.5,
					Parent = SoundService
				})
			else
				Audio:PlayOne("Sounds.UI.SkillCheck.Wrong")
			end

			if text then
				ichorDropUI.TapCounter.Text = "SILENCED!"
				ichorDropUI.TapCounter.TextColor3 = Color3.fromRGB(100, 255, 100)
			else
				ichorDropUI.TapCounter.Text = "FAILED!"
				ichorDropUI.TapCounter.TextColor3 = Color3.fromRGB(255, 0, 0)
			end

			if ichorDropUI.OutlineDrop then
				TweenService:Create(
					ichorDropUI.OutlineDrop,
					TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						ImageColor3 = Color3.fromRGB(255, 200, 200)
					}
				):Play()
			end

			if skillCheckMessage then
				if messageFadeTask then
					task.cancel(messageFadeTask)
				end

				if text then
					skillCheckMessage.Text = text
				else
					skillCheckMessage.Text = "Try Again!"
				end

				skillCheckMessage.Visible = true
				skillCheckMessage.TextTransparency = 0
				skillCheckMessage.TextStrokeTransparency = 0

				if skillCheckMessage:FindFirstChild("UIGradient") and skillCheckMessage:FindFirstChild("UIGradientWin") then
					skillCheckMessage.UIGradient.Enabled = true
					skillCheckMessage.UIGradientWin.Enabled = false
				end

				task.spawn(function()
					task.wait(1)

					if not flag2 then
						TweenService:Create(
							skillCheckMessage,
							TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								TextTransparency = 1,
								TextStrokeTransparency = 1
							}
						):Play()
						task.wait(1)

						if not flag2 then
							skillCheckMessage.Visible = false
						end
					end
				end)
			end

			task.wait(1)
		end

		task.spawn(function()
			if calibrate then
				calibrate.Visible = false

				if position then
					calibrate.Position = position
				end
			end

			if spaceBarPromptText then
				spaceBarPromptText.Visible = false
			end

			task.wait(0.4)
			local tween = TweenService:Create(
				ichorDropUI.Frame,
				TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
				{
					Size = UDim2.new(0, 0, 0, 0)
				}
			)
			tween:Play()
			tween.Completed:Wait()
			TreadmillTapSkillCheck.CleanUp()
		end)
		return v6
	end
end

function TreadmillTapSkillCheck.ForceStopSkillCheck()
	if TreadmillTapSkillCheck.ActiveSkillCheck and TreadmillTapSkillCheck.ActiveSkillCheck.forceStop then
		TreadmillTapSkillCheck.ActiveSkillCheck.forceStop()
	end
end

function TreadmillTapSkillCheck.CleanUp()
	TreadmillTapSkillCheck.ForceStopSkillCheck()

	if not TreadmillTapSkillCheck.ActiveSkillCheck then
		return
	end

	local activeSkillCheck = TreadmillTapSkillCheck.ActiveSkillCheck

	for _, connection in pairs(activeSkillCheck.connections) do
		if not connection then
			continue
		end

		if typeof(connection) == "RBXScriptConnection" then
			connection:Disconnect()
		elseif typeof(connection) == "thread" then
			task.cancel(connection)
		elseif type(connection) == "table" and connection.Disconnect then
			connection:Disconnect()
		end
	end

	if activeSkillCheck.calibrateButton then
		activeSkillCheck.calibrateButton.Visible = false

		if activeSkillCheck.originalButtonPosition then
			activeSkillCheck.calibrateButton.Position = activeSkillCheck.originalButtonPosition
		end
	end

	if activeSkillCheck.spaceBarPromptText then
		activeSkillCheck.spaceBarPromptText.Visible = false
	end

	if activeSkillCheck.ui and activeSkillCheck.ui.GUI then
		activeSkillCheck.ui.GUI:Destroy()
	end

	if activeSkillCheck.correctSound and activeSkillCheck.originalCorrectPitch then
		activeSkillCheck.correctSound.Pitch = activeSkillCheck.originalCorrectPitch
	end

	local character = activeSkillCheck.character

	if character then
		character:SetAttribute("TreadmillSkillCheckReady", nil)
	end

	TreadmillTapSkillCheck.ActiveSkillCheck = nil
end

return TreadmillTapSkillCheck