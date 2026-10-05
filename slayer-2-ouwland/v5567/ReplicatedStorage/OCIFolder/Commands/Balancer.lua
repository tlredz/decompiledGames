local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local isServer = RunService:IsServer()
local parent = script.Parent
local Breathings = require(ReplicatedStorage.CAM.Global.Powers.Breathings)
local DemonArts = require(ReplicatedStorage.CAM.Global.Powers.DemonArts)
local CombatMode = require(ReplicatedStorage.CAM.Global.CombatMode)
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
local Mastery = require(parent.Mastery)
local Set = require(parent.Set)
local Ultimates = require(parent.Ultimates)
local v

if isServer then
	local ModeBar = require(parent.ModeBar)
	v = ModeBar or nil
else
	v = nil
end

local v2

if isServer then
	local Clan = require(parent.Set.Clan)
	v2 = Clan or nil
else
	v2 = nil
end

local v3

if isServer then
	local Race = require(parent.Set.Race)
	v3 = Race or nil
else
	v3 = nil
end

local v4

if isServer then
	local Breathing = require(parent.Give.Breathing)
	v4 = Breathing or nil
else
	v4 = nil
end

local v5

if isServer then
	local EvilArt = require(parent.Give["Evil Art"])
	v5 = EvilArt or nil
else
	v5 = nil
end

local v6

if isServer then
	local StatPoints = require(parent.Give["Stat Points"])
	v6 = StatPoints or nil
else
	v6 = nil
end

local Cooldowns = isServer and require(parent.Reset.Cooldowns) or nil
local breathing = {}
local evilart = {}
local race = { "Slayer", "Demon" }
local pvp = { "On", "Off" }
local suggester = {
	"Mastery",
	"Clan",
	"StatPoints",
	"Breathing",
	"EvilArt",
	"Race",
	"Ultimates",
	"ModeBar",
	"Cooldowns",
	"PvP"
}
local v12 = {
	ModeBar = true,
	Cooldowns = true
}

for k in Breathings do
	table.insert(breathing, k)
end

for k in DemonArts do
	table.insert(evilart, k)
end

table.sort(breathing)
table.sort(evilart)
local v13 = {
	mastery = Mastery.Keys[2].Suggester,
	clan = Set.Keys[3].Suggester({
		[2] = "clan"
	}),
	breathing = breathing,
	evilart = evilart,
	race = race,
	pvp = pvp
}

-- equivalent calls inferred from this helper; original call sites unknown
local function valuesFor(lower: string)
	if lower == "ultimates" then
		return Ultimates.Keys[2].Suggester()
	end

	return v13[lower]
end

local function named(items, p)
	if items == nil then
		return nil
	end

	local lower = tostring(p):lower()

	for _, item in items do
		if item:lower() == lower then
			return item
		end
	end

	return nil
end

return {
	Clearance = 0.5,
	Keys = {
		{
			Type = "Category",
			Name = "Category",
			Required = true,
			Suggester = suggester,
			Completer = function(p: string)
				return (named(suggester, p))
			end
		},
		{
			Type = "Value",
			Name = "Value",
			Required = false,
			Suggester = function(list)
				local v14 = valuesFor((list[1] or ""):lower()) -- equivalent call inferred; original call site unknown
				return v14, true
			end,
			Completer = function(p: string, list)
				if p == nil or p == "" then
					return nil
				end

				local v14 = valuesFor((list[1] or ""):lower()) -- equivalent call inferred; original call site unknown

				if v14 == nil then
					return (tonumber(p))
				end

				return named(v14, p) or p
			end
		},
		{
			Type = "Amount",
			Name = "Amount",
			Required = false,
			Completer = function(p: string)
				return (tonumber(p))
			end
		}
	},
	Server = function(p, p2: string, p3, p4)
		local v14 = named(suggester, p2)

		if v14 == nil then
			error((`Invalid balancer category: {p2}`))
		end

		if p3 == nil and not v12[v14] then
			error((`{v14} needs a value`))
		end

		local v15 = { p }

		if v14 == "Mastery" then
			local v16 = named(v13.mastery, p3)

			if v16 == nil then
				error((`No mastery named "{p3}"`))
			end

			return Mastery.Server(p, v15, v16, (math.max(tonumber(p4) or 1, 0)))
		else
			if v14 == "Clan" then
				return v2(v15, p3)
			end

			if v14 == "Race" then
				if table.find(race, p3) == nil then
					error((`Race must be {table.concat(race, " or ")}, not "{p3}"`))
				end

				return v3(v15, p3)
			elseif v14 == "Breathing" then
				if Breathings[p3] == nil then
					error((`No breathing named "{p3}"`))
				end

				return v4(p, p3)
			elseif v14 == "EvilArt" then
				if DemonArts[p3] == nil then
					error((`No evil art named "{p3}"`))
				end

				return v5(p, p3)
			elseif v14 == "StatPoints" then
				local v16 = tonumber(p3)

				if v16 == nil then
					error((`Stat Points needs a number, not "{p3}"`))
				end

				return v6(p, (math.max(v16, 0)))
			elseif v14 == "Ultimates" then
				local v16 = named(Ultimates.Keys[2].Suggester(), p3)

				if v16 == nil then
					error((`No boss-skill category named "{p3}"`))
				end

				return Ultimates.Server(p, v15, v16)
			else
				if v14 == "ModeBar" then
					return v.Server(p, v15)
				elseif v14 == "Cooldowns" then
					return Cooldowns(v15)
				end

				if v14 ~= "PvP" then
					return
				end

				if not (gameSettings.IsTestPlace or gameSettings.IsStudio) then
					error("PvP only works in the test places")
				end

				local v16 = named(pvp, p3)

				if v16 == nil then
					error((`PvP must be On or Off, not "{p3}"`))
				end

				CombatMode.SetMode(v16 == "On" and "BalancerPvP" or nil, p)
				return {
					Content = v16 == "On" and "PvP and ranked numbers ON: every hit and cast of yours pays them, dummies included" or "PvP numbers OFF: NPCs take PvE numbers again, players still take PvP",
					BgColor = Color3.fromRGB(32, 143, 70),
					FgColor = Color3.new(1, 1, 1)
				}
			end
		end
	end
}