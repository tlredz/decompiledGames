local TraitVisualNoCollisionCharge = {}
TraitVisualNoCollisionCharge.__index = TraitVisualNoCollisionCharge

function TraitVisualNoCollisionCharge.new(ctx)
	local self = setmetatable({}, TraitVisualNoCollisionCharge)
	self._ctx = ctx
	self.models = {}
	self.parts = {}
	return self
end

function TraitVisualNoCollisionCharge:update(data2)
	local templateBundle = self._ctx.templateBundle

	if not templateBundle then
		return
	end

	local v

	if data2.skill.trigger == "NoCollisionCharge" then
		v = (data2.chargeMultiplier or 0) > (data2.skill.baseMultiplier or 1)
	else
		v = false
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
			model, v2 = self._ctx.cloneTemplateModel(templateBundle, data2.id .. "_NoCollisionCharge")
			local models = self.models
			local id = data2.id
			local parts = self.parts
			local id2 = data2.id
			models[id] = model
			parts[id2] = v2
		end

		model:PivotTo(attachment.WorldCFrame * templateBundle.markerOffset:Inverse())
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

function TraitVisualNoCollisionCharge:cleanupBall(p2: string)
	local model = self.models[p2]

	if model then
		model:Destroy()
	end

	local models = self.models
	local parts = self.parts
	models[p2] = nil
	parts[p2] = nil
end

function TraitVisualNoCollisionCharge:reset()
	for k in self.models do
		self:cleanupBall(k)
	end
end

return TraitVisualNoCollisionCharge