local createVector = vector.create

function getPoint3D(p: number, p2: number, p3: number, p4: number)
	local v = 0.01 + Random.new(p2 * p + 1):NextNumber()
	local v2 = 0.01 + Random.new(p3 * p + 2):NextNumber()
	local v3 = 0.01 + Random.new(p4 * p + 3):NextNumber()
	local v4 = 10000000 * (v + v2 + v3)
	return Vector3.new(p2, p3, p4) + createVector(0.5, 0.5, 0.5) + 0.5 * Random.new(v4):NextUnitVector()
end

function getPoint2D(p: number, p2: number, p3: number)
	local v = 10000000 * (0.01 + Random.new(p2 * p + 1):NextNumber() + (0.01 + Random.new(p3 * p + 2):NextNumber()))
	local unitVector = Random.new(v):NextUnitVector()
	return Vector3.new(p2, p3) + createVector(0.5, 0.5, 0.5) + Vector3.new(unitVector.X, unitVector.Y) * 0.5
end

local Noise = {}
Noise.__index = Noise

function Noise:Random(p2: number, p3: number, p4: number?)
	if not p4 then
		local v = 100000 * ((0.01 + Random.new(p2 * self.Seed * 1):NextNumber() + (0.01 + Random.new(p3 * self.Seed * 2):NextNumber())) % 1)
		return Random.new(v):NextNumber()
	end

	local v = 0.01 + Random.new(p2 * self.Seed * 1):NextNumber()
	local v2 = 0.01 + Random.new(p3 * self.Seed * 2):NextNumber()
	local v3 = 0.01 + Random.new(p4 * self.Seed * 3):NextNumber()
	local v4 = 100000 * ((v + v2 + v3) % 1)
	return Random.new(v4):NextNumber()
end

function Noise:Cellular(p: number, p2: number, p3: number?)
	if p3 then
		local vector2 = Vector3.new(p, p2, p3)
		local v = {}
		local vector3 = Vector3.new(math.floor(p), math.floor(p2), (math.floor(p3)))

		if self._PointCache3D[vector3] then
			v = self._PointCache3D[vector3]
		else
			for i = -1, 1 do
				for i2 = -1, 1 do
					for i3 = -1, 1 do
						table.insert(v, getPoint3D(self.Seed, vector3.X + i, vector3.Y + i2, vector3.Z + i3))
					end
				end
			end

			self._PointCache3D[vector3] = v
		end

		local v2 = nil
		local v3 = nil
		local v4 = nil
		local v5 = 0

		for _, v6 in ipairs(v) do
			local magnitude = (v6 - vector2).Magnitude

			if not v2 or v3 and magnitude < v3 or not v3 then
				v3 = magnitude
				v2 = v6
			end

			if not (not v4 or v5 < magnitude) then
				continue
			end

			v5 = magnitude
			v4 = v6
		end

		assert(v3)
		return v3
	else
		local vector2 = Vector3.new(p, p2)
		local v = {}
		local vector3 = Vector3.new(math.floor(p), (math.floor(p2)))

		if self._PointCache2D[vector3] then
			v = self._PointCache2D[vector3]
		else
			for i = -1, 1 do
				for i2 = -1, 1 do
					table.insert(v, getPoint2D(self.Seed, vector3.X + i, vector3.Y + i2))
				end
			end

			self._PointCache2D[vector3] = v
		end

		local v2 = nil
		local v3 = nil

		for _, v4 in ipairs(v) do
			local magnitude = (v4 - vector2).Magnitude

			if not (not v2 or v3 and magnitude < v3 or not v3) then
				continue
			end

			v3 = magnitude
			v2 = v4
		end

		assert(v3)
		return (v3 - 0.375) / 0.7
	end
end

function Noise:Voronoi(p: number, p2: number, p3: number?)
	if p3 then
		local vector2 = Vector3.new(p, p2, p3)
		local v = {}
		local vector3 = Vector3.new(math.floor(p), math.floor(p2), (math.floor(p3)))

		if self._PointCache3D[vector3] then
			v = self._PointCache3D[vector3]
		else
			for i = -1, 1 do
				for i2 = -1, 1 do
					for i3 = -1, 1 do
						local vector4 = Vector3.new(i, i2, i3)
						table.insert(
							v,
							getPoint3D(self.Seed, vector3.X + vector4.X, vector3.Y + vector4.Y, vector3.Z + vector4.Z)
						)
					end
				end
			end

			self._PointCache3D[vector3] = v
		end

		local v2 = nil
		local v3 = 1e999

		for _, v4 in ipairs(v) do
			local magnitude = (v4 - vector2).Magnitude

			if not (not v2 or magnitude < v3) then
				continue
			end

			v3 = magnitude
			v2 = v4
		end

		if self._VoronoiCache3D[v2] == nil then
			self._VoronoiCache3D[v2] = self:Random(v2.X, v2.Y, v2.Z)
		end

		return self._VoronoiCache3D[v2]
	else
		local vector2 = Vector3.new(p, p2)
		local v = {}
		local vector3 = Vector3.new(math.floor(p), (math.floor(p2)))

		if self._PointCache2D[vector3] then
			v = self._PointCache2D[vector3]
		else
			for i = -1, 1 do
				for i2 = -1, 1 do
					for i3 = -1, 1 do
						local vector4 = Vector3.new(i, i2, i3)
						table.insert(v, getPoint2D(self.Seed, vector3.X + vector4.X, vector3.Y + vector4.Y))
					end
				end
			end

			self._PointCache2D[vector3] = v
		end

		local v2 = nil
		local v3 = 1e999

		for _, v4 in ipairs(v) do
			local magnitude = (v4 - vector2).Magnitude

			if not (not v2 or magnitude < v3) then
				continue
			end

			v3 = magnitude
			v2 = v4
		end

		if self._VoronoiCache2D[v2] == nil then
			self._VoronoiCache2D[v2] = self:Random(v2.X, v2.Y)
		end

		return self._VoronoiCache2D[v2]
	end
