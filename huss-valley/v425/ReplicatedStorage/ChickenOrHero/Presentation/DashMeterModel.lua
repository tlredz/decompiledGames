return {
	read = function(data, p)
		local v = math.max(0, data.cooldown or 0)
		local fill = 1 - math.clamp(v / math.max(p.Dash.Cooldown, 0.01), 0, 1)

		if not p.Dash.Enabled then
			return {
				fill = 0,
				label = "DASH OFF",
				hint = "Disabled",
				tone = "Muted"
			}
		end

		if data.paused then
			return {
				fill = fill,
				label = "DASH PAUSED",
				hint = "Waiting for movement",
				tone = "Muted"
			}
		end

		if data.boosting then
			return {
				fill = fill,
				label = "DASHING",
				hint = "Speed burst",
				tone = "Mint"
			}
		end

		if (data.recovery or 0) > 0 then
			return {
				fill = fill,
				label = "RECOVERING",
				hint = "Brief speed slowdown",
				tone = "Gold"
			}
		end

		if v > 0.02 then
			return {
				fill = fill,
				label = ("%s  ·  %.1fs"):format("DASH", v),
				hint = "Recharging",
				tone = "Blue"
			}
		end

		if not data.grounded then
			return {
				fill = 1,
				label = "DASH",
				hint = "Land to dash",
				tone = "Muted"
			}
		end

		if (data.speed or 0) <= p.StopThreshold then
			return {
				fill = 1,
				label = "DASH READY",
				hint = "Move, then turn + dash",
				tone = "Muted"
			}
		end

		return {
			fill = 1,
			label = "DASH READY",
			hint = "Turn + press to dodge",
			tone = "Mint",
			ready = true
		}
	end
}