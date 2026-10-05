local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local GameAnalytics = {
	EGAResourceFlowType = require3(script.GAResourceFlowType),
	EGAProgressionStatus = require3(script.GAProgressionStatus),
	EGAErrorSeverity = require3(script.GAErrorSeverity)
}
local v = require3(script.Logger)
local v2 = require3(script.Threading)
local v3 = require3(script.State)
local v4 = require3(script.Validation)
local v5 = require3(script.Store)
local v6 = require3(script.Events)
local v7 = require3(script.Utilities)
local Players = game:GetService("Players")
local v8 = require3(game.ReplicatedStorage.Common.MarketplaceService)
local RunService = game:GetService("RunService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local LocalizationService = game:GetService("LocalizationService")
local ScriptContext = game:GetService("ScriptContext")
local v9 = require3(script.Postie)
local v10 = nil
local productInfos = {}
local errorDataStore = {}
local v11 = {}
local v12 = {}
local v13 = {}
local v14 = {}

local function addToInitializationQueue(func, ...)
	if v13 == nil then
		v:w("Initialization queue already cleared.")
		return
	end

	table.insert(v13, {
		Func = func,
		Args = { ... }
	})
	v:i("Added event to initialization queue")
end

local function addToInitializationQueueByUserId(p, func, ...)
	if GameAnalytics:isPlayerReady(p) then
		v:w("Player initialization queue already cleared.")
		return
	end

	if v14[p] == nil then
		v14[p] = {}
	end

	table.insert(v14[p], {
		Func = func,
		Args = { ... }
	})
	v:i("Added event to player initialization queue")
end

local function isSdkReady(data)
	local playerId = data.playerId or nil
	local needsInitialized = data.needsInitialized or true
	local shouldWarn = data.shouldWarn or false
	local message = data.message or ""

	if needsInitialized and not v3.Initialized then
		if shouldWarn then
			v:w(message .. " SDK is not initialized")
		end

		return false
	elseif needsInitialized and playerId and not v3:isEnabled(playerId) then
		if shouldWarn then
			v:w(message .. " SDK is disabled")
		end

		return false
	elseif needsInitialized and playerId and not v3:sessionIsStarted(playerId) then
		if shouldWarn then
			v:w(message .. " Session has not started yet")
		end

		return false
	else
		return true
	end
end

function GameAnalytics:configureAvailableCustomDimensions01(p)
	if isSdkReady({
		needsInitialized = true,
		shouldWarn = false
	}) then
		v:w("Available custom dimensions must be set before SDK is initialized")
	else
		v3:setAvailableCustomDimensions01(p)
	end
end

function GameAnalytics:configureAvailableCustomDimensions02(p)
	if isSdkReady({
		needsInitialized = true,
		shouldWarn = false
	}) then
		v:w("Available custom dimensions must be set before SDK is initialized")
	else
		v3:setAvailableCustomDimensions02(p)
	end
end

function GameAnalytics:configureAvailableCustomDimensions03(p)
	if isSdkReady({
		needsInitialized = true,
		shouldWarn = false
	}) then
		v:w("Available custom dimensions must be set before SDK is initialized")
	else
		v3:setAvailableCustomDimensions03(p)
	end
end

function GameAnalytics:configureAvailableResourceCurrencies(p)
	if isSdkReady({
		needsInitialized = true,
		shouldWarn = false
	}) then
		v:w("Available resource currencies must be set before SDK is initialized")
	else
		v6:setAvailableResourceCurrencies(p)
	end
end

function GameAnalytics:configureAvailableResourceItemTypes(p)
	if isSdkReady({
		needsInitialized = true,
		shouldWarn = false
	}) then
		v:w("Available resource item types must be set before SDK is initialized")
	else
		v6:setAvailableResourceItemTypes(p)
	end
end

function GameAnalytics:configureBuild(p)
	if isSdkReady({
		needsInitialized = true,
		shouldWarn = false
	}) then
		v:w("Build version must be set before SDK is initialized.")
	else
		v6:setBuild(p)
	end
end

function GameAnalytics:configureAvailableGamepasses(p)
	if isSdkReady({
		needsInitialized = true,
		shouldWarn = false
	}) then
		v:w("Available gamepasses must be set before SDK is initialized.")
	else
		v3:setAvailableGamepasses(p)
	end
end

function GameAnalytics:startNewSession(p, p2)
	v2:performTaskOnGAThread(function()
		if not v3:isEventSubmissionEnabled() then
			return
		end

		if v3.Initialized then
			v3:startNewSession(p, p2)
		else
			v:w("Cannot start new session. SDK is not initialized yet.")
		end
	end)
end

function GameAnalytics:endSession(p)
	v2:performTaskOnGAThread(function()
		if not v3:isEventSubmissionEnabled() then
			return
		end

		v3:endSession(p)
	end)
end

function GameAnalytics:filterForBusinessEvent(value)
	return string.gsub(value, "[^A-Za-z0-9%s%-_%.%(%)!%?]", "")
end

function GameAnalytics:addBusinessEvent(playerId, data)
	v2:performTaskOnGAThread(function()
		if not v3:isEventSubmissionEnabled() then
			return
		end

		if isSdkReady({
			playerId = playerId,
			needsInitialized = true,
			shouldWarn = false,
			message = "Could not add business event"
		}) then
			local amount = data.amount or 0
			local itemType = data.itemType or ""
			local itemId = data.itemId or ""
			local cartType = data.cartType or ""
			local v15 = math.floor(amount * 0.7 * 0.35)
			local gamepassId = data.gamepassId or nil
			v6:addBusinessEvent(playerId, "USD", v15, itemType, itemId, cartType)

			if itemType == "Gamepass" and cartType ~= "Website" then
				local playerByUserId = Players:GetPlayerByUserId(playerId)
				local playerDataFromCache = v5:GetPlayerDataFromCache(playerId)

				if not playerDataFromCache.OwnedGamepasses then
					playerDataFromCache.OwnedGamepasses = {}
				end

				table.insert(playerDataFromCache.OwnedGamepasses, gamepassId)
				v5.PlayerCache[playerId] = playerDataFromCache
				v5:SavePlayerData(playerByUserId)
			end
		elseif playerId then
			addToInitializationQueueByUserId(playerId, GameAnalytics.addBusinessEvent, GameAnalytics, playerId, data)
		else
			addToInitializationQueue(GameAnalytics.addBusinessEvent, GameAnalytics, playerId, data)
		end
	end)
end

function GameAnalytics:addResourceEvent(playerId, data)
	v2:performTaskOnGAThread(function()
		if not v3:isEventSubmissionEnabled() then
			return
		end

		if isSdkReady({
			playerId = playerId,
			needsInitialized = true,
			shouldWarn = false,
			message = "Could not add resource event"
		}) then
			local flowType = data.flowType or 0
			local currency = data.currency or ""
			local amount = data.amount or 0
			local itemType = data.itemType or ""
			local itemId = data.itemId or ""
			v6:addResourceEvent(playerId, flowType, currency, amount, itemType, itemId)
		elseif playerId then
			addToInitializationQueueByUserId(playerId, GameAnalytics.addResourceEvent, GameAnalytics, playerId, data)
		else
			addToInitializationQueue(GameAnalytics.addResourceEvent, GameAnalytics, playerId, data)
		end
	end)
end

function GameAnalytics:addProgressionEvent(playerId, data)
	v2:performTaskOnGAThread(function()
		if not v3:isEventSubmissionEnabled() then
			return
		end

		if isSdkReady({
			playerId = playerId,
			needsInitialized = true,
			shouldWarn = false,
			message = "Could not add progression event"
		}) then
			local progressionStatus = data.progressionStatus or 0
			local progression01 = data.progression01 or ""
			local progression02 = data.progression02 or nil
			local progression03 = data.progression03 or nil
			local score = data.score or nil
			v6:addProgressionEvent(playerId, progressionStatus, progression01, progression02, progression03, score)
		elseif playerId then
			addToInitializationQueueByUserId(playerId, GameAnalytics.addProgressionEvent, GameAnalytics, playerId, data)
		else
			addToInitializationQueue(GameAnalytics.addProgressionEvent, GameAnalytics, playerId, data)
		end
	end)
end

function GameAnalytics:addDesignEvent(playerId, p2)
	v2:performTaskOnGAThread(function()
		if not v3:isEventSubmissionEnabled() then
			return
		end

		if isSdkReady({
			playerId = playerId,
			needsInitialized = true,
			shouldWarn = false,
			message = "Could not add design event"
		}) then
			local eventId = p2.eventId or ""
			local value = p2.value or nil
			v6:addDesignEvent(playerId, eventId, value)
		elseif playerId then
			addToInitializationQueueByUserId(playerId, GameAnalytics.addDesignEvent, GameAnalytics, playerId, p2)
		else
			addToInitializationQueue(GameAnalytics.addDesignEvent, GameAnalytics, playerId, p2)
		end
	end)
end

function GameAnalytics:addErrorEvent(playerId, p2)
	v2:performTaskOnGAThread(function()
		if not v3:isEventSubmissionEnabled() then
			return
		end

		if isSdkReady({
			playerId = playerId,
			needsInitialized = true,
			shouldWarn = false,
			message = "Could not add error event"
		}) then
			local severity = p2.severity or 0
			local message = p2.message or ""
			v6:addErrorEvent(playerId, severity, message)
		elseif playerId then
			addToInitializationQueueByUserId(playerId, GameAnalytics.addErrorEvent, GameAnalytics, playerId, p2)
		else
			addToInitializationQueue(GameAnalytics.addErrorEvent, GameAnalytics, playerId, p2)
		end
	end)
end

function GameAnalytics:setEnabledDebugLog(p)
	if not RunService:IsStudio() then
		v:i("setEnabledDebugLog can only be used in studio")
	elseif p then
		v:setDebugLog(p)
		v:i("Debug logging enabled")
	else
		v:i("Debug logging disabled")
		v:setDebugLog(p)
	end
end

function GameAnalytics:setEnabledInfoLog(p)
	if p then
		v:setInfoLog(p)
		v:i("Info logging enabled")
	else
		v:i("Info logging disabled")
		v:setInfoLog(p)
	end
end

function GameAnalytics:setEnabledVerboseLog(p)
	if p then
		v:setVerboseLog(p)
		v:ii("Verbose logging enabled")
	else
		v:ii("Verbose logging disabled")
		v:setVerboseLog(p)
	end
end

function GameAnalytics.setEnabledEventSubmission(_, p)
	v2:performTaskOnGAThread(function()
		if p then
			v3:setEventSubmission(p)
			v:i("Event submission enabled")
		else
			v:i("Event submission disabled")
			v3:setEventSubmission(p)
		end
	end)
end

function GameAnalytics:setCustomDimension01(playerId, p2)
	v2:performTaskOnGAThread(function()
		if not v4:validateDimension(v3._availableCustomDimensions01, p2) then
			v:w("Could not set custom01 dimension value to '" .. p2 .. "'. Value not found in available custom01 dimension values")
			return
		end

		if not isSdkReady({
			playerId = playerId,
			needsInitialized = true,
			shouldWarn = true,
			message = "Could not set custom01 dimension"
		}) then
			return
		end

		v3:setCustomDimension01(playerId, p2)
	end)
end

function GameAnalytics:setCustomDimension02(playerId, p2)
	v2:performTaskOnGAThread(function()
		if not v4:validateDimension(v3._availableCustomDimensions02, p2) then
			v:w("Could not set custom02 dimension value to '" .. p2 .. "'. Value not found in available custom02 dimension values")
			return
		end

		if not isSdkReady({
			playerId = playerId,
			needsInitialized = true,
			shouldWarn = true,
			message = "Could not set custom02 dimension"
		}) then
			return
		end

		v3:setCustomDimension02(playerId, p2)
	end)
end

function GameAnalytics:setCustomDimension03(playerId, p2)
	v2:performTaskOnGAThread(function()
		if not v4:validateDimension(v3._availableCustomDimensions03, p2) then
			v:w("Could not set custom03 dimension value to '" .. p2 .. "'. Value not found in available custom03 dimension values")
			return
		end

		if not isSdkReady({
			playerId = playerId,
			needsInitialized = true,
			shouldWarn = true,
			message = "Could not set custom03 dimension"
		}) then
			return
		end

		v3:setCustomDimension03(playerId, p2)
	end)
end

function GameAnalytics:setEnabledReportErrors(reportErrors)
	v2:performTaskOnGAThread(function()
		v3.ReportErrors = reportErrors
	end)
end

function GameAnalytics:setEnabledCustomUserId(useCustomUserId)
	v2:performTaskOnGAThread(function()
		v3.UseCustomUserId = useCustomUserId
	end)
end

function GameAnalytics:setEnabledAutomaticSendBusinessEvents(automaticSendBusinessEvents)
	v2:performTaskOnGAThread(function()
		v3.AutomaticSendBusinessEvents = automaticSendBusinessEvents
	end)
end

function GameAnalytics.addGameAnalyticsTeleportData(_, list, p)
	local gameanalyticsData = {}

	for _, v16 in ipairs(list) do
		local playerDataFromCache = v5:GetPlayerDataFromCache(v16)
		playerDataFromCache.PlayerTeleporting = true
		local v17 = {
			SessionID = playerDataFromCache.SessionID,
			Sessions = playerDataFromCache.Sessions,
			SessionStart = playerDataFromCache.SessionStart
		}
		gameanalyticsData[tostring(v16)] = v17
	end

	p.gameanalyticsData = gameanalyticsData
	return p
end

function GameAnalytics.getRemoteConfigsValueAsString(_, p, p2)
	local key = p2.key or ""
	local defaultValue = p2.defaultValue or nil
	return v3:getRemoteConfigsStringValue(p, key, defaultValue)
end

function GameAnalytics:isRemoteConfigsReady(p)
	return v3:isRemoteConfigsReady(p)
end

function GameAnalytics:getRemoteConfigsContentAsString(p)
	return v3:getRemoteConfigsContentAsString(p)
end

function GameAnalytics:PlayerJoined(object)
	local teleportData = object:GetJoinData().TeleportData
	local playerData = v5:GetPlayerData(object)
	local v15

	if teleportData then
		v15 = teleportData.gameanalyticsData and teleportData.gameanalyticsData[tostring(object.UserId)]
	end

	local playerDataFromCache = v5:GetPlayerDataFromCache(object.UserId)

	if playerDataFromCache then
		if v15 then
			playerDataFromCache.SessionID = v15.SessionID
			playerDataFromCache.SessionStart = v15.SessionStart
		end

		playerDataFromCache.PlayerTeleporting = false
	else
		local v16, v17 = v9.invokeClient("getPlatform", object, 5)
		local v18 = not v16 and "unknown" or v17

		for k, v19 in pairs(v5.BasePlayerData) do
			if playerData[k] then
				continue
			end

			if typeof(v19) == "table" then
				playerData[k] = v7:copyTable(v19)
			else
				playerData[k] = v19
			end
		end

		local success, result = pcall(function()
			return LocalizationService:GetCountryRegionForPlayerAsync(object)
		end)

		if success then
			playerData.CountryCode = result
		end

		v5.PlayerCache[object.UserId] = playerData
		local platform

		if v18 == "Console" then
			platform = "uwp_console"
		elseif v18 == "Mobile" then
			platform = "uwp_mobile"
		else
			platform = "uwp_desktop"
		end

		playerData.Platform = platform
		playerData.OS = playerData.Platform .. " 0.0.0"

		if not success then
			v6:addSdkErrorEvent(
				object.UserId,
				"event_validation",
				"player_joined",
				"string_empty_or_null",
				"country_code",
				""
			)
		end

		local customUserId = ""

		if v3.UseCustomUserId then
			local v21, v22 = v9.invokeClient("getCustomUserId", object, 5)

			if v21 then
				customUserId = v22
			end
		end

		if not v7:isStringNullOrEmpty(customUserId) then
			v:i("Using custom id: " .. customUserId)
			playerData.CustomUserId = customUserId
		end

		GameAnalytics:startNewSession(object, v15)
		v10 = v10 or ReplicatedStorage2:WaitForChild("OnPlayerReadyEvent")
		v10:Fire(object)

		if v3.AutomaticSendBusinessEvents then
			if playerData.OwnedGamepasses == nil then
				playerData.OwnedGamepasses = {}

				for _, _availableGamepass in ipairs(v3._availableGamepasses) do
					if v8:UserOwnsGamePassAsync(object.UserId, _availableGamepass) then
						table.insert(playerData.OwnedGamepasses, _availableGamepass)
					end
				end

				v5.PlayerCache[object.UserId] = playerData
				v5:SavePlayerData(object)
			else
				local _availableGamepasses = {}

				for _, _availableGamepass in ipairs(v3._availableGamepasses) do
					if v8:UserOwnsGamePassAsync(object.UserId, _availableGamepass) then
						table.insert(_availableGamepasses, _availableGamepass)
					end
				end

				local v21 = {}

				for _, ownedGamepass in ipairs(playerData.OwnedGamepasses) do
					v21[ownedGamepass] = true
				end

				for _, v22 in ipairs(_availableGamepasses) do
					if v21[v22] then
						continue
					end

					table.insert(playerData.OwnedGamepasses, v22)
					local productInfo = productInfos[v22]

					if not productInfo then
						productInfo = v8:GetProductInfo(v22, Enum.InfoType.GamePass)
						productInfos[v22] = productInfo
					end

					GameAnalytics:addBusinessEvent(object.UserId, {
						amount = productInfo.PriceInRobux,
						itemType = "Gamepass",
						itemId = GameAnalytics:filterForBusinessEvent(productInfo.Name),
						cartType = "Website"
					})
				end

				v5.PlayerCache[object.UserId] = playerData
				v5:SavePlayerData(object)
			end
		end

		local v21 = v14[object.UserId]

		if v21 then
			v14[object.UserId] = nil

			for _, v22 in ipairs(v21) do
				v22.Func(unpack(v22.Args))
			end

			v:i("Player initialization queue called #" .. #v21 .. " events")
		end
	end
end

function GameAnalytics:PlayerRemoved(p)
	v5:SavePlayerData(p)
	local playerDataFromCache = v5:GetPlayerDataFromCache(p.UserId)

	if playerDataFromCache then
		if playerDataFromCache.PlayerTeleporting then
			v5.PlayerCache[p.UserId] = nil
			v5.DataStoreQueue.RemoveKey(p.UserId)
		else
			GameAnalytics:endSession(p.UserId)
		end
	end
end

function GameAnalytics:isPlayerReady(p)
	if v5:GetPlayerDataFromCache(p) then
		return true
	end

	return false
end

function GameAnalytics.ProcessReceiptCallback(_, data)
	local productInfo = productInfos[data.ProductId]

	if not productInfo then
		pcall(function()
			productInfo = v8:GetProductInfo(data.ProductId, Enum.InfoType.Product)
			productInfos[data.ProductId] = productInfo
		end)
	end

	if productInfo then
		GameAnalytics:addBusinessEvent(data.PlayerId, {
			amount = data.CurrencySpent,
			itemType = "DeveloperProduct",
			itemId = GameAnalytics:filterForBusinessEvent(productInfo.Name)
		})
	end
end

function GameAnalytics:GamepassPurchased(p, gamepassId, p3)
	local productInfo = productInfos[gamepassId]

	if not productInfo then
		productInfo = v8:GetProductInfo(gamepassId, Enum.InfoType.GamePass)
		productInfos[gamepassId] = productInfo
	end

	local priceInRobux = 0
	local name = "GamePass"

	if p3 then
		priceInRobux = p3.PriceInRobux
		name = p3.Name
	elseif productInfo then
		priceInRobux = productInfo.PriceInRobux
		name = productInfo.Name
	end

	GameAnalytics:addBusinessEvent(p.UserId, {
		amount = priceInRobux or 0,
		itemType = "Gamepass",
		itemId = GameAnalytics:filterForBusinessEvent(name),
		gamepassId = gamepassId
	})
end

local v15 = { "gameKey", "secretKey" }

function GameAnalytics.initServer(_, gameKey: string, secretKey: string)
	GameAnalytics:initialize({
		gameKey = gameKey,
		secretKey = secretKey
	})
end

function GameAnalytics:initialize(data)
	v2:performTaskOnGAThread(function()
		for _, v16 in ipairs(v15) do
			if data[v16] ~= nil then
				continue
			end

			v:e("Initialize '" .. v16 .. "' option missing")
			return
		end

		if data.enableInfoLog ~= nil and data.enableInfoLog then
			GameAnalytics:setEnabledInfoLog(data.enableInfoLog)
		end

		if data.enableVerboseLog ~= nil and data.enableVerboseLog then
			GameAnalytics:setEnabledVerboseLog(data.enableVerboseLog)
		end

		if data.availableCustomDimensions01 ~= nil and #data.availableCustomDimensions01 > 0 then
			GameAnalytics:configureAvailableCustomDimensions01(data.availableCustomDimensions01)
		end

		if data.availableCustomDimensions02 ~= nil and #data.availableCustomDimensions02 > 0 then
			GameAnalytics:configureAvailableCustomDimensions02(data.availableCustomDimensions02)
		end

		if data.availableCustomDimensions03 ~= nil and #data.availableCustomDimensions03 > 0 then
			GameAnalytics:configureAvailableCustomDimensions03(data.availableCustomDimensions03)
		end

		if data.availableResourceCurrencies ~= nil and #data.availableResourceCurrencies > 0 then
			GameAnalytics:configureAvailableResourceCurrencies(data.availableResourceCurrencies)
		end

		if data.availableResourceItemTypes ~= nil and #data.availableResourceItemTypes > 0 then
			GameAnalytics:configureAvailableResourceItemTypes(data.availableResourceItemTypes)
		end

		if data.build ~= nil and #data.build > 0 then
			GameAnalytics:configureBuild(data.build)
		end

		if data.availableGamepasses ~= nil and #data.availableGamepasses > 0 then
			GameAnalytics:configureAvailableGamepasses(data.availableGamepasses)
		end

		if data.enableDebugLog ~= nil then
			GameAnalytics:setEnabledDebugLog(data.enableDebugLog)
		end

		if data.automaticSendBusinessEvents ~= nil then
			GameAnalytics:setEnabledAutomaticSendBusinessEvents(data.automaticSendBusinessEvents)
		end

		if data.reportErrors ~= nil then
			GameAnalytics:setEnabledReportErrors(data.reportErrors)
		end

		if data.useCustomUserId ~= nil then
			GameAnalytics:setEnabledCustomUserId(data.useCustomUserId)
		end

		if isSdkReady({
			needsInitialized = true,
			shouldWarn = false
		}) then
			v:w("SDK already initialized. Can only be called once.")
			return
		end

		local gameKey = data.gameKey
		local secretKey = data.secretKey

		if not v4:validateKeys(gameKey, secretKey) then
			v:w("SDK failed initialize. Game key or secret key is invalid. Can only contain characters A-z 0-9, gameKey is 32 length, secretKey is 40 length. Failed keys - gameKey: " .. gameKey .. ", secretKey: " .. secretKey)
			return
		end

		v6.GameKey = gameKey
		v6.SecretKey = secretKey
		v3.Initialized = true
		Players.PlayerAdded:Connect(function(player)
			GameAnalytics:PlayerJoined(player)
		end)
		Players.PlayerRemoving:Connect(function(player)
			GameAnalytics:PlayerRemoved(player)
		end)

		for _, v16 in ipairs(Players:GetPlayers()) do
			coroutine.wrap(GameAnalytics.PlayerJoined)(GameAnalytics, v16)
		end

		for _, v16 in ipairs(v13) do
			task.spawn(v16.Func, unpack(v16.Args))
		end

		v:i("Server initialization queue called #" .. #v13 .. " events")
		v13 = nil
		v6:processEventQueue()
	end)
end

if not ReplicatedStorage2:FindFirstChild("GameAnalyticsRemoteConfigs") then
	local remoteEvent = Instance.new("RemoteEvent")
	remoteEvent.Name = "GameAnalyticsRemoteConfigs"
	remoteEvent.Parent = ReplicatedStorage2
end

if not ReplicatedStorage2:FindFirstChild("OnPlayerReadyEvent") then
	local bindableEvent = Instance.new("BindableEvent")
	bindableEvent.Name = "OnPlayerReadyEvent"
	bindableEvent.Parent = ReplicatedStorage2
end

task.spawn(function()
	errorDataStore = v5:GetErrorDataStore((math.floor(os.time() / 3600)))

	while task.wait(3600) do
		errorDataStore = v5:GetErrorDataStore((math.floor(os.time() / 3600)))
		v11 = {}
		v12 = {}
	end
end)
task.spawn(function()
	while task.wait(v5.AutoSaveData) do
		for _, v16 in pairs(v12) do
			local v17 = v11[v16]
			local v18 = v17.currentCount - v17.countInDS
			v11[v16].countInDS = v5:IncrementErrorCount(errorDataStore, v16, v18)
			v11[v16].currentCount = v11[v16].countInDS
		end
	end
end)

local function ErrorHandler(p, p2, p3, p4)
	local message = (p3 == nil and "(null)" or p3) .. ": message=" .. (p == nil and "(null)" or p) .. ", trace=" .. (p2 == nil and "(null)" or p2)

	if #message > 8192 then
		message = string.sub(message, 1, 8192)
	end

	local userId

	if p4 then
		userId = p4.UserId
		message = message:gsub(p4.Name, "[LocalPlayer]")
	end

	local v17

	if #message > 50 then
		v17 = string.sub(message, 1, 50)
	else
		v17 = message
	end

	if v11[v17] == nil then
		v12[#v12 + 1] = v17
		v11[v17] = {}
		v11[v17].countInDS = 0
		v11[v17].currentCount = 0
	end

	if v11[v17].currentCount > 10 then
		return
	end

	GameAnalytics:addErrorEvent(userId, {
		severity = GameAnalytics.EGAErrorSeverity.error,
		message = message
	})
	v11[v17].currentCount = v11[v17].currentCount + 1
end

local function ErrorHandlerFromServer(p, p2, instance)
	if not (v3.ReportErrors and instance) then
		return
	end

	local fullName = nil
	local success, _ = pcall(function()
		fullName = instance:GetFullName()
	end)

	if success then
		return ErrorHandler(p, p2, fullName)
	end
end

local function ErrorHandlerFromClient(p, p2, p3, p4)
	if v3.ReportErrors then
		return ErrorHandler(p, p2, p3, p4)
	end
end

ScriptContext.Error:Connect(ErrorHandlerFromServer)

if not ReplicatedStorage2:FindFirstChild("GameAnalyticsError") then
	local remoteEvent = Instance.new("RemoteEvent")
	remoteEvent.Name = "GameAnalyticsError"
	remoteEvent.Parent = ReplicatedStorage2
end

ReplicatedStorage2.GameAnalyticsError.OnServerEvent:Connect(function(p, p2, p3, p4)
	if not v3.ReportErrors then
		return
	end

	ErrorHandler(p2, p3, p4, p)
end)
v8.PromptGamePassPurchaseFinished:Connect(function(p, p2, p3)
	if v3.AutomaticSendBusinessEvents and p3 then
		GameAnalytics:GamepassPurchased(p, p2)
	end
end)
return GameAnalytics