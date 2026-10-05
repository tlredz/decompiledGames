local createVector = vector.create
local value = Enum.ContextActionPriority.High.Value
local v = {
	0.10999999999999999,
	0.30000000000000004,
	0.4,
	0.5,
	0.6,
	0.7,
	0.75
}
local count = #v
local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local commonUtils = script.Parent.Parent:WaitForChild("CommonUtils")
local FlagUtil = require(commonUtils:WaitForChild("FlagUtil"))
local userFlag = FlagUtil.getUserFlag("UserAllowAbilityControls")
local userFlag2 = FlagUtil.getUserFlag("UserAllowAbilityControlsBonus")
local success, result = pcall(function()
	return UserSettings():IsUserFeatureEnabled("UserDynamicThumbstickSafeAreaUpdate")
end)
local v2 = success and result
local AvatarAbilitiesInterface

if userFlag then
	AvatarAbilitiesInterface = require(script.Parent:WaitForChild("AvatarAbilitiesInterface"))
else
	AvatarAbilitiesInterface = nil
end

local localPlayer = Players.LocalPlayer

if not localPlayer then
	Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
	localPlayer = Players.LocalPlayer
end

local BaseCharacterController = require(script.Parent:WaitForChild("BaseCharacterController"))
local object = setmetatable({}, BaseCharacterController)
object.__index = object

function object.new()
	local self = setmetatable(BaseCharacterController.new(), object)
	self.moveTouchObject = nil
	self.moveTouchLockedIn = false
	self.moveTouchFirstChanged = false
	self.moveTouchStartPosition = nil
	self.startImage = nil
	self.endImage = nil
	self.middleImages = {}
	self.startImageFadeTween = nil
	self.endImageFadeTween = nil
	self.middleImageFadeTweens = {}
	self.isFirstTouch = true
	self.thumbstickFrame = nil
	self.onRenderSteppedConn = nil
	self.fadeInAndOutBalance = 0.5
	self.fadeInAndOutHalfDuration = 0.3
	self.hasFadedBackgroundInPortrait = false
	self.hasFadedBackgroundInLandscape = false
	self.tweenInAlphaStart = nil
	self.tweenOutAlphaStart = nil
	return self
end

function object:GetIsJumping()
	local isJumping = self.isJumping
	self.isJumping = false
	return isJumping
end

function object:Enable(flag: boolean?, p)
	if flag == nil then
		return false
	end

	local v3 = flag and true or false

	if self.enabled == v3 then
		return true
	end

	if v3 then
		if not self.thumbstickFrame then
			self:Create(p)
		end

		self:BindContextActions()
	else
		self:UnbindContextActions()
		self:OnInputEnded()
	end

	self.enabled = v3
	self.thumbstickFrame.Visible = v3
	return nil
end

function object:OnInputEnded()
	self.moveTouchObject = nil
	self.moveVector = createVector(0, 0, 0)
	self:FadeThumbstick(false)
end

function object:FadeThumbstick(flag: boolean?)
	if not flag and self.moveTouchObject or self.isFirstTouch then
		return
	end

	if self.startImageFadeTween then
		self.startImageFadeTween:Cancel()
	end

	if self.endImageFadeTween then
		self.endImageFadeTween:Cancel()
	end

	for i = 1, #self.middleImages do
		if self.middleImageFadeTweens[i] then
			self.middleImageFadeTweens[i]:Cancel()
		end
	end

	if flag then
		self.startImageFadeTween = TweenService:Create(self.startImage, tweenInfo, {
			ImageTransparency = 0
		})
		self.startImageFadeTween:Play()
		self.endImageFadeTween = TweenService:Create(self.endImage, tweenInfo, {
			ImageTransparency = 0.2
		})
		self.endImageFadeTween:Play()

		for i = 1, #self.middleImages do
			self.middleImageFadeTweens[i] = TweenService:Create(self.middleImages[i], tweenInfo, {
				ImageTransparency = v[i]
			})
			self.middleImageFadeTweens[i]:Play()
		end
	else
		self.startImageFadeTween = TweenService:Create(self.startImage, tweenInfo, {
			ImageTransparency = 1
		})
		self.startImageFadeTween:Play()
		self.endImageFadeTween = TweenService:Create(self.endImage, tweenInfo, {
			ImageTransparency = 1
		})
		self.endImageFadeTween:Play()

		for i = 1, #self.middleImages do
			self.middleImageFadeTweens[i] = TweenService:Create(self.middleImages[i], tweenInfo, {
				ImageTransparency = 1
			})
			self.middleImageFadeTweens[i]:Play()
		end
	end
