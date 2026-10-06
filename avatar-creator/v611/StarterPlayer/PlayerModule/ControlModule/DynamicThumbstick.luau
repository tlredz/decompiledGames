local v = {
	0.10999999999999999,
	0.30000000000000004,
	0.4,
	0.5,
	0.6,
	0.7,
	0.75
}
local v2 = {
	0.55,
	0.65,
	0.7,
	0.75,
	0.8,
	0.85,
	0.875
}
local count = #v
local vector = Vector2.new(-1, -1)
local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
local CommonUtils = require(script.Parent.Parent:WaitForChild("CommonUtils"))
local flagUtil = CommonUtils.get("FlagUtil")
local userFlag = flagUtil.getUserFlag("UserPlayerScriptsCCLIntegrationD")
local userFlag2 = flagUtil.getUserFlag("UserAllowAbilityControlsBonus")
local userFlag3 = flagUtil.getUserFlag("UserPlayerScriptsFireThroughScriptableBindings")
local userFlag4 = flagUtil.getUserFlag("UserPlayerScriptsSAuthDirectAPIs2")
local userFlag5 = flagUtil.getUserFlag("UserDoubleJumpButtonFix")
local userFlag6 = flagUtil.getUserFlag("UserPlayerScriptsResetDTTouchOnCreate")
local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local thumbstickAction = script.Parent.Parent:WaitForChild("InputContexts"):WaitForChild("TransformerContext"):WaitForChild("ThumbstickAction")
local AvatarAbilitiesInterface = require(script.Parent:WaitForChild("AvatarAbilitiesInterface"))
local v3

if userFlag then
	v3 = AvatarAbilitiesInterface.get(Players.LocalPlayer)
else
	v3 = nil
end

local localPlayer = Players.LocalPlayer

if not localPlayer then
	Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
	localPlayer = Players.LocalPlayer
end

local ActionController = require(script.Parent:WaitForChild("ActionController"))
local object = setmetatable({}, ActionController)
object.__index = object

function object.new(playerData)
	local self = setmetatable(ActionController.new(), object)
	self.playerData = playerData
	self.enabled = false
	self.isTouchActive = false
	self.moveTouchFirstChanged = false
	self.moveTouchStartPosition = nil
	self.startImage = nil
	self.endImage = nil
	self.endImageStroke = nil
	self.endImageCenter = nil
	self.middleImages = {}
	self.startImageFadeTween = nil
	self.endImageFadeTween = nil
	self.endImageCenterFadeTween = nil
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
	self.newStyle = false
	return self
end

function object:GetIsJumping()
	local isJumping = self.isJumping
	self.isJumping = false
	return isJumping
end

local function setupThumbstickInput(p)
	for _, child in thumbstickAction:GetChildren() do
		if child.Name == "DynamicTouchBinding" or child.Name == "ClassicTouchBinding" then
			child:Destroy()
		end
	end

	local inputBinding = Instance.new("InputBinding")
	inputBinding.Name = "DynamicTouchBinding"
	inputBinding.KeyCode = Enum.KeyCode.TouchPosition
	inputBinding.UIModifier = p.thumbstickButton
	inputBinding.Parent = thumbstickAction
end

local function enableThumbstickInput(state, flag: boolean)
	if flag then
		setupThumbstickInput(state)
		state.thumbstickStateChangedConn = thumbstickAction.StateChanged:Connect(state.onStateChanged)
		thumbstickAction.Enabled = true
	else
		thumbstickAction.Enabled = false

		if state.thumbstickStateChangedConn then
			state.thumbstickStateChangedConn:Disconnect()
			state.thumbstickStateChangedConn = nil
		end
	end
end

