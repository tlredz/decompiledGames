local BattleAnalysisJobQueue = {}
BattleAnalysisJobQueue.__index = BattleAnalysisJobQueue
local v = { "pair", "ball", "global" }

function BattleAnalysisJobQueue.new()
	return (setmetatable({
		_buckets = {
			pair = {},
			ball = {},
			global = {}
		},
		_cursors = {
			pair = 0,
			ball = 0,
			global = 0
		},
		_byId = {},
		_nextId = 0
	}, BattleAnalysisJobQueue))
end

function BattleAnalysisJobQueue:create(kind: string, targetId: string, targetLabel: string, pairKeys)
	local _bucket = self._buckets[kind]
	assert(_bucket ~= nil, string.format("未知 job 类型：%s", (tostring(kind))))
	assert(#pairKeys > 0, "job 至少要覆盖一个组合")

	for _, v2 in ipairs(_bucket) do
		if v2.targetId ~= targetId then
			continue
		end

		v2.paused = false
		return v2, false
	end

	self._nextId += 1
	local now = os.clock()
	local v2 = {
		id = string.format("%s_%d", kind, self._nextId),
		kind = kind,
		targetId = targetId,
		targetLabel = targetLabel,
		pairKeys = pairKeys,
		cursor = 0,
		completedCount = 0,
		paused = false,
		startedAt = os.time(),
		ratePerSecond = 0,
		_windowStart = now,
		_windowCount = 0
	}
	table.insert(_bucket, v2)
	self._byId[v2.id] = v2
	return v2, true
end

function BattleAnalysisJobQueue:nextPairKey()
	local count = #self.pairKeys

	if count == 0 then
		return nil
	end

	self.cursor = self.cursor % count + 1
	return self.pairKeys[self.cursor]
end

function BattleAnalysisJobQueue:pickNext()
	for _, v2 in ipairs(v) do
		local _bucket = self._buckets[v2]
		local count = #_bucket

		if not (count > 0) then
			continue
		end

		local _cursor = self._cursors[v2]

		for i = 1, count do
			local v3 = (_cursor + i - 1) % count + 1
			local v4 = _bucket[v3]

			if v4.paused then
				continue
			end

			self._cursors[v2] = v3
			return v4
		end
	end

	return nil
end

function BattleAnalysisJobQueue.recordCompletion(_, state, p: number)
	if p <= 0 then
		return
	end

	state.completedCount += p
	state._windowCount += p
	local now = os.clock()
	local v2 = now - state._windowStart

	if v2 >= 3 then
		state.ratePerSecond = state._windowCount / v2
		state._windowStart = now
		state._windowCount = 0
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function currentRate(p)
	if os.clock() - p._windowStart >= 6 then
		return 0
	end

	return p.ratePerSecond
end

function BattleAnalysisJobQueue:get(p2: string)
	return self._byId[p2]
end

function BattleAnalysisJobQueue:setPaused(p2: string, flag: boolean)
	local v2 = self._byId[p2]

	if not v2 then
		return false
	end

	v2.paused = flag == true
	return true
end

function BattleAnalysisJobQueue:remove(p: string)
	local v2 = self._byId[p]

	if not v2 then
		return false
	end

	local _bucket = self._buckets[v2.kind]

	for i = #_bucket, 1, -1 do
		if _bucket[i].id ~= p then
			continue
		end

		table.remove(_bucket, i)

		if i <= self._cursors[v2.kind] then
			self._cursors[v2.kind] = math.max(0, self._cursors[v2.kind] - 1)
		end
	end

	self._byId[p] = nil
	return true
end

function BattleAnalysisJobQueue:list()
	local result = {}

	for _, v2 in ipairs(v) do
		for _, v3 in ipairs(self._buckets[v2]) do
			table.insert(result, {
				id = v3.id,
				kind = v3.kind,
				targetId = v3.targetId,
				targetLabel = v3.targetLabel,
				pairCount = #v3.pairKeys,
				completedCount = v3.completedCount,
				paused = v3.paused,
				startedAt = v3.startedAt,
				ratePerSecond = currentRate(v3)
			})
		end
	end

	return result
end

function BattleAnalysisJobQueue:count()
	local total = 0

	for _, v2 in ipairs(v) do
		total += #self._buckets[v2]
	end

	return total
end

return BattleAnalysisJobQueue