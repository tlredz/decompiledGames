local cframe = CFrame.new(0, -200, 0)
local v = table.create(1000)
local v2 = table.create(1000)
local flag = false

local function UpdateMovement()
	while true do
		for i = 1, #v do
			local v3 = v[i]

			if v3 then
				v3:PivotTo(v2[i])
			end
		end

		table.clear(v)
		table.clear(v2)
		flag = false
		coroutine.yield()
	end
end

coroutine.create(UpdateMovement)
local class = {}
class.__index = class

local function AnchorModel(folder)
	for _, part in ipairs(folder:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Anchored = true
		end
	end
end

function class:_CleanupExpiredExtras()
	local _PreallocAmount = self._PreallocAmount

	if not _PreallocAmount then
		return
	end

	local now = os.clock()

	if #self._FreeObjects <= _PreallocAmount then
		return
	end

	for i = #self._FreeObjects, 1, -1 do
		if #self._FreeObjects <= _PreallocAmount then
			break
		end

		local _FreeObject = self._FreeObjects[i]
		local v3 = self._ExtraExpiry[_FreeObject]

		if not (v3 ~= nil and v3 <= now) then
			continue
		end

		self._FreeObjects[i] = self._FreeObjects[#self._FreeObjects]
		self._FreeObjects[#self._FreeObjects] = nil
		self._ExtraExpiry[_FreeObject] = nil
		_FreeObject:Destroy()
	end
end

function class:_ScheduleCleanup()
	if self._Destroyed then
		return
	end

	task.delay(60, function()
		if self._Destroyed then
			return
		end

		if self.CacheHolder and self.CacheHolder.Parent then
			self:_CleanupExpiredExtras()
		end
	end)
end

function class:_GetNew()
	warn("ObjectCache: Cache retrieval exceeded preallocated amount! cloning a new model...")
	local clone = self._Template:Clone()
	AnchorModel(clone)
	clone:PivotTo(cframe)
	clone.Parent = self.CacheHolder
	self._ExtraExpiry[clone] = os.clock() + 60
	self:_ScheduleCleanup()
	return clone
end

function class:GetPart(cframe2: CFrame?)
	local v3 = table.remove(self._FreeObjects) or self:_GetNew()

	if cframe2 then
		v3:PivotTo(cframe2)
	end

	return v3
end

function class:ReturnPart(instance)
	table.insert(self._FreeObjects, instance)
	instance:PivotTo(cframe)
	self:_CleanupExpiredExtras()
end

function class:Destroy()
	self._Destroyed = true
	self.CacheHolder:Destroy()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetCacheContainer(parent)
	local folder = Instance.new("Folder")
	folder.Name = "ObjectCache"
	folder.Parent = parent
	return folder
end

return {
	new = function(model, value: number?, p)
		local typeName = typeof(model)
		assert(typeName == "Instance", (`Invalid argument #1 to 'ObjectCache.new' (Model expected, got {typeName})`))
		assert(model:IsA("Model"), (`Invalid argument #1 to 'ObjectCache.new' (Model expected, got {model.ClassName})`))
		assert(model.Archivable, "ObjectCache: Cannot use template model provided, as it has Archivable set to false.")
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
		local preallocAmount = value or 10
		local v5 = GetCacheContainer(p or workspace) -- equivalent call inferred; original call site unknown
		local clones = table.create(preallocAmount)

		for i = 1, preallocAmount do
			local clone = model:Clone()
			AnchorModel(clone)
			clone:PivotTo(cframe)
			clone.Parent = v5
			clones[i] = clone
		end

		return (setmetatable({
			CacheHolder = v5,
			_Template = model,
			_FreeObjects = clones,
			_PreallocAmount = preallocAmount,
			_ExtraExpiry = {},
			_Destroyed = false
		}, class))
	end
}