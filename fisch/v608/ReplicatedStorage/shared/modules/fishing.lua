local Fishing = {}
local _ = {
	Trash = 40,
	Common = 20,
	Uncommon = 10,
	Unusual = 5
}
local RunService = game:GetService("RunService")
game:GetService("Debris")
game:GetService("AnalyticsService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local library = ReplicatedStorage.shared.modules:WaitForChild("library")
local zones = require(library:WaitForChild("fish"):WaitForChild("zones"))
local locations = require(library:WaitForChild("locations"))
local crabzone = require(library:WaitForChild("fish"):WaitForChild("zones"):WaitForChild("crabzone"))
local fish = require(library:WaitForChild("fish"))
local rods = require(library:WaitForChild("rods"))
require(library:WaitForChild("rods"):WaitForChild("enchants"))
local bait = require(library:WaitForChild("bait"))
local rarities = require(library:WaitForChild("rarities"))
require(library:WaitForChild("weathers"))
local RodSkins = require(ReplicatedStorage.shared.modules.RodSkins)
local module = require("@self/FishInstance")
require("@self/BiteTypes")
local GeneralUtils = require(ReplicatedStorage.shared.utils.GeneralUtils)
local SharedWeather = require(ReplicatedStorage.shared.modules.SharedWeather)
local fx = require(ReplicatedStorage.shared.modules:WaitForChild("fx"))
local handler = nil
local assets = require(ReplicatedStorage.shared.utils.assets)
local Hook = require(ReplicatedStorage.shared.modules.Hook)
local world = ReplicatedStorage:WaitForChild("world")
local PlayerService = nil
local CurrencyService = nil
local legacyPlayerData = nil
local LifetimeCatchService = nil
local GroupRankService = nil
local Net = require(ReplicatedStorage.packages.Net)
local remoteEvent = Net:RemoteEvent("Notification")
local forPlayer

if RunService:IsServer() then
	require(ReplicatedStorage.shared.modules.FFlags)
	PlayerService = require(game.ServerScriptService.server.legacyServices.PlayerService)
	local ServerScriptService2 = game:GetService("ServerScriptService")
	handler = require(ServerScriptService2.server.player:WaitForChild("data"):WaitForChild("handler"))
	legacyPlayerData = require(ServerScriptService.server.modules.legacyPlayerData)
	CurrencyService = require(ServerScriptService.server.legacyServices.CurrencyService)
	require(ServerScriptService.server.legacyServices.WorldService)
	LifetimeCatchService = require(ServerScriptService.server.legacyServices.LifetimeCatchService)
	GroupRankService = require(ServerScriptService.server.legacyServices.GroupRankService)
	forPlayer = legacyPlayerData.forPlayer
else
	local legacyLocalPlayerData = require(ReplicatedStorage.client.modules.legacyLocalPlayerData)
	forPlayer = legacyLocalPlayerData.fetchWithProfile
end

local packages = ReplicatedStorage:WaitForChild("packages")
local Cache = require(packages.Cache)
_G.ForcedCatches = {}
_G.ForcedCatchMutation = {}
_G.ForcedCatchNew = {}
game.Players.PlayerRemoving:Connect(function(player)
	_G.ForcedCatches[player.UserId] = nil
	_G.ForcedCatchMutation[player.UserId] = nil
	_G.ForcedCatchNew[player.UserId] = nil
end)
local _ = {
	Shiny = 1,
	Sparkling = 1,
	Mutation = 8,
	WeightBoost = 7,
	TreasureMap = 0.005
}

local function debugPrint(items, p)
	local total = 0

	for _, item in pairs(items) do
		total += item
	end

	local v = {}

	for k, item in pairs(items) do
		v[k] = item / total * 100
		warn(k, v[k], "(" .. fish[k].Rarity .. ")")
	end

	warn("+" .. p .. "% Luck")
end

local function findLoweredFish(value)
	for k, _ in pairs(fish) do
		if string.lower(k) == string.lower(value) then
			return k
		end
	end
end

function Fishing.WeldToArm(_, instance, instance2)
	if instance2:FindFirstChild("WeldToArm") then
		return
	end

	local motor6D = Instance.new("Motor6D")
	motor6D.Name = "WeldToArm"
	motor6D.Part0 = instance:FindFirstChild("Right Arm")
	motor6D.Part1 = instance2
	motor6D.C0 = instance2:GetAttribute("OverrideWeldC0") or CFrame.new(-0.151, -1.013, -0.25) * CFrame.Angles(
		-1.5707963267948966,
		-3.141592653589793,
		0
	)
	motor6D.Parent = instance2
end

function Fishing.CastBobber(_, parent, gravity, filterDescendantsInstances, wind, length, visualize)
	local v = {
		obj = parent,
		gravity = gravity,
		whitelist = filterDescendantsInstances,
		wind = wind,
		visualize = visualize,
		maxdist = length,
		params = RaycastParams.new()
	}
	v.params.FilterType = Enum.RaycastFilterType.Include
	v.params.IgnoreWater = false
	v.params.FilterDescendantsInstances = filterDescendantsInstances
	v.obj.Anchored = false

	function v.cast(p4, position, p5, p6, attachment, attachment2, callback)
		task.spawn(function()
			local assemblyLinearVelocity = (p5 - position).Unit * p6 * 20.020408163265305
			local _ = Vector3.new(p4.wind.X, p4.wind.Y - p4.gravity * 9.8, p4.wind.Z) * 20.020408163265305
			v.obj.CFrame = CFrame.new(position)
			v.obj.AssemblyLinearVelocity = assemblyLinearVelocity

			local function CreateRope()
				local ropeConstraint = Instance.new("RopeConstraint")
				ropeConstraint.Parent = parent
				ropeConstraint.Restitution = 0
				ropeConstraint.Visible = false
				ropeConstraint.Length = length
				ropeConstraint.Parent = parent
				ropeConstraint.Attachment0 = attachment
				ropeConstraint.Attachment1 = attachment2

				if callback then
					local heartbeatConnection = nil
					heartbeatConnection = RunService.Heartbeat:Connect(function()
						if not heartbeatConnection then
							return
						end

						if ropeConstraint.CurrentDistance > ropeConstraint.Length + 3 then
							heartbeatConnection:Disconnect()
							heartbeatConnection = nil
							callback()

							if game.PlaceId ~= 16732694052 then
								warn("Cancelling cast for far distance")
							end
						end
					end)
					ropeConstraint.Destroying:Once(function()
						if heartbeatConnection then
							heartbeatConnection:Disconnect()
							heartbeatConnection = nil
						end
					end)
				end
			end

			v.obj.Anchored = false
			CreateRope()
		end)
	end

	return v
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getChance(mutation)
	if typeof(mutation.Chance) == "function" then
		return mutation.Chance()
	end

	return mutation.Chance
end

local function sumofchance(items)
	local total = 0

	for _, item in items do
		total += item
	end

	return total
end

local v = {
	Generic_ReelRecolor = true,
	["The Brick Rod"] = true,
	CocoRod = true,
	["Prismatic Rod"] = true
}
local v2 = {
	R0bWhitelist = true,
	Generic_GroupWhitelist = true
}

local function handleOP(copy)
	local copy2 = GeneralUtils.copy(rods[copy.OP_Fallback or "No-Life Rod"], true)
	copy2.Color = copy.Color
	copy2.BobberTop = copy.BobberTop
	copy2.BobberBottom = copy.BobberBottom
	copy2.Icon = copy.Icon
	copy2.Description = copy.Description
	copy2.DEV = copy.DEV
	copy2.Unregistered = copy.Unregistered
	copy2.Unpurchasable = copy.Unpurchasable
	copy2.Modes = copy.Modes
	copy2.ReelGuiName = copy.ReelGuiName
	local fishingPassives = copy2.FishingPassives
	local fishingPassives2 = copy.FishingPassives

	if fishingPassives2 and fishingPassives then
		if fishingPassives2.Generic_FallingWeapon and fishingPassives.Generic_FallingWeapon then
			local generic_FallingWeapon = fishingPassives.Generic_FallingWeapon
			local generic_FallingWeapon2 = fishingPassives2.Generic_FallingWeapon
			generic_FallingWeapon2.TriggerChance = generic_FallingWeapon.TriggerChance
			generic_FallingWeapon2.ProgressGain = generic_FallingWeapon.ProgressGain
			generic_FallingWeapon2.ProgressGainSplit = generic_FallingWeapon.ProgressGainSplit
			generic_FallingWeapon2.ProgressGainSplitInterval = generic_FallingWeapon.ProgressGainSplitInterval
			generic_FallingWeapon2.ProgressGainFinalMultiplier = generic_FallingWeapon.ProgressGainFinalMultiplier
			fishingPassives.Generic_FallingWeapon = generic_FallingWeapon2
		end

		if fishingPassives2.Generic_Laser and fishingPassives.Generic_Laser then
			local generic_Laser = fishingPassives.Generic_Laser
			local generic_Laser2 = fishingPassives2.Generic_Laser
			generic_Laser2.TriggerChance = generic_Laser.TriggerChance
			generic_Laser2.ProgressGain = generic_Laser.ProgressGain
			fishingPassives.Generic_Laser = generic_Laser2
		end

		for k in v2 do
			if fishingPassives2[k] then
				fishingPassives[k] = fishingPassives2[k]
			end
		end
	end

	local clientFishingPassives = copy2.ClientFishingPassives
	local clientFishingPassives2 = copy.ClientFishingPassives

	if clientFishingPassives2 then
		if not clientFishingPassives then
			copy2.ClientFishingPassives = {}
			clientFishingPassives = copy2.ClientFishingPassives
		end

		if clientFishingPassives2.Generic_Slashes and clientFishingPassives.Generic_Slashes then
			local generic_Slashes = clientFishingPassives.Generic_Slashes
			local _ = clientFishingPassives2.Generic_Slashes
			generic_Slashes.AnimTime = clientFishingPassives2.AnimTime
			generic_Slashes.SoundName = clientFishingPassives2.SoundName
			generic_Slashes.SoundPitch = clientFishingPassives2.SoundPitch
			generic_Slashes.IconName = clientFishingPassives2.IconName
			generic_Slashes.IconColor = clientFishingPassives2.IconColor
			generic_Slashes.GradientColor = clientFishingPassives2.GradientColor
			generic_Slashes.IconSizeFull = clientFishingPassives2.IconSizeFull
			generic_Slashes.IconSizeEnd = clientFishingPassives2.IconSizeEnd
			generic_Slashes.IconRotation = clientFishingPassives2.IconRotation
		end

		for k in v do
			if clientFishingPassives2[k] then
				clientFishingPassives[k] = clientFishingPassives2[k]
			end
		end
	end

	copy2.Durability = copy.Durability
	return copy2
end

function Fishing:GetRodStats(instance, p: string)
	local rod = rods[p]

	if not (rod and typeof(rod) == "table") then
		return nil
	end

	local v3, v4 = forPlayer(instance)

	if not (v3 and v4) then
		return rod
	end

	local copy = GeneralUtils.copy(rod, true)
	local newFormat = v4.Data.NewFormat or v4.Data
	local rods2 = newFormat.Rods

	if not rods2 then
		return rod
	end

	local rod2 = rods2[p]

	if not rod2 then
		return rod
	end

	if v4 and newFormat.RodEnhancements[p] then
		for k, v5 in newFormat.RodEnhancements[p] do
			if v5 and copy.EnhancementPatches[k] then
				copy = GeneralUtils.applyTable(copy, copy.EnhancementPatches[k], true)
			end
		end
	end

	if v4 and copy.Modes then
		local mode = rod2.mode or copy.DefaultMode
		local patches = copy.Modes[mode] and copy.Modes[mode].Patches

		if patches then
			copy = GeneralUtils.applyTable(copy, patches, true)
		end
	end

	local skin = rod2.skin

	if skin and RodSkins.Skins[skin] and RodSkins.Skins[skin].RodPatches then
		copy = GeneralUtils.applyTable(copy, RodSkins.Skins[skin].RodPatches, true)
	end

	if copy.OP then
		if instance:GetAttribute("CanUseOP") == nil then
			print("Waiting for CanUseOP")
			instance:GetAttributeChangedSignal("CanUseOP"):Wait()
		end

		if not instance:GetAttribute("CanUseOP") then
			rod = rods[rod.OP_Fallback or "No-Life Rod"] or rod
			copy = handleOP(copy)
		end
	end

	if v4 and newFormat.RodUpgrades and newFormat.RodUpgrades[p] then
		for k, v5 in newFormat.RodUpgrades[p] do
			if not (v5 and v5 ~= 0) then
				continue
			end

			local v6 = rod[k]

			if not (v6 and math.isfinite(v6)) then
				continue
			end

			if k == "LureSpeed" then
				v6 = 100 - v6
				k = "Lure"
			end

			if v6 < 0 then
				v5 = -v5 or v5
			end

			local v7 = v6 * v5
			local v8

			if k == "Control" or k == "ProgressEfficiency" or k == "ForcedProgressEfficiency" then
				v8 = math.round(v7 * 100) / 100
			else
				v8 = math.round(v7)
			end

			copy[k] = (copy[k] or 0) + v8
		end
	end

	if v4 and newFormat.ActiveSpirits and rod.FishingPassives and rod.FishingPassives.Spirits then
		for k, spirit in rod.FishingPassives.Spirits.Spirits do
			local v5 = spirit.StatBoost and spirit.StatBoost[1]

			if v5 then
				copy[v5] = (copy[v5] or 0) + (newFormat.ActiveSpirits[k] or 0)
			end
		end
	end

	if copy.FixedStats then
		for k, fixedStat in copy.FixedStats do
			copy[k] = fixedStat
		end
	end

	return copy
end

Fishing.GetTargetedLuck = Hook.new(function(p, p2, p3)
	return p, p2, p3, 0
end)
Fishing.HookNaturalFishPool = Hook.direct()
Fishing.BuildFishPool = Hook.new(function(p, p2)
	if not p2.FishPool then
		p2.FishPool = {}
	end

	return p, p2
end)
Fishing.HookFinalFishPool = Hook.new(function(p, p2)
	if not p2.FishPool then
		p2.FishPool = {}
	end

	return p, p2
end)
Fishing.BuildNaturalMutationPool = Hook.new(function(p, p2)
	return p, p2, {}
end)
Fishing.ShouldAllowBobber = Hook.new(function(p, p2)
	return p, p2, true
end)

function Fishing:GetStatsTemplate()
	return {
		Luck = 0,
		LuckMultiply = 1,
		Strength = 0,
		Lure = 0,
		Resilience = 0,
		Control = 0,
		XpMultiply = 1,
		BaitPreserveChance = 0,
		LineDistance = 0,
		Durability = 0,
		Disturbance = 1,
		Scavenging = 0,
		ShakeSize = 100,
		ShakePower = 100,
		PowerEfficiency = 100,
		BaitEffectiveness = 1,
		TimeEffectiveness = 1,
		WeatherEffectiveness = 1,
		SeasonEffectiveness = 1,
		ProgressSpeed = 0,
		ForcedProgressSpeed = 0,
		TrueProgressSpeed = 0,
		StartingProgress = 20,
		WeightBoost = 0,
		NaturalMutationChance = 8,
		MutationChanceBoost = 0,
		ShinyChance = 1,
		SparklingChance = 1
	}
end

function Fishing.BuildBaseMeta(p, biteArgs)
	local v3, v4 = legacyPlayerData.forPlayer(p)
	local stats = v3:WaitForChild("Stats")
	local rod = biteArgs.Rod or stats:WaitForChild("rod").Value
	local rod2 = v4.Data.NewFormat.Rods[rod]
	local skin = rod2.skin
	local keeperboundEnchant = rod2.keeperboundActive and rod2.keeperboundEnchant
	local keeperboundAffixes = not rod2.keeperboundActive and {} or rod2.keeperboundAffixes or {}
	local FishingRodService = require(ServerScriptService.server.legacyServices.FishingRodService)
	local rod3 = FishingRodService:GetRod(p)
	local BaitService = require(ServerScriptService.server.legacyServices.BaitService)
	local equipped = BaitService:GetEquipped(p)
	local sourceType = biteArgs.SourceType or biteArgs.PassiveCapture and "entity" or "catch"
	local v6 = {
		MetaType = "rod",
		Zone = biteArgs.Zone,
		ZoneName = biteArgs.ZoneName or biteArgs.Zone and biteArgs.Zone.Name,
		Roamers = biteArgs.Roamers,
		Rod = rod,
		RodSkin = skin,
		RodServer = rod3,
		Bait = equipped,
		Perfect = nil,
		PerfectCast = biteArgs.PerfectCast,
		CastPower = biteArgs.CastPower,
		FishPosition = rod3 and rod3.Bobber and rod3.Bobber.Position,
		ReelGuiName = "default",
		ShakeButtonName = "default",
		BiteArgs = biteArgs,
		BiteStats = Fishing:GetStatsTemplate(),
		EventFlags = {},
		IsKeeperbound = rod2.keeperboundActive or false,
		Enchant = keeperboundEnchant or rod2.enchant,
		SecondaryEnchant = 0,
		KeeperboundAffixes = 0,
		KeeperboundPower = 0,
		SourceType = 0,
		SourceName = 0,
		PreferredDisturbance = 0
	}
	local secondaryEnchant

	if not rod2.keeperboundActive then
		secondaryEnchant = rod2.secondaryEnchant
	end

	v6.SecondaryEnchant = secondaryEnchant
	v6.KeeperboundAffixes = keeperboundAffixes
	v6.KeeperboundPower = rod2.power or 0
	v6.SourceType = sourceType
	v6.SourceName = biteArgs.SourceName or "StandardCatch"
	v6.PreferredDisturbance = {}
	return p, v6
end

Fishing.BuildBiteMeta = Hook.new(Fishing.BuildBaseMeta)
Fishing.BuildBiteMeta:BindAtPriority(0, function(p, state)
	local rodStats = Fishing:GetRodStats(p, state.Rod)
	local biteStats = state.BiteStats
	state.ReelGuiName = rodStats.ReelGuiName
	state.ShakeButtonName = rodStats.ShakeButtonName

	for k, rodStat in rodStats do
		if typeof(rodStat) == "number" and biteStats[k] then
			biteStats[k] += rodStat
		end
	end

	biteStats.ProgressSpeed += (rodStats.ProgressEfficiency or 0) * 100
	biteStats.ForcedProgressSpeed += (rodStats.ForcedProgressEfficiency or 0) * 100
	biteStats.Lure += 100 - (rodStats.LureSpeed or 0)

	if rodStats.InstantCatch then
		biteStats.Lure = 9000000000
	end

	if rodStats.PreferredDisturbance then
		if not state.PreferredDisturbance then
			state.PreferredDisturbance = {}
		end

		state.PreferredDisturbance[rodStats.PreferredDisturbance.Event] = (state.PreferredDisturbance[rodStats.PreferredDisturbance.Event] or 0) + rodStats.PreferredDisturbance.Risk
	end

	return p, state
end)
local v3 = {
	Luck = 0.25,
	Lure = 0.25,
	XpMultiply = 0.5
}

function Fishing.ApplyBaitStats(p, data)
	local v4 = data.Bait and bait[data.Bait]

	if v4 then
		for k, v5 in v4 do
			if not (typeof(v5) == "number" and data.BiteStats[k]) then
				continue
			end

			data.BiteStats[k] += v5 * data.BiteStats.BaitEffectiveness * (data.MetaType ~= "cage" and 1 or v3[k] or 1)
		end
	end

	if not data.BiteStats.LuckMultiply then
		return p, data
	end

	data.BiteStats.LuckMultiply += world.luck_Server.Value == 1 and 0 or world.luck_Server.Value
	data.BiteStats.LuckMultiply += world.luck_ServerSide.Value + (world.luck_Luck.Value - 1)
	return p, data
end

function Fishing.ApplyZoneStats(p, data)
	local v4 = data.MetaType == "cage" and crabzone or zones

	if data.BiteStats.Luck then
		if data.Zone and data.Zone:FindFirstChild("lucky") then
			data.BiteStats.Luck += 55
		end

		if data.Zone and data.Zone:FindFirstChild("poolluck") then
			data.BiteStats.Luck += data.Zone:FindFirstChild("poolluck").Value
		end
	end

	local v5 = v4[data.ZoneName]

	if not v5 then
		return p, data
	end

	if v5.FishingStats then
		for k, fishingStat in v5.FishingStats do
			if not (typeof(fishingStat) == "number" and data.BiteStats[k]) then
				continue
			end

			data.BiteStats[k] += fishingStat
		end
	end

	if not v5.FishingStatsMultiply then
		return p, data
	end

	for k, v6 in v5.FishingStatsMultiply do
		if not (typeof(v6) == "number" and data.BiteStats[k]) then
			continue
		end

		data.BiteStats[k] *= v6
	end

	return p, data
end

if RunService:IsServer() then
	PlayerService.HookAllBuildMeta:AddHook(Fishing.BuildBiteMeta)
	PlayerService.HookAllBuildMeta:BindAtPriority(1000, Fishing.ApplyBaitStats)
	PlayerService.HookAllBuildMeta:BindAtPriority(2000, Fishing.ApplyZoneStats)
end

Fishing.BuildBiteMeta:BindAtPriority(1000000, function(p, p2)
	local rodStats = Fishing:GetRodStats(p, p2.Rod)

	if rodStats.FixedStats then
		for k, fixedStat in rodStats.FixedStats do
			p2.BiteStats[k] = fixedStat
		end
	end

	return p, p2
end)
Fishing.GetTargetedLuck:BindAtPriority(0, function(p, p2, p3, total)
	if p2.Bait and bait[p2.Bait] and (typeof(p3.FavouriteBait) == "table" and table.find(p3.FavouriteBait, p2.Bait) or p3.FavouriteBait == p2.Bait) then
		total += bait[p2.Bait].PreferredLuck * p2.BiteStats.BaitEffectiveness
	end

	return p, p2, p3, total
end)

local function isLimitedWindowActive(p: string)
	local location = locations[p]

	if not (location and location.StartTime and location.EndTime) then
		return true
	end

	local serverTimeNow = workspace:GetServerTimeNow()
	return location.StartTime.UnixTimestamp <= serverTimeNow and serverTimeNow < location.EndTime.UnixTimestamp
end

function Fishing.BuildStrictChancePool(p, data)
	local v4 = 100

	for _, v5 in data.FishPool do
		v4 -= v5
	end

	if v4 <= 0 then
		return p, data
	end

	local v5 = {}
	local total = 0

	for k, v6 in pairs(fish) do
		if not (typeof(v6) == "table" and type(v6.GlobalStrictChance) == "number") then
			continue
		end

		if v6.FromLimited then
			local location = locations[v6.FromLimited]
			local v7

			if location and location.StartTime and location.EndTime then
				local serverTimeNow = workspace:GetServerTimeNow()

				if location.StartTime.UnixTimestamp <= serverTimeNow then
					v7 = serverTimeNow < location.EndTime.UnixTimestamp
				else
					v7 = false
				end
			else
				v7 = true
			end

			if not v7 then
				continue
			end
		end

		if not ((not v6.MaximumLifetimeCatches or LifetimeCatchService:CanCatch(p, k)) and v6.WeightPool[1] / 10 <= data.BiteStats.Strength) then
			continue
		end

		if not ((data.BiteArgs.PassiveCapture or data.SourceType == "catch" and 5 or 0) >= v6.BlockPassiveCapture and (data.MetaType ~= "cage" or v6.AllowCrabCageGlobal)) then
			continue
		end

		v5[k] = (v5[k] or 0) + v6.GlobalStrictChance
		total += v6.GlobalStrictChance
	end

	local v6 = data.MetaType == "cage" and crabzone or zones

	if data.ZoneName and v6[data.ZoneName].Pool then
		local overrideZoneContents

		if data.BiteArgs.OverrideZoneContents then
			overrideZoneContents = data.BiteArgs.OverrideZoneContents
		else
			local v7 = v6[data.ZoneName]
			overrideZoneContents = table.clone(v7.Pool or {})

			if data.Zone and data.Zone.Name == data.ZoneName and data.Zone:FindFirstChild("Abundance") and fish[data.Zone.Abundance.Value] and not (v7.IsHunt or table.find(
				overrideZoneContents,
				data.Zone.Abundance.Value
			)) then
				table.insert(overrideZoneContents, data.Zone.Abundance.Value)
			end

			if data.Roamers then
				for _, roamer in data.Roamers do
					if not table.find(overrideZoneContents, roamer:GetAttribute("FishName")) then
						table.insert(overrideZoneContents, roamer:GetAttribute("FishName"))
					end
				end
			end
		end

		for _, overrideZoneContent in overrideZoneContents do
			local v7 = fish[overrideZoneContent]

			if typeof(v7) == "table" and typeof(v7.StrictZoneChance) == "number" and (not v7.MaximumLifetimeCatches or LifetimeCatchService:CanCatch(
				p,
				overrideZoneContent
			)) and v7.WeightPool[1] / 10 <= data.BiteStats.Strength and (data.BiteArgs.PassiveCapture or data.SourceType == "catch" and 5 or 0) >= v7.BlockPassiveCapture and not (v7.BlockRods and table.find(
				v7.BlockRods,
				data.Rod
			)) then
				v5[overrideZoneContent] = (v5[overrideZoneContent] or 0) + v7.StrictZoneChance
				total += v7.StrictZoneChance
			end

			if not (data.Bait and bait[data.Bait] and bait[data.Bait].FixedChanceFish and bait[data.Bait].FixedChanceFish[overrideZoneContent]) then
				continue
			end

			if not (v7.WeightPool[1] / 10 <= data.BiteStats.Strength and (data.BiteArgs.PassiveCapture or data.SourceType == "catch" and 5 or 0) >= v7.BlockPassiveCapture) then
				continue
			end

			v5[overrideZoneContent] = (v5[overrideZoneContent] or 0) + bait[data.Bait].FixedChanceFish[overrideZoneContent]
			total += bait[data.Bait].FixedChanceFish[overrideZoneContent]
		end
	end

	if data.Roamers then
		for _, roamer in data.Roamers do
			local fishName = roamer:GetAttribute("FishName")

			if not (fishName and v5[fishName]) then
				continue
			end

			local v7 = fish[fishName]

			if not v7 then
				continue
			end

			if v7.Rarity == "Divine Secret" then
				v5[fishName] *= 1000
			else
				local chanceGroup = v7.ChanceGroup or rarities.Rarities[v7.Rarity].ChanceGroup

				if chanceGroup and rarities.ChanceGroups[chanceGroup] then
					v5[fishName] *= rarities.ChanceGroups[chanceGroup].RoamerChanceMultiplier
				end
			end
		end
	end

	local v7 = not (v4 < total) and 1 or v4 / total

	for k, v8 in v5 do
		data.FishPool[k] = (data.FishPool[k] or 0) + v8 * v7
	end

	return p, data
end

function Fishing.BuildDefaultPool(player, state)
	if state.BiteArgs.SkipDefaultPool then
		return player, state
	end

	local v4 = 100

	for _, v5 in state.FishPool do
		v4 -= v5
	end

	if v4 <= 0 then
		return player, state
	end

	local _ = player.Character
	local v5 = (state.MetaType == "cage" and crabzone or zones)[state.ZoneName] or {}
	local overrideZoneContents

	if state.BiteArgs.OverrideZoneContents then
		overrideZoneContents = state.BiteArgs.OverrideZoneContents
	else
		overrideZoneContents = table.clone(v5.Pool or {})

		if state.Zone and state.Zone.Name == state.ZoneName and state.Zone:FindFirstChild("Abundance") and fish[state.Zone.Abundance.Value] and not (v5.IsHunt or table.find(
			overrideZoneContents,
			state.Zone.Abundance.Value
		)) then
			table.insert(overrideZoneContents, state.Zone.Abundance.Value)
		end

		if state.Roamers then
			for _, roamer in state.Roamers do
				if not table.find(overrideZoneContents, roamer:GetAttribute("FishName")) then
					table.insert(overrideZoneContents, roamer:GetAttribute("FishName"))
				end
			end
		end
	end

	local v6 = {}
	local v7 = {}
	local weightedPool = {}

	for k, orderedChanceGroup in rarities.OrderedChanceGroups do
		v6[k] = orderedChanceGroup.BaseChance * (not v5.RarityBaseChanceBoosts and 1 or v5.RarityBaseChanceBoosts[orderedChanceGroup.Name] or 1)
	end

	local total = 0
	local v9 = true
	local v10 = {}
	local v11 = {}
	local v12 = {}
	local luck = state.BiteStats.Luck

	if state.Bait and bait[state.Bait] then
		for _, overrideZoneContent in overrideZoneContents do
			local v14 = fish[overrideZoneContent]

			if not (v14 and (typeof(v14.FavouriteBait) == "table" and table.find(v14.FavouriteBait, state.Bait) or v14.FavouriteBait == state.Bait)) then
				continue
			end

			luck += bait[state.Bait].PreferredLuck
			break
		end
	end

	local v13 = luck * (1 + (state.BiteStats.LuckMultiply - 1) / 4)

	for i = #rarities.OrderedChanceGroups, 1, -1 do
		local orderedChanceGroup = rarities.OrderedChanceGroups[i]
		local v14 = v6[i] + v13 / 100 * orderedChanceGroup.LuckFactor * (not v5.RarityLuckFactorBoosts and 1 or v5.RarityLuckFactorBoosts[orderedChanceGroup.Name] or 1)
		v12[i] = {}
		local total2 = 0

		for _, overrideZoneContent in overrideZoneContents do
			local v15 = fish[overrideZoneContent]

			if not v15 then
				continue
			end

			local chanceGroup = v15.ChanceGroup or rarities.Rarities[v15.Rarity].ChanceGroup

			if v15.Chance <= 0 or chanceGroup ~= orderedChanceGroup.Name then
				continue
			end

			if v15.WeightPool[1] / 10 > state.BiteStats.Strength or ((state.BiteArgs.PassiveCapture or state.SourceType == "catch" and 5 or 0) < v15.BlockPassiveCapture or v15.BlockRods and table.find(
				v15.BlockRods,
				state.Rod
			)) then
				continue
			end

			total2 += v15.Chance
			v12[i][overrideZoneContent] = v15.Chance / (v15.FinalChanceDivisor or 1)

			if v9 and v15.Rarity ~= "Limited" then
				v9 = false
			end
		end

		if total2 > 0 then
			v10[i] = math.max(v14, 0) + total
			v11[i] = total2
			total = 0
		else
			total += v14
		end
	end

	if total > 0 then
		if (v10[2] or 0) > 0 then
			v10[2] += total
		elseif not v9 then
			for _, v14 in zones.Default.Pool do
				v12[1][v14] = fish[v14].Chance
			end

			v10[1] = total
		end
	end

	for i = #rarities.OrderedChanceGroups, 1, -1 do
		local v14 = v11[i]
		local v15 = v10[i]

		if not (v14 and v14 > 0 and v15) then
			continue
		end

		for k, v16 in v12[i] do
			v7[k] = math.max(v16 / v14 * v15, v16 / 2000)
		end
	end

	for _, overrideZoneContent in ipairs(overrideZoneContents) do
		if not (fish[overrideZoneContent] and fish[overrideZoneContent].StrictZoneChance == nil) then
			continue
		end

		local v14 = fish[overrideZoneContent]
		local rarity = rarities.Rarities[v14.Rarity]

		if not (v14.WeightPool[1] / 10 <= state.BiteStats.Strength and (not v14.MaximumLifetimeCatches or LifetimeCatchService:CanCatch(
			player,
			overrideZoneContent
		))) then
			continue
		end

		if not ((state.BiteArgs.PassiveCapture or state.SourceType == "catch" and 5 or 0) >= v14.BlockPassiveCapture) or v14.BlockRods and table.find(
			v14.BlockRods,
			state.Rod
		) then
			continue
		end

		local _ = v14.Chance
		local v15 = v7[overrideZoneContent] or 0
		local _ = state.BiteStats.Luck
		local _ = state.BiteStats.LuckMultiply
		local _, _, _, v16 = Fishing.GetTargetedLuck:InvokeAsync(player, state, v14)
		local v17 = 1 * (rarity.FinalChanceDivisor or 1) * (v14.FinalChanceDivisor or 1)

		if v16 > 0 then
			local chanceGroup = rarities.ChanceGroups[rarity.ChanceGroup]

			if chanceGroup and chanceGroup.LuckFactor > 0 then
				v15 += v16 / 79 * chanceGroup.LuckFactor * (not v5.RarityLuckFactorBoosts and 1 or v5.RarityLuckFactorBoosts[rarity.ChanceGroup] or 1) * (1 + (state.BiteStats.LuckMultiply - 1) / 4)
			else
				v15 *= 1 + v16 / 100 / v17
			end
		end

		if state.Bait and bait[state.Bait] and (typeof(v14.FavouriteBait) == "table" and table.find(
			v14.FavouriteBait,
			state.Bait
		) or v14.FavouriteBait == state.Bait) then
			v15 *= 1 + 0.1 * state.BiteStats.BaitEffectiveness
		end

		if v14.Seasons and #v14.Seasons > 0 and v14.Seasons[1] ~= "None" then
			if table.find(v14.Seasons, world.season.Value) then
				v15 *= math.max(1 + 0.2 * state.BiteStats.SeasonEffectiveness, 0)
			else
				v15 *= math.max(1 + -0.1 * state.BiteStats.SeasonEffectiveness, 0)
			end
		end

		if SharedWeather.IsAnyActive(v14.Weather) then
			v15 *= math.max(1 + 0.35 * state.BiteStats.WeatherEffectiveness)
		end

		if state.Zone then
			local abundance = state.Zone:FindFirstChild("Abundance")

			if abundance then
				local value = tostring(abundance.Value)
				local chance = abundance:FindFirstChild("Chance")

				if value ~= "Mutation" then
					local v18 = false
					local v19

					if string.sub(value, 1, 10) == "__series__" then
						v19 = false
						local parts = value:sub(11):split("_")

						if table.find(parts, overrideZoneContent) then
							v18 = true
						end
					else
						v19 = true
					end

					if v19 and value == overrideZoneContent or v18 then
						if chance then
							v15 *= 1 + chance.Value / 100
						else
							v15 *= 1.7
						end
					end
				end
			end
		end

		if v14.FavouriteTime ~= nil and v14.FavouriteTime ~= "None" then
			if world.cycle.Value ~= v14.FavouriteTime then
				v15 *= math.max(1 + -0.75 * state.BiteStats.TimeEffectiveness, 0)
			end

			if v14.FavouriteTime == "Night" and world.event.Value == "Night of the Fireflies" then
				v15 *= 2
			end
		end

		weightedPool[overrideZoneContent] = math.max(v15, 0)
	end

	if state.Roamers then
		for _, roamer in state.Roamers do
			local fishName = roamer:GetAttribute("FishName")

			if not (fishName and weightedPool[fishName]) then
				continue
			end

			local v14 = fish[fishName]

			if typeof(v14) ~= "table" then
				continue
			end

			local chanceGroup = v14.ChanceGroup or rarities.Rarities[v14.Rarity].ChanceGroup

			if chanceGroup and rarities.ChanceGroups[chanceGroup] then
				weightedPool[fishName] *= rarities.ChanceGroups[chanceGroup].RoamerChanceMultiplier
			end
		end
	end

	state.WeightedPool = weightedPool
	Fishing.HookNaturalFishPool:InvokePcallAsync(player, state, weightedPool)
	local total2 = 0

	for _, v14 in weightedPool do
		total2 += v14
	end

	if total2 <= 0 then
		weightedPool.Rock = 1
		weightedPool.Log = 1
		weightedPool.Seaweed = 1
		weightedPool.Tire = 1
		total2 = 4
	end

	for k, v14 in weightedPool do
		state.FishPool[k] = (state.FishPool[k] or 0) + v14 / total2 * v4
	end

	return player, state
end

Fishing.BuildFishPool:BindAtPriority(0, Fishing.BuildDefaultPool)
Fishing.BuildFishPool:BindAtPriority(-6000, Fishing.BuildStrictChancePool)
Fishing.BuildNaturalMutationPool:BindAtPriority(0, function(p, p2, chances)
	local module2 = require("@self/mutations")
	local mutations = module2.Mutations

	for k, mutation in pairs(mutations) do
		if not module2:CanNaturalCatch(k, p2.Enchant == "Wormhole" and "_wormhole_" or p2.ZoneName or "") then
			continue
		end

		local chance = getChance(mutation) -- equivalent call inferred; original call site unknown
		chances[k] = chance
	end

	return p, p2, chances
end)

function Fishing.Bite(_, player, options)
	local rod = options.Rod
	local character, playerFromCharacter

	if player:IsA("Player") then
		character = player.Character
		local tool = character:FindFirstChildWhichIsA("Tool")

		if tool and rods[tool.Name] then
			if not rod then
				rod = tool.Name
			end
		else
			if not rod then
				local v4, _ = legacyPlayerData.forPlayerSafe(player)
				rod = v4:WaitForChild("Stats"):WaitForChild("rod").Value
				options.Rod = rod
			end

			player.Backpack:FindFirstChild(rod)
		end

		playerFromCharacter = player
	else
		character = player.Parent
		playerFromCharacter = game.Players:GetPlayerFromCharacter(character)

		if not rod then
			rod = player.Name
		end
	end

	local v4 = options or {}
	local v5, v6 = legacyPlayerData.forPlayerSafe(playerFromCharacter)

	if not v5 then
		warn((`Bite called for {playerFromCharacter and playerFromCharacter.Name or "???"}, whose data is not currently loaded`))
		return nil, {
			Rod = rod,
			SourceType = v4.PassiveCapture and "entity" or "catch",
			SourceName = rod
		}
	end

	if handler and handler:CheckFull(playerFromCharacter) then
		return nil, {
			Rod = rod,
			SourceType = v4.PassiveCapture and "entity" or "catch",
			SourceName = rod
		}
	end

	if not (rod and rods[rod]) then
		warn((`Unknown fishing rod "{rod}" passed to :Bite`))
		return nil, {
			Rod = rod,
			SourceType = v4.PassiveCapture and "entity" or "catch",
			SourceName = rod
		}
	end

	local _, v7 = Fishing.BuildBiteMeta:InvokePcallAsync(playerFromCharacter, v4)

	if v4.OverrideFishPool then
		v7.FishPool = v4.OverrideFishPool
	else
		Fishing.BuildFishPool:InvokePcallAsync(playerFromCharacter, v7)
	end

	Fishing.HookFinalFishPool:InvokePcallAsync(playerFromCharacter, v7)
	local _, _, v8 = Fishing.ShouldAllowBobber:InvokePcallAsync(playerFromCharacter, v7)

	if v8 == false then
		return nil, v7
	end

	if not character or not v7.ZoneName or not zones[v7.ZoneName] or v7.Zone and not v7.Zone.Parent then
		return
	end

	local zone = zones[v7.ZoneName]

	if zone.CustomCondition and v6 and not playerFromCharacter:GetAttribute("BypassProgressionChecks") then
		local customCondition, v9 = zone.CustomCondition(playerFromCharacter, v6, v5)

		if not customCondition then
			remoteEvent:FireClient(playerFromCharacter, v9, 10, "error")
			return nil, v7
		end
	end

	local _ = zone.Pool

	if v7.Bait and v7.Bait ~= "None" and v7.SourceType == "catch" and RunService:IsServer() then
		PlayerService.HasFishWithBait:Fire(playerFromCharacter, v7.Bait)
	end

	local function getfish(fishPool)
		local random = Random.new()
		local total = 0

		for _, item in fishPool do
			total += item
		end

		local number = random:NextNumber(0, total)

		for k, item in pairs(fishPool) do
			if number <= item then
				return k
			else
				number -= item
			end
		end
	end

	local function roundNumber(p, value)
		return (tonumber(string.format("%." .. (value or 0) .. "f", p)))
	end

	if not next(v7.FishPool) then
		return nil, v7
	end

	local result = module.new()
	result:SetMeta(v7)
	local zone2 = v7.Zone

	if zone2 and zone2:FindFirstChild("NewAbundances") then
		for _, child in zone2.NewAbundances:GetChildren() do
			local v10 = fish[child.Name]

			if not v10 or (v10.WeightPool[1] / 10 > v7.BiteStats.Strength or Random.new():NextNumber(0, 100) > child.Value) then
				continue
			end

			local _ = child.Name
			break
		end
	end

	result.Name = getfish(v7.FishPool)
	local v9 = fish[result.Name]

	if _G.ForcedCatches[playerFromCharacter.UserId] ~= nil and tostring(_G.ForcedCatches[playerFromCharacter.UserId]) and findLoweredFish(tostring(_G.ForcedCatches[playerFromCharacter.UserId])) ~= nil then
		result.Name = findLoweredFish(tostring(_G.ForcedCatches[playerFromCharacter.UserId]))
		_G.ForcedCatches[playerFromCharacter.UserId] = nil
	end

	if v9.WeightPool[2] - v9.WeightPool[1] > 0 and math.random(10, 1000) / 10 <= 7 * ReplicatedStorage:WaitForChild("world"):WaitForChild("luck_Weight").Value then
		if math.random(1, 2) == 1 then
			result:WeightBoost(math.random(11, 21) / 10)
		else
			result:WeightBoost(math.random(11, 15) / 10)
		end
	end

	result:WeightBoost(1 + v7.BiteStats.WeightBoost / 100)
	result:AddShinyChance(v7.BiteStats.ShinyChance)
	result:AddSparklingChance(v7.BiteStats.SparklingChance)
	local _, _, v10 = Fishing.BuildNaturalMutationPool:InvokeAsync(playerFromCharacter, v7)
	local total = 0

	for _, v11 in v10 do
		total += v11
	end

	local v11 = {}

	for k, v12 in v10 do
		v11[k] = v12 / total * v7.BiteStats.NaturalMutationChance
	end

	result:AddMutationPool(v11)
	result.CaughtBy = playerFromCharacter.UserId or nil

	if _G.ForcedCatchMutation[playerFromCharacter.UserId] then
		if _G.ForcedCatchMutation[playerFromCharacter.UserId] == "Shiny" then
			result.Shiny = true
		elseif _G.ForcedCatchMutation[playerFromCharacter.UserId] == "Sparkling" then
			result.Sparkling = true
		elseif _G.ForcedCatchMutation[playerFromCharacter.UserId] == "Glitched" then
			result.Glitched = true
		else
			result.Mutation = _G.ForcedCatchMutation[playerFromCharacter.UserId]
		end

		_G.ForcedCatchMutation[playerFromCharacter.UserId] = nil
	end

	if v7.BiteStats.Strength <= 0.001 then
		remoteEvent:FireClient(
			playerFromCharacter,
			"<font color=\"#D20103\">Your rod is too weak... Try a stronger rod or enchanting.</font>",
			10,
			"error"
		)
		return nil, v7
	end

	if _G.ForcedCatchNew[playerFromCharacter.UserId] then
		for k, v12 in _G.ForcedCatchNew[playerFromCharacter.UserId] do
			if v12 == "None" then
				v12 = nil
			end

			result[k] = v12
		end

		_G.ForcedCatchNew[playerFromCharacter.UserId] = nil
	end

	if not v4.IgnoreRemote then
		PlayerService.OnFishLured:Fire(playerFromCharacter, result, v7)
	end

	return result, v7
end

function Fishing:ReloadRod(player, flag, p)
	if flag == nil then
		flag = false
	end

	local v4, v5 = legacyPlayerData.forPlayer(player)
	local stats = v4:WaitForChild("Stats")

	if stats and player.Character then
		if player:FindFirstChild("Backpack") then
			local FishingRodService = require(ServerScriptService.server.legacyServices.FishingRodService)

			if (p == false or p == nil) and not FishingRodService:CanChange(player) then
				return false
			end

			local backpack = player:FindFirstChild("Backpack")
			local name = stats.rod.Value
			local character = player.Character

			if not rods[name] then
				return
			end

			for _, tool in pairs(character:GetChildren()) do
				if not (tool:IsA("Tool") and rods[tool.Name]) then
					continue
				end

				tool.Parent = backpack
				tool:Destroy()
			end

			for _, child in pairs(backpack:GetChildren()) do
				if rods[child.Name] then
					child:Destroy()
				end
			end

			local rods2 = v5.Data.NewFormat.Rods
			local rod = rods2[name]

			if rod then
				local v6 = v5.Data.NewFormat.RemovedRodData[name] or {}
				local skin = rod.skin

				if not skin then
					rod.skin = v6.Skin or "Default"
				end

				if skin ~= "Default" and not (RodSkins.RodsSkins.All[skin] or v5.Data.NewFormat.RodSkins[skin] and RodSkins.RodsSkins[name] and RodSkins.RodsSkins[name][skin]) then
					rod.skin = "Default"
				end

				if rod.randomSkin then
					local rodsSkin = RodSkins.RodsSkins[name]

					if rodsSkin then
						local rodSkins = v5.Data.NewFormat.FavoritedEquipment.RodSkins
						local rodSkins2 = v5.Data.NewFormat.RodSkins
						local v7 = {}
						local v8 = {}

						for k in rodsSkin do
							if not rodSkins2[k] then
								continue
							end

							if rodSkins[k] then
								table.insert(v7, k)
							else
								table.insert(v8, k)
							end
						end

						if rodSkins[`Default/{name}`] then
							table.insert(v7, "Default")
						else
							table.insert(v8, "Default")
						end

						if #v7 > 0 then
							rod.skin = v7[math.random(1, #v7)]
						elseif #v8 > 0 then
							rod.skin = v8[math.random(1, #v8)]
						end
					end
				end

				if not rod.enchant then
					rod.secondaryEnchant = v6.SecondaryEnchant or "none"
				end

				if rod.favorited == nil then
					rod.favorited = v6.Favorited or false
				end

				if not rod.caught then
					rod.caught = v6.Caught or 0
				end

				local tool = Instance.new("Tool")
				tool.CanBeDropped = false
				tool.RequiresHandle = false
				tool.ToolTip = "fisch"
				tool.Name = name
				local v7

				if rod.skin == "Default" then
					v7 = false
				else
					v7 = assets.getImmediate("skin", rod.skin)
				end

				local overrideModelName = rod.mode and rods[name].Modes and rods[name].Modes[rod.mode] and rods[name].Modes[rod.mode].OverrideModelName
				local clone

				if rod.skin == "Default" or not (v7 and v7:FindFirstChild("Skin")) then
					local async = assets.getAsync("rod", name)

					if async and not (overrideModelName and async:FindFirstChild(overrideModelName)) then
						overrideModelName = name
					end

					local flimsyRod = async and async:FindFirstChild(overrideModelName or name)

					if not flimsyRod then
						warn((`Failed to load model for {name}, defaulting to Flimsy Rod`))
						flimsyRod = assets.getAsync("rod", "Flimsy Rod"):FindFirstChild("Flimsy Rod")
					end

					clone = flimsyRod:Clone()
				else
					local v8 = not (overrideModelName and v7:FindFirstChild(overrideModelName)) and "Skin" or overrideModelName
					clone = (v8 and v7:FindFirstChild(v8) or v7:WaitForChild("Skin")):Clone()
				end

				if clone.PrimaryPart ~= nil then
					clone.PrimaryPart.Name = "handle"
				end

				for _, v8 in clone:QueryDescendants(".BodyModelOnly") do
					v8:Destroy()
				end

				for _, child in pairs(clone:GetChildren()) do
					child.Parent = tool
				end

				for _, child in script:WaitForChild("rodresources"):GetChildren() do
					local clone_2 = child:Clone()
					clone_2.Parent = tool
				end

				for _, sound in tool:GetDescendants() do
					if not sound:IsA("Sound") then
						continue
					end

					sound:SetAttribute("Owner", player.Name)
					sound:SetAttribute("OriginalVolume", sound.Volume)
					sound:AddTag("FishingSound")
				end

				tool.Parent = player:FindFirstChildWhichIsA("Backpack")
				FishingRodService:LoadRod(player, tool)

				if flag then
					return true
				end

				return nil
			else
				if not rods2["Flimsy Rod"] then
					Fishing:GiveRodItem(player, "Flimsy Rod", false)
				end

				stats.rod.Value = "Flimsy Rod"
				Fishing:ReloadRod(player, nil, true)
			end
		end
	else
		warn("!! COULD NOT FIND CORRECT INFO FOR " .. tostring(player.Name) .. " ROD HAS NOT BEEN RELOADED.")
	end
end

function Fishing.HasRod(_, p, p2: string)
	local _, v4 = legacyPlayerData.forPlayer(p)
	local rods2 = v4.Data.NewFormat.Rods

	if rods2 then
		return rods2[p2] ~= nil
	end

	return false
end

function Fishing.HasRodThatsNotRestricted(_, p, p2: string)
	local _, v4 = legacyPlayerData.forPlayer(p)
	local rods2 = v4.Data.NewFormat.Rods
	return not not rods2 and rods2[p2] ~= nil and rods2[p2].enchant ~= "Restricted"
end

function Fishing:GiveRodItem(player, name: string, flag: boolean, p2: number?)
	if name == "Debug Rod" and not GroupRankService:HasMinimumRole(player, "Developer") then
		warn((`{player.Name} does not have the sufficient permissions to have Debug Rod!`))
		return nil
	end

	local ServerScriptService2 = game:GetService("ServerScriptService")
	require(ServerScriptService2.server.legacyServices:WaitForChild("FunnelsService"))
	local _, v4 = legacyPlayerData.forPlayer(player)
	local rods2 = v4.Data.NewFormat.Rods

	if not rods2 then
		return
	end

	if rods2[name] then
		return rods2[name]
	end

	if not rods[name] and v4 then
		table.insert(v4.Data.NewFormat.FailedRewards, {
			Type = "Rod",
			Name = name,
			Amount = 1,
			Time = os.time()
		})
		return nil
	end

	local v5 = v4.Data.NewFormat.RemovedRodData[name] or {}
	rods2[name] = {
		caught = v5.Caught or 0,
		enchant = v5.Enchant or "none",
		favorited = v5.Favorited or false,
		secondaryEnchant = v5.SecondaryEnchant or "none",
		skin = v5.Skin or "Default",
		admin = p2 or nil
	}
	v4.Data.NewFormat.RemovedRodData[name] = nil

	if flag then
		ReplicatedStorage:WaitForChild("events"):WaitForChild("anno_unlock"):FireClient(player, name)
	end

	PlayerService.OnRodGiven:Fire(player, name)
	return rods2[name]
end

function Fishing:SellFish(player, p2, p3)
	if p3 == nil then
		p3 = false
	end

	if RunService:IsClient() and not p3 then
		return nil
	end

	local v4 = fish[p2.name]
	local price = v4.Price
	local v5

	if p2.sub.Weight then
		v5 = math.ceil(p2.sub.Weight / (v4.WeightPool[2] / 10) * price)
	else
		warn("!! FISH DOES NOT HAVE WEIGHT VALUE")
		v5 = math.ceil(v4.WeightPool[1] / 10 / (v4.WeightPool[2] / 10) * price)
	end

	if p2.sub.Shiny then
		v5 *= 1.85
	end

	if p2.sub.Sparkling then
		v5 *= 1.85
	end

	local price2 = p2.sub.Glitched and 0 or v5

	if p2.sub.Mutation then
		local module2 = require("@self/mutations")
		local mutations = module2.Mutations

		if mutations[p2.sub.Mutation] then
			if p2.sub.Mutation == "Seasonal" then
				local season = p2.sub.Season

				if season then
					local value = season.Value

					if value == "Spring" then
						price2 *= 4.5
					elseif value == "Winter" then
						price2 *= 2.5
					elseif value == "Autumn" then
						price2 *= 4
					end
				end
			else
				price2 *= mutations[p2.sub.Mutation].PriceMultiply
			end
		end
	end

	if Cache:Get("ServerBoost") and not v4.BuyMult then
		price2 *= Cache:Get("ServerBoost"):Get("C$") or 1
	end

	if p3 == false then
		local clone = table.clone(p2.sub)
		clone.Stack = nil
		handler:RemoveItem(player, p2.name, clone, 1)

		if legacyPlayerData.forPlayerSafe(player) then
			local StatusEffectsService = require(ServerScriptService.server.legacyServices.StatusEffectsService)
			local effectsOfType = StatusEffectsService:GetEffectsOfType(player, "Currency")
			local total = 0

			for _, v7 in effectsOfType do
				total += v7.Data.BoostValue
			end

			price2 += price2 * total
			CurrencyService:Increase(player, (math.ceil(price2)))
		end

		local ServerScriptService2 = game:GetService("ServerScriptService")
		require(ServerScriptService2.server.legacyServices:WaitForChild("FunnelsService")):TrackLogOnboardingFunnel(
			player,
			5,
			"Fish Sold"
		)

		if player.Character and player.Character:FindFirstChild("Torso") then
			fx:PlaySound(
				ReplicatedStorage:WaitForChild("resources"):WaitForChild("sounds"):WaitForChild("sfx"):WaitForChild("player"):WaitForChild("sellFish"),
				player.Character:FindFirstChild("Torso"),
				true
			)
			fx:EmitParticles(
				ReplicatedStorage:WaitForChild("resources"):WaitForChild("replicated"):WaitForChild("fx"):WaitForChild("sellParticle"),
				player.Character:FindFirstChild("Torso"),
				math.random(2, 5)
			)
		end
	end

	self.price = price2
	return price2
end

function Fishing.GetRandomUniqueFishes(_, p: string, p2: number, flag: boolean?, list)
	local zone = zones[p]

	if not (zone and zone.Pool) then
		return
	end

	local pool = {}

	if list and #list > 0 then
		for _, v4 in zone.Pool do
			if not table.find(list, v4) then
				table.insert(pool, v4)
			end
		end
	else
		pool = zone.Pool
	end

	local count = #pool

	if count == 0 then
		return
	end

	local v4 = math.min(p2, count)

	if flag and v4 <= count / 4 then
		local result = table.create(v4)
		local v5 = {}

		while #result < v4 do
			local v6 = math.random(count)

			if v5[v6] then
				continue
			end

			v5[v6] = true
			result[#result + 1] = pool[v6]
		end

		return result
	else
		local clone = table.clone(pool)

		for i = #clone, 2, -1 do
			local v5 = math.random(i)
			local v6 = clone[v5]
			local v7 = clone[i]
			clone[i] = v6
			clone[v5] = v7
		end

		local result = table.create(v4)

		for i = 1, v4 do
			result[i] = clone[i]
		end

		return result
	end
end

function Fishing.GetRandomWeightedUniqueFishes(_, p, p2, p3: number, list)
	local _, v4 = Fishing.BuildBiteMeta:InvokePcallAsync(p, p2)

	if not v4 then
		return
	end

	Fishing.BuildFishPool:InvokePcallAsync(p, v4)
	Fishing.HookFinalFishPool:InvokePcallAsync(p, v4)
	local weightedPool = v4.WeightedPool

	if not (weightedPool and next(weightedPool)) then
		return
	end

	local v5 = {}
	local total = 0

	for k, v6 in weightedPool do
		if table.find(list, k) then
			continue
		end

		v5[k] = v6
		total += v6
	end

	if total == 0 then
		return
	end

	local v6 = {}
	local v7 = {}

	for _ = 1, p3 do
		if not next(v5) then
			break
		end

		local total2 = 0

		for k, v8 in v5 do
			if not v6[k] then
				total2 += v8
			end
		end

		if total2 == 0 then
			break
		end

		local v8 = math.random() * total2
		local total3 = 0

		for k, v10 in v5 do
			if v6[k] then
				continue
			end

			total3 += v10

			if not (v8 <= total3) then
				continue
			end

			table.insert(v7, k)
			v6[k] = true
			break
		end
	end

	return #v7 > 0 and v7 or nil, weightedPool
end

return Fishing