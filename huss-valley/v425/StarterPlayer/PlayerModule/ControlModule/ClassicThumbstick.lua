local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local CommonUtils = require(script.Parent.Parent:WaitForChild("CommonUtils"))
local flagUtil = CommonUtils.get("FlagUtil")
local userFlag = flagUtil.getUserFlag("UserPlayerScriptsCCLIntegrationD")
local userFlag2 = flagUtil.getUserFlag("UserPlayerScriptsClassicThumbstickRenameUI")
local userFlag3 = flagUtil.getUserFlag("UserPlayerScriptsFireThroughScriptableBindings")
local userFlag4 = flagUtil.getUserFlag("UserPlayerScriptsSAuthDirectAPIs2")
local userFlag5 = flagUtil.getUserFlag("UserAbilitiesUserInterfaceC")
local userFlag6 = flagUtil.getUserFlag("UserPlayerScriptsResetDTTouchOnCreate")
local thumbstickAction = script.Parent.Parent:WaitForChild("InputContexts"):WaitForChild("TransformerContext"):WaitForChild("ThumbstickAction")
local vector = Vector2.new(-1, -1)
local AvatarAbilitiesInterface = require(script.Parent:WaitForChild("AvatarAbilitiesInterface"))
local v

if userFlag then
	v = AvatarAbilitiesInterface.get(Players.LocalPlayer)
else
	v = nil
end

local ActionController = require(script.Parent:WaitForChild("ActionController"))
local object = setmetatable({}, ActionController)
object.__index = object

function object.new(playerData)
	local self = setmetatable(ActionController.new(), object)
	self.playerData = playerData
	self.enabled = false
	self.isTouchActive = false
	self.isFollowStick = false
	self.thumbstickFrame = nil
	self.screenPos = nil
	self.stickImage = nil
	self.thumbstickSize = nil
	return self
end

local function setupThumbstickInput(p)
	for _, child in thumbstickAction:GetChildren() do
		if child.Name == "DynamicTouchBinding" or child.Name == "ClassicTouchBinding" then
			child:Destroy()
		end
	end

	local inputBinding = Instance.new("InputBinding")
	inputBinding.Name = "ClassicTouchBinding"
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

	local enabled = flag and true or false

	if self.enabled == enabled then
		return true
	end

	ActionController.Enable(self, enabled)
	self.isJumping = false

	if enabled then
		if not self.thumbstickFrame then
			self:Create(p)
		end

		if userFlag6 then
			setupThumbstickInput(self)
		end

		self.thumbstickStateChangedConn = thumbstickAction.StateChanged:Connect(self.onStateChanged)
		thumbstickAction.Enabled = true
		self.thumbstickFrame.Visible = true
	else
		if userFlag6 then
		end

		thumbstickAction.Enabled = false

		if self.thumbstickStateChangedConn then
			self.thumbstickStateChangedConn:Disconnect()
			self.thumbstickStateChangedConn = nil
		end

		self.thumbstickFrame.Visible = false
		self:OnInputEnded()
	end

	self.enabled = enabled
end

