local TweenService = game:GetService("TweenService")
local TraitVisualDiceBarrage = {}
TraitVisualDiceBarrage.__index = TraitVisualDiceBarrage
local v = {
	[1] = CFrame.identity,
	[6] = CFrame.Angles(3.141592653589793, 0, 0),
	[3] = CFrame.Angles(1.5707963267948966, 0, 0),
	[4] = CFrame.Angles(-1.5707963267948966, 0, 0),
	[5] = CFrame.Angles(0, 0, -1.5707963267948966),
	[2] = CFrame.Angles(0, 0, 1.5707963267948966)
}

function TraitVisualDiceBarrage.new(ctx)
	local object = setmetatable({}, TraitVisualDiceBarrage)
	object._ctx = ctx
	object._models = {}
	object._topValues = {}
	object._tweens = {}
	object._templateRotation = ctx.diceTemplateBundle.model:GetPivot().Rotation
	return object
end

function TraitVisualDiceBarrage:_key(p, p2)
	return string.format("%s:%s", tostring(p), (tostring(p2)))
end

function TraitVisualDiceBarrage:_targetCFrame(point: Vector2, p2: number)
	local _ctx = self._ctx
	local worldFromArena = _ctx.worldFromArena(point, _ctx.config.visual.diceHeight or 0.26)
	local v2 = v[p2] or CFrame.identity
	return _ctx.getArenaBallCFrame(worldFromArena) * v2 * self._templateRotation
end

function TraitVisualDiceBarrage:_stopTween(p2: string)
	local _tween = self._tweens[p2]

	if _tween then
		_tween.tween:Cancel()
		_tween.connection:Disconnect()
		_tween.value:Destroy()
		self._tweens[p2] = nil
	end
end

function TraitVisualDiceBarrage:_rollTo(p: string, instance, cframe: CFrame, duration: number)
	self:_stopTween(p)
	local cFrameValue = Instance.new("CFrameValue")
	cFrameValue.Value = instance:GetPivot()
	local valueChangedConnection = cFrameValue:GetPropertyChangedSignal("Value"):Connect(function()
		if instance.Parent then
			instance:PivotTo(cFrameValue.Value)
		end
	end)
	local tween = TweenService:Create(
		cFrameValue,
		TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{
			Value = cframe
		}
	)
	self._tweens[p] = {
		tween = tween,
		value = cFrameValue,
		connection = valueChangedConnection
	}
	tween.Completed:Connect(function()
		if self._tweens[p] and self._tweens[p].tween == tween then
			valueChangedConnection:Disconnect()
			cFrameValue:Destroy()
			self._tweens[p] = nil
		end
	end)
	tween:Play()
end

function TraitVisualDiceBarrage:update(p)
	local diceBarrage = p.traits.DiceBarrage

	if not diceBarrage then
		return
	end

	self._models[p.id] = self._models[p.id] or {}
	self._topValues[p.id] = self._topValues[p.id] or {}
	local v2 = {}

	for _, v3 in diceBarrage.dice or {} do
		local diceId = v3.diceId
		v2[diceId] = true
		local v4 = self._models[p.id][diceId]
		local _targetCFrame = self:_targetCFrame(v3.position, v3.topValue)

		if v4 then
			if self._topValues[p.id][diceId] ~= v3.topValue then
				local v5 = math.max(0, self._ctx.config.traits.DiceBarrage.diceRollTweenDuration or 0.35)

				if v5 > 0 then
					self:_rollTo(self:_key(p.id, diceId), v4, _targetCFrame, v5)
				else
					v4:PivotTo(_targetCFrame)
				end
			end
		else
			local templateModel = self._ctx.cloneTemplateModel(
				self._ctx.diceTemplateBundle,
				string.format("Dice_%s_%s", p.id, diceId)
			)
			self._models[p.id][diceId] = templateModel
			templateModel:PivotTo(_targetCFrame)
		end

		self._topValues[p.id][diceId] = v3.topValue
	end

	for k, v3 in self._models[p.id] do
		if v2[k] then
			continue
		end

		self:_stopTween(self:_key(p.id, k))
		v3:Destroy()
		self._models[p.id][k] = nil
		self._topValues[p.id][k] = nil
	end
end

function TraitVisualDiceBarrage:cleanupBall(p)
	for k, v2 in self._models[p] or {} do
		self:_stopTween(self:_key(p, k))
		v2:Destroy()
	end

	self._models[p] = nil
	self._topValues[p] = nil
end

function TraitVisualDiceBarrage:reset()
	local v2 = {}

	for k in self._models do
		table.insert(v2, k)
	end

	for _, v3 in v2 do
		self:cleanupBall(v3)
	end
end

return TraitVisualDiceBarrage