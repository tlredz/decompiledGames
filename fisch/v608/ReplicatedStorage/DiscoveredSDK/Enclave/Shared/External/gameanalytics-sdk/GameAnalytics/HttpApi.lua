local RunService = game:GetService("RunService")
local Validation = require(script.Parent.Validation)
local Version = require(script.Parent.Version)
local HashLib = require(script.HashLib)
local HttpApi = {
	protocol = "https",
	hostName = "api.gameanalytics.com",
	version = "v2",
	remoteConfigsVersion = "v1",
	initializeUrlPath = "init",
	eventsUrlPath = "events",
	EGAHTTPApiResponse = {
		NoResponse = 0,
		BadResponse = 1,
		RequestTimeout = 2,
		JsonEncodeFailed = 3,
		JsonDecodeFailed = 4,
		InternalServerError = 5,
		BadRequest = 6,
		Unauthorized = 7,
		UnknownResponseCode = 8,
		Ok = 9,
		Created = 10
	}
}
local HttpService = game:GetService("HttpService")
local Logger = require(script.Parent.Logger)
local v = (RunService:IsStudio() and "http" or HttpApi.protocol) .. "://" .. (RunService:IsStudio() and "sandbox-" or "") .. HttpApi.hostName .. "/" .. HttpApi.version
local v2 = (RunService:IsStudio() and "http" or HttpApi.protocol) .. "://" .. (RunService:IsStudio() and "sandbox-" or "") .. HttpApi.hostName .. "/remote_configs/" .. HttpApi.remoteConfigsVersion

