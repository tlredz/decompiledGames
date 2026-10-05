local GameAnalyticsServer = {
	EGAResourceFlowType = require(script.GAResourceFlowType),
	EGAProgressionStatus = require(script.GAProgressionStatus),
	EGAErrorSeverity = require(script.GAErrorSeverity)
}
local Logger = require(script.Logger)
local Threading = require(script.Threading)
local State = require(script.State)
local Validation = require(script.Validation)
local Store = require(script.Store)
local Events = require(script.Events)
local Utilities = require(script.Utilities)
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalizationService = game:GetService("LocalizationService")
game:GetService("ScriptContext")
local Postie = require(script.Postie)
local marketplace = require(ReplicatedStorage.shared.utils.marketplace)
local v = nil
local productInfos = {}
local errorDataStore = {}
local v2 = {}
local v3 = {}
local v4 = {}
local v5 = {}

local function addToInitializationQueue(func, ...)
	if v4 == nil then
		Logger:w("Initialization queue already cleared.")
		return
	end

	table.insert(v4, {
		Func = func,
		Args = { ... }
	})
	Logger:i("Added event to initialization queue")
end

local function addToInitializationQueueByUserId(p, func, ...)
	if GameAnalyticsServer:isPlayerReady(p) then
		Logger:w("Player initialization queue already cleared.")
		return
	end

	if v5[p] == nil then
		v5[p] = {}
	end

	table.insert(v5[p], {
		Func = func,
		Args = { ... }
	})
	Logger:i("Added event to player initialization queue")
end

local function isSdkReady(data)
	local playerId = data.playerId or nil
	local needsInitialized = data.needsInitialized or true
	local shouldWarn = data.shouldWarn or false
	local message = data.message or ""

	if needsInitialized and not State.Initialized then
		if shouldWarn then
			Logger:w(message .. " SDK is not initialized")
		end

		return false
	elseif needsInitialized and playerId and not State:isEnabled(playerId) then
		if shouldWarn then
			Logger:w(message .. " SDK is disabled")
		end

		return false
	elseif needsInitialized and playerId and not State:sessionIsStarted(playerId) then
		if shouldWarn then
			Logger:w(message .. " Session has not started yet")
		end

		return false
	else
		return true
	end
end

function GameAnalyticsServer:configureAvailableCustomDimensions01(p)
	if isSdkReady({
		needsInitialized = true,
		shouldWarn = false
	}) then
		Logger:w("Available custom dimensions must be set before SDK is initialized")
	else
		State:setAvailableCustomDimensions01(p)
	end
end

function GameAnalyticsServer:configureAvailableCustomDimensions02(p)
	if isSdkReady({
		needsInitialized = true,
		shouldWarn = false
	}) then
		Logger:w("Available custom dimensions must be set before SDK is initialized")
	else
		State:setAvailableCustomDimensions02(p)
	end
end

function GameAnalyticsServer:configureAvailableCustomDimensions03(p)
	if isSdkReady({
		needsInitialized = true,
		shouldWarn = false
	}) then
		Logger:w("Available custom dimensions must be set before SDK is initialized")
	else
		State:setAvailableCustomDimensions03(p)
	end
end

function GameAnalyticsServer:configureAvailableResourceCurrencies(p)
	if isSdkReady({
		needsInitialized = true,
		shouldWarn = false
	}) then
		Logger:w("Available resource currencies must be set before SDK is initialized")
	else
		Events:setAvailableResourceCurrencies(p)
	end
end

function GameAnalyticsServer:configureAvailableResourceItemTypes(p)
	if isSdkReady({
		needsInitialized = true,
		shouldWarn = false
	}) then
		Logger:w("Available resource item types must be set before SDK is initialized")
	else
		Events:setAvailableResourceItemTypes(p)
	end
end

function GameAnalyticsServer:configureBuild(p)
	if isSdkReady({
		needsInitialized = true,
		shouldWarn = false
	}) then
		Logger:w("Build version must be set before SDK is initialized.")
	else
		Events:setBuild(p)
	end
end

function GameAnalyticsServer:configureAvailableGamepasses(p)
	if isSdkReady({
		needsInitialized = true,
		shouldWarn = false
	}) then
		Logger:w("Available gamepasses must be set before SDK is initialized.")
	else
		State:setAvailableGamepasses(p)
	end
