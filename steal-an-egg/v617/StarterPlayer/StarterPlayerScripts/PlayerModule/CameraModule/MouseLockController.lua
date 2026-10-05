local createVector = vector.create
local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local CameraUtils = require(script.Parent.CameraUtils)
local FlagUtil = require(script.Parent.Parent.CommonUtils.FlagUtil)
require(ReplicatedStorage.Shared.Globals.Constants)
local Log = require(ReplicatedStorage.Packages.Log)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Signal = require(ReplicatedStorage.Packages.Signal)
local MouseLockController = {}
MouseLockController.__index = MouseLockController
MouseLockController.__class = "MouseLockController"
local value = Enum.ContextActionPriority.Medium.Value
local userFlag = FlagUtil.getUserFlag("UserPreferredInputPlayerScripts2")
local gameSettings = UserSettings().GameSettings
local localPlayer = Players.LocalPlayer
local v = Log.new()
local v2 = false

function MouseLockController.new()
	local self = setmetatable({}, MouseLockController)
	self.boundKeys = { Enum.KeyCode.LeftShift, Enum.KeyCode.RightShift }
	self.enabled = false
	self.isMouseLocked = false
	self.mouseLockToggledEvent = Signal.new()
	self:_init()
	return self
end

function MouseLockController:_updateMouseLockAvailability()
	local devEnableMouseLock = localPlayer.DevEnableMouseLock
	local v3 = localPlayer.DevComputerMovementMode == Enum.DevComputerMovementMode.Scriptable
	local v4 = gameSettings.ControlMode == Enum.ControlMode.MouseLockSwitch
	local v5 = gameSettings.ComputerMovementMode == Enum.ComputerMovementMode.ClickToMove
	local v6 = UserInputService.PreferredInput == Enum.PreferredInput.KeyboardAndMouse
	local v7 = not v2

	if not userFlag or v6 then
		v6 = devEnableMouseLock and v4 and not v5 and not v3 and v7
	end

	if v6 ~= self.enabled then
		if not v7 then
			v:AtDebug():Log("PlayerModule mouse lock suppressed by a gameplay lock")
		end

		self:EnableMouseLock(v6)
	end
end

function MouseLockController:_onBoundKeysObjectChanged(value2: string)
	local boundKeys = {}

	for k in string.gmatch(value2, "[^%s,]+") do
		for _, v5 in Enum.KeyCode:GetEnumItems() do
			if v5.Name ~= k then
				continue
			end

			table.insert(boundKeys, v5)
			break
		end
	end

	self.boundKeys = boundKeys
	self:_unbindContextActions()

	if self.enabled then
		self:_bindContextActions()
	end
end

function MouseLockController:_onMouseLockToggled()
	self.isMouseLocked = not self.isMouseLocked

	if self.isMouseLocked then
		local cursorImage = script:FindFirstChild("CursorImage")
		local v3 = (cursorImage == nil or not cursorImage:IsA("StringValue")) and "rbxasset://textures/MouseLockedCursor.png" or cursorImage.Value
		CameraUtils.setMouseIconOverride(v3)
	else
		CameraUtils.restoreMouseIcon()
	end

	self.mouseLockToggledEvent:Fire()
end

function MouseLockController:_doMouseLockSwitch(_: string, p, _)
	if p ~= Enum.UserInputState.Begin then
		return Enum.ContextActionResult.Pass
	end

	self:_onMouseLockToggled()
	return Enum.ContextActionResult.Sink
end

function MouseLockController:_bindContextActions()
	ContextActionService:BindActionAtPriority("MouseLockSwitchAction", function(p: string, p2, p3)
		return self:_doMouseLockSwitch(p, p2, p3)
	end, false, value, table.unpack(self.boundKeys))
end

function MouseLockController:_unbindContextActions()
	ContextActionService:UnbindAction("MouseLockSwitchAction")
end

function MouseLockController.GetIsMouseLocked(p)
	return p.isMouseLocked
end

function MouseLockController.GetBindableToggleEvent(p)
	return p.mouseLockToggledEvent
end

function MouseLockController.GetMouseLockOffset(_)
	return createVector(1.75, 0, 0)
end

function MouseLockController.IsMouseLocked(p)
	return p.enabled and p.isMouseLocked
end

function MouseLockController:EnableMouseLock(enabled: boolean)
	if enabled == self.enabled then
		return
	end

	self.enabled = enabled

	if enabled then
		self:_bindContextActions()
		return
	end

	CameraUtils.restoreMouseIcon()
	self:_unbindContextActions()

	if self.isMouseLocked then
		self.isMouseLocked = false
		self.mouseLockToggledEvent:Fire()
	end
end

function MouseLockController:_init()
	local boundKeys = script:FindFirstChild("BoundKeys")

	if boundKeys ~= nil and boundKeys:IsA("StringValue") then
		boundKeys.Changed:Connect(function(p: string)
			self:_onBoundKeysObjectChanged(p)
		end)
		self:_onBoundKeysObjectChanged(boundKeys.Value)
	end

	gameSettings.Changed:Connect(function(p: string)
		if p == "ControlMode" or p == "ComputerMovementMode" then
			self:_updateMouseLockAvailability()
		end
	end)
	localPlayer:GetPropertyChangedSignal("DevEnableMouseLock"):Connect(function()
		self:_updateMouseLockAvailability()
	end)
	localPlayer:GetPropertyChangedSignal("DevComputerMovementMode"):Connect(function()
		self:_updateMouseLockAvailability()
	end)

	if userFlag then
		UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(function()
			self:_updateMouseLockAvailability()
		end)
	end

	Remotes.Treadmill.AssignedBeltShifted.OnClientEvent:Connect(function(p: string?)
		v2 = p ~= nil
		self:_updateMouseLockAvailability()
	end)
	self:_updateMouseLockAvailability()
end

return MouseLockController