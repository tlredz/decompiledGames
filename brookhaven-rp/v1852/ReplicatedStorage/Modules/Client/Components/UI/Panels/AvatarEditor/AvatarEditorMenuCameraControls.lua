local createVector = vector.create
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local GameSdkShared = require(ReplicatedStorage.Packages.GameSdkShared)
local ABTest = require(GameSdkShared.Modules.ABTest)
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local Platform = require(ReplicatedStorage.Modules.Client.Util.Platform)
local CameraController = require(ReplicatedStorage.Modules.Client.UI.CameraController)
local BasePartUtil = require(ReplicatedStorage.Modules.Shared.Utils.BasePartUtil)
local v = Component.new({
	Tag = "AvatarEditorMenuCameraControls"
})

function v:_refreshABSettings()
	local v2, v3 = ABTest.GetExperimentVariable("console-controls", "enabled"):timeout(7):await()
	self._isConsoleControlsEnabled = not v2 or v3
	local v4, v5 = ABTest.GetExperimentVariables("avatar-editor-camera-move"):timeout(7):await()
	self._isExperimentEnabled = v4 and v5.enabled == true
end

function v:_getCurrentCharacterData()
	local character = Players.LocalPlayer.Character

	if character == nil then
		return nil, nil
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return nil, nil
	end

	return character, humanoidRootPart
end

function v:_isPointerInsideCameraArea()
	if self._cameraArea == nil or not self._cameraArea.Visible then
		return false
	end

	local mouseLocation = UserInputService:GetMouseLocation()
	local absolutePosition = self._cameraArea.AbsolutePosition
	local absoluteSize = self._cameraArea.AbsoluteSize
	return mouseLocation.X >= absolutePosition.X and mouseLocation.X <= absolutePosition.X + absoluteSize.X and mouseLocation.Y >= absolutePosition.Y and mouseLocation.Y <= absolutePosition.Y + absoluteSize.Y
end

function v:_isPointInsideCameraArea(point: Vector2)
	if self._cameraArea == nil or not self._cameraArea.Visible then
		return false
	end

	local absolutePosition = self._cameraArea.AbsolutePosition
	local absoluteSize = self._cameraArea.AbsoluteSize
	return point.X >= absolutePosition.X and point.X <= absolutePosition.X + absoluteSize.X and point.Y >= absolutePosition.Y and point.Y <= absolutePosition.Y + absoluteSize.Y
end

function v:_isAnyTouchInsideCameraArea(items)
	for _, item in items do
		local vector2 = nil

		if typeof(item) == "Vector2" then
			vector2 = item
		elseif typeof(item) == "InputObject" then
			vector2 = Vector2.new(item.Position.X, item.Position.Y)
		end

		if vector2 ~= nil and self:_isPointInsideCameraArea(vector2) then
			return true
		end
	end

	return false
end

function v:_getDragDeadzonePixels()
	if self._activeDragInputType == Enum.UserInputType.Touch then
		return 8
	end

	return 2
end

function v:_getOrbitPivotPoint()
	local _hrp = self._hrp

	if _hrp == nil then
		return createVector(0, 0, 0)
	end

	return _hrp.Position + createVector(0, 0, 0)
end

function v:_getLookAtTargetPoint(vector2: Vector3, vector3: Vector3)
	return vector3 + CFrame.new(vector2, vector3).RightVector * self._lookLateralOffset
end

function v:_resolveOrbitCameraCollision(vector2: Vector3, vector3: Vector3, vector4: Vector3)
	local _cameraCollisionParams = self._cameraCollisionParams

	if _cameraCollisionParams == nil then
		return vector3
	end

	local v2 = vector3 - vector2

	if v2.Magnitude <= 0 then
		return vector3
	end

	local raycastResult = workspace:Blockcast(
		CFrame.new(vector2, vector4),
		createVector(1.5, 1.5, 1.5),
		v2,
		_cameraCollisionParams
	)

	if raycastResult == nil then
		raycastResult = workspace:Raycast(vector2, v2, _cameraCollisionParams)
	end

	if raycastResult == nil then
		return vector3
	end

	local v3 = math.max(raycastResult.Distance - 0.35, 0.1)
	return vector2 + v2.Unit * v3
end

function v:_getOrbitCameraCFrame()
	local _getOrbitPivotPoint = self:_getOrbitPivotPoint()
	local v2 = _getOrbitPivotPoint + (CFrame.fromOrientation(-self._orbitPitch, self._orbitYaw, 0) * CFrame.new(
		0,
		0,
		self._zoomDistance
	)).Position
	local _resolveOrbitCameraCollision = self:_resolveOrbitCameraCollision(
		_getOrbitPivotPoint,
		v2,
		(self:_getLookAtTargetPoint(v2, _getOrbitPivotPoint))
	)
	local _getLookAtTargetPoint = self:_getLookAtTargetPoint(_resolveOrbitCameraCollision, _getOrbitPivotPoint)
	return CFrame.new(_resolveOrbitCameraCollision, _getLookAtTargetPoint)