end

function GameAnalyticsServer:startNewSession(p, p2)
	Threading:performTaskOnGAThread(function()
		if not State:isEventSubmissionEnabled() then
			return
		end

		if State.Initialized then
			State:startNewSession(p, p2)
		else
			Logger:w("Cannot start new session. SDK is not initialized yet.")
		end
	end)
end

function GameAnalyticsServer:endSession(p)
	Threading:performTaskOnGAThread(function()
		if not State:isEventSubmissionEnabled() then
			return
		end

		State:endSession(p)
	end)
end

function GameAnalyticsServer:filterForBusinessEvent(value)
	return string.gsub(value, "[^A-Za-z0-9%s%-_%.%(%)!%?]", "")
end

function GameAnalyticsServer:addBusinessEvent(playerId, data)
	Threading:performTaskOnGAThread(function()
		if not State:isEventSubmissionEnabled() then
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
			local v6 = math.floor(amount * 0.7 * 0.35)
			local gamepassId = data.gamepassId or nil
			Events:addBusinessEvent(playerId, "USD", v6, itemType, itemId, cartType)

			if itemType == "Gamepass" and cartType ~= "Website" then
				local playerByUserId = Players:GetPlayerByUserId(playerId)
				local playerDataFromCache = Store:GetPlayerDataFromCache(playerId)

				if not playerDataFromCache.OwnedGamepasses then
					playerDataFromCache.OwnedGamepasses = {}
				end

				table.insert(playerDataFromCache.OwnedGamepasses, gamepassId)
				Store.PlayerCache[playerId] = playerDataFromCache
				Store:SavePlayerData(playerByUserId)
			end
		elseif playerId then
			addToInitializationQueueByUserId(
				playerId,
				GameAnalyticsServer.addBusinessEvent,
				GameAnalyticsServer,
				playerId,
				data
			)
		else
			addToInitializationQueue(GameAnalyticsServer.addBusinessEvent, GameAnalyticsServer, playerId, data)
		end
	end)
end

function GameAnalyticsServer:addResourceEvent(playerId, data)
	Threading:performTaskOnGAThread(function()
		if not State:isEventSubmissionEnabled() then
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
			Events:addResourceEvent(playerId, flowType, currency, amount, itemType, itemId)
		elseif playerId then
			addToInitializationQueueByUserId(
				playerId,
				GameAnalyticsServer.addResourceEvent,
				GameAnalyticsServer,
				playerId,
				data
			)
		else
			addToInitializationQueue(GameAnalyticsServer.addResourceEvent, GameAnalyticsServer, playerId, data)
		end
	end)
end

function GameAnalyticsServer:addProgressionEvent(playerId, data)
	Threading:performTaskOnGAThread(function()
		if not State:isEventSubmissionEnabled() then
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
			Events:addProgressionEvent(playerId, progressionStatus, progression01, progression02, progression03, score)
		elseif playerId then
			addToInitializationQueueByUserId(
				playerId,
				GameAnalyticsServer.addProgressionEvent,
				GameAnalyticsServer,
				playerId,
				data
			)
		else
			addToInitializationQueue(GameAnalyticsServer.addProgressionEvent, GameAnalyticsServer, playerId, data)
		end
	end)
end

function GameAnalyticsServer:addDesignEvent(playerId, p2)
	Threading:performTaskOnGAThread(function()
		if not State:isEventSubmissionEnabled() then
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
			Events:addDesignEvent(playerId, eventId, value)
		elseif playerId then
			addToInitializationQueueByUserId(
				playerId,
				GameAnalyticsServer.addDesignEvent,
				GameAnalyticsServer,
				playerId,
				p2
			)
		else
			addToInitializationQueue(GameAnalyticsServer.addDesignEvent, GameAnalyticsServer, playerId, p2)
		end
	end)
end

function GameAnalyticsServer:addErrorEvent(playerId, p2)
	Threading:performTaskOnGAThread(function()
		if not State:isEventSubmissionEnabled() then
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
			Events:addErrorEvent(playerId, severity, message)
		elseif playerId then
			addToInitializationQueueByUserId(
				playerId,
				GameAnalyticsServer.addErrorEvent,
				GameAnalyticsServer,
				playerId,
				p2
			)
		else
			addToInitializationQueue(GameAnalyticsServer.addErrorEvent, GameAnalyticsServer, playerId, p2)
		end
	end)
