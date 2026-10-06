local v = {
	Version = 1,
	MaximumFieldLength = 50,
	StaffRank = 199,
	DaySeconds = 86400,
	RetentionDays = 7,
	ClientBatchSize = 40,
	ClientFlushInterval = 30,
	ClientMinimumInterval = 6,
	ClientPollInterval = 0.5,
	RelayCooldown = 5,
	MaximumLoadDuration = 180,
	IdleThreshold = 60,
	IdleCheckInterval = 5,
	MaximumScreenOpens = 100,
	MaximumDialogs = 20,
	MaximumCampaignLength = 20,
	OnboardingLevel = 5,
	MaximumRarePulls = 20,
	MaximumChases = 20,
	RareRank = 6,
	ContextualWindow = 30,
	WallWindow = 10,
	UpsellWindow = 600,
	ShopOriginWindow = 600,
	UpsellCooldown = 60,
	MaximumReceiptFailures = 20,
	LevelMilestones = {
		5,
		10,
		15,
		20,
		25,
		30,
		40,
		50,
		60,
		75,
		90,
		100
	},
	ClientPerfInterval = 5,
	ServerPerfInterval = 60,
	MaximumErrors = 50,
	MaximumErrorSystems = 8,
	Platforms = {
		Computer = true,
		Mobile = true,
		Console = true
	},
	AutomationSettings = { "Auto Attack", "Auto Clicker" },
	Onboarding = {
		"FirstJoin",
		"CharacterSpawned",
		"FirstKill",
		"FirstStarOpened",
		"FirstMainQuestAccepted",
		"FirstTimeReward",
		"ReachedLevel5",
		"FirstMainQuestCompleted",
		"FirstMainQuestClaimed",
		"FirstGamemodeJoined",
		"FirstGamemodeFinished",
		"SecondSession"
	},
	Rarities = {
		"Common",
		"Uncommon",
		"Rare",
		"Epic",
		"Legendary",
		"Mythical",
		"Secret",
		"Divine",
		"Exclusive"
	},
	Economy = {
		Currencies = {
			Yen = true,
			Gems = true
		},
		Tokens = {
			["Haki Token"] = true,
			["Cursed Token"] = true,
			["Trait Shard"] = true,
			["Breathing Token"] = true,
			["Slayer Token"] = true,
			["Stats Reset Token"] = true,
			["Adventurer Token"] = true,
			Gokumonkye = true
		},
		Origins = {
			Free = true,
			Paid = true,
			Mixed = true,
			None = true
		},
		TransactionTypes = {
			IAP = true,
			Shop = true,
			ContextualPurchase = true,
			Gameplay = true,
			TimedReward = true,
			Gacha = true,
			Sell = true,
			Reward = true,
			Gift = true,
			LiveOps = true,
			Guild = true,
			EntryFee = true,
			Upgrade = true,
			Admin = true,
			Unknown = true
		},
		Reasons = {
			EnemyDrop = {
				Type = "Gameplay"
			},
			FighterSell = {
				Type = "Sell"
			},
			AutoSell = {
				Type = "Sell"
			},
			StarOpen = {
				Type = "Gacha"
			},
			QuestReward = {
				Type = "Reward"
			},
			LevelReward = {
				Type = "Reward"
			},
			IndexReward = {
				Type = "Reward"
			},
			DailyReward = {
				Type = "TimedReward"
			},
			TimeReward = {
				Type = "TimedReward"
			},
			TimeChamberReward = {
				Type = "TimedReward"
			},
			TutorialReward = {
				Type = "Reward"
			},
			Inbox = {
				Type = "LiveOps"
			},
			Admin = {
				Type = "Admin"
			},
			GemPackPurchase = {
				Type = "IAP",
				Immediate = true
			},
			ShopPurchase = {
				Type = "Shop",
				Immediate = true
			},
			GiftPurchase = {
				Type = "Gift",
				Immediate = true
			},
			GiftClaim = {
				Type = "Gift",
				Immediate = true
			},
			Conversion = {
				Type = "ContextualPurchase"
			},
			GuildCreate = {
				Type = "Guild"
			},
			GuildDonate = {
				Type = "Guild"
			},
			GamemodeEntry = {
				Type = "EntryFee"
			},
			UpgradePurchase = {
				Type = "Upgrade"
			},
			GachaRoll = {
				Type = "Gacha"
			},
			TraitSpin = {
				Type = "Gacha"
			},
			BreathingSpin = {
				Type = "Gacha"
			},
			ProgressionUpgrade = {
				Type = "Upgrade"
			},
			StatsReset = {
				Type = "Upgrade"
			},
			Unknown = {
				Type = "Unknown"
			}
		}
	},
	Commerce = {
		Origins = {
			Hud = true,
			TimeChamber = true,
			GemBalance = true,
			RemoteAccess = true,
			External = true,
			Unknown = true
		},
		Sections = {
			Bundles = true,
			Gamepasses = true,
			["Gem Packs"] = true,
			None = true
		},
		Categories = {
			GemPack = true,
			Gamepass = true,
			Bundle = true
		},
		Payments = {
			Robux = true,
			Gems = true
		},
		Results = {
			Rejected = true,
			Cancelled = true,
			Success = true
		},
		Reasons = {
			Processing = "Processing",
			Unavailable = "Unavailable",
			Owned = "Owned",
			Purchased = "Limit",
			Expired = "Expired",
			["Sold Out"] = "SoldOut",
			["Pending inbox"] = "PendingInbox",
			["Not enough Gems"] = "InsufficientGems",
			["Not enough Paid Gems"] = "InsufficientPaidGems",
			["This purchase was already submitted. Refresh the shop."] = "Stale",
			["Refresh the shop and try again."] = "Stale",
			["The price changed. Refresh the shop and try again."] = "PriceChanged",
			["Check your inventory space and try again."] = "InventoryFull",
			["Your purchase is being saved and will be delivered automatically."] = "Saving",
			["Your purchase is being recovered. Please wait."] = "Error",
			Prompt = "Prompt"
		},
		ReceiptReasons = {
			Resetting = true,
			Cancelled = true,
			UnknownOffer = true,
			MissingSnapshot = true,
			PendingSave = true,
			Stock = true,
			Recipient = true,
			Transaction = true,
			Save = true,
			Error = true
		},
		Targets = {
			Self = true,
			Gift = true
		}
	},
	Content = {
		GamemodeReasons = {
			Completed = true,
			TimeUp = true,
			LivesOut = true,
			RoomFailed = true,
			SetupFailed = true,
			Closed = true,
			Empty = true,
			Disbanded = true
		},
		Sources = {
			Reward = true,
			Admin = true
		},
		QuestStates = {
			Unfinished = true,
			Unclaimed = true
		},
		MilestoneKinds = {
			Index = true,
			Achievement = true
		}
	},
	Social = {
		GuildActions = {
			Create = true,
			Invite = true,
			Join = true,
			Decline = true,
			Leave = true,
			Handover = true,
			Disband = true,
			Kick = true,
			Promote = true,
			Demote = true,
			Donate = true,
			Upgrade = true,
			Edit = true
		},
		PartyActions = {
			Create = true,
			Join = true,
			Leave = true,
			Kick = true,
			Start = true,
			Disband = true
		},
		TradeReasons = {
			Declined = true,
			Left = true
		},
		TradeStages = {
			Offering = true,
			Accepted = true
		},
		TradeResults = {
			Sent = true,
			Accepted = true,
			Expired = true
		},
		TradeSettlements = {
			Completed = true,
			Aborted = true,
			Pending = true,
			Rejected = true,
			Recovered = true,
			RecoveryFailed = true
		},
		TradeConflictStages = {
			Settle = true,
			Recovery = true
		},
		TradeCategories = {
			Fighters = true,
			Weapons = true,
			Mounts = true
		},
		CampaignKinds = {
			Weather = true,
			Announcement = true,
			Inbox = true
		},
		Scopes = {
			Global = true,
			Local = true
		}
	},
	Funnels = {
		ShopRobux = {
			Stages = {
				"OfferClicked",
				"PromptShown",
				"PromptAccepted",
				"Delivered"
			},
			Fields = { "Origin", "Kind", "Target" }
		},
		Upsell = {
			Stages = { "WallHit", "UpsellOpened", "Converted" },
			Fields = { "System", "Resource" }
		},
		MainStory = {
			Stages = { "Accepted", "Completed", "Claimed" }
		},
		Tutorial = {
			Stages = { "Completed" }
		}
	},
	Events = {
		DailyActive = {
			Fields = { "Visitor" }
		},
		NewPlayer = {
			Fields = { "Source" }
		},
		PlayerReturned = {
			Fields = { "Day", "Cohort" }
		},
		SessionEnded = {
			Fields = { "Session", "Tenure", "Platform" }
		},
		SessionSource = {
			Fields = { "Source", "Campaign", "Visitor" }
		},
		SessionExit = {
			Fields = { "Context", "Screen", "Onboarding" }
		},
		SessionActivity = {
			Fields = { "Automation", "Platform" }
		},
		ClientLoaded = {
			Fields = { "Platform", "Visitor" }
		},
		ScreenTime = {
			Fields = { "Screen" },
			Aggregate = true
		},
		ScreenOpens = {
			Fields = { "Screen" },
			Aggregate = true
		},
		NpcDialog = {
			Fields = { "Npc" },
			Aggregate = true
		},
		TokenFlow = {
			Fields = { "Token", "Reason", "Origin" },
			Aggregate = true
		},
		WallHit = {
			Fields = { "Wall", "System", "Resource" },
			Aggregate = true
		},
		RewardLost = {
			Fields = { "Source", "Kind", "Reason" },
			Aggregate = true
		},
		PityHit = {
			Fields = { "System", "Rarity" },
			Aggregate = true
		},
		GachaSession = {
			Fields = { "System", "Best", "Paid" }
		},
		RarePull = {
			Fields = { "System", "Rarity", "Trigger" }
		},
		ChaseReached = {
			Fields = { "System", "Target", "Rarity" }
		},
		TutorialAnswered = {
			Fields = { "Answer" }
		},
		TutorialSkipped = {
			Fields = { "Step" }
		},
		ShopOpened = {
			Fields = { "Origin", "Section" },
			Aggregate = true
		},
		ShopAttempt = {
			Fields = { "Payment", "Result", "Reason" },
			Aggregate = true
		},
		FirstRobuxPurchase = {
			Fields = { "Category", "Session", "Origin" }
		},
		FirstGemsPurchase = {
			Fields = { "Category", "Session", "Origin" }
		},
		ReceiptNotProcessed = {
			Fields = { "Reason", "Category" }
		},
		ReceiptRecovered = {
			Fields = { "Reason", "Category" }
		},
		GiftSent = {
			Fields = { "Category", "Payment" }
		},
		GiftClaimed = {
			Fields = { "Category" }
		},
		GamepassRevoked = {
			Fields = { "Pass" }
		},
		GamemodeEnded = {
			Fields = { "Gamemode", "Difficulty", "Outcome" }
		},
		GamemodeStage = {
			Fields = { "Gamemode", "Difficulty", "Outcome" }
		},
		GamemodeLeft = {
			Fields = { "Gamemode", "Difficulty", "Stage" }
		},
		BossKilled = {
			Fields = { "Boss", "Mode", "Group" }
		},
		LevelReached = {
			Fields = { "Level", "Prestige" }
		},
		PrestigeDone = {
			Fields = { "Prestige" }
		},
		MapUnlocked = {
			Fields = { "Map", "Source" }
		},
		MapVisited = {
			Fields = { "Map" }
		},
		QuestCompleted = {
			Fields = { "Class", "Quest" },
			Aggregate = true
		},
		QuestClaimed = {
			Fields = { "Class", "Quest" },
			Aggregate = true
		},
		QuestExpired = {
			Fields = { "Class", "Quest", "State" },
			Aggregate = true
		},
		MountObtained = {
			Fields = { "Mount", "Source" }
		},
		MountUsed = {
			Fields = { "Mount" },
			Aggregate = true
		},
		MilestoneClaimed = {
			Fields = { "Kind", "Name", "Step" },
			Aggregate = true
		},
		GuildAction = {
			Fields = { "Action", "Size", "Detail" }
		},
		PartyAction = {
			Fields = { "Action", "Gamemode", "Size" }
		},
		TradeCompleted = {
			Fields = { "Fairness", "Age", "Value" }
		},
		TradeCancelled = {
			Fields = { "Reason", "Stage" }
		},
		TradeRequest = {
			Fields = { "Result" },
			Aggregate = true
		},
		TradeSettlement = {
			Fields = { "Result" }
		},
		TradeGems = {
			Fields = { "Size" }
		},
		TradeItems = {
			Fields = { "Category" }
		},
		TradeConflict = {
			Fields = { "Stage", "Category" }
		},
		CampaignReceived = {
			Fields = { "Kind", "Name", "Scope" },
			Aggregate = true
		},
		ScriptErrors = {
			Fields = { "System", "Platform" },
			Aggregate = true
		},
		ClientPerf = {
			Fields = { "Platform", "Fps", "Ping" },
			Aggregate = true
		},
		ServerPerf = {
			Fields = { "ServerFps", "Memory", "Players" },
			Aggregate = true
		},
		ProfileLoad = {
			Fields = { "Result", "Visitor" }
		}
	},
	Buckets = {
		Session = {
			{
				Maximum = 1,
				Name = "1"
			},
			{
				Maximum = 2,
				Name = "2"
			},
			{
				Maximum = 5,
				Name = "3-5"
			},
			{
				Maximum = 10,
				Name = "6-10"
			},
			{
				Maximum = 1e999,
				Name = "11+"
			}
		},
		Tenure = {
			{
				Maximum = 0,
				Name = "D0"
			},
			{
				Maximum = 1,
				Name = "D1"
			},
			{
				Maximum = 7,
				Name = "D2-7"
			},
			{
				Maximum = 30,
				Name = "D8-30"
			},
			{
				Maximum = 1e999,
				Name = "D31+"
			}
		},
		Automation = {
			{
				Maximum = 0,
				Name = "0%"
			},
			{
				Maximum = 25,
				Name = "1-25%"
			},
			{
				Maximum = 75,
				Name = "26-75%"
			},
			{
				Maximum = 1e999,
				Name = "76-100%"
			}
		},
		Share = {
			{
				Maximum = 0,
				Name = "0%"
			},
			{
				Maximum = 25,
				Name = "1-25%"
			},
			{
				Maximum = 75,
				Name = "26-75%"
			},
			{
				Maximum = 1e999,
				Name = "76-100%"
			}
		},
		Level = {
			{
				Maximum = 10,
				Name = "1-10"
			},
			{
				Maximum = 25,
				Name = "11-25"
			},
			{
				Maximum = 50,
				Name = "26-50"
			},
			{
				Maximum = 75,
				Name = "51-75"
			},
			{
				Maximum = 1e999,
				Name = "76-100"
			}
		},
		Group = {
			{
				Maximum = 1,
				Name = "1"
			},
			{
				Maximum = 2,
				Name = "2"
			},
			{
				Maximum = 4,
				Name = "3-4"
			},
			{
				Maximum = 1e999,
				Name = "5+"
			}
		},
		Members = {
			{
				Maximum = 1,
				Name = "1"
			},
			{
				Maximum = 5,
				Name = "2-5"
			},
			{
				Maximum = 10,
				Name = "6-10"
			},
			{
				Maximum = 20,
				Name = "11-20"
			},
			{
				Maximum = 1e999,
				Name = "21+"
			}
		},
		Stage = {
			{
				Maximum = 0,
				Name = "0%"
			},
			{
				Maximum = 25,
				Name = "1-25%"
			},
			{
				Maximum = 50,
				Name = "26-50%"
			},
			{
				Maximum = 75,
				Name = "51-75%"
			},
			{
				Maximum = 99,
				Name = "76-99%"
			},
			{
				Maximum = 1e999,
				Name = "100%"
			}
		},
		AccountAge = {
			{
				Maximum = 6,
				Name = "<7d"
			},
			{
				Maximum = 30,
				Name = "7-30d"
			},
			{
				Maximum = 180,
				Name = "31-180d"
			},
			{
				Maximum = 1e999,
				Name = "180d+"
			}
		},
		TradeValue = {
			{
				Maximum = 999,
				Name = "<1K"
			},
			{
				Maximum = 9999,
				Name = "1K-10K"
			},
			{
				Maximum = 99999,
				Name = "10K-100K"
			},
			{
				Maximum = 999999,
				Name = "100K-1M"
			},
			{
				Maximum = 1e999,
				Name = "1M+"
			}
		},
		TradeGems = {
			{
				Maximum = 99,
				Name = "<100"
			},
			{
				Maximum = 999,
				Name = "100-1K"
			},
			{
				Maximum = 9999,
				Name = "1K-10K"
			},
			{
				Maximum = 99999,
				Name = "10K-100K"
			},
			{
				Maximum = 1e999,
				Name = "100K+"
			}
		},
		Fps = {
			{
				Maximum = 19,
				Name = "<20"
			},
			{
				Maximum = 29,
				Name = "20-29"
			},
			{
				Maximum = 44,
				Name = "30-44"
			},
			{
				Maximum = 59,
				Name = "45-59"
			},
			{
				Maximum = 1e999,
				Name = "60+"
			}
		},
		Ping = {
			{
				Maximum = 99,
				Name = "<100"
			},
			{
				Maximum = 199,
				Name = "100-199"
			},
			{
				Maximum = 399,
				Name = "200-399"
			},
			{
				Maximum = 1e999,
				Name = "400+"
			}
		},
		ServerFps = {
			{
				Maximum = 19,
				Name = "<20"
			},
			{
				Maximum = 39,
				Name = "20-39"
			},
			{
				Maximum = 54,
				Name = "40-54"
			},
			{
				Maximum = 1e999,
				Name = "55+"
			}
		},
		Memory = {
			{
				Maximum = 999,
				Name = "<1000"
			},
			{
				Maximum = 1999,
				Name = "1000-1999"
			},
			{
				Maximum = 2999,
				Name = "2000-2999"
			},
			{
				Maximum = 1e999,
				Name = "3000+"
			}
		}
	}
}

