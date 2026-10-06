local TraitVisualElectromagneticParalysis = {}
TraitVisualElectromagneticParalysis.__index = TraitVisualElectromagneticParalysis

function TraitVisualElectromagneticParalysis.new(ctx)
	local self = setmetatable({}, TraitVisualElectromagneticParalysis)
	self._ctx = ctx
	self.progress1Models = {}
	self.progress1Parts = {}
	self.progress2Models = {}
	self.progress2Parts = {}
	self.paralyzedModels = {}
	self.paralyzedParts = {}
	return self
end

function TraitVisualElectromagneticParalysis:_destroyProgress1(p2: string)
	local progress1Model = self.progress1Models[p2]

	if progress1Model then
		progress1Model:Destroy()
	end

	local progress1Models = self.progress1Models
	local progress1Parts = self.progress1Parts
	progress1Models[p2] = nil
	progress1Parts[p2] = nil
end

function TraitVisualElectromagneticParalysis:_destroyProgress2(p2: string)
	local progress2Model = self.progress2Models[p2]

	if progress2Model then
		progress2Model:Destroy()
	end

	local progress2Models = self.progress2Models
	local progress2Parts = self.progress2Parts
	progress2Models[p2] = nil
	progress2Parts[p2] = nil
end

function TraitVisualElectromagneticParalysis:_destroyParalyzed(p2: string)
	local paralyzedModel = self.paralyzedModels[p2]

	if paralyzedModel then
		paralyzedModel:Destroy()
	end

	local paralyzedModels = self.paralyzedModels
	local paralyzedParts = self.paralyzedParts
	paralyzedModels[p2] = nil
	paralyzedParts[p2] = nil
end

function TraitVisualElectromagneticParalysis:_alignModel(p2, p3: string, p4, p5, p6: string)
	local ballPart = self._ctx.getBallPart(p3)

	if not ballPart then
		return
	end

	local attachment = ballPart:FindFirstChild("朝向标记")
	assert(attachment and attachment:IsA("Attachment"), string.format("小球 '%s' 的碰撞箱缺少朝向标记", p3))
	local v = p4[p3]
	local v2 = p5[p3]

	if not (v and v2) then
		local v3
		v, v3 = self._ctx.cloneTemplateModel(p2, p3 .. p6)
		p4[p3] = v
		p5[p3] = v3
	end

	v:PivotTo(self._ctx.getArenaBallCFrame(attachment.WorldPosition) * p2.markerOffset:Inverse())
end

function TraitVisualElectromagneticParalysis:update(data)
	local v

	if (data.slowRemaining or 0) > 0 then
		v = data.slowedByTraitId == "ElectromagneticParalysis"
	else
		v = false
	end

	local v2 = v and 0 or math.max(0, (math.floor(data.electromagneticParalysisProgress or 0)))

	if v then
		self:_destroyProgress1(data.id)
		self:_destroyProgress2(data.id)
		self:_alignModel(
			self._ctx.paralyzedTemplateBundle,
			data.id,
			self.paralyzedModels,
			self.paralyzedParts,
			"_ElectromagneticParalyzed"
		)
	else
		self:_destroyParalyzed(data.id)

		if v2 >= 1 then
			self:_alignModel(
				self._ctx.progress1TemplateBundle,
				data.id,
				self.progress1Models,
				self.progress1Parts,
				"_ElectromagneticProgress1"
			)
		else
			self:_destroyProgress1(data.id)
		end

		if v2 >= 2 then
			self:_alignModel(
				self._ctx.progress2TemplateBundle,
				data.id,
				self.progress2Models,
				self.progress2Parts,
				"_ElectromagneticProgress2"
			)
		else
			self:_destroyProgress2(data.id)
		end
	end
end

function TraitVisualElectromagneticParalysis.getParalyzedModel(p, p2: string)
	return p.paralyzedModels[p2]
end

function TraitVisualElectromagneticParalysis:cleanupBall(p: string)
	self:_destroyProgress1(p)
	self:_destroyProgress2(p)
	self:_destroyParalyzed(p)
end

function TraitVisualElectromagneticParalysis:reset()
	for k in self.progress1Models do
		self:_destroyProgress1(k)
	end

	for k in self.progress2Models do
		self:_destroyProgress2(k)
	end

	for k in self.paralyzedModels do
		self:_destroyParalyzed(k)
	end
end

return TraitVisualElectromagneticParalysis