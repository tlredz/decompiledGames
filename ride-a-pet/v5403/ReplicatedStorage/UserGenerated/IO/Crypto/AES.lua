local bxor = bit32.bxor
local rrotate = bit32.rrotate
local copy = buffer.copy
local create = buffer.create
local fromstring = buffer.fromstring
local len = buffer.len
local readu8 = buffer.readu8
local readu16 = buffer.readu16
local readu32 = buffer.readu32
local tostring = buffer.tostring
local writestring = buffer.writestring
local writeu8 = buffer.writeu8
local writeu32 = buffer.writeu32
local floor = math.floor
local sub = string.sub
local buf = create(131072)
local buf2 = create(65536)
local buf3 = create(65536)
local buf4 = create(65536)
local buf5 = create(65536)
local buf6 = create(65536)

local function keySchedule(list, p: number, buf7: buffer, flag: boolean)
	if flag then
		copy(buf7, 0, list, 0, p)
	else
		writestring(buf7, 0, list, p)
	end

	local v3 = rrotate(readu32(buf7, p - 4), 8)
	local v4 = 0.5

	if p == 32 then
		for i = 32, 192, 32 do
			v4 = v4 * 2 % 229
			local v14 = bxor(
				readu32(buf7, i - 32),
				readu16(buf, floor(v3 / 65536) * 2) * 65536 + readu16(buf, v3 % 65536 * 2),
				v4
			)
			writeu32(buf7, i, v14)
			local v17 = bxor(readu32(buf7, i - 28), v14)
			writeu32(buf7, i + 4, v17)
			local v21 = bxor(readu32(buf7, i - 24), v17)
			writeu32(buf7, i + 8, v21)
			local v25 = bxor(readu32(buf7, i - 20), v21)
			writeu32(buf7, i + 12, v25)
			local v36 = bxor(
				readu32(buf7, i - 16),
				readu16(buf, floor(v25 / 65536) * 2) * 65536 + readu16(buf, v25 % 65536 * 2)
			)
			writeu32(buf7, i + 16, v36)
			local v40 = bxor(readu32(buf7, i - 12), v36)
			writeu32(buf7, i + 20, v40)
			local v44 = bxor(readu32(buf7, i - 8), v40)
			writeu32(buf7, i + 24, v44)
			local v48 = bxor(readu32(buf7, i - 4), v44)
			writeu32(buf7, i + 28, v48)
			v3 = rrotate(v48, 8)
		end

		local v13 = bxor(
			readu32(buf7, 192),
			readu16(buf, floor(v3 / 65536) * 2) * 65536 + readu16(buf, v3 % 65536 * 2),
			64
		)
		writeu32(buf7, 224, v13)
		local v15 = bxor(readu32(buf7, 196), v13)
		writeu32(buf7, 228, v15)
		local v17 = bxor(readu32(buf7, 200), v15)
		writeu32(buf7, 232, v17)
		writeu32(buf7, 236, (bxor(readu32(buf7, 204), v17)))
		return buf7
	elseif p == 24 then
		for i = 24, 168, 24 do
			v4 = v4 * 2 % 229
			local v14 = bxor(
				readu32(buf7, i - 24),
				readu16(buf, floor(v3 / 65536) * 2) * 65536 + readu16(buf, v3 % 65536 * 2),
				v4
			)
			writeu32(buf7, i, v14)
			local v17 = bxor(readu32(buf7, i - 20), v14)
			writeu32(buf7, i + 4, v17)
			local v21 = bxor(readu32(buf7, i - 16), v17)
			writeu32(buf7, i + 8, v21)
			local v25 = bxor(readu32(buf7, i - 12), v21)
			writeu32(buf7, i + 12, v25)
			local v29 = bxor(readu32(buf7, i - 8), v25)
			writeu32(buf7, i + 16, v29)
			local v33 = bxor(readu32(buf7, i - 4), v29)
			writeu32(buf7, i + 20, v33)
			v3 = rrotate(v33, 8)
		end

		local v13 = bxor(
			readu32(buf7, 168),
			readu16(buf, floor(v3 / 65536) * 2) * 65536 + readu16(buf, v3 % 65536 * 2),
			128
		)
		writeu32(buf7, 192, v13)
		local v15 = bxor(readu32(buf7, 172), v13)
		writeu32(buf7, 196, v15)
		local v17 = bxor(readu32(buf7, 176), v15)
		writeu32(buf7, 200, v17)
		writeu32(buf7, 204, (bxor(readu32(buf7, 180), v17)))
		return buf7
	else
		for i = 16, 144, 16 do
			v4 = v4 * 2 % 229
			local v14 = bxor(
				readu32(buf7, i - 16),
				readu16(buf, floor(v3 / 65536) * 2) * 65536 + readu16(buf, v3 % 65536 * 2),
				v4
			)
			writeu32(buf7, i, v14)
			local v17 = bxor(readu32(buf7, i - 12), v14)
			writeu32(buf7, i + 4, v17)
			local v21 = bxor(readu32(buf7, i - 8), v17)
			writeu32(buf7, i + 8, v21)
			local v25 = bxor(readu32(buf7, i - 4), v21)
			writeu32(buf7, i + 12, v25)
			v3 = rrotate(v25, 8)
		end

		local v13 = bxor(
			readu32(buf7, 144),
			readu16(buf, floor(v3 / 65536) * 2) * 65536 + readu16(buf, v3 % 65536 * 2),
			54
		)
		writeu32(buf7, 160, v13)
		local v15 = bxor(readu32(buf7, 148), v13)
		writeu32(buf7, 164, v15)
		local v17 = bxor(readu32(buf7, 152), v15)
		writeu32(buf7, 168, v17)
		writeu32(buf7, 172, (bxor(readu32(buf7, 156), v17)))
		return buf7
	end
