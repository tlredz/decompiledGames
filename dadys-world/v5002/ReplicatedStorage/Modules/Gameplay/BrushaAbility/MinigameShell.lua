local createVector = vector.create
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CameraAuthority = require(ReplicatedStorage.SharedUtils.CameraAuthority)
local CameraController = require(ReplicatedStorage.SharedUtils.CameraController)
local InputService = require(ReplicatedStorage.SharedUtils.InputService)
local SwipeHint = require(ReplicatedStorage.Modules.UI.SwipeHint)
local TowerLUT = require(ReplicatedStorage.SharedUtils.TowerLUT)
local localPlayer = Players.LocalPlayer
local MinigameShell = {}
MinigameShell.__index = MinigameShell
local color = Color3.fromRGB(81, 81, 81)
local cframe = CFrame.Angles(-1.2566370614359172, 0, 0)
local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
MinigameShell.RESULT_HOLD = 0.5
MinigameShell.RESULT_FADE = 0.35
MinigameShell.Z = {
	GHOST = 0,
	CANVAS = 1,
	SPLOTCH = 2,
	VIEWPORT = 3,
	RESULT = 4,
	TIMER = 5
}
local v = {
	zIndex = MinigameShell.Z.TIMER,
	startDirection = -1,
	introTweenInfo = TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
	fadeTweenInfo = TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	slideTweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
	fadeOutTweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
	loopGap = 0.25
}
local v2 = {
	[Enum.UserInputType.Gamepad1] = true,
	[Enum.UserInputType.Gamepad2] = true,
	[Enum.UserInputType.Gamepad3] = true,
	[Enum.UserInputType.Gamepad4] = true,
	[Enum.UserInputType.Gamepad5] = true,
	[Enum.UserInputType.Gamepad6] = true,
	[Enum.UserInputType.Gamepad7] = true,
	[Enum.UserInputType.Gamepad8] = true
}
local v3 = {}
local v4 = nil

local function getStyleController(instance)
	if v4 then
		return v4
	end

	local stylesheets = instance:FindFirstChild("Stylesheets")

	if not stylesheets then
		return nil
	end

	local success, result = pcall(function()
		local styleController = require(ReplicatedStorage.SharedUtils.styleController)
		return styleController.new(stylesheets)
	end)

	if success then
		v4 = result
		return result
	end

	warn("[BrushaMinigameShell] styleController unavailable:", result)
	return nil
end

local function applyStyle(brushaAbilityUI, p, p2)
	if not p or v3[p2] then
		return
	end

	v3[p2] = true
	local styleController = getStyleController(brushaAbilityUI)

	if not styleController then
		return
	end

	local success, result = pcall(function()
		styleController:Apply(p, p2)
	end)

	if not success then
		warn(string.format(
			"[BrushaMinigameShell] '%s' stylesheet failed — %s keeps its Studio look. %s",
			p2,
			p.Name,
			(tostring(result))
		))
	end
end

local function requireModule(instance)
	if not instance then
		return nil
	end

	local success, result = pcall(require, instance)

	if success then
		return result
	end

	warn("[BrushaMinigameShell] failed to require " .. instance:GetFullName() .. ":", result)
	return nil
end

function MinigameShell.resolvePaintInfo(instance)
	local currentSkin = instance and instance:GetAttribute("CurrentSkin")

	if currentSkin and currentSkin ~= "" then
		local skin = TowerLUT:GetSkin("Brusha", currentSkin)
		local result

		if skin then
			local success
			success, result = pcall(require, skin)

			if not success then
				warn("[BrushaMinigameShell] failed to require " .. skin:GetFullName() .. ":", result)
				result = nil
			end
		end

		if result and result.PaintInfo then
			return result.PaintInfo
		end
	end

	local tower = TowerLUT:GetTower("Brusha")
	local result

	if not tower then
		return result and result.PaintInfo or nil
	end

	local success
	success, result = pcall(require, tower)

	if not success then
		warn("[BrushaMinigameShell] failed to require " .. tower:GetFullName() .. ":", result)
		result = nil
	end

	return result and result.PaintInfo or nil
end

