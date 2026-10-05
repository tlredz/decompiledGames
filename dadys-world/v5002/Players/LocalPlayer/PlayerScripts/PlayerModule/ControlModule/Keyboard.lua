local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local commonUtils = script.Parent.Parent:WaitForChild("CommonUtils")
local FlagUtil = require(commonUtils:WaitForChild("FlagUtil"))
local userFlag = FlagUtil.getUserFlag("UserUpdateInputConnections")
local vector = Vector3.new()
local BaseCharacterController = require(script.Parent:WaitForChild("BaseCharacterController"))
local object = setmetatable({}, BaseCharacterController)
object.__index = object

function object.new(CONTROL_ACTION_PRIORITY)
	local self = setmetatable(BaseCharacterController.new(), object)
	self.CONTROL_ACTION_PRIORITY = CONTROL_ACTION_PRIORITY

	if not userFlag then
		self.textFocusReleasedConn = nil
		self.textFocusGainedConn = nil
		self.windowFocusReleasedConn = nil
	end

	self.forwardValue = 0
	self.backwardValue = 0
	self.leftValue = 0
	self.rightValue = 0
	self.jumpEnabled = true
	return self
end

function object:Enable(enabled: boolean)
	if not (userFlag or UserInputService.KeyboardEnabled) then
		return false
	end

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
	elseif userFlag then
		self._connections:disconnectAll()
	else
		self:UnbindContextActions()
		self:DisconnectFocusEventListeners()
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

	if userFlag then
		self._connections:connectManual("moveForwardAction", function()
			ContextActionService:UnbindAction("moveForwardAction")
		end)
		self._connections:connectManual("moveBackwardAction", function()
			ContextActionService:UnbindAction("moveBackwardAction")
		end)
		self._connections:connectManual("moveLeftAction", function()
			ContextActionService:UnbindAction("moveLeftAction")
		end)
		self._connections:connectManual("moveRightAction", function()
			ContextActionService:UnbindAction("moveRightAction")
		end)
		self._connections:connectManual("jumpAction", function()
			ContextActionService:UnbindAction("jumpAction")
		end)
	end
end

function object:UnbindContextActions()
	ContextActionService:UnbindAction("moveForwardAction")
	ContextActionService:UnbindAction("moveBackwardAction")
	ContextActionService:UnbindAction("moveLeftAction")
	ContextActionService:UnbindAction("moveRightAction")
	ContextActionService:UnbindAction("jumpAction")
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

	if userFlag then
		self._connections:connect("textBoxFocusReleased", UserInputService.TextBoxFocusReleased, onFocusReleased)
		self._connections:connect("textBoxFocused", UserInputService.TextBoxFocused, onTextFocusGained)
		self._connections:connect("windowFocusReleased", UserInputService.WindowFocused, onFocusReleased)
	else
		self.textFocusReleasedConn = UserInputService.TextBoxFocusReleased:Connect(onFocusReleased)
		self.textFocusGainedConn = UserInputService.TextBoxFocused:Connect(onTextFocusGained)
		self.windowFocusReleasedConn = UserInputService.WindowFocused:Connect(onFocusReleased)
	end
end

function object:DisconnectFocusEventListeners()
	if self.textFocusReleasedConn then
		self.textFocusReleasedConn:Disconnect()
		self.textFocusReleasedConn = nil
	end

	if self.textFocusGainedConn then
		self.textFocusGainedConn:Disconnect()
		self.textFocusGainedConn = nil
	end

	if self.windowFocusReleasedConn then
		self.windowFocusReleasedConn:Disconnect()
		self.windowFocusReleasedConn = nil
	end
end

return object