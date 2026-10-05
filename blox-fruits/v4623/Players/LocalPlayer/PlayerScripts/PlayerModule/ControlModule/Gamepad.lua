local createVector = vector.create
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local none = Enum.UserInputType.None
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
	self.activeGamepad = none
	self.gamepadConnectedConn = nil
	self.gamepadDisconnectedConn = nil
	return self
end

function object:Enable(enabled)
	if not UserInputService.GamepadEnabled then
		return false
	end

	if enabled == self.enabled then
		return true
	end

	self.forwardValue = 0
	self.backwardValue = 0
	self.leftValue = 0
	self.rightValue = 0
	self.moveVector = createVector(0, 0, 0)
	self.isJumping = false

	if enabled then
		self.activeGamepad = self:GetHighestPriorityGamepad()

		if self.activeGamepad == none then
			return false
		end

		self:BindContextActions()
		self:ConnectGamepadConnectionListeners()
	else
		self:UnbindContextActions()
		self:DisconnectGamepadConnectionListeners()
		self.activeGamepad = none
	end

	self.enabled = enabled
	return true
end

function object:GetHighestPriorityGamepad()
	local connectedGamepads = UserInputService:GetConnectedGamepads()
	local v = none

	for _, connectedGamepad in pairs(connectedGamepads) do
		if connectedGamepad.Value < v.Value then
			v = connectedGamepad
		end
	end

	return v
end

function object:BindContextActions()
	if self.activeGamepad == none then
		return false
	end

	ContextActionService:BindActivate(self.activeGamepad, Enum.KeyCode.ButtonR2)
	ContextActionService:BindActionAtPriority("jumpAction", function(_, p, _)
		self.isJumping = p == Enum.UserInputState.Begin
		return Enum.ContextActionResult.Sink
	end, false, self.CONTROL_ACTION_PRIORITY, Enum.KeyCode.ButtonA)
	ContextActionService:BindActionAtPriority("moveThumbstick", function(_, p, data)
		if p == Enum.UserInputState.Cancel then
			self.moveVector = createVector(0, 0, 0)
			return Enum.ContextActionResult.Sink
		end

		if self.activeGamepad ~= data.UserInputType then
			return Enum.ContextActionResult.Pass
		end

		if data.KeyCode ~= Enum.KeyCode.Thumbstick1 then
			return
		end

		if data.Position.magnitude > 0.2 then
			self.moveVector = Vector3.new(data.Position.X, 0, -data.Position.Y)
		else
			self.moveVector = createVector(0, 0, 0)
		end

		return Enum.ContextActionResult.Sink
	end, false, self.CONTROL_ACTION_PRIORITY, Enum.KeyCode.Thumbstick1)
	return true
end

function object:UnbindContextActions()
	if self.activeGamepad ~= none then
		ContextActionService:UnbindActivate(self.activeGamepad, Enum.KeyCode.ButtonR2)
	end

	ContextActionService:UnbindAction("moveThumbstick")
	ContextActionService:UnbindAction("jumpAction")
end

function object:OnNewGamepadConnected()
	local highestPriorityGamepad = self:GetHighestPriorityGamepad()

	if highestPriorityGamepad == self.activeGamepad then
		return
	end

	if highestPriorityGamepad == none then
		warn("Gamepad:OnNewGamepadConnected found no connected gamepads")
		self:UnbindContextActions()
	else
		if self.activeGamepad ~= none then
			self:UnbindContextActions()
		end

		self.activeGamepad = highestPriorityGamepad
		self:BindContextActions()
	end
end

function object:OnCurrentGamepadDisconnected()
	if self.activeGamepad ~= none then
		ContextActionService:UnbindActivate(self.activeGamepad, Enum.KeyCode.ButtonR2)
	end

	local highestPriorityGamepad = self:GetHighestPriorityGamepad()

	if self.activeGamepad == none or highestPriorityGamepad ~= self.activeGamepad then
		if highestPriorityGamepad == none then
			self:UnbindContextActions()
			self.activeGamepad = none
		else
			self.activeGamepad = highestPriorityGamepad
			ContextActionService:BindActivate(self.activeGamepad, Enum.KeyCode.ButtonR2)
		end
	else
		warn("Gamepad:OnCurrentGamepadDisconnected found the supposedly disconnected gamepad in connectedGamepads.")
		self:UnbindContextActions()
		self.activeGamepad = none
	end
end

function object:ConnectGamepadConnectionListeners()
	self.gamepadConnectedConn = UserInputService.GamepadConnected:Connect(function(_)
		self:OnNewGamepadConnected()
	end)
	self.gamepadDisconnectedConn = UserInputService.GamepadDisconnected:Connect(function(p)
		if self.activeGamepad == p then
			self:OnCurrentGamepadDisconnected()
		end
	end)
end

function object:DisconnectGamepadConnectionListeners()
	if self.gamepadConnectedConn then
		self.gamepadConnectedConn:Disconnect()
		self.gamepadConnectedConn = nil
	end

	if self.gamepadDisconnectedConn then
		self.gamepadDisconnectedConn:Disconnect()
		self.gamepadDisconnectedConn = nil
	end
end

return object