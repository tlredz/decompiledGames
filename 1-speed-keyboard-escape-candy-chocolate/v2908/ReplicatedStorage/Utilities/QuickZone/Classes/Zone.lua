local CollectionService = game:GetService("CollectionService")
local State = require(script.Parent.Parent.Core.State)
require(script.Parent.Parent.Types)
local Geometry = require(script.Parent.Parent.Utils.Geometry)
local Log = require(script.Parent.Parent.Utils.Log)
local Zones = require(script.Parent.Zones)
local staticCFrames = State.staticCFrames
local staticHalfSizes = State.staticHalfSizes
local staticTypes = State.staticTypes
local dynamicCFrames = State.dynamicCFrames
local dynamicHalfSizes = State.dynamicHalfSizes
local dynamicTypes = State.dynamicTypes
local isPointInShape = Geometry.isPointInShape
local v = {
	Block = Enum.PartType.Block.Value,
	Cylinder = Enum.PartType.Cylinder.Value,
	Ball = Enum.PartType.Ball.Value,
	Wedge = Enum.PartType.Wedge.Value,
	CornerWedge = Enum.PartType.CornerWedge.Value
}

local function getShapeEnumValue(reference)
	if reference:IsA("Part") then
		return reference.Shape.Value
	end

	if reference:IsA("WedgePart") then
		return Enum.PartType.Wedge.Value
	end

	if reference:IsA("CornerWedgePart") then
		return Enum.PartType.CornerWedge.Value
	end

	return Enum.PartType.Block.Value
end

-- equivalent calls inferred from this helper; original call sites unknown
local function clearAutoSync(state)
	State.autoSyncZones[state.id] = nil

	if state.syncConnections then
		for _, syncConnection in state.syncConnections do
			syncConnection:Disconnect()
		end

		state.syncConnections = nil
	end
end

local function setupAutoSync(object, part)
	State.autoSyncZones[object.id] = object
	local syncConnections = object.syncConnections or {}

	if part:IsA("BasePart") then
		table.insert(syncConnections, part:GetPropertyChangedSignal("Size"):Connect(function()
			local v2 = part.ExtentsSize * 0.5

			if dynamicHalfSizes[object.id] ~= v2 then
				dynamicHalfSizes[object.id] = v2
				State.pendingDynamicRebuild = true
			end
		end))
	end

	if part:IsA("Part") then
		table.insert(syncConnections, part:GetPropertyChangedSignal("Shape"):Connect(function()
			local value = part.Shape.Value

			if dynamicTypes[object.id] ~= value then
				dynamicTypes[object.id] = value
				State.pendingDynamicRebuild = true
			end
		end))
	end

	object.syncConnections = syncConnections
	object:sync()
end

local function updateObserverZoneCount(p: number, flag: boolean, p2: number)
	local observerDynamicCount = flag and State.observerDynamicCount or State.observerStaticCount
	local v2 = observerDynamicCount[p] or 0
	local v3 = v2 + p2
	observerDynamicCount[p] = v3

	if v2 == 0 and v3 == 1 or v2 == 1 and v3 == 0 then
		if v2 == 1 and v3 == 0 then
			State.logicVersion += 1
		end

		for k, groupToObserver in State.groupToObservers do
			if not groupToObserver[p] then
				continue
			end

			local group = State.groups[k]

			if not group then
				continue
			end

			for _, entity in group.entities do
				State.dirtyTopology[entity] = true
			end
		end
	end
end

local Zone = {}
Zone.__index = Zone

