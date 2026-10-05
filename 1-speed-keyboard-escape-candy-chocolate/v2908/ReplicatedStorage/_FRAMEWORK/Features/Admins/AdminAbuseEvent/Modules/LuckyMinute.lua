local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local parentModule = require(script.Parent.Parent)
local BonusManager = require(ReplicatedStorage.BonusManager)
local Config = require(script.Config)
local RevealView = require(script.RevealView)

local function rollMultiplier()
	local total = 0

	for _, tier in Config.tiers do
		total += tier.weight
	end

	local v = math.random() * total
	local total2 = 0

	for _, tier in Config.tiers do
		total2 += tier.weight

		if v <= total2 then
			return math.random(tier.minimum, tier.maximum)
		end
	end

	local tier = Config.tiers[#Config.tiers]
	return math.random(tier.minimum, tier.maximum)
end

local function buildServerRuntime(p)
	local v = {}
	local v2 = true

	local function grantPlayer(p2)
		local multiplier = rollMultiplier()
		v[p2] = multiplier
		task.defer(function()
			if p2.Parent == Players then
				p.FireServerEventToPlayer(p2, {
					kind = "reveal",
					multiplier = multiplier,
					remainingSeconds = Config.durationSeconds
				})
			end
		end)
		task.delay(Config.revealRollSeconds, function()
			if v2 and p2.Parent == Players and v[p2] == multiplier then
				BonusManager:StopBonus("player", "XP", p2, "LuckyMinute")
				BonusManager:ActivateBonus("player", "XP", multiplier, Config.durationSeconds, p2, "LuckyMinute")
			end
		end)
	end

	return {
		onStart = function()
			for _, v3 in Players:GetPlayers() do
				grantPlayer(v3)
			end

			p.janitor:Add(Players.PlayerRemoving:Connect(function(player)
				v[player] = nil
			end))
		end,
		onPlayerAdded = grantPlayer,
		onStop = function(_)
			v2 = false
			table.clear(v)
		end
	}
end

local function buildClientRuntime(p)
	local playerGui = Players.LocalPlayer:FindFirstChildOfClass("PlayerGui")
	local v

	if playerGui then
		v = RevealView.mount(playerGui)
	else
		v = nil
	end

	local v2 = false

	if v then
		p.janitor:Add(v.destroy)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function reveal(p2: number, p3: number)
		if v and not v2 then
			v2 = true
			v.reveal(p2, p3, Config.revealRollSeconds, (math.min(Config.revealHoldSeconds, p3)))
		end
	end

	return {
		onStart = function()
			local activePlayerBonuses = BonusManager:GetActivePlayerBonuses(Players.LocalPlayer)
			local XP = activePlayerBonuses.LuckyMinute and activePlayerBonuses.LuckyMinute.XP

			if XP then
				reveal(XP.mult, BonusManager:GetRemainingTime(XP)) -- equivalent call inferred; original call site unknown
			end
		end,
		onServerEvent = function(data)
			if data.kind == "reveal" then
				reveal(data.multiplier, data.remainingSeconds) -- equivalent call inferred; original call site unknown
			end
		end
	}
end

parentModule.register(script.Name, {
	displayName = "Lucky Minute",
	slot = "overlay",
	needsDuration = true,
	defaultDurationSeconds = Config.durationSeconds,
	maxDurationSeconds = Config.durationSeconds,
	load = function(p)
		if RunService:IsServer() then
			return (buildServerRuntime(p))
		end

		return (buildClientRuntime(p))
	end
})
return {}