end

function GameAnalyticsServer:setEnabledDebugLog(p)
	if not RunService:IsStudio() then
		Logger:i("setEnabledDebugLog can only be used in studio")
	elseif p then
		Logger:setDebugLog(p)
		Logger:i("Debug logging enabled")
	else
		Logger:i("Debug logging disabled")
		Logger:setDebugLog(p)
	end
end

function GameAnalyticsServer:setEnabledInfoLog(p)
	if p then
		Logger:setInfoLog(p)
		Logger:i("Info logging enabled")
	else
		Logger:i("Info logging disabled")
		Logger:setInfoLog(p)
	end
end

function GameAnalyticsServer:setEnabledVerboseLog(p)
	if p then
		Logger:setVerboseLog(p)
		Logger:ii("Verbose logging enabled")
	else
		Logger:ii("Verbose logging disabled")
		Logger:setVerboseLog(p)
	end
end

function GameAnalyticsServer.setEnabledEventSubmission(_, p)
	Threading:performTaskOnGAThread(function()
		if p then
			State:setEventSubmission(p)
			Logger:i("Event submission enabled")
		else
			Logger:i("Event submission disabled")
			State:setEventSubmission(p)
		end
	end)
end

function GameAnalyticsServer:setCustomDimension01(playerId, p2)
	Threading:performTaskOnGAThread(function()
		if not Validation:validateDimension(State._availableCustomDimensions01, p2) then
			Logger:w("Could not set custom01 dimension value to '" .. p2 .. "'. Value not found in available custom01 dimension values")
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

		State:setCustomDimension01(playerId, p2)
	end)
end

function GameAnalyticsServer:setCustomDimension02(playerId, p2)
	Threading:performTaskOnGAThread(function()
		if not Validation:validateDimension(State._availableCustomDimensions02, p2) then
			Logger:w("Could not set custom02 dimension value to '" .. p2 .. "'. Value not found in available custom02 dimension values")
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

		State:setCustomDimension02(playerId, p2)
	end)
end

function GameAnalyticsServer:setCustomDimension03(playerId, p2)
	Threading:performTaskOnGAThread(function()
		if not Validation:validateDimension(State._availableCustomDimensions03, p2) then
			Logger:w("Could not set custom03 dimension value to '" .. p2 .. "'. Value not found in available custom03 dimension values")
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

		State:setCustomDimension03(playerId, p2)
	end)
end

function GameAnalyticsServer:setEnabledReportErrors(reportErrors)
	Threading:performTaskOnGAThread(function()
		State.ReportErrors = reportErrors
	end)
end

function GameAnalyticsServer:setEnabledCustomUserId(useCustomUserId)
	Threading:performTaskOnGAThread(function()
		State.UseCustomUserId = useCustomUserId
	end)
end

function GameAnalyticsServer:setEnabledAutomaticSendBusinessEvents(automaticSendBusinessEvents)
	Threading:performTaskOnGAThread(function()
		State.AutomaticSendBusinessEvents = automaticSendBusinessEvents
	end)
end

function GameAnalyticsServer.addGameAnalyticsTeleportData(_, list, p)
	local gameanalyticsData = {}

	for _, v7 in ipairs(list) do
		local playerDataFromCache = Store:GetPlayerDataFromCache(v7)
		playerDataFromCache.PlayerTeleporting = true
		local v8 = {
			SessionID = playerDataFromCache.SessionID,
			Sessions = playerDataFromCache.Sessions,
			SessionStart = playerDataFromCache.SessionStart
		}
		gameanalyticsData[tostring(v7)] = v8
	end

	p.gameanalyticsData = gameanalyticsData
	return p
end

function GameAnalyticsServer.getRemoteConfigsValueAsString(_, p, p2)
	local key = p2.key or ""
	local defaultValue = p2.defaultValue or nil
	return State:getRemoteConfigsStringValue(p, key, defaultValue)
end

function GameAnalyticsServer:isRemoteConfigsReady(p)
	return State:isRemoteConfigsReady(p)
end

function GameAnalyticsServer:getRemoteConfigsContentAsString(p)
	return State:getRemoteConfigsContentAsString(p)
end

