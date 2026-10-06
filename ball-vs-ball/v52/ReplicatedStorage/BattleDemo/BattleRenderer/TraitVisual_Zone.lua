local GeometryService = game:GetService("GeometryService")
local TraitVisualZone = {}
TraitVisualZone.__index = TraitVisualZone

local function buildZoneRegionSignature(data)
	local v = {
		string.format("%d", data.regionId),
		string.format("%.3f,%.3f", data.startPosition.X, data.startPosition.Y),
		string.format("%.3f,%.3f", data.endPosition.X, data.endPosition.Y)
	}

	for _, v2 in data.polygon do
		table.insert(v, string.format("%.3f,%.3f", v2.X, v2.Y))
	end

	return table.concat(v, "|")
end

function TraitVisualZone.new(ctx)
	local self = setmetatable({}, TraitVisualZone)
	self._ctx = ctx
	self.zonePreviewModels = {}
	self.zonePreviewParts = {}
	self.zoneRegionLineModels = {}
	self.zoneRegionLineParts = {}
	self.zoneRegionFillFolders = {}
	self.zoneRegionSignatures = {}
	return self
end

function TraitVisualZone:_setZoneStringModelVisibility(folder, flag: boolean)
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

function TraitVisualZone:_applyZoneStringPart(p, instance, point: Vector2, point2: Vector2, p2: number, flag: boolean?)
	local worldFromArena = self._ctx.worldFromArena(point, p2)
	local worldFromArena2 = self._ctx.worldFromArena(point2, p2)
	local magnitude = (worldFromArena2 - worldFromArena).Magnitude

	if magnitude < 0.05 then
		self:_setZoneStringModelVisibility(p, false)
		return
	end

	instance.Size = Vector3.new(instance.Size.X, instance.Size.Y, magnitude)
	instance.CFrame = CFrame.lookAt(
		(worldFromArena + worldFromArena2) * 0.5,
		worldFromArena,
		self._ctx.arenaCFrame.LookVector
	)

	if flag then
		local attachment = instance:FindFirstChild("朝向标记")
		assert(attachment and attachment:IsA("Attachment"), "区域边界线碰撞箱缺少朝向标记")
		attachment.Position = Vector3.new(attachment.Position.X, attachment.Position.Y, magnitude * 0.5)
	end

	self:_setZoneStringModelVisibility(p, true)
end

function TraitVisualZone:_isChordVisible(point: Vector2, point2: Vector2, p2: number)
	local worldFromArena = self._ctx.worldFromArena(point, p2)
	return (self._ctx.worldFromArena(point2, p2) - worldFromArena).Magnitude >= 0.05
end

function TraitVisualZone:_ensureZonePreviewPart(p: string)
	local zonePreviewModel = self.zonePreviewModels[p]
	local zonePreviewPart = self.zonePreviewParts[p]

	if zonePreviewModel and zonePreviewPart then
		return zonePreviewModel, zonePreviewPart
	end

	local templateModel, v = self._ctx.cloneTemplateModel(
		self._ctx.redStringTemplateBundle,
		string.format("%s_ZonePreview", p)
	)
	self:_setZoneStringModelVisibility(templateModel, false)
	self.zonePreviewModels[p] = templateModel
	self.zonePreviewParts[p] = v
	return templateModel, v
end

function TraitVisualZone:_ensureZoneRegionLinePart(p: string, p2: number)
	self.zoneRegionLineModels[p] = self.zoneRegionLineModels[p] or {}
	self.zoneRegionLineParts[p] = self.zoneRegionLineParts[p] or {}
	local v = self.zoneRegionLineModels[p][p2]
	local v2 = self.zoneRegionLineParts[p][p2]

	if v and v2 then
		return v, v2
	end

	local templateModel, v3 = self._ctx.cloneTemplateModel(
		self._ctx.redStringTemplateBundle,
		string.format("%s_ZoneLine_%d", p, p2)
	)
	self:_setZoneStringModelVisibility(templateModel, false)
	self.zoneRegionLineModels[p][p2] = templateModel
	self.zoneRegionLineParts[p][p2] = v3
	return templateModel, v3
end

function TraitVisualZone:_ensureZoneRegionFillFolder(p2: string, p3: number)
	self.zoneRegionFillFolders[p2] = self.zoneRegionFillFolders[p2] or {}
	local v = self.zoneRegionFillFolders[p2][p3]

	if v then
		return v
	end

	local folder = Instance.new("Folder")
	folder.Name = string.format("%s_ZoneFill_%d", p2, p3)
	folder.Parent = self._ctx.rootFolder
	self.zoneRegionFillFolders[p2][p3] = folder
	return folder
