local Profiles = require(script.Parent.Profiles)
local Groups = require(script.Parent.Groups)
require(script.Parent.MeshScroller)
local getBase = Groups.getBase

function pulseFactor(p, p2: number)
	if p.Amplitude == 0 then
		return 1
	end

	return 1 + p.Amplitude * math.sin(6.283185307179586 * p2 / math.max(p.Period, 0.05))
end

function hasPulse(p, p2)
	return p.Amplitude ~= 0 or p2.Pulse.Amplitude ~= 0
end

function brightnessScale(p: number, p2, p3, p4: number)
	return p * p3.Brightness * pulseFactor(p2, p4) * pulseFactor(p3.Pulse, p4)
end

function tintColor(color: Color3, p, p2)
	return color:Lerp(p.Tint, p.TintAlpha):Lerp(p2.Tint, p2.TintAlpha)
end

function scaleColor(color: Color3, p: number)
	return Color3.new(math.clamp(color.R * p, 0, 1), math.clamp(color.G * p, 0, 1), (math.clamp(color.B * p, 0, 1)))
end

function tintSequence(sequence, p, p2)
	local colorSequenceKeypoints = {}

	for _, keypoint in sequence.Keypoints do
		table.insert(colorSequenceKeypoints, ColorSequenceKeypoint.new(keypoint.Time, tintColor(keypoint.Value, p, p2)))
	end

	return ColorSequence.new(colorSequenceKeypoints)
end

function opacityToTransparency(p: number, p2: number)
	return (math.clamp(1 - (1 - p) * p2, 0, 1))
end

function scaleOpacity(sequence, p: number)
	local numberSequenceKeypoints = {}

	for _, keypoint in sequence.Keypoints do
		local v = opacityToTransparency(keypoint.Value, p)
		local v2 = math.min(keypoint.Envelope, v, 1 - v)
		table.insert(numberSequenceKeypoints, NumberSequenceKeypoint.new(keypoint.Time, v, v2))
	end

	return NumberSequence.new(numberSequenceKeypoints)
end

function scaleSequence(sequence, p: number)
	local numberSequenceKeypoints = {}

	for _, keypoint in sequence.Keypoints do
		table.insert(
			numberSequenceKeypoints,
			NumberSequenceKeypoint.new(
				keypoint.Time,
				math.max(keypoint.Value * p, 0),
				(math.max(keypoint.Envelope * p, 0))
			)
		)
	end

	return NumberSequence.new(numberSequenceKeypoints)
end

function scaleRange(range: NumberRange, p: number)
	return NumberRange.new(math.max(range.Min * p, 0), (math.max(range.Max * p, 0)))
end

function applyMeshColor(p, p2, p3, p4: number)
	local mesh = p.Profile.Meshes[p2]
	local global = p.Profile.Global
	local meshColorTarget = Groups.getMeshColorTarget(p3)
	local v = pulseFactor(mesh.Pulse, p4) * pulseFactor(global.Pulse, p4)
	meshColorTarget.Color = scaleColor(tintColor(getBase(meshColorTarget, "Color"), mesh, global), v)
end

function applyMesh(data, p, instance, p2: number)
	local mesh = data.Profile.Meshes[p]
	local global = data.Profile.Global
	local base = getBase(instance, "Transparency")
	local transparency = not data.Visibility.Meshes[p] and 1 or opacityToTransparency(
		base,
		mesh.Opacity * global.Opacity
	)
	instance.Transparency = transparency
	instance:SetAttribute(Groups.MESH_TRANSPARENCY_ATTRIBUTE, transparency)
	data.Scroller:SetModifier(instance, mesh.ScrollSpeed * global.Speed, mesh.ScrollAngle)
	applyMeshColor(data, p, instance, p2)
end

function stepBeamBrightness(p, p2, p3: number)
	local beam = p.Profile.Beams[p2]
	local v = brightnessScale(beam.Brightness, beam.Pulse, p.Profile.Global, p3)

	for _, v2 in p.Groups.Beams[p2] do
		v2.Brightness = getBase(v2, "Brightness") * v
	end
end

