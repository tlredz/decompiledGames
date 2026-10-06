local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local packages = ReplicatedStorage.Packages
local DataServiceTyped = require(packages.DataServiceTyped)
local AuditService = require(script.Parent.AuditService)
local TimeService = require(script.Parent.TimeService)
local GameFlags = require(ReplicatedStorage.GameFlags)
local Config = require(script.Parent.Config)
local dataServiceTyped = DataServiceTyped({
	template = {
		dataVersion = 8,
		balls = {},
		items = {},
		itemMigration = {
			version = 0,
			status = "pending",
			legacyBallCount = 0,
			migratedBallCount = 0
		},
		equipment = {
			Ball = nil,
			Skin = nil,
			KillEffect = nil,
			Emote = nil,
			Pose = nil
		},
		emoteWheelInitialized = false,
		auditLog = AuditService.empty(),
		stickers = {},
		coins = 0,
		diamonds = 0,
		tradeRequestsEnabled = false,
		settings = {
			musicEnabled = true,
			soundEffectsEnabled = true
		},
		exp = {
			total = 0,
			firstMatchDayKey = 0,
			dailyMatchXp = {
				dayKey = 0,
				amount = 0
			},
			sameOpponentMatches = {
				dayKey = 0,
				counts = {}
			}
		},
		levelRewards = {
			randomByLevel = {},
			grantedRandom = {},
			grantedRewards = {}
		},
		newbieChestProgress = {},
		tradeQualification = {
			firstJoinAt = 0,
			validMatchCount = 0,
			opponentMatchCounts = {}
		},
		adminCommandUsage = {},
		mailbox = {
			mails = {}
		},
		weeklyWins = {},
		weeklyRobuxSpent = {},
		matchStats = {
			Duel = {
				matches = 0,
				wins = 0,
				draws = 0
			},
			RPS = {
				matches = 0,
				wins = 0,
				draws = 0
			},
			TwoVTwo = {
				matches = 0,
				wins = 0,
				draws = 0
			}
		},
		winStreak = 0,
		maxWinStreak = 0,
		lastStreak = 0,
		duelCoinLimit = {
			dailyKey = 0,
			dailyEarned = 0,
			weeklyKey = 0,
			weeklyEarned = 0
		},
		robuxSpent = 0,
		hasClaimedNewbieFreeChest = false,
		hasClaimedNewbieFreeChestV2 = false,
		hasClaimedJoinGroupFreeChest = false,
		hasClaimedFirstRaceFreeChest = false,
		hasJoinedGameBefore = false,
		hasClaimedFriendInviteFreeChest = false,
		hasReceivedFriendInviteFreeChest = false,
		hasSeenSeatTutorial = false,
		dailyQuest = {
			dayKey = 0,
			progress = {},
			claimed = {}
		},
		checkIn = {
			progressDays = 0,
			lastDayKey = 0,
			claimed = {},
			hasEnteredLoop = false
		},
		onlineReward = {
			dayKey = 0,
			onlineSeconds = 0,
			claimed = {},
			notified = {}
		},
		updateLog = "",
		updateLogEntrySeen = false,
		vouchers = {},
		voucherExploitPenalty = nil,
		exploitCleanup = nil,
		serialRegistryPending = {},
		starterPack = {
			remainingSeconds = Config.misc.starterPackLimitHours * 3600,
			purchased = false
		},
		boothListings = {},
		boothTotalSold = 0,
		hasUnlockedTradingSign = false,
		hasBoughtFirstChargeBall = false,
		dailyDiamonds = {
			lastDayKey = 0,
			streak = 0
		},
		dailyDiamondDeal = {
			lastDayKey = 0,
			streak = 0
		},
		dailyShop = {
			dayKey = 0,
			slots = {},
			purchased = {}
		},
		expBoost = {
			multiplier = 1,
			remaining = 0,
			dayKey = 0
		},
		coinBoost = {
			multiplier = 1,
			remaining = 0,
			dayKey = 0
		},
		dailyFirstMatchDayKey = 0,
		diamondDraw = {
			period = 0,
			tickets = 0,
			contribution = 0,
			spendProgress = 0,
			checkedPeriod = 0
		},
		titles = {},
		equippedTitle = ""
	},
	useMock = RunService:IsStudio() and not GameFlags.studioOnly["读存档"]
})

local function countLegacyBalls(items)
	local count = 0

	for k, item in items do
		if not (typeof(k) == "string" and typeof(item) == "table" and typeof(item.cnId) == "string") then
			continue
		end

		count += 1
	end

	return count
end

