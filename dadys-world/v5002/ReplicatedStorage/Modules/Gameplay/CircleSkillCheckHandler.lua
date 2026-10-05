local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local InputService = require(ReplicatedStorage.SharedUtils.InputService)
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local SkillCheckTouchButton = require(script.Parent.SkillCheckTouchButton)
local SoundPool = require(script.Parent.Parent.Audio.SoundPool)
local _ = SoundPool.SoundPool
local soundPoolManager = SoundPool.SoundPoolManager
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

local CircleSkillCheckHandler = {
	ActiveSkillCheck = nil,
	DEFAULTS = {
		Core = {
			boundarySize = 150,
			boundaryModifier = 1,
			markerSpeed = 1.2,
			randomPosition = false,
			speedMode = "star",
			lineThicknessModifier = 1,
			hitTolerance = 3
		},
		Zones = {
			blackRatio = 0.225,
			yellowRatio = 0.075,
			greyRatio = 0.1,
			yellowReward = 3,
			greyReward = 1
		},
		Movement = {
			pattern = "none",
			amplitude = 150,
			speed = 2,
			radius = 100
		}
	}
}

local function applyConfigOverrides(state)
	local DEFAULTS = CircleSkillCheckHandler.DEFAULTS
	state.boundarySize = state.boundarySize or DEFAULTS.Core.boundarySize
	state.boundaryModifier = state.boundaryModifier or DEFAULTS.Core.boundaryModifier
	state.markerSpeed = state.markerSpeed or DEFAULTS.Core.markerSpeed
	state.randomPosition = state.randomPosition or DEFAULTS.Core.randomPosition
	state.speedMode = state.speedMode or DEFAULTS.Core.speedMode
	state.lineThicknessModifier = state.lineThicknessModifier or DEFAULTS.Core.lineThicknessModifier
	state.hitTolerance = state.hitTolerance or DEFAULTS.Core.hitTolerance
	state.sizeRatios = state.sizeRatios or {}
	state.sizeRatios.black = state.sizeRatios.black or DEFAULTS.Zones.blackRatio
	state.sizeRatios.yellow = state.sizeRatios.yellow or DEFAULTS.Zones.yellowRatio
	state.sizeRatios.grey = state.sizeRatios.grey or DEFAULTS.Zones.greyRatio
	state.circles = state.circles or {
		{
			reward = DEFAULTS.Zones.greyReward
		},
		{
			reward = DEFAULTS.Zones.yellowReward
		},
		{
			reward = 0
		}
	}
	state.movementPattern = state.movementPattern or DEFAULTS.Movement.pattern
	state.movementConfig = state.movementConfig or {}
	state.movementConfig.amplitude = state.movementConfig.amplitude or DEFAULTS.Movement.amplitude
	state.movementConfig.speed = state.movementConfig.speed or DEFAULTS.Movement.speed
	state.movementConfig.radius = state.movementConfig.radius or DEFAULTS.Movement.radius
	return state
end

local function getSkillCheckSpeed(p, p2)
	if p2 then
	end

	if p <= 63 then
		return 0.6
	end

	if p <= 125 then
		return 0.75
	end

	if p <= 188 then
		return 0.9
	end

	if p <= 250 then
		return 1.2
	end

	return 1.8
end

local function createSound(soundId, value, value2)
	local sound = Instance.new("Sound")
	sound.SoundId = soundId
	sound.Volume = value or 0.5
	sound.Pitch = value2 or 1
	sound.Parent = SoundService
	return sound
end

local sound = Instance.new("Sound")
sound.SoundId = "rbxasset://sounds/clickfast.wav"
sound.Volume = 0.2
sound.Pitch = 1.5
sound.Parent = SoundService
local pools = {}
local v3 = {
	horizontal = {
		name = "Horizontal",
		update = function(p, p2)
			local isTouchOnly = InputService:IsTouchOnly()
			local v4 = (p2.amplitude or 150) * (isTouchOnly and 0.5 or 0.8)
			local speed = p2.speed or 2
			return UDim2.new(0.5, math.sin(p * speed) * v4, isTouchOnly and 0.35 or 0.45, 0)
		end
	},
	vertical = {
		name = "Vertical",
		update = function(p, p2)
			local isTouchOnly = InputService:IsTouchOnly()
			local v4 = (p2.amplitude or 100) * (isTouchOnly and 0.4 or 0.7)
			local v5 = math.sin(p * (p2.speed or 2)) * v4
			return UDim2.new(0.5, 0, isTouchOnly and 0.3 or 0.45, v5)
		end
	},
	figure8 = {
		name = "Figure 8",
		update = function(p, p2)
			local isTouchOnly = InputService:IsTouchOnly()
			local v4 = (p2.amplitude or 120) * (isTouchOnly and 0.5 or 0.8)
			local speed = p2.speed or 1.5
			local v5 = math.sin(p * speed) * v4
			local v6 = math.sin(p * speed * 2) * v4 * (isTouchOnly and 0.2 or 0.4)
			return UDim2.new(0.5, v5, isTouchOnly and 0.3 or 0.45, v6)
		end
	},
	circle = {
		name = "Circle",
		update = function(p, p2)
			local isTouchOnly = InputService:IsTouchOnly()
			local v4 = (p2.radius or 100) * (isTouchOnly and 0.5 or 0.8)
			local speed = p2.speed or 2
			local v5 = math.cos(p * speed) * v4
			local v6 = math.sin(p * speed) * v4 * (isTouchOnly and 0.3 or 0.6)
			return UDim2.new(0.5, v5, isTouchOnly and 0.3 or 0.45, v6)
		end
	},
	diagonal = {
		name = "Diagonal",
		update = function(p, p2)
			local isTouchOnly = InputService:IsTouchOnly()
			local v4 = (p2.amplitude or 120) * (isTouchOnly and 0.5 or 0.8)
			local v5 = math.sin(p * (p2.speed or 2)) * v4
			return UDim2.new(0.5, v5, isTouchOnly and 0.3 or 0.45, v5 * (isTouchOnly and 0.2 or 0.5))
		end
	},
	random = {
		name = "Random",
		update = function(p, state)
			local isTouchOnly = InputService:IsTouchOnly()

			if not state.nextChange or state.nextChange < p then
				state.targetX = isTouchOnly and math.random(-75, 75) or math.random(-120, 120)
				state.targetY = isTouchOnly and math.random(-40, 20) or math.random(-60, 60)
				state.nextChange = p + math.random() * 2 + 1
			end

			local currentX = state.currentX or 0
			local currentY = state.currentY or 0
			state.currentX = currentX + (state.targetX - currentX) * 0.05
			state.currentY = currentY + (state.targetY - currentY) * 0.05
			return UDim2.new(0.5, state.currentX, isTouchOnly and 0.3 or 0.45, state.currentY)
		end
	}
}
local v4 = {
	Shrimpo = 63,
	Cosmo = 63,
	Bassie = 63,
	Blott = 63,
	Connie = 125,
	Flutter = 125,
	Glisten = 125,
	Scraps = 125,
	Coal = 125,
	Astro = 125,
	Sprout = 125,
	Flyte = 125,
	Boxten = 188,
	Yatta = 188,
	Cocoa = 188,
	Toodles = 188,
	Pebble = 188,
	Teagan = 188,
	Ginger = 188,
	Brightney = 188,
	Eggson = 188,
	Rudie = 188,
	Goob = 188,
	RazzleDazzle = 188,
	Rodger = 188,
	Poppy = 188,
	Tisha = 250,
	Bobette = 250,
	Vee = 250,
	Finn = 250,
	Looey = 250,
	Brusha = 250,
	Shelly = 313,
	Dandy = 313,
	Gigi = 313
}

