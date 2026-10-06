local TraitVisualIceConeTrail = {}
TraitVisualIceConeTrail.__index = TraitVisualIceConeTrail

function TraitVisualIceConeTrail.new(ctx)
	local self = setmetatable({}, TraitVisualIceConeTrail)
	self._ctx = ctx
	self.bombParts = {}
	self.coneModels = {}
	return self
end

local function setSubtreeVisible(part, flag: boolean)
	-- equivalent calls inferred from this helper; original call sites unknown
	local function setPart(part2)
		part2.Transparency = not flag and 1 or part2:GetAttribute("OriginalTransparency") or 0
	end

	if part:IsA("BasePart") then
		setPart(part) -- equivalent call inferred; original call site unknown
	end

	for _, part2 in part:GetDescendants() do
		if not part2:IsA("BasePart") then
			continue
		end

		setPart(part2) -- equivalent call inferred; original call site unknown
	end
end

function TraitVisualIceConeTrail:_bombPart(p2, p3)
	local clones = self.bombParts[p2] or {}
	self.bombParts[p2] = clones
	local clone = clones[p3]

	if clone then
		return clone
	end

	clone = self._ctx.bombTemplate:Clone()
	clone.Name = string.format("IceConeBomb_%s_%d", p2, p3)
	clone.Anchored = true
	clone.CanCollide = false
	clone.CanQuery = false
	clone.CanTouch = false
	clone.Parent = self._ctx.rootFolder
	clones[p3] = clone
	return clone
end

function TraitVisualIceConeTrail:update(p)
	local _ctx = self._ctx
	local iceConeTrail = p.traits.IceConeTrail
	local v = {}
	local v2 = {}

	for _, v3 in not iceConeTrail and {} or iceConeTrail.bombs or {} do
		v[v3.bombId] = true
		local _bombPart = self:_bombPart(p.id, v3.bombId)
		_bombPart.CFrame = CFrame.new(_ctx.worldFromArena(v3.position, 0.32)) * _ctx.effectArenaRotation * _ctx.bombTemplate.CFrame.Rotation
	end

	for k, v3 in self.bombParts[p.id] or {} do
		if v[k] then
			continue
		end

		v3:Destroy()
		self.bombParts[p.id][k] = nil
	end

	for _, v3 in iceConeTrail and iceConeTrail.iceCones or {} do
		v2[v3.projectileId] = true
		local foldersByProjectileId = self.coneModels[p.id] or {}
		self.coneModels[p.id] = foldersByProjectileId
		local folder = foldersByProjectileId[v3.projectileId]

		if not folder then
			folder = _ctx.cloneTemplateModel(
				_ctx.iceConeTemplateBundle,
				string.format("IceConeProjectile_%s_%d", p.id, v3.projectileId)
			)
			folder.Parent = _ctx.rootFolder
			foldersByProjectileId[v3.projectileId] = folder
		end

		local worldFromArena = _ctx.worldFromArena(v3.position)
		local worldFromArena2 = _ctx.worldFromArena(v3.position + v3.direction)
		folder:PivotTo(CFrame.lookAt(worldFromArena, worldFromArena2) * _ctx.iceConeTemplateBundle.markerOffset:Inverse())
		_ctx.setTemplateModelVisibility(folder, true)
		local folder2 = folder:FindFirstChild("装饰")
		assert(folder2 and folder2:IsA("Folder"), "冰锥模板缺少 Folder：装饰")
		setSubtreeVisible(folder2, false)
		local iceConeMaxDistance = _ctx.config.traits.IceConeTrail.iceConeMaxDistance or 8
		local v4 = math.clamp((v3.distanceTravelled or 0) / math.max(iceConeMaxDistance, 1e-6), 0, 1)

		for _, part in folder:GetDescendants() do
			if not part:IsA("BasePart") or part:IsDescendantOf(folder2) then
				continue
			end

			part.Transparency = math.clamp(
				(part:GetAttribute("OriginalTransparency") or 0) + v4 * (1 - (part:GetAttribute("OriginalTransparency") or 0)),
				0,
				1
			)
		end
	end

	for k, v3 in self.coneModels[p.id] or {} do
		if v2[k] then
			continue
		end

		v3:Destroy()
		self.coneModels[p.id][k] = nil
	end
end

function TraitVisualIceConeTrail:cleanupBall(p2)
	for _, v in self.bombParts[p2] or {} do
		v:Destroy()
	end

	for _, v in self.coneModels[p2] or {} do
		v:Destroy()
	end

	local bombParts = self.bombParts
	local coneModels = self.coneModels
	bombParts[p2] = nil
	coneModels[p2] = nil
end

function TraitVisualIceConeTrail:reset()
	for k in self.bombParts do
		self:cleanupBall(k)
	end

	for k in self.coneModels do
		self:cleanupBall(k)
	end

	self.bombParts = {}
	self.coneModels = {}
end

return TraitVisualIceConeTrail