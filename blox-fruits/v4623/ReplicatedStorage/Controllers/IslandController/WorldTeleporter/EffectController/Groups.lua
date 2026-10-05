local Profiles = require(script.Parent.Profiles)
local Geometry = require(script.Parent.Geometry)
local v = { "Transparency" }
local v2 = { "Transparency" }
local v3 = { "Color" }
local v4 = {
	"Enabled",
	"Brightness",
	"Width0",
	"Width1",
	"CurveSize0",
	"CurveSize1",
	"Transparency",
	"Color",
	"TextureSpeed",
	"LightEmission"
}
local v5 = {
	"Rate",
	"Brightness",
	"Size",
	"Transparency",
	"Speed",
	"Lifetime",
	"TimeScale",
	"LightEmission",
	"Color"
}
local v6 = {
	"Enabled",
	"Brightness",
	"Range",
	"Color"
}

function collect(folder, className: string, options)
	local descendants = options or {}

	if folder then
		for _, descendant in folder:GetDescendants() do
			if descendant:IsA(className) then
				table.insert(descendants, descendant)
			end
		end
	end

	return descendants
end

function collectRingAndFlares(folder, emitters, emitters2)
	for _, emitter in folder:GetDescendants() do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		if emitter.Parent == folder then
			table.insert(emitters, emitter)
		else
			table.insert(emitters2, emitter)
		end
	end
end

function findHostPart(parent)
	while parent do
		if parent:IsA("BasePart") then
			return parent
		else
			parent = parent.Parent
		end
	end

	return nil
end

function collectHostParts(p, items)
	local v7 = {
		[p.Part] = true
	}
	local v8 = {}
	local hostParts = {}

	for _, item in items do
		table.insert(v8, item.Attachment0)
		table.insert(v8, item.Attachment1)
	end

	for _, v9 in v8 do
		local hostPart = findHostPart(v9)

		if not hostPart or v7[hostPart] then
			continue
		end

		v7[hostPart] = true

		if (hostPart:GetAttribute("EffectBase_Transparency") or hostPart.Transparency) < 1 then
			table.insert(hostParts, hostPart)
		end
	end

	return hostParts
end

