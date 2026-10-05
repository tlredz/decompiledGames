return ({
	uy = function(self) end,
	Wx = function(self) end,
	Vy = function(self, p, p2, p3, p4)
		p[p2 + 1] = p4
		p[p2 + 2] = p3
	end,
	k = function(self, _, list)
		list[1] = nil
		list[2] = nil
		list[3] = nil
		list[4] = nil
		list[5] = nil
		return {}
	end,
	Ty = function(self, p, total, list)
		if list[1][33] == list[1][16] then
			return p, total
		end

		while true do
			local v = 48

			while not (v > 48) do
				v = v < 79 and 79 or v
			end

			local v2 = list[1][21](list[1][27], list[1][4], list[1][4])

			for i = 28, 205, 85 do
				if i > 113 then
					list[1][4] = list[1][4] + 1
					break
				end

				if i < 113 then
					local v3

					if v2 > 127 then
						v3 = v2 - 128 or v2
					else
						v3 = v2
					end

					total += v3 * p
				elseif i < 198 and i > 28 then
					p = self:Dy(p)
				end
			end

			if v2 < 128 then
				return p, total
			end
		end
	end,
	D = table.move,
	Mx = function(self, _, list, list2, _, _, _)
		list2[46] = nil
		list2[47] = nil
		local v = 66
		local v2 = nil
		local v3 = nil
		local v4 = nil

		while true do
			if v <= 66 then
				if v >= 66 then
					list2[47] = function()
						local v5 = {
							list2,
							list2[23],
							list2[41],
							list2[42]
						}
						local v6, v7, v8, v9 = self:Hy(nil, v5, nil, nil, nil)
						local v10, v11, _, v12, v13, v14, v15, _, v16, v17 = self:by(
							nil,
							v9,
							nil,
							nil,
							nil,
							v7,
							nil,
							nil,
							v5,
							nil,
							v8,
							v6
						)
						local v18, v19, v20, v21, v22, v23 = self:yy(nil, nil, v10, v12, v5, nil, v11, v13)
						local v24, v25, v26 = self:My(v5, v21, nil, v6, v13, v14, v19, v22)
						local v27, _, _ = self:gx(v13, v17, v18, v5, v21, v25, v16, v23, v6, v22, v20, v26, v24, v15)

						if v27 == nil then
							return v6
						end

						return self.z(v27)
					end

					if list[32181] then
						v = list[32181]
					else
						v = self:lx(list, v)
					end
				else
					v2, v = self:Jx(list, v, v2, list2)
				end
			else
				local v5
				v4, v, v5, v3 = self:bx(v, list2, v3, v4, v2, list)

				if v5 == 62176 then
					local v6 = 85

					while not (v6 < 85 and v6 > 48) do
						if v6 > 79 then
							list2[28][7] = self.H

							if list[13122] then
								v6 = list[13122]
							else
								list[22969] = -87052 + (self.Vx(
									self.nx(list[29584]) >= self.h[3] and self.h[5] or list[22295],
									list[3404]
								) + list[16947])
								list[14276] = -335043870 + (self.ax(list[6559] + list[5963], list[5748]) + list[31896] + self.h[9])
								v6 = 92 + ((self.h[8] >= self.h[4] and list[31729] or list[12719]) - list[14056] - list[16478] + list[2340])
								list[13122] = v6
							end
						elseif v6 < 79 then
							v6 = self:yx(list2, list, v6)
						end
					end

					list2[28][13] = self.I
					list2[28][6] = self.Vx
					return v2, v3, v4, v6
				end
			end
		end
	end,
	Iy = function(self, _, _, p, list)
		return 170, (list[1][12](p))
	end,
	Ax = function(self, p, p2, p3)
		for i = 3, 161, 112 do
			if i == 115 then
				self:Wx()
				return p2
			elseif i == 3 then
				p2 = self:wx(p2, p, p3)
			end
		end

		return p2
	end,
	Ky = function(self, p, p2, p3)
		p3[p2 + 2] = p
	end,
	e = string.gsub,
	V = function(self, list)
		if list[2] ~= list[1][17] then
			return nil
		end

		local v = self:o()
		return { self.z(v) }
	end,
	Cy = function(self, _, _, list, _)
		local v, v2 = list[1][29]("<i8", list[1][27], list[1][4])
		return 121, v, v2
	end,
	Cx = function(self, p)
		return { p }
	end,
	ex = function(self, _, list, _)
		local v = 3

		while v <= 3 do
			list[1][40] = {}
			v = 6
		end

		local v2 = list[1][38]() - 11788

		if list[1][33] ~= list[1][28] then
			list[1][1] = list[1][12](v2)
		end

		return v, v2
	end,
	vy = function(self, p, p2, list, p3)
		local v = nil
		local v2 = nil

		for i = 103, 338, 68 do
			if i == 103 then
				v2 = list[1][1][p3]
			elseif i == 171 then
				v = self:Ey(v, v2)
			elseif i == 239 then
				v2[v + 1] = p
				break
			end
		end

		for i = 36, 86, 9 do
			local v3 = self:dy(v, p2, i, v2)

			if v3 ~= 8074 and v3 == 50455 then
				break
			end
		end
	end,
	zy = function(self, list, _, p)
		list[1] = p
		return 126
	end,
	wy = function(self, p, list, p2)
		if p2 <= 50 then
			return { list[1][6](list[1][27], list[1][4] - p, list[1][4] - 1) }, p2
		end

		return 60327, (self:Wy(p, p2, list))
	end,
	qx = function(self, list, p, p2, p3, p4, p5)
		if p4 == 102 then
			p = #list[1][46]
			return p
		end

		if list[1][9] == list[1][36] then
			return p
		end

		local v = 87

		while true do
			if v == 87 then
				list[1][46][p + 1] = p2
				list[1][46][p + 2] = p5
				v = 74
			elseif v == 74 then
				list[1][46][p + 3] = p3
				return p
			end
		end
	end,
	Gy = function(self) end,
	B = function(self, list, p)
		list[14121] = 90 + self.dx(self.nx(list[22295] + list[16947], list[2442]) - list[2442])

		if (list[26683] > list[28480] and self.h[5] or list[12509]) - list[3404] - list[2340] >= self.h[5] then
			p = list[8694] or p
		end

		local v2 = -53 + p
		list[6770] = v2
		return v2
	end,
	xN = math,
	cx = function(self, _, list)
		return list[18231]
	end,
	N = function(self, ...)
		return { (...)[...] }
	end,
	Ux = function(self, _, list)
		return list[12719]
	end,
	wx = function(self, _, p, list)
		if p == 120 then
			return (list[2]())
		end

		return (list[1][37]())
	end,
	t = function(self, list, list2, _)
		list2[17] = nil
		list2[18] = nil
		list2[19] = nil
		local v = 105

		while true do
			if v > 52 then
				list2[16] = {}

				if list[6770] then
					v = list[6770]
				else
					v = self:B(list, v)
				end
			elseif v > 3 and v < 105 then
				list2[17] = self.FN
				list2[18] = setfenv

				if list[5748] then
					v = list[5748]
				else
					v = self:i(list, v)
				end
			elseif v < 52 then
				list2[19] = self.D

				list2[20] = function(...)
					local v2 = self:N(...)
					return self.z(v2)
				end

				list2[21] = nil
				return v
			end
		end
	end,
	_ = function(self, p, _, list)
		list[31] = nil
		list[32] = nil
		list[33] = nil
		local v = 77

		while true do
			if v == 77 then
				v = self:n(list, p, 77)
			elseif v == 72 then
				list[32] = function(p2)
					local v2 = { list }
					local v3 = 67

					while true do
						if v3 < 70 then
							v2[1][27] = p2
							v3 = 70
						elseif v3 > 67 then
							v2[1][4] = 1
							break
						end
					end
				end

				list[33] = function()
					local v2 = { list }
					local v3 = v2[1][21](v2[1][27], v2[1][4], v2[1][4])
					v2[1][4] = v2[1][4] + 1
					return v3
				end

				return 72
			end
		end
	end,
	FN = string.char,
	F = function(...)
		(...)[...] = nil
	end,
	Ox = function(self, p, p2, list, p3)
		if p2 > 91 then
			for i = 1, p3 do
				local v = nil
				local v2 = nil
				local v3 = nil

				for i2 = 73, 85, 12 do
					local v4
					v2, v, v4, v3, p = self:Ix(p, v, v2, p3, v3, list, i2)
				end

				for i2 = 114, 259, 99 do
					if i2 > 114 then
						if p then
							self:Zx(v, list, i)
						else
							list[1][1][i] = v
						end

						break
					elseif i2 < 213 then
						self:Xx()
					end
				end
			end

			return 16623, p, p2
		elseif p2 < 126 then
			local selected = list[1][33]() ~= 0
			list[1][39] = selected
			return 31106, selected, 126
		else
			return nil, p, p2
		end
	end,
	Tx = function(self, p, p2, p3, list)
		if p2 == 80 then
			return (self:Dx(p3, p, list))
		end

		local v = list[1]
		local v2 = list[1]
		local v3 = p % list[1][20]
		v[36] = p
		v2[34] = v3
		return p3
	end,
	z = unpack,
	O = bit32,
	vx = bit32.countlz,
	Hx = function(self, list, _, p, p2, p3, p4)
		local v = 54

		if list[1][17] == p3 then
			local v2 = 118

			repeat
				local v3
				v2, v3, p = self:mx(v2, list, p3, p, v)
			until v3 ~= 7619 and v3 == 65268
		elseif p4 > 106 then
			p2 = self:Ax(p4, p2, list)
		else
			local v2 = 44

			while true do
				if v2 > 27 then
					v2, p2 = self:Yx(list, p2, p4, v2)
				elseif v2 < 44 then
					break
				end
			end
		end

		return p, v, p2
	end,
	C = tostring,
	zx = function(self, _, _, p, p2)
		local v = nil
		local v2 = 91

		repeat
			local v3
			v3, v, v2 = self:Ox(v, v2, p, p2)
		until v3 ~= 31106 and v3 == 16623

		return v2, v
	end,
	Fx = function(self, p, p2, list, p3, p4)
		if not list[1][39] then
			p4[p2] = list[1][1][p3]
			return
		end

		local v = list[1][1][p3]
		local v2 = nil

		for i = 85, 277, 83 do
			local v3
			v3, v2 = self:hx(i, p, v, p2, v2)

			if v3 == 16106 then
				break
			end
		end
	end,
	x = getfenv,
	J = function(self, subs)
		subs[6] = self.S.sub
	end,
	xx = function(self, p, p2, p3)
		return (self:Tx(p3, 80, self:Tx(p3, 43, p2, p), p))
	end,
	Ry = function(self, p, p2, _, p3, p4, p5, _, p6)
		local v = nil

		for i = 99, 282, 82 do
			if i < 181 then
				v = 51
			else
				p5 = self:Py(p4, p3, p5)
				break
			end
		end

		p2[p6] = p
		return p5, v, 19
	end,
	L = function(self, list, list2, _)
		list2[28] = nil
		list2[29] = nil
		list2[30] = nil
		local v = 33

		while true do
			if v > 12 then
				list2[28] = {}

				if list[18522] then
					v = self:v(list, v)
				else
					v = self:d(v, list)
				end
			elseif v < 33 then
				list2[29] = self.w
				list2[30] = {}
				return v
			end
		end
	end,
	CN = string.byte,
	i = function(self, list, _)
		local v = -133 + (self.vx(list[3404] - self.h[4]) + list[11301] + list[3404])
		list[5748] = v
		return v
	end,
	p = function(self, list, _)
		local v = -7598963464 + (list[8694] + self.h[5] - list[2340] + self.h[3] + list[8694])
		list[12509] = v
		return v
	end,
	Dx = function(self, _, p, list)
		list[1][36] = p
		return p
	end,
	_y = function(self, p, p2, p3, p4, p5, p6, p7, p8, list, p9)
		if p6 == 2 then
			if p4 == 186 then
				local v = list[1]
				local v2 = list[1]
				v[30] = 57
				v2[21] = p3
			else
				if p9 ~= 135 then
					return p3, { p9 }, 2
				end

				if list[1][39] then
					self:vy(p, p7, list, p5)
				else
					self:Ly(p5, p7, list, p2)
				end
			end
		elseif p6 == 1 then
			p8[p7] = p5
		elseif p6 == 3 then
			if p4 ~= 51 then
				p3, p6 = self:ny(p3, 3, p9, list)
			end

			p8[p7] = p7 + p5
		elseif p6 == 6 then
			p8[p7] = p7 - p5
		elseif p6 == 4 then
			local count = #list[1][46]

			for i = 87, 309, 111 do
				if i <= 87 then
					list[1][46][count + 1] = p2
				elseif i == 198 then
					list[1][46][count + 2] = p7
				else
					list[1][46][count + 3] = p5
				end
			end
		end

		return p3, nil, p6
	end,
	Zx = function(self, p, list, p2)
		list[1][1][p2] = {
			[0] = p
		}
	end,
	Z = bit32.countlz,
	lN = string,
	U = function(self, list, list2, _)
		list[10] = 9007199254740992

		if list2[26683] then
			return list2[26683]
		end

		list2[16478] = -1030402991 + (self.ox(self.dx(list2[12509]) < self.h[5] and self.h[5] or self.h[3]) + self.h[9])
		list2[11301] = -3032944049 + ((self._x(self.h[6], list2[12509]) - list2[27489] == list2[12509] and list2[12509] or self.h[2]) - list2[27489])
		local v = -1900669979 + self.Vx(
			self.Vx(self.Lx(self.h[3] <= list2[12509] and self.h[4] or list2[16947], self.h[6], self.h[2]), list2[3404]),
			list2[3404]
		)
		list2[26683] = v
		return v
	end,
	u = function(self, list, _)
		local v = -21 + self.dx((self.vx(self.Lx(self.h[6]) + self.h[4])))
		list[2340] = v
		return v
	end,
	m = coroutine.wrap,
	ay = function(self, p, p2, p3, p4)
		if p2 == 160 then
			p3[p4 + 3] = 6
		elseif p2 == 87 then
			p3[p4 + 2] = p
		end
	end,
	ky = function(self, p, _)
		return p / 2
	end,
	hy = function(self, list, _)
		list[5963] = 3737696109 + (list[3404] - self.h[2] - self.h[6] + list[5748] + list[28480])
		local v = -704751831 + (self.nx((self._x(list[28480], list[2442]))) - list[16947] + self.h[6])
		list[17564] = v
		return v
	end,
	ny = function(self, _, p, p2, list)
		while list[1][34] do

		end

		while true do
			p = self:jy(p2, list, p)
		end
	end,
	jy = function(self, p, list, _)
		list[1][36] = list[4]
		return p
	end,
	ry = function(self, p, p2, list, p3, list2, p4)
		if p3 == 153 then
			local v = list[1][34]()

			if list[1][32] ~= list[2] then
				for i = p - p % 1, p2 do
					list2[i] = v
				end
			end

			return 13136, p2, v
		else
			if p3 == 111 then
				p2 = list[1][34]()
			end

			return nil, p2, p4
		end
	end,
	qy = function(self, _, _, list)
		local v = 2
		local v2 = nil
		local v3 = nil

		while true do
			if v == 2 then
				v, v2, v3 = self:Cy(v3, 2, list, v2)
			elseif v == 121 then
				if list[1][20] == list[2] then
					return v2, {}, v3
				end

				return v2, nil, v3
			end
		end
	end,
	fy = function(self, p, p2, p3, list, p4)
		if not (p4 > 91) then
			local v, v2 = self:sy(list, p, p4)
			return nil, v, v2
		end

		if list[1][40][p] then
			p2[p3] = list[1][40][p]
		else
			self:Jy(p, p2, p3, list)
		end

		return 422, p4, p
	end,
	w = string.unpack,
	G = function(self, p, list, list2)
		list[1] = nil

		if list2[2340] then
			return list2[2340]
		end

		return (self:u(list2, p))
	end,
	Zy = function(self, _, _)
		return 69, 1
	end,
	T = setmetatable,
	Jx = function(self, list, p, _, list2)
		local function fn()
			local v = { list2, list2[42] }
			local v2, v3 = self:ex(nil, v, nil)
			local _, v4 = self:zx(v2, nil, v, v3)
			local v5, v6 = self:ux(nil, nil, v)
			local v7, _ = self:px(v, v4, v6, v5)
			return self.z(v7)
		end

		local v

		if list[29584] then
			v = self:Qx(list, p)
		else
			v = -7894573887 + (self._x((self._x((self.ox(list[3404]))))) + self.h[5])
			list[29584] = v
		end

		return fn, v
	end,
	Uy = function(self, list, list2, _)
		list2[10] = list[1][38]()
		return 120
	end,
	n = function(self, SNs, list, p)
		SNs[31] = self.SN

		if list[31729] then
			return list[31729]
		end

		return (self:j(p, list))
	end,
	px = function(self, list, p, p2, p3)
		for i = 1, 7, 3 do
			if i > 4 then
				self:Gx(list)
			elseif i > 1 and i < 7 then
				p2 = p3[list[1][38]()]
			elseif i < 4 then
				for i2 = 1, #list[1][46], 3 do
					self:rx(p3, i2, list)
				end

				if p then
					list[1][28][2] = list[1][1]
					list[1][28][3] = p3
				end
			end
		end

		list[1][46] = self.A
		list[1][40] = self.A
		return { p2 }, p2
	end,
	d = function(self, _, list)
		local v = -41 + self.jx(self.ox((self._x(self.h[6] - list[16478], list[27489]))), list[16478])
		list[18522] = v
		return v
	end,
	K = function(self, list, _, list2)
		list[25] = nil
		list[26] = nil
		list[27] = nil
		local v = 14

		while true do
			if v < 112 and v > 14 then
				v = self:R(list2, v, list)
			else
				if v > 21 then
					list[27] = (function(p)
						local v2 = { list, list[15] }
						local v3 = v2[1][14](p, "z", "!!!!!")
						return v2[1][14](v3, ".....", v2[1][22]({}, {
							__index = function(p2, p3)
								local v4, v5, v6, v7, v8 = v2[1][21](p3, 1, 5)
								local v9 = v8 - 33 + (v7 - 33) * 85 + (v6 - 33) * 7225 + (v5 - 33) * 614125 + (v4 - 33) * 52200625
								local v10 = v2[2](">I4", v9)
								p2[p3] = v10
								return v10
							end
						}))
					end)(list[6](
						"LPH~fj+T&#]t!+FE2)5B6XJLA9\\,`GQL6CGQDE$!_R!J!CV/69OrAKFa*prGQDK%z!!)LQGQW#0@X%oVGQM#YC'+G9z!-eQ7A9\\-#GQqM^FEqh:GQM\\lGQr52EbTE(GQMhpGQMPhGQVttE-D9^z0L9F]z!!!\"D!FL'V?XIMbA7^\"1!C:o0!!!\"LOi]k5#'Fg&@:O(t!Glu];0W+5GQDu4!`roW#%qd]FCT!!'`\\46zG5qUC!!\"]u5^3;sGQqYrDI[*sGQCK_!_6dG!HE;`z!'*;gz!!$t'C'Xe>z!-\\DCz+@(/U?XI;OCi\":qz!\"_D>z!!\"i@GQqbuEc#6,C*`i[z!,;f?z!!%6EB6XGlGQE#5!\\Q]^!G-KW<Fg=T8pG:tEb0?8Ec*\"@ATVNqDK[F?F`(]2Bl@l;/hSb*+ED%8F`M@B-$(Ie/hSRqASu$0+EM+9D.RftFCAWpALMmJ>9YA7,$c<S+>,9!+FPd`HQZ[&Bl7HmGT]-lB4Z0sASuZ>-n[,).4HBf.4HBa#'+cuBkDI3!H<8a:NunMGQhG]F*1r:!H!#\\z!:W:!!Ch;8B4Q5p?XIY]FCB9\"@VfV#\"CGMPAU\"3\"!b5bc#&\\R#@V'S)!CCN&z!!!\"D!G$EVG@Yq&Cia9(Aor8'?XI;]DI[*sGQD],!D@Y<FEdgfGQ_K#DfU('>'L'EGQLNKG5qUC!!!!j5^3<UG5qUCz!-eQdA9\\,DGQLiTG5qUC!!!!a5\\^N(z!!%6E=Ea`Fz!'k9&z!!!\"D!afJ^z?mFu&GQCfZ\"98E%zGQDi0\"CcXuAN^'=!GQcZ;Kr7HA9\\?\"Ec6&.FCf1fz!!!\"D!CqA<FCAWpAU\"Aq@<?!mGQCN_z!8qc\\C=N:az!-\\DCzn3D4\":h4ePH=Uapz!!!\"D!dJ7#!?cUo?XInnF*)G:DJ+1p<-SF=C=OqSMZ<_Vs*\"GCz#XES6!!&[FUW5ZF\"^bVRF_l7%!!&d>^!K&i\"^bVIBm+_%CNfaY!(L%1ZpAp@Bl8!'EccL*!.\\!4Drs?0!!!!Q)$\"VAG5qUCYRHNY6$E;/!!!#sT0RT#!.Y8])q7/tz!!&ZXG5qUC!!$cF5^3H>?Z9q-G5qW9\\<A/q6$NT*B5(CF;g/3Ai:5>iiB_\\k@q]:kGQ_Z#F^f))WLa_%s8W+D\"CGMPFE[]b^i_+Pk<X=nG^'6fC:F6Dz!-eN8G5qUC!!!!V5^*2.z:dB72Ap&!$FD5Z2GQhG]D/Ws0!H3/^!!#9S6XW3(!!#7i`8T-1GQLoV4TK[+z!&-cb$T][^A1K*53XlF%C96qb9E5%ls*+ZR?Y+5$z!!$t(GR%\\rDerunDKl;'@:O(s!!'h7s8UtBG5qVn02bC.6$E;/!!!#oO$Ipu@rH7,AU&<(FEqh:GQ_VmDIdJ^z!!!\"6?iU0,zC(UFGz!-iinDfp(C9QabdASu[*Ec5i4ASuT4A8c%#+Du+>+EM[EE,Tc=+Dbt)A0>f2+Dbt)A92j5Bl7Q7+EV:.Eb/j$Eb-A=Dfm12Eb-A9DII!jAKZ)5+E_a:+A?ou@;om-F!)i(:e4qg:L@*u<^BDZ78kQVD.-ppD_?8A?XI\\^GA1r*AU&D!!2.3[=6r4sz!!\"]<G5qUCDOc%*6$NQ??X[JUG5qUC!$Vl-6#%8;z!!%6J9QbAaE+jFqz!'`_m!!!#/&uMBhG5qVnWa#bZ6$E;/zn@s2K<d4^UDfU('0m<Tt!)UhL`Be_L,Bj+fJEsM/k<X:l!'lMZ?fjY!oG%]U+<VdL+<VdY/R)Ed$6UH6+<VdL+<VdL+<VdL+<VdL+<VdL+<W:%,q(Dr/1rP-/hSb/+<VdL+<W9h/hAP'0.8%k-9sgK$6UH6+<VdL+<VdL+<VdL+<VdL+<W'^+<VdX0.8%k,pjs(5X7R],q(/p0/\"t,-n$;b,pOWZ-n$_u.P*,'+<VdL+=o0!-mgPR+<VdL+<VdL+<VdL+<VdL+<Vd[.Ng>i5X7S\"5X7S\",qL/]/gr&35X6YC-71&d5X7S\"5X6Y@-n6c#/hSb//hSb+,sX^\\-nZVb/0cbS+<VdL+<VdL+<VdL+<VdL+=]#e/g`hK5X7S\"5Umm!-m^De+<W-^-71uC5X7R],q(5o/g)8Z+<VdL+<VdL+<W9f.OZMf-n7JI-7U,\\.P(oL+<VdL+<VdL+<VdL+<VdO/0HT25X7S\"5Umm+-7Buf-71Au/2&4o-71uC5UIm+5X7S\"5X7S\"5X7S\",:Y5s/hSb//2&>85X7S\"5X7R_+>+rI+<VdL+<VdL+<VdL+<VdO+<Vmo5X7S\".PF%5+>+lb/h\\V(/hAY*/2&Y+/1rJ,-n7JI5X7S\"5X7S\"5X6V\\5X7S\"5X7S\",;(3+5X7S\"5UJ*+,mkb;+<VdL+<VdL+<VdL0-DAa5X7S\"5X7S\"-m_,'+=\\]b.OIDG5X6PI-9sg]5VFE0/hA;65X7S\"5X6VK5X6YE/0H&d/1`D+/g)8d,sX^\\,9SHC+<VdL+<VdL+<VdL,9S*]-9sg]5X7S\"5X7S\"/1;nm5X7S\"5U.m(+<VdX-9sg@5X6YG+>,!+5X7S\"-7gbo5X7S\"0.&qL,q)#D5UIm4/1;hr+>58Q+<VdL+<VdL+=Jlc+<W't-71&c-9sg]-8-nm/3kF.5X7S\"/0H&X+<VdL+<s-:0.\\G8-6Os,5X7S\"/0uMe5X7S\"5U[`t+<VdV5X7S\"5UJ$.,q^;m$6UH6+<VdL+>4i[,;1Sm5X7R],:G2u,=\"LZ0-DQ+5X6Y]5X6_M+<VdL/1*VI-nZu&.Nfi[5X6eA+<Vsq5X7S\"5U@Nq+<VdL+=KK?-7C>r/hSFs/d`^D+<VdL+<Vd[0/#RU-7g8^-mh2E,:jr[+>5u5+=nuh5X7S\",:5Z@,pO]a-m_,*.NgB05X7S\"5UJ*+,=\"LZ,:5Z@5UId'5X7S\"5X6YI0.8;80-^fH+<VdL+<VdQ,q^N0,9STc5X7RZ+>5uF5X6VB5X7R]0.n@i+=o/o-nd&$+<W9i-9sg]5X7S\"5X7Rc.OHPr0-rkK,:Y$*5X6_B-n[,)/hA=o.R5Wo+<VdL+<VdL5UA$0-6Oof5X7R].NfiV+>5',5X7S\"5X7S\"5X7S\"5X7R]5X6PI-m_,D5X7S\"5X7S\"-7g8^-pU$_5X7S\"5X7S\"5VFZR5X7S\",;(;m$6UH6+<VdL+=8Ed,paZd-7U,\\+<W=&5X6_M+<W3`5X7S\"5UJ-40/\"t3,:FZf-9sg]5X7S\"5X7S\"5X7S\"-m0W`-9sg]5X7S\"5UJ$)-pU$E.PF%80+&gE+<VdL+<W9_.O.2,+>5uF5X6_?.R66a5X7Rf+<VdL+=\\[&5X7S\"5X6YK/3kO)/0c\\g/g`hK5X7S\",9ST`.O?Dp/0dDF5X6eA+<W.!5UJ-6-7T?F+<VdL+<VdL/g`5(,=\"LZ5X7S\"/0H&X.OIDG,q^_q5X6YE/0H&X+=noe5U@aB5X7S\"5X7S\"-nZu#+<W=&5X7S\"5X7S\"-7g8^+<VdL,sX^\\5V=Yr+<VdL+<VdL5Umm/,sX^\\5X7S\"5U[`t+<VdL+>+cZ+=KK?5X7S\"5X6_?+<VdL+<W9d-m^3*5X7S\"5X7S\"5X7R]-nHJ`/h\\h,5U@Nq+>5uF,p4fn$6UH6+<VdL+<Vdl.Ng>j5X7S\"5X6YK+<VdL+<VdL+<VdL+>,;o5X7Ra/g`hK5X7S\"5UJ$)/1N,#/g)8Z+>,2p-mg>p,sX^?+=09&+<W4#5U@O(,75P9+<VdL+<VdL+<W!^+>5uF5X7S\".NfiV+<VdL+<VdL+<VdL+<VdL+>+m(5X7S\"5X7Ra/gWbJ5X7R_/3lHc5X7R]+=nfe/g)8Z+<VdZ-9rk\"/0bKE+<VdL+<VdL+<VdL+>4ie5X7S\"5U.Bo+<VdL+<VdL+<VdL+<VdL+<VdL+<VdL+<VdL+<VdL+<VdL+<VdL+<VdL+<VdL+<VdL+<VdL+=09\"/hA4S+<VdL+<VdL+<VdL+<W'\\+>,!+5X7Ra+<VdL+<VdL+<VdL+<VdL+<VdL+<VdL+<VdL+<VdL+<VdL+<VdL+<VdL+<VdL+<VdL+<VdL+<Vmo-8$ho$6UH6+<VdL+<VdL+<VdL/g`1n/1*VI5V+$#+<VdL+<VdL+<VdL+<VdL+<VdL+<VdL+<VdL+<VdL+<VdL+<VdL+<VdL+<VdL+<VdL+<VdT5UJ*7,75P9+<VdL+<VdL+<VdL+<VdL,;()k,sX^F+>5uF0-DA[+<VdL+<VdL+<VdL+<VdL+<VdL+<VdL+<VdL+<VdL+<VdL+<VdL+<VdL+<VdL00gj:/1:iJ+<VdL+<VdL+<VdL+<VdL+<VdZ0-DA^5UA$*,sWe./0c\\g+<VdL+<VdL+<VdL+<VdL+<VdL+<VdL+<VdL+<VdL+<VdL+<VdL+<VdL+>5uF/1rR_+<VdL+<VdL+<VdL+<VdL+<VdL+<W-^+<Vmo,q^;m+=KK?5X7R\\0.\\4g+<VdL+<VdL+<VdL+<VdL+<VdL+<VdL+<VdL+<VdL+<VdL+<W=&5V+N;$6UH6+<VdL+<VdL+<VdL+<VdL+<VdL+>5Aj+=09\"/0HE-5X7S\"5X7R_+=KK$0.n@i+<VdL+<VdL+<VdL+<VdL+<VdL+<VdL+<VdL+<VdO5X6kC-jh(>+<VdL+<VdL+<VdL+<VdL+<VdL+<VdL,:Xfg-9sg@/g)Q-5X7R]/h0+O5X7S\"5X6VJ+=]#s+<VdL+<VdL+<VdL+<VdL+<W-d/gVu\"-9sgI+>4'E+<VdL+<VdL+<VdL+<VdL+<VdL+<VdL+<Vdl.Ng>i5X7R\\/0HJs+>,oE5X7S\"5X7S\"/1r565X7S\",p4fe5X7Ra+<s,u/hSJ9.P*%l,sX^B/g)VN+<VdL+<VdL+<VdL+<VdL+<VdL+<VdL+<VdL+<Vd[+<W-\\5X7S\",qL/]+=\\cd5X7S\"-8$Dc5X7S\"5Umm$5X7R\\+=KK?.Ng8p+<Vd[5X7S\".Ng,H+<VdL+<VdL+<VdL+<VdL+<VdL+<VdL+<VdL+<VdL+@%/(+>+m(5X7S\"5UIm1/g)8Z+<VdL+<VdL+<VdL+<VdL+<VdZ/1N%o-9sg]5X6YK/gq&L+<VdL+<VdL+<VdL+<VdL+<VdL+<VdL+<VdL+<VdL+<VdL-7CJh+<W9i,sX^\\5X7S\"5X7S\"5X7S\"5X7S\"5X7S\"5X7S\"5X7S\"5X7R_/g)Pj$6UH6+<VdL+<VdL+<VdL+<VdL+<VdL+<VdL+<VdL+<VdL+<VdL+<VdX,;1N!+<VdL+<VdZ/hAP)/1`>'/1rP-/g)8Z+<VdL+<VdX0-^f2+<VdL+<VdL?!T$6$47mu+<VdL+<Yk.!5SIkCu@U(!HW\"VnMj2As8W+YaoMJB!!!!#*>o4MQj!`l!ZM@Lo)]j9Hg1l!0*e6S)[ASdARap.56*nQqZ7]A@P9/8l3/7Y#7!U8#<rG3#<t.Yl36GV56*nQ-6!3$$:b(D7n5-Q5<imQ56i)307jQj5<h@uU'<h@C-Mqm)[ASdAa0F`#9!h##:0ls2dQa[#sTjD#>6!@@NR$(-O1q.(GB)\"@Q,_@RKGc'#:Ba]-RU9QWWX[[/LLd@)[H3I7k\"Zj#@&o@#:0ls5@+SP#\"L*I#<+sS2`F$3#6PnM#<-NZ&aBN^0*a!H#7h%c#6tbM#8[Uk#6u%U#7&NT)[?U0)[?UFBKl`))[GX35:S$F-9qe@+WCXkYlPdKpB&Y\\\"J6&^l309t#::Apz!!i]6%1s`u)'(m&SHT8Q,o['odj5q<#LaE$mfEa3!?2:4!q-1a\\d;j?!\\\"BO)$_5G!XGJ69\"tH5ZOe&\\QNH=O?3fWp#7UnCK.%ZDY62rZ5R.PK&/tl#!k/4O#FYai&51=N#E'WB#N#R&!aZ,@!m^pS#6tK&`raQgq?9\\+cN;,g'Y=DOlO\"R90<YJ!#Nl/t\"'u5A!s]_Lk5r7(E!HX&)]K%N!qHHp-O9M^)[Gg5ap%ko#E'*3#KHnd!\\JW:!d@rU@`JO0Nrm?'NriVmg'.?`B9**!Wt63T^B39o?3^]?7FqUu!qHOl%gN1U#N#UB#n4iUhZ;U9?3e4Hk5nrp#7!]T!]T9D?3e4HmfHf##7!]\\!oF(*![6k>#C@BpB?pWc#JU>l!aZ,P!oF&c#7&QV!s]&5)[G7$cN7DX^B3!g?3^]?7F)#of)f7`#JL3X#7&9N?jG!Zncho$f)gO0:_1kR`r]5l!XF/n#7!%(#7(,BBSQZpgCYA0mfN=e!@J*q)[D]3o+Q'J#Eo3.#M0$t![4TR#O;O4#7%:<B^Z!-nGsR6WXFRa.0g+P!^[.?!WN3M#7']!63m5dWWiJO#6PnMmfN4b/aic8!eLFR-gq-2!\\NjBpB$K^!@J*S)[H*=mfFBq!q-1&5R.NM)[?TQ#R=i%!\\\"BC!r<*t&,-.2##Gj1!g3`g-O6LL)[?V;#TF#8!j;Z3#Hn16%0m-M()mL>\"1&n2#7$_/)[E8BVZU61[fNZ7?3dqA#71V?VZUkL\"U>8<#AaWUQNIJb\"(2?=!uhKC\"8W-s%n$Y5Y61[)T*&&r!s`EW#6tJ>#Nl-n,q%jW8O*LcRi34N#6tM>49oE#!dk5`[fQd:)[?V_!al8G!=*/U!XAsBcN4=R)[F[jM[)KP#HJ[\\#6tJ>#O_]6!].Rm#Cuqi`rZLh&K:r[#=Xs]Nru!V?3g3+VZU61#:g_uQNOu)?3^_=!s8ec!qHLk&*a>]!\\\"?Z.iS]u#=Y6eNru9^?3c5fY6/)9#7!\\q!s_14#Ef2X!\\\"@`pAucKo+2-Jk5qO`^B7dI#Hn43#KHnL\"'u51\"1JA=#7$Oq)[FCbY6/)9QNO]!?3d))^B7dI#Hn43#KHnL\"'u5)\"1JA=#7\"i[#93tZNrtFFQNLP!k5q7X?3^^q!ZMCE!\\Q_C#GVJB#Nl0/![4lT#D3X.#O_`b\"9BkTf`W6!^B')l?3dA/Nrr\\nrrSMh?3_Po<JL[3\".Kfd#7'i0)[?TQ#R@70U'+:'(T.@V#H%Zu\"AfUNVZUuFVZNau?3gK2Y6/)9[fZjA#7%./Dn?e\"!f$k6rrRrX$U=q%K)utsk5luL#7'Z\")[Gg5JcPm\"#HInF#7(,28uDarQ2qp0QNG2/?3eLP#7UnCklVk0hZCOo#Jp`'!q-1S^B27WmfELX!ri>Z!bJqELBHuHA\\%r(\"5a/kncFRKNrpth\"-3P>\"(f=S#6PnMNs#C`/WU!p\"-3NhWW\\@b^B.^H#MT7u#G2'a\"'u4n\".o[%#H%[8\"AfW4\"1e\\5LB@dJ!tZgbjoHD+rrT)#?3cMnY6/)9#F>N(-O3Zk#EJuX!DnOR^B'Z'?3g3*T*&C)#=]X;LB@c-2hqJ?%0m-c!?2:4!g3`g-O15&#6uDcmfE`n\"<.T$\",[<a-O6%B)[G7%^B/!##i>^@!XG_.hZCOo?3^];)[?VC*(n6Q#DNI&#F>MD!aZ,`!XB/>#<Nk0pAtRG(De/nmfL6)rrQL3LB@c-*u?#!rrV'ZK)n4B#BLghB@d2k#L<J/!aZ,p!hofo%gU\\f!sbV&#@u-^cN;]\"?3f'`#7Upi!XB#:#6PnM^B*3n?3fWp#:0ls+'%2\"^B*d)?3^_<!?27K_[%1dmfKWr5R.PS#oa,9!fmFi#EJrl%0m.+\"rddP#7(P>M\\-m5mfMqZ9Zd_2!p9V!b81CT)[?W6(J:k4#HJ+L#;cZr[fa)AY6/)9#IsjS#N#Qk\"'u59\"2=qE#6tK&[faAIiWE!f^B:qI'Y+5L:)aG)!q-1s#O_^!%0m+O)[HBE#71V?mfIFF%]9Bs!aZ*R#ANo6rrQ(p%u18H!`0Dg\"0)N$%j1NIC^12?)[?WF\"rdf^!J^b`#@EMo?3gK3QNLP!#6PnM#G2*+#:CTnLBE;6b7-]A#H7nH#O__g\"AfWt!p9V!h?+!-)[A=b!aZ,X!q-1s#6tK&k5klP)[?W)\"<.Tl!s],;`ridQ<6kXO3?&4<!ga!FNs#C`^B.B$!sb\"o)[F+[dK*1R\"31N7\"AlQ0cNDl+:q$PY\"-Njb[fbn!^B6%=\"4mX\\\"&QH/l3531/Ct!U\"8W'q[fbn!cN>`M\")$3f?3e4IhZI0iT*+6Y?3^_e!s8d@f)o=a`rk3$?3d))k6##q#M0%[#6t>M#A;Wj?3edYhZI0iT*+6Y?3^];)[?W\"!s8c5`X*RhQNEKU?3cf!#7UnCq[+8ImfMqZ9^3$qpAucKd/aInk5pD@Op1q7#E&d*#PS8&\"'u64!k/8<#G2+5\"'u3;VZRJX#O;I2#J(,+\"\"^&HT)tVe?3cMnVZU61Y62?=:_/lo[f]qA#?)QH#F>O##P%n^\"\"]K8Ns!,u<0m^e!l\"e9QNIHp)[B`B\"'u4n\"/c6-#Hn6@\"AfU6T*%Cb#DN6u#7$k'&1=pgT*&C)#G2)/#G2+5!`YKg^B(57?3^_l!?2:$!LEmp#EJtZ\"'u3;#=Xs]T*(Mc:_00#QNJCp!XG2\")[EhS[fZm+!k/8m\"'u3;\\HEiVNru*a*4H#?^B7dINs!E)?3^]?7DAr6\"0V`)^B:qIWWOZ1\"1e`H\"$!al#@8>S#MT;nmfE_e)[DE+RfPbZ#He(H#F>LQ\"'u4n!s]8?#Mo_*#H%X<\"'u5A\"31LM#L<JW#mU^M\")g3g!r;s!-O9ML)[?TQ#RB&eG=_T4#E]30#O2K5!\\\"?ZJH?bqpB&JA!@R=;mfEjj!q-2n!C-kpis$G-k5sTLE!HWS\"WI^0!g=.6#7&oc)[D]2Nrr\\nNroUr#7%L@)[DE+[fKe?ncFCL>)rdN\"d]<?#6uIm#7$:l0GfcPf)f7`#EJs@*sY7S#I4T,\"\"=IaVZS@Q\\HE-YQNIHt#R:S>1$8TCk5l/!#@8>SmfMqZ9Ss*bpAucKRgoZEk5knW!^[.d!jVn/-gq-2!d3r5#6PnMmfM/F5R.NM)[EYMNrpg9#QFil#I4Dd\"\"=H[pB!YdrrUmZ!@J+a)[?Vq$6'65!nRJf^'Y,5$6'5b!NuQ2#H%t88%/Q7!h'0e%gN1U#9P$fY6\"sD!al6<TaYV<!XI`g)[Gg5q>p[F#EoW:#DW]e(EVH7#6tM>@cmeA#O_`j##Gj)!jVn/-gD*>!\\\"?ZmfGf\\#:g_umfN4b/aic8!nmk[-hd]2!ZCG.mfKg)5R.N=)[H*=q>p[FpB'db548RI!f@3`-O3Bc#7%+,)[B0j!aZ,@!oF&c#@cit.0l\"EmfFpC#7DIU#KHmaq$nbW<S%9WcN7P\\f)c0`#6uk##EfD.!\\\"AP!lk@K#7&QV?j?p[)[F+ZQNK%)!sd*ZBU8f+jp2n2LB@c-5DK=G%0m-5$6'3T#7(R\\!p9Vk#Nl-n%0u/%k5m(;#6PnMOot.S.0j>V!\\\"BE$O7a9!oF(2![3C2#:g_uhZ;=1?3edXhZ@*h#7!]L!oF'J\"],^74rX_3Xpl<T#EB9dmfEa)#9*p:!qHHp-O5A2)[Gg5ap%ko#GqbG#PS;*!Dj=$!f@.XpB(?rU&n.%#6PnMLBFO\\!@Np1g'7X+LBES>7#(jL,9$mN!XC#!k5sfJ*=)$7g&b(]#A+n[LBEqI5R.P9%N>Y^!hg#f#7$(d)[?WA#YLus#K$fd#Ia^=#m\\3G_?EaH`rY0':_*f[\"<.T!!=*.j!pTrM!\\\"A5!=*/%!hTOW!Dj<)!ZFlG#D3-u#MKD9D>F=^!AA;Q\"ulA`:_,eU\"&KLuE_m927l*Y2dK35U#D3$r#FYqe!H%*'U'^8hD;#01#k%e2g'+bjmf@:Z\"U?h&#GMRo!H$NoWX/%oD;#/N%.=46g',n1mf@:Z\"nDrf!H$No#Q\"N@#FZ\"g!H$Noapd_>D;#/F%.=46g'-1=mf@:Z\"UA?Q#<u!?:Tjg)<``YN\"&KM@Z33u7Dd#sJ#6PnM5Ar>rl32A\\#Cjl\":_,d?1Ok/\\\\cYb>#:g_u5F2C,QN<]ZZ3=&8VZELq:_*f7!FQ-;Sc]o:5DK7qLB3G:Op=eo5E>h$NrbRJJcnm\\#?DcK#7hXV#;9HincUU_Z3(>t!uhL)#k%e2g',>$mf@:Z\"o8Sp!H$No_@5l6D;#0f!KmL\\%gW+8?j?r9!uhK[!XB#:#Hn2ITb.Ou!FQ/\\$h\"+5l2o*7mf@:Z\"l]pY!H$No#K?ib#H%X,!aZ,0!Oi,:#7%^>%gN>G)[F[iOp\"Sl5L0?dcN2Vu_?*OE5M#olf)ab0_?NgIk5g/9:_*ec!?2:D!jVi'&,u_-\"&T\"!LBG['!@Np1WWiJO#9t/m#PS9d#QFl%!Wa[(\"8W'\"-O2.@#EJtB\"$VJBRL>/Y.0g+X!^[-I\"-Nih-O3Bc#:Ba]mfN4bM?a/0mfN4bFmfD#!kAe+#6uau#@cit.0o;CdKNGXpB%W$:_3:%\\ckq)!XH^G)[?V!$l]H/!P\\\\B#IacT!aZ*:#=ZB/#6PnM`rc)@:_1SJ^B,RP&I3:p#DWBd,qk#U#7UnC[LX;^Y7f._CPNY6(Uk)i^D<.XVZm.A&sig;\"tJLLk5rX1E!HX1%N>YN\"0iG'#7#Sp#L<Jr:_+oY>djgE\"1J@ST)f0!)[F+[iWi9j`ri%=:_,3$<Mop(<Z;8K#7(RL!N-$+#KHkK\"'u4f!Oi/;#JUAp\"AfWL\"!UPP#C[Ts#@SPV^B39o/(Xj[!l\"eC#Pn_:$qn>:#MBS+#7&NdB^Z!-jpE%4z!\"*9@8O\\I:4Wu+/T`Gb*R0<g7)[?T])[?Vc\")&b]irL)(#7hXV(C)5k%j,*_#6PnM-cuYp%gNn;#9O0s(C(Tm#7$.kBJ0Tp)[?m$?3`.+#6>>?+$p2;!uhIM*tJT(U'(K-0*`dF%l[f\"5KX33%j)ln0*bo)#7$.k)[GX3=#`DLP6,Df#MTD$#?M-V-W^N^#7!.+#>YRN-VjsV#7&-I)[@_q<DNi)ECWe0,tAJI?3ai[#6>>?9,e+##:2#67pZF0:H1!49,e+3#:2SF='c,@?T9\\t@Q.p)IN&MC#@qHP:CnlY&SMsc,9$kH@Q.@9#@'J`#:2;6DArfcdfUNol30sC(C/=gBKla.!uhIMgB)%9#D3*t#<rG>-U.hF#7&f\\)[?Ul!sa#T,u7Tl?3ahm!F?!9G68(o#:3/QIpN@uLB1]d#Bp7T:Np+MG6]#k#B'\\Ll32)c-[,eA:Hs>8#=jOM?3^^Z!sa#T,u7$\\?3_j5!F?!9;]>s[#:3.fG?tM=IpN?bFrL[!LB1]d#Bp7TG6]EiB7F4m=,-f_#7(5/)[?Ul!sa#T,u7<d?3^^9)[@1'?3_R%?3^^R!s]'s!?2:/\"^a5Zl31f[+)_B1:Bs?.#7&?PBK$0N!uhJP#:1a)#7UnC:)aG)\",@p!pE'Y)!?28>#:1`n#7UnC&K:s^#:1a)#7UnCmK4C556iJ^56hW&#DN6u#64`(!!!!/hO\"HOqZ.W@#P.s8#<s:^-U/tb#7\"HP#O2Jf!bW#K,9$k@%gSg52\\u^n\"ue1L1C\"L2#;6SmU'BldqZ1=_#J1!U#8[nW#6u[s#;8;*&#'7m!'`D<4r9pt:B4/q!uhJP+(_/N57_'*:D[=B?QWSZ#6PnM#AY7`l3.i6(C)r>#N#mg$?haF(Cse##B:[f#8\\3^@NR$(l3/Oa#6t>M#6u1e#<*_V-T<DZ#6uIm#O2J!B+G5r)[@`D?3`+g)@%oS4qF@l2ZPd,+(_/N2\\04\"7iu%B#:USsz!!*W5Z^:n$',q/]$QB<U!uhIM%i>NV%i5HU#8.9N&aolHNu%cr!!!!#XT8S-[$V\"%',q/]$QB<U!uhIU#:0TkU&b9*#7jZ:#6tkHV]NS[&sjI9z!sOM^I0Il_\"UANV#7\"HP#7\"0H#KI1d)/]*a*sX)&(CsIe(J4]5*sX)&(CsIe(RbO/#7##`#7hVW#8[U`#6tcI#8d4>!='\\O,nCe&<$)pV#6>&7+WCY&#:10&(EE`i(H<3I(H)d/=W7Sf#:0ls%oaVel377o*sX)&(CsIe(YSrl#9TB9!='DO<$)?g)[??C!!!!$Vu[(D!=6H-\"U?7k#6u1e#6tn]#:B`_#:B`p#6u%^#9W47:_+Wi1D_,N5R/A9GUG/=\"9B#d+*RrC#:1/k!uhIm2dQ^o02Vrb0/FCt#9!in$*P4l[fQO0!!!!$\"VDIUd?k(BZN2!M#HIkE#7%\"))[H*MY9,]Y*m+j\\.0g):63fG.Ab#mU2_?[A#:1/s5@+R\"6Q67`2_?[A#:10&5@+R\"+WCZD#\"L*I#<+sS2`G<b#7!^;#D*%J.0g):63f/&/MAa^)@$cX,mP4k,nFH,.0l\"<-Rf9J03&Mf!uhIu#:1062dQac#sTjD#;8CK0/$nj$9&29(EYkJ#7#Mn#64`(!!!-B'd4G-WgO\"q',q0c+\"7FF#9FCb%k.`\"#:0T[(Cp`U#oa,Y\"m6&)cPI+E!cSALCE!M.#:1/kIh)c;IkuQZZNb)m#HIkE#?Mj`#7%jE)[A=N\"`O\\O]*0,YG6]E1#Bp[`G>UU1#I=LO#6t>M#6tJ>#7h%c%i5Hs(C(`e#9O0s#6t>M#7h&>*sW#Y&!$_r,o7's<K@.c#B>4uK*<2!Ig781LB.W+(C,]r%gN>/)[Di9#9Gf/045%M\"ZIk8Z3NTC#@^1P#7!.+#7h&>D[-Me?WSm[?O$ZP#?M-V%poPf#7\"TH#A48f#7h&>B*SZ]='l1Y%gN1U#A48f#7\"lP#B'hn#7h&>D[-Me?WSm[?O,<f)[C!\\,mOZf%gR\"X,mO[h!?28F#:0mf#:0T[?OmBS#:0Tc#?>CA#B<gP#:0lcAfCu!#:0T[G7Oo`;&]`F#7(QD2^ntr#:0T[57\\!.7k\"\\\"!='Z)Nr]J3#7h&>Nr]K8@L%*1<.>,T)[?Un)[D-!#:0Tc#??N[#7#6m%gQfuLB.W+(C,]r%gN>W)[CR?<.B)s,p.UA,o6f9%gN>O)[?TQ#R:Tk!?27K#7(P>aT<Cdl316<#I4SA.0j<p.0g([)[CWn*`mgr,o6f9%gN?\"!?28f03!FF#:0T[G7Oq.#:1/k!uhIMIh)d6`W8=0#@8>S2oYr=#7'r()[??Cz#geqB#9t/m#9+Te#Fb`5#7#Th0*chC#6u=f#9P0U#6th[#PSeM!YWNe@P9/8#8nHc(Lf<N-RV3S\"tq>U-O0_m#7iIJ0/\"sc-SH?&#7!g>#;6<##O2IG.0g)!)[@0g2^]t#6)\"Q2-Yj57@Q,qV@Q-4N!uhJ(00V$u0/tU<00u<:-SIJ-#6PnM0..!60/#L:0*`C#z!!!DKQj!_I!?27KHQ*1p#8.:)*Ub%`LDN`f?3aO:%0m+?)[B/??3^^:%gQ/J5R.N;)[Crs2^nt:-UJ%`#@oIm;]>s@#@pU83?&2.#>PN5!=)=0&)%4a&,-;69c\"V_!DjRK-XI&C#;7M2#?_uN>R+du9F#)m$jU<5#Bh$kz!!R3C,ukZjJ=-QGUBDM@#Fbi8#6uW\"(FL#*#6t>M#@]&0#;6T.#Ef?O.0l=C#9G6?q?6m1-QaM<!=-4<)[?Up)[?mD1I#>E3'RpL1Ja_L=#`DT=#3oJ?SbbZ?W7gH!uhJP-R)V^?Sc&%U'(K-:L@(6#@SPV(FNMo#HIkE#:F5)#7%:2)[?TQ#R<\"!?3^]a)[@b=#6>>_+!E'<dfLHn=!&Vf0395K=/l?N-b9Oa3*00_#P%pt-XI#_Wra4F<sL#f(LLJR:M3u=#?O4s='$n\"#AtIc-Pp(o#:USs-O1q6(GB)\"@Q,_@@Qu:H-O3m(0=h/b%l^Kj-mo6-)[E,=#9Gh8#<+V$2`D!4!]MK5#GMD].0i'R*=$%D.0g)I)[?TQ#R:S>&dJXP(^ClB\"],^O#:0Tk-XI#_#=T_+iX.di#8%m[#=]X;T,$5uC\"Eb4l309d#LNPk#<0'mE!HX<!?27K-Z0_*ScTi9z!!*Z9Z^:n,#6Y8R#6b>[#:0T[!uhIM+*&HY!hUQ%mhc91)[??C!!!!#0pMbD\\sNX+',q/]$QB<U!uhIU#:0T[(LRIi#:0T[!uhIm#:0lc-P$G8#:0lk#?<D^#?;iN#7D(B%*o%]QQ?,,z\"2^E/#;[;(#:g_u0*bGe#D3$r#9O0k#@]&0#AXPc(M!b]%hAmS#9O0c#6t>M#6tJY#Ef0\".0g(_1Cj^$?jC-W.0g)$)[BH\"'K)3l#7_[X#8S6`(D1Tk#9Ffhz!!`RV!F8-.\"`XgiQj\"!*,nC4k(C(HU,o6dg)[@/a,p+36,o7p6,prpJ)[Gp@0.@,2%hLB)#:0lc!uhIM%i,C'dKT_*aoOFM#:Ba]+\"%:>(G?\">-T?nc!ADRr5:Hgb#?<,V%j2)f#:10&#:2;6+(,?=\"Xb`(#=0:6#6>bKmg9\"/ESh*'z!\"QW/\"UFo.)[EAM?S#ja$\"kjq;I:tf11+mU$4!=0)[C#-#>f'=#%&ooQNq.[#N>el/8#4Z#9*oj\"^c+]l3:U4nd!JGB35BDMZOh&\\cZ;VU'$Ge#7bD;\"^`fnB?(HN#7$_&)[DN5?Z!pkmg04tB<hPF/8&<s2%g-!:LDfY?Z#?9M?.($Op1+O?Yu57pAkLjB<hYI/8'P<?Z!pg#:g_uBDM^,BDMg>/8+\\Y#>Jjr\"(*Tl#A+n[g&YPtao]ur?Z\"d*#EK$sB,Y,.B@dFp;eH=i)[Crt?YueERK[&8RKj(1;PsQ\\\"CE]m#C.6nOo\\o@B=\\4QD$o_:#?,7?lNA.3q?:5CWWCNL?Z\"L$'F//]#MT7u#A48eLCUm$?S#hN?Z\"L)#Iaq@B9E='/8*rI?Z#?A,%#2U#sW&,#N>no/8#3#0D>YUMZOh&B*T)_q?L@YBCZ76D41K_!afg(\"paPs)[DN/?YuMBcNa\\9B;,Q:/8#2_)[E)<?Z!(V_?+(]_?&O)#@D-/$\"#5rB>4L0#N?/!/8#4B!?27V?S#i&pB)cJ_?O?uB3JYZZ3cs.?Z#'8k6qSoB*Z<T)[AuBD:/c(#71X0\"CE]mH=(NH$.9,eD>F8<V?%V@#?M`I#@CjDhZ=$]B*Wth)[EAH?S#j,\"(,o>#]a9hWX1.^D7U-B?Z!XdZ3=TPdL;QG?Z!(UJd,S!Z3ZTu?Ytr6#GD/;#Cct_BA*Z!/8*rE?YtB%#GD5=#A:UO:hS2[?S#j4#@D>b$E=><D7U)[_#kV]aoc!%B:9$3D2JFQ\"CH#o\"4@B\\D<_?2B6;`3#6PnMJc]:1BA*GpD8HFe!FK]l\":&'K#A9b>:hSJ`?S#j1\"p\\(>B8QjhB;,H7/8'P??YtZ.f*5kP#6tPS#PnR1D;kT:#%muB_?F9tB*YRB)[?WA!ZM@T[fK=W#ljr*!!!!$ZBte##>PMg!=*-G#7!C.#6tVImg/(^17nRP!?27Dz\"9jV_0qeUZcC\"h@3u\\D01E-Q(.iS_n$nj%70Br`B#</@[!=(7o<&Y%,)[E_N#@n>M(LRIil377o#Fbo:#6tJH#9WdF!='\\_<\"C(N#6>&O(K:neg&h?\\-^k);#9Oa]-O58.)[@H$<\"C(.!<EEI(K:nMAfCt&G?tM%IpN@%#?>[I#?=8!#B;[eM?3e`#;6/a0*`dF+#dL2-U1oB-V%JJ#@e\\X-U1oB7jfl9:FBm)#L`hq#BU2]7jh)=#:ESZ#9O1N7gB9=2a<0$!=&i_!s]'h!uhIM2aRa6M?3e`#;8CK-RVkH0*`dF+#dL2#;[;(+%cP=*u@le+$ou5*u@le++aXs#7%4/)[@`T1FFP??3^]o63d`?)[@H$<\"C's!='\\_<\"B4W)[G@,5:HgB01#mk-WD`P#:1H62dQ_:5@+R\"V?.\\A0*`dF+#dL2-U1oB-V%JJ-Vn%R#?r,P-U1oB-V%JJ:F@53=1SD5#?OtK-O4E+#:F.j#:FFr#6tK&B.%V(#7&?O)[@`l?3_ib?3^^B%gN>7)[A%-!<EEQ2`!*?-WE#0)&iff\\cDg:?RHq&-O3XA#7#6-5DfLC#6uma#;6<.+!3FJ#7%40)[@_q,nD(6<$rcV\"p\"rN(K:ne3WTHjRfOH5X8rQ:+\"%:>(C)U$#8]=*#6uVC#;6<.+!3FJ#6t>M#:D`B#:E#J#:E;R#:ESZ#:Ekb#7\"HP#>Z^_:FB3U-Vmf(:JXJE7gH'q)[@H$<\"C)9!<EEI(K:ne_?0fD*u@le#?r,P-YH`j#7!\\)-YH`j%gQ*I#7\"7!#7#6-5DfLC#6uma#;6<.+!3FJ#7%[?)[@I:\"p\"rN(K:ne1'%UbOTZU.#<+sS5DfLC#6uma#7'Jr)[E8Xf,7&]\"onW'!!!$$#.Ks'#9t/m%j+au(ZGW-+!2R\\%j)#p#6u%^#6u>Y#:GrA!=&i9)[Gg;ruFIn&I0a(#64`(!!!!%Z'Y\\\"#>PL/#<`k.#=B:4!?29!*VTRb`teXT!!!!$.0YP/$HAG:#:g_u#9t/m#6tM>-O1q6-O1(c#6tkH%gN4B#9R=Y#7!C>#9RC[@OET00*`d.2_\"h=#7!CV#7#6%@Q,_@,6o8;7u@?K%n?jC#F>OJ*+\\d[#::Ap-OXku#8%m[+%J+O7h6ai#<!M+':SW+e(=<V58*.n`ETG%5GWtS\\0q@?5>k]%/50^'56cD+8CU)b5N,feJV#iJ59u=&NtZ)JHlYA(*O59I.$$7-#kDi+>>M9?-b,1[Gu/:R'p;f1GQkTEQ]An,#DFAIIGh-'G5qUC!!!!C^iobYz0#2Z2z!%bp0zzpW3F9\"TSN&zzzz$NL/,%fcS0!<<*\"!!Ks%\"U>tn#6tnh#6tV`#6t>X#6tK/#HnFE@g<>OGnL>a-3jbX-3kUt<sKokD)*1<<sKWcD(6V4#mU]j#SIC2(q1ShY64k+",
						5
					))
					return v
				end

				if v < 21 then
					list[24] = self.x

					if list2[4205] then
						v = list2[4205]
					else
						v = self:E(list2, v)
					end
				end
			end
		end
	end,
	TN = setmetatable,
	My = function(self, list, p, _, list2, p2, _, p3, p4)
		local v = 68

		while true do
			if v == 68 then
				p3 = list[1][12](p2)
				list2[9] = p
				v = 83
			elseif v == 83 then
				list2[4] = p4
				return 83, p3, 135
			end
		end
	end,
	yy = function(self, _, _, p, p2, list, _, p3, p4)
		local v = nil
		local v2 = nil

		for i = 49, 338, 113 do
			if i == 49 then
				p = list[1][12](p4)
			elseif i == 162 then
				p2 = list[1][12](p4)
				p3 = list[1][12](p4)
			elseif i == 275 then
				v = list[1][12](p4)
				v2 = list[1][12](p4)
				break
			end
		end

		return v, nil, p, p2, p3, v2
	end,
	R = function(self, list, _, list2)
		list2[25] = self.m
		list2[26] = self.W

		if list[14056] then
			return list[14056]
		end

		list[11559] = -1265249061 + self._x(self.jx(self.h[1] + self.h[4], list[3404]) - self.h[2], list[8694])
		local v = 54 + self.ox(self.ox(list[2442] + list[28480]) + list[31896])
		list[14056] = v
		return v
	end,
	c = function(self, list, p)
		list[16][p] = list[17](p)
	end,
	X = bit32.bor,
	hN = string.pack,
	Ny = function(self, _, _, _, _)
		return nil, nil, 3, nil
	end,
	Y = coroutine,
	l = table.create,
	my = function(self, p, p2, p3)
		if p2 < 184 then
			local v = self:xy(p, p3)

			if v == 28319 then
				return 51707
			end

			if v ~= nil then
				return { self.z(v) }
			end
		elseif p2 > 121 then
			return { p }
		end

		return nil
	end,
	Rx = function(self, list, p)
		return { list[45](p, list[23]) }
	end,
	v = function(self, list, _)
		return list[18522]
	end,
	ux = function(self, _, _, list)
		local v = list[1][38]() - 25846
		local v2 = nil

		for i = 1, 74, 73 do
			if i > 1 then
				if list[2] ~= list[1][36] then
					list[1][46] = list[1][12](v * 3)
				end
			else
				v2 = list[1][12](v)
			end
		end

		for i = 1, v do
			self:kx(i, list, v2)
		end

		return v2, nil
	end,
	ly = function(self, list, _, p)
		list[34] = nil
		list[35] = nil
		local v = 18

		while true do
			if v < 73 then
				v = self:Fy(p, v, list)
			elseif v > 18 then
				self:Sy(list)
				list[36] = 4503599627370496

				list[37] = function()
					local v2 = self:gy({ list })

					if v2 == nil then
						return
					else
						return self.z(v2)
					end
				end

				return v
			end
		end
	end,
	Sy = function(self, list)
		list[35] = function()
			local v = { list, list[23] }
			local v2, v3, v4 = self:qy(nil, nil, v)

			if v3 ~= nil then
				return self.z(v3)
			end

			v[1][4] = v4
			return v2
		end
	end,
	jx = bit32.rshift,
	a = function(self, p, list)
		list[1][4] = p
	end,
	ax = bit32.lshift,
	Yx = function(self, list, _, p, _)
		local v2

		if p >= 106 then
			v2 = list[1][35]()
		else
			v2 = list[1][33]() == 1
		end

		return 27, v2
	end,
	cy = function(self, p, _, list, _, p2, _, _, p3, p4, _, _)
		while true do
			if p4 > 3 then
				if p4 <= 6 then
					p3 = list[3]()
					p4 = 45
				else
					local v = self:ty(p2, list)
					local v2 = list[3]()
					local v3 = p3 % 8
					local v4 = v2 % 8
					local v5 = p % 8
					local v6 = (p3 - v3) / 8
					return (p - v5) / 8, v4, v, p3, (v2 - v4) / 8, v3, v5, p, p4, v6
				end
			else
				p = list[3]()
				p4 = 6
			end
		end
	end,
	Ly = function(self, p, p2, list, p3)
		p3[p2] = list[1][1][p]
	end,
	rx = function(self, p, p2, list)
		list[1][46][p2][list[1][46][p2 + 1]] = p[list[1][46][p2 + 2]]
	end,
	DN = table,
	Ex = function(self, list, list2, p, p2, p3, p4)
		if p4 == 96 then
			return p2, 8147, (self:Nx(96, list2, list))
		elseif p4 == 63 then
			return p2, 8147, (self:tx(63, list, list2))
		end

		if p4 == 18 then
			list2[28][15] = self.ox
			local v

			if list[18231] then
				v = self:cx(18, list)
			else
				v = 55 + (self.dx((self.qN(list[1070] - list[16947], list[4205]))) + 18)
				list[18231] = v
			end

			return p2, 8147, v
		elseif p4 == 73 then
			list2[28][11] = self.O.lshift
			local v

			if list[31530] then
				v = list[31530]
			else
				v = -4704108304 + (self.h[6] + self.h[3] - list[5963] - list[24659] - list[2442])
				list[31530] = v
			end

			return p2, 8147, v
		elseif p4 == 20 then
			list2[28][9] = self.Lx
			list2[28][16] = self.S.unpack
			p2 = list2[45](p2, list2[23])(
				p,
				self.F,
				list2[20],
				p3,
				list2[37],
				list2[33],
				list2[34],
				self.h,
				list2[32],
				list2[45]
			)

			if list[28801] then
				p4 = list[28801]
			else
				p4 = self:Px(20, list)
			end

			return p2, nil, p4
		else
			if p4 ~= 99 then
				return p2, nil, p4
			end

			local v = self:Rx(list2, p2)
			return p2, { self.z(v) }, p4
		end
	end,
	gx = function(self, p, p2, p3, p4, p5, p6, p7, p8, list, p9, p10, p11, _, p12)
		local v = 101

		while not (v < 101) do
			list[11] = p8
			v = 0
		end

		list[6] = p10
		list[7] = p12

		for i = 63, 237, 99 do
			local v2 = self:iy(p6, p3, i, list)

			if v2 ~= 972 and v2 == 7137 then
				break
			end
		end

		for i = 1, p do
			local v2, v3, v4, v5 = self:Ny(nil, nil, nil, nil)
			local v6, v7, v8, _, v9, v10, v11, _, v12, v13 = self:cy(v2, nil, p4, nil, v5, nil, nil, v3, v4, nil, nil)
			local v14, v15, v16 = self:Ry(v6, p6, v12, p11, p4, v10, nil, i)
			local v17, v18, v19
			p7, v17, v18, v19 = self:Sx(
				p10,
				v15,
				v13,
				list,
				v9,
				p9,
				p8,
				v6,
				p2,
				i,
				p5,
				p6,
				p3,
				v11,
				p7,
				v16,
				p11,
				p4,
				p12,
				v8,
				v7,
				v14
			)

			if v18 ~= nil then
				return { self.z(v18) }, p7, v17
			end
		end

		return nil, p7, v
	end,
	Kx = function(self, p, _, p2, p3, p4, p5)
		local v = 96
		local v2

		repeat
			p3, v2, v = self:Ex(p4, p5, p2, p3, p, v)
		until v2 ~= 8147 and v2 ~= nil

		return { self.z(v2) }, v, p3
	end,
	sy = function(self, list, _, _)
		return 126, (list[1][38]())
	end,
	lx = function(self, list, _)
		local v = 3303404743 + ((self.dx(list[22295]) - list[2340] > self.h[6] and list[12509] or list[16478]) - self.h[4])
		list[32181] = v
		return v
	end,
	A = nil,
	bx = function(self, p, p2, p3, p4, callback, list)
		if p ~= 68 then
			self:fx(p2)
			return p4, p, 62176, p3
		end

		local function fn(...)
			return (...)()
		end

		local v = callback()
		local v2

		if list[12719] then
			v2 = self:Ux(p, list)
		else
			v2 = -3303404547 + self.Lx(list[16947] + list[8694] + list[12509] - list[31729], self.h[4], list[4205])
			list[12719] = v2
		end

		return fn, v2, nil, v
	end,
	eN = bit32,
	Py = function(self, list, p, p2)
		if p == 135 then
			return p2
		end

		list[1][20] = -p
		return -144
	end,
	Yy = function(self, list, p, list2)
		while not (p > 27) do
			if not (p < 62) then
				continue
			end

			list[38] = function()
				local v = { list }
				local v2 = 65
				local v3 = nil
				local v4 = 0

				while true do
					if v2 == 65 then
						v2 = 44
						v3 = 1
					elseif v2 == 44 then
						local _, v5 = self:Ty(v3, v4, v)
						return v5
					end
				end
			end

			if list2[1070] then
				p = list2[1070]
			else
				p = 44 + self.nx(
					self._x(
						list2[20291] - list2[22295] < list2[12509] and self.h[8] or list2[11559],
						list2[11206],
						list2[12509]
					),
					list2[16478]
				)
				list2[1070] = p
			end
		end

		list[39] = self.A
		list[40] = self.A

		list[41] = function()
			local v = { list }
			local v2 = v[1][38]()

			for i = 121, 234, 63 do
				local v3 = self:my(v2, i, v)

				if v3 ~= 51707 and v3 ~= nil then
					return self.z(v3)
				end
			end
		end

		list[42] = function()
			local v = self:Ay({ list })

			if v == nil then
				return
			else
				return self.z(v)
			end
		end

		list[43] = function(...)
			local v = { list }
			local v2 = v[1][13]("#", ...)

			if v2 == 0 then
				return v2, v[1][30]
			end

			return v2, { ... }
		end

		list[44] = self.Y.yield

		list[45] = function(list3, p2, _)
			local v = {
				list,
				list[7],
				list[44],
				list[45]
			}
			local v2 = list3[10]
			local v3 = list3[1]
			local v4 = list3[8]
			local v5 = list3[7]
			local v6 = list3[2]
			local v7 = list3[4]
			local v8 = list3[11]
			local v9 = list3[9]
			local v10 = list3[6]
			return function(...)
				local v11 = v[1][12](v2)
				local v12, v13 = v[1][43](...)
				local v14 = 0
				local v15 = 1
				local v16 = 1
				local v17 = 1
				local v18 = nil
				local v19 = nil
				local v20 = nil
				local v21 = nil
				local v22 = nil
				local v23, v24, v25, v26 = v[2](function()
					while true do
						local v27 = v7[v17]

						if v27 < 61 then
							if v27 < 30 then
								if v27 >= 15 then
									if v27 < 22 then
										if v27 < 18 then
											if v27 < 16 then
												v15 = v5[v17]
												v11[v15] = v11[v15]()
											elseif v27 == 17 then
												v11[v5[v17]] = v11[v4[v17]] ^ v11[v9[v17]]
											else
												local v28 = v5[v17]
												v15 = v28 + v9[v17] - 1
												v11[v28](v[1][9](v15, v28 + 1, v11))
												v15 = v28 - 1
											end
										elseif v27 >= 20 then
											if v27 == 21 then
												for i = v9[v17], v4[v17] do
													v11[i] = nil
												end
											elseif v11[v5[v17]] == v11[v4[v17]] then
												v17 = v9[v17]
											end
										elseif v27 == 19 then
											v11[v9[v17]] = self.gN
										else
											if not v19 then
												break
											end

											for k, v28 in v19 do
												if not (k >= 1) then
													continue
												end

												v28[1] = v28
												v28[2] = v11[k]
												v28[3] = 2
												v19[k] = nil
											end

											break
										end
									elseif v27 >= 26 then
										if v27 < 28 then
											if v27 == 27 then
												v17 = v5[v17]
											else
												if v19 then
													for k, v28 in v19 do
														if not (k >= 1) then
															continue
														end

														v28[1] = v28
														v28[2] = v11[k]
														v28[3] = 2
														v19[k] = nil
													end
												end

												local v28 = v4[v17]
												return false, v28, v28
											end
										elseif v27 == 29 then
											v11[v4[v17]] = #v11[v5[v17]]
										else
											v11[v9[v17]] = v[1][5](v11[v4[v17]], v8[v17])
										end
									elseif v27 >= 24 then
										if v27 == 25 then
											v11[v9[v17]] = v11[v5[v17]] <= v11[v4[v17]]
										else
											for i = 1, v5[v17] do
												v11[i] = v13[i]
											end
										end
									elseif v27 == 23 then
										local v28 = p2[v9[v17]]
										v28[1][v28[3]] = v11[v5[v17]]
									else
										if not v19 then
											return true, v5[v17], 1
										end

										for k, v28 in v19 do
											if not (k >= 1) then
												continue
											end

											v28[1] = v28
											v28[2] = v11[k]
											v28[3] = 2
											v19[k] = nil
										end

										return true, v5[v17], 1
									end
								elseif v27 >= 7 then
									if v27 >= 11 then
										if v27 < 13 then
											if v27 == 12 then
												v11[v9[v17]][v11[v4[v17]]] = v8[v17]
											else
												if not v19 then
													return true, v9[v17], 0
												end

												for k, v28 in v19 do
													if not (k >= 1) then
														continue
													end

													v28[1] = v28
													v28[2] = v11[k]
													v28[3] = 2
													v19[k] = nil
												end

												return true, v9[v17], 0
											end
										elseif v27 == 14 then
											v11[v9[v17]] = error
										else
											v15 = v4[v17]
											v11[v15]()
											v15 -= 1
										end
									elseif v27 >= 9 then
										if v27 == 10 then
											v11[v5[v17]] = v11[v4[v17]] >= v11[v9[v17]]
										else
											v11[v4[v17]] = nil
										end
									elseif v27 == 8 then
										v22 = v21[3]
										v20 = v21[2]
										v18 = v21[5]
										v21 = v21[1]
									else
										v11[v4[v17]] = v11[v5[v17]] % v6[v17]
									end
								elseif v27 >= 3 then
									if v27 >= 5 then
										if v27 == 6 then
											v11[v5[v17]] = loadstring
										else
											v11[v4[v17]] = v13[v16]
										end
									elseif v27 == 4 then
										v14 = v4[v17]

										for i = 1, v14 do
											v11[i] = v13[i]
										end

										v16 = v14 + 1
									else
										local v28 = v5[v17]
										v11[v28](v11[v28 + 1], v11[v28 + 2])
										v15 = v28 - 1
									end
								elseif v27 < 1 then
									v11[v5[v17]] = v11[v9[v17]] / v10[v17]
								elseif v27 == 2 then
									v11[v5[v17]] = pcall
								else
									v11[v4[v17]] = p2[v9[v17]][v8[v17]]
								end
							elseif v27 < 45 then
								if v27 < 37 then
									if v27 >= 33 then
										if v27 < 35 then
											if v27 == 34 then
												v11[v4[v17]] = p2[v5[v17]][v11[v9[v17]]]
											elseif v11[v5[v17]] ~= v11[v4[v17]] then
												v17 = v9[v17]
											end
										elseif v27 == 36 then
											v11[v4[v17]] = xpcall
										else
											v11[v4[v17]] = list3
										end
									elseif v27 < 31 then
										v21 = {
											[1] = v21,
											[2] = v20,
											[3] = v22,
											[5] = v18
										}
										local v28 = v9[v17]
										v18 = v11[v28 + 2] + 0
										v20 = v11[v28 + 1] + 0
										v22 = v11[v28] - v18
										v17 = v4[v17]
									elseif v27 == 32 then
										local v28 = v5[v17]
										v11[v28](v[1][9](v15, v28 + 1, v11))
										v15 = v28 - 1
									else
										v11[v4[v17]] = v11[v9[v17]] .. v11[v5[v17]]
									end
								elseif v27 < 41 then
									if v27 < 39 then
										if v27 == 38 then
											local v28 = 18
											local v29 = nil
											local v30 = nil
											local v31 = nil

											while true do
												if v28 == 18 then
													local v32 = v[1][28][9]
													local v33 = v[1][28][6]
													v28 = -4718537 + (v32((v33(18, 18))) + 18)
													v31 = -4292871370
												elseif v28 == 73 then
													v29 = 0
													local v33 = v[1][28][10]
													local v34 = v[1][28][11]
													local v35

													if v27 == 73 or not v27 then
														v35 = 73
													else
														v35 = v27
													end

													local _ = v34(v35, 31) == v27 and v27
													v28 = 20 + v33(v27, 73, 73)
												elseif v28 == 20 then
													local v32 = 4503599627370495
													local v33 = v29 * v32
													local v34 = 11
													local v35 = 8
													local v36 = nil
													local v37 = nil

													while true do
														if v34 == 11 then
															v32 = v[1][28]
															v34 = 131 + (v[1][28][12]((v[1][28][11](v[1][28][9](11), 11))) - v27)
														elseif v34 == 110 then
															v30 = 6
															v32 = v32[v30]
															v34 = 189 + (v[1][28][7](v27 - v27, 8) + v27 - 110)
														elseif v34 == 117 then
															v30 = v[1][28]

															if v[1][28][13]((v[1][28][14](v27 - v27, 117))) ~= v27 and v27 then
																v34 = v27
															end

															v34 = 42 + v34
														elseif v34 == 80 then
															v34 = 111 + v[1][28][10](
																v[1][28][15]((v[1][28][12](v27))) - v27,
																80,
																v27
															)
															v37 = 7
														elseif v34 == 111 then
															v30 = v30[v37]
															v34 = 40 + (v[1][28][13](111) - v27 - 111 + 111)
														elseif v34 == 2 then
															local v38 = v[1][28][v35]
															local v39 = 29

															while true do
																if v39 > 74 and v39 < 88 then
																	v35 += v36
																	local _ = v27 - v27 + v27 - v27 == v39 and v39
																	v39 = -13 + v39
																elseif v39 > 87 then
																	v39 = 175 + (v[1][28][7](
																		v[1][28][10](v39, v27) + v27,
																		(v[1][28][16](">i8", "\0\0\0\0\0\0\0\7"))
																	) - v39)
																	v36 = v27
																elseif v39 < 29 then
																	local v40 = v27
																	local v41 = 89

																	while true do
																		if v41 == 89 then
																			v38 -= v40
																			v41 = 62 + (v27 < v[1][28][11](
																				v[1][28][12](89) + 89,
																				14
																			) and v27 or 89)
																		elseif v41 == 100 then
																			v41 = -47 + (v[1][28][6](
																				v[1][28][9](100, 100) + 100,
																				1
																			) - v27)
																			v40 = 6
																		elseif v41 == 115 then
																			local v42 = v30(v38, v40)
																			local v43 = 70

																			while not (v43 < 109 and v43 > 70) do
																				if v43 > 104 then
																					v42 = v7[v17]
																					v43 = -3221225295 + (v[1][28][6](
																						v[1][28][6](v43 + v27, 5),
																						25
																					) - v43)
																				elseif v43 < 104 then
																					v32 = v32(v42, 21)
																					local v45

																					if v[1][28][15](v27 < v27 and v43 or v27) - v43 == v27 then
																						v45 = v43 or v27
																					else
																						v45 = v27
																					end

																					v43 = 71 + v45
																				end
																			end

																			local v44 = v32 + v42 - v27
																			local v45 = v27
																			local v46 = 6

																			while not (v46 > 6) do
																				if not (v46 < 45) then
																					continue
																				end

																				v45 = v7[v17]
																				v46 = -1744830380 + v[1][28][9](
																					v[1][28][15](v[1][28][8](v27, v46) + v46),
																					v27,
																					v46
																				)
																			end

																			local v47 = v31 + (v33 + (v44 + v45))
																			v7[v17] = v47
																			local v48 = 56

																			while not (v48 < 56) do
																				if not (v48 > 55) then
																					continue
																				end

																				v47 = v5[v17]
																				v48 = 55 + v[1][28][12]((v[1][28][15]((v[1][28][8](
																					v48 - v27,
																					28
																				)))))
																			end

																			v17 = v47
																			break
																		end
																	end

																	break
																elseif v39 > 33 and v39 < 87 then
																	v39 = 107 + (((v39 == v27 and v27 or v39) <= v27 and v39 or v27) - v39 - v27)
																	v36 = 11
																elseif v39 < 33 and v39 > 12 then
																	v39 = 112 + (v[1][28][7](
																		v[1][28][11](v39, v39) + v39,
																		v39
																	) - v39)
																	v35 = v27
																elseif v39 < 74 and v39 > 29 then
																	v38 = v38(v35, v36)
																	v39 = -4294967245 + (v[1][28][15]((v[1][28][7](
																		v27 - v27,
																		14
																	))) - v27)
																end
															end

															break
														end
													end

													break
												end
											end
										else
											v11[v4[v17]] = p2[v9[v17]]
										end
									elseif v27 == 40 then
										v11[v4[v17]] = v8[v17] * v11[v9[v17]]
									else
										v11[v4[v17]] = type
									end
								elseif v27 < 43 then
									if v27 == 42 then
										v11[v5[v17]] = v11[v9[v17]] == v10[v17]
									else
										v11[v5[v17]] = v10[v17]
									end
								elseif v27 == 44 then
									v11[v5[v17]][v10[v17]] = v11[v9[v17]]
								else
									v11[v5[v17]] = v[1][5](v11[v4[v17]], v11[v9[v17]])
								end
							elseif v27 >= 53 then
								if v27 >= 57 then
									if v27 < 59 then
										if v27 == 58 then
											v11[v9[v17]] = getfenv
										else
											v11[v9[v17]] = v11[v4[v17]] % v11[v5[v17]]
										end
									elseif v27 == 60 then
										if v11[v9[v17]] ~= v8[v17] then
											v17 = v4[v17]
										end
									else
										v11[v4[v17]] = tonumber
									end
								elseif v27 >= 55 then
									if v27 == 56 then
										v11[v5[v17]] = v11[v9[v17]] + v10[v17]
									else
										v11[v9[v17]] = v11[v4[v17]] - v8[v17]
									end
								elseif v27 == 54 then
									p2[v4[v17]][v11[v5[v17]]] = v11[v9[v17]]
								else
									local v28 = v4[v17]
									local v29 = v11[v5[v17]]
									v11[v28 + 1] = v29
									v11[v28] = v29[v6[v17]]
								end
							elseif v27 < 49 then
								if v27 >= 47 then
									if v27 == 48 then
										v11[v5[v17]] = v[1][28][v9[v17]]
									else
										v11[v5[v17]] = script
									end
								elseif v27 == 46 then
									v11[v5[v17]] = game
								else
									v11[v4[v17]] = v11[v9[v17]] + v11[v5[v17]]
								end
							elseif v27 < 51 then
								if v27 == 50 then
									v11[v4[v17]] = v5
								else
									local v28 = p2[v5[v17]]
									v11[v9[v17]] = v28[1][v28[3]]
								end
							elseif v27 == 52 then
								v11[v5[v17]] = workspace
							else
								v11[v5[v17]] = v11[v4[v17]][v11[v9[v17]]]
							end
						elseif v27 < 91 then
							if v27 >= 76 then
								if v27 < 83 then
									if v27 < 79 then
										if v27 >= 77 then
											if v27 ~= 78 then
												v11[v9[v17]] = self.lN
											end
										else
											v11[v5[v17]] = v6[v17] + v11[v4[v17]]
										end
									elseif v27 < 81 then
										if v27 == 80 then
											v11[v4[v17]] = v11[v9[v17]][v8[v17]]
										else
											if v19 then
												for k, v28 in v19 do
													if not (k >= 1) then
														continue
													end

													v28[1] = v28
													v28[2] = v11[k]
													v28[3] = 2
													v19[k] = nil
												end
											end

											local v28 = v9[v17]
											v15 = v28 + 1
											return true, v28, 2
										end
									elseif v27 == 82 then
										v11[v5[v17]] = tostring
									else
										local v28 = v5[v17]
										v11[v28](v11[v28 + 1])
										v15 = v28 - 1
									end
								elseif v27 >= 87 then
									if v27 < 89 then
										if v27 == 88 then
											v11[v5[v17]] = rawset
										else
											local v28 = 48
											local v29 = nil
											local v30 = nil
											local v31 = nil

											while true do
												if v28 <= 48 then
													v28 = -8 + (v[1][28][10](v4[v17] + v28, v28, v28) + v27 - v28)
													v31 = -37
												elseif v28 >= 98 then
													local v32 = 4503599627370495
													local v33 = v29 * v32
													local v34 = 32
													local v35 = nil

													while true do
														if v34 > 9 and v34 < 35 then
															v32 = v[1][28]
															v34 = 82 + v[1][28][12](v[1][28][13](v4[v17] + v34) - v4[v17])
															v30 = 13
														elseif v34 < 32 then
															v30 = v7[v17]
															local v36 = v[1][28][9]
															local v37 = v[1][28][14]
															local _ = v4[v17] <= v34 and v34
															v34 = 79 + (v36(v37(v34, v4[v17]), v4[v17]) - v4[v17])
														elseif v34 < 84 and v34 > 35 then
															v32 = v32[v30]
															v34 = -18 + v[1][28][12](v[1][28][12](v34) + v4[v17] + v4[v17])
														elseif v34 > 82 then
															v35 = v7[v17]
															v34 = -4294967347 + (v[1][28][15]((v[1][28][9](
																v34 <= v34 and v4[v17] or v4[v17],
																v4[v17]
															))) + v27)
														elseif v34 < 82 and v34 > 32 then
															local v36 = v30 + v35
															local v37 = v4[v17]
															local v38 = 29

															while true do
																if v38 < 88 then
																	v36 = v37 <= v36
																	local v40 = v[1][28][14]

																	if v27 < v38 then
																		v38 = v4[v17] or v38
																	end

																	v38 = 57 + v40(v38 - v4[v17] + v4[v17], v4[v17])
																elseif v38 > 29 then
																	local v39 = v36 and v7[v17] or v7[v17]
																	local v40 = 45

																	while true do
																		if v40 <= 45 then
																			if v40 > 26 then
																				if v40 == 40 then
																					v39 -= v37
																					v40 = 180 + (v4[v17] - v4[v17] + v4[v17] - 40 - 40)
																				else
																					v40 = 39 + (v[1][28][13]((v[1][28][12](v40))) - v40 + v40)
																					v37 = v27
																				end
																			else
																				local v41 = v[1][28][9]
																				local _ = v[1][28][10](v40) + v4[v17] < v27 and v40
																				v40 = 23 + v41(v40, v40, v40)
																				v39 = v27
																			end
																		elseif v40 > 49 then
																			if v40 == 92 then
																				local v41 = v32 + v4[v17] + v7[v17]
																				local v43 = 17

																				while not (v43 > 60) do
																					if v43 > 17 and v43 < 107 then
																						v41 = v41 and v7[v17]
																						local v44 = v[1][28][11]
																						local _ = v27 + v43 == v4[v17] or not v27
																						v43 = -586 + (v44(v27, v4[v17]) - v4[v17])
																					elseif v43 < 60 then
																						v41 = v27 < v41
																						v43 = -3932120 + (v[1][28][14](
																							v[1][28][11](
																								v[1][28][12](v4[v17]),
																								v43
																							),
																							v4[v17]
																						) + v43)
																					end
																				end

																				local v44 = v41 or v7[v17]
																				local v45 = v33 + v44
																				local v46 = v31 + v45
																				v7[v17] = v46
																				local v47 = 71

																				while true do
																					if v47 == 71 then
																						v46 = v11
																						v45 = v4[v17]
																						v44 = v5
																						v47 = 119 + (v[1][28][8](
																							71 + 71,
																							v4[v17]
																						) - v4[v17] <= 71 and v4[v17] or v4[v17])
																					elseif v47 == 122 then
																						v46[v45] = v44
																						break
																					end
																				end

																				break
																			else
																				v32 = v32(v39)
																				local _ = v27 - v40 - v40 == v40 and v40
																				v40 = -180 + (v40 + v40)
																			end
																		else
																			v32 += v39
																			v40 = 92 + v[1][28][11](
																				v[1][28][8](
																					v27 - v40 <= v4[v17] and v40 or v4[v17],
																					v4[v17]
																				),
																				v4[v17]
																			)
																		end
																	end

																	break
																end
															end

															break
														end
													end

													break
												else
													local v32 = v[1][28][9]
													local _ = v[1][28][15](v28) == v27 and v28
													v28 = 17 + v32(v28 + v4[v17], v4[v17])
													v29 = 0
												end
											end
										end
									elseif v27 == 90 then
										v11[v9[v17]] = v8[v17] % v10[v17]
									else
										v11[v9[v17]] = setfenv
									end
								elseif v27 >= 85 then
									if v27 == 86 then
										v11[v9[v17]] = select
									else
										local v28 = v9[v17]
										local v29 = v4[v17]
										local v30 = v5[v17]

										if v29 ~= 0 then
											v15 = v28 + v29 - 1
										end

										local v31, v32

										if v29 == 1 then
											v31, v32 = v[1][43](v11[v28]())
										else
											v31, v32 = v[1][43](v11[v28](v[1][9](v15, v28 + 1, v11)))
										end

										if v30 == 1 then
											v15 = v28 - 1
										else
											local v33

											if v30 == 0 then
												v33 = v31 + v28 - 1
												v15 = v33
											else
												v33 = v28 + v30 - 2
												v15 = v33 + 1
											end

											local count = 0

											for i = v28, v33 do
												count += 1
												v11[i] = v32[count]
											end
										end
									end
								elseif v27 == 84 then
									v11[v5[v17]][v11[v4[v17]]] = v11[v9[v17]]
								else
									v11[v9[v17]] = self.eN
								end
							elseif v27 < 68 then
								if v27 < 64 then
									if v27 < 62 then
										local v28 = v12 - v14 - 1
										local v29 = v9[v17]
										local v30 = v28 < 0 and -1 or v28
										local count = 0

										for i = v29, v29 + v30 do
											v11[i] = v13[v16 + count]
											count += 1
										end

										v15 = v29 + v30
									elseif v27 == 63 then
										v11[v5[v17]] = self.DN
									else
										v11[v5[v17]] = v11[v9[v17]] - v11[v4[v17]]
									end
								elseif v27 >= 66 then
									if v27 == 67 then
										if not v19 then
											return false, v9[v17], v15
										end

										for k, v28 in v19 do
											if not (k >= 1) then
												continue
											end

											v28[1] = v28
											v28[2] = v11[k]
											v28[3] = 2
											v19[k] = nil
										end

										return false, v9[v17], v15
									else
										local v28 = v5[v17]
										v11[v28] = v11[v28](v11[v28 + 1], v11[v28 + 2])
										v15 = v28
									end
								elseif v27 == 65 then
									v11[v5[v17]] = v6[v17] ^ v11[v4[v17]]
								elseif not v11[v4[v17]] then
									v17 = v5[v17]
								end
							elseif v27 < 72 then
								if v27 >= 70 then
									if v27 == 71 then
										v11[v9[v17]] = assert
									else
										v11[v4[v17]] = rawget
									end
								elseif v27 == 69 then
									local v28 = v9[v17]
									v11[v28] = v11[v28](v11[v28 + 1])
									v15 = v28
								else
									v11[v4[v17]] = v11[v9[v17]] ~= v11[v5[v17]]
								end
							elseif v27 < 74 then
								if v27 == 73 then
									v11[v9[v17]] = self.TN
								elseif not (v10[v17] <= v11[v5[v17]]) then
									v17 = v9[v17]
								end
							elseif v27 == 75 then
								if not (v11[v9[v17]] < v10[v17]) then
									v17 = v5[v17]
								end
							else
								local v28 = v9[v17]
								local v29, v30, v31 = v22()

								if v29 then
									v11[v28 + 1] = v30
									v11[v28 + 2] = v31
									v17 = v5[v17]
								end
							end
						elseif v27 >= 106 then
							if v27 >= 114 then
								if v27 >= 118 then
									if v27 >= 120 then
										if v27 == 121 then
											local v28 = 59
											local v29 = nil
											local v30 = nil

											while true do
												if v28 == 59 then
													v28 = 93 + ((59 - v5[v17] < 59 and 59 or v5[v17]) + v5[v17] - 59)
													v30 = -2147483418
												elseif v28 == 94 then
													local v31 = v[1][28]
													local v32 = 44
													local v34 = 0 * 4503599627370495
													local v35 = 8

													while v32 == 44 do
														v31 = v31[v35]
														v32 = 2 + v[1][28][12]((v[1][28][14](
															v5[v17] + v27 - v5[v17],
															v5[v17]
														)))
													end

													local v36 = v[1][28][15]
													local v37 = v[1][28]
													local v38 = 1
													local v39 = nil

													while true do
														if v38 > 91 and v38 < 126 then
															v37 = v37[v39]
															v38 = -36 + v[1][28][14](
																v[1][28][11](
																	v[1][28][8](v38, v5[v17]) - v5[v17],
																	v5[v17]
																),
																v38,
																v27
															)
														elseif v38 < 69 then
															v38 = 108 + v[1][28][13](v[1][28][15](v27 - v27) <= v38 and v38 or v5[v17])
															v39 = 10
														elseif v38 > 108 then
															v38 = -299 + (v[1][28][11](v27 + v27 - v27, v5[v17]) + v38)
															v29 = 8
														elseif v38 > 69 and v38 < 108 then
															v39 = v[1][28]
															local _ = v5[v17] - v27 - v38 < v38 and v38
															v38 = 156 + (v38 - v27)
														elseif v38 < 91 and v38 > 1 then
															local v40 = v39[v29](v7[v17] - v5[v17] - v27, v5[v17])
															local v41 = 44

															while true do
																if v41 == 44 then
																	v37 = v37(v40, v7[v17], v5[v17])
																	v41 = -93 + v[1][28][9](
																		v[1][28][13](v5[v17]) + v27 - v5[v17],
																		v5[v17],
																		v5[v17]
																	)
																elseif v41 == 27 then
																	local v42 = v36(v37)
																	local v43 = v5[v17]
																	local v44 = 56

																	while true do
																		if v44 == 56 then
																			v31 = v31(v42, v43)
																			v42 = v7[v17]
																			local v45 = v[1][28][9]
																			local _ = 56 + v27 > 56 and 56
																			local _ = v5[v17] >= 56 and 56
																			v44 = 55 + v45(56, 56)
																		elseif v44 == 55 then
																			local v45 = v31 - v42
																			local v46 = v5[v17]
																			local v47 = 63

																			while true do
																				if v47 > 18 then
																					v45 += v46
																					v47 = -48 + (v[1][28][13]((v[1][28][14](v27 + v47))) + v47)
																				elseif v47 < 63 then
																					local v48 = v34 + v45
																					local v49 = v30 + v48
																					v7[v17] = v49
																					local v50 = 105

																					while true do
																						if v50 == 105 then
																							v49 = v11
																							local v52

																							if v5[v17] > 105 then
																								v52 = v5[v17] or 105
																							else
																								v52 = 105
																							end

																							v50 = 52 + ((v27 < v52 - 105 and v27 or 105) - 105)
																						elseif v50 == 52 then
																							v48 = v5[v17]
																							v50 = -2147483584 + v[1][28][7](
																								v[1][28][9](52 - 52 - v27),
																								v5[v17]
																							)
																						elseif v50 == 3 then
																							local v51 = v49[v48]
																							local v52 = 114

																							while true do
																								if v52 == 114 then
																									v48 = v10[v17]
																									local v54

																									if v[1][28][6](
																										v[1][28][10](114),
																										v5[v17]
																									) - 114 <= v27 then
																										v54 = 114 or v27
																									else
																										v54 = v27
																									end

																									v52 = -73 + v54
																								elseif v52 == 41 then
																									v51[v48] = v6[v17]
																									break
																								end
																							end

																							break
																						end
																					end

																					break
																				end
																			end

																			break
																		end
																	end

																	break
																end
															end

															break
														end
													end

													break
												end
											end
										else
											local v28 = p2[v5[v17]]
											v11[v9[v17]] = v28[1][v28[3]][v11[v4[v17]]]
										end
									elseif v27 == 119 then
										local v28 = p2[v9[v17]]
										v28[1][v28[3]][v11[v5[v17]]] = v11[v4[v17]]
									else
										v11[v5[v17]] = not v11[v9[v17]]
									end
								elseif v27 >= 116 then
									if v27 == 117 then
										v11[v4[v17]] = v11[v9[v17]] > v11[v5[v17]]
									else
										v11[v5[v17]] = unpack
									end
								elseif v27 == 115 then
									v[1][28][v4[v17]] = v11[v5[v17]]
								else
									if v19 then
										for k, v28 in v19 do
											if not (k >= 1) then
												continue
											end

											v28[1] = v28
											v28[2] = v11[k]
											v28[3] = 2
											v19[k] = nil
										end
									end

									local v28 = v5[v17]
									return false, v28, v28 + v9[v17] - 2
								end
							elseif v27 >= 110 then
								if v27 < 112 then
									if v27 == 111 then
										v21 = {
											[1] = v21,
											[2] = v20,
											[3] = v22,
											[5] = v18
										}
										v15 = v5[v17]
										local v28 = v[1][25](function(...)
											v[3]()

											for k, v29 in ... do
												v[3](true, k, v29)
											end
										end)
										v28(v11[v15], v11[v15 + 1], v11[v15 + 2])
										v22 = v28
										v17 = v9[v17]
									else
										v11[v5[v17]] = -v11[v9[v17]]
									end
								elseif v27 == 113 then
									local v28 = v9[v17]
									v11[v28] = v11[v28](v[1][9](v15, v28 + 1, v11))
									v15 = v28
								else
									v22 += v18
									local v28

									if v18 <= 0 then
										v28 = v20 <= v22
									else
										v28 = v22 <= v20
									end

									if v28 then
										v11[v4[v17] + 3] = v22
										v17 = v5[v17]
									end
								end
							elseif v27 < 108 then
								if v27 == 107 then
									v11[v4[v17]] = v11[v9[v17]] / v11[v5[v17]]
								else
									v11[v4[v17]] = v11[v5[v17]] * v11[v9[v17]]
								end
							elseif v27 == 109 then
								v11[v5[v17]][v10[v17]] = v6[v17]
							else
								local v28 = v5[v17]
								local v29 = v9[v17]
								local v30 = v11[v28]
								v[1][19](v11, v28 + 1, v28 + v4[v17], v29 + 1, v30)
							end
						elseif v27 >= 98 then
							if v27 < 102 then
								if v27 >= 100 then
									if v27 == 101 then
										v11[v4[v17]] = v11[v5[v17]] * v6[v17]
									else
										local v28 = v10[v17]
										local v29 = v28[3]
										local count = #v29
										local v30 = count > 0 and {} or false
										local v31 = v[4](v28, v30)
										v[1][18](v31, (v[1][24]()))
										v11[v9[v17]] = v31

										if v30 then
											for i = 1, count do
												local v32 = v29[i]
												local v33 = v32[1]
												local v34 = v32[3]

												if v33 == 0 then
													if not v19 then
														v19 = {}
													end

													local v35 = v19[v34]

													if not v35 then
														v35 = {
															[1] = v11,
															[3] = v34
														}
														v19[v34] = v35
													end

													v30[i - 1] = v35
												elseif v33 == 1 then
													v30[i - 1] = v11[v34]
												else
													v30[i - 1] = p2[v34]
												end
											end
										end
									end
								elseif v27 == 99 then
									local v28 = 111
									local v29 = 4503599627370495
									local v30 = nil
									local v31 = nil
									local games = nil

									while true do
										if v28 > 2 then
											v28 = 3 + (v[1][28][12](v[1][28][15](v28) + v5[v17]) - v5[v17])
											games = 46
										elseif v28 < 111 then
											local v32 = 31
											local v33 = 0

											while not (v32 > 114) do
												if v32 < 114 and v32 > 31 then
													local v34 = v[1][28][9]
													local v35 = v[1][28][9]
													local _ = v[1][28][10](v5[v17]) < v32 and v32
													v32 = 75 + v34((v35(v32)))
													v30 = 14
												elseif v32 < 41 then
													v33 *= v29
													local v34 = v[1][28][11]
													local _ = v5[v17] == v27 and v32
													v32 = 115 + (v34(v32 - v32, v5[v17]) - v5[v17])
												elseif v32 > 41 and v32 < 116 then
													v29 = v[1][28]
													local v35

													if v32 < v27 then
														v35 = v5[v17] or v32
													else
														v35 = v32
													end

													v32 = -87 + (v35 - v5[v17] + v32 - v27)
												end
											end

											local v34 = v29[v30]
											local v35 = 29
											local v36 = nil

											while true do
												if v35 > 33 then
													if v35 <= 87 then
														if v35 == 87 then
															v36 = v[1][28]
															local v38

															if v[1][28][11](v27, v5[v17]) + v5[v17] > 87 then
																v38 = 87 or v27
															else
																v38 = v27
															end

															v35 = 86 + (v38 - v27)
														else
															v31 = 10
															local _ = v[1][28][9](
																v[1][28][8](v5[v17], v5[v17]),
																v35,
																v35
															) + v35 == v35 or not v35
															v35 = -41 + v35
														end
													elseif v35 == 123 then
														local v37 = 107
														local v38 = 12

														while true do
															if v37 > 78 then
																if v37 >= 107 then
																	v31 = v31[v38]
																	v37 = -4294967004 + v[1][28][11](
																		v[1][28][13]((v[1][28][9](v5[v17]))) - v37,
																		v5[v17]
																	)
																else
																	local v39 = 1
																	local v40 = 15

																	while true do
																		if v39 == 1 then
																			v38 = v38[v40]
																			v39 = 107 + v[1][28][13]((v[1][28][15]((v[1][28][14](
																				1 - 1,
																				1,
																				v5[v17]
																			)))))
																		elseif v39 == 108 then
																			v40 = v5[v17]
																			v39 = -8 + (v[1][28][8](
																				v[1][28][6](v27, v5[v17]),
																				v5[v17]
																			) + 108 - 108)
																		elseif v39 == 91 then
																			local v41 = v40 ~= v5[v17] and v7[v17]
																			local v42 = 96

																			while not (v42 < 96) do
																				if not (v42 > 63) then
																					continue
																				end

																				v41 = v41 or v7[v17]
																				v42 = -4294967037 + v[1][28][15](v27 + v5[v17] - v5[v17] + v42)
																			end

																			local v43 = v41 + v7[v17]
																			local v44 = 92

																			while true do
																				if v44 == 92 then
																					v38 = v38(v43)
																					local v46

																					if v[1][28][13](v[1][28][14](
																						v27,
																						92,
																						v27
																					) <= 92 and 92 or v27) > 92 then
																						v46 = v5[v17] or v27
																					else
																						v46 = v27
																					end

																					v44 = -88 + v46
																				elseif v44 == 11 then
																					local v45 = v38 + v27
																					local v46 = 34

																					while true do
																						if v46 > 93 then
																							v34 = v34(v30)

																							if v[1][28][11](
																								v46 + v5[v17],
																								v5[v17]
																							) - v5[v17] == v46 or not v46 then
																								v46 = v5[v17]
																							end

																							v46 = -25 + v46
																						elseif v46 < 25 and v46 > 23 then
																							games += v33
																							local v48 = v[1][28][6]

																							if v46 < v[1][28][14](v46 + v5[v17]) then
																								v46 = v5[v17] or v46
																							end

																							v46 = 21 + v48(v46, v5[v17])
																						elseif v46 < 24 then
																							v7[v17] = games
																							local v47 = 109

																							while true do
																								if v47 > 104 then
																									games = v11
																									v47 = 54 + v[1][28][6](
																										v[1][28][12](v[1][28][10](
																											v47,
																											v5[v17],
																											v47
																										) + v47),
																										v5[v17]
																									)
																								elseif v47 < 109 then
																									games[v5[v17]] = game
																									break
																								end
																							end

																							break
																						elseif v46 > 36 and v46 < 93 then
																							v30 = v30(v36)
																							v46 = -86 + v[1][28][11](
																								v[1][28][9]((v46 <= v46 and v46 or v5[v17]) + v46),
																								v5[v17]
																							)
																						elseif v46 < 34 and v46 > 24 then
																							v45 = v7[v17]
																							v46 = -64 + (v[1][28][9](
																								v[1][28][13](v46) + v27,
																								v5[v17],
																								v27
																							) + v27)
																						elseif v46 > 34 and v46 < 51 then
																							v36 = v36(v31, v45)
																							v46 = -102 + (v[1][28][7](
																								v46 + v46 + v46,
																								v5[v17]
																							) + v27)
																						elseif v46 > 25 and v46 < 36 then
																							v31 = v31(v45)
																							local v48

																							if v[1][28][10]((v[1][28][11](
																								v27,
																								v5[v17]
																							))) == v5[v17] or not v27 then
																								v48 = v46
																							else
																								v48 = v27
																							end

																							v46 = -108 + (v48 + v46)
																						elseif v46 > 51 and v46 < 118 then
																							v33 += v34
																							v46 = -99 + (v[1][28][10]((v[1][28][12](v46 + v27))) + v27)
																						end
																					end

																					break
																				end
																			end

																			break
																		end
																	end

																	break
																end
															else
																v38 = v[1][28]
																v37 = -93 + (v[1][28][13](v5[v17]) + v5[v17] + v27 + v37)
															end
														end

														break
													else
														v30 = v30[v36]
														v35 = 31 + v[1][28][11](
															v[1][28][12]((v[1][28][7](v[1][28][12](v5[v17]), v5[v17]))),
															v5[v17]
														)
													end
												elseif v35 <= 12 then
													v31 = v[1][28]
													local _ = v[1][28][11](v27 - v35, v5[v17]) <= v35 and v35
													v35 = 111 + (v35 < v35 and v27 or v35)
												elseif v35 >= 33 then
													v36 = v36[v31]
													local _ = v[1][28][13]((v[1][28][11](v27, v5[v17]))) + v35 <= v35 and v35
													v35 = -21 + v35
												else
													v30 = v[1][28]
													v35 = 87 + v[1][28][13](v35 - v35 - v35 + v27)
													v36 = 9
												end
											end

											break
										end
									end
								else
									local v28 = v5[v17]
									local v29 = v4[v17]
									local v30 = v11[v28]
									v[1][19](v11, v28 + 1, v15, v29 + 1, v30)
								end
							elseif v27 >= 104 then
								if v27 == 105 then
									v11[v9[v17]] = v[1][12](v4[v17])
								elseif v11[v9[v17]] then
									v17 = v5[v17]
								end
							elseif v27 == 103 then
								if not (v10[v17] < v11[v9[v17]]) then
									v17 = v5[v17]
								end
							else
								v11[v9[v17]] = v11
							end
						elseif v27 < 94 then
							if v27 < 92 then
								v11[v9[v17]] = typeof
							elseif v27 == 93 then
								if not (v11[v5[v17]] < v11[v4[v17]]) then
									v17 = v9[v17]
								end
							else
								local v28 = v9[v17]
								v15 = v28 + v4[v17] - 1
								v11[v28] = v11[v28](v[1][9](v15, v28 + 1, v11))
								v15 = v28
							end
						elseif v27 >= 96 then
							if v27 == 97 then
								v11[v9[v17]] = next
							else
								v11[v5[v17]] = {}
							end
						elseif v27 == 95 then
							v11[v9[v17]] = self.xN
						else
							v11[v5[v17]] = v11[v4[v17]]
						end

						v17 += 1
					end
				end)

				if v23 then
					if v24 then
						if v26 == 1 then
							return v11[v25]()
						end

						return v11[v25](v[1][9](v15, v25 + 1, v11))
					elseif v25 then
						return v[1][9](v26, v25, v11)
					end
				else
					if v19 then
						for k, v27 in v19 do
							if not (k >= 1) then
								continue
							end

							v27[1] = v27
							v27[2] = v11[k]
							v27[3] = 2
							v19[k] = nil
						end
					end

					if v[1][26](v24) == "string" then
						if v[1][31](v24, ":(%d+)[:\r\n]") then
							v[1][11]("Luraph Script:" .. (v3[v17] or "(internal)") .. ": " .. v[1][2](v24), 0)
						else
							v[1][11](v24, 0)
						end
					else
						v[1][11](v24, 0)
					end
				end
			end
		end

		return p
	end,
	gy = function(self, list)
		local v, v2 = list[1][29]("<d", list[1][27], list[1][4])

		if list[1][16] == list[1][8] then
			return nil
		end

		for i = 67, 158, 76 do
			if i == 143 then
				return { v }
			end

			if i == 67 then
				list[1][4] = v2
			end
		end

		return nil
	end,
	b = function(self, list, _)
		local v = -2033076126 + self.ax(
			(list[22295] > self.h[8] and list[27489] or self.h[4]) - list[16947] + self.h[9],
			list[3404]
		)
		list[28480] = v
		return v
	end,
	fx = function(self, list)
		if list[34] == list[10] then
			self:sx(list)
		end
	end,
	Px = function(self, _, list)
		local v = 153 + (self.vx((self.Lx(list[29584] + list[14276]))) - list[24659])
		list[28801] = v
		return v
	end,
	Fy = function(self, list, p, list2)
		list2[34] = function()
			local v = { list2, list2[23] }
			local v2 = nil
			local v3 = nil

			for i = 65, 314, 52 do
				if i > 117 and i < 221 then
					self:a(v2, v)
				elseif i < 117 then
					v3, v2 = v[1][29]("<I4", v[1][27], v[1][4])
				else
					if i > 169 then
						return v3
					end

					if i < 169 and i > 65 then
						local v4 = self:V(v)

						if v4 ~= nil then
							return self.z(v4)
						end
					end
				end
			end
		end

		if list[17564] then
			return list[17564]
		end

		return (self:hy(list, p))
	end,
	iy = function(self, p, p2, p3, list)
		if p3 == 162 then
			list[2] = p2
			return 7137
		end

		self:By(p, list)
		return 972
	end,
	ix = function(self, _, list)
		return list[27030]
	end,
	P = function(self, _, list, list2)
		list2[22] = nil
		local v = 1

		while v ~= 108 do
			list2[21] = self.CN

			if list[20291] then
				v = list[20291]
			else
				list[11206] = 73 + (self.qN(list[14121], list[5748]) - self.h[5] + self.h[9] > list[16478] and list[3404] or list[3404])
				v = -4294967043 + (self.ox((self.vx(list[16478] - list[5748]))) - list[8694])
				list[20291] = v
			end
		end

		list2[22] = self.T

		for i = 0, 255 do
			self:c(list2, i)
		end

		list2[23] = {}
		list2[24] = nil
		return v
	end,
	Qx = function(self, list, _)
		return list[29584]
	end,
	h = {
		46670,
		3032944221,
		3999356651,
		3303404712,
		3599606670,
		704751911,
		748074511,
		1972490546,
		335042392
	},
	hx = function(self, p, p2, list, p3, p4)
		if p < 168 then
			return 59895, #list
		end

		if p > 168 then
			list[p4 + 3] = 2
			return 16106, p4
		end

		if p < 251 and p > 85 then
			self:Vy(list, p4, p3, p2)
			return 59895, p4
		else
			return nil, p4
		end
	end,
	j = function(self, _, list)
		local v = 72 + self.nx(self.dx(list[18522] - self.h[7]) + list[5748], self.h[9], list[11301])
		list[31729] = v
		return v
	end,
	yx = function(self, list, list2, _)
		list[28][10] = self.nx

		if list2[24659] then
			return list2[24659]
		end

		local v = -4240441264 + self.nx((self._x((self.qN(list2[6770] - list2[26683], list2[2340])))))
		list2[24659] = v
		return v
	end,
	Jy = function(self, p, p2, p3, list)
		local v = nil
		local v2 = nil

		for i = 26, 183, 28 do
			if i <= 26 then
				v = p / 4
			elseif i == 82 then
				list[1][40][p] = v2
				break
			else
				v2 = {
					[3] = v - v % 1,
					[1] = p % 4
				}
			end
		end

		p2[p3] = v2
	end,
	By = function(self, p, list)
		list[8] = p
	end,
	Wy = function(self, p, _, list)
		list[1][4] = list[1][4] + p
		return 50
	end,
	_x = bit32.bor,
	Hy = function(self, _, list, _, _, _)
		return {
			nil,
			self.A,
			nil,
			nil,
			self.A,
			nil,
			nil,
			nil,
			nil,
			nil,
			nil,
			[5] = list[1][38]()
		}, nil, nil, nil
	end,
	Dy = function(self, p)
		return p * 128
	end,
	g = error,
	ty = function(self, _, list)
		return (list[3]())
	end,
	E = function(self, list, _)
		local v = -77 + (((self.Vx(self.h[9], list[2340]) ~= self.h[2] and self.h[8] or list[26683]) ~= self.h[6] and list[20291] or self.h[4]) <= list[28480] and list[28480] or list[28480])
		list[4205] = v
		return v
	end,
	Oy = function(self, p, p2, p3)
		if p3 > 108 then
			local v, v2 = self:Zy(p2, p3)
			return v2, 53842, v, p
		end

		local v, v2 = self:Xy(p3, p)
		return p2, 53842, v2, v
	end,
	S = string,
	y = function(self, list, _)
		return list[28480]
	end,
	dx = bit32.countrz,
	tx = function(self, _, list, list2)
		list2[28][8] = self.O.rrotate

		if list[5117] then
			return list[5117]
		end

		list[17720] = -43 + ((list[4205] - self.h[1] + self.h[4] > self.h[3] and list[31729] or list[29584]) + list[12509])
		local v = -46776 + ((self.nx(self.ax(list[22969], list[2340]), list[17564], list[1070]) >= list[12509] and list[18522] or self.h[1]) + list[11301])
		list[5117] = v
		return v
	end,
	nx = bit32.band,
	by = function(self, _, p, _, _, _, p2, _, _, list, _, p3, list2)
		local v = 108
		local v2 = nil
		local v3 = nil

		repeat
			local v4
			p3, v2, v, v3, p2, v4, p = self:Qy(p, v, list2, p3, list, v2, v3, p2)
		until v4 ~= 7847 and v4 == 3688

		local v4 = 19

		while true do
			if v4 < 61 then
				list2[3] = v3
				v4 = 86
			elseif v4 < 120 and v4 > 61 then
				v4 = 61

				for i = 1, p do
					local v5 = nil
					local v6 = 91

					repeat
						local v7
						v7, v6, v5 = self:fy(v5, v3, i, list, v6)
					until v7 == 422
				end
			elseif v4 > 86 then
				local v5 = list[1][38]() - 85036
				return nil, nil, p2, nil, v5, v4, list[1][12](v5), p, p3, v2
			elseif v4 < 86 and v4 > 19 then
				v4 = self:Uy(list, list2, v4)
			end
		end
	end,
	o = function(self)
		return { 145 }
	end,
	gN = getmetatable,
	Sx = function(self, p, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15, p16, p17, list, p18, p19, p20, p21)
		while not (p16 > 19) do
			if not (p16 < 86) then
				continue
			end

			p6[p10] = p19
			p16 = 86
		end

		p11[p10] = p5
		p18[p10] = p3

		for i = 92, 188, 48 do
			if i > 92 and i < 188 then
				local v
				p15, v, p21 = self:_y(p4, p7, p15, p2, p3, p21, p10, p18, list, p17)

				if v ~= nil then
					return p15, p16, { self.z(v) }, p21
				end
			elseif i > 140 then
				if p14 == 2 then
					if list[1][39] then
						local v = 122
						local v2 = nil

						while not (v <= 17) do
							v2 = list[1][1][p8]
							v = 17
						end

						local count = #v2
						v2[count + 1] = p4
						self:ay(p10, 87, v2, count)
						self:ay(p10, 160, v2, count)
					else
						p[p10] = list[1][1][p8]
					end
				elseif p14 == 1 then
					p12[p10] = p8
				elseif p14 == 3 then
					p12[p10] = p10 + p8
				elseif p14 == 6 then
					p12[p10] = p10 - p8
				elseif p14 == 4 then
					local count = #list[1][46]
					list[1][46][count + 1] = p
					local v = 107

					repeat
						local v2
						v2, v = self:oy(count, p8, list, v, p10)
					until v2 == 26358
				end
			elseif i < 140 then
				if p20 == 2 then
					self:Fx(p4, p10, list, p5, p13)
				elseif p20 == 1 then
					p11[p10] = p5
				elseif p20 == 3 then
					p11[p10] = p10 + p5
				elseif p17 == 135 then
					if list[1][34] == p5 then
						local v = self:Cx(p9)
						return p15, p16, { self.z(v) }, p21
					end

					if p20 == 6 then
						p11[p10] = p10 - p5
					elseif p20 == 4 then
						self:qx(list, self:qx(list, nil, p13, p5, 102, p10), p13, p5, 180, p10)
					end
				else
					local v = list[1]
					p21 = list[1][32]
					v[38] = p9 * true
				end
			end
		end

		return p15, p16, nil, p21
	end,
	Ix = function(self, p, p2, p3, p4, p5, list, p6)
		if p6 > 73 then
			p, p3, p2 = self:Hx(list, p3, p, p2, p4, p5)
			return p3, p2, nil, p5, p
		end

		if p6 < 85 then
			return p3, p2, 64199, list[1][33](), p
		end

		return p3, p2, nil, p5, p
	end,
	qN = bit32.rrotate,
	Xy = function(self, _, _)
		return {}, 91
	end,
	SN = string.match,
	M = function(self, list, list2, p)
		while true do
			if p <= 79 then
				if p <= 48 then
					p = self:U(list, list2, p)
				elseif p > 78 then
					list[11] = self.g

					if list2[28480] then
						p = self:y(list2, p)
					else
						p = self:b(list2, p)
					end
				else
					list[8] = function(p2, p3, p4, _)
						local v = { list }

						if p3 < p4 then
							return
						end

						local v2 = p3 - p4 + 1

						if v2 >= 8 then
							return
								p2[p4],
								p2[p4 + 1],
								p2[p4 + 2],
								p2[p4 + 3],
								p2[p4 + 4],
								p2[p4 + 5],
								p2[p4 + 6],
								p2[p4 + 7],
								v[1][8](p2, p3, p4 + 8)
						end

						if v2 >= 7 then
							return
								p2[p4],
								p2[p4 + 1],
								p2[p4 + 2],
								p2[p4 + 3],
								p2[p4 + 4],
								p2[p4 + 5],
								p2[p4 + 6],
								v[1][8](p2, p3, p4 + 7)
						end

						if v2 >= 6 then
							return
								p2[p4],
								p2[p4 + 1],
								p2[p4 + 2],
								p2[p4 + 3],
								p2[p4 + 4],
								p2[p4 + 5],
								v[1][8](p2, p3, p4 + 6)
						end

						if v2 >= 5 then
							return p2[p4], p2[p4 + 1], p2[p4 + 2], p2[p4 + 3], p2[p4 + 4], v[1][8](p2, p3, p4 + 5)
						end

						if v2 >= 4 then
							return p2[p4], p2[p4 + 1], p2[p4 + 2], p2[p4 + 3], v[1][8](p2, p3, p4 + 4)
						end

						if v2 >= 3 then
							return p2[p4], p2[p4 + 1], p2[p4 + 2], v[1][8](p2, p3, p4 + 3)
						end

						if v2 >= 2 then
							return p2[p4], p2[p4 + 1], v[1][8](p2, p3, p4 + 2)
						end

						return p2[p4], v[1][8](p2, p3, p4 + 1)
					end

					if list2[22295] then
						p = list2[22295]
					else
						list2[2442] = -46 + (self.nx(self.dx(self.h[3]) - list2[8694]) >= self.h[1] and list2[8694] or self.h[5])
						p = -1224256205 + self.ox(self.Vx(p, list2[2340]) - self.h[8] + self.h[7])
						list2[22295] = p
					end
				end
			elseif p <= 85 then
				list[9] = function(p2, value, list3)
					local v = { list }
					local v2 = value or 1
					local v3 = p2 or #list3

					if v3 - v2 + 1 > 7997 then
						return v[1][8](list3, v3, v2)
					end

					return v[1][3](list3, v2, v3)
				end

				if list2[27489] then
					p = list2[27489]
				else
					list2[3404] = 5971847136 + (self.dx(list2[2442]) - self.h[3] - self.h[8] + list2[2442])
					p = -180115291 + (self.ax(list2[12509] + self.h[3] + list2[12509], list2[2340]) - list2[8694])
					list2[27489] = p
				end
			elseif p == 89 then
				list[14] = self.e
				list[15] = self.hN
				list[16] = nil
				return 89
			else
				list[12] = self.l
				list[13] = select

				if list2[6559] then
					p = list2[6559]
				else
					p = 59 + self.vx((self.vx(self.ox(p) < list2[16478] and self.h[2] or self.h[7])))
					list2[6559] = p
				end
			end
		end
	end,
	Lx = bit32.bxor,
	py = function(self, p, _, _, list, p2)
		for _ = 1, list[1][34]() do
			local v = nil
			local v2 = nil

			for i = 31, 93, 31 do
				if i > 31 then
					if i == 93 then
						v2 = self:ky(v, v2)
					else
						v = list[1][34]()
					end
				else
					self:uy()
				end
			end

			for i = 108, 212, 25 do
				if i > 133 then
					p += 1
					break
				end

				if i < 158 and i > 108 then
					self:Gy()
				elseif i < 133 then
					if v % 2 == 0 then
						p2[p] = v2 - v2 % 1
					else
						local v3 = nil

						for i2 = 111, 224, 42 do
							local v4
							v4, p, v3 = self:ry(v2, p, list, i2, p2, v3)

							if v4 == 13136 then
								break
							end
						end
					end
				end
			end
		end

		return list[1][38](), 96, p
	end,
	r = function(self, list, _)
		local v = -346790 + self.jx(
			(list[2340] < self.h[3] and self.h[2] or list[16947]) + self.h[8] + list[2340],
			list[2340]
		)
		list[8694] = v
		return v
	end,
	Bx = function(self, _, list)
		local v = -4294817729 + self.ax(self.ox(list[32181]) - list[22295] - list[5748], list[3404])
		list[27030] = v
		return v
	end,
	mN = function(self)
		local v = {}
		local v2 = self:k(nil, v)
		local v3, v4, v5, v6 = self:Mx(
			nil,
			v2,
			v,
			self:Yy(
				v,
				self:ey(
					self:ly(
						v,
						self:_(
							v2,
							self:L(
								v2,
								v,
								(self:K(
									v,
									self:P(self:t(v2, v, (self:M(v, v2, (self:f(self:s(v2, v, nil), v))))), v2, v),
									v2
								))
							),
							v
						),
						v2
					),
					v
				),
				v2
			),
			nil,
			nil
		)
		local v7, _, _ = self:Kx(v5, v6, v3, v4, v2, v)

		if v7 == nil then
			return
		else
			return self.z(v7)
		end
	end,
	H = bit32.rshift,
	dy = function(self, p, p2, p3, p4)
		if p3 == 45 then
			p4[p + 3] = 11
			return 50455
		end

		if p3 ~= 36 then
			return nil
		end

		self:Ky(p2, p, p4)
		return 8074
	end,
	sx = function(self, list)
		list[16] = list[38]
		list[43] = -list[32]
	end,
	kx = function(self, p, list, p2)
		p2[p] = list[1][47]()
	end,
	ey = function(self, _, list)
		list[38] = nil
		list[39] = nil
		list[40] = nil
		return 27
	end,
	s = function(self, list, list2, _)
		list2[6] = nil
		local v = 92

		while true do
			if v == 92 then
				v = self:G(92, list2, list)
			elseif v == 11 then
				list2[2] = self.C

				if list[16947] then
					v = list[16947]
				else
					v = 4731680608 + (self.nx(self._x(self.h[7], self.h[4]), self.h[9]) - self.h[7] - self.h[3])
					list[16947] = v
				end
			elseif v == 110 then
				list2[3] = unpack

				if list[8694] then
					v = list[8694]
				else
					v = self:r(list, 110)
				end
			elseif v == 117 then
				v = self:Q(117, list, list2)
			elseif v == 80 then
				list2[5] = self.q

				if list[31896] then
					v = list[31896]
				else
					v = 191 + (self.ax(self.Lx((self.dx(self.h[3]))), list[2340]) - list[12509])
					list[31896] = v
				end
			elseif v == 111 then
				self:J(list2)
				list2[7] = pcall
				list2[8] = nil
				return 111
			end
		end
	end,
	f = function(self, _, list)
		list[9] = nil
		list[10] = nil
		list[11] = nil
		list[12] = nil
		list[13] = nil
		list[14] = nil
		return 78
	end,
	Ey = function(self, _, list)
		return #list
	end,
	q = bit32.bxor,
	Xx = function(self) end,
	W = type,
	Vx = bit32.lrotate,
	Gx = function(self, list)
		list[1][1] = self.A
	end,
	mx = function(self, p, list, p2, p3, p4)
		if p < 118 then
			while p4 do
				p3 = self:xx(list, p3, p4)
			end

			return p, 65268, p3
		else
			if not (p > 93) then
				return p, nil, p3
			end

			while p2 do
				local v = list[1]
				local v2 = list[1]
				local v3 = list[1][43]
				v[37] = p4
				v2[32] = v3
			end

			return 93, 7619, p3
		end
	end,
	Ay = function(self, list)
		local v = list[1][38]()
		local v2 = 95
		local v3

		repeat
			v3, v2 = self:wy(v, list, v2)
		until v3 ~= 60327 and v3 ~= nil

		return { self.z(v3) }
	end,
	Qy = function(self, p, p2, p3, p4, p5, p6, p7, p8)
		if p2 > 91 then
			if p2 <= 96 then
				local v, v2 = self:Iy(p6, p7, p, p5)
				return p4, v, p2, v2, p8, 3688, p
			end

			local v, v2, v3, v4 = self:Oy(p4, p8, p2)

			if v2 == 53842 then
				return v4, p6, v3, p7, v, 7847, p
			end

			return v4, p6, v3, p7, v, nil, p
		else
			if p2 ~= 69 then
				return p4, p6, self:zy(p3, p2, p4), p7, p8, 7847, p
			end

			local v, v2, v3 = self:py(p8, p, p2, p5, p4)
			return p4, p6, v2, p7, v3, 7847, v
		end
	end,
	I = bit32.countrz,
	oy = function(self, p, p2, list, p3, p4)
		if p3 <= 78 then
			list[1][46][p + 3] = p2
			return 26358, p3
		end

		list[1][46][p + 2] = p4
		return nil, 78
	end,
	ox = bit32.bnot,
	Nx = function(self, p, list, list2)
		list[28][12] = self.Z
		list[28][14] = self.X

		if list2[27030] then
			return (self:ix(p, list2))
		end

		return (self:Bx(p, list2))
	end,
	xy = function(self, p, list)
		if list[1][36] <= p then
			return { p - list[1][10] }
		end

		return 28319
	end,
	Q = function(self, p, list, list2)
		list2[4] = 1

		if list[12509] then
			return list[12509]
		end

		return (self:p(list, p))
	end
}):mN()(...)