local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local LocalizationService = game:GetService("LocalizationService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Observers = require(ReplicatedStorage.Packages.Observers)
local dataStore

if RunService:IsServer() then
	dataStore = DataStoreService:GetDataStore("PlayerEmojiV1")
else
	dataStore = nil
end

local v = {}

local function waitForBudget(p)
	local count = 0

	while count < 60 do
		local success, requestBudgetForRequestType = pcall(
			DataStoreService.GetRequestBudgetForRequestType,
			DataStoreService,
			p
		)

		if not success or requestBudgetForRequestType > 30 then
			break
		end

		task.wait(1)
		count += 1
	end
end

local function codeToEmoji(value: string?)
	if typeof(value) ~= "string" or #value ~= 2 then
		return nil
	end

	local v2, v3 = string.byte(string.upper(value), 1, 2)

	if v2 < 65 or v2 > 90 or v3 < 65 or v3 > 90 then
		return nil
	end

	return utf8.char(v2 - 65 + 127462, 127462 + (v3 - 65))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function fetchCountryCode(p)
	local success, countryRegionForPlayerAsync = pcall(
		LocalizationService.GetCountryRegionForPlayerAsync,
		LocalizationService,
		p
	)

	if success and typeof(countryRegionForPlayerAsync) == "string" and tonumber(countryRegionForPlayerAsync) == nil then
		return countryRegionForPlayerAsync, true
	end

	return "US", false
end

local function resolvePlayer(p)
	local countryCode, v3 = fetchCountryCode(p) -- equivalent call inferred; original call site unknown
	local v4 = codeToEmoji(countryCode) or "🌐"
	v[p.UserId] = v4
	local v5 = dataStore

	if v3 and v5 then
		waitForBudget(Enum.DataStoreRequestType.SetIncrementAsync)
		local success, result = pcall(v5.SetAsync, v5, tostring(p.UserId), v4)

		if not success then
			warn(string.format("[PlayerCountryService] 保存 emoji 失败（%d）: %s", p.UserId, (tostring(result))))
		end
	end
end

local function getCountryEmoji(p: number)
	assert(RunService:IsServer(), "getCountryEmoji 只能由服务器调用")
	local v2 = v[p]

	if v2 then
		return v2
	end

	if Players:GetPlayerByUserId(p) then
		return "🌐"
	end

	local v3 = dataStore

	if not v3 then
		return "🌐"
	end

	waitForBudget(Enum.DataStoreRequestType.GetAsync)
	local v4 = v[p]

	if v4 then
		return v4
	end

	local success, async = pcall(v3.GetAsync, v3, (tostring(p)))

	if success and typeof(async) == "string" and async ~= "" then
		v[p] = async
		return async
	end

	if success then
		v[p] = "🌐"
	else
		warn(string.format("[PlayerCountryService] 读取 emoji 失败（%d）: %s", p, (tostring(async))))
	end

	return "🌐"
end

if RunService:IsServer() then
	Observers.observePlayer(function(p)
		resolvePlayer(p)
	end)
end

return {
	server = {
		getCountryEmoji = getCountryEmoji
	}
}