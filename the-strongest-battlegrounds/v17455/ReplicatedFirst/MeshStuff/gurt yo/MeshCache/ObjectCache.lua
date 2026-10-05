local cframe = CFrame.new(16777216, 16777216, 16777216)
game:GetService("RunService")
local v = table.create(10000)
local v2 = table.create(10000)
local flag = false

local function UpdateMovement()
	while true do
		workspace:BulkMoveTo(v, v2, Enum.BulkMoveMode.FireCFrameChanged)
		table.clear(v)
		table.clear(v2)
		flag = false
		coroutine.yield()
	end
end

local thread = coroutine.create(UpdateMovement)
local class = {}
class.__index = class

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
	local cframes = table.create(p)
	local clones = table.create(p)

	for i = count + 1, count + p do
		local clone = _Template:Clone()
		local primaryPart

		if _IsTemplateModel then
			primaryPart = clone.PrimaryPart
		else
			primaryPart = clone
		end

		_FreeObjects[i] = primaryPart
		local v3 = i - count
		primaryParts[v3] = primaryPart
		cframes[v3] = cframe
		clones[v3] = clone
	end

	workspace:BulkMoveTo(primaryParts, cframes, Enum.BulkMoveMode.FireCFrameChanged)

	for _, v3 in clones do
		v3.Parent = cacheHolder
	end

	return table.remove(_FreeObjects)
end

function class:_ReleasePart(parent)
	local index = table.find(self._FreeObjects, parent)

	if index then
		table.remove(self._FreeObjects, index)
	end

	self._Objects[parent] = nil

	if self._IsTemplateModel and parent.Parent and parent.Parent:IsA("Model") then
		parent = parent.Parent
	end

	parent:Destroy()
end

function class:GetPart(cframe2: CFrame?)
	local v3 = table.remove(self._FreeObjects) or self:_GetNew(self._ExpandAmount, false)
	self._Objects[v3] = nil

	if not cframe2 then
		return v3
	end

	table.insert(v, v3)
	table.insert(v2, cframe2)

	if not flag then
		flag = true
		task.defer(thread)
	end

	return v3
end

function class:ReturnPart(p2)
	if self._Objects[p2] then
		return true
	end

	self._Objects[p2] = true
	table.insert(self._FreeObjects, p2)
	table.insert(v, p2)
	table.insert(v2, cframe)

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
	self:_GetNew(value, false)
end

function class:SetExpandAmount(expandAmount: number)
	assert(
		typeof(expandAmount) ~= "number" or expandAmount > 0,
		(`Invalid argument #1 to 'ObjectCache:SetExpandAmount' (positive number expected, got {typeof(expandAmount)})`)
	)
	self._ExpandAmount = expandAmount
end

function class:IsInUse(p2)
	return self._Objects[p2] == nil
end

function class:Destroy()
	self.CacheHolder:Destroy()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetCacheContainer()
	local folder = Instance.new("Folder")
	folder:AddTag("MESHEMISSION_VISUAL")
	folder.Archivable = false
	return folder
end

return {
	new = function(instance, value: number?, p)
		local typeName = typeof(instance)
		assert(typeName == "Instance", (`Invalid argument #1 to 'ObjectCache.new' (BasePart expected, got {typeName})`))
		assert(
			instance:IsA("BasePart") or instance:IsA("Model"),
			(`Invalid argument #1 to 'ObjectCache.new' (BasePart or Model expected, got {instance.ClassName})`)
		)
		assert(
			instance.Archivable,
			"ObjectCache: Cannot use template object provided, as it has Archivable set to false."
		)

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
		local typeName3 = typeof(p)
		assert(
			p == nil or typeName3 == "Instance",
			(`Invalid argument #3 to 'ObjectCache.new' (Instance expected, got {typeName3})`)
		)
		local preallocatedAmount = value or 10
		local v4 = GetCacheContainer() -- equivalent call inferred; original call site unknown
		local clones = table.create(preallocatedAmount)
		local primaryParts = table.create(preallocatedAmount)
		local isA = instance:IsA("Model")

		for i = 1, preallocatedAmount do
			local clone = instance:Clone()
			local primaryPart

			if isA then
				primaryPart = clone.PrimaryPart
			else
				primaryPart = clone
			end

			clones[i] = clone
			primaryParts[i] = primaryPart
			primaryPart.CFrame = cframe
			clone.Parent = v4
		end

		v4.Name = `ObjectCache/{instance.Name}`
		v4.Parent = p or workspace
		return (setmetatable({
			CacheHolder = v4,
			_ExpandAmount = 16,
			_Template = instance,
			_FreeObjects = primaryParts,
			_Objects = {},
			_IsTemplateModel = isA,
			_PreallocatedAmount = preallocatedAmount
		}, class))
	end
}