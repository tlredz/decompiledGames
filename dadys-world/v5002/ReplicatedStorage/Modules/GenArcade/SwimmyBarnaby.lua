local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local TowerLUT = require(ReplicatedStorage.SharedUtils.TowerLUT)
local CameraController = require(ReplicatedStorage.SharedUtils.CameraController)
local KeyCodeNames = require(ReplicatedStorage.SharedUtils.KeyCodeNames)

if RunService:IsServer() then
	print("You cannot require " .. tostring(script) .. " from the server!")
	return {}
end

local Engine = require(script.Parent:WaitForChild("Util"):WaitForChild("Engine"))
local SwimmyBarnaby = {}
SwimmyBarnaby.__index = SwimmyBarnaby
setmetatable(SwimmyBarnaby, Engine)
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local fieldOfView = nil
local cframe = CFrame.new(createVector(0, 0, 60), createVector(0, 0, 0))

local function trace(...) end

local bendySeaweed = script:WaitForChild("BendySeaweed")

if not bendySeaweed:GetAttribute("Required") then
	bendySeaweed:SetAttribute("Required", true)
	require(bendySeaweed)
end

local v = {
	SPEED = 13,
	GAP_HEIGHT = 15,
	MIN_SIZE = createVector(3, 2, 6),
	SCREEN_HEIGHT = 30,
	SCREEN_WIDTH = 30
}

function SwimmyBarnaby:IsGenMode()
	if self.GenMode ~= nil then
		return self.GenMode == true
	end

	return self.Model ~= nil and self.Model:GetAttribute("MinigameType") == "Barnaby"
end

function SwimmyBarnaby:FormatScoreText()
	if not self:IsGenMode() then
		return (tostring(self.Score))
	end

	local stats = self.Model:FindFirstChild("Stats")
	local currentAmount = stats and stats:FindFirstChild("CurrentAmount")
	local requiredAmount = stats and stats:FindFirstChild("RequiredAmount")

	if currentAmount and requiredAmount and requiredAmount.Value > 0 then
		return math.clamp(math.floor(currentAmount.Value / requiredAmount.Value * 100 + 0.5), 0, 100) .. "%"
	end

	return (tostring(self.Score))
end

