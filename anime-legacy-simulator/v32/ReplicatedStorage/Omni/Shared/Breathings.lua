local SoftPity = require(script.Parent.SoftPity)
require("@game/ReplicatedStorage/Omni/Settings")
local module = require("@game/ReplicatedStorage/Omni/Utils/Order")
require("@game/ReplicatedStorage/Omni/Utils/Luck")
local Probability = require(script.Parent.Parent.Utils.Probability)
local Validator = require(script.Parent.Parent.Utils.Validator)
local Gacha = require(script.Parent.Gacha)
local v = {
	List = {},
	Name = "Breathings",
	MapName = "Slayers Village",
	Icon = "rbxassetid://102212128812100",
	Price = {
		Type = "Item",
		Name = "Breathing Token",
		Amount = 10
	},
	Products = {
		{
			Type = "Item",
			Name = "Breathing Token",
			Amount = 50,
			Price = 200,
			Enabled = true
		},
		{
			Type = "Item",
			Name = "Breathing Token",
			Amount = 150,
			Price = 500,
			Enabled = true
		},
		{
			Type = "Item",
			Name = "Breathing Token",
			Amount = 400,
			Price = 1250,
			Enabled = true
		},
		{
			Type = "Item",
			Name = "Breathing Token",
			Amount = 1000,
			Price = 2500,
			Enabled = true
		},
		{
			Type = "Item",
			Name = "Breathing Token",
			Amount = 3000,
			Price = 6000,
			Enabled = true
		},
		{
			Type = "Item",
			Name = "Breathing Token",
			Amount = 8000,
			Price = 12500,
			Enabled = true
		},
		{
			Type = "Item",
			Name = "Breathing Token",
			Amount = 20000,
			Price = 25000,
			Enabled = true
		},
		{
			Type = "Item",
			Name = "Breathing Token",
			Amount = 50000,
			Price = 50000,
			Enabled = true
		},
		{
			Type = "Item",
			Name = "Breathing Token",
			Amount = 125000,
			Price = 100000,
			Enabled = true
		}
	},
	Counts = {
		{
			Amount = 1,
			Chance = 100
		},
		{
			Amount = 2,
			Chance = 25
		},
		{
			Amount = 3,
			Chance = 1
		}
	},
	SoftPity = {
		{
			Name = "Secret",
			Amount = 250000,
			Multiplier = 1.1
		}
	},
	Pity = {
		{
			Name = "Legendary",
			Amount = 100
		},
		{
			Name = "Mythical",
			Amount = 2000
		},
		{
			Name = "Secret",
			Amount = 10000
		}
	}
}

local function IsPlainTable(p)
	return typeof(p) == "table" and getmetatable(p) == nil
end

local function IsName(value)
	return typeof(value) == "string" and string.find(value, "%S") ~= nil
end

local function IsPositiveInteger(p)
	local v2 = Validator:ValidateNumber(p)

	if v2 then
		if p > 0 and p <= 9007199254740991 then
			return p % 1 == 0
		else
			return false
		end
	end

	return v2
end

local function EncodeNames(clone)
	local v2 = {}

	for _, item in clone do
		table.insert(v2, (`{#item}:{item}`))
	end

	return table.concat(v2)
end

local function EncodeEntry(list: string, list2: string)
	return (`{#list}:{list}{#list2}:{list2}`)
end

local function IsEntry(p)
	local v2

	if typeof(p) == "table" then
		v2 = getmetatable(p) == nil
	else
		v2 = false
	end

	if not v2 then
		return v2
	end

	local name = p.Name

	if typeof(name) == "string" then
		v2 = string.find(name, "%S") ~= nil
	else
		v2 = false
	end

	if not v2 then
		return v2
	end

	local rarity = p.Rarity

	if typeof(rarity) == "string" then
		return string.find(rarity, "%S") ~= nil
	else
		return false
	end

	return v2
end

local function IsLegacyCurrent(items)
	if typeof(items) ~= "table" then
		return false
	end

	for k in items do
		if typeof(k) == "string" then
			return true
		end
	end

	return false
end

