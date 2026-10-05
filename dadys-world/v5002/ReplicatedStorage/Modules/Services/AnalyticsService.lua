local AnalyticsService = game:GetService("AnalyticsService")
local BetterAnalyticsService = require(script.Parent.BetterAnalyticsService)
local AnalyticsService2 = {}
local v = {
	EVENTS_PER_MINUTE = 50,
	CLEANUP_INTERVAL = 60,
	PROCESS_QUEUE_INTERVAL = 1,
	MAX_QUEUE_SIZE = 1000,
	EVENTS = {},
	GLOBAL_EVENTS = {},
	EVENT_QUEUES = {}
}

local function createEventQueue(userId)
	if not v.EVENT_QUEUES[userId] then
		v.EVENT_QUEUES[userId] = {
			queue = {},
			processing = false
		}
	end

	return v.EVENT_QUEUES[userId]
end

local function isRateLimited(p)
	local userId = p.UserId

	if not v.EVENTS[userId] then
		v.EVENTS[userId] = {}
	end

	local v2 = os.time() - 60
	local count = 0

	for _, v3 in ipairs(v.EVENTS[userId]) do
		if v2 < v3 then
			count += 1
		end
	end

	local count2 = 0

	for _, v3 in ipairs(v.GLOBAL_EVENTS) do
		if v2 < v3 then
			count2 += 1
		end
	end

	return v.EVENTS_PER_MINUTE <= count or count2 >= 120
end

local function processEventQueue(k)
	local v2 = v.EVENT_QUEUES[k]

	if not v2 or v2.processing or #v2.queue == 0 then
		return
	end

	v2.processing = true
	local v3 = table.remove(v2.queue, 1)

	if v3 and not isRateLimited(v3.player) then
		if not v.EVENTS[k] then
			v.EVENTS[k] = {}
		end

		table.insert(v.EVENTS[k], os.time())
		table.insert(v.GLOBAL_EVENTS, os.time())
		task.spawn(v3.callback)
	elseif v3 then
		table.insert(v2.queue, v3)
	end

	v2.processing = false
end

local function processQueues()
	while true do
		for k, v2 in pairs(v.EVENT_QUEUES) do
			if #v2.queue > 0 then
				processEventQueue(k)
			end
		end

		task.wait(v.PROCESS_QUEUE_INTERVAL)
	end
end

task.spawn(processQueues)

local function cleanupOldEvents()
	while true do
		local v2 = os.time() - 60

		for k, list in pairs(v.EVENTS) do
			v.EVENTS[k] = table.create(0)

			for _, v3 in ipairs(list) do
				if v2 < v3 then
					table.insert(v.EVENTS[k], v3)
				end
			end

			if #v.EVENTS[k] == 0 then
				v.EVENTS[k] = nil
			end
		end

		v.GLOBAL_EVENTS = table.create(0)

		for _, v3 in ipairs(v.GLOBAL_EVENTS) do
			if v2 < v3 then
				table.insert(v.GLOBAL_EVENTS, v3)
			end
		end

		task.wait(v.CLEANUP_INTERVAL)
	end
end

task.spawn(cleanupOldEvents)

local function trackEvent(player, callback)
	local userId = player.UserId
	local eventQueue = createEventQueue(userId)

	if isRateLimited(player) then
		if #eventQueue.queue < v.MAX_QUEUE_SIZE then
			table.insert(eventQueue.queue, {
				player = player,
				callback = callback,
				timestamp = os.time()
			})

			if #eventQueue.queue == v.MAX_QUEUE_SIZE then
				warn(string.format("[Analytics] Queue full for player %s, new events will be dropped", player.Name))
			end
		end
	else
		if not v.EVENTS[userId] then
			v.EVENTS[userId] = {}
		end

		table.insert(v.EVENTS[userId], os.time())
		table.insert(v.GLOBAL_EVENTS, os.time())
		callback()
	end
end

local function getFloorNumber()
	local success, result = pcall(function()
		return workspace:FindFirstChild("Info") and workspace.Info:FindFirstChild("FloorNumber") and workspace.Info.FloorNumber.Value or 0
	end)
	return success and result or 0
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getPlayerBalance(instance)
	local success, result = pcall(function()
		return instance:GetAttribute("CoinBalance") or 0
	end)
	return success and result or 0
end

local function convertToCustomFields(items)
	local result = {
		CustomField01 = "",
		CustomField02 = "",
		CustomField03 = ""
	}

	if not items then
		return result
	end

	local v2 = {}

	for k, item in pairs(items) do
		table.insert(v2, {
			key = k,
			value = tostring(item or "")
		})
	end

	table.sort(v2, function(a, b)
		return a.key < b.key
	end)

	for i, v3 in ipairs(v2) do
		if i == 1 then
			result.CustomField01 = v3.value
		elseif i == 2 then
			result.CustomField02 = v3.value
		elseif i == 3 then
			result.CustomField03 = v3.value
		else
			warn("[Analytics] Too many fields provided, maximum is 3")
			return result
		end
	end

	return result
