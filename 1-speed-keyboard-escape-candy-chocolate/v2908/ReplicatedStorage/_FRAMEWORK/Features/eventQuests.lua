local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local FeatureManager = require(ReplicatedStorage._FRAMEWORK.Libraries.FeatureManager)
local NotificationBadge = require(ReplicatedStorage._FRAMEWORK.Libraries.uiComponents.NotificationBadge)
local TopBarButton = require(ReplicatedStorage._FRAMEWORK.Libraries.uiComponents.TopBarButton)
local remo = require(ReplicatedStorage.Packages.remo)
local t = require(ReplicatedStorage.Packages.t)
local Vide = require(ReplicatedStorage.Packages.Vide)
local EventsConfig = require(ReplicatedStorage.EventsConfig)
local Config = require(script.Config)
local QuestsMenu = require(script.QuestsMenu)
require(script.Types)
local isServer = RunService:IsServer()
local DataManager

if isServer then
	DataManager = require(ServerScriptService.DataManager)
else
	DataManager = nil
end

local EventCurrencyManager

if isServer then
	EventCurrencyManager = require(ServerScriptService.EventCurrencyManager)
else
	EventCurrencyManager = nil
end

local GameEvents

if isServer then
	GameEvents = require(ServerScriptService.GameEvents)
else
	GameEvents = nil
end

local NotificationSystem

if isServer then
	NotificationSystem = require(ReplicatedStorage.NotificationSystem)
else
	NotificationSystem = nil
end

local ClientState

if isServer then
	ClientState = nil
else
	ClientState = require(ReplicatedStorage.ClientState)
end

local color = Color3.fromRGB(255, 214, 120)
local EventQuests = {
	remotes = remo.createRemotes({
		eventQuests = remo.namespace({
			requestState = remo.remote().middleware(remo.throttleMiddleware(0.5)),
			stateUpdate = remo.remote(),
			claimQuest = remo.remote(t.string).middleware(remo.throttleMiddleware(0.5)),
			promptSkip = remo.remote(t.string).middleware(remo.throttleMiddleware(0.5)),
			promptRefresh = remo.remote().middleware(remo.throttleMiddleware(0.5))
		})
	}).eventQuests
}
local v = {}
local v2 = {}
local v3 = {}
local v4 = 0
local v5 = 0
local v6 = 0
local v7 = 0
local quests = {}
local source = Vide.source({})
local source2 = Vide.source(false)
local source3 = Vide.source(Config.events[1])
local v8 = nil
local v9 = 0

-- equivalent calls inferred from this helper; original call sites unknown
local function todayIndex()
	return os.time() // Config.daySeconds
end

local function isWindowOpen(event: string, now: number)
	for _, event2 in EventsConfig.Events do
		if event2.Name == event then
			return event2.Start <= now and now < event2.End
		end
	end

	return false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function findActiveEntry()
	local now = os.time()

	for _, event in Config.events do
		if isWindowOpen(event.event, now) then
			return event
		end
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function findEntry(event: string)
	for _, event2 in Config.events do
		if event2.event == event then
			return event2
		end
	end

	return nil
end

