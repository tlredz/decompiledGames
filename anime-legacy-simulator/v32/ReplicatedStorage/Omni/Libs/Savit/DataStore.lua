local DataStoreService = game:GetService("DataStoreService")
local DataStore = {}
DataStore.__index = DataStore

local function Try(p: number, callback, ...)
	for _ = 1, p do
		local v = { pcall(callback, ...) }

		if v[1] then
			return table.unpack(v)
		else
			task.wait(0.25)
		end
	end

	return nil
end

local function GetRequestBudget(p)
	return DataStoreService:GetRequestBudgetForRequestType(p)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function IsRequestCurrentlySafe(p)
	return DataStoreService:GetRequestBudgetForRequestType(p) >= 1
end

local function WaitForRequestToBeSafe(p)
	while true do
		local requestCurrentlySafe = IsRequestCurrentlySafe(p) -- equivalent call inferred; original call site unknown

		if requestCurrentlySafe then
			break
		end

		task.wait(1)

		if requestCurrentlySafe then
			break
		end
	end
end

function DataStore.GetAsync(data, data2)
	if not (typeof(data2) == "table" and typeof(data2.Key) == "string") then
		return
	end

	local v = data.KeysCache[data2.Key]

	if v and not data2.BypassCache and os.clock() - v.Time <= v.Duration then
		return v.Value
	end

	local threads = data.PendingRequests[data2.Key]

	if threads then
		table.insert(threads, coroutine.running())
		return coroutine.yield()
	end

	local v2 = {}
	data.PendingRequests[data2.Key] = v2

	if data2.ShouldWait == true then
		WaitForRequestToBeSafe(Enum.DataStoreRequestType.GetAsync)
	end

	local v3, value

	if DataStoreService:GetRequestBudgetForRequestType(Enum.DataStoreRequestType.GetAsync) >= 1 then
		v3, value = Try(2, data.Store.GetAsync, data.Store, data2.Key)
	else
		v3 = false
	end

	local now = os.clock()

	if v3 then
		if data2.CacheDuration then
			data.KeysCache[data2.Key] = {
				Value = value,
				Time = now,
				Duration = data2.CacheDuration
			}
		end
	elseif v then
		v.Time = now
		v.Duration = 30
		value = v.Value
	elseif data2.CacheDuration then
		data.KeysCache[data2.Key] = {
			Value = nil,
			Time = now,
			Duration = 30
		}
	end

	data.PendingRequests[data2.Key] = nil

	for _, callback in v2 do
		task.spawn(callback, value)
	end

	return value
end

function DataStore.SetAsync(p, value: string, p2, flag: boolean?)
	if typeof(value) ~= "string" then
		return false
	end

	if flag == true then
		WaitForRequestToBeSafe(Enum.DataStoreRequestType.SetIncrementAsync)
	end

	if DataStoreService:GetRequestBudgetForRequestType(Enum.DataStoreRequestType.SetIncrementAsync) >= 1 then
		return Try(5, p.Store.SetAsync, p.Store, value, p2) == true
	end

	return false
end

function DataStore.UpdateAsync(p, value: string, callback, flag: boolean?)
	if not (typeof(value) == "string" and typeof(callback) == "function") then
		return
	end

	if flag == true then
		WaitForRequestToBeSafe(Enum.DataStoreRequestType.UpdateAsync)
	end

	if DataStoreService:GetRequestBudgetForRequestType(Enum.DataStoreRequestType.UpdateAsync) >= 1 then
		local v, v2 = Try(5, p.Store.UpdateAsync, p.Store, value, callback)
		return v and v2 or nil
	else
		return nil
	end
end

function DataStore.IncrementAsync(p, value: string, value2: number?, flag: boolean?)
	if typeof(value) ~= "string" then
		return
	end

	if flag == true then
		WaitForRequestToBeSafe(Enum.DataStoreRequestType.SetIncrementAsync)
	end

	if DataStoreService:GetRequestBudgetForRequestType(Enum.DataStoreRequestType.SetIncrementAsync) >= 1 then
		local v, v2 = Try(5, p.Store.IncrementAsync, p.Store, value, value2 or 1)
		return v and v2 or nil
	else
		return nil
	end
end

function DataStore.RemoveAsync(p, value: string, flag: boolean?)
	if typeof(value) ~= "string" then
		return
	end

	if flag == true then
		WaitForRequestToBeSafe(Enum.DataStoreRequestType.StandardRemove)
	end

	if DataStoreService:GetRequestBudgetForRequestType(Enum.DataStoreRequestType.StandardRemove) >= 1 then
		local v, v2 = Try(5, p.Store.RemoveAsync, p.Store, value)
		return v and v2 or nil
	else
		return nil
	end
end

return DataStore