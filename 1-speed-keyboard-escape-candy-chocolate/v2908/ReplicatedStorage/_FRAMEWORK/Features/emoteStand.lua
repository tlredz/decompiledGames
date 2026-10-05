local CollectionService = game:GetService("CollectionService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local FeatureManager = require(ReplicatedStorage._FRAMEWORK.Libraries.FeatureManager)
local Janitor = require(ReplicatedStorage.Utilities.Janitor)
local LoggerManager = require(ReplicatedStorage._FRAMEWORK.Libraries.LoggerManager)
local RelicsBridge = require(script.RelicsBridge)
local StandBuilder = require(script.StandBuilder)
require(script.Types)
local isClient = RunService:IsClient()
local logger = LoggerManager.createLogger(script.Name, {
	feature = script:GetFullName()
})
local EmoteStand = {}
local v = {}
local v2 = {}
local v3 = false
local v4 = false
local count = 0

local function parseEmoteNames(instance)
	local result = {}
	local emotes = instance:GetAttribute("Emotes")

	if type(emotes) == "string" then
		for k in string.gmatch(emotes, "[^,]+") do
			local v5 = string.match(k, "^%s*(.-)%s*$")

			if v5 and v5 ~= "" then
				table.insert(result, v5)
			end
		end
	end

	if #result == 0 then
		local emote = instance:GetAttribute("Emote")

		if type(emote) == "string" and emote ~= "" then
			table.insert(result, emote)
		end
	end

	return result
end

local function parseRollOrder(instance)
	local rollOrder = instance:GetAttribute("RollOrder")

	if type(rollOrder) == "string" and string.lower(rollOrder) == "random" then
		return "random"
	end

	return "sequence"
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updatePrompt(p)
	local prompt = p.prompt
	local emote = p.emote

	if prompt and emote then
		prompt.ObjectText = emote.Name
		task.spawn(function()
			local playerOwns = RelicsBridge.playerOwns(emote)

			if p.prompt ~= prompt or p.emote ~= emote then
				return
			end

			if playerOwns then
				prompt.ActionText = "Open"
				return
			end

			local buyText = RelicsBridge.getBuyText(emote)

			if p.prompt == prompt and p.emote == emote then
				prompt.ActionText = buyText
			end
		end)
	end
end

local function onTriggered(p)
	local emote = p.emote

	if not emote then
		return
	end

	if RelicsBridge.playerOwns(emote) then
		RelicsBridge.openEmoteMenu()
	else
		RelicsBridge.promptPurchase(emote)
	end
end

local function pickEmote(data, flag: boolean)
	local emoteNames = data.emoteNames
	local count2 = #emoteNames

	if count2 == 0 then
		return nil, data.rollIndex
	end

	local v5 = not flag and 0 or (data.rollOrder ~= "random" or not (count2 > 2)) and 1 or math.random(1, count2 - 1)

	for i = 0, count2 - 1 do
		local v6 = 1 + (data.rollIndex - 1 + v5 + i) % count2
		local emote = RelicsBridge.getEmote(emoteNames[v6])

		if emote and (not flag or emote ~= data.emote) then
			return emote, v6
		end
	end

	return nil, data.rollIndex
end

-- equivalent calls inferred from this helper; original call sites unknown
local function rollStand(state)
	local emote2, rollIndex = pickEmote(state, true)

	if not emote2 then
		return
	end

	state.emote = emote2
	state.rollIndex = rollIndex
	local buildId = state.buildId
	task.spawn(StandBuilder.showEmote, state, emote2, buildId)
	local prompt = state.prompt
	local emote = state.emote

	if prompt then
		if not emote then
			return
		end

		prompt.ObjectText = emote.Name
		task.spawn(function()
			local playerOwns = RelicsBridge.playerOwns(emote)

			if state.prompt ~= prompt or state.emote ~= emote then
				return
			end

			if playerOwns then
				prompt.ActionText = "Open"
				return
			end

			local buyText = RelicsBridge.getBuyText(emote)

			if state.prompt == prompt and state.emote == emote then
				prompt.ActionText = buyText
			end
		end)
	end
end

local function tryBuild(state)
	if state.destroyed or state.emote or not v3 then
		return
	end

	local emote2, rollIndex = pickEmote(state, false)

	if not emote2 then
		return
	end

	state.emote = emote2
	state.rollIndex = rollIndex
	state.buildId += 1
	local buildId = state.buildId
	task.spawn(function()
		local v7 = StandBuilder.build(state, emote2, buildId, {
			onTriggered = function()
				local emote = state.emote

				if not emote then
					return
				end

				if RelicsBridge.playerOwns(emote) then
					RelicsBridge.openEmoteMenu()
				else
					RelicsBridge.promptPurchase(emote)
				end
			end,
			onPromptReady = function()
				local v8 = state
				local prompt = v8.prompt
				local emote = v8.emote

				if prompt then
					if not emote then
						return
					end

					prompt.ObjectText = emote.Name
					task.spawn(function()
						local playerOwns = RelicsBridge.playerOwns(emote)

						if v8.prompt ~= prompt or v8.emote ~= emote then
							return
						end

						if playerOwns then
							prompt.ActionText = "Open"
							return
						end

						local buyText = RelicsBridge.getBuyText(emote)

						if v8.prompt == prompt and v8.emote == emote then
							prompt.ActionText = buyText
						end
					end)
				end
			end
		})

		if state.destroyed or state.buildId ~= buildId then
			return
		end

		if v7 then
			state.nextRollClock = os.clock() + state.rollInterval * (0.6 + math.random() * 0.4)
		else
			StandBuilder.clear(state)
		end
	end)
end

local function registerStand(p)
	local v5 = {}

	for _, emoteName in p.emoteNames do
		if v5[emoteName] then
			continue
		end

		v5[emoteName] = true
		local v6 = v2[emoteName]

		if not v6 then
			v6 = {}
			v2[emoteName] = v6
		end

		table.insert(v6, p)
	end
end

local function unregisterStand(p)
	for _, emoteName in p.emoteNames do
		local v5 = v2[emoteName]

		if not v5 then
			continue
		end

		local index = table.find(v5, p)

		if index then
			table.remove(v5, index)
		end

		if #v5 == 0 then
			v2[emoteName] = nil
		end
	end
end

local scheduleUnknownEmoteWarning

scheduleUnknownEmoteWarning = function(data)
	task.delay(20, function()
		if data.destroyed or data.emote then
			return
		end

		if not v4 then
			scheduleUnknownEmoteWarning(data)
			return
		end

		if not v3 then
			return
		end

		local loadedEmoteNames = RelicsBridge.getLoadedEmoteNames()
		local v5 = not (#loadedEmoteNames > 0) and "No emotes loaded (backend unavailable?)." or `Available emotes: {table.concat(loadedEmoteNames, ", ")}`
		logger:warn((`{data.stand:GetFullName()} : emote(s) "{table.concat(data.emoteNames, ", ")}" unknown. {v5}`))
	end)
end

local function setupStand(instance)
	if v[instance] then
		return
	end

	local emoteNames = parseEmoteNames(instance)

	if #emoteNames == 0 then
		logger:warn((`{instance:GetFullName()} : missing string attribute "Emote" or "Emotes".`))
		return
	end

	count += 1
	local v6 = {
		stand = instance,
		emoteNames = emoteNames,
		rollOrder = 0,
		rollInterval = 0,
		rollIndex = 0,
		nextRollClock = 1e999,
		emote = nil,
		dummy = nil,
		prompt = nil,
		buildJanitor = 0,
		showJanitor = 0,
		buildId = 0,
		showId = 0,
		destroyed = false
	}
	local rollOrder = instance:GetAttribute("RollOrder")
	v6.rollOrder = type(rollOrder) == "string" and string.lower(rollOrder) == "random" and "random" or "sequence"
	v6.rollInterval = math.max(tonumber(instance:GetAttribute("RollInterval")) or 8, 2)
	v6.rollIndex = (count - 1) % #emoteNames + 1
	v6.buildJanitor = Janitor.new()
	v6.showJanitor = Janitor.new()

	for k in v do
		if k:IsDescendantOf(instance) or instance:IsDescendantOf(k) then
			logger:warn((`{instance:GetFullName()} is nested with another tagged stand ({k:GetFullName()}) — both spawn a mannequin.`))
		end
	end

	v[instance] = v6
	registerStand(v6)
	tryBuild(v6)
	task.delay(20, function()
		if v6.destroyed or v6.emote then
			return
		end

		if not v4 then
			scheduleUnknownEmoteWarning(v6)
			return
		end

		if not v3 then
			return
		end

		local loadedEmoteNames = RelicsBridge.getLoadedEmoteNames()
		local v7 = not (#loadedEmoteNames > 0) and "No emotes loaded (backend unavailable?)." or `Available emotes: {table.concat(loadedEmoteNames, ", ")}`
		logger:warn((`{v6.stand:GetFullName()} : emote(s) "{table.concat(v6.emoteNames, ", ")}" unknown. {v7}`))
	end)
end

local function teardownStand(p)
	local v5 = v[p]

	if not v5 then
		return
	end

	v5.destroyed = true
	v[p] = nil
	unregisterStand(v5)
	StandBuilder.clear(v5)
end

local function onEmoteAdded(p)
	local v5 = v2[p.Name]

	if not v5 then
		return
	end

	for _, v6 in v5 do
		tryBuild(v6)
	end
end

local function onEmoteRemoved(p)
	local v5 = v2[p.Name]

	if not v5 then
		return
	end

	for _, v6 in v5 do
		if v6.emote ~= p then
			continue
		end

		v6.emote = nil
		local emote, rollIndex = pickEmote(v6, true)

		if emote then
			v6.emote = emote
			v6.rollIndex = rollIndex
			local buildId = v6.buildId
			task.spawn(StandBuilder.showEmote, v6, emote, buildId)
			updatePrompt(v6) -- equivalent call inferred; original call site unknown
		end

		if not v6.emote then
			StandBuilder.clear(v6)
		end
	end
end

local function refreshPrompts(p)
	for _, v5 in v do
		if not (v5.emote and (p == nil or v5.emote == p)) then
			continue
		end

		local prompt = v5.prompt
		local emote = v5.emote

		if not (prompt and emote) then
			continue
		end

		prompt.ObjectText = emote.Name
		local emote2 = emote
		local v7 = v5
		local prompt2 = prompt
		task.spawn(function()
			local playerOwns = RelicsBridge.playerOwns(emote2)

			if v7.prompt ~= prompt2 or v7.emote ~= emote2 then
				return
			end

			if playerOwns then
				prompt2.ActionText = "Open"
				return
			end

			local buyText = RelicsBridge.getBuyText(emote2)

			if v7.prompt == prompt2 and v7.emote == emote2 then
				prompt2.ActionText = buyText
			end
		end)
	end
end

local function onOwnershipChanged(p, p2: number)
	if p2 ~= Players.LocalPlayer.UserId then
		return
	end

	RelicsBridge.invalidateOwnership(p)
	refreshPrompts(p)
end

local function onPurchaseFinished(p, _: number, flag: boolean)
	if p ~= Players.LocalPlayer or not flag then
		return
	end

	RelicsBridge.invalidateOwnership(nil)

	for _, v5 in v do
		if not v5.emote then
			continue
		end

		local prompt = v5.prompt
		local emote = v5.emote

		if not (prompt and emote) then
			continue
		end

		prompt.ObjectText = emote.Name
		local emote2 = emote
		local v7 = v5
		local prompt2 = prompt
		task.spawn(function()
			local playerOwns = RelicsBridge.playerOwns(emote2)

			if v7.prompt ~= prompt2 or v7.emote ~= emote2 then
				return
			end

			if playerOwns then
				prompt2.ActionText = "Open"
				return
			end

			local buyText = RelicsBridge.getBuyText(emote2)

			if v7.prompt == prompt2 and v7.emote == emote2 then
				prompt2.ActionText = buyText
			end
		end)
	end
end

function EmoteStand.getStandTag()
	return "EmoteStand"
end

function EmoteStand.getDisplayedEmoteName(p)
	local v5 = v[p]
	local emote = v5 and v5.emote

	if emote then
		return emote.Name
	end

	return nil
end

FeatureManager.RegisterFeature(script.Name, {
	OnInit = function()
		if not isClient then
			return
		end

		CollectionService:GetInstanceAddedSignal("EmoteStand"):Connect(setupStand)
		CollectionService:GetInstanceRemovedSignal("EmoteStand"):Connect(teardownStand)
		MarketplaceService.PromptPurchaseFinished:Connect(onPurchaseFinished)
		MarketplaceService.PromptBundlePurchaseFinished:Connect(onPurchaseFinished)

		for _, v5 in CollectionService:GetTagged("EmoteStand") do
			setupStand(v5)
		end
	end,
	OnStart = function()
		if not isClient then
			return
		end

		local resolved = RelicsBridge.resolve(30)
		v4 = true

		if not resolved then
			logger:warn("RelicsXYZ module not found in ReplicatedStorage — stands disabled.")
			return
		end

		v3 = true
		RelicsBridge.connectEmoteAdded(onEmoteAdded)
		RelicsBridge.connectEmoteRemoved(onEmoteRemoved)
		RelicsBridge.connectOwnershipChanged(onOwnershipChanged)

		for _, v5 in v do
			tryBuild(v5)
		end
	end,
	OnUpdate = function()
		if not v3 then
			return
		end

		local now = os.clock()

		for _, v5 in v do
			if not (#v5.emoteNames > 1 and v5.nextRollClock <= now) then
				continue
			end

			v5.nextRollClock = now + v5.rollInterval
			rollStand(v5) -- equivalent call inferred; original call site unknown
		end
	end
})
return EmoteStand