local function ValidateState(p, list)
	if p == nil then
		return true
	end

	local v2

	if typeof(p) == "table" then
		v2 = getmetatable(p) == nil
	else
		v2 = false
	end

	if not v2 then
		return false, "Breathing state must be a table."
	end

	local current = p.Current

	if current == nil then
		return true
	end

	local v3

	if typeof(current) == "table" then
		v3 = getmetatable(current) == nil
	else
		v3 = false
	end

	if not v3 then
		return false, "Current Breathings must be a table."
	end

	local count = 0

	for _ in current do
		count += 1
	end

	if count ~= #current then
		return false, "Current Breathings must be a sequential list."
	end

	for _, v4 in current do
		local v5

		if typeof(v4) == "table" then
			v5 = getmetatable(v4) == nil
		else
			v5 = false
		end

		if v5 then
			local name = v4.Name

			if typeof(name) == "string" then
				v5 = string.find(name, "%S") ~= nil
			else
				v5 = false
			end

			if v5 then
				local rarity = v4.Rarity

				if typeof(rarity) == "string" then
					v5 = string.find(rarity, "%S") ~= nil
				else
					v5 = false
				end
			end
		end

		if v5 and list[v4.Name] and list[v4.Name].Rarities[v4.Rarity] then
			if v4.Locked ~= nil and v4.Locked ~= true then
				return false, "Each lock must be true or absent."
			end
		else
			return false, "Current Breathings must exist in the catalog with their recorded rarities."
		end
	end

	return true
end

local function GetCatalogChances(list, p: number)
	local v2

	if typeof(list) == "table" then
		v2 = getmetatable(list) == nil
	else
		v2 = false
	end

	if not (v2 and next(list)) then
		return nil, "Breathings require a nonempty catalog."
	end

	local chances = {}

	for k, item in list do
		local v3

		if typeof(k) == "string" then
			v3 = string.find(k, "%S") ~= nil
		else
			v3 = false
		end

		if not v3 then
			return nil, "Each Breathing must match its catalog name."
		end

		local v4

		if typeof(item) == "table" then
			v4 = getmetatable(item) == nil
		else
			v4 = false
		end

		if not (v4 and item.Name == k) then
			return nil, "Each Breathing must match its catalog name."
		end

		if not Validator:ValidateNumber(item.Chance) or item.Chance <= 0 then
			return nil, "Breathing name weights must be finite and positive."
		end

		local rarities = item.Rarities
		local v5

		if typeof(rarities) == "table" then
			v5 = getmetatable(rarities) == nil
		else
			v5 = false
		end

		if not v5 then
			return nil, "Breathing rarities must be a table."
		end

		for k2, rarity in item.Rarities do
			if not table.find(module.Rarities, k2) then
				return nil, "Each Breathing rarity must match a known rarity name."
			end

			local v6

			if typeof(rarity) == "table" then
				v6 = getmetatable(rarity) == nil
			else
				v6 = false
			end

			if v6 and rarity.Name == k2 then
				continue
			end

			return nil, "Each Breathing rarity must match a known rarity name."
		end

		local chances2, v6 = Probability.GetChances(item.Rarities, p, true)

		if not chances2 then
			return nil, v6
		end

		chances[k] = chances2
		continue
	end

	return chances
end

local function GetCountChances(counts, p: number, lockedCount: number)
	local v2

	if typeof(counts) == "table" then
		v2 = getmetatable(counts) == nil
	else
		v2 = false
	end

	if not (v2 and next(counts)) then
		return nil, "Breathing counts require a nonempty sequential table."
	end

	local v3 = {}
	local count = 0
	local v4 = 0

	for k, item in counts do
		local v5 = Validator:ValidateNumber(k)

		if v5 then
			if k > 0 and k <= 9007199254740991 then
				v5 = k % 1 == 0
			else
				v5 = false
			end
		end

		if not v5 then
			return nil, "Each count requires a positive integer index and amount."
		end

		local v6

		if typeof(item) == "table" then
			v6 = getmetatable(item) == nil
		else
			v6 = false
		end

		if not v6 then
			return nil, "Each count requires a positive integer index and amount."
		end

		local amount = item.Amount
		local v7 = Validator:ValidateNumber(amount)

		if v7 then
			if amount > 0 and amount <= 9007199254740991 then
				v7 = amount % 1 == 0
			else
				v7 = false
			end
		end

		if v7 then
			local amount2 = tostring(item.Amount)

			if v3[amount2] then
				return nil, "Breathing count amounts must be unique."
			end

			v3[amount2] = {
				Name = amount2,
				Chance = item.Chance
			}
			count += 1
			v4 = math.max(v4, k)
			continue
		end

		return nil, "Each count requires a positive integer index and amount."
	end

	if count ~= v4 then
		return nil, "Breathing count indexes must be consecutive."
	end

	local chances, v5 = Probability.GetChances(v3, p, true)

	if not chances then
		return nil, v5
	end

	local result = {}

	for k, chance in chances do
		if chance.Chance == 0 then
			continue
		end

		local newRollCount = v.GetNewRollCount(tonumber(k), lockedCount)
		result[newRollCount] = (result[newRollCount] or 0) + chance.Chance
	end

	return result
