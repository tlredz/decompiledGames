require("@game/ReplicatedStorage/Omni/Settings")
require("@game/ReplicatedStorage/Omni/DataTemplate")
local module = require("@game/ReplicatedStorage/Omni/Utils/Order")
local module2 = require("@game/ReplicatedStorage/Omni/Shared/Maps")
local module3 = require("@game/ReplicatedStorage/Omni/Shared/Fighters")
local module4 = require("@game/ReplicatedStorage/Omni/Shared/Accessories")
local module5 = require("@game/ReplicatedStorage/Omni/Shared/Weapons")
local v = {
	Categories = { "Worlds", "Special" },
	SpecialSections = { "Exclusives" },
	TypeLists = {
		Fighters = module3.List,
		Accessories = module4.List,
		Weapons = module5.List
	},
	SingularType = {
		Fighters = "Fighter",
		Accessories = "Accessory",
		Weapons = "Weapon"
	},
	Rewards = {
		Fighters = {
			Index = 1,
			Default = true,
			Icon = "rbxassetid://81841411962155",
			List = {
				{
					Amount = 6,
					Perks = {
						["Fighter Damage"] = {
							Type = "Add",
							Amount = 0.1
						}
					},
					Rewards = {
						{
							Type = "Item",
							Name = "Luck Boost",
							Amount = 1
						},
						{
							Type = "Item",
							Name = "Speed Boost",
							Amount = 1
						},
						{
							Type = "Item",
							Name = "Yen Boost",
							Amount = 1
						},
						{
							Type = "Item",
							Name = "Damage Boost",
							Amount = 1
						},
						{
							Type = "Item",
							Name = "Drops Boost",
							Amount = 1
						}
					}
				},
				{
					Amount = 12,
					Perks = {
						["Fighter Damage"] = {
							Type = "Add",
							Amount = 0.1
						}
					},
					Rewards = {
						{
							Type = "Item",
							Name = "Luck Boost",
							Amount = 2
						},
						{
							Type = "Item",
							Name = "Speed Boost",
							Amount = 2
						},
						{
							Type = "Item",
							Name = "Yen Boost",
							Amount = 2
						},
						{
							Type = "Item",
							Name = "Damage Boost",
							Amount = 2
						},
						{
							Type = "Item",
							Name = "Drops Boost",
							Amount = 2
						}
					}
				},
				{
					Amount = 18,
					Perks = {
						["Fighter Damage"] = {
							Type = "Add",
							Amount = 0.1
						}
					},
					Rewards = {
						{
							Type = "Item",
							Name = "Luck Boost",
							Amount = 3
						},
						{
							Type = "Item",
							Name = "Speed Boost",
							Amount = 3
						},
						{
							Type = "Item",
							Name = "Yen Boost",
							Amount = 3
						},
						{
							Type = "Item",
							Name = "Damage Boost",
							Amount = 3
						},
						{
							Type = "Item",
							Name = "Drops Boost",
							Amount = 3
						}
					}
				}
			}
		},
		Accessories = {
			Index = 2,
			Icon = "rbxassetid://86832638879053",
			List = {
				{
					Amount = 2,
					Perks = {
						Damage = {
							Type = "Add",
							Amount = 0.05
						}
					},
					Rewards = {
						{
							Type = "Item",
							Name = "Luck Boost",
							Amount = 1
						},
						{
							Type = "Item",
							Name = "Speed Boost",
							Amount = 1
						},
						{
							Type = "Item",
							Name = "Yen Boost",
							Amount = 1
						},
						{
							Type = "Item",
							Name = "Damage Boost",
							Amount = 1
						},
						{
							Type = "Item",
							Name = "Drops Boost",
							Amount = 1
						}
					}
				},
				{
					Amount = 4,
					Perks = {
						Damage = {
							Type = "Add",
							Amount = 0.05
						}
					},
					Rewards = {
						{
							Type = "Item",
							Name = "Luck Boost",
							Amount = 2
						},
						{
							Type = "Item",
							Name = "Speed Boost",
							Amount = 2
						},
						{
							Type = "Item",
							Name = "Yen Boost",
							Amount = 2
						},
						{
							Type = "Item",
							Name = "Damage Boost",
							Amount = 2
						},
						{
							Type = "Item",
							Name = "Drops Boost",
							Amount = 2
						}
					}
				},
				{
					Amount = 6,
					Perks = {
						Damage = {
							Type = "Add",
							Amount = 0.05
						}
					},
					Rewards = {
						{
							Type = "Item",
							Name = "Luck Boost",
							Amount = 3
						},
						{
							Type = "Item",
							Name = "Speed Boost",
							Amount = 3
						},
						{
							Type = "Item",
							Name = "Yen Boost",
							Amount = 3
						},
						{
							Type = "Item",
							Name = "Damage Boost",
							Amount = 3
						},
						{
							Type = "Item",
							Name = "Drops Boost",
							Amount = 3
						}
					}
				}
			}
		},
		Weapons = {
			Index = 3,
			Icon = "rbxassetid://84877938258705",
			List = {
				{
					Amount = 2,
					Perks = {
						["Player Damage"] = {
							Type = "Add",
							Amount = 0.25
						}
					},
					Rewards = {
						{
							Type = "Item",
							Name = "Luck Boost",
							Amount = 1
						},
						{
							Type = "Item",
							Name = "Speed Boost",
							Amount = 1
						},
						{
							Type = "Item",
							Name = "Yen Boost",
							Amount = 1
						},
						{
							Type = "Item",
							Name = "Damage Boost",
							Amount = 1
						},
						{
							Type = "Item",
							Name = "Drops Boost",
							Amount = 1
						}
					}
				},
				{
					Amount = 4,
					Perks = {
						["Player Damage"] = {
							Type = "Add",
							Amount = 0.25
						}
					},
					Rewards = {
						{
							Type = "Item",
							Name = "Luck Boost",
							Amount = 2
						},
						{
							Type = "Item",
							Name = "Speed Boost",
							Amount = 2
						},
						{
							Type = "Item",
							Name = "Yen Boost",
							Amount = 2
						},
						{
							Type = "Item",
							Name = "Damage Boost",
							Amount = 2
						},
						{
							Type = "Item",
							Name = "Drops Boost",
							Amount = 2
						}
					}
				},
				{
					Amount = 6,
					Perks = {
						["Player Damage"] = {
							Type = "Add",
							Amount = 0.25
						}
					},
					Rewards = {
						{
							Type = "Item",
							Name = "Luck Boost",
							Amount = 3
						},
						{
							Type = "Item",
							Name = "Speed Boost",
							Amount = 3
						},
						{
							Type = "Item",
							Name = "Yen Boost",
							Amount = 3
						},
						{
							Type = "Item",
							Name = "Damage Boost",
							Amount = 3
						},
						{
							Type = "Item",
							Name = "Drops Boost",
							Amount = 3
						}
					}
				},
				{
					Amount = 9,
					Perks = {
						["Player Damage"] = {
							Type = "Add",
							Amount = 0.25
						}
					},
					Rewards = {
						{
							Type = "Item",
							Name = "Luck Boost",
							Amount = 4
						},
						{
							Type = "Item",
							Name = "Speed Boost",
							Amount = 4
						},
						{
							Type = "Item",
							Name = "Yen Boost",
							Amount = 4
						},
						{
							Type = "Item",
							Name = "Damage Boost",
							Amount = 4
						},
						{
							Type = "Item",
							Name = "Drops Boost",
							Amount = 4
						}
					}
				}
			}
		}
	},
	GetAmount = function(p: string, p2: string, p3)
		if p3.Index[p] then
			return p3.Index[p][p2] or 0
		end

		return 0
	end,
	SectionMatches = function(p: string, p2: string, p3)
		if p == "Special" then
			return p3.Rarity == "Exclusive"
		end

		return p3.MapName == p2
	end
}

