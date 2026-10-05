local createVector = vector.create
local BoltGen = {
	layout = function(value, value2, value3, max)
		local v = math.clamp(math.floor(value or 12), 2, max)
		local v2 = math.max(2, (math.floor(v / 2)))
		local v3

		if (value2 or 0) >= 0.5 and (value3 or 0) > 0 then
			local v4 = max - v

			if v4 >= 4 and math.floor(v4 / v2) < 2 then
				v2 = math.max(4, (math.min(v2, (math.floor(v4 / 2)))))
			end

			v3 = math.min(6, (math.floor(v4 / v2)))

			if v3 < 0 then
				v3 = 0
			end
		else
			v3 = 0
		end

		return v + v3 * v2, v, v2, v3
	end,
	basis = function(p)
		if p.Magnitude < 0.0001 then
			return createVector(1, 0, 0), createVector(0, 0, 1)
		end

		local unit = p.Unit
		local unit2 = unit:Cross(math.abs(unit.Y) < 0.99 and createVector(0, 1, 0) or createVector(1, 0, 0)).Unit
		return unit2, (unit:Cross(unit2))
	end
}
local displace

displace = function(p, p2, p3, p4, p5, p6, p7)
	if p3 - p2 <= 1 then
		return
	end

	local v = math.floor((p2 + p3) / 2)
	local v2 = (v - p2) / (p3 - p2)
	p[v] = p[p2]:Lerp(p[p3], v2) + p6 * ((math.random() * 2 - 1) * p4) + p7 * ((math.random() * 2 - 1) * p4)
	local v3 = p4 * p5
	displace(p, p2, v, v3, p5, p6, p7)
	displace(p, v, p3, v3, p5, p6, p7)
end

local function buildPolyline(list, p, p2, p3, p4, _decay, p5, p6, p7, value)
	local v = p3 - p2
	local magnitude = v.Magnitude

	for i = 1, p + 1 do
		list[i] = p2 + v * ((i - 1) / p)
	end

	if p6 and p4 ~= 0 then
		local basis, v2 = BoltGen.basis(v)
		displace(list, 1, p + 1, p4, _decay, basis, v2)
	end

	if p5 ~= 0 and magnitude > 0.0001 then
		local vector2 = (p7 or createVector(0, 1, 0)) * (p5 >= 0 and -1 or 1)
		local v2 = math.max(value or 1, 0)
		local v3 = math.abs(p5) * magnitude

		if v2 >= 1 then
			for i = 2, p do
				local v4 = (i - 1) / p
				local v5 = 4 * v4 * (1 - v4)

				if v2 ~= 1 then
					v5 ^= v2
				end

				list[i] += vector2 * (v3 * v5)
			end
		else
			local v4 = v * (1 / magnitude)
			local v5 = vector2 - v4 * vector2:Dot(v4)

			if v5.Magnitude > 0.0001 then
				local unit = v5.Unit
				local v6 = (magnitude * magnitude * 0.25 + v3 * v3) / (2 * v3)
				local v7 = math.acos((math.clamp((v6 - v3) / v6, -1, 1)))
				local v8 = p2 + v * 0.5 + unit * (v3 - v6)

				for i = 2, p do
					local v9 = (i - 1) / p
					local v10 = p2 + v * v9
					local v11 = (2 * v9 - 1) * v7
					local v12 = v8 + (v4 * math.sin(v11) + unit * math.cos(v11)) * v6
					local v13

					if v2 >= 0.5 then
						v13 = v12:Lerp(v10 + unit * (v3 * 4 * v9 * (1 - v9)), (v2 - 0.5) * 2)
					else
						v13 = (v10 + unit * v3):Lerp(v12, v2 * 2)
					end

					list[i] += v13 - v10
				end
			end
		end
	end
end

local function writeSegments(data, list, p, p2, p3)
	local v = p3

	for i = 1, p do
		local v2 = list[i]
		local v3 = list[i + 1]
		local magnitude = (v3 - v2).Magnitude
		local v4 = p2 + i
		data.revealDist[v4] = v

		if magnitude > 0.0001 then
			data.rollCFs[v4] = CFrame.lookAt((v2 + v3) * 0.5, v3)
		else
			data.rollCFs[v4] = CFrame.new((v2 + v3) * 0.5)
		end

		data.segLen[v4] = math.max(magnitude, 0.05)
		v += magnitude
	end

	return v - p3
end