local function pickQuests(userId: number, p: number, p2: number)
	local random = Random.new(p * 7919 + userId + p2 * 31337)
	local clone = table.clone(Config.pool)
	local result = {}

	for _ = 1, Config.questsPerDay do
		local v10 = table.remove(clone, random:NextInteger(1, #clone))
		table.insert(result, {
			id = v10.id,
			type = v10.type,
			progress = 0,
			target = v10.target,
			reward = v10.reward,
			done = false,
			claimed = false
		})
	end

	return result
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getState(p)
	local profile = DataManager.Profiles[p]

	if profile then
		return profile.Data.EventQuestsState
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function flush(p, p2)
	v[p] = nil
	EventQuests.remotes.stateUpdate:fire(p, {
		day = p2.day,
		quests = p2.quests
	})
end

-- equivalent calls inferred from this helper; original call sites unknown
local function payReward(p, p2, reward: number, formatString: string)
	EventCurrencyManager:Add(p, p2.currency, reward)
	NotificationSystem:ShowGeneralNotificationForPlayer(
		p,
		string.format(formatString, reward, p2.currencyName),
		color,
		4
	)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function grantReward(p, p2, p3)
	p3.claimed = true
	payReward(p, p2, p3.reward, "Quest complete! +%d %s") -- equivalent call inferred; original call site unknown
end

local function claimFinished(p, p2, state)
	for _, quest in state.quests do
		if not quest.done or quest.claimed then
			continue
		end

		grantReward(p, p2, quest) -- equivalent call inferred; original call site unknown
	end
end

local function reconcile(p, state, activeEntry)
	local day = todayIndex() -- equivalent call inferred; original call site unknown

	if state.event ~= activeEntry.event or state.day ~= day then
		local entry = findEntry(state.event) -- equivalent call inferred; original call site unknown

		if entry then
			claimFinished(p, entry, state)
		end

		state.event = activeEntry.event
		state.day = day
		state.rerolls = 0
		state.quests = pickQuests(p.UserId, day, 0)
		v[p] = true
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function resolveState(p)
	local activeEntry = findActiveEntry() -- equivalent call inferred; original call site unknown
	local state = getState(p) -- equivalent call inferred; original call site unknown

	if activeEntry and state then
		reconcile(p, state, activeEntry)
		return state, activeEntry
	else
		return nil, nil
	end
end

local function resolveReceiptState(p)
	local state, activeEntry = resolveState(p) -- equivalent call inferred; original call site unknown

	if state then
		return state, activeEntry
	end

	local state2 = getState(p) -- equivalent call inferred; original call site unknown

	if not state2 then
		return state2, nil
	end

	local event = state2.event

	for _, event2 in Config.events do
		if event2.event == event then
			return state2, event2
		end
	end

	return state2, nil
end

local function addProgress(p, p2: string, p3: number)
	local activeEntry = findActiveEntry() -- equivalent call inferred; original call site unknown
	local state = getState(p) -- equivalent call inferred; original call site unknown

	if activeEntry and state then
		reconcile(p, state, activeEntry)
	else
		state = nil
	end

	if state then
		for _, quest in state.quests do
			if quest.type ~= p2 or quest.done then
				continue
			end

			quest.progress = math.min(quest.progress + p3, quest.target)
			quest.done = quest.progress >= quest.target

			if not quest.done then
				v[p] = true
				return
			end

			flush(p, state) -- equivalent call inferred; original call site unknown
			return
		end
	end
end

local function tickDistance(player)
	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if humanoidRootPart and humanoid then
		local position = humanoidRootPart.Position
		local v10 = v3[player]
		v3[player] = position

		if v10 then
			local magnitude = Vector3.new(position.X - v10.X, 0, position.Z - v10.Z).Magnitude
			local v11 = humanoid.WalkSpeed * Config.distanceTickSeconds * Config.teleportFactor

			if magnitude > 0.5 and magnitude <= v11 then
				addProgress(player, "Distance", magnitude)
			end
		end
	else
		v3[player] = nil
	end
end

local function resolveSkipTarget(state, p: string?)
	for _, quest in state.quests do
		if quest.id == p and not quest.done then
			return quest
		end
	end

	for _, quest in state.quests do
		if not quest.done then
			return quest
		end
	end

	for _, quest in state.quests do
		if quest.id == p then
			return quest
		end
	end

	return state.quests[1]
end

local function applySkip(playerByUserId)
	local state, activeEntry = resolveState(playerByUserId) -- equivalent call inferred; original call site unknown

	if not state then
		local profile = DataManager.Profiles[playerByUserId]

		if profile then
			state = profile.Data.EventQuestsState
		else
			state = nil
		end

		if state then
			local event = state.event

			for _, event2 in Config.events do
				if event2.event ~= event then
					continue
				end

				activeEntry = event2
				break
			end
		else
			activeEntry = nil
		end
	end

	if not (state and activeEntry) then
		return false
	end

	local skipTarget = resolveSkipTarget(state, v2[playerByUserId])
	v2[playerByUserId] = nil
	skipTarget.progress = skipTarget.target
	skipTarget.done = true

	if skipTarget.claimed then
		payReward(playerByUserId, activeEntry, skipTarget.reward, "+%d %s") -- equivalent call inferred; original call site unknown
	else
		grantReward(playerByUserId, activeEntry, skipTarget) -- equivalent call inferred; original call site unknown
	end

	flush(playerByUserId, state) -- equivalent call inferred; original call site unknown
	return true
end

local function applyRefresh(playerByUserId)
	local state, activeEntry = resolveState(playerByUserId) -- equivalent call inferred; original call site unknown

	if not state then
		local profile = DataManager.Profiles[playerByUserId]

		if profile then
			state = profile.Data.EventQuestsState
		else
			state = nil
		end

		if state then
			local event = state.event

			for _, event2 in Config.events do
				if event2.event ~= event then
					continue
				end

				activeEntry = event2
				break
			end
		else
			activeEntry = nil
		end
	end

	if not (state and activeEntry) then
		return false
	end

	claimFinished(playerByUserId, activeEntry, state)
	state.rerolls += 1
	state.quests = pickQuests(playerByUserId.UserId, state.day, state.rerolls)
	flush(playerByUserId, state) -- equivalent call inferred; original call site unknown
	return true
end

local function onRequestState(p)
	local activeEntry = findActiveEntry() -- equivalent call inferred; original call site unknown
	local state = getState(p) -- equivalent call inferred; original call site unknown

	if activeEntry and state then
		reconcile(p, state, activeEntry)
	else
		state = nil
	end

	if state then
		flush(p, state) -- equivalent call inferred; original call site unknown
	end
end

local function onClaimQuest(p, p2: string)
	local state, activeEntry = resolveState(p) -- equivalent call inferred; original call site unknown

	if state and activeEntry then
		for _, quest in state.quests do
			if quest.id ~= p2 or not quest.done or quest.claimed then
				continue
			end

			grantReward(p, activeEntry, quest) -- equivalent call inferred; original call site unknown
			flush(p, state) -- equivalent call inferred; original call site unknown
			return
		end
	end
end

local function onPromptSkip(p, p2: string)
	local activeEntry = findActiveEntry() -- equivalent call inferred; original call site unknown
	local state = getState(p) -- equivalent call inferred; original call site unknown

	if activeEntry and state then
		reconcile(p, state, activeEntry)
	else
		state = nil
	end

	if state then
		for _, quest in state.quests do
			if quest.id ~= p2 or quest.done then
				continue
			end

			v2[p] = p2
			MarketplaceService:PromptProductPurchase(p, Config.products.skip)
			return
		end
	end
end

local function onPromptRefresh(p)
	-- equivalent call inferred; original call site unknown
	if findActiveEntry() then
		MarketplaceService:PromptProductPurchase(p, Config.products.refresh)
	end
end

local function serverInit()
	EventQuests.remotes.requestState:connect(onRequestState)
	EventQuests.remotes.claimQuest:connect(onClaimQuest)
	EventQuests.remotes.promptSkip:connect(onPromptSkip)
	EventQuests.remotes.promptRefresh:connect(onPromptRefresh)
	GameEvents.LevelUp:Connect(function(p, p2: number, p3: number)
		addProgress(p, "Levels", p3 - p2)
	end)
	GameEvents.SpecialKeyCollected:Connect(function(p, p2: string)
		if p2 == "Golden" then
			addProgress(p, "GoldenKey", 1)
		elseif p2 == "Secret" then
			addProgress(p, "SecretKey", 1)
		end
	end)
	GameEvents.EventCoinCollected:Connect(function(p, p2: number)
		addProgress(p, "EventCoin", p2)
	end)
	GameEvents.PlayerTeleported:Connect(function(p, p2: string)
		v3[p] = nil

		if p2 == "WinBlock" or p2 == "BossBlock" then
			addProgress(p, "WinButton", 1)
		end
	end)
	Players.PlayerRemoving:Connect(function(player)
		v[player] = nil
		v2[player] = nil
		v3[player] = nil
	end)
end

local function serverUpdate()
	local now = os.clock()

	if now - v4 >= Config.distanceTickSeconds then
		v4 = now

		-- equivalent call inferred; original call site unknown
		if findActiveEntry() then
			for _, v10 in Players:GetPlayers() do
				tickDistance(v10)
			end
		end
	end

	if now - v5 >= Config.playtimeTickSeconds then
		v5 = now

		for _, v10 in Players:GetPlayers() do
			addProgress(v10, "Playtime", 1)
		end
	end

	if now - v6 >= 1 then
		v6 = now

		for k in v do
			local eventQuestsState

			if k.Parent then
				local profile = DataManager.Profiles[k]

				if profile then
					eventQuestsState = profile.Data.EventQuestsState
				end
			end

			if eventQuestsState then
				flush(k, eventQuestsState) -- equivalent call inferred; original call site unknown
			else
				v[k] = nil
			end
		end
	end

	if now - v7 >= 30 then
		v7 = now

		for _, v10 in Players:GetPlayers() do
			local activeEntry = findActiveEntry() -- equivalent call inferred; original call site unknown
			local state = getState(v10) -- equivalent call inferred; original call site unknown

			if activeEntry and state then
				reconcile(v10, state, activeEntry)
			end
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function findDefinition(id: string)
	for _, v10 in Config.pool do
		if v10.id == id then
			return v10
		end
	end

	return nil
end

local function currencyIcon(currency: string)
	for _, currency2 in EventsConfig.Currencies do
		if currency2.Key == currency then
			return "rbxassetid://" .. currency2.Icon
		end
	end

	error(string.format("eventQuests: no EventsConfig currency '%s'", currency))
end

local function toQuestViews(quests2)
	local result = {}

	for k, item in quests2 do
		local definition = findDefinition(item.id) -- equivalent call inferred; original call site unknown
		local v10 = {
			id = item.id,
			label = 0,
			progress = 0,
			target = 0,
			reward = 0,
			state = 0
		}
		local label

		if definition then
			label = string.format(definition.label, item.target, source3().currencyName)
		else
			label = item.id
		end

		v10.label = label
		v10.progress = math.floor(item.progress)
		v10.target = item.target
		v10.reward = item.reward
		v10.state = item.claimed and "Claimed" or item.done and "Completed" or "InProgress"
		result[k] = v10
	end

	return result
end

-- equivalent calls inferred from this helper; original call sites unknown
local function refreshActiveEntry()
	local activeEntry = findActiveEntry() -- equivalent call inferred; original call site unknown
	source2(activeEntry ~= nil)

	if activeEntry and activeEntry ~= source3() then
		source3(activeEntry)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function clientInit()
	refreshActiveEntry() -- equivalent call inferred; original call site unknown
	EventQuests.remotes.stateUpdate:connect(function(p)
		quests = p.quests
		source((toQuestViews(p.quests)))
	end)
	EventQuests.remotes.requestState:fire()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function clientUpdate()
	local now = os.clock()

	if now - v9 >= 30 then
		v9 = now
		refreshActiveEntry() -- equivalent call inferred; original call site unknown
	end
end

local v10 = {
	OnClose = function() end
}

local function openModal()
	EventQuests.remotes.requestState:fire()
	ClientState:ToggleModal(v8, v10)
end

local function claimableCount()
	local count = 0

	for _, v11 in source() do
		if v11.state == "Completed" then
			count += 1
		end
	end

	return count
end

local function theme()
	return source3().theme
end

local function clientUIInit()
	local speedGameUI = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("SpeedGameUI")
	local topButtons = speedGameUI:WaitForChild("Frames"):WaitForChild("TopButtons")
	Vide.mount(function()
		TopBarButton({
			Name = "QuestButton",
			LayoutOrder = 10,
			Emoji = function()
				return source3().theme.buttonEmoji
			end,
			BackgroundColor = function()
				return source3().theme.buttonColor
			end,
			Visible = source2,
			Parent = topButtons,
			OnActivated = openModal
		}, NotificationBadge({
			Count = claimableCount
		}))
		local questsMenu = QuestsMenu({
			Visible = false,
			Theme = theme,
			RewardIcon = function()
				return currencyIcon(source3().currency)
			end,
			Quests = source,
			OnClaim = function(p: string)
				EventQuests.remotes.claimQuest:fire(p)
			end,
			OnSkip = function(p: string)
				EventQuests.remotes.promptSkip:fire(p)
			end,
			OnRefresh = function()
				EventQuests.remotes.promptRefresh:fire()
			end,
			OnClose = function()
				ClientState:CloseCurrentModal()
			end
		})
		questsMenu:SetAttribute("ModalVisibleY", 0.45)
		v8 = questsMenu
		return questsMenu
	end, speedGameUI)
end

function EventQuests.isEnabled()
	return Config.enabled
end

function EventQuests.getProducts()
	return Config.products
end

function EventQuests.getQuests(p)
	if not isServer then
		return quests
	end

	assert(p, "eventQuests.getQuests requires a player on the server")
	local activeEntry = findActiveEntry() -- equivalent call inferred; original call site unknown
	local state = getState(p) -- equivalent call inferred; original call site unknown

	if activeEntry and state then
		reconcile(p, state, activeEntry)
	else
		state = nil
	end

	if state then
		return state.quests
	end

	return nil
end

function EventQuests.grantSkip(p: number)
	assert(isServer, "eventQuests: this function is server-only")
	local playerByUserId = Players:GetPlayerByUserId(p)

	if playerByUserId then
		return (applySkip(playerByUserId))
	end

	return false
end

function EventQuests.grantRefresh(p: number)
	assert(isServer, "eventQuests: this function is server-only")
	local playerByUserId = Players:GetPlayerByUserId(p)

	if playerByUserId then
		return (applyRefresh(playerByUserId))
	end

	return false
end

FeatureManager.RegisterFeature(script.Name, {
	OnInit = function()
		if not Config.enabled then
			return
		end

		if isServer then
			serverInit()
			return
		end

		clientInit() -- equivalent call inferred; original call site unknown
	end,
	OnUIInit = function()
		if Config.enabled then
			clientUIInit()
		end
	end,
	OnUpdate = function()
		if Config.enabled then
			if isServer then
				serverUpdate()
				return
			end

			clientUpdate() -- equivalent call inferred; original call site unknown
		end
	end
})
return EventQuests