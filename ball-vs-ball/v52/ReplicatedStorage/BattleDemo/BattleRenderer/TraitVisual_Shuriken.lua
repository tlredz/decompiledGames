local TraitVisualShuriken = {}
TraitVisualShuriken.__index = TraitVisualShuriken

function TraitVisualShuriken.new(ctx)
	local self = setmetatable({}, TraitVisualShuriken)
	self._ctx = ctx
	self._models = {}
	return self
end

function TraitVisualShuriken:update(p2)
	local _ctx = self._ctx
	local shuriken = p2.traits and p2.traits.Shuriken

	if not shuriken then
		return
	end

	self._models[p2.id] = self._models[p2.id] or {}
	local _model = self._models[p2.id]
	local lookVector = _ctx.arenaCFrame.LookVector
	local shurikenTemplateBundle = _ctx.shurikenTemplateBundle
	local shuriken2 = _ctx.config.traits and _ctx.config.traits.Shuriken
	local flightSpinSpeed = shuriken2 and shuriken2.flightSpinSpeed or 0
	local v = {}

	for _, v2 in shuriken.shurikens or {} do
		v[v2.shurikenId] = true
		local v3 = _model[v2.shurikenId]

		if not v3 then
			v3 = _ctx.cloneTemplateModel(shurikenTemplateBundle, string.format("Shuriken_%s_%d", p2.id, v2.shurikenId))
			v3.Parent = _ctx.rootFolder
			_model[v2.shurikenId] = v3
		end

		local worldFromArena = _ctx.worldFromArena(v2.position)
		local worldFromArena2 = _ctx.worldFromArena(v2.position + v2.direction)
		local v4 = math.rad(flightSpinSpeed * (v2.elapsed or 0))

		if (worldFromArena2 - worldFromArena).Magnitude > 0.001 then
			v3:PivotTo(CFrame.lookAt(worldFromArena, worldFromArena2, lookVector) * CFrame.Angles(0, v4, 0) * shurikenTemplateBundle.forwardOffset:Inverse())
		else
			v3:PivotTo(CFrame.new(worldFromArena) * v3:GetPivot().Rotation)
		end

		_ctx.setTemplateModelVisibility(v3, true)
	end

	for k, v2 in _model do
		if v[k] then
			continue
		end

		v2:Destroy()
		_model[k] = nil
	end
end

function TraitVisualShuriken:cleanupBall(p2: string)
	for _, v in self._models[p2] or {} do
		v:Destroy()
	end

	self._models[p2] = nil
end

function TraitVisualShuriken:reset()
	local v = {}

	for k in self._models do
		table.insert(v, k)
	end

	for _, v2 in v do
		self:cleanupBall(v2)
	end
end

return TraitVisualShuriken