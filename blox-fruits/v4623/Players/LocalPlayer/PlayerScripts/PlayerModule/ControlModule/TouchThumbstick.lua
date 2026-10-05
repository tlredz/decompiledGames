local createVector = vector.create
game:GetService("Players")
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")
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

function object:Enable(p, p2)
	if p == nil then
		return false
	end

	local enabled = p and true or false

	if self.enabled == enabled then
		return true
	end

	self.moveVector = createVector(0, 0, 0)
	self.isJumping = false

	if enabled then
		if not self.thumbstickFrame then
			self:Create(p2)
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
	end

	local v = math.min(parent.AbsoluteSize.x, parent.AbsoluteSize.y) <= 500
	self.thumbstickSize = v and 70 or 120
	self.screenPos = v and UDim2.new(0, self.thumbstickSize / 2 - 10, 1, -self.thumbstickSize - 20) or UDim2.new(
		0,
		self.thumbstickSize / 2,
		1,
		-self.thumbstickSize * 1.75
	)
	self.thumbstickFrame = Instance.new("Frame")
	self.thumbstickFrame.Name = "ThumbstickFrame"
	self.thumbstickFrame.Active = true
	self.thumbstickFrame.Visible = false
	self.thumbstickFrame.Size = UDim2.new(0, self.thumbstickSize, 0, self.thumbstickSize)
	self.thumbstickFrame.Position = self.screenPos
	self.thumbstickFrame.BackgroundTransparency = 1
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = "OuterImage"
	imageLabel.Image = "rbxasset://textures/ui/TouchControlsSheet.png"
	imageLabel.ImageRectOffset = Vector2.new()
	imageLabel.ImageRectSize = Vector2.new(220, 220)
	imageLabel.BackgroundTransparency = 1
	imageLabel.Size = UDim2.new(0, self.thumbstickSize, 0, self.thumbstickSize)
	imageLabel.Position = UDim2.new(0, 0, 0, 0)
	imageLabel.Parent = self.thumbstickFrame
	self.stickImage = Instance.new("ImageLabel")
	self.stickImage.Name = "StickImage"
	self.stickImage.Image = "rbxasset://textures/ui/TouchControlsSheet.png"
	self.stickImage.ImageRectOffset = Vector2.new(220, 0)
	self.stickImage.ImageRectSize = Vector2.new(111, 111)
	self.stickImage.BackgroundTransparency = 1
	self.stickImage.Size = UDim2.new(0, self.thumbstickSize / 2, 0, self.thumbstickSize / 2)
	self.stickImage.Position = UDim2.new(
		0,
		self.thumbstickSize / 2 - self.thumbstickSize / 4,
		0,
		self.thumbstickSize / 2 - self.thumbstickSize / 4
	)
	self.stickImage.ZIndex = 2
	self.stickImage.Parent = self.thumbstickFrame
	local vector2 = nil

	-- equivalent calls inferred from this helper; original call sites unknown
	local function DoMove(vector3)
		local v2 = vector3 / (self.thumbstickSize / 2)
		local magnitude = v2.magnitude
		local vector4

		if magnitude < 0.05 then
			vector4 = Vector3.new()
		else
			local v3 = v2.unit * ((magnitude - 0.05) / 0.95)
			vector4 = Vector3.new(v3.x, 0, v3.y)
		end

		self.moveVector = vector4
	end

	local function MoveStick(position)
		local vector3 = Vector2.new(position.x - vector2.x, position.y - vector2.y)
		local magnitude = vector3.magnitude
		local v2 = self.thumbstickFrame.AbsoluteSize.x / 2

		if self.isFollowStick and v2 < magnitude then
			local v3 = vector3.unit * v2
			self.thumbstickFrame.Position = UDim2.new(
				0,
				position.x - self.thumbstickFrame.AbsoluteSize.x / 2 - v3.x,
				0,
				position.y - self.thumbstickFrame.AbsoluteSize.y / 2 - v3.y
			)
		else
			local v3 = math.min(magnitude, v2)
			vector3 = vector3.unit * v3
		end

		self.stickImage.Position = UDim2.new(
			0,
			vector3.x + self.stickImage.AbsoluteSize.x / 2,
			0,
			vector3.y + self.stickImage.AbsoluteSize.y / 2
		)
	end

	self.thumbstickFrame.InputBegan:Connect(function(moveTouchObject)
		if self.moveTouchObject or moveTouchObject.UserInputType ~= Enum.UserInputType.Touch or moveTouchObject.UserInputState ~= Enum.UserInputState.Begin then
			return
		end

		self.moveTouchObject = moveTouchObject
		self.thumbstickFrame.Position = UDim2.new(
			0,
			moveTouchObject.Position.x - self.thumbstickFrame.Size.X.Offset / 2,
			0,
			moveTouchObject.Position.y - self.thumbstickFrame.Size.Y.Offset / 2
		)
		vector2 = Vector2.new(
			self.thumbstickFrame.AbsolutePosition.x + self.thumbstickFrame.AbsoluteSize.x / 2,
			self.thumbstickFrame.AbsolutePosition.y + self.thumbstickFrame.AbsoluteSize.y / 2
		)
		Vector2.new(moveTouchObject.Position.x - vector2.x, moveTouchObject.Position.y - vector2.y)
	end)
	self.onTouchMovedConn = UserInputService.TouchMoved:Connect(function(p, _)
		if p == self.moveTouchObject then
			vector2 = Vector2.new(
				self.thumbstickFrame.AbsolutePosition.x + self.thumbstickFrame.AbsoluteSize.x / 2,
				self.thumbstickFrame.AbsolutePosition.y + self.thumbstickFrame.AbsoluteSize.y / 2
			)
			DoMove(Vector2.new(p.Position.x - vector2.x, p.Position.y - vector2.y)) -- equivalent call inferred; original call site unknown
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