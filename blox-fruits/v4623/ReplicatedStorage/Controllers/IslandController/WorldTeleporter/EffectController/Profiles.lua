local HttpService = game:GetService("HttpService")
local Audio = require(game.ReplicatedStorage.Audio)
local v = {
	RiseDamping = 0.45,
	RiseFrequency = 2.2,
	FallDamping = 1,
	FallFrequency = 2.5
}
local color = Color3.new(1, 1, 1)
local ambient = Audio.fx["world-teleporter"].vfx.ambient

function pulse(value: number?, value2: number?)
	return {
		Amplitude = value or 0,
		Period = value2 or 2
	}
end

function motion(value: number?, value2: number?, value3: number?, value4: number?)
	return {
		RiseDamping = value or 1,
		RiseFrequency = value2 or 1,
		FallDamping = value3 or 1,
		FallFrequency = value4 or 1
	}
end

function meshProfile()
	return {
		Opacity = 1,
		Height = 1,
		Tint = color,
		TintAlpha = 0,
		ScrollSpeed = 1,
		ScrollAngle = 0,
		SpinSpeed = 0,
		Pulse = pulse(),
		Motion = motion()
	}
end

function beamGroupProfile()
	return {
		Brightness = 1,
		Width = 1,
		Height = 1,
		Opacity = 1,
		TextureSpeed = 1,
		LightEmission = 1,
		Tint = color,
		TintAlpha = 0,
		Pulse = pulse(),
		Motion = motion()
	}
end

function particleGroupProfile()
	return {
		Rate = 1,
		Brightness = 1,
		Size = 1,
		Height = 1,
		Opacity = 1,
		Speed = 1,
		Lifetime = 1,
		TimeScale = 1,
		LightEmission = 1,
		Tint = color,
		TintAlpha = 0,
		Pulse = pulse(),
		Motion = motion()
	}
end

function ambientProfile(soundId: string?, volume: number?)
	return {
		SoundId = soundId,
		Volume = volume
	}
end

function buildDefault()
	return {
		Global = {
			Brightness = 1,
			Opacity = 1,
			Speed = 1,
			Height = 1,
			Tint = color,
			TintAlpha = 0,
			Pulse = pulse(),
			Motion = motion(1, 2, 1, 2)
		},
		Meshes = {
			FlareMesh = meshProfile(),
			BeamMesh = meshProfile(),
			Lines = meshProfile(),
			SideMesh = meshProfile()
		},
		Beams = {
			MainBeam = beamGroupProfile(),
			BeamColumns = beamGroupProfile()
		},
		Particles = {
			GroundRing = particleGroupProfile(),
			Flares = particleGroupProfile(),
			TopGlow = particleGroupProfile(),
			Smoke = particleGroupProfile(),
			Debris = particleGroupProfile()
		},
		Lights = {
			Brightness = 1,
			Range = 1,
			Tint = color,
			TintAlpha = 0,
			Pulse = pulse()
		},
		Ambient = ambientProfile()
	}
end

function deepCopy(items)
	if type(items) ~= "table" then
		return items
	end

	local copies = {}

	for k, item in items do
		copies[k] = deepCopy(item)
	end

	return copies
end

function formatNumber(p: number)
	local selected = string.format("%.3f", p)

	if selected:find("%.") then
		selected = selected:gsub("0+$", ""):gsub("%.$", "")
	end

	if selected == "-0" then
		return "0"
	end

	return selected
end

function sortedKeys(items)
	local result = {}

	for k in items do
		table.insert(result, k)
	end

	table.sort(result)
	return result
end

function toLuauValue(data, count: number)
	local typeName = typeof(data)

	if typeName == "Color3" then
		return (`Color3.fromRGB({math.round(data.R * 255)}, {math.round(data.G * 255)}, {math.round(data.B * 255)})`)
	elseif typeName == "number" then
		return formatNumber(data)
	elseif typeName == "string" then
		return string.format("%q", data)
	elseif typeName == "boolean" then
		return (tostring(data))
	end

	if typeName ~= "table" then
		error((`unsupported profile value type: {typeName}`))
		return
	end

	local v2 = ("\t"):rep(count + 1)
	local v3 = { "{" }

	for _, v4 in sortedKeys(data) do
		table.insert(v3, (`{v2}{v4} = {toLuauValue(data[v4], count + 1)},`))
	end

	table.insert(v3, (`{("\t"):rep(count)}}`))
	return table.concat(v3, "\n")
