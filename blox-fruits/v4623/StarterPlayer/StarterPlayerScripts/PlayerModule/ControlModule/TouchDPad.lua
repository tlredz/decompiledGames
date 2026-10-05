local createVector = vector.create
game:GetService("Players")
local GuiService = game:GetService("GuiService")
local v = {
	createVector(1, 0, 0),
	(createVector(1, 0, 1)).unit,
	createVector(0, 0, 1),
	(createVector(-1, 0, 1)).unit,
	createVector(-1, 0, 0),
	(createVector(-1, 0, -1)).unit,
	createVector(0, 0, -1),
	(createVector(1, 0, -1)).unit
}
local BaseCharacterController = require(script.Parent:WaitForChild("BaseCharacterController"))
local object = setmetatable({}, BaseCharacterController)
object.__index = object

function object.new()
	local self = setmetatable(BaseCharacterController.new(), object)
	self.DPadFrame = nil
	self.touchObject = nil
	self.flBtn = nil
	self.frBtn = nil
	return self
end

local function CreateArrowLabel(name, position, size, imageRectOffset, imageRectSize, parent)
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = name
	imageLabel.Image = "rbxasset://textures/ui/DPadSheet.png"
	imageLabel.ImageRectOffset = imageRectOffset
	imageLabel.ImageRectSize = imageRectSize
	imageLabel.BackgroundTransparency = 1
	imageLabel.Size = size
	imageLabel.Position = position
	imageLabel.Parent = parent
	return imageLabel
end

function object:GetCenterPosition()
	return Vector2.new(
		self.DPadFrame.AbsolutePosition.x + self.DPadFrame.AbsoluteSize.x * 0.5,
		self.DPadFrame.AbsolutePosition.y + self.DPadFrame.AbsoluteSize.y * 0.5
	)
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
		if not self.DPadFrame then
			self:Create(p2)
		end

		self.DPadFrame.Visible = true
	else
		self.DPadFrame.Visible = false
		self:OnInputEnded()
	end

	self.enabled = enabled
end

function object:GetIsJumping()
	local isJumping = self.isJumping
	self.isJumping = false
	return isJumping
end

function object:OnInputEnded()
	self.touchObject = nil

	if self.flBtn then
		self.flBtn.Visible = false
	end

	if self.frBtn then
		self.frBtn.Visible = false
	end

	self.moveVector = createVector(0, 0, 0)
end

