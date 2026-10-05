local createVector = vector.create
local value = Enum.ContextActionPriority.Default.Value
local Players = game:GetService("Players")
local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")
local gameSettings = UserSettings().GameSettings
local CameraUtils = require(script.Parent:WaitForChild("CameraUtils"))
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
	Players.LocalPlayer:GetAttributeChangedSignal("S_ShiftlockSkin"):Connect(function()
		object:_updateShiftlockOverlay()
	end)
	Players.LocalPlayer:GetAttributeChangedSignal("S_ShiftlockScale"):Connect(function()
		object:_updateShiftlockOverlay()
	end)
	object:UpdateMouseLockAvailability()
	return object
end

function MouseLockController:_updateShiftlockOverlay()
	local localPlayer = Players.LocalPlayer

	if not localPlayer then
		return
	end

	local s_ShiftlockSkin = localPlayer:GetAttribute("S_ShiftlockSkin")
	local image = typeof(s_ShiftlockSkin) == "string" and s_ShiftlockSkin or ""
	local v2 = image:sub(1, 1) == "H"

	if v2 then
		image = image:sub(2) or image
	end

	local s_ShiftlockScale = localPlayer:GetAttribute("S_ShiftlockScale")
	local v3 = typeof(s_ShiftlockScale) ~= "number" and 1 or s_ShiftlockScale
	local v4 = image ~= ""
	local v5

	if self.isMouseLocked == true then
		v5 = v4 and not v2
	else
		v5 = false
	end

	local v6

	if self.isMouseLocked == true then
		v6 = v2 or v4
	else
		v6 = false
	end

	if self.isMouseLocked and not (v2 or v4) then
		local cursorImage = script:FindFirstChild("CursorImage")
		local value2 = cursorImage and cursorImage:IsA("StringValue") and cursorImage.Value or "rbxasset://textures/MouseLockedCursor.png"
		CameraUtils.setMouseIconOverride(value2)
	end

	if v5 then
		if not (self._shiftlockGui and self._shiftlockGui.Parent) then
			local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui") or localPlayer:WaitForChild("PlayerGui", 5)

			if not playerGui then
				return
			end

			local screenGui = Instance.new("ScreenGui")
			screenGui.Name = "ShiftlockCursorOverlay"
			screenGui.ResetOnSpawn = false
			screenGui.IgnoreGuiInset = true
			screenGui.DisplayOrder = 2147483646
			screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
			screenGui.Parent = playerGui
			local imageLabel = Instance.new("ImageLabel")
			imageLabel.Name = "CursorImage"
			imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
			imageLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
			imageLabel.BackgroundTransparency = 1
			imageLabel.BorderSizePixel = 0
			imageLabel.ScaleType = Enum.ScaleType.Fit
			imageLabel.SizeConstraint = Enum.SizeConstraint.RelativeYY
			imageLabel.ZIndex = 999
			imageLabel.Parent = screenGui
			self._shiftlockGui = screenGui
			self._shiftlockImg = imageLabel
		end

		if not (image:match("^rbx") or image:match("^http")) then
			image = "rbxassetid://" .. image
		end

		self._shiftlockImg.Image = image
		local v7 = math.max(math.abs(v3), 0.05) * 0.04
		self._shiftlockImg.Size = UDim2.new(v7, 0, v7, 0)
		self._shiftlockImg.Visible = true
		self._shiftlockGui.Enabled = true
	elseif self._shiftlockGui then
		self._shiftlockGui.Enabled = false
	end

	UserInputService.MouseIconEnabled = not v6
end

function MouseLockController.GetIsMouseLocked(p)
	return p.isMouseLocked
end

function MouseLockController.GetBindableToggleEvent(p)
	return p.mouseLockToggledEvent.Event
end

function MouseLockController.GetMouseLockOffset(_)
	local localPlayer = Players.LocalPlayer
	local s_ShiftlockX = localPlayer and localPlayer:GetAttribute("S_ShiftlockX")
	local s_ShiftlockY = localPlayer and localPlayer:GetAttribute("S_ShiftlockY")
	local s_ShiftlockZ = localPlayer and localPlayer:GetAttribute("S_ShiftlockZ")

	if typeof(s_ShiftlockX) == "number" or typeof(s_ShiftlockY) == "number" or typeof(s_ShiftlockZ) == "number" then
		return (Vector3.new(
			typeof(s_ShiftlockX) == "number" and s_ShiftlockX or 1.75,
			typeof(s_ShiftlockY) == "number" and s_ShiftlockY or 0,
			typeof(s_ShiftlockZ) == "number" and s_ShiftlockZ or 0
		))
	end

	local cameraOffset = script:FindFirstChild("CameraOffset")

	if cameraOffset and cameraOffset:IsA("Vector3Value") then
		return cameraOffset.Value
	end

	if cameraOffset then
		cameraOffset:Destroy()
	end

	local vector3Value = Instance.new("Vector3Value")
	assert(vector3Value, "")
	vector3Value.Name = "CameraOffset"
	vector3Value.Value = createVector(1.75, 0, 0)
	vector3Value.Parent = script

	if vector3Value and vector3Value.Value then
		return vector3Value.Value
	end

	return createVector(1.75, 0, 0)
end

function MouseLockController:UpdateMouseLockAvailability()
	local devEnableMouseLock = Players.LocalPlayer.DevEnableMouseLock
	local v = Players.LocalPlayer.DevComputerMovementMode == Enum.DevComputerMovementMode.Scriptable
	local v2 = gameSettings.ControlMode == Enum.ControlMode.MouseLockSwitch
	local v3 = gameSettings.ComputerMovementMode == Enum.ComputerMovementMode.ClickToMove
	local v4 = devEnableMouseLock and v2 and not v3 and not v

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
		local localPlayer = Players.LocalPlayer
		local s_ShiftlockSkin = localPlayer and localPlayer:GetAttribute("S_ShiftlockSkin")
		local v = typeof(s_ShiftlockSkin) == "string" and s_ShiftlockSkin or ""
		local v2 = v:sub(1, 1) == "H"

		if v2 then
			v = v:sub(2) or v
		end

		if not v2 then
			if v == "" then
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
				if not (v:match("^rbx") or v:match("^http")) then
					v = "rbxassetid://" .. v
				end

				CameraUtils.setMouseIconOverride(v)
			end
		end
	else
		CameraUtils.restoreMouseIcon()
	end

	self:_updateShiftlockOverlay()
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

		if self.isMouseLocked then
			self.mouseLockToggledEvent:Fire()
		end

		self.isMouseLocked = false
		self:_updateShiftlockOverlay()
	end
end

return MouseLockController