local TraitVisualGravity = {}
TraitVisualGravity.__index = TraitVisualGravity

function TraitVisualGravity.new(ctx)
	local self = setmetatable({}, TraitVisualGravity)
	self._ctx = ctx
	self.models = {}
	self.parts = {}
	return self
end

function TraitVisualGravity:update(p)
	local templateBundle = self._ctx.templateBundle

	if not templateBundle then
		return
	end

	local v = (p.traits and p.traits.Gravity) ~= nil
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
			model, v2 = self._ctx.cloneTemplateModel(templateBundle, p.id .. "_Gravity")
			local models = self.models
			local id = p.id
			local parts = self.parts
			local id2 = p.id
			models[id] = model
			parts[id2] = v2
		end

		model:PivotTo(attachment.WorldCFrame * templateBundle.markerOffset:Inverse())
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

function TraitVisualGravity:cleanupBall(p2: string)
	local model = self.models[p2]

	if model then
		model:Destroy()
	end

	local models = self.models
	local parts = self.parts
	models[p2] = nil
	parts[p2] = nil
end

function TraitVisualGravity:reset()
	for k in self.models do
		self:cleanupBall(k)
	end
end

return TraitVisualGravity