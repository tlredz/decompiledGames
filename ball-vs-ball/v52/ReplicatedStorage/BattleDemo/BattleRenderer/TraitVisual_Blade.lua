local function getMaxBladeCount(config)
	local v = 0

	for _, role in config.roles do
		if role.skill.trigger == "Passive" then
			v = math.max(v, role.skill.maxBladeCount)
		elseif role.skill.trigger == "PassiveSword" or role.skill.trigger == "PassiveAxe" then
			v = math.max(v, 1)
		end
	end

	return v
end

local TraitVisualBlade = {}
TraitVisualBlade.__index = TraitVisualBlade

function TraitVisualBlade.new(ctx)
	local object = setmetatable({}, TraitVisualBlade)
	object._ctx = ctx
	object.bladeModels = {}
	object.bladeParts = {}
	object.swordModels = {}
	object.swordParts = {}
	object.swordPivotOffset = {}
	object.axeModels = {}
	object.axeParts = {}
	object.axePivotOffset = {}
	object.maxBladeCount = getMaxBladeCount(ctx.config)

	for k, _ in ctx.config.slots do
		object:_ensurePool(k)
	end

	return object
end

function TraitVisualBlade:_ensurePool(p: string)
	if self.bladeModels[p] then
		return
	end

	local _ctx = self._ctx
	self.bladeModels[p] = {}
	self.bladeParts[p] = {}

	for i = 1, self.maxBladeCount do
		local templateModel, v = _ctx.cloneTemplateModel(_ctx.bladeTemplateBundle, string.format("%s_Blade_%d", p, i))
		self.bladeModels[p][i] = templateModel
		self.bladeParts[p][i] = v
		_ctx.setTemplateModelVisibility(templateModel, false)
	end

	self.swordModels[p] = {}
	self.swordParts[p] = {}
	local templateModel, v = _ctx.cloneTemplateModel(_ctx.swordTemplateBundle, string.format("%s_Sword_1", p))
	self.swordModels[p][1] = templateModel
	self.swordParts[p][1] = v
	_ctx.setTemplateModelVisibility(templateModel, false)
	self.swordPivotOffset[p] = _ctx.swordTemplateBundle.forwardOffset
	self.axeModels[p] = {}
	self.axeParts[p] = {}
	local templateModel2, v2 = _ctx.cloneTemplateModel(_ctx.axeTemplateBundle, string.format("%s_Axe_1", p))
	self.axeModels[p][1] = templateModel2
	self.axeParts[p][1] = v2
	_ctx.setTemplateModelVisibility(templateModel2, false)
	self.axePivotOffset[p] = _ctx.axeTemplateBundle.forwardOffset
end

