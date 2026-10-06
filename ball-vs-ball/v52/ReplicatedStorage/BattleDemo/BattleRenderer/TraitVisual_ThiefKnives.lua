local TraitVisualThiefKnives = {}
TraitVisualThiefKnives.__index = TraitVisualThiefKnives

function TraitVisualThiefKnives.new(ctx)
	local self = setmetatable({}, TraitVisualThiefKnives)
	self._ctx = ctx
	self.heldKnifeModels = {}
	self.projectileModels = {}
	self.chargeModels = {}
	return self
end

function TraitVisualThiefKnives:_updateChargeEffect(p2, p3)
	local _ctx = self._ctx
	local v

	if p3 == nil then
		v = false
	else
		v = p3.phase == "Charging"
	end

	local chargeModel = self.chargeModels[p2.id]

	if v then
		local ballPart = _ctx.getBallPart(p2.id)

		if not ballPart then
			return
		end

		local attachment = ballPart:FindFirstChild("朝向标记")
		assert(attachment and attachment:IsA("Attachment"), string.format("小球 '%s' 的碰撞箱缺少朝向标记", p2.id))

		if not chargeModel then
			chargeModel = _ctx.cloneTemplateModel(
				_ctx.thiefChargeTemplateBundle,
				string.format("ThiefCharge_%s", p2.id)
			)
			chargeModel.Parent = _ctx.rootFolder
			self.chargeModels[p2.id] = chargeModel
		end

		chargeModel:PivotTo(attachment.WorldCFrame * _ctx.thiefChargeTemplateBundle.markerOffset:Inverse())
	elseif chargeModel then
		chargeModel:Destroy()
		self.chargeModels[p2.id] = nil
	end
end

function TraitVisualThiefKnives:_placeKnife(instance, point: Vector2, point2: Vector2)
	local _ctx = self._ctx
	local worldFromArena = _ctx.worldFromArena(point)
	local worldFromArena2 = _ctx.worldFromArena(point - point2)
	instance:PivotTo(CFrame.lookAt(worldFromArena, worldFromArena2, _ctx.arenaCFrame.LookVector) * CFrame.Angles(
		0,
		0,
		1.5707963267948966
	) * _ctx.thiefKnifeTemplateBundle.markerOffset:Inverse())
	_ctx.setTemplateModelVisibility(instance, true)
end

function TraitVisualThiefKnives:update(p)
	local _ctx = self._ctx
	local thiefKnives = p.traits.ThiefKnives
	local v = {}

	for _, v2 in not thiefKnives and {} or thiefKnives.heldKnives or {} do
		v[v2.index] = true
		local v3 = self.heldKnifeModels[p.id] or {}
		self.heldKnifeModels[p.id] = v3
		local v4 = v3[v2.index]

		if not v4 then
			v4 = _ctx.cloneTemplateModel(
				_ctx.thiefKnifeTemplateBundle,
				string.format("ThiefHeldKnife_%s_%d", p.id, v2.index)
			)
			v4.Parent = _ctx.rootFolder
			v3[v2.index] = v4
		end

		self:_placeKnife(v4, v2.position, v2.direction)
	end

	for k, v2 in self.heldKnifeModels[p.id] or {} do
		if v[k] then
			continue
		end

		v2:Destroy()
		self.heldKnifeModels[p.id][k] = nil
	end

	local v2 = {}

	for _, v3 in not thiefKnives and {} or thiefKnives.projectiles or {} do
		v2[v3.projectileId] = true
		local v4 = self.projectileModels[p.id] or {}
		self.projectileModels[p.id] = v4
		local v5 = v4[v3.projectileId]

		if not v5 then
			v5 = _ctx.cloneTemplateModel(
				_ctx.thiefKnifeTemplateBundle,
				string.format("ThiefKnife_%s_%d", p.id, v3.projectileId)
			)
			v5.Parent = _ctx.rootFolder
			v4[v3.projectileId] = v5
		end

		self:_placeKnife(v5, v3.position, v3.direction)
	end

	for k, v3 in self.projectileModels[p.id] or {} do
		if v2[k] then
			continue
		end

		v3:Destroy()
		self.projectileModels[p.id][k] = nil
	end

	self:_updateChargeEffect(p, thiefKnives)
end

function TraitVisualThiefKnives:cleanupBall(p)
	for _, v in self.heldKnifeModels[p] or {} do
		v:Destroy()
	end

	for _, v in self.projectileModels[p] or {} do
		v:Destroy()
	end

	local chargeModel = self.chargeModels[p]

	if chargeModel then
		chargeModel:Destroy()
	end

	local heldKnifeModels = self.heldKnifeModels
	local projectileModels = self.projectileModels
	local chargeModels = self.chargeModels
	heldKnifeModels[p] = nil
	projectileModels[p] = nil
	chargeModels[p] = nil
end

function TraitVisualThiefKnives:reset()
	for k in self.heldKnifeModels do
		self:cleanupBall(k)
	end

	for k in self.projectileModels do
		self:cleanupBall(k)
	end

	for k in self.chargeModels do
		self:cleanupBall(k)
	end

	self.heldKnifeModels = {}
	self.projectileModels = {}
	self.chargeModels = {}
end

return TraitVisualThiefKnives