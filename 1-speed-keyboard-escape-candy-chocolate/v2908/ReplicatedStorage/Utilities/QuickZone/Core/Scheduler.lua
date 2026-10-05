local RunService = game:GetService("RunService")
local Config = require(script.Parent.Parent.Config)
require(script.Parent.Parent.Types)
local Geometry = require(script.Parent.Parent.Utils.Geometry)
local LinearBVH = require(script.Parent.Parent.Utils.LinearBVH)
local Log = require(script.Parent.Parent.Utils.Log)
local State = require(script.Parent.State)
local queryPoint = LinearBVH.queryPoint
local isPointInShape = Geometry.isPointInShape
local staticCFrames = State.staticCFrames
local staticHalfSizes = State.staticHalfSizes
local staticTypes = State.staticTypes
local dynamicCFrames = State.dynamicCFrames
local dynamicHalfSizes = State.dynamicHalfSizes
local dynamicTypes = State.dynamicTypes
local zoneIdToZoneObj = State.zoneIdToZoneObj
local zoneAttachedObservers = State.zoneAttachedObservers
local autoSyncZones = State.autoSyncZones
local observerPriorityMap = State.observerPriorityMap
local observerTrackingEntities = State.observerTrackingEntities
local observerEnteredCallbacks = State.observerEnteredCallbacks
local observerExitedCallbacks = State.observerExitedCallbacks
local observerTransitionedCallbacks = State.observerTransitionedCallbacks
local observerEnabled = State.observerEnabled
local observerSafety = State.observerSafety
local observerPrecisionSq = State.observerPrecisionSq
local observerUpdateRate = State.observerUpdateRate
local observerStaticCount = State.observerStaticCount
local observerDynamicCount = State.observerDynamicCount
local entityToReference = State.entityToReference
local entityData = State.entityData
local entityToObservers = State.entityToObservers
local entityToGroups = State.entityToGroups
local groupToObservers = State.groupToObservers
local dirtyProfiles = State.dirtyProfiles
local dirtyTopology = State.dirtyTopology
local staticTree = State.staticTree
local dynamicTree = State.dynamicTree
local vector = nil
local count = 0
local v = nil
local v2 = table.create(16)
local v3 = table.create(16)
local v4 = table.create(16)
local v5 = nil
local activeObserverMemberships = nil
local frameBudget = Config.Scheduler.frameBudget
local autoSyncRate = Config.Scheduler.autoSyncRate
local total = 0
local postSimulationConnection = nil
local bucketList = State.bucketList
local buckets = State.buckets
local v6 = 1
local v7 = {}
local POS = Config.Strategy.POS
local PRIM = Config.Strategy.PRIM
local WORLD = Config.Strategy.WORLD
local CFRAME = Config.Strategy.CFRAME
local TRANSFORM = Config.Strategy.TRANSFORM
local PIVOT = Config.Strategy.PIVOT

local function processProfileChange(k)
	local entityToGroup = entityToGroups[k]

	if not entityToGroup then
		return
	end

	local entityToObserver = entityToObservers[k]

	if entityToObserver then
		table.clear(entityToObserver)
	else
		entityToObserver = {}
	end

	local precisionSq = 1e999
	local updateRate2 = 0

	for k2, _ in entityToGroup do
		local groupToObserver = groupToObservers[k2]

		if not groupToObserver then
			continue
		end

		for k3, _ in groupToObserver do
			entityToObserver[k3] = true
			local v10 = observerPrecisionSq[k3]
			local v11 = observerUpdateRate[k3]

			if v10 < precisionSq then
				precisionSq = v10
			end

			if updateRate2 < v11 then
				updateRate2 = v11
			end
		end
	end

	local v10 = entityData[k]
	local updateRate = v10.updateRate

	if updateRate ~= updateRate2 then
		if updateRate and updateRate > 0 and buckets[updateRate] then
			local bucket = buckets[updateRate]
			local bucketIndex = v10.bucketIndex
			local count2 = #bucket
			local v11 = bucket[count2]

			if bucketIndex ~= count2 then
				bucket[bucketIndex] = v11

				if entityData[v11] then
					entityData[v11].bucketIndex = bucketIndex
				end
			end

			bucket[count2] = nil

			if #bucket == 0 then
				buckets[updateRate] = nil
				local index = table.find(bucketList, updateRate)

				if index then
					table.remove(bucketList, index)
				end
			end
		end

		if updateRate2 > 0 then
			if not buckets[updateRate2] then
				buckets[updateRate2] = {}
				table.insert(bucketList, updateRate2)
				table.sort(bucketList, function(a: number, b: number)
					return b < a
				end)
			end

			local bucket = buckets[updateRate2]
			local bucketIndex = #bucket + 1
			bucket[bucketIndex] = k
			v10.bucketIndex = bucketIndex
		else
			v10.bucketIndex = 0
		end

		v10.updateRate = updateRate2
	end

	if updateRate2 > 0 then
		v10.precisionSq = precisionSq
		entityToObservers[k] = entityToObserver
	else
		entityToObservers[k] = nil
	end