function GameAnalyticsServer:PlayerJoined(object)
	local teleportData = object:GetJoinData().TeleportData
	local playerData = Store:GetPlayerData(object)
	local v6

	if teleportData then
		v6 = teleportData.gameanalyticsData and teleportData.gameanalyticsData[tostring(object.UserId)]
	end

	local playerDataFromCache = Store:GetPlayerDataFromCache(object.UserId)

	if playerDataFromCache then
		if v6 then
			playerDataFromCache.SessionID = v6.SessionID
			playerDataFromCache.SessionStart = v6.SessionStart
		end

		playerDataFromCache.PlayerTeleporting = false
	else
		local v7, v8 = Postie.invokeClient("getPlatform", object, 5)
		local v9 = not v7 and "unknown" or v8

		for k, v10 in pairs(Store.BasePlayerData) do
			if playerData[k] then
				continue
			end

			if typeof(v10) == "table" then
				playerData[k] = Utilities:copyTable(v10)
			else
				playerData[k] = v10
			end
		end

		local success, result = pcall(function()
			return LocalizationService:GetCountryRegionForPlayerAsync(object)
		end)

		if success then
			playerData.CountryCode = result
		end

		Store.PlayerCache[object.UserId] = playerData
		local platform

		if v9 == "Console" then
			platform = "uwp_console"
		elseif v9 == "Mobile" then
			platform = "uwp_mobile"
		else
			platform = "uwp_desktop"
		end

		playerData.Platform = platform
		playerData.OS = playerData.Platform .. " 0.0.0"

		if not success then
			Events:addSdkErrorEvent(
				object.UserId,
				"event_validation",
				"player_joined",
				"string_empty_or_null",
				"country_code",
				""
			)
		end

		local customUserId = ""

		if State.UseCustomUserId then
			local v12, v13 = Postie.invokeClient("getCustomUserId", object, 5)

			if v12 then
				customUserId = v13
			end
		end

		if not Utilities:isStringNullOrEmpty(customUserId) then
			Logger:i("Using custom id: " .. customUserId)
			playerData.CustomUserId = customUserId
		end

		GameAnalyticsServer:startNewSession(object, v6)
		v = v or ReplicatedStorage:WaitForChild("OnPlayerReadyEvent")
		v:Fire(object)

		if State.AutomaticSendBusinessEvents then
			if playerData.OwnedGamepasses == nil then
				playerData.OwnedGamepasses = {}

				for _, _availableGamepass in ipairs(State._availableGamepasses) do
					if marketplace.userHasGamepassAsync(object, _availableGamepass) then
						table.insert(playerData.OwnedGamepasses, _availableGamepass)
					end
				end

				Store.PlayerCache[object.UserId] = playerData
				Store:SavePlayerData(object)
			else
				local _availableGamepasses = {}

				for _, _availableGamepass in ipairs(State._availableGamepasses) do
					if marketplace.userHasGamepassAsync(object, _availableGamepass) then
						table.insert(_availableGamepasses, _availableGamepass)
					end
				end

				local v12 = {}

				for _, ownedGamepass in ipairs(playerData.OwnedGamepasses) do
					v12[ownedGamepass] = true
				end

				for _, v13 in ipairs(_availableGamepasses) do
					if v12[v13] then
						continue
					end

					table.insert(playerData.OwnedGamepasses, v13)
					local productInfo = productInfos[v13]

					if not productInfo then
						productInfo = MarketplaceService:GetProductInfo(v13, Enum.InfoType.GamePass)
						productInfos[v13] = productInfo
					end

					GameAnalyticsServer:addBusinessEvent(object.UserId, {
						amount = productInfo.PriceInRobux,
						itemType = "Gamepass",
						itemId = GameAnalyticsServer:filterForBusinessEvent(productInfo.Name),
						cartType = "Website"
					})
				end

				Store.PlayerCache[object.UserId] = playerData
				Store:SavePlayerData(object)
			end
		end

		local v12 = v5[object.UserId]

		if v12 then
			v5[object.UserId] = nil

			for _, v13 in ipairs(v12) do
				v13.Func(unpack(v13.Args))
			end

			Logger:i("Player initialization queue called #" .. #v12 .. " events")
		end
	end
end

function GameAnalyticsServer:PlayerRemoved(p)
	Store:SavePlayerData(p)
	local playerDataFromCache = Store:GetPlayerDataFromCache(p.UserId)

	if playerDataFromCache then
		if playerDataFromCache.PlayerTeleporting then
			Store.PlayerCache[p.UserId] = nil
			Store.DataStoreQueue.RemoveKey(p.UserId)
		else
			GameAnalyticsServer:endSession(p.UserId)
		end
	end
end

function GameAnalyticsServer:isPlayerReady(p)
	if Store:GetPlayerDataFromCache(p) then
		return true
	end

	return false
end

function GameAnalyticsServer.ProcessReceiptCallback(_, data)
	local productInfo = productInfos[data.ProductId]

	if not productInfo then
		pcall(function()
			productInfo = MarketplaceService:GetProductInfo(data.ProductId, Enum.InfoType.Product)
			productInfos[data.ProductId] = productInfo
		end)
	end

	if productInfo then
		GameAnalyticsServer:addBusinessEvent(data.PlayerId, {
			amount = data.CurrencySpent,
			itemType = "DeveloperProduct",
			itemId = GameAnalyticsServer:filterForBusinessEvent(productInfo.Name)
		})
	end
end

function GameAnalyticsServer:GamepassPurchased(p, gamepassId, p3)
	local productInfo = productInfos[gamepassId]

	if not productInfo then
		productInfo = MarketplaceService:GetProductInfo(gamepassId, Enum.InfoType.GamePass)
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

	GameAnalyticsServer:addBusinessEvent(p.UserId, {
		amount = priceInRobux or 0,
		itemType = "Gamepass",
		itemId = GameAnalyticsServer:filterForBusinessEvent(name),
		gamepassId = gamepassId
	})
end

local v6 = { "gameKey", "secretKey" }

function GameAnalyticsServer.initServer(_, gameKey: string, secretKey: string)
	GameAnalyticsServer:initialize({
		gameKey = gameKey,
		secretKey = secretKey
	})
end

function GameAnalyticsServer:initialize(data)
	Threading:performTaskOnGAThread(function()
		for _, v7 in ipairs(v6) do
			if data[v7] ~= nil then
				continue
			end

			Logger:e("Initialize '" .. v7 .. "' option missing")
			return
		end

		if data.enableInfoLog ~= nil and data.enableInfoLog then
			GameAnalyticsServer:setEnabledInfoLog(data.enableInfoLog)
		end

		if data.enableVerboseLog ~= nil and data.enableVerboseLog then
			GameAnalyticsServer:setEnabledVerboseLog(data.enableVerboseLog)
		end

		if data.availableCustomDimensions01 ~= nil and #data.availableCustomDimensions01 > 0 then
			GameAnalyticsServer:configureAvailableCustomDimensions01(data.availableCustomDimensions01)
		end

		if data.availableCustomDimensions02 ~= nil and #data.availableCustomDimensions02 > 0 then
			GameAnalyticsServer:configureAvailableCustomDimensions02(data.availableCustomDimensions02)
		end

		if data.availableCustomDimensions03 ~= nil and #data.availableCustomDimensions03 > 0 then
			GameAnalyticsServer:configureAvailableCustomDimensions03(data.availableCustomDimensions03)
		end

		if data.availableResourceCurrencies ~= nil and #data.availableResourceCurrencies > 0 then
			GameAnalyticsServer:configureAvailableResourceCurrencies(data.availableResourceCurrencies)
		end

		if data.availableResourceItemTypes ~= nil and #data.availableResourceItemTypes > 0 then
			GameAnalyticsServer:configureAvailableResourceItemTypes(data.availableResourceItemTypes)
		end

		if data.build ~= nil and #data.build > 0 then
			GameAnalyticsServer:configureBuild(data.build)
		end

		if data.availableGamepasses ~= nil and #data.availableGamepasses > 0 then
			GameAnalyticsServer:configureAvailableGamepasses(data.availableGamepasses)
		end

		if data.enableDebugLog ~= nil then
			GameAnalyticsServer:setEnabledDebugLog(data.enableDebugLog)
		end

		if data.automaticSendBusinessEvents ~= nil then
			GameAnalyticsServer:setEnabledAutomaticSendBusinessEvents(data.automaticSendBusinessEvents)
		end

		if data.reportErrors ~= nil then
			GameAnalyticsServer:setEnabledReportErrors(data.reportErrors)
		end

		if data.useCustomUserId ~= nil then
			GameAnalyticsServer:setEnabledCustomUserId(data.useCustomUserId)
		end

		if isSdkReady({
			needsInitialized = true,
			shouldWarn = false
		}) then
			Logger:w("SDK already initialized. Can only be called once.")
			return
		end

		local gameKey = data.gameKey
		local secretKey = data.secretKey

		if not Validation:validateKeys(gameKey, secretKey) then
			Logger:w("SDK failed initialize. Game key or secret key is invalid. Can only contain characters A-z 0-9, gameKey is 32 length, secretKey is 40 length. Failed keys - gameKey: " .. gameKey .. ", secretKey: " .. secretKey)
			return
		end

		Events.GameKey = gameKey
		Events.SecretKey = secretKey
		State.Initialized = true
		Players.PlayerAdded:Connect(function(player)
			GameAnalyticsServer:PlayerJoined(player)
		end)
		Players.PlayerRemoving:Connect(function(player)
			GameAnalyticsServer:PlayerRemoved(player)
		end)

		for _, v7 in ipairs(Players:GetPlayers()) do
			coroutine.wrap(GameAnalyticsServer.PlayerJoined)(GameAnalyticsServer, v7)
		end

		for _, v7 in ipairs(v4) do
			task.spawn(v7.Func, unpack(v7.Args))
		end

		Logger:i("Server initialization queue called #" .. #v4 .. " events")
		v4 = nil
		Events:processEventQueue()
	end)
end

if not ReplicatedStorage:FindFirstChild("GameAnalyticsRemoteConfigs") then
	local remoteEvent = Instance.new("RemoteEvent")
	remoteEvent.Name = "GameAnalyticsRemoteConfigs"
	remoteEvent.Parent = ReplicatedStorage
end

if not ReplicatedStorage:FindFirstChild("OnPlayerReadyEvent") then
	local bindableEvent = Instance.new("BindableEvent")
	bindableEvent.Name = "OnPlayerReadyEvent"
	bindableEvent.Parent = ReplicatedStorage
end

task.spawn(function()
	errorDataStore = Store:GetErrorDataStore((math.floor(os.time() / 3600)))

	while task.wait(3600) do
		errorDataStore = Store:GetErrorDataStore((math.floor(os.time() / 3600)))
		v2 = {}
		v3 = {}
	end
end)
task.spawn(function()
	while task.wait(Store.AutoSaveData) do
		for _, v7 in pairs(v3) do
			local v8 = v2[v7]
			local v9 = v8.currentCount - v8.countInDS
			v2[v7].countInDS = Store:IncrementErrorCount(errorDataStore, v7, v9)
			v2[v7].currentCount = v2[v7].countInDS
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

	local v8

	if #message > 50 then
		v8 = string.sub(message, 1, 50)
	else
		v8 = message
	end

	if v2[v8] == nil then
		v3[#v3 + 1] = v8
		v2[v8] = {}
		v2[v8].countInDS = 0
		v2[v8].currentCount = 0
	end

	if v2[v8].currentCount > 10 then
		return
	end

	GameAnalyticsServer:addErrorEvent(userId, {
		severity = GameAnalyticsServer.EGAErrorSeverity.error,
		message = message
	})
	v2[v8].currentCount = v2[v8].currentCount + 1
end

local function ErrorHandlerFromServer(p, p2, instance)
	if not (State.ReportErrors and instance) then
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
	if State.ReportErrors then
		return ErrorHandler(p, p2, p3, p4)
	end
end

if not ReplicatedStorage:FindFirstChild("GameAnalyticsError") then
	local remoteEvent = Instance.new("RemoteEvent")
	remoteEvent.Name = "GameAnalyticsError"
	remoteEvent.Parent = ReplicatedStorage
end

ReplicatedStorage.GameAnalyticsError.OnServerEvent:Connect(function(p, p2, p3, p4)
	if not State.ReportErrors then
		return
	end

	ErrorHandler(p2, p3, p4, p)
end)
MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(p, p2, p3)
	if State.AutomaticSendBusinessEvents and p3 then
		GameAnalyticsServer:GamepassPurchased(p, p2)
	end
end)
return GameAnalyticsServer