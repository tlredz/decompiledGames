local v = {
	[36] = true,
	[95] = true
}
local v2 = {
	[36] = true,
	[95] = true
}
local v3 = {
	[0] = -12336,
	[1] = -12592,
	[2] = -12848,
	[3] = -13104,
	[4] = -13360,
	[5] = -13616,
	[6] = -13872,
	[7] = -14128,
	[8] = 25180,
	[9] = 29788,
	[10] = 28252,
	[11] = -25136,
	[12] = 26204,
	[13] = 29276,
	[14] = -25904,
	[15] = -26160,
	[16] = -12337,
	[17] = -12593,
	[18] = -12849,
	[19] = -13105,
	[20] = -13361,
	[21] = -13617,
	[22] = -13873,
	[23] = -14129,
	[24] = -14385,
	[25] = -14641,
	[26] = -24881,
	[27] = -25137,
	[28] = -25393,
	[29] = -25649,
	[30] = -25905,
	[31] = -26161
}

for i = 65, 90 do
	v[i] = true
	v2[i] = true
end

for i = 97, 122 do
	v[i] = true
	v2[i] = true
end

v2[48] = true
v2[49] = true
v2[50] = true
v2[51] = true
v2[52] = true
v2[53] = true
v2[54] = true
v2[55] = true
v2[56] = true
v2[57] = true

local function Stream(buf: buffer)
	return {
		Buf = buf,
		Pos = 0,
		Cap = buffer.len(buf),
		Indent = 0,
		Pretty = false,
		Encoders = {},
		Null = nil,
		QuoteChar = 34,
		UnquoteIdent = false
	}
end

local function ToString(p)
	return buffer.readstring(p.Buf, 0, p.Pos)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function AllocSize(p: number)
	return (math.max(p, 2 ^ math.ceil((math.log(p, 2)))))
end

local function Reserve(state, p: number)
	local pos = state.Pos
	local pos2 = pos + p

	if state.Cap < pos2 then
		local cap = AllocSize(pos2) -- equivalent call inferred; original call site unknown
		local buf = buffer.create(cap)
		buffer.copy(buf, 0, state.Buf, 0, pos)
		state.Buf = buf
		state.Cap = cap
	end

	state.Pos = pos2
	return pos
end

-- equivalent calls inferred from this helper; original call sites unknown
local function WriteString(p, str: string)
	local v4 = string.len(str)
	local reserve = Reserve(p, v4)
	buffer.writestring(p.Buf, reserve, str, v4)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function WriteIndent(p)
	local v4 = p.Indent * 2
	local reserve = Reserve(p, v4)
	local buf = p.Buf

	for i = 0, v4 - 1 do
		buffer.writeu16(buf, reserve + i * 2, 8224)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function IncrementIndent(p, p2: number)
	p.Indent += p2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function WriteU8(p, value: number)
	local reserve = Reserve(p, 1)
	buffer.writeu8(p.Buf, reserve, value)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function WriteU16(p, value: number)
	local reserve = Reserve(p, 2)
	buffer.writeu16(p.Buf, reserve, value)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function WriteU32(p, value: number)
	local reserve = Reserve(p, 4)
	buffer.writeu32(p.Buf, reserve, value)
end

local function EncodeNull(p, _: nil)
	WriteU32(p, 1819047278) -- equivalent call inferred; original call site unknown
end

local function EncodeBoolean(p, flag: boolean)
	if flag then
		WriteU32(p, 1702195828) -- equivalent call inferred; original call site unknown
	else
		local reserve = Reserve(p, 5)
		local buf = p.Buf
		buffer.writeu32(buf, reserve, 1936482662)
		buffer.writeu8(buf, reserve + 4, 101)
	end
end

