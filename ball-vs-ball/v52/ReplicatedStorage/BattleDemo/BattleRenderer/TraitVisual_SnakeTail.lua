local TraitVisualSnakeTail = {}
TraitVisualSnakeTail.__index = TraitVisualSnakeTail

function TraitVisualSnakeTail.new(ctx)
	local self = setmetatable({}, TraitVisualSnakeTail)
	self._ctx = ctx
	self.tailModels = {}
	return self
end

function TraitVisualSnakeTail:_placeSegment(p2, data)
	local _ctx = self._ctx
	local v = math.max(0.001, data.scale or 1)
	local worldFromArena = _ctx.worldFromArena(data.position)
	local worldFromArena2 = _ctx.worldFromArena(data.position + data.direction)
	p2.model:ScaleTo(v)
	p2.model:PivotTo(CFrame.lookAt(worldFromArena, worldFromArena2) * _ctx.snakeTailTemplateBundle.markerOffset:Inverse())
	_ctx.setTemplateModelVisibility(p2.model, true)
end

function TraitVisualSnakeTail:update(p)
	local snakeTail = p.traits.SnakeTail

	if not snakeTail then
		return
	end

	local v = self.tailModels[p.id] or {}
	self.tailModels[p.id] = v
	local v2 = {}

	for _, v3 in snakeTail.tailSegments or {} do
		v2[v3.tailId] = true
		local v4 = v[v3.tailId]

		if not v4 then
			local templateModel = self._ctx.cloneTemplateModel(
				self._ctx.snakeTailTemplateBundle,
				string.format("SnakeTail_%s_%d", p.id, v3.tailId)
			)
			templateModel.Parent = self._ctx.rootFolder
			v4 = {
				model = templateModel
			}
			v[v3.tailId] = v4
		end

		self:_placeSegment(v4, v3)
	end

	for k, v3 in v do
		if v2[k] then
			continue
		end

		v3.model:Destroy()
		v[k] = nil
	end
end

function TraitVisualSnakeTail:cleanupBall(p2)
	for _, v in self.tailModels[p2] or {} do
		v.model:Destroy()
	end

	self.tailModels[p2] = nil
end

function TraitVisualSnakeTail:reset()
	local v = {}

	for k in self.tailModels do
		table.insert(v, k)
	end

	for _, v2 in v do
		self:cleanupBall(v2)
	end

	self.tailModels = {}
end

return TraitVisualSnakeTail