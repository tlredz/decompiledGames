local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local MemoryStoreService = game:GetService("MemoryStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Net = require(ReplicatedStorage.Packages.Net)
local remoteFunction = Net:RemoteFunction("RAP/GetHistory")

local function now()
	return Workspace:GetServerTimeNow()
end

local sortedMaps = {}

local function getMap(p: string)
	local sortedMap = sortedMaps[p]

	if not sortedMap then
		sortedMap = MemoryStoreService:GetSortedMap("RAPD:" .. p)
		sortedMaps[p] = sortedMap
	end

	return sortedMap
end

local v = {}

local function writeBucket(p: string, p2: number, p3: number, p4: number)
	local sortedMap = sortedMaps[p]

	if not sortedMap then
		sortedMap = MemoryStoreService:GetSortedMap("RAPD:" .. p)
		sortedMaps[p] = sortedMap
	end

	local v2 = pcall(function()
		sortedMap:UpdateAsync(tostring(p3), function(p5)
			local sum, count

			if typeof(p5) == "table" then
				sum = p5.sum
				count = p5.count
			else
				sum = 0
				count = 0
			end

			return {
				sum = sum + p2,
				count = count + 1
			}, p3
		end, p4)
	end)

	if v2 then
		v[p] = nil
	end

	return v2
end

local function fetchFromStore(p: string)
	local sortedMap = sortedMaps[p]

	if not sortedMap then
		sortedMap = MemoryStoreService:GetSortedMap("RAPD:" .. p)
		sortedMaps[p] = sortedMap
	end

	local result = {}
	local v2 = math.floor(Workspace:GetServerTimeNow() / 86400)
	local success, result2 = pcall(function()
		return sortedMap:GetRangeAsync(Enum.SortDirection.Descending, 7, {
			sortKey = v2 - 7
		}, {
			sortKey = v2 + 1
		})
	end)

	if success then
		for _, v3 in result2 do
			table.insert(result, {
				day = v3.sortKey,
				sum = v3.value.sum,
				count = v3.value.count
			})
		end
	end

	return result
end

local function getHistory(p: string)
	local v2 = v[p]

	if v2 and Workspace:GetServerTimeNow() - v2.cachedAt < 60 then
		return v2.data
	end

	local selected

	if RunService:IsServer() then
		selected = fetchFromStore(p)
	else
		selected = remoteFunction:InvokeServer(p)
	end

	v[p] = {
		data = selected,
		cachedAt = Workspace:GetServerTimeNow()
	}
	return selected
end

local function serverInit()
	assert(RunService:IsServer(), "server.init 只能由服务器调用")

	remoteFunction.OnServerInvoke = function(_, value)
		if typeof(value) == "string" then
			return (getHistory(value))
		end

		return {}
	end
end

return {
	getHistory = getHistory,
	getAverage = function(p: string)
		local history = getHistory(p)
		local total = 0
		local total2 = 0

		for _, v2 in history do
			total += v2.sum
			total2 += v2.count
		end

		if total2 == 0 then
			return nil
		end

		return total / total2
	end,
	server = {
		init = serverInit,
		record = function(p: string, p2: number)
			assert(RunService:IsServer(), "record 只能由服务器调用")
			task.spawn(function()
				local v2 = p
				local v3 = p2
				local v4 = math.floor(Workspace:GetServerTimeNow() / 86400)
				local sortedMap = sortedMaps[v2]

				if not sortedMap then
					sortedMap = MemoryStoreService:GetSortedMap("RAPD:" .. v2)
					sortedMaps[v2] = sortedMap
				end

				local v5 = 691200

				if pcall(function()
					sortedMap:UpdateAsync(tostring(v4), function(p3)
						local sum, count

						if typeof(p3) == "table" then
							sum = p3.sum
							count = p3.count
						else
							sum = 0
							count = 0
						end

						return {
							sum = sum + v3,
							count = count + 1
						}, v4
					end, v5)
				end) then
					v[v2] = nil
				end
			end)
		end,
		debugRecordAt = function(p: string, p2: number, p3: number)
			assert(RunService:IsServer(), "debugRecordAt 只能由服务器调用")
			local v2 = math.max(60, 691200 - (Workspace:GetServerTimeNow() - p3))
			local v3 = math.floor(p3 / 86400)
			local sortedMap = sortedMaps[p]

			if not sortedMap then
				sortedMap = MemoryStoreService:GetSortedMap("RAPD:" .. p)
				sortedMaps[p] = sortedMap
			end

			local v4 = pcall(function()
				sortedMap:UpdateAsync(tostring(v3), function(p4)
					local sum, count

					if typeof(p4) == "table" then
						sum = p4.sum
						count = p4.count
					else
						sum = 0
						count = 0
					end

					return {
						sum = sum + p2,
						count = count + 1
					}, v3
				end, v2)
			end)

			if v4 then
				v[p] = nil
			end

			return v4
		end
	}
}