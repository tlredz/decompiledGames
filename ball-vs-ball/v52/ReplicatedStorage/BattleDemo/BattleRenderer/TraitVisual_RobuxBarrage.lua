local TraitVisualRobuxBarrage = {}
TraitVisualRobuxBarrage.__index = TraitVisualRobuxBarrage

function TraitVisualRobuxBarrage.new(ctx)
	return (setmetatable({
		_ctx = ctx,
		_models = {},
		_pool = {}
	}, TraitVisualRobuxBarrage))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setParticles(folder, enabled)
	for _, emitter in folder:GetDescendants() do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		emitter.Enabled = enabled

		if not enabled then
			emitter:Clear()
		end
	end
end

function TraitVisualRobuxBarrage:_baseScale()
	local _ctx = self._ctx
	return _ctx.robuxTemplateBundle.model:GetScale() * _ctx.arenaScale
end

function TraitVisualRobuxBarrage:update(data)
	local _ctx = self._ctx
	local _ = self._ctx.config.traits.RobuxBarrage
	local robuxBarrage = data.traits and data.traits.RobuxBarrage

	if not robuxBarrage then
		return
	end

	local v = self._models[data.id] or {}
	local v2 = self._pool[data.id] or {}
	local _models = self._models
	local id = data.id
	local _pool = self._pool
	local id2 = data.id
	_models[id] = v
	_pool[id2] = v2
	local v3 = {}

	for _, projectile in robuxBarrage.projectiles do
		v3[projectile.projectileId] = true
	end

	for k, v4 in v do
		if v3[k] then
			continue
		end

		setParticles(v4, false)
		v4:ScaleTo(self:_baseScale())
		_ctx.setTemplateModelVisibility(v4, false)
		v4.Parent = nil
		v[k] = nil
		table.insert(v2, v4)
	end

	for _, projectile in robuxBarrage.projectiles do
		local v4 = v[projectile.projectileId]
		local flag

		if v4 then
			flag = false
		else
			v4 = table.remove(v2) or _ctx.cloneTemplateModel(_ctx.robuxTemplateBundle, "Robux_" .. data.id)
			v4.Name = "Robux_" .. data.id .. "_" .. projectile.projectileId
			v4:SetAttribute("BattleOwnerSlotId", data.team or data.id)
			v[projectile.projectileId] = v4
			flag = true
		end

		local _baseScale = self:_baseScale()

		if math.abs(v4:GetScale() - _baseScale) > 1e-6 then
			v4:ScaleTo(_baseScale)
		end

		local worldFromArena = _ctx.worldFromArena(projectile.position)
		v4:PivotTo(CFrame.lookAt(
			worldFromArena,
			worldFromArena + _ctx.arenaCFrame.LookVector,
			_ctx.arenaCFrame.UpVector
		) * _ctx.robuxTemplateBundle.forwardOffset:Inverse())

		if not flag then
			continue
		end

		v4.Parent = _ctx.rootFolder
		_ctx.setTemplateModelVisibility(v4, true)
		setParticles(v4, true) -- equivalent call inferred; original call site unknown
	end
end

function TraitVisualRobuxBarrage:cleanupBall(p2)
	for _, v in self._models[p2] or {} do
		v:Destroy()
	end

	for _, v in self._pool[p2] or {} do
		v:Destroy()
	end

	local _models = self._models
	local _pool = self._pool
	_models[p2] = nil
	_pool[p2] = nil
end

function TraitVisualRobuxBarrage:reset()
	local v = {}

	for k in self._models do
		table.insert(v, k)
	end

	for _, v2 in v do
		self:cleanupBall(v2)
	end
end

return TraitVisualRobuxBarrage