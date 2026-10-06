local TraitVisualMedicBarrage = {}
TraitVisualMedicBarrage.__index = TraitVisualMedicBarrage

function TraitVisualMedicBarrage.new(ctx)
	local self = setmetatable({}, TraitVisualMedicBarrage)
	self._ctx = ctx
	self._models = {}
	return self
end

function TraitVisualMedicBarrage:update(p2)
	local _ctx = self._ctx
	local medicBarrage = p2.traits and p2.traits.MedicBarrage

	if not medicBarrage then
		return
	end

	self._models[p2.id] = self._models[p2.id] or {}
	local _model = self._models[p2.id]
	local lookVector = _ctx.arenaCFrame.LookVector
	local medicBulletTemplateBundle = _ctx.medicBulletTemplateBundle
	local v = {}

	for _, v2 in medicBarrage.bullets or {} do
		v[v2.bulletId] = true
		local v3 = _model[v2.bulletId]

		if not v3 then
			v3 = _ctx.cloneTemplateModel(
				medicBulletTemplateBundle,
				string.format("MedicBullet_%s_%d", p2.id, v2.bulletId)
			)
			v3.Parent = _ctx.rootFolder
			_model[v2.bulletId] = v3
		end

		local worldFromArena = _ctx.worldFromArena(v2.position)
		local worldFromArena2 = _ctx.worldFromArena(v2.position + v2.direction)

		if (worldFromArena2 - worldFromArena).Magnitude > 0.001 then
			v3:PivotTo(CFrame.lookAt(worldFromArena, worldFromArena2, lookVector) * medicBulletTemplateBundle.forwardOffset:Inverse())
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

function TraitVisualMedicBarrage:cleanupBall(p2: string)
	for _, v in self._models[p2] or {} do
		v:Destroy()
	end

	self._models[p2] = nil
end

function TraitVisualMedicBarrage:reset()
	local v = {}

	for k in self._models do
		table.insert(v, k)
	end

	for _, v2 in v do
		self:cleanupBall(v2)
	end
end

return TraitVisualMedicBarrage