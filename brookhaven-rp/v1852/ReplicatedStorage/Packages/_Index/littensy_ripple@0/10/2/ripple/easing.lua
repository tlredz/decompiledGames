local Easing = {}

function Easing.linear(p: number)
	return p
end

function Easing.instant(p: number)
	if p == 0 then
		return 0
	end

	return 1
end

function Easing.smoothstep(p: number)
	return p * p * (3 - p * 2)
end

function Easing.quadIn(p: number)
	return p * p
end

function Easing.quadOut(p: number)
	return 1 - (1 - p) * (1 - p)
end

function Easing.quadInOut(p: number)
	if p < 0.5 then
		return p * 2 * p
	end

	return 1 - (p * -2 + 2) ^ 2 / 2
end

function Easing.cubicIn(p: number)
	return p * p * p
end

function Easing.cubicOut(p: number)
	return 1 - (1 - p) ^ 3
end

function Easing.cubicInOut(p: number)
	if p < 0.5 then
		return p * 4 * p * p
	end

	return 1 - (p * -2 + 2) ^ 3 / 2
end

function Easing.quartIn(p: number)
	return p * p * p * p
end

function Easing.quartOut(p: number)
	return 1 - (1 - p) ^ 4
end

function Easing.quartInOut(p: number)
	if p < 0.5 then
		return p * 8 * p * p * p
	end

	return 1 - (p * -2 + 2) ^ 4 / 2
end

function Easing.quintIn(p: number)
	return p * p * p * p * p
end

function Easing.quintOut(p: number)
	return 1 - (1 - p) ^ 5
end

function Easing.quintInOut(p: number)
	if p < 0.5 then
		return p * 16 * p * p * p * p
	end

	return 1 - (p * -2 + 2) ^ 5 / 2
end

function Easing.sineIn(p: number)
	return 1 - math.cos(p * 3.141592653589793 / 2)
end

function Easing.sineOut(p: number)
	return (math.sin(p * 3.141592653589793 / 2))
end

function Easing.sineInOut(p: number)
	return -(math.cos(3.141592653589793 * p) - 1) / 2
end

function Easing.expoIn(p: number)
	if p == 0 then
		return 0
	end

	return 2 ^ (p * 10 - 10)
end

function Easing.expoOut(p: number)
	if p == 1 then
		return 1
	end

	return 1 - 2 ^ (p * -10)
end

function Easing.expoInOut(p: number)
	if p == 0 then
		return 0
	elseif p == 1 then
		return 1
	end

	if p < 0.5 then
		return 2 ^ (p * 20 - 10) / 2
	end

	return (2 - 2 ^ (p * -20 + 10)) / 2
end

function Easing.circIn(p: number)
	return 1 - (1 - p ^ 2) ^ 0.5
end

function Easing.circOut(p: number)
	return (1 - (p - 1) ^ 2) ^ 0.5
end

function Easing.circInOut(p: number)
	if p < 0.5 then
		return (1 - (1 - (p * 2) ^ 2) ^ 0.5) / 2
	end

	return ((1 - (p * -2 + 2) ^ 2) ^ 0.5 + 1) / 2
end

function Easing.backIn(p: number)
	return p * 2.70158 * p * p - p * 1.70158 * p
end

function Easing.backOut(p: number)
	return (p - 1) ^ 3 * 2.70158 + 1 + (p - 1) ^ 2 * 1.70158
end

function Easing.backInOut(p: number)
	if p < 0.5 then
		return (p * 2) ^ 2 * (p * 7.189819 - 2.5949095) / 2
	end

	return ((p * 2 - 2) ^ 2 * ((p * 2 - 2) * 3.5949095 + 2.5949095) + 2) / 2
end

function Easing.elasticIn(p: number)
	if p == 0 then
		return 0
	elseif p == 1 then
		return 1
	end

	return -2 ^ (p * 10 - 10) * math.sin((p * 10 - 10.75) * 2.0943951023931953)
end

function Easing.elasticOut(p: number)
	if p == 0 then
		return 0
	elseif p == 1 then
		return 1
	end

	return 2 ^ (p * -10) * math.sin((p * 10 - 0.75) * 2.0943951023931953) + 1
end

function Easing.elasticInOut(p: number)
	if p == 0 then
		return 0
	elseif p == 1 then
		return 1
	end

	if p < 0.5 then
		return -(2 ^ (p * 20 - 10) * math.sin((p * 20 - 11.125) * 1.3962634015954636)) / 2
	end

	return 2 ^ (p * -20 + 10) * math.sin((p * 20 - 11.125) * 1.3962634015954636) / 2 + 1
end

function Easing.bounceIn(p: number)
	local v = 1 - p
	local v2

	if v < 0.36363636363636365 then
		v2 = v * 7.5625 * v
	elseif v < 0.7272727272727273 then
		local v3 = v - 0.5454545454545454
		v2 = v3 * 7.5625 * v3 + 0.75
	elseif v < 0.9090909090909091 then
		local v3 = v - 0.8181818181818182
		v2 = v3 * 7.5625 * v3 + 0.9375
	else
		local v3 = v - 0.9545454545454546
		v2 = v3 * 7.5625 * v3 + 0.984375
	end

	return 1 - v2
end

function Easing.bounceOut(p: number)
	if p < 0.36363636363636365 then
		return p * 7.5625 * p
	end

	if p < 0.7272727272727273 then
		local v = p - 0.5454545454545454
		return v * 7.5625 * v + 0.75
	end

	if p < 0.9090909090909091 then
		local v = p - 0.8181818181818182
		return v * 7.5625 * v + 0.9375
	end

	local v = p - 0.9545454545454546
	return v * 7.5625 * v + 0.984375
end

function Easing.bounceInOut(p: number)
	if p < 0.5 then
		local v = 1 - p * 2
		local v2

		if v < 0.36363636363636365 then
			v2 = v * 7.5625 * v
		elseif v < 0.7272727272727273 then
			local v3 = v - 0.5454545454545454
			v2 = v3 * 7.5625 * v3 + 0.75
		elseif v < 0.9090909090909091 then
			local v3 = v - 0.8181818181818182
			v2 = v3 * 7.5625 * v3 + 0.9375
		else
			local v3 = v - 0.9545454545454546
			v2 = v3 * 7.5625 * v3 + 0.984375
		end

		return (1 - v2) / 2
	else
		local v = p * 2 - 1
		local v2

		if v < 0.36363636363636365 then
			v2 = v * 7.5625 * v
		elseif v < 0.7272727272727273 then
			local v3 = v - 0.5454545454545454
			v2 = v3 * 7.5625 * v3 + 0.75
		elseif v < 0.9090909090909091 then
			local v3 = v - 0.8181818181818182
			v2 = v3 * 7.5625 * v3 + 0.9375
		else
			local v3 = v - 0.9545454545454546
			v2 = v3 * 7.5625 * v3 + 0.984375
		end

		return (v2 + 1) / 2
	end
end

return Easing