local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local BunchaIcons = require(ReplicatedStorage.CAM.Global.BunchaIcons)
local HudGrid = require(ReplicatedStorage.CAM.HudGrid)
local MinigameSettings = require(ReplicatedStorage.CAM.Global.MinigameSettings)
local Restrictions = require(ReplicatedStorage.CAM.Global.Restrictions)
local SettingsLive = require(ReplicatedStorage.CAM.Global.SettingsLive)
local VipAccess = require(ReplicatedStorage.CAM.Global.VipAccess)
local Rating = require(script.Rating)
local Rules = require(script.Rules)
local ranked = MinigameSettings.Settings.PvP.Ranked
local Ranked = {
	Rating = Rating,
	Rules = Rules,
	TOURNEY = "Tourney",
	MINIGAME = "PvP",
	VERIFIED = "RankedVerified",
	Live = SettingsLive.new("Ranked", ranked, SettingsLive.surface(ranked))
}

function Ranked.KeyFor(p: string, value: string?)
	if p == Ranked.TOURNEY then
		return (`{Ranked.TOURNEY}:{value or ""}`)
	end

	return p
end

function Ranked.BucketOfKey(value: string)
	return string.match(value, (`^{Ranked.TOURNEY}:(.+)$`))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isBreathing(p: string)
	local Breathings = require(ReplicatedStorage.CAM.Global.Powers.Breathings)
	return Breathings[p] ~= nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isDemonArt(p: string)
	local DemonArts = require(ReplicatedStorage.CAM.Global.Powers.DemonArts)
	return DemonArts[p] ~= nil
end

function Ranked.PowersOf(instance)
	local v = {}

	if instance == nil then
		return v
	end

	local powers = instance:FindFirstChild("Powers")

	if powers == nil then
		return v
	end

	local value = instance.Race.Value
	local breathing = powers:FindFirstChild("Breathing")

	if value ~= "Demon" and breathing ~= nil and breathing.Value ~= "" and isBreathing(breathing.Value) then
		v.Breathing = breathing.Value
	end

	local demonArt = powers:FindFirstChild("DemonArt")

	if (value == "Demon" or value == "Hybrid") and demonArt ~= nil and demonArt.Value ~= "" and isDemonArt(demonArt.Value) then
		v.DemonArt = demonArt.Value
	end

	return v
end

function Ranked.BucketOf(p)
	local powers = Ranked.PowersOf(p)
	return powers.Breathing or powers.DemonArt
end

function Ranked.MatchKeys()
	local result = {}

	for k, v in HudGrid.Grid do
		if v.Ranked == true and v.Minigame == Ranked.MINIGAME and k ~= Ranked.TOURNEY then
			table.insert(result, k)
		end
	end

	table.sort(result)
	return result
end

function Ranked.Keys()
	local result = Ranked.MatchKeys()
	local Breathings = require(ReplicatedStorage.CAM.Global.Powers.Breathings)

	for _, v in { Breathings, require(ReplicatedStorage.CAM.Global.Powers.DemonArts) } do
		for k in v do
			table.insert(result, Ranked.KeyFor(Ranked.TOURNEY, k))
		end
	end

	table.sort(result)
	return result
end

function Ranked.IsKey(p: string)
	local bucketOfKey = Ranked.BucketOfKey(p)

	if bucketOfKey == nil then
		if p == Ranked.TOURNEY then
			return false
		end

		local v = HudGrid.ByName[p]
		return v ~= nil and v.Ranked == true and v.Minigame == Ranked.MINIGAME
	else
		local breathing = isBreathing(bucketOfKey) -- equivalent call inferred; original call site unknown

		if not breathing then
			breathing = isDemonArt(bucketOfKey)
		end

		return breathing
	end
end

Ranked.BANNED = "Banned"

function Ranked.Verified(instance, p: string)
	if Restrictions.Has(instance, Restrictions.RANKED) then
		return Ranked.BANNED
	end

	if RunService:IsStudio() then
		return true
	end

	if not RunService:IsServer() then
		return (instance:GetAttribute(Ranked.VERIFIED))
	end

	local setting = MinigameSettings.Settings[p]
	local verifiedLevel

	if not (setting == nil or setting.Ranked == nil) then
		verifiedLevel = setting.Ranked.VerifiedLevel
	end

	if verifiedLevel == nil then
		return false
	end

	if VipAccess.Tenured(instance) then
		return true
	end

	local success, result = pcall(instance.IsVerified, instance, verifiedLevel)

	if success then
		return result == true
	end

	warn((`[Ranked] IsVerified failed for {instance.Name}: {result}`))
	return nil
end

function Ranked.LockedUntil(instance)
	local ranked2

	if instance ~= nil then
		ranked2 = instance:FindFirstChild("Ranked")
	end

	local lockedUntil

	if ranked2 ~= nil then
		lockedUntil = ranked2:FindFirstChild("LockedUntil")
	end

	if lockedUntil == nil then
		return 0
	end

	return lockedUntil.Value