-- equivalent calls inferred from this helper; original call sites unknown
local function IsFinite(value)
	return typeof(value) == "number" and math.isfinite(value)
end

local function NormalizeList(fields, p, flag: boolean)
	local result = {}

	if not fields then
		return result
	end

	for k, item in fields do
		local v2

		if typeof(p) == "table" then
			v2 = p[item]
		end

		if flag and typeof(v2) == "number" then
			local v3

			if typeof(v2) == "number" then
				v3 = math.isfinite(v2)
			else
				v3 = false
			end

			if v3 then
				v2 = tostring(v2)
			end
		end

		if v2 == nil then
			result[k] = ""
		elseif typeof(v2) == "string" and v2 ~= "" then
			result[k] = string.sub(string.gsub(v2, "|", "/"), 1, v.MaximumFieldLength)
		else
			return nil
		end
	end

	return result
end

function v.IsFinite(value)
	return IsFinite(value)
end

function v.GetDay(p: number)
	return (math.floor(p / v.DaySeconds))
end

function v.GetBucket(p: string, value: number)
	local bucket = v.Buckets[p]

	if not bucket then
		return nil
	end

	local v2

	if typeof(value) == "number" then
		v2 = math.isfinite(value)
	else
		v2 = false
	end

	if not v2 then
		return nil
	end

	for _, v3 in bucket do
		if value <= v3.Maximum then
			return v3.Name
		end
	end

	return nil
