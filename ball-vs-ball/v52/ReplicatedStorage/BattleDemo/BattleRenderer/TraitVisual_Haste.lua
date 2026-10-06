local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EffectPlayer = require(ReplicatedStorage:WaitForChild("Engine"):WaitForChild("Service"):WaitForChild("EffectPlayer"))
local TraitVisualHaste = {}
TraitVisualHaste.__index = TraitVisualHaste

function TraitVisualHaste.new(ctx)
	local self = setmetatable({}, TraitVisualHaste)
	self._ctx = ctx
	self.models = {}
	self.parts = {}
	return self
end

function TraitVisualHaste:_destroy(p2: string)
	local model = self.models[p2]

	if model then
		model:Destroy()
	end

	local models = self.models
	local parts = self.parts
	models[p2] = nil
	parts[p2] = nil
end

function TraitVisualHaste:update(data)
	local v

	if (data.hasteRemaining or 0) > 0 then
		v = data.hastenedByTraitId == "AppleThrow"
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
		model, v2 = self._ctx.cloneTemplateModel(self._ctx.templateBundle, data.id .. "_Haste")
		local models = self.models
		local id = data.id
		local parts = self.parts
		local id2 = data.id
		models[id] = model
		parts[id2] = v2
		EffectPlayer.playEmbeddedSounds(model)
	end

	model:PivotTo(attachment.WorldCFrame * self._ctx.templateBundle.markerOffset:Inverse())
end

function TraitVisualHaste:cleanupBall(p: string)
	self:_destroy(p)
end

function TraitVisualHaste:reset()
	for k in self.models do
		self:_destroy(k)
	end
end

return TraitVisualHaste