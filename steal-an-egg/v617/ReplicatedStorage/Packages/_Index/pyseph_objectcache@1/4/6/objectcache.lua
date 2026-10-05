local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Constants = require(ReplicatedStorage.Shared.Globals.Constants)
local QueueLock = require(ReplicatedStorage.Shared.Modules.QueueLock)
local Log = require(ReplicatedStorage.Packages.Log)
local v = Log.new()
local invisibleRenderSpace = workspace:WaitForChild("World"):WaitForChild("InvisibleRenderSpace")
local v2 = invisibleRenderSpace.Size * 0.5
local v3 = invisibleRenderSpace.Position - v2
local v4 = invisibleRenderSpace.Position + v2
local v5 = Constants.IS_MOBILE and 0.006 or 0.004
local v6 = table.create(10000)
local v7 = table.create(10000)
local v8 = Constants.IS_CLIENT and {} or nil
local flag = false

local function UpdateMovement()
	while true do
		workspace:BulkMoveTo(v6, v7, Enum.BulkMoveMode.FireCFrameChanged)
		table.clear(v6)
		table.clear(v7)
		flag = false
		coroutine.yield()
	end
end

local thread = coroutine.create(UpdateMovement)
local class = {}
class.__index = class

-- equivalent calls inferred from this helper; original call sites unknown
local function randFloat(p: number, p2: number)
	return math.random() * (p2 - p) + p
end

local function hiddenCFrame()
	local v9 = randFloat(v3.X, v4.X) -- equivalent call inferred; original call site unknown
	local v10 = randFloat(v3.Y, v4.Y) -- equivalent call inferred; original call site unknown
	return CFrame.new(v9, v10, randFloat(v3.Z, v4.Z))
end

function class:_GetNew(p: number, flag2: boolean)
	if flag2 then
		warn((`ObjectCache: Cache retrieval exceeded preallocated amount! expanding by {p}...`))
	end

	local _FreeObjects = self._FreeObjects
	local count = #self._FreeObjects
	local cacheHolder = self.CacheHolder
	local _IsTemplateModel = self._IsTemplateModel
	local _Template = self._Template
	local primaryParts = table.create(p)
	local v9 = table.create(p)
	local lastTime = os.clock()

	for i = count + 1, count + p do
		local clone = _Template:Clone()
		local primaryPart

		if _IsTemplateModel then
			primaryPart = clone.PrimaryPart
		else
			primaryPart = clone
		end

		_FreeObjects[i] = primaryPart
		self._DesiredAnchored[primaryPart] = primaryPart.Anchored
		primaryPart.Anchored = true
		clone.Parent = cacheHolder
		local v10 = i - count
		primaryParts[v10] = primaryPart
		local v11 = randFloat(v3.X, v4.X) -- equivalent call inferred; original call site unknown
		local v12 = randFloat(v3.Y, v4.Y) -- equivalent call inferred; original call site unknown
		v9[v10] = CFrame.new(v11, v12, randFloat(v3.Z, v4.Z))

		if not (v5 <= os.clock() - lastTime) then
			continue
		end

		task.wait()
		lastTime = os.clock()
	end

	workspace:BulkMoveTo(primaryParts, v9, Enum.BulkMoveMode.FireCFrameChanged)
	return table.remove(_FreeObjects)
end

function class:GetPart(cframe: CFrame?)
	local v9 = table.remove(self._FreeObjects)

	if not v9 then
		self._ExpandMutex:WithLock(function()
			v:AtTrace():Log("free objects at creation:", self._FreeObjects, "SELF", self)
			v9 = self:_GetNew(self._ExpandAmount, true)
			v:AtTrace():Log("part found after expanding cache:", v9, "self:", self)
		end)
	end

	assert(v9, "ObjectCache: failed to allocate part")
	self._Objects[v9] = nil

	if cframe then
		table.insert(v6, v9)
		table.insert(v7, cframe)

		if not flag then
			flag = true
			task.defer(thread)
		end
	end

	local anchored = self._DesiredAnchored[v9]

	if anchored ~= nil then
		self._DesiredAnchored[v9] = nil
		task.defer(function()
			v9.Anchored = anchored
		end)
	end

	return v9
end

function class:ReturnPart(p)
	if self._Objects[p] then
		return
	end

	self._Objects[p] = true
	self._DesiredAnchored[p] = p.Anchored
	p.Anchored = true
	table.insert(self._FreeObjects, p)
	table.insert(v6, p)
	table.insert(v7, hiddenCFrame())

	if not flag then
		flag = true
		task.defer(thread)
	end
end

function class.Update(_)
	task.spawn(thread)
end

function class:ExpandCache(value: number)
	assert(
		typeof(value) ~= "number" or value >= 0,
		(`Invalid argument #1 to 'ObjectCache:ExpandCache' (positive number expected, got {typeof(value)})`)
	)
	self._ExpandMutex:WithLock(function()
		self:_GetNew(value, false)
	end)
	return self
