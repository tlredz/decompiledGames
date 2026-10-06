require("@game/ReplicatedStorage/Omni/Settings")
require("@game/ReplicatedStorage/Omni/DataTemplate")
local v = {
	List = {},
	Slots = {
		Head = "rbxassetid://137894804041605",
		Face = "rbxassetid://115470998140830",
		Back = "rbxassetid://75644158051814",
		Waist = "rbxassetid://133067249295078",
		Body = "rbxassetid://108703270400322"
	},
	EvolveOrder = {
		"Common",
		"Uncommon",
		"Rare",
		"Epic",
		"Legendary",
		"Mythical",
		"Secret"
	},
	Rarities = {
		Common = {
			Multiplier = 1,
			Required = 3
		},
		Uncommon = {
			Multiplier = 1.5,
			Required = 3
		},
		Rare = {
			Multiplier = 2,
			Required = 3
		},
		Epic = {
			Multiplier = 2.75,
			Required = 3
		},
		Legendary = {
			Multiplier = 3.5,
			Required = 3
		},
		Mythical = {
			Multiplier = 4.25,
			Required = 3
		},
		Secret = {
			Multiplier = 5
		},
		Exclusive = {
			Multiplier = 1
		}
	}
}

function v.Register(mapName: string, items)
	for k, item in items do
		if v.List[k] then
			warn((`Repeated Accessory: {k}!`))
		else
			if not item.Name then
				item.Name = k
			end

			if not item.Icon then
				item.Icon = ""
			end

			if not item.Type then
				item.Type = "Head"
			end

			if not item.MapName then
				item.MapName = mapName
			end

			if not (item.Rarity and v.Rarities[item.Rarity]) then
				item.Rarity = "Common"
			end

			if not item.Perks then
				item.Perks = {}
			end

			v.List[k] = item
		end
	end
end

function v.GetRarity(p)
	local rarity = p.Rarity

	if typeof(rarity) == "string" and v.Rarities[rarity] then
		return rarity
	end

	local v2 = v.List[p.Name]
	return v2 and v2.Rarity or "Common"
end

function v.CanAutoManage(p: string)
	local v2 = v.List[p]

	if v2 then
		return v2.Rarity ~= "Exclusive"
	end

	return false
end

function v.GetNextRarity(p: string)
	local index = table.find(v.EvolveOrder, p)

	if not index then
		return
	end

	local rarity = v.Rarities[p]

	if rarity and rarity.Required then
		return v.EvolveOrder[index + 1]
	end
end

function v.GetEvolveResult(p: string, p2: number)
	local v2 = 1
	local total = 0

	while true do
		local nextRarity = v.GetNextRarity(p)

		if not nextRarity then
			break
		end

		local v3 = math.max(math.floor(v.Rarities[p].Required), 2)
		local v4 = (v3 - 1) * v2

		if p2 < total + v4 then
			break
		end

		total += v4
		v2 *= v3
		p = nextRarity
	end

	return p, total
end

function v.ScalePerk(p, p2: string)
	local rarity = v.Rarities[p2]
	local multiplier = rarity and rarity.Multiplier or 1

	if p.Type == "Multi" then
		return {
			Type = p.Type,
			Amount = 1 + (p.Amount - 1) * multiplier
		}
	end

	return {
		Type = p.Type,
		Amount = p.Amount * multiplier
	}
end

function v.GetAccessoryMultiplier(p: string, p2, _)
	local v2 = {}
	local v3 = v.List[p2.Name]
	local v4 = v3 and v3.Perks[p]

	if v4 then
		table.insert(v2, v.ScalePerk(v4, v.GetRarity(p2)))
	end

	return v2
end

function v.GetAllAccessoryMultipliers(p, p2)
	local result = {}
	local v2 = v.List[p.Name]

	if v2 then
		for k in v2.Perks do
			result[k] = v.GetAccessoryMultiplier(k, p, p2)
		end
	end

	return result
end

function v.SystemSolver(p: string, p2)
	local result = {}

	for _, v2 in p2.Accessories.Equipped do
		local v3 = p2.Accessories.List[v2]

		if not v3 then
			continue
		end

		local accessoryMultiplier = v.GetAccessoryMultiplier(p, v3, p2)

		for _, v4 in accessoryMultiplier do
			table.insert(result, v4)
		end
	end

	return result
end

for _, moduleScript in script:GetChildren() do
	if not moduleScript:IsA("ModuleScript") then
		continue
	end

	local module = require(moduleScript)

	if module then
		v.Register(moduleScript.Name, module)
	end
end

return table.freeze(v)