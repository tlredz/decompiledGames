local TraitVisualPoisonSpike = {}
TraitVisualPoisonSpike.__index = TraitVisualPoisonSpike

function TraitVisualPoisonSpike.new(ctx)
	local object = setmetatable({}, TraitVisualPoisonSpike)
	object._ctx = ctx
	object.poisonSpikeModels = {}
	object.poisonSpikeParts = {}
	object.poisonSpikeTemplateBundle = nil
	object.poisonSpikeMarkerOffset = CFrame.identity
	local poisonSpikeTemplateName = ctx.config.visual.poisonSpikeTemplateName
	local v

	if type(poisonSpikeTemplateName) == "string" then
		v = poisonSpikeTemplateName ~= ""
	else
		v = false
	end

	assert(v, "BattleConfig.visual.poisonSpikeTemplateName is missing")
	object.poisonSpikeTemplateBundle = ctx.getTemplateBundle(poisonSpikeTemplateName)
	object.poisonSpikeMarkerOffset = object.poisonSpikeTemplateBundle.markerOffset
	return object
end

function TraitVisualPoisonSpike:_scaled(p2: number)
	return p2 * self._ctx.arenaScale
end

function TraitVisualPoisonSpike:_worldFromArena(point: Vector2, value: number?)
	local _ctx = self._ctx
	return _ctx.arenaCFrame:PointToWorldSpace((Vector3.new(
		point.X * _ctx.arenaScale,
		point.Y * _ctx.arenaScale,
		-self:_scaled(value or 0)
	)))
end

function TraitVisualPoisonSpike:_setModelVisibility(folder, flag: boolean)
	for _, part in ipairs(folder:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		local originalTransparency = part:GetAttribute("OriginalTransparency")

		if flag then
			part.Transparency = typeof(originalTransparency) == "number" and originalTransparency or part.Transparency
		else
			part.Transparency = 1
		end
	end
end

function TraitVisualPoisonSpike:_ensurePart(p: string, p2: number)
	self.poisonSpikeModels[p] = self.poisonSpikeModels[p] or {}
	self.poisonSpikeParts[p] = self.poisonSpikeParts[p] or {}
	local v = self.poisonSpikeModels[p][p2]
	local v2 = self.poisonSpikeParts[p][p2]

	if v and v2 then
		return v, v2
	end

	local templateModel, v3 = self._ctx.cloneTemplateModel(
		self.poisonSpikeTemplateBundle,
		string.format("%s_PoisonSpike_%d", p, p2)
	)
	self:_setModelVisibility(templateModel, false)
	self.poisonSpikeModels[p][p2] = templateModel
	self.poisonSpikeParts[p][p2] = v3
	return templateModel, v3
end

function TraitVisualPoisonSpike:_destroyVisual(p2: string, p3: number)
	local poisonSpikeModel = self.poisonSpikeModels[p2]
	local poisonSpikePart = self.poisonSpikeParts[p2]

	if poisonSpikeModel and poisonSpikeModel[p3] then
		poisonSpikeModel[p3]:Destroy()
		poisonSpikeModel[p3] = nil
	end

	if poisonSpikePart then
		poisonSpikePart[p3] = nil
	end
end

function TraitVisualPoisonSpike:_applyPart(instance, _, _, p)
	local _worldFromArena = self:_worldFromArena(p.wallPosition)
	local _worldFromArena2 = self:_worldFromArena(p.wallPosition + p.normal)
	instance:PivotTo(CFrame.lookAt(_worldFromArena, _worldFromArena2, self._ctx.arenaCFrame.LookVector) * self.poisonSpikeMarkerOffset:Inverse())
	self:_setModelVisibility(instance, true)
end

function TraitVisualPoisonSpike:update(p)
	local v = {}

	for _, v2 in p.poisonSpikes or {} do
		v[v2.spikeId] = true
		local _ensurePart, v3 = self:_ensurePart(p.id, v2.spikeId)
		self:_applyPart(_ensurePart, v3, p, v2)
	end

	for k, _ in self.poisonSpikeModels[p.id] or {} do
		if not v[k] then
			self:_destroyVisual(p.id, k)
		end
	end
end

function TraitVisualPoisonSpike:cleanupBall(p: string)
	for k, _ in self.poisonSpikeModels[p] or {} do
		self:_destroyVisual(p, k)
	end
end

function TraitVisualPoisonSpike:reset()
	for k in self.poisonSpikeModels do
		self:cleanupBall(k)
	end
end

return TraitVisualPoisonSpike