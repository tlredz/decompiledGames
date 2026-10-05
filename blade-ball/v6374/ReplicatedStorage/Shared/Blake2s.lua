local v = {
	1779033703,
	3144134277,
	1013904242,
	2773480762,
	1359893119,
	2600822924,
	528734635,
	1541459225
}
local v2 = {
	{
		1,
		2,
		3,
		4,
		5,
		6,
		7,
		8,
		9,
		10,
		11,
		12,
		13,
		14,
		15,
		16
	},
	{
		15,
		11,
		5,
		9,
		10,
		16,
		14,
		7,
		2,
		13,
		1,
		3,
		12,
		8,
		6,
		4
	},
	{
		12,
		9,
		13,
		1,
		6,
		3,
		16,
		14,
		11,
		15,
		4,
		7,
		8,
		2,
		10,
		5
	},
	{
		8,
		10,
		4,
		2,
		14,
		13,
		12,
		15,
		3,
		7,
		6,
		11,
		5,
		1,
		16,
		9
	},
	{
		10,
		1,
		6,
		8,
		3,
		5,
		11,
		16,
		15,
		2,
		12,
		13,
		7,
		9,
		4,
		14
	},
	{
		3,
		13,
		7,
		11,
		1,
		12,
		9,
		4,
		5,
		14,
		8,
		6,
		16,
		15,
		2,
		10
	},
	{
		13,
		6,
		2,
		16,
		15,
		14,
		5,
		11,
		1,
		8,
		7,
		4,
		10,
		3,
		9,
		12
	},
	{
		14,
		12,
		8,
		15,
		13,
		2,
		4,
		10,
		6,
		1,
		16,
		5,
		9,
		7,
		3,
		11
	},
	{
		7,
		16,
		15,
		10,
		12,
		4,
		1,
		9,
		13,
		3,
		14,
		8,
		2,
		5,
		11,
		6
	},
	{
		11,
		3,
		9,
		5,
		8,
		7,
		2,
		6,
		16,
		12,
		10,
		15,
		4,
		13,
		14,
		1
	}
}