function SwimmyBarnaby:_findCabinetScreenPart()
	local model = self.Model
	local v2 = type(self.SlotSuffix) ~= "string" and "" or self.SlotSuffix or ""
	local folder = model and (model:FindFirstChild("SwimmyBarnaby" .. v2) or model:FindFirstChild("SwimmyBarnaby") or model:FindFirstChild("SwimmyBarnaby_Mirror"))

	if not folder then
		return nil
	end

	local v3 = 0
	local v4 = nil

	for _, part in ipairs(folder:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		local name = string.lower(part.Name)

		if not string.find(name, "screen", 1, true) then
			continue
		end

		if string.find(name, "border", 1, true) or string.find(name, "small", 1, true) or string.find(
			name,
			"_02",
			1,
			true
		) then
			continue
		end

		local v5 = part.Size.X * part.Size.Y

		if not (v3 < v5) then
			continue
		end

		v4 = part
		v3 = v5
	end

	return v4
end

local function collectDecals(folder)
	local decals = {}

	for _, decal in ipairs(folder:GetDescendants()) do
		if decal:IsA("Decal") then
			decals[#decals + 1] = decal
		end
	end

	return decals
end

function SwimmyBarnaby:StartCabinetMirror()
	if self._mirror then
		return
	end

	local parent = self.Parent

	if not (parent and parent:IsA("WorldModel")) then
		return
	end

	local _findCabinetScreenPart = self:_findCabinetScreenPart()

	if not _findCabinetScreenPart then
		return
	end

	local surfaceGui = _findCabinetScreenPart:FindFirstChildWhichIsA("SurfaceGui") or _findCabinetScreenPart:WaitForChild(
		"SurfaceGui",
		3
	)

	if not surfaceGui then
		return
	end

	local viewportFrame = Instance.new("ViewportFrame")
	viewportFrame.Name = "BarnabyLiveMirror"
	viewportFrame.AnchorPoint = Vector2.new(0, 0)
	viewportFrame.Position = UDim2.fromScale(0, 0)
	viewportFrame.Size = UDim2.fromScale(1, 1)
	viewportFrame.BackgroundColor3 = Color3.new(0, 0, 0)
	viewportFrame.BackgroundTransparency = 0
	viewportFrame.BorderSizePixel = 0
	viewportFrame.ZIndex = 50
	viewportFrame.LightColor = Color3.new(1, 1, 1)
	local worldModel = Instance.new("WorldModel")
	worldModel.Parent = viewportFrame
	local camera = Instance.new("Camera")
	camera.CFrame = self.cam.CFrame
	camera.FieldOfView = self.cam.FieldOfView
	camera.Parent = viewportFrame
	viewportFrame.CurrentCamera = camera
	viewportFrame.Parent = surfaceGui
	local mirror = {
		vf = viewportFrame,
		wm = worldModel,
		cam = camera,
		primaryWM = parent,
		pairs = {},
		conns = {}
	}
	self._mirror = mirror

	local function addTwin(child)
		if mirror.pairs[child] or not (child:IsA("BasePart") or child:IsA("Model")) then
			return
		end

		local success, result = pcall(function()
			return child:Clone()
		end)

		if not (success and result) then
			return
		end

		for _, part in ipairs(result:GetDescendants()) do
			if not part:IsA("BasePart") then
				continue
			end

			part.Anchored = true
			part.CanCollide = false
			part.CanQuery = false
		end

		if result:IsA("BasePart") then
			result.Anchored = true
			result.CanCollide = false
			result.CanQuery = false
		end

		result.Parent = mirror.wm
		mirror.pairs[child] = {
			twin = result,
			srcDecals = collectDecals(child),
			dstDecals = collectDecals(result)
		}
	end

	local function removeTwin(p)
		local pair = mirror.pairs[p]

		if pair then
			mirror.pairs[p] = nil

			if pair.twin then
				pcall(function()
					pair.twin:Destroy()
				end)
			end
		end
	end

	for _, child in ipairs(parent:GetChildren()) do
		addTwin(child)
	end

	table.insert(mirror.conns, parent.ChildAdded:Connect(addTwin))
	table.insert(mirror.conns, parent.ChildRemoved:Connect(removeTwin))
end

function SwimmyBarnaby:UpdateCabinetMirror()
	local _mirror = self._mirror

	if not (_mirror and (_mirror.vf and _mirror.vf.Parent)) then
		return
	end

	local cam = _mirror.cam

	if cam.CFrame ~= self.cam.CFrame then
		cam.CFrame = self.cam.CFrame
	end

	if cam.FieldOfView ~= self.cam.FieldOfView then
		cam.FieldOfView = self.cam.FieldOfView
	end

	for k, pair in pairs(_mirror.pairs) do
		local twin = pair.twin

		if not (k.Parent and twin and twin.Parent) then
			continue
		end

		twin:PivotTo(k:GetPivot())
		local srcDecals = pair.srcDecals
		local dstDecals = pair.dstDecals

		for i = 1, math.min(#srcDecals, #dstDecals) do
			local srcDecal = srcDecals[i]
			local dstDecal = dstDecals[i]

			if dstDecal.Texture ~= srcDecal.Texture then
				dstDecal.Texture = srcDecal.Texture
			end

			if dstDecal.Transparency ~= srcDecal.Transparency then
				dstDecal.Transparency = srcDecal.Transparency
			end
		end
	end
end

function SwimmyBarnaby:StopCabinetMirror()
	local _mirror = self._mirror

	if not _mirror then
		return
	end

	self._mirror = nil

	for _, conn in ipairs(_mirror.conns) do
		local connection = conn
		pcall(function()
			connection:Disconnect()
		end)
	end

	for _, pair in pairs(_mirror.pairs) do
		if not pair.twin then
			continue
		end

		local v2 = pair
		pcall(function()
			v2.twin:Destroy()
		end)
	end

	_mirror.pairs = nil

	if _mirror.vf then
		pcall(function()
			_mirror.vf:Destroy()
		end)
	end
end

function SwimmyBarnaby:IncreaseScore(p)
	Engine.IncreaseScore(self, p)
	self:PlaySoundOneShot("Score")
	local top = self.ScreenGui:FindFirstChild("Top")
	local scoreNum = top and top:FindFirstChild("ScoreNum")

	if scoreNum then
		scoreNum.Text = self:FormatScoreText()
	end
end

function SwimmyBarnaby:CoinsEnabled()
	if not self:IsGenMode() then
		return false
	end

	local info = workspace:FindFirstChild("Info")
	return not info or info:GetAttribute("BarnabyCoinsEnabled") ~= false
end

function SwimmyBarnaby:HasWon()
	local model = self.Model

	if not model then
		return false
	end

	if model:GetAttribute("BarnabyScreenState") == "win" then
		return true
	end

	local stats = model:FindFirstChild("Stats")
	local currentAmount = stats and stats:FindFirstChild("CurrentAmount")
	local requiredAmount = stats and stats:FindFirstChild("RequiredAmount")
	return currentAmount and requiredAmount and requiredAmount.Value > 0 and currentAmount.Value >= requiredAmount.Value and true or false
end

function SwimmyBarnaby:ShowCountdown(p)
	local screenGui = self.ScreenGui

	if not screenGui then
		self._countingDown = false
		return
	end

	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "Countdown"
	textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	textLabel.Position = UDim2.fromScale(0.5, 0.42)
	textLabel.Size = UDim2.fromScale(0.4, 0.3)
	textLabel.BackgroundTransparency = 1
	textLabel.Font = Enum.Font.Arcade
	textLabel.TextScaled = true
	textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
	textLabel.TextStrokeTransparency = 0
	textLabel.ZIndex = 60
	textLabel.Parent = screenGui
	task.spawn(function()
		for i = p, 1, -1 do
			if self.Destroyed then
				if textLabel then
					textLabel:Destroy()
				end

				self._countingDown = false
				return
			else
				textLabel.Text = tostring(i)
				task.wait(1)
			end
		end

		textLabel.Text = "GO!"
		self._countingDown = false
		task.wait(0.5)

		if textLabel and textLabel.Parent then
			textLabel:Destroy()
		end
	end)
end

function SwimmyBarnaby:SkillCheckChance()
	local character = localPlayer.Character
	local stats = character and character:FindFirstChild("Stats")
	local skillCheckChance = stats and stats:FindFirstChild("SkillCheckChance")

	if skillCheckChance then
		return skillCheckChance.Value
	end

	return 15
end

function SwimmyBarnaby:SkillCheckFreq()
	local info = workspace:FindFirstChild("Info")
	local barnabySkillCheckFreq = info and tonumber(info:GetAttribute("BarnabySkillCheckFreq"))

	if barnabySkillCheckFreq and barnabySkillCheckFreq > 0 then
		return barnabySkillCheckFreq
	end

	return 2
end

function SwimmyBarnaby:FirstGapFreeEnabled()
	if not self:IsGenMode() then
		return false
	end

	local info = workspace:FindFirstChild("Info")
	return not info or info:GetAttribute("BarnabyFirstGapFree") ~= false
end

function SwimmyBarnaby:RollCoinThisColumn()
	if not self:CoinsEnabled() then
		return false
	end

	local skillCheckFreq = self:SkillCheckFreq()
	local now = tick()
	local v2 = now - (self._lastCoinSpawn or -1e999)
	local v3 = 4 / skillCheckFreq <= v2
	local v4 = math.min(self:SkillCheckChance() * skillCheckFreq, 100)

	if v3 and math.random(1, 100) <= v4 then
		self._lastCoinSpawn = now
		return true
	else
		return false
	end
end

function SwimmyBarnaby:JuiceEnabled()
	local info = workspace:FindFirstChild("Info")
	return not info or info:GetAttribute("BarnabyJuiceEnabled") ~= false
end

function SwimmyBarnaby:ScreenFlash(backgroundColor, value)
	local screenGui = self.ScreenGui

	if not screenGui then
		return
	end

	local frame = Instance.new("Frame")
	frame.Name = "JuiceFlash"
	frame.Size = UDim2.fromScale(1, 1)
	frame.BackgroundColor3 = backgroundColor
	frame.BackgroundTransparency = value or 0.5
	frame.BorderSizePixel = 0
	frame.ZIndex = 100
	frame.Parent = screenGui
	local tween = TweenService:Create(frame, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		BackgroundTransparency = 1
	})
	tween:Play()
	tween.Completed:Connect(function()
		frame:Destroy()
	end)
end

function SwimmyBarnaby:ShowGreatPopup()
	local screenGui = self.ScreenGui

	if not screenGui then
		return
	end

	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "GreatPopup"
	textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	textLabel.Position = UDim2.fromScale(0.5, 0.42)
	textLabel.Size = UDim2.fromScale(0, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.Text = "GREAT!"
	textLabel.Font = Enum.Font.Arcade
	textLabel.TextScaled = true
	textLabel.TextColor3 = Color3.fromRGB(255, 232, 90)
	textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
	textLabel.TextStrokeTransparency = 0
	textLabel.ZIndex = 60
	textLabel.Rotation = math.random(-6, 6)
	textLabel.Parent = screenGui
	TweenService:Create(textLabel, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.fromScale(0.5, 0.16)
	}):Play()
	task.delay(0.22, function()
		if not textLabel.Parent then
			return
		end

		local tween = TweenService:Create(
			textLabel,
			TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				Position = UDim2.fromScale(0.5, 0.3),
				TextTransparency = 1,
				TextStrokeTransparency = 1
			}
		)
		tween:Play()
		tween.Completed:Connect(function()
			textLabel:Destroy()
		end)
	end)
end

function SwimmyBarnaby:CoinVignette()
	local screenGui = self.ScreenGui

	if not screenGui then
		return
	end

	local v2 = screenGui:FindFirstChild("Vignette", true)

	if not v2 then
		local playerGui2 = localPlayer and localPlayer:FindFirstChild("PlayerGui")
		v2 = playerGui2 and playerGui2:FindFirstChild("Vignette", true)
	end

	if not (v2 and v2:IsA("ImageLabel")) then
		v2 = screenGui:FindFirstChild("BarnabyCoinVignetteFX")

		if not v2 then
			v2 = Instance.new("ImageLabel")
			v2.Name = "BarnabyCoinVignetteFX"
			v2.BackgroundTransparency = 1
			v2.Image = "rbxassetid://1039998940"
			v2.ScaleType = Enum.ScaleType.Stretch
			v2.AnchorPoint = Vector2.new(0.5, 0.5)
			v2.Position = UDim2.fromScale(0.5, 0.5)
			v2.Size = UDim2.fromScale(1, 1)
			v2.ImageTransparency = 1
			v2.ZIndex = 40
			v2.Parent = screenGui
		end
	end

	v2.ImageColor3 = Color3.fromRGB(255, 200, 0)
	v2.Visible = true

	if self._coinVigActive then
		return
	end

	self._coinVigActive = true
	v2.ImageTransparency = 1
	local tween = TweenService:Create(v2, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		ImageTransparency = 0.4
	})
	tween.Completed:Connect(function()
		local tween2 = TweenService:Create(v2, TweenInfo.new(0.7, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			ImageTransparency = 1
		})
		tween2.Completed:Connect(function()
			self._coinVigActive = false
		end)
		tween2:Play()
	end)
	tween:Play()
