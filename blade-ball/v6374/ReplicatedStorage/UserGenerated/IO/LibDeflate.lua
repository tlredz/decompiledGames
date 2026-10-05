local byte = string.byte
local char = string.char
local find = string.find
local gsub = string.gsub
local sub = string.sub
local concat = table.concat
local sort = table.sort
local v = {}
local v2 = {}
local v3 = {}
local v4 = {}
local v5 = {}
local v6 = {}
local v7 = {}
local v8 = {}
local v9 = {}
local class = {}
local v10 = {
	16,
	17,
	18,
	0,
	8,
	7,
	9,
	6,
	10,
	5,
	11,
	4,
	12,
	3,
	13,
	2,
	14,
	1,
	15
}
local v11 = {
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	1,
	1,
	1,
	1,
	2,
	2,
	2,
	2,
	3,
	3,
	3,
	3,
	4,
	4,
	4,
	4,
	5,
	5,
	5,
	5,
	0
}
local v12 = {}
local v13 = {}
local v14 = {}
local v15 = {
	3,
	4,
	5,
	6,
	7,
	8,
	9,
	10,
	11,
	13,
	15,
	17,
	19,
	23,
	27,
	31,
	35,
	43,
	51,
	59,
	67,
	83,
	99,
	115,
	131,
	163,
	195,
	227,
	258
}
local v16 = {
	[0] = 1,
	2,
	3,
	4,
	5,
	7,
	9,
	13,
	17,
	25,
	33,
	49,
	65,
	97,
	129,
	193,
	257,
	385,
	513,
	769,
	1025,
	1537,
	2049,
	3073,
	4097,
	6145,
	8193,
	12289,
	16385,
	24577
}
local v17 = {
	[0] = 0,
	0,
	0,
	0,
	1,
	1,
	2,
	2,
	3,
	3,
	4,
	4,
	5,
	5,
	6,
	6,
	7,
	7,
	8,
	8,
	9,
	9,
	10,
	10,
	11,
	11,
	12,
	12,
	13,
	13
}
local v18 = {}
local v19 = {}
local v20 = {}
local v21 = {}

for i = 0, 255 do
	v[i] = char(i)
end

local v22 = 1

for i = 0, 32 do
	v2[i] = v22
	v22 *= 2
end

for i = 1, 9 do
	v3[i] = {}

	for i2 = 0, v2[i + 1] - 1 do
		local v23 = i2
		local v24 = 0

		for _ = 1, i do
			local v25 = v24 - v24 % 2 + ((v24 % 2 == 1 or v23 % 2 == 1) and 1 or 0)
			v23 = (v23 - v23 % 2) / 2
			v24 = v25 * 2
		end

		v3[i][i2] = (v24 - v24 % 2) / 2
	end
end

local total = 18
local v23 = 16
local total2 = 265
local v24 = 1

for i = 3, 258 do
	if i <= 10 then
		v4[i] = i + 254
		v5[i] = 0
	elseif i == 258 then
		v4[258] = 285
		v5[258] = 0
	else
		if total < i then
			total += v23
			v23 *= 2
			total2 += 4
			v24 += 1
		end

		local v25 = i - total - 1 + v23 / 2
		v4[i] = (v25 - v25 % (v23 / 8)) / (v23 / 8) + total2
		v5[i] = v24
		v6[i] = v25 % (v23 / 8)
	end
end

v7[1] = 0
v7[2] = 1
v8[1] = 0
v8[2] = 0
local v25 = 4
local v26 = 3
local total3 = 2
local count = 0

for i = 3, 256 do
	if v25 < i then
		v26 *= 2
		v25 *= 2
		total3 += 2
		count += 1
	end

	v7[i] = i <= v26 and total3 or total3 + 1
	v8[i] = count < 0 and 0 or count

	if v25 >= 8 then
		v9[i] = (i - v25 / 2 - 1) % (v25 / 4)
	end
end

function class:Adler32(value: string)
	if type(value) ~= "string" then
		error(("Usage: LibDeflate:Adler32(str): 'str' - string expected got '%s'."):format((type(value))), 2)
	end

	local count2 = #value
	local total4 = 1
	local v27 = 1
	local v28 = 0

	while total4 <= count2 - 15 do
		local v30, v31, v32, v33, v34, v35, v36, v37, v38, v39, v40, v41, v42, v43, v44, v45 = byte(
			value,
			total4,
			total4 + 15
		)
		v28 = (v28 + v27 * 16 + v30 * 16 + 15 * v31 + 14 * v32 + 13 * v33 + 12 * v34 + 11 * v35 + 10 * v36 + 9 * v37 + 8 * v38 + 7 * v39 + 6 * v40 + 5 * v41 + 4 * v42 + 3 * v43 + 2 * v44 + v45) % 65521
		v27 = (v27 + v30 + v31 + v32 + v33 + v34 + v35 + v36 + v37 + v38 + v39 + v40 + v41 + v42 + v43 + v44 + v45) % 65521
		total4 += 16
	end

	while total4 <= count2 do
		v27 = (v27 + byte(value, total4, total4)) % 65521
		v28 = (v28 + v27) % 65521
		total4 += 1
	end

	return (v28 * 65536 + v27) % 4294967296
end

local function IsEqualAdler32(p: number, p2: number)
	return p % 4294967296 == p2 % 4294967296
end

