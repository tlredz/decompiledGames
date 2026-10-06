local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DuelAudioController = require(ReplicatedStorage:WaitForChild("Engine"):WaitForChild("Service"):WaitForChild("DuelAudioController"))
local TraitVisualLaserTurretV3 = {}
TraitVisualLaserTurretV3.__index = TraitVisualLaserTurretV3

function TraitVisualLaserTurretV3.new(ctx)
	local object = setmetatable({}, TraitVisualLaserTurretV3)
	object._ctx = ctx
	object.rootFolder = ctx.rootFolder
	object._config = ctx.config
	object._worldFromArena = ctx.worldFromArena
	object._effectArenaRotation = ctx.effectArenaRotation
	object._getBallMarkerHeight = ctx.getBallMarkerHeight
	object._turretModels = {}
	object._beamModels = {}
	object._beamParts = {}
	return object
end

function TraitVisualLaserTurretV3:_setBeamAlpha(folder, p: number)
	for _, part in ipairs(folder:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		local originalTransparency = part:GetAttribute("OriginalTransparency")
		local v = typeof(originalTransparency) == "number" and originalTransparency or part.Transparency
		part.Transparency = v + (1 - v) * (1 - p)
	end
end

function TraitVisualLaserTurretV3:_ensureBeamModel(battleOwnerSlotId: string, p: number)
	self._beamModels[battleOwnerSlotId] = self._beamModels[battleOwnerSlotId] or {}
	self._beamParts[battleOwnerSlotId] = self._beamParts[battleOwnerSlotId] or {}
	local v = self._beamModels[battleOwnerSlotId][p]
	local v2 = self._beamParts[battleOwnerSlotId][p]

	if v and v2 then
		return v, v2.line, v2.startPoint, v2.endPoint
	end

	local clone = self._ctx.laserTurretV3BeamTemplate:Clone()
	clone.Name = string.format("%s_LaserV3Beam_%d", battleOwnerSlotId, p)
	clone:SetAttribute("BattleOwnerSlotId", battleOwnerSlotId)
	local firstChild = clone:FindFirstChild("碰撞箱")
	local firstChild2 = clone:FindFirstChild("附着点")
	assert(firstChild and firstChild2, "激光V3光束克隆缺少碰撞箱或附着点")
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
	self._beamModels[battleOwnerSlotId][p] = clone
	self._beamParts[battleOwnerSlotId][p] = {
		line = firstChild,
		startPoint = firstChild2,
		endPoint = clone2
	}
	self:_setBeamAlpha(clone, 0)
	return clone, firstChild, firstChild2, clone2
end

function TraitVisualLaserTurretV3:_beamEndPosition(data)
	local size = self._config.arena.size
	local v

	if data.normal.X == 0 then
		v = size.Y
	else
		v = size.X
	end

	return data.position + data.aimDirection * v
end

function TraitVisualLaserTurretV3:update(p)
	local _ctx = self._ctx
	local laserTurretV3 = p.traits and p.traits.LaserTurretV3

	if not laserTurretV3 then
		return
	end

	local id = p.id
	local _getBallMarkerHeight = self._getBallMarkerHeight(id)
	local laserFlashDuration = self._config.traits.LaserTurretV3.laserFlashDuration or 0
	self._turretModels[id] = self._turretModels[id] or {}
	local v = {}

	for _, v2 in laserTurretV3.turrets or {} do
		v[v2.turretId] = true

		if not self._turretModels[id][v2.turretId] then
			local templateModel = _ctx.cloneTemplateModel(
				_ctx.laserTurretV3TemplateBundle,
				string.format("LaserTurretV3_%s_%d", id, v2.turretId)
			)
			templateModel.Parent = _ctx.rootFolder
			self._turretModels[id][v2.turretId] = templateModel
			local _worldFromArena = self._worldFromArena(v2.position)
			local _worldFromArena2 = self._worldFromArena(v2.position + v2.aimDirection)

			if (_worldFromArena2 - _worldFromArena).Magnitude > 0.001 then
				templateModel:PivotTo(CFrame.lookAt(_worldFromArena, _worldFromArena2, _ctx.arenaCFrame.LookVector) * CFrame.Angles(
					0,
					0,
					1.5707963267948966
				) * _ctx.laserTurretV3TemplateBundle.markerOffset:Inverse())
			end

			_ctx.setTemplateModelVisibility(templateModel, true)
		end

		local _ensureBeamModel, v3, v4, v5 = self:_ensureBeamModel(id, v2.turretId)
		local v6 = not ((v2.flashRemaining or 0) > 0 and laserFlashDuration > 0) and 0 or math.clamp(
			v2.flashRemaining / laserFlashDuration,
			0,
			1
		)

		if v6 > 0 then
			local _worldFromArena = self._worldFromArena(v2.position, _getBallMarkerHeight)
			local _worldFromArena2 = self._worldFromArena(self:_beamEndPosition(v2), _getBallMarkerHeight)
			local magnitude = (_worldFromArena2 - _worldFromArena).Magnitude

			if magnitude > 0.05 then
				v3.Size = Vector3.new(v3.Size.X, v3.Size.Y, magnitude)
				v3.CFrame = CFrame.lookAt((_worldFromArena + _worldFromArena2) * 0.5, _worldFromArena)

				for _, v7 in ipairs({ v4, v5 }) do
					local attachment = v7:FindFirstChild("朝向标记")
					assert(attachment and attachment:IsA("Attachment"), "激光V3光束附着点缺少朝向标记")
					local v8 = v7 == v4 and _worldFromArena or _worldFromArena2
					v7.CFrame = CFrame.new(v8) * self._effectArenaRotation * attachment.CFrame:Inverse()
				end

				self:_setBeamAlpha(_ensureBeamModel, v6)
			else
				self:_setBeamAlpha(_ensureBeamModel, 0)
			end
		else
			self:_setBeamAlpha(_ensureBeamModel, 0)
		end
	end

	for k, v2 in self._turretModels[id] or {} do
		if v[k] then
			continue
		end

		v2:Destroy()
		self._turretModels[id][k] = nil
		local v3 = self._beamModels[id] and self._beamModels[id][k]

		if not v3 then
			continue
		end

		v3:Destroy()
		self._beamModels[id][k] = nil
		self._beamParts[id][k] = nil
	end
end

function TraitVisualLaserTurretV3:playFire(p: string, p2: number)
	if p2 == nil then
		return
	end

	local _, v = self:_ensureBeamModel(p, p2)
	local sound = v:FindFirstChild("音效")

	if sound and sound:IsA("Sound") then
		sound.TimePosition = 0
		DuelAudioController.prepare(sound)
		sound:Play()
	end
end

function TraitVisualLaserTurretV3:cleanupBall(p: string)
	for _, v in self._turretModels[p] or {} do
		v:Destroy()
	end

	self._turretModels[p] = nil

	for _, v in self._beamModels[p] or {} do
		v:Destroy()
	end

	local _beamModels = self._beamModels
	local _beamParts = self._beamParts
	_beamModels[p] = nil
	_beamParts[p] = nil
end

function TraitVisualLaserTurretV3:reset()
	local v = {}

	for k in self._turretModels do
		table.insert(v, k)
	end

	for k in self._beamModels do
		if not self._turretModels[k] then
			table.insert(v, k)
		end
	end

	for _, v2 in v do
		self:cleanupBall(v2)
	end
end

return TraitVisualLaserTurretV3