local PoolHide = require(script.Parent.PoolHide)
local Pool = {}

local function _getPoolFolder()
	local part_IclesPooled = workspace.Terrain:FindFirstChild("Part_IclesPooled")

	if part_IclesPooled then
		return part_IclesPooled
	end

	local folder = Instance.new("Folder")
	folder.Name = "Part_IclesPooled"
	folder.Archivable = false
	folder.Parent = workspace.Terrain
	return folder
end

Pool._pools = setmetatable({}, {
	__mode = "k"
})
Pool._totalSize = 0
Pool._lastSweepAt = 0
Pool._lastReportAt = 0
Pool.MAX_POOL_TOTAL = 2048
Pool.TTL = 5
Pool.SWEEP_INTERVAL = 2
Pool.REPORT_INTERVAL = 0
Pool.MIN_CAP = 8
Pool.CAP_SAFETY = 1.25

-- equivalent calls inferred from this helper; original call sites unknown
local function estimateCap(value)
	return math.ceil(math.max(value or 0, 0) * Pool.TTL * Pool.CAP_SAFETY) + Pool.MIN_CAP
end

local function getOrInitPool(instance)
	local _pool = Pool._pools[instance]

	if _pool then
		return _pool
	end

	local v = {
		entries = {},
		gen = instance:GetAttribute("_PoolGen") or 0,
		cap = Pool.MIN_CAP,
		peakSize = 0,
		hits = 0,
		misses = 0,
		evictions = 0
	}
	Pool._pools[instance] = v
	return v
end

-- equivalent calls inferred from this helper; original call sites unknown
local function destroyEntry(p)
	if p and p.instance then
		pcall(function()
			p.instance:Destroy()
		end)
	end
end

