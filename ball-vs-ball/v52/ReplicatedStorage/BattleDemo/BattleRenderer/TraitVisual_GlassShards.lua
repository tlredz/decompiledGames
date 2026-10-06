local TraitVisualGlassShards = {}
TraitVisualGlassShards.__index = TraitVisualGlassShards

function TraitVisualGlassShards.new(ctx)
	local object = setmetatable({}, TraitVisualGlassShards)
	object._ctx = ctx
	object.glassShardModels = {}
	object.glassShardParts = {}
	object.glassShardDebugCounts = {}
	object.glassShardDebugEnabled = ctx.debugEnabled
	object.glassShardTemplateBundle = ctx.glassShardTemplateBundle
	return object
end

function TraitVisualGlassShards:update(p, _: number?)
	local _ctx = self._ctx
	local glassShards = p.traits and p.traits.GlassShards
	local shards = glassShards and glassShards.shards or {}
	local v = self.glassShardModels[p.id] or {}

	if self.glassShardDebugEnabled then
		local count = #shards

		if self.glassShardDebugCounts[p.id] ~= count then
			self.glassShardDebugCounts[p.id] = count
		end
	end

	local v2 = self.glassShardParts[p.id] or {}
	local glassShardModels = self.glassShardModels
	local id = p.id
	local glassShardParts = self.glassShardParts
	local id2 = p.id
	glassShardModels[id] = v
	glassShardParts[id2] = v2
	local v3 = {}

	for _, shard in shards do
		v3[shard.shardId] = true
		local v4 = v[shard.shardId]
		local v5 = v2[shard.shardId]

		if not (v4 and v5) then
			local v6
			v4, v6 = _ctx.cloneTemplateModel(
				self.glassShardTemplateBundle,
				string.format("%s_GlassShard_%d", p.id, shard.shardId)
			)
			v4.Parent = _ctx.rootFolder
			local shardId = shard.shardId
			local shardId2 = shard.shardId
			v[shardId] = v4
			v2[shardId2] = v6
		end

		local worldFromArena = _ctx.worldFromArena(shard.position)
		v4:PivotTo(CFrame.new(worldFromArena) * _ctx.effectArenaRotation * CFrame.Angles(
			math.rad(shard.rotationX or 0),
			math.rad(shard.rotationY or 0),
			0
		) * self.glassShardTemplateBundle.markerOffset:Inverse())
		_ctx.setTemplateModelVisibility(v4, true)
	end

	for k, v4 in v do
		if v3[k] then
			continue
		end

		v4:Destroy()
		v[k] = nil
		v2[k] = nil
	end
end

function TraitVisualGlassShards:cleanupBall(p: string)
	for _, v in self.glassShardModels[p] or {} do
		v:Destroy()
	end

	local glassShardModels = self.glassShardModels
	local glassShardParts = self.glassShardParts
	glassShardModels[p] = nil
	glassShardParts[p] = nil
	self.glassShardDebugCounts[p] = nil
end

function TraitVisualGlassShards:reset()
	for k in self.glassShardModels do
		self:cleanupBall(k)
	end

	self.glassShardDebugCounts = {}
end

return TraitVisualGlassShards