end

function v.GetEvent(value: string)
	if typeof(value) == "string" then
		return v.Events[value]
	end

	return nil
end

function v.NormalizeFields(p: string, p2)
	local event = v.GetEvent(p)

	if event then
		return (NormalizeList(event.Fields, p2, true))
	end

	return nil
end

function v.NormalizeFunnelFields(p: string, p2)
	local funnel = v.Funnels[p]

	if funnel then
		return (NormalizeList(funnel.Fields, p2, false))
	end

	return nil
end

function v.BuildKey(items)
	local v2 = {}

	for k, item in items do
		v2[k] = string.gsub(tostring(item), "|", "/")
	end

	return table.concat(v2, "|")
end

function v.GetFunnelStep(p: string, p2: string)
	local funnel = v.Funnels[p]
	return funnel and table.find(funnel.Stages, p2)
end

function v.GetCommerceCategory(value)
	if typeof(value) == "string" and v.Commerce.Categories[value] then
		return value
	end

	return "Other"
end

function v.GetCommerceReason(value)
	return typeof(value) == "string" and v.Commerce.Reasons[value] or "Other"
end

function v.GetShopOrigin(value)
	if typeof(value) == "string" and v.Commerce.Origins[value] then
		return value
	end

	return "Unknown"
end

function v.IsBucketName(p: string, value)
	local bucket = v.Buckets[p]

	if not bucket or typeof(value) ~= "string" then
		return false
	end

	for _, v2 in bucket do
		if v2.Name == value then
			return true
		end
	end

	return false
