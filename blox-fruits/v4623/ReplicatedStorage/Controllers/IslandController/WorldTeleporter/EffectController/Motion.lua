local Spring = require(game.ReplicatedStorage.Packages.Spring)
local Profiles = require(script.Parent.Profiles)
local Geometry = require(script.Parent.Geometry)
local Groups = require(script.Parent.Groups)
local getBase = Groups.getBase

function newSpring(p: number)
	return Spring.new(1, 1, p)
end

function heightSprings(p: number)
	return {
		Height = newSpring(p)
	}
end

function tuneSpring(object, p: number, data, data2)
	local v, v2

	if object.Position <= p then
		v = data.RiseDamping * data2.RiseDamping
		v2 = data.RiseFrequency * data2.RiseFrequency
	else
		v = data.FallDamping * data2.FallDamping
		v2 = data.FallFrequency * data2.FallFrequency
	end

	object.Damping = math.max(v, 0)
	object.Frequency = math.max(v2, 0.01)
	object:Set(p)
end

function isSpringMoving(data)
	return math.abs(data.Position - data.Goal) > 0.001 or math.abs(data.Velocity) > 0.001
end

function forEachSpring(data, callback)
	callback(data.Global.Height)

	for _, v in Profiles.MESH_KEYS do
		callback(data.Meshes[v].Height)
	end

	for _, v in Profiles.BEAM_GROUP_KEYS do
		callback(data.Beams[v].Width)
		callback(data.Beams[v].Height)
	end

	for _, v in Profiles.PARTICLE_GROUP_KEYS do
		callback(data.Particles[v].Height)
	end
end

function forEachHeightSpring(data, callback)
	for _, v in Profiles.MESH_KEYS do
		callback(data.Meshes[v].Height)
	end

	for _, v in Profiles.BEAM_GROUP_KEYS do
		callback(data.Beams[v].Height)
	end

	for _, v in Profiles.PARTICLE_GROUP_KEYS do
		callback(data.Particles[v].Height)
	end
end

local Motion = {
	build = function(data)
		return {
			Global = heightSprings(data.Global.Height),
			Meshes = {
				FlareMesh = heightSprings(data.Meshes.FlareMesh.Height),
				BeamMesh = heightSprings(data.Meshes.BeamMesh.Height),
				Lines = heightSprings(data.Meshes.Lines.Height),
				SideMesh = heightSprings(data.Meshes.SideMesh.Height)
			},
			Beams = {
				MainBeam = {
					Width = newSpring(data.Beams.MainBeam.Width),
					Height = newSpring(data.Beams.MainBeam.Height)
				},
				BeamColumns = {
					Width = newSpring(data.Beams.BeamColumns.Width),
					Height = newSpring(data.Beams.BeamColumns.Height)
				}
			},
			Particles = {
				GroundRing = heightSprings(data.Particles.GroundRing.Height),
				Flares = heightSprings(data.Particles.Flares.Height),
				TopGlow = heightSprings(data.Particles.TopGlow.Height),
				Smoke = heightSprings(data.Particles.Smoke.Height),
				Debris = heightSprings(data.Particles.Debris.Height)
			}
		}
	end,
	tune = function(data, data2)
		local global = data2.Global
		tuneSpring(data.Global.Height, global.Height, global.Motion, Profiles.IDENTITY_MOTION)

		for _, v in Profiles.MESH_KEYS do
			tuneSpring(data.Meshes[v].Height, data2.Meshes[v].Height, data2.Meshes[v].Motion, global.Motion)
		end

		for _, v in Profiles.BEAM_GROUP_KEYS do
			local beam = data2.Beams[v]
			tuneSpring(data.Beams[v].Width, beam.Width, beam.Motion, global.Motion)
			tuneSpring(data.Beams[v].Height, beam.Height, beam.Motion, global.Motion)
		end

		for _, v in Profiles.PARTICLE_GROUP_KEYS do
			local particle = data2.Particles[v]
			tuneSpring(data.Particles[v].Height, particle.Height, particle.Motion, global.Motion)
		end
	end,
	snap = function(p)
		forEachSpring(p, function(p2)
			p2.Position = p2.Goal
			p2.Velocity = 0
		end)
	end,
	collapseHeights = function(p, position: number)
		forEachHeightSpring(p, function(p2)
			p2.Position = position
			p2.Velocity = 0
		end)
	end,
	step = function(p, p2: number)
		local v = false
		forEachSpring(p, function(object)
			object:Step(p2)

			if isSpringMoving(object) then
				v = true
			end
		end)
		return v
	end,
	isSettled = function(p)
		local v = true
		forEachSpring(p, function(p2)
			if isSpringMoving(p2) then
				v = false
			end
		end)
		return v
	end,
	height = function(p, p2)
		return (math.max(p2.Height.Position * p.Global.Height.Position, 0))
	end
}

function Motion.applyMeshGeometry(data, p, p2, p3)
	local mesh = data.Meshes[p3]
	local meshPlacement = data.MeshPlacements[p3]

	if mesh and meshPlacement then
		Geometry.applyPart(data.Anchor, meshPlacement, Motion.height(p, p.Meshes[p3]), p2[mesh] or 0)
	end
end

function Motion.applyGeometry(data, p, p2)
	for _, v in Profiles.MESH_KEYS do
		Motion.applyMeshGeometry(data, p, p2, v)
	end

	for _, v in Profiles.BEAM_GROUP_KEYS do
		local beam = p.Beams[v]
		local height = Motion.height(p, beam)
		local v2 = math.max(beam.Width.Position, 0)
		Geometry.applyHosts(data.Anchor, data.BeamHosts[v], height)

		for _, v3 in data.Beams[v] do
			v3.Width0 = getBase(v3, "Width0") * v2
			v3.Width1 = getBase(v3, "Width1") * v2
			v3.CurveSize0 = getBase(v3, "CurveSize0") * height
			v3.CurveSize1 = getBase(v3, "CurveSize1") * height
		end
	end

	for _, v in Profiles.PARTICLE_GROUP_KEYS do
		Geometry.applyHosts(data.Anchor, data.ParticleHosts[v], Motion.height(p, p.Particles[v]))
	end
end

return Motion