local function makeMigratedBall(k: string, userId: number, data)
	local v2 = {
		instanceId = k,
		ownerUserId = userId,
		itemType = "Ball",
		itemId = data.cnId,
		tradable = data.allowTrade ~= false,
		canFusion = data.allowTrade ~= false,
		source = typeof(data.source) ~= "string" and "旧存档迁移" or data.source,
		obtainedAt = 0,
		locks = 0,
		metadata = 0
	}
	local obtainedAt

	if typeof(data.obtainedAt) == "number" then
		obtainedAt = data.obtainedAt
	else
		obtainedAt = os.time()
	end

	v2.obtainedAt = obtainedAt
	v2.locks = {}
	v2.metadata = {
		tradeCount = 0,
		lastTradedAt = nil
	}
	return v2
end

local function normalizeItems(items, userId: number)
	for k, item in items do
		if typeof(k) ~= "string" or typeof(item) ~= "table" or typeof(item.itemType) ~= "string" or typeof(item.itemId) ~= "string" then
			return false, "物品结构异常: " .. tostring(k)
		end
	end

	for k, item in items do
		item.instanceId = k
		item.ownerUserId = userId
		item.locks = typeof(item.locks) ~= "table" and {} or item.locks
		item.metadata = typeof(item.metadata) ~= "table" and {} or item.metadata
		item.metadata.tradeCount = typeof(item.metadata.tradeCount) ~= "number" and 0 or item.metadata.tradeCount

		if typeof(item.canFusion) ~= "boolean" then
			item.canFusion = item.tradable == true
		end
	end

	return true, nil
end

local function legacyMatchesItems(items, p)
	for k, item in items do
		if not (typeof(k) == "string" and typeof(item) == "table" and typeof(item.cnId) == "string") then
			continue
		end

		local v2 = p[k]

		if typeof(v2) ~= "table" or v2.itemType ~= "Ball" or v2.itemId ~= item.cnId then
			return false
		end
	end

	return true
end

local v2 = {
	[4] = true,
	[5] = true,
	[6] = true
}

local function normalizeEmoteWheel(state, p)
	local equipment = typeof(state.equipment) ~= "table" and {} or state.equipment
	local v4 = state.emoteWheelInitialized ~= true

	for i = 1, 8 do
		local v5 = "表情轮盘_" .. tostring(i)
		local v6 = "表情轮盘_飞行器_" .. tostring(i)
		local v7 = equipment[v5]
		local v8 = v7 == nil and typeof(equipment[v6]) == "string" and {
			kind = "flyer",
			id = equipment[v6]
		} or v7
		equipment[v6] = nil
		local v9 = false

		if typeof(v8) == "table" and typeof(v8.kind) == "string" and typeof(v8.id) == "string" then
			if v8.kind == "freeEmote" then
				v9 = not v2[i] and Config.freeEmote.byCnId[v8.id] ~= nil
			elseif v8.kind == "flyer" then
				local v10 = p[v8.id]

				if typeof(v10) == "table" then
					v9 = v10.itemType == "飞行器"
				else
					v9 = false
				end
			end
		end

		if not v9 then
			v8 = nil
		end

		if v8 == nil and v4 and not v2[i] then
			local v10 = Config.freeEmote.list[i]
			v8 = v10 and typeof(v10.cnId) == "string" and {
				kind = "freeEmote",
				id = v10.cnId
			} or nil
		end

		equipment[v5] = v8
	end

	state.equipment = equipment
	state.emoteWheelInitialized = true
end

if not RunService:IsServer() then
	return dataServiceTyped
end

AuditService.bind(dataServiceTyped.server)
local flag = false

-- equivalent calls inferred from this helper; original call sites unknown
local function installPrivateReplication(p)
	if flag then
		return
	end

	flag = true
	local networker = p.networker
	local fire = networker.fire

	function networker.fire(p2, p3, p4: string, ...)
		local clones = table.pack(...)

		if p4 == "load" and typeof(clones[1]) == "table" then
			local clone = table.clone(clones[1])
			clone.serialRegistryPending = nil
			clones[1] = clone
		elseif typeof(clones[1]) == "table" and clones[1][1] == "serialRegistryPending" then
			return
		end

		return fire(p2, p3, p4, table.unpack(clones, 1, clones.n))
	end
end