local function EncodeNumber(p, value: number)
	if value == value then
		if value == 1e999 then
			local reserve = Reserve(p, 8)
			local buf = p.Buf
			buffer.writeu32(buf, reserve, 1768320585)
			buffer.writeu32(buf, reserve + 4, 2037672302)
		elseif value == -1e999 then
			local reserve = Reserve(p, 9)
			local buf = p.Buf
			buffer.writeu8(buf, reserve, 45)
			buffer.writeu32(buf, reserve + 1, 1768320585)
			buffer.writeu32(buf, reserve + 5, 2037672302)
		else
			local v4 = tostring(value)
			local v5 = string.find(v4, "e%+")

			if v5 then
				v4 = string.sub(v4, 1, v5) .. string.sub(v4, v5 + 2)
			end

			WriteString(p, v4) -- equivalent call inferred; original call site unknown
		end
	else
		local reserve = Reserve(p, 3)
		local buf = p.Buf
		buffer.writeu16(buf, reserve, 24910)
		buffer.writeu8(buf, reserve + 2, 78)
	end
end

local function IsIdentifierName(_, value: string)
	local v4 = string.len(value)

	if not (v4 ~= 0 and v[string.byte(value, 1)]) then
		return false
	end

	local v6 = v2

	for i = 2, v4 do
		if not v6[string.byte(value, i)] then
			return false
		end
	end

	return true
end

local function EncodeString(state, value: string, unquoteIdent: boolean?)
	if unquoteIdent then
		local v4 = string.len(value)
		local v5

		if v4 == 0 then
			v5 = false
		elseif v[string.byte(value, 1)] then
			local v7 = v2
			local flag = true

			for i = 2, v4 do
				if v7[string.byte(value, i)] then
					continue
				end

				v5 = false
				flag = false
				break
			end

			if flag then
				v5 = true
			end
		else
			v5 = false
		end

		if not v5 then
			unquoteIdent = false
		end
	end

	local v4 = string.len(value)
	local pos = Reserve(state, v4 * 6 + 2)
	local buf = state.Buf
	local quoteChar = state.QuoteChar

	if not unquoteIdent then
		buffer.writeu8(buf, pos, quoteChar)
		pos += 1
	end

	for i = 1, v4 do
		local v6 = string.byte(value, i)

		if v6 > 31 then
			if v6 == quoteChar or v6 == 92 then
				buffer.writeu16(buf, pos, bit32.lshift(v6, 8) + 92)
				pos += 2
			else
				buffer.writeu8(buf, pos, v6)
				pos += 1
			end
		else
			local v7 = v3[v6]

			if v7 < 0 then
				v7 = -v7
				buffer.writeu32(buf, pos, 808482140)
				pos += 4
			end

			buffer.writeu16(buf, pos, v7)
			pos += 2
		end
	end

	if not unquoteIdent then
		buffer.writeu8(buf, pos, quoteChar)
		pos += 1
	end

	state.Pos = pos
end

local function EncodeBuffer(state, buf: buffer)
	local v4 = buffer.len(buf)
	local reserve = Reserve(state, 2 + v4 * 6)
	local buf2 = state.Buf
	local quoteChar = state.QuoteChar
	buffer.writeu8(buf2, reserve, quoteChar)
	local v6 = reserve + 1

	for i = 0, v4 - 1 do
		local v7 = buffer.readu8(buf, i)

		if v7 > 31 then
			if v7 == quoteChar or v7 == 92 then
				buffer.writeu16(buf2, v6, bit32.lshift(v7, 8) + 92)
				v6 += 2
			else
				buffer.writeu8(buf2, v6, v7)
				v6 += 1
			end
		else
			local v8 = v3[v7]

			if v8 < 0 then
				v8 = -v8
				buffer.writeu32(buf2, v6, 808482140)
				v6 += 4
			end

			buffer.writeu16(buf2, v6, v8)
			v6 += 2
		end
	end

	buffer.writeu8(buf2, v6, quoteChar)
	state.Pos = v6 + 1
end

-- equivalent calls inferred from this helper; original call sites unknown
local function EncodeAny(p, p2)
	if p2 == p.Null then
		p2 = nil
	end

	p.Encoders[typeof(p2)](p, p2)
end

