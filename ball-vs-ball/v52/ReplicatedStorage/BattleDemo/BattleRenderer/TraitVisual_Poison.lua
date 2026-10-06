local TraitVisualPoison = {}
TraitVisualPoison.__index = TraitVisualPoison

function TraitVisualPoison.new(ctx)
	local self = setmetatable({}, TraitVisualPoison)
	self._ctx = ctx
	self.models = {}
	self.parts = {}
	return self
end

function TraitVisualPoison:update(data2)
	local v

	if (data2.poisonRemaining or 0) > 0 then
		v = true
	elseif data2.acidPoisonStacks == nil then
		v = false
	else
		v = #data2.acidPoisonStacks > 0
	end

	local model = self.models[data2.id]

	if v then
		local ballPart = self._ctx.getBallPart(data2.id)

		if not ballPart then
			return
		end

		local attachment = ballPart:FindFirstChild("朝向标记")
		assert(attachment and attachment:IsA("Attachment"), string.format("小球 '%s' 的碰撞箱缺少朝向标记", data2.id))
		local part = self.parts[data2.id]

		if not (model and part) then
			local v2
			model, v2 = self._ctx.cloneTemplateModel(self._ctx.templateBundle, data2.id .. "_Poison")
			local models = self.models
			local id = data2.id
			local parts = self.parts
			local id2 = data2.id
			models[id] = model
			parts[id2] = v2
		end

		model:PivotTo(attachment.WorldCFrame * self._ctx.templateBundle.markerOffset:Inverse())
	elseif model then
		model:Destroy()
		local models = self.models
		local id = data2.id
		local parts = self.parts
		local id2 = data2.id
		models[id] = nil
		parts[id2] = nil
	end
end

function TraitVisualPoison.getModel(p, p2: string)
	return p.models[p2]
end

function TraitVisualPoison:cleanupBall(p2: string)
	local model = self.models[p2]

	if model then
		model:Destroy()
	end

	local models = self.models
	local parts = self.parts
	models[p2] = nil
	parts[p2] = nil
end

function TraitVisualPoison:reset()
	for k in self.models do
		self:cleanupBall(k)
	end
end

return TraitVisualPoison