end

local function encryptBlock(buf7: buffer, p: number, buf8: buffer, p2: number, buf9: buffer, p3: number)
	local v = readu8(buf8, p2)
	local v3 = bxor(v, (readu8(buf7, 0)))
	v = readu8(buf8, p2 + 1)
	local v6 = bxor(v, (readu8(buf7, 1)))
	v = readu8(buf8, p2 + 2)
	local v9 = bxor(v, (readu8(buf7, 2)))
	v = readu8(buf8, p2 + 3)
	local v12 = bxor(v, (readu8(buf7, 3)))
	v = readu8(buf8, p2 + 4)
	local v15 = bxor(v, (readu8(buf7, 4)))
	v = readu8(buf8, p2 + 5)
	local v18 = bxor(v, (readu8(buf7, 5)))
	v = readu8(buf8, p2 + 6)
	local v21 = bxor(v, (readu8(buf7, 6)))
	v = readu8(buf8, p2 + 7)
	local v24 = bxor(v, (readu8(buf7, 7)))
	v = readu8(buf8, p2 + 8)
	local v27 = bxor(v, (readu8(buf7, 8)))
	v = readu8(buf8, p2 + 9)
	local v30 = bxor(v, (readu8(buf7, 9)))
	v = readu8(buf8, p2 + 10)
	local v33 = bxor(v, (readu8(buf7, 10)))
	v = readu8(buf8, p2 + 11)
	local v36 = bxor(v, (readu8(buf7, 11)))
	v = readu8(buf8, p2 + 12)
	local v39 = bxor(v, (readu8(buf7, 12)))
	v = readu8(buf8, p2 + 13)
	local v42 = bxor(v, (readu8(buf7, 13)))
	v = readu8(buf8, p2 + 14)
	local v45 = bxor(v, (readu8(buf7, 14)))
	v = readu8(buf8, p2 + 15)
	local v48 = bxor(v, (readu8(buf7, 15)))
	local v49 = v3 * 256 + v18
	local v50 = v18 * 256 + v33
	local v51 = v33 * 256 + v48
	local v52 = v48 * 256 + v3
	local v53 = v15 * 256 + v30
	local v54 = v30 * 256 + v45
	local v55 = v45 * 256 + v12
	local v56 = v12 * 256 + v15
	local v57 = v27 * 256 + v42
	local v58 = v42 * 256 + v9
	local v59 = v9 * 256 + v24
	local v60 = v24 * 256 + v27
	local v61 = v39 * 256 + v6
	local v62 = v6 * 256 + v21
	local v63 = v21 * 256 + v36
	local v64 = v36 * 256 + v39

	for i = 16, p, 16 do
		local v65 = readu8(buf2, v49)
		local v66 = readu8(buf3, v51)
		local v68 = bxor(v65, v66, (readu8(buf7, i)))
		v65 = readu8(buf2, v50)
		v66 = readu8(buf3, v52)
		local v71 = bxor(v65, v66, (readu8(buf7, i + 1)))
		v65 = readu8(buf2, v51)
		v66 = readu8(buf3, v49)
		local v74 = bxor(v65, v66, (readu8(buf7, i + 2)))
		v65 = readu8(buf2, v52)
		v66 = readu8(buf3, v50)
		local v77 = bxor(v65, v66, (readu8(buf7, i + 3)))
		v65 = readu8(buf2, v53)
		v66 = readu8(buf3, v55)
		local v80 = bxor(v65, v66, (readu8(buf7, i + 4)))
		v65 = readu8(buf2, v54)
		v66 = readu8(buf3, v56)
		local v83 = bxor(v65, v66, (readu8(buf7, i + 5)))
		v65 = readu8(buf2, v55)
		v66 = readu8(buf3, v53)
		local v86 = bxor(v65, v66, (readu8(buf7, i + 6)))
		v65 = readu8(buf2, v56)
		v66 = readu8(buf3, v54)
		local v89 = bxor(v65, v66, (readu8(buf7, i + 7)))
		v65 = readu8(buf2, v57)
		v66 = readu8(buf3, v59)
		local v92 = bxor(v65, v66, (readu8(buf7, i + 8)))
		v65 = readu8(buf2, v58)
		v66 = readu8(buf3, v60)
		local v95 = bxor(v65, v66, (readu8(buf7, i + 9)))
		v65 = readu8(buf2, v59)
		v66 = readu8(buf3, v57)
		local v98 = bxor(v65, v66, (readu8(buf7, i + 10)))
		v65 = readu8(buf2, v60)
		v66 = readu8(buf3, v58)
		local v101 = bxor(v65, v66, (readu8(buf7, i + 11)))
		v65 = readu8(buf2, v61)
		v66 = readu8(buf3, v63)
		local v104 = bxor(v65, v66, (readu8(buf7, i + 12)))
		v65 = readu8(buf2, v62)
		v66 = readu8(buf3, v64)
		local v107 = bxor(v65, v66, (readu8(buf7, i + 13)))
		v65 = readu8(buf2, v63)
		v66 = readu8(buf3, v61)
		local v110 = bxor(v65, v66, (readu8(buf7, i + 14)))
		v65 = readu8(buf2, v64)
		v66 = readu8(buf3, v62)
		local v113 = bxor(v65, v66, (readu8(buf7, i + 15)))
		v49 = v68 * 256 + v83
		v50 = v83 * 256 + v98
		v51 = v98 * 256 + v113
		v52 = v113 * 256 + v68
		v53 = v80 * 256 + v95
		v54 = v95 * 256 + v110
		v55 = v110 * 256 + v77
		v56 = v77 * 256 + v80
		v57 = v92 * 256 + v107
		v58 = v107 * 256 + v74
		v59 = v74 * 256 + v89
		v60 = v89 * 256 + v92
		v61 = v104 * 256 + v71
		v62 = v71 * 256 + v86
		v63 = v86 * 256 + v101
		v64 = v101 * 256 + v104
	end

	v = buf
	v3 = readu8(buf2, v64)
	v6 = readu8(buf3, v62)
	v9 = bxor(v3, v6, (readu8(buf7, p + 31))) * 512
	v3 = readu8(buf2, v59)
	v6 = readu8(buf3, v57)
	v3 = readu16(v, v9 + bxor(v3, v6, (readu8(buf7, p + 26))) * 2) * 65536
	v = buf
	v6 = readu8(buf2, v54)
	v9 = readu8(buf3, v56)
	v12 = bxor(v6, v9, (readu8(buf7, p + 21))) * 512
	v6 = readu8(buf2, v49)
	v9 = readu8(buf3, v51)
	v6 = v3 + readu16(v, v12 + bxor(v6, v9, (readu8(buf7, p + 16))) * 2)
	writeu32(buf9, p3, (bxor(v6, (readu32(buf7, p + 32)))))
	v = p3 + 4
	v3 = buf
	v6 = readu8(buf2, v52)
	v9 = readu8(buf3, v50)
	v12 = bxor(v6, v9, (readu8(buf7, p + 19))) * 512
	v6 = readu8(buf2, v63)
	v9 = readu8(buf3, v61)
	v6 = readu16(v3, v12 + bxor(v6, v9, (readu8(buf7, p + 30))) * 2) * 65536
	v3 = buf
	v9 = readu8(buf2, v58)
	v12 = readu8(buf3, v60)
	v15 = bxor(v9, v12, (readu8(buf7, p + 25))) * 512
	v9 = readu8(buf2, v53)
	v12 = readu8(buf3, v55)
	v9 = v6 + readu16(v3, v15 + bxor(v9, v12, (readu8(buf7, p + 20))) * 2)
	writeu32(buf9, v, (bxor(v9, (readu32(buf7, p + 36)))))
	v = p3 + 8
	v3 = buf
	v6 = readu8(buf2, v56)
	v9 = readu8(buf3, v54)
	v12 = bxor(v6, v9, (readu8(buf7, p + 23))) * 512
	v6 = readu8(buf2, v51)
	v9 = readu8(buf3, v49)
	v6 = readu16(v3, v12 + bxor(v6, v9, (readu8(buf7, p + 18))) * 2) * 65536
	v3 = buf
	v9 = readu8(buf2, v62)
	v12 = readu8(buf3, v64)
	v15 = bxor(v9, v12, (readu8(buf7, p + 29))) * 512
	v9 = readu8(buf2, v57)
	v12 = readu8(buf3, v59)
	v9 = v6 + readu16(v3, v15 + bxor(v9, v12, (readu8(buf7, p + 24))) * 2)
	writeu32(buf9, v, (bxor(v9, (readu32(buf7, p + 40)))))
	v = p3 + 12
	v3 = buf
	v6 = readu8(buf2, v60)
	v9 = readu8(buf3, v58)
	v12 = bxor(v6, v9, (readu8(buf7, p + 27))) * 512
	v6 = readu8(buf2, v55)
	v9 = readu8(buf3, v53)
	v6 = readu16(v3, v12 + bxor(v6, v9, (readu8(buf7, p + 22))) * 2) * 65536
	v3 = buf
	v9 = readu8(buf2, v50)
	v12 = readu8(buf3, v52)
	v15 = bxor(v9, v12, (readu8(buf7, p + 17))) * 512
	v9 = readu8(buf2, v61)
	v12 = readu8(buf3, v63)
	v9 = v6 + readu16(v3, v15 + bxor(v9, v12, (readu8(buf7, p + 28))) * 2)
	writeu32(buf9, v, (bxor(v9, (readu32(buf7, p + 44)))))
