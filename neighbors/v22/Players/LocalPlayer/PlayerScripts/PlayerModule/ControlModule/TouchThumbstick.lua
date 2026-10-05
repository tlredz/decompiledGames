local createVector = vector.create
game:GetService("Players")
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")
UserSettings():GetService("UserGameSettings")
local commonUtils = script.Parent.Parent:WaitForChild("CommonUtils")
local FlagUtil = require(commonUtils:WaitForChild("FlagUtil"))
local userFlag = FlagUtil.getUserFlag("UserAllowAbilityControls")
local AvatarAbilitiesInterface

if userFlag then
	AvatarAbilitiesInterface = require(script.Parent:WaitForChild("AvatarAbilitiesInterface"))
else
	AvatarAbilitiesInterface = nil
end

local BaseCharacterController = require(script.Parent:WaitForChild("BaseCharacterController"))
local object = setmetatable({}, BaseCharacterController)
object.__index = object

function object.new()
	local self = setmetatable(BaseCharacterController.new(), object)
	self.isFollowStick = false
	self.thumbstickFrame = nil
	self.moveTouchObject = nil
	self.onTouchMovedConn = nil
	self.onTouchEndedConn = nil
	self.screenPos = nil
	self.stickImage = nil
	self.thumbstickSize = nil
	return self
end

function object:Enable(flag: boolean?, p)
	if flag == nil then
		return false
	end

	local enabled = flag and true or false

	if self.enabled == enabled then
		return true
	end

	self.moveVector = createVector(0, 0, 0)
	self.isJumping = false

	if enabled then
		if not self.thumbstickFrame then
			self:Create(p)
		end

		self.thumbstickFrame.Visible = true
	else
		self.thumbstickFrame.Visible = false
		self:OnInputEnded()
	end

	self.enabled = enabled
end

function object:OnInputEnded()
	self.thumbstickFrame.Position = self.screenPos
	self.stickImage.Position = UDim2.new(
		0,
		self.thumbstickFrame.Size.X.Offset / 2 - self.thumbstickSize / 4,
		0,
		self.thumbstickFrame.Size.Y.Offset / 2 - self.thumbstickSize / 4
	)
	self.moveVector = createVector(0, 0, 0)
	self.isJumping = false
	self.thumbstickFrame.Position = self.screenPos
	self.moveTouchObject = nil
end

function object:Create(parent)
	if self.thumbstickFrame then
		self.thumbstickFrame:Destroy()
		self.thumbstickFrame = nil

		if self.onTouchMovedConn then
			self.onTouchMovedConn:Disconnect()
			self.onTouchMovedConn = nil
		end

		if self.onTouchEndedConn then
			self.onTouchEndedConn:Disconnect()
			self.onTouchEndedConn = nil
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

	self.thumbstickFrame = Instance.new("Frame")
	self.thumbstickFrame.Name = "ThumbstickFrame"
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
		local v = math.min(parent.AbsoluteSize.X, parent.AbsoluteSize.Y) <= 500

		if userFlag and AvatarAbilitiesInterface.isEnabled() then
			self.thumbstickSize = v and 72 or 120
			self.screenPos = UDim2.new(0, v and 64 or 100, 1, -self.thumbstickSize - (v and 64 or 112))
		else
			self.thumbstickSize = v and 70 or 120
			self.screenPos = v and UDim2.new(0, self.thumbstickSize / 2 - 10, 1, -self.thumbstickSize - 20) or UDim2.new(
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
		self.avatarAbilitiesEnabledChangedConn = AvatarAbilitiesInterface.GetEnabledChangedSignal():Connect(ResizeThumbstick)
	end

	imageLabel.Parent = self.thumbstickFrame
	self.stickImage.Parent = self.thumbstickFrame
	local vector2 = nil

	-- equivalent calls inferred from this helper; original call sites unknown
	local function DoMove(point: Vector2)
		local v = point / (self.thumbstickSize / 2)
		local magnitude = v.magnitude
		local vector3

		if magnitude < 0.05 then
			vector3 = Vector3.new()
		else
			local v2 = v.unit * math.min(1, (magnitude - 0.05) / 0.95)
			vector3 = Vector3.new(v2.X, 0, v2.Y)
		end

		self.moveVector = vector3
	end

	local function MoveStick(position: Vector3)
		local vector3 = Vector2.new(position.X - vector2.X, position.Y - vector2.Y)
		local magnitude = vector3.magnitude
		local v = self.thumbstickFrame.AbsoluteSize.X / 2

		if self.isFollowStick and v < magnitude then
			local v2 = vector3.unit * v
			self.thumbstickFrame.Position = UDim2.new(
				0,
				position.X - self.thumbstickFrame.AbsoluteSize.X / 2 - v2.X,
				0,
				position.Y - self.thumbstickFrame.AbsoluteSize.Y / 2 - v2.Y
			)
		else
			local v2 = math.min(magnitude, v)
			vector3 = vector3.unit * v2
		end

		self.stickImage.Position = UDim2.new(
			0,
			vector3.X + self.stickImage.AbsoluteSize.X / 2,
			0,
			vector3.Y + self.stickImage.AbsoluteSize.Y / 2
		)
	end

	self.thumbstickFrame.InputBegan:Connect(function(moveTouchObject)
		if self.moveTouchObject or moveTouchObject.UserInputType ~= Enum.UserInputType.Touch or moveTouchObject.UserInputState ~= Enum.UserInputState.Begin then
			return
		end

		self.moveTouchObject = moveTouchObject
		self.thumbstickFrame.Position = UDim2.new(
			0,
			moveTouchObject.Position.X - self.thumbstickFrame.Size.X.Offset / 2,
			0,
			moveTouchObject.Position.Y - self.thumbstickFrame.Size.Y.Offset / 2
		)
		vector2 = Vector2.new(
			self.thumbstickFrame.AbsolutePosition.X + self.thumbstickFrame.AbsoluteSize.X / 2,
			self.thumbstickFrame.AbsolutePosition.Y + self.thumbstickFrame.AbsoluteSize.Y / 2
		)
		Vector2.new(moveTouchObject.Position.X - vector2.X, moveTouchObject.Position.Y - vector2.Y)
	end)
	self.onTouchMovedConn = UserInputService.TouchMoved:Connect(function(p, _: boolean)
		if p == self.moveTouchObject then
			vector2 = Vector2.new(
				self.thumbstickFrame.AbsolutePosition.X + self.thumbstickFrame.AbsoluteSize.X / 2,
				self.thumbstickFrame.AbsolutePosition.Y + self.thumbstickFrame.AbsoluteSize.Y / 2
			)
			DoMove(Vector2.new(p.Position.X - vector2.X, p.Position.Y - vector2.Y)) -- equivalent call inferred; original call site unknown
			MoveStick(p.Position)
		end
	end)
	self.onTouchEndedConn = UserInputService.TouchEnded:Connect(function(otherPart, _)
		if otherPart == self.moveTouchObject then
			self:OnInputEnded()
		end
	end)
	GuiService.MenuOpened:Connect(function()
		if self.moveTouchObject then
			self:OnInputEnded()
		end
	end)
	self.thumbstickFrame.Parent = parent
end

return object