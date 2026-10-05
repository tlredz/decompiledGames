game:GetService("HttpService")
local Mappings = require(script.Parent.Mappings)
local Utils = require(script.Parent.Utils)
local TYPE_SIGNATURES = Utils.TYPE_SIGNATURES
local TYPE_FORMATS = Utils.TYPE_FORMATS
local Deserialize = {
	CFrame = function(buf, offset, _)
		return CFrame.new(
			buffer.readi32(buf, offset) / 100,
			buffer.readi32(buf, offset + 4) / 100,
			buffer.readi32(buf, offset + 8) / 100,
			buffer.readi8(buf, offset + 13) / 127,
			buffer.readi8(buf, offset + 14) / 127,
			buffer.readi8(buf, offset + 15) / 127,
			buffer.readi8(buf, offset + 16) / 127,
			buffer.readi8(buf, offset + 17) / 127,
			buffer.readi8(buf, offset + 18) / 127,
			buffer.readi8(buf, offset + 19) / 127,
			buffer.readi8(buf, offset + 20) / 127,
			buffer.readi8(buf, offset + 21) / 127
		)
	end,
	Vector3 = function(buf, offset, _)
		return (Vector3.new(
			buffer.readi32(buf, offset) / 100,
			buffer.readi32(buf, offset + 4) / 100,
			buffer.readi32(buf, offset + 8) / 100
		))
	end,
	Vector3int16 = function(buf, offset, _)
		return Vector3int16.new(
			buffer.readi16(buf, offset),
			buffer.readi16(buf, offset + 2),
			(buffer.readi16(buf, offset + 4))
		)
	end,
	Vector2 = function(buf, offset, _)
		return Vector2.new(buffer.readi32(buf, offset) / 100, buffer.readi32(buf, offset + 4) / 100)
	end,
	Vector2int16 = function(buf, offset, _)
		return Vector2int16.new(buffer.readi16(buf, offset), (buffer.readi16(buf, offset + 2)))
	end,
	Color3 = function(buf, offset, _)
		return Color3.fromRGB(
			buffer.readu8(buf, offset),
			buffer.readu8(buf, offset + 1),
			(buffer.readu8(buf, offset + 2))
		)
	end,
	EnumItem = function(buf, offset, _)
		local v = buffer.readu8(buf, offset)
		local v2 = buffer.readu16(buf, offset + 1)
		local v3 = Mappings.enumMapping[v]
		return Enum[v3]:FromValue(v2)
	end,
	number = function(p, p2, p3)
		return buffer[`read{p3.numbersAs}`](p, p2) / 100, Utils.NUMBER_SIZES[p3.numbersAs]
	end,
	boolean = function(buf, offset, _)
		local v = buffer.readu8(buf, offset)
		return Mappings.bools[v]
	end,
	string = function(buf, p, _)
		local count = 0
		local v = {}

		while true do
			local v2 = buffer.readu8(buf, p + count)

			if v2 == 0 then
				break
			end

			table.insert(v, (string.char(v2)))
			count += 1
		end

		return table.concat(v), count + 1
	end
}

-- equivalent calls inferred from this helper; original call sites unknown
local function sign_error(p, p2)
	local formatted = ("Unexpected signature: \n SIGNATURE: %s"):format(p2)

	if p.errorOnException then
		error(formatted)
	else
		warn(formatted)
	end
end

local function readMember(buf, offset, p)
	local v = buffer.readu8(buf, offset)
	local v2 = TYPE_SIGNATURES[v]
	local v3 = Deserialize[v2]

	if not v3 then
		return nil, true, v
	end

	local v4, v5 = v3(buf, offset + 1, p)
	return v4, false, 1 + (v5 or TYPE_FORMATS[v2])
end

function Deserialize.table(buf, p, p2)
	local result = {}
	local v = p

	local function r()
		local v2 = buf
		local v3 = v
		local v4 = p2
		local v5 = buffer.readu8(v2, v3)
		local v6 = TYPE_SIGNATURES[v5]
		local v7 = Deserialize[v6]
		local v8, v9

		if v7 then
			local v10
			v8, v10 = v7(v2, v3 + 1, v4)
			v5 = 1 + (v10 or TYPE_FORMATS[v6])
			v9 = false
		else
			v9 = true
		end

		if not v9 then
			v += v5
			return v8
		end

		v += 1
		sign_error(p2, v5) -- equivalent call inferred; original call site unknown
		return "ERROR"
	end

	while buffer.readu8(buf, v) ~= 0 do
		if p2.keys then
			local v2 = v
			local v3 = buffer.readu8(buf, v2)
			local v4 = TYPE_SIGNATURES[v3]
			local v5 = Deserialize[v4]
			local v6, flag

			if v5 then
				local v7
				v6, v7 = v5(buf, v2 + 1, p2)
				v3 = 1 + (v7 or TYPE_FORMATS[v4])
				flag = false
			else
				flag = true
			end

			if flag then
				v += 1
				sign_error(p2, v3) -- equivalent call inferred; original call site unknown
				v6 = "ERROR"
			else
				v += v3
			end

			local v7 = v
			local v8 = buffer.readu8(buf, v7)
			local v9 = TYPE_SIGNATURES[v8]
			local v10 = Deserialize[v9]
			local v11, flag2

			if v10 then
				local v12
				v11, v12 = v10(buf, v7 + 1, p2)
				v8 = 1 + (v12 or TYPE_FORMATS[v9])
				flag2 = false
			else
				flag2 = true
			end

			if flag2 then
				v += 1
				sign_error(p2, v8) -- equivalent call inferred; original call site unknown
				v11 = "ERROR"
			else
				v += v8
			end

			result[v6] = v11
		else
			local v2 = v
			local v3 = buffer.readu8(buf, v2)
			local v4 = TYPE_SIGNATURES[v3]
			local v5 = Deserialize[v4]
			local v6, flag

			if v5 then
				local v7
				v6, v7 = v5(buf, v2 + 1, p2)
				v3 = 1 + (v7 or TYPE_FORMATS[v4])
				flag = false
			else
				flag = true
			end

			if flag then
				v += 1
				sign_error(p2, v3) -- equivalent call inferred; original call site unknown
				v6 = "ERROR"
			else
				v += v3
			end

			table.insert(result, v6)
		end
	end

	return result, v - p + 1
end

local function getApplyInstanceProperties(list)
	local v = list[1]
	local name = list[2]
	local v3 = list[3]
	local v4 = list[4]
	local v5 = list[5]
	local v6 = list[6]
	local instance = Instance.new(v)
	instance.Name = name

	for k, v7 in v3 do
		instance:SetAttribute(k, v7)
	end

	for _, tag in v4 do
		instance:AddTag(tag)
	end

	for k, v7 in v5 do
		if k:match("METHOD_") ~= nil then
			local v8 = k:split("_")[2]
			Utils.Properties.methods[v8](instance, v7)
		else
			instance[k] = v7
		end
	end

	for _, v7 in v6 do
		v7.Parent = instance
	end

	return instance
end

function Deserialize.Instance(buf, offset, p)
	if p.readInstanceAsCopy then
		local table2, v = Deserialize.table(buf, offset, p)
		return getApplyInstanceProperties(table2), v
	end

	local v = buffer.readu16(buf, offset)

	for _, descendant in game:GetDescendants() do
		if descendant:GetAttribute("UniqueId") == v then
			return descendant
		end
	end
end

return Deserialize