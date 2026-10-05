local createVector = vector.create
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
require(script.Parent.Parent.Types)
local Config = require(script.Parent.Parent.Config)
local PlayerTracker = require(script.Parent.Parent.Core.PlayerTracker)
local State = require(script.Parent.Parent.Core.State)
local Log = require(script.Parent.Parent.Utils.Log)
local POS = Config.Strategy.POS
local PRIM = Config.Strategy.PRIM
local WORLD = Config.Strategy.WORLD
local CFRAME = Config.Strategy.CFRAME
local TRANSFORM = Config.Strategy.TRANSFORM
local PIVOT = Config.Strategy.PIVOT
local precisionSq = Config.Observer.precision ^ 2
local isClient = RunService:IsClient()
local Group = {}
Group.__index = Group

function Group.new(p)
	local nextGroupId = State.nextGroupId
	State.nextGroupId += 1
	local autoClean = Config.Group.autoClean

	if p and p.autoClean ~= nil then
		autoClean = p.autoClean
	end

	local object = setmetatable({
		id = nextGroupId,
		entities = {},
		entityIndices = {},
		autoClean = autoClean
	}, Group)
	State.groups[nextGroupId] = object
	State.groupToObservers[nextGroupId] = {}
	State.groupEntityCleanups[nextGroupId] = {}

	if p and p.entities then
		object:_addBulk(p.entities)
	end

	return object
end

function Group.fromTag(tag: string)
	local v2 = Group.new({
		autoClean = false,
		entities = nil
	})
	v2.isManaged = true
	local v3 = {}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function checkAncestry(instance)
		if instance:IsDescendantOf(workspace) then
			v2:_add(instance)
		else
			v2:_remove(instance)
		end
	end

	local function startWatching(instance)
		if v3[instance] then
			return
		end

		if not (instance:IsA("BasePart") or instance:IsA("Model") or instance:IsA("Attachment") or instance:IsA("Bone") or instance:IsA("Camera")) then
			return
		end

		v3[instance] = instance.AncestryChanged:Connect(function()
			checkAncestry(instance) -- equivalent call inferred; original call site unknown
		end)
		checkAncestry(instance) -- equivalent call inferred; original call site unknown
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function stopWatching(k)
		local connection = v3[k]

		if connection then
			connection:Disconnect()
			v3[k] = nil
		end

		v2:_remove(k)
	end

	local connection = CollectionService:GetInstanceAddedSignal(tag):Connect(startWatching)
	local connection2 = CollectionService:GetInstanceRemovedSignal(tag):Connect(stopWatching)

	for _, v4 in CollectionService:GetTagged(tag) do
		startWatching(v4)
	end

	v2:onDestroy(function()
		connection:Disconnect()
		connection2:Disconnect()

		for k, _ in v3 do
			stopWatching(k) -- equivalent call inferred; original call site unknown
		end
	end)
	return v2
end

function Group.players()
	local v2 = Group.new({
		autoClean = false,
		entities = nil
	})
	v2.isManaged = true
	local playerAddedConnection = Players.PlayerAdded:Connect(function(player)
		v2:_add(player)
	end)

	for _, v3 in Players:GetPlayers() do
		v2:_add(v3)
	end

	v2:onDestroy(function()
		playerAddedConnection:Disconnect()
	end)
	return v2
end

function Group.localPlayer()
	if not isClient then
		Log.fatal("Group.localPlayer() can only be called on the Client.", nil)
	end

	local v2 = Group.new({
		autoClean = false,
		entities = nil
	})
	v2.isManaged = true
	v2:_add(Players.LocalPlayer)
	return v2
end

function Group:setAutoClean(autoClean: boolean)
	if self.isManaged then
		Log.warn("Cannot set autoClean on a Managed Group. Ignoring request.", nil)
		return self
	end

	if self.autoClean == autoClean then
		return self
	end

	self.autoClean = autoClean
	local groupEntityCleanup = State.groupEntityCleanups[self.id]

	if autoClean then
		for _, entity in self.entities do
			if typeof(entity) ~= "Instance" or groupEntityCleanup[entity] then
				continue
			end

			local v2 = entity
			groupEntityCleanup[entity] = entity.AncestryChanged:Connect(function(p, parent)
				if not parent then
					self:_remove(v2)
				end
			end)
		end
	else
		for k, connection in groupEntityCleanup do
			connection:Disconnect()
			groupEntityCleanup[k] = nil
		end
	end

	return self
