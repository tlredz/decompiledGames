local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")
local ContentProvider = game:GetService("ContentProvider")
local Players = game:GetService("Players")
local tweenInfo = TweenInfo.new(0.12, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(0.5, Enum.EasingStyle.Quad)
local tweenInfo3 = TweenInfo.new(0.25)
local tweenInfo4 = TweenInfo.new(0.1, Enum.EasingStyle.Quad)
local tweenInfo5 = TweenInfo.new(0.3)
local tweenInfo6 = TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo7 = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local tweenInfo8 = TweenInfo.new(0.3)
local tweenInfo9 = TweenInfo.new(0.08, Enum.EasingStyle.Back)
local tweenInfo10 = TweenInfo.new(0.4)
local tweenInfo11 = TweenInfo.new(0.2, Enum.EasingStyle.Quad)
local tweenInfo12 = TweenInfo.new(0.2)
local tweenInfo13 = TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local tweenInfo14 = TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
TweenInfo.new(0.4)
local tweenInfo15 = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local tweenInfo16 = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo17 = TweenInfo.new(0.2)
local v = {
	image = "rbxassetid://82317421402458",
	color = Color3.fromRGB(255, 120, 40),
	size = UDim2.fromScale(0.6, 0.6),
	rotation = 180
}
local v2 = {
	image = "rbxassetid://139495386833064",
	color = Color3.fromRGB(255, 220, 80),
	size = UDim2.fromScale(0.45, 0.45),
	rotation = 180
}
local v3 = {
	image = "rbxassetid://82463301279786",
	color = Color3.fromRGB(220, 40, 40),
	size = UDim2.fromScale(0.55, 0.55),
	rotation = 0
}
local v4 = {
	image = "rbxassetid://82317421402458",
	color = Color3.fromRGB(30, 120, 200),
	size = UDim2.fromScale(0.6, 0.6),
	rotation = 180
}
local v5 = {
	image = "rbxassetid://13771592635",
	color = Color3.fromRGB(255, 255, 100),
	size = UDim2.fromScale(0.7, 0.7),
	rotation = 0
}
local v6 = {
	image = "rbxassetid://12159555294",
	color = Color3.fromRGB(140, 50, 200),
	size = UDim2.fromScale(0.5, 0.5),
	rotation = 0
}
local v7 = {
	image = "rbxassetid://12159555294",
	color = Color3.fromRGB(255, 200, 40),
	size = UDim2.fromScale(0.55, 0.55),
	rotation = 0
}
local v8 = { v, v2, v3 }
local v9 = {
	v,
	v3,
	v4,
	v5,
	v6,
	v7
}
local fish = require(ReplicatedStorage.shared.modules.library.fish)
local rarities = require(ReplicatedStorage.shared.modules.library.rarities)
local SettingsController = require(ReplicatedStorage.client.legacyControllers.SettingsController)
local CompanionController = require(ReplicatedStorage.client.legacyControllers.CompanionController)
local DataController = require(ReplicatedStorage.client.legacyControllers.DataController)
local Net = require(ReplicatedStorage.packages.Net)
local Input = require(ReplicatedStorage.packages.Input)
local playerDataReplicator = DataController.PlayerDataReplicator
local module = require("./PassiveHandler")
local parentModule = require(script.Parent)
local HardChartUserIds = require(script:WaitForChild("HardChartUserIds"))

local function getChartData(childName: string)
	local child = script:FindFirstChild(childName)

	if not child then
		return nil
	end

	local module2 = require(child)
	return module2
end

local fishing = ReplicatedStorage.resources.sounds.sfx.fishing
local slashes = fishing.slashes
local ui = ReplicatedStorage.resources.sounds.sfx.ui
local v10 = {
	SpecialChartChance = 1,
	SpecialChartSpeed = 1,
	MobileLaneScale = 1.5,
	DefaultAttackCooldown = 8,
	DefaultAttackChance = 15,
	AttackChanceEscalation = 15,
	EnchantNoteCooldownScale = 1
}

local function resolveConfig(config)
	local clone = table.clone(v10)

	if config then
		for k, item in config do
			if clone[k] ~= nil and typeof(item) == "number" then
				clone[k] = item
			end
		end
	end

	return clone
end

local TranquilityRod = {}
local _ = {
	Miss = 15,
	WrongKey = 5,
	Perfect = -0.5
}
local remoteEvent = Net:RemoteEvent("TranquilityRod/AccuracyUpdate")
local remoteEvent2 = Net:RemoteEvent("TranquilityRod/AccuracyReset")
local v11 = {}
local flag = false
local v12 = nil
local v13 = false
Net:Connect("TranquilityRod/ForceChart", function(value: string)
	if value == "clear" then
		v12 = nil
		v13 = false
	elseif value:match("^full_") then
		v12 = value:sub(6)
		v13 = true
	else
		v12 = value
		v13 = false
	end
end)

local function loadAccuracyHistory()
	if flag then
		return
	end

	flag = true
	playerDataReplicator:WaitForLoaded()
	local v14 = playerDataReplicator:TryIndex({ "TranquilityAccuracy" })

	if typeof(v14) == "table" then
		for _, v15 in v14 do
			if typeof(v15) == "boolean" then
				table.insert(v11, v15)
			end
		end
	end
end

task.spawn(loadAccuracyHistory)
Net:Connect("TranquilityRod/AccuracySync", function(items)
	if typeof(items) ~= "table" then
		return
	end

	table.clear(v11)

	for _, item in items do
		if typeof(item) == "boolean" then
			table.insert(v11, item)
		end
	end
end)
local tranquilityRodRhythmGame = script:WaitForChild("TranquilityRodRhythmGame")
local tranquilityRodRhythmGameUpsScroll = script:FindFirstChild("TranquilityRodRhythmGameUpsScroll")
local customreels = ReplicatedStorage.resources.replicated.fishing.customreels

local function resolveSkinTemplate(childName: string?)
	if not childName then
		return nil
	end

	local screenGui = script:FindFirstChild(childName) or customreels:FindFirstChild(childName)

	if screenGui and screenGui:IsA("ScreenGui") then
		return screenGui
	end

	return nil
end

local v14 = {
	text = "SICK!!",
	color = Color3.fromRGB(0, 255, 200)
}
local v15 = {
	text = "Good!",
	color = Color3.fromRGB(50, 200, 50)
}
local v16 = {
	text = "Bad",
	color = Color3.fromRGB(200, 150, 50)
}
local v17 = {
	text = "MISS",
	color = Color3.fromRGB(255, 50, 50)
}
local rating = {
	text = "STAB!",
	color = Color3.fromRGB(255, 170, 0)
}
local rating2 = {
	text = "FREEZE!",
	color = Color3.fromRGB(100, 200, 255)
}
local rating3 = {
	text = "CHOMP!",
	color = Color3.fromRGB(255, 170, 60)
}
local rating4 = {
	text = "SPLASH!",
	color = Color3.fromRGB(120, 220, 160)
}
local rating5 = {
	text = "TREASURE!",
	color = Color3.fromRGB(255, 215, 90)
}
local v23 = {
	Chaotic = {
		effectType = "stab",
		progressBonus = 6,
		stunTime = 0.35,
		cooldown = 5,
		color = Color3.fromRGB(255, 70, 255),
		rating = rating
	},
	Piercing = {
		effectType = "stab",
		progressBonus = 6,
		stunTime = 0.35,
		cooldown = 4,
		color = Color3.fromRGB(200, 50, 50),
		rating = rating
	},
	Spooky = {
		effectType = "stab",
		progressBonus = 3,
		stunTime = 0.25,
		cooldown = 3,
		color = Color3.fromRGB(220, 151, 81),
		rating = rating
	},
	Peppermint = {
		effectType = "stab",
		progressBonus = 1,
		stunTime = 0.1,
		cooldown = 2.5,
		color = Color3.fromRGB(255, 100, 100),
		rating = rating
	},
	Rage = {
		effectType = "stab",
		progressBonus = 8,
		stunTime = 0.25,
		cooldown = 4.5,
		color = Color3.fromRGB(180, 30, 30),
		rating = rating
	}
}
local v24 = {
	Chronos = Color3.fromRGB(29, 84, 211),
	Cryogenic = Color3.fromRGB(148, 235, 255)
}

local function deriveStabEffect(config)
	local slashDamage = tonumber(config.SlashDamage) or 5
	local slashChance = tonumber(config.SlashChance) or 30
	local v25 = {
		effectType = "stab",
		progressBonus = slashDamage,
		stunTime = tonumber(config.StunTime) or 0.25,
		cooldown = math.clamp(2 + slashDamage * 0.35 + (30 - slashChance) * 0.05, 2.5, 8),
		color = 0,
		rating = 0
	}
	local color

	if typeof(config.IconColor) == "Color3" then
		color = config.IconColor
	else
		color = rating.color
	end

	v25.color = color
	v25.rating = rating
	return v25
end

local function deriveFreezeEffect(passiveName: string, config)
	local freezeDuration = math.min(tonumber(config.FreezeDuration) or 3, 5)
	local v26 = math.clamp(tonumber(config.FreezeChance) or 50, 1, 100) / 100
	local cooldown

	if passiveName == "Cryogenic" then
		cooldown = math.clamp((tonumber(config.AttemptDelay) or 1) / v26 * 1.6, 4, 10)
	else
		cooldown = math.clamp((tonumber(config.FreezeCooldown) or 3) / v26 * 1.2, 3, 10)
	end

	return {
		effectType = "freeze",
		progressBonus = math.floor(math.min(freezeDuration * 0.4 + 1, 4) + 0.5),
		freezeDuration = freezeDuration,
		regenPerSecond = math.clamp(freezeDuration * 0.2 + 0.2, 0.3, 1),
		cooldown = cooldown,
		color = v24[passiveName] or rating2.color,
		rating = rating2
	}
end

local v25 = {
	PenguinPal_Freezing = function(data)
		local v26 = math.clamp(tonumber(data.TriggerChance) or 15, 1, 100) / 100
		local freezeDuration = math.min(tonumber(data.Duration) or 4, 5)
		return {
			effectType = "freeze",
			progressBonus = math.floor(math.min(freezeDuration * 0.4 + 1, 4) + 0.5),
			freezeDuration = freezeDuration,
			regenPerSecond = math.clamp(freezeDuration * 0.2 + 0.2, 0.3, 1),
			cooldown = math.clamp((tonumber(data.AttemptInterval) or 4) / v26 * 0.4, 8, 16),
			color = Color3.fromRGB(140, 210, 255),
			rating = rating2
		}
	end,
	JawConstriction = function(data)
		local v26 = math.clamp(tonumber(data.TriggerChance) or 10, 1, 100) / 100
		local freezeDuration = math.min(tonumber(data.Duration) or 5, 5)
		local progressSpeedMin = tonumber(data.ProgressSpeedMin) or 0
		return {
			effectType = "freeze",
			progressBonus = math.floor(math.min(freezeDuration * 0.4 + 1, 4) + 0.5),
			freezeDuration = freezeDuration,
			regenPerSecond = math.clamp(0.3 + progressSpeedMin / 100, 0.3, 1),
			cooldown = math.clamp((tonumber(data.AttemptInterval) or 5) / v26 * 0.4, 8, 16),
			color = Color3.fromRGB(255, 120, 120),
			rating = rating3
		}
	end,
	Mosswaddler_Distraction = function(data)
		local v26 = math.clamp(tonumber(data.TriggerChance) or 20, 1, 100) / 100
		return {
			effectType = "stab",
			progressBonus = 3,
			stunTime = math.min(tonumber(data.Duration) or 3, 3),
			cooldown = math.clamp((tonumber(data.AttemptInterval) or 5) / v26 * 0.4, 6, 14),
			color = Color3.fromRGB(109, 209, 92),
			rating = rating4
		}
	end,
	SillySeal_ClientFishBite = function(data)
		local midpoint = ((tonumber(data.BiteIntervalMin) or 1.5) + (tonumber(data.BiteIntervalMax) or 3)) / 2
		return {
			effectType = "stab",
			progressBonus = math.min(tonumber(data.BiteProgress) or 8, 10),
			stunTime = 0.2,
			cooldown = math.clamp(midpoint * 2.5, 4, 10),
			color = Color3.fromRGB(230, 242, 255),
			rating = rating3
		}
	end,
	GaryGator_Bites = function(data)
		local v26 = math.clamp(tonumber(data.MiniBiteChance) or 33, 1, 100) / 100
		local v27 = {
			effectType = "stab",
			progressBonus = math.min(tonumber(data.MiniBiteProgress) or 5, 10),
			stunTime = 0.2,
			cooldown = math.clamp((tonumber(data.MiniBiteInterval) or 5) / v26 * 0.4, 5, 12),
			color = 0,
			rating = 0
		}
		local color

		if typeof(data.MiniBiteColor) == "Color3" then
			color = data.MiniBiteColor
		else
			color = Color3.fromRGB(120, 220, 100)
		end

		v27.color = color
		v27.rating = rating3
		return v27
	end,
	OllieOtter_Attack = function(data)
		local v26 = math.clamp(tonumber(data.TriggerChance) or 35, 1, 100) / 100
		local midpoint = ((tonumber(data.IntervalMin) or 2) + (tonumber(data.IntervalMax) or 9)) / 2
		local v28 = {
			effectType = "stab",
			progressBonus = math.min(tonumber(data.AttackProgress) or 4, 10),
			stunTime = 0.2,
			cooldown = math.clamp(midpoint / v26 * 0.4, 4, 10),
			color = 0,
			rating = 0
		}
		local color

		if typeof(data.FlashColor) == "Color3" then
			color = data.FlashColor
		else
			color = Color3.fromRGB(150, 111, 74)
		end

		v28.color = color
		v28.rating = rating3
		return v28
	end,
	RelicConstruct_TwistedAttack = function(data)
		local v26 = math.clamp(tonumber(data.TriggerChance) or 25, 1, 100) / 100
		return {
			effectType = "stab",
			progressBonus = math.min(tonumber(data.ProgressBoost) or 3, 10),
			stunTime = 0.2,
			cooldown = math.clamp((tonumber(data.Interval) or 3) / v26 * 0.4, 4, 12),
			color = Color3.fromRGB(167, 100, 255),
			rating = rating
		}
	end
}
local v26 = {
	SillySeal_ClientFishBite = function(p, p2)
		local data = p2.data

		if not (data and data.SealActive) then
			return false
		end

		local name = tostring(p2.fish and p2.fish.Name or "")
		local v27 = fish[name]
		local biteBlacklist = p.BiteBlacklist

		if typeof(biteBlacklist) ~= "table" then
			return true
		end

		if typeof(biteBlacklist.Name) == "table" and table.find(biteBlacklist.Name, name) then
			return false
		end

		if v27 and typeof(biteBlacklist.Rarity) == "table" and table.find(biteBlacklist.Rarity, (tostring(v27.Rarity))) then
			return false
		end

		return true
	end
}
local v27 = {
	ScyllaBehavior = {
		attackType = "drain",
		drainRatio = 0.12,
		warningText = "BITE!"
	},
	MegalodonBehavior = {
		attackType = "burst",
		burstCount = 4,
		warningText = "RAMPAGE!"
	},
	LeviathanBehavior = {
		attackType = "speedup",
		speedMultiplier = 0.55,
		duration = 5,
		warningText = "WHIP!"
	},
	KrakenBehavior = {
		attackType = "lock",
		duration = 2.5,
		warningText = "GRAB!"
	},
	FrostwyrmBehavior = {
		attackType = "freeze",
		speedMultiplier = 2.2,
		windowShrink = 0.6,
		duration = 3,
		warningText = "FREEZE!"
	},
	MossjawBehavior = {
		attackType = "drain",
		drainRatio = 0.08,
		drainFlat = 3,
		warningText = "SNAP!"
	},
	ColossalDragonBehavior = {
		attackType = "fakeout",
		gainAmount = 8,
		lossDelay = 1.5,
		lossRatio = 0.2,
		warningText = "PULSE!"
	},
	BloopBehavior = {
		attackType = "escalate",
		escalateRate = 0.03,
		resetOnPerfect = true,
		warningText = "CHARGE!"
	},
	["Skeletal LeviathanBehavior"] = {
		attackType = "speedup",
		speedMultiplier = 0.5,
		duration = 4,
		drainPerSecond = 1.5,
		warningText = "WHIP!"
	},
	RadiantCrystalBehavior = {
		attackType = "shrink",
		shrinkRate = 0.005,
		resetOnPerfect = true,
		warningText = ""
	},
	WyvernBehavior = {
		attackType = "swoop",
		drainRatio = 0.12,
		speedMultiplier = 0.75,
		speedDuration = 2.5,
		warningText = "SWOOP!"
	},
	TerrosunderBehavior = {
		attackType = "burst",
		burstCount = 4,
		warningText = "ERUPT!"
	},
	KingCrabstleBehavior = {
		attackType = "lock",
		duration = 2.5,
		warningText = "PINCH!"
	},
	FlameslasherBehavior = {
		attackType = "speedup",
		speedMultiplier = 0.6,
		duration = 4,
		warningText = "SCORCH!"
	},
	VeiledCharybdisBehavior = {
		attackType = "lock",
		duration = 3,
		warningText = "WHIRLPOOL!"
	},
	SkolopendraBehavior = {
		attackType = "darkness",
		slashDrain = 4,
		warningText = "DARKNESS!"
	},
	OlympianDevilBehavior = {
		attackType = "olympian",
		warningText = "",
		phases = {
			{
				name = "Bellona",
				warningText = "BELLONA!",
				color = Color3.fromRGB(180, 30, 30),
				attackType = "burst",
				burstCount = 5
			},
			{
				name = "Zeus",
				warningText = "ZEUS!",
				color = Color3.fromRGB(255, 255, 100),
				attackType = "smite",
				smiteLanes = 2,
				smiteDrain = 10,
				smiteWarningTime = 0.8,
				smiteDuration = 0.4
			},
			{
				name = "Poseidon",
				warningText = "POSEIDON!",
				color = Color3.fromRGB(30, 140, 220),
				attackType = "wave",
				speedMultiplier = 0.5,
				speedDuration = 3,
				burstCount = 3
			},
			{
				name = "Hades",
				warningText = "HADES!",
				color = Color3.fromRGB(82, 255, 140),
				attackType = "wither",
				drainPerSecond = 5,
				speedMultiplier = 1.4,
				windowShrink = 0.7,
				duration = 4
			},
			{
				name = "Apollo",
				warningText = "APOLLO!",
				color = Color3.fromRGB(255, 200, 40),
				attackType = "radiance",
				burstCount = 4,
				speedMultiplier = 0.6,
				speedDuration = 3,
				missDrain = 4
			},
			{
				name = "Olympian Devil",
				warningText = "DIVINE WRATH!",
				color = Color3.fromRGB(191, 146, 255),
				attackType = "divineWrath",
				burstCount = 6,
				lockDuration = 3,
				drainRatio = 0.2,
				speedMultiplier = 0.55,
				speedDuration = 4
			}
		}
	}
}
local v28 = {
	attackType = "drain",
	drainRatio = 0.1,
	warningText = "ATTACK!"
}

local function getBehaviorEffect(p: string)
	return v27[p] or v28
end

local function singlePhaseOlympian(p: string)
	local olympianDevilBehavior = v27.OlympianDevilBehavior
	local phases = olympianDevilBehavior and olympianDevilBehavior.phases

	if not phases then
		return nil
	end

	for _, phas in phases do
		if phas.name == p then
			return {
				attackType = "olympian",
				warningText = "",
				phases = { phas }
			}
		end
	end

	return nil
end

local v29 = {
	BellonaGodFight = singlePhaseOlympian("Bellona"),
	ZeusGodFight = singlePhaseOlympian("Zeus"),
	PoseidonGodFight = singlePhaseOlympian("Poseidon"),
	HadesGodFight = singlePhaseOlympian("Hades"),
	ApolloGodFight = singlePhaseOlympian("Apollo")
}
local v30 = {
	freedomdive = {
		chartModule = "FreedomDiveChart",
		musicId = "rbxassetid://101804452888533",
		audioOffset = 2.133,
		overrides = {
			NOTE_FALL_TIME = 0.55,
			PERFECT_WINDOW = 0.04,
			GOOD_WINDOW = 0.075,
			OK_WINDOW = 0.12,
			MISS_PENALTY = -1.8,
			WRONG_KEY_PENALTY = -0.6,
			PERFECT_PROGRESS = 0.3,
			GOOD_PROGRESS = 0.12,
			OK_PROGRESS = 0.02,
			COMBO_MULTIPLIER = 0.015,
			MAX_COMBO_BONUS = 0.3,
			SPECIAL_NOTE_SCALE = 0.05,
			WARMUP_DURATION = 0
		}
	},
	weluvlama = {
		chartModule = "WeLuvLamaChart",
		musicId = "rbxassetid://99348409174711",
		overrides = {
			NOTE_FALL_TIME = 0.45,
			PERFECT_WINDOW = 0.036,
			GOOD_WINDOW = 0.065,
			OK_WINDOW = 0.1,
			MISS_PENALTY = -2.5,
			WRONG_KEY_PENALTY = -0.9,
			PERFECT_PROGRESS = 0.25,
			GOOD_PROGRESS = 0.1,
			OK_PROGRESS = 0.02,
			COMBO_MULTIPLIER = 0.012,
			MAX_COMBO_BONUS = 0.25,
			SPECIAL_NOTE_SCALE = 0.05,
			WARMUP_DURATION = 0
		}
	},
	riftwalker = {
		chartModule = "RiftWalkerChart",
		musicId = "rbxassetid://136048177884213",
		overrides = {
			NOTE_FALL_TIME = 0.5,
			PERFECT_WINDOW = 0.038,
			GOOD_WINDOW = 0.07,
			OK_WINDOW = 0.11,
			MISS_PENALTY = -2,
			WRONG_KEY_PENALTY = -0.7,
			PERFECT_PROGRESS = 0.3,
			GOOD_PROGRESS = 0.12,
			OK_PROGRESS = 0.02,
			COMBO_MULTIPLIER = 0.015,
			MAX_COMBO_BONUS = 0.3,
			SPECIAL_NOTE_SCALE = 0.05,
			WARMUP_DURATION = 0
		}
	},
	virtualfutural = {
		chartModule = "VirtualFuturalChart",
		musicId = "rbxassetid://128239566991326",
		overrides = {
			NOTE_FALL_TIME = 0.5,
			PERFECT_WINDOW = 0.038,
			GOOD_WINDOW = 0.068,
			OK_WINDOW = 0.11,
			MISS_PENALTY = -2,
			WRONG_KEY_PENALTY = -0.7,
			PERFECT_PROGRESS = 0.3,
			GOOD_PROGRESS = 0.12,
			OK_PROGRESS = 0.02,
			COMBO_MULTIPLIER = 0.015,
			MAX_COMBO_BONUS = 0.3,
			SPECIAL_NOTE_SCALE = 0.05,
			WARMUP_DURATION = 0
		}
	},
	baryogenesis = {
		chartModule = "BaryogenesisChart",
		musicId = "rbxassetid://94183461089562",
		overrides = {
			NOTE_FALL_TIME = 0.45,
			PERFECT_WINDOW = 0.036,
			GOOD_WINDOW = 0.065,
			OK_WINDOW = 0.1,
			MISS_PENALTY = -2.5,
			WRONG_KEY_PENALTY = -0.9,
			PERFECT_PROGRESS = 0.22,
			GOOD_PROGRESS = 0.09,
			OK_PROGRESS = 0.02,
			COMBO_MULTIPLIER = 0.01,
			MAX_COMBO_BONUS = 0.2,
			SPECIAL_NOTE_SCALE = 0.05,
			WARMUP_DURATION = 0
		}
	}
}
local v31 = {
	"freedomdive",
	"weluvlama",
	"riftwalker",
	"virtualfutural",
	"baryogenesis"
}
local v32 = {
	{
		chartModule = "TranquilityTrack1",
		musicId = "rbxassetid://139523337474874",
		maxScale = 1
	},
	{
		chartModule = "TranquilityTrack2",
		musicId = "rbxassetid://105416986310169",
		maxScale = 2
	},
	{
		chartModule = "TranquilityTrack3",
		musicId = "rbxassetid://137258426094747",
		maxScale = 3
	},
	{
		chartModule = "TranquilityTrack4",
		musicId = "rbxassetid://82527825248527",
		maxScale = 4.2
	},
	{
		chartModule = "TranquilityTrack5",
		musicId = "rbxassetid://114725042296413",
		maxScale = 1e999
	}
}

-- equivalent calls inferred from this helper; original call sites unknown
local function getDeviceType()
	local current = Input.PreferredInput.Current

	if current == "Touch" then
		return "Touch"
	elseif current == "Gamepad" then
		return "Gamepad"
	end

	return "Keyboard"
end

local v33 = {
	DFJK = {
		keys = {
			Enum.KeyCode.D,
			Enum.KeyCode.F,
			Enum.KeyCode.J,
			Enum.KeyCode.K
		},
		labels = {
			"D",
			"F",
			"J",
			"K"
		}
	},
	ASDF = {
		keys = {
			Enum.KeyCode.A,
			Enum.KeyCode.S,
			Enum.KeyCode.D,
			Enum.KeyCode.F
		},
		labels = {
			"A",
			"S",
			"D",
			"F"
		}
	},
	QWOP = {
		keys = {
			Enum.KeyCode.Q,
			Enum.KeyCode.W,
			Enum.KeyCode.O,
			Enum.KeyCode.P
		},
		labels = {
			"Q",
			"W",
			"O",
			"P"
		}
	},
	ZXCP = {
		keys = {
			Enum.KeyCode.Z,
			Enum.KeyCode.X,
			Enum.KeyCode.Comma,
			Enum.KeyCode.Period
		},
		labels = {
			"Z",
			"X",
			",",
			"."
		}
	},
	Arrows = {
		keys = {
			Enum.KeyCode.Left,
			Enum.KeyCode.Down,
			Enum.KeyCode.Up,
			Enum.KeyCode.Right
		},
		labels = {
			"←",
			"↓",
			"↑",
			"→"
		}
	},
	WASD = {
		keys = {
			Enum.KeyCode.A,
			Enum.KeyCode.S,
			Enum.KeyCode.W,
			Enum.KeyCode.D
		},
		labels = {
			"A",
			"S",
			"W",
			"D"
		}
	}
}

local function getSetting(p: string)
	local success, result = pcall(function()
		return SettingsController:GetSettingValue(p)
	end)

	if success then
		return result
	end

	return nil
end

local function getKeyboardConfig()
	local v34 = "rhythmKeybinds"
	local success, result = pcall(function()
		return SettingsController:GetSettingValue(v34)
	end)

	if not success then
		result = nil
	end

	return result and v33[result] or v33.DFJK
end

local v34 = {
	FaceButtons = {
		keys = {
			Enum.KeyCode.ButtonX,
			Enum.KeyCode.ButtonA,
			Enum.KeyCode.ButtonY,
			Enum.KeyCode.ButtonB
		},
		labels = {
			"X",
			"A",
			"Y",
			"B"
		},
		psLabels = {
			"□",
			"×",
			"△",
			"○"
		}
	},
	DpadFace = {
		keys = {
			Enum.KeyCode.DPadLeft,
			Enum.KeyCode.DPadRight,
			Enum.KeyCode.ButtonY,
			Enum.KeyCode.ButtonB
		},
		labels = {
			"←",
			"→",
			"Y",
			"B"
		},
		psLabels = {
			"←",
			"→",
			"△",
			"○"
		}
	},
	DpadOnly = {
		keys = {
			Enum.KeyCode.DPadLeft,
			Enum.KeyCode.DPadDown,
			Enum.KeyCode.DPadUp,
			Enum.KeyCode.DPadRight
		},
		labels = {
			"←",
			"↓",
			"↑",
			"→"
		}
	},
	Triggers = {
		keys = {
			Enum.KeyCode.ButtonL2,
			Enum.KeyCode.ButtonL1,
			Enum.KeyCode.ButtonR1,
			Enum.KeyCode.ButtonR2
		},
		labels = {
			"LT",
			"LB",
			"RB",
			"RT"
		},
		psLabels = {
			"L2",
			"L1",
			"R1",
			"R2"
		}
	},
	DpadAB = {
		keys = {
			Enum.KeyCode.DPadLeft,
			Enum.KeyCode.DPadUp,
			Enum.KeyCode.ButtonA,
			Enum.KeyCode.ButtonB
		},
		labels = {
			"←",
			"↑",
			"A",
			"B"
		},
		psLabels = {
			"←",
			"↑",
			"×",
			"○"
		}
	},
	DpadYB = {
		keys = {
			Enum.KeyCode.DPadLeft,
			Enum.KeyCode.DPadDown,
			Enum.KeyCode.ButtonY,
			Enum.KeyCode.ButtonB
		},
		labels = {
			"←",
			"↓",
			"Y",
			"B"
		},
		psLabels = {
			"←",
			"↓",
			"△",
			"○"
		}
	}
}

local function getGamepadConfig()
	local v35 = "rhythmGamepadKeybinds"
	local success, result = pcall(function()
		return SettingsController:GetSettingValue(v35)
	end)

	if not success then
		result = nil
	end

	local v36 = result and v34[result] or v34.FaceButtons
	local v37 = UserInputService:GetStringForKeyCode(Enum.KeyCode.ButtonX) == "ButtonSquare"
	local v38 = {
		keys = v36.keys,
		labels = 0
	}
	local labels

	if v37 and v36.psLabels then
		labels = v36.psLabels
	else
		labels = v36.labels
	end

	v38.labels = labels
	return v38
end

local v35 = {
	LANES = 4,
	NOTE_FALL_TIME = 0.83,
	MIN_SPAWN_INTERVAL = 0.25,
	MAX_SPAWN_INTERVAL = 0.55,
	SPAWN_RATE_INCREASE = 0.015,
	PERFECT_WINDOW = 0.058,
	GOOD_WINDOW = 0.12,
	OK_WINDOW = 0.19,
	PERFECT_PROGRESS = 1.1,
	GOOD_PROGRESS = 0.5,
	OK_PROGRESS = 0.1,
	MISS_PENALTY = -3.2,
	WRONG_KEY_PENALTY = -1.2,
	COMBO_MULTIPLIER = 0.1,
	MAX_COMBO_BONUS = 1.2,
	SPECIAL_NOTE_SCALE = 1,
	WARMUP_DURATION = 2,
	PROGRESS_DRAIN = 0,
	DIFFICULTY_SCALE = 0
}

local function getDifficultyConfig(name: string, object)
	local clone = table.clone(v35)
	local v36 = fish[name]

	if not v36 then
		return clone
	end

	local rarity = v36.Rarity
	local rarity2 = rarities.Rarities[rarity]
	local v37 = math.clamp(math.pow(math.max(0, (not rarity2 and 1 or rarity2.Order) - 1), 0.7) * 0.55, 0, 3)
	local v38 = math.clamp((50 - math.clamp(v36.Resilience or 50, -60, 120)) / 35, -0.5, 2)
	local v39 = math.clamp((1 - (v36.ForcedProgressEfficiency or v36.ProgressEfficiency or 1)) * 1.5, -0.3, 1.5)
	local v40 = not object and 0 or math.max(0, ((object.movementfactor or 1) - 1) * 0.5)
	local v41 = math.clamp(v37 + v38 + v39 + v40, 0, 5.5)
	local v42 = math.clamp(v41 * 0.7 + 2, 2, 7)
	clone.NOTE_FALL_TIME = math.max(0.42, v35.NOTE_FALL_TIME - v41 * 0.07)
	clone.MIN_SPAWN_INTERVAL = math.max(0.14, v35.MIN_SPAWN_INTERVAL - v41 * 0.015)
	clone.MAX_SPAWN_INTERVAL = math.max(0.22, v35.MAX_SPAWN_INTERVAL - v41 * 0.04)
	clone.SPAWN_RATE_INCREASE = v35.SPAWN_RATE_INCREASE + v41 * 0.004
	clone.PERFECT_WINDOW = math.max(0.038, v35.PERFECT_WINDOW - v41 * 0.004)
	clone.GOOD_WINDOW = math.max(0.07, v35.GOOD_WINDOW - v41 * 0.011)
	clone.OK_WINDOW = math.max(0.11, v35.OK_WINDOW - v41 * 0.017)
	clone.MISS_PENALTY = v35.MISS_PENALTY - v41 * 0.6
	clone.WRONG_KEY_PENALTY = v35.WRONG_KEY_PENALTY - v41 * 0.3
	local v43 = math.clamp(1.8 - v41 * 0.3, 0.2, 1.8)
	clone.PERFECT_PROGRESS *= v43
	clone.GOOD_PROGRESS *= v43
	clone.OK_PROGRESS *= v43
	clone.COMBO_MULTIPLIER = math.max(0.03, v35.COMBO_MULTIPLIER - v41 * 0.014)
	clone.MAX_COMBO_BONUS = math.max(0.25, v35.MAX_COMBO_BONUS - v41 * 0.16)
	clone.SPECIAL_NOTE_SCALE = math.clamp(v43 / 1.8, 0.1, 1)
	clone.WARMUP_DURATION = v42
	clone.PROGRESS_DRAIN = v41 * 0.18 + 0.05
	clone.DIFFICULTY_SCALE = v41
	local v44 = math.clamp(1 - (1.8 - v43) * 0.12, 0.3, 1)
	clone.MISS_PENALTY *= v44
	clone.WRONG_KEY_PENALTY *= v44

	if not (object and object.stats) then
		return clone
	end

	local stats = object.stats
	local v45 = math.clamp((stats.Control or 0) / 0.3, 0, 1.5)
	clone.PERFECT_WINDOW += v45 * 0.02
	clone.GOOD_WINDOW += v45 * 0.035
	clone.OK_WINDOW += v45 * 0.045
	local v46 = math.clamp((stats.ProgressSpeed or 0) / 80, -0.6, 0.5) + 1
	clone.PERFECT_PROGRESS *= math.max(0.1, v46)
	clone.GOOD_PROGRESS *= math.max(0.1, v46)
	clone.OK_PROGRESS *= math.max(0.1, v46)
	local v47 = math.clamp((stats.Luck or 0) / 200, 0, 0.4)
	clone.MISS_PENALTY *= 1 - v47
	clone.WRONG_KEY_PENALTY *= 1 - v47
	local v48 = math.clamp((stats.Resilience or 0) / 200, 0, 0.15)
	clone.NOTE_FALL_TIME += v48 * v35.NOTE_FALL_TIME
	return clone
end

function TranquilityRod.Morph(p, p2, object)
	local config = p.config
	local rhythmGuiName

	if config then
		rhythmGuiName = config.RhythmGuiName or nil
	end

	local screenGui

	if rhythmGuiName then
		screenGui = script:FindFirstChild(rhythmGuiName) or customreels:FindFirstChild(rhythmGuiName)

		if not (screenGui and screenGui:IsA("ScreenGui")) then
			screenGui = nil
		end
	end

	local v36 = screenGui or tranquilityRodRhythmGame
	local rhythmGuiUpscrollName = config and config.RhythmGuiUpscrollName or nil
	local screenGui2

	if rhythmGuiUpscrollName then
		screenGui2 = script:FindFirstChild(rhythmGuiUpscrollName) or customreels:FindFirstChild(rhythmGuiUpscrollName)

		if not (screenGui2 and screenGui2:IsA("ScreenGui")) then
			screenGui2 = nil
		end
	end

	local v37 = screenGui2 or tranquilityRodRhythmGameUpsScroll
	task.spawn(ContentProvider.PreloadAsync, ContentProvider, { v36, v37 })
	local config2 = resolveConfig(p.config)
	local name = object.fish.Name or ""
	local difficultyConfig = getDifficultyConfig(name, object)
	local deviceType = getDeviceType() -- equivalent call inferred; original call site unknown
	local v38 = {
		Keyboard = 0,
		Gamepad = 0,
		Touch = 0
	}
	local v39 = "rhythmKeybinds"
	local success, result = pcall(function()
		return SettingsController:GetSettingValue(v39)
	end)

	if not success then
		result = nil
	end

	v38.Keyboard = result and v33[result] or v33.DFJK
	v38.Gamepad = getGamepadConfig()
	v38.Touch = {
		keys = {},
		labels = {
			"←",
			"↓",
			"↑",
			"→"
		}
	}
	local v40 = v38[deviceType]
	local v41 = "rhythmScrollDirection"
	local success2, result2 = pcall(function()
		return SettingsController:GetSettingValue(v41)
	end)

	if not success2 then
		result2 = nil
	end

	local v42 = result2 == "Upscroll"
	p2.Visible = false

	if v42 then
		v36 = v37 or v36
	end

	local clone = v36:Clone()
	clone.Enabled = true
	clone.Parent = Players.LocalPlayer.PlayerGui
	p.reelTrove:Add(clone)
	local rhythmGame = clone:WaitForChild("RhythmGame")
	local laneContainer = rhythmGame:WaitForChild("LaneContainer")

	if deviceType == "Touch" then
		local mobileLaneScale = config2.MobileLaneScale

		-- equivalent calls inferred from this helper; original call sites unknown
		local function spreadFromCenter(state, flag2: boolean)
			if flag2 then
				state.Size = UDim2.fromScale(state.Size.X.Scale * mobileLaneScale, state.Size.Y.Scale)
			end

			state.Position = UDim2.fromScale(
				0.5 + (state.Position.X.Scale - 0.5) * mobileLaneScale,
				state.Position.Y.Scale
			)
		end

		for _, frame in laneContainer:GetChildren() do
			if not (frame:IsA("Frame") and frame.Name:match("^Lane%d")) then
				continue
			end

			spreadFromCenter(frame, true) -- equivalent call inferred; original call site unknown
		end

		for i = 1, 4 do
			local guiObject = rhythmGame:FindFirstChild("GlowOverlay" .. i)

			if guiObject and guiObject:IsA("GuiObject") then
				spreadFromCenter(guiObject, true) -- equivalent call inferred; original call site unknown
			end

			local guiObject2 = rhythmGame:FindFirstChild("KeyLabel" .. i)

			if not (guiObject2 and guiObject2:IsA("GuiObject")) then
				continue
			end

			spreadFromCenter(guiObject2, false) -- equivalent call inferred; original call site unknown
		end
	end

	local fishLabel = rhythmGame:WaitForChild("FishLabel")
	local comboLabel = rhythmGame:WaitForChild("ComboLabel")
	local feedbackLabel = rhythmGame:WaitForChild("FeedbackLabel")
	local fill = rhythmGame:WaitForChild("HealthBar"):WaitForChild("Fill")
	local noteTemplate = rhythmGame:WaitForChild("NoteTemplate")
	local attackTemplate = rhythmGame:FindFirstChild("AttackTemplate")

	if not attackTemplate then
		warn("[Tranquility Rod] AttackTemplate not found in", rhythmGame:GetFullName())
	end

	local children = {}
	local receptors = {}
	local imageColor3s = {}
	local children2 = {}

	for i = 1, difficultyConfig.LANES do
		local child = laneContainer:WaitForChild("Lane" .. i)
		children[i] = child
		local receptor = child:WaitForChild("Receptor")
		receptors[i] = receptor
		imageColor3s[i] = receptor.ImageColor3
		local child2 = rhythmGame:FindFirstChild("GlowOverlay" .. i)

		if child2 then
			children2[i] = child2
		end

		local child3 = rhythmGame:FindFirstChild("KeyLabel" .. i)

		if child3 then
			child3.Text = v40.labels[i] or "?"
		end
	end

	local scale = receptors[1].Position.Y.Scale
	local v43 = fish[name]
	local v44 = not v43 and "Unknown" or v43.Rarity
	local rarity = rarities.Rarities[v44]
	local color

	if rarity then
		color = rarity.Color
	else
		color = Color3.fromRGB(255, 255, 255)
	end

	fishLabel.Text = (name == "" or not name) and "Fish" or name
	fishLabel.TextColor3 = color
	local v45 = {}
	local effects = {}

	for k, source in parentModule.Sources do
		for k2, activePassive in source.ActivePassives do
			local passiveName

			if typeof(activePassive.env) == "table" and typeof(activePassive.env.PassiveName) == "string" then
				passiveName = activePassive.env.PassiveName
			else
				passiveName = tostring(k2):split("//")[1]
			end

			local config3 = activePassive.config

			if typeof(config3) ~= "table" then
				continue
			end

			local effect = nil

			if passiveName == "Generic_Slashes" then
				effect = v23[tostring(config3.SourceName)] or deriveStabEffect(config3)
			elseif passiveName == "Chronos" or passiveName == "Cryogenic" then
				effect = deriveFreezeEffect(passiveName, config3)
			else
				local v47 = v25[passiveName]

				if v47 then
					local v48 = v26[passiveName]

					if not v48 or v48(config3, object) then
						effect = v47(CompanionController.GetScaledConfig(config3))
					end
				end
			end

			if effect then
				table.insert(v45, {
					key = k .. "/" .. tostring(k2),
					effect = effect
				})
			end
		end
	end

	table.sort(v45, function(a, b)
		return a.key < b.key
	end)

	for _, v46 in v45 do
		table.insert(effects, v46.effect)
	end

	local userId = Players.LocalPlayer and Players.LocalPlayer.UserId or 0
	local v46 = table.find(HardChartUserIds, userId) ~= nil
	local v47 = v12
	local v48 = v13
	v12 = nil
	v13 = false
	local v49 = nil
	local random = object:GetRandom(7)

	if v46 then
		v49 = v31[random:NextInteger(1, #v31)]
	elseif v47 and v30[v47] then
		v49 = v47
	elseif random:NextInteger(1, 10000) <= config2.SpecialChartChance * 100 then
		v49 = v31[random:NextInteger(1, #v31)]
	end

	local v50 = (not rarity and 1 or rarity.Order) >= 7

	if not v49 and not v46 and #v11 >= 100 then
		local flag2 = true

		for _, v52 in v11 do
			if v52 then
				continue
			end

			flag2 = false
			break
		end

		if flag2 then
			v49 = "weluvlama"
		end
	end

	if v49 == "weluvlama" then
		table.clear(v11)
		remoteEvent2:FireServer()
	end

	local v51

	if v49 then
		v51 = v30[v49]
	else
		v51 = nil
	end

	local v52 = v49 ~= nil
	local v53 = v52 and v48
	local v54 = nil

	if not v52 then
		for _, v56 in v32 do
			if not (difficultyConfig.DIFFICULTY_SCALE <= v56.maxScale) then
				continue
			end

			if script:FindFirstChild(v56.chartModule) then
				v54 = v56
			end

			break
		end
	end

	local v55 = v52 or v54 ~= nil
	local v56 = false
	object.BuildEndingData:Bind(function(p3)
		object.perfect = not v56
		p3.TranquilityRod_FullCombo = not v56
		p3.TranquilityRod_SpecialChart = v49 or false
		return p3
	end)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function playGameSound(instance, flag2: boolean?)
		local clone2 = instance:Clone()

		if flag2 then
			clone2.PlaybackSpeed = 0.95 + math.random() * 0.15
		end

		clone2.Parent = rhythmGame
		clone2.Ended:Once(function()
			clone2:Destroy()
		end)
		clone2:Play()
	end

	local v57 = slashes:FindFirstChild("stabbystab" .. object.rodName) or slashes:FindFirstChild(object.rodName) or slashes.stabbystab
	local chronos = ui:FindFirstChild("chronos")
	local bite = fishing.bite
	task.spawn(ContentProvider.PreloadAsync, ContentProvider, { v57, chronos })
	local screenFlashTemplate = rhythmGame:WaitForChild("ScreenFlashTemplate")
	local specialNoteTemplate = rhythmGame:WaitForChild("SpecialNoteTemplate")
	local rhythmMusic = rhythmGame:WaitForChild("RhythmMusic")
	local v58 = {}

	if deviceType == "Touch" then
		for i = 1, difficultyConfig.LANES do
			local touchArea = children[i]:WaitForChild("TouchArea")
			touchArea.Visible = true
			local v59 = i
			touchArea.MouseButton1Down:Connect(function()
				if v58[v59] then
					v58[v59](v59)
				end
			end)
		end
	end

	local soundId

	if v51 then
		soundId = v51.musicId
	else
		soundId = not v54 and "rbxassetid://102279259280161" or v54.musicId
	end

	rhythmMusic.SoundId = soundId
	rhythmMusic.Volume = 1
	rhythmMusic.Looped = not v55

	if v55 then
		task.spawn(ContentProvider.PreloadAsync, ContentProvider, { rhythmMusic })
	end

	rhythmGame.BackgroundTransparency = 1
	object.logicTweens:Create(rhythmGame, tweenInfo6, {
		BackgroundTransparency = 0.15
	}):Play()

	for k, v60 in children do
		local position = v60.Position
		v60.Position = position + UDim2.fromScale(0, 0.5)
		local v61 = v60
		object:DelayLogic(k * 0.05, function()
			object.logicTweens:Create(v61, tweenInfo15, {
				Position = position
			}):Play()
		end)
	end

	task.spawn(function()
		object:WaitUntilReady()
		local v60 = nil
		local fishBehavior = parentModule.Sources.FishBehavior

		if fishBehavior then
			for childName, activePassive in fishBehavior.ActivePassives do
				local v61 = tostring(childName):split("//")[1]

				if v61 == "VeiledCharybdisBehavior" then
					activePassive.nextSpawn = 1e999
					local config3 = activePassive.config
					activePassive.config = setmetatable({
						ProgressGainPullRatio = 0,
						ProgressLossPullRatio = 0
					}, {
						__index = config3
					})
					local v62 = activePassive
					p.reelTrove:Add(function()
						v62.config = config3
					end)
					v60 = activePassive
				elseif v61 == "SkolopendraBehavior" then
					activePassive.nextDarkness = 1e999
					activePassive.darknessCount = 1
				end

				if activePassive.lastAttack ~= nil then
					activePassive.lastAttack = 1e999
				end

				if activePassive.fightActive ~= nil then
					activePassive.fightActive = false
				end

				local folder = script.Parent:FindFirstChild(childName)

				if not folder then
					continue
				end

				for _, sound in folder:GetDescendants() do
					if not sound:IsA("Sound") then
						continue
					end

					local volume = sound.Volume
					sound.Volume = 0
					local v62 = sound
					local connection = sound:GetPropertyChangedSignal("Volume"):Connect(function()
						if v62.Volume ~= 0 then
							volume = v62.Volume
							v62.Volume = 0
						end
					end)
					local v63 = sound
					p.reelTrove:Add(function()
						connection:Disconnect()
						v63.Volume = volume
					end)
				end
			end
		end

		object:AddModifier("progressefficiency", "force", 0)
		object:AddModifier("progressLossMultiplier", "multiply", 0)
		local slash = object.fx.Slash

		function object.fx.Slash()
			return nil
		end

		p.reelTrove:Add(function()
			object.fx.Slash = slash
		end)
		local modifier = object:CreateModifier("progress", "force")
		modifier.Value = object.progress
		local flag2 = false

		local function setProgress(p3: number)
			if object.progressLocked then
				return
			end

			local v61 = math.max(p3, 0)

			if v53 then
				if flag2 then
					modifier.Value = 100 / object.trueprogressefficiency
					return
				else
					v61 = math.min(v61, 99 / object.trueprogressefficiency)
				end
			end

			modifier.Value = v61
		end

		local v61 = object
		local addProgress = v61.AddProgress

		function v61.AddProgress(data, p3: number, p4: number?)
			if not data.isPaused or data.progressLocked then
				return addProgress(data, p3, p4)
			end

			local v62 = p3 * data.trueprogressefficiency

			if p4 then
				v62 = math.min(v62, p4 - modifier.Value)
			end

			if not (v62 == v62 and math.abs(v62) ~= 1e999) then
				return addProgress(data, p3, p4)
			end

			local v63 = modifier.Value + v62

			if not object.progressLocked then
				local v64 = math.max(v63, 0)

				if v53 then
					if flag2 then
						modifier.Value = 100 / object.trueprogressefficiency
					else
						v64 = math.min(v64, 99 / object.trueprogressefficiency)
						modifier.Value = v64
					end
				else
					modifier.Value = v64
				end
			end

			return addProgress(data, p3, p4)
		end

		p.reelTrove:Add(function()
			v61.AddProgress = addProgress
		end)
		local dangerBar = rhythmGame:FindFirstChild("DangerBar")
		local fill2

		if dangerBar then
			fill2 = dangerBar:FindFirstChild("Fill")
		else
			fill2 = nil
		end

		local function addVeiledDanger(p3: number)
			local v62 = v60

			if not v62 or not v62.veiledActive or object.isPaused then
				return
			end

			v62.currentDanger = math.clamp(v62.currentDanger + p3, 0, 100)

			if p3 > 0 and dangerBar then
				object.fx:SpawnShake(dangerBar, 0.3, 0.2, 0.02)
			end
		end

		local v62 = {}
		local count = 0
		local flag3 = true
		local now = tick()
		local now2 = tick()
		local v63 = 0
		local MAX_SPAWN_INTERVAL = difficultyConfig.MAX_SPAWN_INTERVAL
		local random2 = object:GetRandom(3)
		local random3 = object:GetRandom(11)
		local v64 = {}
		local clones = {}
		local count2 = 0
		local data = object.data
		local v65, v66, v67, v68

		if data and data.OllieTreasure then
			v65 = Net:RemoteEvent("Companion/OllieOtter/TreasureShown")
			v66 = Net:RemoteEvent("Companion/OllieOtter/ClaimTreasure")
			local fillTime = 5
			local appearDelayMin = 1.5
			local appearDelayMax = 7
			local companion = parentModule.Sources.Companion
			local ollieOtter_Treasure = companion and companion.ActivePassives.OllieOtter_Treasure
			local config3 = ollieOtter_Treasure and ollieOtter_Treasure.config

			if typeof(config3) == "table" then
				local scaledConfig = CompanionController.GetScaledConfig(config3)
				fillTime = tonumber(scaledConfig.FillTime) or fillTime
				appearDelayMin = tonumber(scaledConfig.AppearDelayMin) or appearDelayMin
				appearDelayMax = tonumber(scaledConfig.AppearDelayMax) or appearDelayMax
			end

			local v69 = math.clamp(math.round(fillTime * 0.6), 2, 4)
			local random4 = object:GetRandom(13)
			v67 = {
				effectType = "treasure",
				progressBonus = 2,
				cooldown = 0,
				color = Color3.fromRGB(255, 215, 90),
				rating = rating5
			}
			v68 = {
				required = v69,
				remaining = v69,
				hits = 0,
				locked = false,
				shown = false,
				nextSpawn = tick() + random4:NextNumber(appearDelayMin, (math.max(appearDelayMax, appearDelayMin)))
			}
			data.OllieTreasure = nil
		else
			v68 = nil
			v66 = nil
			v67 = nil
			v65 = nil
		end

		local chart = {}
		local v69 = 1
		local total = 0
		local duration = 0
		local audioOffset = 0
		local specialChartSpeed = config2.SpecialChartSpeed

		if v51 then
			local chartModule = v51.chartModule
			local child = script:FindFirstChild(chartModule)
			local module2

			if child then
				module2 = require(child)
			end

			if module2 then
				chart = module2.chart
				duration = module2.duration
				audioOffset = v51.audioOffset or module2.audioOffset or 0
			end

			for k, override in v51.overrides do
				difficultyConfig[k] = override
			end
		end

		local v70 = nil
		local duration2 = 0
		local audioOffset2 = 0
		local module2

		if v54 then
			local chartModule = v54.chartModule
			local child = script:FindFirstChild(chartModule)

			if child then
				module2 = require(child)
			end
		end

		if v54 and module2 then
			local v71 = difficultyConfig.DIFFICULTY_SCALE * 1 + 3.3
			local v72

			if deviceType == "Touch" then
				v72 = false
			else
				v72 = difficultyConfig.DIFFICULTY_SCALE >= 3
			end

			local v73 = 2

			for i = 3, v72 and 5 or 4 do
				if module2.levelDensity[i] <= v71 then
					v73 = i
				end
			end

			local sections = module2.sections
			local v74 = not (#sections > 0) and 0 or sections[random:NextInteger(1, #sections)]
			v70 = {}
			chart = {}

			for _, note in module2.notes do
				if not (note // 4 % 8 + 1 <= v73) then
					continue
				end

				local v75 = note // 32
				local lane = note % 4 + 1
				table.insert(v70, {
					time = v75 / 1000,
					lane = lane
				})

				if v74 <= v75 then
					table.insert(chart, {
						time = (v75 - v74) / 1000,
						lane = lane
					})
				end
			end

			audioOffset2 = v54.audioOffset or 0
			duration = module2.duration - v74 / 1000
			audioOffset = v74 / 1000 + audioOffset2
			duration2 = module2.duration
		end

		if v55 then
			local v71 = tick() + 3

			while not rhythmMusic.IsLoaded and tick() < v71 and object.active do
				object:WaitRender(0)
			end

			if not object.active then
				return
			end

			now = tick() + difficultyConfig.NOTE_FALL_TIME + 0.7
		else
			rhythmMusic:Play()
		end

		rhythmMusic.PlaybackSpeed = specialChartSpeed

		local function getWarmupAlpha()
			return (math.clamp((tick() - now) / difficultyConfig.WARMUP_DURATION, 0, 1))
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function warmupLerp(p3: number, p4: number)
			return p3 + (p4 - p3) * math.clamp((tick() - now) / difficultyConfig.WARMUP_DURATION, 0, 1)
		end

		local defaultAttackCooldown = config2.DefaultAttackCooldown
		local v71 = config2.DefaultAttackChance / 100
		local now3 = tick()
		local v72 = not v55
		local imageTransparency = noteTemplate.ImageTransparency
		local v73 = {}
		local speedMultiplier = 1
		local v74 = nil
		local olympianDevilBehavior = nil
		local v75 = false
		local v76 = nil
		local windowShrink = 1
		local flag4 = false
		local v77 = false
		local v78 = 0
		local v79 = false
		local v80 = 0.016
		local total2 = 0
		local v81 = false
		local v82 = 0
		local v83 = 0
		local regenPerSecond = 0
		local v84 = false
		local flag5 = false
		local v85 = 0
		local v86 = 0
		local v87 = false
		local count3 = 0
		local v88 = 0
		local flag6 = false
		local count4 = 0
		local v89 = false

		for _, v90 in effects do
			v73[v90] = tick()
		end

		local v90 = nil

		if v43 then
			local clientFishingPassives = v43.ClientFishingPassives

			if clientFishingPassives then
				local count5 = 0

				for k, _ in clientFishingPassives do
					if k:match("GodFight$") then
						count5 += 1
					end
				end

				if count5 > 1 then
					olympianDevilBehavior = v27.OlympianDevilBehavior or v28
					v76 = {
						Color = Color3.fromRGB(191, 146, 255)
					}
					defaultAttackCooldown = 6
					v71 = 0.25
				else
					for k, clientFishingPassive in clientFishingPassives do
						if not k:match("Behavior$") then
							continue
						end

						olympianDevilBehavior = v27[k] or v28
						defaultAttackCooldown = clientFishingPassive.Cooldown or config2.DefaultAttackCooldown
						v71 = (clientFishingPassive.BaseChance or clientFishingPassive.TriggerChance or config2.DefaultAttackChance) / 100
						v76 = clientFishingPassive
						break
					end

					if not olympianDevilBehavior then
						for k, clientFishingPassive in clientFishingPassives do
							local v93 = v29[k]

							if not v93 then
								continue
							end

							v76 = clientFishingPassive
							olympianDevilBehavior = v93
							defaultAttackCooldown = 6
							v71 = 0.25
							break
						end
					end
				end
			end
		end

		local laneOverlays = {}

		for i = 1, difficultyConfig.LANES do
			local laneOverlay = children[i]:FindFirstChild("LaneOverlay")

			if laneOverlay and laneOverlay:IsA("Frame") then
				laneOverlays[i] = laneOverlay
			end
		end

		local attackWarning = rhythmGame:FindFirstChild("AttackWarning")
		local phaseNameLabel = rhythmGame:FindFirstChild("PhaseNameLabel")

		local function tweenLabel(instance, tweenInfo18, p3: number)
			object.logicTweens:Create(instance, tweenInfo18, {
				TextTransparency = p3
			}):Play()

			for _, uIStroke in instance:GetChildren() do
				if uIStroke:IsA("UIStroke") then
					object.logicTweens:Create(uIStroke, tweenInfo18, {
						Transparency = p3
					}):Play()
				end
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function showPhaseName(name2: string, color2: Color3)
			if phaseNameLabel then
				phaseNameLabel.Text = name2
				phaseNameLabel.TextColor3 = color2
				tweenLabel(phaseNameLabel, tweenInfo9, 0)
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function hidePhaseName()
			if phaseNameLabel and phaseNameLabel.Parent then
				tweenLabel(phaseNameLabel, tweenInfo10, 1)
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function showLaneOverlay(i: number, backgroundColor: Color3, backgroundTransparency: number)
			local v91 = laneOverlays[i]

			if v91 then
				v91.BackgroundColor3 = backgroundColor
				v91.BackgroundTransparency = backgroundTransparency
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function hideLaneOverlay(p3: number)
			local v91 = laneOverlays[p3]

			if v91 then
				object.logicTweens:Create(v91, tweenInfo8, {
					BackgroundTransparency = 1
				}):Play()
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function showAllLaneOverlays(color2: Color3, backgroundTransparency: number)
			for i = 1, difficultyConfig.LANES do
				showLaneOverlay(i, color2, backgroundTransparency) -- equivalent call inferred; original call site unknown
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function hideAllLaneOverlays()
			for i = 1, difficultyConfig.LANES do
				hideLaneOverlay(i) -- equivalent call inferred; original call site unknown
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function flashLaneOverlay(p3: number, backgroundColor: Color3, backgroundTransparency: number, backgroundTransparency2: number)
			local v91 = laneOverlays[p3]

			if v91 then
				v91.BackgroundColor3 = backgroundColor
				v91.BackgroundTransparency = backgroundTransparency
				object.logicTweens:Create(v91, tweenInfo16, {
					BackgroundTransparency = backgroundTransparency2
				}):Play()
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function flashAllLaneOverlays(backgroundColor: Color3, backgroundTransparency: number, backgroundTransparency2: number)
			for i = 1, difficultyConfig.LANES do
				flashLaneOverlay(i, backgroundColor, backgroundTransparency, backgroundTransparency2) -- equivalent call inferred; original call site unknown
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function showAttackWarning(warningText: string, color2: Color3)
			local v91 = attackWarning

			if not v91 then
				return
			end

			v91.Text = warningText
			v91.TextColor3 = color2
			tweenLabel(v91, tweenInfo9, 0)
			object:DelayLogic(0.8, function()
				if v91.Parent then
					tweenLabel(v91, tweenInfo10, 1)
				end
			end)
		end

		local function spawnProjectile(lane: number, data2, value: number?, p4)
			if not attackTemplate then
				return
			end

			local trail = p4 and p4.trail
			local splash = p4 and p4.splash
			local clone2 = attackTemplate:Clone()
			clone2.Image = data2.image
			clone2.ImageColor3 = data2.color
			clone2.Size = data2.size
			clone2.Rotation = data2.rotation or 0
			clone2.Visible = true
			clone2.ZIndex = 10
			local v92 = scale
			clone2.Position = UDim2.fromScale(0.5, v42 and 1.1 or -0.1)
			clone2.Parent = children[lane]
			local v93 = value or 0.6
			object.logicTweens:Create(clone2, TweenInfo.new(v93, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				Position = UDim2.fromScale(0.5, v92)
			}):Play()

			if trail then
				table.insert(v64, {
					proj = clone2,
					projectile = data2,
					lane = lane,
					endTime = tick() + v93,
					nextGhost = tick()
				})
			end

			object:DelayLogic(v93, function()
				if clone2.Parent then
					if splash then
						local clone3 = attackTemplate:Clone()
						clone3.Image = "rbxassetid://99534224346344"
						clone3.ImageColor3 = data2.color
						clone3.Size = UDim2.fromScale(0.4, 0.4)
						clone3.Position = UDim2.fromScale(0.5, v92)
						clone3.ImageTransparency = 0.1
						clone3.Visible = true
						clone3.ZIndex = 11
						clone3.Parent = children[lane]
						object.logicTweens:Create(clone3, tweenInfo13, {
							Size = UDim2.fromScale(0.7, 0.7),
							ImageTransparency = 1
						}):Play()
						object:DelayLogic(0.45, function()
							if clone3.Parent then
								clone3:Destroy()
							end
						end)
					end

					object.logicTweens:Create(clone2, tweenInfo11, {
						ImageTransparency = 1,
						Size = UDim2.fromScale(data2.size.X.Scale * 1.5, data2.size.Y.Scale * 1.5)
					}):Play()
					object:DelayLogic(0.2, function()
						if clone2.Parent then
							clone2:Destroy()
						end
					end)
				end
			end)
		end

		local function spawnScreenFlash(backgroundColor: Color3, value: number?, value2: number?)
			local clone2 = screenFlashTemplate:Clone()
			clone2.Name = "ScreenFlash"
			clone2.Visible = true
			clone2.BackgroundColor3 = backgroundColor
			clone2.BackgroundTransparency = value or 0.3
			clone2.Parent = rhythmGame
			local v91 = object.logicTweens:Create(clone2, TweenInfo.new(value2 or 0.4), {
				BackgroundTransparency = 1
			})
			v91.Completed:Once(function()
				clone2:Destroy()
			end)
			v91:Play()
		end

		local function spawnSpotlight(p3: number, color2: Color3, callback)
			if attackTemplate then
				local clone2 = attackTemplate:Clone()
				clone2.Image = "rbxassetid://1423321378"
				clone2.ImageColor3 = color2
				clone2.Size = UDim2.fromScale(1.5, 1.5)
				clone2.ImageTransparency = 0.5
				clone2.Position = UDim2.fromScale(0.5, v42 and 0.8 or 0.2)
				clone2.Visible = true
				clone2.ZIndex = 12
				clone2.Parent = children[p3]
				object.logicTweens:Create(clone2, tweenInfo14, {
					Size = UDim2.fromScale(0.3, 0.3),
					Position = UDim2.fromScale(0.5, scale),
					ImageTransparency = 0.1
				}):Play()
				object:DelayLogic(0.6, function()
					if clone2.Parent then
						clone2:Destroy()
					end

					if callback then
						callback()
					end
				end)
			elseif callback then
				callback()
			end
		end

		local function createNoteFrame(p3: number, p4)
			local v91

			if p4 then
				v91 = specialNoteTemplate
			else
				v91 = noteTemplate
			end

			local clone2 = v91:Clone()
			clone2.Name = p4 and "SpecialNote" or "Note"
			clone2.Visible = true
			clone2.Position = UDim2.fromScale(0.5, v42 and 1.05 or -0.05)
			clone2.ZIndex = p4 and 9 or 8
			local imageColor

			if p4 then
				imageColor = p4.color
			else
				imageColor = imageColor3s[p3]
			end

			clone2.ImageColor3 = imageColor

			if p4 then
				local specialGlow = clone2:FindFirstChild("SpecialGlow")

				if specialGlow and specialGlow:IsA("Frame") then
					specialGlow.BackgroundColor3 = p4.color
				end
			end

			clone2.Parent = children[p3]
			return clone2
		end

		local nows = {}

		local function addNote(lane: number, p4: number?)
			local now4 = tick()
			nows[lane] = now4
			local v91 = warmupLerp(v35.NOTE_FALL_TIME, difficultyConfig.NOTE_FALL_TIME) * speedMultiplier
			local targetTime = p4 or now4 + v91
			local fallTime = targetTime - now4

			if fallTime <= 0.01 then
				fallTime = v91
			end

			local special = v90
			v90 = nil
			table.insert(v62, {
				lane = lane,
				frame = createNoteFrame(lane, special),
				spawnTime = now4,
				targetTime = targetTime,
				fallTime = fallTime,
				hit = false,
				special = special
			})
		end

		local function spawnNote()
			local now4 = tick()
			local v91 = {}

			for i = 1, difficultyConfig.LANES do
				if i ~= v74 then
					table.insert(v91, i)
				end
			end

			local v92 = {}

			for _, v93 in v91 do
				if not nows[v93] or now4 - nows[v93] >= 0.2 then
					table.insert(v92, v93)
				end
			end

			if #v92 > 0 then
				v91 = v92
			end

			addNote(v91[random2:NextInteger(1, #v91)])
		end

		local position = feedbackLabel.Position
		local uIStroke = feedbackLabel:FindFirstChildOfClass("UIStroke")
		local v91 = nil
		local v92 = nil
		local v93 = nil

		local function showFeedback(p3)
			if v91 then
				task.cancel(v91)
				v91 = nil
			end

			if v92 then
				v92:Cancel()
				v92 = nil
			end

			if v93 then
				v93:Cancel()
				v93 = nil
			end

			feedbackLabel.Text = p3.text
			feedbackLabel.TextColor3 = p3.color
			feedbackLabel.TextTransparency = 0
			feedbackLabel.Visible = true
			feedbackLabel.Position = position

			if uIStroke then
				uIStroke.Transparency = 0.2
			end

			object.logicTweens:Create(feedbackLabel, tweenInfo, {
				Position = position + UDim2.fromScale(0, -0.03)
			}):Play()
			v91 = object:DelayLogic(0.15, function()
				v91 = nil

				if feedbackLabel and feedbackLabel.Parent then
					local v94 = object.logicTweens:Create(feedbackLabel, tweenInfo2, {
						TextTransparency = 1,
						Position = position + UDim2.fromScale(0, -0.06)
					})
					v92 = v94
					v94:Play()

					if uIStroke then
						local v95 = object.logicTweens:Create(uIStroke, tweenInfo2, {
							Transparency = 1
						})
						v93 = v95
						v95:Play()
					end
				end
			end)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function flashReceptor(p3: number, flag7: boolean)
			local v94 = receptors[p3]

			if not v94 then
				return
			end

			if flag7 then
				local v95 = children2[p3]

				if v95 then
					v95.ImageTransparency = 0
				end

				v94.ImageTransparency = 0
				object:DelayLogic(0.15, function()
					if v95 and v95.Parent then
						object.logicTweens:Create(v95, tweenInfo3, {
							ImageTransparency = 1
						}):Play()
					end

					if v94 and v94.Parent then
						object.logicTweens:Create(v94, tweenInfo3, {
							ImageTransparency = 0.15
						}):Play()
					end
				end)
			else
				v94.ImageTransparency = 0.6
				object.logicTweens:Create(v94, tweenInfo3, {
					ImageTransparency = 0.15
				}):Play()
			end
		end

		local function updateCombo()
			if count >= 10 then
				comboLabel.Text = count .. "x COMBO!!"
				comboLabel.TextColor3 = Color3.fromRGB(255, 180, 0)
			elseif count >= 5 then
				comboLabel.Text = count .. "x COMBO!"
				comboLabel.TextColor3 = Color3.fromRGB(255, 220, 100)
			elseif count >= 3 then
				comboLabel.Text = count .. "x"
				comboLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
			else
				comboLabel.Text = ""
			end
		end

		local function triggerBehaviorAttack()
			if not (olympianDevilBehavior and flag3) or olympianDevilBehavior.attackType == "darkness" and v75 then
				return
			end

			local v94 = olympianDevilBehavior
			local color2

			if v76 and v76.Color then
				color2 = v76.Color
			else
				color2 = Color3.fromRGB(255, 50, 50)
			end

			if v94.attackType ~= "swoop" then
				if v94.warningText and v94.warningText ~= "" then
					showAttackWarning(v94.warningText, color2) -- equivalent call inferred; original call site unknown
				end

				playGameSound(bite, true)
			end

			if v94.attackType == "drain" then
				local v95 = (v94.drainRatio or 0) * modifier.Value + (v94.drainFlat or 0)
				local v96 = modifier.Value - v95

				if not object.progressLocked then
					local v97 = math.max(v96, 0)

					if v53 then
						if flag2 then
							modifier.Value = 100 / object.trueprogressefficiency
						else
							v97 = math.min(v97, 99 / object.trueprogressefficiency)
							modifier.Value = v97
						end
					else
						modifier.Value = v97
					end
				end

				count = 0
				updateCombo()
				showAllLaneOverlays(color2, 0.5) -- equivalent call inferred; original call site unknown
				object:DelayLogic(0.3, function()
					if flag3 then
						hideAllLaneOverlays() -- equivalent call inferred; original call site unknown
					end
				end)
			elseif v94.attackType == "burst" then
				for _ = 1, v94.burstCount or 3 do
					spawnNote()
				end

				showAllLaneOverlays(color2, 0.4) -- equivalent call inferred; original call site unknown
				object:DelayLogic(0.5, function()
					if flag3 then
						hideAllLaneOverlays() -- equivalent call inferred; original call site unknown
					end
				end)
			elseif v94.attackType == "speedup" then
				speedMultiplier = v94.speedMultiplier or 0.6
				flashAllLaneOverlays(color2, 0.3, 0.85) -- equivalent call inferred; original call site unknown
				object:DelayLogic(v94.duration or 4, function()
					if flag3 then
						speedMultiplier = 1
					end

					hideAllLaneOverlays() -- equivalent call inferred; original call site unknown
				end)
			elseif v94.attackType == "lock" then
				local integer = random2:NextInteger(1, difficultyConfig.LANES)
				v74 = integer
				flashLaneOverlay(integer, color2, 0.4, 0.82) -- equivalent call inferred; original call site unknown
				object:DelayLogic(v94.duration or 2.5, function()
					if v74 == integer then
						v74 = nil
					end

					local v95 = flag3 and laneOverlays[integer]

					if v95 then
						object.logicTweens:Create(v95, tweenInfo8, {
							BackgroundTransparency = 1
						}):Play()
					end
				end)
			elseif v94.attackType == "freeze" then
				speedMultiplier = v94.speedMultiplier or 2
				windowShrink = v94.windowShrink or 0.6
				flashAllLaneOverlays(Color3.fromRGB(150, 220, 255), 0.25, 0.85) -- equivalent call inferred; original call site unknown
				object:DelayLogic(v94.duration or 3, function()
					if flag3 then
						speedMultiplier = 1
						windowShrink = 1
						hideAllLaneOverlays() -- equivalent call inferred; original call site unknown
					end
				end)
			elseif v94.attackType == "fakeout" then
				local gainAmount = v94.gainAmount or 8
				local v95 = modifier.Value + gainAmount

				if not object.progressLocked then
					local v96 = math.max(v95, 0)

					if v53 then
						if flag2 then
							modifier.Value = 100 / object.trueprogressefficiency
						else
							v96 = math.min(v96, 99 / object.trueprogressefficiency)
							modifier.Value = v96
						end
					else
						modifier.Value = v96
					end
				end

				showAllLaneOverlays(Color3.fromRGB(80, 200, 255), 0.3) -- equivalent call inferred; original call site unknown
				object:DelayLogic(v94.lossDelay or 1.5, function()
					if flag3 then
						local v96 = (v94.lossRatio or 0.2) * modifier.Value
						local v97 = modifier.Value - v96

						if not object.progressLocked then
							local v98 = math.max(v97, 0)

							if v53 then
								if flag2 then
									modifier.Value = 100 / object.trueprogressefficiency
								else
									v98 = math.min(v98, 99 / object.trueprogressefficiency)
									modifier.Value = v98
								end
							else
								modifier.Value = v98
							end
						end

						showAllLaneOverlays(Color3.fromRGB(255, 50, 50), 0.4) -- equivalent call inferred; original call site unknown
						object:DelayLogic(0.3, function()
							if flag3 then
								hideAllLaneOverlays() -- equivalent call inferred; original call site unknown
							end
						end)
					end
				end)
			elseif v94.attackType == "swoop" then
				if flag4 then
					return
				end

				flag4 = true
				local speedDuration = v94.speedDuration or 2.5
				local speedMultiplier2 = v94.speedMultiplier or 0.75
				now3 = tick() + speedDuration + 2
				task.spawn(function()
					if attackWarning then
						attackWarning.Text = v94.warningText or "SWOOP!"
						attackWarning.TextColor3 = color2
						attackWarning.TextTransparency = 0

						for _, uIStroke2 in attackWarning:GetChildren() do
							if uIStroke2:IsA("UIStroke") then
								uIStroke2.Transparency = 0
							end
						end
					end

					object:WaitLogic(0.35)

					if not flag3 then
						flag4 = false
						return
					end

					playGameSound(bite, true)

					if attackWarning and attackWarning.Parent then
						tweenLabel(attackWarning, tweenInfo10, 1)
					end

					local v95 = (v94.drainRatio or 0.12) * modifier.Value
					local v96 = modifier.Value - v95

					if not object.progressLocked then
						local v97 = math.max(v96, 0)

						if v53 then
							if flag2 then
								modifier.Value = 100 / object.trueprogressefficiency
							else
								v97 = math.min(v97, 99 / object.trueprogressefficiency)
								modifier.Value = v97
							end
						else
							modifier.Value = v97
						end
					end

					object.fx:SpawnShake(rhythmGame, 0.5, 0.25, 0.02)
					local now4 = tick()

					for _, v97 in v62 do
						if v97.hit then
							continue
						end

						local v98 = (now4 - v97.spawnTime) / v97.fallTime
						local fallTime = v97.fallTime * speedMultiplier2
						v97.fallTime = fallTime
						v97.spawnTime = now4 - v98 * fallTime
						v97.targetTime = v97.spawnTime + fallTime
					end

					speedMultiplier = speedMultiplier2
					flashAllLaneOverlays(color2, 0.3, 0.85) -- equivalent call inferred; original call site unknown
					object:WaitLogic(speedDuration)

					if not flag3 then
						flag4 = false
						return
					end

					local now5 = tick()
					local v98 = 1 / speedMultiplier2

					for _, v99 in v62 do
						if v99.hit then
							continue
						end

						local v100 = (now5 - v99.spawnTime) / v99.fallTime
						local fallTime = v99.fallTime * v98
						v99.fallTime = fallTime
						v99.spawnTime = now5 - v100 * fallTime
						v99.targetTime = v99.spawnTime + fallTime
					end

					speedMultiplier = 1
					flag4 = false
					hideAllLaneOverlays() -- equivalent call inferred; original call site unknown
				end)
			elseif v94.attackType == "darkness" then
				v75 = true
				local slashCount = v76 and v76.SlashCount or 4
				local slashWarnTime = v76 and v76.SlashWarnTime or 0.75
				local v95 = slashWarnTime + 0.6
				flashAllLaneOverlays(Color3.new(), 0.15, 0.45) -- equivalent call inferred; original call site unknown

				for i = 1, slashCount do
					object:DelayLogic(0.5 + (i - 1) * v95, function()
						if not flag3 then
							return
						end

						local v96 = random2:NextInteger(0, 1) == 1 and 3 or 1

						for i2 = v96, v96 + 1 do
							flashLaneOverlay(i2, color2, 0.3, 0.6) -- equivalent call inferred; original call site unknown
						end

						object:DelayLogic(slashWarnTime, function()
							if not flag3 then
								return
							end

							playGameSound(bite, true)

							for i2 = v96, v96 + 1 do
								spawnProjectile(i2, v3, 0.15)
								flashLaneOverlay(i2, Color3.new(), 0.15, 0.45) -- equivalent call inferred; original call site unknown
							end

							object.fx:SpawnShake(rhythmGame, 0.5, 0.25, 0.02)
							local v97 = modifier.Value - (v94.slashDrain or 4)

							if not object.progressLocked then
								local v98 = math.max(v97, 0)

								if v53 then
									if flag2 then
										modifier.Value = 100 / object.trueprogressefficiency
									else
										v98 = math.min(v98, 99 / object.trueprogressefficiency)
										modifier.Value = v98
									end
								else
									modifier.Value = v98
								end
							end

							count = 0
							updateCombo()
						end)
					end)
				end

				object:DelayLogic(0.5 + slashCount * v95, function()
					v75 = false
					v77 = true

					if not flag3 then
						return
					end

					hideAllLaneOverlays() -- equivalent call inferred; original call site unknown

					for _, v96 in v62 do
						if not (v96.hit or v96.special) then
							v96.frame.ImageTransparency = imageTransparency
						end
					end

					object.core.minigame.NoComplete = false
				end)
			elseif v94.attackType == "olympian" then
				local phases = v94.phases

				if not phases or #phases == 0 then
					return
				end

				v78 = v78 % #phases + 1
				local phas = phases[v78]
				local color3 = phas.color or color2
				local warningText = phas.warningText or ""
				showAttackWarning(warningText, color3) -- equivalent call inferred; original call site unknown
				local name2 = phas.name or ""
				showPhaseName(name2, color3) -- equivalent call inferred; original call site unknown
				playGameSound(bite, true)

				local function shakeContainer(p3: number)
					object.fx:SpawnShake(rhythmGame, p3 / 20, 0.3, 0.02)
				end

				if phas.attackType == "burst" then
					object.fx:SpawnShake(rhythmGame, 0.4, 0.3, 0.02)
					local v95 = modifier.Value - 8

					if not object.progressLocked then
						local v96 = math.max(v95, 0)

						if v53 then
							if flag2 then
								modifier.Value = 100 / object.trueprogressefficiency
							else
								v96 = math.min(v96, 99 / object.trueprogressefficiency)
								modifier.Value = v96
							end
						else
							modifier.Value = v96
						end
					end

					for i = 1, phas.burstCount or 4 do
						object:DelayLogic((i - 1) * 0.08, function()
							if flag3 then
								spawnProjectile(
									random2:NextInteger(1, difficultyConfig.LANES),
									v8[random2:NextInteger(1, #v8)],
									0.5,
									{
										trail = true
									}
								)
								spawnNote()
							end
						end)
					end

					flashAllLaneOverlays(color3, 0.2, 0.6) -- equivalent call inferred; original call site unknown
					object:DelayLogic(0.8, function()
						if flag3 then
							hideAllLaneOverlays() -- equivalent call inferred; original call site unknown
						end

						hidePhaseName() -- equivalent call inferred; original call site unknown
					end)
				elseif phas.attackType == "smite" then
					local smiteLanes = phas.smiteLanes or 2
					local smiteWarningTime = phas.smiteWarningTime or 0.8
					local smiteDuration = phas.smiteDuration or 0.4
					local smiteDrain = phas.smiteDrain or 5
					local v95 = {}

					for _ = 1, smiteLanes do
						table.insert(v95, (random2:NextInteger(1, difficultyConfig.LANES)))
					end

					for _, v96 in v95 do
						flashLaneOverlay(v96, color3, 0.3, 0.6) -- equivalent call inferred; original call site unknown
					end

					object:DelayLogic(smiteWarningTime, function()
						if not flag3 then
							return
						end

						playGameSound(bite, true)

						for _, v96 in v95 do
							flashLaneOverlay(v96, Color3.fromRGB(255, 255, 200), 0, 0.3) -- equivalent call inferred; original call site unknown
							spawnProjectile(v96, v5, 0.15)
						end

						spawnScreenFlash(Color3.fromRGB(255, 255, 100), 0.3, 0.4)
						object.fx:SpawnShake(rhythmGame, 0.7, 0.3, 0.02)
						local v96 = modifier.Value - smiteDrain

						if not object.progressLocked then
							local v97 = math.max(v96, 0)

							if v53 then
								if flag2 then
									modifier.Value = 100 / object.trueprogressefficiency
								else
									v97 = math.min(v97, 99 / object.trueprogressefficiency)
									modifier.Value = v97
								end
							else
								modifier.Value = v97
							end
						end

						count = 0
						updateCombo()
						object:DelayLogic(smiteDuration + 0.3, function()
							if flag3 then
								for _, v97 in v95 do
									hideLaneOverlay(v97) -- equivalent call inferred; original call site unknown
								end
							end

							hidePhaseName() -- equivalent call inferred; original call site unknown
						end)
					end)
				elseif phas.attackType == "wave" then
					local speedMultiplier2 = phas.speedMultiplier or 0.5
					local speedDuration = phas.speedDuration or 3
					local v95 = modifier.Value - 6

					if not object.progressLocked then
						local v96 = math.max(v95, 0)

						if v53 then
							if flag2 then
								modifier.Value = 100 / object.trueprogressefficiency
							else
								v96 = math.min(v96, 99 / object.trueprogressefficiency)
								modifier.Value = v96
							end
						else
							modifier.Value = v96
						end
					end

					for i = 1, phas.burstCount or 3 do
						object:DelayLogic((i - 1) * 0.12, function()
							if flag3 then
								spawnProjectile(random2:NextInteger(1, difficultyConfig.LANES), v4, 0.5, {
									trail = true,
									splash = true
								})
								spawnNote()
							end
						end)
					end

					speedMultiplier = speedMultiplier2

					for i = 1, difficultyConfig.LANES do
						local v96 = i
						object:DelayLogic((i - 1) * 0.1, function()
							if flag3 then
								flashLaneOverlay(v96, color3, 0.15, 0.7) -- equivalent call inferred; original call site unknown
							end
						end)
					end

					object.fx:SpawnShake(rhythmGame, 0.4, 0.3, 0.02)
					object:DelayLogic(speedDuration, function()
						if flag3 then
							speedMultiplier = 1
							hideAllLaneOverlays() -- equivalent call inferred; original call site unknown
						end

						hidePhaseName() -- equivalent call inferred; original call site unknown
					end)
				elseif phas.attackType == "wither" then
					local duration3 = phas.duration or 4

					for i = 1, 4 do
						object:DelayLogic((i - 1) * 0.25, function()
							if flag3 then
								flashAllLaneOverlays(color3, 0.3, 0.85) -- equivalent call inferred; original call site unknown
							end
						end)
					end

					object:DelayLogic(1, function()
						if not flag3 then
							return
						end

						v79 = true
						speedMultiplier = phas.speedMultiplier or 1.4
						windowShrink = phas.windowShrink or 0.7

						for i = 1, difficultyConfig.LANES do
							spawnProjectile(i, v6, 0.8)
						end

						flashAllLaneOverlays(color3, 0.1, 0.7) -- equivalent call inferred; original call site unknown
						object.fx:SpawnShake(rhythmGame, 0.3, 0.3, 0.02)
					end)
					object:DelayLogic(1 + duration3, function()
						if flag3 then
							v79 = false
							speedMultiplier = 1
							windowShrink = 1
							hideAllLaneOverlays() -- equivalent call inferred; original call site unknown
						end

						hidePhaseName() -- equivalent call inferred; original call site unknown
					end)
				elseif phas.attackType == "radiance" then
					local v95 = modifier.Value - 7

					if not object.progressLocked then
						local v96 = math.max(v95, 0)

						if v53 then
							if flag2 then
								modifier.Value = 100 / object.trueprogressefficiency
							else
								v96 = math.min(v96, 99 / object.trueprogressefficiency)
								modifier.Value = v96
							end
						else
							modifier.Value = v96
						end
					end

					local v96 = {}

					for i = 1, difficultyConfig.LANES do
						table.insert(v96, i)
					end

					for k, v97 in v96 do
						local v98 = v97
						object:DelayLogic((k - 1) * 0.1, function()
							if flag3 then
								spawnSpotlight(v98, color3)
							end
						end)
					end

					object:DelayLogic(0.6, function()
						if not flag3 then
							return
						end

						spawnScreenFlash(Color3.fromRGB(255, 255, 220), 0.2, 0.5)
						object.fx:SpawnShake(rhythmGame, 0.4, 0.3, 0.02)

						for i = 1, difficultyConfig.LANES do
							spawnProjectile(i, v7, 0.3)
						end

						for i = 1, phas.burstCount or 4 do
							object:DelayLogic((i - 1) * 0.1, function()
								if flag3 then
									spawnProjectile(random2:NextInteger(1, difficultyConfig.LANES), v7, 0.5)
									spawnNote()
								end
							end)
						end

						flashAllLaneOverlays(color3, 0.2, 0.8) -- equivalent call inferred; original call site unknown
					end)
					local speedMultiplier2 = phas.speedMultiplier or 0.6
					local speedDuration = phas.speedDuration or 3
					speedMultiplier = speedMultiplier2
					object:DelayLogic(speedDuration, function()
						if flag3 then
							speedMultiplier = 1
							hideAllLaneOverlays() -- equivalent call inferred; original call site unknown
						end

						hidePhaseName() -- equivalent call inferred; original call site unknown
					end)
				elseif phas.attackType == "divineWrath" then
					for i = 1, phas.burstCount or 6 do
						object:DelayLogic((i - 1) * 0.06, function()
							if flag3 then
								spawnProjectile(
									random2:NextInteger(1, difficultyConfig.LANES),
									v9[random2:NextInteger(1, #v9)],
									0.4,
									{
										trail = true
									}
								)
								spawnNote()
							end
						end)
					end

					local v95 = (phas.drainRatio or 0.15) * modifier.Value
					local v96 = modifier.Value - v95

					if not object.progressLocked then
						local v97 = math.max(v96, 0)

						if v53 then
							if flag2 then
								modifier.Value = 100 / object.trueprogressefficiency
							else
								v97 = math.min(v97, 99 / object.trueprogressefficiency)
								modifier.Value = v97
							end
						else
							modifier.Value = v97
						end
					end

					spawnScreenFlash(Color3.fromRGB(191, 146, 255), 0.2, 0.5)
					count = 0
					updateCombo()
					local integer = random2:NextInteger(1, difficultyConfig.LANES)
					v74 = integer
					speedMultiplier = phas.speedMultiplier or 0.55
					flashAllLaneOverlays(Color3.fromRGB(255, 255, 255), 0, 0.5) -- equivalent call inferred; original call site unknown
					object.fx:SpawnShake(rhythmGame, 0.8, 0.3, 0.02)
					object:DelayLogic(0.15, function()
						if not flag3 then
							return
						end

						flashAllLaneOverlays(color3, 0.15, 0.65) -- equivalent call inferred; original call site unknown
						flashLaneOverlay(integer, Color3.fromRGB(255, 80, 80), 0.1, 0.55) -- equivalent call inferred; original call site unknown
					end)
					local lockDuration = phas.lockDuration or 3
					local speedDuration = phas.speedDuration or 4
					object:DelayLogic(lockDuration, function()
						if v74 == integer then
							v74 = nil
						end

						local v97 = flag3 and laneOverlays[integer]

						if v97 then
							object.logicTweens:Create(v97, tweenInfo8, {
								BackgroundTransparency = 1
							}):Play()
						end
					end)
					object:DelayLogic(speedDuration, function()
						if flag3 then
							speedMultiplier = 1
							hideAllLaneOverlays() -- equivalent call inferred; original call site unknown
						end

						hidePhaseName() -- equivalent call inferred; original call site unknown
					end)
				end
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function hitWindow(p3: number, p4: number)
			return warmupLerp(p3, p4) * windowShrink + math.clamp(v80 * 0.5, 0, 0.025)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function resetEscalation()
			if olympianDevilBehavior and olympianDevilBehavior.resetOnPerfect then
				total2 = 0
				speedMultiplier = 1
				windowShrink = 1
			end
		end

		local function tryHitLane(p3: number)
			if v81 then
				return
			end

			local now4 = tick()
			local v94 = hitWindow(v35.PERFECT_WINDOW, difficultyConfig.PERFECT_WINDOW) -- equivalent call inferred; original call site unknown
			local v95 = hitWindow(v35.GOOD_WINDOW, difficultyConfig.GOOD_WINDOW) -- equivalent call inferred; original call site unknown
			local v96 = hitWindow(v35.OK_WINDOW, difficultyConfig.OK_WINDOW) -- equivalent call inferred; original call site unknown
			local v97 = nil
			local v98 = 1e999

			for _, v99 in v62 do
				if v99.lane ~= p3 or v99.hit then
					continue
				end

				local v100 = math.abs(now4 - v99.targetTime)

				if not (v100 <= v96 and (not v97 or v99.targetTime < v97.targetTime)) then
					continue
				end

				v98 = v100
				v97 = v99
			end

			if v97 and v98 <= v96 then
				v97.hit = true
				local v99 = math.min(count * difficultyConfig.COMBO_MULTIPLIER, difficultyConfig.MAX_COMBO_BONUS)
				local OK_PROGRESS

				if v97.special then
					local special = v97.special
					OK_PROGRESS = math.max(
						special.progressBonus * difficultyConfig.SPECIAL_NOTE_SCALE,
						difficultyConfig.PERFECT_PROGRESS * 1.5
					) + special.progressBonus + v99
					showFeedback(special.rating)
					count += 1
					resetEscalation() -- equivalent call inferred; original call site unknown

					if special.effectType == "stab" then
						playGameSound(v57, true)
						v63 = tick() + 0.5

						if special.stunTime and object.core and object.core.fish then
							object.core.fish:DelayNextMovement(special.stunTime)
						end

						object.fx:SpawnShake(rhythmGame, 0.35, 0.2, 0.02)
					elseif special.effectType == "freeze" then
						if now4 < v82 then
							v82 = math.max(v82, now4 + (special.freezeDuration or 3))
						else
							v83 = now4
							v82 = now4 + (special.freezeDuration or 3)
						end

						regenPerSecond = special.regenPerSecond or 0

						if chronos then
							playGameSound(chronos, false) -- equivalent call inferred; original call site unknown
						end

						if rhythmMusic and rhythmMusic.IsPlaying then
							rhythmMusic:Pause()
						end

						flashAllLaneOverlays(Color3.fromRGB(100, 200, 255), 0.25, 0.88) -- equivalent call inferred; original call site unknown
						object:DelayLogic(special.freezeDuration or 3, function()
							if flag3 then
								hideAllLaneOverlays() -- equivalent call inferred; original call site unknown
							end
						end)
					elseif special.effectType == "treasure" then
						local v100 = v68

						if v100 then
							v100.hits += 1
							local clank1 = ui:FindFirstChild("clank1")

							if clank1 then
								playGameSound(clank1, true)
							end

							if v100.hits >= v100.required and not v100.locked then
								v100.locked = true

								if v66 then
									v66:FireServer()
								end

								local collect1 = ui:FindFirstChild("collect1")

								if collect1 then
									playGameSound(collect1, false) -- equivalent call inferred; original call site unknown
								end
							end
						end
					end
				elseif v98 <= v94 then
					OK_PROGRESS = difficultyConfig.PERFECT_PROGRESS + v99
					showFeedback(v14)
					local v100 = v60

					if v100 and v100.veiledActive and not object.isPaused then
						v100.currentDanger = math.clamp(v100.currentDanger + -0.5, 0, 100)
					end

					count += 1
					resetEscalation() -- equivalent call inferred; original call site unknown
				else
					if v98 <= v95 then
						OK_PROGRESS = difficultyConfig.GOOD_PROGRESS + v99
						showFeedback(v15)
					else
						OK_PROGRESS = difficultyConfig.OK_PROGRESS
						showFeedback(v16)
					end

					v56 = true
					count += 1
				end

				local v100 = modifier.Value + OK_PROGRESS

				if not object.progressLocked then
					local v101 = math.max(v100, 0)

					if v53 then
						if flag2 then
							modifier.Value = 100 / object.trueprogressefficiency
						else
							v101 = math.min(v101, 99 / object.trueprogressefficiency)
							modifier.Value = v101
						end
					else
						modifier.Value = v101
					end
				end

				flashReceptor(p3, true) -- equivalent call inferred; original call site unknown
				updateCombo()

				if v97.special then
					object.logicTweens:Create(v97.frame, TweenInfo.new(0.2, Enum.EasingStyle.Back), {
						Size = UDim2.fromScale(2, 2),
						ImageTransparency = 1
					}):Play()
				else
					object.logicTweens:Create(v97.frame, tweenInfo4, {
						Size = UDim2.fromScale(1.5, 1.5),
						ImageTransparency = 1
					}):Play()
				end

				object:DelayLogic(0.15, function()
					if v97.frame and v97.frame.Parent then
						v97.frame:Destroy()
					end
				end)
			elseif v55 then
				local flag7 = false

				for _, v100 in v62 do
					if v100.lane == p3 or v100.hit or not (math.abs(now4 - v100.targetTime) <= v96) then
						continue
					end

					flag7 = true
					break
				end

				if flag7 then
					flashReceptor(p3, false) -- equivalent call inferred; original call site unknown
				else
					flashReceptor(p3, false) -- equivalent call inferred; original call site unknown
					local v100 = modifier.Value + difficultyConfig.WRONG_KEY_PENALTY

					if not object.progressLocked then
						local v101 = math.max(v100, 0)

						if v53 then
							if flag2 then
								modifier.Value = 100 / object.trueprogressefficiency
							else
								v101 = math.min(v101, 99 / object.trueprogressefficiency)
								modifier.Value = v101
							end
						else
							modifier.Value = v101
						end
					end

					local v101 = v60

					if v101 and v101.veiledActive and not object.isPaused then
						v101.currentDanger = math.clamp(v101.currentDanger + 5, 0, 100)

						if dangerBar then
							object.fx:SpawnShake(dangerBar, 0.3, 0.2, 0.02)
						end
					end

					count = 0
					updateCombo()
				end
			else
				flashReceptor(p3, false) -- equivalent call inferred; original call site unknown
				local v99 = modifier.Value + difficultyConfig.WRONG_KEY_PENALTY

				if not object.progressLocked then
					local v100 = math.max(v99, 0)

					if v53 then
						if flag2 then
							modifier.Value = 100 / object.trueprogressefficiency
						else
							v100 = math.min(v100, 99 / object.trueprogressefficiency)
							modifier.Value = v100
						end
					else
						modifier.Value = v100
					end
				end

				local v100 = v60

				if v100 and v100.veiledActive and not object.isPaused then
					v100.currentDanger = math.clamp(v100.currentDanger + 5, 0, 100)

					if dangerBar then
						object.fx:SpawnShake(dangerBar, 0.3, 0.2, 0.02)
					end
				end

				count = 0
				updateCombo()
			end
		end

		for i = 1, difficultyConfig.LANES do
			local v94 = i

			v58[i] = function()
				tryHitLane(v94)
			end
		end

		local v94 = {}
		local v95

		if deviceType == "Touch" then
			v95 = v33.DFJK
		else
			v95 = v38.Keyboard
		end

		for k, key in v95.keys do
			v94[key] = k
		end

		if UserInputService.GamepadEnabled or deviceType == "Gamepad" then
			for k, key in v38.Gamepad.keys do
				v94[key] = k
			end
		end

		local function handleInput(_: string, p3, p4)
			if p3 ~= Enum.UserInputState.Begin or not flag3 then
				return Enum.ContextActionResult.Sink
			end

			local v96 = v94[p4.KeyCode]

			if v96 then
				tryHitLane(v96)
			end

			return Enum.ContextActionResult.Sink
		end

		local v96 = {}

		for k, _ in v94 do
			table.insert(v96, k)
		end

		if #v96 > 0 then
			ContextActionService:BindActionAtPriority(
				"TranquilityRodRhythm",
				handleInput,
				false,
				10000,
				table.unpack(v96)
			)
			p.reelTrove:Add(function()
				ContextActionService:UnbindAction("TranquilityRodRhythm")
			end)
		end

		local onLogicStepConnection = object.OnLogicStep:Connect(function(p3)
			if not flag3 then
				return
			end

			v80 = p3
			local now4 = tick()
			local isPaused = object.isPaused or object.logicPaused

			if isPaused then
				if not v84 then
					clone.Enabled = false

					if rhythmMusic.IsPlaying then
						rhythmMusic:Pause()
						flag5 = true
					end
				end

				v85 = now4 + 1
			elseif v84 then
				clone.Enabled = true
			end

			v84 = isPaused
			v81 = isPaused or now4 < v85

			if v81 then
				now += p3
				now2 += p3
				now3 += p3
				v63 += p3

				if now4 < v82 then
					v83 += p3
					v82 += p3
				end

				for k, v97 in v73 do
					v73[k] = v97 + p3
				end

				if v68 then
					v68.nextSpawn += p3
				end
			elseif flag5 then
				flag5 = false

				if v82 <= now4 then
					rhythmMusic:Resume()
					v86 = now4
				end
			end

			local v97 = warmupLerp(v35.MAX_SPAWN_INTERVAL, difficultyConfig.MAX_SPAWN_INTERVAL) -- equivalent call inferred; original call site unknown
			local v98 = warmupLerp(v35.MIN_SPAWN_INTERVAL, difficultyConfig.MIN_SPAWN_INTERVAL) -- equivalent call inferred; original call site unknown
			local v99 = now4 < v82
			local v100 = v99 or v81

			if v87 and not v99 then
				local v101 = v82 - v83

				if v101 > 0 then
					now += v101

					if v72 and not rhythmMusic.IsPlaying then
						rhythmMusic:Resume()
						v86 = now4
					end
				end
			end

			v87 = v99
			local v101 = (olympianDevilBehavior and olympianDevilBehavior.attackType == "olympian" and 2 or 1) * config2.EnchantNoteCooldownScale

			for _, v102 in effects do
				if not (now4 - (v73[v102] or 0) >= v102.cooldown * v101 and v90 == nil) then
					continue
				end

				v90 = v102
				v73[v102] = now4
			end

			if v68 and v67 and v68.remaining > 0 and not v100 and v68.nextSpawn <= now4 and v90 == nil then
				v90 = v67
				v68.remaining -= 1
				v68.nextSpawn = now4 + 2.5

				if not v68.shown then
					v68.shown = true

					if v65 then
						v65:FireServer()
					end
				end
			end

			if v55 then
				local v102 = (now4 - now - total) * specialChartSpeed

				if v53 then
					if v69 > #chart and duration + 2 <= v102 then
						flag2 = true
						modifier.Value = 100 / object.trueprogressefficiency
						flag3 = false

						if object.active then
							object:EndMinigame(true)
						end

						return
					end
				elseif duration <= v102 then
					local NOTE_FALL_TIME = difficultyConfig.NOTE_FALL_TIME
					total += duration / specialChartSpeed + NOTE_FALL_TIME
					v69 = 1

					if v70 then
						chart = v70
						duration = duration2
						audioOffset = audioOffset2
						v70 = nil
					end

					v102 = (now4 - now - total) * specialChartSpeed
					rhythmMusic:Stop()
					v72 = false
				end

				local v103 = (difficultyConfig.NOTE_FALL_TIME + 0.7) * specialChartSpeed
				local timePosition = audioOffset + v102

				if not v72 and not v100 and -v103 <= v102 and timePosition >= 0 then
					v72 = true
					v86 = now4
					rhythmMusic.TimePosition = timePosition

					if v102 < 0 then
						rhythmMusic.Volume = 0
						object.logicTweens:CreateAndPlay(
							rhythmMusic,
							TweenInfo.new(-v102 / specialChartSpeed, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
							{
								Volume = 1
							}
						)
					else
						rhythmMusic.Volume = 1
					end

					rhythmMusic:Play()
				end

				if rhythmMusic.IsPlaying and not v100 and now4 - v86 >= 0.15 then
					local v105 = rhythmMusic.TimePosition - audioOffset - v102

					if math.abs(v105) < 5 then
						count3 += 1
						v88 += (v105 - v88) / math.min(count3, 20)

						if count3 >= 20 then
							if math.abs(v88) > 0.012 then
								flag6 = true
							elseif math.abs(v88) < 0.002 then
								flag6 = false
							end
						end

						if flag6 then
							local v106 = false

							for _, v108 in v62 do
								if v108.hit then
									continue
								end

								v106 = true
								break
							end

							local v108 = not v106 and 1e999 or p3 * 0.08 * specialChartSpeed
							local v109 = math.clamp(v88, -v108, v108)
							local v110 = v109 / specialChartSpeed
							now -= v110
							v102 += v109
							v88 -= v109

							for _, v111 in v62 do
								if v111.hit then
									continue
								end

								v111.spawnTime -= v110
								v111.targetTime -= v110
							end
						end
					end
				else
					count3 = 0
					v88 = 0
					flag6 = false
				end

				if not v100 then
					local v105 = difficultyConfig.NOTE_FALL_TIME * speedMultiplier

					while v69 <= #chart do
						local v106 = chart[v69]

						if v106.time - v105 * specialChartSpeed <= v102 then
							local v107 = now + total + v106.time / specialChartSpeed
							addNote(v106.lane, v107)
							v69 += 1
						else
							break
						end
					end
				end
			elseif not v100 then
				local v102 = now4 - now2

				if MAX_SPAWN_INTERVAL <= v102 then
					spawnNote()
					now2 = now4
					MAX_SPAWN_INTERVAL = math.max(v98, MAX_SPAWN_INTERVAL - difficultyConfig.SPAWN_RATE_INCREASE)
					MAX_SPAWN_INTERVAL = math.min(MAX_SPAWN_INTERVAL, v97)
				end
			end

			if olympianDevilBehavior and not v100 then
				local v102 = olympianDevilBehavior

				if v102.attackType == "darkness" and not (v77 or v75) then
					local forcedDarknessThreshold = v76 and v76.ForcedDarknessThreshold or 60

					if forcedDarknessThreshold <= modifier.Value then
						if not object.progressLocked then
							local v103 = math.max(forcedDarknessThreshold, 0)

							if v53 then
								if flag2 then
									modifier.Value = 100 / object.trueprogressefficiency
								else
									v103 = math.min(v103, 99 / object.trueprogressefficiency)
									modifier.Value = v103
								end
							else
								modifier.Value = v103
							end
						end

						triggerBehaviorAttack()
						now3 = now4
						count4 = 0
					end
				end

				if v102.attackType ~= "escalate" and v102.attackType ~= "shrink" and defaultAttackCooldown <= now4 - now3 then
					count4 += 1

					if v71 + (count4 - 1) * (config2.AttackChanceEscalation / 100) >= random3:NextNumber() then
						triggerBehaviorAttack()
						count4 = 0
					end

					if now3 <= now4 then
						now3 = now4
					end
				end

				if v102.attackType == "escalate" then
					total2 += (v102.escalateRate or 0.03) * p3
					speedMultiplier = math.max(0.4, 1 - total2)
				elseif v102.attackType == "shrink" then
					windowShrink = math.max(0.3, windowShrink - (v102.shrinkRate or 0.005) * p3)
				end

				if v102.drainPerSecond and speedMultiplier < 1 then
					local v103 = modifier.Value - v102.drainPerSecond * p3

					if not object.progressLocked then
						local v104 = math.max(v103, 0)

						if v53 then
							if flag2 then
								modifier.Value = 100 / object.trueprogressefficiency
							else
								v104 = math.min(v104, 99 / object.trueprogressefficiency)
								modifier.Value = v104
							end
						else
							modifier.Value = v104
						end
					end
				end

				local phases = v102.attackType == "olympian" and v79 and v102.phases

				if phases then
					local phas = phases[v78]

					if phas and phas.drainPerSecond then
						local v103 = modifier.Value - phas.drainPerSecond * p3

						if not object.progressLocked then
							local v104 = math.max(v103, 0)

							if v53 then
								if flag2 then
									modifier.Value = 100 / object.trueprogressefficiency
								else
									v104 = math.min(v104, 99 / object.trueprogressefficiency)
									modifier.Value = v104
								end
							else
								modifier.Value = v104
							end
						end
					end
				end
			end

			if v99 and regenPerSecond > 0 then
				local v102 = modifier.Value + regenPerSecond * p3

				if not object.progressLocked then
					local v103 = math.max(v102, 0)

					if v53 then
						if flag2 then
							modifier.Value = 100 / object.trueprogressefficiency
						else
							v103 = math.min(v103, 99 / object.trueprogressefficiency)
							modifier.Value = v103
						end
					else
						modifier.Value = v103
					end
				end
			end

			if not v100 and difficultyConfig.PROGRESS_DRAIN > 0 and v63 <= now4 then
				local v102 = math.clamp((100 - modifier.Value) / 10, 0, 1)
				local v103 = ((difficultyConfig.PROGRESS_DRAIN - 0) * math.clamp(
					(tick() - now) / difficultyConfig.WARMUP_DURATION,
					0,
					1
				) + 0) * v102
				local v104 = modifier.Value - v103 * p3

				if not object.progressLocked then
					local v105 = math.max(v104, 0)

					if v53 then
						if flag2 then
							modifier.Value = 100 / object.trueprogressefficiency
						else
							v105 = math.min(v105, 99 / object.trueprogressefficiency)
							modifier.Value = v105
						end
					else
						modifier.Value = v105
					end
				end
			end

			local v102 = hitWindow(v35.OK_WINDOW, difficultyConfig.OK_WINDOW) -- equivalent call inferred; original call site unknown

			for i = #v62, 1, -1 do
				local v103 = v62[i]

				if v100 and not v103.hit then
					v103.spawnTime += p3
					v103.targetTime += p3
				end

				if not v103.hit then
					local v104 = (now4 - v103.spawnTime) / v103.fallTime
					local v105

					if v42 then
						v105 = scale + (1 - scale) * (1 - v104)
					else
						v105 = scale * v104
					end

					v103.frame.Position = UDim2.fromScale(0.5, v105)

					if v75 and not v103.special then
						local v106 = math.clamp((v104 - 0.45) / 0.15, 0, 1)
						v103.frame.ImageTransparency = 1 - v106 * (1 - imageTransparency)
					end

					if not v100 and v103.targetTime + v102 < now4 then
						v103.hit = true
						v56 = true
						count = 0
						updateCombo()

						if v103.special and v103.special.effectType == "treasure" then
							local v106 = v68

							if v106 and not v106.locked then
								v106.remaining = 0
							end
						end

						showFeedback(v17)
						local v106 = modifier.Value + difficultyConfig.MISS_PENALTY

						if not object.progressLocked then
							local v107 = math.max(v106, 0)

							if v53 then
								if flag2 then
									modifier.Value = 100 / object.trueprogressefficiency
								else
									v107 = math.min(v107, 99 / object.trueprogressefficiency)
									modifier.Value = v107
								end
							else
								modifier.Value = v107
							end
						end

						local v107 = v60

						if v107 and v107.veiledActive and not object.isPaused then
							v107.currentDanger = math.clamp(v107.currentDanger + 15, 0, 100)

							if dangerBar then
								object.fx:SpawnShake(dangerBar, 0.3, 0.2, 0.02)
							end
						end

						object.logicTweens:Create(v103.frame, tweenInfo5, {
							ImageTransparency = 1,
							Position = UDim2.fromScale(0.5, v105 + (v42 and -0.15 or 0.15))
						}):Play()
						local v108 = v103
						object:DelayLogic(0.3, function()
							if v108.frame and v108.frame.Parent then
								v108.frame:Destroy()
							end
						end)
					end
				end

				if not (v103.hit and v103.targetTime + 1 < now4) then
					continue
				end

				if v103.frame and v103.frame.Parent then
					v103.frame:Destroy()
				end

				table.remove(v62, i)
			end

			for i = #v64, 1, -1 do
				local v103 = v64[i]

				if v103.endTime <= now4 or not v103.proj.Parent then
					table.remove(v64, i)
				elseif v103.nextGhost <= now4 then
					v103.nextGhost = now4 + 0.06
					local clone2 = table.remove(clones)

					if not clone2 and attackTemplate and count2 < 24 then
						count2 += 1
						clone2 = attackTemplate:Clone()
					end

					if clone2 then
						local projectile = v103.projectile
						clone2.Image = projectile.image
						clone2.ImageColor3 = projectile.color
						clone2.Size = projectile.size
						clone2.Rotation = projectile.rotation or 0
						clone2.Position = v103.proj.Position
						clone2.ImageTransparency = 0.55
						clone2.Visible = true
						clone2.ZIndex = 9
						clone2.Parent = children[v103.lane]
						local v104 = object.logicTweens:Create(clone2, tweenInfo12, {
							ImageTransparency = 1
						})
						v104.Completed:Once(function()
							clone2.Visible = false
							clone2.Parent = nil
							table.insert(clones, clone2)
						end)
						v104:Play()
					end
				end
			end

			local v103 = math.clamp(object.progress / 100, 0, 1)
			fill.Size = UDim2.fromScale(v103, 1)
			local v104 = v60

			if v104 and v104.veiledActive and dangerBar and fill2 then
				if not v89 then
					v89 = true
					dangerBar.Visible = true
					object.logicTweens:Create(rhythmGame, tweenInfo6, {
						BackgroundTransparency = 0.55
					}):Play()
				end

				local v105 = math.clamp(v104.currentDanger / 100, 0, 1)
				fill2.Size = fill2.Size:Lerp(UDim2.fromScale(v105, 1), (math.clamp(p3 * 12, 0, 1)))
			end
		end)
		p.reelTrove:Add(onLogicStepConnection)
		object:AddCleanupDelay(0.6)
		object.OnMinigameEnd:Once(function()
			flag3 = false
			rhythmMusic:Stop()
			hideAllLaneOverlays() -- equivalent call inferred; original call site unknown

			if not v52 and v50 then
				local v97 = not v56
				table.insert(v11, v97)

				if #v11 > 100 then
					table.remove(v11, 1)
				end

				remoteEvent:FireServer(v97)
			end

			for _, descendant in rhythmGame:GetDescendants() do
				if descendant == laneContainer or table.find(children, descendant) then
					continue
				end

				if descendant:IsA("UIStroke") then
					object.logicTweens:Create(descendant, tweenInfo17, {
						Transparency = 1
					}):Play()
				elseif descendant:IsA("GuiObject") then
					local v97 = {
						BackgroundTransparency = 1
					}

					if descendant:IsA("TextLabel") then
						v97.TextTransparency = 1
					elseif descendant:IsA("ImageLabel") then
						v97.ImageTransparency = 1
					end

					object.logicTweens:Create(descendant, tweenInfo17, v97):Play()
				end
			end

			object.logicTweens:Create(rhythmGame, tweenInfo7, {
				BackgroundTransparency = 1
			}):Play()

			for k, v97 in children do
				object.logicTweens:Create(
					v97,
					TweenInfo.new(k * 0.05 + 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
					{
						Position = v97.Position + UDim2.fromScale(0, 0.5),
						BackgroundTransparency = 1
					}
				):Play()
			end

			for _, v97 in v62 do
				if v97.frame and v97.frame.Parent then
					v97.frame:Destroy()
				end
			end

			table.clear(v62)
		end)
	end)
end

setmetatable(TranquilityRod, module)
return TranquilityRod