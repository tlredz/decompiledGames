local TraitVisualSpeedEffect = {}
TraitVisualSpeedEffect.__index = TraitVisualSpeedEffect

function TraitVisualSpeedEffect.new(ctx)
	local self = setmetatable({}, TraitVisualSpeedEffect)
	self._ctx = ctx
	self.models = {}
	self.parts = {}
	return self
end

function TraitVisualSpeedEffect:_isActive(p)
	local sprintStart = p.traits and p.traits.SprintStart

	if sprintStart and sprintStart.active then
		return true
	end

	for _, v in { "BounceAccel", "BallHitAccel" } do
		local v2 = p.traits and p.traits[v]

		if v2 and (v2.boostRemaining or 0) > 0 then
			return true
		end
	end

	return false
end

function TraitVisualSpeedEffect:update(p)
	local _isActive = self:_isActive(p)
	local model = self.models[p.id]

	if _isActive then
		local ballPart = self._ctx.getBallPart(p.id)

		if not ballPart then
			return
		end

		local attachment = ballPart:FindFirstChild("朝向标记")
		assert(attachment and attachment:IsA("Attachment"), string.format("小球 '%s' 的碰撞箱缺少朝向标记", p.id))
		local part = self.parts[p.id]

		if not (model and part) then
			local v
			model, v = self._ctx.cloneTemplateModel(self._ctx.templateBundle, p.id .. "_SpeedEffect")
			local models = self.models
			local id = p.id
			local parts = self.parts
			local id2 = p.id
			models[id] = model
			parts[id2] = v
		end

		model:PivotTo(attachment.WorldCFrame * self._ctx.templateBundle.markerOffset:Inverse())
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

function TraitVisualSpeedEffect:cleanupBall(p2: string)
	local model = self.models[p2]

	if model then
		model:Destroy()
	end

	local models = self.models
	local parts = self.parts
	models[p2] = nil
	parts[p2] = nil
end

function TraitVisualSpeedEffect:reset()
	for k in self.models do
		self:cleanupBall(k)
	end
end

return TraitVisualSpeedEffect