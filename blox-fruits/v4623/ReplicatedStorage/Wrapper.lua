local byte = string.byte
local char = string.char
local sub = string.sub
local concat = table.concat
local _ = table.insert
local ldexp = math.ldexp
local getfenv2 = getfenv or function()
	return _ENV
end
local setmetatable2 = setmetatable
local select2 = select
local unpack2 = unpack or table.unpack
local tonumber2 = tonumber

local function u(list)
	local v = 256
	local v2 = {}
	local v3 = {}

	for i = 0, v - 1 do
		v2[i] = char(i)
	end

	local total = 1

	local function a()
		local v5 = tonumber2(sub(list, total, total), 36)
		total += 1
		local v10 = tonumber2(sub(list, total, total + v5 - 1), 36)
		total += v5
		return v10
	end

	local v4 = char(a())
	v3[1] = v4

	while total < #list do
		local v5 = a()
		local v6

		if v2[v5] then
			v6 = v2[v5]
		else
			v6 = v4 .. sub(v4, 1, 1)
		end

		v2[v] = v4 .. sub(v6, 1, 1)
		local v7 = #v3 + 1
		v += 1
		v3[v7] = v6
		v4 = v6
	end

	return table.concat(v3)
end

local v = u("21M21N27521L21Q27521N22G22B22M22G22827827623F27927J2151S2792742752151W27N27J1L27921L27J1627S27527O21N27W27V27G21N22322G22I22F22F2112791T1021N27427827427421R21H27928I21N28E28221N28O28K28M27528O21N1H21N21K27J27521B29028G27921P21J29521G29628U27929B27427Q21N21R28R27521P1728S27S27O1927Z2751U29I28R27829829V29F29628L29E29621N2942912812A529V28129H27828321N29M2AF29C29K29R2752912792AK29V27921F29O27W27421P21C29V27R2812A22752AY2751A29O2921529O2A81Z2B52792B021N2122A41G2BB27927U2AD27X29S2AE2BO2AM21N23622023E21L21D27923D22I22022M22W22G22122A22322721P27J2182922751R2CB29G27629K2CB2AE2CB2CK2A42CB2942AL2CL21L21O27922K22M22722L22M22D22521L21E2792242C422722M22L22A22F22M21L2992752CU22722G22C22D22022722I22D22722027727922N22M22H22622K2BQ27925N1421L29J27522E22I22722B21L2C82752212DM22N22C22E2DX21N23F22Q23F2EG21N22A23F2E12CT22I22E2DB21627922X22M22322F22A2882D622N22W22722C2EB2CU2CR2EV22M22E22C2D62DP2D227523128922A22N2E52F62BV27923H22A2212C122M2212252FU2BQ26325G25G22C2BU2E221N22B2DV2DB2BW2FH2FJ2FL2F5221192DQ2752232C42DN2EG23724Z23F23A2792151Q29S2BE2AI27P27R27W2CJ2B42EL1O28R2GY2B32962AE2AV29623G2CM2BD2HA27O1B2CH29L29927W1Y2AI2BD2HK2741R1N28R27429129Y2HJ2HL28V21N2HN21N2HP2HR29V2H827W2152HB2HX2I629D2752HZ2I12AT29O2I421N2HD2BC2HX2II2ID2962782IM27W29J2IG2II2752HC2A42942CJ275142I227P2CG2E921N2I62952CS2CC2CP2912AR2J629J2FG2J528W21N2G927J2912BL2JD2AH2IU2CG1329629H2C82AW2CC112AH2C82992CD2JY21N21I2I029L2AH28M2K12C82C829B2J62AR2172GQ2752D22J82K521N2D22D22EU2792KM2CB2C82D22CF2AH2JV2KK2KA21N2K02K62C82K42K92AH2I62L42KB2JG21N2KE2KG2KL21N2KJ2K12KQ2KO2KH2LD2922KS2A11V28R2H227O2IX2CM21N21A2J12L927W2142CB2A72CB2G42J92B82952L428K2KK2CS28H2JO2CS23C2HW2792ME2IA21N23I2962I12MA29O2MM2LE2AP21028R2MN2BD23B2ML1M2LL21N21H1T2A92IE2IU2HX2IE2MV2A12N62A427Y2802CL291")
local bxor = bit and bit.bxor or function(p, p2)
	local v2 = 1
	local total = 0

	while p > 0 and p2 > 0 do
		local v3 = p % 2
		local v4 = p2 % 2

		if v3 ~= v4 then
			total += v2
		end

		p = (p - v3) / 2
		p2 = (p2 - v4) / 2
		v2 *= 2
	end

	if p < p2 then
		p = p2
	end

	while p > 0 do
		local v3 = p % 2

		if v3 > 0 then
			total += v2
		end

		p = (p - v3) / 2
		v2 *= 2
	end

	return total