for k, v5 in pairs({
	tick = sound
}) do
	local v6 = k == "tick" and 20 or 5
	pools[k] = soundPoolManager:GetPool("CircleSkillCheck_" .. k, v5, v6)
end

local v5 = {}

local function createParticle(parent, position, backgroundColor)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0, math.random(4, 8), 0, math.random(4, 8))
	frame.Position = position
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.BackgroundColor3 = backgroundColor
	frame.BorderSizePixel = 0
	frame.Parent = parent
	local uICorner = Instance.new("UICorner")
	uICorner.CornerRadius = UDim.new(0.5, 0)
	uICorner.Parent = frame
	local v6 = math.random() * 3.141592653589793 * 2
	local v7 = math.random(50, 150)
	local v8 = position.X.Offset + math.cos(v6) * v7
	local v9 = position.Y.Offset + math.sin(v6) * v7
	TweenService:Create(frame, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Position = UDim2.new(0.5, v8, 0.5, v9),
		Size = UDim2.new(0, 0, 0, 0),
		BackgroundTransparency = 1
	}):Play()
	task.wait(0.8)
	frame:Destroy()
end

local function createParticleBurst(container, uDim, color, p)
	for _ = 1, p do
		task.spawn(function()
			createParticle(container, uDim, color)
		end)
	end
end

local function getOrCreateUI(parent)
	local v6 = parent:FindFirstChild("CircleSkillCheckGui")

	if v6 then
		return v6
	end

	v6 = Instance.new("ScreenGui")
	v6.Name = "CircleSkillCheckGui"
	v6.ResetOnSpawn = false
	v6.DisplayOrder = 0
	v6.Parent = parent
	return v6
end