end

local function decryptBlock(buf7: buffer, p: number, buf8: buffer, p2: number, buf9: buffer, p3: number)
	local v = buf4
	local v2 = readu8(buf8, p2) * 256
	v2 = readu8(v, v2 + readu8(buf7, p + 32))
	v = bxor(v2, (readu8(buf7, p + 16)))
	v2 = buf4
	local v8 = readu8(buf8, p2 + 13) * 256
	v8 = readu8(v2, v8 + readu8(buf7, p + 45))
	v2 = bxor(v8, (readu8(buf7, p + 17)))
	v8 = buf4
	local v14 = readu8(buf8, p2 + 10) * 256
	v14 = readu8(v8, v14 + readu8(buf7, p + 42))
	v8 = bxor(v14, (readu8(buf7, p + 18)))
	v14 = buf4
	local v20 = readu8(buf8, p2 + 7) * 256
	v20 = readu8(v14, v20 + readu8(buf7, p + 39))
	v14 = bxor(v20, (readu8(buf7, p + 19)))
	v20 = buf4
	local v26 = readu8(buf8, p2 + 4) * 256
	v26 = readu8(v20, v26 + readu8(buf7, p + 36))
	v20 = bxor(v26, (readu8(buf7, p + 20)))
	v26 = buf4
	local v32 = readu8(buf8, p2 + 1) * 256
	v32 = readu8(v26, v32 + readu8(buf7, p + 33))
	v26 = bxor(v32, (readu8(buf7, p + 21)))
	v32 = buf4
	local v38 = readu8(buf8, p2 + 14) * 256
	v38 = readu8(v32, v38 + readu8(buf7, p + 46))
	v32 = bxor(v38, (readu8(buf7, p + 22)))
	v38 = buf4
	local v44 = readu8(buf8, p2 + 11) * 256
	v44 = readu8(v38, v44 + readu8(buf7, p + 43))
	v38 = bxor(v44, (readu8(buf7, p + 23)))
	v44 = buf4
	local v50 = readu8(buf8, p2 + 8) * 256
	v50 = readu8(v44, v50 + readu8(buf7, p + 40))
	v44 = bxor(v50, (readu8(buf7, p + 24)))
	v50 = buf4
	local v56 = readu8(buf8, p2 + 5) * 256
	v56 = readu8(v50, v56 + readu8(buf7, p + 37))
	v50 = bxor(v56, (readu8(buf7, p + 25)))
	v56 = buf4
	local v62 = readu8(buf8, p2 + 2) * 256
	v62 = readu8(v56, v62 + readu8(buf7, p + 34))
	v56 = bxor(v62, (readu8(buf7, p + 26)))
	v62 = buf4
	local v68 = readu8(buf8, p2 + 15) * 256
	v68 = readu8(v62, v68 + readu8(buf7, p + 47))
	v62 = bxor(v68, (readu8(buf7, p + 27)))
	v68 = buf4
	local v74 = readu8(buf8, p2 + 12) * 256
	v74 = readu8(v68, v74 + readu8(buf7, p + 44))
	v68 = bxor(v74, (readu8(buf7, p + 28)))
	v74 = buf4
	local v80 = readu8(buf8, p2 + 9) * 256
	v80 = readu8(v74, v80 + readu8(buf7, p + 41))
	v74 = bxor(v80, (readu8(buf7, p + 29)))
	v80 = buf4
	local v86 = readu8(buf8, p2 + 6) * 256
	v86 = readu8(v80, v86 + readu8(buf7, p + 38))
	v80 = bxor(v86, (readu8(buf7, p + 30)))
	v86 = buf4
	local v92 = readu8(buf8, p2 + 3) * 256
	v92 = readu8(v86, v92 + readu8(buf7, p + 35))
	v86 = bxor(v92, (readu8(buf7, p + 31)))
	local v97 = v * 256 + v2
	local v98 = v2 * 256 + v8
	local v99 = v8 * 256 + v14
	local v100 = v14 * 256 + v
	local v101 = v20 * 256 + v26
	local v102 = v26 * 256 + v32
	local v103 = v32 * 256 + v38
	local v104 = v38 * 256 + v20
	local v105 = v44 * 256 + v50
	local v106 = v50 * 256 + v56
	local v107 = v56 * 256 + v62
	local v108 = v62 * 256 + v44
	local v109 = v68 * 256 + v74
	local v110 = v74 * 256 + v80
	local v111 = v80 * 256 + v86
	local v112 = v86 * 256 + v68

	for i = p, 16, -16 do
		local v113 = buf4
		local v115 = readu8(v113, readu8(buf5, v97) * 256 + readu8(buf6, v99))
		v113 = bxor(v115, (readu8(buf7, i)))
		v115 = buf4
		local v118 = readu8(v115, readu8(buf5, v110) * 256 + readu8(buf6, v112))
		v115 = bxor(v118, (readu8(buf7, i + 1)))
		v118 = buf4
		local v122 = readu8(v118, readu8(buf5, v107) * 256 + readu8(buf6, v105))
		v118 = bxor(v122, (readu8(buf7, i + 2)))
		v122 = buf4
		local v126 = readu8(v122, readu8(buf5, v104) * 256 + readu8(buf6, v102))
		v122 = bxor(v126, (readu8(buf7, i + 3)))
		v126 = buf4
		local v130 = readu8(v126, readu8(buf5, v101) * 256 + readu8(buf6, v103))
		v126 = bxor(v130, (readu8(buf7, i + 4)))
		v130 = buf4
		local v134 = readu8(v130, readu8(buf5, v98) * 256 + readu8(buf6, v100))
		v130 = bxor(v134, (readu8(buf7, i + 5)))
		v134 = buf4
		local v138 = readu8(v134, readu8(buf5, v111) * 256 + readu8(buf6, v109))
		v134 = bxor(v138, (readu8(buf7, i + 6)))
		v138 = buf4
		local v142 = readu8(v138, readu8(buf5, v108) * 256 + readu8(buf6, v106))
		v138 = bxor(v142, (readu8(buf7, i + 7)))
		v142 = buf4
		local v146 = readu8(v142, readu8(buf5, v105) * 256 + readu8(buf6, v107))
		v142 = bxor(v146, (readu8(buf7, i + 8)))
		v146 = buf4
		local v150 = readu8(v146, readu8(buf5, v102) * 256 + readu8(buf6, v104))
		v146 = bxor(v150, (readu8(buf7, i + 9)))
		v150 = buf4
		local v154 = readu8(v150, readu8(buf5, v99) * 256 + readu8(buf6, v97))
		v150 = bxor(v154, (readu8(buf7, i + 10)))
		v154 = buf4
		local v158 = readu8(v154, readu8(buf5, v112) * 256 + readu8(buf6, v110))
		v154 = bxor(v158, (readu8(buf7, i + 11)))
		v158 = buf4
		local v162 = readu8(v158, readu8(buf5, v109) * 256 + readu8(buf6, v111))
		v158 = bxor(v162, (readu8(buf7, i + 12)))
		v162 = buf4
		local v166 = readu8(v162, readu8(buf5, v106) * 256 + readu8(buf6, v108))
		v162 = bxor(v166, (readu8(buf7, i + 13)))
		v166 = buf4
		local v170 = readu8(v166, readu8(buf5, v103) * 256 + readu8(buf6, v101))
		v166 = bxor(v170, (readu8(buf7, i + 14)))
		v170 = buf4
		v170 = bxor(readu8(v170, readu8(buf5, v100) * 256 + readu8(buf6, v98)), (readu8(buf7, i + 15)))
		v97 = v113 * 256 + v115
		v98 = v115 * 256 + v118
		v99 = v118 * 256 + v122
		v100 = v122 * 256 + v113
		v101 = v126 * 256 + v130
		v102 = v130 * 256 + v134
		v103 = v134 * 256 + v138
		v104 = v138 * 256 + v126
		v105 = v142 * 256 + v146
		v106 = v146 * 256 + v150
		v107 = v150 * 256 + v154
		v108 = v154 * 256 + v142
		v109 = v158 * 256 + v162
		v110 = v162 * 256 + v166
		v111 = v166 * 256 + v170
		v112 = v170 * 256 + v158
	end

	v = buf4
	v2 = readu8(v, readu8(buf5, v104) * 256 + readu8(buf6, v102))
	v = bxor(v2, (readu8(buf7, 3))) * 16777216
	v2 = buf4
	v8 = readu8(v2, readu8(buf5, v107) * 256 + readu8(buf6, v105))
	v2 = v + bxor(v8, (readu8(buf7, 2))) * 65536
	v = buf4
	v8 = readu8(v, readu8(buf5, v110) * 256 + readu8(buf6, v112))
	v = v2 + bxor(v8, (readu8(buf7, 1))) * 256
	v2 = buf4
	v8 = readu8(v2, readu8(buf5, v97) * 256 + readu8(buf6, v99))
	writeu32(buf9, p3, v + bxor(v8, (readu8(buf7, 0))))
	v = p3 + 4
	v2 = buf4
	v8 = readu8(v2, readu8(buf5, v108) * 256 + readu8(buf6, v106))
	v2 = bxor(v8, (readu8(buf7, 7))) * 16777216
	v8 = buf4
	v14 = readu8(v8, readu8(buf5, v111) * 256 + readu8(buf6, v109))
	v8 = v2 + bxor(v14, (readu8(buf7, 6))) * 65536
	v2 = buf4
	v14 = readu8(v2, readu8(buf5, v98) * 256 + readu8(buf6, v100))
	v2 = v8 + bxor(v14, (readu8(buf7, 5))) * 256
	v8 = buf4
	v14 = readu8(v8, readu8(buf5, v101) * 256 + readu8(buf6, v103))
	writeu32(buf9, v, v2 + bxor(v14, (readu8(buf7, 4))))
	v = p3 + 8
	v2 = buf4
	v8 = readu8(v2, readu8(buf5, v112) * 256 + readu8(buf6, v110))
	v2 = bxor(v8, (readu8(buf7, 11))) * 16777216
	v8 = buf4
	v14 = readu8(v8, readu8(buf5, v99) * 256 + readu8(buf6, v97))
	v8 = v2 + bxor(v14, (readu8(buf7, 10))) * 65536
	v2 = buf4
	v14 = readu8(v2, readu8(buf5, v102) * 256 + readu8(buf6, v104))
	v2 = v8 + bxor(v14, (readu8(buf7, 9))) * 256
	v8 = buf4
	v14 = readu8(v8, readu8(buf5, v105) * 256 + readu8(buf6, v107))
	writeu32(buf9, v, v2 + bxor(v14, (readu8(buf7, 8))))
	v = p3 + 12
	v2 = buf4
	v8 = readu8(v2, readu8(buf5, v100) * 256 + readu8(buf6, v98))
	v2 = bxor(v8, (readu8(buf7, 15))) * 16777216
	v8 = buf4
	v14 = readu8(v8, readu8(buf5, v103) * 256 + readu8(buf6, v101))
	v8 = v2 + bxor(v14, (readu8(buf7, 14))) * 65536
	v2 = buf4
	v14 = readu8(v2, readu8(buf5, v106) * 256 + readu8(buf6, v108))
	v2 = v8 + bxor(v14, (readu8(buf7, 13))) * 256
	v8 = buf4
	v14 = readu8(v8, readu8(buf5, v109) * 256 + readu8(buf6, v111))
	writeu32(buf9, v, v2 + bxor(v14, (readu8(buf7, 12))))
