local Trove = require(script.Parent.Parent.Trove)
local Signal = require(script.Parent.Parent.Signal)
local UserInputService = game:GetService("UserInputService")
local HapticService = game:GetService("HapticService")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")

-- equivalent calls inferred from this helper; original call sites unknown
local function ApplyDeadzone(X: number, p: number)
	if math.abs(X) < p then
		return 0
	end

	return (math.abs(X) - p) / (1 - p) * math.sign(X)
end

local function GetActiveGamepad()
	local v = nil
	local navigationGamepads = UserInputService:GetNavigationGamepads()

	if #navigationGamepads > 1 then
		for _, navigationGamepad in ipairs(navigationGamepads) do
			if v == nil or navigationGamepad.Value < v.Value then
				v = navigationGamepad
			end
		end
	else
		local connectedGamepads = UserInputService:GetConnectedGamepads()

		for _, connectedGamepad in ipairs(connectedGamepads) do
			if v == nil or connectedGamepad.Value < v.Value then
				v = connectedGamepad
			end
		end
	end

	if v and not UserInputService:GetGamepadConnected(v) then
		return nil
	end

	return v
end

-- equivalent calls inferred from this helper; original call sites unknown
local function HeartbeatDelay(p: number, fn)
	local v = time()
	local heartbeatConnection = nil
	heartbeatConnection = RunService.Heartbeat:Connect(function()
		if p <= time() - v then
			heartbeatConnection:Disconnect()
			fn()
		end
	end)
	return heartbeatConnection
end

local Gamepad = {}
Gamepad.__index = Gamepad

function Gamepad.new(p)
	local self = setmetatable({}, Gamepad)
	self._trove = Trove.new()
	self._gamepadTrove = self._trove:Construct(Trove)
	self.ButtonDown = self._trove:Construct(Signal)
	self.ButtonUp = self._trove:Construct(Signal)
	self.Connected = self._trove:Construct(Signal)
	self.Disconnected = self._trove:Construct(Signal)
	self.GamepadChanged = self._trove:Construct(Signal)
	self.DefaultDeadzone = 0.05
	self.SupportsVibration = false
	self.State = {}
	self:_setupGamepad(p)
	self:_setupMotors()
	return self
end

function Gamepad:_setupActiveGamepad(gamepad)
	local _gamepad = self._gamepad

	if gamepad == _gamepad then
		return
	end

	self._gamepadTrove:Clean()
	table.clear(self.State)
	local supportsVibration

	if gamepad then
		supportsVibration = HapticService:IsVibrationSupported(gamepad)
	else
		supportsVibration = false
	end

	self.SupportsVibration = supportsVibration
	self._gamepad = gamepad

	if gamepad then
		for _, v2 in ipairs(UserInputService:GetGamepadState(gamepad)) do
			self.State[v2.KeyCode] = v2
		end

		self._gamepadTrove:Add(self, "StopMotors")
		self._gamepadTrove:Connect(UserInputService.InputBegan, function(p, p2)
			if p.UserInputType == gamepad then
				self.ButtonDown:Fire(p.KeyCode, p2)
			end
		end)
		self._gamepadTrove:Connect(UserInputService.InputEnded, function(p, p2)
			if p.UserInputType == gamepad then
				self.ButtonUp:Fire(p.KeyCode, p2)
			end
		end)

		if _gamepad == nil then
			self.Connected:Fire()
		end

		self.GamepadChanged:Fire(gamepad)
	else
		self.Disconnected:Fire()
		self.GamepadChanged:Fire(nil)
	end
end

function Gamepad:_setupGamepad(p)
	if p then
		self._trove:Connect(UserInputService.GamepadConnected, function(p2)
			if p2 == p then
				self:_setupActiveGamepad(p)
			end
		end)
		self._trove:Connect(UserInputService.GamepadDisconnected, function(p2)
			if p2 == p then
				self:_setupActiveGamepad(nil)
			end
		end)

		if UserInputService:GetGamepadConnected(p) then
			self:_setupActiveGamepad(p)
		end
	else
		local function CheckToSetupActive()
			local activeGamepad = GetActiveGamepad()

			if activeGamepad ~= self._gamepad then
				self:_setupActiveGamepad(activeGamepad)
			end
		end

		self._trove:Connect(UserInputService.GamepadConnected, CheckToSetupActive)
		self._trove:Connect(UserInputService.GamepadDisconnected, CheckToSetupActive)
		self:_setupActiveGamepad((GetActiveGamepad()))
	end
end

function Gamepad:_setupMotors()
	self._setMotorIds = {}

	for _, v in ipairs(Enum.VibrationMotor:GetEnumItems()) do
		self._setMotorIds[v] = 0
	end
end

function Gamepad.GetThumbstick(p, p2, p3: number?)
	local position = p.State[p2].Position
	local v = p3 or p.DefaultDeadzone
	local applyDeadzone = ApplyDeadzone(position.X, v) -- equivalent call inferred; original call site unknown
	return Vector2.new(applyDeadzone, ApplyDeadzone(position.Y, v))
end

function Gamepad.GetTrigger(p, p2, p3: number?)
	local Z = p.State[p2].Position.Z
	local v = p3 or p.DefaultDeadzone

	if math.abs(Z) < v then
		return 0
	end

	return (math.abs(Z) - v) / (1 - v) * math.sign(Z)
end

function Gamepad:IsButtonDown(p2)
	return UserInputService:IsGamepadButtonDown(self._gamepad, p2)
end

function Gamepad:IsMotorSupported(p2)
	return HapticService:IsMotorSupported(self._gamepad, p2)
end

function Gamepad:SetMotor(p2, p3: number)
	self._setMotorIds[p2] += 1
	local _setMotorId = self._setMotorIds[p2]
	HapticService:SetMotor(self._gamepad, p2, p3)
	return _setMotorId
end

function Gamepad:PulseMotor(p, p2: number, p3: number)
	local v = self:SetMotor(p, p2)

	local function fn()
		if self._setMotorIds[p] ~= v then
			return
		end

		self:StopMotor(p)
	end

	local heartbeatDelay = HeartbeatDelay(p3, fn) -- equivalent call inferred; original call site unknown
	self._gamepadTrove:Add(heartbeatDelay)
end

function Gamepad:StopMotor(p)
	self:SetMotor(p, 0)
end

function Gamepad:StopMotors()
	for _, v in ipairs(Enum.VibrationMotor:GetEnumItems()) do
		if self:IsMotorSupported(v) then
			self:StopMotor(v)
		end
	end
end

function Gamepad:IsConnected()
	if self._gamepad then
		return (UserInputService:GetGamepadConnected(self._gamepad))
	end

	return false
end

function Gamepad:GetUserInputType()
	return self._gamepad
end

function Gamepad.SetAutoSelectGui(_, autoSelectGuiEnabled: boolean)
	GuiService.AutoSelectGuiEnabled = autoSelectGuiEnabled
end

function Gamepad.IsAutoSelectGuiEnabled(_)
	return GuiService.AutoSelectGuiEnabled
end

function Gamepad:Destroy()
	self._trove:Destroy()
end

return Gamepad