local function createCircleSkillCheckUI(playerGui, data)
	local v6 = playerGui:FindFirstChild("CircleSkillCheckGui")

	if not v6 then
		v6 = Instance.new("ScreenGui")
		v6.Name = "CircleSkillCheckGui"
		v6.ResetOnSpawn = false
		v6.DisplayOrder = 0
		v6.Parent = playerGui
	end

	v6:ClearAllChildren()
	local isTouchOnly = InputService:IsTouchOnly()
	local v7 = isTouchOnly and 140 or 280
	local boundarySize = data.boundarySize or 150
	local boundaryModifier = data.boundaryModifier or 1
	local v8 = math.random(95, 105) / 100
	local v9 = math.max(boundarySize * boundaryModifier * v8, 30) / 150
	local frame = Instance.new("Frame")
	frame.Name = "SkillCheckFrame"
	frame.Size = UDim2.new(0, v7, 0, v7)
	frame.Position = UDim2.new(0.5, 0, isTouchOnly and 0.35 or 0.5, 0)
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.BackgroundTransparency = 1
	frame.Visible = false
	frame.Parent = v6

	if data.randomPosition and (not data.movementPattern or data.movementPattern == "none") then
		local v10, v11

		if isTouchOnly then
			v10 = math.random(25, 75) / 100
			v11 = math.random(15, 45) / 100
		else
			v10 = math.random(20, 80) / 100
			v11 = math.random(20, 70) / 100
		end

		frame.Position = UDim2.new(v10, 0, v11, 0)
	end

	local numberValue = Instance.new("NumberValue")
	numberValue.Value = 0
	numberValue.Parent = frame
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = "Shadow"
	imageLabel.Size = UDim2.new(1.2, 0, 1.2, 0)
	imageLabel.Position = UDim2.new(0.5, 0, 0.5, 10)
	imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	imageLabel.BackgroundTransparency = 1
	imageLabel.Image = "rbxasset://textures/ui/LuaApp/graphic/CircleShadow.png"
	imageLabel.ImageTransparency = 0.5
	imageLabel.ZIndex = 0
	imageLabel.Parent = frame
	local frame2 = Instance.new("Frame")
	frame2.Name = "Container"
	frame2.Size = UDim2.new(1, 0, 1, 0)
	frame2.BackgroundColor3 = Color3.fromRGB(51, 51, 51)
	frame2.BackgroundTransparency = 0
	frame2.Parent = frame
	local uICorner = Instance.new("UICorner")
	uICorner.CornerRadius = UDim.new(0.5, 0)
	uICorner.Parent = frame2
	local sizeRatios = data.sizeRatios or {
		black = 0.15 + math.random() * 0.125,
		yellow = 0.075,
		grey = 0.1
	}
	local size = v7 * sizeRatios.black
	local v11 = v7 * sizeRatios.yellow * v9 * 0.7
	local v12 = v7 * sizeRatios.grey * v9 * 0.7
	local size2 = size + v11 * 2
	local size3 = size2 + v12 * 2
	local v15 = v7 - 6

	if v15 < size3 then
		local v16 = v15 / size3
		size2 *= v16
		size *= v16
		size3 = v15
	end

	local frame3 = Instance.new("Frame")
	frame3.Name = "GreyCircle"
	frame3.Size = UDim2.new(0, size3, 0, size3)
	frame3.Position = UDim2.new(0.5, 0, 0.5, 0)
	frame3.AnchorPoint = Vector2.new(0.5, 0.5)
	frame3.BackgroundColor3 = Color3.fromRGB(192, 192, 192)
	frame3.ZIndex = 2
	frame3.Parent = frame2
	local uICorner2 = Instance.new("UICorner")
	uICorner2.CornerRadius = UDim.new(0.5, 0)
	uICorner2.Parent = frame3
	local uIStroke = Instance.new("UIStroke")
	uIStroke.Color = Color3.fromRGB(100, 100, 100)
	uIStroke.Thickness = 2
	uIStroke.Transparency = 0.3
	uIStroke.Parent = frame3
	local uIGradient = Instance.new("UIGradient")
	uIGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(220, 220, 220)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(192, 192, 192)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(160, 160, 160))
	})
	uIGradient.Parent = frame3
	local frame4 = Instance.new("Frame")
	frame4.Name = "YellowCircle"
	frame4.Size = UDim2.new(0, size2, 0, size2)
	frame4.Position = UDim2.new(0.5, 0, 0.5, 0)
	frame4.AnchorPoint = Vector2.new(0.5, 0.5)
	frame4.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
	frame4.ZIndex = 3
	frame4.Parent = frame2
	local uICorner3 = Instance.new("UICorner")
	uICorner3.CornerRadius = UDim.new(0.5, 0)
	uICorner3.Parent = frame4
	local uIStroke2 = Instance.new("UIStroke")
	uIStroke2.Color = Color3.fromRGB(200, 150, 0)
	uIStroke2.Thickness = 2
	uIStroke2.Transparency = 0.2
	uIStroke2.Parent = frame4
	local uIGradient2 = Instance.new("UIGradient")
	uIGradient2.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 235, 80)),
		ColorSequenceKeypoint.new(0.7, Color3.fromRGB(255, 215, 40)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 195, 0))
	})
	uIGradient2.Parent = frame4
	local imageLabel2 = Instance.new("ImageLabel")
	imageLabel2.Name = "Glow"
	imageLabel2.Size = UDim2.new(1.3, 0, 1.3, 0)
	imageLabel2.Position = UDim2.new(0.5, 0, 0.5, 0)
	imageLabel2.AnchorPoint = Vector2.new(0.5, 0.5)
	imageLabel2.BackgroundTransparency = 1
	imageLabel2.Image = "rbxasset://textures/ui/LuaApp/graphic/CircleShadow.png"
	imageLabel2.ImageColor3 = Color3.fromRGB(255, 235, 80)
	imageLabel2.ImageTransparency = 0.8
	imageLabel2.ZIndex = 2
	imageLabel2.Parent = frame4
	local frame5 = Instance.new("Frame")
	frame5.Name = "CenterHole"
	frame5.Size = UDim2.new(0, size, 0, size)
	frame5.Position = UDim2.new(0.5, 0, 0.5, 0)
	frame5.AnchorPoint = Vector2.new(0.5, 0.5)
	frame5.BackgroundColor3 = Color3.fromRGB(51, 51, 51)
	frame5.BackgroundTransparency = 0
	frame5.ZIndex = 4
	frame5.Parent = frame2
	local uICorner4 = Instance.new("UICorner")
	uICorner4.CornerRadius = UDim.new(0.5, 0)
	uICorner4.Parent = frame5
	local uIStroke3 = Instance.new("UIStroke")
	uIStroke3.Color = Color3.fromRGB(30, 30, 30)
	uIStroke3.Thickness = 2
	uIStroke3.Transparency = 0.4
	uIStroke3.Parent = frame5
	local frame6 = Instance.new("Frame")
	frame6.Name = "ShrinkingCircle"
	frame6.Size = UDim2.new(0, v7 - 6, 0, v7 - 6)
	frame6.Position = UDim2.new(0.5, 0, 0.5, 0)
	frame6.AnchorPoint = Vector2.new(0.5, 0.5)
	frame6.BackgroundTransparency = 1
	frame6.ZIndex = 5
	frame6.Parent = frame2
	local lineThicknessModifier = data.lineThicknessModifier or 1
	local uIStroke4 = Instance.new("UIStroke")
	uIStroke4.Color = Color3.fromRGB(220, 20, 20)
	uIStroke4.Thickness = 4 * lineThicknessModifier
	uIStroke4.Transparency = 0
	uIStroke4.Parent = frame6
	local uIGradient3 = Instance.new("UIGradient")
	uIGradient3.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 100, 100)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(220, 20, 20)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 0, 0))
	})
	uIGradient3.Rotation = 45
	uIGradient3.Parent = uIStroke4
	local uICorner5 = Instance.new("UICorner")
	uICorner5.CornerRadius = UDim.new(0.5, 0)
	uICorner5.Parent = frame6
	return {
		Frame = frame,
		Container = frame2,
		ShrinkingCircle = frame6,
		Zones = {
			grey = {
				size = size3,
				reward = not (data.circles and data.circles[1]) and 1 or data.circles[1].reward or 1,
				circle = frame3,
				name = "good"
			},
			yellow = {
				size = size2,
				reward = data.circles and data.circles[2] and data.circles[2].reward or 3,
				circle = frame4,
				name = "great"
			},
			black = {
				size = size,
				reward = 0,
				circle = frame5,
				name = "miss"
			}
		},
		YellowGlow = imageLabel2,
		RotationValue = numberValue,
		gui = v6
	}
end

