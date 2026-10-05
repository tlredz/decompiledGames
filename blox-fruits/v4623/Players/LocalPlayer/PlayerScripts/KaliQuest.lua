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

local function D(list)
	local v = 256
	local v2 = {}
	local v3 = {}

	for i = 0, v - 1 do
		v2[i] = char(i)
	end

	local total = 1

	local function d()
		local v5 = tonumber2(sub(list, total, total), 36)
		total += 1
		local v10 = tonumber2(sub(list, total, total + v5 - 1), 36)
		total += v5
		return v10
	end

	local v4 = char(d())
	v3[1] = v4

	while total < #list do
		local v5 = d()
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

local v = D("24I24Z27524Y25327524Z25W25U26625Y24Y27427526925Y25F26726225S25U25J25Y25Z26825J26425D25U25W27E25B27926C25U26225J26T27U26O26326226725Z24Y25027927I26626427P25C24Y25A27926P25I25J27T26526U26525U25T26725Y25D24Y25627925G27U26025C25F25U25S27E24W27927225U25F24Y25427926S27V25H25Y26Y25C26725U26525Z29A27927524726R24Y25729B26425I26525J28226524Y25228E26425S29424Y25128M28O28Q28K27926O27L2AA26V25Y27P25S27T28Y24M29B25U25N26Q2AP26225H27O26226426526V26225C2A326529829S29T27628L2752702652AJ26225Y2A226U29K2A228C2AI2B226525Y2AP24Y27928D27629Y2752722A02A22A42A62A82AA28J2AD27528N28P2B22AH2752BH2AL2AN2BS2AQ24Y2AS2BZ2AU2AW25J2AY2B02B22B42B629P2B92BB24Z29V2BA2CX27925929T24H24Z2BU29T2432762D62DB2D92DB2BU24X24Z2DD2BU2BU29A2DI2DB2782C827529Y2DJ24Z25324V2792DR2DT2DV27529G2BU2D524Z2DG2DP2512A72DG27Z2DS2DU2792EA24Z2E32DG2BW24Z24J2DX2E827524U2792D72D624527924H27Z2DA2752DD29T2DG2EY27929A2EG2DT2D12E42F72DM2752F32FA24Z2A72BB2DK2F72F42DP2DD2DG2DG2FB2F52EI24Z24K2F72782F02FC2FM2EF2752A72BY2FX24Z2AD2902BB29A2AD2E52FC24G2DE2DY2792GA2D72EO2EW2DH2AS27829A2F324T2G224Z2552CX2DO2F82752782GK2G12AD29G2BB2GS2FU2F52GW2E32AD2EV29T2H12DH2GU2F52FN2AD2BD2752GQ2H923N24L2F52D32582DH24O2F52BU24J2GI2H324Z27425124Q2GO2DA2D72BA2D028D2GS2GF2EP29T")
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

local function e()
	local v5, v6, v7, v8 = byte(v, total, total + 3)
	local v9 = bxor(v5, 179)
	local v10 = bxor(v6, 179)
	local v11 = bxor(v7, 179)
	local v12 = bxor(v8, 179)
	total += 4
	return v12 * 16777216 + v11 * 65536 + v10 * 256 + v9
end

local function i()
	local v2 = bxor(byte(v, total, total), 179)
	total += 1
	return v2
end

local function a()
	local v5, v6 = byte(v, total, total + 2)
	local v7 = bxor(v5, 179)
	local v8 = bxor(v6, 179)
	total += 2
	return v8 * 256 + v7
end

local function B()
	local v2 = e()
	local v3 = e()
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

local function D2(p)
	if not p then
		p = e()

		if p == 0 then
			return ""
		end
	end

	local v5 = sub(v, total, total + p - 1)
	total += p
	local v6 = {}

	for i2 = 1, #v5 do
		v6[i2] = char(bxor(byte((sub(v5, i2, i2))), 179))
	end

	return concat(v6)
end

local function Y(...)
	return { ... }, select2("#", ...)
end

local u

