local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
script.Parent.Parent:WaitForChild("CommonUtils")
local vector = Vector3.new()
local BaseCharacterController = require(script.Parent:WaitForChild("BaseCharacterController"))
local object = setmetatable({}, BaseCharacterController)
object.__index = object

function object.new(CONTROL_ACTION_PRIORITY)
	local self = setmetatable(BaseCharacterController.new(), object)
	self.CONTROL_ACTION_PRIORITY = CONTROL_ACTION_PRIORITY
	self.forwardValue = 0
	self.backwardValue = 0
	self.leftValue = 0
	self.rightValue = 0
	self.jumpEnabled = true
	return self
end

function object:Enable(enabled: boolean)
	if enabled == self.enabled then
		return true
	end

	self.forwardValue = 0
	self.backwardValue = 0
	self.leftValue = 0
	self.rightValue = 0
	self.moveVector = vector
	self.jumpRequested = false
	self:UpdateJump()

	if enabled then
		self:BindContextActions()
		self:ConnectFocusEventListeners()
	else
		self._connectionUtil:disconnectAll()
	end

	self.enabled = enabled
	return true
end

function object:UpdateMovement(p)
	if p == Enum.UserInputState.Cancel then
		self.moveVector = vector
	else
		self.moveVector = Vector3.new(self.leftValue + self.rightValue, 0, self.forwardValue + self.backwardValue)
	end
end

function object:UpdateJump()
	self.isJumping = self.jumpRequested
end

function object:BindContextActions()
	ContextActionService:BindActionAtPriority("moveForwardAction", function(_, p, _)
		self.forwardValue = p == Enum.UserInputState.Begin and -1 or 0
		self:UpdateMovement(p)
		return Enum.ContextActionResult.Pass
	end, false, self.CONTROL_ACTION_PRIORITY, Enum.PlayerActions.CharacterForward)
	ContextActionService:BindActionAtPriority("moveBackwardAction", function(_, p, _)
		self.backwardValue = p == Enum.UserInputState.Begin and 1 or 0
		self:UpdateMovement(p)
		return Enum.ContextActionResult.Pass
	end, false, self.CONTROL_ACTION_PRIORITY, Enum.PlayerActions.CharacterBackward)
	ContextActionService:BindActionAtPriority("moveLeftAction", function(_, p, _)
		self.leftValue = p == Enum.UserInputState.Begin and -1 or 0
		self:UpdateMovement(p)
		return Enum.ContextActionResult.Pass
	end, false, self.CONTROL_ACTION_PRIORITY, Enum.PlayerActions.CharacterLeft)
	ContextActionService:BindActionAtPriority("moveRightAction", function(_, p, _)
		self.rightValue = p == Enum.UserInputState.Begin and 1 or 0
		self:UpdateMovement(p)
		return Enum.ContextActionResult.Pass
	end, false, self.CONTROL_ACTION_PRIORITY, Enum.PlayerActions.CharacterRight)
	ContextActionService:BindActionAtPriority("jumpAction", function(_, p, _)
		self.jumpRequested = self.jumpEnabled and p == Enum.UserInputState.Begin
		self:UpdateJump()
		return Enum.ContextActionResult.Pass
	end, false, self.CONTROL_ACTION_PRIORITY, Enum.PlayerActions.CharacterJump)
	self._connectionUtil:trackBoundFunction("moveForwardAction", function()
		ContextActionService:UnbindAction("moveForwardAction")
	end)
	self._connectionUtil:trackBoundFunction("moveBackwardAction", function()
		ContextActionService:UnbindAction("moveBackwardAction")
	end)
	self._connectionUtil:trackBoundFunction("moveLeftAction", function()
		ContextActionService:UnbindAction("moveLeftAction")
	end)
	self._connectionUtil:trackBoundFunction("moveRightAction", function()
		ContextActionService:UnbindAction("moveRightAction")
	end)
	self._connectionUtil:trackBoundFunction("jumpAction", function()
		ContextActionService:UnbindAction("jumpAction")
	end)
end

function object:ConnectFocusEventListeners()
	local function onFocusReleased()
		self.moveVector = vector
		self.forwardValue = 0
		self.backwardValue = 0
		self.leftValue = 0
		self.rightValue = 0
		self.jumpRequested = false
		self:UpdateJump()
	end

	local function onTextFocusGained(_)
		self.jumpRequested = false
		self:UpdateJump()
	end

	self._connectionUtil:trackConnection(
		"textBoxFocusReleased",
		UserInputService.TextBoxFocusReleased:Connect(onFocusReleased)
	)
	self._connectionUtil:trackConnection("textBoxFocused", UserInputService.TextBoxFocused:Connect(onTextFocusGained))
	self._connectionUtil:trackConnection("windowFocusReleased", UserInputService.WindowFocused:Connect(onFocusReleased))
end

return object