local function newZoneInternal(cframe: CFrame, vector: Vector3, value: number, reference, isDynamic: boolean, metadata, autoSync: boolean)
	local nextZoneId = State.nextZoneId
	State.nextZoneId += 1
	local v3 = vector * 0.5

	if isDynamic then
		State.dynamicCFrames[nextZoneId] = cframe
		State.dynamicHalfSizes[nextZoneId] = v3
		State.dynamicTypes[nextZoneId] = value
		State.pendingDynamicRebuild = true
	else
		State.staticCFrames[nextZoneId] = cframe
		State.staticHalfSizes[nextZoneId] = v3
		State.staticTypes[nextZoneId] = value
		State.pendingStaticRebuild = true
	end

	local self = setmetatable({
		id = nextZoneId,
		reference = reference,
		dynamic = isDynamic,
		metadata = metadata,
		autoSync = false
	}, Zone)
	State.zoneIdToZoneObj[nextZoneId] = self

	if autoSync then
		self:setAutoSync(true)
	end

	return self
end

function Zone.new(data)
	local value = Enum.PartType.Block.Value

	if data.shape then
		local v2 = v[data.shape]

		if v2 then
			value = v2
		else
			Log.warn("Invalid shape '%s'. Defaulting to Block.", nil, (tostring(data.shape)))
		end
	end

	return (newZoneInternal(
		data.cframe,
		data.size,
		value,
		data.reference,
		data.isDynamic or false,
		data.metadata,
		data.autoSync or false
	))
end

function Zone.fromPart(instance, data)
	local value = Enum.PartType.Block.Value

	if instance:IsA("Part") then
		value = instance.Shape.Value
	elseif instance:IsA("WedgePart") then
		value = Enum.PartType.Wedge.Value
	elseif instance:IsA("CornerWedgePart") then
		value = Enum.PartType.CornerWedge.Value
	end

	local isDynamic

	if data then
		isDynamic = data.isDynamic or false
	else
		isDynamic = false
	end

	local metadata = data and data.metadata
	local autoSync = data and data.autoSync or false
	return (newZoneInternal(instance.CFrame, instance.ExtentsSize, value, instance, isDynamic, metadata, autoSync))
end

function Zone.fromParts(items, data)
	local isDynamic

	if data and data.isDynamic ~= nil then
		isDynamic = data.isDynamic
	else
		isDynamic = false
	end

	local metadata

	if data and data.metadata ~= nil then
		metadata = data.metadata
	end

	local autoSync

	if data and data.autoSync ~= nil then
		autoSync = data.autoSync
	else
		autoSync = false
	end

	local v2 = Zones.new({
		isDynamic = isDynamic,
		metadata = metadata,
		autoSync = autoSync
	})

	for _, part in items do
		if part:IsA("BasePart") then
			v2:add((Zone.fromPart(part, {
				isDynamic = isDynamic,
				metadata = v2.metadata,
				autoSync = autoSync
			})))
		end
	end

	return v2
end

function Zone.fromChildren(instance, data)
	local isDynamic

	if data and data.isDynamic ~= nil then
		isDynamic = data.isDynamic
	else
		isDynamic = false
	end

	local metadata

	if data and data.metadata ~= nil then
		metadata = data.metadata
	end

	local autoSync

	if data and data.autoSync ~= nil then
		autoSync = data.autoSync
	else
		autoSync = false
	end

	local v3 = Zones.new({
		isDynamic = isDynamic,
		metadata = metadata,
		autoSync = autoSync
	})
	local v4 = {}

	local function onAdded(part)
		if part:IsA("BasePart") and not v4[part] then
			local v5 = Zone.fromPart(part, {
				isDynamic = isDynamic,
				metadata = v3.metadata
			})
			v4[part] = v5
			v3:add(v5)
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function onRemoved(k)
		local v5 = v4[k]

		if v5 then
			v4[k] = nil
			v5:destroy()
		end
	end

	local childAddedConnection = instance.ChildAdded:Connect(onAdded)
	local childRemovedConnection = instance.ChildRemoved:Connect(onRemoved)

	for _, child in instance:GetChildren() do
		onAdded(child)
	end

	v3:onDestroy(function()
		childAddedConnection:Disconnect()
		childRemovedConnection:Disconnect()

		for k, _ in v4 do
			onRemoved(k) -- equivalent call inferred; original call site unknown
		end

		table.clear(v4)
	end)
	return v3