local function EncodeArray(data, list)
	local pretty = data.Pretty
	WriteU8(data, 91) -- equivalent call inferred; original call site unknown

	if pretty then
		IncrementIndent(data, 1) -- equivalent call inferred; original call site unknown
	end

	for i, v4 in ipairs(list) do
		if i > 1 then
			WriteU8(data, 44) -- equivalent call inferred; original call site unknown
		end

		if pretty then
			WriteU8(data, 10) -- equivalent call inferred; original call site unknown
			WriteIndent(data) -- equivalent call inferred; original call site unknown
		end

		if v4 == data.Null then
			v4 = nil
		end

		data.Encoders[typeof(v4)](data, v4)
	end

	if pretty then
		IncrementIndent(data, -1) -- equivalent call inferred; original call site unknown

		if #list > 0 then
			WriteU8(data, 10) -- equivalent call inferred; original call site unknown
			WriteIndent(data) -- equivalent call inferred; original call site unknown
		end
	end

	WriteU8(data, 93) -- equivalent call inferred; original call site unknown
end

local function EncodeMap(p, items)
	local v4 = {}

	for k, _ in pairs(items) do
		assert(type(k) == "string")
		table.insert(v4, k)
	end

	table.sort(v4)
	local pretty = p.Pretty
	local unquoteIdent = p.UnquoteIdent
	WriteU8(p, 123) -- equivalent call inferred; original call site unknown

	if pretty then
		IncrementIndent(p, 1) -- equivalent call inferred; original call site unknown
	end

	for i, v5 in ipairs(v4) do
		if i > 1 then
			WriteU8(p, 44) -- equivalent call inferred; original call site unknown
		end

		if pretty then
			WriteU8(p, 10) -- equivalent call inferred; original call site unknown
			WriteIndent(p) -- equivalent call inferred; original call site unknown
		end

		EncodeString(p, v5, unquoteIdent)

		if pretty then
			WriteU16(p, 8250) -- equivalent call inferred; original call site unknown
		else
			WriteU8(p, 58) -- equivalent call inferred; original call site unknown
		end

		EncodeAny(p, items[v5]) -- equivalent call inferred; original call site unknown
	end

	if pretty then
		IncrementIndent(p, -1) -- equivalent call inferred; original call site unknown

		if #v4 > 0 then
			WriteU8(p, 10) -- equivalent call inferred; original call site unknown
			WriteIndent(p) -- equivalent call inferred; original call site unknown
		end
	end

	WriteU8(p, 125) -- equivalent call inferred; original call site unknown
end

local function EncodeTable(p, list)
	if #list > 0 or next(list) == nil then
		EncodeArray(p, list)
	else
		EncodeMap(p, list)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function EncodeVector2(p, point: Vector2)
	EncodeArray(p, { point.X, point.Y })
end

-- equivalent calls inferred from this helper; original call sites unknown
local function EncodeVector3(p, vector: Vector3)
	EncodeArray(p, { vector.X, vector.Y, vector.Z })
end

local function EncodeVector2int16(p, p2)
	EncodeVector2(p, p2) -- equivalent call inferred; original call site unknown
end

local function EncodeVector3int16(p, p2)
	EncodeVector3(p, p2) -- equivalent call inferred; original call site unknown
end

local function EncodeRegion3(p, instance)
	local v4 = instance.CFrame * (instance.Size * -0.5)
	local v5 = instance.CFrame * (instance.Size * 0.5)
	EncodeArray(p, {
		v4.X,
		v4.Y,
		v4.Z,
		v5.X,
		v5.Y,
		v5.Z
	})
end

local function EncodeRegion3int16(p, p2)
	EncodeArray(p, {
		p2.Min.X,
		p2.Min.Y,
		p2.Min.Z,
		p2.Max.X,
		p2.Max.Y,
		p2.Max.Z
	})
end

local function EncodeUDim(p, udim: UDim)
	EncodeArray(p, { udim.Scale, udim.Offset })
end

local function EncodeUDim2(p, udim: UDim2)
	EncodeArray(p, {
		udim.X.Scale,
		udim.X.Offset,
		udim.Y.Scale,
		udim.Y.Offset
	})
