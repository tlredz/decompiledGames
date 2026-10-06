function easeIn(p, callback)
	return callback(p)
end

function easeOut(p, callback)
	return 1 - callback(1 - p)
end

function easeInOut(p, p2)
	local v = p * 2

	if v < 1 then
		return easeIn(v, p2) * 0.5
	end

	return 0.5 + easeOut(v - 1, p2) * 0.5
end

function bounce(p)
	if p < 0.36363636 then
		return 7.5625 * p * p
	end

	if p < 0.72727272 then
		local v = p - 0.54545454
		return 7.5625 * v * v + 0.75
	end

	if p < 0.9090909 then
		local v = p - 0.81818181
		return 7.5625 * v * v + 0.9375
	end

	local v = p - 0.95454545
	return 7.5625 * v * v + 0.984375
end

function cubic(p)
	return p ^ 3
end

return {
	GetEasing = function(p, p2, p3)
		if p == "Bounce" then
			if p2 == "Out" then
				return 1 - easeOut(p3, bounce)
			elseif p2 == "In" then
				return 1 - bounce(p3)
			end

			return 1 - easeInOut(p3, bounce)
		elseif p == "Elastic" then
			if p2 == "Out" then
				local v = 1 - p3
				return 1 + 2 ^ (-10 * v) * math.sin((v * 1 - 0.075) * 6.283185307179586 / 0.3)
			elseif p2 == "In" then
				return 1 - (1 + 2 ^ (-10 * p3) * math.sin((p3 * 1 - 0.075) * 6.283185307179586 / 0.3))
			elseif p2 == "InOut" then
				local v = p3 * 2

				if v < 1 then
					local v2 = v - 1
					return 1 - -0.5 * 2 ^ (10 * v2) * math.sin((v2 - 0.11249999999999999) * 6.283185307179586 / 0.44999999999999996)
				end

				local v2 = v - 1
				return 1 - (1 + 0.5 * 2 ^ (-10 * v2) * math.sin((v2 - 0.11249999999999999) * 6.283185307179586 / 0.44999999999999996))
			end
		elseif p == "Cubic" or p == "CubicV2" then
			if p2 == "Out" then
				return 1 - easeOut(p3, cubic)
			elseif p2 == "In" then
				return 1 - cubic(p3)
			elseif p2 == "InOut" then
				return 1 - easeInOut(p3, cubic)
			end
		else
			if p == "Linear" then
				return 1 - p3
			end

			if p == "Constant" then
				if "Constant" == "Out" then
					return 1
				end

				if p == "In" then
					return 0
				elseif p == "InOut" then
					return 0.5
				end
			end
		end
	end
}