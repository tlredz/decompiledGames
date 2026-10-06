local TraitVisualExpandingAura = {}
TraitVisualExpandingAura.__index = TraitVisualExpandingAura

function TraitVisualExpandingAura.new(ctx)
	local self = setmetatable({}, TraitVisualExpandingAura)
	self._ctx = ctx
	self.models = {}
	self.parts = {}
	return self
end

function TraitVisualExpandingAura:update(p)
	local expandingAura = p.traits and p.traits.ExpandingAura
	local model = self.models[p.id]

	if expandingAura then
		local ballPart = self._ctx.getBallPart(p.id)

		if not ballPart then
			return
		end

		local attachment = ballPart:FindFirstChild("朝向标记")
		assert(attachment and attachment:IsA("Attachment"), string.format("小球 '%s' 的碰撞箱缺少朝向标记", p.id))
		local part = self.parts[p.id]

		if not (model and part) then
			model, part = self._ctx.cloneTemplateModel(self._ctx.templateBundle, p.id .. "_ExpandingAura")
			local models = self.models
			local id = p.id
			local parts = self.parts
			local id2 = p.id
			models[id] = model
			parts[id2] = part
		end

		local v = math.max(0.01, (expandingAura.currentRadius or 0) * 2)
		part.Size = Vector3.new(v, v, v)
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

function TraitVisualExpandingAura:cleanupBall(p2: string)
	local model = self.models[p2]

	if model then
		model:Destroy()
	end

	local models = self.models
	local parts = self.parts
	models[p2] = nil
	parts[p2] = nil
end

function TraitVisualExpandingAura:reset()
	for k in self.models do
		self:cleanupBall(k)
	end
end

return TraitVisualExpandingAura