end

function v:_getDefaultAvatarEditorCameraCFrame()
	if self._character == nil then
		return workspace.CurrentCamera.CFrame
	end

	local _character = self._character
	local currentCamera = workspace.CurrentCamera
	local vector2 = Vector2.new(0.4, 0.46)
	local boundingBox, size = _character:GetBoundingBox()
	local v3 = math.tan(math.rad(currentCamera.FieldOfView) / 2)
	local position = (boundingBox * CFrame.new(0, size.Y / 2, -size.Z / 2)).Position
	local position2 = (boundingBox * CFrame.new(0, -size.Y / 2, -size.Z / 2)).Position
	local v4 = ((position.Y - position2.Y) / 2 / v3 + size.Z / 2) * 1.25
	local v5 = v4 * math.tan(math.atan(v3 * (currentCamera.ViewportSize.X / currentCamera.ViewportSize.Y)) * 2 / 2) * 2 / currentCamera.ViewportSize.X
	local v6 = v4 * 2 * v3 / currentCamera.ViewportSize.Y
	local cFrame = boundingBox * CFrame.new(0, 0, -v4)
	local position3 = (boundingBox * CFrame.new(
		(vector2.X - 0.5) * currentCamera.ViewportSize.X * v5,
		(vector2.Y - 0.5) * currentCamera.ViewportSize.Y * v6,
		0
	)).Position
	local v8 = BasePartUtil.closestPoint({
		CFrame = boundingBox,
		Size = size
	}, {
		CFrame = cFrame,
		Size = Vector3.new(-currentCamera.NearPlaneZ, -currentCamera.NearPlaneZ, -currentCamera.NearPlaneZ)
	}) - boundingBox.LookVector * (size.Z / 2)
	local v9 = CFrame.new(v8, v8 + boundingBox.LookVector) * CFrame.new(0, 0, -v4)
	return CFrame.new(v9.Position, position3)
end

function v:_updateOrbitCamera()
	workspace.CurrentCamera.CFrame = self:_getOrbitCameraCFrame()
end

function v:_shouldUseConsoleThumbstickRotation()
	return self._isConsoleControlsEnabled and Platform.IsConsole()
end

function v:_isGamepadFocusOnCameraArea()
	local selectedObject = GuiService.SelectedObject

	if selectedObject == nil then
		return true
	end

	if self._cameraArea == nil then
		return false
	end

	return selectedObject == self._cameraArea or selectedObject:IsDescendantOf(self._cameraArea)
end

function v:_initializeDefaultExperimentOrbit()
	if self._character == nil or self._hrp == nil then
		return
	end

	local _getDefaultAvatarEditorCameraCFrame = self:_getDefaultAvatarEditorCameraCFrame()
	local _getOrbitPivotPoint = self:_getOrbitPivotPoint()
	local position = _getDefaultAvatarEditorCameraCFrame.Position
	local v2 = position - _getOrbitPivotPoint
	local v3 = not (v2.Magnitude > 0.001) and createVector(0, 0, 1) or v2.Unit
	self._zoomDistance = math.clamp(v2.Magnitude, 4, 18)
	self._orbitYaw = math.atan2(v3.X, v3.Z)
	self._orbitPitch = math.asin(v3.Y)
	local cframe = CFrame.new(position, _getOrbitPivotPoint)
	self._lookLateralOffset = (position + _getDefaultAvatarEditorCameraCFrame.LookVector * self._zoomDistance - _getOrbitPivotPoint):Dot(cframe.RightVector)
end

function v:_stepDragInput()
	if not self._isDragging then
		return
	end

	local vector2

	if self._activeDragInputObject and self._activeDragInputObject.UserInputType == Enum.UserInputType.Touch then
		vector2 = Vector2.new(self._activeDragInputObject.Position.X, self._activeDragInputObject.Position.Y)
	else
		vector2 = UserInputService:GetMouseLocation()
	end

	if self._lastScreenPos == nil then
		self._lastScreenPos = vector2
		return
	end

	if self._isPinchingCameraArea then
		self._lastScreenPos = vector2
		return
	end

	local v2 = vector2 - self._lastScreenPos

	if self._hasBrokenDragDeadzone then
		self._lastScreenPos = vector2
		local viewportSize = workspace.CurrentCamera.ViewportSize

		if viewportSize.X <= 0 or viewportSize.Y <= 0 then
			return
		end

		local v3 = Vector2.new(v2.X / viewportSize.X, v2.Y / viewportSize.Y) * 1 * 6.283185307179586

		if self._isExperimentEnabled then
			self._orbitYaw -= v3.X
			self._orbitPitch = math.clamp(self._orbitPitch + v3.Y, -1.3089969389957472, 1.3089969389957472)
			self:_updateOrbitCamera()
		elseif self._hrp ~= nil then
			self._hrp.CFrame *= CFrame.Angles(0, v3.X, 0)
		end
	else
		if v2.Magnitude < self:_getDragDeadzonePixels() then
			return
		end

		self._hasBrokenDragDeadzone = true
		self._lastScreenPos = vector2
	end