local Groups = {
	MESH_TRANSPARENCY_ATTRIBUTE = "Transparency",
	BEAM_TRANSPARENCY_ATTRIBUTE = "BaseTransparency",
	getBase = function(instance, p: string)
		local v7 = "EffectBase_" .. p
		local attribute = instance:GetAttribute(v7)

		if attribute == nil then
			attribute = instance[p]
			instance:SetAttribute(v7, attribute)
		end

		return attribute
	end,
	restoreBase = function(attributes, items)
		for _, item in items do
			local v7 = "EffectBase_" .. item
			local attribute = attributes:GetAttribute(v7)

			if attribute == nil then
				continue
			end

			attributes[item] = attribute
			attributes:SetAttribute(v7, nil)
		end
	end,
	getMeshColorTarget = function(instance)
		return instance:FindFirstChildWhichIsA("SurfaceAppearance") or instance
	end,
	fillVisibility = function(flag: boolean)
		return {
			Meshes = {
				FlareMesh = flag,
				BeamMesh = flag,
				Lines = flag,
				SideMesh = flag
			},
			Beams = {
				MainBeam = flag,
				BeamColumns = flag
			},
			Particles = {
				GroundRing = flag,
				Flares = flag,
				TopGlow = flag,
				Smoke = flag,
				Debris = flag
			},
			Lights = flag,
			Ambient = flag
		}
	end,
	copyVisibility = function(data)
		return {
			Meshes = table.clone(data.Meshes),
			Beams = table.clone(data.Beams),
			Particles = table.clone(data.Particles),
			Lights = data.Lights,
			Ambient = data.Ambient
		}
	end,
	collect = function(instance)
		local teleporterVFX = instance:FindFirstChild("TeleporterVFX")
		assert(teleporterVFX, "bad teleporter vfx")
		local base = teleporterVFX:FindFirstChild("Base")
		assert(base and base:IsA("BasePart"), "bad vfx base")
		local meshs = instance:FindFirstChild("Meshs")
		assert(meshs, "bad meshs folder")
		local anchor = Geometry.newAnchor(base)
		local beams = {
			MainBeam = collect(teleporterVFX:FindFirstChild("MainBeam"), "Beam"),
			BeamColumns = {}
		}
		local particles = {
			GroundRing = {},
			Flares = {},
			TopGlow = {},
			Smoke = collect(teleporterVFX:FindFirstChild("Smokes"), "ParticleEmitter"),
			Debris = {}
		}
		local lights = {}
		local partsByChildName = {
			FlareMesh = nil,
			BeamMesh = nil,
			Lines = nil,
			SideMesh = nil
		}
		local meshPlacements = {
			FlareMesh = nil,
			BeamMesh = nil,
			Lines = nil,
			SideMesh = nil
		}

		for _, child in teleporterVFX:GetChildren() do
			if child.Name:match("^DebrisPart") then
				collect(child, "ParticleEmitter", particles.Debris)
			end
		end

		for _, child in base:GetChildren() do
			if child.Name == "BeamsColums" then
				collect(child, "Beam", beams.BeamColumns)
			elseif child.Name == "Lights" then
				collect(child, "Light", lights)
			elseif child.Name == "Smokes" then
				collect(child, "ParticleEmitter", particles.Smoke)
			elseif child.Name:match("^TopCircle") then
				collect(child, "ParticleEmitter", particles.TopGlow)
			else
				collectRingAndFlares(child, particles.GroundRing, particles.Flares)
			end
		end

		for _, childName in Profiles.MESH_KEYS do
			local part = meshs:FindFirstChild(childName)

			if not (part and part:IsA("MeshPart")) then
				continue
			end

			partsByChildName[childName] = part
			meshPlacements[childName] = Geometry.placePart(anchor, part)
		end

		return {
			Meshes = partsByChildName,
			MeshPlacements = meshPlacements,
			Beams = beams,
			BeamHosts = {
				MainBeam = Geometry.beamHosts(anchor, beams.MainBeam),
				BeamColumns = Geometry.beamHosts(anchor, beams.BeamColumns)
			},
			BeamHostParts = {
				MainBeam = collectHostParts(anchor, beams.MainBeam),
				BeamColumns = collectHostParts(anchor, beams.BeamColumns)
			},
			Particles = particles,
			ParticleHosts = {
				GroundRing = Geometry.particleHosts(anchor, particles.GroundRing),
				Flares = Geometry.particleHosts(anchor, particles.Flares),
				TopGlow = Geometry.particleHosts(anchor, particles.TopGlow),
				Smoke = Geometry.particleHosts(anchor, particles.Smoke),
				Debris = Geometry.particleHosts(anchor, particles.Debris)
			},
			Lights = lights,
			Anchor = anchor
		}
	end,
	count = function(data)
		local count = 0

		for _, v7 in Profiles.MESH_KEYS do
			if data.Meshes[v7] then
				count += 1
			end
		end

		local beams = {}

		for _, v8 in Profiles.BEAM_GROUP_KEYS do
			beams[v8] = #data.Beams[v8]
		end

		local particles = {}

		for _, v9 in Profiles.PARTICLE_GROUP_KEYS do
			particles[v9] = #data.Particles[v9]
		end

		return {
			Meshes = count,
			Beams = beams,
			Particles = particles,
			Lights = #data.Lights
		}
	end
}

function Groups.restoreAll(data)
	for _, v7 in Profiles.MESH_KEYS do
		local mesh = data.Meshes[v7]
		local meshPlacement = data.MeshPlacements[v7]

		if not (mesh and meshPlacement) then
			continue
		end

		Groups.restoreBase(mesh, v)
		Groups.restoreBase(Groups.getMeshColorTarget(mesh), v3)
		Geometry.applyPart(data.Anchor, meshPlacement, 1, 0)
		mesh:SetAttribute(Groups.MESH_TRANSPARENCY_ATTRIBUTE, mesh.Transparency)
	end

	for _, v7 in Profiles.BEAM_GROUP_KEYS do
		Geometry.applyHosts(data.Anchor, data.BeamHosts[v7], 1)

		for _, v8 in data.Beams[v7] do
			Groups.restoreBase(v8, v4)
			v8:SetAttribute(Groups.BEAM_TRANSPARENCY_ATTRIBUTE, nil)
		end

		for _, v8 in data.BeamHostParts[v7] do
			Groups.restoreBase(v8, v2)
		end
	end

	for _, v7 in Profiles.PARTICLE_GROUP_KEYS do
		Geometry.applyHosts(data.Anchor, data.ParticleHosts[v7], 1)

		for _, v8 in data.Particles[v7] do
			Groups.restoreBase(v8, v5)
		end
	end

	for _, light in data.Lights do
		Groups.restoreBase(light, v6)
	end
end

return Groups