end

function v.RegisterBreathing(name: string, state)
	if typeof(name) ~= "string" then
		warn("[BREATHINGS] Breathing name wasn't given!")
		return
	end

	if v.List[name] then
		warn((`[BREATHINGS] Repeated Breathing: {name}!`))
		return
	end

	if typeof(state) ~= "table" then
		warn((`[BREATHINGS] Breathing info wasn't given for breathing: {name}!`))
		return
	end

	if typeof(state.Rarities) ~= "table" then
		warn((`[BREATHINGS] Rarities weren't given for breathing: {name}!`))
		return
	end

	if state.Chance == nil then
		state.Chance = 100
	end

	if typeof(state.Chance) ~= "number" or not (state.Chance > 0 and state.Chance < 1e999) then
		warn((`[BREATHINGS] Invalid Chance for breathing: {name}!`))
		return
	end

	for k, rarity in state.Rarities do
		if typeof(k) == "string" and table.find(module.Rarities, k) and typeof(rarity) == "table" then
			if typeof(rarity.Chance) == "number" then
				rarity.Name = k

				for _, v2 in { "Attributes", "Perks" } do
					if typeof(rarity[v2]) == "table" then
						for k2, v3 in rarity[v2] do
							if not (typeof(k2) ~= "string" or typeof(v3) ~= "table" or v3.Type ~= "Add" and v3.Type ~= "Multi" or typeof(v3.Amount) ~= "number") then
								continue
							end

							rarity[v2][k2] = nil
						end
					else
						rarity[v2] = {}
					end
				end
			else
				state.Rarities[k] = nil
			end
		else
			state.Rarities[k] = nil
		end
	end

	if not next(state.Rarities) then
		warn((`[BREATHINGS] {name} has no valid Rarities!`))
		return
	end

	if typeof(state.Name) ~= "string" then
		state.Name = name
	end

	if typeof(state.Icon) ~= "string" then
		state.Icon = ""
	end

	v.List[name] = state
end

function v.SortEntries(list)
	table.sort(list, function(a, b)
		local rarity = module:Rarity(a.Rarity)
		local rarity2 = module:Rarity(b.Rarity)

		if rarity == rarity2 then
			return a.Name < b.Name
		end

		return rarity2 < rarity
	end)
	return list
end

function v:NormalizeState()
	if typeof(self) ~= "table" then
		return false
	end

	local v2 = false
	local current = self.Current
	local flag

	if typeof(current) == "table" then
		local flag2 = true

		for k in current do
			if typeof(k) ~= "string" then
				continue
			end

			flag = true
			flag2 = false
			break
		end

		if flag2 then
			flag = false
		end
	else
		flag = false
	end

	if flag then
		local v3 = typeof(self.Locked) ~= "table" and {} or self.Locked or {}
		local v4 = {}

		for k, rarity in self.Current do
			if not (typeof(k) == "string" and typeof(rarity) == "string") then
				continue
			end

			table.insert(v4, {
				Name = k,
				Rarity = rarity,
				Locked = v3[k] == true or nil
			})
		end

		self.Current = v.SortEntries(v4)
		v2 = true
	end

	if self.Locked ~= nil then
		self.Locked = nil
		return true
	end

	return v2