end

function object:FadeThumbstickFrame(p2: number, fadeInAndOutBalance: number)
	self.fadeInAndOutHalfDuration = p2 * 0.5
	self.fadeInAndOutBalance = fadeInAndOutBalance
	self.tweenInAlphaStart = tick()
end

function object:InputInFrame(p2)
	local absolutePosition = self.thumbstickFrame.AbsolutePosition
	local v3 = absolutePosition + self.thumbstickFrame.AbsoluteSize
	local position = p2.Position
	return position.X >= absolutePosition.X and position.Y >= absolutePosition.Y and position.X <= v3.X and position.Y <= v3.Y
end

function object:DoFadeInBackground()
	local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")
	local hasFadedBackgroundInLandscape = false

	if playerGui then
		if playerGui.CurrentScreenOrientation == Enum.ScreenOrientation.LandscapeLeft or playerGui.CurrentScreenOrientation == Enum.ScreenOrientation.LandscapeRight then
			hasFadedBackgroundInLandscape = self.hasFadedBackgroundInLandscape
			self.hasFadedBackgroundInLandscape = true
		elseif playerGui.CurrentScreenOrientation == Enum.ScreenOrientation.Portrait then
			hasFadedBackgroundInLandscape = self.hasFadedBackgroundInPortrait
			self.hasFadedBackgroundInPortrait = true
		end
	end

	if not hasFadedBackgroundInLandscape then
		self.fadeInAndOutHalfDuration = 0.3
		self.fadeInAndOutBalance = 0.5
		self.tweenInAlphaStart = tick()
	end
end

function object:DoMove(vector2: Vector3)
	local vector3

	if vector2.Magnitude < self.radiusOfDeadZone then
		vector3 = createVector(0, 0, 0)
	else
		local v3 = vector2.Unit * (1 - math.max(0, (self.radiusOfMaxSpeed - vector2.Magnitude) / self.radiusOfMaxSpeed))
		vector3 = Vector3.new(v3.X, 0, v3.Y)
	end

	self.moveVector = vector3
end

function object:LayoutMiddleImages(vector2: Vector3, vector3: Vector3)
	local v3 = self.thumbstickSize / 2 + self.middleSize
	local v4 = vector3 - vector2
	local v5 = v4.Magnitude - self.thumbstickRingSize / 2 - self.middleSize
	local unit = v4.Unit
	local v6 = self.middleSpacing * count
	local middleSpacing = self.middleSpacing

	if v6 < v5 then
		middleSpacing = v5 / count
	end

	for i = 1, count do
		local middleImage = self.middleImages[i]
		local v7 = v3 + middleSpacing * (i - 2)
		local v8 = v3 + middleSpacing * (i - 1)

		if v7 < v5 then
			local v9 = vector3 - unit * v8
			local v10 = math.clamp(1 - (v8 - v5) / middleSpacing, 0, 1)
			middleImage.Visible = true
			middleImage.Position = UDim2.new(0, v9.X, 0, v9.Y)
			middleImage.Size = UDim2.new(0, self.middleSize * v10, 0, self.middleSize * v10)
		else
			middleImage.Visible = false
		end
	end
end

function object:MoveStick(p)
	local v3 = Vector2.new(self.moveTouchStartPosition.X, self.moveTouchStartPosition.Y) - self.thumbstickFrame.AbsolutePosition
	local v4 = Vector2.new(p.X, p.Y) - self.thumbstickFrame.AbsolutePosition
	self.endImage.Position = UDim2.new(0, v4.X, 0, v4.Y)
	self:LayoutMiddleImages(v3, v4)
end