end

function Zone.fromDescendants(folder, data)
	local isDynamic

	if data and data.isDynamic ~= nil then
		isDynamic = data.isDynamic
	else
		isDynamic = false
	end

	local metadata

	if data and data.metadata ~= nil then
		metadata = data.metadata
	end

	local autoSync

	if data and data.autoSync ~= nil then
		autoSync = data.autoSync
	else
		autoSync = false
	end

	local v3 = Zones.new({
		isDynamic = isDynamic,
		metadata = metadata,
		autoSync = autoSync
	})
	local v4 = {}

	local function onAdded(part)
		if part:IsA("BasePart") and not v4[part] then
			local v5 = Zone.fromPart(part, {
				isDynamic = isDynamic,
				metadata = v3.metadata
			})
			v4[part] = v5
			v3:add(v5)
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function onRemoved(k)
		local v5 = v4[k]

		if v5 then
			v4[k] = nil
			v5:destroy()
		end
	end

	local descendantAddedConnection = folder.DescendantAdded:Connect(onAdded)
	local descendantRemovingConnection = folder.DescendantRemoving:Connect(onRemoved)

	for _, descendant in folder:GetDescendants() do
		onAdded(descendant)
	end

	v3:onDestroy(function()
		descendantAddedConnection:Disconnect()
		descendantRemovingConnection:Disconnect()

		for k, _ in v4 do
			onRemoved(k) -- equivalent call inferred; original call site unknown
		end

		table.clear(v4)
	end)
	return v3
end

function Zone.fromTag(tag: string, data)
	local isDynamic

	if data and data.isDynamic ~= nil then
		isDynamic = data.isDynamic
	else
		isDynamic = false
	end

	local metadata

	if data and data.metadata ~= nil then
		metadata = data.metadata
	end

	local autoSync

	if data and data.autoSync ~= nil then
		autoSync = data.autoSync
	else
		autoSync = false
	end

	local v2 = Zones.new({
		isDynamic = isDynamic,
		metadata = metadata,
		autoSync = autoSync
	})
	local v3 = {}
	local v4 = {}
	local v5 = {}
	local v6 = {}

	local function addPart(part)
		local v7 = (v6[part] or 0) + 1
		v6[part] = v7

		if v7 == 1 then
			local v8 = Zone.fromPart(part, {
				isDynamic = isDynamic,
				metadata = v2.metadata,
				autoSync = autoSync
			})
			v5[part] = v8
			v2:add(v8)
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function removePart(part)
		local v7 = (v6[part] or 0) - 1

		if v7 <= 0 then
			v6[part] = nil
			local v8 = v5[part]

			if v8 then
				v5[part] = nil
				v8:destroy()
			end
		else
			v6[part] = v7
		end
	end

	local function processTaggedInstance(part)
		if part:IsDescendantOf(workspace) then
			if part:IsA("BasePart") then
				addPart(part)
			elseif not v4[part] then
				v4[part] = { part.DescendantAdded:Connect(function(part2)
						if part2:IsA("BasePart") then
							addPart(part2)
						end
					end), (part.DescendantRemoving:Connect(function(part2)
						if part2:IsA("BasePart") then
							removePart(part2) -- equivalent call inferred; original call site unknown
						end
					end)) }

				for _, part2 in part:GetDescendants() do
					if part2:IsA("BasePart") then
						addPart(part2)
					end
				end
			end
		elseif part:IsA("BasePart") then
			removePart(part) -- equivalent call inferred; original call site unknown
		else
			local v7 = v4[part]

			if v7 then
				v7[1]:Disconnect()
				v7[2]:Disconnect()
				v4[part] = nil
			end

			for _, part2 in part:GetDescendants() do
				if not part2:IsA("BasePart") then
					continue
				end

				removePart(part2) -- equivalent call inferred; original call site unknown
			end
		end
	end

	local function startWatching(instance)
		if v3[instance] then
			return
		end

		v3[instance] = instance.AncestryChanged:Connect(function()
			processTaggedInstance(instance)
		end)
		processTaggedInstance(instance)
	end

	local function stopWatching(part)
		local connection = v3[part]

		if connection then
			connection:Disconnect()
			v3[part] = nil
		end

		if part:IsA("BasePart") then
			removePart(part) -- equivalent call inferred; original call site unknown
		else
			local v7 = v4[part]

			if v7 then
				v7[1]:Disconnect()
				v7[2]:Disconnect()
				v4[part] = nil
			end

			for _, part2 in part:GetDescendants() do
				if not part2:IsA("BasePart") then
					continue
				end

				removePart(part2) -- equivalent call inferred; original call site unknown
			end
		end
	end

	local connection = CollectionService:GetInstanceAddedSignal(tag):Connect(startWatching)
	local connection2 = CollectionService:GetInstanceRemovedSignal(tag):Connect(stopWatching)

	for _, v7 in CollectionService:GetTagged(tag) do
		if v3[v7] then
			continue
		end

		local v8 = v7
		v3[v7] = v7.AncestryChanged:Connect(function()
			processTaggedInstance(v8)
		end)
		processTaggedInstance(v7)
	end

	v2:onDestroy(function()
		connection:Disconnect()
		connection2:Disconnect()

		for k in v3 do
			stopWatching(k)
		end

		table.clear(v3)
		table.clear(v4)
		table.clear(v5)
		table.clear(v6)
	end)
	return v2
