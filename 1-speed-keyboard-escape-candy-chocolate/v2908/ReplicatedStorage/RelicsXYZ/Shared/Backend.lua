local Backend = {}
local parent = script.Parent
local Promise = require(parent.Promise)
local Network = require(parent.Network)
local RunContext = require(parent.RunContext)
local HttpService = game:GetService("HttpService")
local ServerStorage = game:GetService("ServerStorage")
local EncodingService = game:GetService("EncodingService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MemoryStoreService

if RunContext.IsServer or RunContext.IsEdit then
	MemoryStoreService = game:GetService("MemoryStoreService")
end

local DataStoreService

if RunContext.IsServer or RunContext.IsEdit then
	DataStoreService = game:GetService("DataStoreService")
end

local MessagingService

if RunContext.IsServer or RunContext.IsEdit then
	MessagingService = game:GetService("MessagingService")
else
	MessagingService = nil
end

local hashMap

if MemoryStoreService then
	hashMap = MemoryStoreService:GetHashMap("RELICS_API_CACHE")
else
	hashMap = nil
end

local dataStore

if DataStoreService then
	dataStore = DataStoreService:GetDataStore("RELICS_API_CACHE")
else
	dataStore = nil
end

local event = Network.Event("DevMockFreemium", function(p)
	assert(type(p) == "boolean")
end)
local v = math.random(0, 30)
local v2 = game.JobId == "" and "Studio" or game.JobId

local function pcallWithRetry(p: string, fn)
	local v3 = nil
	local traceback = nil

	for i = 1, 3 do
		local v4, v5 = xpcall(fn, function(p2)
			v3 = p2
			traceback = debug.traceback()
		end)

		if v4 then
			return true, v5
		end

		if not (i < 3) then
			continue
		end

		local v6 = math.min(1.5, 2 ^ (i - 1) * 0.15)
		task.wait(v6)
	end

	warn(`[RelicsXYZ.Backend] {p} failed after {3} attempts:`, v3, traceback)
	return false, nil
end

local function getSecret(value: string?)
	local v3 = value or "RELICS_API_KEY"
	local stringValue = ServerStorage:FindFirstChild(v3)
	local v4

	if stringValue and stringValue:IsA("StringValue") then
		v4 = `Basic {stringValue.Value}`
	else
		v4 = nil
	end

	xpcall(function()
		local secret = HttpService:GetSecret(v3)

		if secret then
			v4 = secret:AddPrefix("Basic ")
		end
	end, function()
		warn((`[RelicsXYZ.Backend] Secret '{v3}' was not found in HttpService secret store!`))
	end)
	return v4
end

local function getCacheValue(p: string)
	if not hashMap then
		return nil
	end

	local v3, v4 = pcallWithRetry(`HashMap:GetAsync({p})`, function()
		return hashMap:GetAsync(p)
	end)

	if v3 then
		return v4
	end

	return nil
end

local function setCacheValue(p: string, p2, p3: number)
	if not hashMap then
		return false, false
	end

	for i = 1, 3 do
		local success, result = pcall(function()
			hashMap:SetAsync(p, p2, p3)
		end)

		if success then
			return true, false
		end

		if string.find(tostring(result), "TotalMemoryOverLimit") then
			return false, true
		end

		if i < 3 then
			task.wait((math.min(1.5, 2 ^ (i - 1) * 0.15)))
		end
	end

	return false, false
end

local function compactHash(value: string, _: number?)
	local v3 = EncodingService:ComputeStringHash(value, Enum.HashAlgorithm.Blake2b):gsub("[^%w]", "")

	if #v3 > 80 then
		v3 = v3:sub(1, 80)
	end

	if v3 == "" then
		local v4 = value:gsub("[^%w]", ""):sub(1, 40)
		return (`{#value}_{v4}`)
	end

	return v3
end

local function makeBaseCacheKey(p: string, p2: string)
	local v3 = "RELICS_API_CACHE|" .. compactHash((`{p}:{p2}`))

	if #v3 > 100 then
		return v3:sub(1, 100)
	end

	return v3
end

-- equivalent calls inferred from this helper; original call sites unknown
local function base64Encode(compressBuffer: buffer)
	return buffer.tostring(EncodingService:Base64Encode(compressBuffer))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function base64Decode(str: string)
	return EncodingService:Base64Decode(buffer.fromstring(str))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function encodeCachePayload(p)
	local jSONEncode = HttpService:JSONEncode(p)
	return base64Encode(EncodingService:CompressBuffer(buffer.fromstring(jSONEncode), Enum.CompressionAlgorithm.Zstd))
end

local function decodeCachePayload(p: string, p2: string)
	return pcallWithRetry(p, function()
		local v4 = base64Decode(p2) -- equivalent call inferred; original call site unknown
		local decompressBuffer = EncodingService:DecompressBuffer(v4, Enum.CompressionAlgorithm.Zstd)
		return HttpService:JSONDecode(buffer.tostring(decompressBuffer))
	end)
end

local v3 = {}

local function getMemo(p: string)
	local v4 = v3[p]

	if not v4 then
		v4 = {}
		v3[p] = v4
	end

	return v4
end

-- equivalent calls inferred from this helper; original call sites unknown
local function writeDataStorePayload(p: string, p2: string, p3: string)
	if dataStore then
		return (pcallWithRetry(`CacheStore:SetAsync({p})`, function()
			dataStore:UpdateAsync(p, function()
				return {
					v = p2,
					d = p3
				}
			end)
		end))
	end

	return false
end

local function fetchDataStorePayload(p: string)
	local v4 = v3[p]

	if not v4 then
		v4 = {}
		v3[p] = v4
	end

	local v5, v6 = pcallWithRetry(`CacheStore:GetAsync({p})`, function()
		return dataStore:GetAsync(p)
	end)
	v4.fetchingVersion = nil

	if not v5 or type(v6) ~= "table" or type(v6.v) ~= "string" or type(v6.d) ~= "string" then
		v4.failedAt = DateTime.now().UnixTimestamp
		return nil
	end

	local d = v6.d
	local v7, v8 = pcallWithRetry("decodeCachePayload(datastore)", function()
		local v10 = base64Decode(d) -- equivalent call inferred; original call site unknown
		local decompressBuffer = EncodingService:DecompressBuffer(v10, Enum.CompressionAlgorithm.Zstd)
		return HttpService:JSONDecode(buffer.tostring(decompressBuffer))
	end)

	if not v7 then
		v4.failedAt = DateTime.now().UnixTimestamp
		return nil
	end

	v4.version = v6.v
	v4.value = v8
	v4.failedAt = nil
	return v8
end

local function readDataStorePayload(p: string, fetchingVersion: string)
	if not dataStore then
		return nil
	end

	local v4 = v3[p]

	if not v4 then
		v4 = {}
		v3[p] = v4
	end

	if v4.version == fetchingVersion then
		return v4.value
	end

	if v4.value == nil then
		local unixTimestamp = DateTime.now().UnixTimestamp

		if v4.failedAt and unixTimestamp - v4.failedAt < 5 then
			return nil
		end

		return (fetchDataStorePayload(p))
	else
		if v4.fetchingVersion ~= fetchingVersion then
			v4.fetchingVersion = fetchingVersion
			task.delay(math.random() * 30, fetchDataStorePayload, p)
		end

		return v4.value
	end
end

local function computeReadShard()
	local jobId = game.JobId

	if jobId == "" then
		return math.random(0, 2147483646)
	end

	local v4 = 5381

	for i = 1, #jobId do
		v4 = (v4 * 33 + string.byte(jobId, i)) % 2147483647
	end

	return v4
end

local v4 = computeReadShard()
local v5 = 16

-- equivalent calls inferred from this helper; original call sites unknown
local function reduceShards()
	if v5 > 1 then
		v5 = math.max(1, v5 // 2)
		warn((`[RelicsXYZ.Backend] MemoryStore quota hit; reducing cache shards to {v5}.`))
	end
end

local function shardKey(p: string, p2: number)
	local formatted = `{p}|s{p2}`

	if #formatted > 128 then
		return formatted:sub(1, 128)
	end

	return formatted
end

local function readCache(p: string)
	local unixTimestamp = DateTime.now().UnixTimestamp
	local v6 = v3[p]

	if v6 and v6.value ~= nil and v6.nextProbe and unixTimestamp < v6.nextProbe then
		local v7 = v6.soft and unixTimestamp < v6.soft and "Fresh" or "Stale"
		return v6.value, v7
	end

	if not hashMap then
		return nil, "Miss"
	end

	local formatted = `{p}|s{v4 % v5}`

	if #formatted > 128 then
		formatted = formatted:sub(1, 128)
	end

	local v7

	if hashMap then
		local v8
		v8, v7 = pcallWithRetry(`HashMap:GetAsync({formatted})`, function()
			return hashMap:GetAsync(formatted)
		end)

		if not v8 then
			v7 = nil
		end
	end

	if type(v7) ~= "string" then
		return nil, "Miss"
	end

	local v8 = tonumber(v7:match("^[SD]|(%d+)|"))
	local soft

	if v8 then
		soft = v8 - v
	else
		soft = nil
	end

	local v10 = soft and soft - unixTimestamp > 0 and "Fresh" or "Stale"

	local function rememberProbe()
		local v11 = p
		local v12 = v3[v11]

		if not v12 then
			v12 = {}
			v3[v11] = v12
		end

		v12.soft = soft
		local nextProbe

		if v10 == "Fresh" and soft then
			nextProbe = soft
		else
			nextProbe = unixTimestamp + 10 * (0.5 + math.random())
		end

		v12.nextProbe = nextProbe
	end

	if v7:sub(1, 2) == "S|" then
		local match = v7:match("^S|%d+|(.*)$")

		if match == nil then
			return nil, "Miss"
		end

		local v11, v12 = pcallWithRetry("decodeCachePayload(single)", function()
			local v14 = base64Decode(match) -- equivalent call inferred; original call site unknown
			local decompressBuffer = EncodingService:DecompressBuffer(v14, Enum.CompressionAlgorithm.Zstd)
			return HttpService:JSONDecode(buffer.tostring(decompressBuffer))
		end)

		if not v11 then
			return nil, "Miss"
		end

		local v13 = v3[p]

		if not v13 then
			v13 = {}
			v3[p] = v13
		end

		v13.version = nil
		v13.value = v12
		local v14 = v3[p]

		if not v14 then
			v14 = {}
			v3[p] = v14
		end

		v14.soft = soft
		v14.nextProbe = v10 == "Fresh" and soft or unixTimestamp + 10 * (0.5 + math.random())
		return v12, v10
	else
		if v7:sub(1, 2) ~= "D|" then
			return nil, "Miss"
		end

		local match = v7:match("^D|%d+|(.+)$")

		if match == nil then
			return nil, "Miss"
		end

		local v11 = readDataStorePayload(p, match)

		if v11 == nil then
			return nil, "Miss"
		end

		local v12 = v3[p]

		if not v12 then
			v12 = {}
			v3[p] = v12
		end

		v12.soft = soft
		v12.nextProbe = v10 == "Fresh" and soft or unixTimestamp + 10 * (0.5 + math.random())
		return v11, v10
	end
end

local function writeCache(p: string, p2)
	if not (hashMap and dataStore) then
		return
	end

	local now = DateTime.now()
	local v6 = encodeCachePayload(p2) -- equivalent call inferred; original call site unknown
	local v7 = now.UnixTimestamp + 900 + math.random(0, 30)
	local v8 = 4500 + math.random(0, 30)
	local v9 = v5
	local version = compactHash(v6)

	-- equivalent call inferred; original call site unknown
	if not writeDataStorePayload(p, version, v6) then
		return
	end

	local formatted = `D|{v7}|{version}`
	local v11 = v3[p]

	if not v11 then
		v11 = {}
		v3[p] = v11
	end

	v11.version = version
	v11.value = p2
	v11.soft = v7 - v
	v11.nextProbe = v7 - v
	v11.fetchingVersion = nil
	v11.failedAt = nil

	for i = 0, v9 - 1 do
		local formatted2 = `{p}|s{i}`

		if #formatted2 > 128 then
			formatted2 = formatted2:sub(1, 128)
		end

		local _, v13 = setCacheValue(formatted2, formatted, v8)

		if not v13 then
			continue
		end

		reduceShards() -- equivalent call inferred; original call site unknown
		break
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function tryAcquireRefreshLock(p: string)
	if not hashMap then
		return false
	end

	local formatted = `{p}|lock`
	local success, result = pcall(function()
		local v6 = formatted
		local v7

		if hashMap then
			local v8
			v8, v7 = pcallWithRetry(`HashMap:GetAsync({v6})`, function()
				return hashMap:GetAsync(v6)
			end)

			if not v8 then
				v7 = nil
			end
		end

		if v7 == nil then
			return hashMap:UpdateAsync(formatted, function(p2)
				if p2 == v2 or p2 == nil then
					return v2
				end

				return nil
			end, 30) == v2
		end

		return v7 == v2
	end)
	return success and result
end

local function fetchFromWeb(secret: string, p: string)
	local v6 = {
		Url = "https://api.relics.xyz/v2/" .. p,
		Method = "GET",
		Headers = {
			["Content-Type"] = "application/json",
			Authorization = secret
		},
		Compress = Enum.HttpCompression.None
	}
	local success, result = pcall(function()
		return HttpService:RequestAsync(v6)
	end)

	if not (success and (result.Success and result.Body)) then
		return false, nil, result
	end

	local success2, result2 = pcall(function()
		return HttpService:JSONDecode(result.Body)
	end)

	if success2 then
		return true, result2, result
	end

	return false, nil, result
end

-- equivalent calls inferred from this helper; original call sites unknown
local function publishInvalidation(p: string, p2: string)
	if not MessagingService then
		return
	end

	pcall(function()
		MessagingService:PublishAsync("RELICS_API_CACHE", {
			p = p,
			k = p2
		})
	end)
end

local function handleInvalidation(p)
	local data = p.Data

	if type(data) ~= "table" or type(data.p) ~= "string" then
		return
	end

	local p2 = data.p
	local v6 = data.k == "RELICS_PUBLIC_KEY" and "RELICS_PUBLIC_KEY" or "RELICS_API_KEY"
	local v7 = "RELICS_API_CACHE|" .. compactHash((`{v6}:{p2}`))

	if #v7 > 100 then
		v7 = v7:sub(1, 100)
	end

	local v8 = v3[v7]

	if v8 then
		v8.soft = nil
		v8.nextProbe = nil
	end

	task.delay(math.random() * 3, function()
		local secret = getSecret(v6)

		if secret == nil then
			return
		end

		local _, v9 = readCache(v7)

		if v9 == "Fresh" then
			return
		end

		-- equivalent call inferred; original call site unknown
		if not tryAcquireRefreshLock(v7) then
			return
		end

		local v11, v12 = fetchFromWeb(secret, p2)

		if v11 then
			writeCache(v7, v12)
		end
	end)
end

local v6 = {}

function Backend.GET(value: string, value2: string?, flag: boolean?)
	local v7 = value2 or "RELICS_API_KEY"
	local formatted = `{v7}|{value}`
	local v8 = not (flag or ServerStorage:HasTag("__RELICSXYZ_NO_CACHE_DANGEROUS_INTERNAL_ONLY_DO_NOT_USE_OR_YOU_WILL_BE_SMITED__"))
	local v9 = v8 and v6[formatted]

	if v9 then
		return v9
	end

	local v10 = Promise.new(function(callback, callback2)
		local secret = getSecret(v7)

		if secret == nil then
			callback2((`Secret {v7} not found.`))
			return
		end

		local isRCC

		if hashMap == nil then
			isRCC = false
		else
			isRCC = RunContext.IsRCC or false
		end

		if ServerStorage:HasTag("__RELICSXYZ_NO_CACHE_DANGEROUS_INTERNAL_ONLY_DO_NOT_USE_OR_YOU_WILL_BE_SMITED__") or flag then
			local v11 = value:find("%?") and "&refresh=true" or "?refresh=true"

			if not value:find(v11) then
				value ..= v11
			end

			local _ = RunContext.IsStudio
			isRCC = false
		end

		if isRCC then
			local v11 = "RELICS_API_CACHE|" .. compactHash((`{v7}:{value}`))

			if #v11 > 100 then
				v11 = v11:sub(1, 100)
			end

			local success, result, v12 = pcall(readCache, v11)

			if not success then
				result = nil
				v12 = "Miss"
			end

			if result == nil or type(result) ~= "table" then
				-- equivalent call inferred; original call site unknown
				if tryAcquireRefreshLock(v11) then
					local v13, v14, v15 = fetchFromWeb(secret, value)

					if not v13 then
						callback2(v15)
						return
					end

					task.spawn(writeCache, v11, v14)
					callback(v14)
					return
				else
					for _ = 1, 10 do
						task.wait(0.5)
						local v13 = readCache(v11)

						if not (v13 ~= nil and type(v13) == "table") then
							continue
						end

						callback(v13)
						return
					end
				end
			else
				callback(result)

				if v12 ~= "Stale" then
					return
				end

				local v13 = v3[v11]

				if not v13 then
					v13 = {}
					v3[v11] = v13
				end

				local unixTimestamp = DateTime.now().UnixTimestamp

				if unixTimestamp < (v13.nextRefreshAttempt or 0) then
					return
				end

				v13.nextRefreshAttempt = unixTimestamp + 10
				task.spawn(function()
					if math.random() > 0.05 and not RunContext.IsStudio then
						return
					end

					task.wait(math.random() * 2)
					local _, v14 = readCache(v11)

					if v14 == "Fresh" then
						return
					end

					-- equivalent call inferred; original call site unknown
					if not tryAcquireRefreshLock(v11) then
						return
					end

					local v16, v17 = fetchFromWeb(secret, value)

					if v16 then
						writeCache(v11, v17)
					end
				end)
				return
			end
		end

		local v11, v12, v13 = fetchFromWeb(secret, value)

		if v11 then
			callback(v12)
		else
			callback2(v13)
		end
	end):catch(function(p)
		warn("Request failed for", value, ":", p)
	end)

	if v8 then
		v6[formatted] = v10
		v10:finally(function()
			if v6[formatted] == v10 then
				v6[formatted] = nil
			end
		end)
	end

	return v10
end

function Backend.Invalidate(p: string, value: string?)
	publishInvalidation(p, value or "RELICS_API_KEY") -- equivalent call inferred; original call site unknown
end

function Backend.IsRelicsDev(instance)
	if instance:HasTag("RelicsDev") then
		return true
	end

	local v7, v8 = pcallWithRetry("Backend.IsRelicsDev", function()
		if instance:IsInGroupAsync(33215936) and instance:GetRankInGroupAsync(33215936) >= 254 then
			instance:AddTag("RelicsDev")
			return true
		else
			return false
		end
	end)
	return v7 and v8 or false
end

function Backend.IsDemo()
	return ReplicatedStorage:HasTag("__RELICSXYZ_DEMO_PLACE_INTERNAL_ONLY__")
end

if MessagingService and RunContext.IsRCC then
	task.spawn(function()
		pcallWithRetry("MessagingService:SubscribeAsync", function()
			MessagingService:SubscribeAsync("RELICS_API_CACHE", handleInvalidation)
		end)
	end)
end

Backend.MockFreemium = event

if RunContext.IsServer or RunContext.IsEdit then
	event:Server():On(function(instance, rELICSxyz_MockFreemium)
		if Backend.IsRelicsDev(instance) then
			instance:SetAttribute("RELICSxyz_MockFreemium", rELICSxyz_MockFreemium)
		end
	end)
end

return Backend