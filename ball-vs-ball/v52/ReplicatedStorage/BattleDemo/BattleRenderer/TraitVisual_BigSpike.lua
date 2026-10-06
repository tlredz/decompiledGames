local TraitVisualBigSpike = {}
TraitVisualBigSpike.__index = TraitVisualBigSpike

function TraitVisualBigSpike.new(ctx)
	local object = setmetatable({}, TraitVisualBigSpike)
	object._ctx = ctx
	object.bigSpikeModels = {}
	object.bigSpikeParts = {}
	object.bigSpikeTemplateBundle = nil
	object.bigSpikeMarkerOffset = CFrame.identity
	local bigSpikeTemplateName = ctx.config.visual.bigSpikeTemplateName
	local v

	if type(bigSpikeTemplateName) == "string" then
		v = bigSpikeTemplateName ~= ""
	else
		v = false
	end

	assert(v, "BattleConfig.visual.bigSpikeTemplateName is missing")
	object.bigSpikeTemplateBundle = ctx.getTemplateBundle(bigSpikeTemplateName)
	object.bigSpikeMarkerOffset = object.bigSpikeTemplateBundle.markerOffset
	return object
end

function TraitVisualBigSpike:_scaled(p2: number)
	return p2 * self._ctx.arenaScale
end

function TraitVisualBigSpike:_worldFromArena(point: Vector2, value: number?)
	local _ctx = self._ctx
	return _ctx.arenaCFrame:PointToWorldSpace((Vector3.new(
		point.X * _ctx.arenaScale,
		point.Y * _ctx.arenaScale,
		-self:_scaled(value or 0)
	)))
end

function TraitVisualBigSpike:_setModelVisibility(folder, flag: boolean)
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

function TraitVisualBigSpike:_ensurePart(p: string, p2: number)
	self.bigSpikeModels[p] = self.bigSpikeModels[p] or {}
	self.bigSpikeParts[p] = self.bigSpikeParts[p] or {}
	local v = self.bigSpikeModels[p][p2]
	local v2 = self.bigSpikeParts[p][p2]

	if v and v2 then
		return v, v2
	end

	local templateModel, v3 = self._ctx.cloneTemplateModel(
		self.bigSpikeTemplateBundle,
		string.format("%s_BigSpike_%d", p, p2)
	)
	self:_setModelVisibility(templateModel, false)
	self.bigSpikeModels[p][p2] = templateModel
	self.bigSpikeParts[p][p2] = v3
	return templateModel, v3
end

function TraitVisualBigSpike:_destroyVisual(p2: string, p3: number)
	local bigSpikeModel = self.bigSpikeModels[p2]
	local bigSpikePart = self.bigSpikeParts[p2]

	if bigSpikeModel and bigSpikeModel[p3] then
		bigSpikeModel[p3]:Destroy()
		bigSpikeModel[p3] = nil
	end

	if bigSpikePart then
		bigSpikePart[p3] = nil
	end
end

function TraitVisualBigSpike:_applyPart(instance, _, _, p)
	local _worldFromArena = self:_worldFromArena(p.wallPosition)
	local _worldFromArena2 = self:_worldFromArena(p.wallPosition + p.normal)
	instance:PivotTo(CFrame.lookAt(_worldFromArena, _worldFromArena2, self._ctx.arenaCFrame.LookVector) * self.bigSpikeMarkerOffset:Inverse())
	self:_setModelVisibility(instance, true)
end

function TraitVisualBigSpike:update(p)
	local v = {}

	for _, v2 in p.poisonSpikes or {} do
		v[v2.spikeId] = true
		local _ensurePart, v3 = self:_ensurePart(p.id, v2.spikeId)
		self:_applyPart(_ensurePart, v3, p, v2)
	end

	for k, _ in self.bigSpikeModels[p.id] or {} do
		if not v[k] then
			self:_destroyVisual(p.id, k)
		end
	end
end

function TraitVisualBigSpike:cleanupBall(p: string)
	for k, _ in self.bigSpikeModels[p] or {} do
		self:_destroyVisual(p, k)
	end
end

function TraitVisualBigSpike:reset()
	for k in self.bigSpikeModels do
		self:cleanupBall(k)
	end
end

return TraitVisualBigSpike