end

local buf7 = create(256)
local buf8 = create(256)
local buf9 = create(256)
local buf10 = create(256)
local buf11 = create(256)

local function gfmul(p: number, p2: number)
	local v = 0

	for _ = 0, 7 do
		if p2 % 2 == 1 then
			v = bxor(v, p)
		end

		if p >= 128 then
			p = bxor(p * 2 % 256, 27)
		else
			p = p * 2 % 256
		end

		p2 = floor(p2 / 2)
	end

	return v
end

writeu8(buf7, 0, 99)
local v = 1
local v2 = 1

for _ = 1, 255 do
	v = bxor(v, v * 2, v < 128 and 0 or 27) % 256
	local v3 = bxor(v2, v2 * 2)
	local v4 = bxor(v3, v3 * 4)
	v2 = bxor(v4, v4 * 16) % 256

	if v2 >= 128 then
		v2 = bxor(v2, 9)
	end

	local v5 = bxor(
		v2,
		v2 % 128 * 2 + v2 / 128,
		v2 % 64 * 4 + v2 / 64,
		v2 % 32 * 8 + v2 / 32,
		v2 % 16 * 16 + v2 / 16,
		99
	)
	writeu8(buf7, v, v5)
	writeu8(buf8, v5, v)
	writeu8(buf9, v, (gfmul(3, v)))
	writeu8(buf10, v, (gfmul(9, v)))
	writeu8(buf11, v, (gfmul(11, v)))