local function findBrushGeo(instance)
	local brush_Geo = instance and instance:FindFirstChild("Brush_Geo", true)

	if brush_Geo and brush_Geo:IsA("MeshPart") then
		return brush_Geo
	end

	return nil
end

local vector2 = nil
local vector3 = nil

local function viewportSize()
	local currentCamera = workspace.CurrentCamera
	local viewportSize2 = currentCamera and currentCamera.ViewportSize

	if viewportSize2 and not (viewportSize2.X <= 0 or viewportSize2.Y <= 0) then
		return viewportSize2
	end

	return nil
end

local function mouseAlpha()
	local currentCamera = workspace.CurrentCamera
	local viewportSize2 = currentCamera and currentCamera.ViewportSize

	if not viewportSize2 or viewportSize2.X <= 0 or viewportSize2.Y <= 0 then
		viewportSize2 = nil
	end

	if not viewportSize2 then
		return Vector2.new(0.5, 0.5)
	end

	local mouseLocation = UserInputService:GetMouseLocation()
	return Vector2.new(
		math.clamp(mouseLocation.X / viewportSize2.X, 0, 1),
		(math.clamp(mouseLocation.Y / viewportSize2.Y, 0, 1))
	)
end

local function currentAlpha(gamepadRange)
	local lastInputType = UserInputService:GetLastInputType()

	if v2[lastInputType] and vector3 then
		if gamepadRange and gamepadRange ~= 1 then
			return Vector2.new(0.5 + (vector3.X - 0.5) * gamepadRange, 0.5 + (vector3.Y - 0.5) * gamepadRange)
		end

		return vector3
	elseif lastInputType == Enum.UserInputType.Touch and vector2 then
		return vector2
	else
		return mouseAlpha()
	end
end

local function noteInput(data, p)
	if p then
		return
	end

	if data.UserInputType == Enum.UserInputType.Touch then
		local currentCamera = workspace.CurrentCamera
		local viewportSize2 = currentCamera and currentCamera.ViewportSize

		if not viewportSize2 or viewportSize2.X <= 0 or viewportSize2.Y <= 0 then
			viewportSize2 = nil
		end

		if viewportSize2 then
			local v5 = UserInputService.PreferredInput == Enum.PreferredInput.Touch and 50 or 0
			vector2 = Vector2.new(
				math.clamp(data.Position.X / viewportSize2.X, 0, 1),
				(math.clamp((data.Position.Y + v5) / viewportSize2.Y, 0, 1))
			)
		end
	elseif data.KeyCode == Enum.KeyCode.Thumbstick2 then
		vector3 = Vector2.new(
			math.clamp((data.Position.X + 1) / 2, 0, 1),
			(math.clamp((1 - data.Position.Y) / 2, 0, 1))
		)
	end
end

local function planeTarget(p)
	local currentCamera = workspace.CurrentCamera
	local currentCamera2 = workspace.CurrentCamera
	local viewportSize2 = currentCamera2 and currentCamera2.ViewportSize

	if not viewportSize2 or viewportSize2.X <= 0 or viewportSize2.Y <= 0 then
		viewportSize2 = nil
	end

	if not (currentCamera and viewportSize2) then
		return nil
	end

	local viewportPointToRay = currentCamera:ViewportPointToRay(0, 0)
	local viewportPointToRay2 = currentCamera:ViewportPointToRay(viewportSize2.X, viewportSize2.Y)
	local v5 = viewportPointToRay.Origin + viewportPointToRay.Direction * 6
	local v6 = viewportPointToRay2.Origin + viewportPointToRay2.Direction * 6
	local rightVector = currentCamera.CFrame.RightVector
	local upVector = currentCamera.CFrame.UpVector
	local vector4 = v6 - v5
	local dot = vector4:Dot(rightVector)
	return v5 + rightVector * (dot * p.X) - upVector * (-vector4:Dot(upVector) * p.Y), dot
end

