return table.freeze({
	read = function(data, p)
		local v = math.max(0, data.cooldown or 0)
		local fill = 1 - math.clamp(v / math.max(p.Cooldown, 0.01), 0, 1)

		if data.paused then
			return {
				fill = fill,
				label = "CATCH PAUSED",
				hint = "Waiting for the run",
				tone = "Muted"
			}
		end

		if data.active then
			if data.elapsed < data.duration then
				return {
					fill = fill,
					label = string.upper(data.variant or "Catch"),
					hint = "Catch in progress",
					tone = "Red"
				}
			end

			return {
				fill = fill,
				label = "RECOVERING",
				hint = "Catch recovery",
				tone = "Gold"
			}
		else
			if v > 0.02 then
				return {
					fill = fill,
					label = ("CATCH  ·  %.1fs"):format(v),
					hint = "Recharging",
					tone = "Blue"
				}
			end

			if data.grounded then
				return {
					fill = 1,
					label = "CATCH READY",
					hint = (data.variant or "Dive") .. "  ·  " .. (data.control or "Catch"),
					tone = "Mint",
					ready = true
				}
			end

			return {
				fill = 1,
				label = "CATCH",
				hint = "Land to catch",
				tone = "Muted"
			}
		end
	end
})