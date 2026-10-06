local TraitVisualVoltaicShock = {}
TraitVisualVoltaicShock.__index = TraitVisualVoltaicShock

function TraitVisualVoltaicShock.new(ctx)
	local object = setmetatable({}, TraitVisualVoltaicShock)
	object.ctx = ctx
	object.models = {}
	object.template = ctx.effectAssetRoot:WaitForChild(ctx.config.visual.voltaicTemplateName)
	return object
end

function TraitVisualVoltaicShock:_ensure(p)
	local model = self.models[p]

	if model then
		return model
	end

	local clone = self.template:Clone()
	clone.Name = p .. "_Voltaic"
	local model2 = clone:FindFirstChild("低充能")
	local model3 = clone:FindFirstChild("高充能")
	assert(model2 and model2:IsA("Model"), "十万伏特模板缺少低充能子模型")
	assert(model3 and model3:IsA("Model"), "十万伏特模板缺少高充能子模型")

	for _, part in ipairs(clone:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
	end

	clone.Parent = self.ctx.rootFolder
	local v = {
		model = clone,
		low = model2,
		high = model3
	}
	self.models[p] = v
	return v
end

function TraitVisualVoltaicShock:_setMode(p, enabled)
	for _, emitter in ipairs(p.low:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = not enabled
		end
	end

	for _, emitter in ipairs(p.high:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = enabled
		end
	end
end

function TraitVisualVoltaicShock:update(data)
	local voltaicShock = data.traits and data.traits.VoltaicShock
	local v

	if data.voltaicShockSourceBallId == nil then
		v = false
	else
		v = (data.voltaicShockRemaining or 0) > 0
	end

	if not (voltaicShock or v) then
		self:cleanupBall(data.id)
		return
	end

	local v2 = v or voltaicShock and voltaicShock.isCharged
	local _ensure = self:_ensure(data.id)
	self:_setMode(_ensure, v2)
	_ensure.model:PivotTo(CFrame.new(self.ctx.worldFromArena(data.position)) * self.ctx.effectArenaRotation)
end

function TraitVisualVoltaicShock.getHighChargeModel(p, p2)
	local model = p.models[p2]
	return model and model.high
end

function TraitVisualVoltaicShock:cleanupBall(p2)
	local model = self.models[p2]

	if model then
		model.model:Destroy()
		self.models[p2] = nil
	end
end

function TraitVisualVoltaicShock:reset()
	for k in self.models do
		self:cleanupBall(k)
	end
end

function TraitVisualVoltaicShock.playShock(p, p2)
	if p2.position then
		p.ctx.audio:playCue("ballHit")
	end
end

return TraitVisualVoltaicShock