end

function TraitVisualZone:_clearZoneRegionFillFolder(instance)
	for _, child in ipairs(instance:GetChildren()) do
		child:Destroy()
	end
end

function TraitVisualZone:_destroyZoneRegionVisual(p: string, p2: number)
	local zoneRegionLineModel = self.zoneRegionLineModels[p]
	local zoneRegionLinePart = self.zoneRegionLineParts[p]
	local zoneRegionFillFolder = self.zoneRegionFillFolders[p]
	local zoneRegionSignature = self.zoneRegionSignatures[p]

	if zoneRegionLineModel and zoneRegionLineModel[p2] then
		zoneRegionLineModel[p2]:Destroy()
		zoneRegionLineModel[p2] = nil

		if zoneRegionLinePart then
			zoneRegionLinePart[p2] = nil
		end
	end

	if zoneRegionFillFolder and zoneRegionFillFolder[p2] then
		zoneRegionFillFolder[p2]:Destroy()
		zoneRegionFillFolder[p2] = nil

		if zoneRegionSignature then
			zoneRegionSignature[p2] = nil
		end
	end
end

function TraitVisualZone:_renderZoneRegionFill(parent, list, point: Vector2, point2: Vector2, battleOwnerSlotId: string, p: number, p2: string)
	self:_clearZoneRegionFillFolder(parent)

	if #list < 3 then
		return
	end

	local v = point2 - point

	if v.Magnitude <= 0.0001 then
		return
	end

	local unit = v.Unit
	local vector = Vector2.new(-unit.Y, unit.X)
	local zero = Vector2.zero

	for _, v2 in list do
		zero += v2
	end

	if (zero / #list - point):Dot(vector) < 0 then
		vector = -vector
	end

	local zoneStyleTemplate = self._ctx.zoneStyleTemplate
	assert(zoneStyleTemplate and zoneStyleTemplate:IsA("BasePart"), "区域样式模板不可用")
	local v2 = zoneStyleTemplate.Size.Y * self._ctx.arenaScale
	local size = self._ctx.config.arena.size
	local v3 = ((size.X * size.X + size.Y * size.Y) ^ 0.5 + 2) * 2
	local clone = zoneStyleTemplate:Clone()
	clone.Name = string.format("ZoneFillSource_%s_%d", battleOwnerSlotId, p)
	clone.Anchored = true
	clone.CanCollide = false
	clone.CanQuery = false
	clone.CanTouch = false
	clone.CastShadow = false
	clone.Size = Vector3.new(size.X * self._ctx.arenaScale, size.Y * self._ctx.arenaScale, v2)
	clone.CFrame = CFrame.fromMatrix(
		self._ctx.worldFromArena(Vector2.zero, v2 * 0.5),
		self._ctx.arenaCFrame.RightVector,
		self._ctx.arenaCFrame.UpVector,
		-self._ctx.arenaCFrame.LookVector
	)
	clone.Transparency = 1
	clone.Parent = parent
	local part = Instance.new("Part")
	part.Name = string.format("ZoneFillCutter_%s_%d", battleOwnerSlotId, p)
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Transparency = 1
	part.Size = Vector3.new(v3 * self._ctx.arenaScale, v2 + 0.02, v3 * self._ctx.arenaScale)
	local v4 = (point + point2) * 0.5 - vector * (v3 * 0.5)
	local worldFromArena = self._ctx.worldFromArena(v4, v2 * 0.5)
	local vectorToWorldSpace = self._ctx.arenaCFrame:VectorToWorldSpace((Vector3.new(vector.X, vector.Y, 0)))
	part.CFrame = CFrame.lookAt(worldFromArena, worldFromArena + vectorToWorldSpace, self._ctx.arenaCFrame.LookVector)
	part.Parent = parent
	task.spawn(function()
		local success, result = pcall(function()
			return GeometryService:SubtractAsync(clone, { part }, {
				SplitApart = false
			})
		end)
		clone:Destroy()
		part:Destroy()

		if not (success and result) then
			warn(string.format("[ZoneField] 区域 Mesh 生成失败：%s", (tostring(result))))
			return
		end

		local v5 = result[1]

		for k, v6 in result do
			if k ~= 1 then
				v6:Destroy()
			end
		end

		local zoneRegionSignature = self.zoneRegionSignatures[battleOwnerSlotId]

		if v5 and zoneRegionSignature and zoneRegionSignature[p] == p2 and parent.Parent ~= nil then
			v5.Name = string.format("ZoneFill_%d", p)
			v5:SetAttribute("BattleOwnerSlotId", battleOwnerSlotId)
			v5.Anchored = true
			v5.CanCollide = false
			v5.CanQuery = false
			v5.CanTouch = false
			v5.CastShadow = false
			v5.Color = zoneStyleTemplate.Color
			v5.Material = zoneStyleTemplate.Material
			v5.Transparency = zoneStyleTemplate.Transparency
			v5.Reflectance = zoneStyleTemplate.Reflectance
			v5.Parent = parent
		elseif v5 then
			v5:Destroy()
		end
	end)
end

function TraitVisualZone:_updateZonePreviewVisual(data)
	local _ensureZonePreviewPart, v = self:_ensureZonePreviewPart(data.id)

	if data.zonePreviewAnchorPosition then
		self:_applyZoneStringPart(
			_ensureZonePreviewPart,
			v,
			data.zonePreviewAnchorPosition,
			data.position,
			self._ctx.getBallMarkerHeight(data.id),
			true
		)
	else
		self:_setZoneStringModelVisibility(_ensureZonePreviewPart, false)
	end
end

function TraitVisualZone:_updateZoneRegionVisuals(p)
	self.zoneRegionSignatures[p.id] = self.zoneRegionSignatures[p.id] or {}
	local v = {}

	for _, v2 in p.zoneRegions or {} do
		v[v2.regionId] = true
		local ballMarkerHeight = self._ctx.getBallMarkerHeight(p.id)
		local _isChordVisible = self:_isChordVisible(v2.startPosition, v2.endPosition, ballMarkerHeight)
		local _ensureZoneRegionLinePart, v3 = self:_ensureZoneRegionLinePart(p.id, v2.regionId)

		if _isChordVisible then
			self:_applyZoneStringPart(_ensureZoneRegionLinePart, v3, v2.startPosition, v2.endPosition, ballMarkerHeight)
		else
			self:_setZoneStringModelVisibility(_ensureZoneRegionLinePart, false)
		end

		local _ensureZoneRegionFillFolder = self:_ensureZoneRegionFillFolder(p.id, v2.regionId)
		local zoneRegionSignature = buildZoneRegionSignature(v2)

		if self.zoneRegionSignatures[p.id][v2.regionId] == zoneRegionSignature then
			continue
		end

		self.zoneRegionSignatures[p.id][v2.regionId] = zoneRegionSignature

		if _isChordVisible then
			self:_renderZoneRegionFill(
				_ensureZoneRegionFillFolder,
				v2.polygon,
				v2.startPosition,
				v2.endPosition,
				p.id,
				v2.regionId,
				zoneRegionSignature
			)
		else
			self:_clearZoneRegionFillFolder(_ensureZoneRegionFillFolder)
		end
	end

	for k, _ in self.zoneRegionLineModels[p.id] or {} do
		if not v[k] then
			self:_destroyZoneRegionVisual(p.id, k)
		end
	end

	for k, _ in self.zoneRegionFillFolders[p.id] or {} do
		if not v[k] then
			self:_destroyZoneRegionVisual(p.id, k)
		end
	end
end

function TraitVisualZone:update(p)
	self:_updateZonePreviewVisual(p)
	self:_updateZoneRegionVisuals(p)
end

function TraitVisualZone:playZoneTick(p2)
	if not p2.position then
		return
	end

	local _ctx = self._ctx
	local worldFromArena = _ctx.worldFromArena(p2.position, _ctx.config.visual.zoneLineHeight * 0.8)

	if _ctx.audio then
		_ctx.audio:playCue("zoneTick", worldFromArena)
	end
end

function TraitVisualZone:cleanupBall(p: string)
	local zonePreviewModel = self.zonePreviewModels[p]

	if zonePreviewModel then
		self:_setZoneStringModelVisibility(zonePreviewModel, false)
	end

	for k, _ in self.zoneRegionLineModels[p] or {} do
		self:_destroyZoneRegionVisual(p, k)
	end
end

function TraitVisualZone:reset()
	self.zoneRegionSignatures = {}

	for k in self.zonePreviewModels do
		self:cleanupBall(k)
	end

	for k in self.zoneRegionLineModels do
		self:cleanupBall(k)
	end
end

function TraitVisualZone:destroy()
	self.zonePreviewModels = {}
	self.zonePreviewParts = {}
	self.zoneRegionLineModels = {}
	self.zoneRegionLineParts = {}
	self.zoneRegionFillFolders = {}
	self.zoneRegionSignatures = {}
end

return TraitVisualZone