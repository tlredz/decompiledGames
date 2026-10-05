local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")
local MessagingService = game:GetService("MessagingService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LoggerManager = require(ReplicatedStorage._FRAMEWORK.Libraries.LoggerManager)
local MessagingServiceUtils = require(ReplicatedStorage.Utilities.MessagingServiceUtils)
local Signal = require(ReplicatedStorage.Utilities.Signal)
local logger = LoggerManager.createLogger(script.Name, {
	feature = script:GetFullName()
})
local BannedLeaderboardUsers = {}
local v = {}
local flag = false
local flag2 = false
local flag3 = false
local v2 = false
local v3 = Signal.new()

local function getStore()
	return DataStoreService:GetDataStore("LeaderboardBans")
end

-- equivalent calls inferred from this helper; original call sites unknown
local function applyReplace(items)
	table.clear(v)

	for _, item in items do
		v[item] = true
	end

	v3:Fire()
end

local function checkBanList(items)
	if items == nil then
		return true, {}, ""
	end

	if type(items) ~= "table" then
		return false, nil, string.format("Unexpected BannedUsers value type: %s", (type(items)))
	end

	local v4 = {}
	local result = {}

	for k, item in pairs(items) do
		if item == true then
			item = k
		end

		local v5 = tonumber(item)

		if v5 == nil or v4[v5] then
			continue
		end

		v4[v5] = true
		table.insert(result, v5)
	end

	return true, result, ""
end

local function checkUserId(p: number)
	if p == nil or p ~= p or math.abs(p) == 1e999 then
		return false, nil, "Invalid leaderboard UserId"
	end

	return true, p, ""
end

local function checkSaveReady(p: number)
	local v4, v5

	if p == nil or p ~= p or math.abs(p) == 1e999 then
		v4 = false
		p = nil
		v5 = "Invalid leaderboard UserId"
	else
		v4 = true
		v5 = ""
	end

	if not v4 then
		return false, nil, v5
	end

	if not RunService:IsServer() then
		return false, nil, "Leaderboard bans can only be changed on the server"
	end

	if flag then
		if flag3 then
			return false, nil, "Another leaderboard ban change is already in progress"
		end

		return true, p, ""
	else
		if flag2 then
			return
				false,
				nil,
				"The leaderboard ban list is still loading. Try again in a few seconds; no ban data was changed."
		end

		task.spawn(BannedLeaderboardUsers.load)
		return
			false,
			nil,
			"The leaderboard ban list could not be loaded. A protected background retry has started; try again shortly. Existing bans were not overwritten and no changes were saved."
	end
end

local function retryStore(p: string, p2: number, fn)
	local result = nil

	for i = 1, p2 do
		local success
		success, result = pcall(fn)

		if success then
			return true, result
		end

		logger:warn(string.format("Leaderboard ban %s failed (%d/%d): %s", p, i, p2, (tostring(result))))

		if i < p2 then
			task.wait((math.min(2 ^ (i - 1) * 0.5, 4)))
		end
	end

	return false, result
end

local function buildStoredList(p, p2: number, flag4: boolean)
	local v4, v5, v6 = checkBanList(p)

	if not v4 then
		error(v6)
		return
	end

	local v7 = {}

	for _, v8 in v5 do
		v7[v8] = true
	end

	if flag4 then
		v7[p2] = true
	else
		v7[p2] = nil
	end

	local result = {}

	for k in v7 do
		table.insert(result, (tostring(k)))
	end

	table.sort(result)
	return result
end

local function applySave(p: number, flag4: boolean)
	flag3 = true
	local v4, v5 = retryStore("save", 3, function()
		return DataStoreService:GetDataStore("LeaderboardBans"):UpdateAsync("BannedUsers", function(p2)
			return buildStoredList(p2, p, flag4)
		end)
	end)
	flag3 = false

	if not v4 then
		return false, string.format("Leaderboard ban data could not be saved: %s", (tostring(v5)))
	end

	local v6, v7, v8 = checkBanList(v5)

	if not v6 then
		return false, string.format("Leaderboard ban data could not be saved: %s", v8)
	end

	applyReplace(v7) -- equivalent call inferred; original call site unknown
	pcall(function()
		MessagingService:PublishAsync("LeaderboardBanSync", HttpService:JSONEncode({
			action = flag4 and "ban" or "unban",
			userId = tostring(p)
		}))
	end)
	return true, ""
end

function BannedLeaderboardUsers.isBanned(p: number)
	return v[p] == true
end

function BannedLeaderboardUsers.isLoaded()
	return flag
end

function BannedLeaderboardUsers.isLoading()
	return flag2
end

function BannedLeaderboardUsers.set(p: number, flag4: boolean)
	if flag4 then
		v[p] = true
	else
		v[p] = nil
	end

	v3:Fire()
end

function BannedLeaderboardUsers.save(p: number, flag4: boolean)
	local flag5, v4

	if p == nil or p ~= p or math.abs(p) == 1e999 then
		flag5 = false
		p = nil
		v4 = "Invalid leaderboard UserId"
	else
		flag5 = true
		v4 = ""
	end

	local flag6

	if flag5 then
		if RunService:IsServer() then
			if flag then
				if flag3 then
					flag6 = false
					p = nil
					v4 = "Another leaderboard ban change is already in progress"
				else
					flag6 = true
					v4 = ""
				end
			elseif flag2 then
				flag6 = false
				p = nil
				v4 = "The leaderboard ban list is still loading. Try again in a few seconds; no ban data was changed."
			else
				task.spawn(BannedLeaderboardUsers.load)
				flag6 = false
				p = nil
				v4 = "The leaderboard ban list could not be loaded. A protected background retry has started; try again shortly. Existing bans were not overwritten and no changes were saved."
			end
		else
			flag6 = false
			p = nil
			v4 = "Leaderboard bans can only be changed on the server"
		end
	else
		flag6 = false
		p = nil
	end

	if flag6 then
		return applySave(p, flag4)
	end

	return false, v4
end

function BannedLeaderboardUsers.load()
	if not RunService:IsServer() then
		return false
	end

	if flag then
		return true
	end

	if flag2 then
		while flag2 do
			task.wait(0.05)
		end

		return flag
	else
		flag2 = true
		local v4, v5 = retryStore("load", 5, function()
			return DataStoreService:GetDataStore("LeaderboardBans"):GetAsync("BannedUsers")
		end)

		if v4 then
			local v6, v7, v8 = checkBanList(v5)

			if v6 then
				applyReplace(v7) -- equivalent call inferred; original call site unknown
				flag = true
			else
				logger:warn(string.format("Leaderboard bans remain unreadable: %s", v8))
			end
		else
			logger:warn(string.format("Leaderboard bans remain unreadable: %s", (tostring(v5))))
		end

		flag2 = false
		return flag
	end
end

function BannedLeaderboardUsers.startSync()
	if v2 or not RunService:IsServer() then
		return
	end

	v2 = true
	MessagingServiceUtils.SubscribeWithTimeoutAsync("LeaderboardBanSync", function(p)
		local success, result = pcall(function()
			return HttpService:JSONDecode(p.Data)
		end)

		if success and flag and type(result) == "table" then
			local userId = tonumber(result.userId)
			local flag4

			if userId == nil or userId ~= userId or math.abs(userId) == 1e999 then
				flag4 = false
				userId = nil
			else
				flag4 = true
			end

			if flag4 then
				if result.action == "ban" then
					BannedLeaderboardUsers.set(userId, true)
				elseif result.action == "unban" then
					BannedLeaderboardUsers.set(userId, false)
				end
			end
		end
	end)
end

function BannedLeaderboardUsers.onChanged(callback)
	return v3:Connect(callback)
end

return BannedLeaderboardUsers