local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")
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
	EventsQueue = {}
}

function Store.GetPlayerData(_, p)
	local v = nil
	return not pcall(function()
		v = RunService:IsStudio() and {} or Store.PlayerDS:GetAsync(p.UserId) or {}
	end) and {} or v
end

function Store:GetPlayerDataFromCache(p)
	local v = Store.PlayerCache[tonumber(p)]
	return v or Store.PlayerCache[tostring(p)]
end

function Store.GetErrorDataStore(_, p)
	local v = nil
	return not pcall(function()
		v = RunService:IsStudio() and {} or DataStoreService:GetDataStore("GA_ErrorDS_1.0.0", p)
	end) and {} or v
end

function Store.SavePlayerData(_, p)
	local playerDataFromCache = Store:GetPlayerDataFromCache(p.UserId)
	local v = {}

	if not playerDataFromCache then
		return
	end

	for _, v2 in pairs(Store.DataToSave) do
		v[v2] = playerDataFromCache[v2]
	end

	if not RunService:IsStudio() then
		pcall(function()
			Store.PlayerDS:SetAsync(p.UserId, v)
		end)
	end
end

function Store.IncrementErrorCount(_, object, p, p2)
	if not p then
		return
	end

	local v = 0

	if not RunService:IsStudio() then
		pcall(function()
			v = object:IncrementAsync(p, p2)
		end)
	end

	return v
end

return Store