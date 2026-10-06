local createVector = vector.create
local TraitVisualHarpoon = {}
TraitVisualHarpoon.__index = TraitVisualHarpoon
local color = Color3.fromRGB(110, 170, 210)

function TraitVisualHarpoon.new(ctx)
	local self = setmetatable({}, TraitVisualHarpoon)
	self._ctx = ctx
	self._harpoonModels = {}
	self._harpoonVisible = {}
	self._pathParts = {}
	return self
end

function TraitVisualHarpoon:_harpoonModel(p2: string)
	local _harpoonModel = self._harpoonModels[p2]

	if _harpoonModel then
		return _harpoonModel
	end

	local _ctx = self._ctx
	local templateModel = _ctx.cloneTemplateModel(_ctx.harpoonTemplateBundle, p2 .. "_Harpoon")
	templateModel.Parent = _ctx.rootFolder
	self._harpoonModels[p2] = templateModel
	return templateModel
end

local function findTrail(instance)
	local firstChild = instance:FindFirstChild("碰撞箱")
	local trail = firstChild and firstChild:FindFirstChild("拖尾")

	if trail and trail:IsA("Trail") then
		return trail
	end

	return nil
end

function TraitVisualHarpoon:_setTrailEnabled(instance, enabled: boolean, flag: boolean)
	local firstChild = instance:FindFirstChild("碰撞箱")
	local trail = firstChild and firstChild:FindFirstChild("拖尾")

	if not (trail and trail:IsA("Trail")) then
		trail = nil
	end

	if not trail then
		return
	end

	if flag then
		trail:Clear()
	end

	trail.Enabled = enabled
end

function TraitVisualHarpoon:_pathPart(battleOwnerSlotId: string, p2: number)
	self._pathParts[battleOwnerSlotId] = self._pathParts[battleOwnerSlotId] or {}
	local v = self._pathParts[battleOwnerSlotId][p2]

	if v then
		return v
	end

	local part = Instance.new("Part")
	part.Name = string.format("%s_HarpoonPath_%d", battleOwnerSlotId, p2)
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.Material = Enum.Material.Neon
	part.Color = color
	part.Transparency = 0.35
	part.Size = createVector(0.14, 0.14, 1)
	part:SetAttribute("BattleOwnerSlotId", battleOwnerSlotId)
	part.Parent = self._ctx.rootFolder
	self._pathParts[battleOwnerSlotId][p2] = part
	return part
end

function TraitVisualHarpoon:_hidePathPartsFrom(p2: string, p3: number)
	for k, v in self._pathParts[p2] or {} do
		if p3 <= k then
			v.Transparency = 1
		end
	end
end

local function ropePoints(harpoon)
	local pathPoints = harpoon.pathPoints

	if not pathPoints or #pathPoints == 0 then
		return nil
	end

	if harpoon.phase == "Flying" then
		local clone = table.clone(pathPoints)

		if harpoon.position then
			table.insert(clone, harpoon.position)
		end

		return clone
	else
		if harpoon.phase ~= "Pulling" then
			return nil
		end

		local pullSegmentIndex = harpoon.pullSegmentIndex or 0

		if pullSegmentIndex <= 1 or #pathPoints < pullSegmentIndex then
			return nil
		end

		local pathPoint = pathPoints[pullSegmentIndex]
		local v = pathPoints[pullSegmentIndex - 1] - pathPoint

		if v.Magnitude > 1e-6 then
			pathPoint += v.Unit * (harpoon.pullSegmentProgress or 0)
		end

		local result = {}

		for i = 1, pullSegmentIndex - 1 do
			table.insert(result, pathPoints[i])
		end

		table.insert(result, pathPoint)
		return result
	end
end

function TraitVisualHarpoon:update(p)
	local _ctx = self._ctx
	local harpoon = p.traits and p.traits.Harpoon

	if not harpoon then
		return
	end

	local id = p.id

	if harpoon.phase == "Flying" and harpoon.position then
		local _harpoonModel = self:_harpoonModel(id)
		local worldFromArena = _ctx.worldFromArena(harpoon.position)
		local direction = harpoon.direction or Vector2.new(1, 0)
		local worldFromArena2 = _ctx.worldFromArena(harpoon.position + direction)

		if (worldFromArena2 - worldFromArena).Magnitude > 0.001 then
			_harpoonModel:PivotTo(CFrame.lookAt(worldFromArena, worldFromArena2, _ctx.arenaCFrame.LookVector) * _ctx.harpoonTemplateBundle.markerOffset:Inverse())
		else
			_harpoonModel:PivotTo(CFrame.new(worldFromArena) * _ctx.effectArenaRotation)
		end

		_ctx.setTemplateModelVisibility(_harpoonModel, true)
		self:_setTrailEnabled(_harpoonModel, true, self._harpoonVisible[id] ~= true)
		self._harpoonVisible[id] = true
	else
		local _harpoonModel = self._harpoonModels[id]

		if _harpoonModel then
			_ctx.setTemplateModelVisibility(_harpoonModel, false)
			self:_setTrailEnabled(_harpoonModel, false, true)
		end

		self._harpoonVisible[id] = false
	end

	local v = ropePoints(harpoon)

	if not v then
		self:_hidePathPartsFrom(id, 1)
		return
	end

	local count = 0

	for i = 1, #v - 1 do
		local worldFromArena = _ctx.worldFromArena(v[i])
		local worldFromArena2 = _ctx.worldFromArena(v[i + 1])
		local magnitude = (worldFromArena2 - worldFromArena).Magnitude

		if not (magnitude > 0.05) then
			continue
		end

		count += 1
		local _pathPart = self:_pathPart(id, count)
		_pathPart.Size = Vector3.new(0.14, 0.14, magnitude)
		_pathPart.CFrame = CFrame.lookAt((worldFromArena + worldFromArena2) * 0.5, worldFromArena)
		_pathPart.Transparency = 0.35
	end

	self:_hidePathPartsFrom(id, count + 1)
end

function TraitVisualHarpoon:playExpired(p: string)
	local _harpoonModel = self._harpoonModels[p]

	if _harpoonModel then
		self._ctx.setTemplateModelVisibility(_harpoonModel, false)
		self:_setTrailEnabled(_harpoonModel, false, true)
	end

	self._harpoonVisible[p] = false
	self:_hidePathPartsFrom(p, 1)
end

function TraitVisualHarpoon:cleanupBall(p: string)
	local _harpoonModel = self._harpoonModels[p]

	if _harpoonModel then
		_harpoonModel:Destroy()
	end

	self._harpoonModels[p] = nil
	self._harpoonVisible[p] = nil

	for _, v in self._pathParts[p] or {} do
		v:Destroy()
	end

	self._pathParts[p] = nil
end

function TraitVisualHarpoon:reset()
	local v = {}

	for k in self._harpoonModels do
		table.insert(v, k)
	end

	for k in self._pathParts do
		if not self._harpoonModels[k] then
			table.insert(v, k)
		end
	end

	for _, v2 in v do
		self:cleanupBall(v2)
	end
end

return TraitVisualHarpoon