end

function v:_stepConsoleInput(p: number)
	if not self:_shouldUseConsoleThumbstickRotation() or not self:_isGamepadFocusOnCameraArea() or self._thumbstickInput.X == 0 and self._thumbstickInput.Y == 0 then
		return
	end

	local v2 = -self._thumbstickInput.X
	local v3 = -self._thumbstickInput.Y

	if self._isExperimentEnabled then
		self._orbitYaw += v2 * 4.5 * p
		self._orbitPitch = math.clamp(self._orbitPitch + v3 * 4.5 * 0.5 * p, -1.3089969389957472, 1.3089969389957472)
		self:_updateOrbitCamera()
	elseif self._hrp ~= nil then
		self._hrp.CFrame *= CFrame.Angles(0, v2 * 4.5 * p, 0)
	end
end

function v:_activate()
	if self._isActive then
		return
	end

	local _getCurrentCharacterData, hrp = self:_getCurrentCharacterData()

	if _getCurrentCharacterData == nil or hrp == nil then
		return
	end

	self._character = _getCurrentCharacterData
	self._hrp = hrp
	local humanoid = _getCurrentCharacterData:FindFirstChild("Humanoid")

	if humanoid and humanoid:IsA("Humanoid") then
		self._humanoid = humanoid
	else
		self._humanoid = nil
	end

	self._isActive = true
	self._isDragging = false
	self._hasBrokenDragDeadzone = false
	self._activeDragInputType = nil
	self._activeDragInputObject = nil
	self._lastScreenPos = nil
	self._thumbstickInput = Vector2.zero

	if self._cameraCollisionParams ~= nil then
		self._cameraCollisionParams.FilterDescendantsInstances = { _getCurrentCharacterData }
	end

	if self._isExperimentEnabled then
		self:_initializeDefaultExperimentOrbit()
		local humanoid2 = self._character:FindFirstChild("Humanoid")

		if humanoid2 and humanoid2:IsA("Humanoid") then
			CameraController.SetCustomCamera(self:_getOrbitCameraCFrame(), humanoid2, nil, false)
		else
			self:_updateOrbitCamera()
		end
	end

	self._sessionJanitor:Add(self._pad.InputBegan:Connect(function(activeDragInputObject, gameProcessed: boolean)
		if gameProcessed or activeDragInputObject.UserInputType ~= Enum.UserInputType.MouseButton1 and activeDragInputObject.UserInputType ~= Enum.UserInputType.MouseButton2 and activeDragInputObject.UserInputType ~= Enum.UserInputType.Touch then
			return
		end

		local vector2 = Vector2.new(activeDragInputObject.Position.X, activeDragInputObject.Position.Y)

		if not self:_isPointInsideCameraArea(vector2) then
			return
		end

		if self._isDragging then
			self._isDragging = false
			self._hasBrokenDragDeadzone = false
			self._activeDragInputObject = nil
		else
			if self._isPinchingCameraArea then
				return
			end

			self._isDragging = true
			self._hasBrokenDragDeadzone = false
			self._activeDragInputType = activeDragInputObject.UserInputType
			self._activeDragInputObject = activeDragInputObject

			if activeDragInputObject.UserInputType == Enum.UserInputType.Touch then
				self._lastScreenPos = vector2
			else
				self._lastScreenPos = UserInputService:GetMouseLocation()
			end
		end
	end), "Disconnect")
	self._sessionJanitor:Add(self._pad.InputEnded:Connect(function(input, _: boolean)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.MouseButton2 and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end

		if self._activeDragInputObject == input then
			self._isDragging = false
			self._hasBrokenDragDeadzone = false
			self._activeDragInputType = nil
			self._activeDragInputObject = nil
			self._lastScreenPos = nil
		end
	end), "Disconnect")
	self._sessionJanitor:Add(UserInputService.InputChanged:Connect(function(input, _: boolean)
		if input.UserInputType == Enum.UserInputType.Gamepad1 and input.KeyCode == Enum.KeyCode.Thumbstick2 then
			if not (self:_shouldUseConsoleThumbstickRotation() and self:_isGamepadFocusOnCameraArea()) then
				self._thumbstickInput = Vector2.zero
				return
			end

			local X = input.Position.X
			local Y = input.Position.Y
			local v3 = math.abs(X) < 0.15 and 0 or X
			local v4 = math.abs(Y) < 0.15 and 0 or Y
			self._thumbstickInput = Vector2.new(v3, v4)
		else
			if not (self._isExperimentEnabled and input.UserInputType == Enum.UserInputType.MouseWheel and self:_isPointerInsideCameraArea()) then
				return
			end

			self._zoomDistance = math.clamp(self._zoomDistance - input.Position.Z * 1.5, 4, 18)
			self:_updateOrbitCamera()
		end
	end), "Disconnect")
	self._sessionJanitor:Add(
		UserInputService.TouchPinch:Connect(function(p, lastPinchScale: number, _: number, p2, flag: boolean)
			if flag or not self._isExperimentEnabled then
				return
			end

			if p2 == Enum.UserInputState.Begin then
				self._isPinchingCameraArea = self:_isAnyTouchInsideCameraArea(p)

				if self._isPinchingCameraArea then
					self._isDragging = false
					self._hasBrokenDragDeadzone = false
					self._activeDragInputType = nil
					self._activeDragInputObject = nil
					self._lastScreenPos = nil
				end

				self._lastPinchScale = lastPinchScale
			elseif p2 == Enum.UserInputState.Change then
				if not self._isPinchingCameraArea or self._lastPinchScale == nil or self._lastPinchScale <= 0 or lastPinchScale <= 0 then
					self._lastPinchScale = lastPinchScale
					return
				end

				local v3 = lastPinchScale / self._lastPinchScale

				if v3 > 0 and math.abs(1 - v3) >= 0.02 then
					self._zoomDistance = math.clamp(self._zoomDistance / v3, 4, 18)
					self:_updateOrbitCamera()
				end

				self._lastPinchScale = lastPinchScale
			elseif p2 == Enum.UserInputState.End or p2 == Enum.UserInputState.Cancel then
				self._isPinchingCameraArea = false
				self._lastPinchScale = nil
			end
		end),
		"Disconnect"
	)
	self._sessionJanitor:Add(RunService.RenderStepped:Connect(function(dt: number)
		self:_stepDragInput()
		self:_stepConsoleInput(dt)

		if self._isExperimentEnabled then
			self:_updateOrbitCamera()
		end
	end), "Disconnect")
