local Table = require(script:WaitForChild("Table"))
local BuildInfo = require(game.ReplicatedStorage.BuildInfo)
local v = BuildInfo.IS_PUBLISHED == false
local PartCache = {}
PartCache.__index = PartCache
PartCache.__type = "PartCache"
local cframe = CFrame.new(0, 1000000000, 0)

local function assertwarn(flag: boolean, p: string)
	if flag == false then
		warn(p)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function MakeFromTemplate(instance, currentCacheParent)
	local clone = instance:Clone()
	clone.CFrame = cframe
	clone.Anchored = true
	clone.Parent = currentCacheParent
	return clone
end

function PartCache:new(value: number?, p)
	local currentCacheParent = p or workspace
	assert(value > 0, "PrecreatedParts can not be negative!")

	if value ~= 0 == false then
		warn("PrecreatedParts is 0! This may have adverse effects when initially using the cache.")
	end

	if self.Archivable == false then
		warn("The template's Archivable property has been set to false, which prevents it from being cloned. It will temporarily be set to true.")
	end

	local archivable = self.Archivable
	self.Archivable = true
	local clone = self:Clone()
	self.Archivable = archivable
	local v4 = {
		Open = {},
		InUse = {},
		CurrentCacheParent = currentCacheParent,
		Template = clone,
		ExpansionSize = 10
	}
	setmetatable(v4, PartCache)

	for _ = 1, value or 5 do
		Table.insert(v4.Open, MakeFromTemplate(clone, v4.CurrentCacheParent))
	end

	v4.Template.Parent = nil
	return v4
end

local function enableparticles(folder)
	for _, emitter in pairs(folder:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = emitter:GetAttribute("_e") or emitter.Enabled
		end
	end
end

local function disableparticles(folder)
	for _, emitter in pairs(folder:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		emitter:SetAttribute("_e", emitter.Enabled)
		emitter.Enabled = false
	end
end

function PartCache.GetPart(data)
	assert(
		getmetatable(data) == PartCache,
		("Cannot statically invoke method '%s' - It is an instance method. Call it on an instance of this class created via %s"):format(
			"GetPart",
			"PartCache.new"
		)
	)

	if #data.Open == 0 then
		if v then
			warn("No parts available in the cache! Creating [" .. data.ExpansionSize .. "] new part instance(s) - this amount can be edited by changing the ExpansionSize property of the PartCache instance... (This cache now contains a grand total of " .. tostring(#data.Open + #data.InUse + data.ExpansionSize) .. " parts.)")
		end

		for _ = 1, data.ExpansionSize do
			Table.insert(data.Open, MakeFromTemplate(data.Template, data.CurrentCacheParent))
		end
	end

	local v2 = data.Open[#data.Open]
	task.defer(function()
		enableparticles(v2)
	end)
	v2:SetAttribute("cached", nil)
	data.Open[#data.Open] = nil
	Table.insert(data.InUse, v2)
	return v2
end

local thread = nil
local v2 = {}
local v3 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function moveaway()
	thread = task.defer(function()
		thread = nil
		workspace:BulkMoveTo(v2, v3, Enum.BulkMoveMode.FireCFrameChanged)
		Table.clear(v3)
		Table.clear(v2)
	end)
end

function PartCache.ReturnPart(p, instance)
	assert(
		getmetatable(p) == PartCache,
		("Cannot statically invoke method '%s' - It is an instance method. Call it on an instance of this class created via %s"):format(
			"ReturnPart",
			"PartCache.new"
		)
	)
	local index = Table.indexOf(p.InUse, instance)

	if index == nil then
		error("Attempted to return part \"" .. instance.Name .. "\" (" .. instance:GetFullName() .. ") to the cache, but it's not in-use! Did you call this on the wrong part?")
		return
	end

	Table.remove(p.InUse, index)
	Table.insert(p.Open, instance)
	Table.insert(v2, instance)
	Table.insert(v3, cframe)
	task.defer(function()
		disableparticles(instance)
	end)

	if not thread then
		moveaway() -- equivalent call inferred; original call site unknown
	end

	instance:SetAttribute("cached", true)
	instance.Anchored = true
end

function PartCache:SetCacheParent(instance)
	assert(
		getmetatable(self) == PartCache,
		("Cannot statically invoke method '%s' - It is an instance method. Call it on an instance of this class created via %s"):format(
			"SetCacheParent",
			"PartCache.new"
		)
	)
	assert(
		instance:IsDescendantOf(workspace) or instance == workspace,
		"Cache parent is not a descendant of Workspace! Parts should be kept where they will remain in the visible world."
	)
	self.CurrentCacheParent = instance

	for i = 1, #self.Open do
		self.Open[i].Parent = instance
	end

	for i = 1, #self.InUse do
		self.InUse[i].Parent = instance
	end
end

function PartCache.Expand(data, expansionSize: number)
	assert(
		getmetatable(data) == PartCache,
		("Cannot statically invoke method '%s' - It is an instance method. Call it on an instance of this class created via %s"):format(
			"Expand",
			"PartCache.new"
		)
	)

	if expansionSize == nil then
		expansionSize = data.ExpansionSize
	end

	for _ = 1, expansionSize do
		Table.insert(data.Open, MakeFromTemplate(data.Template, data.CurrentCacheParent))
	end
end

function PartCache:Dispose()
	assert(
		getmetatable(self) == PartCache,
		("Cannot statically invoke method '%s' - It is an instance method. Call it on an instance of this class created via %s"):format(
			"Dispose",
			"PartCache.new"
		)
	)

	for i = 1, #self.Open do
		self.Open[i]:Destroy()
	end

	for i = 1, #self.InUse do
		self.InUse[i]:Destroy()
	end

	self.Template:Destroy()
	self.Open = {}
	self.InUse = {}
	self.CurrentCacheParent = nil
	self.GetPart = nil
	self.ReturnPart = nil
	self.SetCacheParent = nil
	self.Expand = nil
	self.Dispose = nil
end

return PartCache