local Luck = require(script.Parent.Luck)
local Validator = require(script.Parent.Validator)
local random = Random.new()
local v = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function IsName(value)
	return typeof(value) == "string" and string.find(value, "%S") ~= nil
end

local function IsTable(p)
	return typeof(p) == "table" and getmetatable(p) == nil
end

local function IsKey(value)
	if typeof(value) == "string" then
		return IsName(value)
	else
		local v2 = Validator:ValidateNumber(value)

		if v2 then
			if value > 0 and value <= 9007199254740991 then
				return value % 1 == 0
			else
				return false
			end
		end

		return v2
	end
end

local function TrimDecimals(value: string)
	if not string.find(value, ".", 1, true) then
		return value
	end

	local v2 = string.gsub(value, "0+$", "")
	return (string.gsub(v2, "%.$", ""))
end

function v.Validate(items, p: number)
	local v2

	if typeof(items) == "table" then
		v2 = getmetatable(items) == nil
	else
		v2 = false
	end

	if not (v2 and next(items)) then
		return false, "Rewards must be a nonempty table without a metatable."
	end

	if not Validator:ValidateNumber(p) or p <= -1 then
		return false, "Luck must be finite and greater than -1."
	end

	local v3 = {}
	local total = 0

	for k, item in items do
		local v4

		if typeof(k) == "string" then
			if typeof(k) == "string" then
				v4 = string.find(k, "%S") ~= nil
			else
				v4 = false
			end
		else
			v4 = Validator:ValidateNumber(k)

			if v4 then
				if k > 0 and k <= 9007199254740991 then
					v4 = k % 1 == 0
				else
					v4 = false
				end
			end
		end

		if not v4 then
			return false, "Each reward requires a valid key and a nonempty name."
		end

		local v5

		if typeof(item) == "table" then
			v5 = getmetatable(item) == nil
		else
			v5 = false
		end

		if not v5 then
			return false, "Each reward requires a valid key and a nonempty name."
		end

		local name = item.Name
		local v6

		if typeof(name) == "string" then
			v6 = string.find(name, "%S") ~= nil
		else
			v6 = false
		end

		if v6 then
			if v3[item.Name] then
				return false, "Reward names must be unique."
			end

			if not Validator:ValidateNumber(item.Chance) or item.Chance < 0 then
				return false, "Reward weights must be finite and nonnegative."
			end

			v3[item.Name] = true
			total += item.Chance
			continue
		end

		return false, "Each reward requires a valid key and a nonempty name."
	end

	if Validator:ValidateNumber(total) and not (total <= 0) then
		return true
	end

	return false, "The total reward weight must be finite and positive."
end

function v.GetChances(p, p2: number, flag: boolean?)
	local v2, v3 = v.Validate(p, p2)

	if not v2 then
		return nil, v3
	end

	if flag ~= nil and typeof(flag) ~= "boolean" then
		return nil, "NameIndex must be a boolean."
	end

	local chances = Luck.GetChances(p, p2, flag)

	if not chances then
		return nil, "The probability calculation failed."
	end

	local total = 0

	for _, chance in chances do
		if not Validator:ValidateNumber(chance.Chance) or chance.Chance < 0 or chance.Chance > 100 then
			return nil, "The probability calculation produced an invalid percentage."
		end

		if p[chance.RealIndex].Chance > 0 and chance.Chance == 0 then
			return nil, "A positive reward weight became unrepresentable as a percentage."
		else
			total += chance.Chance
		end
	end

	if Validator:ValidateNumber(total) and not (math.abs(total - 100) > 1e-8) then
		return chances
	end

	return nil, "The calculated probabilities do not total 100 percent."
end

function v.RollChances(items, p: number?)
	local v2, v3 = v.Validate(items, 0)

	if not v2 then
		return nil, v3
	end

	if p ~= nil and (not Validator:ValidateNumber(p) or p < 0 or p >= 1) then
		return nil, "The random sample must be finite and between 0 inclusive and 1 exclusive."
	end

	local v4 = {}
	local total = 0

	for _, item in items do
		if item.Chance > 100 then
			return nil, "A probability cannot exceed 100 percent."
		end

		if item.Chance > 0 then
			table.insert(v4, item)
		end
	end

	table.sort(v4, function(a, b)
		if a.Chance == b.Chance then
			return a.Name < b.Name
		end

		return a.Chance < b.Chance
	end)

	for _, v5 in v4 do
		total += v5.Chance
	end

	if not Validator:ValidateNumber(total) or math.abs(total - 100) > 1e-8 then
		return nil, "The supplied probabilities do not total 100 percent."
	end

	local v5 = (p or random:NextNumber()) * total
	local total2 = 0

	for _, v6 in v4 do
		total2 += v6.Chance

		if v5 < total2 then
			return v6.Name
		end
	end

	return v4[#v4].Name
end

function v.FormatPercentage(p: number)
	if not Validator:ValidateNumber(p) or p < 0 or p > 100 then
		return nil, "A percentage must be finite and between 0 and 100."
	end

	if p == 0 then
		return "0%"
	elseif p == 100 then
		return "100%"
	end

	for i = 2, 12 do
		local v2 = string.format("%." .. i .. "f", p)
		local v3 = tonumber(v2)

		if not (v3 and v3 > 0) then
			continue
		end

		if string.find(v2, ".", 1, true) then
			local v4 = string.gsub(v2, "0+$", "")
			v2 = string.gsub(v4, "%.$", "")
		end

		return v2 .. "%"
	end

	for i = 6, 17 do
		local v2 = string.format("%." .. i .. "g", p)
		local v3 = tonumber(v2)

		if v3 and v3 > 0 and v3 < 100 then
			return v2 .. "%"
		end
	end

	local v2 = tostring(p)
	local v3 = tonumber(v2)

	if v3 and v3 > 0 and v3 < 100 then
		return v2 .. "%"
	end

	return nil, "The percentage cannot be formatted without changing its bounds."
end

return table.freeze(v)