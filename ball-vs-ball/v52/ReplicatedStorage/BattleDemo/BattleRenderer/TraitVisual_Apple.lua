local TraitVisualApple = {}
TraitVisualApple.__index = TraitVisualApple

function TraitVisualApple.new(ctx)
	local self = setmetatable({}, TraitVisualApple)
	self._ctx = ctx
	self._models = {}
	self._subModels = {}
	return self
end

function TraitVisualApple:update(p)
	local _ctx = self._ctx
	local appleThrow = p.traits.AppleThrow

	if not appleThrow then
		return
	end

	self._models[p.id] = self._models[p.id] or {}
	self._subModels[p.id] = self._subModels[p.id] or {}
	local v = {}

	for _, v2 in appleThrow.apples or {} do
		v[v2.appleId] = true
		local v3 = self._models[p.id][v2.appleId]
		local v4 = self._subModels[p.id][v2.appleId]

		if not v3 then
			v3 = _ctx.cloneTemplateModel(_ctx.appleTemplateBundle, string.format("Apple_%s_%d", p.id, v2.appleId))
			v3.Parent = _ctx.rootFolder
			local firstChild = v3:FindFirstChild("装饰")
			v4 = {
				projectile = firstChild and firstChild:FindFirstChild("弹丸"),
				apple = firstChild and firstChild:FindFirstChild("苹果")
			}
			self._models[p.id][v2.appleId] = v3
			self._subModels[p.id][v2.appleId] = v4
		end

		local worldFromArena = _ctx.worldFromArena(v2.position)
		v3:PivotTo(_ctx.getArenaBallCFrame(worldFromArena))
		local v5 = v2.phase == "Flying"

		if v4.projectile then
			for _, part in ipairs(v4.projectile:GetDescendants()) do
				if part:IsA("BasePart") then
					part.Transparency = v5 and 0 or 1
				end
			end

			if v4.projectile:IsA("BasePart") then
				v4.projectile.Transparency = v5 and 0 or 1
			end
		end

		if not v4.apple then
			continue
		end

		for _, part in ipairs(v4.apple:GetDescendants()) do
			if part:IsA("BasePart") then
				part.Transparency = v5 and 1 or 0
			end
		end

		if v4.apple:IsA("BasePart") then
			v4.apple.Transparency = v5 and 1 or 0
		end
	end

	for k, v2 in self._models[p.id] do
		if v[k] then
			continue
		end

		v2:Destroy()
		self._models[p.id][k] = nil
		self._subModels[p.id][k] = nil
	end
end

function TraitVisualApple:cleanupBall(p2)
	for _, v in self._models[p2] or {} do
		v:Destroy()
	end

	self._models[p2] = nil
	self._subModels[p2] = nil
end

function TraitVisualApple:reset()
	local v = {}

	for k in self._models do
		table.insert(v, k)
	end

	for _, v2 in v do
		self:cleanupBall(v2)
	end
end

return TraitVisualApple