local function buildCanvas(brushaAbilityUI)
	local frame = Instance.new("Frame")
	frame.Name = "BrushaCanvas"
	frame.Size = UDim2.fromScale(0.6, 0.6)
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.Position = UDim2.fromScale(0.5, 0.5)
	frame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	frame.ZIndex = MinigameShell.Z.CANVAS
	frame.Parent = brushaAbilityUI
	local uIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	uIAspectRatioConstraint.AspectRatio = 1
	uIAspectRatioConstraint.Parent = frame
	return frame
end

local function buildViewport(brushaAbilityUI, brush_Geo)
	local viewportFrame = Instance.new("ViewportFrame")
	viewportFrame.Name = "BrushaBrushViewport"
	viewportFrame.Size = UDim2.fromScale(1, 1)
	viewportFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	viewportFrame.Position = UDim2.fromScale(0.5, 0.5)
	viewportFrame.BackgroundColor3 = Color3.new(0, 0, 0)
	viewportFrame.BackgroundTransparency = 1
	viewportFrame.BorderSizePixel = 0
	viewportFrame.Ambient = color
	viewportFrame.ZIndex = MinigameShell.Z.VIEWPORT
	viewportFrame.CurrentCamera = workspace.CurrentCamera
	viewportFrame.Parent = brushaAbilityUI
	local worldModel = Instance.new("WorldModel")
	worldModel.Name = "BrushaWorld"
	worldModel.Parent = viewportFrame
	local part = Instance.new("Part")
	part.Name = "Brush"
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Size = createVector(1, 1, 1)
	part.Transparency = 0
	part.Parent = worldModel
	local specialMesh = Instance.new("SpecialMesh")
	specialMesh.MeshType = Enum.MeshType.FileMesh
	specialMesh.MeshId = brush_Geo.MeshId
	specialMesh.TextureId = brush_Geo.TextureID
	specialMesh.Scale = createVector(1, 1, 1)
	specialMesh.Parent = part
	return viewportFrame, part
end

local function buildSplotchLayer(parent)
	local frame = Instance.new("Frame")
	frame.Name = "BrushaSplotches"
	frame.Size = UDim2.fromScale(1, 1)
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	frame.ClipsDescendants = false
	frame.ZIndex = MinigameShell.Z.SPLOTCH
	frame.Parent = parent
	return frame
end

local function findResultLabel(instance)
	local brushaResult = instance:FindFirstChild("BrushaResult")

	if not brushaResult then
		warn("[BrushaMinigameShell] BrushaResult label missing — no result text this run")
		return nil
	end

	brushaResult.TextTransparency = 1
	brushaResult.Text = ""
	brushaResult.Visible = false
	brushaResult.ZIndex = MinigameShell.Z.RESULT
	local uIStroke = brushaResult:FindFirstChildOfClass("UIStroke")

	if uIStroke then
		uIStroke.Transparency = 1
	end

	return brushaResult, uIStroke
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setResultGradient(resultLabel, enabled)
	if not resultLabel then
		return
	end

	local uIGradient = resultLabel:FindFirstChild("UIGradient")
	local uIGradientWin = resultLabel:FindFirstChild("UIGradientWin")

	if uIGradient then
		uIGradient.Enabled = not enabled
	end

	if uIGradientWin then
		uIGradientWin.Enabled = enabled
	end
end

