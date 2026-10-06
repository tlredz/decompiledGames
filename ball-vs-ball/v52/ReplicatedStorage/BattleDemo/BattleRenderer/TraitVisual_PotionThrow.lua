local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local RenderMath = require(script.Parent.RenderMath)
local v = {
	Red = "potionRedFlyTemplateBundle",
	Green = "potionGreenFlyTemplateBundle",
	Blue = "potionBlueFlyTemplateBundle"
}
local unit = Vector2.new(1, 1).Unit
local v2 = {
	Red = "potionRedRegionTemplateBundle",
	Green = "potionGreenRegionTemplateBundle",
	Blue = "potionBlueRegionTemplateBundle"
}
local v3 = {
	Red = "potionRedImpactTemplateName",
	Green = "potionGreenImpactTemplateName",
	Blue = "potionBlueImpactTemplateName"
}
local TraitVisualPotionThrow = {}
TraitVisualPotionThrow.__index = TraitVisualPotionThrow

function TraitVisualPotionThrow.new(ctx)
	local self = setmetatable({}, TraitVisualPotionThrow)
	self._ctx = ctx
	self._tracked = {}
	return self
end

function TraitVisualPotionThrow:_track(p2: string)
	local v4 = self._tracked[p2]

	if not v4 then
		v4 = {
			throwModel = nil,
			throwModelType = nil,
			regionModels = {},
			fadingModels = {}
		}
		self._tracked[p2] = v4
	end

	return v4
end

function TraitVisualPotionThrow:_ensureThrowModel(p2: string, state, throwModelType: string)
	if state.throwModel and state.throwModelType == throwModelType then
		return state.throwModel
	end

	if state.throwModel then
		state.throwModel:Destroy()
		state.throwModel = nil
	end

	local _ctx = self._ctx
	local v4 = _ctx[v[throwModelType]]
	local templateModel = _ctx.cloneTemplateModel(v4, string.format("%s_PotionThrow_Fly", p2))
	state.throwModel = templateModel
	state.throwModelType = throwModelType
	return templateModel
end

function TraitVisualPotionThrow:_regionModel(p2: string, p3, p4: number, p5: string)
	local regionModel = p3.regionModels[p4]

	if regionModel then
		return regionModel, false
	end

	local _ctx = self._ctx
	local v4 = _ctx[v2[p5]]
	local templateModel = _ctx.cloneTemplateModel(v4, string.format("%s_PotionThrow_Region_%d", p2, p4))
	p3.regionModels[p4] = templateModel
	return templateModel, true
end

function TraitVisualPotionThrow:_impactTemplateName(p2: string)
	return self._ctx.config.visual[v3[p2]]
end

function TraitVisualPotionThrow:_fadeOutRegion(p, folder, duration: number)
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

function TraitVisualPotionThrow:update(data)
	local _ctx = self._ctx
	local potionThrow = _ctx.config.traits.PotionThrow
	local potionThrow2 = data.traits and data.traits.PotionThrow

	if not potionThrow2 then
		self:cleanupBall(data.id)
		return
	end

	local _track = self:_track(data.id)

	if potionThrow2.isWindingUp or potionThrow2.isFlying then
		local _ensureThrowModel = self:_ensureThrowModel(data.id, _track, potionThrow2.pendingType)

		if potionThrow2.isWindingUp then
			local worldFromArena = _ctx.worldFromArena(data.position)
			local arenaBallCFrame = _ctx.getArenaBallCFrame(worldFromArena)
			local v4 = math.sin(potionThrow2.windupElapsed * (potionThrow.windupWobbleFrequency or 0)) * math.rad(potionThrow.windupWobbleAmplitude or 0)
			local cframe = CFrame.fromAxisAngle(_ctx.arenaCFrame.LookVector, v4)
			local v5 = worldFromArena + cframe:VectorToWorldSpace(arenaBallCFrame.RightVector) * (data.radius + (potionThrow.holdOffset or 0))
			local v6 = _ctx[v[potionThrow2.pendingType]]
			local vectorToWorldSpace = cframe:VectorToWorldSpace(_ctx.arenaCFrame:VectorToWorldSpace((Vector3.new(
				unit.X,
				unit.Y,
				0
			))))
			_ensureThrowModel:PivotTo(RenderMath.resolveDirectionFacingCFrame(
				v5,
				v5 + vectorToWorldSpace,
				_ctx.arenaCFrame.LookVector,
				v6.forwardOffset
			) or CFrame.new(v5) * (arenaBallCFrame - arenaBallCFrame.Position))
		else
			local v4 = math.clamp(potionThrow2.flightElapsed / math.max(0.0001, potionThrow.flightDuration or 1), 0, 1)
			local flightStartPosition = potionThrow2.flightStartPosition
			local flightTargetPosition = potionThrow2.flightTargetPosition
			local v5 = flightTargetPosition - flightStartPosition
			local vector = v5.Magnitude > 0.0001 and Vector2.new(-v5.Unit.Y, v5.Unit.X) or Vector2.new(0, 1)
			local v6 = 4 * (potionThrow.flightArcHeight or 0) * v4 * (1 - v4)
			local v7 = flightStartPosition:Lerp(flightTargetPosition, v4) + vector * v6
			local v8 = math.rad((potionThrow.flightSpinSpeed or 0) * potionThrow2.flightElapsed)
			_ensureThrowModel:PivotTo(CFrame.new(_ctx.worldFromArena(v7)) * _ctx.effectArenaRotation * CFrame.Angles(
				v8,
				v8 * 0.6,
				0
			))
		end
	elseif _track.throwModel then
		_track.throwModel:Destroy()
		_track.throwModel = nil
		_track.throwModelType = nil
	end

	local v4 = {}

	for _, v5 in potionThrow2.potions or {} do
		v4[v5.potionId] = true
		local _regionModel, v6 = self:_regionModel(data.id, _track, v5.potionId, v5.potionType)
		_regionModel:PivotTo(CFrame.new(_ctx.worldFromArena(v5.position)) * _ctx.effectArenaRotation)

		if v6 then
			_ctx.playOneShotModelEffect(self:_impactTemplateName(v5.potionType), v5.position)
		end
	end

	for k, regionModel in _track.regionModels do
		if v4[k] then
			continue
		end

		self:_fadeOutRegion(_track, regionModel, potionThrow.regionResidueLifetime or 2)
		_track.regionModels[k] = nil
	end
end

function TraitVisualPotionThrow:cleanupBall(p2: string)
	local v4 = self._tracked[p2]

	if not v4 then
		return
	end

	if v4.throwModel then
		v4.throwModel:Destroy()
	end

	for _, regionModel in v4.regionModels do
		regionModel:Destroy()
	end

	for _, fadingModel in v4.fadingModels do
		if fadingModel.Parent then
			fadingModel:Destroy()
		end
	end

	self._tracked[p2] = nil
end

function TraitVisualPotionThrow:reset()
	for k in self._tracked do
		self:cleanupBall(k)
	end
end

return TraitVisualPotionThrow