end

function encodeValue(p)
	local typeName = typeof(p)

	if typeName == "Color3" then
		return {
			__color = { p.R, p.G, p.B }
		}
	end

	if typeName ~= "table" then
		return p
	end

	local result = {}

	for k, v2 in p do
		result[k] = encodeValue(v2)
	end

	return result
end

function decodeValue(p)
	if type(p) ~= "table" then
		return p
	end

	local __color = p.__color

	if type(__color) == "table" then
		return Color3.new(__color[1], __color[2], __color[3])
	end

	local result = {}

	for k, v2 in p do
		result[k] = decodeValue(v2)
	end

	return result
end

function mergeInto(items, p)
	for k, item in items do
		local v2 = p[k]

		if v2 == nil then
			continue
		end

		if type(item) == "table" and typeof(v2) == "table" then
			mergeInto(item, v2)
		elseif typeof(v2) == typeof(item) then
			items[k] = v2
		end
	end
end

function mergeAmbient(p, p2)
	if type(p2) ~= "table" then
		return
	end

	if type(p2.SoundId) == "string" then
		p.SoundId = p2.SoundId
	end

	if type(p2.Volume) == "number" then
		p.Volume = p2.Volume
	end
end

local Profiles = {
	IDENTITY_MOTION = motion(),
	MESH_KEYS = {
		"FlareMesh",
		"BeamMesh",
		"Lines",
		"SideMesh"
	},
	BEAM_GROUP_KEYS = { "MainBeam", "BeamColumns" },
	PARTICLE_GROUP_KEYS = {
		"GroundRing",
		"Flares",
		"TopGlow",
		"Smoke",
		"Debris"
	},
	DEFAULT = buildDefault(),
	STATE_MOTION = v
}
local default = buildDefault()
default.Global.Motion = table.clone(v)
default.Ambient = ambientProfile(ambient["activated.ogg"], 0.8)
local default2 = buildDefault()
default2.Global.Motion = table.clone(v)
default2.Ambient = ambientProfile(ambient["deactivated.ogg"], 0.1)
default2.Global.Height = 0
default2.Beams.MainBeam.Opacity = 0
default2.Global.Brightness = 0.4
default2.Global.Opacity = 0.8
default2.Global.Speed = 0.6
default2.Lights.Brightness = 0.35
default2.Lights.Range = 0.8
default2.Particles.Flares.Opacity = 0
default2.Particles.GroundRing.Brightness = 0.4
default2.Particles.TopGlow.Opacity = 0
default2.Particles.Smoke.Opacity = 0
default2.Particles.Debris.Rate = 0
default2.Particles.Smoke.Rate = 0.5
local default3 = buildDefault()
default3.Global.Brightness = 1.5
default3.Global.Speed = 1.75
default3.Global.Tint = Color3.fromRGB(255, 205, 105)
default3.Global.TintAlpha = 0.35
default3.Global.Pulse = pulse(0.15, 1.6)
default3.Global.Motion = motion(0.45, 2.5, 1, 2.5)
default3.Lights.Brightness = 1.6
default3.Lights.Range = 1.3
default3.Beams.MainBeam.Width = 1.15
default3.Beams.MainBeam.Pulse = pulse(0.3, 0.8)
default3.Particles.Debris.Rate = 2
default3.Particles.Debris.Speed = 1.5
default3.Particles.GroundRing.Size = 1.1
default3.Meshes.Lines.ScrollSpeed = 2.5
default3.Meshes.BeamMesh.ScrollSpeed = 1.5
default3.Ambient = ambientProfile(ambient["activated.ogg"], 0.7)
Profiles.PRESETS = {
	Active = default,
	Dormant = default2,
	Overcharged = default3
}
Profiles.PRESET_ORDER = { "Active", "Dormant", "Overcharged" }

function Profiles.copy(p)
	return deepCopy(p)
end

function Profiles.toLuau(p)
	return toLuauValue(p, 0)
end

function Profiles.serialize(p)
	return HttpService:JSONEncode(encodeValue(p))
end

function Profiles.deserialize(json: string)
	local success, result = pcall(function()
		return decodeValue(HttpService:JSONDecode(json))
	end)

	if not success or type(result) ~= "table" then
		return nil
	end

	local default4 = buildDefault()
	mergeInto(default4, result)
	mergeAmbient(default4.Ambient, result.Ambient)
	return default4
end

return Profiles