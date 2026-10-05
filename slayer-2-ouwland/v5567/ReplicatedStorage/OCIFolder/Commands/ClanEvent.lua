local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local isServer = RunService:IsServer()
local Clans = require(ReplicatedStorage.CAM:WaitForChild("Clans"))
local BadgeRewards = require(ReplicatedStorage.CAM.Global.BadgeRewards)
local v

if isServer then
	local ClanEvents = require(ReplicatedStorage.CAM.Global.ClanEvents)
	v = ClanEvents or nil
else
	v = nil
end

local Utility = isServer and require(ReplicatedStorage.CAM.Global.Utility) or nil
local suggester = { "None" }
local v3 = {}
local clanEvents = {}

for k in Clans.Clans do
	table.insert(suggester, k)
	v3[k:lower()] = k
end

table.sort(suggester)

for _, badgeReward in BadgeRewards do
	if typeof(badgeReward.ClanEvent) ~= "table" then
		continue
	end

	clanEvents[badgeReward.Key:lower()] = badgeReward.ClanEvent
	table.insert(suggester, 1, badgeReward.Key)
end

local names = {}

for _, rarity in Clans.Rarities do
	table.insert(names, rarity.name)
end

local function named(items, p)
	if p == nil then
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
	Clearance = 6,
	Keys = {
		{
			Type = "Players",
			Required = true
		},
		{
			Type = "Event",
			Name = "Badge or clan",
			Required = true,
			Suggester = suggester,
			Completer = function(p: string)
				if p == nil or p == "" then
					return nil
				end

				return (named(suggester, p))
			end
		},
		{
			Type = "Rarity",
			Name = "Rarity",
			Required = false,
			Suggester = names,
			Completer = function(p: string)
				if p == nil or p == "" then
					return nil
				end

				return (named(names, p))
			end
		},
		{
			Type = "Amount",
			Name = "Spins",
			Required = false,
			Completer = function(p: string)
				return (tonumber(p))
			end
		}
	},
	Server = function(_, list, p, p2, p3)
		local v4 = named(suggester, p)

		if v4 == nil then
			error((`No clan or badge reward "{tostring(p)}"`))
		end

		if v4 == "None" then
			for _, v5 in list do
				v.Clear(v5)
			end

			return {
				Content = `Cleared every clan event on {#list} player(s)`,
				ContentColor = Color3.new(1, 1, 1),
				BgColor = Color3.fromRGB(150, 80, 30)
			}
		else
			local v5 = clanEvents[v4:lower()]
			local clan

			if v5 == nil then
				clan = v3[v4:lower()]
			else
				clan = v5.Clan
			end

			local rarity = named(names, p2)

			if not rarity then
				if v5 == nil then
					rarity = nil
				else
					rarity = v5.Rarity or nil
				end
			end

			local spins = tonumber(p3)

			if not spins then
				if v5 == nil then
					spins = nil
				else
					spins = v5.Spins or nil
				end
			end

			if clan == nil then
				error((`No clan "{tostring(v4)}"`))
			end

			if rarity == nil then
				error((`Which rarity? ({table.concat(names, ", ")})`))
			end

			if spins == nil or spins <= 0 then
				error("How many spins? Give a count above 0")
			end

			local v6 = true
			local v7 = {}

			for _, v8 in list do
				Utility.GetData(v8, true)

				if v8.Parent == nil then
					continue
				end

				local v9 = v.Grant(v8, clan, rarity, spins)
				table.insert(v7, (`{v8.Name}: {v9 and "granted" or "refused"}`))
				v6 = v6 and v9
			end

			table.insert(v7, 1, (`{clan} draws as {rarity} for {spins} spins`))
			local v8 = {
				Content = table.concat(v7, "\n"),
				ContentColor = Color3.new(1, 1, 1),
				BgColor = 0
			}
			local bgColor

			if v6 then
				bgColor = Color3.fromRGB(30, 110, 60)
			else
				bgColor = Color3.fromRGB(150, 30, 30)
			end

			v8.BgColor = bgColor
			return v8
		end
	end
}