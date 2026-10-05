local createVector = vector.create
game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local BaseCharacterController = require(script.Parent:WaitForChild("BaseCharacterController"))
local object = setmetatable({}, BaseCharacterController)
object.__index = object

function object.new()
	local self = setmetatable(BaseCharacterController.new(), object)
	self.thumbpadFrame = nil
	self.touchChangedConn = nil
	self.touchEndedConn = nil
	self.menuOpenedConn = nil
	self.screenPos = nil
	self.isRight = false
	self.isLeft = false
	self.isUp = false
	self.isDown = false
	self.smArrowSize = nil
	self.lgArrowSize = nil
	self.smImgOffset = nil
	self.lgImgOffset = nil
	return self
end

-- equivalent calls inferred from this helper; original call sites unknown
local function doTween(object2, p, p2)
	object2:TweenSizeAndPosition(p, p2, Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 0.15, true)
end

local function CreateArrowLabel(name, position, size, imageRectOffset, imageRectSize, parent)
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = name
	imageLabel.Image = "rbxasset://textures/ui/DPadSheet.png"
	imageLabel.ImageRectOffset = imageRectOffset
	imageLabel.ImageRectSize = imageRectSize
	imageLabel.BackgroundTransparency = 1
	imageLabel.ImageColor3 = Color3.fromRGB(190, 190, 190)
	imageLabel.Size = size
	imageLabel.Position = position
	imageLabel.Parent = parent
	return imageLabel
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
		if not self.thumbpadFrame then
			self:Create(p2)
		end

		self.thumbpadFrame.Visible = true
	else
		self.thumbpadFrame.Visible = false
		self:OnInputEnded()
	end

	self.enabled = enabled
end

function object:OnInputEnded()
	self.moveVector = createVector(0, 0, 0)
	self.isJumping = false
	self.thumbpadFrame.Position = self.screenPos
	self.touchObject = nil
	self.isUp = false
	self.isDown = false
	self.isLeft = false
	self.isRight = false
	self.dArrow:TweenSizeAndPosition(
		self.smArrowSize,
		UDim2.new(0.5, -0.5 * self.smArrowSize.X.Offset, 1, self.lgImgOffset),
		Enum.EasingDirection.InOut,
		Enum.EasingStyle.Linear,
		0.15,
		true
	)
	self.uArrow:TweenSizeAndPosition(
		self.smArrowSize,
		UDim2.new(0.5, -0.5 * self.smArrowSize.X.Offset, 0, self.smImgOffset),
		Enum.EasingDirection.InOut,
		Enum.EasingStyle.Linear,
		0.15,
		true
	)
	self.lArrow:TweenSizeAndPosition(
		self.smArrowSize,
		UDim2.new(0, self.smImgOffset, 0.5, -0.5 * self.smArrowSize.Y.Offset),
		Enum.EasingDirection.InOut,
		Enum.EasingStyle.Linear,
		0.15,
		true
	)
	self.rArrow:TweenSizeAndPosition(
		self.smArrowSize,
		UDim2.new(1, self.lgImgOffset, 0.5, -0.5 * self.smArrowSize.Y.Offset),
		Enum.EasingDirection.InOut,
		Enum.EasingStyle.Linear,
		0.15,
		true
	)
end

