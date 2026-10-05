local import = _G.import("dictUtil")
local MemoryStoreService = game:GetService("MemoryStoreService")
local HttpService = game:GetService("HttpService")
game:GetService("RunService")
local v = {
	t0 = time(),
	lastPrint = time(),
	hash_get = 0,
	hash_set = 0,
	hash_remove = 0,
	hash_update = 0,
	sorted_set = 0,
	sorted_remove = 0,
	sorted_getrange_calls = 0,
	sorted_getrange_items = 0,
	errors = 0,
	retries = 0
}

local function bump(_, _) end

local function elapsedSince(p)
	return (math.max(1e-6, time() - p))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function estimateRUPerMin()
	local v2 = v.hash_get + v.hash_set + v.hash_remove + v.hash_update + v.sorted_set + v.sorted_remove + v.sorted_getrange_calls + v.sorted_getrange_items
	local t0 = v.t0
	return v2 / (math.max(1e-6, time() - t0) / 60)
end

local function opsPerMin()
	local t0 = v.t0
	local v2 = math.max(1e-6, time() - t0) / 60
	return {
		hash_get = v.hash_get / v2,
		hash_set = v.hash_set / v2,
		hash_remove = v.hash_remove / v2,
		hash_update = v.hash_update / v2,
		sorted_set = v.sorted_set / v2,
		sorted_remove = v.sorted_remove / v2,
		sorted_getrange_calls = v.sorted_getrange_calls / v2,
		sorted_getrange_items = v.sorted_getrange_items / v2,
		errors = v.errors / v2,
		retries = v.retries / v2
	}
end

local function maybePrint() end

-- equivalent calls inferred from this helper; original call sites unknown
local function isTransientMemoryStoreError(result)
	local v2 = tostring(result)
	return string.find(v2, "InternalError", 1, true) or string.find(v2, "ServiceUnavailable", 1, true)
end

local function handleMemoryStoreError(p, result, value)
	if not p then
		warn(("[memoryStoreUtil] %s error: %s"):format(value or "MemoryStore", (tostring(result))))
	end

	return p, result
end

local function retryMemoryStore(p, fn)
	for i = 1, 6 do
		local success, result = pcall(fn)

		if success then
			if i > 1 then
				local _ = i - 1
			end

			return true, result
		elseif isTransientMemoryStoreError(result) and i ~= 6 then
			local v3 = math.random() * 0.05
			task.wait((math.min(1, 2 ^ (i - 1) * 0.05 + v3)))
		else
			if i > 1 then
				local _ = i - 1
			end

			return handleMemoryStoreError(false, result, p)
		end
	end

	return false, p .. " retry loop fell through"
end

local MemoryStoreUtil = {
	memoryStoreStatsSnapshot = function(p)
		local copy = import.shallowCopy(v)
		copy.estimated_ru_per_min = estimateRUPerMin()
		local now = os.clock()

		if not p then
			return copy
		end

		v.t0 = now
		v.lastPrint = now
		v.hash_get = 0
		v.hash_set = 0
		v.hash_remove = 0
		v.hash_update = 0
		v.sorted_set = 0
		v.sorted_remove = 0
		v.sorted_getrange_calls = 0
		v.sorted_getrange_items = 0
		v.errors = 0
		v.retries = 0
		return copy
	end,
	getHashMapData = function(value, value2)
		assert(type(value) == "string", "Key must be a string")
		assert(type(value2) == "string", "Field must be a string")
		local success, result = pcall(function()
			return MemoryStoreService:GetHashMap(value):GetAsync(value2)
		end)

		if not success then
			return false, "MemoryStore GetAsync failed"
		end

		if not result then
			return
		end

		local success2, result2 = pcall(HttpService.JSONDecode, HttpService, result)

		if success2 then
			return result2
		end

		return false, "JSONDecode failed"
	end,
	setHashMapData = function(value, p, p2, value2)
		assert(type(value) == "string", "Key must be a string")
		assert(type(p) == "table", "Data must be a table")
		assert(type(value2) == "string", "Field must be a string")
		local jSONEncode = HttpService:JSONEncode(p)
		local hashMap = MemoryStoreService:GetHashMap(value)
		local v2, v3 = retryMemoryStore("HashMap SetAsync", function()
			return hashMap:SetAsync(value2, jSONEncode, p2)
		end)
		return v2, v3
	end,
	removeHashMapData = function(value, value2)
		assert(type(value) == "string", "Key must be a string")
		assert(type(value2) == "string", "Field must be a string")
		local hashMap = MemoryStoreService:GetHashMap(value)
		local v2, v3 = retryMemoryStore("HashMap RemoveAsync", function()
			return hashMap:RemoveAsync(value2)
		end)
		return v2, v3
	end,
	updateHashMapData = function(value, value2, callback, p)
		assert(type(value) == "string", "Key must be a string")
		assert(type(value2) == "string", "Field must be a string")
		assert(type(callback) == "function", "UpdateFunction must be a function")
		local hashMap = MemoryStoreService:GetHashMap(value)
		return retryMemoryStore("HashMap UpdateAsync", function()
			return hashMap:UpdateAsync(value2, callback, p)
		end)
	end
}

