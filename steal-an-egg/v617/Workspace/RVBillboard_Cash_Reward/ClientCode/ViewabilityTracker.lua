local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local currentCamera = Workspace.CurrentCamera
local localPlayer = Players.LocalPlayer
local v = false
local ViewabilityTracker = {}
ViewabilityTracker.__index = ViewabilityTracker

function ViewabilityTracker.new(screenPart, range: number, flag: boolean?)
	v = flag or false
	local object = setmetatable({}, ViewabilityTracker)
	object._screenPart = screenPart
	object._model = screenPart.Parent
	object._range = range
	object._viewDuration = 0
	object._confirmed = false
	object._lastDebugState = ""
	object._raycastParams = RaycastParams.new()
	object._raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	return object
end

function ViewabilityTracker:_getDistance()
	local character = localPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart then
		return (self._screenPart.Position - humanoidRootPart.Position).Magnitude
	end

	return 1e999
end

function ViewabilityTracker:_getAngle()
	return (math.abs(180 - math.deg((math.acos((math.clamp(
		self._screenPart.CFrame.LookVector:Dot(currentCamera.CFrame.LookVector),
		-1,
		1
	)))))))
end

function ViewabilityTracker:_getCameraDistance()
	return (self._screenPart.Position - currentCamera.CFrame.Position).Magnitude
end

function ViewabilityTracker:_getAngularRatio()
	local _getCameraDistance = self:_getCameraDistance()

	if _getCameraDistance <= 0 then
		return 1e999
	end

	local X = self._screenPart.Size.X
	local fieldOfView = math.rad(currentCamera.FieldOfView)
	return math.atan(X / 2 / _getCameraDistance) * 2 / fieldOfView
end

function ViewabilityTracker:_getOcclusionCount()
	local character = localPlayer.Character
	self._raycastParams.FilterDescendantsInstances = { character, self._model }
	local position = currentCamera.CFrame.Position
	local size = self._screenPart.Size
	local cFrame = self._screenPart.CFrame
	local v2 = size.X / 2
	local v3 = size.Y / 2
	local count = 0

	for _, v4 in {
		self._screenPart.Position,
		(cFrame * CFrame.new(-v2, v3, 0)).Position,
		(cFrame * CFrame.new(v2, v3, 0)).Position,
		(cFrame * CFrame.new(-v2, -v3, 0)).Position,
		(cFrame * CFrame.new(v2, -v3, 0)).Position,
		(cFrame * CFrame.new(-v2 / 2, v3 / 2, 0)).Position,
		(cFrame * CFrame.new(v2 / 2, v3 / 2, 0)).Position,
		(cFrame * CFrame.new(-v2 / 2, -v3 / 2, 0)).Position,
		(cFrame * CFrame.new(v2 / 2, -v3 / 2, 0)).Position
	} do
		if Workspace:Raycast(position, v4 - position, self._raycastParams) == nil then
			count += 1
		end
	end

	return count
end

function ViewabilityTracker:_debugPrint(lastDebugState: string, p: number, p2: number, p3: number, p4: number)
	if not (v and lastDebugState ~= self._lastDebugState) then
		return
	end

	self._lastDebugState = lastDebugState
	local v2 = p <= self._range
	local v3 = p2 <= 65
	local v4 = p3 >= 0.2
	local v5 = p4 >= 5
	print(string.format(
		"[Viewability] %s | Dist: %.0f/%d %s | Angle: %.1f°/%d° %s | FOV%%: %.1f%%/%.1f%% %s | Rays: %d/9 %s | Timer: %.1f/%.1fs",
		lastDebugState,
		p,
		self._range,
		v2 and "OK" or "FAIL",
		p2,
		65,
		v3 and "OK" or "FAIL",
		p3 * 100,
		20,
		v4 and "OK" or "FAIL",
		p4,
		v5 and "OK" or "FAIL",
		self._viewDuration,
		1
	))
end

function ViewabilityTracker:update(p: number)
	if self._confirmed then
		return true
	end

	local _getDistance = self:_getDistance()
	local _getCameraDistance = self:_getCameraDistance()

	if self._range * 2 < _getCameraDistance then
		self._viewDuration = 0
		self:_debugPrint("HARD CUTOFF", _getCameraDistance, 0, 0, 0)
		return false
	elseif self._range < _getDistance then
		self._viewDuration = 0
		self:_debugPrint("OUT OF RANGE", _getDistance, 0, 0, 0)
		return false
	else
		local _getAngle = self:_getAngle()
		local _getAngularRatio = self:_getAngularRatio()
		local _getOcclusionCount = self:_getOcclusionCount()
		local v2 = _getAngle <= 65
		local v3 = _getAngularRatio >= 0.2
		local v4 = _getOcclusionCount >= 5

		if v2 then
			if v3 then
				if v4 then
					self._viewDuration += p
					self:_debugPrint(
						string.format("VALIDATING %.1fs", self._viewDuration),
						_getDistance,
						_getAngle,
						_getAngularRatio,
						_getOcclusionCount
					)

					if not (self._viewDuration >= 1) then
						return false
					end

					self._confirmed = true
					self._lastDebugState = ""
					self:_debugPrint(
						"IMPRESSION CONFIRMED",
						_getDistance,
						_getAngle,
						_getAngularRatio,
						_getOcclusionCount
					)
					return true
				else
					self._viewDuration = 0
					self:_debugPrint("FAIL: OCCLUDED", _getDistance, _getAngle, _getAngularRatio, _getOcclusionCount)
					return false
				end
			else
				self._viewDuration = 0
				self:_debugPrint("FAIL: SIZE", _getDistance, _getAngle, _getAngularRatio, _getOcclusionCount)
				return false
			end
		else
			self._viewDuration = 0
			self:_debugPrint("FAIL: ANGLE", _getDistance, _getAngle, _getAngularRatio, _getOcclusionCount)
			return false
		end
	end
end

function ViewabilityTracker:reset()
	self._viewDuration = 0
	self._confirmed = false
	self._lastDebugState = ""

	if v then
		print("[Viewability] RESET — awaiting new impression")
	end
end

function ViewabilityTracker:destroy()
	self._screenPart = nil
	self._model = nil
	self._raycastParams = nil
end

return ViewabilityTracker