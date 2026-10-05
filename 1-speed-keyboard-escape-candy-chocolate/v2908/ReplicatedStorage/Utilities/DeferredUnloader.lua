local DeferredUnloader = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function normalizeRoots(instance)
	if typeof(instance) == "Instance" then
		return { instance }
	end

	return instance
end

local function collectBaseParts(roots)
	local v = {}
	local parts = {}

	for _, part in roots do
		if part:IsA("BasePart") and not v[part] then
			v[part] = true
			table.insert(parts, part)
		end

		for _, part2 in part:GetDescendants() do
			if not part2:IsA("BasePart") or v[part2] then
				continue
			end

			v[part2] = true
			table.insert(parts, part2)
		end
	end

	return parts
end

local function yieldDestroyParts(list, p: number)
	local v = 0

	-- equivalent calls inferred from this helper; original call sites unknown
	local function resetTimer()
		v = tick() + p
	end

	local function maybeYield()
		local now = tick()

		if v <= now then
			task.wait()
			resetTimer() -- equivalent call inferred; original call site unknown
		end
	end

	resetTimer() -- equivalent call inferred; original call site unknown

	for i = #list, 1, -1 do
		local v2 = list[i]

		if v2.Parent then
			v2:Destroy()
		end

		if not (v <= tick()) then
			continue
		end

		task.wait()
		resetTimer() -- equivalent call inferred; original call site unknown
	end

	if v <= tick() then
		task.wait()
		resetTimer() -- equivalent call inferred; original call site unknown
	end
end

local function destroyRoots(items)
	for _, item in items do
		if item.Parent then
			item:Destroy()
		end
	end
end

function DeferredUnloader.new(instance)
	local self = setmetatable({}, {
		__index = DeferredUnloader
	})
	self.roots = normalizeRoots(instance)
	self.task = nil
	return self
end

function DeferredUnloader:CancelAsync()
	if self.task then
		task.cancel(self.task)
		self.task = nil
	end
end

function DeferredUnloader:Unload(p: number)
	self:CancelAsync()
	yieldDestroyParts(collectBaseParts(self.roots), p)

	for _, root in self.roots do
		if root.Parent then
			root:Destroy()
		end
	end
end

function DeferredUnloader:AsynchUnload(p: number, callback)
	self:CancelAsync()
	self.task = task.spawn(function()
		yieldDestroyParts(collectBaseParts(self.roots), p)

		for _, root in self.roots do
			if root.Parent then
				root:Destroy()
			end
		end

		self.task = nil

		if callback then
			callback()
		end
	end)
end

function DeferredUnloader:Destroy()
	self:CancelAsync()
	table.clear(self.roots)
	setmetatable(self, nil)
end

return DeferredUnloader