end

function SwimmyBarnaby:ShakeViewport()
	local info = workspace:FindFirstChild("Info")

	if not info or info:GetAttribute("BarnabyCoinShake") ~= true or not self:JuiceEnabled() then
		return
	end

	local _gameWindow = self._gameWindow or self._sceneViewport

	if not _gameWindow then
		return
	end

	if not self._shakeStart then
		self._shakeTarget = _gameWindow
		self._shakeHomePos = _gameWindow.Position
	end

	self._shakeStart = tick()
end

function SwimmyBarnaby:_applyViewportShake()
	local _shakeTarget = self._shakeTarget

	if not _shakeTarget then
		return
	end

	local _shakeHomePos = self._shakeHomePos
	local _shakeStart = self._shakeStart

	if _shakeStart then
		local v2 = tick() - _shakeStart

		if v2 >= 0.22 then
			if _shakeHomePos then
				_shakeTarget.Position = _shakeHomePos
			end

			self._shakeStart = nil
		else
			local v3 = 1 - v2 / 0.22
			local v4 = 0.011 * v3 * v3
			local v5 = math.sin(v2 * 50) * v4
			local v6 = math.cos(v2 * 43) * v4
			_shakeTarget.Position = UDim2.new(
				_shakeHomePos.X.Scale + v5,
				_shakeHomePos.X.Offset,
				_shakeHomePos.Y.Scale + v6,
				_shakeHomePos.Y.Offset
			)
		end
	elseif _shakeHomePos and _shakeTarget.Position ~= _shakeHomePos then
		_shakeTarget.Position = _shakeHomePos
	end
end

function SwimmyBarnaby:CollectCoin()
	local prompt = self.Model and self.Model:FindFirstChild("Prompt")
	local correct = prompt and prompt:FindFirstChild("Correct")

	if correct and correct:IsA("Sound") then
		correct:Play()
	else
		self:PlaySound("Score")
	end

	if self:JuiceEnabled() then
		self:ShowGreatPopup()
	end

	local info = workspace:FindFirstChild("Info")

	if info and info:GetAttribute("BarnabyCoinVignette") == true then
		self:CoinVignette()
	end

	if info and info:GetAttribute("BarnabyCoinFlash") == true then
		self:ScreenFlash(Color3.fromRGB(255, 226, 120), 0.55)
	end

	if info and info:GetAttribute("BarnabyCoinShake") == true then
		self:ShakeViewport()
	end
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