end

function Zone.attach(p, p2)
	local ids = State.zoneAttachedObservers[p.id] or {}
	State.zoneAttachedObservers[p.id] = ids

	if not table.find(ids, p2.id) then
		table.insert(ids, p2.id)
		updateObserverZoneCount(p2.id, p.dynamic, 1)
	end

	if p.dynamic then
		State.dynamicVersion += 1
		return p
	else
		State.staticVersion += 1
		return p
	end
end

function Zone.detach(p, p2)
	local zoneAttachedObserver = State.zoneAttachedObservers[p.id]

	if not zoneAttachedObserver then
		return p
	end

	local index = table.find(zoneAttachedObserver, p2.id)

	if index then
		local count = #zoneAttachedObserver

		if index ~= count then
			zoneAttachedObserver[index] = zoneAttachedObserver[count]
		end

		zoneAttachedObserver[count] = nil
		updateObserverZoneCount(p2.id, p.dynamic, -1)
	end

	if #zoneAttachedObserver == 0 then
		State.zoneAttachedObservers[p.id] = nil
	end

	if p.dynamic then
		State.dynamicVersion += 1
		return p
	else
		State.staticVersion += 1
		return p
	end
end

function Zone:setAutoSync(autoSync: boolean)
	if self.autoSync == autoSync then
		return self
	end

	self.autoSync = autoSync

	if autoSync then
		if not self.dynamic then
			self:setDynamic(true)
		end

		if self.reference then
			setupAutoSync(self, self.reference)
			return self
		end

		Log.warn("Cannot autoSync Zone %d without a tracked reference.", nil, self.id)
	else
		clearAutoSync(self) -- equivalent call inferred; original call site unknown
	end

	return self
end

function Zone:setReference(reference)
	self.reference = reference

	if not self.autoSync then
		return self
	end

	clearAutoSync(self) -- equivalent call inferred; original call site unknown

	if reference then
		setupAutoSync(self, reference)
	end

	return self
end

