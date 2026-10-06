local TraitVisualBurn = {}
TraitVisualBurn.__index = TraitVisualBurn
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")

function TraitVisualBurn.new(ctx)
	local self = setmetatable({}, TraitVisualBurn)
	self._ctx = ctx
	self.models = {}
	self.parts = {}
	self.lingeringModels = {}
	return self
end

function TraitVisualBurn:_releaseModel(p: string)
	local folder = self.models[p]
	local models = self.models
	local parts = self.parts
	models[p] = nil
	parts[p] = nil

	if not folder then
		return
	end

	local v = 0

	for _, descendant in ipairs(folder:GetDescendants()) do
		if descendant:IsA("ParticleEmitter") then
			descendant.Enabled = false
			v = math.max(v, descendant.Lifetime.Max)
		elseif descendant:IsA("Fire") or descendant:IsA("Smoke") or descendant:IsA("Sparkles") then
			descendant.Enabled = false
		end
	end

	if v <= 0 then
		folder:Destroy()
		return
	end

	self.lingeringModels[folder] = true
	local templateBundle = self._ctx.templateBundle
	local ballPart = self._ctx.getBallPart(p)
	local attachment = ballPart and ballPart:FindFirstChild("朝向标记")
	local heartbeatConnection = nil

	if attachment and attachment:IsA("Attachment") then
		heartbeatConnection = RunService.Heartbeat:Connect(function()
			if folder.Parent ~= nil and attachment.Parent ~= nil then
				folder:PivotTo(attachment.WorldCFrame * templateBundle.markerOffset:Inverse())
			elseif heartbeatConnection then
				heartbeatConnection:Disconnect()
			end
		end)
	end

	folder.Destroying:Once(function()
		self.lingeringModels[folder] = nil

		if heartbeatConnection then
			heartbeatConnection:Disconnect()
		end
	end)
	Debris:AddItem(folder, v)
end

function TraitVisualBurn:update(p)
	local templateBundle = self._ctx.templateBundle

	if not templateBundle then
		return
	end

	local v = (p.burnRemaining or 0) > 0
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
			model, v2 = self._ctx.cloneTemplateModel(templateBundle, p.id .. "_Burn")
			local models = self.models
			local id = p.id
			local parts = self.parts
			local id2 = p.id
			models[id] = model
			parts[id2] = v2
		end

		model:PivotTo(attachment.WorldCFrame * templateBundle.markerOffset:Inverse())
	elseif model then
		self:_releaseModel(p.id)
	end
end

function TraitVisualBurn.getModel(p, p2: string)
	return p.models[p2]
end

function TraitVisualBurn:cleanupBall(p: string)
	self:_releaseModel(p)
end

function TraitVisualBurn.reset(data)
	for _, model in data.models do
		model:Destroy()
	end

	table.clear(data.models)
	table.clear(data.parts)

	for k in data.lingeringModels do
		k:Destroy()
	end

	table.clear(data.lingeringModels)
end

return TraitVisualBurn