end

local count = 0

for i = 0, 255 do
	local v3 = readu8(buf7, i)
	local v4 = v3 * 256
	local v5 = gfmul(2, v3)
	local v6 = gfmul(13, i)
	local v7 = gfmul(14, i)

	for i2 = 0, 255 do
		local v8 = readu8(buf7, i2)
		buffer.writeu16(buf, count * 2, v4 + v8)
		writeu8(buf4, count, (readu8(buf8, (bxor(i, i2)))))
		writeu8(buf2, count, (bxor(v5, (readu8(buf9, v8)))))
		writeu8(buf3, count, (bxor(v3, v8)))
		writeu8(buf5, count, (bxor(v7, (readu8(buf11, i2)))))
		writeu8(buf6, count, (bxor(v6, (readu8(buf10, i2)))))
		count += 1
	end
end

local function newidx(_, p)
	return error((`{p} cannot be assigned to`))
end

local function tostr()
	return "AesCipher"
end

local Modes = require(script.Modes)
local Pads = require(script.Pads)

local function expandKey(list, buf12: buffer?)
	local v3 = typeof(list) == "buffer"
	local v4

	if v3 then
		v4 = len(list)
	else
		v4 = #list
	end

	local v5

	if v4 == 32 then
		v5 = 240
	elseif v4 == 24 then
		v5 = 208
	elseif v4 == 16 then
		v5 = 176
	else
		v5 = error("Key must be either 16, 24 or 32 bytes long")
	end

	return (keySchedule(list, v4, buf12 or create(v5), v3))