function Zone:sync()
	local reference = self.reference

	if not reference then
		Log.warn("Zone:sync failed for Zone %d. No reference found.", nil, self.id)
		return self
	end

	local id = self.id

	if reference:IsA("BasePart") then
		local cFrame = reference.CFrame
		local v2 = reference.ExtentsSize * 0.5
		local shapeEnumValue = getShapeEnumValue(reference)

		if self.dynamic then
			local flag

			if dynamicCFrames[id] == cFrame then
				flag = false
			else
				dynamicCFrames[id] = cFrame
				flag = true
			end

			if dynamicHalfSizes[id] ~= v2 then
				dynamicHalfSizes[id] = v2
				flag = true
			end

			if dynamicTypes[id] ~= shapeEnumValue then
				dynamicTypes[id] = shapeEnumValue
				flag = true
			end

			if flag then
				State.pendingDynamicRebuild = true
				return self
			end
		else
			local flag

			if staticCFrames[id] == cFrame then
				flag = false
			else
				staticCFrames[id] = cFrame
				flag = true
			end

			if staticHalfSizes[id] ~= v2 then
				staticHalfSizes[id] = v2
				flag = true
			end

			if staticTypes[id] ~= shapeEnumValue then
				staticTypes[id] = shapeEnumValue
				flag = true
			end

			if flag then
				State.pendingStaticRebuild = true
			end
		end

		return self
	else
		if not (reference:IsA("Attachment") or reference:IsA("Bone")) then
			return self
		end

		local worldCFrame = reference.WorldCFrame

		if self.dynamic then
			if dynamicCFrames[id] == worldCFrame then
				return self
			end

			dynamicCFrames[id] = worldCFrame
			State.pendingDynamicRebuild = true
		else
			if staticCFrames[id] == worldCFrame then
				return self
			end

			staticCFrames[id] = worldCFrame
			State.pendingStaticRebuild = true
		end

		return self
	end
end

function Zone:setDynamic(dynamic: boolean)
	if self.dynamic == dynamic then
		return self
	end

	local id = self.id
	self.dynamic = dynamic
	local zoneAttachedObserver = State.zoneAttachedObservers[id]

	if zoneAttachedObserver then
		for _, v2 in zoneAttachedObserver do
			updateObserverZoneCount(v2, not dynamic, -1)
			updateObserverZoneCount(v2, dynamic, 1)
		end
	end

	if dynamic then
		dynamicCFrames[id] = staticCFrames[id]
		dynamicHalfSizes[id] = staticHalfSizes[id]
		dynamicTypes[id] = staticTypes[id]
		staticCFrames[id] = nil
		staticHalfSizes[id] = nil
		staticTypes[id] = nil
	else
		if self.autoSync then
			self:setAutoSync(false)
		end

		staticCFrames[id] = dynamicCFrames[id]
		staticHalfSizes[id] = dynamicHalfSizes[id]
		staticTypes[id] = dynamicTypes[id]
		dynamicCFrames[id] = nil
		dynamicHalfSizes[id] = nil
		dynamicTypes[id] = nil
	end

	State.pendingStaticRebuild = true
	State.pendingDynamicRebuild = true
	return self
end

function Zone:setCFrame(cframe: CFrame)
	if self.dynamic then
		dynamicCFrames[self.id] = cframe
		State.pendingDynamicRebuild = true
	else
		staticCFrames[self.id] = cframe
		State.pendingStaticRebuild = true
	end

	return self
end

function Zone:setPosition(vector: Vector3)
	return self:setCFrame((self.dynamic and dynamicCFrames[self.id] or staticCFrames[self.id]).Rotation + vector)
end

function Zone.setSize(p, vector: Vector3)
	local v2 = vector * 0.5

	if p.dynamic then
		dynamicHalfSizes[p.id] = v2
		State.pendingDynamicRebuild = true
	else
		staticHalfSizes[p.id] = v2
		State.pendingStaticRebuild = true
	end

	return p
end

function Zone.setShape(p, p2)
	local value = Enum.PartType.Block.Value
	local v2 = v[p2]

	if v2 then
		value = v2
	else
		Log.warn("Invalid shape '%s'. Defaulting to Block.", nil, (tostring(p2)))
	end

	if p.dynamic then
		dynamicTypes[p.id] = value
	else
		staticTypes[p.id] = value
	end

	if p.dynamic then
		State.dynamicVersion += 1
		return p
	else
		State.staticVersion += 1
		return p
	end