local function F(clone, p, p2: number, flag: boolean)
	local v3 = clone[1]
	local v4 = clone[2]
	local v5 = clone[3]
	local v6 = clone[4]
	local v7 = clone[5]
	local v8 = clone[6]
	local v9 = clone[7]
	local v10 = clone[8]
	local v11 = v[1]
	local v12 = v[2]
	local v13 = v[3]
	local v14 = v[4]
	local v15 = v[5]
	local v16 = v[6]
	local v17 = v[7]
	local v18 = v[8]
	local v19 = bit32.bxor(v15, p2)
	local v20 = bit32.bxor(v16, p2 // 4294967296)

	if flag then
		v17 = bit32.bnot(v17)
	end

	for _, v21 in v2 do
		local v22 = v3 + (v7 + p[v21[1]])
		local v23 = bit32.rrotate(bit32.bxor(v19, v22), 16)
		local v24 = v11 + v23
		local v25 = bit32.rrotate(bit32.bxor(v7, v24), 12)
		local v26 = v22 + (v25 + p[v21[2]])
		local v27 = bit32.rrotate(bit32.bxor(v23, v26), 8)
		local v28 = v24 + v27
		local v29 = bit32.rrotate(bit32.bxor(v25, v28), 7)
		local v30 = v4 + (v8 + p[v21[3]])
		local v31 = bit32.rrotate(bit32.bxor(v20, v30), 16)
		local v32 = v12 + v31
		local v33 = bit32.rrotate(bit32.bxor(v8, v32), 12)
		local v34 = v30 + (v33 + p[v21[4]])
		local v35 = bit32.rrotate(bit32.bxor(v31, v34), 8)
		local v36 = v32 + v35
		local v37 = bit32.rrotate(bit32.bxor(v33, v36), 7)
		local v38 = v5 + (v9 + p[v21[5]])
		local v39 = bit32.rrotate(bit32.bxor(v17, v38), 16)
		local v40 = v13 + v39
		local v41 = bit32.rrotate(bit32.bxor(v9, v40), 12)
		local v42 = v38 + (v41 + p[v21[6]])
		local v43 = bit32.rrotate(bit32.bxor(v39, v42), 8)
		local v44 = v40 + v43
		local v45 = bit32.rrotate(bit32.bxor(v41, v44), 7)
		local v46 = v6 + (v10 + p[v21[7]])
		local v47 = bit32.rrotate(bit32.bxor(v18, v46), 16)
		local v48 = v14 + v47
		local v49 = bit32.rrotate(bit32.bxor(v10, v48), 12)
		local v50 = v46 + (v49 + p[v21[8]])
		local v51 = bit32.rrotate(bit32.bxor(v47, v50), 8)
		local v52 = v48 + v51
		local v53 = bit32.rrotate(bit32.bxor(v49, v52), 7)
		local v54 = v26 + (v37 + p[v21[9]])
		local v55 = bit32.rrotate(bit32.bxor(v51, v54), 16)
		local v56 = v44 + v55
		local v57 = bit32.rrotate(bit32.bxor(v37, v56), 12)
		v3 = v54 + (v57 + p[v21[10]])
		v18 = bit32.rrotate(bit32.bxor(v55, v3), 8)
		v13 = v56 + v18
		v8 = bit32.rrotate(bit32.bxor(v57, v13), 7)
		local v58 = v34 + (v45 + p[v21[11]])
		local v59 = bit32.rrotate(bit32.bxor(v27, v58), 16)
		local v60 = v52 + v59
		local v61 = bit32.rrotate(bit32.bxor(v45, v60), 12)
		v4 = v58 + (v61 + p[v21[12]])
		v19 = bit32.rrotate(bit32.bxor(v59, v4), 8)
		v14 = v60 + v19
		v9 = bit32.rrotate(bit32.bxor(v61, v14), 7)
		local v62 = v42 + (v53 + p[v21[13]])
		local v63 = bit32.rrotate(bit32.bxor(v35, v62), 16)
		local v64 = v28 + v63
		local v65 = bit32.rrotate(bit32.bxor(v53, v64), 12)
		v5 = v62 + (v65 + p[v21[14]])
		v20 = bit32.rrotate(bit32.bxor(v63, v5), 8)
		v11 = v64 + v20
		v10 = bit32.rrotate(bit32.bxor(v65, v11), 7)
		local v66 = v50 + (v29 + p[v21[15]])
		local v67 = bit32.rrotate(bit32.bxor(v43, v66), 16)
		local v68 = v36 + v67
		local v69 = bit32.rrotate(bit32.bxor(v29, v68), 12)
		v6 = v66 + (v69 + p[v21[16]])
		v17 = bit32.rrotate(bit32.bxor(v67, v6), 8)
		v12 = v68 + v17
		v7 = bit32.rrotate(bit32.bxor(v69, v12), 7)
	end

	clone[1] = bit32.bxor(clone[1], v3, v11)
	clone[2] = bit32.bxor(clone[2], v4, v12)
	clone[3] = bit32.bxor(clone[3], v5, v13)
	clone[4] = bit32.bxor(clone[4], v6, v14)
	clone[5] = bit32.bxor(clone[5], v7, v19)
	clone[6] = bit32.bxor(clone[6], v8, v20)
	clone[7] = bit32.bxor(clone[7], v9, v17)
	clone[8] = bit32.bxor(clone[8], v10, v18)
end

local function blake2s(value: string, value2: number, value3: string?)
	local v3 = value3 or ""
	local count = #v3
	assert(math.clamp(value2, 1, 32) == value2, "outSize must be in the range [1, 32]")
	assert(math.clamp(count, 0, 32) == count, "key length must be in the range [0, 32]")
	local clone = table.clone(v)
	clone[1] = bit32.bxor(clone[1], 16842752, bit32.lshift(count, 8), value2)
	local v4 = table.create(16)
	local count2 = #value
	local v5 = count > 0 and 64 or 0

	if count > 0 then
		local v6 = v3 .. string.rep("\0", -count + 64)
		local total = 1

		for i = 1, 16 do
			local v7, v8, v9, v10 = string.byte(v6, total, total + 3)
			v4[i] = bit32.bor(bit32.lshift(v10, 24), bit32.lshift(v9, 16), bit32.lshift(v8, 8), v7)
			total += 4
		end

		F(clone, v4, 64, count2 == 0)
	end

	local v6 = count2 % 64
	local v7 = v6 == 0 and 64 or v6

	for i = 1, count2 - v7, 64 do
		local v8 = i

		for i2 = 1, 16 do
			local v9, v10, v11, v12 = string.byte(value, v8, v8 + 3)
			v4[i2] = bit32.bor(bit32.lshift(v12, 24), bit32.lshift(v11, 16), bit32.lshift(v10, 8), v9)
			v8 += 4
		end

		v5 += 64
		F(clone, v4, v5, false)
	end

	if count == 0 or count2 > 0 then
		local v8 = string.sub(value, -v7)
		local v9 = v8 .. string.rep("\0", 64)
		local total = 1

		for i = 1, 16 do
			local v10, v11, v12, v13 = string.byte(v9, total, total + 3)
			v4[i] = bit32.bor(bit32.lshift(v13, 24), bit32.lshift(v12, 16), bit32.lshift(v11, 8), v10)
			total += 4
		end

		F(clone, v4, v5 + #v8, true)
	end

	return (string.sub(
		string.format(
			"%08x%08x%08x%08x%08x%08x%08x%08x",
			bit32.byteswap(clone[1]),
			bit32.byteswap(clone[2]),
			bit32.byteswap(clone[3]),
			bit32.byteswap(clone[4]),
			bit32.byteswap(clone[5]),
			bit32.byteswap(clone[6]),
			bit32.byteswap(clone[7]),
			(bit32.byteswap(clone[8]))
		),
		1,
		value2 * 2
	))
end

return blake2s