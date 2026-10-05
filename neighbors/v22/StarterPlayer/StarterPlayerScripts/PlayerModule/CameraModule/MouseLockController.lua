local createVector = vector.create
local commonUtils = script.Parent.Parent:WaitForChild("CommonUtils")
local FlagUtil = require(commonUtils:WaitForChild("FlagUtil"))
local value = Enum.ContextActionPriority.Medium.Value
local Players = game:GetService("Players")
local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")
local gameSettings = UserSettings().GameSettings
local CameraUtils = require(script.Parent:WaitForChild("CameraUtils"))
local userFlag = FlagUtil.getUserFlag("UserFixStuckShiftLock")
local MouseLockController = {}
MouseLockController.__index = MouseLockController

function MouseLockController.new()
	local object = setmetatable({}, MouseLockController)
	object.isMouseLocked = false
	object.savedMouseCursor = nil
	object.boundKeys = { Enum.KeyCode.LeftShift, Enum.KeyCode.RightShift }
	object.mouseLockToggledEvent = Instance.new("BindableEvent")
	local v = script:FindFirstChild("BoundKeys")

	if not (v and v:IsA("StringValue")) then
		if v then
			v:Destroy()
		end

		v = Instance.new("StringValue")
		assert(v, "")
		v.Name = "BoundKeys"
		v.Value = "LeftShift,RightShift"
		v.Parent = script
	end

	if v then
		v.Changed:Connect(function(p)
			object:OnBoundKeysObjectChanged(p)
		end)
		object:OnBoundKeysObjectChanged(v.Value)
	end

	gameSettings.Changed:Connect(function(p)
		if p == "ControlMode" or p == "ComputerMovementMode" then
			object:UpdateMouseLockAvailability()
		end
	end)
	Players.LocalPlayer:GetPropertyChangedSignal("DevEnableMouseLock"):Connect(function()
		object:UpdateMouseLockAvailability()
	end)
	Players.LocalPlayer:GetPropertyChangedSignal("DevComputerMovementMode"):Connect(function()
		object:UpdateMouseLockAvailability()
	end)
	UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(function()
		object:UpdateMouseLockAvailability()
	end)
	object:UpdateMouseLockAvailability()
	return object
end

function MouseLockController.GetIsMouseLocked(p)
	return p.isMouseLocked
end

function MouseLockController.GetBindableToggleEvent(p)
	return p.mouseLockToggledEvent.Event
end

function MouseLockController.GetMouseLockOffset(_)
	return createVector(1.75, 0, 0)
end

function MouseLockController:UpdateMouseLockAvailability()
	local devEnableMouseLock = Players.LocalPlayer.DevEnableMouseLock
	local v = Players.LocalPlayer.DevComputerMovementMode == Enum.DevComputerMovementMode.Scriptable
	local v2 = gameSettings.ControlMode == Enum.ControlMode.MouseLockSwitch
	local v3 = gameSettings.ComputerMovementMode == Enum.ComputerMovementMode.ClickToMove
	local v4 = UserInputService.PreferredInput == Enum.PreferredInput.KeyboardAndMouse and devEnableMouseLock and v2 and not v3 and not v

	if v4 ~= self.enabled then
		self:EnableMouseLock(v4)
	end
end

function MouseLockController:OnBoundKeysObjectChanged(value2: string)
	self.boundKeys = {}

	for k in string.gmatch(value2, "[^%s,]+") do
		for _, v2 in pairs(Enum.KeyCode:GetEnumItems()) do
			if k ~= v2.Name then
				continue
			end

			self.boundKeys[#self.boundKeys + 1] = v2
			break
		end
	end

	self:UnbindContextActions()
	self:BindContextActions()
end

function MouseLockController:OnMouseLockToggled()
	self.isMouseLocked = not self.isMouseLocked

	if self.isMouseLocked then
		local cursorImage = script:FindFirstChild("CursorImage")

		if cursorImage and cursorImage:IsA("StringValue") and cursorImage.Value then
			CameraUtils.setMouseIconOverride(cursorImage.Value)
		else
			if cursorImage then
				cursorImage:Destroy()
			end

			local stringValue = Instance.new("StringValue")
			assert(stringValue, "")
			stringValue.Name = "CursorImage"
			stringValue.Value = "rbxasset://textures/MouseLockedCursor.png"
			stringValue.Parent = script
			CameraUtils.setMouseIconOverride("rbxasset://textures/MouseLockedCursor.png")
		end
	else
		CameraUtils.restoreMouseIcon()
	end

	self.mouseLockToggledEvent:Fire()
end

function MouseLockController:DoMouseLockSwitch(_, p, _)
	if p ~= Enum.UserInputState.Begin then
		return Enum.ContextActionResult.Pass
	end

	self:OnMouseLockToggled()
	return Enum.ContextActionResult.Sink
end

function MouseLockController:BindContextActions()
	ContextActionService:BindActionAtPriority("MouseLockSwitchAction", function(p, p2, p3)
		return self:DoMouseLockSwitch(p, p2, p3)
	end, false, value, unpack(self.boundKeys))
end

function MouseLockController:UnbindContextActions()
	ContextActionService:UnbindAction("MouseLockSwitchAction")
end

function MouseLockController.IsMouseLocked(p)
	return p.enabled and p.isMouseLocked
end

function MouseLockController:EnableMouseLock(enabled: boolean)
	if enabled ~= self.enabled then
		self.enabled = enabled

		if self.enabled then
			self:BindContextActions()
			return
		end

		CameraUtils.restoreMouseIcon()
		self:UnbindContextActions()

		if userFlag then
			if self.isMouseLocked then
				self.isMouseLocked = false
				self.mouseLockToggledEvent:Fire()
			end
		else
			if self.isMouseLocked then
				self.mouseLockToggledEvent:Fire()
			end

			self.isMouseLocked = false
		end
	end
end

return MouseLockController