local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local GamepadService = game:GetService("GamepadService")
local ContextActionService = game:GetService("ContextActionService")
local CollectionService = game:GetService("CollectionService")
local Network = require(ReplicatedStorage.SharedUtils.Network)
local Signal = require(ReplicatedStorage.SharedUtils.Signal)
local TowerLUT = require(ReplicatedStorage.SharedUtils.TowerLUT)
local CameraController = require(ReplicatedStorage.SharedUtils.CameraController)
local PlayerCache = require(ReplicatedStorage.SharedUtils.PlayerCache)
local CharacterVisibilityHandler = require(ReplicatedStorage.SharedUtils.CharacterVisibilityHandler)
local KeyCodeNames = require(ReplicatedStorage.SharedUtils.KeyCodeNames)
local SettingsFlags = require(ReplicatedStorage.SharedUtils.SettingsFlags)

if RunService:IsServer() then
	print("You cannot require " .. tostring(script) .. " from the server!")
	return {}
end

local Engine = require(script.Parent:WaitForChild("Util"):WaitForChild("Engine"))
local SwimmyBarnaby = {}
SwimmyBarnaby.__index = SwimmyBarnaby
setmetatable(SwimmyBarnaby, Engine)

local function setMusicMufflersEnabled(enabled: boolean)
	for _, equalizerSoundEffect in ipairs(CollectionService:GetTagged("MusicMuffler")) do
		if equalizerSoundEffect:IsA("EqualizerSoundEffect") then
			equalizerSoundEffect.Enabled = enabled
		end
	end
end

