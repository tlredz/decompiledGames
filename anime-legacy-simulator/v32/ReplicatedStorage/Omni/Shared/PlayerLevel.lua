require("@game/ReplicatedStorage/Omni/Settings")
require("@game/ReplicatedStorage/Omni/DataTemplate")
local module = require("@game/ReplicatedStorage/Omni/Shared/Prestige")
local v = {
	Price = {
		Type = "Item",
		Name = "Stats Reset Token",
		Amount = 1
	},
	Products = {
		{
			Amount = 1,
			Price = 200,
			Enabled = true
		},
		{
			Amount = 3,
			Price = 570,
			Enabled = true
		},
		{
			Amount = 10,
			Price = 1800,
			Enabled = true
		},
		{
			Amount = 30,
			Price = 5100,
			Enabled = true
		},
		{
			Amount = 75,
			Price = 12000,
			Enabled = true
		},
		{
			Amount = 150,
			Price = 22500,
			Enabled = true
		},
		{
			Amount = 350,
			Price = 50000,
			Enabled = true
		},
		{
			Amount = 750,
			Price = 100000,
			Enabled = true
		}
	},
	List = {
		MaxLevel = 100,
		BaseExp = 100,
		ExpFactor = 1.105,
		Stats = {
			["Fighter Damage"] = {
				Type = "Add",
				Color = Color3.fromRGB(255, 0, 0),
				Start = 0,
				Increasing = 0.005,
				Index = 1
			},
			Yen = {
				Type = "Add",
				Color = Color3.fromRGB(255, 255, 0),
				Start = 0,
				Increasing = 0.005,
				Index = 2
			},
			Luck = {
				Type = "Add",
				Color = Color3.fromRGB(0, 255, 0),
				Start = 0,
				Increasing = 0.0125,
				Index = 3
			},
			Drops = {
				Type = "Add",
				Color = Color3.fromRGB(0, 255, 255),
				Start = 0,
				Increasing = 0.005,
				Index = 4
			}
		},
		PassivePerks = {
			["Player Damage"] = {
				Type = "Add",
				Start = 0,
				Increasing = 0.025
			},
			["Shiny Chance"] = {
				Type = "Add",
				Start = 0,
				Increasing = 0.025
			}
		},
		Rewards = require("@self/Rewards")
	}
}

function v.GetExpForNextLevel(p: number)
	return (math.floor(v.List.BaseExp * v.List.ExpFactor ^ (p - 2)))
end

function v.GetTotalExpForLevel(p: number)
	local total = 0

	for i = 2, p do
		total += v.GetExpForNextLevel(i)
	end

	return total
end

function v.GetRewardInfo(p: number)
	for _, reward in v.List.Rewards do
		if reward.Level == p then
			return reward
		end
	end

	return nil
end

function v.GetMaxLevel(_)
	return v.List.MaxLevel
end

function v.GetAvailablePoints(p)
	local v3 = 1 + module.GetExtraStatPoints(p)
	local v4 = p.Level.Amount * v3

	for _, stat in p.Level.Stats do
		v4 -= stat
	end

	return v4
end

function v.SystemSolver(p: string, p2)
	local result = {}
	local amount = p2.Level.Amount
	local passivePerk = v.List.PassivePerks[p]

	if passivePerk then
		local amount2 = passivePerk.Start + passivePerk.Increasing * (amount - 1)
		table.insert(result, {
			Type = passivePerk.Type,
			Amount = amount2
		})
	end

	local stat = v.List.Stats[p]
	local v3 = p2.Level.Stats[p] or 0

	if stat and v3 > 0 then
		local amount2 = stat.Start + stat.Increasing * v3
		table.insert(result, {
			Type = stat.Type,
			Amount = amount2
		})
	end

	for _, reward in v.List.Rewards do
		if p2.Level.Rewards["Level" .. reward.Level] ~= true then
			continue
		end

		for k, perk in reward.Perks do
			if k == p then
				table.insert(result, perk)
			end
		end
	end

	return result
end

return table.freeze(v)