function object:BindContextActions()
	local function inputBegan(moveTouchObject)
		if self.moveTouchObject or not self:InputInFrame(moveTouchObject) then
			return Enum.ContextActionResult.Pass
		end

		if self.isFirstTouch then
			self.isFirstTouch = false
			local tweenInfo2 = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0)
			TweenService:Create(self.startImage, tweenInfo2, {
				Size = UDim2.new(0, 0, 0, 0)
			}):Play()
			TweenService:Create(self.endImage, tweenInfo2, {
				Size = UDim2.new(0, self.thumbstickSize, 0, self.thumbstickSize),
				ImageColor3 = Color3.new(0, 0, 0)
			}):Play()
		end

		self.moveTouchLockedIn = false
		self.moveTouchObject = moveTouchObject
		self.moveTouchStartPosition = moveTouchObject.Position
		self.moveTouchFirstChanged = true
		self:DoFadeInBackground()
		return Enum.ContextActionResult.Pass
	end

	local function inputChanged(p)
		if p ~= self.moveTouchObject then
			return Enum.ContextActionResult.Pass
		end

		if self.moveTouchFirstChanged then
			self.moveTouchFirstChanged = false
			local vector2 = Vector2.new(
				p.Position.X - self.thumbstickFrame.AbsolutePosition.X,
				p.Position.Y - self.thumbstickFrame.AbsolutePosition.Y
			)
			self.startImage.Visible = true
			self.startImage.Position = UDim2.new(0, vector2.X, 0, vector2.Y)
			self.endImage.Visible = true
			self.endImage.Position = self.startImage.Position
			self:FadeThumbstick(true)
			self:MoveStick(p.Position)
		end

		self.moveTouchLockedIn = true
		local vector2 = Vector2.new(
			p.Position.X - self.moveTouchStartPosition.X,
			p.Position.Y - self.moveTouchStartPosition.Y
		)

		if math.abs(vector2.X) > 0 or math.abs(vector2.Y) > 0 then
			self:DoMove(vector2)
			self:MoveStick(p.Position)
		end

		return Enum.ContextActionResult.Sink
	end

	local function inputEnded(p)
		if p == self.moveTouchObject then
			self:OnInputEnded()

			if self.moveTouchLockedIn then
				return Enum.ContextActionResult.Sink
			end
		end

		return Enum.ContextActionResult.Pass
	end

	local function handleInput(_, p, moveTouchObject)
		if p == Enum.UserInputState.Begin then
			return (inputBegan(moveTouchObject))
		end

		if p == Enum.UserInputState.Change then
			if moveTouchObject == self.moveTouchObject then
				return Enum.ContextActionResult.Sink
			end

			return Enum.ContextActionResult.Pass
		elseif p == Enum.UserInputState.End then
			if moveTouchObject == self.moveTouchObject then
				self:OnInputEnded()

				if self.moveTouchLockedIn then
					return Enum.ContextActionResult.Sink
				end
			end

			return Enum.ContextActionResult.Pass
		elseif p == Enum.UserInputState.Cancel then
			self:OnInputEnded()
		end
	end

	ContextActionService:BindActionAtPriority(
		"DynamicThumbstickAction",
		handleInput,
		false,
		value,
		Enum.UserInputType.Touch
	)
	self.TouchMovedCon = UserInputService.TouchMoved:Connect(function(p, _: boolean)
		inputChanged(p)
	end)
end

function object:UnbindContextActions()
	ContextActionService:UnbindAction("DynamicThumbstickAction")

	if self.TouchMovedCon then
		self.TouchMovedCon:Disconnect()
	end
end