end

function Group:add(p)
	if not self.isManaged then
		return self:_add(p)
	end

	Log.warn("Cannot manually add to a Managed Group. Ignoring request.", nil)
	return self
end

function Group:addBulk(p)
	if not self.isManaged then
		return self:_addBulk(p)
	end

	Log.warn("Cannot manually addBulk to a Managed Group. Ignoring request.", nil)
	return self
end

function Group:remove(p)
	if not self.isManaged then
		return self:_remove(p)
	end

	Log.warn("Cannot manually remove from a Managed Group. Ignoring request.", nil)
	return self
end

function Group:removeBulk(p)
	if not self.isManaged then
		return self:_removeBulk(p)
	end

	Log.warn("Cannot manually removeBulk from a Managed Group. Ignoring request.", nil)
	return self
end

function Group:clear()
	if not self.isManaged then
		return self:_clear()
	end

	Log.warn("Cannot clear a Managed Group. Ignoring request.", nil)
	return self
end

function Group.contains(p, p2)
	local v2 = State.referenceToEntity[p2] or p2
	local entityToGroup = State.entityToGroups[v2]
	return entityToGroup and entityToGroup[p.id] == true and true or false
end

function Group.getId(p)
	return p.id
end

function Group.getEntities(p)
	local result = table.create(#p.entities)

	for i, entity in ipairs(p.entities) do
		result[i] = State.entityToReference[entity] or entity
	end

	return result
end

function Group.iterEntities(p)
	local v2 = nil
	return function()
		v2 = next(p.entityIndices, v2)
		return v2 and (State.entityToReference[v2] or v2)
	end
end

function Group:onDestroy(callback)
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

function Group:destroy()
	if self.onDestroyCallbacks then
		for _, callback in self.onDestroyCallbacks do
			task.spawn(callback)
		end

		table.clear(self.onDestroyCallbacks)
	end

	for i = #self.entities, 1, -1 do
		self:_remove(self.entities[i])
	end

	State.groupToObservers[self.id] = nil
	State.groups[self.id] = nil
	State.groupEntityCleanups[self.id] = nil
	setmetatable(self, nil)
end

function Group:_add(player)
	if typeof(player) == "Instance" and player:IsA("Player") then
		PlayerTracker.subscribe(player, self)
		return self
	end

	local instance = State.referenceToEntity[player] or player

	if not State.entityToGroups[instance] then
		State.entityToGroups[instance] = {}
	end

	if State.entityToGroups[instance][self.id] then
		return self
	end

	State.entityToGroups[instance][self.id] = true

	if not State.entityData[instance] then
		local strategy = nil

		if typeof(instance) == "Instance" then
			if instance:IsA("BasePart") then
				strategy = POS
			elseif instance:IsA("Attachment") or instance:IsA("Bone") then
				strategy = WORLD
			elseif instance:IsA("Camera") then
				strategy = CFRAME
			elseif instance:IsA("Model") then
				strategy = instance.PrimaryPart and PRIM or PIVOT
			end
		elseif typeof(instance) == "table" then
			if instance.Position then
				strategy = POS
			elseif instance.CFrame then
				strategy = CFRAME
			elseif instance.Transform then
				strategy = TRANSFORM
			elseif instance.WorldPosition then
				strategy = WORLD
			elseif instance.GetPivot then
				strategy = PIVOT
			end
		end

		if strategy then
			State.entityData[instance] = {
				strategy = strategy,
				lastPosition = createVector(0, 0, 0),
				activeObserverMemberships = {},
				precisionSq = precisionSq,
				updateRate = -1,
				bucketIndex = 0,
				dynamicVersion = -1,
				staticVersion = -1,
				logicVersion = -1,
				needsStatic = false,
				needsDynamic = false
			}
		else
			Log.nonFatal(
				"Invalid entity (%s). Expected BasePart, Model, Bone, Attachment, Camera, or a valid EntityTable.",
				nil,
				(tostring(instance))
			)
			State.entityToGroups[instance][self.id] = nil
			return self
		end
	end

	local v2 = #self.entities + 1
	self.entities[v2] = instance
	self.entityIndices[instance] = v2
	State.dirtyProfiles[instance] = true
	State.dirtyTopology[instance] = true
	State.entityData[instance].logicVersion = -1

	if self.autoClean and typeof(instance) == "Instance" and not State.groupEntityCleanups[self.id][instance] then
		State.groupEntityCleanups[self.id][instance] = instance.AncestryChanged:Connect(function(_, parent)
			if not parent then
				self:_remove(instance)
			end
		end)
	end

	return self
end

function Group:_addBulk(items)
	for _, item in items do
		self:_add(item)
	end

	return self
end

function Group:_remove(player)
	if typeof(player) == "Instance" and player:IsA("Player") then
		PlayerTracker.unsubscribe(player, self)
		return self
	end

	local v2 = State.referenceToEntity[player] or player

	if not (State.entityToGroups[v2] and State.entityToGroups[v2][self.id]) then
		return self
	end

	local connection = State.groupEntityCleanups[self.id][v2]

	if connection then
		connection:Disconnect()
		State.groupEntityCleanups[self.id][v2] = nil
	end

	State.entityToGroups[v2][self.id] = nil
	local v3 = State.entityData[v2]
	local entityIndice = self.entityIndices[v2]
	local count = #self.entities

	if entityIndice == count then
		self.entities[count] = nil
		self.entityIndices[v2] = nil
	else
		local entity = self.entities[count]
		self.entities[entityIndice] = entity
		self.entityIndices[entity] = entityIndice
		self.entities[count] = nil
		self.entityIndices[v2] = nil
	end

	State.dirtyProfiles[v2] = true
	State.dirtyTopology[v2] = true

	for k, activeObserverMembership in v3.activeObserverMemberships do
		local v4 = false

		for k2 in State.entityToGroups[v2] do
			if not (State.groupToObservers[k2] and State.groupToObservers[k2][k]) then
				continue
			end

			v4 = true
			break
		end

		if v4 then
			continue
		end

		v3.activeObserverMemberships[k] = nil

		if State.observerTrackingEntities[k] then
			State.observerTrackingEntities[k][v2] = nil
		end

		local observerExitedCallback = State.observerExitedCallbacks[k]

		if not observerExitedCallback then
			continue
		end

		local v6 = State.observerSafety[k]
		local v7 = State.zoneIdToZoneObj[activeObserverMembership]
		local v8 = State.entityToReference[v2] or v2

		for _, callback in observerExitedCallback do
			if v6 then
				task.spawn(callback, v8, v7, v2)
			else
				callback(v8, v7, v2)
			end
		end
	end

	if next(State.entityToGroups[v2]) ~= nil then
		return self
	end

	local updateRate = v3.updateRate

	if updateRate and updateRate > 0 and State.buckets[updateRate] then
		local bucket = State.buckets[updateRate]
		local bucketIndex = v3.bucketIndex
		local count2 = #bucket
		local v4 = bucket[count2]

		if bucketIndex ~= count2 then
			bucket[bucketIndex] = v4

			if State.entityData[v4] then
				State.entityData[v4].bucketIndex = bucketIndex
			end
		end

		bucket[count2] = nil
	end

	State.entityData[v2] = nil
	State.entityToGroups[v2] = nil
	State.entityToObservers[v2] = nil
	State.dirtyProfiles[v2] = nil
	State.dirtyTopology[v2] = nil
	local player2 = State.entityToReference[v2]

	if player2 and (typeof(player2) ~= "Instance" or not player2:IsA("Player")) then
		State.entityToReference[v2] = nil

		if State.referenceToEntity[player2] == v2 then
			State.referenceToEntity[player2] = nil
		end
	end

	return self
end

function Group:_removeBulk(items)
	for _, item in items do
		self:_remove(item)
	end

	return self
end

function Group:_clear()
	local entities = self.entities

	for i = #entities, 1, -1 do
		self:_remove(entities[i])
	end

	return self
end

return Group