function SwimmyBarnaby:Bootup(myReplica)
	self.SessionId = tick()
	self.myReplica = myReplica
	local count = 0

	for _, child in ipairs(playerGui:GetChildren()) do
		local barnabyArcadeSession = child:GetAttribute("BarnabyArcadeSession")

		if not (barnabyArcadeSession ~= nil and barnabyArcadeSession ~= self.SessionId) then
			continue
		end

		count += 1
		local v2 = child
		pcall(function()
			v2:Destroy()
		end)
	end

	if count > 0 then
		trace(string.format(
			"Bootup id=%s session=%s — swept %d orphaned arcade GUI corpse(s) from PlayerGui ('new machine fixes bugged client' cleanup)",
			tostring(self.ID),
			tostring(self.SessionId),
			count
		))
	end

	self.SurfaceGui.Parent = playerGui
	self.ScreenGui.Parent = playerGui
	self.SurfaceGui:SetAttribute("BarnabyArcadeSession", self.SessionId)
	self.ScreenGui:SetAttribute("BarnabyArcadeSession", self.SessionId)
	trace(string.format(
		"Bootup id=%s — ClientUI hopped to PlayerGui (now Parent=%s); this is the hop that fails when the GUI 'never replicates'",
		tostring(self.ID),
		not self.ScreenGui.Parent and "nil" or self.ScreenGui.Parent.Name or "nil"
	))
	local viewportFrame = self.SurfaceGui:WaitForChild("ViewportFrame")
	self._sceneViewport = viewportFrame
	local adornee = self.SurfaceGui.Adornee
	local isGenMode = self:IsGenMode()
	fieldOfView = workspace.CurrentCamera.FieldOfView

	if isGenMode then
		self.ScreenGui.IgnoreGuiInset = true
		self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		local v2 = self.ScreenGui:FindFirstChild("GameWindow")

		if not v2 then
			v2 = Instance.new("Frame")
			v2.Name = "GameWindow"
			v2.BackgroundTransparency = 1
			v2.BorderSizePixel = 0
			v2.AnchorPoint = Vector2.new(0.5, 0.5)
			v2.ZIndex = 1
			v2.ClipsDescendants = true
			v2.Parent = self.ScreenGui
		end

		v2.Position = UDim2.fromScale(0.5, 0.45)
		v2.Size = UDim2.fromScale(0.64, 0.64)
		self._gameWindow = v2

		if not v2:FindFirstChildOfClass("UICorner") then
			local uICorner = Instance.new("UICorner")
			uICorner.CornerRadius = UDim.new(0, 0)
			uICorner.Parent = v2
		end

		viewportFrame.AnchorPoint = Vector2.new(0.5, 0.5)
		viewportFrame.Position = UDim2.fromScale(0.5, 0.5)
		viewportFrame.Size = UDim2.fromScale(0.99, 0.99)
		viewportFrame.BackgroundTransparency = 1
		viewportFrame.BorderSizePixel = 0
		viewportFrame.ZIndex = 1
		viewportFrame.Parent = v2

		if not viewportFrame:FindFirstChildOfClass("UICorner") then
			local uICorner = Instance.new("UICorner")
			uICorner.CornerRadius = UDim.new(0, 0)
			uICorner.Parent = viewportFrame
		end

		local imageLabel = Instance.new("ImageLabel")
		imageLabel.Name = "GenBezel"
		imageLabel.BackgroundTransparency = 1
		imageLabel.Size = UDim2.fromScale(1, 1)
		imageLabel.Position = UDim2.fromScale(0, 0)
		imageLabel.Image = "rbxassetid://80845848370387"
		imageLabel.ScaleType = Enum.ScaleType.Stretch
		imageLabel.ZIndex = 3
		imageLabel.Parent = v2
		local v3 = {
			"rbxassetid://4388380516",
			"rbxassetid://4388381112",
			"rbxassetid://4388381606",
			"rbxassetid://4388382104",
			"rbxassetid://4388382493",
			"rbxassetid://4388382958",
			"rbxassetid://4388383410",
			"rbxassetid://4388383891"
		}
		local v4 = v2:FindFirstChild("GenStatic")

		if not v4 then
			v4 = Instance.new("ImageLabel")
			v4.Name = "GenStatic"
			v4.BackgroundTransparency = 1
			v4.BorderSizePixel = 0
			v4.Size = UDim2.fromScale(1, 1)
			v4.Position = UDim2.fromScale(0, 0)
			v4.ScaleType = Enum.ScaleType.Stretch
			v4.ImageTransparency = 0.82
			v4.ZIndex = 2
			v4.Parent = v2
		end

		v4.Visible = false
		task.spawn(function()
			local v5 = 1

			while self.SessionId == nil and v4.Parent do
				v4.Image = v3[v5]
				v5 = v5 % #v3 + 1
				task.wait(0.065)
			end

			if v4 and v4.Parent then
				v4.Visible = false
			end
		end)
		local top = self.ScreenGui:FindFirstChild("Top")

		if top then
			top.ZIndex = 5
		end

		local bottom = self.ScreenGui:FindFirstChild("Bottom")

		if bottom then
			bottom.ZIndex = 5
		end

		for _, guiObject in ipairs(self.ScreenGui:GetDescendants()) do
			if guiObject:IsA("GuiObject") and guiObject.Name ~= "BarnabyExitBtn" then
				guiObject.Active = false
			end
		end

		self.SurfaceGui.Enabled = false
	else
		local alwaysOnTop = not isGenMode or false

		if alwaysOnTop then
			local cFrame = self.Objects.Camera and self.Objects.Camera.CFrame or CFrame.new(
				adornee.Position + adornee.CFrame.LookVector * 30,
				adornee.Position
			)
			CameraController:SetCFrame(cFrame)
			CameraController:FitPartInView(adornee)
		end

		self.SurfaceGui.AlwaysOnTop = alwaysOnTop
	end

	viewportFrame.CurrentCamera = self.cam
	self:PlaySound("MenuMusic")
	self:StopSound("MenuMusic")
	self:SetAllowTick(true)

	if self.object_creators then
		self:Start(self.object_creators)
	end

	return not self._torndown and self.ShutdownSignal:Wait() == 1
end

