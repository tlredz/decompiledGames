require("@game/ReplicatedStorage/Omni/Settings")
local module = require("@game/ReplicatedStorage/Omni/Utils/Probability")
local SoftPity = require(script.Parent.SoftPity)
local module2 = require("@game/ReplicatedStorage/Omni/Utils/Validator")
local v = {
	List = {},
	Sources = {},
	SoftPityTemplates = {
		Default = {
			{
				Name = "Secret",
				Amount = 250000,
				Multiplier = 1.1
			}
		}
	},
	PityTemplates = {
		Default = {
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
}

local function IsPlainTable(p)
	return typeof(p) == "table" and getmetatable(p) == nil
end

local function IsCounter(p)
	local v2 = module2:ValidateNumber(p)

	if v2 then
		if p >= 0 and p <= 9007199254740991 then
			return p % 1 == 0
		else
			return false
		end
	end

	return v2
end

local function IsName(value)
	return typeof(value) == "string" and string.find(value, "%S") ~= nil
end

function v.RegisterSource(value: string, data)
	if typeof(value) ~= "string" then
		warn("[GACHA] Source name wasn't given!")
		return
	end

	if typeof(data) ~= "table" then
		warn((`[GACHA] Source info wasn't given for source: {value}!`))
		return
	end

	if typeof(data.Type) ~= "string" then
		warn((`[GACHA] Type wasn't given to source: {value}!`))
		return
	end

	if data.Type == "Normal" then
		if typeof(data.Normal) ~= "table" then
			warn((`[GACHA] List wasn't given to source: {value}!`))
			return
		end

		local index = 0

		for k, v2 in data.Normal do
			if typeof(k) == "string" and typeof(v2) == "table" then
				if typeof(v2.Chance) == "number" then
					if typeof(v2.Index) == "number" then
						if index < v2.Index then
							index = v2.Index
						end
					else
						index += 1
						v2.Index = index
					end

					if typeof(v2.Name) ~= "string" then
						v2.Name = k
					end

					if typeof(v2.Rarity) ~= "string" then
						v2.Rarity = "Common"
					end

					if typeof(v2.Icon) ~= "string" then
						v2.Icon = ""
					end

					if typeof(v2.Perks) == "table" then
						for k2, perk in v2.Perks do
							if not (typeof(k2) ~= "string" or typeof(perk) ~= "table" or typeof(perk.Type) ~= "string" or typeof(perk.Amount) ~= "number") then
								continue
							end

							v2.Perks[k2] = nil
						end
					else
						v2.Perks = {}
					end
				else
					data.Normal[k] = nil
				end
			else
				data.Normal[k] = nil
			end
		end

		if not next(data.Normal) then
			warn((`[GACHA] {value} {data.Type} list is empty!`))
			return
		end
	elseif data.Type == "Talents" then
		if typeof(data.Talents) ~= "table" or typeof(data.Talents.Ranks) ~= "table" or typeof(data.Talents.List) ~= "table" then
			warn((`[GACHA] List wasn't given to source: {value}!`))
			return
		end

		local index = 0

		for k, rank in data.Talents.Ranks do
			if typeof(k) == "string" and typeof(rank) == "table" then
				if typeof(rank.Chance) == "number" then
					if typeof(rank.Name) ~= "string" then
						rank.Name = k
					end

					if typeof(rank.Multiplier) ~= "number" then
						rank.Multiplier = 1
					end

					if typeof(rank.Index) == "number" then
						if index < rank.Index then
							index = rank.Index
						end
					else
						index += 1
						rank.Index = index
					end
				else
					data.Talents.Ranks[k] = nil
				end
			else
				data.Talents.Ranks[k] = nil
			end
		end

		for k, v2 in data.Talents.List do
			if typeof(k) == "string" and typeof(v2) == "table" then
				if typeof(v2.StartRank) ~= "string" then
					v2.StartRank = nil
				end

				if typeof(v2.EndRank) ~= "string" then
					v2.EndRank = nil
				end

				if typeof(v2.Perks) == "table" then
					for k2, perk in v2.Perks do
						if not (typeof(k2) ~= "string" or typeof(perk) ~= "table" or typeof(perk.Type) ~= "string" or typeof(perk.Amount) ~= "number") then
							continue
						end

						v2.Perks[k2] = nil
					end
				else
					v2.Perks = {}
				end
			else
				data.Talents.List[k] = nil
			end
		end
	end

	v.Sources[value] = data
end

function v.RegisterGacha(name: string, state)
	if typeof(name) ~= "string" then
		warn("[GACHA] Gacha name wasn't given!")
		return
	end

	if typeof(state) ~= "table" then
		warn((`[GACHA] Gacha info wasn't given for gacha: {name}!`))
		return
	end

	if typeof(state.Interface) ~= "string" then
		warn((`[GACHA] Interface wasn't given for gacha: {name}!`))
		return
	end

	if typeof(state.Map) ~= "string" then
		warn((`[GACHA] Map wasn't given for gacha: {name}!`))
		return
	end

	if typeof(state.Price) ~= "table" or typeof(state.Price.Type) ~= "string" or typeof(state.Price.Name) ~= "string" or typeof(state.Price.Amount) ~= "number" then
		warn((`[GACHA] Price wasn't given for gacha: {name}!`))
		return
	end

	if typeof(state.Target) ~= "string" or state.Target ~= "Player" and state.Target ~= "Fighter" then
		warn((`[GACHA] Target wasn't given (or invalid) for gacha: {name}!`))
		return
	end

	if typeof(state.Source) ~= "string" then
		warn((`[GACHA] Source wasn't given for gacha: {name}!`))
		return
	end

	local source = v.Sources[state.Source]

	if not source then
		warn((`[GACHA] Source: {state.Source} not found for gacha: {name}!`))
		return
	end

	state.Source = source

	if typeof(state.SoftPity) == "string" then
		local softPityTemplate = v.SoftPityTemplates[state.SoftPity]

		if softPityTemplate then
			state.SoftPity = softPityTemplate
		else
			warn((`[GACHA] Unknown soft pity template: {state.SoftPity}`))
			return
		end
	end

	local preview, v2 = SoftPity.GetPreview(state.SoftPity)

	if not preview then
		warn((`[GACHA] {name}: {v2}`))
		return
	end

	if typeof(state.Pity) == "string" then
		state.Pity = v.PityTemplates[state.Pity] or {}
	elseif typeof(state.Pity) == "table" then
		for k, v3 in state.Pity do
			if not (typeof(k) ~= "number" or typeof(v3) ~= "table" or typeof(v3.Name) ~= "string" or typeof(v3.Amount) ~= "number") then
				continue
			end

			state.Pity[k] = nil
		end
	else
		state.Pity = {}
	end

	if typeof(state.Icon) ~= "string" then
		state.Icon = ""
	end

	if typeof(state.Name) ~= "string" then
		state.Name = name
	end

	v.List[name] = state
end

function v.GetPityPreview(items, p)
	local v2

	if typeof(items) == "table" then
		v2 = getmetatable(items) == nil
	else
		v2 = false
	end

	if not v2 then
		return nil, "Pity must be a sequential table of stages."
	end

	local count = 0
	local v3 = 0

	for k, item in items do
		local v4 = module2:ValidateNumber(k)

		if v4 then
			if k >= 0 and k <= 9007199254740991 then
				v4 = k % 1 == 0
			else
				v4 = false
			end
		end

		if not v4 or k == 0 then
			return nil, "Each pity stage requires a positive integer index and a definition."
		end

		local v5

		if typeof(item) == "table" then
			v5 = getmetatable(item) == nil
		else
			v5 = false
		end

		if not v5 then
			return nil, "Each pity stage requires a positive integer index and a definition."
		end

		local name = item.Name
		local v6

		if typeof(name) == "string" then
			v6 = string.find(name, "%S") ~= nil
		else
			v6 = false
		end

		if not v6 then
			return nil, "Each pity stage requires a rarity name and a positive integer threshold."
		end

		local amount = item.Amount
		local v7 = module2:ValidateNumber(amount)

		if v7 then
			if amount >= 0 and amount <= 9007199254740991 then
				v7 = amount % 1 == 0
			else
				v7 = false
			end
		end

		if v7 and item.Amount ~= 0 then
			count += 1
			v3 = math.max(v3, k)
			continue
		end

		return nil, "Each pity stage requires a rarity name and a positive integer threshold."
	end

	if count ~= v3 then
		return nil, "Pity stages must be consecutive, starting at index 1."
	end

	if count == 0 then
		return {
			Enabled = false,
			WasReset = false
		}
	end

	local wasReset = false
	local currentIndex, currentAmount, v5, currentIndex3, currentAmount3, _, _

	-- [DEDUP] synthesized from 2 duplicated terminal regions
	local function deduplicatedTail()
		local name, currentIndex2

		if v5.Amount <= currentAmount3 then
			name = v5.Name
			currentIndex2 = currentIndex3
			currentAmount3 = 0
		else
			currentIndex2 = currentIndex
		end

		return {
			Enabled = true,
			WasReset = wasReset,
			Result = name,
			Stage = v5.Name,
			CurrentState = {
				CurrentIndex = currentIndex,
				CurrentAmount = currentAmount
			},
			NextState = {
				CurrentIndex = currentIndex2,
				CurrentAmount = currentAmount3
			},
			ObtainedState = {
				CurrentIndex = currentIndex3,
				CurrentAmount = 0
			}
		}
	end

	if p == nil then
		currentIndex = 1
		currentAmount = 0
		v5 = items[currentIndex]
		currentIndex3 = not (currentIndex < count) and 1 or currentIndex + 1
		currentAmount3 = currentAmount + 1
		return deduplicatedTail()
	else
		local v8

		if typeof(p) == "table" then
			v8 = getmetatable(p) == nil
		else
			v8 = false
		end

		if not v8 then
			return nil, "The pity state requires a positive integer index and a nonnegative integer count."
		end

		local currentIndex2 = p.CurrentIndex
		local v9 = module2:ValidateNumber(currentIndex2)

		if v9 then
			if currentIndex2 >= 0 and currentIndex2 <= 9007199254740991 then
				v9 = currentIndex2 % 1 == 0
			else
				v9 = false
			end
		end

		if not (v9 and p.CurrentIndex ~= 0) then
			return nil, "The pity state requires a positive integer index and a nonnegative integer count."
		end

		local currentAmount2 = p.CurrentAmount
		local v10 = module2:ValidateNumber(currentAmount2)

		if v10 then
			if currentAmount2 >= 0 and currentAmount2 <= 9007199254740991 then
				v10 = currentAmount2 % 1 == 0
			else
				v10 = false
			end
		end

		if v10 then
			currentIndex = p.CurrentIndex
			currentAmount = p.CurrentAmount

			if not items[currentIndex] then
				currentIndex = 1
				currentAmount = 0
				wasReset = true
			end

			v5 = items[currentIndex]
			currentIndex3 = not (currentIndex < count) and 1 or currentIndex + 1
			currentAmount3 = currentAmount + 1
			return deduplicatedTail()
		end

		return nil, "The pity state requires a positive integer index and a nonnegative integer count."
	end
end

function v.GetNextPityState(data, p)
	if not data.Enabled then
		return nil
	end

	if data.Stage and p[data.Stage] then
		return data.ObtainedState
	end

	return data.NextState
end

function v.GetNormalPreview(data, gachaLuck: number, p2, p3)
	local v2

	if typeof(data) == "table" then
		v2 = getmetatable(data) == nil
	else
		v2 = false
	end

	if not v2 then
		return nil, "A normal gacha definition is required."
	end

	local source = data.Source
	local v3

	if typeof(source) == "table" then
		v3 = getmetatable(source) == nil
	else
		v3 = false
	end

	if not (v3 and data.Source.Type == "Normal") then
		return nil, "A normal gacha definition is required."
	end

	local normal = data.Source.Normal
	local v4, v5 = module.Validate(normal, gachaLuck)

	if not v4 then
		return nil, v5
	end

	local v6 = {}

	for k, v7 in normal do
		local v8

		if typeof(k) == "string" then
			v8 = string.find(k, "%S") ~= nil
		else
			v8 = false
		end

		if not v8 or v7.Name ~= k then
			return nil, "Each normal result must match its catalog name and specify a rarity."
		end

		local rarity = v7.Rarity
		local v9

		if typeof(rarity) == "string" then
			v9 = string.find(rarity, "%S") ~= nil
		else
			v9 = false
		end

		if v9 then
			if v7.Chance > 0 then
				v6[v7.Rarity] = true
			end

			continue
		end

		return nil, "Each normal result must match its catalog name and specify a rarity."
	end

	local pityPreview, v7 = v.GetPityPreview(data.Pity, p2)

	if not pityPreview then
		return nil, v7
	end

	for _, v8 in data.Pity do
		if not v6[v8.Name] then
			return nil, (`Pity rarity {v8.Name} has no result with a positive weight.`)
		end
	end

	local preview, v8 = SoftPity.GetPreview(data.SoftPity, p3)

	if not preview then
		return nil, v8
	end

	local v9

	if pityPreview.Result then
		v9 = {}

		for k, v10 in normal do
			if v10.Rarity == pityPreview.Result then
				v9[k] = v10
			end
		end
	else
		v9 = normal
	end

	local chances, v10 = module.GetChances(v9, gachaLuck, true)

	if not chances then
		return nil, v10
	end

	if not pityPreview.Result then
		local rarities = {}

		for k, v11 in normal do
			rarities[k] = v11.Rarity
		end

		chances = SoftPity.Apply(chances, rarities, preview)
	end

	return {
		GachaLuck = gachaLuck,
		SoftPity = preview,
		Chances = chances,
		Pity = pityPreview
	}
end

function v.GetTalentsPreview(data, p: number, p2, p3, p4)
	local pityPreview, v2 = v.GetPityPreview(data.Pity, p2)

	if not pityPreview then
		return nil, v2
	end

	local preview, v3 = SoftPity.GetPreview(data.SoftPity, p3)

	if not preview then
		return nil, v3
	end

	local ranks = data.Source.Talents.Ranks
	local fields = {}
	local targets = {}

	for k, v6 in data.Source.Talents.List do
		if p4[k] then
			continue
		end

		local rank = ranks[v6.StartRank]
		local rank2 = ranks[v6.EndRank]

		if not (rank and rank2) then
			return nil, "Invalid Talent rank range."
		end

		local v7 = {}
		local v8 = {}

		for k2, rank3 in ranks do
			if rank3.Index < math.min(rank.Index, rank2.Index) or rank3.Index > math.max(rank.Index, rank2.Index) then
				continue
			end

			v7[k2] = {
				Name = k2,
				Chance = rank3.Chance
			}
			v8[k2] = k2
		end

		local chances, v9 = module.GetChances(v7, p, true)

		if not chances then
			return nil, v9
		end

		fields[k] = SoftPity.Apply(chances, v8, preview)

		if pityPreview.Result and v7[pityPreview.Result] and v7[pityPreview.Result].Chance > 0 then
			table.insert(targets, k)
		end
	end

	if not next(fields) then
		return nil, "No unlocked Talent fields."
	end

	if pityPreview.Result and #targets == 0 then
		return nil, "No unlocked Talent field can satisfy pity."
	end

	return {
		Pity = pityPreview,
		SoftPity = preview,
		Fields = fields,
		Targets = targets
	}
end

for _, moduleScript in script.Sources:GetChildren() do
	if moduleScript:IsA("ModuleScript") then
		v.RegisterSource(moduleScript.Name, require(moduleScript))
	end
end

local machines = script:FindFirstChild("Machines")

if machines then
	for _, moduleScript in machines:GetChildren() do
		if moduleScript:IsA("ModuleScript") then
			v.RegisterGacha(moduleScript.Name, require(moduleScript))
		end
	end
end

function v.SystemSolver(p: string, p2)
	local result = {}

	for k, v2 in p2.Gacha do
		local v3 = v.List[k]

		if not (v3 and v3.Target == "Player") then
			continue
		end

		if v3.Source.Type == "Normal" then
			local current = v2.Current

			if typeof(current) == "string" then
				local v4 = v3.Source.Normal[current]

				if v4 then
					local perk = v4.Perks[p]

					if perk then
						table.insert(result, perk)
					end
				end
			end
		elseif v3.Source.Type == "Talents" then
			local current = v2.Current

			if typeof(current) == "table" then
				for k2, v4 in current do
					local v5 = v3.Source.Talents.List[k2]

					if not v5 then
						continue
					end

					local rank = v3.Source.Talents.Ranks[v4]

					if not rank then
						continue
					end

					local perk = v5.Perks[p]

					if perk then
						table.insert(result, {
							Type = perk.Type,
							Amount = perk.Amount * rank.Multiplier
						})
					end
				end
			end
		end
	end

	return result
end

return table.freeze(v)