end

local v = {
	{ 1, 1, 0 },
	{ -1, 1, 0 },
	{ 1, -1, 0 },
	{ -1, -1, 0 },
	{ 1, 0, 1 },
	{ -1, 0, 1 },
	{ 1, 0, -1 },
	{ -1, 0, -1 },
	{ 0, 1, 1 },
	{ 0, -1, 1 },
	{ 0, 1, -1 },
	{ 0, -1, -1 },
	{ 1, 1, 0 },
	{ 0, -1, 1 },
	{ -1, 1, 0 },
	{ 0, -1, -1 }
}

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function perlin_fade(p: number)
	return p * p * p * (p * (p * 6 - 15) + 10)
end

local function perlin_lerp(p: number, p2: number, p3: number)
	return p2 + p * (p3 - p2)
end

local function perlin_grad(p: number, p2: number, p3: number, p4: number)
	local v2 = v[p % 16 + 1]
	return v2[1] * p2 + v2[2] * p3 + v2[3] * p4
end

function Noise:Perlin(p2: number, p3: number, value: number?)
	local v2 = value or 0
	assert(v2)
	local v3 = math.floor(p2)
	local v4 = math.floor(p3)
	local v5 = math.floor(v2)
	local v6 = v3 % 256
	local v7 = v4 % 256
	local v8 = v5 % 256
	local v9 = p2 - v3
	local v10 = p3 - v4
	local v11 = v2 - v5
	local v12 = perlin_fade(v9)
	local v13 = perlin_fade(v10)
	local v14 = perlin_fade(v11)
	local _PerlinHash3D = self._PerlinHash3D
	local v15 = (_PerlinHash3D[v6 + 1] + v7) % 256
	local v16 = (_PerlinHash3D[v15 + 1] + v8) % 256
	local v17 = (_PerlinHash3D[v15 + 2] + v8) % 256
	local v18 = (_PerlinHash3D[v6 + 2] + v7) % 256
	local v19 = (_PerlinHash3D[v18 + 1] + v8) % 256
	local v20 = (_PerlinHash3D[v18 + 2] + v8) % 256
	local v22 = v[_PerlinHash3D[v16 + 1] % 16 + 1]
	local v23 = v22[1] * v9 + v22[2] * v10 + v22[3] * v11
	local v24 = _PerlinHash3D[v19 + 1]
	local v25 = v9 - 1
	local v26 = v[v24 % 16 + 1]
	local v27 = v23 + v12 * (v26[1] * v25 + v26[2] * v10 + v26[3] * v11 - v23)
	local v28 = _PerlinHash3D[v17 + 1]
	local v29 = v10 - 1
	local v30 = v[v28 % 16 + 1]
	local v31 = v30[1] * v9 + v30[2] * v29 + v30[3] * v11
	local v32 = _PerlinHash3D[v20 + 1]
	local v33 = v9 - 1
	local v34 = v10 - 1
	local v35 = v[v32 % 16 + 1]
	local v36 = v31 + v12 * (v35[1] * v33 + v35[2] * v34 + v35[3] * v11 - v31)
	local v37 = _PerlinHash3D[v16 + 2]
	local v38 = v11 - 1
	local v39 = v[v37 % 16 + 1]
	local v40 = v39[1] * v9 + v39[2] * v10 + v39[3] * v38
	local v41 = _PerlinHash3D[v19 + 2]
	local v42 = v9 - 1
	local v43 = v11 - 1
	local v44 = v[v41 % 16 + 1]
	local v45 = v40 + v12 * (v44[1] * v42 + v44[2] * v10 + v44[3] * v43 - v40)
	local v46 = _PerlinHash3D[v17 + 2]
	local v47 = v10 - 1
	local v48 = v11 - 1
	local v49 = v[v46 % 16 + 1]
	local v50 = v49[1] * v9 + v49[2] * v47 + v49[3] * v48
	local v51 = _PerlinHash3D[v20 + 2]
	local v52 = v9 - 1
	local v53 = v10 - 1
	local v54 = v11 - 1
	local v55 = v[v51 % 16 + 1]
	local v56 = v50 + v12 * (v55[1] * v52 + v55[2] * v53 + v55[3] * v54 - v50)
	local v57 = v27 + v13 * (v36 - v27)
	return (v57 + v14 * (v45 + v13 * (v56 - v45) - v57)) * 0.5 + 0.5
end

function Noise.new(p: number?)
	local self = setmetatable({}, Noise)
	self.Seed = p or tick()
	self._PointCache3D = {}
	self._PointCache2D = {}
	self._VoronoiCache2D = {}
	self._VoronoiCache3D = {}
	local random = Random.new(self.Seed)
	self._PerlinHash3D = {}

	for i = 1, 257 do
		self._PerlinHash3D[i] = random:NextInteger(1, 256)
	end

	table.freeze(self._PerlinHash3D)
	self._PerlinHash2D = {}

	for i = 1, 257 do
		self._PerlinHash2D[i] = random:NextInteger(1, 256)
	end

	table.freeze(self._PerlinHash2D)
	table.freeze(self)
	return self
end

return Noise