end

local function processTopologyChange(k)
	local v8 = entityData[k]

	if not v8 then
		return
	end

	local flag = false
	local flag2 = false
	local entityToObserver = entityToObservers[k]

	if entityToObserver then
		for k2, _ in entityToObserver do
			flag = (observerStaticCount[k2] or 0) > 0 or flag
			flag2 = (observerDynamicCount[k2] or 0) > 0 or flag2

			if flag and flag2 then
				break
			end
		end
	end

	v8.needsStatic = flag
	v8.needsDynamic = flag2
end

local function processZoneHit(p: number)
	local zoneAttachedObserver = zoneAttachedObservers[p]

	if not zoneAttachedObserver then
		return
	end

	for _, v8 in zoneAttachedObserver do
		if not (v5[v8] and observerEnabled[v8] ~= false) then
			continue
		end

		local v9 = v2[v8]
		local v10 = observerPriorityMap[v8] or 0

		if v9 then
			if v9 < v10 then
				v3[v8] = p
				v2[v8] = v10

				if v < v10 then
					v = v10
				end
			elseif v10 == v9 and activeObserverMemberships[v8] == p then
				v3[v8] = p
			end
		else
			count += 1
			v4[count] = v8
			v3[v8] = p
			v2[v8] = v10

			if v < v10 then
				v = v10
			end
		end
	end
end

local function queryCallbackStatic(p: number)
	if isPointInShape(vector, staticCFrames[p], staticHalfSizes[p], staticTypes[p]) then
		processZoneHit(p)
	end
end

local function queryCallbackDynamic(p: number)
	if isPointInShape(vector, dynamicCFrames[p], dynamicHalfSizes[p], dynamicTypes[p]) then
		processZoneHit(p)
	end
end

local function fireCallback(items, p, p2, p3, flag: boolean)
	if flag then
		for _, callback in items do
			task.spawn(callback, p, p2, p3)
		end
	else
		for _, item in items do
			item(p, p2, p3)
		end
	end
end

local Scheduler = {}