local function onPlayerInit(p, instance, state)
	installPrivateReplication(p) -- equivalent call inferred; original call site unknown

	if RunService:IsStudio() and instance.UserId == -1 then
		local ServerStorage = game:GetService("ServerStorage")
		local studioProfileSeeds = ServerStorage:FindFirstChild("StudioProfileSeeds")
		local playerMinus1 = studioProfileSeeds and studioProfileSeeds:FindFirstChild("PlayerMinus1")

		if playerMinus1 and playerMinus1:IsA("ModuleScript") then
			local HttpService = game:GetService("HttpService")
			local HttpService2 = game:GetService("HttpService")
			local jSONDecode = HttpService:JSONDecode(HttpService2:JSONEncode(require(playerMinus1)))

			for k, v3 in jSONDecode do
				state[k] = v3
			end

			state.exploitCleanup = jSONDecode.exploitCleanup
		end
	end

	local migrate, v3 = AuditService.migrate(state, TimeService.now())

	if not migrate then
		warn("[PlayerData] 审计迁移失败，旧流水已保留: " .. tostring(instance.UserId) .. " " .. tostring(v3))
	end

	local firstJoinAt

	if typeof(state.tradeQualification) == "table" then
		firstJoinAt = state.tradeQualification.firstJoinAt
	end

	local v4

	if state.hasJoinedGameBefore == true then
		v4 = true
	elseif typeof(firstJoinAt) == "number" then
		v4 = firstJoinAt > 0
	else
		v4 = false
	end

	instance:SetAttribute("UpdateLogSkipAutoOpen", state.updateLogEntrySeen ~= true and not v4)
	state.updateLogEntrySeen = true
	local v6 = typeof(state.balls) ~= "table" and {} or state.balls
	local items2 = typeof(state.items) ~= "table" and {} or state.items
	local v8 = countLegacyBalls(v6)
	local itemMigration = typeof(state.itemMigration) ~= "table" and {} or state.itemMigration
	local v10

	if itemMigration.version == 1 then
		v10 = itemMigration.status == "complete"
	else
		v10 = false
	end

	if v10 then
		local items, v11 = normalizeItems(items2, instance.UserId)

		if not items then
			itemMigration.status = "needsReview"
			itemMigration.version = 0
			warn("[PlayerData] 玩家 " .. instance.UserId .. " 的物品数据异常，已标记待核对: " .. tostring(v11))
		end
	else
		if next(items2) == nil then
			for k, v11 in v6 do
				if not (typeof(k) == "string" and typeof(v11) == "table" and typeof(v11.cnId) == "string") then
					continue
				end

				items2[k] = makeMigratedBall(k, instance.UserId, v11)
			end
		end

		local items, v11 = normalizeItems(items2, instance.UserId)
		local v12 = items and legacyMatchesItems(v6, items2)
		local v13 = items and not v12 and "旧 balls 与 items 的迁移对应关系不匹配" or v11

		if items and v12 then
			itemMigration = {
				version = 1,
				status = "complete",
				legacyBallCount = v8,
				migratedBallCount = v8
			}
		else
			warn("[PlayerData] 玩家 " .. instance.UserId .. " 的物品迁移校验失败，已保留旧 balls 数据: " .. tostring(v13))
			itemMigration = {
				version = 0,
				status = "needsReview",
				legacyBallCount = v8,
				migratedBallCount = 0
			}
		end
	end

	state.items = items2
	state.itemMigration = itemMigration
	normalizeEmoteWheel(state, items2)
	state.tradeRequestsEnabled = typeof(state.tradeRequestsEnabled) ~= "boolean" or state.tradeRequestsEnabled
	state.settings = typeof(state.settings) ~= "table" and {} or state.settings
	state.settings.musicEnabled = typeof(state.settings.musicEnabled) ~= "boolean" or state.settings.musicEnabled
	state.settings.soundEffectsEnabled = typeof(state.settings.soundEffectsEnabled) ~= "boolean" or state.settings.soundEffectsEnabled
	state.tradeQualification = typeof(state.tradeQualification) ~= "table" and {} or state.tradeQualification
	local tradeQualification = state.tradeQualification
	local firstJoinAt2

	if typeof(state.tradeQualification.firstJoinAt) == "number" and state.tradeQualification.firstJoinAt > 0 then
		firstJoinAt2 = state.tradeQualification.firstJoinAt
	else
		firstJoinAt2 = TimeService.now()
	end

	tradeQualification.firstJoinAt = firstJoinAt2
	state.tradeQualification.validMatchCount = typeof(state.tradeQualification.validMatchCount) ~= "number" and 0 or math.max(
		0,
		(math.floor(state.tradeQualification.validMatchCount))
	)
	local v12 = typeof(state.tradeQualification.opponentMatchCounts) ~= "table" and {} or state.tradeQualification.opponentMatchCounts
	local opponentMatchCounts = {}

	for k, v14 in pairs(v12) do
		if not (typeof(k) == "string" and typeof(v14) == "number" and v14 > 0) then
			continue
		end

		opponentMatchCounts[k] = math.min(3, (math.floor(v14)))
	end

	state.tradeQualification.opponentMatchCounts = opponentMatchCounts
	state.exp = typeof(state.exp) ~= "table" and {} or state.exp
	state.exp.total = typeof(state.exp.total) ~= "number" and 0 or math.max(0, (math.floor(state.exp.total)))
	state.exp.firstMatchDayKey = typeof(state.exp.firstMatchDayKey) ~= "number" and 0 or state.exp.firstMatchDayKey
	state.exp.dailyMatchXp = typeof(state.exp.dailyMatchXp) ~= "table" and {} or state.exp.dailyMatchXp
	state.exp.dailyMatchXp.dayKey = typeof(state.exp.dailyMatchXp.dayKey) ~= "number" and 0 or state.exp.dailyMatchXp.dayKey
	state.exp.dailyMatchXp.amount = typeof(state.exp.dailyMatchXp.amount) ~= "number" and 0 or math.max(
		0,
		(math.floor(state.exp.dailyMatchXp.amount))
	)
	state.exp.sameOpponentMatches = typeof(state.exp.sameOpponentMatches) ~= "table" and {} or state.exp.sameOpponentMatches
	state.exp.sameOpponentMatches.dayKey = typeof(state.exp.sameOpponentMatches.dayKey) ~= "number" and 0 or state.exp.sameOpponentMatches.dayKey
	local v14 = typeof(state.exp.sameOpponentMatches.counts) ~= "table" and {} or state.exp.sameOpponentMatches.counts
	local counts = {}

	for k, v16 in pairs(v14) do
		if not (typeof(k) == "string" and typeof(v16) == "number" and v16 >= 0) then
			continue
		end

		counts[k] = math.floor(v16)
	end

	state.exp.sameOpponentMatches.counts = counts
	local LevelRewardRules = require(script.Parent.LevelRewardRules)
	state.levelRewards = LevelRewardRules.normalizeState(state.levelRewards)
	state.newbieChestProgress = typeof(state.newbieChestProgress) ~= "table" and {} or state.newbieChestProgress
	state.dailyDiamondDeal = typeof(state.dailyDiamondDeal) ~= "table" and {} or state.dailyDiamondDeal
	state.dailyDiamondDeal.lastDayKey = typeof(state.dailyDiamondDeal.lastDayKey) ~= "number" and 0 or math.max(
		0,
		(math.floor(state.dailyDiamondDeal.lastDayKey))
	)
	state.dailyDiamondDeal.streak = typeof(state.dailyDiamondDeal.streak) ~= "number" and 0 or math.clamp(
		math.floor(state.dailyDiamondDeal.streak),
		0,
		7
	)
	state.dailyShop = typeof(state.dailyShop) ~= "table" and {} or state.dailyShop
	state.dailyShop.dayKey = typeof(state.dailyShop.dayKey) ~= "number" and 0 or state.dailyShop.dayKey
	state.dailyShop.slots = typeof(state.dailyShop.slots) ~= "table" and {} or state.dailyShop.slots
	state.dailyShop.purchased = typeof(state.dailyShop.purchased) ~= "table" and {} or state.dailyShop.purchased
	local BoostService = require(script.Parent.BoostService)
	BoostService.preparePlayerData(state)
	state.dailyFirstMatchDayKey = typeof(state.dailyFirstMatchDayKey) ~= "number" and 0 or state.dailyFirstMatchDayKey
	state.diamondDraw = typeof(state.diamondDraw) ~= "table" and {} or state.diamondDraw

	for _, v16 in {
		"period",
		"tickets",
		"contribution",
		"spendProgress",
		"checkedPeriod"
	} do
		local v17 = state.diamondDraw[v16]
		state.diamondDraw[v16] = (typeof(v17) ~= "number" or not (v17 >= 0)) and 0 or v17
	end

	state.mailbox = typeof(state.mailbox) ~= "table" and {
		mails = {}
	} or state.mailbox
	state.mailbox.mails = typeof(state.mailbox.mails) ~= "table" and {} or state.mailbox.mails
	local v16 = typeof(state.titles) ~= "table" and {} or state.titles
	local titles = {}

	for k, v18 in pairs(v16) do
		if typeof(k) == "string" and v18 == true then
			titles[k] = true
		end
	end

	state.titles = titles
	state.equippedTitle = (typeof(state.equippedTitle) ~= "string" or not titles[state.equippedTitle]) and "" or state.equippedTitle
	state.dataVersion = 8
end

dataServiceTyped.server.Service.onPlayerInit = onPlayerInit
return dataServiceTyped