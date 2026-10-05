local RunService = game:GetService("RunService")
require(script.Types)
local Config = require(script.Config)
local Scheduler = require(script.Core.Scheduler)
local State = require(script.Core.State)
local Geometry = require(script.Utils.Geometry)
local LinearBVH = require(script.Utils.LinearBVH)
local queryPoint = LinearBVH.queryPoint
local isPointInShape = Geometry.isPointInShape
local zoneAttachedObservers = State.zoneAttachedObservers
local zoneIdToZoneObj = State.zoneIdToZoneObj
local entityData = State.entityData
local observerIdToObserverObj = State.observerIdToObserverObj
local groups = State.groups
local entityToGroups = State.entityToGroups
local entityToReference = State.entityToReference
local referenceToEntity = State.referenceToEntity
local staticCFrames = State.staticCFrames
local staticHalfSizes = State.staticHalfSizes
local staticTypes = State.staticTypes
local dynamicCFrames = State.dynamicCFrames
local dynamicHalfSizes = State.dynamicHalfSizes
local dynamicTypes = State.dynamicTypes
local dynamicTree = State.dynamicTree
local staticTree = State.staticTree
local connection = nil
local parent = nil
local v2 = {}
local QuickZone = {}
QuickZone.Zone = require(script.Classes.Zone)
QuickZone.Observer = require(script.Classes.Observer)
QuickZone.Group = require(script.Classes.Group)

function QuickZone:configure(data)
	if data.enabled ~= nil then
		self:setEnabled(data.enabled)
	end

	if data.autoSyncRate ~= nil then
		self:setAutoSyncRate(data.autoSyncRate)
	end

	if data.frameBudget ~= nil then
		self:setFrameBudget(data.frameBudget)
	end

	return self
end

function QuickZone.setEnabled(p, flag: boolean)
	Scheduler.setEnabled(flag)
	return p
end

function QuickZone.update(p, p2: number)
	Scheduler.update(p2)
	return p
end

function QuickZone.setAutoSyncRate(p, p2: number)
	Scheduler.setAutoSyncRate(p2)
	return p
end

function QuickZone.rebuild(p)
	Scheduler.rebuildTrees()
	return p
end

function QuickZone.setReference(p, p2, player)
	local player2 = entityToReference[p2]

	if player == nil then
		if typeof(player2) ~= "Instance" or not player2:IsA("Player") then
			if player2 then
				referenceToEntity[player2] = nil
			end

			entityToReference[p2] = nil
		end
	elseif typeof(player) ~= "Instance" or not player:IsA("Player") then
		entityToReference[p2] = player
		referenceToEntity[player] = p2
	end

	return p
end

function QuickZone.setFrameBudget(p, p2: number)
	local v3 = p2 / 1000
	Scheduler.setFrameBudget(v3)
	return p
end

function QuickZone.removeEntity(p, p2)
	local v3 = referenceToEntity[p2] or p2
	local entityToGroup = entityToGroups[v3]

	if not entityToGroup then
		return p
	end

	local v4 = {}

	for k in entityToGroup do
		table.insert(v4, k)
	end

	for _, v5 in v4 do
		local group = groups[v5]

		if group then
			group:remove(v3)
		end
	end

	return p
end

function QuickZone.getEntityOfReference(_, instance)
	local v3 = referenceToEntity[instance]

	if v3 then
		return v3
	end

	if typeof(instance) == "Instance" then
		if instance:IsA("BasePart") or instance:IsA("Attachment") or instance:IsA("Bone") or instance:IsA("Camera") or instance:IsA("Model") then
			return instance
		end
	elseif typeof(instance) == "table" and (instance.Position or instance.CFrame or instance.WorldPosition or instance.GetPivot) then
		return instance
	end

	return nil
end

function QuickZone.getReferenceOfEntity(_, p)
	return entityToReference[p] or p
end

function QuickZone.getObservers(_)
	local result = {}

	for _, v3 in observerIdToObserverObj do
		table.insert(result, v3)
	end

	return result
end

function QuickZone.getGroups(_)
	local groups2 = {}

	for _, group in groups do
		table.insert(groups2, group)
	end

	return groups2
end

function QuickZone.getZones(_)
	local result = {}

	for _, v3 in zoneIdToZoneObj do
		table.insert(result, v3)
	end

	return result
end

function QuickZone.getEntities(_)
	local count = 0
	local result = {}

	for k in entityData do
		count += 1
		result[count] = entityToReference[k] or k
	end

	return result
