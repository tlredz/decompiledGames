local cframe = CFrame.new(0, 10000, 0)

-- equivalent calls inferred from this helper; original call sites unknown
local function move_to_new_state(p, prev, state: string)
	local state2 = prev.state

	if prev.prev ~= nil then
		prev.prev.next = prev.next
	end

	if prev.next then
		prev.next.prev = prev.prev
	end

	if p[state2] == prev then
		p[state2] = prev.next
	end

	prev.next = p[state]
	prev.prev = nil

	if p[state] then
		p[state].prev = prev
	end

	prev.state = state
	p[state] = prev
end

local PartCache = {}
PartCache.__index = PartCache

function PartCache.new(instance, parent)
	local object = setmetatable({
		template = instance,
		parent = parent,
		elements = {},
		destroyed = false,
		amount = 0
	}, PartCache)

	if instance.Archivable == false then
		instance.Archivable = true
		local clone = instance:Clone()
		instance.Archivable = false
		instance = clone
	end

	if instance:IsA("Model") then
		if instance.PrimaryPart ~= nil then
			instance.PrimaryPart.Anchored = true
		end
	elseif instance:IsA("BasePart") then
		instance.Anchored = true
	end

	instance.Parent = nil
	object:ExpandCache()
	return object
end

function PartCache:ExpandCache(value)
	if self.destroyed == true then
		error("Cannot Expand() a destroyed PartCache")
	end

	local v = value or 20
	local _ = self.amount == 0
	self.amount += v
	local isA = self.template:IsA("Model")
	local clones = {}
	local cframes = {}

	for _ = 1, v do
		local clone = self.template:Clone()

		if isA then
			clone:PivotTo(cframe)
		else
			table.insert(clones, clone)
			table.insert(cframes, cframe)
		end

		clone.Parent = self.parent
		local prev = {
			element = clone
		}
		self.elements[clone] = prev
		move_to_new_state(self, prev, "available") -- equivalent call inferred; original call site unknown
	end

	if isA == false then
		workspace:BulkMoveTo(clones, cframes)
	end
end

function PartCache:Get()
	if self.destroyed == true then
		error("Cannot Get() to a destroyed PartCache")
	end

	local available

	if self.cleaning == nil then
		if self.available == nil then
			self:ExpandCache()
		end

		available = self.available
	else
		available = self.cleaning
	end

	move_to_new_state(self, available, "unavailable") -- equivalent call inferred; original call site unknown
	return available.element
end

function PartCache:Return(instance)
	if self.destroyed == true then
		error("Cannot Return() to a destroyed PartCache")
	end

	if self.cleaning_thread == nil then
		self.cleaning_thread = task.defer(function()
			self.cleaning_thread = nil
			local isA = self.template:IsA("Model")
			local elements = {}
			local cframes = {}

			while self.cleaning ~= nil do
				if isA == true then
					self.cleaning.element:PivotTo(cframe)
				else
					local element = self.cleaning.element
					element.Anchored = true
					table.insert(elements, element)
					table.insert(cframes, cframe)
				end

				move_to_new_state(self, self.cleaning, "available") -- equivalent call inferred; original call site unknown
			end

			if isA == false then
				workspace:BulkMoveTo(elements, cframes)
			end
		end)
	end

	local element = self.elements[instance]

	if element == nil then
		error((`Cannot return a part that does not exist in PartCache: {instance:GetFullName()}`))
	end

	move_to_new_state(self, element, "cleaning") -- equivalent call inferred; original call site unknown
end

function PartCache:Destroy()
	if self.destroyed == true then
		return
	end

	self.destroyed = true

	if self.cleaning_thread ~= nil then
		task.cancel(self.cleaning_thread)
	end

	for _, element in self.elements do
		element.element:Destroy()
		element.next = nil
		element.prev = nil
	end

	table.clear(self.elements)
	self.template:Destroy()
	self.cleaning = nil
	self.available = nil
	self.unavailable = nil
end

return PartCache