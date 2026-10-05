local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "SnapScrolling"
})
local t = require(ReplicatedStorage.Packages.t)
local quad = Enum.EasingStyle.Quad
local out = Enum.EasingDirection.Out

local function clampSensitivity(p, p2)
	if t.number(p) and not (p <= 0 or p > 1) then
		return p
	end

	return p2
end

local v2 = {
	ImageLabel = true,
	ImageButton = true,
	TextLabel = true,
	TextButton = true,
	Frame = true
}

function v:_countSlotChildren()
	local count = 0

	for _, child in self.Instance:GetChildren() do
		if v2[child.ClassName] then
			count += 1
		end
	end

	return count
end

function v:Construct()
	self._Janitor = Janitor.new()
	self._scrolling = false
	self._lastSnapIndex = nil
	self._manualDragActive = false
	self._touchStartY = nil
	self._touchStartCanvasY = nil
	self._activeTouch = nil
end

function v:_isPointInScroll(point: Vector2)
	local instance = self.Instance
	local absolutePosition = instance.AbsolutePosition
	local absoluteSize = instance.AbsoluteSize
	return point.X >= absolutePosition.X and point.X <= absolutePosition.X + absoluteSize.X and point.Y >= absolutePosition.Y and point.Y <= absolutePosition.Y + absoluteSize.Y
end

function v:_getSnapConfig()
	local slotsCount = self.Instance:GetAttribute("SlotsCount")

	if not t.number(slotsCount) or slotsCount < 1 then
		slotsCount = self:_countSlotChildren()
	end

	local v3 = slotsCount < 1 and 1 or slotsCount
	local slotsPerView = self.Instance:GetAttribute("SlotsPerView")
	local v4 = (not t.number(slotsPerView) or slotsPerView < 1) and 5 or slotsPerView
	return v3, v4, (math.max(1, (math.ceil(v3 / v4))))
end

function v:_getSnapPositions()
	local instance = self.Instance
	local v3 = math.max(0, instance.AbsoluteCanvasSize.Y - instance.AbsoluteSize.Y)
	local _, _, v4 = self:_getSnapConfig()

	if v4 <= 1 then
		return { 0 }, v3
	end

	local result = {}

	for i = 0, v4 - 1 do
		result[i + 1] = i / (v4 - 1) * v3
	end

	return result, v3
end

function v:_getClosestSnapIndex(p)
	local _getSnapPositions, _ = self:_getSnapPositions()
	local v3 = 1e999
	local v4 = 1

	for k, _getSnapPosition in _getSnapPositions do
		local v5 = math.abs(p - _getSnapPosition)

		if not (v5 < v3) then
			continue
		end

		v4 = k
		v3 = v5
	end

	return v4
end

function v:_getSnapIndexByDirection(p2, p3, p4)
	local _lastSnapIndex = self._lastSnapIndex or 1
	local v3 = p3[_lastSnapIndex]

	if p4 <= 1 then
		return _lastSnapIndex
	end

	local v4

	if UserInputService.TouchEnabled then
		local snapSensitivityMobile = self.Instance:GetAttribute("SnapSensitivityMobile")
		v4 = (not t.number(snapSensitivityMobile) or snapSensitivityMobile <= 0 or snapSensitivityMobile > 1) and 0.35 or snapSensitivityMobile
	else
		local snapSensitivity = self.Instance:GetAttribute("SnapSensitivity")
		v4 = (not t.number(snapSensitivity) or snapSensitivity <= 0 or snapSensitivity > 1) and 0.1 or snapSensitivity
	end

	local v5

	if _lastSnapIndex < p4 then
		v5 = p3[_lastSnapIndex + 1] - p3[_lastSnapIndex]
	else
		v5 = p3[_lastSnapIndex] - p3[_lastSnapIndex - 1]
	end

	local v6 = v5 * v4

	if p2 <= v3 - v6 and _lastSnapIndex > 1 then
		return _lastSnapIndex - 1
	end

	if v3 + v6 <= p2 and _lastSnapIndex < p4 then
		return _lastSnapIndex + 1
	end

	return _lastSnapIndex