function BoltGen:roll(data, p, p2, p3)
	local curSegs = math.clamp(data._segCount or self.mainSegs, 2, self.mainSegs)
	local magnitude = (p2 - p).Magnitude
	local v2 = (data._amplitude or 0) * magnitude
	local _shapeMode = data._shapeMode or "Jitter"
	buildPolyline(
		self.ptBuf,
		curSegs,
		p,
		p2,
		v2,
		data._decay or 0.5,
		data._sag or 0,
		_shapeMode ~= "Scroll",
		data._sagDirWorld,
		data._sagShape
	)

	if _shapeMode ~= "Jitter" then
		for i = 1, curSegs + 1 do
			self.basePtBuf[i] = self.ptBuf[i]
		end

		local basis, scrollV = BoltGen.basis(p2 - p)
		self.scrollU = basis
		self.scrollV = scrollV
		self.scrollDist = magnitude
	end

	self.curSegs = curSegs
	local v3 = writeSegments(self, self.ptBuf, curSegs, 0, 0)

	for i = curSegs + 1, self.mainSegs do
		self.rollCFs[i] = p3
		self.segLen[i] = 0.05
		self.revealDist[i] = 1e999
	end

	local count = 0

	for i = 1, self.forkSlots do
		local v4 = self.mainSegs + (i - 1) * self.forkSegs
		local v5 = self.slotDepth[i]
		local v6 = false

		if (data._forkChance or 0) > math.random() and v5 <= (data._forkDepth or 0) then
			local v7 = nil
			local v8 = nil
			local v9 = nil
			local v10 = 0
			local v11 = 0
			local v12 = 0

			if v5 == 1 then
				v10 = math.random(2, curSegs)
				v7 = self.ptBuf[v10]
				v8 = (self.ptBuf[v10 + 1] or p2) - v7
				v9 = self.revealDist[v10] or 0
			elseif count > 0 then
				local v13 = math.random(1, count)
				v7 = self.forkAnchorPos[v13]
				v8 = self.forkAnchorDir[v13]
				v9 = self.forkAnchorReveal[v13]
				v11 = self.forkAnchorSlot[v13]
				v12 = self.forkAnchorPtIdx[v13]
			end

			if v7 and v8 and v8.Magnitude > 0.0001 then
				local v13 = (data._forkLenScale or 0.4) ^ v5
				local v14 = math.max(1, magnitude * v13)
				local basis, v15 = BoltGen.basis(v8)
				local v16 = math.random() * 3.141592653589793 * 2
				local v17 = basis * math.cos(v16) + v15 * math.sin(v16)
				local v18 = 0.2617993877991494 + math.random() * 0.5235987755982989
				local vectorToWorldSpace = CFrame.fromAxisAngle(v17, v18):VectorToWorldSpace(v8.Unit)
				local v19 = v7 + vectorToWorldSpace * v14
				buildPolyline(self.forkPtBuf, self.forkSegs, v7, v19, v2 * v13, data._decay or 0.5, 0, true)
				writeSegments(self, self.forkPtBuf, self.forkSegs, v4, v9)
				local forkLocalPt = self.forkLocalPts[i]

				for i2 = 1, self.forkSegs + 1 do
					forkLocalPt[i2] = self.forkPtBuf[i2] - v7
				end

				self.forkOriginIdx[i] = v10 or 0
				self.forkParentSlot[i] = v11 or 0
				self.forkParentPtIdx[i] = v12 or 0
				self.forkLen[i] = v14
				local basis2, v20 = BoltGen.basis(vectorToWorldSpace)
				local forkU = self.forkU
				local forkV = self.forkV
				forkU[i] = basis2
				forkV[i] = v20
				self.forkSeedU[i] = math.random() * 100
				self.forkSeedV[i] = 100 + math.random() * 100

				if v5 == 1 then
					count += 1
					local v21 = math.max(2, math.floor(self.forkSegs / 2) + 1)
					self.forkAnchorPos[count] = self.forkPtBuf[v21]
					self.forkAnchorDir[count] = vectorToWorldSpace
					self.forkAnchorReveal[count] = v9
					self.forkAnchorSlot[count] = i
					self.forkAnchorPtIdx[count] = v21
				end

				v6 = true
			end
		end

		if v6 then
			continue
		end

		self.forkOriginIdx[i] = 0
		self.forkParentSlot[i] = 0

		for i2 = 1, self.forkSegs do
			local v7 = v4 + i2
			self.rollCFs[v7] = p3
			self.segLen[v7] = 0.05
			self.revealDist[v7] = 1e999
		end
	end

	local maxReveal = 0

	for i = 1, self.partCount do
		local v5 = self.revealDist[i]

		if v5 ~= 1e999 and maxReveal < v5 + self.segLen[i] then
			maxReveal = v5 + self.segLen[i]
		end
	end

	self.maxReveal = maxReveal
	BoltGen.sortReveal(self)
	return v3
end

function BoltGen.diffLive(data)
	local count = 0

	for i = 1, data.partCount do
		local v = data.revealDist[i] ~= 1e999

		if v and not data.prevLive[i] then
			count += 1
			data.newlyLiveIdx[count] = i
			data.lastWrittenLen[i] = -1
		end

		data.prevLive[i] = v
	end

	return count
