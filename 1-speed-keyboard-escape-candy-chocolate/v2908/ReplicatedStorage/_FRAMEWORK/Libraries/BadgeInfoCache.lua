local BadgeService = game:GetService("BadgeService")
local ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LoggerManager = require(ReplicatedStorage._FRAMEWORK.Libraries.LoggerManager)
local logger = LoggerManager.createLogger(script.Name, {
	feature = script:GetFullName()
})
local BadgeInfoCache = {}
local v = {}
local v2 = {}
local v3 = {}
local v4 = 4

local function cacheKey(p: number)
	return (tostring(p))
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

local function preloadIcon(iconImageId: number)
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Image = "rbxassetid://" .. iconImageId
	pcall(ContentProvider.PreloadAsync, ContentProvider, { imageLabel })
	imageLabel:Destroy()
end

local function fetchBadgeInfo(p: number)
	local success, badgeInfoAsync = pcall(BadgeService.GetBadgeInfoAsync, BadgeService, p)

	if success and badgeInfoAsync then
		return true, badgeInfoAsync
	end

	return success, badgeInfoAsync
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

	local badgeId = data.badgeId
	local success, badgeInfoAsync = pcall(BadgeService.GetBadgeInfoAsync, BadgeService, badgeId)

	if (success and badgeInfoAsync or success) and badgeInfoAsync then
		if badgeInfoAsync.IconImageId ~= 0 then
			preloadIcon(badgeInfoAsync.IconImageId)
		end

		v[key] = badgeInfoAsync
	else
		if data.attempt < 3 then
			table.insert(v3, {
				badgeId = data.badgeId,
				key = key,
				attempt = data.attempt + 1
			})
			return
		end

		v[key] = false
		logger:warn(string.format("GetBadgeInfo failed for %s → %s", tostring(data.badgeId), (tostring(badgeInfoAsync))))
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

local function enqueue(badgeId: number, callback, flag: boolean?)
	local v5 = tostring(badgeId)

	if v[v5] == nil then
		if v2[v5] then
			table.insert(v2[v5], callback)

			if flag then
				bumpQueueToFront(v5)
			end
		else
			v2[v5] = { callback }
			local v6 = {
				badgeId = badgeId,
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

function BadgeInfoCache.Request(p: number, callback)
	enqueue(p, callback)
end

function BadgeInfoCache.Prefetch(badgeId: number, flag: boolean?)
	enqueue(badgeId, function() end, flag)
end

function BadgeInfoCache.GetAsync(p: number)
	local v5 = tostring(p)
	local v6 = v[v5]

	if v6 == nil or v6 == false then
		v6 = nil
	end

	if v[v5] ~= nil then
		return v6
	end

	local bindableEvent = Instance.new("BindableEvent")
	enqueue(p, function(p2)
		v6 = p2
		bindableEvent:Fire()
	end)
	bindableEvent.Event:Wait()
	bindableEvent:Destroy()
	return v6
end

function BadgeInfoCache.GetCached(p: number)
	local v6 = v[tostring(p)]

	if v6 == nil or v6 == false then
		return nil
	end

	return v6
end

function BadgeInfoCache.Clear()
	table.clear(v)
end

return BadgeInfoCache