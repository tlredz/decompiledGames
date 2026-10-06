local TraitVisualHiveSwarm = {}
TraitVisualHiveSwarm.__index = TraitVisualHiveSwarm

function TraitVisualHiveSwarm.new(ctx)
	local self = setmetatable({}, TraitVisualHiveSwarm)
	self._ctx = ctx
	self._beeModels = {}
	return self
end

local function applyFade(folder, fadeAlpha: number)
	for _, part in ipairs(folder:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		local originalTransparency = part:GetAttribute("OriginalTransparency")

		if typeof(originalTransparency) ~= "number" then
			originalTransparency = part.Transparency
		end

		part.Transparency = originalTransparency + (1 - originalTransparency) * fadeAlpha
	end
end

function TraitVisualHiveSwarm:update(p2)
	local _ctx = self._ctx
	local hiveSwarm = p2.traits and p2.traits.HiveSwarm

	if not hiveSwarm then
		return
	end

	self._beeModels[p2.id] = self._beeModels[p2.id] or {}
	local _beeModel = self._beeModels[p2.id]
	local lookVector = _ctx.arenaCFrame.LookVector
	local hiveBeeTemplateBundle = _ctx.hiveBeeTemplateBundle
	local v = {}

	for _, v2 in hiveSwarm.bees or {} do
		v[v2.beeId] = true
		local v3 = _beeModel[v2.beeId]

		if not v3 then
			v3 = _ctx.cloneTemplateModel(_ctx.hiveBeeTemplateBundle, string.format("HiveBee_%s_%d", p2.id, v2.beeId))
			v3.Parent = _ctx.rootFolder
			_beeModel[v2.beeId] = v3
		end

		local worldFromArena = _ctx.worldFromArena(v2.position)
		local worldFromArena2 = _ctx.worldFromArena(v2.position + v2.direction)

		if (worldFromArena2 - worldFromArena).Magnitude > 0.001 then
			v3:PivotTo(CFrame.lookAt(worldFromArena, worldFromArena2, lookVector) * hiveBeeTemplateBundle.forwardOffset:Inverse())
		else
			v3:PivotTo(CFrame.new(worldFromArena) * v3:GetPivot().Rotation)
		end

		_ctx.setTemplateModelVisibility(v3, true)
		applyFade(v3, v2.fadeAlpha or 0)
	end

	for k, v2 in _beeModel do
		if v[k] then
			continue
		end

		v2:Destroy()
		_beeModel[k] = nil
	end
end

function TraitVisualHiveSwarm:cleanupBall(p2: string)
	for _, v in self._beeModels[p2] or {} do
		v:Destroy()
	end

	self._beeModels[p2] = nil
end

function TraitVisualHiveSwarm:reset()
	local v = {}

	for k in self._beeModels do
		table.insert(v, k)
	end

	for _, v2 in v do
		self:cleanupBall(v2)
	end
end

return TraitVisualHiveSwarm