function object:OnInputEnded()
	self.isTouchActive = false
	self.thumbstickFrame.Position = self.screenPos
	self.stickImage.Position = UDim2.new(
		0,
		self.thumbstickFrame.Size.X.Offset / 2 - self.thumbstickSize / 4,
		0,
		self.thumbstickFrame.Size.Y.Offset / 2 - self.thumbstickSize / 4
	)

	if userFlag4 then
		local classicThumbstickScriptableBinding = self.playerData.actions.MoveAction:FindFirstChild("ClassicThumbstickScriptableBinding")

		if classicThumbstickScriptableBinding then
			classicThumbstickScriptableBinding:Fire(Vector2.zero)
		end
	elseif userFlag3 then
		local classicThumbstickScriptableBinding = self.playerData.actions.MoveAction:FindFirstChild("ClassicThumbstickScriptableBinding")

		if classicThumbstickScriptableBinding then
			local success, _ = pcall(function()
				classicThumbstickScriptableBinding.Type = Enum.InputBindingType.Scriptable
				classicThumbstickScriptableBinding:Fire(Vector2.zero)
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

	self.isJumping = false
	self.thumbstickFrame.Position = self.screenPos
end

function object:Create(parent)
	if self.thumbstickFrame then
		thumbstickAction.Enabled = false

		if self.thumbstickStateChangedConn then
			self.thumbstickStateChangedConn:Disconnect()
			self.thumbstickStateChangedConn = nil
		end

		self.thumbstickFrame:Destroy()
		self.thumbstickFrame = nil

		if self.absoluteSizeChangedConn then
			self.absoluteSizeChangedConn:Disconnect()
			self.absoluteSizeChangedConn = nil
		end

		if self.avatarAbilitiesEnabledChangedConn then
			self.avatarAbilitiesEnabledChangedConn:Disconnect()
			self.avatarAbilitiesEnabledChangedConn = nil
		end
	end

	self.thumbstickFrame = Instance.new("Frame")
	self.thumbstickFrame.Name = userFlag2 and "ClassicThumbstickFrame" or "ThumbstickFrame"
	self.thumbstickFrame.Active = true
	self.thumbstickFrame.Visible = false
	self.thumbstickFrame.BackgroundTransparency = 1
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = "OuterImage"
	imageLabel.Image = "rbxasset://textures/ui/TouchControlsSheet.png"
	imageLabel.ImageRectOffset = Vector2.new()
	imageLabel.ImageRectSize = Vector2.new(220, 220)
	imageLabel.BackgroundTransparency = 1
	imageLabel.Position = UDim2.new(0, 0, 0, 0)
	self.stickImage = Instance.new("ImageLabel")
	self.stickImage.Name = "StickImage"
	self.stickImage.Image = "rbxasset://textures/ui/TouchControlsSheet.png"
	self.stickImage.ImageRectOffset = Vector2.new(220, 0)
	self.stickImage.ImageRectSize = Vector2.new(111, 111)
	self.stickImage.BackgroundTransparency = 1
	self.stickImage.ZIndex = 2

	local function ResizeThumbstick()
		local v2 = math.min(parent.AbsoluteSize.X, parent.AbsoluteSize.Y) <= 500
		local v3

		if userFlag then
			v3 = v:isEnabled()
		else
			v3 = AvatarAbilitiesInterface.isEnabled()
		end

		if v3 then
			self.thumbstickSize = v2 and 72 or 120
			self.screenPos = UDim2.new(0, v2 and 64 or 100, 1, -self.thumbstickSize - (v2 and 64 or 112))
		else
			self.thumbstickSize = v2 and 70 or 120
			self.screenPos = v2 and UDim2.new(0, self.thumbstickSize / 2 - 10, 1, -self.thumbstickSize - 20) or UDim2.new(
				0,
				self.thumbstickSize / 2,
				1,
				-self.thumbstickSize * 1.75
			)
		end

		self.thumbstickFrame.Size = UDim2.new(0, self.thumbstickSize, 0, self.thumbstickSize)
		self.thumbstickFrame.Position = self.screenPos
		imageLabel.Size = UDim2.new(0, self.thumbstickSize, 0, self.thumbstickSize)
		self.stickImage.Size = UDim2.new(0, self.thumbstickSize / 2, 0, self.thumbstickSize / 2)
		self.stickImage.Position = UDim2.new(
			0,
			self.thumbstickSize / 2 - self.thumbstickSize / 4,
			0,
			self.thumbstickSize / 2 - self.thumbstickSize / 4
		)
	end

	ResizeThumbstick()
	self.absoluteSizeChangedConn = parent:GetPropertyChangedSignal("AbsoluteSize"):Connect(ResizeThumbstick)

	if userFlag then
		self.avatarAbilitiesEnabledChangedConn = v:GetEnabledChangedSignal():Connect(ResizeThumbstick)
	else
		self.avatarAbilitiesEnabledChangedConn = AvatarAbilitiesInterface.GetEnabledChangedSignal():Connect(ResizeThumbstick)
	end

	imageLabel.Parent = self.thumbstickFrame
	self.stickImage.Parent = self.thumbstickFrame
	self.thumbstickButton = Instance.new("ImageButton")
	self.thumbstickButton.Name = "ClassicThumbstickUIModifier"
	self.thumbstickButton.BackgroundTransparency = 1
	self.thumbstickButton.ImageTransparency = 1
	self.thumbstickButton.AutoButtonColor = false
	self.thumbstickButton.Size = UDim2.new(1, 0, 1, 0)
	self.thumbstickButton.ZIndex = self.thumbstickFrame.ZIndex
	self.thumbstickButton.Visible = true
	self.thumbstickButton.Active = false
	self.thumbstickButton.Parent = self.thumbstickFrame

	if not userFlag6 then
		local inputBinding = Instance.new("InputBinding")
		inputBinding.Name = "ClassicTouchBinding"
		inputBinding.KeyCode = Enum.KeyCode.TouchPosition
		inputBinding.UIModifier = self.thumbstickButton
		inputBinding.Parent = thumbstickAction
	end

	local vector2 = nil

	local function DoMove(vector3: Vector2)
		local v2 = vector3 / (self.thumbstickSize / 2)
		local magnitude = v2.magnitude
		local vector4

		if magnitude < 0.05 then
			vector4 = Vector2.new()
		else
			vector4 = v2.unit * math.min(1, (magnitude - 0.05) / 0.95)
		end

		local vector5 = Vector2.new(vector4.X, -vector4.Y)

		if userFlag4 then
			local classicThumbstickScriptableBinding = self.playerData.actions.MoveAction:FindFirstChild("ClassicThumbstickScriptableBinding")

			if classicThumbstickScriptableBinding then
				classicThumbstickScriptableBinding:Fire(vector5)
			end
		elseif userFlag3 then
			local classicThumbstickScriptableBinding = self.playerData.actions.MoveAction:FindFirstChild("ClassicThumbstickScriptableBinding")

			if classicThumbstickScriptableBinding then
				local success, _ = pcall(function()
					classicThumbstickScriptableBinding.Type = Enum.InputBindingType.Scriptable
					classicThumbstickScriptableBinding:Fire(vector5)
				end)

				if not success then
					self.playerData.actions.MoveAction:Fire(vector5)
				end
			else
				self.playerData.actions.MoveAction:Fire(vector5)
			end
		else
			self.playerData.actions.MoveAction:Fire(vector5)
		end
	end

	local function MoveStick(vector3: Vector3)
		local vector4 = Vector2.new(vector3.X - vector2.X, vector3.Y - vector2.Y)
		local magnitude = vector4.magnitude
		local v2 = self.thumbstickFrame.AbsoluteSize.X / 2

		if self.isFollowStick and v2 < magnitude then
			local v3 = vector4.unit * v2

			if userFlag5 then
				local absolutePosition = parent.AbsolutePosition
				self.thumbstickFrame.Position = UDim2.new(
					0,
					vector3.X - absolutePosition.X - self.thumbstickFrame.AbsoluteSize.X / 2 - v3.X,
					0,
					vector3.Y - absolutePosition.Y - self.thumbstickFrame.AbsoluteSize.Y / 2 - v3.Y
				)
			else
				self.thumbstickFrame.Position = UDim2.new(
					0,
					vector3.X - self.thumbstickFrame.AbsoluteSize.X / 2 - v3.X,
					0,
					vector3.Y - self.thumbstickFrame.AbsoluteSize.Y / 2 - v3.Y
				)
			end
		else
			local v3 = math.min(magnitude, v2)
			vector4 = vector4.unit * v3
		end

		self.stickImage.Position = UDim2.new(
			0,
			vector4.X + self.stickImage.AbsoluteSize.X / 2,
			0,
			vector4.Y + self.stickImage.AbsoluteSize.Y / 2
		)
	end

	function self.onStateChanged(point: Vector2)
		if point == vector then
			if self.isTouchActive then
				self:OnInputEnded()
			end
		else
			local min = GuiService:GetInsetArea(Enum.ScreenInsets.None).Min
			local vector3 = Vector3.new(point.X + min.X, point.Y + min.Y, 0)

			if self.isTouchActive then
				vector2 = Vector2.new(
					self.thumbstickFrame.AbsolutePosition.X + self.thumbstickFrame.AbsoluteSize.X / 2,
					self.thumbstickFrame.AbsolutePosition.Y + self.thumbstickFrame.AbsoluteSize.Y / 2
				)
				DoMove(Vector2.new(vector3.X - vector2.X, vector3.Y - vector2.Y))
				MoveStick(vector3)
			else
				self.isTouchActive = true

				if userFlag5 then
					local absolutePosition = parent.AbsolutePosition
					self.thumbstickFrame.Position = UDim2.new(
						0,
						vector3.X - absolutePosition.X - self.thumbstickFrame.Size.X.Offset / 2,
						0,
						vector3.Y - absolutePosition.Y - self.thumbstickFrame.Size.Y.Offset / 2
					)
				else
					self.thumbstickFrame.Position = UDim2.new(
						0,
						vector3.X - self.thumbstickFrame.Size.X.Offset / 2,
						0,
						vector3.Y - self.thumbstickFrame.Size.Y.Offset / 2
					)
				end

				vector2 = Vector2.new(
					self.thumbstickFrame.AbsolutePosition.X + self.thumbstickFrame.AbsoluteSize.X / 2,
					self.thumbstickFrame.AbsolutePosition.Y + self.thumbstickFrame.AbsoluteSize.Y / 2
				)
			end
		end
	end

	GuiService.MenuOpened:Connect(function()
		if self.isTouchActive then
			self:OnInputEnded()
		end
	end)
	self.thumbstickFrame.Parent = parent
end

return object