end

local function n(p, p2, p3)
	if p3 then
		local v2 = p / 2 ^ (p2 - 1) % 2 ^ (p3 - 1 - (p2 - 1) + 1)
		return v2 - v2 % 1
	end

	local v2 = 2 ^ (p2 - 1)

	if v2 <= p % (v2 + v2) then
		return 1
	end

	return 0
end

local total = 1

local function l()
	local v5, v6, v7, v8 = byte(v, total, total + 3)
	local v9 = bxor(v5, 59)
	local v10 = bxor(v6, 59)
	local v11 = bxor(v7, 59)
	local v12 = bxor(v8, 59)
	total += 4
	return v12 * 16777216 + v11 * 65536 + v10 * 256 + v9
end

local function d()
	local v2 = bxor(byte(v, total, total), 59)
	total += 1
	return v2
end

local function i()
	local v5, v6 = byte(v, total, total + 2)
	local v7 = bxor(v5, 59)
	local v8 = bxor(v6, 59)
	total += 2
	return v8 * 256 + v7
end

local function B()
	local v2 = l()
	local v3 = l()
	local v4 = 1
	local v5 = n(v3, 1, 20) * 4294967296 + v2
	local v6 = n(v3, 21, 31)
	local v7 = (-1) ^ n(v3, 32)

	if v6 == 0 then
		if v5 == 0 then
			return v7 * 0
		end

		v6 = 1
		v4 = 0
	elseif v6 == 2047 then
		return v5 == 0 and v7 * 1e999 or v7 * (0 / 0)
	end

	return ldexp(v7, v6 - 1023) * (v4 + v5 / 4503599627370496)
end

local function N(p)
	if not p then
		p = l()

		if p == 0 then
			return ""
		end
	end

	local v5 = sub(v, total, total + p - 1)
	total += p
	local v6 = {}

	for i2 = 1, #v5 do
		v6[i2] = char(bxor(byte((sub(v5, i2, i2))), 59))
	end

	return concat(v6)
end

local function s(...)
	return { ... }, select2("#", ...)
end

local u2

u2 = function()
	local v2 = {}
	local v3 = {}
	local v4 = {}
	local v5 = {
		v2,
		v3,
		nil,
		{}
	}

	for i2 = 1, l() do
		local v6 = d()
		local v7 = nil

		if v6 == 1 then
			v7 = d() ~= 0
		elseif v6 == 3 then
			v7 = B()
		elseif v6 == 2 then
			v7 = N()
		end

		v4[i2] = v7
	end

	for i2 = 1, l() do
		local v6 = d()

		if n(v6, 1, 1) ~= 0 then
			continue
		end

		local v7 = n(v6, 2, 3)
		local v8 = n(v6, 4, 6)
		local v9 = {
			i(),
			i(),
			nil,
			nil
		}

		if v7 == 0 then
			v9[3] = i()
			v9[4] = i()
		elseif v7 == 1 then
			v9[3] = l()
		elseif v7 == 2 then
			v9[3] = l() - 65536
		elseif v7 == 3 then
			v9[3] = l() - 65536
			v9[4] = i()
		end

		if n(v8, 1, 1) == 1 then
			v9[2] = v4[v9[2]]
		end

		if n(v8, 2, 2) == 1 then
			v9[3] = v4[v9[3]]
		end

		if n(v8, 3, 3) == 1 then
			v9[4] = v4[v9[4]]
		end

		v2[i2] = v9
	end

	for i2 = 1, l() do
		v3[i2 - 1] = u2()
	end

	v5[3] = d()
	return v5
