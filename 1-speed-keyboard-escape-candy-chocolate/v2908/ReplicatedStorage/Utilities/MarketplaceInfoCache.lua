local AvatarEditorService = game:GetService("AvatarEditorService")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LoggerManager = require(ReplicatedStorage._FRAMEWORK.Libraries.LoggerManager)
local MarketplaceInfoCache = {}
local logger = LoggerManager.createLogger("MarketplaceInfoCache", {
	feature = script:GetFullName()
})
local v = {}
local v2 = {}
local v3 = {}
local v4 = 4

-- equivalent calls inferred from this helper; original call sites unknown
local function cacheKey(p: number, p2)
	return tostring(p2.Value) .. ":" .. tostring(p)
end

local function resolveCached(p: string)
	local v5 = v[p]

	if v5 == nil or v5 == false then
		return nil
	end

	return v5
end

local function notifyWaiters(key: string)
	local v5 = v2[key]
	v2[key] = nil
	local v6 = v[key]

	if v6 == nil or v6 == false then
		v6 = nil
	end

	for _, callback in ipairs(v5) do
		task.spawn(callback, v6)
	end
end

local function normalizeInfo(state)
	if type(state) == "table" and state.PriceInRobux == nil and state.Price ~= nil then
		state.PriceInRobux = state.Price
	end

	return state
end

local function fetchProductInfo(id: number, infoType)
	if infoType == Enum.InfoType.Bundle then
		local success, result = pcall(function()
			return AvatarEditorService:GetItemDetailsAsync(id, Enum.AvatarItemType.Bundle)
		end)

		if not (success and result) then
			return success, result
		end

		if type(result) == "table" and result.PriceInRobux == nil and result.Price ~= nil then
			result.PriceInRobux = result.Price
		end

		return true, result
	else
		local success, productInfoAsync = pcall(
			MarketplaceService.GetProductInfoAsync,
			MarketplaceService,
			id,
			infoType
		)

		if not (success and productInfoAsync) then
			return success, productInfoAsync
		end

		if type(productInfoAsync) == "table" and productInfoAsync.PriceInRobux == nil and productInfoAsync.Price ~= nil then
			productInfoAsync.PriceInRobux = productInfoAsync.Price
		end

		return true, productInfoAsync
	end
end

local function fetchJob(data)
	local key = data.key
	local v5 = v[key]

	if v5 == nil or v5 == false then
		v5 = nil
	end

	if v5 then
		notifyWaiters(key)
		return
	end

	local v6, v7 = fetchProductInfo(data.id, data.infoType)

	if v6 and v7 then
		v[key] = v7
	else
		logger:error(string.format(
			"GetProductInfo failed for marketplace id %s (%s): %s",
			tostring(data.id),
			tostring(data.infoType),
			(tostring(v7))
		))

		if data.attempt < 3 then
			table.insert(v3, {
				id = data.id,
				infoType = data.infoType,
				key = key,
				attempt = data.attempt + 1
			})
			return
		end

		v[key] = false
	end

	notifyWaiters(key)
end

local function pumpBatch()
	for _ = 1, math.min(16, #v3) do
		local v5 = table.remove(v3, 1)
		task.spawn(fetchJob, v5)
	end
end

RunService.Heartbeat:Connect(function(dt)
	if #v3 > 0 then
		v4 -= dt

		if v4 <= 0 then
			pumpBatch()
			v4 = 4
		end
	elseif v4 > 1 then
		v4 = math.max(1, v4 - dt)
	end
end)

local function bumpQueueToFront(p: string)
	for i, v5 in ipairs(v3) do
		if v5.key ~= p then
			continue
		end

		table.remove(v3, i)
		table.insert(v3, 1, v5)
		break
	end
end

local function enqueue(id: number, infoType, callback, flag: boolean?)
	local v5 = cacheKey(id, infoType) -- equivalent call inferred; original call site unknown

	if v[v5] == nil then
		if v2[v5] then
			table.insert(v2[v5], callback)

			if flag then
				bumpQueueToFront(v5)
			end
		else
			v2[v5] = { callback }
			local v6 = {
				id = id,
				infoType = infoType,
				key = v5,
				attempt = 1
			}

			if flag then
				table.insert(v3, 1, v6)
			else
				table.insert(v3, v6)
			end
		end
	else
		local v6 = v[v5]

		if v6 == nil or v6 == false then
			v6 = nil
		end

		task.spawn(callback, v6)
	end
end

function MarketplaceInfoCache.Request(p: number, p2, callback)
	enqueue(p, p2, callback)
end

function MarketplaceInfoCache.Prefetch(id: number, infoType, flag: boolean?)
	enqueue(id, infoType, function() end, flag)
end

function MarketplaceInfoCache.GetAsync(p: number, p2)
	local v5 = cacheKey(p, p2) -- equivalent call inferred; original call site unknown
	local v6 = v[v5]

	if v6 == nil or v6 == false then
		v6 = nil
	end

	if v[v5] ~= nil then
		return v6
	end

	local bindableEvent = Instance.new("BindableEvent")
	enqueue(p, p2, function(p3)
		v6 = p3
		bindableEvent:Fire()
	end)
	bindableEvent.Event:Wait()
	bindableEvent:Destroy()
	return v6
end

function MarketplaceInfoCache.GetCached(p: number, p2)
	local v5 = cacheKey(p, p2) -- equivalent call inferred; original call site unknown
	local v6 = v[v5]

	if v6 == nil or v6 == false then
		return nil
	end

	return v6
end

function MarketplaceInfoCache.Clear()
	table.clear(v)
end

return MarketplaceInfoCache