end

function v.GetEntries(p)
	local result = {}
	local current = p and p.Current

	if typeof(current) ~= "table" then
		return result
	end

	for i = 1, #current do
		local v2 = current[i]
		local v3

		if typeof(v2) == "table" then
			v3 = getmetatable(v2) == nil
		else
			v3 = false
		end

		if v3 then
			local name = v2.Name

			if typeof(name) == "string" then
				v3 = string.find(name, "%S") ~= nil
			else
				v3 = false
			end

			if v3 then
				local rarity = v2.Rarity

				if typeof(rarity) == "string" then
					v3 = string.find(rarity, "%S") ~= nil
				else
					v3 = false
				end
			end
		end

		if v3 then
			table.insert(result, {
				Slot = i,
				Name = v2.Name,
				Rarity = v2.Rarity,
				Locked = v2.Locked == true or nil
			})
		end
	end

	return result
end

function v.GetRollState(p)
	local entries = v.GetEntries(p)
	local count = 0
	local pool = {}

	for _, entry in entries do
		if entry.Locked then
			count += 1
		end
	end

	for k in v.List do
		table.insert(pool, k)
	end

	table.sort(pool)
	return {
		Current = entries,
		Pool = pool,
		CurrentCount = #entries,
		LockedCount = count,
		UnlockedCount = #entries - count,
		CanSpin = #pool > 0 and (#entries == 0 or count < #entries)
	}
end

function v.CanLock(p, p2: number)
	local rollState = v.GetRollState(p)

	for _, v2 in rollState.Current do
		if v2.Slot == p2 then
			return v2.Locked == true or rollState.UnlockedCount > 1
		end
	end

	return false
end

function v.GetNewRollCount(p: number, p2: number)
	return (math.max(math.floor(p) - p2, 1))
end

function v.GetNamePool(items)
	local result = {}

	for _, item in items do
		local v2 = v.List[item]

		if v2 then
			result[item] = {
				Name = item,
				Chance = v2.Chance
			}
		end
	end

	return result
end

function v.GetHighestRarityIndex(p)
	local v2 = 0

	for k in p.Rarities do
		local rarity = module:Rarity(k)

		if v2 < rarity then
			v2 = rarity
		end
	end

	return v2
end

function v.GetOutcomeKey(list)
	local v2

	if typeof(list) == "table" then
		v2 = getmetatable(list) == nil
	else
		v2 = false
	end

	if not v2 or #list == 0 then
		return nil
	end

	local v3 = {}

	for _, v4 in list do
		local v5

		if typeof(v4) == "table" then
			v5 = getmetatable(v4) == nil
		else
			v5 = false
		end

		if v5 then
			local name = v4.Name

			if typeof(name) == "string" then
				v5 = string.find(name, "%S") ~= nil
			else
				v5 = false
			end

			if v5 then
				local rarity = v4.Rarity

				if typeof(rarity) == "string" then
					v5 = string.find(rarity, "%S") ~= nil
				else
					v5 = false
				end
			end
		end

		if not v5 then
			return nil
		end

		local name = v4.Name
		local rarity = v4.Rarity
		table.insert(v3, (`{#name}:{name}{#rarity}:{rarity}`))
	end

	table.sort(v3)
	return table.concat(v3)
end