function object:Enable(flag: boolean?, p)
	if flag == nil then
		return false
	end

	local v4 = flag and true or false

	if self.enabled == v4 then
		return true
	end

	ActionController.Enable(self, v4)

	if v4 then
		if not self.thumbstickFrame then
			self:Create(p)

			if userFlag and not self.avatarAbilitiesEnabledChangedConn then
				self.avatarAbilitiesEnabledChangedConn = v3:GetEnabledChangedSignal():Connect(function()
					if self.enabled then
						self:Create(p)

						if userFlag6 then
							local v5 = self
							setupThumbstickInput(v5)
							v5.thumbstickStateChangedConn = thumbstickAction.StateChanged:Connect(v5.onStateChanged)
							thumbstickAction.Enabled = true
						else
							self.thumbstickStateChangedConn = thumbstickAction.StateChanged:Connect(self.onStateChanged)
							thumbstickAction.Enabled = true
						end

						self.thumbstickFrame.Visible = true
					end
				end)
			end
		end

		if userFlag6 then
			setupThumbstickInput(self)
		end

		self.thumbstickStateChangedConn = thumbstickAction.StateChanged:Connect(self.onStateChanged)
		thumbstickAction.Enabled = true
	else
		if userFlag6 then
		end

		thumbstickAction.Enabled = false

		if self.thumbstickStateChangedConn then
			self.thumbstickStateChangedConn:Disconnect()
			self.thumbstickStateChangedConn = nil
		end

		self:OnInputEnded()
	end

	self.enabled = v4
	self.thumbstickFrame.Visible = v4
	return nil
end

function object:OnInputEnded()
	self.isTouchActive = false

	if userFlag4 then
		local dynamicThumbstickScriptableBinding = self.playerData.actions.MoveAction:FindFirstChild("DynamicThumbstickScriptableBinding")

		if dynamicThumbstickScriptableBinding then
			dynamicThumbstickScriptableBinding:Fire(Vector2.zero)
		end
	elseif userFlag3 then
		local dynamicThumbstickScriptableBinding = self.playerData.actions.MoveAction:FindFirstChild("DynamicThumbstickScriptableBinding")

		if dynamicThumbstickScriptableBinding then
			local success, _ = pcall(function()
				dynamicThumbstickScriptableBinding.Type = Enum.InputBindingType.Scriptable
				dynamicThumbstickScriptableBinding:Fire(Vector2.zero)
			end)

			if not success then
				self.playerData.actions.MoveAction:Fire(Vector2.zero)
			end
		else
			self.playerData.actions.MoveAction:Fire(Vector2.zero)
		end
	else
		self.playerData.actions.MoveAction:Fire(Vector2.zero)
	end

	self:FadeThumbstick(false)
end

