local StringUtil = {
	prefix = function(value, p)
		return value:sub(1, p)
	end,
	suffix = function(value, p)
		return value:sub(#value - p + 1, #value)
	end
}

function StringUtil.startsWith(p, list)
	return StringUtil.prefix(p, #list) == list
end

function StringUtil.endsWith(p, list)
	return StringUtil.suffix(p, #list) == list
end

local function head(value)
	return value:sub(1, 1)
end

local function tail(value)
	return value:sub(2, #value)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function levMemo(lower, p)
	local v = {}
	local lev

	lev = function(value, value2)
		local v2 = v[value]

		if not v2 then
			v2 = {}
			v[value] = v2
		end

		local v3 = v2[value2]

		if v3 then
			return v3
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function cache(p2)
			v[value][value2] = p2
			return p2
		end

		if #value2 == 0 then
			return cache(#value)
		elseif #value == 0 then
			return cache(#value2)
		elseif value:sub(1, 1) == value2:sub(1, 1) then
			return cache(lev(value:sub(2, #value), tail(value2)))
		else
			return cache(math.min(
				lev(value:sub(2, #value), value2),
				lev(value, tail(value2)),
				lev(value:sub(2, #value), tail(value2))
			) + 1)
		end
	end

	return (lev(lower, p))
end

function StringUtil.endCursorEdits(value, value2)
	local v = 1
	local result = {}

	while v <= #value and v <= #value2 and value:sub(v, v) == value2:sub(v, v) do
		v += 1
	end

	local v2 = v - 1

	for _ = #value, v2 + 1, -1 do
		table.insert(result, {
			op = "pop"
		})
	end

	for i = v2 + 1, #value2 do
		table.insert(result, {
			op = "push",
			char = value2:sub(i, i)
		})
	end

	return result
end

function StringUtil.fuzzySearch(value, value2, p)
	local lower = value:lower()
	local lower2 = value2:lower()
	local v = lower2:sub(1, (math.min(#lower, #lower2)))
	return levMemo(lower, v) / #v <= p
end

function StringUtil.countFormatArgs(list)
	local count = #list
	local byte = string.byte
	local total = 1
	local count2 = 0

	while total <= count do
		if byte(list, total) == 37 then
			if byte(list, total + 1) == 37 then
				total += 2
			else
				total += 1

				while total <= count do
					local v = byte(list, total)

					if v >= 65 and v <= 90 or v >= 97 and v <= 122 then
						count2 += 1
						total += 1
						break
					else
						total += 1
					end
				end
			end
		else
			total += 1
		end
	end

	return count2
end

function StringUtil.capitalize(value)
	return string.upper(value:sub(1, 1)) .. value:sub(2, #value)
end

function StringUtil.pascalCase(value)
	local v, _, _ = value:gmatch("[^%s]+")
	local capitalize = StringUtil.capitalize(v())

	for k in v do
		capitalize ..= " " .. StringUtil.capitalize(k)
	end

	return capitalize
end

return StringUtil