function Scheduler.update(p: number)
	local lastTime = os.clock()

	for k, _ in dirtyProfiles do
		dirtyProfiles[k] = nil

		if entityData[k] then
			processProfileChange(k)
		end
	end

	for k, _ in dirtyTopology do
		dirtyTopology[k] = nil

		if entityData[k] then
			processTopologyChange(k)
		end
	end

	if autoSyncRate > 0 then
		local v8 = 1 / autoSyncRate
		total += p

		if v8 <= total then
			total = 0
			local flag = false

			for k, autoSyncZone in autoSyncZones do
				local reference = autoSyncZone.reference

				if not reference then
					continue
				end

				local worldCFrame = reference:IsA("Attachment") and reference.WorldCFrame or reference.CFrame

				if dynamicCFrames[k] == worldCFrame then
					continue
				end

				dynamicCFrames[k] = worldCFrame
				flag = true
			end

			if flag then
				State.pendingDynamicRebuild = true
			end
		end
	end

	Scheduler.rebuildTrees()
	local v8 = os.clock() - lastTime

	if frameBudget < v8 then
		return
	end

	local count2 = #bucketList

	if count2 == 0 then
		return
	end

	if count2 < v6 then
		v6 = 1
	end

	local dynamicVersion = State.dynamicVersion
	local staticVersion = State.staticVersion
	local logicVersion = State.logicVersion

	for _ = 1, count2 do
		local v9 = bucketList[v6]
		v6 = v6 % count2 + 1
		local bucket = buckets[v9]
		local count3 = #bucket

		if count3 == 0 then
			continue
		end

		local v10 = math.clamp(math.ceil(count3 * v9 * p), 1, count3)
		local v11 = v7[v9] or 1
		local v12 = count3 < v11 and 1 or v11
		local count4 = 0
		local v13 = 32

		while count4 < v10 do
			local v14 = bucket[v12]
			local v15 = entityData[v14]
			local position = nil
			local strategy = v15.strategy

			if strategy == POS then
				position = v14.Position
			elseif strategy == WORLD then
				position = v14.WorldPosition
			elseif strategy == CFRAME then
				position = v14.CFrame.Position
			elseif strategy == TRANSFORM then
				position = v14.Transform.Position
			elseif strategy == PRIM then
				local primaryPart = v14.PrimaryPart
				position = primaryPart and primaryPart.Position or v14:GetPivot().Position
			elseif strategy == PIVOT then
				position = v14:GetPivot().Position
			end

			local needsStatic = v15.needsStatic
			local needsDynamic = v15.needsDynamic
			local v17

			if v15.logicVersion == logicVersion and (not needsDynamic or v15.dynamicVersion == dynamicVersion) and (not needsStatic or v15.staticVersion == staticVersion) then
				local lastPosition = v15.lastPosition
				local v18 = position.X - lastPosition.X
				local v19 = position.Y - lastPosition.Y
				local v20 = position.Z - lastPosition.Z
				v17 = v18 * v18 + v19 * v19 + v20 * v20 >= v15.precisionSq or false
			else
				v17 = true
			end

			if v17 then
				v15.lastPosition = position
				v15.dynamicVersion = dynamicVersion
				v15.logicVersion = logicVersion
				v15.staticVersion = staticVersion
				v5 = entityToObservers[v14]
				activeObserverMemberships = v15.activeObserverMemberships
				vector = position
				count = 0
				v = -1e999

				if needsDynamic then
					queryPoint(dynamicTree, position, queryCallbackDynamic)
				end

				if needsStatic then
					queryPoint(staticTree, position, queryCallbackStatic)
				end

				local activeObserverMemberships2 = v15.activeObserverMemberships

				for k, activeObserverMembership in activeObserverMemberships2 do
					local v18 = v2[k]

					if v18 and v <= v18 then
						continue
					end

					activeObserverMemberships2[k] = nil

					if observerTrackingEntities[k] then
						observerTrackingEntities[k][v14] = nil
					end

					local observerExitedCallback = observerExitedCallbacks[k]

					if not observerExitedCallback then
						continue
					end

					local v19 = observerSafety[k]
					local v20 = zoneIdToZoneObj[activeObserverMembership]
					fireCallback(observerExitedCallback, entityToReference[v14] or v14, v20, v14, v19)
				end

				for i = 1, count do
					local v18 = v4[i]
					local v19 = v2[v18]
					local v20 = v3[v18]
					v2[v18] = nil
					v3[v18] = nil
					v4[i] = nil

					if not observerTrackingEntities[v18] or v19 < v then
						continue
					end

					local activeObserverMembership = activeObserverMemberships2[v18]

					if activeObserverMembership == v20 then
						continue
					end

					activeObserverMemberships2[v18] = v20
					local v21 = observerSafety[v18]

					if activeObserverMembership then
						local observerTransitionedCallback = observerTransitionedCallbacks[v18]

						if observerTransitionedCallback then
							local v22 = zoneIdToZoneObj[v20]
							fireCallback(observerTransitionedCallback, entityToReference[v14] or v14, v22, v14, v21)
						end
					else
						observerTrackingEntities[v18][v14] = true
						local observerEnteredCallback = observerEnteredCallbacks[v18]

						if observerEnteredCallback then
							local v22 = zoneIdToZoneObj[v20]
							fireCallback(observerEnteredCallback, entityToReference[v14] or v14, v22, v14, v21)
						end
					end
				end
			end

			local v18 = v12 + 1
			v12 = count3 < v18 and 1 or v18
			count4 += 1
			v13 -= 1

			if v13 ~= 0 then
				continue
			end

			local v19 = os.clock() - lastTime

			if frameBudget < v19 then
				break
			else
				v13 = 32
			end
		end

		v7[v9] = v12
		local v14 = os.clock() - lastTime

		if frameBudget < v14 then
			break
		end
	end
end

function Scheduler.setEnabled(flag: boolean)
	if flag then
		if not postSimulationConnection then
			postSimulationConnection = RunService.PostSimulation:Connect(Scheduler.update)
		end
	elseif postSimulationConnection then
		postSimulationConnection:Disconnect()
		postSimulationConnection = nil
	end
end

function Scheduler.setAutoSyncRate(p: number)
	if p <= 0 then
		autoSyncRate = 0
	else
		autoSyncRate = p
	end
end

function Scheduler.setFrameBudget(p: number)
	if p <= 0 then
		Log.fatal("frameBudget must be greater than 0.", nil)
	end

	frameBudget = p
end

function Scheduler.rebuildTrees()
	if State.pendingDynamicRebuild then
		LinearBVH.build(dynamicTree, dynamicCFrames, dynamicHalfSizes)
		State.pendingDynamicRebuild = false
		State.dynamicVersion += 1
	end

	if State.pendingStaticRebuild then
		LinearBVH.build(staticTree, staticCFrames, staticHalfSizes)
		State.pendingStaticRebuild = false
		State.staticVersion += 1
	end
end

Scheduler.setEnabled(Config.Scheduler.enabled)
return Scheduler