function object:Create(parent)
	local IMAGE_ID = "rbxasset://textures/ui/Input/TouchControlsSheetV2.png"

	if self.thumbstickFrame then
		self.thumbstickFrame:Destroy()
		self.thumbstickFrame = nil

		if self.onRenderSteppedConn then
			self.onRenderSteppedConn:Disconnect()
			self.onRenderSteppedConn = nil
		end

		if self.absoluteSizeChangedConn then
			self.absoluteSizeChangedConn:Disconnect()
			self.absoluteSizeChangedConn = nil
		end

		if userFlag and self.avatarAbilitiesEnabledChangedConn then
			self.avatarAbilitiesEnabledChangedConn:Disconnect()
			self.avatarAbilitiesEnabledChangedConn = nil
		end
	end

	local v3 = v2 and 100 or 0

	local function layoutThumbstickFrame(flag: boolean)
		if flag then
			self.thumbstickFrame.Size = UDim2.new(1, v3, 0.4, v3)
			self.thumbstickFrame.Position = UDim2.new(0, -v3, 0.6, 0)
		else
			self.thumbstickFrame.Size = UDim2.new(0.4, v3, 0.6666666666666666, v3)
			self.thumbstickFrame.Position = UDim2.new(0, -v3, 0.3333333333333333, 0)
		end
	end

	self.thumbstickFrame = Instance.new("Frame")
	self.thumbstickFrame.BorderSizePixel = 0
	self.thumbstickFrame.Name = "DynamicThumbstickFrame"
	self.thumbstickFrame.Visible = false
	self.thumbstickFrame.BackgroundTransparency = 1
	self.thumbstickFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	self.thumbstickFrame.Active = false
	self.thumbstickFrame.Size = UDim2.new(0.4, v3, 0.6666666666666666, v3)
	self.thumbstickFrame.Position = UDim2.new(0, -v3, 0.3333333333333333, 0)
	self.startImage = Instance.new("ImageLabel")
	self.startImage.Name = "ThumbstickStart"
	self.startImage.Visible = true
	self.startImage.BackgroundTransparency = 1
	self.startImage.Image = IMAGE_ID
	self.startImage.ImageRectOffset = Vector2.new(1, 1)
	self.startImage.ImageRectSize = Vector2.new(144, 144)
	self.startImage.ImageColor3 = Color3.new(0, 0, 0)
	self.startImage.AnchorPoint = Vector2.new(0.5, 0.5)
	self.startImage.ZIndex = 10
	self.startImage.Parent = self.thumbstickFrame
	self.endImage = Instance.new("ImageLabel")
	self.endImage.Name = "ThumbstickEnd"
	self.endImage.Visible = true
	self.endImage.BackgroundTransparency = 1
	self.endImage.Image = IMAGE_ID
	self.endImage.ImageRectOffset = Vector2.new(1, 1)
	self.endImage.ImageRectSize = Vector2.new(144, 144)
	self.endImage.AnchorPoint = Vector2.new(0.5, 0.5)
	self.endImage.ZIndex = 10
	self.endImage.Parent = self.thumbstickFrame

	for i = 1, count do
		self.middleImages[i] = Instance.new("ImageLabel")
		self.middleImages[i].Name = "ThumbstickMiddle"
		self.middleImages[i].Visible = false
		self.middleImages[i].BackgroundTransparency = 1
		self.middleImages[i].Image = IMAGE_ID
		self.middleImages[i].ImageRectOffset = Vector2.new(1, 1)
		self.middleImages[i].ImageRectSize = Vector2.new(144, 144)
		self.middleImages[i].ImageTransparency = v[i]
		self.middleImages[i].AnchorPoint = Vector2.new(0.5, 0.5)
		self.middleImages[i].ZIndex = 9
		self.middleImages[i].Parent = self.thumbstickFrame
	end

	local function ResizeThumbstick()
		local absoluteSize = parent.AbsoluteSize
		local v4 = math.min(absoluteSize.X, absoluteSize.Y) > 500

		if userFlag then
			local v5 = userFlag2 and AvatarAbilitiesInterface.isEnabled() and v4 and 1.6216216216216217 or v4 and 2 or 1
			self.thumbstickSize = 45 * v5
			self.thumbstickRingSize = 20 * v5
			self.middleSize = 10 * v5
			self.middleSpacing = 14 * v5
			self.radiusOfDeadZone = 2 * v5
			self.radiusOfMaxSpeed = 20 * v5
			local v6 = 74 * v5

			if AvatarAbilitiesInterface.isEnabled() then
				self.startImage.Position = UDim2.new(
					0,
					v6 * 0.5 + v3 + (v4 and 100 or 64),
					1,
					-v6 * 0.5 - v3 - (v4 and 112 or 64)
				)
			else
				self.startImage.Position = UDim2.new(
					0,
					self.thumbstickRingSize * 3.3 + v3,
					1,
					-self.thumbstickRingSize * 2.8 - v3
				)
			end

			self.startImage.Size = UDim2.new(0, v6, 0, v6)
		else
			if v4 then
				self.thumbstickSize = 90
				self.thumbstickRingSize = 40
				self.middleSize = 20
				self.middleSpacing = 28
				self.radiusOfDeadZone = 4
				self.radiusOfMaxSpeed = 40
			else
				self.thumbstickSize = 45
				self.thumbstickRingSize = 20
				self.middleSize = 10
				self.middleSpacing = 14
				self.radiusOfDeadZone = 2
				self.radiusOfMaxSpeed = 20
			end

			self.startImage.Position = UDim2.new(
				0,
				self.thumbstickRingSize * 3.3 + v3,
				1,
				-self.thumbstickRingSize * 2.8 - v3
			)
			self.startImage.Size = UDim2.new(0, self.thumbstickRingSize * 3.7, 0, self.thumbstickRingSize * 3.7)
		end

		self.endImage.Position = self.startImage.Position
		self.endImage.Size = UDim2.new(0, self.thumbstickSize * 0.8, 0, self.thumbstickSize * 0.8)
	end

	ResizeThumbstick()
	self.absoluteSizeChangedConn = parent:GetPropertyChangedSignal("AbsoluteSize"):Connect(ResizeThumbstick)

	if userFlag then
		self.avatarAbilitiesEnabledChangedConn = AvatarAbilitiesInterface.GetEnabledChangedSignal():Connect(ResizeThumbstick)
	end

	local viewportSizeChangedConnection = nil

	local function onCurrentCameraChanged()
		if viewportSizeChangedConnection then
			viewportSizeChangedConnection:Disconnect()
			viewportSizeChangedConnection = nil
		end

		local currentCamera = workspace.CurrentCamera

		if currentCamera then
			-- equivalent calls inferred from this helper; original call sites unknown
			local function onViewportSizeChanged()
				local viewportSize = currentCamera.ViewportSize
				layoutThumbstickFrame(viewportSize.X < viewportSize.Y)
			end

			viewportSizeChangedConnection = currentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(onViewportSizeChanged)
			onViewportSizeChanged() -- equivalent call inferred; original call site unknown
		end
	end

	workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(onCurrentCameraChanged)

	if workspace.CurrentCamera then
		onCurrentCameraChanged()
	end

	self.moveTouchStartPosition = nil
	self.startImageFadeTween = nil
	self.endImageFadeTween = nil
	self.middleImageFadeTweens = {}
	self.onRenderSteppedConn = RunService.RenderStepped:Connect(function()
		if self.tweenInAlphaStart == nil then
			if self.tweenOutAlphaStart ~= nil then
				local v4 = tick() - self.tweenOutAlphaStart
				local v5 = self.fadeInAndOutHalfDuration * 2 - self.fadeInAndOutHalfDuration * 2 * self.fadeInAndOutBalance
				self.thumbstickFrame.BackgroundTransparency = math.min(v4 / v5, 1) * 0.35 + 0.65

				if v5 < v4 then
					self.tweenOutAlphaStart = nil
				end
			end
		else
			local v4 = tick() - self.tweenInAlphaStart
			local v5 = self.fadeInAndOutHalfDuration * 2 * self.fadeInAndOutBalance
			self.thumbstickFrame.BackgroundTransparency = 1 - math.min(v4 / v5, 1) * 0.35

			if v5 < v4 then
				self.tweenOutAlphaStart = tick()
				self.tweenInAlphaStart = nil
			end
		end
	end)
	self.onTouchEndedConn = UserInputService.TouchEnded:connect(function(p)
		if p == self.moveTouchObject then
			self:OnInputEnded()
		end
	end)
	GuiService.MenuOpened:connect(function()
		if self.moveTouchObject then
			self:OnInputEnded()
		end
	end)
	local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")

	while not playerGui do
		localPlayer.ChildAdded:wait()
		playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")
	end

	local currentScreenOrientationChangedConnection = nil
	local v4 = playerGui.CurrentScreenOrientation == Enum.ScreenOrientation.LandscapeLeft or playerGui.CurrentScreenOrientation == Enum.ScreenOrientation.LandscapeRight

	-- equivalent calls inferred from this helper; original call sites unknown
	local function longShowBackground()
		self.fadeInAndOutHalfDuration = 2.5
		self.fadeInAndOutBalance = 0.05
		self.tweenInAlphaStart = tick()
	end

	currentScreenOrientationChangedConnection = playerGui:GetPropertyChangedSignal("CurrentScreenOrientation"):Connect(function()
		if v4 and playerGui.CurrentScreenOrientation == Enum.ScreenOrientation.Portrait or not v4 and playerGui.CurrentScreenOrientation ~= Enum.ScreenOrientation.Portrait then
			currentScreenOrientationChangedConnection:disconnect()
			longShowBackground() -- equivalent call inferred; original call site unknown

			if v4 then
				self.hasFadedBackgroundInPortrait = true
			else
				self.hasFadedBackgroundInLandscape = true
			end
		end
	end)
	self.thumbstickFrame.Parent = parent

	if game:IsLoaded() then
		longShowBackground() -- equivalent call inferred; original call site unknown
	else
		coroutine.wrap(function()
			game.Loaded:Wait()
			longShowBackground() -- equivalent call inferred; original call site unknown
		end)()
	end
end

return object