end

function Ranked.Reason(p, p2: string?, value: number?)
	if p == Ranked.BANNED then
		if p2 == nil then
			return "You are banned from playing ranked"
		end

		return (`{p2} is banned from playing ranked`)
	elseif p == nil then
		if p2 == nil then
			return "Ranked data isn't ready, try again"
		end

		return (`{p2}'s ranked data isn't ready, try again`)
	elseif p == true then
		local v = (value or 0) - os.time()

		if not (v > 0) then
			return nil
		end

		local v2 = math.ceil(v / 60)

		if p2 == nil then
			return (`You left a ranked match: locked for {v2}m`)
		end

		return (`{p2} left a ranked match: locked for {v2}m`)
	elseif p2 == nil then
		return "Verify your Roblox account or have VIP for a month to play ranked"
	else
		return (`{p2} must verify their Roblox account or have VIP for a month for ranked`)
	end
end

function Ranked.Season(p: number?)
	return Rules.Season(p)
end

function Ranked.Previous(p: string)
	return Rules.Previous(p)
end

function Ranked.SeasonLabel(p: string?)
	return Rules.SeasonLabel(p or Rules.Season())
end

function Ranked.SeasonEnds(p: number?)
	return Rules.SeasonEnds(p)
end

function Ranked.Display(p: number)
	return Rules.Display(ranked, p)
end

function Ranked.TierOf(p: number)
	return Rules.TierOf(ranked, p)
end

function Ranked.IconOf(p: number)
	local _, v = Rules.TierOf(ranked, p)
	local rank = BunchaIcons.Ranks[v.Name]

	if rank == nil or rank == "" then
		return nil
	end

	return rank
end

function Ranked.HighestTier(instance)
	local ranked2

	if instance ~= nil then
		ranked2 = instance:FindFirstChild("Ranked")
	end

	local modes

	if ranked2 ~= nil then
		modes = ranked2:FindFirstChild("Modes")
	end

	if modes == nil then
		return nil
	end

	local season = Ranked.Season()
	local v = nil

	for _, child in modes:GetChildren() do
		local points = child:FindFirstChild("Points")
		local placements = child:FindFirstChild("Placements")
		local season2 = child:FindFirstChild("Season")

		if points == nil or placements == nil or placements.Value < ranked.PlacementCount or not (season2 == nil or season2.Value == season) then
			continue
		end

		local tier = Rules.TierOf(ranked, points.Value)

		if v == nil or v < tier then
			v = tier
		end
	end

	return v
end

function Ranked.HighestIcon(p)
	local highestTier = Ranked.HighestTier(p)

	if highestTier == nil then
		return nil
	end

	return (Ranked.IconOf(ranked.Tiers[highestTier].Threshold))
end

function Ranked.ProgressBar(p: number, p2: number)
	local tiers = ranked.Tiers
	local tier, v = Rules.TierOf(ranked, p2)
	local tier2 = tiers[tier + 1]

	-- equivalent calls inferred from this helper; original call sites unknown
	local function fraction(p3: number)
		if tier2 == nil then
			return 1
		end

		return (math.clamp((p3 - v.Threshold) / (tier2.Threshold - v.Threshold), 0, 1))
	end

	local tier3 = Rules.TierOf(ranked, p)
	local v2 = {
		From = tier3 < tier and 0 or tier < tier3 and 1 or fraction(p),
		To = fraction(p2),
		StartIcon = Ranked.IconOf(p2),
		EndIcon = 0,
		StartName = 0,
		EndName = 0
	}
	local endIcon

	if tier2 ~= nil then
		endIcon = Ranked.IconOf(tier2.Threshold)
	end

	v2.EndIcon = endIcon
	v2.StartName = v.Name
	local endName

	if tier2 ~= nil then
		endName = tier2.Name
	end

	v2.EndName = endName
	return v2
end

function Ranked.Placed(p)
	return Rules.Placed(ranked, p)
end

function Ranked.Apply(p, p2, p3: number, p4: number, p5: number)
	return Rules.Apply(ranked, p, p2, p3, p4, p5)
end

function Ranked.Delta(p, p2, p3: number)
	return Rules.Delta(ranked, p, p2, p3)
end

function Ranked.Margin(p: number, p2: number)
	return Rules.Margin(ranked, p, p2)
end

function Ranked.PruneRecent(p, p2: number)
	return Rules.PruneRecent(ranked, p, p2)
end

function Ranked.Dampened(p, p2, p3: number)
	return Rules.Dampened(ranked, p, p2, p3)
end

function Ranked.Bucket(p: number)
	return Rules.Bucket(ranked, p)
end

function Ranked.ShareAbove(p, p2: number)
	return Rules.ShareAbove(ranked, p, p2)
end

return Ranked