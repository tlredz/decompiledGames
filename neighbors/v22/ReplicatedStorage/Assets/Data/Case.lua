local WeeklyStore = require(game.ReplicatedStorage.Assets.Data.WeeklyStore)

local function IsWithinTimePeriod(p, p2: number)
	return p.Start < p2 and p2 < p.End
end

local v = {
	Common = Color3.fromRGB(255, 255, 255),
	Uncommon = Color3.fromRGB(85, 255, 127),
	Rare = Color3.fromRGB(85, 255, 255),
	Royalty = Color3.fromRGB(230, 129, 255),
	Unique = Color3.fromRGB(255, 255, 73),
	["???"] = Color3.fromRGB(255, 60, 60),
	Collectible = Color3.fromRGB(127, 82, 5)
}
local RunService = game:GetService("RunService")
local data = game.ReplicatedStorage.Assets.Data
local result = {}
local v2 = {}
local Case = {}
local v3 = {
	Common = 52,
	Uncommon = 32,
	Rare = 9.6,
	Royalty = 5,
	Unique = 1,
	["???"] = 0.4,
	Collectible = 0
}
local v4 = {
	["???"] = "Secret"
}
local v5 = {
	Common = 1,
	Uncommon = 2,
	Rare = 3,
	Royalty = 4,
	Unique = 5,
	["???"] = 6,
	Collectible = 7
}

for _, moduleScript in data.Crates:GetChildren() do
	local module, v6, v7 = require(moduleScript)

	for k, v8 in module, v6, v7 do
		v8.Type = moduleScript.Name
		result[k] = v8
	end

	local emotes = data.Store:FindFirstChild(moduleScript.Name)

	if not emotes then
		continue
	end

	if moduleScript.Name == "Emotes" and RunService:IsServer() then
		emotes = game.ServerStorage.Assets.Data.Emotes
	end

	local module2, v8, v9 = require(emotes)

	for k, v10 in module2, v8, v9 do
		v2[k] = v10

		if not v2[k].ItemType then
			v2[k].ItemType = moduleScript.Name
		end
	end
end

for k, allBanner in WeeklyStore.AllBanners do
	result[k] = allBanner
end

function Case.GetCrates(_)
	return result
end

function Case.GetCrateFromName(_, p)
	return result[p]
end

function Case.GetCrateFromItem(_, p)
	for _, v6 in result do
		for _, item in v6.Items do
			for _, v7 in item do
				if p == v7 then
					return v6
				end
			end
		end
	end
end

function Case.GetCrateFromParent(_, p)
	for k, v6 in result do
		if v6.Parent == p then
			return v6, k
		end
	end
end

function Case.GetRarities(_)
	return v3
end

function Case.GetColors(_)
	return v
end

function Case.GetRarityDisplay(_, p: string)
	return v4[p] or p
end

function Case.GetItemChances(_, p)
	local v6 = {}

	for k, v7 in v5 do
		v6[v7] = k
	end

	local v7 = {}
	local total = 0

	for _, rarity in v6 do
		local weight = v3[rarity]
		local item = p.Items[rarity]

		if weight <= 0 or not item then
			continue
		end

		for _, name in item do
			if p.LimitedTimeItems and p.LimitedTimeItems[name] then
				local limitedTimeItem = p.LimitedTimeItems[name]
				local now = os.time()
				local v11

				if limitedTimeItem.Start < now then
					v11 = now < limitedTimeItem.End
				else
					v11 = false
				end

				if not v11 then
					continue
				end
			end

			table.insert(v7, {
				Name = name,
				Rarity = rarity,
				Weight = weight,
				Units = 0,
				Fraction = 0
			})
			total += weight
		end
	end

	local result2 = {}
	local result3 = {}

	if total <= 0 then
		return result2, result3
	end

	for _, v8 in { 1000, 10000, 100000 } do
		local v9 = v8
		local v10 = 1e999

		for _, v11 in v7 do
			local v12 = v11.Weight / total * v8
			v11.Units = math.floor(v12)
			v11.Fraction = v12 - v11.Units
			v9 -= v11.Units
		end

		local clone = table.clone(v7)
		table.sort(clone, function(a, b)
			return a.Fraction > b.Fraction
		end)

		for i = 1, v9 do
			clone[i].Units += 1
		end

		for _, v11 in v7 do
			v10 = math.min(v10, v11.Units)
		end

		if not (v10 > 0 or v8 == 100000) then
			continue
		end

		local v11 = v8 / 100

		for _, v12 in v7 do
			result2[v12.Name] = v12.Units / v11
			result3[v12.Rarity] = (result3[v12.Rarity] or 0) + v12.Units
		end

		for k, v12 in result3 do
			result3[k] = v12 / v11
		end

		return result2, result3
	end

	return result2, result3
end

function Case.GetItemInfo(_, p)
	return v2[p]
end

function Case:GetRarityFromWeight(p)
	for k, v6 in v3 do
		if v6 == p then
			return k
		end
	end
end

function Case:GetRandomItem(p)
	local items = p.Items
	local v6 = {}

	for k, v7 in v3 do
		if not items[k] then
			continue
		end

		for _, v8 in items[k] do
			if p.LimitedTimeItems and p.LimitedTimeItems[v8] then
				local limitedTimeItem = p.LimitedTimeItems[v8]
				local now = os.time()
				local v9

				if limitedTimeItem.Start < now then
					v9 = now < limitedTimeItem.End
				else
					v9 = false
				end

				if not v9 then
					continue
				end
			end

			if v7 > 0 then
				v6[v8] = v7
			end
		end
	end

	local randomWeighted = self:PickRandomWeighted(v6)
	local rarityFromWeight = self:GetRarityFromWeight(v6[randomWeighted])
	return randomWeighted, v2[randomWeighted], rarityFromWeight
end

function Case.GetRarity(_, p, p2)
	for k, list in p.Items do
		if table.find(list, p2) then
			return k
		end
	end
end

function Case:PickRandomWeighted(items)
	local total = 0

	for _, item in items do
		total += item
	end

	local v6 = math.random() * total

	for k, item in items do
		v6 -= item

		if v6 <= 0 then
			return k
		end
	end
end

function Case.GetRarityIndex(_, p)
	return v5[p]
end

return Case