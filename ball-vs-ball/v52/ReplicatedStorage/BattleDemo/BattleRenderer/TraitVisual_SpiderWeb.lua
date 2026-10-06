local TraitVisualSpiderWeb = {}
TraitVisualSpiderWeb.__index = TraitVisualSpiderWeb

function TraitVisualSpiderWeb.new(ctx)
	local object = setmetatable({}, TraitVisualSpiderWeb)
	object._ctx = ctx
	object.config = ctx.config
	object.arenaScale = ctx.arenaScale
	object._audio = ctx.audio
	object._worldFromArena = ctx.worldFromArena
	object._getBallMarkerHeight = ctx.getBallMarkerHeight
	object._cloneTemplateModel = ctx.cloneTemplateModel
	object.spiderWebModels = {}
	object.spiderWebParts = {}
	object.spiderWebStates = {}
	object.spiderWebTemplateBundle = nil
	object._websField = ctx.websField or "spiderWebs"
	object._templateNameKey = ctx.templateNameKey or "spiderWebTemplateName"
	object._instanceTag = ctx.instanceTag or "SpiderWeb"
	local v = object.config.visual[object._templateNameKey]
	local v2

	if type(v) == "string" then
		v2 = v ~= ""
	else
		v2 = false
	end

	assert(v2, "BattleConfig.visual." .. object._templateNameKey .. " is missing")
	object.spiderWebTemplateBundle = ctx.getTemplateBundle(ctx.effectAssetRoot, v)
	return object
end

function TraitVisualSpiderWeb._cloneSpiderWebState(_, options)
	local result = {}

	for k, v in options or {} do
		result[k] = {
			anchorPosition = v.anchorPosition,
			startPosition = v.startPosition,
			endPosition = v.endPosition
		}
	end

	return result
end

function TraitVisualSpiderWeb:_setSpiderWebModelVisibility(folder, flag: boolean)
	for _, part in ipairs(folder:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		local originalTransparency = part:GetAttribute("OriginalTransparency")

		if flag then
			part.Transparency = typeof(originalTransparency) == "number" and originalTransparency or part.Transparency
		else
			part.Transparency = 1
		end
	end
end

function TraitVisualSpiderWeb:_ensureSpiderWebPart(p: string, p2: number)
	self.spiderWebModels[p] = self.spiderWebModels[p] or {}
	self.spiderWebParts[p] = self.spiderWebParts[p] or {}
	local v = self.spiderWebModels[p][p2]
	local v2 = self.spiderWebParts[p][p2]

	if v and v2 then
		return v, v2
	end

	local _cloneTemplateModel, v3 = self._cloneTemplateModel(
		self.spiderWebTemplateBundle,
		string.format("%s_%s_%d", p, self._instanceTag, p2)
	)
	self:_setSpiderWebModelVisibility(_cloneTemplateModel, false)
	self.spiderWebModels[p][p2] = _cloneTemplateModel
	self.spiderWebParts[p][p2] = v3
	return _cloneTemplateModel, v3
end

function TraitVisualSpiderWeb:_mergeSpiderWebState(p2)
	local id = p2.id
	local v = p2[self._websField] or {}
	local result = self.spiderWebStates[id] or {}

	for k, v2 in v do
		result[k] = result[k] or {}
		result[k].anchorPosition = v2.anchorPosition
		result[k].startPosition = v2.startPosition
		result[k].endPosition = v2.endPosition
	end

	for k, v2 in result do
		if not (v[k] == nil and v2.anchorPosition) then
			continue
		end

		v2.startPosition = v2.anchorPosition
		v2.endPosition = p2.position
	end

	self.spiderWebStates[id] = result
	return result
end

function TraitVisualSpiderWeb:_applySpiderWebPart(p, instance, p2, p3: number)
	local _worldFromArena = self._worldFromArena(p2.startPosition, p3)
	local _worldFromArena2 = self._worldFromArena(p2.endPosition, p3)
	local magnitude = (_worldFromArena2 - _worldFromArena).Magnitude

	if magnitude < 0.05 then
		self:_setSpiderWebModelVisibility(p, false)
		return
	end

	instance.Size = Vector3.new(instance.Size.X, instance.Size.Y, magnitude)
	instance.CFrame = CFrame.lookAt((_worldFromArena + _worldFromArena2) * 0.5, _worldFromArena)
	local attachment = instance:FindFirstChild("朝向标记")
	assert(attachment and attachment:IsA("Attachment"), "蜘蛛丝碰撞箱缺少朝向标记")
	attachment.Position = Vector3.new(attachment.Position.X, attachment.Position.Y, magnitude * 0.5)
	self:_setSpiderWebModelVisibility(p, true)
end

function TraitVisualSpiderWeb:_updateSpiderWebVisuals(p)
	local _mergeSpiderWebState = self:_mergeSpiderWebState(p)
	local v = self.spiderWebParts[p.id] or {}
	local v2 = self.spiderWebModels[p.id] or {}

	for k, v3 in _mergeSpiderWebState do
		local _ensureSpiderWebPart, v4 = self:_ensureSpiderWebPart(p.id, k)
		self:_applySpiderWebPart(_ensureSpiderWebPart, v4, v3, self._getBallMarkerHeight(p.id))
	end

	for k, v3 in v do
		if _mergeSpiderWebState[k] ~= nil then
			continue
		end

		local v4 = v2[k]

		if v4 then
			self:_setSpiderWebModelVisibility(v4, false)
		else
			v3.Transparency = 1
		end
	end
end

function TraitVisualSpiderWeb:_registerSpiderWebEvent(data)
	if not (data.ballId and data.webIndex and data.startPosition and data.endPosition) then
		return
	end

	self.spiderWebStates[data.ballId] = self.spiderWebStates[data.ballId] or {}
	self.spiderWebStates[data.ballId][data.webIndex] = {
		anchorPosition = data.startPosition,
		startPosition = data.startPosition,
		endPosition = data.endPosition
	}
	local _ensureSpiderWebPart, v = self:_ensureSpiderWebPart(data.ballId, data.webIndex)
	self:_applySpiderWebPart(
		_ensureSpiderWebPart,
		v,
		self.spiderWebStates[data.ballId][data.webIndex],
		self._getBallMarkerHeight(data.ballId)
	)
end

function TraitVisualSpiderWeb:_playSpiderWebHit(p)
	if not p.position then
		return
	end

	local _worldFromArena = self._worldFromArena(p.position, self.config.visual.spiderWebHeight)
	self._audio:playCue("spiderWebHit", _worldFromArena)
end

function TraitVisualSpiderWeb:update(p)
	if p[self._websField] then
		self:_updateSpiderWebVisuals(p)
	end
end

function TraitVisualSpiderWeb:registerEvent(p)
	self:_registerSpiderWebEvent(p)
end

function TraitVisualSpiderWeb:playHit(p)
	self:_playSpiderWebHit(p)
end

function TraitVisualSpiderWeb:cleanupBall(p: string)
	self.spiderWebStates[p] = nil
	local spiderWebPart = self.spiderWebParts[p]

	if not spiderWebPart then
		return
	end

	local v = self.spiderWebModels[p] or {}

	for k, v2 in spiderWebPart do
		local v3 = v[k]

		if v3 then
			self:_setSpiderWebModelVisibility(v3, false)
		else
			v2.Transparency = 1
		end
	end
end

function TraitVisualSpiderWeb:reset()
	self.spiderWebStates = {}

	for k in self.spiderWebParts do
		self:cleanupBall(k)
	end
end

return TraitVisualSpiderWeb