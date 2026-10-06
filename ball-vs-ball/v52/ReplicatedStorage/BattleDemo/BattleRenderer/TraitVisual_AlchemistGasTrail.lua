local TraitVisualAlchemistGasTrail = {}
TraitVisualAlchemistGasTrail.__index = TraitVisualAlchemistGasTrail

function TraitVisualAlchemistGasTrail.new(ctx)
	local self = setmetatable({}, TraitVisualAlchemistGasTrail)
	self._ctx = ctx
	self.models = {}
	self.parts = {}
	return self
end

function TraitVisualAlchemistGasTrail:_setTemplateModelAlpha(folder, p: number)
	for _, part in ipairs(folder:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		local originalTransparency = part:GetAttribute("OriginalTransparency")
		local v = typeof(originalTransparency) == "number" and originalTransparency or part.Transparency
		part.Transparency = v + (1 - v) * (1 - p)
	end
end

function TraitVisualAlchemistGasTrail:_setEmittersEnabled(folder, enabled: boolean)
	for _, emitter in ipairs(folder:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") and emitter.Enabled ~= enabled then
			emitter.Enabled = enabled
		end
	end
end

function TraitVisualAlchemistGasTrail:_ensureModel(p: string, p2: number)
	self.models[p] = self.models[p] or {}
	self.parts[p] = self.parts[p] or {}
	local v = self.models[p][p2]
	local v2 = self.parts[p][p2]

	if v and v2 then
		return v, v2
	end

	local templateModel, v3 = self._ctx.cloneTemplateModel(
		self._ctx.alchemistGasTrailTemplateBundle,
		string.format("%s_AlchemistGasTrail_%d", p, p2)
	)
	self.models[p][p2] = templateModel
	self.parts[p][p2] = v3
	return templateModel, v3
end

function TraitVisualAlchemistGasTrail:_destroyPatch(p2: string, p3: number)
	local model = self.models[p2]
	local part = self.parts[p2]

	if model and model[p3] then
		model[p3]:Destroy()
		model[p3] = nil
	end

	if part then
		part[p3] = nil
	end
end

function TraitVisualAlchemistGasTrail:update(p)
	local _ctx = self._ctx
	local alchemistGasTrail = p.traits and p.traits.AlchemistGasTrail

	if not alchemistGasTrail then
		return
	end

	local trailDuration = _ctx.config.traits.AlchemistGasTrail.trailDuration or 0
	local v = {}

	for _, v2 in alchemistGasTrail.trail or {} do
		v[v2.trailId] = true
		local _ensureModel, _ = self:_ensureModel(p.id, v2.trailId)
		local worldFromArena = _ctx.worldFromArena(v2.position)
		_ensureModel:PivotTo(_ctx.getArenaBallCFrame(worldFromArena) * _ctx.alchemistGasTrailTemplateBundle.markerOffset:Inverse())
		local residueRemaining = v2.residueRemaining or 0
		self:_setTemplateModelAlpha(
			_ensureModel,
			not (trailDuration > 0) and 1 or math.clamp(residueRemaining / trailDuration, 0, 1) or 1
		)
		self:_setEmittersEnabled(_ensureModel, residueRemaining > 1)
	end

	for k, _ in self.models[p.id] or {} do
		if not v[k] then
			self:_destroyPatch(p.id, k)
		end
	end
end

function TraitVisualAlchemistGasTrail:cleanupBall(p: string)
	for k, _ in self.models[p] or {} do
		self:_destroyPatch(p, k)
	end
end

function TraitVisualAlchemistGasTrail:reset()
	for k in self.models do
		self:cleanupBall(k)
	end
end

return TraitVisualAlchemistGasTrail