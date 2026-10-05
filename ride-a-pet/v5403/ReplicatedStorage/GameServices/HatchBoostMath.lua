local DayNight = require(script.Parent.DayNight)
local HatchBoostMath = {
	Elapsed = function(p, p2, p3)
		return p3 and math.max(p2 - p, 0) or DayNight.GrowthElapsed(p, p2)
	end
}

function HatchBoostMath.Advance(p, p2, p3, p4)
	if p2 <= 0 then
		return p
	end

	if p4 then
		return p - p2
	end

	local v = HatchBoostMath.Elapsed(p, p3, false) + p2
	local v2 = p - p2

	for _ = 1, 40 do
		local midpoint = (v2 + p) / 2

		if v <= HatchBoostMath.Elapsed(midpoint, p3, false) then
			v2 = midpoint
		else
			p = midpoint
		end
	end

	return v2
end

return HatchBoostMath