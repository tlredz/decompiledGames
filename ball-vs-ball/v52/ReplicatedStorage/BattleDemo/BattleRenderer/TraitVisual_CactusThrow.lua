local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local RenderMath = require(script.Parent.RenderMath)
local TraitVisualCactusThrow = {}
TraitVisualCactusThrow.__index = TraitVisualCactusThrow

function TraitVisualCactusThrow.new(ctx)
	local self = setmetatable({}, TraitVisualCactusThrow)
	self._ctx = ctx
	self._tracked = {}
	return self
end

function TraitVisualCactusThrow:_track(p2: string)
	local v = self._tracked[p2]

	if not v then
		v = {
			flyingModels = {},
			cactusModels = {},
			fadingModels = {}
		}
		self._tracked[p2] = v
	end

	return v
end

function TraitVisualCactusThrow:_cactusCFrame(point: Vector2)
	local _ctx = self._ctx
	return RenderMath.getArenaBallCFrame(_ctx.arenaCFrame, _ctx.worldFromArena(point)) * _ctx.cactusTemplateBundle.forwardOffset:Inverse()
end

function TraitVisualCactusThrow:_fadeOutCactus(p, folder, duration: number)
	local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	for _, descendant in folder:GetDescendants() do
		if descendant:IsA("ParticleEmitter") then
			descendant.Enabled = false
		elseif descendant:IsA("BasePart") then
			local originalTransparency = descendant:GetAttribute("OriginalTransparency")
			descendant.Transparency = typeof(originalTransparency) == "number" and originalTransparency or descendant.Transparency
			TweenService:Create(descendant, tweenInfo, {
				Transparency = 1
			}):Play()
		end
	end

	table.insert(p.fadingModels, folder)
	Debris:AddItem(folder, duration)
end

function TraitVisualCactusThrow:_clearFlyingModels(p)
	for _, flyingModel in p.flyingModels do
		flyingModel.model:Destroy()
	end

	p.flyingModels = {}
end

function TraitVisualCactusThrow:update(data)
	local _ctx = self._ctx
	local cactusThrow = _ctx.config.traits.CactusThrow
	local cactusThrow2 = data.traits and data.traits.CactusThrow

	if not cactusThrow2 then
		self:cleanupBall(data.id)
		return
	end

	local _track = self:_track(data.id)
	local cactusThrowEffectTemplateName = _ctx.config.visual.cactusThrowEffectTemplateName

	if cactusThrow2.isFlying and cactusThrow2.pendingTargets and cactusThrow2.flightStartPosition then
		if #_track.flyingModels == 0 then
			for k, pendingTarget in cactusThrow2.pendingTargets do
				local templateModel = _ctx.cloneTemplateModel(
					_ctx.cactusTemplateBundle,
					string.format("%s_CactusThrow_Fly_%d", data.id, k)
				)
				table.insert(_track.flyingModels, {
					model = templateModel,
					target = pendingTarget
				})
			end

			_ctx.playOneShotModelEffect(cactusThrowEffectTemplateName, data.position, nil, data.id)
		end

		local v = math.clamp(cactusThrow2.flightElapsed / math.max(0.0001, cactusThrow.flightDuration or 1), 0, 1)
		local flightStartPosition = cactusThrow2.flightStartPosition
		local v2 = 4 * (cactusThrow.flightArcHeight or 0) * v * (1 - v)

		for _, flyingModel in _track.flyingModels do
			local v3 = flyingModel.target - flightStartPosition
			local vector = v3.Magnitude > 0.0001 and Vector2.new(-v3.Unit.Y, v3.Unit.X) or Vector2.new(0, 1)
			flyingModel.model:PivotTo(self:_cactusCFrame(flightStartPosition:Lerp(flyingModel.target, v) + vector * v2))
		end
	elseif #_track.flyingModels > 0 then
		self:_clearFlyingModels(_track)
	end

	local v = {}

	for _, v2 in cactusThrow2.cacti or {} do
		v[v2.cactusId] = true

		if _track.cactusModels[v2.cactusId] then
			continue
		end

		local templateModel = _ctx.cloneTemplateModel(
			_ctx.cactusTemplateBundle,
			string.format("%s_CactusThrow_Cactus_%d", data.id, v2.cactusId)
		)
		templateModel:PivotTo(self:_cactusCFrame(v2.position))
		_track.cactusModels[v2.cactusId] = templateModel
		_ctx.playOneShotModelEffect(cactusThrowEffectTemplateName, v2.position)
	end

	for k, cactusModel in _track.cactusModels do
		if v[k] then
			continue
		end

		self:_fadeOutCactus(_track, cactusModel, cactusThrow.regionResidueLifetime or 1.5)
		_track.cactusModels[k] = nil
	end
end

function TraitVisualCactusThrow:cleanupBall(p: string)
	local v = self._tracked[p]

	if not v then
		return
	end

	self:_clearFlyingModels(v)

	for _, cactusModel in v.cactusModels do
		cactusModel:Destroy()
	end

	for _, fadingModel in v.fadingModels do
		if fadingModel.Parent then
			fadingModel:Destroy()
		end
	end

	self._tracked[p] = nil
end

function TraitVisualCactusThrow:reset()
	for k in self._tracked do
		self:cleanupBall(k)
	end
end

return TraitVisualCactusThrow