function object:FadeThumbstick(flag: boolean?)
	if not flag and self.isTouchActive or self.isFirstTouch then
		return
	end

	if self.startImageFadeTween then
		self.startImageFadeTween:Cancel()
	end

	if self.endImageFadeTween then
		self.endImageFadeTween:Cancel()
	end

	if userFlag and self.endImageCenterFadeTween then
		self.endImageCenterFadeTween:Cancel()
	end

	for i = 1, #self.middleImages do
		if self.middleImageFadeTweens[i] then
			self.middleImageFadeTweens[i]:Cancel()
		end
	end

	if flag then
		if userFlag and self.newStyle then
			self.startImageFadeTween = TweenService:Create(self.startImage, tweenInfo, {
				BackgroundTransparency = 0.4
			})
			self.startImageFadeTween:Play()
			self.endImageFadeTween = TweenService:Create(self.endImageStroke, tweenInfo, {
				Transparency = 0
			})
			self.endImageFadeTween:Play()
			self.endImageCenterFadeTween = TweenService:Create(self.endImageCenter, tweenInfo, {
				BackgroundTransparency = 0
			})
			self.endImageCenterFadeTween:Play()
		else
			self.startImageFadeTween = TweenService:Create(self.startImage, tweenInfo, {
				ImageTransparency = 0
			})
			self.startImageFadeTween:Play()
			self.endImageFadeTween = TweenService:Create(self.endImage, tweenInfo, {
				ImageTransparency = 0.2
			})
			self.endImageFadeTween:Play()
		end

		for i = 1, #self.middleImages do
			if userFlag and self.newStyle then
				self.middleImageFadeTweens[i] = TweenService:Create(self.middleImages[i], tweenInfo, {
					BackgroundTransparency = v2[i]
				})
			else
				self.middleImageFadeTweens[i] = TweenService:Create(self.middleImages[i], tweenInfo, {
					ImageTransparency = v[i]
				})
			end

			self.middleImageFadeTweens[i]:Play()
		end
	else
		if userFlag and self.newStyle then
			self.startImageFadeTween = TweenService:Create(self.startImage, tweenInfo, {
				BackgroundTransparency = 1
			})
			self.startImageFadeTween:Play()
			self.endImageFadeTween = TweenService:Create(self.endImageStroke, tweenInfo, {
				Transparency = 1
			})
			self.endImageFadeTween:Play()
			self.endImageCenterFadeTween = TweenService:Create(self.endImageCenter, tweenInfo, {
				BackgroundTransparency = 1
			})
			self.endImageCenterFadeTween:Play()
		else
			self.startImageFadeTween = TweenService:Create(self.startImage, tweenInfo, {
				ImageTransparency = 1
			})
			self.startImageFadeTween:Play()
			self.endImageFadeTween = TweenService:Create(self.endImage, tweenInfo, {
				ImageTransparency = 1
			})
			self.endImageFadeTween:Play()
		end

		for i = 1, #self.middleImages do
			if userFlag and self.newStyle then
				self.middleImageFadeTweens[i] = TweenService:Create(self.middleImages[i], tweenInfo, {
					BackgroundTransparency = 1
				})
			else
				self.middleImageFadeTweens[i] = TweenService:Create(self.middleImages[i], tweenInfo, {
					ImageTransparency = 1
				})
			end

			self.middleImageFadeTweens[i]:Play()
		end
	end
end

function object:FadeThumbstickFrame(p2: number, fadeInAndOutBalance: number)
	self.fadeInAndOutHalfDuration = p2 * 0.5
	self.fadeInAndOutBalance = fadeInAndOutBalance
	self.tweenInAlphaStart = tick()
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

function object:DoMove(point: Vector2)
	local vector2

	if point.Magnitude < self.radiusOfDeadZone then
		vector2 = Vector2.new()
	else
		vector2 = point.Unit * (1 - math.max(0, (self.radiusOfMaxSpeed - point.Magnitude) / self.radiusOfMaxSpeed))
	end

	local vector3 = Vector2.new(vector2.X, -vector2.Y)

	if userFlag4 then
		local dynamicThumbstickScriptableBinding = self.playerData.actions.MoveAction:FindFirstChild("DynamicThumbstickScriptableBinding")

		if dynamicThumbstickScriptableBinding then
			dynamicThumbstickScriptableBinding:Fire(vector3)
		end
	elseif userFlag3 then
		local dynamicThumbstickScriptableBinding = self.playerData.actions.MoveAction:FindFirstChild("DynamicThumbstickScriptableBinding")

		if dynamicThumbstickScriptableBinding then
			local success, _ = pcall(function()
				dynamicThumbstickScriptableBinding.Type = Enum.InputBindingType.Scriptable
				dynamicThumbstickScriptableBinding:Fire(vector3)
			end)

			if not success then
				self.playerData.actions.MoveAction:Fire(vector3)
			end
		else
			self.playerData.actions.MoveAction:Fire(vector3)
		end
	else
		self.playerData.actions.MoveAction:Fire(vector3)
	end
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

