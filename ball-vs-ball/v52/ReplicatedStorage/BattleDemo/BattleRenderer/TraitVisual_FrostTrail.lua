local TraitVisualFrostTrail = {}
TraitVisualFrostTrail.__index = TraitVisualFrostTrail

function TraitVisualFrostTrail.new(ctx)
	local self = setmetatable({}, TraitVisualFrostTrail)
	self._ctx = ctx
	self.models = {}
	self.parts = {}
	return self
end

function TraitVisualFrostTrail:_setTemplateModelAlpha(folder, p: number)
	for _, part in ipairs(folder:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		local originalTransparency = part:GetAttribute("OriginalTransparency")
		local v = typeof(originalTransparency) == "number" and originalTransparency or part.Transparency
		part.Transparency = v + (1 - v) * (1 - p)
	end
end

function TraitVisualFrostTrail:_ensureModel(p: string, p2: number)
	self.models[p] = self.models[p] or {}
	self.parts[p] = self.parts[p] or {}
	local v = self.models[p][p2]
	local v2 = self.parts[p][p2]

	if v and v2 then
		return v, v2
	end

	local templateModel, v3 = self._ctx.cloneTemplateModel(
		self._ctx.frostTrailTemplateBundle,
		string.format("%s_FrostTrail_%d", p, p2)
	)
	self.models[p][p2] = templateModel
	self.parts[p][p2] = v3
	return templateModel, v3
end

function TraitVisualFrostTrail:_destroyPatch(p2: string, p3: number)
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

function TraitVisualFrostTrail:update(p)
	local _ctx = self._ctx
	local frostTrail = p.traits and p.traits.FrostTrail

	if not frostTrail then
		return
	end

	local trailDuration = _ctx.config.traits.FrostTrail.trailDuration or 0
	local v = {}

	for _, v2 in frostTrail.trail or {} do
		v[v2.trailId] = true
		local _ensureModel, _ = self:_ensureModel(p.id, v2.trailId)
		local worldFromArena = _ctx.worldFromArena(v2.position)
		_ensureModel:PivotTo(_ctx.getArenaBallCFrame(worldFromArena) * _ctx.frostTrailTemplateBundle.markerOffset:Inverse())
		self:_setTemplateModelAlpha(
			_ensureModel,
			not (trailDuration > 0) and 1 or math.clamp((v2.residueRemaining or 0) / trailDuration, 0, 1) or 1
		)
	end

	for k, _ in self.models[p.id] or {} do
		if not v[k] then
			self:_destroyPatch(p.id, k)
		end
	end
end

function TraitVisualFrostTrail:cleanupBall(p: string)
	for k, _ in self.models[p] or {} do
		self:_destroyPatch(p, k)
	end
end

function TraitVisualFrostTrail:reset()
	for k in self.models do
		self:cleanupBall(k)
	end
end

return TraitVisualFrostTrail