function object:Create(parent)
	local IMAGE_ID = "rbxasset://textures/ui/DPadSheet.png"

	if self.thumbpadFrame then
		self.thumbpadFrame:Destroy()
		self.thumbpadFrame = nil
	end

	if self.touchChangedConn then
		self.touchChangedConn:Disconnect()
		self.touchChangedConn = nil
	end

	if self.touchEndedConn then
		self.touchEndedConn:Disconnect()
		self.touchEndedConn = nil
	end

	if self.menuOpenedConn then
		self.menuOpenedConn:Disconnect()
		self.menuOpenedConn = nil
	end

	local v = math.min(parent.AbsoluteSize.x, parent.AbsoluteSize.y) <= 500
	local v2 = v and 70 or 120
	self.screenPos = v and UDim2.new(0, v2 * 1.25, 1, -v2 - 20) or UDim2.new(0, v2 * 0.5 - 10, 1, -v2 * 1.75 - 10)
	self.thumbpadFrame = Instance.new("Frame")
	self.thumbpadFrame.Name = "ThumbpadFrame"
	self.thumbpadFrame.Visible = false
	self.thumbpadFrame.Active = true
	self.thumbpadFrame.Size = UDim2.new(0, v2 + 20, 0, v2 + 20)
	self.thumbpadFrame.Position = self.screenPos
	self.thumbpadFrame.BackgroundTransparency = 1
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = "OuterImage"
	imageLabel.Image = "rbxasset://textures/ui/TouchControlsSheet.png"
	imageLabel.ImageRectOffset = Vector2.new(0, 0)
	imageLabel.ImageRectSize = Vector2.new(220, 220)
	imageLabel.BackgroundTransparency = 1
	imageLabel.Size = UDim2.new(0, v2, 0, v2)
	imageLabel.Position = UDim2.new(0, 10, 0, 10)
	imageLabel.Parent = self.thumbpadFrame
	self.smArrowSize = v and UDim2.new(0, 32, 0, 32) or UDim2.new(0, 64, 0, 64)
	self.lgArrowSize = UDim2.new(0, self.smArrowSize.X.Offset * 2, 0, self.smArrowSize.Y.Offset * 2)
	local vector2 = Vector2.new(110, 110)
	self.smImgOffset = v and -4 or -9
	self.lgImgOffset = v and -28 or -55
	local uDim = UDim2.new(0.5, -0.5 * self.smArrowSize.X.Offset, 1, self.lgImgOffset)
	local smArrowSize = self.smArrowSize
	local vector3 = Vector2.new(8, 8)
	local imageLabel2 = Instance.new("ImageLabel")
	imageLabel2.Name = "DownArrow"
	imageLabel2.Image = IMAGE_ID
	imageLabel2.ImageRectOffset = vector3
	imageLabel2.ImageRectSize = vector2
	imageLabel2.BackgroundTransparency = 1
	imageLabel2.ImageColor3 = Color3.fromRGB(190, 190, 190)
	imageLabel2.Size = smArrowSize
	imageLabel2.Position = uDim
	imageLabel2.Parent = imageLabel
	self.dArrow = imageLabel2
	local uDim2 = UDim2.new(0.5, -0.5 * self.smArrowSize.X.Offset, 0, self.smImgOffset)
	local smArrowSize2 = self.smArrowSize
	local vector4 = Vector2.new(8, 266)
	local imageLabel3 = Instance.new("ImageLabel")
	imageLabel3.Name = "UpArrow"
	imageLabel3.Image = IMAGE_ID
	imageLabel3.ImageRectOffset = vector4
	imageLabel3.ImageRectSize = vector2
	imageLabel3.BackgroundTransparency = 1
	imageLabel3.ImageColor3 = Color3.fromRGB(190, 190, 190)
	imageLabel3.Size = smArrowSize2
	imageLabel3.Position = uDim2
	imageLabel3.Parent = imageLabel
	self.uArrow = imageLabel3
	local uDim3 = UDim2.new(0, self.smImgOffset, 0.5, -0.5 * self.smArrowSize.Y.Offset)
	local smArrowSize3 = self.smArrowSize
	local vector5 = Vector2.new(137, 137)
	local imageLabel4 = Instance.new("ImageLabel")
	imageLabel4.Name = "LeftArrow"
	imageLabel4.Image = IMAGE_ID
	imageLabel4.ImageRectOffset = vector5
	imageLabel4.ImageRectSize = vector2
	imageLabel4.BackgroundTransparency = 1
	imageLabel4.ImageColor3 = Color3.fromRGB(190, 190, 190)
	imageLabel4.Size = smArrowSize3
	imageLabel4.Position = uDim3
	imageLabel4.Parent = imageLabel
	self.lArrow = imageLabel4
	local uDim4 = UDim2.new(1, self.lgImgOffset, 0.5, -0.5 * self.smArrowSize.Y.Offset)
	local smArrowSize4 = self.smArrowSize
	local vector6 = Vector2.new(8, 137)
	local imageLabel5 = Instance.new("ImageLabel")
	imageLabel5.Name = "RightArrow"
	imageLabel5.Image = IMAGE_ID
	imageLabel5.ImageRectOffset = vector6
	imageLabel5.ImageRectSize = vector2
	imageLabel5.BackgroundTransparency = 1
	imageLabel5.ImageColor3 = Color3.fromRGB(190, 190, 190)
	imageLabel5.Size = smArrowSize4
	imageLabel5.Position = uDim4
	imageLabel5.Parent = imageLabel
	self.rArrow = imageLabel5

	local function doTween2(object3, p, p2)
		doTween(object3, p, p2) -- equivalent call inferred; original call site unknown
	end

	local vector7 = nil
	self.isRight = false
	self.isLeft = false
	self.isUp = false
	self.isDown = false

	local function doMove(position)
		local v3 = 2 * (position - vector7) / v2

		if v3.Magnitude < 0.1 then
			self.moveVector = createVector(0, 0, 0)
		else
			local v4 = v3.unit * ((v3.Magnitude - 0.1) / 0.9)

			if v4.Magnitude == 0 then
				self.moveVector = createVector(0, 0, 0)
			else
				self.moveVector = Vector3.new(v4.x, 0, v4.y).Unit
			end
		end

		local dot = self.moveVector:Dot(createVector(-0, -0, -1))
		local dot2 = self.moveVector:Dot(createVector(1, 0, 0))

		if dot > 0.5 then
			if not self.isUp then
				local v4 = self
				self.isUp = true
				v4.isDown = false
				self.uArrow:TweenSizeAndPosition(
					self.lgArrowSize,
					UDim2.new(0.5, -self.smArrowSize.X.Offset, 0, self.smImgOffset - 1.5 * self.smArrowSize.Y.Offset),
					Enum.EasingDirection.InOut,
					Enum.EasingStyle.Linear,
					0.15,
					true
				)
				self.dArrow:TweenSizeAndPosition(
					self.smArrowSize,
					UDim2.new(0.5, -0.5 * self.smArrowSize.X.Offset, 1, self.lgImgOffset),
					Enum.EasingDirection.InOut,
					Enum.EasingStyle.Linear,
					0.15,
					true
				)
			end
		elseif dot < -0.5 then
			if not self.isDown then
				local v4 = self
				self.isDown = true
				v4.isUp = false
				self.dArrow:TweenSizeAndPosition(
					self.lgArrowSize,
					UDim2.new(0.5, -self.smArrowSize.X.Offset, 1, self.lgImgOffset + 0.5 * self.smArrowSize.Y.Offset),
					Enum.EasingDirection.InOut,
					Enum.EasingStyle.Linear,
					0.15,
					true
				)
				self.uArrow:TweenSizeAndPosition(
					self.smArrowSize,
					UDim2.new(0.5, -0.5 * self.smArrowSize.X.Offset, 0, self.smImgOffset),
					Enum.EasingDirection.InOut,
					Enum.EasingStyle.Linear,
					0.15,
					true
				)
			end
		else
			local v4 = self
			self.isUp = false
			v4.isDown = false
			self.dArrow:TweenSizeAndPosition(
				self.smArrowSize,
				UDim2.new(0.5, -0.5 * self.smArrowSize.X.Offset, 1, self.lgImgOffset),
				Enum.EasingDirection.InOut,
				Enum.EasingStyle.Linear,
				0.15,
				true
			)
			self.uArrow:TweenSizeAndPosition(
				self.smArrowSize,
				UDim2.new(0.5, -0.5 * self.smArrowSize.X.Offset, 0, self.smImgOffset),
				Enum.EasingDirection.InOut,
				Enum.EasingStyle.Linear,
				0.15,
				true
			)
		end

		if dot2 > 0.5 then
			if not self.isRight then
				local v4 = self
				self.isRight = true
				v4.isLeft = false
				self.rArrow:TweenSizeAndPosition(
					self.lgArrowSize,
					UDim2.new(1, self.lgImgOffset + 0.5 * self.smArrowSize.X.Offset, 0.5, -self.smArrowSize.Y.Offset),
					Enum.EasingDirection.InOut,
					Enum.EasingStyle.Linear,
					0.15,
					true
				)
				self.lArrow:TweenSizeAndPosition(
					self.smArrowSize,
					UDim2.new(0, self.smImgOffset, 0.5, -0.5 * self.smArrowSize.Y.Offset),
					Enum.EasingDirection.InOut,
					Enum.EasingStyle.Linear,
					0.15,
					true
				)
			end
		elseif dot2 < -0.5 then
			if not self.isLeft then
				local v4 = self
				self.isLeft = true
				v4.isRight = false
				self.lArrow:TweenSizeAndPosition(
					self.lgArrowSize,
					UDim2.new(0, self.smImgOffset - 1.5 * self.smArrowSize.X.Offset, 0.5, -self.smArrowSize.Y.Offset),
					Enum.EasingDirection.InOut,
					Enum.EasingStyle.Linear,
					0.15,
					true
				)
				self.rArrow:TweenSizeAndPosition(
					self.smArrowSize,
					UDim2.new(1, self.lgImgOffset, 0.5, -0.5 * self.smArrowSize.Y.Offset),
					Enum.EasingDirection.InOut,
					Enum.EasingStyle.Linear,
					0.15,
					true
				)
			end
		else
			local v4 = self
			self.isRight = false
			v4.isLeft = false
			self.lArrow:TweenSizeAndPosition(
				self.smArrowSize,
				UDim2.new(0, self.smImgOffset, 0.5, -0.5 * self.smArrowSize.Y.Offset),
				Enum.EasingDirection.InOut,
				Enum.EasingStyle.Linear,
				0.15,
				true
			)
			self.rArrow:TweenSizeAndPosition(
				self.smArrowSize,
				UDim2.new(1, self.lgImgOffset, 0.5, -0.5 * self.smArrowSize.Y.Offset),
				Enum.EasingDirection.InOut,
				Enum.EasingStyle.Linear,
				0.15,
				true
			)
		end
	end

	self.thumbpadFrame.InputBegan:connect(function(touchObject)
		if self.touchObject or touchObject.UserInputType ~= Enum.UserInputType.Touch or touchObject.UserInputState ~= Enum.UserInputState.Begin then
			return
		end

		self.thumbpadFrame.Position = UDim2.new(
			0,
			touchObject.Position.x - 0.5 * self.thumbpadFrame.AbsoluteSize.x,
			0,
			touchObject.Position.y - 0.5 * self.thumbpadFrame.Size.Y.Offset
		)
		vector7 = Vector3.new(
			self.thumbpadFrame.AbsolutePosition.x + 0.5 * self.thumbpadFrame.AbsoluteSize.x,
			self.thumbpadFrame.AbsolutePosition.y + 0.5 * self.thumbpadFrame.AbsoluteSize.y,
			0
		)
		doMove(touchObject.Position)
		self.touchObject = touchObject
	end)
	self.touchChangedConn = UserInputService.TouchMoved:connect(function(p, _)
		if p == self.touchObject then
			doMove(self.touchObject.Position)
		end
	end)
	self.touchEndedConn = UserInputService.TouchEnded:Connect(function(otherPart)
		if otherPart == self.touchObject then
			self:OnInputEnded()
		end
	end)
	self.menuOpenedConn = GuiService.MenuOpened:Connect(function()
		if self.touchObject then
			self:OnInputEnded()
		end
	end)
	self.thumbpadFrame.Parent = parent
end

return object