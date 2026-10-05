return table.freeze({
	sample = function(p, data, data2)
		if p < data.Windup then
			return "Windup", math.max(0, p) * data2.WindupRate, data2.WindupRate
		end

		local v = p - data.Windup
		local stabContactStart = data2.StabContactStart
		local stabContactEnd = data2.StabContactEnd

		if v < data.ActiveDuration then
			local v2 = (stabContactEnd - stabContactStart) / data.ActiveDuration
			return "Active", stabContactStart + math.max(0, v) * v2, v2
		end

		local v2 = v - data.ActiveDuration

		if v2 < data.Recovery then
			local v3 = (data2.StabDuration - stabContactEnd) / data.Recovery
			return "Recovery", stabContactEnd + math.max(0, v2) * v3, v3
		else
			return "Complete", data2.StabDuration, 0
		end
	end
})