function v.SectionHasItems(p: string, p2: string)
	for _, typeList in v.TypeLists do
		for _, v2 in typeList do
			if v.SectionMatches(p, p2, v2) then
				return true
			end
		end
	end

	return false
end

function v.GetSectionsForCategory(p: string)
	if p == "Special" then
		return v.SpecialSections
	end

	local v2 = {}

	for k, v3 in module2.List do
		if v.SectionHasItems(p, k) then
			table.insert(v2, {
				Name = k,
				Index = v3.Index or 0
			})
		end
	end

	table.sort(v2, function(a, b)
		return a.Index < b.Index
	end)
	local names = {}

	for _, v3 in v2 do
		table.insert(names, v3.Name)
	end

	return names
end

function v.GetRewardSections()
	local v2 = {}

	for k, reward in v.Rewards do
		table.insert(v2, {
			Name = k,
			Index = reward.Index or 0
		})
	end

	table.sort(v2, function(a, b)
		return a.Index < b.Index
	end)
	local names = {}

	for _, v3 in v2 do
		table.insert(names, v3.Name)
	end

	return names
end

function v.GetDefaultRewardSection()
	for k, reward in v.Rewards do
		if reward.Default then
			return k
		end
	end

	return v.GetRewardSections()[1]
end

function v.GetDiscoveredAmount(p: string, p2)
	local typeList = v.TypeLists[p]

	if not typeList then
		return 0
	end

	local v2 = v.SingularType[p]
	local count = 0

	for k in typeList do
		if v.GetAmount(v2, k, p2) > 0 then
			count += 1
		end
	end

	return count
end

function v.GetTotalAmount(p: string)
	local typeList = v.TypeLists[p]

	if not typeList then
		return 0
	end

	local count = 0

	for _ in typeList do
		count += 1
	end

	return count
end

function v.IsRewardClaimed(p: string, p2: number, p3)
	local indexReward = p3.IndexRewards[p]

	if indexReward then
		return indexReward[tostring(p2)] == true
	end

	return false
end

function v.GetRewardMultiplier(p: string, p2: string, p3: number)
	local perks = {}
	local reward = v.Rewards[p2]

	if not reward then
		return perks
	end

	for _, v2 in reward.List do
		if not (v2.Amount == p3 and v2.Perks) then
			continue
		end

		local perk = v2.Perks[p]

		if perk then
			table.insert(perks, perk)
		end
	end

	return perks
end

function v.SystemSolver(p: string, p2)
	local result = {}

	for k, reward in v.Rewards do
		for _, v2 in reward.List do
			if not (v2.Perks and v.IsRewardClaimed(k, v2.Amount, p2)) then
				continue
			end

			for _, v3 in v.GetRewardMultiplier(p, k, v2.Amount) do
				table.insert(result, v3)
			end
		end
	end

	return result
end

function v.GetItemsForSection(p: string, p2: string)
	local result = {}

	for k, typeList in v.TypeLists do
		local v2 = {}

		for k2, v3 in typeList do
			if v.SectionMatches(p, p2, v3) then
				table.insert(v2, {
					Name = k2,
					RarityOrder = module:Rarity(v3.Rarity)
				})
			end
		end

		table.sort(v2, function(a, b)
			if a.RarityOrder == b.RarityOrder then
				return a.Name < b.Name
			end

			return a.RarityOrder < b.RarityOrder
		end)
		local names = {}

		for _, v3 in v2 do
			table.insert(names, v3.Name)
		end

		result[k] = names
	end

	return result
end

return table.freeze(v)