function class:CreateDictionary(value: string, value2: number, value3: number)
	if type(value) ~= "string" then
		error(
			("Usage: LibDeflate:CreateDictionary(str, strlen, adler32): 'str' - string expected got '%s'."):format((type(value))),
			2
		)
	end

	if type(value2) ~= "number" then
		error(
			("Usage: LibDeflate:CreateDictionary(str, strlen, adler32): 'strlen' - number expected got '%s'."):format((type(value2))),
			2
		)
	end

	if type(value3) ~= "number" then
		error(
			("Usage: LibDeflate:CreateDictionary(str, strlen, adler32): 'adler32' - number expected got '%s'."):format((type(value3))),
			2
		)
	end

	if value2 ~= #value then
		error(("Usage: LibDeflate:CreateDictionary(str, strlen, adler32): 'strlen' does not match the actual length of 'str'. 'strlen': %u, '#str': %u . Please check if 'str' is modified unintentionally."):format(
			value2,
			#value
		))
	end

	if value2 == 0 then
		error("Usage: LibDeflate:CreateDictionary(str, strlen, adler32): 'str' - Empty string is not allowed.", 2)
	end

	if value2 > 32768 then
		error(
			("Usage: LibDeflate:CreateDictionary(str, strlen, adler32): 'str' - string longer than 32768 bytes is not allowed. Got %d bytes."):format(value2),
			2
		)
	end

	local adler32 = self:Adler32(value)

	if value3 % 4294967296 ~= adler32 % 4294967296 then
		error(("Usage: LibDeflate:CreateDictionary(str, strlen, adler32): 'adler32' does not match the actual adler32 of 'str'. 'adler32': %u, 'Adler32(str)': %u . Please check if 'str' is modified unintentionally."):format(
			value3,
			adler32
		))
	end

	local v27 = {
		adler32 = value3,
		hash_tables = {},
		string_table = {},
		strlen = value2
	}
	local string_table = v27.string_table
	local hash_tables = v27.hash_tables
	string_table[1] = byte(value, 1, 1)
	string_table[2] = byte(value, 2, 2)

	if not (value2 >= 3) then
		return v27
	end

	local v28 = string_table[1] * 256 + string_table[2]
	local v29 = 1

	while v29 <= value2 - 2 - 3 do
		local v32, v33, v34, v35 = byte(value, v29 + 2, v29 + 5)
		string_table[v29 + 2] = v32
		string_table[v29 + 3] = v33
		string_table[v29 + 4] = v34
		string_table[v29 + 5] = v35
		local v36 = (v28 * 256 + v32) % 16777216
		local hash_table = hash_tables[v36]

		if not hash_table then
			hash_table = {}
			hash_tables[v36] = hash_table
		end

		hash_table[#hash_table + 1] = v29 - value2
		local v37 = v29 + 1
		local v38 = (v36 * 256 + v33) % 16777216
		local hash_table2 = hash_tables[v38]

		if not hash_table2 then
			hash_table2 = {}
			hash_tables[v38] = hash_table2
		end

		hash_table2[#hash_table2 + 1] = v37 - value2
		local v39 = v37 + 1
		local v40 = (v38 * 256 + v34) % 16777216
		local hash_table3 = hash_tables[v40]

		if not hash_table3 then
			hash_table3 = {}
			hash_tables[v40] = hash_table3
		end

		hash_table3[#hash_table3 + 1] = v39 - value2
		local v41 = v39 + 1
		v28 = (v40 * 256 + v35) % 16777216
		local hash_table4 = hash_tables[v28]

		if not hash_table4 then
			hash_table4 = {}
			hash_tables[v28] = hash_table4
		end

		hash_table4[#hash_table4 + 1] = v41 - value2
		v29 = v41 + 1
	end

	while v29 <= value2 - 2 do
		local v31 = byte(value, v29 + 2)
		string_table[v29 + 2] = v31
		v28 = (v28 * 256 + v31) % 16777216
		local hash_table = hash_tables[v28]

		if not hash_table then
			hash_table = {}
			hash_tables[v28] = hash_table
		end

		hash_table[#hash_table + 1] = v29 - value2
		v29 += 1
	end

	return v27
end

local function IsValidDictionary(data)
	if data == nil or type(data) ~= "table" then
		return false, ("'dictionary' - table expected got '%s'."):format((type(data)))
	end

	if type(data.adler32) == "number" and type(data.string_table) == "table" and type(data.strlen) == "number" and not (data.strlen <= 0) and not (data.strlen > 32768) and data.strlen == #data.string_table and type(data.hash_tables) == "table" then
		return true, ""
	end

	return false, ("'%s' - corrupted dictionary."):format((type(data)))
end

local v27 = {
	[0] = {
		false,
		nil,
		0,
		0,
		0
	},
	[1] = {
		false,
		nil,
		4,
		8,
		4
	},
	[2] = {
		false,
		nil,
		5,
		18,
		8
	},
	[3] = {
		false,
		nil,
		6,
		32,
		32
	},
	[4] = {
		true,
		4,
		4,
		16,
		16
	},
	[5] = {
		true,
		8,
		16,
		32,
		32
	},
	[6] = {
		true,
		8,
		16,
		128,
		128
	},
	[7] = {
		true,
		8,
		32,
		128,
		256
	},
	[8] = {
		true,
		32,
		128,
		258,
		1024
	},
	[9] = {
		true,
		32,
		258,
		258,
		4096
	}
}

local function IsValidArguments(value: string, flag: boolean?, p, flag2: boolean?, items)
	if type(value) ~= "string" then
		return false, ("'str' - string expected got '%s'."):format((type(value)))
	end

	if flag then
		local flag3, v28 = IsValidDictionary(p)

		if not flag3 then
			return false, v28
		end
	end

	if not flag2 then
		return true, ""
	end

	local typeName = type(items)

	if typeName ~= "nil" and typeName ~= "table" then
		return false, ("'configs' - nil or table expected got '%s'."):format((type(items)))
	end

	if typeName ~= "table" then
		return true, ""
	end

	assert(items)

	for k, item in pairs(items) do
		if k ~= "level" and k ~= "strategy" then
			return false, ("'configs' - unsupported table key in the configs: '%s'."):format(k)
		end

		if k == "level" and not v27[item] then
			return false, ("'configs' - unsupported 'level': %s."):format((tostring(item)))
		end

		if k == "strategy" and item ~= "fixed" and item ~= "huffman_only" and item ~= "dynamic" then
			return false, ("'configs' - unsupported 'strategy': '%s'."):format((tostring(item)))
		end
	end

	return true, ""
end

local function CreateWriter()
	local count2 = 0
	local v28 = 0
	local v29 = 0
	local total4 = 0
	local v30 = {}
	local joineds = {}

	local function WriteBits(p: number, p2: number)
		v28 += p * v2[v29]
		v29 += p2
		total4 += p2

		if v29 >= 32 then
			count2 += 1
			v30[count2] = v[v28 % 256] .. v[(v28 - v28 % 256) / 256 % 256] .. v[(v28 - v28 % 65536) / 65536 % 256] .. v[(v28 - v28 % 16777216) / 16777216 % 256]
			local v31 = v2[32 - v29 + p2]
			v28 = (p - p % v31) / v31
			v29 -= 32
		end
	end

	local function WriteString(list: string)
		for _ = 1, v29, 8 do
			count2 += 1
			v30[count2] = char(v28 % 256)
			v28 = (v28 - v28 % 256) / 256
		end

		v29 = 0
		count2 += 1
		v30[count2] = list
		total4 += #list * 8
	end

	local function FlushWriter(p: number)
		if p == 3 then
			return total4, nil
		end

		if p == 1 or p == 2 then
			local v31 = (8 - v29 % 8) % 8

			if v29 > 0 then
				v28 = v28 - v2[v29] + v2[v29 + v31]

				for _ = 1, v29, 8 do
					count2 += 1
					v30[count2] = v[v28 % 256]
					v28 = (v28 - v28 % 256) / 256
				end

				v28 = 0
				v29 = 0
			end

			if p == 2 then
				total4 += v31
				return total4, nil
			end
		end

		local joined = concat(v30)
		v30 = {}
		count2 = 0
		joineds[#joineds + 1] = joined

		if p == 0 then
			return total4, nil
		end

		return total4, concat(joineds)
	end

	return WriteBits, WriteString, FlushWriter
end

local function MinHeapPush(p, list, p2: number)
	local v28 = p2 + 1
	p[v28] = list
	local v29 = list[1]
	local v30 = (v28 - v28 % 2) / 2

	while v30 >= 1 and v29 < p[v30][1] do
		local v31 = p[v30]
		p[v30] = list
		p[v28] = v31
		v28 = v30
		v30 = (v30 - v30 % 2) / 2
	end
end

local function MinHeapPop(list, p: number)
	local v28 = list[1]
	local v29 = list[p]
	local v30 = v29[1]
	list[1] = v29
	list[p] = v28
	local v31 = p - 1
	local v32 = 1
	local v33 = v32 * 2
	local v34 = v33 + 1

	while v33 <= v31 do
		local v35 = list[v33]
		local v36

		if v34 <= v31 and list[v34][1] < v35[1] then
			local v37 = list[v34]

			if not (v37[1] < v30) then
				break
			end

			list[v34] = v29
			list[v32] = v37
			v36 = v34 * 2
			v32 = v34
			v34 = v36 + 1
			v33 = v36
		else
			if not (v35[1] < v30) then
				break
			end

			list[v33] = v29
			list[v32] = v35
			v36 = v33 * 2
			v34 = v36 + 1
			v32 = v33
			v33 = v36
		end
	end

	return v28
end

local function GetHuffmanCodeFromBitlen(p, list, p2: number, p3: number)
	local v28 = 0
	local v29 = {}
	local result = {}

	for i = 1, p3 do
		v28 = (v28 + (p[i - 1] or 0)) * 2
		v29[i] = v28
	end

	for i = 0, p2 do
		local v30 = list[i]

		if not v30 then
			continue
		end

		local v31 = v29[v30]
		v29[v30] = v31 + 1

		if v30 <= 9 then
			result[i] = v3[v30][v31]
		else
			local v32 = 0

			for _ = 1, v30 do
				local v33 = v32 - v32 % 2 + ((v32 % 2 == 1 or v31 % 2 == 1) and 1 or 0)
				v31 = (v31 - v31 % 2) / 2
				v32 = v33 * 2
			end

			result[i] = (v32 - v32 % 2) / 2
		end
	end

	return result
end

local function SortByFirstThenSecond(list, list2)
	if list[1] < list2[1] then
		return true
	elseif list[1] == list2[1] then
		return list[2] < list2[2]
	else
		return false
	end
end

local function GetHuffmanBitlenAndCode(items, p: number, p2: number)
	local v28 = 0
	local v29 = {}
	local v30 = {}
	local result = {}
	local v31 = -1
	local v32 = {}
	local v33 = {}

	for k, item in pairs(items) do
		v28 += 1
		v29[v28] = { item, k }
	end

	if v28 == 0 then
		return {}, {}, -1
	end

	if v28 == 1 then
		local v34 = v29[1][2]
		result[v34] = 1
		v33[v34] = 0
		return result, v33, v34
	else
		sort(v29, SortByFirstThenSecond)

		for i = 1, v28 do
			v30[i] = v29[i]
		end

		while v28 > 1 do
			local minHeapPop = MinHeapPop(v30, v28)
			local v35 = v28 - 1
			local minHeapPop2 = MinHeapPop(v30, v35)
			local v37 = v35 - 1
			MinHeapPush(v30, {
				minHeapPop[1] + minHeapPop2[1],
				-1,
				minHeapPop,
				minHeapPop2
			}, v37)
			v28 = v37 + 1
		end

		local v34 = {
			v30[1],
			{},
			{},
			{}
		}
		v30[1][1] = 0
		local v35 = 1
		local v36 = 1
		local v37 = 0

		while v35 <= v36 do
			local v38 = v34[v35]
			local v39 = v38[1]
			local v40 = v38[2]
			local v41 = v38[3]
			local v42 = v38[4]

			if v41 then
				v36 += 1
				v34[v36] = v41
				v41[1] = v39 + 1
			end

			if v42 then
				v36 += 1
				v34[v36] = v42
				v42[1] = v39 + 1
			end

			v35 += 1

			if p < v39 then
				v37 += 1
				v39 = p
			end

			if not (v40 >= 0) then
				continue
			end

			result[v40] = v39

			if v31 < v40 then
				v31 = v40 or v31
			end

			v32[v39] = (v32[v39] or 0) + 1
		end

		if not (v37 > 0) then
			return result, GetHuffmanCodeFromBitlen(v32, result, p2, p), v31
		end

		while true do
			local v38 = p - 1

			while (v32[v38] or 0) == 0 do
				v38 -= 1
			end

			v32[v38] -= 1
			v32[v38 + 1] = (v32[v38 + 1] or 0) + 2
			v32[p] -= 1
			v37 -= 2

			if not (v37 <= 0) then
				continue
			end

			local v39 = 1

			for i = p, 1, -1 do
				local v40 = v32[i] or 0

				while v40 > 0 do
					result[v29[v39][2]] = i
					v40 -= 1
					v39 += 1
				end
			end

			break
		end

		return result, GetHuffmanCodeFromBitlen(v32, result, p2, p), v31
	end
end

local function RunLengthEncodeHuffmanBitlen(list, p: number, p2, p3: number)
	local v28 = p + (p3 < 0 and 0 or p3) + 1
	local v29 = nil
	local v30 = 0
	local v31 = 0
	local result = {}
	local count2 = 0
	local result2 = {}
	local result3 = {}

	for i = 0, v28 + 1 do
		local v32

		if i <= p then
			v32 = list[i] or 0
		elseif i <= v28 then
			v32 = p2[i - p - 1] or 0
		end

		if v32 == v29 then
			v30 += 1

			if v32 == 0 or v30 ~= 6 then
				if v32 == 0 and v30 == 138 then
					v31 += 1
					result[v31] = 18
					count2 += 1
					result2[count2] = 127
					result3[18] = (result3[18] or 0) + 1
					v30 = 0
				end
			else
				v31 += 1
				result[v31] = 16
				count2 += 1
				result2[count2] = 3
				result3[16] = (result3[16] or 0) + 1
				v30 = 0
			end
		else
			if v30 == 1 then
				assert(v29)
				v31 += 1
				result[v31] = v29
				result3[v29] = (result3[v29] or 0) + 1
			elseif v30 == 2 then
				assert(v29)
				local v33 = v31 + 1
				result[v33] = v29
				v31 = v33 + 1
				result[v31] = v29
				result3[v29] = (result3[v29] or 0) + 2
			elseif v30 >= 3 then
				v31 += 1
				local v33 = v29 ~= 0 and 16 or v30 <= 10 and 17 or 18
				result[v31] = v33
				result3[v33] = (result3[v33] or 0) + 1
				count2 += 1
				result2[count2] = v30 <= 10 and v30 - 3 or v30 - 11
			end

			if v32 and v32 ~= 0 then
				v31 += 1
				result[v31] = v32
				result3[v32] = (result3[v32] or 0) + 1
				v29 = v32
				v30 = 0
			else
				v29 = v32
				v30 = 1
			end
		end
	end

	return result, result2, result3
end

local function LoadStringToTable(list: string, p, p2: number, p3: number, p4: number)
	local v28 = p2 - p4

	while v28 <= p3 - 15 - p4 do
		local v29 = v28 + 1
		local v30 = v28 + 2
		local v31 = v28 + 3
		local v32 = v28 + 4
		local v33 = v28 + 5
		local v34 = v28 + 6
		local v35 = v28 + 7
		local v36 = v28 + 8
		local v37 = v28 + 9
		local v38 = v28 + 10
		local v39 = v28 + 11
		local v40 = v28 + 12
		local v41 = v28 + 13
		local v42 = v28 + 14
		local v43 = v28 + 15
		local v46, v47, v48, v49, v50, v51, v52, v53, v54, v55, v56, v57, v58, v59, v60, v61 = byte(
			list,
			v28 + p4,
			v28 + 15 + p4
		)
		p[v28] = v46
		p[v29] = v47
		p[v30] = v48
		p[v31] = v49
		p[v32] = v50
		p[v33] = v51
		p[v34] = v52
		p[v35] = v53
		p[v36] = v54
		p[v37] = v55
		p[v38] = v56
		p[v39] = v57
		p[v40] = v58
		p[v41] = v59
		p[v42] = v60
		p[v43] = v61
		v28 += 16
	end

	while v28 <= p3 - p4 do
		p[v28] = byte(list, v28 + p4, v28 + p4)
		v28 += 1
	end

	return p
end

local function GetBlockLZ77Result(level: number, list, p, p2: number, p3: number, p4: number, data)
	local v28 = v27[level]
	local flag = v28[1]
	local v29 = v28[2]
	local v30 = v28[3]
	local v31 = v28[4]
	local v32 = v28[5]
	local v33 = (flag or not v30) and 2147483646 or v30
	local v34 = v32 - v32 % 4 / 4
	local hash_tables, string_table, strlen

	if data then
		hash_tables = data.hash_tables
		string_table = data.string_table
		strlen = data.strlen
		assert(p2 == 1)

		if p2 <= p3 and strlen >= 2 then
			local v35 = string_table[strlen - 1] * 65536 + string_table[strlen] * 256 + list[1]
			local v36 = p[v35]

			if not v36 then
				v36 = {}
				p[v35] = v36
			end

			v36[#v36 + 1] = -1
		end

		if p2 + 1 <= p3 and strlen >= 1 then
			local v35 = string_table[strlen] * 65536 + list[1] * 256 + list[2]
			local v36 = p[v35]

			if not v36 then
				v36 = {}
				p[v35] = v36
			end

			v36[#v36 + 1] = 0
		end
	else
		strlen = 0
		hash_tables = {}
		string_table = {}
	end

	local v35 = strlen + 3
	local v36 = (list[p2 - p4] or 0) * 256 + (list[p2 + 1 - p4] or 0)
	local v37 = p3 + (flag and 1 or 0)
	local v38 = 0
	local v39 = 0
	local v40 = false
	local count2 = 0
	local result = {}
	local result2 = {}
	local count3 = 0
	local result3 = {}
	local result4 = {}
	local count4 = 0
	local result5 = {}
	local count5 = 0
	local result6 = {}

	while p2 <= v37 do
		local v41 = p2 - p4
		local v42 = p4 - 3
		local v43 = 0
		v36 = (v36 * 256 + (list[v41 + 2] or 0)) % 16777216
		local v44 = nil
		local v45 = p[v36]
		local v46, v47

		if v45 then
			v46 = #v45
			v44 = v45
			v47 = v46
		else
			v46 = 0
			v45 = {}
			p[v36] = v45

			if hash_tables then
				v44 = hash_tables[v36]
				v47 = not v44 and 0 or #v44 or 0
			else
				v47 = 0
			end
		end

		if p2 <= p3 then
			v45[v46 + 1] = p2
		end

		local v48, v49

		if v47 > 0 and p2 + 2 <= p3 and (not flag or v38 < v30) then
			local v50

			if flag and v29 <= v38 and v34 then
				v50 = v34
			else
				v50 = v32
			end

			local v51 = p3 - p2
			local v52 = (v51 >= 257 and 257 or v51) + v41
			local v53 = v41 + 3
			v48 = v39
			v49 = v38

			while true do
				if not (v47 >= 1 and v50 > 0) then
					v38 = v43
					break
				end

				local v54 = v44[v47]

				if p2 - v54 > 32768 then
					v38 = v43
					break
				end

				if v54 < p2 then
					local v55

					if v54 >= -257 then
						local v56 = v54 - v42
						v55 = v53

						while v55 <= v52 and list[v56] == list[v55] do
							v55 += 1
							v56 += 1
						end
					else
						local v56 = v35 + v54
						v55 = v53

						while v55 <= v52 and string_table[v56] == list[v55] do
							v55 += 1
							v56 += 1
						end
					end

					v38 = v55 - v41

					if v43 < v38 then
						v39 = p2 - v54
					else
						v38 = v43
					end

					if v31 <= v38 then
						break
					end
				else
					v38 = v43
				end

				v47 -= 1
				v50 -= 1

				if v47 == 0 and v54 > 0 and hash_tables then
					v44 = hash_tables[v36]
					v47 = not v44 and 0 or #v44 or 0
				end

				v43 = v38
			end
		else
			v48 = v39
			v49 = v38
			v38 = v43
		end

		if not flag then
			v48 = v39
			v49 = v38
		end

		if flag and not v40 or not (v49 > 3) and (v49 ~= 3 or not (v48 < 4096)) or not (v38 <= v49) then
			if flag and not v40 then
				p2 += 1
				v40 = true
			else
				if flag then
					v41 = v41 - 1 or v41
				end

				local v50 = list[v41]
				count2 += 1
				result[count2] = v50
				result2[v50] = (result2[v50] or 0) + 1
				p2 += 1
			end
		else
			local v50 = v4[v49]
			local v51 = v5[v49]
			local v52, v53, v54

			if v48 <= 256 then
				v52 = v7[v48]
				v53 = v9[v48]
				v54 = v8[v48]
			else
				local v55 = 384
				local v56 = 512
				v52 = 16
				v54 = 7

				while true do
					if v48 <= v55 then
						v53 = (v48 - v56 / 2 - 1) % (v56 / 4)
						break
					end

					if v48 <= v56 then
						v53 = (v48 - v56 / 2 - 1) % (v56 / 4)
						v52 += 1
						break
					else
						v52 += 2
						v54 += 1
						v55 *= 2
						v56 *= 2
					end
				end
			end

			count2 += 1
			result[count2] = v50
			result2[v50] = (result2[v50] or 0) + 1
			count3 += 1
			result3[count3] = v52
			result4[v52] = (result4[v52] or 0) + 1

			if v51 > 0 then
				local v55 = v6[v49]
				count4 += 1
				result5[count4] = v55
			end

			if v54 > 0 then
				count5 += 1
				result6[count5] = v53
			end

			for i = p2 + 1, p2 + v49 - (flag and 2 or 1) do
				v36 = (v36 * 256 + (list[i - p4 + 2] or 0)) % 16777216

				if not (v49 <= v33) then
					continue
				end

				local v55 = p[v36]

				if not v55 then
					v55 = {}
					p[v36] = v55
				end

				v55[#v55 + 1] = i
			end

			p2 = p2 + v49 - (flag and 1 or 0)
			v40 = false
		end
	end

	result[count2 + 1] = 256
	result2[256] = (result2[256] or 0) + 1
	return result, result5, result2, result3, result6, result4
end

local function GetBlockDynamicHuffmanHeader(p, p2)
	local v28, v29, v30 = GetHuffmanBitlenAndCode(p, 15, 285)
	local v31, v32, v33 = GetHuffmanBitlenAndCode(p2, 15, 29)
	local v34, v35, v36 = RunLengthEncodeHuffmanBitlen(v28, v30, v31, v33)
	local v37, v38 = GetHuffmanBitlenAndCode(v36, 7, 18)
	local v39 = 0

	for i = 1, 19 do
		if (v37[v10[i]] or 0) ~= 0 then
			v39 = i
		end
	end

	local v40 = v39 - 4
	local v41 = v30 + 1 - 257
	local v42 = v33 + 1 - 1
	return v41, v42 < 0 and 0 or v42, v40, v37, v38, v34, v35, v28, v29, v31, v32
end

local function GetDynamicHuffmanBlockSize(list, p, p2: number, p3, list2, p4, p5)
	local v28 = 17 + (p2 + 4) * 3

	for i = 1, #list2 do
		local v29 = list2[i]
		v28 += p3[v29]

		if v29 >= 16 then
			v28 += v29 == 16 and 2 or v29 == 17 and 3 or 7
		end
	end

	local count2 = 0

	for i = 1, #list do
		local v29 = list[i]
		v28 += p4[v29]

		if not (v29 > 256) then
			continue
		end

		count2 += 1

		if v29 > 264 and v29 < 285 then
			v28 += v11[v29 - 256]
		end

		local v30 = p[count2]
		v28 += p5[v30]

		if v30 > 3 then
			v28 += (v30 - v30 % 2) / 2 - 1
		end
	end

	return v28
end

local function CompressDynamicHuffmanBlock(callback, flag, list, p, p2, p3, p4, p5, p6, p7, p8, list2, p9, p10, p11, p12, p13)
	callback(flag and 1 or 0, 1)
	callback(2, 2)
	callback(p4, 5)
	callback(p5, 5)
	callback(p6, 4)

	for i = 1, p6 + 4 do
		callback(p7[v10[i]] or 0, 3)
	end

	local v28 = 1

	for i = 1, #list2 do
		local v29 = list2[i]
		callback(p8[v29], p7[v29])

		if not (v29 >= 16) then
			continue
		end

		callback(p9[v28], v29 == 16 and 2 or v29 == 17 and 3 or 7)
		v28 += 1
	end

	local count2 = 0
	local count3 = 0
	local count4 = 0

	for i = 1, #list do
		local v29 = list[i]
		callback(p11[v29], p10[v29])

		if not (v29 > 256) then
			continue
		end

		count2 += 1

		if v29 > 264 and v29 < 285 then
			count3 += 1
			callback(p[count3], v11[v29 - 256])
		end

		local v30 = p2[count2]
		callback(p13[v30], p12[v30])

		if not (v30 > 3) then
			continue
		end

		count4 += 1
		callback(p3[count4], (v30 - v30 % 2) / 2 - 1)
	end
end

local function GetFixedHuffmanBlockSize(list, p)
	local total4 = 3
	local count2 = 0

	for i = 1, #list do
		local v28 = list[i]
		total4 += v12[v28]

		if not (v28 > 256) then
			continue
		end

		count2 += 1

		if v28 > 264 and v28 < 285 then
			total4 += v11[v28 - 256]
		end

		local v29 = p[count2]
		total4 += 5

		if v29 > 3 then
			total4 += (v29 - v29 % 2) / 2 - 1
		end
	end

	return total4
end

local function CompressFixedHuffmanBlock(callback, flag: boolean, list, p, p2, p3)
	callback(flag and 1 or 0, 1)
	callback(1, 2)
	local count2 = 0
	local count3 = 0
	local count4 = 0

	for i = 1, #list do
		local v28 = list[i]
		callback(v13[v28], v12[v28])

		if not (v28 > 256) then
			continue
		end

		count2 += 1

		if v28 > 264 and v28 < 285 then
			count3 += 1
			callback(p[count3], v11[v28 - 256])
		end

		local v29 = p2[count2]
		callback(v14[v29], 5)

		if not (v29 > 3) then
			continue
		end

		count4 += 1
		callback(p3[count4], (v29 - v29 % 2) / 2 - 1)
	end
end

local function GetStoreBlockSize(p: number, p2: number, p3: number)
	assert(p2 - p + 1 <= 65535)
	return 3 + (8 - (p3 + 3) % 8) % 8 + 32 + (p2 - p + 1) * 8
end

local function CompressStoreBlock(callback, callback2, flag: boolean, value: string, p: number, p2: number, p3: number)
	assert(p2 - p + 1 <= 65535)
	callback(flag and 1 or 0, 1)
	callback(0, 2)
	local v28 = (8 - (p3 + 3) % 8) % 8

	if v28 > 0 then
		callback(v2[v28] - 1, v28)
	end

	local v29 = p2 - p + 1
	callback(v29, 16)
	callback(255 - v29 % 256 + (255 - (v29 - v29 % 256) / 256) * 256, 16)
	callback2(value:sub(p, p2))
end

local function Deflate(p, callback, callback2, callback3, list: string, p2)
	local v28 = {}
	local v29 = {}
	local flag = nil
	local v30 = 0
	local v31 = 0
	local v32, _ = callback3(3)
	local count2 = #list
	local level = nil
	local strategy = nil

	if p then
		if p.level then
			level = p.level
		end

		if p.strategy then
			strategy = p.strategy
		end
	end

	if not level then
		if count2 < 2048 then
			level = 7
		elseif count2 > 65536 then
			level = 3
		else
			level = 5
		end
	end

	while not flag do
		local v33

		if v30 == 0 then
			v31 = 65535
			v30 = 1
			v33 = 0
		else
			v30 = v31 + 1
			v31 += 32768
			v33 = v30 - 32768 - 1
		end

		if count2 <= v31 then
			v31 = count2
			flag = true
		else
			flag = false
		end

		local v34, v35, v36, v37, v38, v39, v40, v41, v42, v43, v44, v45, v46, v47, v48, v49, v50

		if level == 0 then
			v36 = {}
			v37 = {}
			v38 = {}
			v39 = {}
			v43 = {}
			v44 = {}
			v45 = {}
			v46 = {}
			v47 = {}
			v48 = {}
			v49 = {}
			v50 = {}
		else
			LoadStringToTable(list, v28, v30, v31 + 3, v33)

			if v30 == 1 and p2 then
				local string_table = p2.string_table
				local strlen = p2.strlen

				for i = 0, -strlen + 1 < -257 and -257 or -strlen + 1, -1 do
					v28[i] = string_table[strlen + i]
				end
			end

			local v51, v52

			if strategy == "huffman_only" then
				v36 = {}
				LoadStringToTable(list, v36, v30, v31, v30 - 1)
				v36[v31 - v30 + 2] = 256
				v51 = {}
				v37 = {}

				for i = 1, v31 - v30 + 2 do
					local v53 = v36[i]
					v51[v53] = (v51[v53] or 0) + 1
				end

				v52 = {}
				v38 = {}
				v39 = {}
			else
				v36, v37, v51, v38, v39, v52 = GetBlockLZ77Result(level, v28, v29, v30, v31, v33, p2)
			end

			v40, v41, v42, v43, v44, v45, v46, v47, v48, v49, v50 = GetBlockDynamicHuffmanHeader(v51, v52)
			v35 = GetDynamicHuffmanBlockSize(v36, v38, v42, v43, v45, v47, v49)
			v34 = GetFixedHuffmanBlockSize(v36, v38)
		end

		assert(v31 - v30 + 1 <= 65535)
		local v51 = 3 + (8 - (v32 + 3) % 8) % 8 + 32 + (v31 - v30 + 1) * 8
		local v52

		if v34 and v34 < v51 and v34 then
			v52 = v34
		else
			v52 = v51
		end

		if v35 and v35 < v52 and v35 then
			v52 = v35
		end

		if level == 0 or strategy ~= "fixed" and strategy ~= "dynamic" and v51 == v52 then
			CompressStoreBlock(callback, callback2, flag, list, v30, v31, v32)
			v32 += v51
		elseif strategy == "dynamic" or strategy ~= "fixed" and v34 ~= v52 then
			if strategy == "dynamic" or v35 == v52 then
				CompressDynamicHuffmanBlock(
					callback,
					flag,
					v36,
					v37,
					v38,
					v39,
					v40,
					v41,
					v42,
					v43,
					v44,
					v45,
					v46,
					v47,
					v48,
					v49,
					v50
				)
				v32 += assert(v35)
			end
		else
			CompressFixedHuffmanBlock(callback, flag, v36, v37, v38, v39)
			v32 += assert(v34)
		end

		local v53

		if flag then
			v53 = callback3(3)
		else
			v53 = callback3(0)
		end

		assert(v53 == v32)

		if flag then
			continue
		end

		if p2 and v30 == 1 then
			local v54 = 0

			while v28[v54] do
				v28[v54] = nil
				v54 -= 1
			end
		end

		local v54 = 1
		p2 = nil

		for i = v31 - 32767, v31 do
			v28[v54] = v28[i - v33]
			v54 += 1
		end

		for k, v55 in pairs(v29) do
			local count3 = #v55

			if not (count3 > 0 and v31 + 1 - v55[1] > 32768) then
				continue
			end

			if count3 == 1 then
				v29[k] = nil
			else
				local count4 = 0
				local v56 = {}

				for i = 2, count3 do
					local v57 = v55[i]

					if not (v31 + 1 - v57 <= 32768) then
						continue
					end

					count4 += 1
					v56[count4] = v57
				end

				v29[k] = v56
			end
		end
	end
end

local function CompressDeflateInternal(p: string, p2, p3)
	local callback, WriteString, FlushWriter = CreateWriter()
	Deflate(p3, callback, WriteString, FlushWriter, p, p2)
	local v30, v31 = FlushWriter(1)
	assert(v31)
	return v31, (8 - v30 % 8) % 8
end

local function CompressZlibInternal(p: string, p2, p3)
	local callback, WriteString, FlushWriter = CreateWriter()
	callback(120, 8)
	local v30 = p2 and 1 or 0
	local v31 = 128 + v30 * 32
	callback(v31 + (31 - (30720 + v31) % 31), 8)

	if v30 == 1 then
		assert(p2)
		local adler32 = p2.adler32
		local v32 = adler32 % 256
		local v33 = (adler32 - v32) / 256
		local v34 = v33 % 256
		local v35 = (v33 - v34) / 256
		local v36 = v35 % 256
		callback((v35 - v36) / 256 % 256, 8)
		callback(v36, 8)
		callback(v34, 8)
		callback(v32, 8)
	end

	Deflate(p3, callback, WriteString, FlushWriter, p, p2)
	FlushWriter(2)
	local adler32 = class:Adler32(p)
	local v32 = adler32 % 256
	local v33 = (adler32 - v32) / 256
	local v34 = v33 % 256
	local v35 = (v33 - v34) / 256
	local v36 = v35 % 256
	callback((v35 - v36) / 256 % 256, 8)
	callback(v36, 8)
	callback(v34, 8)
	callback(v32, 8)
	local v37, v38 = FlushWriter(1)
	assert(v38)
	return v38, (8 - v37 % 8) % 8
end

function class.CompressDeflate(_, p, p2)
	local flag, v28 = IsValidArguments(p, false, nil, true, p2)

	if not flag then
		error("Usage: LibDeflate:CompressDeflate(str, configs): " .. v28, 2)
	end

	return CompressDeflateInternal(p, nil, p2)
end

function class.CompressDeflateWithDict(_, p, p2, p3)
	local flag, v28 = IsValidArguments(p, true, p2, true, p3)

	if not flag then
		error("Usage: LibDeflate:CompressDeflateWithDict" .. "(str, dictionary, configs): " .. v28, 2)
	end

	return CompressDeflateInternal(p, p2, p3)
end

function class.CompressZlib(_, p, p2)
	local flag, v28 = IsValidArguments(p, false, nil, true, p2)

	if not flag then
		error("Usage: LibDeflate:CompressZlib(str, configs): " .. v28, 2)
	end

	return CompressZlibInternal(p, nil, p2)
end

function class.CompressZlibWithDict(_, p, p2, p3)
	local flag, v28 = IsValidArguments(p, true, p2, true, p3)

	if not flag then
		error("Usage: LibDeflate:CompressZlibWithDict" .. "(str, dictionary, configs): " .. v28, 2)
	end

	return CompressZlibInternal(p, p2, p3)
end

local function CreateReader(list: string)
	local count2 = #list
	local total4 = 1
	local v28 = 0
	local v29 = 0

	local function ReadBits(p: number)
		local v30 = v2[p]

		if p <= v28 then
			local v31 = v29 % v30
			v29 = (v29 - v31) / v30
			v28 -= p
			return v31
		else
			local v31 = v2[v28]
			local v35, v36, v37, v38 = byte(list, total4, total4 + 3)
			v29 += ((v35 or 0) + (v36 or 0) * 256 + (v37 or 0) * 65536 + (v38 or 0) * 16777216) * v31
			total4 += 4
			v28 = v28 + 32 - p
			local v39 = v29 % v30
			v29 = (v29 - v39) / v30
			return v39
		end
	end

	local function ReadBytes(p: number, p2, count3: number)
		assert(v28 % 8 == 0)
		local v30

		if v28 / 8 < p then
			v30 = v28 / 8 or p
		else
			v30 = p
		end

		for _ = 1, v30 do
			local v31 = v29 % 256
			count3 += 1
			p2[count3] = char(v31)
			v29 = (v29 - v31) / 256
		end

		v28 -= v30 * 8
		local v31 = p - v30

		if (count2 - total4 - v31 + 1) * 8 + v28 < 0 then
			return -1
		end

		for i = total4, total4 + v31 - 1 do
			count3 += 1
			p2[count3] = sub(list, i, i)
		end

		total4 += v31
		return count3
	end

	local function Decode(list2, p, p2: number)
		local v30, v31, v32

		if p2 > 0 then
			if v28 < 15 and list then
				local v33 = v2[v28]
				local v37, v38, v39, v40 = byte(list, total4, total4 + 3)
				v29 += ((v37 or 0) + (v38 or 0) * 256 + (v39 or 0) * 65536 + (v40 or 0) * 16777216) * v33
				total4 += 4
				v28 += 32
			end

			local v33 = v2[p2]
			v28 -= p2
			local v34 = v29 % v33
			v29 = (v29 - v34) / v33
			local v35 = v3[p2][v34]
			v30 = list2[p2]

			if v35 < v30 then
				return p[v35]
			end

			v31 = v30 * 2
			v32 = v35 * 2
		else
			v32 = 0
			v31 = 0
			v30 = 0
		end

		for i = p2 + 1, 15 do
			local v33 = v29 % 2
			v29 = (v29 - v33) / 2
			v28 -= 1

			if v33 == 1 then
				v32 = v32 + 1 - v32 % 2 or v32
			end

			local v34 = list2[i] or 0
			local v35 = v32 - v31

			if v35 < v34 then
				return p[v30 + v35]
			end

			v30 += v34
			v31 = (v31 + v34) * 2
			v32 *= 2
		end

		return -10
	end

	local function ReaderBitlenLeft()
		return (count2 - total4 + 1) * 8 + v28
	end

	local function SkipToByteBoundary()
		local v30 = v28 % 8
		local v31 = v2[v30]
		v28 -= v30
		v29 = (v29 - v29 % v31) / v31
	end

	return ReadBits, ReadBytes, Decode, ReaderBitlenLeft, SkipToByteBoundary
end

local function CreateDecompressState(p: string, dictionary)
	local callback, readBytes, decode, readerBitlenLeft, skipToByteBoundary = CreateReader(p)
	return {
		ReadBits = callback,
		ReadBytes = readBytes,
		Decode = decode,
		ReaderBitlenLeft = readerBitlenLeft,
		SkipToByteBoundary = skipToByteBoundary,
		buffer_size = 0,
		buffer = {},
		result_buffer = {},
		dictionary = dictionary
	}
end

local function GetHuffmanForDecode(list, p: number, p2: number)
	local v28 = p2
	local result = {}

	for i = 0, p do
		local v29 = list[i] or 0

		if v29 > 0 and v29 < v28 and v29 then
			v28 = v29
		end

		result[v29] = (result[v29] or 0) + 1
	end

	if result[0] == p + 1 then
		return 0, result, {}, 0
	end

	local v29 = 1

	for i = 1, p2 do
		v29 = v29 * 2 - (result[i] or 0)

		if v29 < 0 then
			return v29, {}, {}, 0
		end
	end

	local v30 = { 0 }

	for i = 1, p2 - 1 do
		v30[i + 1] = v30[i] + (result[i] or 0)
	end

	local result2 = {}

	for i = 0, p do
		local v31 = list[i] or 0

		if v31 == 0 then
			continue
		end

		result2[v30[v31]] = i
		v30[v31] += 1
	end

	return v29, result, result2, v28
end

local function DecodeUntilEndOfBlock(state, p, p2, p3: number, p4, p5, p6: number)
	local buffer = state.buffer
	local buffer_size = state.buffer_size
	local readBits = state.ReadBits
	local decode = state.Decode
	local readerBitlenLeft = state.ReaderBitlenLeft
	local result_buffer = state.result_buffer
	local dictionary = state.dictionary
	local string_table, strlen, v28

	if dictionary and not buffer[0] then
		string_table = dictionary.string_table
		strlen = dictionary.strlen
		v28 = -strlen + 1

		for i = 0, -strlen + 1 < -257 and -257 or -strlen + 1, -1 do
			buffer[i] = v[string_table[strlen + i]]
		end
	else
		v28 = 1
		string_table = {}
	end

	while true do
		local decoded = decode(p, p2, p3)

		if decoded < 0 or decoded > 285 then
			break
		end

		if decoded < 256 then
			buffer_size += 1
			buffer[buffer_size] = v[decoded]
		elseif decoded > 256 then
			local v29 = decoded - 256
			local v30 = v15[v29]

			if v29 >= 8 then
				v30 = v30 + readBits(v11[v29]) or v30
			end

			decoded = decode(p4, p5, p6)

			if decoded < 0 or decoded > 29 then
				return -10
			end

			local v31 = v16[decoded]

			if v31 > 4 then
				v31 = v31 + readBits(v17[decoded]) or v31
			end

			local v32 = buffer_size - v31 + 1

			if v32 < v28 then
				return -11
			end

			if v32 >= -257 then
				for _ = 1, v30 do
					buffer_size += 1
					buffer[buffer_size] = buffer[v32]
					v32 += 1
				end
			else
				local v33 = strlen + v32

				for _ = 1, v30 do
					buffer_size += 1
					buffer[buffer_size] = v[string_table[v33]]
					v33 += 1
				end
			end
		end

		if readerBitlenLeft() < 0 then
			return 2
		end

		if buffer_size >= 65536 then
			result_buffer[#result_buffer + 1] = concat(buffer, "", 1, 32768)

			for i = 32769, buffer_size do
				buffer[i - 32768] = buffer[i]
			end

			buffer_size -= 32768
			buffer[buffer_size + 1] = nil
		end

		if decoded ~= 256 then
			continue
		end

		state.buffer_size = buffer_size
		return 0
	end

	return -10
end

local function DecompressStoreBlock(state)
	local buffer = state.buffer
	local buffer_size = state.buffer_size
	local readBits = state.ReadBits
	local readBytes = state.ReadBytes
	local readerBitlenLeft = state.ReaderBitlenLeft
	local skipToByteBoundary = state.SkipToByteBoundary
	local result_buffer = state.result_buffer
	skipToByteBoundary()
	local v28 = readBits(16)

	if readerBitlenLeft() < 0 then
		return 2
	end

	local v29 = readBits(16)

	if readerBitlenLeft() < 0 then
		return 2
	end

	if not (v28 % 256 + v29 % 256 == 255 and (v28 - v28 % 256) / 256 + (v29 - v29 % 256) / 256 == 255) then
		return -2
	end

	local buffer_size2 = readBytes(v28, buffer, buffer_size)

	if buffer_size2 < 0 then
		return 2
	end

	if buffer_size2 >= 65536 then
		result_buffer[#result_buffer + 1] = concat(buffer, "", 1, 32768)

		for i = 32769, buffer_size2 do
			buffer[i - 32768] = buffer[i]
		end

		buffer_size2 -= 32768
		buffer[buffer_size2 + 1] = nil
	end

	state.buffer_size = buffer_size2
	return 0
end

local function DecompressFixBlock(p)
	return (DecodeUntilEndOfBlock(p, v18, v19, 7, v20, v21, 5))
end

local function DecompressDynamicBlock(data)
	local readBits = data.ReadBits
	local decode = data.Decode
	local v28 = readBits(5) + 257
	local v29 = readBits(5) + 1
	local v30 = readBits(4) + 4

	if v28 > 286 or v29 > 30 then
		return -3
	end

	local v31 = {}

	for i = 1, v30 do
		v31[v10[i]] = readBits(3)
	end

	local v32, v33, v34, v35 = GetHuffmanForDecode(v31, 18, 7)

	if v32 ~= 0 then
		return -4
	end

	local count2 = 0
	local v36 = {}
	local v37 = {}

	while count2 < v28 + v29 do
		local decoded = decode(v33, v34, v35)

		if decoded < 0 then
			return decoded
		end

		if decoded < 16 then
			if count2 < v28 then
				v36[count2] = decoded
			else
				v37[count2 - v28] = decoded
			end

			count2 += 1
		else
			local v38 = 0
			local v39

			if decoded == 16 then
				if count2 == 0 then
					return -5
				end

				if count2 - 1 < v28 then
					v38 = v36[count2 - 1]
				else
					v38 = v37[count2 - v28 - 1]
				end

				v39 = 3 + readBits(2)
			elseif decoded == 17 then
				v39 = 3 + readBits(3)
			else
				v39 = 11 + readBits(7)
			end

			local v40 = count2 + v39

			if v28 + v29 < v40 then
				return -6
			end

			while v39 > 0 do
				v39 -= 1

				if count2 < v28 then
					v36[count2] = v38
				else
					v37[count2 - v28] = v38
				end

				count2 += 1
			end
		end
	end

	if (v36[256] or 0) == 0 then
		return -9
	end

	local v38, v39, v40, v41 = GetHuffmanForDecode(v36, v28 - 1, 15)

	if v38 ~= 0 and (v38 < 0 or v28 ~= (v39[0] or 0) + (v39[1] or 0)) then
		return -7
	end

	local v42, v43, v44, v45 = GetHuffmanForDecode(v37, v29 - 1, 15)

	if v42 == 0 or not (v42 < 0) and v29 == (v43[0] or 0) + (v43[1] or 0) then
		return (DecodeUntilEndOfBlock(data, v39, v40, v41, v43, v44, v45))
	end

	return -8
end

local function Inflate(data)
	local readBits = data.ReadBits
	local v28 = nil

	while not v28 do
		v28 = readBits(1) == 1
		local v29 = readBits(2)
		local v30

		if v29 == 0 then
			v30 = DecompressStoreBlock(data)
		elseif v29 == 1 then
			v30 = DecodeUntilEndOfBlock(data, v18, v19, 7, v20, v21, 5)
		elseif v29 == 2 then
			v30 = DecompressDynamicBlock(data)
		else
			return nil, -1
		end

		if v30 ~= 0 then
			return nil, v30
		end
	end

	data.result_buffer[#data.result_buffer + 1] = concat(data.buffer, "", 1, data.buffer_size)
	return concat(data.result_buffer), 0
end

local function DecompressDeflateInternal(value: string, dictionary)
	local decompressState = CreateDecompressState(value, dictionary)
	local v29, v30 = Inflate(decompressState)

	if not v29 then
		return nil, v30
	end

	local readerBitlenLeft = decompressState.ReaderBitlenLeft()
	return v29, (readerBitlenLeft - readerBitlenLeft % 8) / 8
end

local function DecompressZlibInternal(value: string, dictionary)
	local decompressState = CreateDecompressState(value, dictionary)
	local readBits = decompressState.ReadBits
	local v29 = readBits(8)

	if decompressState.ReaderBitlenLeft() < 0 then
		return nil, 2
	end

	local v30 = v29 % 16
	local v31 = (v29 - v30) / 16

	if v30 ~= 8 then
		return nil, -12
	end

	if v31 > 7 then
		return nil, -13
	end

	local v32 = readBits(8)

	if decompressState.ReaderBitlenLeft() < 0 then
		return nil, 2
	end

	if (v29 * 256 + v32) % 31 ~= 0 then
		return nil, -14
	end

	local v33 = (v32 - v32 % 32) / 32 % 2
	local _ = (v32 - v32 % 64) / 64 % 4

	if v33 == 1 then
		if not dictionary then
			return nil, -16
		end

		local v34 = readBits(8)
		local v35 = readBits(8)
		local v36 = readBits(8)
		local v37 = readBits(8)
		local v38 = v34 * 16777216 + v35 * 65536 + v36 * 256 + v37

		if decompressState.ReaderBitlenLeft() < 0 then
			return nil, 2
		end

		local adler32 = dictionary.adler32

		if v38 % 4294967296 ~= adler32 % 4294967296 then
			return nil, -17
		end
	end

	local v34, v35 = Inflate(decompressState)

	if not v34 then
		return nil, v35
	end

	decompressState.SkipToByteBoundary()
	local v36 = readBits(8)
	local v37 = readBits(8)
	local v38 = readBits(8)
	local v39 = readBits(8)

	if decompressState.ReaderBitlenLeft() < 0 then
		return nil, 2
	end

	local v40 = v36 * 16777216 + v37 * 65536 + v38 * 256 + v39
	local adler32 = class:Adler32(v34)

	if v40 % 4294967296 ~= adler32 % 4294967296 then
		return nil, -15
	end

	local readerBitlenLeft = decompressState.ReaderBitlenLeft()
	return v34, (readerBitlenLeft - readerBitlenLeft % 8) / 8
end

function class.DecompressDeflate(_, value: string)
	local v28, v29

	if type(value) == "string" then
		v28 = true
		v29 = ""
	else
		v29 = ("'str' - string expected got '%s'."):format((type(value)))
		v28 = false
	end

	if not v28 then
		error("Usage: LibDeflate:DecompressDeflate(str): " .. v29, 2)
	end

	return DecompressDeflateInternal(value)
end

function class.DecompressDeflateWithDict(_, value: string, dictionary)
	local v28, v29

	if type(value) == "string" then
		local v30
		v30, v28 = IsValidDictionary(dictionary)

		if v30 then
			v29 = true
			v28 = ""
		else
			v29 = false
		end
	else
		v28 = ("'str' - string expected got '%s'."):format((type(value)))
		v29 = false
	end

	if not v29 then
		error("Usage: LibDeflate:DecompressDeflateWithDict(str, dictionary): " .. v28, 2)
	end

	return DecompressDeflateInternal(value, dictionary)
end

function class.DecompressZlib(_, value: string)
	local v28, v29

	if type(value) == "string" then
		v28 = true
		v29 = ""
	else
		v29 = ("'str' - string expected got '%s'."):format((type(value)))
		v28 = false
	end

	if not v28 then
		error("Usage: LibDeflate:DecompressZlib(str): " .. v29, 2)
	end

	return DecompressZlibInternal(value)
end

function class.DecompressZlibWithDict(_, value: string, dictionary)
	local v28, v29

	if type(value) == "string" then
		local v30
		v30, v28 = IsValidDictionary(dictionary)

		if v30 then
			v29 = true
			v28 = ""
		else
			v29 = false
		end
	else
		v28 = ("'str' - string expected got '%s'."):format((type(value)))
		v29 = false
	end

	if not v29 then
		error("Usage: LibDeflate:DecompressZlibWithDict(str, dictionary): " .. v28, 2)
	end

	return DecompressZlibInternal(value, dictionary)
end

v12 = {}

for i = 0, 143 do
	v12[i] = 8
end

for i = 144, 255 do
	v12[i] = 9
end

v12[256] = 7
v12[257] = 7
v12[258] = 7
v12[259] = 7
v12[260] = 7
v12[261] = 7
v12[262] = 7
v12[263] = 7
v12[264] = 7
v12[265] = 7
v12[266] = 7
v12[267] = 7
v12[268] = 7
v12[269] = 7
v12[270] = 7
v12[271] = 7
v12[272] = 7
v12[273] = 7
v12[274] = 7
v12[275] = 7
v12[276] = 7
v12[277] = 7
v12[278] = 7
v12[279] = 7
v12[280] = 8
v12[281] = 8
v12[282] = 8
v12[283] = 8
v12[284] = 8
v12[285] = 8
v12[286] = 8
v12[287] = 8
local v28 = {}

for i = 0, 31 do
	v28[i] = 5
end

local v29, v30, v31 = GetHuffmanForDecode(v12, 287, 9)
v18 = v30
v19 = v31
assert(v29 == 0)
local v32, v33, v34 = GetHuffmanForDecode(v28, 31, 5)
v20 = v33
v21 = v34
assert(v32 == 0)
v13 = GetHuffmanCodeFromBitlen(v18, v12, 287, 9)
v14 = GetHuffmanCodeFromBitlen(v20, v28, 31, 5)
local v35 = {
	["\0"] = "%z",
	["("] = "%(",
	[")"] = "%)",
	["."] = "%.",
	["%"] = "%%",
	["+"] = "%+",
	["-"] = "%-",
	["*"] = "%*",
	["?"] = "%?",
	["["] = "%[",
	["]"] = "%]",
	["^"] = "%^",
	["$"] = "%$"
}

-- equivalent calls inferred from this helper; original call sites unknown
local function escape_for_gsub(value: string)
	local v36, _ = value:gsub("([%z%(%)%.%%%+%-%*%?%[%]%^%$])", v35)
	return v36
end

function class.CreateCodec(_, value: string, value2: string, value3: string)
	if type(value) ~= "string" or type(value2) ~= "string" or type(value3) ~= "string" then
		error(
			"Usage: LibDeflate:CreateCodec(reserved_chars, escape_chars, map_chars): All arguments must be string.",
			2
		)
	end

	if value2 == "" then
		return nil, "No escape characters supplied."
	end

	if #value < #value3 then
		return nil, "The number of reserved characters must be at least as many as the number of mapped chars."
	end

	if value == "" then
		return nil, "No characters to encode."
	end

	local v36 = value .. value2 .. value3
	local v37 = {}

	for i = 1, #v36 do
		local v38 = byte(v36, i, i)

		if v37[v38] then
			return
				nil,
				"There must be no duplicate characters in the concatenation of reserved_chars, escape_chars and map_chars."
		else
			v37[v38] = true
		end
	end

	local v38 = {}
	local v39 = {}
	local v40 = {}
	local v41 = {}

	if #value3 > 0 then
		local v42 = {}
		local v43 = {}

		for i = 1, #value3 do
			local v44 = sub(value, i, i)
			local v45 = sub(value3, i, i)
			v41[v44] = v45
			v40[#v40 + 1] = v44
			v42[v45] = v44
			v43[#v43 + 1] = v45
		end

		local v44 = #v38 + 1
		v38[v44] = "([" .. escape_for_gsub(concat(v43)) .. "])"
		v39[#v39 + 1] = v42
	end

	local v42 = 1
	local v43 = sub(value2, v42, v42)
	local count2 = 0
	local v44 = {}
	local v45 = {}

	for i = 1, #v36 do
		local v46 = sub(v36, i, i)

		if not v41[v46] then
			while count2 >= 256 or v37[count2] do
				count2 += 1

				if not (count2 > 255) then
					continue
				end

				local v47 = #v38 + 1
				local v48 = escape_for_gsub(v43) -- equivalent call inferred; original call site unknown
				v38[v47] = v48 .. "([" .. escape_for_gsub(concat(v44)) .. "])"
				v39[#v39 + 1] = v45
				v42 += 1
				v43 = sub(value2, v42, v42)

				if not v43 or v43 == "" then
					return nil, "Out of escape characters."
				end

				count2 = 0
				v44 = {}
				v45 = {}
			end

			local v47 = v[count2]
			v41[v46] = v43 .. v47
			v40[#v40 + 1] = v46
			v45[v47] = v46
			v44[#v44 + 1] = v47
			count2 += 1
		end

		if i ~= #v36 then
			continue
		end

		local v47 = #v38 + 1
		local v48 = escape_for_gsub(v43) -- equivalent call inferred; original call site unknown
		v38[v47] = v48 .. "([" .. escape_for_gsub(concat(v44)) .. "])"
		v39[#v39 + 1] = v45
	end

	local v47 = "([" .. escape_for_gsub(concat(v40)) .. "])"
	local v46 = {
		Encode = function(_, value4: string)
			if type(value4) ~= "string" then
				error(("Usage: codec:Encode(str): 'str' - string expected got '%s'."):format((type(value4))), 2)
			end

			local v48, _ = gsub(value4, v47, v41)
			return v48
		end
	}
	local count3 = #v38
	local v48 = "([" .. escape_for_gsub(value) .. "])"

	function v46.Decode(_, value4: string)
		if type(value4) ~= "string" then
			error(("Usage: codec:Decode(str): 'str' - string expected got '%s'."):format((type(value4))), 2)
		end

		if find(value4, v48) then
			return nil
		end

		for i = 1, count3 do
			value4 = gsub(value4, v38[i], v39[i])
		end

		return value4
	end

	return v46, ""
end

class.internals = {
	LoadStringToTable = LoadStringToTable,
	IsValidDictionary = IsValidDictionary,
	IsEqualAdler32 = IsEqualAdler32
}
return table.freeze(class)