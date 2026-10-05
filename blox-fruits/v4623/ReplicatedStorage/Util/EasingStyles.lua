local EasingStyles = {
	InLinear = function(p: number)
		return p
	end,
	OutLinear = function(p: number)
		return p
	end,
	InOutLinear = function(p: number)
		return p
	end,
	InQuad = function(p: number)
		return p * p
	end,
	OutQuad = function(p: number)
		return 1 - (1 - p) * (1 - p)
	end,
	InOutQuad = function(p: number)
		return p < 0.5 and p * 2 * p or 1 - math.pow(p * -2 + 2, 2) / 2
	end,
	InCubic = function(p: number)
		return (math.pow(p, 3))
	end,
	OutCubic = function(p: number)
		return 1 - math.pow(1 - p, 3)
	end,
	InOutCubic = function(p: number)
		return p < 0.5 and math.pow(p, 3) * 4 or 1 - math.pow(p * -2 + 2, 3) / 2
	end,
	InQuart = function(p: number)
		return (math.pow(p, 4))
	end,
	OutQuart = function(p: number)
		return 1 - math.pow(1 - p, 4)
	end,
	InOutQuart = function(p: number)
		return p < 0.5 and math.pow(p, 4) * 8 or 1 - math.pow(p * -2 + 2, 4) / 2
	end,
	InQuint = function(p: number)
		return (math.pow(p, 5))
	end,
	OutQuint = function(p: number)
		return 1 - math.pow(1 - p, 5)
	end,
	InOutQuint = function(p: number)
		return p < 0.5 and math.pow(p, 5) * 16 or 1 - math.pow(p * -2 + 2, 5) / 2
	end,
	InHexic = function(p: number)
		return (math.pow(p, 6))
	end,
	OutHexic = function(p: number)
		return 1 - math.pow(1 - p, 6)
	end,
	InOutHexic = function(p: number)
		return p < 0.5 and math.pow(p, 6) * 32 or 1 - math.pow(p * -2 + 2, 6) / 2
	end,
	InSeptic = function(p: number)
		return (math.pow(p, 7))
	end,
	OutSeptic = function(p: number)
		return 1 - math.pow(1 - p, 7)
	end,
	InOutSeptic = function(p: number)
		return p < 0.5 and math.pow(p, 7) * 64 or 1 - math.pow(p * -2 + 2, 7) / 2
	end,
	InOctic = function(p: number)
		return (math.pow(p, 8))
	end,
	OutOctic = function(p: number)
		return 1 - math.pow(1 - p, 8)
	end,
	InOutOctic = function(p: number)
		return p < 0.5 and math.pow(p, 8) * 128 or 1 - math.pow(p * -2 + 2, 8) / 2
	end,
	InCirc = function(p: number)
		return 1 - math.sqrt(1 - math.pow(p, 2))
	end,
	OutCirc = function(p: number)
		return (math.sqrt(1 - math.pow(p - 1, 2)))
	end,
	InOutCirc = function(p: number)
		return p < 0.5 and (1 - math.sqrt(1 - math.pow(p * 2, 2))) / 2 or (math.sqrt(1 - math.pow(p * -2 + 2, 2)) + 1) / 2
	end,
	InExponential = function(p: number)
		if p == 0 then
			return 0
		end

		return (math.pow(2, p * 10 - 10))
	end,
	OutExponential = function(p: number)
		if p == 1 then
			return 1
		end

		return 1 - math.pow(2, p * -10)
	end,
	InOutExponential = function(p: number)
		if p == 0 then
			return 0
		elseif p == 1 then
			return 1
		end

		return p < 0.5 and math.pow(2, p * 20 - 10) / 2 or (2 - math.pow(2, p * -20 + 10)) / 2
	end,
	InSine = function(p: number)
		return 1 - math.cos(p * 3.141592653589793 / 2)
	end,
	OutSine = function(p: number)
		return (math.sin(p * 3.141592653589793 / 2))
	end,
	InOutSine = function(p: number)
		return -(math.cos(3.141592653589793 * p) - 1) / 2
	end,
	InBack = function(p: number)
		return math.pow(p, 3) * 2.70158 - math.pow(p, 2) * 1.70158
	end,
	OutBack = function(p: number)
		return math.pow(p - 1, 3) * 2.70158 + 1 + math.pow(p - 1, 2) * 1.70158
	end,
	InOutBack = function(p: number)
		return p < 0.5 and math.pow(p * 2, 2) * (p * 7.189819 - 2.5949095) / 2 or (math.pow(p * 2 - 2, 2) * ((p * 2 - 2) * 3.5949095 + 2.5949095) + 2) / 2
	end
}

function EasingStyles.InBounce(p: number)
	return 1 - EasingStyles.OutBounce(1 - p)
end

function EasingStyles.OutBounce(p: number)
	if p < 0.36363636363636365 then
		return math.pow(p, 2) * 7.5625
	end

	if p < 0.7272727272727273 then
		return math.pow(p - 0.5454545454545454, 2) * 7.5625 + 0.75
	end

	if p < 0.9090909090909091 then
		return math.pow(p - 0.8181818181818182, 2) * 7.5625 + 0.9375
	end

	return math.pow(p - 0.9545454545454546, 2) * 7.5625 + 0.984375
end

function EasingStyles.InOutBounce(p: number)
	return p < 0.5 and (1 - EasingStyles.OutBounce(1 - p * 2)) / 2 or (1 + EasingStyles.OutBounce(p * 2 - 1)) / 2
end

function EasingStyles.InElastic(p: number)
	if p == 0 then
		return 0
	elseif p == 1 then
		return 1
	end

	return -math.pow(2, p * 10 - 10) * math.sin((p * 10 - 10.75) * 2.0943951023931953)
end

function EasingStyles.OutElastic(p: number)
	if p == 0 then
		return 0
	elseif p == 1 then
		return 1
	end

	return math.pow(2, p * -10) * math.sin((p * 10 - 0.75) * 2.0943951023931953) + 1
end

function EasingStyles.InOutElastic(p: number)
	if p == 0 then
		return 0
	elseif p == 1 then
		return 1
	end

	return p < 0.5 and -(math.pow(2, p * 20 - 10) * math.sin((p * 20 - 11.125) * 1.3962634015954636)) / 2 or math.pow(
		2,
		p * -20 + 10
	) * math.sin((p * 20 - 11.125) * 1.3962634015954636) / 2 + 1
end

return EasingStyles