function object:Create(parent)
	local IMAGE_ID = "rbxasset://textures/ui/DPadSheet.png"

	if self.DPadFrame then
		self.DPadFrame:Destroy()
		self.DPadFrame = nil
	end

	local uDim = UDim2.new(0, 10, 1, -230)
	self.DPadFrame = Instance.new("Frame")
	self.DPadFrame.Name = "DPadFrame"
	self.DPadFrame.Active = true
	self.DPadFrame.Visible = false
	self.DPadFrame.Size = UDim2.new(0, 192, 0, 192)
	self.DPadFrame.Position = uDim
	self.DPadFrame.BackgroundTransparency = 1
	local uDim2 = UDim2.new(0, 23, 0, 23)
	local uDim3 = UDim2.new(0, 64, 0, 64)
	local vector2 = Vector2.new(46, 46)
	local vector3 = Vector2.new(128, 128)
	local uDim4 = UDim2.new(0.5, -32, 1, -64)
	local vector4 = Vector2.new(0, 0)
	local dPadFrame = self.DPadFrame
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = "BackButton"
	imageLabel.Image = IMAGE_ID
	imageLabel.ImageRectOffset = vector4
	imageLabel.ImageRectSize = vector3
	imageLabel.BackgroundTransparency = 1
	imageLabel.Size = uDim3
	imageLabel.Position = uDim4
	imageLabel.Parent = dPadFrame
	local uDim5 = UDim2.new(0.5, -32, 0, 0)
	local vector5 = Vector2.new(0, 258)
	local dPadFrame2 = self.DPadFrame
	local imageLabel2 = Instance.new("ImageLabel")
	imageLabel2.Name = "ForwardButton"
	imageLabel2.Image = IMAGE_ID
	imageLabel2.ImageRectOffset = vector5
	imageLabel2.ImageRectSize = vector3
	imageLabel2.BackgroundTransparency = 1
	imageLabel2.Size = uDim3
	imageLabel2.Position = uDim5
	imageLabel2.Parent = dPadFrame2
	local uDim6 = UDim2.new(0, 0, 0.5, -32)
	local vector6 = Vector2.new(129, 129)
	local dPadFrame3 = self.DPadFrame
	local imageLabel3 = Instance.new("ImageLabel")
	imageLabel3.Name = "LeftButton"
	imageLabel3.Image = IMAGE_ID
	imageLabel3.ImageRectOffset = vector6
	imageLabel3.ImageRectSize = vector3
	imageLabel3.BackgroundTransparency = 1
	imageLabel3.Size = uDim3
	imageLabel3.Position = uDim6
	imageLabel3.Parent = dPadFrame3
	local uDim7 = UDim2.new(1, -64, 0.5, -32)
	local vector7 = Vector2.new(0, 129)
	local dPadFrame4 = self.DPadFrame
	local imageLabel4 = Instance.new("ImageLabel")
	imageLabel4.Name = "RightButton"
	imageLabel4.Image = IMAGE_ID
	imageLabel4.ImageRectOffset = vector7
	imageLabel4.ImageRectSize = vector3
	imageLabel4.BackgroundTransparency = 1
	imageLabel4.Size = uDim3
	imageLabel4.Position = uDim7
	imageLabel4.Parent = dPadFrame4
	local uDim8 = UDim2.new(0.5, -32, 0.5, -32)
	local vector8 = Vector2.new(129, 0)
	local dPadFrame5 = self.DPadFrame
	local imageLabel5 = Instance.new("ImageLabel")
	imageLabel5.Name = "JumpButton"
	imageLabel5.Image = IMAGE_ID
	imageLabel5.ImageRectOffset = vector8
	imageLabel5.ImageRectSize = vector3
	imageLabel5.BackgroundTransparency = 1
	imageLabel5.Size = uDim3
	imageLabel5.Position = uDim8
	imageLabel5.Parent = dPadFrame5
	local uDim9 = UDim2.new(0, 35, 0, 35)
	local vector9 = Vector2.new(129, 258)
	local dPadFrame6 = self.DPadFrame
	local imageLabel6 = Instance.new("ImageLabel")
	imageLabel6.Name = "ForwardLeftButton"
	imageLabel6.Image = IMAGE_ID
	imageLabel6.ImageRectOffset = vector9
	imageLabel6.ImageRectSize = vector2
	imageLabel6.BackgroundTransparency = 1
	imageLabel6.Size = uDim2
	imageLabel6.Position = uDim9
	imageLabel6.Parent = dPadFrame6
	self.flBtn = imageLabel6
	local uDim10 = UDim2.new(1, -55, 0, 35)
	local vector10 = Vector2.new(176, 258)
	local dPadFrame7 = self.DPadFrame
	local imageLabel7 = Instance.new("ImageLabel")
	imageLabel7.Name = "ForwardRightButton"
	imageLabel7.Image = IMAGE_ID
	imageLabel7.ImageRectOffset = vector10
	imageLabel7.ImageRectSize = vector2
	imageLabel7.BackgroundTransparency = 1
	imageLabel7.Size = uDim2
	imageLabel7.Position = uDim10
	imageLabel7.Parent = dPadFrame7
	self.frBtn = imageLabel7
	self.flBtn.Visible = false
	self.frBtn.Visible = false
	imageLabel5.InputBegan:Connect(function(_)
		self.isJumping = true
	end)

	local function normalizeDirection(position)
		local v2 = imageLabel5.AbsoluteSize.x * 0.5
		local centerPosition = self:GetCenterPosition()
		local vector11 = Vector2.new(position.x - centerPosition.x, position.y - centerPosition.y)

		if v2 < vector11.magnitude then
			self.moveVector = v[math.floor(math.atan2(vector11.y, vector11.x) * 8 / 6.283185307179586 + 8.5) % 8 + 1]
		end

		if not self.flBtn.Visible and self.moveVector == v[7] then
			self.flBtn.Visible = true
			self.frBtn.Visible = true
		end
	end

	self.DPadFrame.InputBegan:Connect(function(touchObject)
		if self.touchObject or touchObject.UserInputType ~= Enum.UserInputType.Touch then
			return
		end

		self.touchObject = touchObject
		normalizeDirection(self.touchObject.Position)
	end)
	self.DPadFrame.InputChanged:Connect(function(input)
		if input == self.touchObject then
			normalizeDirection(self.touchObject.Position)
			self.isJumping = false
		end
	end)
	self.DPadFrame.InputEnded:connect(function(p)
		if p == self.touchObject then
			self:OnInputEnded()
		end
	end)
	GuiService.MenuOpened:Connect(function()
		if self.touchObject then
			self:OnInputEnded()
		end
	end)
	self.DPadFrame.Parent = parent
end

return object