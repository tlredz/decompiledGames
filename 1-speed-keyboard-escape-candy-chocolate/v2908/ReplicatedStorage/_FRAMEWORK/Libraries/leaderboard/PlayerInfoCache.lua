local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LoggerManager = require(ReplicatedStorage._FRAMEWORK.Libraries.LoggerManager)
local logger = LoggerManager.createLogger(script.Name, {
	feature = script:GetFullName()
})
local headShot = Enum.ThumbnailType.HeadShot
local size150x150 = Enum.ThumbnailSize.Size150x150
local PlayerInfoCache = {
	Name = "Name",
	Thumbnail = "Thumbnail"
}
local v = {}
local v2 = {}
local v3 = {}
local v4 = 4

-- equivalent calls inferred from this helper; original call sites unknown
local function cacheKey(p: number, p2: string)
	return p2 .. ":" .. tostring(p)
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

local function fetchPlayerInfo(p: number, p2: string)
	if p2 == PlayerInfoCache.Name then
		return pcall(Players.GetNameFromUserIdAsync, Players, p)
	end

	return pcall(Players.GetUserThumbnailAsync, Players, p, headShot, size150x150)
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

	local userId = data.userId
	local success, nameFromUserIdAsync

	if data.kind == PlayerInfoCache.Name then
		success, nameFromUserIdAsync = pcall(Players.GetNameFromUserIdAsync, Players, userId)
	else
		success, nameFromUserIdAsync = pcall(Players.GetUserThumbnailAsync, Players, userId, headShot, size150x150)
	end

	if success and nameFromUserIdAsync then
		v[key] = nameFromUserIdAsync
	else
		if data.attempt < 3 then
			table.insert(v3, {
				userId = data.userId,
				kind = data.kind,
				key = key,
				attempt = data.attempt + 1
			})
			return
		end

		v[key] = false
		logger:warn(string.format(
			"fetch failed for %s %s → %s",
			data.kind,
			tostring(data.userId),
			(tostring(nameFromUserIdAsync))
		))
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

local function enqueue(userId: number, kind: string, callback, flag: boolean?)
	local v5 = cacheKey(userId, kind) -- equivalent call inferred; original call site unknown

	if v[v5] == nil then
		if v2[v5] then
			table.insert(v2[v5], callback)

			if flag then
				bumpQueueToFront(v5)
			end
		else
			v2[v5] = { callback }
			local v6 = {
				userId = userId,
				kind = kind,
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

function PlayerInfoCache.Request(p: number, p2: string, callback)
	enqueue(p, p2, callback)
end

function PlayerInfoCache.Prefetch(userId: number, kind: string, flag: boolean?)
	enqueue(userId, kind, function() end, flag)
end

function PlayerInfoCache.GetAsync(p: number, p2: string)
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

function PlayerInfoCache.GetCached(p: number, p2: string)
	local v5 = cacheKey(p, p2) -- equivalent call inferred; original call site unknown
	local v6 = v[v5]

	if v6 == nil or v6 == false then
		return nil
	end

	return v6
end

function PlayerInfoCache.Clear()
	table.clear(v)
end

return PlayerInfoCache