function SwimmyBarnaby:Start(data)
	Engine.Start(self)
	self._obstaclesSpawned = 0
	self:StopSound("MenuMusic")
	self:PlaySound("Music")
	self:SetSoundVolume("Music", 0.2)
	local videoFrame = self.SurfaceGui.Background.VideoFrame
	local isGenMode = self:IsGenMode()
	local v2 = isGenMode and true
	local success, result = pcall(function()
		return require(script.Frames)
	end)
	local v3 = success and result or nil

	if videoFrame then
		pcall(function()
			videoFrame:Pause()
		end)
		videoFrame.BackgroundColor3 = Color3.fromRGB(12, 64, 70)
		videoFrame.BackgroundTransparency = 0
		local farBackground = v3 and v3.FarBackground
		local background = self.SurfaceGui:FindFirstChild("Background")
		local _gameWindow

		if v2 then
			_gameWindow = self._gameWindow or self.ScreenGui or background
		else
			_gameWindow = background
		end

		if farBackground and farBackground ~= "" and _gameWindow and not _gameWindow:FindFirstChild("GenFarBackground") then
			local imageLabel = Instance.new("ImageLabel")
			imageLabel.Name = "GenFarBackground"
			imageLabel.BackgroundTransparency = 1
			imageLabel.BorderSizePixel = 0

			if v2 then
				imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
				imageLabel.Position = UDim2.fromScale(0.5, 0.5)
				imageLabel.Size = UDim2.fromScale(0.99, 0.99)
			else
				imageLabel.Size = UDim2.fromScale(1, 1)
				imageLabel.Position = UDim2.fromScale(0, 0)
			end

			imageLabel.Image = farBackground
			imageLabel.ScaleType = Enum.ScaleType.Stretch
			imageLabel.ImageTransparency = v2 and 0.25 or 0
			imageLabel.ZIndex = v2 and 0 or videoFrame.ZIndex
			imageLabel.Parent = _gameWindow

			if v2 and not imageLabel:FindFirstChildOfClass("UICorner") then
				local uICorner = Instance.new("UICorner")
				uICorner.CornerRadius = UDim.new(0, 0)
				uICorner.Parent = imageLabel
			end
		end

		local FG = background and background:FindFirstChild("FG")

		if FG then
			FG.Visible = false
		end
	end

	if isGenMode then
		local character = localPlayer.Character
		local stats = character and character:FindFirstChild("Stats")
		local boundarySize = stats and stats:FindFirstChild("BoundarySize")
		local v4

		if boundarySize then
			local boundarySizeModifier = stats:FindFirstChild("BoundarySizeModifier")
			v4 = boundarySize.Value * (boundarySizeModifier and boundarySizeModifier.Value or 1)
		else
			v4 = 150
		end

		local v5 = v4 / 150
		self.GAME_CONFIG = table.clone(self.GAME_CONFIG)
		self.GAME_CONFIG.GAP_HEIGHT = math.clamp(v.GAP_HEIGHT * v5, 11, 21)
		local MIN_SIZE = v.MIN_SIZE
		self.GAME_CONFIG.MIN_SIZE = Vector3.new(math.clamp(MIN_SIZE.X / v5, 2, 5), MIN_SIZE.Y, MIN_SIZE.Z)
	end

	local v4 = 0
	local sessionId = self.SessionId
	self.SurfaceGui.Enabled = not v2
	local foreground = isGenMode and self.SurfaceGui:FindFirstChild("Foreground")

	if foreground then
		foreground.BackgroundColor3 = Color3.new(0, 0, 0)
		foreground.BackgroundTransparency = 0
		TweenService:Create(foreground, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundTransparency = 1
		}):Play()
	end

	local v5 = v.SCREEN_WIDTH * 0.5
	local v6 = v.SCREEN_HEIGHT * 0.5

	-- equivalent calls inferred from this helper; original call sites unknown
	local function halfExtent(p, depth)
		return p + math.abs(depth) * 0.2679491924311227
	end

	local v7 = not (isGenMode and v3) and {} or {
		{
			name = "Shells",
			pool = v3.Shells,
			size = v3.ShellSize or 4,
			depth = -18,
			anchor = "floor",
			rate = 2.4,
			driftMul = 0.85,
			vary = true,
			transparency = 0.7
		},
		{
			name = "ShrimpoWalk",
			pool = v3.ShrimpoWalk,
			animate = true,
			fps = v3.ShrimpoWalkFPS or 3,
			size = v3.ShrimpoSize or 5,
			depth = -18,
			anchor = "floor",
			rate = 3,
			chance = 0.08,
			driftMul = 0.85,
			transparency = 0.7,
			easter = true
		}
	} or {}
	local info = workspace:FindFirstChild("Info")

	if info and info:GetAttribute("BarnabyShrimpoTest") == true then
		for _, v8 in ipairs(v7) do
			if not v8.easter then
				continue
			end

			v8.rate = 0.7
			v8.chance = nil
		end
	end

	local v8 = {}

	for i = 1, #v7 do
		v8[i] = 0
	end

	local function spawnDecor(data2, p)
		local v9 = halfExtent(v6, data2.depth) -- equivalent call inferred; original call site unknown
		local v10 = halfExtent(v5, data2.depth) -- equivalent call inferred; original call site unknown
		local size = data2.size

		if data2.vary then
			size *= 0.6 + math.random() * 0.8
		end

		local yPos = 0

		if data2.anchor == "floor" then
			yPos = -v9 + size * 0.5

			if data2.vary then
				yPos += math.random() * (v9 * 0.5)
			end
		elseif data2.anchor == "ceiling" then
			yPos = v9 - size * 0.5
		elseif data2.anchor == "float" then
			yPos = (math.random() * 2 - 1) * (v9 * 0.55)
		end

		local v12 = p or v10 + size
		local decoration = data.Decoration(self, {
			Name = data2.name,
			Frames = data2.pool,
			Size = size,
			Depth = data2.depth,
			YPos = yPos,
			XOffset = v10 + size,
			DriftMul = data2.driftMul,
			Transparency = data2.transparency,
			Animate = data2.animate,
			FPS = data2.fps
		})
		decoration.Model:PivotTo(CFrame.new(v12, 0, 0))
		decoration.Model.Parent = self.Parent
		self:AddObject(decoration)
	end

	for _, v9 in ipairs(v7) do
		if not v9.pool or not (#v9.pool > 0) or v9.chance then
			continue
		end

		local v10 = halfExtent(v5, v9.depth) -- equivalent call inferred; original call site unknown

		for i = 0, 3 do
			spawnDecor(v9, -v10 + i / 3 * (2 * v10))
		end
	end

	if isGenMode and v3 and v3.Hills and #v3.Hills > 0 then
		local hill = v3.Hills[math.random(1, #v3.Hills)]
		local v9 = v6 + 14.737205583711749
		local v10 = (v5 + 14.737205583711749) * 4 + 14
		local v11 = (v3.HillHeight or 30) + 18
		local v12 = -v9 + (v3.HillHeight or 30) * 0.5 - 5
		local v13 = v.SPEED * 0.45

		for i = 0, 1 do
			local plane = v3.buildPlane(Vector3.new(v10, v11, 0), { hill })
			plane.CFrame = CFrame.new(i * v10, v12, -55)
			plane.Parent = self.Parent
			self:AddObject({
				plane = plane,
				tick = function(self, p2)
					if self.Destroyed then
						return
					end

					local plane2 = self.plane
					local v14 = plane2.Position.X - v13 * p2

					if v14 <= -v10 then
						v14 += v10 * 2
					end

					plane2.CFrame = CFrame.new(v14, v12, -55)
				end,
				Destroy = function(p)
					p.Destroyed = true

					if p.plane then
						p.plane:Destroy()
					end
				end
			})
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

		local v9 = self:tick(dt)
		local hasWon = self:HasWon()

		if hasWon then
			local info2 = workspace:FindFirstChild("Info")

			if info2 and info2:GetAttribute("BarnabyWinAutoFly") == true and self.Fish then
				self._winFlapCd = (self._winFlapCd or 0) - dt

				if self._winFlapCd <= 0 then
					self._winFlapCd = 0.6
					pcall(function()
						self.Fish:Jump()
					end)
				end
			end
		end

		if v9 == -1 and not hasWon then
			self:Stop()
		end

		local now = tick()

		if now - v4 > self:ApplyTuningFromFlags(1.1) then
			v4 = now
			local rollCoinThisColumn = self:RollCoinThisColumn()
			local v10 = math.random()
			self._obstaclesSpawned = (self._obstaclesSpawned or 0) + 1
			local v11

			if self._obstaclesSpawned == 1 and self:FirstGapFreeEnabled() then
				local GAME_CONFIG = self.GAME_CONFIG
				v11 = math.max(GAME_CONFIG.GAP_HEIGHT, GAME_CONFIG.SCREEN_HEIGHT * 0.6)
				local v12 = GAME_CONFIG.SCREEN_HEIGHT - GAME_CONFIG.MIN_SIZE.Y * 2 - v11
				local Y = self.Fish and self.Fish.Part and self.Fish.Part.Position.Y or 0
				v10 = v12 > 0 and math.clamp(0.5 + Y / v12, 0, 1) or 0.5
			end

			local obstacle = data.Obstacle(self, v10, self.Content.Assets.BendySeaweed, rollCoinThisColumn, v11)
			obstacle.Model:PivotTo(CFrame.new((v.SCREEN_WIDTH + v.MIN_SIZE.X * 2) * 0.5, 0, 0))
			obstacle.Model.Parent = self.Parent
			self:AddObject(obstacle)
		end

		for i, v10 in ipairs(v7) do
			if not (v10.pool and #v10.pool > 0 and now - v8[i] > v10.rate) then
				continue
			end

			v8[i] = now

			if not v10.chance or math.random() <= v10.chance then
				spawnDecor(v10)
			end
		end

		self:_applyViewportShake()

		if self._mirror then
			self:UpdateCabinetMirror()
		end
	end))
	local barnabyTexture = nil

	if self.myReplica and self.myReplica.Data and self.myReplica.Data.Towers then
		for _, tower in pairs(self.myReplica.Data.Towers) do
			if tower[1] ~= "Finn" then
				continue
			end

			local v10 = tower[2]

			if v10 == "Default" then
				continue
			end

			local skin = TowerLUT:GetSkin("Finn", v10)

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
	local info2 = workspace:FindFirstChild("Info")
	local v9 = 0.75
	local v10 = 0.01

	if info2 then
		local barnabyGravity = info2:GetAttribute("BarnabyGravity")

		if type(barnabyGravity) == "number" then
			v9 = barnabyGravity
		end

		local barnabyIntroFloat = info2:GetAttribute("BarnabyIntroFloat")

		if type(barnabyIntroFloat) == "number" then
			v10 = barnabyIntroFloat
		end

		if info2:GetAttribute("BarnabyGravityFromSkillCheck") == true then
			local barnabyGravityStrength = info2:GetAttribute("BarnabyGravityStrength")
			local v11 = type(barnabyGravityStrength) ~= "number" and 0.5 or barnabyGravityStrength
			v9 *= 1 - math.clamp(self:SkillCheckChance(), 0, 100) / 100 * math.clamp(v11, 0, 1)
		end
	end

	self.Fish:SetGravity(v9)
	self.Fish:SetIntroFloat(v10)
	local info3 = workspace:FindFirstChild("Info")

	if info3 and info3:GetAttribute("BarnabyStartCountdown") == true then
		local barnabyCountdownSeconds = info3:GetAttribute("BarnabyCountdownSeconds")
		local v11 = type(barnabyCountdownSeconds) ~= "number" and 3 or barnabyCountdownSeconds
		self._countingDown = true
		self:ShowCountdown((math.clamp(math.floor(v11), 1, 5)))
	end

	self.Fish.Part:PivotTo(CFrame.new(v.SCREEN_WIDTH * -0.45, 0, 0))
	self.Fish.Part.Parent = self.Parent
	self:AddObject(self.Fish)
	local bottom = self.ScreenGui.Bottom
	local top = self.ScreenGui.Top
	local space = Enum.KeyCode.Space
	local success2, result2 = pcall(function()
		return require(ReplicatedStorage.SharedUtils.InputService)
	end)

	if success2 and result2 then
		local success3, result3 = pcall(function()
			return result2:GetBoundKeyCode("SkillCheckTap", "Keyboard")
		end)

		if success3 and result3 then
			space = result3
		end
	else
		result2 = nil
	end

	local v11 = UserInputService.PreferredInput == Enum.PreferredInput.Gamepad
	local text = string.upper(KeyCodeNames.toDisplay(space) or "SPACE")
	local v13 = "A"

	if result2 then
		local success3, result3 = pcall(function()
			return result2:GetBinding("SkillCheckTap", "Gamepad")
		end)

		if success3 and result3 then
			v13 = string.upper(KeyCodeNames.toDisplay(result3) or "A")
		end
	end

	if v11 then
		text = v13 or text
	end

	local mobile = bottom:FindFirstChild("Mobile")
	local pressed = mobile and mobile:FindFirstChild("Pressed")
	local unpressed = mobile and mobile:FindFirstChild("Unpressed")
	local textLabel = pressed and pressed:FindFirstChild("TextLabel")
	local textLabel2 = unpressed and unpressed:FindFirstChild("TextLabel")

	if textLabel and textLabel2 then
		textLabel.Text = text
		textLabel2.Text = text
	else
		local textLabel3 = mobile and mobile:FindFirstChild("TextLabel")

		if textLabel3 then
			textLabel3.Text = text
		end
	end

	local hint = bottom:FindFirstChild("Hint")

	if hint then
		hint.Text = string.format("Press <%s> to Jump!", text)
		hint.Visible = not isGenMode
	end

	local v14 = 0

	local function attempt_jump()
		local now = os.clock()

		if now - v14 < 0.05 then
			return
		end

		v14 = now

		if hint then
			hint.Visible = false
		end

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
		end
	end))

	if result2 then
		pcall(function()
			local StickerController = require(ReplicatedStorage.Modules.ClientUI.StickerController)

			if StickerController.SuppressWheel and not self._torndown then
				if self._stickerWheelRelease then
					self._stickerWheelRelease()
				end

				self._stickerWheelRelease = StickerController.SuppressWheel()
			end
		end)
		local v15 = result2:OnAction("SkillCheckTap", function()
			if result2:IsTyping() then
				return
			end

			attempt_jump()
		end)

		if typeof(v15) == "RBXScriptConnection" then
			self:AddConnection(v15)
		end

		print(string.format(
			"[BarnabySkillCheck] gen-mode=%s  hint/raw key=%s  live OnAction wired=%s",
			tostring(isGenMode),
			tostring(space.Name),
			(tostring(typeof(v15) == "RBXScriptConnection"))
		))
	end

	if mobile then
		self:AddConnection(mobile.MouseButton1Down:Connect(function()
			attempt_jump()
		end))
	end

	if isGenMode then
		local mobile2 = bottom:FindFirstChild("Mobile")

		if mobile2 then
			mobile2.Parent = v2 and self._gameWindow or self.ScreenGui
			mobile2.AnchorPoint = Vector2.new(0, 0)
			mobile2.Position = UDim2.fromScale(0, 0)
			mobile2.Size = UDim2.fromScale(1, 1)
			mobile2.BackgroundTransparency = 1
			mobile2.AutoButtonColor = false
			mobile2.Text = ""
			mobile2.Visible = true
			mobile2.BorderSizePixel = 0
			mobile2.ZIndex = v2 and 2 or 0
			mobile2.Active = false
			local textLabel3 = mobile2:FindFirstChild("TextLabel")

			if textLabel3 then
				textLabel3.Visible = false
			end

			for _, uIStroke in ipairs(mobile2:GetDescendants()) do
				if uIStroke:IsA("UIStroke") then
					uIStroke.Enabled = false
				end
			end

			self:AddConnection(UserInputService.InputBegan:Connect(function(input, gameProcessed)
				if gameProcessed then
					return
				end

				local userInputType = input.UserInputType

				if userInputType ~= Enum.UserInputType.MouseButton1 and userInputType ~= Enum.UserInputType.Touch then
					return
				end

				local absolutePosition = mobile2.AbsolutePosition
				local absoluteSize = mobile2.AbsoluteSize
				local X = input.Position.X
				local Y = input.Position.Y

				if absolutePosition.X <= X and X <= absolutePosition.X + absoluteSize.X and absolutePosition.Y <= Y and Y <= absolutePosition.Y + absoluteSize.Y then
					attempt_jump()
				end
			end))
		end

		top.Visible = false

		if v2 and self._gameWindow then
			local _gameWindow = self._gameWindow
			self._won = false
			local parent = _gameWindow:FindFirstChild("GenFillText")

			if not parent then
				parent = Instance.new("TextLabel")
				parent.Name = "GenFillText"
				parent.AnchorPoint = Vector2.new(0, 0)
				parent.Position = UDim2.fromScale(0.03, 0.04)
				parent.Size = UDim2.fromScale(0.34, 0.13)
				parent.BackgroundTransparency = 1
				parent.Font = Enum.Font.Arcade
				parent.Text = "0%"
				parent.TextScaled = true
				parent.TextXAlignment = Enum.TextXAlignment.Left
				parent.TextYAlignment = Enum.TextYAlignment.Top
				parent.TextColor3 = Color3.fromRGB(150, 255, 180)
				parent.ZIndex = 9
				local uIStroke = Instance.new("UIStroke")
				uIStroke.Color = Color3.new(0, 0, 0)
				uIStroke.Thickness = 2
				uIStroke.Parent = parent
				parent.Parent = _gameWindow
			end

			local function refreshFillVisibility()
				local info4 = workspace:FindFirstChild("Info")
				parent.Visible = info4 ~= nil and info4:GetAttribute("BarnabyShowFillPct") == true
			end

			local info4 = workspace:FindFirstChild("Info")
			local visible

			if info4 == nil then
				visible = false
			else
				visible = info4:GetAttribute("BarnabyShowFillPct") == true
			end

			parent.Visible = visible
			local info5 = workspace:FindFirstChild("Info")

			if info5 then
				self:AddConnection(info5:GetAttributeChangedSignal("BarnabyShowFillPct"):Connect(refreshFillVisibility))
			end

			local parent2 = _gameWindow:FindFirstChild("GenWinText")

			if not parent2 then
				parent2 = Instance.new("TextLabel")
				parent2.Name = "GenWinText"
				parent2.AnchorPoint = Vector2.new(0.5, 0.5)
				parent2.Position = UDim2.fromScale(0.5, 0.42)
				parent2.Size = UDim2.fromScale(0.92, 0.26)
				parent2.BackgroundTransparency = 1
				parent2.Font = Enum.Font.Arcade
				parent2.Text = "YOU WIN!"
				parent2.TextScaled = true
				parent2.TextColor3 = Color3.fromRGB(120, 255, 170)
				parent2.ZIndex = 12
				local uIStroke = Instance.new("UIStroke")
				uIStroke.Color = Color3.new(0, 0, 0)
				uIStroke.Thickness = 3
				uIStroke.Parent = parent2
				parent2.Parent = _gameWindow
			end

			parent2.Visible = false
			local genLoseText = _gameWindow:FindFirstChild("GenLoseText")

			if genLoseText then
				genLoseText.Visible = false
			end

			local parent3 = _gameWindow:FindFirstChild("GenInstr")

			if not parent3 then
				parent3 = Instance.new("TextLabel")
				parent3.Name = "GenInstr"
				parent3.AnchorPoint = Vector2.new(0.5, 1)
				parent3.Position = UDim2.fromScale(0.5, 0.97)
				parent3.Size = UDim2.fromScale(0.92, 0.07)
				parent3.BackgroundTransparency = 1
				parent3.Font = Enum.Font.Arcade
				parent3.TextScaled = true
				parent3.TextColor3 = Color3.fromRGB(150, 255, 180)
				parent3.ZIndex = 9
				local uIStroke = Instance.new("UIStroke")
				uIStroke.Color = Color3.new(0, 0, 0)
				uIStroke.Thickness = 2
				uIStroke.Parent = parent3
				parent3.Parent = _gameWindow
			end

			parent3.Text = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled and "TAP THE SCREEN TO SWIM UP  -  DODGE THE SEAWEED!" or "TAP THE SCREEN OR PRESS " .. tostring(text) .. " TO SWIM UP  -  DODGE THE SEAWEED!"
			local stats = self.Model and self.Model:FindFirstChild("Stats")
			local currentAmount = stats and stats:FindFirstChild("CurrentAmount")
			local requiredAmount = stats and stats:FindFirstChild("RequiredAmount")

			local function refresh()
				if parent then
					parent.Text = self:FormatScoreText()
				end

				if currentAmount and requiredAmount and requiredAmount.Value > 0 and currentAmount.Value >= requiredAmount.Value and not self._won then
					self._won = true
					parent2.Visible = true
					pcall(function()
						self:PlaySound("Score")
					end)
				end
			end

			refresh()

			if currentAmount then
				self:AddConnection(currentAmount:GetPropertyChangedSignal("Value"):Connect(refresh))
			end
		end

		for _, childName in ipairs({ "BarnabyJumpBtn", "BarnabyExitBtn" }) do
			local child = self.ScreenGui:FindFirstChild(childName, true)

			if child then
				child:Destroy()
			end
		end

		local UI = ReplicatedStorage:FindFirstChild("UI")
		local barnabyExitBtn = UI and UI:FindFirstChild("BarnabyExitBtn")
		local parent4

		if barnabyExitBtn then
			parent4 = barnabyExitBtn:Clone()
		else
			parent4 = Instance.new("TextButton")
			parent4.Name = "BarnabyExitBtn"
			parent4.AnchorPoint = Vector2.new(0, 0)
			parent4.Position = UDim2.new(0.392585635, 0, 0.88, 0)
			parent4.Size = UDim2.new(0.21470958, 0, 0.06445086, 0)
			parent4.BackgroundColor3 = Color3.fromRGB(120, 22, 22)
			parent4.BackgroundTransparency = 0
			parent4.AutoButtonColor = true
			parent4.BorderSizePixel = 0
			parent4.Font = Enum.Font.Arcade
			parent4.Text = "EXIT"
			parent4.TextScaled = true
			parent4.TextColor3 = Color3.fromRGB(255, 80, 80)
			parent4.TextStrokeColor3 = Color3.new(0, 0, 0)
			parent4.TextStrokeTransparency = 0
			parent4.ZIndex = 6
			local uICorner = Instance.new("UICorner")
			uICorner.CornerRadius = UDim.new(0, 8)
			uICorner.Parent = parent4
			local uIStroke = Instance.new("UIStroke")
			uIStroke.Color = Color3.fromRGB(255, 60, 60)
			uIStroke.Thickness = 2
			uIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			uIStroke.Parent = parent4
		end

		parent4.Selectable = false
		parent4.Parent = self.ScreenGui
		local events = ReplicatedStorage:FindFirstChild("Events")
		local barnabyLeaveEvent = events and events:FindFirstChild("BarnabyLeaveEvent")

		if barnabyLeaveEvent then
			self:AddConnection(parent4.Activated:Connect(function()
				barnabyLeaveEvent:FireServer(self.ID)
				self:SendShutdownSignal(-1)
			end))

			if result2 then
				local v16 = result2:OnAction("GeneratorStop", function()
					if result2:IsTyping() then
						return
					end

					barnabyLeaveEvent:FireServer(self.ID)
					self:SendShutdownSignal(-1)
				end)

				if typeof(v16) == "RBXScriptConnection" then
					self:AddConnection(v16)
				end
			end
		end
	else
		top.Visible = true
		bottom.Visible = true
		local scoreNum = top:FindFirstChild("ScoreNum")

		if scoreNum then
			scoreNum.Text = "0"
		end
	end