function MemoryStoreUtil.getNewestSortedMapEntries(value, value2, p)
	assert(type(value) == "string", "Key must be a string")
	return MemoryStoreUtil.getSortedMapEntries(value, value2 or 50, Enum.SortDirection.Descending, p)
end

function MemoryStoreUtil.getSortedMapEntries(value, value2, p, p2, p3)
	assert(type(value) == "string", "Key must be a string")
	local v2 = value2 or 100
	assert(type(v2) == "number", "Count must be a number")
	local v3 = p or Enum.SortDirection.Ascending
	local success, result = pcall(function()
		return MemoryStoreService:GetSortedMap(value):GetRangeAsync(v3, v2, p2, p3)
	end)

	if not (success and result) then
		warn(("[memoryStoreUtil] failed to fetch entries for %s"):format(value))
		return {}
	end

	local _ = #result
	local result2 = {}
	local v4 = nil

	for _, v5 in ipairs(result) do
		local success2, result3 = pcall(HttpService.JSONDecode, HttpService, v5.value)

		if success2 and result3 then
			result3._ms_key = v5.key
			result3._ms_sortKey = v5.sortKey
			table.insert(result2, result3)
		end

		v4 = {
			sortKey = v5.sortKey,
			key = v5.key
		}
	end

	return result2, v4
end

function MemoryStoreUtil.getSortedMapEntriesBySortKeyRange(value, value2, p, value3, value4, p2)
	assert(type(value) == "string", "Key must be a string")
	local v2 = value2 or 100
	assert(type(v2) == "number", "Count must be a number")
	local v3 = p or Enum.SortDirection.Ascending
	local v4

	if type(value3) == "number" then
		v4 = type(value4) == "number"
	else
		v4 = false
	end

	assert(v4, "SortKey range must be numbers")
	local v5 = p2 or {
		sortKey = value3 - 1e-6
	}
	local v6 = {
		sortKey = value4 + 1e-6
	}
	return MemoryStoreUtil.getSortedMapEntries(value, v2, v3, v5, v6)
end

function MemoryStoreUtil.setSortedMapData(value, value2, p, p2, p3)
	assert(type(value) == "string", "Key must be a string")
	assert(type(value2) == "string", "ItemKey must be a string")
	assert(type(p) == "table", "Data must be a table")
	local jSONEncode = HttpService:JSONEncode(p)
	return retryMemoryStore("SortedMap SetAsync", function()
		return MemoryStoreService:GetSortedMap(value):SetAsync(value2, jSONEncode, p2, p3)
	end)
end

function MemoryStoreUtil.removeSortedMapData(value, value2)
	assert(type(value) == "string", "Key must be a string")
	assert(type(value2) == "string", "ItemKey must be a string")
	return retryMemoryStore("SortedMap RemoveAsync", function()
		return MemoryStoreService:GetSortedMap(value):RemoveAsync(value2)
	end)
end

return MemoryStoreUtil