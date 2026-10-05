local Validation = require(script.Parent.Validation)
local Logger = require(script.Parent.Logger)
local HttpApi = require(script.Parent.HttpApi)
local Store = require(script.Parent.Store)
local Events = require(script.Parent.Events)
local HttpService = game:GetService("HttpService")
local State = {
	_availableCustomDimensions01 = {},
	_availableCustomDimensions02 = {},
	_availableCustomDimensions03 = {},
	_availableGamepasses = {},
	_enableEventSubmission = true,
	Initialized = false,
	ReportErrors = true,
	UseCustomUserId = false,
	AutomaticSendBusinessEvents = true,
	ConfigsHash = ""
}
local v = nil

local function getClientTsAdjusted(p)
	local playerDataFromCache = Store:GetPlayerDataFromCache(p)

	if not playerDataFromCache then
		return os.time()
	end

	local now = os.time()
	local v2 = now + playerDataFromCache.ClientServerTimeOffset

	if Validation:validateClientTs(v2) then
		return v2
	end

	return now
end

local function populateConfigurations(player)
	local playerDataFromCache = Store:GetPlayerDataFromCache(player.UserId)
	local sdkConfig = playerDataFromCache.SdkConfig

	if sdkConfig.configs then
		local configs = sdkConfig.configs

		for _, config in pairs(configs) do
			if not config then
				continue
			end

			local key = config.key or ""
			local start_ts = config.start_ts or 0
			local end_ts = config.end_ts or 1e999
			local playerDataFromCache2 = Store:GetPlayerDataFromCache(player.UserId)
			local now

			if playerDataFromCache2 then
				now = os.time()
				local v2 = now + playerDataFromCache2.ClientServerTimeOffset

				if Validation:validateClientTs(v2) then
					now = v2
				end
			else
				now = os.time()
			end

			if not (#key > 0 and config.value and start_ts < now and now < end_ts) then
				continue
			end

			playerDataFromCache.Configurations[key] = config.value
			Logger:d("configuration added: key=" .. config.key .. ", value=" .. config.value)
		end
	end

	Logger:i("Remote configs populated")
	playerDataFromCache.RemoteConfigsIsReady = true
	local gameAnalyticsRemoteConfigs = v

	if not gameAnalyticsRemoteConfigs then
		local ReplicatedStorage = game:GetService("ReplicatedStorage")
		gameAnalyticsRemoteConfigs = ReplicatedStorage:WaitForChild("GameAnalyticsRemoteConfigs")
	end

	v = gameAnalyticsRemoteConfigs
	v:FireClient(player, playerDataFromCache.Configurations)
end

function State:sessionIsStarted(p)
	local playerDataFromCache = Store:GetPlayerDataFromCache(p)

	if playerDataFromCache then
		return playerDataFromCache.SessionStart ~= 0
	end

	return false
end

function State:isEnabled(p)
	local playerDataFromCache = Store:GetPlayerDataFromCache(p)

	if not playerDataFromCache then
		return false
	end

	if playerDataFromCache.InitAuthorized then
		return true
	end

	return false
end

function State:validateAndFixCurrentDimensions(p)
	local playerDataFromCache = Store:GetPlayerDataFromCache(p)

	if not Validation:validateDimension(self._availableCustomDimensions01, playerDataFromCache.CurrentCustomDimension01) then
		Logger:d("Invalid dimension01 found in variable. Setting to nil. Invalid dimension: " .. playerDataFromCache.CurrentCustomDimension01)
	end

	if not Validation:validateDimension(self._availableCustomDimensions02, playerDataFromCache.CurrentCustomDimension02) then
		Logger:d("Invalid dimension02 found in variable. Setting to nil. Invalid dimension: " .. playerDataFromCache.CurrentCustomDimension02)
	end

	if not Validation:validateDimension(self._availableCustomDimensions03, playerDataFromCache.CurrentCustomDimension03) then
		Logger:d("Invalid dimension03 found in variable. Setting to nil. Invalid dimension: " .. playerDataFromCache.CurrentCustomDimension03)
	end
end

function State:setAvailableCustomDimensions01(availableCustomDimensions)
	if not Validation:validateCustomDimensions(availableCustomDimensions) then
		return
	end

	self._availableCustomDimensions01 = availableCustomDimensions
	Logger:i("Set available custom01 dimension values: (" .. table.concat(availableCustomDimensions, ", ") .. ")")
end

function State:setAvailableCustomDimensions02(availableCustomDimensions)
	if not Validation:validateCustomDimensions(availableCustomDimensions) then
		return
	end

	self._availableCustomDimensions02 = availableCustomDimensions
	Logger:i("Set available custom02 dimension values: (" .. table.concat(availableCustomDimensions, ", ") .. ")")
end

function State:setAvailableCustomDimensions03(availableCustomDimensions)
	if not Validation:validateCustomDimensions(availableCustomDimensions) then
		return
	end

	self._availableCustomDimensions03 = availableCustomDimensions
	Logger:i("Set available custom03 dimension values: (" .. table.concat(availableCustomDimensions, ", ") .. ")")
end

function State:setAvailableGamepasses(availableGamepasses)
	self._availableGamepasses = availableGamepasses
	Logger:i("Set available game passes: (" .. table.concat(availableGamepasses, ", ") .. ")")
end

function State:setEventSubmission(enableEventSubmission)
	self._enableEventSubmission = enableEventSubmission
end

function State:isEventSubmissionEnabled()
	return self._enableEventSubmission
end

function State.setCustomDimension01(_, p, currentCustomDimension)
	local playerDataFromCache = Store:GetPlayerDataFromCache(p)
	playerDataFromCache.CurrentCustomDimension01 = currentCustomDimension
end

function State.setCustomDimension02(_, p, currentCustomDimension)
	local playerDataFromCache = Store:GetPlayerDataFromCache(p)
	playerDataFromCache.CurrentCustomDimension02 = currentCustomDimension
end

function State.setCustomDimension03(_, p, currentCustomDimension)
	local playerDataFromCache = Store:GetPlayerDataFromCache(p)
	playerDataFromCache.CurrentCustomDimension03 = currentCustomDimension
end

function State.startNewSession(_, p, p2)
	if State:isEventSubmissionEnabled() and p2 == nil then
		Logger:i("Starting a new session.")
	end

	local playerDataFromCache = Store:GetPlayerDataFromCache(p.UserId)
	State:validateAndFixCurrentDimensions(p.UserId)
	local v2 = HttpApi:initRequest(Events.GameKey, Events.SecretKey, Events.Build, playerDataFromCache, p.UserId)
	local statusCode = v2.statusCode
	local body = v2.body

	if (statusCode == HttpApi.EGAHTTPApiResponse.Ok or statusCode == HttpApi.EGAHTTPApiResponse.Created) and body then
		local server_ts = body.server_ts or -1
		body.time_offset = not (server_ts > 0) and 0 or server_ts - os.time()

		if statusCode ~= HttpApi.EGAHTTPApiResponse.Created then
			local sdkConfig = playerDataFromCache.SdkConfig

			if sdkConfig.configs then
				body.configs = sdkConfig.configs
			end

			if sdkConfig.ab_id then
				body.ab_id = sdkConfig.ab_id
			end

			if sdkConfig.ab_variant_id then
				body.ab_variant_id = sdkConfig.ab_variant_id
			end
		end

		playerDataFromCache.SdkConfig = body
		playerDataFromCache.InitAuthorized = true
	elseif statusCode == HttpApi.EGAHTTPApiResponse.Unauthorized then
		Logger:w("Initialize SDK failed - Unauthorized")
		playerDataFromCache.InitAuthorized = false
	else
		if statusCode == HttpApi.EGAHTTPApiResponse.NoResponse or statusCode == HttpApi.EGAHTTPApiResponse.RequestTimeout then
			Logger:i("Init call (session start) failed - no response. Could be offline or timeout.")
		elseif statusCode == HttpApi.EGAHTTPApiResponse.BadResponse or statusCode == HttpApi.EGAHTTPApiResponse.JsonEncodeFailed or statusCode == HttpApi.EGAHTTPApiResponse.JsonDecodeFailed then
			Logger:i("Init call (session start) failed - bad response. Could be bad response from proxy or GA servers.")
		elseif statusCode == HttpApi.EGAHTTPApiResponse.BadRequest or statusCode == HttpApi.EGAHTTPApiResponse.UnknownResponseCode then
			Logger:i("Init call (session start) failed - bad request or unknown response.")
		end

		playerDataFromCache.InitAuthorized = true
	end

	playerDataFromCache.ClientServerTimeOffset = playerDataFromCache.SdkConfig.time_offset or 0
	playerDataFromCache.ConfigsHash = playerDataFromCache.SdkConfig.configs_hash or ""
	playerDataFromCache.AbId = playerDataFromCache.SdkConfig.ab_id or ""
	playerDataFromCache.AbVariantId = playerDataFromCache.SdkConfig.ab_variant_id or ""
	populateConfigurations(p)

	if not State:isEnabled(p.UserId) then
		Logger:w("Could not start session: SDK is disabled.")
		return
	end

	if p2 then
		playerDataFromCache.SessionID = p2.SessionID
		playerDataFromCache.SessionStart = p2.SessionStart
	else
		playerDataFromCache.SessionID = string.lower(HttpService:GenerateGUID(false))
		local playerDataFromCache2 = Store:GetPlayerDataFromCache(p.UserId)
		local now

		if playerDataFromCache2 then
			now = os.time()
			local v3 = now + playerDataFromCache2.ClientServerTimeOffset

			if Validation:validateClientTs(v3) then
				now = v3
			end
		else
			now = os.time()
		end

		playerDataFromCache.SessionStart = now
	end

	if State:isEventSubmissionEnabled() then
		Events:addSessionStartEvent(p.UserId, p2)
	end
end

function State.endSession(_, p)
	if State.Initialized and State:isEventSubmissionEnabled() then
		Logger:i("Ending session.")

		if State:isEnabled(p) and State:sessionIsStarted(p) then
			Events:addSessionEndEvent(p)
			Store.PlayerCache[p] = nil
		end
	end
end

function State.getRemoteConfigsStringValue(_, p, p2, p3)
	return Store:GetPlayerDataFromCache(p).Configurations[p2] or p3
end

function State.isRemoteConfigsReady(_, p)
	return Store:GetPlayerDataFromCache(p).RemoteConfigsIsReady
end

function State.getRemoteConfigsContentAsString(_, p)
	return HttpService:JSONEncode(Store:GetPlayerDataFromCache(p).Configurations)
end

return State