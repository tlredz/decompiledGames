local createVector = vector.create
local CommonUtils = require(script.Parent.Parent:WaitForChild("CommonUtils"))
local flagUtil = CommonUtils.get("FlagUtil")
local mouseLockSwitchAction = script.Parent.Parent:WaitForChild("InputContexts"):WaitForChild("CameraContext"):WaitForChild("MouseLockSwitchAction")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local gameSettings = UserSettings().GameSettings
local CameraUtils = require(script.Parent:WaitForChild("CameraUtils"))
local userFlag = flagUtil.getUserFlag("UserFixStuckShiftLock")
local MouseLockController = {}
MouseLockController.__index = MouseLockController

function MouseLockController.new()
	local object = setmetatable({}, MouseLockController)
	object.isMouseLocked = false
	object.savedMouseCursor = nil
	object.enabled = false
	object.mouseLockToggledEvent = Instance.new("BindableEvent")
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
	mouseLockSwitchAction.Pressed:Connect(function()
		object:OnMouseLockToggled()
	end)
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

function MouseLockController.IsMouseLocked(p)
	return p.enabled and p.isMouseLocked
end

function MouseLockController:EnableMouseLock(enabled: boolean)
	if enabled == self.enabled then
		return
	end

	self.enabled = enabled

	if self.enabled then
		mouseLockSwitchAction.Enabled = true
		return
	end

	CameraUtils.restoreMouseIcon()
	mouseLockSwitchAction.Enabled = false

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

return MouseLockController