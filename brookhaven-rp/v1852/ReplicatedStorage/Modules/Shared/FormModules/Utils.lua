local DataStoreService = game:GetService("DataStoreService")
local parent = script.Parent
local Config = require(parent.Config)
local v = {
	["\\n"] = "\n",
	["&nbsp;"] = "",
	["&amp;"] = "&",
	["&lt;"] = "<",
	["&gt;"] = ">",
	["&quot;"] = "\"",
	["&apos;"] = "'",
	["&#(%d+);"] = function(p)
		return (string.char(p))
	end
}

local function sanitizeEncodedHtml(value, p)
	for k, v2 in pairs(v) do
		if p then
			value = string.gsub(value, p .. k, v2)
		end

		value = string.gsub(value, k, v2)
	end

	local v2 = string.gsub(value, "\\u%x%x%x%x", function(value2)
		local v3 = string.sub(value2, 3)
		return utf8.char((tonumber(v3, 16)))
	end)
	local v3 = string.gsub(v2, "\160", "")
	return (string.gsub(v3, "\194", " "))
end

local function isValidFormId(value)
	if value == nil or typeof(value) ~= "string" then
		return false
	end

	local v2 = string.len(value)
	return v2 ~= 0 and not (v2 > 128)
end

local function isRenderedContentEqual(value, value2)
	return (string.gsub(value, "</?[biu]>", "") or "") == (value2 or "")
end

local v2 = {}

local function throttleRequest(p, p2)
	local v3 = v2[p]
	local v4 = time()

	if v3 then
		local v5 = v3[p2]
		local rateLimit = Config.RateLimits[p2]

		if v5 and v4 - v5 < rateLimit then
			return true
		end
	else
		v3 = {}
		v2[p] = v3
	end

	v3[p2] = v4
	return false
end

local dataStore = nil

local function getDataStore()
	assert(Config.AllowMultipleResponses == false, "AllowMultipleResponses must be false")

	if dataStore == nil then
		dataStore = DataStoreService:GetDataStore(Config.DataStoreName)
	end

	return dataStore
end

local v3 = {}

local function hasPlayerResponded(p, p2)
	assert(Config.AllowMultipleResponses == false, "AllowMultipleResponses must be false")
	local userId = p.UserId
	local async = v3[userId]

	if async ~= nil then
		return async ~= nil and async[p2] ~= nil
	end

	assert(Config.AllowMultipleResponses == false, "AllowMultipleResponses must be false")

	if dataStore == nil then
		dataStore = DataStoreService:GetDataStore(Config.DataStoreName)
	end

	async = dataStore:GetAsync(userId)
	v3[userId] = async
	return async ~= nil and async[p2] ~= nil
end

local function setPlayerFormResponse(p, p2, p3)
	assert(Config.AllowMultipleResponses == false, "AllowMultipleResponses must be false")
	local userId = p.UserId
	local v4 = v3[userId]

	if v4 == nil then
		v4 = {}
		v3[userId] = v4
	end

	v4[p2] = p3
end

local function savePlayerFormReponses(p)
	assert(Config.AllowMultipleResponses == false, "AllowMultipleResponses must be false")
	local userId = p.UserId
	local v4 = v3[userId]

	if v4 ~= nil then
		assert(Config.AllowMultipleResponses == false, "AllowMultipleResponses must be false")

		if dataStore == nil then
			dataStore = DataStoreService:GetDataStore(Config.DataStoreName)
		end

		dataStore:SetAsync(userId, v4, { userId })
	end
end

return {
	SanitizeEncodedHtml = sanitizeEncodedHtml,
	IsValidFormId = isValidFormId,
	IsRenderedContentEqual = isRenderedContentEqual,
	ThrottleRequest = throttleRequest,
	HasPlayerResponded = hasPlayerResponded,
	SetPlayerFormResponse = setPlayerFormResponse,
	SavePlayerFormResponses = savePlayerFormReponses
}