end

local function EncodeCFrame(p, cframe: CFrame)
	EncodeArray(p, { cframe:GetComponents() })
end

local function EncodeColor3(p, color: Color3)
	EncodeArray(p, { math.round(color.R * 255), math.round(color.G * 255), (math.round(color.B * 255)) })
end

local function EncodeNumberRange(p, range: NumberRange)
	EncodeArray(p, { range.Min, range.Max })
end

local function EncodeRect(p, rect: Rect)
	EncodeArray(p, {
		rect.Min.X,
		rect.Min.Y,
		rect.Max.X,
		rect.Max.Y
	})
end

local function EncodeEnumItem(p, p2)
	EncodeNumber(p, p2.Value)
end

local encoders = {
	["nil"] = EncodeNull,
	boolean = EncodeBoolean,
	number = EncodeNumber,
	string = EncodeString,
	buffer = EncodeBuffer,
	table = EncodeTable
}
local clone = table.clone(encoders)
clone.Vector2 = EncodeVector2
clone.Vector3 = EncodeVector3
clone.Vector2int16 = EncodeVector2int16
clone.Vector3int16 = EncodeVector3int16
clone.Region3 = EncodeRegion3
clone.Region3int16 = EncodeRegion3int16
clone.UDim = EncodeUDim
clone.UDim2 = EncodeUDim2
clone.CFrame = EncodeCFrame
clone.Color3 = EncodeColor3
clone.NumberRange = EncodeNumberRange
clone.Rect = EncodeRect
clone.EnumItem = EncodeEnumItem
local buf = buffer.create(4096)
local stream = Stream(buf)
stream.Encoders = encoders
local stream2 = Stream(buf)
stream2.Encoders = encoders
stream2.Pretty = true
local stream3 = Stream(buf)
stream3.Encoders = clone
local stream4 = Stream(buf)
stream4.Encoders = clone
stream4.Pretty = true
local stream5 = Stream(buf)
stream5.Encoders = encoders
stream5.UnquoteIdent = true
stream5.QuoteChar = 39
local stream6 = Stream(buf)
stream6.Encoders = encoders
stream6.Pretty = true
stream6.UnquoteIdent = true
stream6.QuoteChar = 39
return table.freeze({
	Compact = function(p, null)
		local stream7 = stream
		stream7.Pos = 0
		stream7.Null = null

		if p == stream7.Null then
			p = nil
		end

		stream7.Encoders[typeof(p)](stream7, p)
		return ToString(stream7)
	end,
	Pretty = function(p, null)
		local stream7 = stream2
		stream7.Pos = 0
		stream7.Indent = 0
		stream7.Null = null

		if p == stream7.Null then
			p = nil
		end

		stream7.Encoders[typeof(p)](stream7, p)
		return ToString(stream7)
	end,
	CompactExt = function(p, null)
		local stream7 = stream3
		stream7.Pos = 0
		stream7.Null = null

		if p == stream7.Null then
			p = nil
		end

		stream7.Encoders[typeof(p)](stream7, p)
		return ToString(stream7)
	end,
	PrettyExt = function(p, null)
		local stream7 = stream4
		stream7.Pos = 0
		stream7.Indent = 0
		stream7.Null = null

		if p == stream7.Null then
			p = nil
		end

		stream7.Encoders[typeof(p)](stream7, p)
		return ToString(stream7)
	end,
	Compact5 = function(p, null)
		local stream7 = stream5
		stream7.Pos = 0
		stream7.Null = null

		if p == stream7.Null then
			p = nil
		end

		stream7.Encoders[typeof(p)](stream7, p)
		return ToString(stream7)
	end,
	Pretty5 = function(p, null)
		local stream7 = stream6
		stream7.Pos = 0
		stream7.Indent = 0
		stream7.Null = null

		if p == stream7.Null then
			p = nil
		end

		stream7.Encoders[typeof(p)](stream7, p)
		return ToString(stream7)
	end
})