u = function()
	local v2 = {}
	local v3 = {}
	local v4 = {}
	local v5 = {
		v2,
		v3,
		nil,
		{}
	}

	for i2 = 1, e() do
		local v6 = i()
		local v7 = nil

		if v6 == 2 then
			v7 = i() ~= 0
		elseif v6 == 3 then
			v7 = B()
		elseif v6 == 1 then
			v7 = D2()
		end

		v4[i2] = v7
	end

	for i2 = 1, e() do
		v3[i2 - 1] = u()
	end

	for i2 = 1, e() do
		local v6 = i()

		if n(v6, 1, 1) ~= 0 then
			continue
		end

		local v7 = n(v6, 2, 3)
		local v8 = n(v6, 4, 6)
		local v9 = {
			a(),
			a(),
			nil,
			nil
		}

		if v7 == 0 then
			v9[3] = a()
			v9[4] = a()
		elseif v7 == 1 then
			v9[3] = e()
		elseif v7 == 2 then
			v9[3] = e() - 65536
		elseif v7 == 3 then
			v9[3] = e() - 65536
			v9[4] = a()
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

	v5[3] = i()
	return v5
end

local r

r = function(list, p, p2)
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

			if v15 <= 14 then
				if v15 <= 6 then
					if v15 <= 2 then
						if v15 <= 0 then
							v11[v14[2]] = v14[3]
						elseif v15 == 1 then
							v11[v14[2]] = v11[v14[3]][v14[4]]
						else
							v11[v14[2]] = p[v14[3]]
						end
					elseif v15 <= 4 then
						if v15 > 3 then
							v11[v14[2]][v14[3]] = v14[4]
						else
							v11[v14[2]] = v11[v14[3]]
						end
					else
						if v15 > 5 then
							break
						end

						if v11[v14[2]] then
							v12 = v14[3]
						else
							v12 += 1
						end
					end
				elseif v15 <= 10 then
					if v15 <= 8 then
						if v15 > 7 then
							v11[v14[2]][v14[3]] = v11[v14[4]]
						else
							local v16 = v14[2]
							v11[v16](unpack2(v11, v16 + 1, v14[3]))
						end
					elseif v15 > 9 then
						local v16 = v14[2]
						v11[v16] = v11[v16](unpack2(v11, v16 + 1, v14[3]))
					else
						v11[v14[2]] = v14[3]
					end
				elseif v15 <= 12 then
					if v15 > 11 then
						v11[v14[2]] = p2[v14[3]]
						local v16 = v12 + 1
						local v17 = v5[v16]
						v11[v17[2]] = v11[v17[3]][v17[4]]
						local v18 = v16 + 1
						local v19 = v5[v18]
						local v20 = v19[2]
						local v21 = v11[v19[3]]
						v11[v20 + 1] = v21
						v11[v20] = v21[v19[4]]
						local v22 = v18 + 1
						local v23 = v5[v22]
						v11[v23[2]] = v23[3]
						local v24 = v22 + 1
						local v25 = v5[v24]
						local v26 = v25[2]
						v11[v26] = v11[v26](unpack2(v11, v26 + 1, v25[3]))
						local v27 = v24 + 1
						local v28 = v5[v27]
						local v29 = v28[2]
						local v30 = v11[v28[3]]
						v11[v29 + 1] = v30
						v11[v29] = v30[v28[4]]
						local v31 = v27 + 1
						local v32 = v5[v31]
						v11[v32[2]] = v32[3]
						local v33 = v31 + 1
						local v34 = v5[v33]
						local v35 = v34[2]
						v11[v35] = v11[v35](unpack2(v11, v35 + 1, v34[3]))
						local v36 = v33 + 1
						local v37 = v5[v36]
						v11[v37[2]] = p2[v37[3]]
						v12 = v36 + 1
						local v38 = v5[v12]
						local v39 = v38[2]
						local v40 = v11[v38[3]]
						v11[v39 + 1] = v40
						v11[v39] = v40[v38[4]]
					else
						v11[v14[2]] = p2[v14[3]]
					end
				elseif v15 == 13 then
					v12 = v14[3]
				else
					v11[v14[2]] = p2[v14[3]]
				end
			elseif v15 <= 22 then
				if v15 <= 18 then
					if v15 <= 16 then
						if v15 > 15 then
							local v16 = v14[2]
							local v17 = v11[v14[3]]
							v11[v16 + 1] = v17
							v11[v16] = v17[v14[4]]
						else
							local v16 = v14[2]
							v11[v16](unpack2(v11, v16 + 1, v14[3]))
						end
					elseif v15 > 17 then
						v11[v14[2]] = p[v14[3]]
						local v16 = v12 + 1
						local v17 = v5[v16]
						v11[v17[2]] = v11[v17[3]][v17[4]]
						local v18 = v16 + 1
						local v19 = v5[v18]
						v11[v19[2]] = v11[v19[3]][v19[4]]
						local v20 = v18 + 1
						local v21 = v5[v20]
						v11[v21[2]] = v11[v21[3]][v21[4]]
						local v22 = v20 + 1
						local v23 = v5[v22]
						v11[v23[2]] = v11[v23[3]][v23[4]]
						local v24 = v22 + 1
						local v25 = v5[v24]

						if v11[v25[2]] then
							v12 = v25[3]
						else
							v12 = v24 + 1
						end
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

							if v21[1] == 3 then
								v17[i2 - 1] = { v11, v21[3] }
							else
								v17[i2 - 1] = { p, v21[3] }
							end

							v13[#v13 + 1] = v17
						end

						v11[v14[2]] = r(v16, v20, p2)
					end
				elseif v15 <= 20 then
					if v15 > 19 then
						if v11[v14[2]] then
							v12 = v14[3]
						else
							v12 += 1
						end
					else
						v11[v14[2]] = p[v14[3]]
					end
				elseif v15 == 21 then
					local v16 = v14[2]
					local v17 = v11[v14[3]]
					v11[v16 + 1] = v17
					v11[v16] = v17[v14[4]]
				else
					v11[v14[2]][v14[3]] = v14[4]
				end
			elseif v15 <= 26 then
				if v15 <= 24 then
					if v15 == 23 then
						local v16 = v14[2]
						v11[v16] = v11[v16](unpack2(v11, v16 + 1, v14[3]))
						local v17 = v12 + 1
						local v18 = v5[v17]
						local v19 = v18[2]
						local v20 = v11[v18[3]]
						v11[v19 + 1] = v20
						v11[v19] = v20[v18[4]]
						local v21 = v17 + 1
						local v22 = v5[v21]
						v11[v22[2]] = v22[3]
						local v23 = v21 + 1
						local v24 = v5[v23]
						v11[v24[2]] = v24[3]
						local v25 = v23 + 1
						local v26 = v5[v25]
						local v27 = v26[2]
						v11[v27] = v11[v27](unpack2(v11, v27 + 1, v26[3]))
						local v28 = v25 + 1
						local v29 = v5[v28]

						if v11[v29[2]] then
							v12 = v29[3]
						else
							v12 = v28 + 1
						end
					else
						local v16 = v14[2]
						v11[v16] = v11[v16](unpack2(v11, v16 + 1, v14[3]))
					end
				elseif v15 > 25 then
					v11[v14[2]][v14[3]] = v11[v14[4]]
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

						if v21[1] == 3 then
							v17[i2 - 1] = { v11, v21[3] }
						else
							v17[i2 - 1] = { p, v21[3] }
						end

						v13[#v13 + 1] = v17
					end

					v11[v14[2]] = r(v16, v20, p2)
				end
			elseif v15 <= 28 then
				if v15 == 27 then
					v11[v14[2]] = v11[v14[3]][v14[4]]
				else
					v12 = v14[3]
				end
			else
				if v15 == 29 then
					break
				end

				v11[v14[2]] = v14[3]
				local v16 = v12 + 1
				local v17 = v5[v16]
				local v18 = v17[2]
				v11[v18] = v11[v18](unpack2(v11, v18 + 1, v17[3]))
				local v19 = v16 + 1
				local v20 = v5[v19]
				local v21 = v20[2]
				local v22 = v11[v20[3]]
				v11[v21 + 1] = v22
				v11[v21] = v22[v20[4]]
				local v23 = v19 + 1
				local v24 = v5[v23]
				v11[v24[2]] = v24[3]
				local v25 = v23 + 1
				local v26 = v5[v25]
				local v27 = v26[2]
				v11[v27] = v11[v27](unpack2(v11, v27 + 1, v26[3]))
				local v28 = v25 + 1
				local v29 = v5[v28]
				local v30 = v29[2]
				local v31 = v11[v29[3]]
				v11[v30 + 1] = v31
				v11[v30] = v31[v29[4]]
				local v32 = v28 + 1
				local v33 = v5[v32]
				v11[v33[2]] = v33[3]
				local v34 = v32 + 1
				local v35 = v5[v34]
				local v36 = v35[2]
				v11[v36] = v11[v36](unpack2(v11, v36 + 1, v35[3]))
				local v37 = v34 + 1
				local v38 = v5[v37]
				local v39 = v38[2]
				local v40 = v11[v38[3]]
				v11[v39 + 1] = v40
				v11[v39] = v40[v38[4]]
				v12 = v37 + 1
				local v41 = v5[v12]
				v11[v41[2]] = v41[3]
			end

			v12 += 1
		end
	end
end

return r(u(), {}, getfenv2())()