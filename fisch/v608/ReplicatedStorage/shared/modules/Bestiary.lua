local Bestiary = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local RunService = game:GetService("RunService")
local LogService = game:GetService("LogService")
local module = require("./library/fish")
local module2 = require("./library/locations")
local module3 = require("./library/rarities")
local module4 = require("./ApplyOverrideConfig")
local isServer = RunService:IsServer()
local playerDataReplication = nil
local DataService

if isServer then
	local legacyPlayerData = require(ServerScriptService.server.modules.legacyPlayerData)
	local _ = legacyPlayerData.forPlayer
	DataService = require(ServerScriptService.server.legacyServices.DataService)
	local Signal = require(ReplicatedStorage.packages.Signal)
	playerDataReplication = require(ServerScriptService.server.modules.playerDataReplication)
	Bestiary.OnFishDiscovered = Signal.new()
	Bestiary.OnFishUndiscovered = Signal.new()
else
	local module5 = require("../../client/modules/legacyLocalPlayerData")
	local _ = module5.fetch
	DataService = require(ReplicatedStorage.client.legacyControllers.DataController)
end

local v = {}
local v2 = {}
local v3 = false

local function flushBestiarySignals()
	v3 = false

	for k, v4 in v do
		Bestiary.OnFishDiscovered:Fire(k, v4)
	end

	table.clear(v)

	for k, v4 in v2 do
		Bestiary.OnFishUndiscovered:Fire(k, v4)
	end

	table.clear(v2)
end

local bindableEvent = Instance.new("BindableEvent")

local function scheduleFlush(p)
	if not v3 then
		v3 = true
		task.defer(flushBestiarySignals)
	end

	playerDataReplication.replicateSeparate(p, "PlayerBestiary")
end

bindableEvent.Event:Connect(scheduleFlush)

-- equivalent calls inferred from this helper; original call sites unknown
local function enqueue(p, p2, p3)
	local v4 = p[p2]

	if not v4 then
		v4 = {}
		p[p2] = v4
	end

	table.insert(v4, p3)
	bindableEvent:Fire(p2)
end

local anno_bestiary = ReplicatedStorage:WaitForChild("events"):WaitForChild("anno_bestiary")

local function internalFishCountable(p: string, p2: string)
	local v4 = module[p]
	local v5 = module2[p2]

	if v4.SkipInBestiary then
		return false
	end

	if v5.Limited then
		return true
	end

	return not module3.Rarities[v4.Rarity].HideInBestiary and not v4.Unregistered
end

local function resolveBestiaryData(p)
	if typeof(p) == "table" then
		return p
	end

	if not isServer then
		return DataService.BestiaryReplicator:TryIndex({ "Bestiary" })
	end

	local profile = DataService:GetProfile(p)
	return profile and profile.Data.NewFormat.Bestiary
end

local v4 = {}
local v5 = {}

function Bestiary:IsInBestiary(fishName: string, bestiaryName: string)
	if typeof(fishName) ~= "string" then
		return false
	end

	if v4[bestiaryName] then
		return table.find(v4[bestiaryName], fishName) ~= nil
	end

	local v6 = module[fishName]

	if typeof(v6) ~= "table" then
		LogService:Warn("[Bestiary] Unknown fish \"{fishName}\"", {
			fishName = fishName,
			bestiaryName = bestiaryName
		})
		return false
	end

	local v7 = module2[bestiaryName]

	if not v7 then
		return false
	end

	if v7.UseChildrenFish then
		for k, v8 in module2 do
			if k ~= bestiaryName and v8.ParentLocation == bestiaryName and (v6.From == k or v6.FromLimited == k) then
				return Bestiary:IsInBestiary(fishName, k)
			end
		end
	end

	if v6.HideInBestiary then
		return false
	end

	if not v7.Limited then
		if v6.IsLimitedBestiary then
			return false
		end

		if bestiaryName == "All" then
			return v6.Rarity ~= "Limited" and v6.Rarity ~= "Extinct" and v6.Rarity ~= "Special"
		end
	end

	if v6.From and v6.From == bestiaryName or v6.FromLimited and v6.FromLimited == bestiaryName then
		return true
	end

	return v6.From == nil and v6.FromLimited == nil and bestiaryName == "None"
end

function Bestiary:IsFishCountable(p: string, p2: string)
	if v5[p2] then
		return table.find(v5[p2], p) ~= nil
	end

	local isInBestiary = self:IsInBestiary(p, p2)

	if not isInBestiary then
		return isInBestiary
	end

	local v6 = module[p]
	local v7 = module2[p2]

	if v6.SkipInBestiary then
		return false
	end

	if v7.Limited then
		isInBestiary = true
		return true
	end

	if module3.Rarities[v6.Rarity].HideInBestiary or v6.Unregistered then
		return false
	end

	isInBestiary = true
	return true
end

function Bestiary:GetFishInBestiary(p: string)
	if v4[p] then
		return v4[p]
	end

	if not module2[p] then
		return {}
	end

	local result = {}

	for k in module do
		if self:IsInBestiary(k, p) then
			table.insert(result, k)
		end
	end

	v4[p] = result
	return result
end

function Bestiary:GetCountedFishInBestiary(p: string)
	if v5[p] then
		return v5[p]
	end

	debug.profilebegin("Bestiary::GetCountedFishInBestiary")
	local result = {}

	for k in module do
		if self:IsFishCountable(k, p) then
			table.insert(result, k)
		end
	end

	debug.profileend()
	v5[p] = result
	return result
