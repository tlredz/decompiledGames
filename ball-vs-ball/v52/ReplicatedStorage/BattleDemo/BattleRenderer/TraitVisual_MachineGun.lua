local TraitVisualMachineGun = {}
TraitVisualMachineGun.__index = TraitVisualMachineGun

function TraitVisualMachineGun.new(ctx)
	local self = setmetatable({}, TraitVisualMachineGun)
	self._ctx = ctx
	self.machineGunBulletModels = {}
	self.machineGunBulletParts = {}
	return self
end

function TraitVisualMachineGun:update(p)
	local _ctx = self._ctx
	local machineGun = p.traits.MachineGun
	local v = {}

	for _, v2 in machineGun and machineGun.bullets or {} do
		v[v2.bulletId] = true
		local v3 = self.machineGunBulletModels[p.id] or {}
		local v4 = self.machineGunBulletParts[p.id] or {}
		local machineGunBulletModels = self.machineGunBulletModels
		local id = p.id
		local machineGunBulletParts = self.machineGunBulletParts
		local id2 = p.id
		machineGunBulletModels[id] = v3
		machineGunBulletParts[id2] = v4
		local v5 = v3[v2.bulletId]
		local v6 = v4[v2.bulletId]

		if not (v5 and v6) then
			local v7
			v5, v7 = _ctx.cloneTemplateModel(
				_ctx.machineGunBulletTemplateBundle,
				string.format("MachineGunBullet_%s_%d", p.id, v2.bulletId)
			)
			v5.Parent = _ctx.rootFolder
			local bulletId = v2.bulletId
			local bulletId2 = v2.bulletId
			v3[bulletId] = v5
			v4[bulletId2] = v7
		end

		local worldFromArena = _ctx.worldFromArena(v2.position)
		local worldFromArena2 = _ctx.worldFromArena(v2.position + v2.direction)
		v5:PivotTo(CFrame.lookAt(worldFromArena, worldFromArena2) * _ctx.machineGunBulletTemplateBundle.markerOffset:Inverse())
		_ctx.setTemplateModelVisibility(v5, true)
	end

	for k, v2 in self.machineGunBulletModels[p.id] or {} do
		if v[k] then
			continue
		end

		v2:Destroy()
		self.machineGunBulletModels[p.id][k] = nil
		self.machineGunBulletParts[p.id][k] = nil
	end
end

function TraitVisualMachineGun.cleanupBall(p, p2)
	for k, v in p.machineGunBulletModels[p2] or {} do
		v:Destroy()
		p.machineGunBulletParts[p2][k] = nil
	end

	local machineGunBulletModels = p.machineGunBulletModels
	local machineGunBulletParts = p.machineGunBulletParts
	machineGunBulletModels[p2] = nil
	machineGunBulletParts[p2] = nil
end

return TraitVisualMachineGun