function applyBeams(data, p, p2: number)
	local beam = data.Profile.Beams[p]
	local global = data.Profile.Global
	local beam2 = data.Visibility.Beams[p]

	for _, v in data.Groups.Beams[p] do
		v.Enabled = getBase(v, "Enabled") and beam2
		v.TextureSpeed = getBase(v, "TextureSpeed") * beam.TextureSpeed * global.Speed
		v.LightEmission = getBase(v, "LightEmission") * beam.LightEmission
		v.Color = tintSequence(getBase(v, "Color"), beam, global)
		local transparency = scaleOpacity(getBase(v, "Transparency"), beam.Opacity * global.Opacity)
		v.Transparency = transparency
		v:SetAttribute(Groups.BEAM_TRANSPARENCY_ATTRIBUTE, transparency)
	end

	for _, v in data.Groups.BeamHostParts[p] do
		v.Transparency = not beam2 and 1 or opacityToTransparency(
			getBase(v, "Transparency"),
			beam.Opacity * global.Opacity
		)
	end

	stepBeamBrightness(data, p, p2)
end

function stepParticleBrightness(p, p2, p3: number)
	local particle = p.Profile.Particles[p2]
	local v = brightnessScale(particle.Brightness, particle.Pulse, p.Profile.Global, p3)

	for _, v2 in p.Groups.Particles[p2] do
		v2.Brightness = getBase(v2, "Brightness") * v
	end
end

function applyParticles(data, p, p2: number)
	local particle = data.Profile.Particles[p]
	local global = data.Profile.Global
	local particle2 = data.Visibility.Particles[p]

	for _, v in data.Groups.Particles[p] do
		v.Rate = not particle2 and 0 or math.max(getBase(v, "Rate") * particle.Rate, 0)

		if not particle2 then
			v:Clear()
		end

		v.Size = scaleSequence(getBase(v, "Size"), particle.Size)
		v.Transparency = scaleOpacity(getBase(v, "Transparency"), particle.Opacity * global.Opacity)
		v.Speed = scaleRange(getBase(v, "Speed"), particle.Speed)
		v.Lifetime = scaleRange(getBase(v, "Lifetime"), particle.Lifetime)
		v.TimeScale = math.clamp(getBase(v, "TimeScale") * particle.TimeScale * global.Speed, 0, 1)
		v.LightEmission = getBase(v, "LightEmission") * particle.LightEmission
		v.Color = tintSequence(getBase(v, "Color"), particle, global)
	end

	stepParticleBrightness(data, p, p2)
end

function stepLightBrightness(p, p2: number)
	local lights = p.Profile.Lights
	local v = brightnessScale(lights.Brightness, lights.Pulse, p.Profile.Global, p2)

	for _, light in p.Groups.Lights do
		light.Brightness = getBase(light, "Brightness") * v
	end
end

function applyLights(data, p: number)
	local lights = data.Profile.Lights
	local global = data.Profile.Global

	for _, light in data.Groups.Lights do
		light.Enabled = getBase(light, "Enabled") and data.Visibility.Lights
		light.Range = math.clamp(getBase(light, "Range") * lights.Range, 0, 60)
		light.Color = tintColor(getBase(light, "Color"), lights, global)
	end

	stepLightBrightness(data, p)
end

local Shading = {}

function Shading.apply(p, p2: number)
	for _, v in Profiles.MESH_KEYS do
		local mesh = p.Groups.Meshes[v]

		if mesh then
			applyMesh(p, v, mesh, p2)
		end
	end

	for _, v in Profiles.BEAM_GROUP_KEYS do
		applyBeams(p, v, p2)
	end

	for _, v in Profiles.PARTICLE_GROUP_KEYS do
		applyParticles(p, v, p2)
	end

	applyLights(p, p2)
end

function Shading.stepPulses(p, p2: number)
	local profile = p.Profile
	local global = profile.Global

	for _, v in Profiles.MESH_KEYS do
		local mesh = p.Groups.Meshes[v]

		if mesh and hasPulse(profile.Meshes[v].Pulse, global) then
			applyMeshColor(p, v, mesh, p2)
		end
	end

	for _, v in Profiles.BEAM_GROUP_KEYS do
		if hasPulse(profile.Beams[v].Pulse, global) then
			stepBeamBrightness(p, v, p2)
		end
	end

	for _, v in Profiles.PARTICLE_GROUP_KEYS do
		if hasPulse(profile.Particles[v].Pulse, global) then
			stepParticleBrightness(p, v, p2)
		end
	end

	if hasPulse(profile.Lights.Pulse, global) then
		stepLightBrightness(p, p2)
	end
end

return Shading