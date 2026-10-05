local createVector = vector.create
local Graph = require(script.Parent.Graph)
local PartConstants = require(script.Parent.PartConstants)
local Turbulence = {
	isLive = function(p)
		if not p or Graph.IsStatic(p) and Graph.GetStaticValue(p, 0) == 0 then
			return nil
		end

		return p
	end,
	sampleRaw = function(p, p2, p3, p4, p5, p6)
		local pointsWithTime = Graph.QueryPointsWithTime(p6, p, p2)

		if pointsWithTime == 0 then
			return createVector(0, 0, 0)
		end

		local v = p6 * p5 * p4
		return (Vector3.new(
			pointsWithTime * math.noise(v, p3, 0.17),
			pointsWithTime * math.noise(v, p3, 137.7),
			pointsWithTime * math.noise(v, p3, 291.3)
		))
	end
}

-- equivalent calls inferred from this helper; original call sites unknown
local function resolvedAt(data, p)
	return PartConstants.resolveDisplacement(
		Turbulence.sampleRaw(
			data.Graphs.Turbulence,
			data.Seeds.Turbulence,
			data._turbSeed,
			data.TurbulenceFrequency,
			data.LifeTime,
			p
		),
		data.DisplacementMode or "Global",
		data.SpawnRotation,
		data.SpawnEmitterRotation
	)
end

function Turbulence:frameDelta(p)
	local prevTurbOff = resolvedAt(self, p) -- equivalent call inferred; original call site unknown
	local v2 = prevTurbOff - self._prevTurbOff
	self._prevTurbOff = prevTurbOff
	return v2
end

function Turbulence:buildInto(p)
	local live = Turbulence.isLive(p.Turbulence)
	self.HasTurbulence = live ~= nil

	if not live then
		self.Graphs.Turbulence = nil
		return
	end

	self.Graphs.Turbulence = live
	self.Seeds.Turbulence = self.Seeds.Turbulence or Graph.GenerateSeed(live)
	self.TurbulenceFrequency = p.TurbulenceFrequency or 1
	self._turbSeed = self.Seeds._turbSeed or math.random() * 997 + 0.5
	self._prevTurbOff = PartConstants.resolveDisplacement(
		Turbulence.sampleRaw(
			self.Graphs.Turbulence,
			self.Seeds.Turbulence,
			self._turbSeed,
			self.TurbulenceFrequency,
			self.LifeTime,
			0
		),
		self.DisplacementMode or "Global",
		self.SpawnRotation,
		self.SpawnEmitterRotation
	)
end

function Turbulence:reprime()
	if not self.HasTurbulence then
		return
	end

	self._prevTurbOff = PartConstants.resolveDisplacement(
		Turbulence.sampleRaw(
			self.Graphs.Turbulence,
			self.Seeds.Turbulence,
			self._turbSeed,
			self.TurbulenceFrequency,
			self.LifeTime,
			0
		),
		self.DisplacementMode or "Global",
		self.SpawnRotation,
		self.SpawnEmitterRotation
	)
end

return Turbulence