end

function SwimmyBarnaby:Stop()
	local sessionId = self.SessionId
	Engine.Stop(self)
	self:SetAllowTick(false)
	local background = self.SurfaceGui:FindFirstChild("Background")
	local videoFrame = background and background:FindFirstChildOfClass("VideoFrame")

	if videoFrame then
		videoFrame:Pause()
	end

	self.DiedInGenMode = true
	self:SetSoundVolume("Music", 0)
	self:PlaySound("Death")
	local _gameWindow = self._gameWindow or self.ScreenGui

	if _gameWindow then
		local parent = _gameWindow:FindFirstChild("GenLoseText")

		if not parent then
			parent = Instance.new("TextLabel")
			parent.Name = "GenLoseText"
			parent.AnchorPoint = Vector2.new(0.5, 0.5)
			parent.Position = UDim2.fromScale(0.5, 0.42)
			parent.Size = UDim2.fromScale(0.92, 0.26)
			parent.BackgroundTransparency = 1
			parent.Font = Enum.Font.Arcade
			parent.Text = "GAME OVER"
			parent.TextScaled = true
			parent.TextColor3 = Color3.fromRGB(255, 90, 90)
			parent.ZIndex = 12
			local uIStroke = Instance.new("UIStroke")
			uIStroke.Color = Color3.new(0, 0, 0)
			uIStroke.Thickness = 3
			uIStroke.Parent = parent
			parent.Parent = _gameWindow
		end

		parent.Visible = true
	end

	pcall(function()
		self.ColorCorrection.Saturation = -0.8
	end)
	local fish = self.Fish

	if fish then
		local lastTime = tick()
		local v2 = false
		local renderSteppedConnection = nil
		renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
			if fish and not fish.Destroyed then
				if tick() - lastTime >= 1 then
					if renderSteppedConnection then
						renderSteppedConnection:Disconnect()
						renderSteppedConnection = nil
					end
				else
					if not v2 then
						fish.IsSpinning = true
						v2 = true
						fish:SetGravity(0.6)
						fish:Jump()
					end

					fish:tick(dt)
				end
			elseif renderSteppedConnection then
				renderSteppedConnection:Disconnect()
				renderSteppedConnection = nil
			end
		end)
	end

	task.delay(1, function()
		if self.SessionId ~= sessionId then
			return
		end

		pcall(function()
			self.ColorCorrection.Saturation = 0
		end)
		self:SendShutdownSignal(2)
	end)
