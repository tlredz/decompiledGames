local TraitVisualStrongParalysis = {}
TraitVisualStrongParalysis.__index = TraitVisualStrongParalysis

function TraitVisualStrongParalysis.new(ctx)
	local self = setmetatable({}, TraitVisualStrongParalysis)
	self._ctx = ctx
	self.models = {}
	self.parts = {}
	return self
end

function TraitVisualStrongParalysis:_destroy(p2: string)
	local model = self.models[p2]

	if model then
		model:Destroy()
	end

	local models = self.models
	local parts = self.parts
	models[p2] = nil
	parts[p2] = nil
end

function TraitVisualStrongParalysis:update(data)
	local v

	if (data.slowRemaining or 0) > 0 then
		v = data.slowedByTraitId == "StrongParalysis"
	else
		v = false
	end

	if not v then
		self:_destroy(data.id)
		return
	end

	local ballPart = self._ctx.getBallPart(data.id)

	if not ballPart then
		return
	end

	local attachment = ballPart:FindFirstChild("朝向标记")
	assert(attachment and attachment:IsA("Attachment"), string.format("小球 '%s' 的碰撞箱缺少朝向标记", data.id))
	local model = self.models[data.id]

	if not model then
		local v2
		model, v2 = self._ctx.cloneTemplateModel(self._ctx.templateBundle, data.id .. "_StrongParalysis")
		local models = self.models
		local id = data.id
		local parts = self.parts
		local id2 = data.id
		models[id] = model
		parts[id2] = v2
	end

	model:PivotTo(attachment.WorldCFrame * self._ctx.templateBundle.markerOffset:Inverse())
end

function TraitVisualStrongParalysis.getModel(p, p2: string)
	return p.models[p2]
end

function TraitVisualStrongParalysis:cleanupBall(p: string)
	self:_destroy(p)
end

function TraitVisualStrongParalysis:reset()
	for k in self.models do
		self:_destroy(k)
	end
end

return TraitVisualStrongParalysis