end

function class:SetExpandAmount(expandAmount: number)
	assert(
		typeof(expandAmount) ~= "number" or expandAmount > 0,
		(`Invalid argument #1 to 'ObjectCache:SetExpandAmount' (positive number expected, got {typeof(expandAmount)})`)
	)
	self._ExpandAmount = expandAmount
	return self
end

function class:IsInUse(p2)
	return self._Objects[p2] == nil
end

local function CollectFlush(p, vector: Vector3, vector2: Vector3)
	debug.profilebegin("ObjectCache :: CollectFlush")

	for _, _FreeObject in ipairs(p._FreeObjects) do
		table.insert(v6, _FreeObject)
		local v10 = randFloat(vector.X, vector2.X) -- equivalent call inferred; original call site unknown
		local v11 = randFloat(vector.Y, vector2.Y) -- equivalent call inferred; original call site unknown
		local Z = vector.Z
		local Z2 = vector2.Z
		table.insert(v7, CFrame.new(v10, v11, randFloat(Z, Z2)))
	end

	debug.profileend()
end

function class.FlushToBounds(p, vector: Vector3, vector2: Vector3)
	CollectFlush(p, vector, vector2)

	if not flag then
		flag = true
		task.defer(thread)
	end
end

function class:Destroy()
	debug.profilebegin("ObjectCache :: Destroy")

	if v8 then
		v8[self] = nil
	end

	self.CacheHolder:Destroy()
	debug.profileend()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetCacheContainer()
	local folder = Instance.new("Folder")
	folder.Name = "ObjectCache"
	return folder
end

local Objectcache = {}

function Objectcache.new(instance, value: number?, parent)
	local typeName = typeof(instance)
	assert(typeName == "Instance", (`Invalid argument #1 to 'ObjectCache.new' (BasePart expected, got {typeName})`))
	assert(
		instance:IsA("BasePart") or instance:IsA("Model"),
		(`Invalid argument #1 to 'ObjectCache.new' (BasePart or Model expected, got {instance.ClassName})`)
	)
	assert(instance.Archivable, "ObjectCache: Cannot use template object provided, as it has Archivable set to false.")

	if instance:IsA("Model") then
		assert(
			instance.PrimaryPart ~= nil,
			"Invalid Template provided to 'ObjectCache.new': Model has no PrimaryPart set!"
		)
	end

	local typeName2 = typeof(value)
	assert(
		value == nil or typeName2 == "number",
		(`Invalid argument #2 to 'ObjectCache.new' (number expected, got {typeName2})`)
	)
	assert(
		value == nil or value >= 0,
		(`Invalid argument #2 to 'ObjectCache.new' (positive number expected, got {value})`)
	)
	local typeName3 = typeof(parent)
	assert(
		parent == nil or typeName3 == "Instance",
		(`Invalid argument #3 to 'ObjectCache.new' (Instance expected, got {typeName3})`)
	)
	local preallocatedAmount = value or 1
	local v10 = GetCacheContainer() -- equivalent call inferred; original call site unknown
	local primaryParts = table.create(preallocatedAmount)
	local anchoredsByPrimaryPart = {}
	local isA = instance:IsA("Model")
	local object = setmetatable({
		CacheHolder = v10,
		_ExpandAmount = value or 1,
		_Template = instance,
		_FreeObjects = primaryParts,
		_Objects = {},
		_IsTemplateModel = isA,
		_PreallocatedAmount = preallocatedAmount,
		_DesiredAnchored = anchoredsByPrimaryPart,
		_ExpandMutex = QueueLock.new()
	}, class)

	if parent then
		v10.Parent = parent
	else
		v10.Parent = workspace
	end

	local lastTime = os.clock()

	for i = 1, preallocatedAmount do
		local clone = instance:Clone()
		local primaryPart

		if isA then
			primaryPart = clone.PrimaryPart
		else
			primaryPart = clone
		end

		primaryParts[i] = primaryPart
		anchoredsByPrimaryPart[primaryPart] = primaryPart.Anchored
		primaryPart.Anchored = true
		clone.Parent = v10
		local v11 = randFloat(v3.X, v4.X) -- equivalent call inferred; original call site unknown
		local v12 = randFloat(v3.Y, v4.Y) -- equivalent call inferred; original call site unknown
		primaryPart.CFrame = CFrame.new(v11, v12, randFloat(v3.Z, v4.Z))

		if not (v5 <= os.clock() - lastTime) then
			continue
		end

		task.wait()
		lastTime = os.clock()
	end

	if v8 then
		v8[object] = true
	end

	return object
end

function Objectcache.SetInvisibleBounds(vector: Vector3, vector2: Vector3)
	v3 = vector
	v4 = vector2
end

function Objectcache.is(p)
	return typeof(p) == "table" and getmetatable(p) == class
end

Objectcache.GetRandomHiddenCFrame = hiddenCFrame
return Objectcache