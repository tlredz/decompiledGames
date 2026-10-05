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
local success, result = pcall(function()
	return UserSettings():IsUserFeatureEnabled("UserDynamicThumbstickMoveOverButtons2")
end)
local v2 = success and result
local success2, result2 = pcall(function()
	return UserSettings():IsUserFeatureEnabled("UserDynamicThumbstickSafeAreaUpdate")
end)
local v3 = success2 and result2
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

	local v4 = flag and true or false

	if self.enabled == v4 then
		return true
	end

	if v4 then
		if not self.thumbstickFrame then
			self:Create(p)
		end

		self:BindContextActions()
	else
		if v2 then
			self:UnbindContextActions()
		else
			ContextActionService:UnbindAction("DynamicThumbstickAction")
		end

		self:OnInputEnded()
	end

	self.enabled = v4
	self.thumbstickFrame.Visible = v4
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
	local v4 = absolutePosition + self.thumbstickFrame.AbsoluteSize
	local position = p2.Position
	return position.X >= absolutePosition.X and position.Y >= absolutePosition.Y and position.X <= v4.X and position.Y <= v4.Y
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
		local unit = vector2.Unit
		vector3 = Vector3.new(unit.X, 0, unit.Y)
	end

	self.moveVector = vector3
end

function object:LayoutMiddleImages(vector2: Vector3, vector3: Vector3)
	local v4 = self.thumbstickSize / 2 + self.middleSize
	local v5 = vector3 - vector2
	local v6 = v5.Magnitude - self.thumbstickRingSize / 2 - self.middleSize
	local unit = v5.Unit
	local v7 = self.middleSpacing * count
	local middleSpacing = self.middleSpacing

	if v7 < v6 then
		middleSpacing = v6 / count
	end

	for i = 1, count do
		local middleImage = self.middleImages[i]
		local v8 = v4 + middleSpacing * (i - 2)
		local v9 = v4 + middleSpacing * (i - 1)

		if v8 < v6 then
			local v10 = vector3 - unit * v9
			local v11 = math.clamp(1 - (v9 - v6) / middleSpacing, 0, 1)
			middleImage.Visible = true
			middleImage.Position = UDim2.new(0, v10.X, 0, v10.Y)
			middleImage.Size = UDim2.new(0, self.middleSize * v11, 0, self.middleSize * v11)
		else
			middleImage.Visible = false
		end
	end
end

function object:MoveStick(p)
	local v4 = Vector2.new(self.moveTouchStartPosition.X, self.moveTouchStartPosition.Y) - self.thumbstickFrame.AbsolutePosition
	local v5 = Vector2.new(p.X, p.Y) - self.thumbstickFrame.AbsolutePosition
	self.endImage.Position = UDim2.new(0, v5.X, 0, v5.Y)
	self:LayoutMiddleImages(v4, v5)
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
			if not v2 then
				return (inputChanged(moveTouchObject))
			end

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

	if v2 then
		self.TouchMovedCon = UserInputService.TouchMoved:Connect(function(p, _: boolean)
			inputChanged(p)
		end)
	end
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
	end

	local v4 = v3 and 100 or 0

	local function layoutThumbstickFrame(flag: boolean)
		if flag then
			self.thumbstickFrame.Size = UDim2.new(1, v4, 0.4, v4)
			self.thumbstickFrame.Position = UDim2.new(0, -v4, 0.6, 0)
		else
			self.thumbstickFrame.Size = UDim2.new(0.4, v4, 0.6666666666666666, v4)
			self.thumbstickFrame.Position = UDim2.new(0, -v4, 0.3333333333333333, 0)
		end
	end

	self.thumbstickFrame = Instance.new("Frame")
	self.thumbstickFrame.BorderSizePixel = 0
	self.thumbstickFrame.Name = "DynamicThumbstickFrame"
	self.thumbstickFrame.Visible = false
	self.thumbstickFrame.BackgroundTransparency = 1
	self.thumbstickFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	self.thumbstickFrame.Active = false
	self.thumbstickFrame.Size = UDim2.new(0.4, v4, 0.6666666666666666, v4)
	self.thumbstickFrame.Position = UDim2.new(0, -v4, 0.3333333333333333, 0)
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

		if math.min(absoluteSize.X, absoluteSize.Y) > 500 then
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
			self.thumbstickRingSize * 3.3 + v4,
			1,
			-self.thumbstickRingSize * 2.8 - v4
		)
		self.startImage.Size = UDim2.new(0, self.thumbstickRingSize * 3.7, 0, self.thumbstickRingSize * 3.7)
		self.endImage.Position = self.startImage.Position
		self.endImage.Size = UDim2.new(0, self.thumbstickSize * 0.8, 0, self.thumbstickSize * 0.8)
	end

	ResizeThumbstick()
	self.absoluteSizeChangedConn = parent:GetPropertyChangedSignal("AbsoluteSize"):Connect(ResizeThumbstick)
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
				local v5 = tick() - self.tweenOutAlphaStart
				local v6 = self.fadeInAndOutHalfDuration * 2 - self.fadeInAndOutHalfDuration * 2 * self.fadeInAndOutBalance
				self.thumbstickFrame.BackgroundTransparency = math.min(v5 / v6, 1) * 0.35 + 0.65

				if v6 < v5 then
					self.tweenOutAlphaStart = nil
				end
			end
		else
			local v5 = tick() - self.tweenInAlphaStart
			local v6 = self.fadeInAndOutHalfDuration * 2 * self.fadeInAndOutBalance
			self.thumbstickFrame.BackgroundTransparency = 1 - math.min(v5 / v6, 1) * 0.35

			if v6 < v5 then
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
	local v5 = playerGui.CurrentScreenOrientation == Enum.ScreenOrientation.LandscapeLeft or playerGui.CurrentScreenOrientation == Enum.ScreenOrientation.LandscapeRight

	-- equivalent calls inferred from this helper; original call sites unknown
	local function longShowBackground()
		self.fadeInAndOutHalfDuration = 2.5
		self.fadeInAndOutBalance = 0.05
		self.tweenInAlphaStart = tick()
	end

	currentScreenOrientationChangedConnection = playerGui:GetPropertyChangedSignal("CurrentScreenOrientation"):Connect(function()
		if v5 and playerGui.CurrentScreenOrientation == Enum.ScreenOrientation.Portrait or not v5 and playerGui.CurrentScreenOrientation ~= Enum.ScreenOrientation.Portrait then
			currentScreenOrientationChangedConnection:disconnect()
			longShowBackground() -- equivalent call inferred; original call site unknown

			if v5 then
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