end

function BoltGen:planSizes(lastThick, p)
	local v = p or lastThick ~= self.lastThick
	local count = 0

	for i = 1, self.partCount do
		if self.revealDist[i] == 1e999 then
			continue
		end

		local v2 = self.segLen[i]

		if not (v or v2 ~= self.lastWrittenLen[i]) then
			continue
		end

		count += 1
		self.sizeWriteIdx[count] = i
		self.lastWrittenLen[i] = v2
	end

	self.lastThick = lastThick
	return count
end

function BoltGen.applyScroll(data, data2, p)
	local curSegs = data.curSegs
	local scrollU = data.scrollU
	local scrollV = data.scrollV

	if not curSegs or curSegs < 2 or not scrollU then
		return
	end

	local v = (data2._amplitude or 0) * (data.scrollDist or 0)
	local _waves = data2._waves or 3
	local _decay = data2._decay or 0.5
	local _noiseSeedA = data2._noiseSeedA or 0
	local _noiseSeedB = data2._noiseSeedB or 500
	local ptBuf = data.ptBuf
	local basePtBuf = data.basePtBuf

	for i = 1, curSegs + 1 do
		local v2 = (i - 1) / curSegs
		local v3 = 4 * v2 * (1 - v2)
		local v4 = v3 * v3
		local v5 = v2 * _waves - p
		local v6 = v2 * _waves * 2.7 - p * 1.6
		local v7 = (math.noise(v5, _noiseSeedA) + math.noise(v6, _noiseSeedA + 37.1) * _decay) * v * v4
		local v8 = (math.noise(v5, _noiseSeedB) + math.noise(v6, _noiseSeedB + 37.1) * _decay) * v * v4
		ptBuf[i] = basePtBuf[i] + scrollU * v7 + scrollV * v8
	end

	for i = 1, curSegs do
		local v2 = ptBuf[i]
		local v3 = ptBuf[i + 1]
		local magnitude = (v3 - v2).Magnitude

		if magnitude > 0.0001 then
			data.rollCFs[i] = CFrame.lookAt((v2 + v3) * 0.5, v3)
		else
			data.rollCFs[i] = CFrame.new((v2 + v3) * 0.5)
		end

		data.segLen[i] = math.max(magnitude, 0.05)
	end
end

function BoltGen.applyScrollForks(data, p, p2)
	local forkSegs = data.forkSegs
	local _waves = p._waves or 3

	for i = 1, data.forkSlots do
		local v = data.forkOriginIdx[i] or 0
		local v2 = data.forkParentSlot[i] or 0

		if not (v ~= 0 or v2 ~= 0) then
			continue
		end

		local v3

		if v2 == 0 then
			v3 = data.ptBuf[v]
		else
			local forkWorldPt = data.forkWorldPts[v2]
			v3 = forkWorldPt and forkWorldPt[data.forkParentPtIdx[i]]
		end

		if not v3 then
			continue
		end

		local forkLocalPt = data.forkLocalPts[i]
		local forkWorldPt = data.forkWorldPts[i]
		local v4 = data.forkU[i]
		local v5 = data.forkV[i]
		local v6 = (p._amplitude or 0) * (data.forkLen[i] or 1)
		local v7 = data.forkSeedU[i] or 0
		local v8 = data.forkSeedV[i] or 50

		for i2 = 1, forkSegs + 1 do
			local v9 = (i2 - 1) / forkSegs
			local v10 = v9 * _waves - p2 * 1.35
			forkWorldPt[i2] = v3 + forkLocalPt[i2] + v4 * (math.noise(v10, v7) * v6 * v9) + v5 * (math.noise(v10, v8) * v6 * v9)
		end

		local v9 = data.mainSegs + (i - 1) * forkSegs

		for i2 = 1, forkSegs do
			local v10 = forkWorldPt[i2]
			local v11 = forkWorldPt[i2 + 1]
			local magnitude = (v11 - v10).Magnitude
			local v12 = v9 + i2

			if magnitude > 0.0001 then
				data.rollCFs[v12] = CFrame.lookAt((v10 + v11) * 0.5, v11)
			else
				data.rollCFs[v12] = CFrame.new((v10 + v11) * 0.5)
			end

			data.segLen[v12] = math.max(magnitude, 0.05)
		end
	end
end

function BoltGen.sortReveal(data)
	local revealOrder = data.revealOrder
	local revealDist = data.revealDist

	for i = 2, data.partCount do
		local v = revealOrder[i]
		local v2 = revealDist[v]
		local v3 = i - 1

		while v3 >= 1 and v2 < revealDist[revealOrder[v3]] do
			revealOrder[v3 + 1] = revealOrder[v3]
			v3 -= 1
		end

		revealOrder[v3 + 1] = v
	end
end

return BoltGen