local function getTrinketCustomProperties()
	local generatorText = nil
	local generatorSound = nil
	local localPlayer = Players.LocalPlayer

	if not localPlayer then
		return nil, nil
	end

	for i = 1, 2 do
		local attribute = localPlayer:GetAttribute("EquippedTrinket" .. i)

		if not attribute then
			continue
		end

		local trinketData = ReplicatedStorage2:FindFirstChild("TrinketData")
		local child = trinketData and trinketData:FindFirstChild(attribute)

		if not child then
			continue
		end

		local success, result = pcall(require, child)

		if not (success and result) then
			continue
		end

		if not generatorText and result.GeneratorText then
			generatorText = result.GeneratorText
		end

		if not generatorSound and result.GeneratorSound then
			generatorSound = result.GeneratorSound
		end

		if generatorText and generatorSound then
			break
		end
	end

	return generatorText, generatorSound
end

function CircleSkillCheckHandler.HandleSkillCheck(instance, p)
	local v6 = applyConfigOverrides(p)
	local playerGui = instance:WaitForChild("PlayerGui")
	local circleSkillCheckUI = createCircleSkillCheckUI(playerGui, v6)
	local v7 = nil
	local connection = nil
	local connection2 = nil
	local connection3 = nil
	local v8 = true
	local v9 = false
	local valueChangedConnection = nil
	local v10 = nil
	local heartbeatConnection = nil
	local lastTime = tick()
	local flag = false
	local screenGui = playerGui:WaitForChild("ScreenGui")
	local calibrate = screenGui and screenGui:FindFirstChild("Menu") and screenGui.Menu:FindFirstChild("Calibrate")
	local skillCheckMessage = screenGui and screenGui:FindFirstChild("Menu") and screenGui.Menu:FindFirstChild("SkillCheckMessage")
	local spaceBarPromptText = screenGui and screenGui:FindFirstChild("Menu") and screenGui.Menu:FindFirstChild("SpaceBarPromptText")
	CircleSkillCheckHandler.ActiveSkillCheck = {
		ui = circleSkillCheckUI,
		connections = {},
		tweens = {},
		player = instance,
		calibrateButton = calibrate,
		spaceBarPromptText = spaceBarPromptText,
		skillCheckMessage = skillCheckMessage,
		forceStop = function()
			flag = true
			v7 = "forcestopped"
			v8 = false
		end
	}
	local position

	if calibrate then
		position = calibrate.Position
		calibrate.Visible = true
		CircleSkillCheckHandler.ActiveSkillCheck.originalButtonPosition = position
		InputService:IsTouchOnly()
	else
		position = nil
	end

	if spaceBarPromptText then
		spaceBarPromptText.Visible = true
		spaceBarPromptText.TextTransparency = 0
		spaceBarPromptText.TextStrokeTransparency = 0

		if spaceBarPromptText.Parent and spaceBarPromptText.Parent.Name == "Menu" and not spaceBarPromptText.Parent.Visible then
			warn("[CircleSkillCheck] Menu parent is not visible!")
		end
	end

	circleSkillCheckUI.Frame.Visible = true
	circleSkillCheckUI.Frame.Size = UDim2.new(0, 0, 0, 0)
	circleSkillCheckUI.Container.BackgroundTransparency = 1
	Audio:PlayOne("Sounds.UI.SkillCheck.SkillCheck")
	local v11 = InputService:IsTouchOnly() and 140 or 280
	TweenService:Create(circleSkillCheckUI.Frame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, v11, 0, v11)
	}):Play()
	TweenService:Create(circleSkillCheckUI.Container, TweenInfo.new(0.3), {
		BackgroundTransparency = 0
	}):Play()
	local movementPattern = v6.movementPattern or "none"
	local movementConfig = v6.movementConfig or {}

	if movementPattern ~= "none" and v3[movementPattern] then
		heartbeatConnection = RunService.Heartbeat:Connect(function()
			local v12 = tick() - lastTime
			local position2 = v3[movementPattern].update(v12, movementConfig)
			circleSkillCheckUI.Frame.Position = position2
		end)
	end

	if circleSkillCheckUI.RotationValue then
		v10 = TweenService:Create(
			circleSkillCheckUI.RotationValue,
			TweenInfo.new(10, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1),
			{
				Value = 360
			}
		)
		v10:Play()
		valueChangedConnection = circleSkillCheckUI.RotationValue:GetPropertyChangedSignal("Value"):Connect(function()
			circleSkillCheckUI.Container.Rotation = circleSkillCheckUI.RotationValue.Value * 0.1
		end)
	end

	local thread = nil

	local function showSkillCheckMessage(text, p2)
		if skillCheckMessage then
			if thread then
				task.cancel(thread)
				thread = nil
			end

			skillCheckMessage.Text = text
			skillCheckMessage.Visible = true
			skillCheckMessage.TextTransparency = 0
			skillCheckMessage.TextStrokeTransparency = 0

			if skillCheckMessage:FindFirstChild("UIGradient") and skillCheckMessage:FindFirstChild("UIGradientWin") then
				if p2 then
					skillCheckMessage.UIGradient.Enabled = false
					skillCheckMessage.UIGradientWin.Enabled = true
				else
					skillCheckMessage.UIGradient.Enabled = true
					skillCheckMessage.UIGradientWin.Enabled = false
				end
			end

			thread = task.spawn(function()
				task.wait(1)

				if flag then
					skillCheckMessage.Visible = false
					return
				end

				TweenService:Create(
					skillCheckMessage,
					TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						TextTransparency = 1,
						TextStrokeTransparency = 1
					}
				):Play()
				task.wait(1)

				if not flag then
					skillCheckMessage.Visible = false
				end
			end)
		end
	end

	local v12 = 0
	local heartbeatConnection2 = RunService.Heartbeat:Connect(function()
		local now = tick()
		local offset = circleSkillCheckUI.ShrinkingCircle.Size.X.Offset
		local v13 = 1 - offset / ((InputService:IsTouchOnly() and 140 or 280) - 6)

		if 0.1 + 0.4 * (1 - v13) < now - v12 and offset > 0 then
			v12 = now

			if pools.tick then
				pools.tick:PlaySound({
					Pitch = 1 + v13 * 0.5,
					Volume = 0.1 + v13 * 0.1
				})
			end
		end
	end)
	local speedMode = v6.speedMode or "star"
	local markerSpeed

	if speedMode == "star" then
		local boundarySize = v6.boundarySize

		if boundarySize <= 63 then
			markerSpeed = 0.6
		elseif boundarySize <= 125 then
			markerSpeed = 0.75
		elseif boundarySize <= 188 then
			markerSpeed = 0.9
		elseif boundarySize <= 250 then
			markerSpeed = 1.2
		else
			markerSpeed = 1.8
		end
	elseif speedMode == "modified" then
		local v13 = v6.boundarySize * v6.boundaryModifier

		if v13 <= 63 then
			markerSpeed = 0.6
		elseif v13 <= 125 then
			markerSpeed = 0.75
		elseif v13 <= 188 then
			markerSpeed = 0.9
		elseif v13 <= 250 then
			markerSpeed = 1.2
		else
			markerSpeed = 1.8
		end
	else
		markerSpeed = 0.9
	end

	if v6.markerSpeed and math.abs(v6.markerSpeed - CircleSkillCheckHandler.DEFAULTS.Core.markerSpeed) > 0.01 then
		markerSpeed = v6.markerSpeed
	end

	local tween = TweenService:Create(
		circleSkillCheckUI.ShrinkingCircle,
		TweenInfo.new(markerSpeed, Enum.EasingStyle.Linear),
		{
			Size = UDim2.new(0, 0, 0, 0)
		}
	)

	local function handleInput()
		if not v8 then
			return
		end

		v8 = false

		if tween then
			tween:Pause()
		end

		if heartbeatConnection2 then
			heartbeatConnection2:Disconnect()
		end

		if valueChangedConnection then
			valueChangedConnection:Disconnect()
		end

		if v10 then
			v10:Cancel()
		end

		if heartbeatConnection then
			heartbeatConnection:Disconnect()
		end

		local halfOffset = circleSkillCheckUI.ShrinkingCircle.Size.X.Offset / 2
		local halfSize = circleSkillCheckUI.Zones.grey.size / 2
		local halfSize2 = circleSkillCheckUI.Zones.yellow.size / 2
		local halfSize3 = circleSkillCheckUI.Zones.black.size / 2
		local hitTolerance = v6.hitTolerance or 3
		local name

		if halfSize < halfOffset then
			name = "miss"
		elseif halfSize2 < halfOffset then
			if halfOffset <= halfSize + hitTolerance then
				name = circleSkillCheckUI.Zones.grey.name
				local _ = circleSkillCheckUI.Zones.grey.reward
			else
				name = "miss"
			end
		elseif halfSize3 < halfOffset then
			name = circleSkillCheckUI.Zones.yellow.name
			local _ = circleSkillCheckUI.Zones.yellow.reward
		elseif halfSize3 - hitTolerance <= halfOffset then
			name = circleSkillCheckUI.Zones.yellow.name
			local _ = circleSkillCheckUI.Zones.yellow.reward
		else
			name = "miss"
		end

		if name == "great" then
			if v then
				v:Play("PulseSingle")
			end

			Audio:PlayOne("Sounds.UI.SkillCheck.Correct")
			Audio:PlayOne("Sounds.UI.SkillCheck.GoldAreaHit")
			TweenService:Create(circleSkillCheckUI.Container, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
				BackgroundColor3 = Color3.fromRGB(255, 235, 100)
			}):Play()
			task.wait(0.1)
			TweenService:Create(circleSkillCheckUI.Container, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
				BackgroundColor3 = Color3.fromRGB(51, 51, 51)
			}):Play()
			local circle = circleSkillCheckUI.Zones.yellow.circle
			TweenService:Create(circle, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = UDim2.new(
					0,
					circleSkillCheckUI.Zones.yellow.size * 1.15,
					0,
					circleSkillCheckUI.Zones.yellow.size * 1.15
				)
			}):Play()

			if circleSkillCheckUI.YellowGlow then
				TweenService:Create(circleSkillCheckUI.YellowGlow, TweenInfo.new(0.2), {
					ImageTransparency = 0.3
				}):Play()
			end

			createParticleBurst(
				circleSkillCheckUI.Container,
				UDim2.new(0.5, 0, 0.5, 0),
				Color3.fromRGB(255, 215, 0),
				12
			)
			local textLabel = Instance.new("TextLabel")
			textLabel.Text = "GREAT!"
			textLabel.Size = UDim2.new(0, 200, 0, 50)
			textLabel.Position = UDim2.new(0.5, 0, 0.5, -80)
			textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
			textLabel.BackgroundTransparency = 1
			textLabel.TextScaled = true
			textLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
			textLabel.Font = Enum.Font.SourceSansBold
			textLabel.TextStrokeTransparency = 0.5
			textLabel.TextStrokeColor3 = Color3.fromRGB(180, 150, 0)
			textLabel.ZIndex = 10
			textLabel.Parent = circleSkillCheckUI.Container
			TweenService:Create(textLabel, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Position = UDim2.new(0.5, 0, 0.5, -120),
				TextTransparency = 1,
				TextStrokeTransparency = 1
			}):Play()
			task.wait(0.15)
			TweenService:Create(circle, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
				Size = UDim2.new(0, circleSkillCheckUI.Zones.yellow.size, 0, circleSkillCheckUI.Zones.yellow.size)
			}):Play()

			if circleSkillCheckUI.YellowGlow then
				TweenService:Create(circleSkillCheckUI.YellowGlow, TweenInfo.new(0.3), {
					ImageTransparency = 0.8
				}):Play()
			end

			task.wait(0.4)
			textLabel:Destroy()
			showSkillCheckMessage("Great Job!", true)
		elseif name == "good" then
			if v then
				v:Play("PulseSingleSmall")
			end

			Audio:PlayOne("Sounds.UI.SkillCheck.Correct")
			TweenService:Create(circleSkillCheckUI.Container, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
				BackgroundColor3 = Color3.fromRGB(120, 120, 120)
			}):Play()
			task.wait(0.1)
			TweenService:Create(circleSkillCheckUI.Container, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
				BackgroundColor3 = Color3.fromRGB(51, 51, 51)
			}):Play()
			local circle = circleSkillCheckUI.Zones.grey.circle
			TweenService:Create(circle, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
				BackgroundColor3 = Color3.fromRGB(220, 220, 220)
			}):Play()
			createParticleBurst(
				circleSkillCheckUI.Container,
				UDim2.new(0.5, 0, 0.5, 0),
				Color3.fromRGB(192, 192, 192),
				8
			)
			local textLabel = Instance.new("TextLabel")
			textLabel.Text = "GOOD"
			textLabel.Size = UDim2.new(0, 150, 0, 40)
			textLabel.Position = UDim2.new(0.5, 0, 0.5, -70)
			textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
			textLabel.BackgroundTransparency = 1
			textLabel.TextScaled = true
			textLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
			textLabel.Font = Enum.Font.SourceSansBold
			textLabel.ZIndex = 10
			textLabel.Parent = circleSkillCheckUI.Container
			TweenService:Create(textLabel, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
				Position = UDim2.new(0.5, 0, 0.5, -100),
				TextTransparency = 1
			}):Play()
			task.wait(0.2)
			TweenService:Create(circle, TweenInfo.new(0.2), {
				BackgroundColor3 = Color3.fromRGB(100, 100, 100)
			}):Play()
			task.wait(0.3)
			textLabel:Destroy()
			showSkillCheckMessage("Good Job!", false)
		else
			local _, v17 = getTrinketCustomProperties()

			if v17 then
				Audio:Play(v17, {
					Parent = screenGui or SoundService
				})
			else
				Audio:PlayOne("Sounds.UI.SkillCheck.Wrong")
			end

			TweenService:Create(circleSkillCheckUI.Container, TweenInfo.new(0.1), {
				BackgroundColor3 = Color3.fromRGB(200, 0, 0)
			}):Play()
			TweenService:Create(circleSkillCheckUI.Zones.black.circle, TweenInfo.new(0.1), {
				BackgroundColor3 = Color3.fromRGB(200, 0, 0)
			}):Play()
			task.spawn(function()
				local position2 = circleSkillCheckUI.Frame.Position

				for i = 1, 8 do
					local v18 = math.random(-8, 8) * (1 - i / 8)
					local v19 = math.random(-8, 8) * (1 - i / 8)
					circleSkillCheckUI.Frame.Position = position2 + UDim2.new(0, v18, 0, v19)
					task.wait(0.04)
				end

				circleSkillCheckUI.Frame.Position = position2
				task.wait(0.1)
				TweenService:Create(circleSkillCheckUI.Container, TweenInfo.new(0.3), {
					BackgroundColor3 = Color3.fromRGB(51, 51, 51)
				}):Play()
				TweenService:Create(circleSkillCheckUI.Zones.black.circle, TweenInfo.new(0.3), {
					BackgroundColor3 = Color3.fromRGB(51, 51, 51)
				}):Play()
				createParticleBurst(
					circleSkillCheckUI.Container,
					UDim2.new(0.5, 0, 0.5, 0),
					Color3.fromRGB(255, 50, 50),
					10
				)
				local textLabel = Instance.new("TextLabel")
				textLabel.Text = "MISS"
				textLabel.Size = UDim2.new(0, 150, 0, 50)
				textLabel.Position = UDim2.new(0.5, 0, 0.5, -70)
				textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
				textLabel.BackgroundTransparency = 1
				textLabel.TextScaled = true
				textLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
				textLabel.Font = Enum.Font.SourceSansBold
				textLabel.TextStrokeTransparency = 0.5
				textLabel.TextStrokeColor3 = Color3.fromRGB(100, 0, 0)
				textLabel.ZIndex = 10
				textLabel.Parent = circleSkillCheckUI.Container

				for i = 1, 10 do
					textLabel.Rotation = math.random(-15, 15) * (1 - i / 10)
					task.wait(0.03)
				end

				TweenService:Create(textLabel, TweenInfo.new(0.2), {
					TextTransparency = 1,
					TextStrokeTransparency = 1
				}):Play()
				task.wait(0.2)
				textLabel:Destroy()
			end)
		end

		if name == "great" then
			v7 = "supercomplete"
		elseif name == "good" then
			v7 = true
		else
			v7 = false
		end

		if connection then
			connection:Disconnect()
		end

		if connection2 then
			connection2:Disconnect()
		end

		if connection3 then
			connection3:Disconnect()
		end

		if calibrate then
			calibrate.Visible = false

			if position then
				calibrate.Position = position
			end
		end

		task.spawn(function()
			task.wait(0.4)
			local tween2 = TweenService:Create(
				circleSkillCheckUI.Frame,
				TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
				{
					Size = UDim2.new(0, 0, 0, 0),
					BackgroundTransparency = 1
				}
			)
			tween2:Play()
			tween2.Completed:Wait()

			if circleSkillCheckUI.Frame then
				circleSkillCheckUI.Frame.Visible = false
			end
		end)
	end

	local textButton = Instance.new("TextButton")
	textButton.Name = "CircleClickHandler"
	textButton.Size = UDim2.new(1, 0, 1, 0)
	textButton.Position = UDim2.new(0.5, 0, 0.5, 0)
	textButton.AnchorPoint = Vector2.new(0.5, 0.5)
	textButton.BackgroundTransparency = 1
	textButton.Text = ""
	textButton.ZIndex = 10
	textButton.Parent = circleSkillCheckUI.Container

	if calibrate then
		connection2 = SkillCheckTouchButton.bind(calibrate, function()
			return v8 and v9
		end, handleInput)
	end

	connection3 = SkillCheckTouchButton.bind(textButton, function()
		return v8 and v9
	end, handleInput)
	task.wait(0.3)
	connection = InputService:OnAction("SkillCheckTap", function()
		if InputService:IsTyping() then
			return
		end

		handleInput()
	end)
	v9 = true
	tween:Play()
	tween.Completed:Connect(function(p2)
		if p2 == Enum.PlaybackState.Completed and not v7 then
			v8 = false
			v7 = "noinput"
			local _, v13 = getTrinketCustomProperties()

			if v13 then
				Audio:Play(v13, {
					Parent = screenGui or SoundService
				})
			else
				Audio:PlayOne("Sounds.UI.SkillCheck.Wrong")
			end

			TweenService:Create(circleSkillCheckUI.Container, TweenInfo.new(0.3), {
				BackgroundColor3 = Color3.fromRGB(255, 0, 0)
			}):Play()

			if connection then
				connection:Disconnect()
			end

			if connection2 then
				connection2:Disconnect()
			end

			if connection3 then
				connection3:Disconnect()
			end

			if heartbeatConnection2 then
				heartbeatConnection2:Disconnect()
			end

			if valueChangedConnection then
				valueChangedConnection:Disconnect()
			end

			if v10 then
				v10:Cancel()
			end

			if heartbeatConnection then
				heartbeatConnection:Disconnect()
			end

			if calibrate then
				calibrate.Visible = false

				if position then
					calibrate.Position = position
				end
			end

			task.wait(0.3)
			TweenService:Create(circleSkillCheckUI.Frame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
				Size = UDim2.new(0, 0, 0, 0)
			}):Play()
			task.wait(0.2)
			circleSkillCheckUI.Frame.Visible = false
		end
	end)

	while v7 == nil do
		task.wait(0.1)
	end

	if flag then
		if thread then
			task.cancel(thread)
			thread = nil
		end

		if connection then
			connection:Disconnect()
		end

		if connection2 then
			connection2:Disconnect()
		end

		if connection3 then
			connection3:Disconnect()
		end

		if heartbeatConnection2 then
			heartbeatConnection2:Disconnect()
		end

		if valueChangedConnection then
			valueChangedConnection:Disconnect()
		end

		if heartbeatConnection then
			heartbeatConnection:Disconnect()
		end

		if tween then
			tween:Cancel()
		end

		if v10 then
			v10:Cancel()
		end

		if calibrate then
			calibrate.Visible = false

			if position then
				calibrate.Position = position
			end
		end

		if spaceBarPromptText then
			spaceBarPromptText.Visible = false
			spaceBarPromptText.TextTransparency = 0
			spaceBarPromptText.TextStrokeTransparency = 0
		end

		if skillCheckMessage then
			skillCheckMessage.Visible = false
			skillCheckMessage.TextTransparency = 0
			skillCheckMessage.TextStrokeTransparency = 0
		end

		if circleSkillCheckUI and circleSkillCheckUI.gui and circleSkillCheckUI.gui.Parent then
			circleSkillCheckUI.gui:Destroy()
		end
	else
		task.spawn(function()
			task.wait(0.5)

			if circleSkillCheckUI and circleSkillCheckUI.gui and circleSkillCheckUI.gui.Parent then
				circleSkillCheckUI.gui:Destroy()
			end
		end)
	end

	CircleSkillCheckHandler.ActiveSkillCheck = nil
	return v7
