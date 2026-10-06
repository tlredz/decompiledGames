local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DuelAudioController = require(ReplicatedStorage:WaitForChild("Engine"):WaitForChild("Service"):WaitForChild("DuelAudioController"))
local TraitVisualElectroKing = {}
TraitVisualElectroKing.__index = TraitVisualElectroKing

function TraitVisualElectroKing.new(ctx)
	local object = setmetatable({}, TraitVisualElectroKing)
	object._ctx = ctx
	object.rootFolder = ctx.rootFolder
	object.electroKingTemplate = ctx.electroKingTemplate
	object._config = ctx.config
	object._worldFromArena = ctx.worldFromArena
	object._effectArenaRotation = ctx.effectArenaRotation
	object._getBallMarkerHeight = ctx.getBallMarkerHeight
	object.nodeModels = {}
	object.edgeModels = {}
	object.edgeParts = {}
	return object
end

function TraitVisualElectroKing:_setTemplateModelAlpha(folder, p: number)
	for _, part in ipairs(folder:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		local originalTransparency = part:GetAttribute("OriginalTransparency")
		local v = typeof(originalTransparency) == "number" and originalTransparency or part.Transparency
		part.Transparency = v + (1 - v) * (1 - p)
	end
end

function TraitVisualElectroKing._ensureNodeModel(data, battleOwnerSlotId: string, p: number)
	data.nodeModels[battleOwnerSlotId] = data.nodeModels[battleOwnerSlotId] or {}
	local v = data.nodeModels[battleOwnerSlotId][p]

	if v then
		return v
	end

	local firstChild = data.electroKingTemplate:FindFirstChild("附着点")
	assert(firstChild, "电王电网克隆缺少附着点（节点标记素材）")
	local clone = firstChild:Clone()
	clone.Name = string.format("%s_ElectroNode_%d", battleOwnerSlotId, p)
	clone:SetAttribute("BattleOwnerSlotId", battleOwnerSlotId)
	clone.Anchored = true
	clone.CanCollide = false
	clone.CanQuery = false
	clone.CanTouch = false
	clone:SetAttribute("OriginalTransparency", clone.Transparency)
	clone.Parent = data.rootFolder
	data.nodeModels[battleOwnerSlotId][p] = clone
	return clone
end

function TraitVisualElectroKing:_ensureEdgeModel(battleOwnerSlotId: string, p: number)
	self.edgeModels[battleOwnerSlotId] = self.edgeModels[battleOwnerSlotId] or {}
	self.edgeParts[battleOwnerSlotId] = self.edgeParts[battleOwnerSlotId] or {}
	local v = self.edgeModels[battleOwnerSlotId][p]
	local v2 = self.edgeParts[battleOwnerSlotId][p]

	if v and v2 then
		return v, v2.line, v2.startPoint, v2.endPoint
	end

	local clone = self.electroKingTemplate:Clone()
	clone.Name = string.format("%s_ElectroEdge_%d", battleOwnerSlotId, p)
	clone:SetAttribute("BattleOwnerSlotId", battleOwnerSlotId)
	local firstChild = clone:FindFirstChild("碰撞箱")
	local firstChild2 = clone:FindFirstChild("附着点")
	assert(firstChild and firstChild2, "电王电网克隆缺少碰撞箱或附着点")
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
	self.edgeModels[battleOwnerSlotId][p] = clone
	self.edgeParts[battleOwnerSlotId][p] = {
		line = firstChild,
		startPoint = firstChild2,
		endPoint = clone2
	}
	return clone, firstChild, firstChild2, clone2
end

function TraitVisualElectroKing:update(p)
	local electroKingGrid = p.traits and p.traits.ElectroKingGrid

	if not electroKingGrid then
		return
	end

	local id = p.id
	local _getBallMarkerHeight = self._getBallMarkerHeight(id)
	local v = {}

	for _, v2 in electroKingGrid.nodes or {} do
		v[v2.nodeId] = true
		local _ensureNodeModel = self:_ensureNodeModel(id, v2.nodeId)
		_ensureNodeModel.CFrame = CFrame.new(self._worldFromArena(v2.position, _getBallMarkerHeight)) * self._effectArenaRotation
	end

	for k, v2 in self.nodeModels[id] or {} do
		if v[k] then
			continue
		end

		v2:Destroy()
		self.nodeModels[id][k] = nil
	end

	local edges = electroKingGrid.edges or {}
	local shockActiveDuration = self._config.traits.ElectroKingGrid.shockActiveDuration or 0
	local v2 = not ((electroKingGrid.shockActiveRemaining or 0) > 0 and shockActiveDuration > 0) and 0 or math.clamp(
		electroKingGrid.shockActiveRemaining / shockActiveDuration,
		0,
		1
	)

	if v2 > 0 then
		for k, edge in edges do
			local _ensureEdgeModel, v3, v4, v5 = self:_ensureEdgeModel(id, k)
			local _worldFromArena = self._worldFromArena(edge.startPosition, _getBallMarkerHeight)
			local _worldFromArena2 = self._worldFromArena(edge.endPosition, _getBallMarkerHeight)
			local magnitude = (_worldFromArena2 - _worldFromArena).Magnitude

			if magnitude > 0.05 then
				v3.Size = Vector3.new(v3.Size.X, v3.Size.Y, magnitude)
				v3.CFrame = CFrame.lookAt((_worldFromArena + _worldFromArena2) * 0.5, _worldFromArena)

				for _, v6 in ipairs({ v4, v5 }) do
					local attachment = v6:FindFirstChild("朝向标记")
					assert(attachment and attachment:IsA("Attachment"), "电王电网附着点缺少朝向标记")
					local v7 = v6 == v4 and _worldFromArena or _worldFromArena2
					v6.CFrame = CFrame.new(v7) * self._effectArenaRotation * attachment.CFrame:Inverse()
				end

				self:_setTemplateModelAlpha(_ensureEdgeModel, v2)
			else
				self:_setTemplateModelAlpha(_ensureEdgeModel, 0)
			end
		end

		for k, v3 in self.edgeModels[id] or {} do
			if #edges < k then
				self:_setTemplateModelAlpha(v3, 0)
			end
		end
	else
		for _, v3 in self.edgeModels[id] or {} do
			self:_setTemplateModelAlpha(v3, 0)
		end
	end
end

function TraitVisualElectroKing:playShockStart(p: string)
	local _, v = self:_ensureEdgeModel(p, 1)
	local sound = v:FindFirstChild("音效")

	if sound and sound:IsA("Sound") then
		sound.TimePosition = 0
		DuelAudioController.prepare(sound)
		sound:Play()
	end
end

function TraitVisualElectroKing:cleanupBall(p: string)
	for _, v in self.nodeModels[p] or {} do
		v:Destroy()
	end

	self.nodeModels[p] = nil

	for _, v in self.edgeModels[p] or {} do
		v:Destroy()
	end

	local edgeModels = self.edgeModels
	local edgeParts = self.edgeParts
	edgeModels[p] = nil
	edgeParts[p] = nil
end

function TraitVisualElectroKing:reset()
	for k in self.nodeModels do
		self:cleanupBall(k)
	end

	for k in self.edgeModels do
		self:cleanupBall(k)
	end
end

return TraitVisualElectroKing