local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DuelAudioController = require(ReplicatedStorage:WaitForChild("Engine"):WaitForChild("Service"):WaitForChild("DuelAudioController"))
local TraitVisualFreezeEffect = {}
TraitVisualFreezeEffect.__index = TraitVisualFreezeEffect

function TraitVisualFreezeEffect.new(ctx)
	local self = setmetatable({}, TraitVisualFreezeEffect)
	self._ctx = ctx
	self.models = {}
	self.parts = {}
	return self
end

function TraitVisualFreezeEffect:_isActive(p)
	return (p.slowRemaining or 0) > 0 and (p.slowedByTraitId == "FreezeOnHit" or p.slowedByTraitId == "FrostTrail" or p.slowedByTraitId == "PotionThrow")
end

function TraitVisualFreezeEffect:update(p)
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
			model, v = self._ctx.cloneTemplateModel(self._ctx.templateBundle, p.id .. "_FreezeEffect")
			local models = self.models
			local id = p.id
			local parts = self.parts
			local id2 = p.id
			models[id] = model
			parts[id2] = v
			local sound = v:FindFirstChild("音效")

			if sound and sound:IsA("Sound") then
				sound.TimePosition = 0
				DuelAudioController.prepare(sound)
				sound:Play()
			end
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

function TraitVisualFreezeEffect:cleanupBall(p2: string)
	local model = self.models[p2]

	if model then
		model:Destroy()
	end

	local models = self.models
	local parts = self.parts
	models[p2] = nil
	parts[p2] = nil
end

function TraitVisualFreezeEffect:reset()
	for k in self.models do
		self:cleanupBall(k)
	end
end

return TraitVisualFreezeEffect