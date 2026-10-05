local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")
game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local isClient = RunService:IsClient()
local utility = script.Utility
local templates = script.Templates
local BVH = require(utility.BVH)
local SimpleSignal = require(utility.SimpleSignal)
local JumpTable = require(utility.JumpTable)
local SearchFor = require(script.SearchFor)
local PlayerLookup = require(script.PlayerLookup)
local Zones = require(script.Zones)
local characterObjects = PlayerLookup.characterObjects
local clientWorker = templates.ClientWorker
local serverWorker = templates.ServerWorker
local zoneClass = {}
local v2 = {
	__index = zoneClass
}
local folder = Instance.new("Folder")
folder.Name = "SIMPLEZONE_ZONE_ACTORS"

if isClient then
	ServerScriptService = Players.LocalPlayer.PlayerScripts or ServerScriptService
end

folder.Parent = ServerScriptService

if isClient then
	serverWorker = clientWorker or serverWorker
end

local folder2 = Instance.new("Folder")
folder2.Name = `SIMPLE_ZONE_QUERY_SPACES:CLIENT:{isClient}`
folder2.Parent = game:GetService("ReplicatedStorage")
local partQueryJump = JumpTable({
	Block = function(object, instance, p)
		return object:GetPartBoundsInBox(instance.CFrame, instance.Size, p)
	end,
	Ball = function(object, p, p2)
		return object:GetPartBoundsInRadius(p.Position, p.ExtentsSize.Y, p2)
	end,
	_ = function(object, p, p2)
		return object:GetPartsInPart(p, p2)
	end
})
local v4 = {
	Shape = true
}
local v5 = {
	CFrame = true,
	Position = true,
	Orientation = true
}

