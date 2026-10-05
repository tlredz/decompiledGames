local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local GamepadService = game:GetService("GamepadService")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local Utility = require(ReplicatedStorage.Modules.Utility)
local Signal = require(ReplicatedStorage.Modules.Signal)
local v = {
	Desktop = "MouseKeyboard",
	Mobile = "Touch",
	Console = "Gamepad",
	VR = "VR"
}
local v2 = {
	[Enum.UserInputType.MouseButton1] = "MouseKeyboard",
	[Enum.UserInputType.MouseButton2] = "MouseKeyboard",
	[Enum.UserInputType.MouseButton3] = "MouseKeyboard",
	[Enum.UserInputType.Keyboard] = "MouseKeyboard",
	[Enum.UserInputType.Touch] = "Touch",
	[Enum.UserInputType.Gamepad1] = "Gamepad",
	[Enum.UserInputType.Gamepad2] = "Gamepad",
	[Enum.UserInputType.Gamepad3] = "Gamepad",
	[Enum.UserInputType.Gamepad4] = "Gamepad",
	[Enum.UserInputType.Gamepad5] = "Gamepad",
	[Enum.UserInputType.Gamepad6] = "Gamepad",
	[Enum.UserInputType.Gamepad7] = "Gamepad",
	[Enum.UserInputType.Gamepad8] = "Gamepad"
}
local v3 = {
	[Enum.KeyCode.W] = "MouseKeyboard",
	[Enum.KeyCode.A] = "MouseKeyboard",
	[Enum.KeyCode.S] = "MouseKeyboard",
	[Enum.KeyCode.D] = "MouseKeyboard"
}
local v4 = {
	["Mouse & Keyboard"] = "MouseKeyboard",
	["Touch Buttons"] = "Touch",
	Controller = "Gamepad"
}
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self.ControlsChanged = Signal.new()
	self.CurrentControls = v[CONSTANTS.DEVICE]
	self._toggled_inputs = {}
	self._is_verification_disabled = false
	self._set_controls_hash = 0
	self._control_scheme_setting = nil
	self:_Init()
	return self
end

function class:IsInputDown(p)
	return p.EnumType == Enum.KeyCode and UserInputService:IsKeyDown(p) or p.EnumType == Enum.UserInputType and UserInputService:IsMouseButtonPressed(p) or p.EnumType == Enum.KeyCode and (self.CurrentControls == "Gamepad" or self.CurrentControls == "VR") and UserInputService:IsGamepadButtonDown(
		UserInputService:GetLastInputType(),
		p
	) or self:IsToggled(p)
end

function class:IsToggled(p2)
	return self._toggled_inputs[p2]
end

function class:ToggleInput(p2, p3)
	self._toggled_inputs[p2] = p3 or nil
end

function class:SetControls(currentControls)
	if self._control_scheme_setting and self._control_scheme_setting ~= "Automatic" then
		currentControls = v4[self._control_scheme_setting] or currentControls
	end

	if not currentControls or currentControls == self.CurrentControls or (currentControls == "VR" or self.CurrentControls == "VR") then
		return
	end

	self._set_controls_hash += 1
	local _set_controls_hash = self._set_controls_hash
	task.defer(function()
		if _set_controls_hash ~= self._set_controls_hash then
			return
		end

		self.CurrentControls = currentControls
		self.ControlsChanged:Fire()
	end)
end

function class:DisableVerification(is_verification_disabled)
	self._is_verification_disabled = is_verification_disabled
end

function class:_ProcessInput(data, p)
	if self._is_verification_disabled or p or Utility:IsTextBoxFocused() then
		return
	end

	if GamepadService.GamepadCursorEnabled or GuiService.SelectedObject or (data.KeyCode == Enum.KeyCode.Thumbstick1 or data.KeyCode == Enum.KeyCode.Thumbstick2) and (data.Position * createVector(
		1,
		1,
		0
	)).Magnitude < 0.75 then
		return
	end

	self:SetControls(v2[data.UserInputType] or v3[data.KeyCode])
end

function class:_SetupControlSchemeSetting()
	local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers.PlayerDataController)

	local function verify()
		self._control_scheme_setting = PlayerDataController:GetSetting("Control Scheme")
		self:SetControls(self.CurrentControls)
	end

	PlayerDataController:GetSettingChangedSignal("Control Scheme"):Connect(verify)
	task.defer(verify)
end

function class:_Init()
	UserInputService.InputBegan:Connect(function(...)
		self:_ProcessInput(...)
	end)
	UserInputService.InputChanged:Connect(function(...)
		self:_ProcessInput(...)
	end)
	UserInputService.InputEnded:Connect(function(...)
		self:_ProcessInput(...)
	end)
	task.defer(self._SetupControlSchemeSetting, self)
end

return class._new()