local function discardAllEntries(p)
	for i = 1, #p.entries do
		destroyEntry(p.entries[i]) -- equivalent call inferred; original call site unknown
	end

	Pool._totalSize = math.max(0, Pool._totalSize - #p.entries)
	p.entries = {}
end

function Pool.acquire(instance, p)
	if not instance then
		return nil
	end

	local initPool = getOrInitPool(instance)
	local _PoolGen = instance:GetAttribute("_PoolGen") or 0

	if _PoolGen ~= initPool.gen then
		discardAllEntries(initPool)
		initPool.gen = _PoolGen
	end

	while #initPool.entries > 0 do
		local v = table.remove(initPool.entries)
		Pool._totalSize = math.max(0, Pool._totalSize - 1)
		local instance2 = v.instance

		if not (instance2 and instance2.Parent) then
			continue
		end

		PoolHide.show(instance2, p)
		initPool.hits += 1
		return instance2
	end

	initPool.misses += 1
	return nil
end

function Pool.release(instance, p, p2, value)
	if not (instance and p and instance.Parent) then
		return
	end

	local initPool = getOrInitPool(p)

	if value then
		initPool.cap = estimateCap(value)
	end

	if Pool._totalSize >= Pool.MAX_POOL_TOTAL then
		pcall(function()
			instance:Destroy()
		end)
		return
	end

	while #initPool.entries >= initPool.cap do
		local v = table.remove(initPool.entries, 1)
		Pool._totalSize = math.max(0, Pool._totalSize - 1)
		destroyEntry(v) -- equivalent call inferred; original call site unknown
		initPool.evictions += 1
	end

	PoolHide.hide(instance, p2)
	pcall(function()
		local instance2 = instance
		local parent = workspace.Terrain:FindFirstChild("Part_IclesPooled")

		if not parent then
			parent = Instance.new("Folder")
			parent.Name = "Part_IclesPooled"
			parent.Archivable = false
			parent.Parent = workspace.Terrain
		end

		instance2.Parent = parent
	end)
	initPool.entries[#initPool.entries + 1] = {
		instance = instance,
		pooledAt = os.clock()
	}
	Pool._totalSize += 1

	if #initPool.entries > initPool.peakSize then
		initPool.peakSize = #initPool.entries
	end
end

function Pool.tickSweep(lastSweepAt)
	if lastSweepAt - Pool._lastSweepAt < Pool.SWEEP_INTERVAL then
		return
	end

	Pool._lastSweepAt = lastSweepAt
	local v = 64
	local v2 = nil

	for k, _pool in pairs(Pool._pools) do
		local v3 = 1

		while v3 <= #_pool.entries and v > 0 do
			local entry = _pool.entries[v3]
			local instance = entry.instance

			if lastSweepAt - entry.pooledAt > Pool.TTL or not (instance and instance.Parent) then
				destroyEntry(entry) -- equivalent call inferred; original call site unknown
				local count = #_pool.entries

				if v3 < count then
					_pool.entries[v3] = _pool.entries[count]
				end

				_pool.entries[count] = nil
				Pool._totalSize = math.max(0, Pool._totalSize - 1)
				_pool.evictions += 1
				v -= 1
			else
				v3 += 1
			end
		end

		if #_pool.entries ~= 0 or k and k.Parent then
			continue
		end

		v2 = v2 or {}
		v2[#v2 + 1] = k
	end

	if v2 then
		for _, v3 in ipairs(v2) do
			Pool._pools[v3] = nil
		end
	end
end

function Pool.bumpGen(instance)
	if not instance then
		return
	end

	local _PoolGen = instance:GetAttribute("_PoolGen") or 0
	pcall(function()
		instance:SetAttribute("_PoolGen", _PoolGen + 1)
	end)
end

function Pool.flushSource(p)
	local _pool = Pool._pools[p]

	if not _pool then
		return
	end

	discardAllEntries(_pool)
	Pool._pools[p] = nil
end

function Pool.flushAll()
	for _, _pool in pairs(Pool._pools) do
		discardAllEntries(_pool)
	end

	Pool._pools = setmetatable({}, {
		__mode = "k"
	})
	Pool._totalSize = 0
end

function Pool.tickReport(lastReportAt)
	if Pool.REPORT_INTERVAL <= 0 or lastReportAt - Pool._lastReportAt < Pool.REPORT_INTERVAL then
		return
	end

	Pool._lastReportAt = lastReportAt
	local count = 0
	local total = 0
	local total2 = 0
	local total3 = 0
	local total4 = 0
	local peakSize = 0

	for _ in pairs(Pool._pools) do
		count += 1
	end

	for _, _pool in pairs(Pool._pools) do
		total += #_pool.entries
		total2 += _pool.hits
		total3 += _pool.misses
		total4 += _pool.evictions

		if peakSize < _pool.peakSize then
			peakSize = _pool.peakSize
		end
	end

	local v = not (total2 + total3 > 0) and 0 or total2 / (total2 + total3) * 100 or 0
	print(string.format(
		"[Part-Icles Pool] sources=%d entries=%d/%d peak=%d hits=%d misses=%d (%.1f%% hit) evictions=%d",
		count,
		total,
		Pool.MAX_POOL_TOTAL,
		peakSize,
		total2,
		total3,
		v,
		total4
	))
end

function Pool.acquireOrClone(instance, p, p2)
	local clone

	if p2 == false then
		clone = instance:Clone()
	else
		clone = Pool.acquire(instance, p) or instance:Clone()
	end

	clone:SetAttribute("_PartIcleEmit", true)
	return clone
end

local copyBare

copyBare = function(instance, options, p)
	local instancesByInstance = options or {}
	local instance2 = Instance.fromExisting(instance)
	instancesByInstance[instance] = instance2

	for _, child in ipairs(instance:GetChildren()) do
		if child:GetAttribute("Transformed") then
			continue
		end

		local copyBare_2 = copyBare(child, instancesByInstance, false)
		copyBare_2.Parent = instance2
	end

	if p ~= nil and not p then
		return instance2, instancesByInstance
	end

	for effect, v in pairs(instancesByInstance) do
		if not (effect:IsA("Trail") or effect:IsA("Beam")) then
			continue
		end

		local attachment0 = effect.Attachment0
		local attachment1 = effect.Attachment1

		if attachment0 and instancesByInstance[attachment0] then
			v.Attachment0 = instancesByInstance[attachment0]
		end

		if attachment1 and instancesByInstance[attachment1] then
			v.Attachment1 = instancesByInstance[attachment1]
		end
	end

	return instance2, instancesByInstance
end

Pool.copyBare = copyBare
Pool._cloneMaps = setmetatable({}, {
	__mode = "k"
})

function Pool.acquireOrCopyBare(p, p2, p3)
	local v, v2

	if p3 == false then
		v, v2 = copyBare(p)
	else
		v = Pool.acquire(p, p2)

		if v then
			v2 = Pool._cloneMaps[v]
		else
			v, v2 = copyBare(p)
		end
	end

	if v2 then
		Pool._cloneMaps[v] = v2
	end

	v:SetAttribute("_PartIcleEmit", true)
	return v
end

function Pool.restoreTrails(p, p2)
	task.delay(0, function()
		if p and p.Parent then
			PoolHide.restoreTrails(p, p2)
		end
	end)
end

function Pool.tick(p)
	Pool.tickSweep(p)
	Pool.tickReport(p)
end

function Pool.stats()
	local v = {
		totalSize = Pool._totalSize,
		sources = {}
	}

	for k, _pool in pairs(Pool._pools) do
		v.sources[k] = {
			size = #_pool.entries,
			peakSize = _pool.peakSize,
			cap = _pool.cap,
			gen = _pool.gen,
			hits = _pool.hits,
			misses = _pool.misses,
			evictions = _pool.evictions
		}
	end

	return v
end

return Pool