end

-- equivalent calls inferred from this helper; original call sites unknown
local function safeFireAnalytics(player, fn)
	task.spawn(function()
		local success, result = pcall(function()
			trackEvent(player, fn)
		end)

		if not success then
			warn("[Analytics] Failed to fire event | Error: " .. tostring(result))
		end
	end)
end

function AnalyticsService2:TrackCustomEvent(player, value, p)
	if typeof(player) ~= "Instance" or not player:IsA("Player") then
		warn("[Analytics] Invalid player object provided")
		return
	end

	if not value then
		warn("[Analytics] No event name provided")
		return
	end

	local v2 = type(p) == "table" and p or {}
	local v3 = {}

	for k, v4 in pairs(v2) do
		v3[k] = BetterAnalyticsService.sanitizeCustomFieldValue(v4 or "")
	end

	local function fn()
		local v4 = convertToCustomFields(v3)
		AnalyticsService:LogCustomEvent(player, string.sub(value, 1, 50), 1, {
			[Enum.AnalyticsCustomFieldKeys.CustomField01.Name] = v4.CustomField01 or "",
			[Enum.AnalyticsCustomFieldKeys.CustomField02.Name] = v4.CustomField02 or "",
			[Enum.AnalyticsCustomFieldKeys.CustomField03.Name] = v4.CustomField03 or ""
		})
	end

	safeFireAnalytics(player, fn) -- equivalent call inferred; original call site unknown
end

function AnalyticsService2.TrackCoinEarned(_, player, value, value2, options)
	if typeof(player) ~= "Instance" or not player:IsA("Player") then
		warn("[Analytics] Invalid player object provided")
		return
	end

	if type(value) ~= "number" or value < 0 then
		warn("[Analytics] Invalid amount provided")
		return
	end

	local v2 = type(options) == "table" and (options or {}) or {}
	local source = tostring(value2 or "Unknown")

	local function fn()
		BetterAnalyticsService:LogEconomyEvent(
			player,
			value >= 0 and "Source" or "Sink",
			"Coins",
			math.abs(value),
			getPlayerBalance(player) + value,
			"Gameplay",
			nil,
			{
				source = source,
				customField01 = v2.customField01,
				customField02 = v2.customField02,
				customField03 = v2.customField03
			}
		)
	end

	safeFireAnalytics(player, fn) -- equivalent call inferred; original call site unknown
end

function AnalyticsService2:TrackItemUsed(player, p, value)
	if typeof(player) ~= "Instance" or not player:IsA("Player") then
		warn("[Analytics] Invalid player object provided")
	elseif p then
		self:TrackCustomEvent(player, "ItemUsed", {
			Item = tostring(p),
			Context = tostring(value or "Unknown")
		})
	else
		warn("[Analytics] No item name provided")
	end
end

function AnalyticsService2:TrackSurvivalPointsEarned(player, value, value2)
	if typeof(player) ~= "Instance" or not player:IsA("Player") then
		warn("[Analytics] Invalid player object provided")
	elseif type(value) == "number" and not (value < 0) then
		self:TrackCustomEvent(player, "SurvivalPointsEarned", {
			Source = tostring(value2 or "Unknown")
		})
	else
		warn("[Analytics] Invalid amount provided")
	end
end

function AnalyticsService2:TrackCharacterUsage(player, p)
	if typeof(player) ~= "Instance" or not player:IsA("Player") then
		warn("[Analytics] Invalid player object provided")
	elseif p then
		self:TrackCustomEvent(player, "CharacterUsed", {
			Character = tostring(p)
		})
	else
		warn("[Analytics] No character name provided")
	end
end

function AnalyticsService2.TrackFloorCompleted(_, player, value, value2, p)
	if typeof(player) ~= "Instance" or not player:IsA("Player") then
		warn("[Analytics] Invalid player object provided")
		return
	end

	if type(value) ~= "number" or value < 0 then
		warn("[Analytics] Invalid floor number")
		return
	end

	if type(value2) ~= "number" or value2 < 0 then
		warn("[Analytics] Invalid time spent")
		return
	end

	if value < 1 or value > 100 then
		warn("[Analytics] Floor number must be between 1 and 100")
		return
	end

	local function fn()
		BetterAnalyticsService:LogFunnelStepEvent(
			player,
			"FloorProgression",
			string.format("%d_floor_%d_%d", player.UserId, value, (math.floor(os.time() / 86400))),
			value,
			string.format("Floor%d", value),
			{
				[Enum.AnalyticsCustomFieldKeys.CustomField01.Name] = tostring((math.floor(value2))),
				[Enum.AnalyticsCustomFieldKeys.CustomField02.Name] = p and BetterAnalyticsService.sanitizeCustomFieldValue(p) or "None",
				[Enum.AnalyticsCustomFieldKeys.CustomField03.Name] = ""
			}
		)
	end

	safeFireAnalytics(player, fn) -- equivalent call inferred; original call site unknown
end

return AnalyticsService2