end

function SwimmyBarnaby:Destroy()
	self:StopCabinetMirror()
	Engine.Destroy(self)
	self.SurfaceGui:Destroy()
	self.ScreenGui:Destroy()
end

function SwimmyBarnaby:Shutdown(_: number)
	if self._torndown then
		return
	end

	self._torndown = true
	trace(string.format(
		"Shutdown id=%s session=%s — tearing down (destroying own GUIs + camera)",
		tostring(self.ID),
		(tostring(self.SessionId))
	))

	if self._stickerWheelRelease then
		self._stickerWheelRelease()
		self._stickerWheelRelease = nil
	end

	self:HideAllMenus()
	self:PlaySound("Drop")
	self:StopSound("Music")
	self:StopSound("MenuMusic")
	self:StopSound("Death")
	self:StopSound("GameOverScreen")
	self:SetSoundVolume("Music", 0.2)
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

	if not self:IsGenMode() then
		pcall(function()
			CameraController:Reset()
		end)
		pcall(function()
			workspace.CurrentCamera.FieldOfView = fieldOfView or 70
		end)
	end

	pcall(function()
		self.ColorCorrection.Saturation = 0
	end)
	pcall(function()
		if self.cam then
			self.cam:Destroy()
		end
	end)
	pcall(function()
		self.SurfaceGui:Destroy()
	end)
	pcall(function()
		self.ScreenGui:Destroy()
	end)
