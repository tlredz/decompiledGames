local Validator = require(script.Parent.Parent.Utils.Validator)
local v = {}

local function IsCounter(p)
	local v2 = Validator:ValidateNumber(p)

	if v2 then
		if p >= 0 and p <= 9007199254740991 then
			return p % 1 == 0
		else
			return false
		end
	end

	return v2
end

function v.GetState(p, p2: string)
	if p.SoftPity == nil then
		return nil
	end

	return typeof(p.SoftPity) == "table" and p.SoftPity[p2]
end

function v.GetPreview(p, p2)
	local v2 = p == nil and {} or p

	if typeof(v2) ~= "table" then
		return nil, "Soft pity requires a sequential configuration."
	end

	local counters = {}
	local logMultipliers = {}
	local count = 0
	local v5 = 0

	for k, v6 in v2 do
		local v7 = Validator:ValidateNumber(k)

		if v7 then
			if k >= 0 and k <= 9007199254740991 then
				v7 = k % 1 == 0
			else
				v7 = false
			end
		end

		if not v7 or k == 0 or typeof(v6) ~= "table" then
			return nil, "Invalid soft pity entry."
		end

		if typeof(v6.Name) ~= "string" or not string.find(v6.Name, "%S") or counters[v6.Name] ~= nil then
			return nil, "Soft pity targets must have unique names."
		end

		local amount = v6.Amount
		local v8 = Validator:ValidateNumber(amount)

		if v8 then
			if amount >= 0 and amount <= 9007199254740991 then
				v8 = amount % 1 == 0
			else
				v8 = false
			end
		end

		if not v8 or v6.Amount == 0 or not Validator:ValidateNumber(v6.Multiplier) or v6.Multiplier < 1 then
			return nil, "Soft pity requires a positive integer interval and a multiplier of at least one."
		end

		if p2 ~= nil and typeof(p2) ~= "table" then
			return nil, "Invalid soft pity state."
		end

		local v9 = (not p2 or p2[v6.Name] == nil) and 0 or p2[v6.Name]
		local v10 = Validator:ValidateNumber(v9)

		if v10 then
			if v9 >= 0 and v9 <= 9007199254740991 then
				v10 = v9 % 1 == 0
			else
				v10 = false
			end
		end

		if not v10 then
			return nil, "Invalid soft pity counter."
		end

		counters[v6.Name] = v9
		logMultipliers[v6.Name] = math.floor(v9 / v6.Amount) * math.log(v6.Multiplier)
		count += 1
		v5 = math.max(v5, k)
	end

	if v5 == count then
		return {
			Enabled = count > 0,
			Counters = counters,
			LogMultipliers = logMultipliers
		}
	end

	return nil, "Soft pity entries must be consecutive."
end

function v.Apply(items, p, p2)
	if not p2.Enabled then
		return items
	end

	local total = 0
	local v2 = {}
	local v3 = false

	for _, item in items do
		local v4 = p[item.Name]
		local v5 = v4 and p2.LogMultipliers[v4]

		if v5 == nil or not (item.Chance > 0) then
			total += item.Chance
		else
			v2[v4] = (v2[v4] or 0) + item.Chance
			v3 = v3 or v5 > 0
		end
	end

	if not v3 then
		return items
	end

	local v4 = {}
	local v5 = -1e999

	for k, v6 in v2 do
		local v7 = math.log(v6) + p2.LogMultipliers[k]
		v4[k] = v7
		v5 = math.max(v5, v7)
	end

	local total2 = 0

	for _, v6 in v4 do
		total2 += math.exp((math.max(-220, v6 - v5)))
	end

	local v6 = v5 + math.log(total2)
	local v7 = v6 >= 4.605170185988092 or total == 0
	local v8 = v7 and 100 or math.exp(v6)
	local v9 = {}

	for k, v10 in v4 do
		local v11

		if v7 then
			v11 = math.exp((math.max(-220, v10 - v5))) * 100 / total2
		else
			v11 = math.exp(v10)
		end

		v9[k] = v11
	end

	local clones = {}

	for k, item in items do
		local clone = table.clone(item)
		local v10 = p[item.Name]

		if v10 and v9[v10] then
			clone.Chance = v9[v10] * (item.Chance / v2[v10])
		else
			clone.Chance = not (total > 0) and 0 or item.Chance * ((100 - v8) / total)
		end

		clones[k] = clone
	end

	return clones
end

function v.Advance(p, p2)
	local result = {}

	for k, counter in p.Counters do
		result[k] = p2[k] and 0 or math.min(9007199254740991, counter + 1)
	end

	return result
end

function v:Commit(p2: string, p3, p4)
	if not p3.Enabled then
		return
	end

	self.SoftPity = self.SoftPity or {}
	self.SoftPity[p2] = v.Advance(p3, p4)
end

return table.freeze(v)