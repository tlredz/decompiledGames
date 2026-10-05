local createVector = vector.create
local AdService = game:GetService("AdService")
local CollectionService = game:GetService("CollectionService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local Config = require(ReplicatedStorage.Config)
local FeatureManager = require(ReplicatedStorage._FRAMEWORK.Libraries.FeatureManager)
local Janitor = require(ReplicatedStorage.Utilities.Janitor)
local LoggerManager = require(ReplicatedStorage._FRAMEWORK.Libraries.LoggerManager)
local experiments = require(ReplicatedStorage._FRAMEWORK.Features.experiments)
local remo = require(ReplicatedStorage.Packages.remo)
local BestStage = require(script.BestStage)
local Config2 = require(script.Config)
require(script.Types)
local isServer = RunService:IsServer()
local DataManager

if isServer then
	DataManager = require(ServerScriptService.DataManager)
else
	DataManager = nil
end

local ClientState

if isServer then
	ClientState = nil
else
	ClientState = require(ReplicatedStorage.ClientState)
end

local ClientUi

if isServer then
	ClientUi = nil
else
	ClientUi = require(script.ClientUi)
end

local logger = LoggerManager.createLogger(script.Name, {
	feature = script:GetFullName()
})
local worlds = ReplicatedStorage.Config.Worlds
local configKey = experiments.ongoing.stageReviveUpsell.configKey
local Revive = {
	remotes = remo.createRemotes({
		revive = remo.namespace({
			present = remo.remote(),
			revived = remo.remote(),
			requestRevive = remo.remote().middleware(remo.throttleMiddleware(1)),
			requestBoost = remo.remote().middleware(remo.throttleMiddleware(1)),
			requestAd = remo.remote().middleware(remo.throttleMiddleware(1))
		})
	}).revive,
	bonusAttribute = Config2.BONUS_ATTRIBUTE,
	bonusEndsAttribute = Config2.BONUS_ENDS_ATTRIBUTE
}
local v = false
local maid = nil
local v2 = {}
local v3 = {}
local v4 = {}

local function applySeed(activeData)
	local worldsBestStage = {}

	for _, v6 in BestStage.playableWorlds() do
		worldsBestStage[v6.WORLD] = BestStage.theoretical(
			v6.STAGE_RECOMMENDED_LEVELS,
			activeData.GalaxyProgress[v6.GALAXY_INDEX].Level
		)
	end

	activeData.WorldsBestStage = worldsBestStage
end

local function refreshGalaxy(activeData, p: number)
	local level = activeData.GalaxyProgress[p].Level
	local worldsBestStage = activeData.WorldsBestStage

	for _, v5 in BestStage.playableWorlds() do
		if v5.GALAXY_INDEX == p then
			worldsBestStage[v5.WORLD] = BestStage.theoretical(v5.STAGE_RECOMMENDED_LEVELS, level)
		end
	end
end

local function missingBestStages(items)
	return items == nil or items == false or next(items) == nil
end

local function ensuredData(p)
	local activeData = DataManager:GetActiveData(p)

	if activeData then
		local worldsBestStage = activeData.WorldsBestStage

		if worldsBestStage == nil or worldsBestStage == false or next(worldsBestStage) == nil then
			applySeed(activeData)
		end
	end

	if not activeData or Config.WORLD ~= 3 or activeData.World3Stage15Beaten ~= true then
		return activeData
	end

	local worldsBestStage = activeData.WorldsBestStage
	local v5 = worldsBestStage[Config.WORLD]

	if v5 == nil or v5 < 15 then
		worldsBestStage[Config.WORLD] = 15
	end

	return activeData
end

local function applyTeleport(instance, instance2, object, zone: number)
	local function destinationFor(p: number)
		local cframe = nil

		for _, part in CollectionService:GetTagged("Stage" .. p) do
			if cframe == nil and part:IsA("BasePart") then
				cframe = part.CFrame * CFrame.new(0, 5, 0)
			end
		end

		if cframe ~= nil then
			return cframe
		end

		local spawnLocation = workspace:FindFirstChild("SpawnLocation", true)

		if spawnLocation and spawnLocation:IsA("BasePart") then
			return spawnLocation.CFrame * CFrame.new(0, 5, 0)
		end

		cframe = CFrame.new(0, 10, 0)
		return cframe
	end

	local v5 = destinationFor(zone)
	object.AssemblyLinearVelocity = createVector(0, 0, 0)
	pcall(function()
		object:SetNetworkOwner(nil)
	end)
	local legitTeleport = ServerScriptService:FindFirstChild("LegitTeleport")

	if legitTeleport then
		legitTeleport:Fire(instance.UserId, v5.Position)
	end

	instance2:PivotTo(v5)
	local bypassWinCooldown = ServerScriptService:FindFirstChild("BypassWinCooldown")

	if bypassWinCooldown then
		bypassWinCooldown:Fire(instance.UserId, v5.Position)
	end

	task.delay(0.5, function()
		pcall(function()
			if object.Parent then
				object:SetNetworkOwner(instance)
			end
		end)
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function reapplyWalkSpeed(p)
	local reapplyWalkSpeed2 = ServerScriptService:FindFirstChild("ReapplyWalkSpeed")

	if reapplyWalkSpeed2 then
		reapplyWalkSpeed2:Fire(p)
	end
end

local function startBoost(instance, p: number)
	local v5 = workspace:GetServerTimeNow() + Config2.BOOST_SECONDS
	instance:SetAttribute(Config2.BONUS_ATTRIBUTE, p)
	instance:SetAttribute(Config2.BONUS_ENDS_ATTRIBUTE, v5)
	v4[instance] = v5
	reapplyWalkSpeed(instance) -- equivalent call inferred; original call site unknown
	return v5
end

local function expireBoosts()
	local serverTimeNow = workspace:GetServerTimeNow()

	for k, v5 in v4 do
		if not (not k.Parent or v5 <= serverTimeNow) then
			continue
		end

		v4[k] = nil

		if not k.Parent then
			continue
		end

		k:SetAttribute(Config2.BONUS_ATTRIBUTE, nil)
		k:SetAttribute(Config2.BONUS_ENDS_ATTRIBUTE, nil)
		reapplyWalkSpeed(k) -- equivalent call inferred; original call site unknown
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function clearBoost(player)
	player:SetAttribute(Config2.BONUS_ATTRIBUTE, nil)
	player:SetAttribute(Config2.BONUS_ENDS_ATTRIBUTE, nil)
	v4[player] = nil
end

local function reviveWhenReady(p, p2, flag: boolean)
	-- equivalent calls inferred from this helper; original call sites unknown
	local function checkLiving(player)
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

		if character and humanoid and humanoid.Health > 0 and humanoidRootPart and humanoidRootPart:IsA("BasePart") then
			return true, character, humanoidRootPart
		end

		return false, nil, nil
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function applyRevive(instance, p3, flag2: boolean, p4, p5)
		applyTeleport(instance, p4, p5, p3.zone)
		local bonus, v5

		if flag2 and p3.bonus > 0 then
			bonus = p3.bonus
			v5 = workspace:GetServerTimeNow() + Config2.BOOST_SECONDS
			instance:SetAttribute(Config2.BONUS_ATTRIBUTE, bonus)
			instance:SetAttribute(Config2.BONUS_ENDS_ATTRIBUTE, v5)
			v4[instance] = v5
			reapplyWalkSpeed(instance) -- equivalent call inferred; original call site unknown
		else
			bonus = 0
			v5 = 0
		end

		Revive.remotes.revived:fire(instance, p3.zone, bonus, v5)
	end

	local v5, character2, humanoidRootPart2 = checkLiving(p) -- equivalent call inferred; original call site unknown

	if not v5 then
		task.spawn(function()
			task.wait(1)
			local v8, character, humanoidRootPart = checkLiving(p) -- equivalent call inferred; original call site unknown

			if v8 then
				applyRevive(p, p2, flag, character, humanoidRootPart) -- equivalent call inferred; original call site unknown
			end
		end)
		return
	end

	applyRevive(p, p2, flag, character2, humanoidRootPart2) -- equivalent call inferred; original call site unknown
end

local function grant(p, flag: boolean)
	local v5 = v2[p.UserId]

	if v5 then
		v2[p.UserId] = nil
		reviveWhenReady(p, v5, flag)
	else
		logger:warn(string.format("revive grant with no offer for %s", p.Name))
	end

	return true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function promptProduct(p, p2: number)
	if v2[p.UserId] then
		if p2 == 0 then
			if not v then
				v = true
				logger:warn("REVIVE_WALKSPEED product id is still 0")
			end
		else
			MarketplaceService:PromptProductPurchase(p, p2)
		end
	end
end

local function showAd(p)
	local success, result = pcall(function()
		return AdService:ShowRewardedVideoAdAsync(
			p,
			(AdService:CreateAdRewardFromDevProductId(Config.DEV_PRODUCTS.REVIVE))
		)
	end)

	if not success then
		logger:warn((tostring(result)))
	end
end

local function serverInit()
	for _, v5 in Players:GetPlayers() do
		ensuredData(v5)
	end

	maid = Janitor.new()
	maid:Add(DataManager.profileLoaded:Connect(function(p)
		ensuredData(p)
	end))
	maid:Add(Players.PlayerRemoving:Connect(function(player)
		v2[player.UserId] = nil
		v3[player.UserId] = nil
		clearBoost(player) -- equivalent call inferred; original call site unknown
	end))
	maid:Add(Revive.remotes.requestRevive:connect(function(p)
		promptProduct(p, Config.DEV_PRODUCTS.REVIVE) -- equivalent call inferred; original call site unknown
	end))
	maid:Add(Revive.remotes.requestBoost:connect(function(p)
		promptProduct(p, Config.DEV_PRODUCTS.REVIVE_WALKSPEED) -- equivalent call inferred; original call site unknown
	end))
	maid:Add(Revive.remotes.requestAd:connect(function(p)
		if v2[p.UserId] then
			task.spawn(showAd, p)
		end
	end))
end

local function upsellInterval(p: string)
	local v5 = Config2.UPSELL_RATE[p]
	local v6

	if v5 then
		return (math.floor(100 / v5))
	end

	return v6
end

local function nextUpsellCount(p)
	local v5 = v3[p.UserId]

	if not v5 then
		v5 = {}
		v3[p.UserId] = v5
	end

	if v5[Config.WORLD] == nil then
		v5[Config.WORLD] = 0
	end

	local WORLD = Config.WORLD
	v5[WORLD] += 1
	return v5[Config.WORLD]
end

local function ensureEnrolled(p)
	if not experiments.isPlayerEnrolled(p, configKey) then
		experiments.enroll(p, configKey)
		local v5 = os.clock() + Config2.ENROLL_TIMEOUT

		while p.Parent and not experiments.isPlayerEnrolled(p, configKey) and os.clock() < v5 do
			task.wait()
		end
	end
end

local function checkPresent(p)
	local v5 = ensuredData(p)

	if not v5 or type(Config.WORLD) ~= "number" then
		return false, nil
	end

	ensureEnrolled(p)
	local v6

	if p.Parent then
		local playerVariantGroup = experiments.getPlayerVariantGroup(p, configKey)
		local v7 = Config2.UPSELL_RATE[playerVariantGroup]

		if v7 then
			v6 = math.floor(100 / v7)
		end
	end

	if v6 then
		return true, v5
	end

	return false, nil
end

local function presentOffer(p, p2, zone: number)
	local v5 = p2.WorldsBestStage[Config.WORLD]

	if v5 == nil then
		local module = require(worlds["World" .. Config.WORLD])
		v5 = BestStage.theoretical(module.STAGE_RECOMMENDED_LEVELS, p2.GalaxyProgress[module.GALAXY_INDEX].Level)
		p2.WorldsBestStage[Config.WORLD] = v5
	end

	local level = p2.GalaxyProgress[Config.GALAXY_INDEX].Level
	local bonusWalkspeed = BestStage.bonusWalkspeed(level, zone)
	local v6

	if Config2.EARLY_STAGE_MAX < zone and v5 < BestStage.worldStageCount() then
		v6 = BestStage.isUpsell(zone, v5)
	else
		v6 = false
	end

	local v7 = "short"

	if v6 then
		local v8 = nextUpsellCount(p)
		local playerVariantGroup = experiments.getPlayerVariantGroup(p, configKey)
		local v9 = Config2.UPSELL_RATE[playerVariantGroup]
		local v10

		if v9 then
			v10 = math.floor(100 / v9)
		end

		v7 = (v10 == 1 or v10 ~= nil and v8 % v10 == 1) and "upsell" or v7
	end

	v2[p.UserId] = {
		zone = zone,
		bonus = bonusWalkspeed
	}
	Revive.remotes.present:fire(p, v7, zone, v5, bonusWalkspeed)
end

local function prefetchClientPrices()
	local MarketplaceInfoCache = require(ReplicatedStorage.Utilities.MarketplaceInfoCache)

	for _, v5 in { Config.DEV_PRODUCTS.REVIVE_WALKSPEED, Config.DEV_PRODUCTS.REVIVE } do
		if v5 ~= 0 then
			MarketplaceInfoCache.Prefetch(v5, Enum.InfoType.Product, true)
		end
	end
end

function Revive.walkSpeedWithBonus(instance, p: number)
	local attribute = instance:GetAttribute(Config2.BONUS_ENDS_ATTRIBUTE)
	local attribute2 = instance:GetAttribute(Config2.BONUS_ATTRIBUTE)

	if type(attribute) == "number" and type(attribute2) == "number" and attribute2 > 0 and workspace:GetServerTimeNow() < attribute then
		p = math.min(p + attribute2, Config2.BONUS_SPEED_CAP)
	end

	return p
end

function Revive.applyLocalWalkSpeed()
	assert(not isServer, "revive: client-only call")
	local localPlayer = Players.LocalPlayer
	local character = localPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if humanoid then
		local v5 = ClientState:Get()
		local world3Stage15Beaten

		if Config.WORLD == 3 then
			world3Stage15Beaten = v5.World3Stage15Beaten
		else
			world3Stage15Beaten = false
		end

		local MAX_LEVEL_SPEED_CAP

		if world3Stage15Beaten then
			MAX_LEVEL_SPEED_CAP = Config.MAX_LEVEL_SPEED_CAP
		else
			MAX_LEVEL_SPEED_CAP = Config.CalculateMaxSpeed(v5.Level)
		end

		if type(v5.CustomWalkSpeed) == "number" and v5.CustomWalkSpeed > 0 then
			MAX_LEVEL_SPEED_CAP = v5.CustomWalkSpeed
		end

		local v6 = math.min(MAX_LEVEL_SPEED_CAP + v5.Stage15SpeedBoost, Config.MAX_LEVEL_SPEED_CAP)
		humanoid.WalkSpeed = Revive.walkSpeedWithBonus(localPlayer, v6)
	end
end

function Revive.hasOffer(p)
	return v2[p.UserId] ~= nil
end

function Revive.grantPlain(p)
	assert(isServer, "revive: server-only call")
	local v5 = v2[p.UserId]

	if v5 then
		v2[p.UserId] = nil
		reviveWhenReady(p, v5, false)
	else
		logger:warn(string.format("revive grant with no offer for %s", p.Name))
	end

	return true
end

function Revive.grantBoost(p)
	assert(isServer, "revive: server-only call")
	local v5 = v2[p.UserId]

	if v5 then
		v2[p.UserId] = nil
		reviveWhenReady(p, v5, true)
	else
		logger:warn(string.format("revive grant with no offer for %s", p.Name))
	end

	return true
end

function Revive.noteStage(p, p2: number)
	assert(isServer, "revive: server-only call")
	local v5 = type(Config.WORLD) == "number" and ensuredData(p)

	if v5 then
		local worldsBestStage = v5.WorldsBestStage
		local v6 = worldsBestStage[Config.WORLD]

		if v6 == nil or v6 < p2 then
			worldsBestStage[Config.WORLD] = p2
		end
	end
end

function Revive.noteWinBlock(p, p2: string)
	assert(isServer, "revive: server-only call")
	local stageFromWinBlock = BestStage.stageFromWinBlock(p2)

	if stageFromWinBlock then
		Revive.noteStage(p, stageFromWinBlock)
	end
end

function Revive.onGalaxyAscended(p, p2: number)
	assert(isServer, "revive: server-only call")
	local activeData = DataManager:GetActiveData(p)

	if activeData then
		local worldsBestStage = activeData.WorldsBestStage

		if worldsBestStage == nil or worldsBestStage == false or next(worldsBestStage) == nil then
			applySeed(activeData)
		else
			refreshGalaxy(activeData, p2)
		end
	end
end

function Revive.activeBonus(instance)
	local attribute = instance:GetAttribute(Config2.BONUS_ENDS_ATTRIBUTE)
	local attribute2 = instance:GetAttribute(Config2.BONUS_ATTRIBUTE)
	local v5 = 0

	if type(attribute) == "number" and type(attribute2) == "number" and attribute2 > 0 and workspace:GetServerTimeNow() < attribute then
		return attribute2
	end

	return v5
end

function Revive.pulseBoostLabel()
	if ClientUi then
		ClientUi.pulseBoost()
	end
end

function Revive.tryPresent(p, zone: number)
	assert(isServer, "revive: server-only call")
	local v5, v6 = checkPresent(p)

	if not v5 then
		return false
	end

	presentOffer(p, v6, zone)
	return true
end

FeatureManager.RegisterFeature(script.Name, {
	OnInit = function()
		if isServer then
			serverInit()
		else
			task.spawn(prefetchClientPrices)
		end
	end,
	OnUIInit = function()
		if ClientUi then
			task.spawn(function()
				ClientUi.bind(Revive.remotes, Revive.applyLocalWalkSpeed)
			end)
		end
	end,
	OnUpdate = function()
		if isServer then
			expireBoosts()
		end
	end
})
return Revive