end

local v2 = {
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
	trace(string.format(
		".new id=%s — cloned SurfaceGui+ClientUI under script (sg=%s cu=%s); awaiting Bootup hop to PlayerGui",
		tostring(ID),
		tostring(clone ~= nil),
		(tostring(clone2 ~= nil))
	))
	local v3 = Engine.new(clone, clone2)

	if v3 then
		v3.ID = ID

		for k, v4 in pairs(p) do
			v3[k] = v4
		end

		v3.SurfaceGui = clone
		v3.ScreenGui = clone2
		v3:BindMusicMute(v2)
		v3.cam = Instance.new("Camera")
		v3.cam.CFrame = cframe
		v3.cam.FieldOfView = 30
		v3.GAME_CONFIG = v
		v3.object_creators = {
			Obstacle = require(script.Obstacle),
			Fish = require(script.Fish),
			Decoration = require(script.Decoration),
			LargeDecoration = require(script.LargeDecor)
		}
		v3.ShutdownSignal:Connect(function(...)
			v3:Shutdown(...)
		end)
		return (setmetatable(v3, SwimmyBarnaby))
	else
		warn("[SwimmyBarnaby] .new: Engine.new failed (SurfaceGui missing Menus/ViewportFrame/WorldModel) — aborting")
		clone:Destroy()
		clone2:Destroy()
		return nil
	end
end

return SwimmyBarnaby