end

local function fromKey(buf12: buffer, p, p2)
	local v3 = len(buf12)
	local v4 = nil
	local v5 = nil
	local v6 = tostring(buf12)

	if v3 == 240 then
		v5 = sub(v6, 1, 32)
		v4 = 192
	elseif v3 == 208 then
		v5 = sub(v6, 1, 24)
		v4 = 160
	elseif v3 == 176 then
		v5 = sub(v6, 1, 16)
		v4 = 128
	else
		error("Round keys must be either 240, 208 or 128 bytes long")
	end

	local buf13 = buf12
	local v7 = p or Modes.ECB
	local fwdMode = v7.FwdMode
	local invMode = v7.InvMode
	local segmentSize = v7.SegmentSize or 16
	local v8 = p2 or Pads.Pkcs7
	local pad = v8.Pad
	local unpad = v8.Unpad
	local v9 = newproxy(true)
	local metatable = getmetatable(v9)

	local function encp(p3, p4, p5, p6)
		encryptBlock(buf13, v4, p3, p4, p5, p6)
	end

	local function decp(p3, p4, p5, p6)
		decryptBlock(buf13, v4, p3, p4, p5, p6)
	end

	local function enc(object, buffer2, p3, ...)
		if typeof(buffer2) ~= "buffer" then
			if typeof(buffer2) == "string" then
				buffer2 = fromstring(buffer2)
			else
				buffer2 = error((`Unable to cast {typeof(buffer2)} to buffer`))
			end
		end

		if typeof(p3) ~= "buffer" then
			p3 = false
		end

		if object ~= v9 then
			return object:Encrypt(buffer2, p3, ...)
		end

		if not v4 then
			error("AesCipher object's already destroyed")
			return create(0)
		end

		local padded = pad(buffer2, p3, segmentSize)
		local v10 = fwdMode

		if v8.Overwrite ~= false then
			buffer2 = padded
		end

		v10(encp, decp, buffer2, padded, v7, ...)
		return padded
	end

	local function encb(object, p3, p4, p5, p6)
		if object ~= v9 then
			object:EncryptBlock(p3, p4, p5, p6)
		elseif v4 then
			encryptBlock(buf13, v4, p3, p4, p5 or p3, p6 or p4)
		else
			error("AesCipher object's already destroyed")
		end
	end

	local function dec(object, buffer2, p3, ...)
		if typeof(buffer2) ~= "buffer" then
			if typeof(buffer2) == "string" then
				buffer2 = fromstring(buffer2)
			else
				buffer2 = error((`Unable to cast {typeof(buffer2)} to buffer`))
			end
		end

		if typeof(p3) ~= "buffer" then
			p3 = false
		end

		if object ~= v9 then
			return object:Decrypt(buffer2, p3, ...)
		end

		if not v4 then
			error("AesCipher object's already destroyed")
			return create(0)
		end

		local overwrite = v8.Overwrite
		local buf14

		if overwrite == nil then
			buf14 = create(len(buffer2))
		elseif overwrite then
			buf14 = buffer2
		else
			buf14 = p3 or create(len(buffer2))
		end

		invMode(encp, decp, buffer2, buf14, v7, ...)
		return (unpad(buf14, p3, segmentSize))
	end

	local function decb(object, p3, p4, p5, p6)
		if object ~= v9 then
			object:DecryptBlock(p3, p4, p5, p6)
		elseif v4 then
			decryptBlock(buf13, v4, p3, p4, p5 or p3, p6 or p4)
		else
			error("AesCipher object's already destroyed")
		end
	end

	local function destroy(instance)
		if instance ~= v9 then
			instance:Destroy()
			return
		end

		if not v4 then
			error("AesCipher object's already destroyed")
			return
		end

		v6 = nil
		buf13 = nil
		v4 = nil
		fwdMode = nil
		invMode = nil
		v7 = nil
		v8 = nil
		v5 = nil
		v3 = nil
	end

	function metatable.__index(_, p3)
		if p3 == "Encrypt" then
			return enc
		elseif p3 == "Decrypt" then
			return dec
		elseif p3 == "EncryptBlock" then
			return encb
		elseif p3 == "DecryptBlock" then
			return decb
		elseif p3 == "Destroy" then
			return destroy
		end

		if not v4 then
			return (error("AesCipher object's already destroyed"))
		end

		if p3 == "Key" then
			return v5
		elseif p3 == "RoundKeys" then
			return v6
		elseif p3 == "Mode" then
			return v7
		elseif p3 == "Padding" then
			return v8
		elseif p3 == "Length" then
			return v3
		end

		return (error((`{p3} is not a valid member of AesCipher`)))
	end

	metatable.__newindex = newidx
	metatable.__tostring = tostr

	function metatable.__len()
		return v3 or error("AesCipher object's destroyed")
	end

	metatable.__metatable = "AesCipher object: Metatable's locked"
	return v9
end

return table.freeze({
	new = function(p, p2, p3)
		return (fromKey(expandKey(p), p2, p3))
	end,
	expandKey = expandKey,
	fromKey = fromKey,
	modes = Modes,
	pads = Pads
})