local function nonEmptyString(value)
	return type(value) == "string" and value ~= ""
end

local SeasonalCurrencyCore = {}

function SeasonalCurrencyCore.resolveTarget(value, value2, value3, value4)
	local v

	if type(value) == "string" then
		v = value ~= ""
	else
		v = false
	end

	if v then
		local v2

		if type(value2) == "string" then
			v2 = value2 ~= ""
		else
			v2 = false
		end

		if v2 then
			return value, value2
		end

		if value ~= value3 then
			return value, nil
		end

		local v3

		if type(value4) == "string" then
			v3 = value4 ~= ""
		else
			v3 = false
		end

		if v3 then
			return value, value4
		end

		return value, nil
	else
		local v2

		if type(value3) == "string" then
			v2 = value3 ~= ""
		else
			v2 = false
		end

		if not v2 then
			return nil, "NOT_CONFIGURED"
		end

		local v3

		if type(value4) == "string" then
			v3 = value4 ~= ""
		else
			v3 = false
		end

		if v3 then
			return value3, value4
		end

		return nil, "NOT_CONFIGURED"
	end
end

function SeasonalCurrencyCore:credit(p2: string, p3: string?, value)
	if type(value) ~= "number" or value <= 0 or value % 1 ~= 0 then
		return false, "BAD_AMOUNT"
	end

	if type(self) ~= "table" then
		return false, "NO_SEASONAL"
	end

	local v = self[p2]

	if p3 == nil then
		if type(v) ~= "number" then
			return false, "UNKNOWN_TARGET"
		end

		self[p2] = v + value
		return true, v, v + value, "Seasonal." .. p2
	else
		if v == nil then
			v = {}
			self[p2] = v
		elseif type(v) ~= "table" then
			return false, "NOT_NESTED"
		end

		local v2 = v[p3]

		if v2 == nil then
			v2 = 0
		elseif type(v2) ~= "number" then
			return false, "BAD_BALANCE"
		end

		v[p3] = v2 + value
		return true, v2, v2 + value, "Seasonal." .. p2 .. "." .. p3
	end
end

function SeasonalCurrencyCore.itemLabel(value, value2, value3, value4, value5, p)
	if value == "Coin" then
		return "Ichor"
	end

	if value == "SeasonalCurrency" then
		local v

		if type(value2) == "string" then
			v = value2 ~= ""
		else
			v = false
		end

		if v and value2 ~= value3 then
			return value2
		end

		local v2

		if type(value2) == "string" then
			v2 = value2 ~= ""
		else
			v2 = false
		end

		if not v2 then
			local v3

			if type(value5) == "string" then
				v3 = value5 ~= ""
			else
				v3 = false
			end

			if v3 and value5 ~= p then
				return value5
			end
		end

		local v3

		if type(value4) == "string" then
			v3 = value4 ~= ""
		else
			v3 = false
		end

		if v3 then
			return value4
		end

		local v4

		if type(value3) == "string" then
			v4 = value3 ~= ""
		else
			v4 = false
		end

		if v4 then
			return value3
		end
	end

	if type(value) == "string" then
		return value
	end

	return "Item"
end

return SeasonalCurrencyCore