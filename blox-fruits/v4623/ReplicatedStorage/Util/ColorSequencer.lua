local function createPallet(p, value, value2, value3)
	local v = p or { Color3.new(1, 1, 1) }
	local v2 = value3 or 0
	local v3 = value2 or 0
	local count = #v
	local v4 = count
	local v5 = (value or 1) / count
	assert(count <= 20, "ColorKeypoints limit reached, please remove a couple colors from the pallet!")
	local v6 = 20 - count

	if v6 - (count - 1) * v2 < 0 then
		local v7 = v2
		v2 = math.floor(v6 / (count - 1))
		warn(string.format("Limiting the Smooth Damp from %d to %d as maximum Keypoints reached!", v7, v2))
	end

	local total = 0
	local pallet2 = {}

	for i = 1, count do
		local v8 = v[1]
		local v9 = {}

		if i < count then
			for _ = 1, v2 do
				v4 += 1
				table.insert(v9, v8)
				total += v5
			end
		end

		total += v3 * (i - 1) / (count - 1)
		table.insert(pallet2, {
			v[i],
			v9,
			-v3 * (i - 1) / (count - 1),
			v8,
			1
		})
	end

	return {
		finished = false,
		pallet = pallet2,
		alpha = 0,
		time = 0,
		duration = total,
		getSegments = function(p2)
			local count2 = 0

			for _, v8 in pairs(p2.pallet) do
				count2 += 1

				for _, _ in pairs(v8[2]) do
					count2 += 1
				end
			end

			return count2
		end,
		toColor3 = function(p2)
			local v8 = p2.pallet[1]
			local _ = p2.pallet[#p2.pallet]
			local v9 = v8[4]

			if v8[5] == count and v8[3] >= 1 then
				p2.finished = true
			end

			return v9
		end,
		toColorSequence = function(p2, p3)
			local v8 = 1 / (count - 1) / (v2 + 1)
			local colorSequenceKeypoints = {}

			for i = 1, count do
				local v9 = (i - 1) / (count - 1)
				local pallet = p2.pallet
				local v10

				if p3 then
					v10 = count - (i - 1) or i
				else
					v10 = i
				end

				local v11 = pallet[v10]
				local v12 = v11[4]
				table.insert(colorSequenceKeypoints, ColorSequenceKeypoint.new(v9, v12))

				for i2 = 1, #v11[2] do
					local v13 = v8 * i2 * (p3 and -1 or 1)
					local v14 = v11[2][i2]
					table.insert(colorSequenceKeypoints, ColorSequenceKeypoint.new(v9 + v13, v14))
				end
			end

			if p3 then
				table.sort(colorSequenceKeypoints, function(a, b)
					return a.Time < b.Time
				end)
			end

			return ColorSequence.new(colorSequenceKeypoints)
		end,
		refresh = function(self)
			self.time = 0
			self.alpha = 0

			for i = 1, #self.pallet do
				self.pallet[i][3] = -v3 * (i - 1) / (#self.pallet - 1)
				self.pallet[i][5] = 1
			end

			self:update()
		end,
		update = function(self, value4)
			if self.finished then
				return
			end

			local v8 = value4 or 0
			local count2 = 0

			for k, _ in pairs(self.pallet) do
				local v9 = self.pallet[k]
				local v10 = math.clamp(v9[3] / v5, 0, 1)
				local v11 = v9[5] < count

				if v11 then
					local v12 = v9[5]
					local v13 = self.pallet[v12][1]
					local v14 = k + 1
					local v15 = self.pallet[v14]
					local v16 = k - 1
					local _ = self.pallet[v16]

					if v15 then
					end

					local v17 = v9[5] + 1
					v9[4] = v13:Lerp(self.pallet[v17][1], v10)

					for i = 1, count - 1 do
						local v18 = self.pallet[i]
						local v19 = self.pallet[i + 1]

						for i2 = 1, v2 do
							local v20 = i2 / (v2 + 1)
							v18[2][i2] = v18[4]:Lerp(v19[4], v20)
						end
					end
				end

				if v10 == 1 then
					if v11 then
						v9[3] = 0
						v9[5] += 1
					else
						count2 += 1
					end
				else
					v9[3] += v8
				end
			end

			self.time += v8
			self.alpha = self.time / self.duration

			if count2 == v4 then
				self.finished = true
			end
		end
	}
end

return createPallet