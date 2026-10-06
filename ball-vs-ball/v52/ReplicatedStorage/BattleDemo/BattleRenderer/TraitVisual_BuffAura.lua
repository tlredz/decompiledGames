local TraitVisualBuffAura = {}
TraitVisualBuffAura.__index = TraitVisualBuffAura

function TraitVisualBuffAura.new(ctx)
	local self = setmetatable({}, TraitVisualBuffAura)
	self._ctx = ctx
	self.attackModels = {}
	self.defenseModels = {}
	return self
end

function TraitVisualBuffAura:_syncRing(p2, p3, flag: boolean, p4, p5: string, p6)
	local v = p2[p3.id]

	if flag then
		if not p6 then
			return
		end

		if not v then
			v = self._ctx.cloneTemplateModel(p4, p3.id .. p5)
			p2[p3.id] = v
		end

		v:PivotTo(p6.WorldCFrame * p4.markerOffset:Inverse())
	elseif v then
		v:Destroy()
		p2[p3.id] = nil
	end
end

function TraitVisualBuffAura:update(data)
	local _ctx = self._ctx
	local attackBuffActive = data.attackBuffActive == true
	local defenseBuffActive = data.defenseBuffActive == true
	local v = nil

	if attackBuffActive or defenseBuffActive then
		local ballPart = _ctx.getBallPart(data.id)
		local attachment = ballPart and ballPart:FindFirstChild("朝向标记")

		if ballPart then
			assert(attachment and attachment:IsA("Attachment"), string.format("小球 '%s' 的碰撞箱缺少朝向标记", data.id))
			v = attachment
		end
	end

	self:_syncRing(self.attackModels, data, attackBuffActive, _ctx.attackTemplateBundle, "_AttackBuff", v)
	self:_syncRing(self.defenseModels, data, defenseBuffActive, _ctx.defenseTemplateBundle, "_DefenseBuff", v)
end

function TraitVisualBuffAura:cleanupBall(p2: string)
	local attackModel = self.attackModels[p2]

	if attackModel then
		attackModel:Destroy()
	end

	local defenseModel = self.defenseModels[p2]

	if defenseModel then
		defenseModel:Destroy()
	end

	local attackModels = self.attackModels
	local defenseModels = self.defenseModels
	attackModels[p2] = nil
	defenseModels[p2] = nil
end

function TraitVisualBuffAura:reset()
	for k in self.attackModels do
		self:cleanupBall(k)
	end

	for k in self.defenseModels do
		self:cleanupBall(k)
	end

	self.attackModels = {}
	self.defenseModels = {}
end

return TraitVisualBuffAura