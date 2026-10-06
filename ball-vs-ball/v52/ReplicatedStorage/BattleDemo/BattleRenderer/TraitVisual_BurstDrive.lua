local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EffectPlayer = require(ReplicatedStorage:WaitForChild("Engine"):WaitForChild("Service"):WaitForChild("EffectPlayer"))
local TraitVisualBurstDrive = {}
TraitVisualBurstDrive.__index = TraitVisualBurstDrive

function TraitVisualBurstDrive.new(ctx)
	local self = setmetatable({}, TraitVisualBurstDrive)
	self._ctx = ctx
	self.models = {}
	self.parts = {}
	return self
end

function TraitVisualBurstDrive:update(data2)
	local v

	if data2.skill.trigger == "Interval" then
		v = (data2.speedBoostTimeRemaining or 0) > 0
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
			model, v2 = self._ctx.cloneTemplateModel(self._ctx.templateBundle, data2.id .. "_BurstDrive")
			local models = self.models
			local id = data2.id
			local parts = self.parts
			local id2 = data2.id
			models[id] = model
			parts[id2] = v2
			EffectPlayer.playEmbeddedSounds(model)
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

function TraitVisualBurstDrive:cleanupBall(p2: string)
	local model = self.models[p2]

	if model then
		model:Destroy()
	end

	local models = self.models
	local parts = self.parts
	models[p2] = nil
	parts[p2] = nil
end

function TraitVisualBurstDrive:reset()
	for k in self.models do
		self:cleanupBall(k)
	end
end

return TraitVisualBurstDrive