end

function v:_tweenToSnap(p)
	local instance = self.Instance
	local canvasPosition = instance.CanvasPosition
	local vector = Vector2.new(canvasPosition.X, p)

	if self._scrollTween and self._scrollTween.PlaybackState == Enum.PlaybackState.Playing then
		self._scrollTween:Cancel()
	end

	self._scrolling = true
	instance.ScrollingEnabled = false

	if UserInputService.TouchEnabled then
		instance.CanvasPosition = vector
		self._scrolling = false
		self._scrollTween = nil
	else
		self._scrollTween = TweenService:Create(instance, TweenInfo.new(0.25, quad, out), {
			CanvasPosition = vector
		})
		self._scrollTween.Completed:Once(function()
			self._scrolling = false
			instance.ScrollingEnabled = true
			self._scrollTween = nil
		end)
		self._scrollTween:Play()
	end
end

function v:_onCanvasPositionChanged()
	if self._scrolling or UserInputService.TouchEnabled and self._manualDragActive then
		return
	end

	local Y = self.Instance.CanvasPosition.Y
	local _getSnapPositions, v3 = self:_getSnapPositions()

	if v3 <= 0 then
		return
	end

	local _, _, v4 = self:_getSnapConfig()
	local _getSnapIndexByDirection = self:_getSnapIndexByDirection(Y, _getSnapPositions, v4)
	local _getSnapPosition = _getSnapPositions[_getSnapIndexByDirection]

	if self._lastSnapIndex == _getSnapIndexByDirection then
		return
	end

	self._lastSnapIndex = _getSnapIndexByDirection
	self:_tweenToSnap(_getSnapPosition)
end

function v:Start()
	local instance = self.Instance

	if not instance:IsA("ScrollingFrame") then
		warn("[SnapScrolling] Instance is not a ScrollingFrame:", instance:GetFullName())
		return
	end

	self._lastSnapIndex = self:_getClosestSnapIndex(instance.CanvasPosition.Y)
	self._Janitor:Add(instance:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
		self:_onCanvasPositionChanged()
	end))

	if UserInputService.TouchEnabled then
		instance.ScrollingEnabled = false
		self._Janitor:Add(UserInputService.InputBegan:Connect(function(activeTouch)
			if not (activeTouch.UserInputType == Enum.UserInputType.Touch and self:_isPointInScroll(activeTouch.Position)) then
				return
			end

			self._manualDragActive = true
			self._touchStartY = activeTouch.Position.Y
			self._touchStartCanvasY = instance.CanvasPosition.Y
			self._activeTouch = activeTouch
		end))
		self._Janitor:Add(UserInputService.InputChanged:Connect(function(input)
			if input ~= self._activeTouch or not self._manualDragActive then
				return
			end

			local _, v3 = self:_getSnapPositions()

			if v3 <= 0 then
				return
			end

			local v4 = math.clamp(self._touchStartCanvasY + (self._touchStartY - input.Position.Y), 0, v3)
			instance.CanvasPosition = Vector2.new(instance.CanvasPosition.X, v4)
		end))
		self._Janitor:Add(UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType ~= Enum.UserInputType.Touch or (input ~= self._activeTouch or not self._manualDragActive) then
				return
			end

			self._manualDragActive = false
			self._activeTouch = nil
			local _getSnapPositions, v3 = self:_getSnapPositions()

			if v3 <= 0 then
				return
			end

			local _getClosestSnapIndex = self:_getClosestSnapIndex(instance.CanvasPosition.Y)
			self._lastSnapIndex = _getClosestSnapIndex
			self:_tweenToSnap(_getSnapPositions[_getClosestSnapIndex])
		end))
	end
end

function v:Stop()
	if self._scrollTween and self._scrollTween.PlaybackState == Enum.PlaybackState.Playing then
		self._scrollTween:Cancel()
	end

	self._Janitor:Destroy()
end

return v