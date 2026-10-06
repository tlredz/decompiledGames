local TraitVisualCannonTurret = {}
TraitVisualCannonTurret.__index = TraitVisualCannonTurret

function TraitVisualCannonTurret.new(ctx)
	local self = setmetatable({}, TraitVisualCannonTurret)
	self._ctx = ctx
	self._turretModels = {}
	self._bulletModels = {}
	return self
end

function TraitVisualCannonTurret:update(p)
	local _ctx = self._ctx
	local cannonTurret = p.traits.CannonTurret

	if not cannonTurret then
		return
	end

	self._turretModels[p.id] = self._turretModels[p.id] or {}
	local v = {}

	for _, v2 in cannonTurret.turrets or {} do
		v[v2.turretId] = true
		local v3 = self._turretModels[p.id][v2.turretId]

		if not v3 then
			v3 = _ctx.cloneTemplateModel(
				_ctx.cannonTurretTemplateBundle,
				string.format("CannonTurret_%s_%d", p.id, v2.turretId)
			)
			v3.Parent = _ctx.rootFolder
			self._turretModels[p.id][v2.turretId] = v3
		end

		local worldFromArena = _ctx.worldFromArena(v2.position)
		local aimDirection = v2.aimDirection
		local worldFromArena2 = _ctx.worldFromArena(v2.position + aimDirection)

		if (worldFromArena2 - worldFromArena).Magnitude > 0.001 then
			v3:PivotTo(CFrame.lookAt(worldFromArena, worldFromArena2, _ctx.arenaCFrame.LookVector) * CFrame.Angles(
				0,
				0,
				1.5707963267948966
			) * _ctx.cannonTurretTemplateBundle.markerOffset:Inverse())
		end

		_ctx.setTemplateModelVisibility(v3, true)
	end

	for k, v2 in self._turretModels[p.id] or {} do
		if v[k] then
			continue
		end

		v2:Destroy()
		self._turretModels[p.id][k] = nil
	end

	self._bulletModels[p.id] = self._bulletModels[p.id] or {}
	local v2 = {}

	for _, v3 in cannonTurret.bullets or {} do
		v2[v3.bulletId] = true
		local v4 = self._bulletModels[p.id][v3.bulletId]

		if not v4 then
			v4 = _ctx.cloneTemplateModel(
				_ctx.cannonBulletTemplateBundle,
				string.format("CannonBullet_%s_%d", p.id, v3.bulletId)
			)
			v4.Parent = _ctx.rootFolder
			self._bulletModels[p.id][v3.bulletId] = v4
		end

		local worldFromArena = _ctx.worldFromArena(v3.position)
		local worldFromArena2 = _ctx.worldFromArena(v3.position + v3.direction)
		v4:PivotTo(CFrame.lookAt(worldFromArena, worldFromArena2) * _ctx.cannonBulletTemplateBundle.markerOffset:Inverse())
		_ctx.setTemplateModelVisibility(v4, true)
	end

	for k, v3 in self._bulletModels[p.id] or {} do
		if v2[k] then
			continue
		end

		v3:Destroy()
		self._bulletModels[p.id][k] = nil
	end
end

function TraitVisualCannonTurret:cleanupBall(p2)
	for _, v in self._turretModels[p2] or {} do
		v:Destroy()
	end

	for _, v in self._bulletModels[p2] or {} do
		v:Destroy()
	end

	self._turretModels[p2] = nil
	self._bulletModels[p2] = nil
end

function TraitVisualCannonTurret:reset()
	local v = {}

	for k in self._turretModels do
		table.insert(v, k)
	end

	for k in self._bulletModels do
		if not self._turretModels[k] then
			table.insert(v, k)
		end
	end

	for _, v2 in v do
		self:cleanupBall(v2)
	end
end

return TraitVisualCannonTurret