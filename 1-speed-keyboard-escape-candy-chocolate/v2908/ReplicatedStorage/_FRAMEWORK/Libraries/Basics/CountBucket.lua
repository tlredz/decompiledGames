local v = {}
local object = setmetatable({}, {
	__mode = "k"
})

-- equivalent calls inferred from this helper; original call sites unknown
local function getState(p)
	local v2 = object[p]
	assert(v2 ~= nil, "Invalid CountBucket")
	return v2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getCurrentBucketId(state)
	return (math.floor(os.clock() / state.bucketDuration))
end

local function getBucketIndex(p: number, p2: number)
	return p % p2 + 1
end

local function isBucketInWindow(p: number, p2: number, p3: number)
	local v2 = p2 - p
	return v2 >= 0 and v2 < p3
end

local function readCountBucketField(_, p: string)
	local v2 = v[p]

	if v2 ~= nil then
		return v2
	end

	error(`Cannot directly read CountBucket field '{p}'`, 2)
end

local function rejectCountBucketWrite(_, p: string, _)
	error(`Cannot directly write CountBucket field '{p}'`, 2)
end

local v2 = {
	__index = readCountBucketField,
	__newindex = rejectCountBucketWrite
}
table.freeze(v2)

function v.increment(p, value: number?)
	local v3 = value or 1
	local v4

	if v3 >= 1 then
		v4 = v3 % 1 == 0
	else
		v4 = false
	end

	assert(v4, "CountBucket increment amount must be a positive integer")
	local state = getState(p) -- equivalent call inferred; original call site unknown
	local currentBucketId = getCurrentBucketId(state) -- equivalent call inferred; original call site unknown
	local bucket = state.buckets[currentBucketId % state.bucketCount + 1]

	if bucket.bucketId ~= currentBucketId then
		bucket.bucketId = currentBucketId
		bucket.count = 0
	end

	bucket.count += v3
end

function v.getCount(p)
	local state = getState(p) -- equivalent call inferred; original call site unknown
	local currentBucketId = getCurrentBucketId(state) -- equivalent call inferred; original call site unknown
	local total = 0

	for _, bucket in state.buckets do
		local bucketId = bucket.bucketId
		local bucketCount = state.bucketCount
		local v3 = currentBucketId - bucketId
		local v4

		if v3 >= 0 then
			v4 = v3 < bucketCount
		else
			v4 = false
		end

		if v4 then
			total += bucket.count
		end
	end

	return total
end

function v.getBuckets(p)
	local state = getState(p) -- equivalent call inferred; original call site unknown
	local currentBucketId = getCurrentBucketId(state) -- equivalent call inferred; original call site unknown
	local result = table.create(state.bucketCount)

	for i = currentBucketId - state.bucketCount + 1, currentBucketId do
		local bucket = state.buckets[i % state.bucketCount + 1]
		table.insert(result, {
			startedAt = i * state.bucketDuration,
			count = bucket.bucketId ~= i and 0 or bucket.count
		})
	end

	return result
end

function v.clear(p)
	local state = getState(p) -- equivalent call inferred; original call site unknown

	for _, bucket in state.buckets do
		bucket.bucketId = -1
		bucket.count = 0
	end
end

return {
	new = function(value: number?, value2: number?)
		local bucketCount = value or 60
		local bucketDuration = value2 or 1
		local v5

		if bucketCount >= 1 then
			v5 = bucketCount % 1 == 0
		else
			v5 = false
		end

		assert(v5, "CountBucket bucket count must be a positive integer")
		assert(bucketDuration > 0, "CountBucket bucket duration must be positive")
		local buckets = table.create(bucketCount)

		for _ = 1, bucketCount do
			table.insert(buckets, {
				bucketId = -1,
				count = 0
			})
		end

		local self = setmetatable({}, v2)
		object[self] = {
			bucketCount = bucketCount,
			bucketDuration = bucketDuration,
			buckets = buckets
		}
		table.freeze(self)
		return self
	end
}