end

function CircleSkillCheckHandler.GetCharacterBoundarySize(p)
	return v4[p] or 188
end

function CircleSkillCheckHandler.ForceStopSkillCheck()
	if CircleSkillCheckHandler.ActiveSkillCheck and CircleSkillCheckHandler.ActiveSkillCheck.forceStop then
		CircleSkillCheckHandler.ActiveSkillCheck.forceStop()
	end
end

function CircleSkillCheckHandler.CleanUp(instance)
	CircleSkillCheckHandler.ForceStopSkillCheck()
	local playerGui = instance:FindFirstChild("PlayerGui")

	if playerGui then
		local circleSkillCheckGui = playerGui:FindFirstChild("CircleSkillCheckGui")

		if circleSkillCheckGui then
			circleSkillCheckGui:Destroy()
		end

		local screenGui = playerGui:FindFirstChild("ScreenGui")

		if screenGui and screenGui:FindFirstChild("Menu") then
			local menu = screenGui.Menu

			if menu:FindFirstChild("SpaceBarPromptText") then
				menu.SpaceBarPromptText.Visible = false
			end

			if menu:FindFirstChild("Calibrate") then
				menu.Calibrate.Visible = false

				if CircleSkillCheckHandler.ActiveSkillCheck and CircleSkillCheckHandler.ActiveSkillCheck.originalButtonPosition then
					menu.Calibrate.Position = CircleSkillCheckHandler.ActiveSkillCheck.originalButtonPosition
				end
			end

			if menu:FindFirstChild("SkillCheckMessage") then
				menu.SkillCheckMessage.Visible = false
			end
		end
	end

	for _, v6 in ipairs(v5) do
		if not (v6 and v6.Parent) then
			continue
		end

		v6:Stop()
		v6:Destroy()
	end

	v5 = {}