function v.GetPreview(gachaLuck: number, p2, p3, p4)
	local v2, v3 = GetCatalogChances(v.List, gachaLuck)

	if not v2 then
		return nil, v3
	end

	local v4, v5 = ValidateState(p2, v.List)

	if not v4 then
		return nil, v5
	end

	local rollState = v.GetRollState(p2)

	if not rollState.CanSpin then
		return nil, "At least one Breathing must remain available for a new roll."
	end

	if #rollState.Pool > 64 then
		return nil, "The Breathing preview exceeds the supported pool size."
	end

	local counts, v7 = GetCountChances(v.Counts, gachaLuck, rollState.LockedCount)

	if not counts then
		return nil, v7
	end

	local pityPreview, v8 = Gacha.GetPityPreview(v.Pity, p3)

	if not pityPreview then
		return nil, v8
	end

	local preview, v9 = SoftPity.GetPreview(v.SoftPity, p4)

	if not preview then
		return nil, v9
	end

	local rarities = {}

	for k, v11 in v2 do
		local v12 = {}

		for k2 in v11 do
			v12[k2] = k2
		end

		rarities[k] = SoftPity.Apply(v11, v12, preview)
	end

	local v11 = {}

	if pityPreview.Result then
		for _, v12 in rollState.Pool do
			local v13 = v2[v12][pityPreview.Result]

			if v13 and v13.Chance > 0 then
				v11[v12] = true
			end
		end

		if not next(v11) then
			return nil, (`No Breathing can satisfy pity rarity {pityPreview.Result}.`)
		end
	end

	local count = 0
	local v12 = nil
	local v13 = {}
	local v14 = {}
	local chances2 = {}
	local outcomeKeys = {}

	local function SpendStep()
		count += 1

		if count > 100000 then
			v12 = "The Breathing preview exceeds the supported calculation budget."
		end

		return v12 == nil
	end

	local function Multiply(p5: number, p6: number)
		local v16 = p5 * p6 / 100

		if Validator:ValidateNumber(v16) and not (v16 <= 0) then
			return v16
		end

		v12 = "A positive Breathing outcome probability is not representable."
		return nil
	end

	local chances, v16 = Probability.GetChances(v.GetNamePool(rollState.Pool), gachaLuck, true)

	if not chances then
		return nil, v16
	end

	local v17 = {}
	local VisitNames

	VisitNames = function(p5: number, chance2: number, p7: number, p8: number)
		count += 1

		if count > 100000 then
			v12 = "The Breathing preview exceeds the supported calculation budget."
		end

		if v12 ~= nil then
			return
		end

		if #v17 == p5 then
			local clone = table.clone(v17)
			local encodeNames = EncodeNames(clone)
			local v19 = v13[encodeNames]

			if v19 then
				v19.Chance += chance2
				return
			end

			v13[encodeNames] = {
				Names = clone,
				Chance = chance2
			}
			table.insert(v14, encodeNames)
		else
			for i = p7, #rollState.Pool do
				local v18 = rollState.Pool[i]
				local chance = chances[v18]

				if not (chance and chance.Chance ~= 0) then
					continue
				end

				local v19 = (i ~= p7 or not (#v17 > 0) or v17[#v17] ~= v18) and 1 or p8 + 1
				local v20 = chance2 * (chance.Chance * (#v17 + 1) / v19) / 100

				if not Validator:ValidateNumber(v20) or v20 <= 0 then
					v12 = "A positive Breathing outcome probability is not representable."
					v20 = nil
				end

				if not v20 then
					return
				end

				table.insert(v17, v18)
				VisitNames(p5, v20, i, v19)
				table.remove(v17)

				if v12 then
					return
				end
			end
		end
	end

	local v18 = {}

	for k in counts do
		table.insert(v18, k)
	end

	table.sort(v18)

	for _, v19 in v18 do
		VisitNames(v19, counts[v19], 1, 0)

		if v12 then
			return nil, v12
		end
	end

	if pityPreview.Result then
		local v19 = {}

		for i = #v14, 1, -1 do
			local v20 = v14[i]
			local v21 = v13[v20]
			local flag = false

			for _, name in v21.Names do
				if not v11[name] then
					continue
				end

				flag = true
				break
			end

			if flag then
				local count2 = #v21.Names
				v19[count2] = (v19[count2] or 0) + v21.Chance
			else
				v13[v20] = nil
				table.remove(v14, i)
			end
		end

		for _, v20 in v18 do
			local v21 = v19[v20]

			if not v21 or not Validator:ValidateNumber(v21) or v21 <= 0 then
				return nil, (`No set of {v20} new Breathings can satisfy pity rarity {pityPreview.Result}.`)
			end
		end

		for _, v20 in v14 do
			local v21 = v13[v20]
			local count2 = #v21.Names
			local chance = v21.Chance / v19[count2] * counts[count2]

			if not Validator:ValidateNumber(chance) or chance <= 0 then
				return nil, "A positive conditioned Breathing probability is not representable."
			end

			v21.Chance = chance
		end
	end

	local v19 = {}
	local v20 = {}

	for _, v21 in rollState.Current do
		if v21.Locked then
			table.insert(v19, {
				Name = v21.Name,
				Rarity = v21.Rarity,
				Locked = true
			})
		end
	end

	table.sort(v14)

	for _, v21 in v14 do
		local v22 = v13[v21]
		local v23 = {}

		if pityPreview.Result then
			for k, name in v22.Names do
				if v11[name] then
					table.insert(v23, k)
				end
			end
		else
			table.insert(v23, false)
		end

		local function AddOutcome(chance: number)
			local new = {}

			for k, name in v22.Names do
				table.insert(new, {
					Name = name,
					Rarity = v20[k]
				})
			end

			v.SortEntries(new)
			local clone = table.clone(v19)

			for k, v26 in new do
				table.insert(clone, v26)
			end

			local outcomeKey = v.GetOutcomeKey(clone)
			local v26 = chances2[outcomeKey]

			if v26 then
				v26.Chance += chance
				return
			end

			if #outcomeKeys >= 25000 then
				v12 = "The Breathing preview exceeds the supported outcome count."
				return
			end

			chances2[outcomeKey] = {
				Name = outcomeKey,
				Chance = chance,
				Current = clone,
				New = new,
				NewCount = #new,
				RealIndex = outcomeKey
			}
			table.insert(outcomeKeys, outcomeKey)
		end

		local VisitRarities
		local v25 = v22
		local AddOutcome2 = AddOutcome
		local VisitRarities2 = VisitRarities

		VisitRarities = function(p5: number, p6: number, p7)
			count += 1

			if count > 100000 then
				v12 = "The Breathing preview exceeds the supported calculation budget."
			end

			if v12 ~= nil then
				return
			end

			local name = v25.Names[p5]

			if not name then
				AddOutcome2(p6)
				return
			end

			if p5 == p7 then
				v20[p5] = pityPreview.Result
				VisitRarities2(p5 + 1, p6, p7)
			else
				for k, rarity in module.Rarities do
					local v26 = rarities[name][rarity]

					if not (v26 and v26.Chance ~= 0) then
						continue
					end

					local v27 = p6 * v26.Chance / 100

					if not Validator:ValidateNumber(v27) or v27 <= 0 then
						v12 = "A positive Breathing outcome probability is not representable."
						v27 = nil
					end

					if not v27 then
						return
					end

					v20[p5] = rarity
					VisitRarities2(p5 + 1, v27, p7)

					if v12 then
						return
					end
				end
			end

			v20[p5] = nil
		end

		local v26 = v22.Chance / #v23

		if not Validator:ValidateNumber(v26) or v26 <= 0 then
			return nil, "A positive pity target probability is not representable."
		end

		for _, v27 in v23 do
			VisitRarities(1, v26, v27)

			if v12 then
				return nil, v12
			end
		end
	end

	table.sort(outcomeKeys)
	local total = 0
	local outcomes = {}
	local nameSets = {}

	for k, v23 in outcomeKeys do
		local v24 = chances2[v23]

		if not Validator:ValidateNumber(v24.Chance) or v24.Chance <= 0 or v24.Chance > 100.00000001 then
			return nil, "The Breathing preview produced an invalid percentage."
		end

		v24.Chance = math.min(100, v24.Chance)
		v24.Index = k
		total += v24.Chance
		table.insert(outcomes, v24)
	end

	if #outcomes == 0 or math.abs(total - 100) > 1e-8 then
		return nil, "The Breathing outcome probabilities do not total 100 percent."
	end

	for _, v23 in v14 do
		table.insert(nameSets, v13[v23])
	end

	return {
		GachaLuck = gachaLuck,
		State = rollState,
		Pity = pityPreview,
		SoftPity = preview,
		Counts = counts,
		Rarities = rarities,
		NameSets = nameSets,
		Outcomes = outcomes,
		Chances = chances2
	}
end

for _, moduleScript in script:GetChildren() do
	if moduleScript:IsA("ModuleScript") then
		v.RegisterBreathing(moduleScript.Name, require(moduleScript))
	end
end

return table.freeze(v)