local TraitVisualLaser = {}
TraitVisualLaser.__index = TraitVisualLaser

function TraitVisualLaser.new(ctx)
	local object = setmetatable({}, TraitVisualLaser)
	object._ctx = ctx
	object.rootFolder = ctx.rootFolder
	object.laserTemplate = ctx.laserTemplate
	object._worldFromArena = ctx.worldFromArena
	object._effectArenaRotation = ctx.effectArenaRotation
	object._getBallMarkerHeight = ctx.getBallMarkerHeight
	object.laserModels = {}
	object.laserParts = {}
	return object
end

function TraitVisualLaser:_setTemplateModelVisibility(folder, flag: boolean)
	for _, part in ipairs(folder:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		local originalTransparency = part:GetAttribute("OriginalTransparency")
		part.Transparency = not flag and 1 or typeof(originalTransparency) == "number" and originalTransparency or part.Transparency or 1
	end
end

function TraitVisualLaser:_ensureLaserModel(battleOwnerSlotId: string, p: number)
	self.laserModels[battleOwnerSlotId] = self.laserModels[battleOwnerSlotId] or {}
	self.laserParts[battleOwnerSlotId] = self.laserParts[battleOwnerSlotId] or {}
	local v = self.laserModels[battleOwnerSlotId][p]
	local v2 = self.laserParts[battleOwnerSlotId][p]

	if v and v2 then
		return v, v2.line, v2.startPoint, v2.endPoint
	end

	local clone = self.laserTemplate:Clone()
	clone.Name = string.format("%s_Laser_%d", battleOwnerSlotId, p)
	clone:SetAttribute("BattleOwnerSlotId", battleOwnerSlotId)
	local firstChild = clone:FindFirstChild("碰撞箱")
	local firstChild2 = clone:FindFirstChild("附着点")
	assert(firstChild and firstChild2, "激光克隆缺少碰撞箱或附着点")
	local clone2 = firstChild2:Clone()
	clone2.Name = "附着点_终点"
	clone2.Parent = clone

	for _, v3 in ipairs({ firstChild, firstChild2, clone2 }) do
		v3.Anchored = true
		v3.CanCollide = false
		v3.CanQuery = false
		v3.CanTouch = false
		v3:SetAttribute("OriginalTransparency", v3.Transparency)
	end

	clone.PrimaryPart = firstChild
	clone.Parent = self.rootFolder
	self.laserModels[battleOwnerSlotId][p] = clone
	self.laserParts[battleOwnerSlotId][p] = {
		line = firstChild,
		startPoint = firstChild2,
		endPoint = clone2
	}
	return clone, firstChild, firstChild2, clone2
end

function TraitVisualLaser:updatePreview(data)
	local laserAnchorPosition = data.laserAnchorPosition

	if laserAnchorPosition then
		local _ensureLaserModel, v, v2, v3 = self:_ensureLaserModel(data.id, 0)
		local _getBallMarkerHeight = self._getBallMarkerHeight(data.id)
		local _worldFromArena = self._worldFromArena(laserAnchorPosition, _getBallMarkerHeight)
		local _worldFromArena2 = self._worldFromArena(data.position, _getBallMarkerHeight)
		local magnitude = (_worldFromArena2 - _worldFromArena).Magnitude

		if magnitude <= 0.05 then
			self:_setTemplateModelVisibility(_ensureLaserModel, false)
			return
		end

		v.Size = Vector3.new(v.Size.X, v.Size.Y, magnitude)
		v.CFrame = CFrame.lookAt((_worldFromArena + _worldFromArena2) * 0.5, _worldFromArena)
		local attachment = v2:FindFirstChild("朝向标记")
		assert(attachment and attachment:IsA("Attachment"), "激光附着点缺少朝向标记")
		v2.CFrame = CFrame.new(_worldFromArena) * self._effectArenaRotation * attachment.CFrame:Inverse()
		self:_setTemplateModelVisibility(_ensureLaserModel, true)
		v3.Transparency = 1
	else
		local v = self.laserModels[data.id] and self.laserModels[data.id][0]

		if v then
			self:_setTemplateModelVisibility(v, false)
		end
	end
end

function TraitVisualLaser:updateVisuals(p)
	local v = {}

	for k, v2 in p.laserSegments or {} do
		v[k] = true
		local _ensureLaserModel, v3, v4, v5 = self:_ensureLaserModel(p.id, k)
		local _getBallMarkerHeight = self._getBallMarkerHeight(p.id)
		local _worldFromArena = self._worldFromArena(v2.startPosition, _getBallMarkerHeight)
		local _worldFromArena2 = self._worldFromArena(v2.endPosition, _getBallMarkerHeight)
		local _ = _worldFromArena2 - _worldFromArena
		local magnitude = (_worldFromArena2 - _worldFromArena).Magnitude

		if magnitude > 0.05 then
			v3.Size = Vector3.new(v3.Size.X, v3.Size.Y, magnitude)
			v3.CFrame = CFrame.lookAt((_worldFromArena + _worldFromArena2) * 0.5, _worldFromArena)

			for _, v6 in ipairs({ v4, v5 }) do
				local attachment = v6:FindFirstChild("朝向标记")
				assert(attachment and attachment:IsA("Attachment"), "激光附着点缺少朝向标记")
				local v7 = v6 == v4 and _worldFromArena or _worldFromArena2
				v6.CFrame = CFrame.new(v7) * self._effectArenaRotation * attachment.CFrame:Inverse()
			end

			self:_setTemplateModelVisibility(_ensureLaserModel, true)
		else
			self:_setTemplateModelVisibility(_ensureLaserModel, false)
		end
	end

	for k, v2 in self.laserModels[p.id] or {} do
		if k == 0 or v[k] then
			continue
		end

		self:_setTemplateModelVisibility(v2, false)
	end
end

function TraitVisualLaser:cleanupBall(p2: string)
	for _, v in self.laserModels[p2] or {} do
		v:Destroy()
	end

	local laserModels = self.laserModels
	local laserParts = self.laserParts
	laserModels[p2] = nil
	laserParts[p2] = nil
end

function TraitVisualLaser:reset()
	for k in self.laserModels do
		self:cleanupBall(k)
	end
end

return TraitVisualLaser