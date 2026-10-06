local TraitVisualShield = {}
TraitVisualShield.__index = TraitVisualShield

function TraitVisualShield.new(ctx)
	local self = setmetatable({}, TraitVisualShield)
	self._ctx = ctx
	self.models = {}
	self.parts = {}
	return self
end

function TraitVisualShield:update(p)
	local shield = p.traits and p.traits.Shield
	local v = shield and (shield.remainingCharges or 0) > 0
	local model = self.models[p.id]

	if v then
		local ballPart = self._ctx.getBallPart(p.id)

		if not ballPart then
			return
		end

		local attachment = ballPart:FindFirstChild("朝向标记")
		assert(attachment and attachment:IsA("Attachment"), string.format("小球 '%s' 的碰撞箱缺少朝向标记", p.id))
		local part = self.parts[p.id]

		if not (model and part) then
			local v2
			model, v2 = self._ctx.cloneTemplateModel(self._ctx.templateBundle, p.id .. "_Shield")
			local models = self.models
			local id = p.id
			local parts = self.parts
			local id2 = p.id
			models[id] = model
			parts[id2] = v2
		end

		model:PivotTo(self._ctx.getArenaBallCFrame(attachment.WorldPosition) * self._ctx.templateBundle.markerOffset:Inverse())
	elseif model then
		model:Destroy()
		local models = self.models
		local id = p.id
		local parts = self.parts
		local id2 = p.id
		models[id] = nil
		parts[id2] = nil
	end
end

function TraitVisualShield:cleanupBall(p2: string)
	local model = self.models[p2]

	if model then
		model:Destroy()
	end

	local models = self.models
	local parts = self.parts
	models[p2] = nil
	parts[p2] = nil
end

function TraitVisualShield:reset()
	for k in self.models do
		self:cleanupBall(k)
	end
end

return TraitVisualShield