function object:Create(parent)
	local IMAGE_ID = "rbxasset://textures/ui/Input/TouchControlsSheetV2.png"

	if self.thumbstickFrame then
		if userFlag6 then
		end

		thumbstickAction.Enabled = false

		if self.thumbstickStateChangedConn then
			self.thumbstickStateChangedConn:Disconnect()
			self.thumbstickStateChangedConn = nil
		end

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

		if not userFlag and self.avatarAbilitiesEnabledChangedConn then
			self.avatarAbilitiesEnabledChangedConn:Disconnect()
			self.avatarAbilitiesEnabledChangedConn = nil
		end

		if userFlag then
			if self.cameraChangedConn then
				self.cameraChangedConn:Disconnect()
				self.cameraChangedConn = nil
			end

			if self.currentCameraChangedConn then
				self.currentCameraChangedConn:Disconnect()
				self.currentCameraChangedConn = nil
			end

			if self.menuOpenedConnection then
				self.menuOpenedConnection:Disconnect()
				self.menuOpenedConnection = nil
			end

			if self.playerGuiChangedConn then
				self.playerGuiChangedConn:Disconnect()
				self.playerGuiChangedConn = nil
			end
		end
	end

	local function layoutThumbstickFrame(flag: boolean)
		if flag then
			self.thumbstickFrame.Size = UDim2.new(1, 100, 0.4, 100)
			self.thumbstickFrame.Position = UDim2.new(0, -100, 0.6, 0)
		else
			self.thumbstickFrame.Size = UDim2.new(0.4, 100, 0.6666666666666666, 100)
			self.thumbstickFrame.Position = UDim2.new(0, -100, 0.3333333333333333, 0)
		end
	end

	self.newStyle = userFlag and v3:isEnabled()
	self.thumbstickFrame = Instance.new("Frame")
	self.thumbstickFrame.BorderSizePixel = 0
	self.thumbstickFrame.Name = "DynamicThumbstickFrame"
	self.thumbstickFrame.Visible = false
	self.thumbstickFrame.BackgroundTransparency = 1
	self.thumbstickFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	self.thumbstickFrame.Active = false
	self.thumbstickFrame.Size = UDim2.new(0.4, 100, 0.6666666666666666, 100)
	self.thumbstickFrame.Position = UDim2.new(0, -100, 0.3333333333333333, 0)
	self.thumbstickButton = Instance.new("ImageButton")
	self.thumbstickButton.Name = "DynamicThumbstickUIModifier"
	self.thumbstickButton.BackgroundTransparency = 1
	self.thumbstickButton.ImageTransparency = 1
	self.thumbstickButton.AutoButtonColor = false
	self.thumbstickButton.Size = UDim2.new(1, 0, 1, 0)
	self.thumbstickButton.ZIndex = self.thumbstickFrame.ZIndex
	self.thumbstickButton.Visible = true
	self.thumbstickButton.Active = false
	self.thumbstickButton.Parent = self.thumbstickFrame

	if not userFlag6 then
		local v4

		if userFlag5 then
			v4 = thumbstickAction:FindFirstChild("DynamicTouchBinding")
		end

		if not v4 then
			v4 = Instance.new("InputBinding")
			v4.Name = "DynamicTouchBinding"
			v4.KeyCode = Enum.KeyCode.TouchPosition
			v4.Parent = thumbstickAction
		end

		v4.UIModifier = self.thumbstickButton
	end

	if userFlag and self.newStyle then
		self.startImage = Instance.new("Frame")
		self.startImage.Name = "ThumbstickStart"
		self.startImage.BackgroundColor3 = Color3.fromRGB(18, 18, 21)
		self.startImage.BackgroundTransparency = 0.4
		self.startImage.AnchorPoint = Vector2.new(0.5, 0.5)
		self.startImage.ZIndex = 10
		self.startImage.Parent = self.thumbstickFrame
		local uICorner = Instance.new("UICorner")
		uICorner.CornerRadius = UDim.new(0.5, 0)
		uICorner.Parent = self.startImage
		self.endImage = Instance.new("Frame")
		self.endImage.Name = "ThumbstickEnd"
		self.endImage.BackgroundTransparency = 1
		self.endImage.AnchorPoint = Vector2.new(0.5, 0.5)
		self.endImage.ZIndex = 10
		self.endImage.Parent = self.thumbstickFrame
		local uICorner2 = Instance.new("UICorner")
		uICorner2.CornerRadius = UDim.new(0.5, 0)
		uICorner2.Parent = self.endImage
		self.endImageStroke = Instance.new("UIStroke")
		self.endImageStroke.Thickness = userFlag5 and 1.5 or 2
		self.endImageStroke.Color = Color3.fromRGB(213, 215, 221)
		self.endImageStroke.Parent = self.endImage
		self.endImageCenter = Instance.new("Frame")
		self.endImageCenter.Name = "ThumbstickEndCenter"
		self.endImageCenter.BackgroundTransparency = 0
		self.endImageCenter.BackgroundColor3 = Color3.fromRGB(213, 215, 221)
		self.endImageCenter.AnchorPoint = Vector2.new(0.5, 0.5)
		self.endImageCenter.Size = UDim2.new(0.74, 0, 0.74, 0)
		self.endImageCenter.Position = UDim2.new(0.5, 0, 0.5, 0)
		self.endImageCenter.ZIndex = 10
		self.endImageCenter.Parent = self.endImage
		local uICorner3 = Instance.new("UICorner")
		uICorner3.CornerRadius = UDim.new(0.5, 0)
		uICorner3.Parent = self.endImageCenter

		for i = 1, count do
			self.middleImages[i] = Instance.new("Frame")
			self.middleImages[i].Name = "ThumbstickMiddle"
			self.middleImages[i].Visible = false
			self.middleImages[i].BackgroundTransparency = v2[i]
			self.middleImages[i].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			self.middleImages[i].AnchorPoint = Vector2.new(0.5, 0.5)
			self.middleImages[i].ZIndex = 9
			self.middleImages[i].Parent = self.thumbstickFrame
			local uICorner4 = Instance.new("UICorner")
			uICorner4.CornerRadius = UDim.new(0.5, 0)
			uICorner4.Parent = self.middleImages[i]
		end
	else
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
	end

	local function ResizeThumbstick()
		local absoluteSize = parent.AbsoluteSize
		local v4 = math.min(absoluteSize.X, absoluteSize.Y) > 500
		local newStyle

		if userFlag then
			newStyle = self.newStyle
		else
			newStyle = AvatarAbilitiesInterface.isEnabled()
		end

		local v6 = userFlag2 and newStyle and v4 and 1.6216216216216217 or v4 and 2 or 1
		self.thumbstickSize = 45 * v6
		self.thumbstickRingSize = 20 * v6
		self.middleSize = 10 * v6
		self.middleSpacing = 14 * v6
		self.radiusOfDeadZone = 2 * v6
		self.radiusOfMaxSpeed = 20 * v6
		local v7 = 74 * v6

		if not userFlag or self.isFirstTouch then
			if newStyle then
				self.startImage.Position = UDim2.new(
					0,
					v7 * 0.5 + 100 + (v4 and 100 or 64),
					1,
					-v7 * 0.5 - 100 - (v4 and 112 or 64)
				)
			else
				self.startImage.Position = UDim2.new(
					0,
					self.thumbstickRingSize * 3.3 + 100,
					1,
					-self.thumbstickRingSize * 2.8 - 100
				)
			end

			self.startImage.Size = UDim2.new(0, v7, 0, v7)
		end

		self.endImage.Position = self.startImage.Position

		if userFlag and self.newStyle then
			self.endImage.Size = UDim2.new(0, self.thumbstickSize * 0.6, 0, self.thumbstickSize * 0.6)
		else
			self.endImage.Size = UDim2.new(0, self.thumbstickSize * 0.8, 0, self.thumbstickSize * 0.8)
		end
	end

	ResizeThumbstick()
	self.absoluteSizeChangedConn = parent:GetPropertyChangedSignal("AbsoluteSize"):Connect(ResizeThumbstick)

	if not userFlag then
		self.avatarAbilitiesEnabledChangedConn = AvatarAbilitiesInterface.GetEnabledChangedSignal():Connect(ResizeThumbstick)
	end

	local function onCurrentCameraChanged()
		if self.cameraChangedConn then
			self.cameraChangedConn:Disconnect()
			self.cameraChangedConn = nil
		end

		local currentCamera = workspace.CurrentCamera

		if currentCamera then
			-- equivalent calls inferred from this helper; original call sites unknown
			local function onViewportSizeChanged()
				local viewportSize = currentCamera.ViewportSize
				layoutThumbstickFrame(viewportSize.X < viewportSize.Y)
			end

			self.cameraChangedConn = currentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(onViewportSizeChanged)
			onViewportSizeChanged() -- equivalent call inferred; original call site unknown
		end
	end

	self.currentCameraChangedConn = workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(onCurrentCameraChanged)

	if workspace.CurrentCamera or userFlag then
		onCurrentCameraChanged()
	end

	self.startImageFadeTween = nil
	self.endImageFadeTween = nil
	self.endImageCenterFadeTween = nil
	self.middleImageFadeTweens = {}

	if userFlag6 and self.isTouchActive then
		self:OnInputEnded()
	end

	self.moveTouchStartPosition = nil
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

	function self.onStateChanged(point: Vector2)
		if point == vector then
			if self.isTouchActive then
				self:OnInputEnded()
			end
		else
			local min = GuiService:GetInsetArea(Enum.ScreenInsets.None).Min
			local vector2 = Vector3.new(point.X + min.X, point.Y + min.Y, 0)

			if self.isTouchActive then
				if self.moveTouchFirstChanged then
					self.moveTouchFirstChanged = false
					local vector3 = Vector2.new(
						self.moveTouchStartPosition.X - self.thumbstickFrame.AbsolutePosition.X,
						self.moveTouchStartPosition.Y - self.thumbstickFrame.AbsolutePosition.Y
					)
					self.startImage.Visible = true
					self.startImage.Position = UDim2.new(0, vector3.X, 0, vector3.Y)
					self.endImage.Visible = true
					self.endImage.Position = self.startImage.Position
					self:FadeThumbstick(true)
					self:MoveStick(self.moveTouchStartPosition)
				end

				local vector3 = Vector2.new(
					vector2.X - self.moveTouchStartPosition.X,
					vector2.Y - self.moveTouchStartPosition.Y
				)

				if vector3.Magnitude > 0 then
					self:DoMove(vector3)
					self:MoveStick(vector2)
				end
			else
				self.isTouchActive = true

				if self.isFirstTouch then
					self.isFirstTouch = false
					local tweenInfo2 = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0)
					TweenService:Create(self.startImage, tweenInfo2, {
						Size = UDim2.new(0, 0, 0, 0)
					}):Play()

					if not (userFlag and self.newStyle) then
						TweenService:Create(self.endImage, tweenInfo2, {
							Size = UDim2.new(0, self.thumbstickSize, 0, self.thumbstickSize),
							ImageColor3 = Color3.new(0, 0, 0)
						}):Play()
					end
				end

				self.moveTouchStartPosition = vector2
				self.moveTouchFirstChanged = true
				self:DoFadeInBackground()
			end
		end
	end

	self.menuOpenedConnection = GuiService.MenuOpened:Connect(function()
		if self.isTouchActive then
			self:OnInputEnded()
		end
	end)
	local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")

	while not playerGui do
		localPlayer.ChildAdded:wait()
		playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")
	end

	local v4 = playerGui.CurrentScreenOrientation == Enum.ScreenOrientation.LandscapeLeft or playerGui.CurrentScreenOrientation == Enum.ScreenOrientation.LandscapeRight

	-- equivalent calls inferred from this helper; original call sites unknown
	local function longShowBackground()
		self.fadeInAndOutHalfDuration = 2.5
		self.fadeInAndOutBalance = 0.05
		self.tweenInAlphaStart = tick()
	end

	self.playerGuiChangedConn = playerGui:GetPropertyChangedSignal("CurrentScreenOrientation"):Connect(function()
		if v4 and playerGui.CurrentScreenOrientation == Enum.ScreenOrientation.Portrait or not v4 and playerGui.CurrentScreenOrientation ~= Enum.ScreenOrientation.Portrait then
			self.playerGuiChangedConn:Disconnect()
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