function MinigameShell.open(p)
	local character = p.character or localPlayer and localPlayer.Character

	if not character then
		return nil, "no character"
	end

	local paintInfo = MinigameShell.resolvePaintInfo(character)

	if not paintInfo then
		return nil, "no PaintInfo resolved"
	end

	local brush_Geo = character and character:FindFirstChild("Brush_Geo", true)

	if not (brush_Geo and brush_Geo:IsA("MeshPart")) then
		brush_Geo = nil
	end

	if not brush_Geo then
		return nil, "Brush_Geo not found on the character"
	end

	local playerGui = localPlayer and localPlayer:FindFirstChildOfClass("PlayerGui")
	local brushaAbilityUI = playerGui and playerGui:WaitForChild("BrushaAbilityUI", 5)

	if not brushaAbilityUI then
		return nil, "BrushaAbilityUI missing from PlayerGui"
	end

	local timerBar = brushaAbilityUI:FindFirstChild("TimerBar")
	local directionIndicator = brushaAbilityUI:FindFirstChild("DirectionIndicator")
	local hint = brushaAbilityUI:FindFirstChild("Hint")
	local object = setmetatable({
		gui = brushaAbilityUI,
		paintInfo = paintInfo,
		character = character,
		timerBar = timerBar,
		timerFill = timerBar and timerBar:FindFirstChild("Fill"),
		progressText = timerBar and timerBar:FindFirstChild("ProgressText"),
		directionIndicator = directionIndicator,
		hint = hint,
		painting = true,
		splotchClock = 0,
		swipeHintIdle = 0,
		brushSwing = 0,
		gamepadRange = 0.5
	}, MinigameShell)
	object.canvas = buildCanvas(brushaAbilityUI)
	local frame = Instance.new("Frame")
	frame.Name = "BrushaSplotches"
	frame.Size = UDim2.fromScale(1, 1)
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	frame.ClipsDescendants = false
	frame.ZIndex = MinigameShell.Z.SPLOTCH
	frame.Parent = brushaAbilityUI
	object.splotchLayer = frame
	local viewport, brush = buildViewport(brushaAbilityUI, brush_Geo)
	object.viewport = viewport
	object.brush = brush
	local brushaResult = brushaAbilityUI:FindFirstChild("BrushaResult")
	local uIStroke

	if brushaResult then
		brushaResult.TextTransparency = 1
		brushaResult.Text = ""
		brushaResult.Visible = false
		brushaResult.ZIndex = MinigameShell.Z.RESULT
		uIStroke = brushaResult:FindFirstChildOfClass("UIStroke")

		if uIStroke then
			uIStroke.Transparency = 1
		end
	else
		warn("[BrushaMinigameShell] BrushaResult label missing — no result text this run")
		brushaResult = nil
	end

	object.resultLabel = brushaResult
	object.resultStroke = uIStroke
	object.brushPosition = planeTarget(Vector2.new(0.5, 0.5)) or createVector(0, 0, 0)
	applyStyle(brushaAbilityUI, timerBar, "timerBar")
	applyStyle(brushaAbilityUI, directionIndicator, "directionIndicator")

	if timerBar then
		timerBar.ZIndex = MinigameShell.Z.TIMER
		timerBar.Visible = true
	end

	if directionIndicator then
		directionIndicator.ZIndex = MinigameShell.Z.TIMER
		directionIndicator.Visible = false
	end

	if hint then
		hint.ZIndex = MinigameShell.Z.TIMER
		hint.Text = ""
		hint.Visible = false
	end

	brushaAbilityUI.Enabled = true
	UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	CameraAuthority.setRotationEnabled("BrushaMinigame", false)
	CameraController:LockOrientation()
	vector2 = nil
	vector3 = nil
	object.inputBegan = UserInputService.InputBegan:Connect(noteInput)
	object.inputChanged = UserInputService.InputChanged:Connect(noteInput)
	return object
end

function MinigameShell:close()
	if self.closed then
		return
	end

	self.closed = true
	UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	CameraController:UnlockOrientation()
	CameraAuthority.setRotationEnabled("BrushaMinigame", true)

	if self.inputBegan then
		self.inputBegan:Disconnect()
	end

	if self.inputChanged then
		self.inputChanged:Disconnect()
	end

	if self.hintConnection then
		self.hintConnection:Disconnect()
		self.hintConnection = nil
	end

	if self.swipeHint then
		self.swipeHint:destroy()
		self.swipeHint = nil
	end

	for _, v5 in ipairs({ self.canvas, self.splotchLayer, self.viewport }) do
		if v5 then
			v5:Destroy()
		end
	end

	self.ghost = nil

	if self.resultLabel then
		self.resultLabel.Visible = false
		self.resultLabel.TextTransparency = 1
		self.resultLabel.Text = ""
	end

	if self.resultStroke then
		self.resultStroke.Transparency = 1
	end

	if self.timerBar then
		self.timerBar.Visible = false
	end

	if self.directionIndicator then
		self.directionIndicator.Visible = false
	end

	if self.hint then
		self.hint.Visible = false
		self.hint.Text = ""
	end

	if self.gui then
		self.gui.Enabled = false
	end
end

