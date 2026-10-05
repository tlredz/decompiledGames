local DeferredMapLoader = {}

local function YieldLoadWithBudget(keycaps, parent, p: number, options)
	local children = keycaps:GetChildren()
	local v, v2 = next(children, nil)
	local clones = options or {}
	local v3 = 0

	-- equivalent calls inferred from this helper; original call sites unknown
	local function ResetTimer()
		v3 = tick() + p
	end

	local function MaybeYield()
		local now = tick()

		if v3 <= now then
			task.wait()
			ResetTimer() -- equivalent call inferred; original call site unknown
		end
	end

	local function LoadAsset(instance, parent2, callback)
		local clone = instance:Clone()
		clone.Parent = parent2
		table.insert(clones, clone)
		callback()
	end

	ResetTimer() -- equivalent call inferred; original call site unknown
	local v4 = false

	while not v4 do
		if v2 then
			local clone = v2:Clone()
			clone.Parent = parent
			table.insert(clones, clone)
			v, v2 = next(children, v)

			if v3 <= tick() then
				task.wait()
				ResetTimer() -- equivalent call inferred; original call site unknown
			end
		else
			v4 = true
		end
	end

	if v3 <= tick() then
		task.wait()
		ResetTimer() -- equivalent call inferred; original call site unknown
	end

	return clones
end

function DeferredMapLoader.new(map)
	local object = setmetatable({}, {
		__index = DeferredMapLoader
	})
	object.map = map
	object.keycaps = map:FindFirstChild("Keycaps")
	return object
end

function DeferredMapLoader.Load(p, p2, p3: number)
	if p.keycaps and p2 then
		return (YieldLoadWithBudget(p.keycaps, p2, p3))
	end

	return {}
end

function DeferredMapLoader:Asynchload(parent, p2: number, callback)
	self:CancelAsynch()

	if self.keycaps and parent then
		self._loadedAssets = {}
		self.task = task.spawn(function()
			local yieldLoadWithBudget = YieldLoadWithBudget(self.keycaps, parent, p2, self._loadedAssets)
			self.task = nil
			self._loadedAssets = nil
			callback(yieldLoadWithBudget)
		end)
	elseif callback then
		callback({})
	end
end

function DeferredMapLoader:CancelAsynch()
	if self.task then
		task.cancel(self.task)
		self.task = nil
	end

	local _loadedAssets = self._loadedAssets

	if _loadedAssets then
		for _, _loadedAsset in _loadedAssets do
			if _loadedAsset.Parent then
				_loadedAsset:Destroy()
			end
		end

		table.clear(_loadedAssets)
		self._loadedAssets = nil
	end
end

function DeferredMapLoader:Destroy()
	self:CancelAsynch()
	table.clear(self)
	setmetatable(self, {
		__mode = "kv"
	})
	table.freeze(self)
end

return DeferredMapLoader