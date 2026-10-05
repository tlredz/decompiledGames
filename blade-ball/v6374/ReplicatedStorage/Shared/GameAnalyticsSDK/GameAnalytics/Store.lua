local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")
local DataStoreQueue = require(script.DataStoreQueue)
local Store = {
	PlayerDS = RunService:IsStudio() and {} or DataStoreService:GetDataStore("GA_PlayerDS_1.0.0"),
	AutoSaveData = 180,
	BasePlayerData = {
		Sessions = 0,
		Transactions = 0,
		ProgressionTries = {},
		CurrentCustomDimension01 = "",
		CurrentCustomDimension02 = "",
		CurrentCustomDimension03 = "",
		ConfigsHash = "",
		AbId = "",
		AbVariantId = "",
		InitAuthorized = false,
		SdkConfig = {},
		ClientServerTimeOffset = 0,
		Configurations = {},
		RemoteConfigsIsReady = false,
		PlayerTeleporting = false,
		OwnedGamepasses = nil,
		CountryCode = "",
		CustomUserId = ""
	},
	DataToSave = {
		"Sessions",
		"Transactions",
		"ProgressionTries",
		"CurrentCustomDimension01",
		"CurrentCustomDimension02",
		"CurrentCustomDimension03",
		"OwnedGamepasses"
	},
	PlayerCache = {},
	EventsQueue = {},
	DataStoreQueue = DataStoreQueue
}

function Store.GetPlayerData(p, p2)
	local userId = p2.UserId
	local v, v2 = DataStoreQueue.AddRequest(userId, function()
		return RunService:IsStudio() and {} or Store.PlayerDS:GetAsync(userId) or {}
	end, 7)
	return not v and {} or v2
end

function Store:GetPlayerDataFromCache(p2)
	local v = Store.PlayerCache[tonumber(p2)]
	return v or Store.PlayerCache[tostring(p2)]
end

function Store.GetErrorDataStore(p, p2)
	local v = nil
	return not pcall(function()
		v = RunService:IsStudio() and {} or DataStoreService:GetDataStore("GA_ErrorDS_1.0.0", p2)
	end) and {} or v
end

function Store.SavePlayerData(p, p2)
	local playerDataFromCache = Store:GetPlayerDataFromCache(p2.UserId)
	local v = {}

	if not playerDataFromCache then
		return
	end

	for k, v2 in pairs(Store.DataToSave) do
		v[v2] = playerDataFromCache[v2]
	end

	local userId = p2.UserId

	if not RunService:IsStudio() then
		DataStoreQueue.AddRequest(userId, function()
			return Store.PlayerDS:SetAsync(userId, v)
		end, 7)
	end
end

function Store.IncrementErrorCount(p, object, p2, p3)
	if not p2 then
		return
	end

	local v

	if RunService:IsStudio() then
		return 0
	else
		local v2
		v2, v = DataStoreQueue.AddRequest(p2, function()
			return object:IncrementAsync(p2, p3)
		end, 7)
		_ = v2
	end

	return v
end

return Store