end

function v.GetStagePercent(value, value2)
	local v2

	if typeof(value) == "number" then
		v2 = math.isfinite(value)
	else
		v2 = false
	end

	if not v2 then
		return 0
	end

	local v3

	if typeof(value2) == "number" then
		v3 = math.isfinite(value2)
	else
		v3 = false
	end

	if v3 and not (value2 <= 0) then
		return (math.clamp(math.floor(100 * value / value2), 0, 100))
	end

	return 0
end

function v.GetCrossedMilestones(p: number, p2: number)
	local levelMilestones = {}

	for _, levelMilestone in v.LevelMilestones do
		if p < levelMilestone and levelMilestone <= p2 then
			table.insert(levelMilestones, levelMilestone)
		end
	end

	return levelMilestones
end

function v.GetOnboardingStep(p: string)
	return table.find(v.Onboarding, p)
end

function v.GetMainStoryStep(value: number, p: string)
	local stages = v.Funnels.MainStory.Stages
	local index = table.find(stages, p)

	if not index then
		return nil
	end

	local v2

	if typeof(value) == "number" then
		v2 = math.isfinite(value)
	else
		v2 = false
	end

	if v2 and not (value < 1) then
		return (math.floor(value) - 1) * #stages + index
	end

	return nil
end

function v.SanitizeName(value: string)
	return (string.sub(string.gsub(value, "[,\"'\r\n]", ""), 1, v.MaximumFieldLength))