end

function QuickZone.getZonesAtPoint(_, vector: Vector3)
	local v3 = {}
	local count = 0
	queryPoint(dynamicTree, vector, function(p)
		local v4 = isPointInShape(vector, dynamicCFrames[p], dynamicHalfSizes[p], dynamicTypes[p]) and zoneIdToZoneObj[p]

		if v4 then
			count += 1
			v3[count] = v4
		end
	end)
	queryPoint(staticTree, vector, function(p)
		local v4 = isPointInShape(vector, staticCFrames[p], staticHalfSizes[p], staticTypes[p]) and zoneIdToZoneObj[p]

		if v4 then
			count += 1
			v3[count] = v4
		end
	end)
	return v3
end

function QuickZone.getZonesOfEntity(_, p)
	local v4 = entityData[referenceToEntity[p] or p]

	if not (v4 and v4.activeObserverMemberships) then
		return {}
	end

	local v5 = {}
	local result = {}

	for _, activeObserverMembership in v4.activeObserverMemberships do
		if v5[activeObserverMembership] then
			continue
		end

		v5[activeObserverMembership] = true
		local v6 = zoneIdToZoneObj[activeObserverMembership]

		if v6 then
			table.insert(result, v6)
		end
	end

	return result
end

function QuickZone.getGroupsOfEntity(_, p)
	local entityToGroup = entityToGroups[referenceToEntity[p] or p]

	if not entityToGroup then
		return {}
	end

	local count = 0
	local groups2 = {}

	for k in entityToGroup do
		local group = groups[k]

		if not group then
			continue
		end

		count += 1
		groups2[count] = group
	end

	return groups2
end

function QuickZone.iterGroups(_)
	local v3 = nil
	return function()
		v3 = next(groups, v3)
		return v3 and groups[v3] or nil
	end
end

function QuickZone.iterZones(_)
	local v3 = nil
	return function()
		v3 = next(zoneIdToZoneObj, v3)
		return v3 and zoneIdToZoneObj[v3] or nil
	end
end

function QuickZone.iterEntities(_)
	local v3 = nil
	return function()
		v3 = next(entityData, v3)
		return v3 and (entityToReference[v3] or v3)
	end
end

function QuickZone.iterObservers(_)
	local v3 = nil
	return function()
		v3 = next(observerIdToObserverObj, v3)
		return v3 and observerIdToObserverObj[v3] or nil
	end
end

function QuickZone.iterGroupsOfEntity(_, p)
	local entityToGroup = entityToGroups[referenceToEntity[p] or p]

	if not entityToGroup then
		return function()
			return nil
		end
	end

	local v4 = nil
	return function()
		v4 = next(entityToGroup, v4)
		return v4 and groups[v4] or nil
	end
end

function QuickZone.iterZonesOfEntity(_, p)
	local v4 = entityData[referenceToEntity[p] or p]

	if not (v4 and v4.activeObserverMemberships) then
		return function()
			return nil
		end
	end

	local activeObserverMemberships = v4.activeObserverMemberships
	local v5 = {}
	local v6 = nil
	return function()
		while true do
			v6 = next(activeObserverMemberships, v6)

			if not v6 then
				break
			end

			local activeObserverMembership = activeObserverMemberships[v6]

			if v5[activeObserverMembership] then
				continue
			end

			v5[activeObserverMembership] = true
			local v7 = zoneIdToZoneObj[activeObserverMembership]

			if v7 then
				return v7
			end
		end

		return nil
	end
end

function QuickZone.iterZonesAtPoint(_, vector: Vector3)
	local nodes = dynamicTree.nodes
	local count = dynamicTree.count or 0
	local nodes2 = staticTree.nodes
	local count2 = staticTree.count or 0
	local X = vector.X
	local Y = vector.Y
	local Z = vector.Z
	local skipIndex = 1
	local flag = true
	return function()
		if flag then
			while skipIndex <= count do
				local node = nodes[skipIndex]
				local min = node.min
				local max = node.max

				if X < min.X or X > max.X or Y < min.Y or Y > max.Y or Z < min.Z or Z > max.Z then
					skipIndex = node.skipIndex
				else
					skipIndex += 1
					local id = node.id

					if id > 0 and isPointInShape(vector, dynamicCFrames[id], dynamicHalfSizes[id], dynamicTypes[id]) then
						return zoneIdToZoneObj[id]
					end
				end
			end

			flag = false
			skipIndex = 1
		end

		if flag then
			return nil
		end

		while skipIndex <= count2 do
			local node = nodes2[skipIndex]
			local min = node.min
			local max = node.max

			if X < min.X or X > max.X or Y < min.Y or Y > max.Y or Z < min.Z or Z > max.Z then
				skipIndex = node.skipIndex
			else
				skipIndex += 1
				local id = node.id

				if id > 0 and isPointInShape(vector, staticCFrames[id], staticHalfSizes[id], staticTypes[id]) then
					return zoneIdToZoneObj[id]
				end
			end
		end

		return nil
	end