end

function CircleSkillCheckHandler.CreateGeneratorDisplay(p, parent)
	if not (p and parent) then
		warn("[CircleSkillCheckHandler] Missing screenGui or backgroundFrame for generator display")
		return
	end

	parent:ClearAllChildren()
	local uIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	uIAspectRatioConstraint.AspectRatio = 1
	uIAspectRatioConstraint.Parent = parent
	local v6 = {
		boundarySize = 188,
		boundaryModifier = 1,
		markerSpeed = 0.9,
		sizeRatios = {
			black = 0.15 + math.random() * 0.125,
			yellow = 0.075,
			grey = 0.1
		}
	}
	local frame = Instance.new("Frame")
	frame.Name = "SkillCheckFrame"
	frame.Size = UDim2.new(0, 140, 0, 140)
	frame.Position = UDim2.new(0.5, 0, 0.5, 0)
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.BackgroundTransparency = 1
	frame.Parent = parent
	local frame2 = Instance.new("Frame")
	frame2.Name = "Container"
	frame2.Size = UDim2.new(1, 0, 1, 0)
	frame2.BackgroundTransparency = 1
	frame2.Parent = frame
	local frame3 = Instance.new("Frame")
	frame3.Name = "BackgroundCircle"
	frame3.Size = UDim2.new(1, 0, 1, 0)
	frame3.Position = UDim2.new(0.5, 0, 0.5, 0)
	frame3.AnchorPoint = Vector2.new(0.5, 0.5)
	frame3.BackgroundTransparency = 1
	frame3.Parent = frame2
	local uIStroke = Instance.new("UIStroke")
	uIStroke.Color = Color3.fromRGB(51, 51, 51)
	uIStroke.Thickness = 70
	uIStroke.Transparency = 0
	uIStroke.Parent = frame3
	local uICorner = Instance.new("UICorner")
	uICorner.CornerRadius = UDim.new(0.5, 0)
	uICorner.Parent = frame3
	local v7 = 140 * v6.sizeRatios.black
	local v8 = 140 * v6.sizeRatios.yellow * 0.7
	local v9 = 140 * v6.sizeRatios.grey * 0.7
	local v10 = v7 + v8 * 2
	local v11 = v10 + v9 * 2

	if v11 > 134 then
		local v12 = 134 / v11
		v10 *= v12
		v7 *= v12
		v11 = 134
	end

	local frame4 = Instance.new("Frame")
	frame4.Name = "GreyCircle"
	frame4.Size = UDim2.new(0, v11, 0, v11)
	frame4.Position = UDim2.new(0.5, 0, 0.5, 0)
	frame4.AnchorPoint = Vector2.new(0.5, 0.5)
	frame4.BackgroundTransparency = 1
	frame4.ZIndex = 2
	frame4.Parent = frame2
	local _ = (v11 - v10) / 2
	local uICorner2 = Instance.new("UICorner")
	uICorner2.CornerRadius = UDim.new(0.5, 0)
	uICorner2.Parent = frame4
	local frame5 = Instance.new("Frame")
	frame5.Name = "YellowCircle"
	frame5.Size = UDim2.new(0, v10, 0, v10)
	frame5.Position = UDim2.new(0.5, 0, 0.5, 0)
	frame5.AnchorPoint = Vector2.new(0.5, 0.5)
	frame5.BackgroundTransparency = 1
	frame5.ZIndex = 3
	frame5.Parent = frame2
	local thickness = (v10 - v7) / 2
	local uIStroke2 = Instance.new("UIStroke")
	uIStroke2.Color = Color3.fromRGB(255, 215, 0)
	uIStroke2.Thickness = thickness
	uIStroke2.Transparency = 0
	uIStroke2.Parent = frame5
	local uICorner3 = Instance.new("UICorner")
	uICorner3.CornerRadius = UDim.new(0.5, 0)
	uICorner3.Parent = frame5
	local frame6 = Instance.new("Frame")
	frame6.Name = "CenterHole"
	frame6.Size = UDim2.new(0, v7, 0, v7)
	frame6.Position = UDim2.new(0.5, 0, 0.5, 0)
	frame6.AnchorPoint = Vector2.new(0.5, 0.5)
	frame6.BackgroundTransparency = 1
	frame6.ZIndex = 4
	frame6.Parent = frame2
	local uIStroke3 = Instance.new("UIStroke")
	uIStroke3.Color = Color3.fromRGB(51, 51, 51)
	uIStroke3.Thickness = v7 / 2
	uIStroke3.Transparency = 0
	uIStroke3.Parent = frame6
	local uICorner4 = Instance.new("UICorner")
	uICorner4.CornerRadius = UDim.new(0.5, 0)
	uICorner4.Parent = frame6
	local connections = {}
	local tweens = {}

	local function createShrinkingCircle()
		local frame7 = Instance.new("Frame")
		frame7.Name = "ShrinkingCircle"
		frame7.Size = UDim2.new(0, 80, 0, 80)
		frame7.Position = UDim2.new(0.5, 0, 0.5, 0)
		frame7.AnchorPoint = Vector2.new(0.5, 0.5)
		frame7.BackgroundTransparency = 1
		frame7.ZIndex = 5
		frame7.Parent = frame2
		local uIStroke4 = Instance.new("UIStroke")
		uIStroke4.Color = Color3.fromRGB(220, 20, 20)
		uIStroke4.Thickness = 4
		uIStroke4.Transparency = 1
		uIStroke4.Parent = frame7
		local uICorner5 = Instance.new("UICorner")
		uICorner5.CornerRadius = UDim.new(0.5, 0)
		uICorner5.Parent = frame7
		local tween = TweenService:Create(frame7, TweenInfo.new(v6.markerSpeed, Enum.EasingStyle.Linear), {
			Size = UDim2.new(0, 0, 0, 0)
		})
		local tween2 = TweenService:Create(uIStroke4, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {
			Transparency = 0
		})
		tween:Play()
		tween2:Play()
		table.insert(tweens, tween)
		table.insert(tweens, tween2)
		tween.Completed:Connect(function()
			frame7:Destroy()
			local index = table.find(tweens, tween)

			if index then
				table.remove(tweens, index)
			end
		end)
	end

	local v13 = 0
	table.insert(connections, (RunService.Heartbeat:Connect(function()
		local now = tick()
		local count = 0

		for _, child in pairs(frame2:GetChildren()) do
			if child.Name == "ShrinkingCircle" then
				count += 1
			end
		end

		if count == 0 and now - v13 > 0.5 then
			v13 = now
			createShrinkingCircle()
		end
	end)))
	return function()
		for _, connection in pairs(connections) do
			if connection then
				connection:Disconnect()
			end
		end

		for _, v14 in pairs(tweens) do
			if v14 then
				v14:Cancel()
			end
		end

		frame:Destroy()
	end
end

function CircleSkillCheckHandler.Destroy()
	soundPoolManager:DestroyAllPools()

	for _, v6 in ipairs(v5) do
		if not (v6 and v6.Parent) then
			continue
		end

		v6:Stop()
		v6:Destroy()
	end

	v5 = {}
end

function CircleSkillCheckHandler.GetSoundPoolStats()
	return soundPoolManager:GetAllStats()
end

return CircleSkillCheckHandler