-- equivalent calls inferred from this helper; original call sites unknown
local function getInitAnnotations(build, data, p2)
	return {
		user_id = tostring(p2) .. data.CustomUserId,
		sdk_version = "roblox " .. Version.SdkVersion,
		os_version = data.OS,
		platform = data.Platform,
		build = build,
		session_num = data.Sessions,
		random_salt = data.Sessions
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function encode(p, p2)
	if p2 then
		local hmac = HashLib.hmac(
			HashLib.sha256,
			RunService:IsStudio() and "16813a12f718bc5c620f56944e1abc3ea13ccbac" or p2,
			p,
			true
		)
		return HashLib.base64_encode(hmac)
	else
		Logger:w("Error encoding, invalid SecretKey")
	end
end

local function processRequestResponse(p, p2)
	local statusCode = p.StatusCode
	local body = p.Body

	if not body or #body == 0 then
		Logger:d(p2 .. " request. failed. Might be no connection. Status code: " .. tostring(statusCode))
		return HttpApi.EGAHTTPApiResponse.NoResponse
	end

	if statusCode == 200 then
		return HttpApi.EGAHTTPApiResponse.Ok
	elseif statusCode == 201 then
		return HttpApi.EGAHTTPApiResponse.Created
	end

	if statusCode == 0 or statusCode == 401 then
		Logger:d(p2 .. " request. 401 - Unauthorized.")
		return HttpApi.EGAHTTPApiResponse.Unauthorized
	end

	if statusCode == 400 then
		Logger:d(p2 .. " request. 400 - Bad Request.")
		return HttpApi.EGAHTTPApiResponse.BadRequest
	end

	if statusCode ~= 500 then
		return HttpApi.EGAHTTPApiResponse.UnknownResponseCode
	end

	Logger:d(p2 .. " request. 500 - Internal Server Error.")
	return HttpApi.EGAHTTPApiResponse.InternalServerError
end

function HttpApi.initRequest(p, p2, p3, build, data, p5)
	local url = v2 .. "/" .. HttpApi.initializeUrlPath .. "?game_key=" .. p2 .. "&interval_seconds=0&configs_hash=" .. (data.ConfigsHash or "")

	if RunService:IsStudio() then
		url = v .. "/5c6bcb5402204249437fb5a7a80a4959/" .. p.initializeUrlPath
	end

	Logger:d("Sending 'init' URL: " .. url)
	local body = HttpService:JSONEncode(getInitAnnotations(build, data, p5)):gsub(
		"\"country_code\":\"unknown\"",
		"\"country_code\":null"
	)
	local authorization = encode(body, p3) -- equivalent call inferred; original call site unknown
	Logger:d("init payload: " .. body)
	local v7 = nil
	local success, result = pcall(function()
		v7 = HttpService:RequestAsync({
			Url = url,
			Method = "POST",
			Headers = {
				Authorization = authorization,
				["Content-Type"] = "application/json"
			},
			Body = body
		})
	end)

	if not success then
		Logger:d("Failed Init Call. error: " .. result)
		return {
			statusCode = HttpApi.EGAHTTPApiResponse.UnknownResponseCode,
			body = nil
		}
	end

	Logger:d("init request content: " .. v7.Body)
	local statusCode = processRequestResponse(v7, "Init")

	if statusCode ~= HttpApi.EGAHTTPApiResponse.Ok and statusCode ~= HttpApi.EGAHTTPApiResponse.Created and statusCode ~= HttpApi.EGAHTTPApiResponse.BadRequest then
		Logger:d("Failed Init Call. URL: " .. url .. ", JSONString: " .. body .. ", Authorization: " .. authorization)
		return {
			statusCode = statusCode,
			body = nil
		}
	end

	local body2 = nil

	if not pcall(function()
		body2 = HttpService:JSONDecode(v7.Body)
	end) then
		Logger:d("Failed Init Call. Json decoding failed: " .. result)
		return {
			statusCode = HttpApi.EGAHTTPApiResponse.JsonDecodeFailed,
			body = nil
		}
	end

	if statusCode == HttpApi.EGAHTTPApiResponse.BadRequest then
		Logger:d("Failed Init Call. Bad request. Response: " .. v7.Body)
		return {
			statusCode = statusCode,
			body = nil
		}
	end

	if Validation:validateAndCleanInitRequestResponse(body2, statusCode == HttpApi.EGAHTTPApiResponse.Created) then
		return {
			statusCode = statusCode,
			body = body2
		}
	end

	return {
		statusCode = HttpApi.EGAHTTPApiResponse.BadResponse,
		body = nil
	}
end

function HttpApi.sendEventsInArray(p, p2, p3, list)
	if not list or #list == 0 then
		Logger:d("sendEventsInArray called with missing eventArray")
		return
	end

	local url = v .. "/" .. p2 .. "/" .. p.eventsUrlPath

	if RunService:IsStudio() then
		url = v .. "/5c6bcb5402204249437fb5a7a80a4959/" .. p.eventsUrlPath
	end

	Logger:d("Sending 'events' URL: " .. url)
	local body = HttpService:JSONEncode(list):gsub("\"country_code\":\"unknown\"", "\"country_code\":null")
	local authorization = encode(body, p3) -- equivalent call inferred; original call site unknown
	local v7 = nil
	local success, result = pcall(function()
		v7 = HttpService:RequestAsync({
			Url = url,
			Method = "POST",
			Headers = {
				Authorization = authorization,
				["Content-Type"] = "application/json"
			},
			Body = body
		})
	end)

	if not success then
		Logger:d("Failed Events Call. error: " .. result)
		return {
			statusCode = HttpApi.EGAHTTPApiResponse.UnknownResponseCode,
			body = nil
		}
	end

	Logger:d("body: " .. v7.Body)
	local statusCode = processRequestResponse(v7, "Events")

	if statusCode ~= HttpApi.EGAHTTPApiResponse.Ok and statusCode ~= HttpApi.EGAHTTPApiResponse.Created and statusCode ~= HttpApi.EGAHTTPApiResponse.BadRequest then
		Logger:d("Failed Events Call. URL: " .. url .. ", JSONString: " .. body .. ", Authorization: " .. authorization)
		return {
			statusCode = statusCode,
			body = nil
		}
	end

	local body2 = nil
	pcall(function()
		body2 = HttpService:JSONDecode(v7.Body)
	end)

	if not body2 then
		Logger:d("Failed Events Call. Json decoding failed")
		return {
			statusCode = HttpApi.EGAHTTPApiResponse.JsonDecodeFailed,
			body = nil
		}
	end

	if statusCode ~= HttpApi.EGAHTTPApiResponse.BadRequest then
		return {
			statusCode = HttpApi.EGAHTTPApiResponse.Ok,
			body = body2
		}
	end

	Logger:d("Failed Events Call. Bad request. Response: " .. v7.Body)
	return {
		statusCode = statusCode,
		body = nil
	}
end

return HttpApi