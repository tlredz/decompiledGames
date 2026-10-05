local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local EggActionMovement = require(script.Parent.EggActionMovement)
local t = require(ReplicatedStorage.Packages.t)
local EggGrowthAnimation = {}
EggGrowthAnimation.__index = EggGrowthAnimation
EggGrowthAnimation.__class = "EggGrowthAnimation"

function EggGrowthAnimation.new(model, basePivot: CFrame, jumpHeightMultiplier: number)
	t.strict(t.instanceIsA("Model"))(model)
	t.strict(t.CFrame)(basePivot)
	t.strict(t.number)(jumpHeightMultiplier)
	assert(jumpHeightMultiplier > 0, "Jump height multiplier must be positive")
	local self = setmetatable({}, EggGrowthAnimation)
	self._model = model
	self._basePivot = basePivot
	self._jumpHeightMultiplier = jumpHeightMultiplier
	self._animation = nil
	self._destroyed = false
	return self
end

function EggGrowthAnimation:_resetVisual()
	local _model = self._model

	if _model:IsDescendantOf(game) then
		EggActionMovement.SetPivot(_model, self._basePivot)
	end
end

function EggGrowthAnimation:SetBasePivot(basePivot: CFrame)
	t.strict(t.CFrame)(basePivot)
	self._basePivot = basePivot

	if not self:IsPlaying() then
		self:_resetVisual()
	end
end

function EggGrowthAnimation:IsPlaying()
	return self._animation ~= nil
end

function EggGrowthAnimation:Play()
	if self._destroyed or self:IsPlaying() or not self._model:IsDescendantOf(game) then
		return false
	end

	local function step(value: number)
		if self._destroyed or not self._model:IsDescendantOf(game) then
			return true
		end

		local v = math.clamp(value, 0, 1)
		local value2

		if v < 0.5 then
			value2 = TweenService:GetValue(v * 2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		else
			value2 = 1 - TweenService:GetValue((v - 0.5) * 2, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)
		end

		local v2 = 1 - TweenService:GetValue(v, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local v3 = math.sin(v * 3.141592653589793 * 2 * 4) * 0.06981317007977318 * v2
		local v4 = 0.85 * self._jumpHeightMultiplier * value2
		EggActionMovement.SetPivot(self._model, self._basePivot * CFrame.new(0, v4, 0) * CFrame.Angles(0, 0, v3))
		return value >= 1
	end

	local v = 0
	local preRenderConnection = nil
	preRenderConnection = RunService.PreRender:Connect(function(dt: number)
		v = math.min(v + dt, 0.55)

		if not step(v / 0.55) then
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

function EggGrowthAnimation:Cancel()
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

function EggGrowthAnimation:Destroy()
	if self._destroyed then
		return
	end

	self:Cancel()
	self._destroyed = true
end

return EggGrowthAnimation