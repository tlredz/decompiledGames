local createVector = vector.create
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local commonUtils = script.Parent.Parent:WaitForChild("CommonUtils")
local FlagUtil = require(commonUtils:WaitForChild("FlagUtil"))
local userFlag = FlagUtil.getUserFlag("UserPlayerScriptsSupportTVRemoteKeycodes")
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
	self.thumbstickVector = createVector(0, 0, 0)
	self.activeGamepad = none
	self.gamepadConnectedConn = nil
	self.gamepadDisconnectedConn = nil
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
	self.thumbstickVector = createVector(0, 0, 0)
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

function object:UpdateMovement()
	self.moveVector = self.thumbstickVector + Vector3.new(0, 0, self.forwardValue + self.backwardValue)
end

function object:BindContextActions()
	if self.activeGamepad == none then
		return false
	end

	local function fn(_, p, _)
		self.isJumping = p == Enum.UserInputState.Begin
		return Enum.ContextActionResult.Sink
	end

	local function fn2(_, p, data)
		if p == Enum.UserInputState.Cancel then
			if userFlag then
				self.thumbstickVector = createVector(0, 0, 0)
				self:UpdateMovement()
			else
				self.moveVector = createVector(0, 0, 0)
			end
		else
			if self.activeGamepad ~= data.UserInputType then
				return Enum.ContextActionResult.Pass
			end

			if data.KeyCode ~= Enum.KeyCode.Thumbstick1 then
				return
			end

			if userFlag then
				if data.Position.magnitude > 0.2 then
					self.thumbstickVector = Vector3.new(data.Position.X, 0, -data.Position.Y)
				else
					self.thumbstickVector = createVector(0, 0, 0)
				end

				self:UpdateMovement()
			elseif data.Position.magnitude > 0.2 then
				self.moveVector = Vector3.new(data.Position.X, 0, -data.Position.Y)
			else
				self.moveVector = createVector(0, 0, 0)
			end
		end

		return Enum.ContextActionResult.Sink
	end

	local function fn3(_, p, p2)
		if p == Enum.UserInputState.Cancel then
			self.forwardValue = 0
			self.backwardValue = 0
			self:UpdateMovement()
			return Enum.ContextActionResult.Sink
		else
			local backwardValue = not (p2.Position.magnitude > 0.2) and 0 or p2.Position.Z

			if p2.KeyCode == Enum.KeyCode.ButtonUp then
				self.forwardValue = -backwardValue
			elseif p2.KeyCode == Enum.KeyCode.ButtonDown then
				self.backwardValue = backwardValue
			end

			self:UpdateMovement()
			return Enum.ContextActionResult.Sink
		end
	end

	ContextActionService:BindActivate(self.activeGamepad, Enum.KeyCode.ButtonR2)

	if userFlag then
		ContextActionService:BindActionAtPriority(
			"jumpAction",
			fn,
			false,
			self.CONTROL_ACTION_PRIORITY,
			Enum.KeyCode.ButtonA,
			Enum.KeyCode.ButtonCenter
		)
		ContextActionService:BindActionAtPriority(
			"moveDirectionalButton",
			fn3,
			false,
			self.CONTROL_ACTION_PRIORITY,
			Enum.KeyCode.ButtonUp,
			Enum.KeyCode.ButtonDown
		)
	else
		ContextActionService:BindActionAtPriority(
			"jumpAction",
			fn,
			false,
			self.CONTROL_ACTION_PRIORITY,
			Enum.KeyCode.ButtonA
		)
	end

	ContextActionService:BindActionAtPriority(
		"moveThumbstick",
		fn2,
		false,
		self.CONTROL_ACTION_PRIORITY,
		Enum.KeyCode.Thumbstick1
	)
	return true
end

function object:UnbindContextActions()
	if self.activeGamepad ~= none then
		ContextActionService:UnbindActivate(self.activeGamepad, Enum.KeyCode.ButtonR2)
	end

	if userFlag then
		ContextActionService:UnbindAction("moveDirectionalButton")
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