function TraitVisualBlade:update(data)
	local _ctx = self._ctx
	local traits = data.traits

	if traits and (traits.Passive or traits.PassiveSword or traits.PassiveAxe) then
		self:_ensurePool(data.id)
	end

	local bladePart = self.bladeParts[data.id]
	local bladeModel = self.bladeModels[data.id]

	if not (bladePart and bladeModel) then
		return
	end

	local passive = data.traits.Passive
	local passiveSword = data.traits.PassiveSword
	local passiveAxe = data.traits.PassiveAxe
	local swordPart = self.swordParts[data.id]
	local swordModel = self.swordModels[data.id]
	local v = swordPart and swordPart[1]
	local v2 = swordModel and swordModel[1]

	if passiveSword and v and v2 then
		local passiveSword2 = _ctx.config.traits.PassiveSword
		local bladePosition = passiveSword.bladePositions[1]
		local worldFromArena = _ctx.worldFromArena(data.position)
		local v3 = bladePosition and _ctx.worldFromArena(bladePosition)

		if (not v3 and 0 or (v3 - worldFromArena).Magnitude or 0) < 0.05 then
			_ctx.setTemplateModelVisibility(v2, false)
		else
			local rotationSpeed = passiveSword.rotationSpeed or passiveSword2.startingRotationSpeed or 0
			local startingRotationSpeed = passiveSword2.startingRotationSpeed or rotationSpeed
			local v4 = math.max(startingRotationSpeed, passiveSword2.maxRotationSpeed or rotationSpeed)

			if startingRotationSpeed < v4 then
				math.clamp((rotationSpeed - startingRotationSpeed) / (v4 - startingRotationSpeed), 0, 1)
			end

			local cframe = self.swordPivotOffset[data.id] or CFrame.identity
			v2:PivotTo(CFrame.lookAt((worldFromArena + v3) * 0.5, v3, _ctx.arenaCFrame.LookVector) * cframe:Inverse())
			_ctx.setTemplateModelVisibility(v2, true)
		end
	elseif v2 then
		_ctx.setTemplateModelVisibility(v2, false)
	end

	local axePart = self.axeParts[data.id]
	local axeModel = self.axeModels[data.id]
	local v3 = axePart and axePart[1]
	local v4 = axeModel and axeModel[1]

	if passiveAxe and v3 and v4 then
		local bladePosition = passiveAxe.bladePositions[1]
		local worldFromArena = _ctx.worldFromArena(data.position)
		local v5 = bladePosition and _ctx.worldFromArena(bladePosition)

		if (not v5 and 0 or (v5 - worldFromArena).Magnitude or 0) < 0.05 then
			_ctx.setTemplateModelVisibility(v4, false)
		else
			local markerOffset = _ctx.axeTemplateBundle.markerOffset
			v4:PivotTo(CFrame.lookAt(worldFromArena, v5, _ctx.arenaCFrame.LookVector) * markerOffset:Inverse())
			_ctx.setTemplateModelVisibility(v4, true)
		end
	elseif v4 then
		_ctx.setTemplateModelVisibility(v4, false)
	end

	for k, _ in bladePart do
		local v5 = bladeModel[k]
		local v6 = passive and passive.bladePositions[k]

		if v5 and v6 then
			local worldFromArena = _ctx.worldFromArena(v6)
			local v7 = worldFromArena + (worldFromArena - _ctx.worldFromArena(data.position))
			local markerOffset = _ctx.bladeTemplateBundle.markerOffset
			v5:PivotTo(CFrame.lookAt(worldFromArena, v7, _ctx.arenaCFrame.LookVector) * CFrame.Angles(
				0,
				0,
				1.5707963267948966
			) * markerOffset:Inverse())
			_ctx.setTemplateModelVisibility(v5, true)
		elseif v5 then
			_ctx.setTemplateModelVisibility(v5, false)
		end
	end
end

function TraitVisualBlade:playHit(p2)
	local _ctx = self._ctx

	if not p2.position then
		return
	end

	local worldFromArena = _ctx.worldFromArena(p2.position, 2.1)
	_ctx.audio:playCue("bladeHit", worldFromArena)
end

function TraitVisualBlade:playGrowth(p2)
	local _ctx = self._ctx

	if not p2.ballId then
		return
	end

	local ballPart = _ctx.getBallPart(p2.ballId)

	if not ballPart then
		return
	end

	_ctx.audio:playCue("bladeGrowth", ballPart.Position)

	if _ctx.playOneShotModelEffect then
		_ctx.playOneShotModelEffect("刀片球获得特效", p2.position, nil, p2.ballId)
	end
end

function TraitVisualBlade:cleanupBall(p: string)
	local _ctx = self._ctx

	for _, v in self.bladeModels[p] or {} do
		_ctx.setTemplateModelVisibility(v, false)
	end

	for _, v in self.swordModels[p] or {} do
		_ctx.setTemplateModelVisibility(v, false)
	end

	for _, v in self.axeModels[p] or {} do
		_ctx.setTemplateModelVisibility(v, false)
	end
end

function TraitVisualBlade:reset()
	for k in self.bladeModels do
		self:cleanupBall(k)
	end
end

function TraitVisualBlade:destroy()
	self.bladeModels = {}
	self.bladeParts = {}
	self.swordModels = {}
	self.swordParts = {}
	self.swordPivotOffset = {}
	self.axeModels = {}
	self.axeParts = {}
	self.axePivotOffset = {}
end

return TraitVisualBlade