end

function QuickZone.visualize(p, flag: boolean)
	if connection then
		connection:Disconnect()
		connection = nil
	end

	if parent then
		parent:Destroy()
		parent = nil
	end

	table.clear(v2)

	if not flag then
		return p
	end

	local folder = Instance.new("Folder")
	folder.Name = "QuickZone_Debug_Visuals"
	folder.Parent = workspace
	parent = folder

	local function getOrCreateVisual(k: number)
		local v3 = v2[k]
		local shape = zoneIdToZoneObj[k]:getShape()

		if v3 and v3.shape ~= shape then
			v3.adornment:Destroy()
			v2[k] = nil
		end

		if v3 then
			return v3
		end

		local adornment

		if shape == "Ball" then
			adornment = Instance.new("SphereHandleAdornment")
		elseif shape == "Cylinder" then
			adornment = Instance.new("CylinderHandleAdornment")
		else
			adornment = Instance.new("BoxHandleAdornment")
		end

		adornment.Name = "Zone_" .. k
		adornment.Adornee = workspace.Terrain
		adornment.Transparency = Config.Debug.transparency
		adornment.AlwaysOnTop = true
		adornment.ZIndex = 1
		adornment.Parent = parent
		v3 = {
			adornment = adornment,
			shape = shape
		}
		v2[k] = v3
		return v3
	end

	connection = (RunService:IsClient() and RunService.PreRender or RunService.Heartbeat):Connect(function()
		if not parent then
			return
		end

		for k, staticCFrame in staticCFrames do
			local visual = getOrCreateVisual(k)
			local adornment = visual.adornment
			local staticHalfSiz = staticHalfSizes[k]
			local size = staticHalfSiz * 2
			local zoneAttachedObserver = zoneAttachedObservers[k]
			local staticActive = zoneAttachedObserver and next(zoneAttachedObserver) ~= nil and Config.Debug.staticActive or Config.Debug.staticInactive

			if visual.shape == "Ball" then
				adornment.Radius = math.max(staticHalfSiz.X, staticHalfSiz.Y, staticHalfSiz.Z)
				adornment.CFrame = staticCFrame
			elseif visual.shape == "Cylinder" then
				adornment.Radius = math.max(staticHalfSiz.X, staticHalfSiz.Z)
				adornment.Height = size.X
				adornment.CFrame = staticCFrame * CFrame.Angles(0, 1.5707963267948966, 0)
			else
				adornment.Size = size
				adornment.CFrame = staticCFrame
			end

			adornment.Color3 = staticActive
		end

		for k, dynamicCFrame in dynamicCFrames do
			local visual = getOrCreateVisual(k)
			local adornment = visual.adornment
			local dynamicHalfSiz = dynamicHalfSizes[k]
			local size = dynamicHalfSiz * 2
			local zoneAttachedObserver = zoneAttachedObservers[k]
			local dynamicActive = zoneAttachedObserver and next(zoneAttachedObserver) ~= nil and Config.Debug.dynamicActive or Config.Debug.dynamicInactive

			if visual.shape == "Ball" then
				adornment.Radius = math.max(dynamicHalfSiz.X, dynamicHalfSiz.Y, dynamicHalfSiz.Z)
				adornment.CFrame = dynamicCFrame
			elseif visual.shape == "Cylinder" then
				adornment.Radius = math.max(dynamicHalfSiz.X, dynamicHalfSiz.Z)
				adornment.Height = size.X
				adornment.CFrame = dynamicCFrame * CFrame.Angles(0, 1.5707963267948966, 0)
			else
				adornment.Size = size
				adornment.CFrame = dynamicCFrame
			end

			adornment.Color3 = dynamicActive
		end

		for k, v3 in v2 do
			if staticCFrames[k] or dynamicCFrames[k] then
				continue
			end

			v3.adornment:Destroy()
			v2[k] = nil
		end
	end)
	return p
end

return QuickZone