function MinigameShell:_spawnSplotch()
	local currentCamera = workspace.CurrentCamera

	if not (currentCamera and self.splotchLayer.Parent) then
		return
	end

	local colors = self.paintInfo.Colors

	if not colors or #colors == 0 then
		return
	end

	local worldToViewportPoint, v5 = currentCamera:WorldToViewportPoint(self.brush.Position)

	if not v5 then
		return
	end

	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Image = "rbxassetid://81703944225345"
	imageLabel.ImageColor3 = colors[math.random(1, #colors)]
	imageLabel.BackgroundTransparency = 1
	imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	imageLabel.Position = UDim2.fromOffset(worldToViewportPoint.X, worldToViewportPoint.Y)
	imageLabel.Size = UDim2.fromScale(0.3, 0.3)
	imageLabel.Rotation = math.random(0, 360)
	imageLabel.ZIndex = MinigameShell.Z.SPLOTCH
	imageLabel.Parent = self.splotchLayer
	local uIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	uIAspectRatioConstraint.AspectRatio = 1
	uIAspectRatioConstraint.Parent = imageLabel
	local v6 = math.random(-70, 70)
	local v7 = math.random(26, 64)
	local v8 = math.random(-120, 120)
	local tween = TweenService:Create(
		imageLabel,
		TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{
			Position = UDim2.fromOffset(worldToViewportPoint.X + v6 * 0.4, worldToViewportPoint.Y - v7),
			Rotation = imageLabel.Rotation + v8 * 0.4
		}
	)
	tween.Completed:Connect(function()
		if not imageLabel.Parent then
			return
		end

		local tween2 = TweenService:Create(
			imageLabel,
			TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
			{
				Position = UDim2.fromOffset(worldToViewportPoint.X + v6, worldToViewportPoint.Y + v7 * 0.9),
				Rotation = imageLabel.Rotation + v8,
				ImageTransparency = 1,
				Size = UDim2.fromScale(0, 0)
			}
		)
		tween2.Completed:Connect(function()
			imageLabel:Destroy()
		end)
		tween2:Play()
	end)
	tween:Play()
end

function MinigameShell:update(p)
	local v5 = currentAlpha(self.gamepadRange)
	local v6, v7 = planeTarget(v5)
	local currentCamera = workspace.CurrentCamera
	local v8 = 0

	if v6 and currentCamera then
		local v9 = 1 - math.exp(-14 * p)
		local brushPosition = self.brushPosition
		self.brushPosition = brushPosition:Lerp(v6, v9)
		local vector4 = self.brushPosition - brushPosition

		if p > 0 then
			v8 = vector4.Magnitude / p
			local v10 = math.clamp(
				(not (v7 and v7 > 0) and 0 or vector4:Dot(currentCamera.CFrame.RightVector) / v7 / p) / 2.5,
				-1,
				1
			) * 0.6108652381980153
			self.brushSwing += (v10 - self.brushSwing) * (1 - math.exp(-12 * p))
		end

		self.brush.CFrame = CFrame.lookAt(self.brushPosition, self.brushPosition + currentCamera.CFrame.LookVector) * CFrame.Angles(
			0,
			self.brushSwing,
			self.brushSwing
		) * cframe
	end

	if self.painting and v8 >= 1 then
		self.splotchClock += p

		if self.splotchClock >= 0.1 then
			self.splotchClock = 0
			self:_spawnSplotch()
		end
	end

	self:_advanceSwipeHint(p)
	self:_reportOffset(p)
	return v5, v8
end

function MinigameShell:_advanceSwipeHint(p)
	if not self.swipeHint or not self.swipeHintStopped or self.swipeHintRetired then
		return
	end

	local v5 = self.swipeHintShown and 2.5 or 1.5
	self.swipeHintIdle += p

	if self.swipeHintIdle < v5 then
		return
	end

	self.swipeHintIdle = 0
	self.swipeHintStopped = false
	self.swipeHintShown = true
	self.swipeHint:start()
end

function MinigameShell:setPainting(p2)
	self.painting = p2 and true or false
end

function MinigameShell:setGamepadRange(value)
	self.gamepadRange = value or 1
end

function MinigameShell.getBrushViewportPoint(p)
	local currentCamera = workspace.CurrentCamera

	if not (currentCamera and p.brush) then
		return nil
	end

	local worldToViewportPoint, v5 = currentCamera:WorldToViewportPoint(p.brush.Position)

	if v5 then
		return Vector2.new(worldToViewportPoint.X, worldToViewportPoint.Y)
	end

	return nil
end

function MinigameShell:_viewportOffset()
	local currentCamera = workspace.CurrentCamera
	local splotchLayer = self.splotchLayer

	if not (currentCamera and splotchLayer) then
		return Vector2.zero
	end

	local v5 = currentCamera.ViewportSize - splotchLayer.AbsoluteSize

	if math.abs(v5.X) < 1 and math.abs(v5.Y) < 1 then
		return Vector2.zero
	end

	return GuiService:GetGuiInset()
end

local vector4 = Vector2.new(0, -58)

function MinigameShell:_reportOffset(_) end

function MinigameShell:_rectOf(p)
	local v5 = self:_viewportOffset() + vector4
	return p.AbsolutePosition - v5, p.AbsoluteSize
end

function MinigameShell:containsBrush(p, p2)
	if not (p and p2) then
		return false
	end

	local _rect, v5 = self:_rectOf(p)
	local v6 = _rect + v5
	return p2.X >= _rect.X and p2.X <= v6.X and p2.Y >= _rect.Y and p2.Y <= v6.Y
end

function MinigameShell:pointToUV(p, p2)
	if not (p and p2) then
		return nil
	end

	local _rect, v5 = self:_rectOf(p)

	if v5.X <= 0 or v5.Y <= 0 then
		return nil
	end

	return Vector2.new((p2.X - _rect.X) / v5.X, (p2.Y - _rect.Y) / v5.Y)
end

function MinigameShell.containsAlpha(p, p2, p3)
	local splotchLayer = p.splotchLayer

	if not (p2 and p3 and splotchLayer) then
		return false
	end

	local absoluteSize = p2.AbsoluteSize

	if absoluteSize.X <= 0 or absoluteSize.Y <= 0 then
		return false
	end

	local v5 = splotchLayer.AbsolutePosition + splotchLayer.AbsoluteSize * p3
	local absolutePosition = p2.AbsolutePosition
	return v5.X >= absolutePosition.X and v5.X <= absolutePosition.X + absoluteSize.X and v5.Y >= absolutePosition.Y and v5.Y <= absolutePosition.Y + absoluteSize.Y
end

function MinigameShell.setTimer(p, p2, p3)
	if p.timerFill and p3 and p3 > 0 then
		p.timerFill.Size = UDim2.new(math.clamp(p2 / p3, 0, 1), 0, 1, 0)
	end
end

function MinigameShell:setProgress(p, p2)
	self:setProgressText(string.format("%d/%d", p, p2))
end

function MinigameShell:setProgressText(text)
	if self.progressText then
		self.progressText.Text = text
	end
end

function MinigameShell:setHint(hintText)
	if not self.hint then
		return
	end

	self.hintText = hintText

	if type(hintText) == "table" and not self.hintConnection then
		self.hintConnection = InputService.PreferredInputChanged:Connect(function()
			self:_applyHint()
		end)
	end

	self:_applyHint()
end

function MinigameShell:_applyHint()
	if not self.hint then
		return
	end

	local hintText = self.hintText

	if type(hintText) == "table" then
		hintText = hintText[InputService:GetPreferredInput()] or hintText.KeyboardAndMouse
	end

	self.hint.Text = hintText or ""
	local hint = self.hint
	hint.Visible = hintText ~= nil and hintText ~= ""
end

function MinigameShell:showBaselineGhost()
	if self.ghost or not self.canvas then
		return
	end

	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = "BrushaGhost"
	imageLabel.Image = "rbxassetid://119673754692515"
	imageLabel.Size = UDim2.fromScale(1.25, 1.25)
	imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	imageLabel.Position = UDim2.fromScale(0.5, 0.5)
	imageLabel.BackgroundTransparency = 1
	imageLabel.ImageTransparency = 1
	imageLabel.ZIndex = MinigameShell.Z.GHOST
	imageLabel.Parent = self.canvas
	self.ghost = imageLabel
	TweenService:Create(imageLabel, tweenInfo, {
		Size = UDim2.fromScale(1, 1),
		ImageTransparency = 0.85
	}):Play()
end

function MinigameShell:showSwipeHint()
	if self.swipeHint or not self.gui then
		return
	end

	self.swipeHint = SwipeHint.new(self.gui, v)
	self.swipeHintStopped = true
	self.swipeHintShown = false
	self.swipeHintIdle = 0
end

function MinigameShell:notifySwipe()
	self.swipeHintIdle = 0

	if self.swipeHint and not self.swipeHintStopped then
		self.swipeHintStopped = true
		self.swipeHint:stop()
	end

	self:_clearBaselineGhost()
end

function MinigameShell:_clearBaselineGhost()
	local ghost = self.ghost

	if not ghost then
		return
	end

	self.ghost = nil
	local tween = TweenService:Create(ghost, tweenInfo2, {
		ImageTransparency = 1
	})
	tween.Completed:Connect(function()
		ghost:Destroy()
	end)
	tween:Play()
end

function MinigameShell.showDirectionIndicator(p)
	if p.directionIndicator then
		p.directionIndicator.Visible = true
	end
end

function MinigameShell.setSwipeDirection(p, visible)
	local directionIndicator = p.directionIndicator

	if not directionIndicator then
		return
	end

	local leftArrowBg = directionIndicator:FindFirstChild("LeftArrowBg")
	local rightArrowBg = directionIndicator:FindFirstChild("RightArrowBg")
	local inactive = leftArrowBg and leftArrowBg:FindFirstChild("Inactive")
	local inactive2 = rightArrowBg and rightArrowBg:FindFirstChild("Inactive")

	if inactive then
		inactive.Visible = visible
	end

	if inactive2 then
		inactive2.Visible = not visible
	end
end

function MinigameShell:playOutro(enabled, options, callback)
	self:setPainting(false)

	if self.swipeHint then
		self.swipeHintRetired = true
		self.swipeHintStopped = true
		self.swipeHint:stop()
	end

	if self.timerBar then
		self.timerBar.Visible = false
	end

	if self.resultLabel then
		self.resultLabel.Text = enabled and "Great!" or "Miss!"
		setResultGradient(self.resultLabel, enabled) -- equivalent call inferred; original call site unknown
		self.resultLabel.Visible = true
		local tweenInfo3 = TweenInfo.new(0.15)
		TweenService:Create(self.resultLabel, tweenInfo3, {
			TextTransparency = 0
		}):Play()

		if self.resultStroke then
			TweenService:Create(self.resultStroke, tweenInfo3, {
				Transparency = 0
			}):Play()
		end
	end

	task.delay(0.5, function()
		local tweenInfo3 = TweenInfo.new(0.35)

		for _, guiObject in ipairs(options or {}) do
			if not (guiObject and guiObject.Parent) then
				continue
			end

			if guiObject:IsA("ImageLabel") or guiObject:IsA("ImageButton") then
				TweenService:Create(guiObject, tweenInfo3, {
					ImageTransparency = 1
				}):Play()
			else
				TweenService:Create(guiObject, tweenInfo3, {
					BackgroundTransparency = 1
				}):Play()
			end
		end

		if self.canvas and self.canvas.Parent then
			TweenService:Create(self.canvas, tweenInfo3, {
				BackgroundTransparency = 1
			}):Play()
		end

		if self.ghost and self.ghost.Parent then
			TweenService:Create(self.ghost, tweenInfo3, {
				ImageTransparency = 1
			}):Play()
		end

		if self.resultLabel and self.resultLabel.Parent then
			TweenService:Create(self.resultLabel, tweenInfo3, {
				TextTransparency = 1
			}):Play()

			if self.resultStroke then
				TweenService:Create(self.resultStroke, tweenInfo3, {
					Transparency = 1
				}):Play()
			end
		end

		task.delay(0.35, function()
			if callback then
				callback()
			end
		end)
	end)
end

return MinigameShell