end

function v:_deactivate()
	if not self._isActive then
		return
	end

	self._isActive = false
	self._isDragging = false
	self._hasBrokenDragDeadzone = false
	self._activeDragInputType = nil
	self._activeDragInputObject = nil
	self._lastScreenPos = nil
	self._thumbstickInput = Vector2.zero
	self._isPinchingCameraArea = false
	self._lastPinchScale = nil

	if self._cameraCollisionParams ~= nil then
		self._cameraCollisionParams.FilterDescendantsInstances = {}
	end

	self._sessionJanitor:Cleanup()
end

function v:Construct()
	self._janitor = Janitor.new()
	self._sessionJanitor = Janitor.new()
	self._pad = nil
	self._cameraArea = nil
	self._character = nil
	self._hrp = nil
	self._humanoid = nil
	self._isActive = false
	self._isExperimentEnabled = false
	self._isConsoleControlsEnabled = true
	self._thumbstickInput = Vector2.zero
	self._isDragging = false
	self._hasBrokenDragDeadzone = false
	self._activeDragInputType = nil
	self._activeDragInputObject = nil
	self._lastScreenPos = nil
	self._zoomDistance = 8
	self._orbitYaw = 0
	self._orbitPitch = 0
	self._lookLateralOffset = 0
	self._isPinchingCameraArea = false
	self._lastPinchScale = nil
	self._cameraCollisionParams = RaycastParams.new()
	self._cameraCollisionParams.FilterType = Enum.RaycastFilterType.Exclude
	self._cameraCollisionParams.FilterDescendantsInstances = {}
	self._cameraCollisionParams.RespectCanCollide = true
end

function v:Start()
	self._pad = self.Instance:WaitForChild("Pad")
	self._cameraArea = self.Instance:WaitForChild("CameraArea")
	self:_refreshABSettings()
	self._janitor:Add(PanelController.OnPanelOpened:Connect(function(_, p)
		if p ~= "AvatarEditorMenu" then
			return
		end

		task.defer(function()
			self:_activate()
		end)
	end))
	self._janitor:Add(PanelController.OnPanelClosed:Connect(function(_, p)
		if p ~= "AvatarEditorMenu" then
			return
		end

		self:_deactivate()
	end))
end

function v:Stop()
	self:_deactivate()
	self._sessionJanitor:Destroy()
	self._janitor:Destroy()
end

return v