end

function Zone:setMetadata(metadata)
	self.metadata = metadata
	return self
end

function Zone.getMetadata(p)
	return p.metadata
end

function Zone.getId(p)
	return p.id
end

function Zone.getReference(p)
	return p.reference
end

function Zone.getPosition(p)
	return (p.dynamic and dynamicCFrames[p.id] or staticCFrames[p.id]).Position
end

function Zone.getCFrame(p)
	return p.dynamic and dynamicCFrames[p.id] or staticCFrames[p.id]
end

function Zone.getSize(p)
	return (p.dynamic and dynamicHalfSizes[p.id] or staticHalfSizes[p.id]) * 2
end

function Zone.getShape(p)
	local v2 = p.dynamic and dynamicTypes[p.id] or staticTypes[p.id]

	if v2 == Enum.PartType.Block.Value then
		return "Block"
	end

	if v2 == Enum.PartType.Ball.Value then
		return "Ball"
	end

	if v2 == Enum.PartType.Cylinder.Value then
		return "Cylinder"
	end

	if v2 == Enum.PartType.Wedge.Value then
		return "Wedge"
	end

	if v2 == Enum.PartType.CornerWedge.Value then
		return "CornerWedge"
	end

	return "Block"
end

function Zone.isPointInside(p, vector: Vector3)
	local id = p.id

	if p.dynamic then
		return isPointInShape(vector, dynamicCFrames[id], dynamicHalfSizes[id], dynamicTypes[id])
	end

	return isPointInShape(vector, staticCFrames[id], staticHalfSizes[id], staticTypes[id])
end

function Zone.isDynamic(p)
	return p.dynamic
end

function Zone:onDestroy(callback)
	if not self.onDestroyCallbacks then
		self.onDestroyCallbacks = {}
	end

	table.insert(self.onDestroyCallbacks, callback)
	return function()
		local index = table.find(self.onDestroyCallbacks, callback)

		if index then
			table.remove(self.onDestroyCallbacks, index)
		end
	end
end

function Zone:destroy()
	clearAutoSync(self) -- equivalent call inferred; original call site unknown
	local id = self.id
	local zoneAttachedObserver = State.zoneAttachedObservers[id]

	if zoneAttachedObserver then
		for _, v2 in zoneAttachedObserver do
			updateObserverZoneCount(v2, self.dynamic, -1)
			local observerTrackingEntity = State.observerTrackingEntities[v2]

			if not observerTrackingEntity then
				continue
			end

			for k, _ in observerTrackingEntity do
				local v3 = State.entityData[k]

				if not (v3 and v3.activeObserverMemberships[v2] == id) then
					continue
				end

				v3.activeObserverMemberships[v2] = nil
				observerTrackingEntity[k] = nil
				local observerExitedCallback = State.observerExitedCallbacks[v2]

				if not observerExitedCallback then
					continue
				end

				local v4 = State.observerSafety[v2]
				local v5 = State.entityToReference[k] or k

				for _, callback in observerExitedCallback do
					if v4 then
						task.spawn(callback, v5, self, k)
					else
						callback(v5, self, k)
					end
				end
			end
		end
	end

	State.zoneAttachedObservers[id] = nil

	if self.onDestroyCallbacks then
		local clone = table.clone(self.onDestroyCallbacks)

		for _, callback in clone do
			task.spawn(callback)
		end

		table.clear(self.onDestroyCallbacks)
	end

	State.zoneIdToZoneObj[id] = nil

	if self.dynamic then
		dynamicCFrames[id] = nil
		dynamicHalfSizes[id] = nil
		dynamicTypes[id] = nil
		State.pendingDynamicRebuild = true
	else
		staticCFrames[id] = nil
		staticHalfSizes[id] = nil
		staticTypes[id] = nil
		State.pendingStaticRebuild = true
	end

	setmetatable(self, nil)
end

return Zone