end

function v.GetRarityRank(p: string?)
	return table.find(v.Rarities, p) or 0
end

function v.GetOrigin(value: number?, value2: number?)
	local v2

	if typeof(value) == "number" then
		v2 = value > 0
	else
		v2 = false
	end

	local v3

	if typeof(value2) == "number" then
		v3 = value2 > 0
	else
		v3 = false
	end

	if v2 and v3 then
		return "Mixed"
	end

	if v3 then
		return "Paid"
	end

	if v2 then
		return "Free"
	end

	return "None"
end

function v.GetEconomyReason(value: string?)
	local selected

	if typeof(value) == "string" then
		selected = v.Economy.Reasons[value]
	else
		selected = false
	end

	if selected then
		return value, selected
	end

	return "Unknown", v.Economy.Reasons.Unknown
end

function v.SanitizeCampaign(value)
	if typeof(value) ~= "string" or value == "" then
		return "None"
	end

	if #value > v.MaximumCampaignLength then
		return "Other"
	end

	if string.match(value, "^[%w_%-]+$") then
		return value
	end

	return "Other"
end

function v.MirrorRobuxSpent(p)
	local analytics = p.Analytics
	local stats = p.Profile and p.Profile.Stats

	if typeof(analytics) ~= "table" or typeof(stats) ~= "table" then
		return
	end

	local robuxSpent = analytics.RobuxSpent
	local v2

	if typeof(robuxSpent) == "number" then
		v2 = math.isfinite(robuxSpent)
	else
		v2 = false
	end

	if not v2 or analytics.RobuxSpent <= 0 then
		return
	end

	stats["Robux Spent"] = analytics.RobuxSpent