-- equivalent calls inferred from this helper; original call sites unknown
local function queryop_new()
	return {
		FireMode = "Both",
		TrackItemEnabled = false,
		ThrottlingEnabled = false,
		StoreByClass = false,
		AcceptMetadata = false,
		UpdateInterval = 0,
		InSeperateQuerySpace = false,
		Static = false,
		DoBoxQueryForBVHNodes = false
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isArray(part)
	if type(part) ~= "table" then
		return false
	end

	local count = #part
	return count ~= 0 and next(part, count) == nil
end

local function isPointInBox(p, cframe, data)
	local pointToObjectSpace = cframe:PointToObjectSpace(p)
	return math.abs(pointToObjectSpace.X) <= data.X and math.abs(pointToObjectSpace.Y) <= data.Y and math.abs(pointToObjectSpace.Z) <= data.Z
end

local function areAnyItemPointsInBox(replicas, cframe: CFrame, size: Vector3)
	local halfSize = size / 2

	for _, item in replicas do
		local pointToObjectSpace = cframe:PointToObjectSpace(item.Position)
		local v7

		if math.abs(pointToObjectSpace.X) <= halfSize.X and math.abs(pointToObjectSpace.Y) <= halfSize.Y then
			v7 = math.abs(pointToObjectSpace.Z) <= halfSize.Z
		else
			v7 = false
		end

		if v7 then
			return true
		end
	end

	return false
end

local function removeFromQuerySpace(p, part)
	if not part:IsA("BasePart") then
		return
	end

	local _querySpace = p._querySpace

	for _, connection in p._replicaConnect[part] do
		connection:Disconnect()
	end

	local index = table.find(_querySpace.static.index, part)
	local static

	if index then
		static = _querySpace.static
	else
		index = table.find(_querySpace.dynamic.index, part)
		static = _querySpace.dynamic
	end

	if not index then
		return
	end

	table.remove(static.index, index)
	table.remove(static.replicas, index)
end

local function copyToQuerySpace(data, part, flag: boolean, p, instances)
	if not part:IsA("BasePart") then
		return
	end

	local _querySpace = data._querySpace
	local _worldModel = data._worldModel
	local _replicaConnect = data._replicaConnect
	local index = flag and _querySpace.static.index or _querySpace.dynamic.index
	local replicas = flag and _querySpace.static.replicas or _querySpace.dynamic.replicas
	local v6 = #replicas + 1
	local instance = Instance.fromExisting(part)
	instance.Name = `REPLICA:{v6}`
	instance.Parent = _worldModel
	index[v6] = part
	replicas[v6] = instance
	local v8

	if p == nil then
		v8 = false
	else
		v8 = part.Changed:Connect(function(p2)
			if v5[p2] or not p[p2] then
				return
			end

			instance[p2] = part[p2]
		end)
	end

	_replicaConnect[part] = { v8, part.Destroying:Once(function()
			removeFromQuerySpace(data, part)
		end) }

	if instances then
		table.insert(instances, instance)
	end

	return instance
end

local function getOnEnterExit(p)
	local _queryOptions = p._queryOptions
	local _ = p._items
	local _ = _queryOptions.FireMode
	return
		(_queryOptions.FireMode == "OnEnter" or _queryOptions.FireMode == "Both") and _queryOptions.FireMode ~= "None",
		(_queryOptions.FireMode == "OnExit" or _queryOptions.FireMode == "Both") and _queryOptions.FireMode ~= "None"
end

local function getTracked(p, instance)
	for ancestor in p._tracked do
		if instance:IsDescendantOf(ancestor) then
			return ancestor
		end
	end
end

local function getItem(object, item)
	local _querySpace = object._querySpace
	local _queryOptions = object._queryOptions

	if typeof(item) == "table" and _queryOptions.AcceptMetadata then
		item = item.item or item
	end

	if _querySpace ~= nil then
		local index = table.find(_querySpace.dynamic.replicas, item)

		if index then
			item = _querySpace.dynamic.index[index]
		end
	end

	local v6

	if _queryOptions.TrackItemEnabled then
		for ancestor in object._tracked do
			if not item:IsDescendantOf(ancestor) then
				continue
			end

			v6 = ancestor
			break
		end

		if not v6 then
			return characterObjects[item] or item
		end
	else
		return characterObjects[item] or item
	end

	return v6
end

function zoneClass:Update(p, flag: boolean?, flag2: boolean?)
	local _queryOptions = self._queryOptions
	local storeByClass = _queryOptions.StoreByClass
	local acceptMetadata = _queryOptions.AcceptMetadata
	local query = self:Query(p)
	local v6 = {}

	for _, v7 in query do
		if v6[v7] then
			continue
		end

		local item = getItem(self, v7)

		if v6[item] then
			continue
		end

		v6[item] = true

		if self._items[item] then
			continue
		end

		local v8 = typeof(v7) == "table"

		if acceptMetadata then
			self._items[item] = not v8 or (v7.metadata or true)
		else
			self._items[item] = true
		end

		if storeByClass then
			local typeName = typeof(item)

			if typeName == "Instance" then
				typeName = item.ClassName or "Instance"
			end

			local _storedClass = self._storedClasses[typeName]

			if not _storedClass then
				_storedClass = {}
				self._storedClasses[typeName] = _storedClass
			end

			_storedClass[#_storedClass + 1] = item
		end

		if not (flag and self.ItemEntered._connectionCount ~= 0) then
			continue
		end

		if acceptMetadata then
			if v8 then
				self.ItemEntered:Fire(item, v7.metadata)
			else
				self.ItemEntered:Fire(item)
			end
		else
			self.ItemEntered:Fire(item)
		end
	end

	for k, _item in self._items do
		if v6[k] then
			continue
		end

		self._items[k] = nil

		if storeByClass then
			local typeName = typeof(k)

			if typeName == "Instance" then
				typeName = k.ClassName or "Instance"
			end

			local _storedClass = self._storedClasses[typeName]
			local index = _storedClass and table.find(_storedClass, k)

			if index then
				table.remove(_storedClass, index)

				if #_storedClass == 0 then
					self._storedClasses[typeName] = nil
				end
			end
		end

		if not (flag2 and self.ItemExited._connectionCount ~= 0) then
			continue
		end

		if acceptMetadata then
			local itemExited = self.ItemExited

			if _item == true then
				_item = nil
			end

			itemExited:Fire(k, _item)
		else
			self.ItemExited:Fire(k)
		end
	end
end

function zoneClass:UnbindFromHeartbeat()
	Zones.deregisterZone(self)
	table.clear(self._items)
end

function zoneClass:BindToHeartbeat(queryParams)
	self:UnbindFromHeartbeat()
	Zones.registerZone(self, {
		QueryParams = queryParams,
		QueryOptions = self._queryOptions
	})
end

function zoneClass:TrackItem(instance)
	assert(typeof(instance) == "Instance", (`Bad item argument: {instance} must be an instance.`))

	if not self._queryOptions.TrackItemEnabled then
		warn("TrackItemEnabled is not enabled, cannot call Zone:TrackItem(...)")
		return
	end

	if self._tracked[instance] then
		warn((`Item {instance} is already being tracked.`))
		return
	end

	self._tracked[instance] = true
	local _trackedConnect = self._trackedConnect
	_trackedConnect[instance] = instance.Destroying:Once(function()
		_trackedConnect[instance] = nil
		self:UntrackItem(instance)
	end)
end

function zoneClass:UntrackItem(p2)
	if not self._tracked[p2] then
		warn((`Item {p2} is not currently being tracked.`))
		return
	end

	self._tracked[p2] = nil
	local _trackedConnect = self._trackedConnect

	if _trackedConnect[p2] then
		_trackedConnect[p2]:Disconnect()
		_trackedConnect[p2] = nil
	end
end

function zoneClass:GetItemsWhichAreA(p2: string)
	if self._queryOptions.StoreByClass then
		return self._storedClasses[p2] or {}
	end

	warn("StoreByClass is not enabled, cannot call Zone:GetItemsWhichAreA(...)")
end

function zoneClass.SearchFor(object, p, p2: string)
	assert(p ~= nil, "Bad properties argument.")
	return SearchFor(object:Query(), p, p2)
end

function zoneClass.ListenTo(p, className: string, p2: string, callback)
	if className == "LocalPlayer" and not isClient then
		error("Can only listen to LocalPlayer on the client.")
	end

	assert(p2 == "Entered" or p2 == "Exited", "Bad mode argument.")
	return p[`Item{p2}`]:Connect(function(instance, p3)
		if className == "LocalPlayer" and instance ~= Players.LocalPlayer or className ~= "LocalPlayer" and not instance:IsA(className) then
			return
		end

		callback(instance, p3)
	end)
end

function zoneClass:IsItemTracked(p2)
	return self._tracked[p2] ~= nil
end

function zoneClass:IsItemWithinZone(p2)
	return self._items[p2] ~= nil
end

function zoneClass:GetContainedItems()
	return self._items
end

function zoneClass:GetTracked()
	return self._tracked
end

function zoneClass:Destroy()
	local _bin = self._bin
	local _trackedConnect = self._trackedConnect
	local _replicaConnect = self._replicaConnect

	for _, connection in _bin do
		if typeof(connection) == "Instance" then
			connection:Destroy()
		elseif typeof(connection) == "RBXScriptConnection" then
			connection:Disconnect()
		end
	end

	for _, connection in _trackedConnect do
		connection:Disconnect()
	end

	for _, v6 in _replicaConnect do
		for _, connection in v6 do
			connection:Disconnect()
		end
	end

	task.defer(function()
		self.ItemEntered:Destroy()
		self.ItemExited:Destroy()
		setmetatable(self, nil)
		table.clear(self)
	end)
end

function zoneClass:GetQuerySpace()
	return self._worldModel
end

function zoneClass:CopyToQuerySpace(list, flag: boolean?, p2)
	assert(
		self._queryOptions.InSeperateQuerySpace,
		"InSeperateQuerySpace is not enabled, cannot call Zone:RegisterToQuerySpace(...)"
	)
	local v6 = table.create(#list)

	for _, v7 in list do
		copyToQuerySpace(self, v7, flag, p2, v6)
	end

	return v6
end

function zoneClass:RemoveFromQuerySpace(items)
	assert(
		self._queryOptions.InSeperateQuerySpace,
		"InSeperateQuerySpace is not enabled, cannot call Zone:RemoveFromQuerySpace(...)"
	)

	for _, item in items do
		removeFromQuerySpace(self, item)
	end
end

function zoneClass:UseQuerySpaceOf(p)
	assert(
		self._queryOptions.InSeperateQuerySpace,
		"InSeperateQuerySpace is not enabled, cannot call Zone:UseQuerySpaceOf(...)"
	)
	assert(p ~= nil, "Bad otherZone argument")
	assert(
		(self._queryOptions.InSeperateQuerySpace or p ~= "self") and true or false,
		"Cannot use query space of self because zone was not created in a seperate query space."
	)
	local _ownQuerySpace, _worldModel

	if p == "self" then
		_ownQuerySpace = self._ownQuerySpace or self._querySpace
		_worldModel = self._worldModel
	else
		_ownQuerySpace = p._querySpace
		_worldModel = p._worldModel
	end

	if p == "self" then
		self._ownQuerySpace = nil
	else
		self._ownQuerySpace = self._querySpace
	end

	self._querySpace = _ownQuerySpace
	self._worldModel = _worldModel
end

function zoneClass:OverwriteQuerySpace(p)
	assert(
		self._queryOptions.InSeperateQuerySpace,
		"InSeperateQuerySpace is not enabled, cannot call Zone:OverwriteQuerySpace(...)"
	)
	assert(p ~= nil, "Bad otherZone argument")
	local _querySpace = self._querySpace
	self:RemoveFromQuerySpace(_querySpace.dynamic.index)
	self:RemoveFromQuerySpace(_querySpace.static.index)
	self._worldModel:Destroy()
	self._querySpace = p._querySpace
	self._worldModel = p._worldModel
end

-- equivalent calls inferred from this helper; original call sites unknown
local function assertQueryOp(data)
	if not data then
		return
	end

	local fireMode = data.FireMode
	assert(
		fireMode == "Both" or fireMode == "OnExit" or fireMode == "OnEnter" or fireMode == "None",
		"Bad QueryOptions argument. (FireMode not specified)"
	)

	if data.ThrottlingEnabled and not data.UpdateInterval then
		error("QueryOptions.UpdateInterval must be specified if QueryOptions.ThrottlingEnabled is true.")
	end
end

local function zone_new(p, ...)
	local queryOptions = p or queryop_new()
	assertQueryOp(queryOptions) -- equivalent call inferred; original call site unknown
	local bin = { ... }
	local self = setmetatable({
		_trackedConnect = {},
		_replicaConnect = {},
		_items = {},
		_storedClasses = {},
		_tracked = {},
		_bin = bin,
		_queryOptions = queryOptions,
		_lastUpdate = os.clock(),
		_worldModel = workspace,
		ItemEntered = SimpleSignal.new(),
		ItemExited = SimpleSignal.new()
	}, v2)

	if queryOptions.InSeperateQuerySpace and queryOptions.QuerySpace == nil then
		local worldModel = Instance.new("WorldModel")
		worldModel.Name = `SimpleZone_QuerySpace({HttpService:GenerateGUID(false)})`
		worldModel.Parent = folder2
		table.insert(bin, worldModel)
		self._worldModel = worldModel
		self._querySpace = {
			dynamic = {
				index = {},
				replicas = {}
			},
			static = {
				index = {},
				replicas = {}
			}
		}
		return self
	else
		if queryOptions.QuerySpace == nil then
			return self
		end

		local v8

		if queryOptions.QuerySpace.World == nil then
			v8 = false
		else
			v8 = queryOptions.QuerySpace.Space ~= nil
		end

		assert(v8, "Missing world/space fields for QuerySpace")
		self._worldModel = queryOptions.QuerySpace.World
		self._querySpace = queryOptions.QuerySpace.Space
		return self
	end
end

local function getBoxesFromParts(items)
	local voxelSize = BVH.VoxelSize
	local result = {}

	for _, item in items do
		local position = item.Position
		local size = item.Size

		if item.Size.Magnitude > 500 then
			position = Vector3.new(
				position.X // voxelSize * voxelSize,
				position.Y // voxelSize * voxelSize,
				position.Z // voxelSize * voxelSize
			)
			size = Vector3.new(
				size.X // voxelSize * voxelSize,
				size.Y // voxelSize * voxelSize,
				size.Z // voxelSize * voxelSize
			)
		end

		result[#result + 1] = {
			cframe = item.CFrame.Rotation + position,
			size = size,
			part = item
		}
	end

	return result
end

local function zone_fromPart(part, data)
	assertQueryOp(data) -- equivalent call inferred; original call site unknown
	local v6 = data or queryop_new()
	local v7 = zone_new(v6)

	if v6.InSeperateQuerySpace then
		part = copyToQuerySpace(v7, part, v6.Static, v4)
	end

	function v7:Query(p2)
		local _worldModel = self._worldModel

		if part:IsA("Part") then
			return partQueryJump(part.Shape.Name, _worldModel, part, p2)
		end

		return _worldModel:GetPartsInPart(part, p2)
	end

	return v7
end

-- equivalent calls inferred from this helper; original call sites unknown
local function zone_fromBox(part: CFrame, vector: Vector3, data)
	assertQueryOp(data) -- equivalent call inferred; original call site unknown
	local v6 = zone_new(data or queryop_new())

	function v6:Query(p2)
		return self._worldModel:GetPartBoundsInBox(part, vector, p2)
	end

	return v6
end

local function zone_fromBoxes(part, data)
	assertQueryOp(data) -- equivalent call inferred; original call site unknown
	local BVH2, _ = BVH.createBVH(part)
	local v6 = zone_new(data or queryop_new())

	function v6:Query(p)
		local _ = self._queryOptions
		local _querySpace = self._querySpace
		local _worldModel = self._worldModel
		local result = {}
		BVH.traverseBVH(BVH2, function(data3)
			local partBoundsInBox

			if _querySpace == nil then
				partBoundsInBox = _worldModel:GetPartBoundsInBox(data3.cframe, data3.size, p)

				if #partBoundsInBox == 0 then
					return false
				end

				if data3.right or data3.left then
					return true
				end
			else
				if not areAnyItemPointsInBox(_querySpace.dynamic.replicas, data3.cframe, data3.size) then
					return false
				end

				if data3.right or data3.left then
					return true
				else
					partBoundsInBox = _worldModel:GetPartBoundsInBox(data3.cframe, data3.size, p)
				end
			end

			if self._queryOptions.AcceptMetadata then
				for _, v7 in partBoundsInBox do
					table.insert(result, {
						item = v7,
						metadata = {
							box = data3
						}
					})
				end
			else
				table.move(partBoundsInBox, 1, #partBoundsInBox, #result + 1, result)
			end

			return false
		end)
		return result
	end

	return v6
end

local function zone_fromParts(part, data)
	assertQueryOp(data) -- equivalent call inferred; original call site unknown
	local v6 = data or queryop_new()
	local v7 = zone_new(v6)
	local v8

	if v6.InSeperateQuerySpace then
		v8 = getBoxesFromParts(v7:CopyToQuerySpace(part, v6.Static, v4))
	else
		v8 = getBoxesFromParts(part)
	end

	local BVH2 = BVH.createBVH(v8)

	function v7:Query(p)
		local _querySpace = self._querySpace
		local _queryOptions = self._queryOptions
		local _worldModel = self._worldModel
		local result = {}
		local static

		if _querySpace == nil then
			static = false
		else
			static = _queryOptions.Static and _querySpace.static or _querySpace.dynamic
		end

		BVH.traverseBVH(BVH2, function(data3)
			local partBoundsInBox = nil

			if _querySpace then
				if not areAnyItemPointsInBox(_querySpace.dynamic.replicas, data3.cframe, data3.size) then
					return false
				end

				if not data3.part then
					return true
				end
			else
				partBoundsInBox = _worldModel:GetPartBoundsInBox(data3.cframe, data3.size, p)

				if not data3.part then
					return #partBoundsInBox > 0
				end
			end

			local part2 = data3.part
			local partsInPart

			if part2:IsA("Part") then
				partsInPart = part2.Shape == Enum.PartType.Block and partBoundsInBox or partQueryJump(
					part2.Shape.Name,
					_worldModel,
					part2,
					p
				)
			else
				partsInPart = _worldModel:GetPartsInPart(part2, p)
			end

			if _queryOptions.AcceptMetadata then
				local part3 = data3.part

				if _queryOptions.InSeperateQuerySpace then
					local index = table.find(static.replicas, data3.part)
					part3 = static.index[index]
				end

				for _, v9 in partsInPart do
					table.insert(result, {
						item = v9,
						metadata = {
							part = part3
						}
					})
				end
			else
				table.move(partsInPart, 1, #partsInPart, #result + 1, result)
			end

			return false
		end)
		return result
	end

	return v7
end

local function zone_fromPartsLPO()
	error("Zone.fromPartsLPO() is deprecated, it should not be used for new work.")
end

local function zone_fromPartsUpdatable()
	error("Zone.fromPartsUpdatable() is deprecated, it should not be used for new work.")
end

local function zone_fromPartParallel(p, data)
	assertQueryOp(data) -- equivalent call inferred; original call site unknown
	local v6 = data or queryop_new()
	local clone = serverWorker:Clone()
	clone.Parent = folder
	local result = clone.Result
	local v7 = zone_new(v6, clone)

	if v6.InSeperateQuerySpace then
		p = copyToQuerySpace(v7, p, v6.Static, v4)
	end

	function v7:Query(p3)
		local _worldModel = self._worldModel
		task.defer(clone.SendMessage, clone, "GetPartsInPart", _worldModel, p3, p)
		return result.Event:Wait()
	end

	return v7
end

local function zone_fromCustom(query, data)
	assert(query ~= nil, "Bad queryFn argument.")
	assertQueryOp(data) -- equivalent call inferred; original call site unknown
	local v6 = zone_new(data or queryop_new())
	v6.Query = query
	return v6
end

local function fn(part, p, p2)
	-- equivalent call inferred; original call site unknown
	if isArray(part) then
		if typeof(part[1]) == "Instance" and part[1]:IsA("BasePart") then
			return (zone_fromParts(part, p))
		end

		if typeof(part[1]) == "table" then
			return (zone_fromBoxes(part, p))
		else
			error("Unable to find an overload.")
		end
	end

	if typeof(part) == "CFrame" and typeof(p) == "Vector3" then
		return zone_fromBox(part, p, p2)
	else
		if typeof(part) == "Instance" and part:IsA("BasePart") then
			return (zone_fromPart(part, p))
		end

		error("Unable to find an overload.")
	end
end

if script:GetAttribute("ClientOnlyDetectLocalPlayer") and RunService:IsClient() then
	PlayerLookup.onPlayerAdded(Players.LocalPlayer)
else
	PlayerLookup.start()
end

return table.freeze({
	new = fn,
	fromBox = zone_fromBox,
	fromPart = zone_fromPart,
	fromParts = zone_fromParts,
	fromBoxes = zone_fromBoxes,
	fromCustom = zone_fromCustom,
	fromPartParallel = zone_fromPartParallel,
	fromPartsUpdatable = zone_fromPartsUpdatable,
	fromPartsLPO = zone_fromPartsLPO,
	QueryOptions = {
		new = queryop_new
	},
	newInternal = zone_new,
	searchFor = SearchFor,
	BVH = BVH,
	ZoneClass = zoneClass,
	PlayerLookup = PlayerLookup,
	PartQueryJump = partQueryJump
})