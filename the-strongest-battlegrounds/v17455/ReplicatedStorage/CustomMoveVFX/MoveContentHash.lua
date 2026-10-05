local MoveContentHash = {}

local function mix(p, value)
	local count = #value

	if count > 256 then
		value = tostring(count) .. string.sub(value, 1, 128) .. string.sub(value, count - 127, count)
		count = #value
	end

	for i = 1, count do
		p = bit32.bxor(p, string.byte(value, i)) * 16777619 % 4294967296
	end

	return p
end

local function valStr(item)
	local typeName = typeof(item)

	if typeName == "boolean" then
		if item then
			return "T"
		end

		return "F"
	else
		if typeName == "number" then
			return string.format("n%.6g", item)
		elseif typeName == "Vector3" then
			return string.format("v%.4f,%.4f,%.4f", item.X, item.Y, item.Z)
		elseif typeName == "Color3" then
			return string.format("c%.4f,%.4f,%.4f", item.R, item.G, item.B)
		elseif typeName == "CFrame" then
			return "f" .. tostring(item)
		end

		return "s" .. tostring(item)
	end
end

local hashTable

hashTable = function(p, items, p2)
	if p2 > 8 then
		return (mix(p, "DEEP"))
	end

	local v = {}

	for k in pairs(items) do
		v[#v + 1] = tostring(k)
	end

	table.sort(v)

	for _, v2 in ipairs(v) do
		local v3 = mix(p, v2)
		local item = items[v2]

		if type(item) == "table" then
			p = mix(hashTable(mix(v3, "{"), item, p2 + 1), "}")
		else
			p = mix(v3, valStr(item))
		end
	end

	return p
end

local object = setmetatable({}, {
	__mode = "k"
})

function MoveContentHash.hashBuffer(buf)
	if typeof(buf) ~= "buffer" then
		return nil
	end

	local v = object[buf]

	if v ~= nil then
		return v
	end

	local v2 = buffer.len(buf)
	local total = 0
	local v3 = 2166136261

	while total + 4 <= v2 do
		local v4 = buffer.readu32(buf, total)
		v3 = bit32.bxor(
			bit32.bxor(
				bit32.bxor(
					bit32.bxor(v3, (bit32.band(v4, 255))) * 16777619 % 4294967296,
					(bit32.band(bit32.rshift(v4, 8), 255))
				) * 16777619 % 4294967296,
				(bit32.band(bit32.rshift(v4, 16), 255))
			) * 16777619 % 4294967296,
			(bit32.rshift(v4, 24))
		) * 16777619 % 4294967296
		total += 4
	end

	while total < v2 do
		v3 = bit32.bxor(v3, (buffer.readu8(buf, total))) * 16777619 % 4294967296
		total += 1
	end

	local v4 = string.format("bf_%08x_%d", v3, v2)
	object[buf] = v4
	return v4
end

function MoveContentHash.hash(list)
	if type(list) ~= "table" then
		return "mv_none"
	end

	local v = mix(2166136261, tostring(#list))

	for _, v2 in ipairs(list) do
		if type(v2) ~= "table" then
			continue
		end

		v = mix(
			mix(
				mix(mix(mix(mix(v, "|"), tostring(v2.Time)), tostring(v2.EventType)), tostring(v2.EventCategory)),
				tostring(v2.Branch)
			),
			tostring(v2.uid)
		)

		if type(v2.Properties) == "table" then
			v = hashTable(mix(v, "P"), v2.Properties, 0)
		end

		if type(v2.Data) == "table" then
			v = hashTable(mix(v, "D"), v2.Data, 0)
		end
	end

	return string.format("mv_%08x_%d", v, #list)
end

return MoveContentHash