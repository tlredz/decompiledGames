local Utils = {}

function Utils.UTCEpoch(year: number, month: number, day: number, value: number?, value2: number?, value3: number?)
	return os.time({
		year = year,
		month = month,
		day = day,
		hour = value or 0,
		min = value2 or 0,
		sec = value3 or 0,
		isdst = false
	})
end

function Utils.SetParticlesVisibility(object, enabled)
	for _, v in object:QueryDescendants("Beam, ParticleEmitter, Trail") do
		v.Enabled = enabled
	end
end

return Utils