end

function Bestiary:IsFishDiscovered(p, p2: string, flag: boolean?)
	local bestiaryData = resolveBestiaryData(p)

	if not bestiaryData then
		return false, false, false
	end

	local v6 = bestiaryData[p2]

	if not v6 then
		return false, false, false
	end

	if flag or not v6.GivenBy then
		return true, v6.Shiny ~= nil, v6.Sparkling ~= nil
	end

	return false, false, false
end

function Bestiary:GetDiscoveryCounts(p, countedFishInBestiary, flag: boolean?)
	if not resolveBestiaryData(p) then
		return 0, 0, 0
	end

	debug.profilebegin("Bestiary::GetDiscoveryCounts")

	if typeof(countedFishInBestiary) == "string" then
		countedFishInBestiary = self:GetCountedFishInBestiary(countedFishInBestiary)
	end

	local count = 0
	local count2 = 0
	local count3 = 0

	for _, v6 in countedFishInBestiary do
		local isFishDiscovered, v7, v8 = self:IsFishDiscovered(p, v6, flag)

		if isFishDiscovered then
			count += 1
		end

		if v7 then
			count2 += 1
		end

		if v8 then
			count3 += 1
		end
	end

	debug.profileend()
	return count, count2, count3
end

function Bestiary:GetDiscoveryPercentages(p, value, flag: boolean?)
	if not resolveBestiaryData(p) then
		return 0, 0, 0
	end

	local countedFishInBestiary

	if typeof(value) == "string" then
		countedFishInBestiary = self:GetCountedFishInBestiary(value)
	else
		countedFishInBestiary = value
	end

	if #countedFishInBestiary == 0 then
		return 0, 0, 0
	end

	local discoveryCounts, v6, v7 = self:GetDiscoveryCounts(p, value, flag)
	return
		discoveryCounts / #countedFishInBestiary * 100,
		v6 / #countedFishInBestiary * 100,
		v7 / #countedFishInBestiary * 100
end

local isServer2 = RunService:IsServer()

function Bestiary.DiscoverFish(_, player, fishData, sourceId)
	assert(isServer2, "DiscoverFish can only be called on the server!")
	local bestiaryData = resolveBestiaryData(player)

	if not bestiaryData then
		LogService:Warn("[Bestiary] Attempt to discover \"{fishName}\" in {player}'s unloaded Bestiary", {
			fishData = fishData,
			fishName = fishData.Name,
			player = player.Name,
			sourceId = sourceId
		})
		return false
	end

	local v6 = bestiaryData[fishData.Name]
	local flag

	if v6 then
		flag = false
	else
		if sourceId == "_appraisal_" then
			return true
		end

		local name = fishData.Name
		bestiaryData[name] = {
			GivenBy = sourceId ~= nil and sourceId,
			Discovered = os.time(),
			Total = sourceId and 0 or 1
		}
		v6 = bestiaryData[fishData.Name]
		anno_bestiary:FireClient(player, fishData.Name, sourceId and "Discovery From Other Player" or "Catch")
		flag = true
	end

	if not sourceId then
		if v6.GivenBy then
			v6.GivenBy = nil
			anno_bestiary:FireClient(player, fishData.Name, "Rediscovery")
			flag = true
		end

		if v6.Total then
			v6.Total += 1
		else
			v6.Total = 1
		end
	end

	if not sourceId or sourceId == "_appraisal_" and not v6.GivenBy then
		if fishData.Shiny and not v6.Shiny then
			v6.Shiny = os.time()
			anno_bestiary:FireClient(player, fishData.Name, "First Shiny Discovery")
			flag = true
		end

		if fishData.Sparkling and not v6.Sparkling then
			v6.Sparkling = os.time()
			anno_bestiary:FireClient(player, fishData.Name, "First Sparkling Discovery")
			flag = true
		end
	end

	if fishData.Weight then
		local highestWeight = v6.HighestWeight

		if highestWeight then
			if highestWeight < fishData.Weight then
				v6.HighestWeight = fishData.Weight
				anno_bestiary:FireClient(
					player,
					fishData.Name,
					sourceId and sourceId ~= "_appraisal_" and "Highest Weight From Other Player" or "Highest Weight"
				)
				flag = true
			end
		else
			v6.HighestWeight = fishData.Weight
			flag = true
		end
	end

	if flag then
		enqueue(v, player, v6) -- equivalent call inferred; original call site unknown
	end

	return true
end

function Bestiary.UndiscoverFish(_, p, fishName: string)
	assert(isServer2, "UndiscoverFish can only be called on the server!")
	local bestiaryData = resolveBestiaryData(p)

	if not bestiaryData then
		LogService:Warn("[Bestiary] Attempt to un-discover \"{fishName}\" in {player}'s unloaded Bestiary", {
			fishName = fishName,
			player = p.Name
		})
		return false
	end

	if not bestiaryData[fishName] then
		return false
	end

	bestiaryData[fishName] = nil
	enqueue(v2, p, fishName) -- equivalent call inferred; original call site unknown
	return true
end

module4.ConfigChanged:Connect(function(p)
	if p == "OverrideFishData" then
		table.clear(v4)
		table.clear(v5)
	end
end)
return Bestiary