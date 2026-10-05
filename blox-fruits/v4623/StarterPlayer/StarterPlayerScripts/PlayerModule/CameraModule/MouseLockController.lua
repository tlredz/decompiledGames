local createVector = vector.create
local value = Enum.ContextActionPriority.Default.Value
require(script.Parent:WaitForChild("CameraUtils"))
local Players = game:GetService("Players")
game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local gameSettings = UserSettings().GameSettings
local mouse = Players.LocalPlayer:GetMouse()
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
	object:UpdateMouseLockAvailability()
	return object
end

function MouseLockController.GetIsMouseLocked(p)
	return p.isMouseLocked
end

function MouseLockController.GetIcon(_)
	return "http://www.roblox.com/asset/?id=9812826835"
end

function MouseLockController.GetBindableToggleEvent(p)
	return p.mouseLockToggledEvent.Event
end

function MouseLockController.GetMouseLockOffset(_)
	local cameraOffset = script:FindFirstChild("CameraOffset")

	if cameraOffset and cameraOffset:IsA("Vector3Value") then
		return cameraOffset.Value
	end

	if cameraOffset then
		cameraOffset:Destroy()
	end

	local vector3Value = Instance.new("Vector3Value")
	vector3Value.Name = "CameraOffset"
	vector3Value.Value = createVector(1.25, 2.5, 0)
	vector3Value.Parent = script

	if vector3Value and vector3Value.Value then
		return vector3Value.Value
	end

	return createVector(1.25, 2.5, 0)
end

function MouseLockController:UpdateMouseLockAvailability()
	local devEnableMouseLock = Players.LocalPlayer.DevEnableMouseLock
	local v = Players.LocalPlayer.DevComputerMovementMode == Enum.DevComputerMovementMode.Scriptable
	local v2 = gameSettings.ControlMode == Enum.ControlMode.MouseLockSwitch
	local v3

	if gameSettings.ComputerMovementMode == Enum.ComputerMovementMode.ClickToMove then
		local Global = require(game.ReplicatedStorage.Global)
		v3 = not Global.BlockingClickToMove
	else
		v3 = false
	end

	local v4 = devEnableMouseLock and v2 and not v3 and not v

	if v4 ~= self.enabled then
		self:EnableMouseLock(v4)
	end
end

function MouseLockController:OnBoundKeysObjectChanged(value2)
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
			mouse.Icon = cursorImage.Value
		else
			if cursorImage then
				cursorImage:Destroy()
			end

			local stringValue = Instance.new("StringValue")
			stringValue.Name = "CursorImage"
			stringValue.Value = "http://www.roblox.com/asset/?id=9812826835"
			stringValue.Parent = script
			mouse.Icon = "http://www.roblox.com/asset/?id=9812826835"
		end
	else
		mouse.Icon = ""

		if self.savedMouseCursor then
			mouse.Icon = self.savedMouseCursor
			self.savedMouseCursor = nil
		end
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

function MouseLockController:EnableMouseLock(enabled)
	if enabled ~= self.enabled then
		self.enabled = enabled

		if self.enabled then
			self:BindContextActions()
			return
		end

		if mouse.Icon ~= "" then
			mouse.Icon = ""
		end

		self:UnbindContextActions()

		if self.isMouseLocked then
			self.mouseLockToggledEvent:Fire()
		end

		self.isMouseLocked = false
	end
end

return MouseLockController