end

local f

f = function(list, p, p2)
	local v2 = list[1]
	local v3 = list[2]
	local v4 = list[3]
	return function(...)
		local v5 = v2
		local v6 = v3
		local v7 = v4
		local v8 = select2("#", ...) - 1
		local v9 = { ... }
		local v10 = {}
		local v11 = {}
		local v12 = 1
		local v13 = {}

		for i2 = 0, v8 do
			if v7 <= i2 then
				v10[i2 - v7] = v9[i2 + 1]
			else
				v11[i2] = v9[i2 + 1]
			end
		end

		local _ = v8 - v7 + 1

		while true do
			local v14 = v5[v12]
			local v15 = v14[1]

			if v15 <= 34 then
				if v15 <= 16 then
					if v15 <= 7 then
						if v15 <= 3 then
							if v15 <= 1 then
								if v15 > 0 then
									v12 = v14[3]
								elseif v11[v14[2]] then
									v12 = v14[3]
								else
									v12 += 1
								end
							elseif v15 > 2 then
								v11[v14[2]] = -v11[v14[3]]
							elseif v11[v14[2]] == v14[4] then
								v12 = v14[3]
							else
								v12 += 1
							end
						elseif v15 <= 5 then
							if v15 > 4 then
								v11[v14[2]] = -v11[v14[3]]
							elseif v11[v14[2]] then
								v12 += 1
							else
								v12 = v14[3]
							end
						elseif v15 > 6 then
							break
						else
							v11[v14[2]] = {}
						end
					elseif v15 <= 11 then
						if v15 <= 9 then
							if v15 == 8 then
								local v16 = v14[2]
								v11[v16](v11[v16 + 1])
							else
								v11[v14[2]] = p[v14[3]]
							end
						elseif v15 == 10 then
							v11[v14[2]] = p2[v14[3]]
						elseif v11[v14[2]] then
							v12 += 1
						else
							v12 = v14[3]
						end
					elseif v15 <= 13 then
						if v15 == 12 then
							if v11[v14[2]] then
								v12 = v14[3]
							else
								v12 += 1
							end
						else
							local v16 = v14[2]
							v11[v16](unpack2(v11, v16 + 1, v14[3]))
						end
					elseif v15 <= 14 then
						v12 = v14[3]
					elseif v15 > 15 then
						v11[v14[2]] = v14[3] ~= 0
						v12 += 1
					else
						local v16 = v6[v14[3]]
						local v17 = {}
						local v19 = v17
						local v20 = setmetatable2({}, {
							__index = function(p3, p4)
								local v21 = v17[p4]
								return v21[1][v21[2]]
							end,
							__newindex = function(p3, p4, p5)
								local v21 = v19[p4]
								v21[1][v21[2]] = p5
							end
						})

						for i2 = 1, v14[4] do
							v12 += 1
							local v21 = v5[v12]

							if v21[1] == 50 then
								v17[i2 - 1] = { v11, v21[3] }
							else
								v17[i2 - 1] = { p, v21[3] }
							end

							v13[#v13 + 1] = v17
						end

						v11[v14[2]] = f(v16, v20, p2)
					end
				elseif v15 <= 25 then
					if v15 <= 20 then
						if v15 <= 18 then
							if v15 == 17 then
								p[v14[3]] = v11[v14[2]]
							else
								local v16 = v14[2]
								local v17 = v11[v16 + 2]
								local v18 = v11[v16] + v17
								v11[v16] = v18

								if v17 > 0 then
									if v18 <= v11[v16 + 1] then
										v12 = v14[3]
										v11[v16 + 3] = v18
									end
								elseif v11[v16 + 1] <= v18 then
									v12 = v14[3]
									v11[v16 + 3] = v18
								end
							end
						elseif v15 > 19 then
							v11[v14[2]] = v14[3] ~= 0
						else
							for i2 = v14[2], v14[3] do
								v11[i2] = nil
							end
						end
					elseif v15 <= 22 then
						if v15 == 21 then
							p[v14[3]] = v11[v14[2]]
							local v16 = v12 + 1
							local v17 = v5[v16]
							v11[v17[2]] = p2[v17[3]]
							local v18 = v16 + 1
							local v19 = v5[v18]
							v11[v19[2]] = v11[v19[3]]
							local v20 = v18 + 1
							local v21 = v5[v20]
							v11[v21[2]] = p[v21[3]]
							local v22 = v20 + 1
							local v23 = v5[v22]
							v11[v23[2]] = v11[v23[3]][v23[4]]
							local v24 = v22 + 1
							local v25 = v5[v24]
							v11[v25[2]] = v11[v25[3]][v25[4]]
							local v26 = v24 + 1
							local v27 = v5[v26]
							v11[v27[2]] = v11[v27[3]][v27[4]]
							local v28 = v26 + 1
							local v29 = v5[v28]

							if v11[v29[2]] then
								v12 = v29[3]
							else
								v12 = v28 + 1
							end
						else
							v11[v14[2]] = v14[3] ~= 0
						end
					elseif v15 <= 23 then
						v11[v14[2]] = p[v14[3]]
						local v16 = v12 + 1
						local v17 = v5[v16]
						local v18 = v17[2]
						local v19 = v11[v17[3]]
						v11[v18 + 1] = v19
						v11[v18] = v19[v17[4]]
						local v20 = v16 + 1
						local v21 = v5[v20]
						v11[v21[2]] = v21[3]
						local v22 = v5[v20 + 1]
						local v23 = v22[2]
						return v11[v23](unpack2(v11, v23 + 1, v22[3]))
					elseif v15 > 24 then
						local v16 = v14[2]
						v11[v16] = v11[v16](v11[v16 + 1])
					else
						return unpack2(v11, v14[2], -1)
					end
				elseif v15 <= 29 then
					if v15 <= 27 then
						if v15 == 26 then
							local v16 = v14[2]
							return v11[v16](unpack2(v11, v16 + 1, v14[3]))
						else
							v11[v14[2]] = p2[v14[3]]
						end
					elseif v15 == 28 then
						if v14[2] < v11[v14[4]] then
							v12 += 1
						else
							v12 = v14[3]
						end
					else
						for i2 = v14[2], v14[3] do
							v11[i2] = nil
						end
					end
				elseif v15 <= 31 then
					if v15 > 30 then
						local v16 = v14[2]
						v11[v16](unpack2(v11, v16 + 1, v14[3]))
					else
						v11[v14[2]] = v11[v14[3]][v14[4]]
					end
				elseif v15 <= 32 then
					v11[v14[2]] = v14[3]
				elseif v15 > 33 then
					return v11[v14[2]]()
				else
					v11[v14[2]] = v14[3]
				end
			elseif v15 <= 51 then
				if v15 <= 42 then
					if v15 <= 38 then
						if v15 <= 36 then
							if v15 == 35 then
								local v16 = v14[2]
								v11[v16] = v11[v16](v11[v16 + 1])
							else
								local v16 = v14[2]
								local v17 = v11[v16 + 2]
								local v18 = v11[v16] + v17
								v11[v16] = v18

								if v17 > 0 then
									if v18 <= v11[v16 + 1] then
										v12 = v14[3]
										v11[v16 + 3] = v18
									end
								elseif v11[v16 + 1] <= v18 then
									v12 = v14[3]
									v11[v16 + 3] = v18
								end
							end
						elseif v15 == 37 then
							local v16 = v14[2]
							local v17 = { v11[v16](v11[v16 + 1]) }
							local count = 0

							for i2 = v16, v14[4] do
								count += 1
								v11[i2] = v17[count]
							end
						elseif v14[2] < v11[v14[4]] then
							v12 += 1
						else
							v12 = v14[3]
						end
					elseif v15 <= 40 then
						if v15 == 39 then
							p2[v14[3]] = v11[v14[2]]
						else
							local v16 = v14[2]
							local v17 = { v11[v16](v11[v16 + 1]) }
							local count = 0

							for i2 = v16, v14[4] do
								count += 1
								v11[i2] = v17[count]
							end
						end
					elseif v15 > 41 then
						v11[v14[2]] = v14[3] ~= 0
						v12 += 1
					else
						v11[v14[2]] = f(v6[v14[3]], nil, p2)
					end
				elseif v15 <= 46 then
					if v15 <= 44 then
						if v15 > 43 then
							v11[v14[2]] = v11[v14[3]][v14[4]]
						else
							v11[v14[2]] = {}
						end
					elseif v15 == 45 then
						v11[v14[2]] = v11[v14[3]] + v14[4]
					else
						return v11[v14[2]]
					end
				elseif v15 <= 48 then
					if v15 > 47 then
						v11[v14[2]] = p[v14[3]]
					else
						return v11[v14[2]]
					end
				elseif v15 <= 49 then
					v11[v14[2]] = v11[v14[3]]
				elseif v15 > 50 then
					local v16 = v14[2]
					return v11[v16](unpack2(v11, v16 + 1, v14[3]))
				else
					v11[v14[2]] = v11[v14[3]]
				end
			elseif v15 <= 60 then
				if v15 <= 55 then
					if v15 <= 53 then
						if v15 == 52 then
							return unpack2(v11, v14[2], -1)
						else
							p[v14[3]] = v11[v14[2]]
						end
					elseif v15 > 54 then
						v11[v14[2]] = v11[v14[3]] + v14[4]
					else
						local v16 = v14[2]
						local v17 = v11[v16]

						if v11[v16 + 2] > 0 then
							if v11[v16 + 1] < v17 then
								v12 = v14[3]
							else
								v11[v16 + 3] = v17
							end
						elseif v17 < v11[v16 + 1] then
							v12 = v14[3]
						else
							v11[v16 + 3] = v17
						end
					end
				elseif v15 <= 57 then
					if v15 == 56 then
						local v16 = v14[2]
						v11[v16](v11[v16 + 1])
					else
						local v16 = v14[2]
						local v17 = v11[v14[3]]
						v11[v16 + 1] = v17
						v11[v16] = v17[v14[4]]
					end
				elseif v15 <= 58 then
					v11[v14[2]] = v11[v14[3]][v14[4]]
					local v16 = v12 + 1
					local v17 = v5[v16]
					v11[v17[2]] = v11[v17[3]][v17[4]]
					local v18 = v16 + 1
					local v19 = v5[v18]
					v11[v19[2]] = v11[v19[3]][v19[4]]
					local v20 = v18 + 1
					local v21 = v5[v20]
					local v22 = v21[2]
					local v23 = v11[v21[3]]
					v11[v22 + 1] = v23
					v11[v22] = v23[v21[4]]
					local v24 = v20 + 1
					local v25 = v5[v24]
					v11[v25[2]] = v25[3]
					local v26 = v24 + 1
					local v27 = v5[v26]
					v11[v27[2]] = p2[v27[3]]
					local v28 = v26 + 1
					local v29 = v5[v28]
					v11[v29[2]] = v11[v29[3]][v29[4]]
					local v30 = v28 + 1
					local v31 = v5[v30]
					v11[v31[2]] = -v11[v31[3]]
					local v32 = v30 + 1
					local v33 = v5[v32]
					local v34 = v33[2]
					v11[v34](unpack2(v11, v34 + 1, v33[3]))
					local v35 = v32 + 1
					local v36 = v5[v35]
					v11[v36[2]] = p2[v36[3]]
					local v37 = v35 + 1
					local v38 = v5[v37]
					v11[v38[2]] = v11[v38[3]][v38[4]]
					local v39 = v37 + 1
					local v40 = v5[v39]
					v11[v40[2]] = v11[v40[3]][v40[4]]
					local v41 = v39 + 1
					local v42 = v5[v41]
					v11[v42[2]] = v11[v42[3]][v42[4]]
					local v43 = v41 + 1
					local v44 = v5[v43]
					local v45 = v44[2]
					local v46 = v11[v44[3]]
					v11[v45 + 1] = v46
					v11[v45] = v46[v44[4]]
					local v47 = v43 + 1
					local v48 = v5[v47]
					v11[v48[2]] = v48[3]
					local v49 = v47 + 1
					local v50 = v5[v49]
					v11[v50[2]] = p2[v50[3]]
					local v51 = v49 + 1
					local v52 = v5[v51]
					v11[v52[2]] = v11[v52[3]][v52[4]]
					local v53 = v51 + 1
					local v54 = v5[v53]
					v11[v54[2]] = -v11[v54[3]]
					v12 = v53 + 1
					local v55 = v5[v12]
					local v56 = v55[2]
					v11[v56](unpack2(v11, v56 + 1, v55[3]))
				elseif v15 > 59 then
					local v16 = v6[v14[3]]
					local v17 = {}
					local v19 = v17
					local v20 = setmetatable2({}, {
						__index = function(p3, p4)
							local v21 = v17[p4]
							return v21[1][v21[2]]
						end,
						__newindex = function(p3, p4, p5)
							local v21 = v19[p4]
							v21[1][v21[2]] = p5
						end
					})

					for i2 = 1, v14[4] do
						v12 += 1
						local v21 = v5[v12]

						if v21[1] == 50 then
							v17[i2 - 1] = { v11, v21[3] }
						else
							v17[i2 - 1] = { p, v21[3] }
						end

						v13[#v13 + 1] = v17
					end

					v11[v14[2]] = f(v16, v20, p2)
				elseif v11[v14[2]] == v14[4] then
					v12 = v14[3]
				else
					v12 += 1
				end
			elseif v15 <= 64 then
				if v15 <= 62 then
					if v15 == 61 then
						break
					else
						return v11[v14[2]]()
					end
				elseif v15 == 63 then
					p[v14[3]] = v11[v14[2]]
					local v16 = v12 + 1
					local v17 = v5[v16]
					v11[v17[2]] = v17[3]
					local v18 = v16 + 1
					local v19 = v5[v18]
					v11[v19[2]] = p2[v19[3]]
					local v20 = v18 + 1
					local v21 = v5[v20]
					v11[v21[2]] = v11[v21[3]][v21[4]]
					local v22 = v20 + 1
					local v23 = v5[v22]
					v11[v23[2]] = v23[3]
					local v24 = v22 + 1
					local v25 = v5[v24]
					v11[v25[2]] = v25[3]
					local v26 = v24 + 1
					local v27 = v5[v26]
					local v28 = v27[2]
					v11[v28] = v11[v28](unpack2(v11, v28 + 1, v27[3]))
					local v29 = v26 + 1
					local v30 = v5[v29]
					v11[v30[2]] = v30[3]
					v12 = v29 + 1
					local v31 = v5[v12]
					local v32 = v31[2]
					local v33 = v11[v32]

					if v11[v32 + 2] > 0 then
						if v11[v32 + 1] < v33 then
							v12 = v31[3]
						else
							v11[v32 + 3] = v33
						end
					elseif v33 < v11[v32 + 1] then
						v12 = v31[3]
					else
						v11[v32 + 3] = v33
					end
				else
					v11[v14[2]] = f(v6[v14[3]], nil, p2)
				end
			elseif v15 <= 66 then
				if v15 == 65 then
					local v16 = v14[2]
					local v17 = v11[v14[3]]
					v11[v16 + 1] = v17
					v11[v16] = v17[v14[4]]
				else
					local v16 = v14[2]
					local v17 = v11[v16]

					if v11[v16 + 2] > 0 then
						if v11[v16 + 1] < v17 then
							v12 = v14[3]
						else
							v11[v16 + 3] = v17
						end
					elseif v17 < v11[v16 + 1] then
						v12 = v14[3]
					else
						v11[v16 + 3] = v17
					end
				end
			elseif v15 <= 67 then
				local v16 = v14[2]
				v11[v16] = v11[v16](unpack2(v11, v16 + 1, v14[3]))
			elseif v15 == 68 then
				p2[v14[3]] = v11[v14[2]]
			else
				local v16 = v14[2]
				v11[v16] = v11[v16](unpack2(v11, v16 + 1, v14[3]))
			end

			v12 += 1
		end
	end
end

return f(u2(), {}, getfenv2())()