local createVector = vector.create
local TraitVisualAcidSpit = {}
TraitVisualAcidSpit.__index = TraitVisualAcidSpit

function TraitVisualAcidSpit.new(ctx)
	local self = setmetatable({}, TraitVisualAcidSpit)
	self._ctx = ctx
	self._entries = {}
	return self
end

function TraitVisualAcidSpit:_createEntry(p2, p3: string, p4: number)
	local _ctx = self._ctx
	local templateModel = _ctx.cloneTemplateModel(p2, string.format("AcidDroplet_%s_%d", p3, p4))
	templateModel.Parent = _ctx.rootFolder
	local firstChild = templateModel:FindFirstChild("装饰")
	local folder = firstChild and firstChild:FindFirstChild("液滴")
	local part = firstChild and firstChild:FindFirstChild("酸液滩")
	local emitters = {}

	if folder then
		for _, emitter in folder:GetDescendants() do
			if emitter:IsA("ParticleEmitter") then
				table.insert(emitters, emitter)
			end
		end
	end

	if not (folder and folder:IsA("BasePart")) then
		folder = nil
	end

	if not (part and part:IsA("BasePart")) then
		part = nil
	end

	return {
		model = templateModel,
		droplet = folder,
		puddle = part,
		puddleBaseSize = not part and createVector(2, 0.1, 2) or part.Size,
		puddleTransparency = not part and 0 or part.Transparency,
		dropletDiameter = not folder and 0.6 or folder.Size.X,
		emitters = emitters
	}
end

function TraitVisualAcidSpit:update(p)
	local _ctx = self._ctx
	local templateBundle = _ctx.templateBundle
	local acidSpit = p.traits.AcidSpit

	if not (acidSpit and templateBundle) then
		return
	end

	local _entry = self._entries[p.id]

	if not _entry then
		_entry = {}
		self._entries[p.id] = _entry
	end

	local puddleResidueDuration = _ctx.config.puddleResidueDuration or 0
	local puddleGrowDuration = _ctx.config.puddleGrowDuration or 0
	local v = {}

	for _, v2 in acidSpit.droplets or {} do
		local dropletId = v2.dropletId
		v[dropletId] = true
		local v3 = _entry[dropletId]

		if not v3 then
			v3 = self:_createEntry(templateBundle, p.id, dropletId)
			_entry[dropletId] = v3
		end

		v3.model:PivotTo(_ctx.getArenaBallCFrame(_ctx.worldFromArena(v2.position)))
		local enabled = v2.phase == "Flying"

		if v3.droplet then
			v3.droplet.Transparency = enabled and 0 or 1
		end

		for _, emitter in v3.emitters do
			emitter.Enabled = enabled
		end

		local puddle = v3.puddle

		if not puddle then
			continue
		end

		if enabled then
			puddle.Transparency = 1
		else
			puddle.Transparency = v3.puddleTransparency
			local v5 = 2 * (v2.puddleRadius or 1)
			local v6 = puddleResidueDuration - (v2.puddleResidueRemaining or puddleResidueDuration)
			local v7 = not (puddleGrowDuration > 0) and 1 or math.clamp(v6 / puddleGrowDuration, 0, 1)
			local v8 = v3.dropletDiameter + (v5 - v3.dropletDiameter) * v7
			local puddleBaseSize = v3.puddleBaseSize
			local cFrame = puddle.CFrame

			if puddleBaseSize.X <= puddleBaseSize.Y and puddleBaseSize.X <= puddleBaseSize.Z then
				puddle.Size = Vector3.new(puddleBaseSize.X, v8, v8)
			elseif puddleBaseSize.Y <= puddleBaseSize.Z then
				puddle.Size = Vector3.new(v8, puddleBaseSize.Y, v8)
			else
				puddle.Size = Vector3.new(v8, v8, puddleBaseSize.Z)
			end

			puddle.CFrame = cFrame
		end
	end

	for k, v2 in _entry do
		if v[k] then
			continue
		end

		v2.model:Destroy()
		_entry[k] = nil
	end
end

function TraitVisualAcidSpit:cleanupBall(p2: string)
	for _, v in self._entries[p2] or {} do
		v.model:Destroy()
	end

	self._entries[p2] = nil
end

function TraitVisualAcidSpit:reset()
	local v = {}

	for k in self._entries do
		table.insert(v, k)
	end

	for _, v2 in v do
		self:cleanupBall(v2)
	end
end

return TraitVisualAcidSpit