end

function v.ApplyRobuxPurchase(p, value: number?, firstPurchaseTime: number)
	local analytics = p.Analytics

	if typeof(analytics) ~= "table" then
		return false
	end

	local v3 = not (IsFinite(value) and value > 0) and 0 or math.floor(value)
	local selected = analytics.FirstPurchaseTime == 0
	analytics.RobuxSpent += v3
	analytics.PurchaseCount += 1

	if selected then
		analytics.FirstPurchaseTime = firstPurchaseTime
	end

	v.MirrorRobuxSpent(p)
	return selected
end

function v:NormalizeData(p)
	local analytics = self.Analytics

	if typeof(analytics) ~= "table" then
		return
	end

	v.MirrorRobuxSpent(self)

	if analytics.ActivatedAt ~= 0 then
		return
	end

	local now = os.time()
	local firstJoinTime = self.FirstJoinTime
	local v2 = not p and 0 or p.FirstSessionTime or 0
	local sessionLoadCount = p and p.SessionLoadCount or 0
	local stats = self.Profile and self.Profile.Stats
	local timePlayed = stats and stats["Time Played"] or 0
	local v3

	if typeof(firstJoinTime) == "number" then
		v3 = math.isfinite(firstJoinTime)
	else
		v3 = false
	end

	if v3 and firstJoinTime > 0 then
		analytics.FirstJoinTime = math.floor(firstJoinTime)
	else
		local v4

		if typeof(v2) == "number" then
			v4 = math.isfinite(v2)
		else
			v4 = false
		end

		if v4 and v2 > 0 then
			analytics.FirstJoinTime = math.floor(v2)
		else
			analytics.FirstJoinTime = now
		end
	end

	analytics.OnboardingEligible = firstJoinTime == nil and (sessionLoadCount <= 1 or timePlayed == 0)
	analytics.ActivatedAt = now
	analytics.Version = v.Version
	self.FirstJoinTime = nil
end

return table.freeze(v)