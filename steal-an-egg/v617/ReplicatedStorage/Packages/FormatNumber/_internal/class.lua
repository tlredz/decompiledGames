local v = {}
local v2 = {}
local object = setmetatable({}, {
	__mode = "k"
})

local function proxy_tostring(p)
	return object[p].type_name .. ": " .. object[p].as_string
end

local frozen = table.freeze({
	DEFAULT = 0,
	NUMBER_FORMATTER = 1,
	SYMBOLS = 2
})
v.ImmutabilityType = frozen

function v.create_init_function(type_name: string, value: string?, p, p2, p3: number)
	if p2 then
		p = setmetatable(table.clone(p2), {
			__index = p
		})
	end

	v2[type_name] = value or "FormatNumberObject"
	return function(list, p4)
		local v3 = newproxy(true)
		local metatable = getmetatable(v3)

		if p3 ~= frozen.SYMBOLS and type(list) == "table" then
			table.freeze(list)
		end

		metatable.data = list
		metatable.resolved_data = nil
		metatable.type_name = type_name
		metatable.as_string = p4 or string.sub(tostring(v3), 11)
		metatable.__index = p
		metatable.__tostring = proxy_tostring
		metatable.__metatable = "The metatable is locked"

		if p3 ~= frozen.NUMBER_FORMATTER then
			table.freeze(metatable)
		end

		object[v3] = metatable
		return v3
	end
end

function v.is_a(p, p2)
	local v3 = object[p]
	local type_name = v3 and v3.type_name
	local v4 = false

	if type_name == p2 then
		return true
	end

	if not type_name then
		return v4
	end

	repeat
		type_name = v2[type_name]
		v4 = type_name == p2
	until not type_name or v4

	return v4
end

function v.get_data(p)
	return object[p].data
end

function v.get_resolved_data(p, callback)
	local v3 = object[p]
	local resolved_data = v3.resolved_data

	if resolved_data then
		return resolved_data
	end

	resolved_data = callback(v3.data)
	v3.resolved_data = resolved_data

	if resolved_data then
		table.freeze(v3)
	end

	return resolved_data
end

function v.try_coerce(p, value, value2, p2)
	local v3 = false
	local data = nil

	if value == nil and p2 ~= nil then
		data = p2
		v3 = true
	elseif value2 == "string" then
		if type(value) == "string" then
			data = value
			v3 = true
		elseif type(value) == "number" then
			data = tostring(value)
			v3 = true
		else
			v3 = false
		end
	elseif value2 == "number" then
		data = tonumber(value)

		if data then
			v3 = true
		else
			value2 = "number" .. " object"
			v3 = false
		end
	elseif string.sub(value2, 1, 1) == "{" then
		local v4 = string.sub(value2, 2, -2)

		if type(value) == "table" then
			data = table.move(value, 1, rawlen(value), 1, table.create((rawlen(value))))

			for k, v5 in data do
				if type(v5) ~= v4 then
					error(
						string.format(
							"Values inside the table argument must be a %s, index %d got %s",
							v4,
							k,
							(type(v5))
						),
						3
					)
				end
			end

			v3 = true
		else
			value2 = "table"
		end
	elseif v.is_a(value, value2) then
		data = object[value].data
		v3 = true
	end

	if not v3 then
		error(string.format("Argument #%d provided must be a %s", p, value2), 3)
	end

	return data
end

function v.try_coerce_range(p, p2, p3, p4, p5)
	local v3 = nil

	if p2 == nil then
		v3 = p5
	else
		local v4 = tonumber(p2)

		if v4 then
			local double_to_int32 = v.double_to_int32(v4)

			if p3 <= double_to_int32 and double_to_int32 <= p4 then
				v3 = double_to_int32
			end
		end
	end

	return v3 or error(
		string.format(
			"Argument #%d provided must be an integer that is in the range of %d to (and including) %d",
			p,
			p3,
			p4
		),
		3
	)
end

function v.try_coerce_enum(p, p2, items, p3)
	local v3 = nil

	if p2 == nil then
		v3 = p3
	elseif tonumber(p2) then
		local double_to_int32 = v.double_to_int32(p2)

		for _, item in items do
			if double_to_int32 ~= item then
				continue
			end

			v3 = item
			break
		end
	end

	return v3 or error(string.format("Argument #%d provided is out of range", p), 3)
end

function v.double_to_int32(p: number)
	if not (p > -2147483649 and p < 2147483648) then
		return UDim.new(nil, p).Offset
	end

	if p <= -1 then
		return (math.ceil(p))
	end

	if p >= 1 then
		return (math.floor(p))
	end

	return 0
end

return table.freeze(v)