local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(7, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
local tweenInfo3 = TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
local tweenInfo4 = TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local fieldOfView = nil
local v = RunService:IsStudio() and 10 or 100
local camera = Instance.new("Camera")
camera.CFrame = CFrame.new(createVector(0, 0, 60), createVector(0, 0, 0))
camera.FieldOfView = 30
local bendySeaweed = script:WaitForChild("BendySeaweed")

if not bendySeaweed:GetAttribute("Required") then
	bendySeaweed:SetAttribute("Required", true)
	require(bendySeaweed)
end

local v2 = {
	SPEED = 13,
	GAP_HEIGHT = 15,
	MIN_SIZE = createVector(3, 2, 6),
	SCREEN_HEIGHT = 30,
	SCREEN_WIDTH = 30
}

function SwimmyBarnaby:ShowIntroAnimation()
	local sessionId = self.SessionId
	local background = self.SurfaceGui.Background
	local FG = background.FG
	local BG = background.BG
	local videoFrame = background.VideoFrame
	self:HideAllMenus()

	for _, image in pairs(BG:GetDescendants()) do
		if not image:IsA("ImageLabel") then
			continue
		end

		image.ImageColor3 = Color3.new(0, 0, 0)
		TweenService:Create(image, tweenInfo2, {
			ImageColor3 = Color3.new(1, 1, 1)
		}):Play()
	end

	videoFrame.Size = UDim2.fromScale(4, 2)
	videoFrame.Position = UDim2.fromScale(0.6, 0)
	local clones = {}
	local bubbleTemplate = background:WaitForChild("BubbleTemplate")
	self.SurfaceGui.Enabled = true
	videoFrame:Play()
	TweenService:Create(videoFrame, tweenInfo2, {
		Size = UDim2.new(1.18, 0, 1, 10),
		Position = UDim2.fromScale(0.5, 0)
	}):Play()
	local tween = TweenService:Create(FG, tweenInfo2, {
		Position = UDim2.fromScale(0, 1),
		ImageTransparency = 0
	})
	tween:Play()
	task.delay(4, function()
		if self.SessionId ~= sessionId then
			return
		end

		self:PlaySound("Bubbles")
		task.wait(0.9)
		local tweenInfo5 = TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
		local tweenInfo6 = TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)

		for i = 1, 40 do
			local clone = bubbleTemplate:Clone()
			clone.Visible = true
			local v3 = 0.2 + math.random() * 0.2
			clone.Size = UDim2.fromScale(v3, v3)
			clones[#clones + 1] = clone
			local v6 = i
			local v8 = (math.sin(math.random() * 3.141592653589793 * 2) + 1) * 0.5
			task.delay((i - 1) / 3 // 1 * 0.1, function()
				local v10 = (v6 - 1) / 3.46 % 1
				clone.Position = UDim2.fromScale(v10, 1.2)
				local imageLabel = clone:FindFirstChild("ImageLabel")

				if imageLabel then
					imageLabel.Position = UDim2.fromScale(v8, 0.5)
					local v11 = 0.5 - v8 + 0.5
					TweenService:Create(imageLabel, math.abs(v11 - v8) > 0.5 and tweenInfo6 or tweenInfo5, {
						Position = UDim2.fromScale(v11, 0.5)
					}):Play()
				end

				TweenService:Create(clone, tweenInfo4, {
					Position = UDim2.fromScale(v10, -0.2),
					Size = UDim2.fromScale(v3 - 0.1, v3 - 0.1)
				}):Play()
				clone.Parent = background
			end)
		end
	end)
	task.delay(6, function()
		if self.SessionId ~= sessionId then
			return
		end

		local tween2 = TweenService:Create(self.SurfaceGui.Foreground, tweenInfo3, {
			BackgroundTransparency = 0
		})
		tween2:Play()
		tween2.Completed:Wait()

		for _, v3 in pairs(clones) do
			v3:Destroy()
		end

		TweenService:Create(self.SurfaceGui.Foreground, tweenInfo, {
			BackgroundTransparency = 1
		}):Play()
	end)
	local sunray = background:FindFirstChild("Sunray")

	if sunray then
		local scale = sunray.Size.X.Scale
		local scale2 = sunray.Size.Y.Scale
		local v3 = 0
		local v4 = 2
		self:AddConnection(RunService.RenderStepped:Connect(function()
			if self.SessionId ~= sessionId then
				return
			end

			local now = tick()

			if now - v3 < v4 then
				return
			end

			v3 = now
			v4 = 0.4 + math.random() * 0.4
			local clone = sunray:Clone()
			local v5 = scale * (0.5 + math.random() * 0.5)
			clone.Size = UDim2.fromScale(v5, scale2)
			clone.Position = UDim2.fromScale(math.random(), sunray.Position.Y.Scale)
			clone.ImageTransparency = 1
			clone.Visible = true
			clone.Parent = background
			local v6 = 2 + math.random()
			TweenService:Create(clone, TweenInfo.new(v6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				ImageTransparency = 0
			}):Play()
			task.delay(v6, function()
				if not (clone and clone.Parent) then
					return
				end

				local tween2 = TweenService:Create(
					clone,
					TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
					{
						ImageTransparency = 1
					}
				)
				tween2:Play()
				tween2.Completed:Connect(function()
					if clone and clone.Parent then
						clone:Destroy()
					end
				end)
			end)
		end))
	end

	local v3 = Signal.new()
	local completedConnection = tween.Completed:Connect(function()
		v3:Fire()
	end)
	local shutdownSignalConnection = self.ShutdownSignal:Connect(function()
		v3:Fire()
	end)
	v3:Wait()
	completedConnection:Disconnect()
	shutdownSignalConnection:Disconnect()
	v3:Destroy()
end

function SwimmyBarnaby:FormatScoreText()
	return (tostring(self.Score))
end

function SwimmyBarnaby:StopCabinetMirror() end

function SwimmyBarnaby:IncreaseScore(p)
	if RunService:IsStudio() then
		Engine.IncreaseScore(self, self.Score >= 10 and 100 or p)
	else
		Engine.IncreaseScore(self, p)
	end

	self:PlaySoundOneShot("Score")

	if not self.MilestoneFired and v <= self.Score then
		self.MilestoneFired = true
		Network:Post("ReportArcadeMilestone", self.ID)
	end

	self.ScreenGui.Top.AnchorPoint = Vector2.new(0.5, 0.25)
	TweenService:Create(self.ScreenGui.Top, tweenInfo, {
		AnchorPoint = Vector2.new(0.5, 0.5)
	}):Play()
	self.ScreenGui.Top.ScoreNum.Text = self:FormatScoreText()
end

function SwimmyBarnaby:ApplyTuningFromFlags(p2)
	local info = workspace:FindFirstChild("Info")

	if not info then
		return p2
	end

	local GAME_CONFIG = self.GAME_CONFIG
	local barnabySeaweedGap = info:GetAttribute("BarnabySeaweedGap")

	if type(barnabySeaweedGap) == "number" then
		GAME_CONFIG.GAP_HEIGHT = math.clamp(barnabySeaweedGap, 0.1, 0.9) * GAME_CONFIG.SCREEN_HEIGHT
	end

	local barnabySeaweedWidth = info:GetAttribute("BarnabySeaweedWidth")

	if type(barnabySeaweedWidth) == "number" then
		GAME_CONFIG.MIN_SIZE = Vector3.new(
			math.clamp(barnabySeaweedWidth, 0.02, 0.3) * GAME_CONFIG.SCREEN_WIDTH,
			GAME_CONFIG.MIN_SIZE.Y,
			GAME_CONFIG.MIN_SIZE.Z
		)
	end

	local barnabyObstacleSpacing = info:GetAttribute("BarnabyObstacleSpacing")

	if type(barnabyObstacleSpacing) == "number" then
		p2 = math.clamp(barnabyObstacleSpacing, 0.2, 1) * 2
	end

	return p2
end

local function buildVoidStage(instance, p)
	local folder = Instance.new("Folder")
	folder.Name = "_SwimmyVoidStage"
	local part = Instance.new("Part")
	part.Name = "VoidScreen"
	part.Size = instance.Size
	part.CFrame = CFrame.new(createVector(0, -9000, 0)) * instance.CFrame.Rotation
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.Color = Color3.new(0, 0, 0)
	part.Parent = folder
	local cframe

	if p then
		cframe = part.CFrame * instance.CFrame:ToObjectSpace(p.CFrame)
	else
		cframe = CFrame.new(part.Position + part.CFrame.LookVector * 30, part.Position)
	end

	local part2 = Instance.new("Part")
	part2.Name = "VoidBackdrop"
	part2.Size = createVector(4000, 4000, 1)
	local v3 = part.Position + (part.Position - cframe.Position).Unit * 40
	part2.CFrame = CFrame.lookAt(v3, cframe.Position)
	part2.Anchored = true
	part2.CanCollide = false
	part2.CanQuery = false
	part2.CanTouch = false
	part2.CastShadow = false
	part2.Color = Color3.new(0, 0, 0)
	part2.Material = Enum.Material.Neon
	part2.Parent = folder
	folder.Parent = workspace
	return folder, part, cframe
end

function SwimmyBarnaby:GetMinigameSetting(p2)
	local data = self.myReplica and self.myReplica.Data
	local minigameSettings = data and data.Settings and data.Settings.MinigameSettings
	local effective = SettingsFlags:GetEffective(minigameSettings and minigameSettings[p2], "MinigameSettings." .. p2)
	return effective == nil or effective == true
end

function SwimmyBarnaby:ApplyCameraSetting()
	local _framePart = self._framePart or self.SurfaceGui and self.SurfaceGui.Adornee

	if not _framePart then
		return
	end

	if self:GetMinigameSetting("AngledCamera") then
		if self._voidCameraCF then
			CameraController:SetCFrame(self._voidCameraCF)
		elseif self.Objects and self.Objects.Camera then
			CameraController:SetCFrame(self.Objects.Camera.CFrame)
		else
			CameraController:SetCFrame(CFrame.new(
				_framePart.Position + _framePart.CFrame.LookVector * 30,
				_framePart.Position
			))
		end
	else
		CameraController:SetCFrame(_framePart.CFrame * CFrame.new(0, 0, -2) * CFrame.Angles(0, 3.141592653589793, 0))
	end

	CameraController:FitPartInView(_framePart)
end

function SwimmyBarnaby:ApplyBackgroundSetting()
	local background = self.SurfaceGui and self.SurfaceGui:FindFirstChild("Background")
	local videoFrame = background and background:FindFirstChild("VideoFrame")

	if not videoFrame then
		return
	end

	if self:GetMinigameSetting("AnimatedBackground") then
		videoFrame:Play()
	else
		videoFrame:Pause()
	end
end

function SwimmyBarnaby:RefreshSettingsLabels()
	local settings = self.MenuFrames and self.MenuFrames:FindFirstChild("Settings")
	local content = settings and settings:FindFirstChild("Content")

	if not content then
		return
	end

	local perspective = content:FindFirstChild("Perspective")
	local value = perspective and perspective:FindFirstChild("Value")

	if value then
		value.Text = self:GetMinigameSetting("AngledCamera") and "Angled" or "Flat"
	end

	local background = content:FindFirstChild("Background")
	local value2 = background and background:FindFirstChild("Value")

	if value2 then
		value2.Text = self:GetMinigameSetting("AnimatedBackground") and "Moving" or "Still"
	end
end

function SwimmyBarnaby:BindMinigameSettings()
	if self._minigameSettingsBound or not self.myReplica then
		return
	end

	self._minigameSettingsBound = true
	self._minigameSettingsConns = {}
	local success, result = pcall(function()
		self._minigameSettingsConns[#self._minigameSettingsConns + 1] = self.myReplica:ListenToChange(
			{ "Settings", "MinigameSettings", "AngledCamera" },
			function()
				self:ApplyCameraSetting()
				self:RefreshSettingsLabels()
			end
		)
		self._minigameSettingsConns[#self._minigameSettingsConns + 1] = self.myReplica:ListenToChange(
			{ "Settings", "MinigameSettings", "AnimatedBackground" },
			function()
				self:ApplyBackgroundSetting()
				self:RefreshSettingsLabels()
			end
		)
	end)

	if not success then
		warn("[SwimmyBarnaby] Failed to bind MinigameSettings listeners: ", result)
	end
end

function SwimmyBarnaby:Bootup(myReplica)
	self.SessionId = tick()
	self.myReplica = myReplica
	self.SurfaceGui.Parent = playerGui
	self.ScreenGui.Parent = playerGui
	local viewportFrame = self.SurfaceGui:WaitForChild("ViewportFrame")
	local adornee = self.SurfaceGui.Adornee
	fieldOfView = workspace.CurrentCamera.FieldOfView

	if self._voidStage then
		self._voidStage:Destroy()
		self._voidStage = nil
	end

	self._voidCameraCF = nil
	local v3 = false
	local info = workspace:FindFirstChild("Info")

	if info then
		local barnabyVoidStage = info:GetAttribute("BarnabyVoidStage")

		if type(barnabyVoidStage) == "boolean" then
			v3 = barnabyVoidStage
		end
	end

	local v4

	if v3 then
		local success, result, voidCameraCF
		success, result, v4, voidCameraCF = pcall(buildVoidStage, adornee, self.Objects and self.Objects.Camera)

		if success and result and v4 then
			self._voidStage = result
			self.SurfaceGui.Adornee = v4
			self._voidCameraCF = voidCameraCF
		else
			v4 = adornee
		end
	else
		v4 = adornee
	end

	self._framePart = v4
	self:ApplyCameraSetting()
	self.SurfaceGui.AlwaysOnTop = true
	CharacterVisibilityHandler:SetSessionHidden(true)
	viewportFrame.CurrentCamera = camera
	self:PlaySound("MenuMusic")
	setMusicMufflersEnabled(true)
	local v5 = nil
	local shutdownSignalConnection = self.ShutdownSignal:Connect(function(p)
		v5 = p
	end)
	local success, result = pcall(function()
		self:ShowIntroAnimation()
	end)

	if not success then
		print("Intro failed to start: ", result)

		if self.Disconnected then
			return
		end
	end

	if v5 then
		if shutdownSignalConnection then
			shutdownSignalConnection:Disconnect()
		end

		return v5
	else
		self:ApplyBackgroundSetting()
		self:BindMinigameSettings()
		self:ShowMenu("MainMenu")
		GamepadService:EnableGamepadCursor(nil)
		return self.ShutdownSignal:Wait() == 1
	end
end

function SwimmyBarnaby:Start(data)
	Engine.Start(self)
	GamepadService:DisableGamepadCursor()
	self.MilestoneFired = false
	self:StopSound("MenuMusic")
	self:PlaySound("Music")
	self:SetSoundVolume("Music", 0.05)
	local videoFrame = self.SurfaceGui.Background.VideoFrame
	local _, _ = pcall(function()
		return require(script.Frames)
	end)

	if videoFrame then
		self:AddConnection(videoFrame.DidLoop:Connect(function()
			videoFrame.TimePosition = 3.6
		end))
		videoFrame:Play()
		self:ApplyBackgroundSetting()
	end

	local sessionId = self.SessionId
	self.SurfaceGui.Enabled = true
	local v3 = v2.SCREEN_WIDTH * 0.5
	local v4 = v2.SCREEN_HEIGHT * 0.5

	-- equivalent calls inferred from this helper; original call sites unknown
	local function halfExtent(p, depth)
		return p + math.abs(depth) * 0.2679491924311227
	end

	local v5 = {}
	local v6 = {}
	local v7 = 0

	for i = 1, #v5 do
		v6[i] = 0
	end

	local function spawnDecor(data2, p)
		local v8 = halfExtent(v4, data2.depth) -- equivalent call inferred; original call site unknown
		local v9 = halfExtent(v3, data2.depth) -- equivalent call inferred; original call site unknown
		local size = data2.size

		if data2.vary then
			size *= 0.6 + math.random() * 0.8
		end

		local yPos = 0

		if data2.anchor == "floor" then
			yPos = -v8 + size * 0.5

			if data2.vary then
				yPos += math.random() * (v8 * 0.5)
			end
		elseif data2.anchor == "ceiling" then
			yPos = v8 - size * 0.5
		end

		local v11 = p or v9 + size
		local decoration = data.Decoration(self, {
			Name = data2.name,
			Frames = data2.pool,
			Size = size,
			Depth = data2.depth,
			YPos = yPos,
			XOffset = v9 + size,
			DriftMul = data2.driftMul,
			Transparency = data2.transparency
		})
		decoration.Model:PivotTo(CFrame.new(v11, 0, 0))
		decoration.Model.Parent = self.Parent
		self:AddObject(decoration)
	end

	for _, v8 in ipairs(v5) do
		if not (v8.pool and #v8.pool > 0) then
			continue
		end

		local v9 = halfExtent(v3, v8.depth) -- equivalent call inferred; original call site unknown

		for i = 0, 3 do
			spawnDecor(v8, -v9 + i / 3 * (2 * v9))
		end
	end

	self:AddConnection(RunService.RenderStepped:Connect(function(dt)
		if self.SessionId ~= sessionId then
			self:Disconnect()
			return
		end

		if self._countingDown then
			return
		end

		if self:tick(dt) == -1 then
			self:Stop()
		end

		local now = tick()

		if now - v7 > self:ApplyTuningFromFlags(1.1) then
			v7 = now
			local v8 = math.random()
			local obstacle = data.Obstacle(self, v8, self.Content.Assets.BendySeaweed, false, nil)
			obstacle.Model:PivotTo(CFrame.new((v2.SCREEN_WIDTH + v2.MIN_SIZE.X * 2) * 0.5, 0, 0))
			obstacle.Model.Parent = self.Parent
			self:AddObject(obstacle)
		end

		for i, v8 in ipairs(v5) do
			if not (v8.pool and #v8.pool > 0 and now - v6[i] > v8.rate) then
				continue
			end

			v6[i] = now
			spawnDecor(v8)
		end
	end))
	local barnabyTexture = nil

	if self.myReplica and self.myReplica.Data and self.myReplica.Data.Towers then
		for _, tower in pairs(self.myReplica.Data.Towers) do
			if tower[1] ~= "Finn" then
				continue
			end

			local v9 = tower[2]

			if v9 == "Default" then
				continue
			end

			local skin = TowerLUT:GetSkin("Finn", v9)

			if skin then
				local module = require(skin)
				barnabyTexture = module.BarnabyTexture
			end

			break
		end
	end

	self.Fish = data.Fish(self, {
		Size = createVector(1, 1, 1),
		Color = Color3.new(0.3, 1, 0.3)
	}, self.Content.Assets.Barnaby, barnabyTexture)
	local info = workspace:FindFirstChild("Info")
	local v8 = 0.75
	local v9 = 0.01

	if info then
		local barnabyGravity = info:GetAttribute("BarnabyGravity")

		if type(barnabyGravity) == "number" then
			v8 = barnabyGravity
		end

		local barnabyIntroFloat = info:GetAttribute("BarnabyIntroFloat")

		if type(barnabyIntroFloat) == "number" then
			v9 = barnabyIntroFloat
		end
	end

	self.Fish:SetGravity(v8)
	self.Fish:SetIntroFloat(v9)
	self.Fish.Part:PivotTo(CFrame.new(v2.SCREEN_WIDTH * -0.45, 0, 0))
	self.Fish.Part.Parent = self.Parent
	self:AddObject(self.Fish)
	local bottom = self.ScreenGui.Bottom
	local top = self.ScreenGui.Top
	local space = Enum.KeyCode.Space
	local success, result = pcall(function()
		return require(ReplicatedStorage.SharedUtils.InputService)
	end)

	if success and result then
		local success2, result2 = pcall(function()
			return result:GetBoundKeyCode("SkillCheckTap", "Keyboard")
		end)

		if success2 and result2 then
			space = result2
		end
	else
		result = nil
	end

	local buttonA = Enum.KeyCode.ButtonA
	local v10 = UserInputService.PreferredInput == Enum.PreferredInput.Gamepad
	local v11 = UserInputService.PreferredInput == Enum.PreferredInput.Touch
	local v12 = string.upper(KeyCodeNames.toDisplay(space) or "SPACE")
	local stringForKeyCode = UserInputService:GetStringForKeyCode(buttonA)
	local v13 = (not stringForKeyCode or stringForKeyCode == "") and "A" or ({
		ButtonA = "A",
		ButtonCross = "X"
	})[stringForKeyCode] or string.upper((stringForKeyCode:gsub("^Button", "")))
	local text = v10 and v13 or v11 and "TAP" or v12
	local pressed = bottom.Mobile:FindFirstChild("Pressed")
	local unpressed = bottom.Mobile:FindFirstChild("Unpressed")
	local textLabel = pressed and pressed:FindFirstChild("TextLabel")
	local textLabel2 = unpressed and unpressed:FindFirstChild("TextLabel")

	if textLabel and textLabel2 then
		textLabel.Text = text
		textLabel2.Text = text
	else
		local textLabel3 = bottom.Mobile:FindFirstChild("TextLabel")

		if textLabel3 then
			textLabel3.Text = text
		end
	end

	bottom.Hint.Text = string.format("Press <%s> to Jump!", text)
	bottom.Hint.Visible = true
	local mobile = bottom.Mobile
	local v15 = 0

	local function attempt_jump()
		local now = tick()

		if now - v15 < 0.05 then
			return
		end

		v15 = now
		bottom.Hint.Visible = false
		self:PlaySoundOneShot("Jump")
		self.Fish:Jump()

		if pressed and unpressed then
			task.spawn(function()
				pressed.Visible = true
				unpressed.Visible = false
				task.wait(0.1)
				pressed.Visible = false
				unpressed.Visible = true
			end)
		end
	end

	self:AddConnection(UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end

		if input.KeyCode == space then
			attempt_jump()
		elseif input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			attempt_jump()
		end
	end))

	if result then
		local v16 = result:OnAction("SkillCheckTap", function()
			if result:IsTyping() then
				return
			end

			attempt_jump()
		end)

		if typeof(v16) == "RBXScriptConnection" then
			self:AddConnection(v16)
		end

		print(string.format(
			"[BarnabySkillCheck][Lobby] hint/raw key=%s  live OnAction wired=%s",
			tostring(space.Name),
			(tostring(typeof(v16) == "RBXScriptConnection"))
		))
	end

	ContextActionService:BindActionAtPriority("BarnabyArcadeJump", function(_, p)
		if p == Enum.UserInputState.Begin then
			attempt_jump()
		end

		return Enum.ContextActionResult.Sink
	end, false, Enum.ContextActionPriority.Medium.Value + 1, buttonA)
	self:AddConnection(function()
		ContextActionService:UnbindAction("BarnabyArcadeJump")
	end)
	self:AddConnection(mobile.MouseButton1Down:Connect(function()
		attempt_jump()
	end))
	top.Visible = true
	bottom.Visible = true
	top.ScoreNum.Text = "0"
end

function SwimmyBarnaby.Stop(object)
	local sessionId = object.SessionId
	GamepadService:EnableGamepadCursor(nil)
	Engine.Stop(object)
	object:SetAllowTick(false)
	object.SurfaceGui.Background.VideoFrame:Pause()
	object:SetSoundVolume("Music", 0)
	object:PlaySound("Death")
	local renderSteppedConnection = nil
	local lastTime = tick()
	local v3 = false
	local fish = object.Fish
	renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
		if fish.Destroyed then
			if renderSteppedConnection then
				renderSteppedConnection:Disconnect()
				renderSteppedConnection = nil
			end
		else
			local v4 = tick() - lastTime

			if v4 >= 3 and renderSteppedConnection then
				renderSteppedConnection:Disconnect()
				renderSteppedConnection = nil
			elseif v4 > 1 then
				if not v3 then
					fish.IsSpinning = true
					v3 = true
					fish:SetGravity(0.6)
					fish:Jump()
				end

				fish:tick(dt)
			end
		end
	end)

	if object.SessionId ~= sessionId then
		return
	end

	object.ScreenGui.Bottom.Visible = false
	task.delay(3, function()
		if object.SessionId ~= sessionId then
			return
		end

		object.ScreenGui.Top.Visible = false
		object.ColorCorrection.Saturation = -0.8
		object:PlaySound((object.Score or 0) < 1000 and "GameOverScreen" or "ProGameOverScreen")
		object:ShowMenu("GameOver")
	end)
end

function SwimmyBarnaby:Destroy()
	self:StopCabinetMirror()

	if self._minigameSettingsConns then
		for _, _minigameSettingsConn in ipairs(self._minigameSettingsConns) do
			local connection = _minigameSettingsConn
			pcall(function()
				connection:Disconnect()
			end)
		end

		self._minigameSettingsConns = nil
	end

	self._minigameSettingsBound = false
	Engine.Destroy(self)
	self.SurfaceGui:Destroy()
	self.ScreenGui:Destroy()
end

function SwimmyBarnaby:Shutdown(_: number)
	GamepadService:DisableGamepadCursor()
	self:HideAllMenus()
	self:PlaySound("Drop")
	self:StopSound("Music")
	self:StopSound("MenuMusic")
	self:StopSound("Death")
	self:StopSound("GameOverScreen")
	self:StopSound("ProGameOverScreen")
	setMusicMufflersEnabled(false)
	self:SetSoundVolume("Music", 0.05)
	self:StopCabinetMirror()

	if self.Fish then
		self.Fish:Destroy()
	end

	self:ClearObjects()
	self.SessionId = nil
	self.SurfaceGui.AlwaysOnTop = false
	local barnabyJumpBtn = self.ScreenGui:FindFirstChild("BarnabyJumpBtn", true)

	if barnabyJumpBtn then
		barnabyJumpBtn.Visible = false
	end

	local barnabyExitBtn = self.ScreenGui:FindFirstChild("BarnabyExitBtn", true)

	if barnabyExitBtn then
		barnabyExitBtn.Visible = false
	end

	local top = self.ScreenGui:FindFirstChild("Top")

	if top then
		top.Visible = false
	end

	local bottom = self.ScreenGui:FindFirstChild("Bottom")

	if bottom then
		bottom.Visible = false
	end

	CameraController:Reset()
	workspace.CurrentCamera.FieldOfView = fieldOfView or 70
	CharacterVisibilityHandler:SetSessionHidden(false)

	if self._voidStage then
		self._voidStage:Destroy()
		self._voidStage = nil
	end

	if self.Objects and self.Objects.Screen then
		self.SurfaceGui.Adornee = self.Objects.Screen
	end

	self.ColorCorrection.Saturation = 0
	self.SurfaceGui.Parent = script
	self.ScreenGui.Parent = script
end

local v3 = {
	"MenuMusic",
	"Music",
	"GameOverScreen",
	"ProGameOverScreen"
}

function SwimmyBarnaby.new(ID, p)
	local surfaceGui = p.Content.Assets:WaitForChild("SurfaceGui", 10)
	local clientUI = p.Content.Assets:WaitForChild("ClientUI", 10)

	if not (surfaceGui and clientUI) then
		warn("[SwimmyBarnaby] .new: arcade bundle missing SurfaceGui/ClientUI — aborting (place not provisioned)")
		return nil
	end

	local clone = surfaceGui:Clone()
	clone.Parent = script
	clone.Adornee = p.Objects.Screen
	local clone2 = clientUI:Clone()
	clone2.Parent = script
	local v4 = Engine.new(clone, clone2)

	if v4 then
		v4.ID = ID

		for k, v5 in pairs(p) do
			v4[k] = v5
		end

		v4.SurfaceGui = clone
		v4.ScreenGui = clone2
		v4:BindMusicMute(v3)
		v4.GAME_CONFIG = v2
		local object_creators = {
			Obstacle = require(script.Obstacle),
			Fish = require(script.Fish),
			Decoration = require(script.Decoration),
			LargeDecoration = require(script.LargeDecor)
		}
		v4.object_creators = object_creators
		v4.ShutdownSignal:Connect(function(...)
			v4:Shutdown(...)
		end)
		v4:AddMenu("MainMenu", {
			MenuOptions = {
				Start = function(p2)
					if Network:Get("PurchaseArcadeEntry", ID) then
						v4:PlaySound("MoneySpent")
						v4:SetAllowTick(true)
						v4:Start(object_creators)
					else
						local imageLabel = p2.Options.List.Start.ImageButton.Cost.ImageLabel
						local frameBG = p2.IchorFrame.FrameBG

						for i = 1, 6 do
							imageLabel.ImageColor3 = i % 2 == 1 and Color3.fromRGB(255, 100, 100) or Color3.new(1, 1, 1)
							task.wait(0.3)
						end

						for i = 1, 6 do
							frameBG.BackgroundColor3 = i % 2 == 1 and Color3.fromRGB(255, 100, 100) or Color3.new(
								0,
								0,
								0
							)
							task.wait(0.3)
						end
					end
				end,
				Leaderboard = function()
					v4:ShowMenu("Leaderboard")
				end,
				Exit = function()
					v4:SendShutdownSignal(1)
				end
			},
			OnOpen = function(p2, p3)
				local coin = p2.myReplica.Data.Coin or 0
				p3.Frame.IchorFrame.TextLabel.Text = coin
			end
		})
		local mainMenu = v4.MenuFrames:FindFirstChild("MainMenu")
		local settingsButton = mainMenu and mainMenu:FindFirstChild("SettingsButton")
		local v6 = settingsButton and (settingsButton:IsA("GuiButton") and settingsButton or settingsButton:FindFirstChildWhichIsA("GuiButton"))

		if v6 then
			v6.MouseButton1Click:Connect(function()
				v4:RunMenuOption(function()
					v4:ShowMenu("Settings")
				end)
			end)
		end

		local template = nil

		-- equivalent calls inferred from this helper; original call sites unknown
		local function ensureTemplate(parent)
			if not template then
				template = parent:WaitForChild("Template")
				template.Parent = nil
			end
		end

		local color = Color3.fromRGB(255, 249, 165)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function getLocalScore()
			local data = v4.myReplica and v4.myReplica.Data
			local statistics = data and data.Statistics
			return statistics and statistics.Highscore_SwimmyBarnaby or 0
		end

		local function buildRows(p2)
			local userId = localPlayer.UserId
			local result = {
				{
					UserId = userId,
					Name = localPlayer.Name,
					Value = getLocalScore(),
					IsLocal = true
				}
			}
			local v8 = type(p2) == "table"
			local v9 = not v8 and {} or p2.entries or {}

			for _, v10 in ipairs(v9) do
				if v10.UserId ~= userId then
					table.insert(result, {
						UserId = v10.UserId,
						Name = PlayerCache.fetchPlayerNameFromCache(v10.UserId),
						Value = v10.Value
					})
				end
			end

			table.sort(result, function(a, b)
				return a.Value > b.Value
			end)
			return result, v8 and (p2.status ~= "computing" or #v9 ~= 0) and "ready" or "loading"
		end

		local function fillOut(content, list, p2)
			ensureTemplate(content) -- equivalent call inferred; original call site unknown

			for _, child in ipairs(content:GetChildren()) do
				if string.match(child.Name, "^Frame_") then
					child:Destroy()
				end
			end

			local v7 = 0

			for i, v8 in ipairs(list) do
				local clone3 = template:Clone()
				clone3.Name = "Frame_" .. i
				clone3.LayoutOrder = i
				clone3.BackgroundColor3 = i % 2 == 0 and Color3.new(0, 0, 0) or Color3.new(0.2, 0.2, 0.2)
				clone3.Index.Text = i
				clone3.Score.Text = v8.Value or -1
				clone3.Username.Text = v8.Name or "???"

				if v8.IsLocal then
					clone3.Username.TextColor3 = color
				end

				clone3.Parent = content
				v7 = i
			end

			if p2 == "loading" then
				local clone3 = template:Clone()
				clone3.Name = "Frame_" .. v7 + 1
				clone3.LayoutOrder = v7 + 1
				clone3.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
				clone3.Index.Text = ""
				clone3.Score.Text = ""
				clone3.Username.Text = "Loading friends…"
				clone3.Parent = content
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function refreshLeaderboard(state, leaderboardMenu)
			state._leaderboardMenu = leaderboardMenu
			local content = leaderboardMenu.Frame.Content
			fillOut(content, buildRows(state._lastLeaderboardPayload))
			task.spawn(function()
				local getFriendsLeaderboard = Network:Get("GetFriendsLeaderboard", state.ID)
				state._lastLeaderboardPayload = getFriendsLeaderboard

				if leaderboardMenu.Frame:GetAttribute("Visible") then
					fillOut(content, buildRows(getFriendsLeaderboard))
				end
			end)
		end

		function v4.UpdateLeaderboard(_, lastLeaderboardPayload)
			v4._lastLeaderboardPayload = lastLeaderboardPayload
			local _leaderboardMenu = v4._leaderboardMenu

			if _leaderboardMenu and _leaderboardMenu.Frame:GetAttribute("Visible") then
				fillOut(_leaderboardMenu.Frame.Content, buildRows(lastLeaderboardPayload))
			end
		end

		v4:AddMenu("Leaderboard", {
			MenuOptions = {
				MainMenu = function()
					v4:ShowMenu("MainMenu")
				end
			},
			OnOpen = function(state, leaderboardMenu)
				refreshLeaderboard(state, leaderboardMenu) -- equivalent call inferred; original call site unknown
			end
		})
		v4:AddMenu("Settings", {
			MenuOptions = {
				MainMenu = function()
					v4:ShowMenu("MainMenu")
				end
			},
			OnOpen = function(object)
				object:RefreshSettingsLabels()
			end
		})
		local settings = v4.MenuFrames:FindFirstChild("Settings")
		local content = settings and settings:FindFirstChild("Content")

		if content then
			local perspective = content:FindFirstChild("Perspective")

			if perspective and perspective:IsA("GuiButton") then
				perspective.MouseButton1Click:Connect(function()
					Network:Post("ToggleSetting", "MinigameSettings.AngledCamera")
				end)
				local backgroundTransparency = perspective.BackgroundTransparency
				perspective.MouseEnter:Connect(function()
					perspective.BackgroundTransparency = backgroundTransparency * 0.7
				end)
				perspective.MouseLeave:Connect(function()
					perspective.BackgroundTransparency = backgroundTransparency
				end)
			end

			local background = content:FindFirstChild("Background")

			if background and background:IsA("GuiButton") then
				background.MouseButton1Click:Connect(function()
					Network:Post("ToggleSetting", "MinigameSettings.AnimatedBackground")
				end)
				local backgroundTransparency = background.BackgroundTransparency
				background.MouseEnter:Connect(function()
					background.BackgroundTransparency = backgroundTransparency * 0.7
				end)
				background.MouseLeave:Connect(function()
					background.BackgroundTransparency = backgroundTransparency
				end)
			end
		end

		v4:AddMenu("GameOver", {
			MenuOptions = {
				MainMenu = function()
					v4:ShowMenu("MainMenu")
					v4:StopSound("Death")
					v4:StopSound("GameOverScreen")
					v4:StopSound("ProGameOverScreen")
					v4.ColorCorrection.Saturation = 0
					v4:PlaySound("MenuMusic")
					v4:ClearObjects()
				end
			},
			OnOpen = function(p2, p3)
				Network:Post("SubmitArcadeScore", ID, p2.Score)
				p3.Frame.Content.TextLabel.Text = string.format("Your score was %d", p2.Score)
			end
		})
		return (setmetatable(v4, SwimmyBarnaby))
	else
		warn("[SwimmyBarnaby] .new: Engine.new failed (SurfaceGui missing Menus/ViewportFrame/WorldModel) — aborting")
		clone:Destroy()
		clone2:Destroy()
		return nil
	end
end

return SwimmyBarnaby