local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local EggActionMovement = require(script.Parent.EggActionMovement)
local t = require(ReplicatedStorage.Packages.t)
local PlacedEggReadyPulse = {}
PlacedEggReadyPulse.__index = PlacedEggReadyPulse
PlacedEggReadyPulse.__class = "PlacedEggReadyPulse"

function PlacedEggReadyPulse.new(model, basePivot: CFrame, baseScale: number)
	t.strict(t.instanceIsA("Model"))(model)
	t.strict(t.CFrame)(basePivot)
	t.strict(t.number)(baseScale)
	local self = setmetatable({}, PlacedEggReadyPulse)
	self._model = model
	self._highlight = nil
	self._basePivot = basePivot
	self._baseScale = baseScale
	self._animation = nil
	self._destroyed = false
	return self
end

function PlacedEggReadyPulse:_createHighlight()
	local highlight = Instance.new("Highlight")
	highlight.Name = "ReadyEggPulseHighlight"
	highlight.Adornee = self._model
	highlight.DepthMode = Enum.HighlightDepthMode.Occluded
	highlight.FillColor = Color3.new(1, 1, 1)
	highlight.FillTransparency = 1
	highlight.OutlineTransparency = 1
	highlight.Parent = self._model
	self._highlight = highlight
	return highlight
end

function PlacedEggReadyPulse:_destroyHighlight()
	local _highlight = self._highlight

	if _highlight == nil then
		return
	end

	self._highlight = nil
	_highlight:Destroy()
end

function PlacedEggReadyPulse:_resetVisual()
	local _model = self._model

	if _model:IsDescendantOf(game) then
		_model:ScaleTo(self._baseScale)
		EggActionMovement.SetPivot(_model, self._basePivot)
	end

	self:_destroyHighlight()
end

function PlacedEggReadyPulse:SetTransform(basePivot: CFrame, baseScale: number)
	t.strict(t.CFrame)(basePivot)
	t.strict(t.number)(baseScale)
	self._basePivot = basePivot
	self._baseScale = baseScale
end

function PlacedEggReadyPulse:IsPlaying()
	return self._animation ~= nil
end

function PlacedEggReadyPulse:Play()
	if self._destroyed or self:IsPlaying() or not self._model:IsDescendantOf(game) then
		return false
	end

	self:_resetVisual()

	local function step(value: number)
		if self._destroyed or not self._model:IsDescendantOf(game) then
			return true
		end

		local v = math.clamp(value, 0, 1) * 1.05
		local _model = self._model
		local _basePivot = self._basePivot
		local _baseScale = self._baseScale

		if v < 0.25 then
			local v2 = v / 0.25
			local v3 = 1 - TweenService:GetValue(v2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			local v4 = math.sin(v2 * 3.141592653589793 * 2 * 3) * 0.05235987755982989 * v3
			_model:ScaleTo(_baseScale)
			EggActionMovement.SetPivot(_model, _basePivot * CFrame.Angles(0, 0, v4))
			return false
		else
			local v2 = v - 0.25

			if v2 < 0.6 then
				local v3 = v2 / 0.6
				local value2 = TweenService:GetValue(v3, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out)
				local v4 = math.sin(v3 * 3.141592653589793);
				(self._highlight or self:_createHighlight()).FillTransparency = 1 - v4 * 0.9
				_model:ScaleTo(_baseScale * (1 + 0.19999999999999996 * value2))
				EggActionMovement.SetPivot(_model, _basePivot)
				return false
			else
				self:_destroyHighlight()
				_model:ScaleTo(_baseScale * (1.2 + -0.19999999999999996 * TweenService:GetValue(
					math.clamp((v2 - 0.6) / 0.2, 0, 1),
					Enum.EasingStyle.Quad,
					Enum.EasingDirection.Out
				)))
				EggActionMovement.SetPivot(_model, _basePivot)
				return value >= 1
			end
		end
	end

	local v = 0
	local preRenderConnection = nil
	preRenderConnection = RunService.PreRender:Connect(function(dt: number)
		v = math.min(v + dt, 1.05)

		if not step(v / 1.05) then
			return
		end

		preRenderConnection:Disconnect()

		if self._animation ~= preRenderConnection then
			return
		end

		self._animation = nil

		if not self._destroyed then
			self:_resetVisual()
		end
	end)
	self._animation = preRenderConnection
	return true
end

function PlacedEggReadyPulse:Cancel()
	local _animation = self._animation

	if _animation == nil then
		return
	end

	self._animation = nil
	_animation:Disconnect()

	if not self._destroyed then
		self:_resetVisual()
	end
end

function PlacedEggReadyPulse:Destroy()
	if self._destroyed then
		return
	end

	self:Cancel()
	self._destroyed = true
	self:_destroyHighlight()
end

return PlacedEggReadyPulse