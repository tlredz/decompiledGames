local v = {}
local parent = script.Parent
require(parent.Types)

function v.Linear(p, p2, p3, p4)
	return p3 * p / p4 + p2
end

function v.Constant(p, _, _, p2)
	if p == p2 then
		return 1
	end

	return 0
end

function v.InSine(p, p2, p3, p4)
	return -p3 * math.cos(p / p4 * 1.5707963267948966) + p3 + p2
end

function v.OutSine(p, p2, p3, p4)
	return p3 * math.sin(p / p4 * 1.5707963267948966) + p2
end

function v.InOutSine(p, p2, p3, p4)
	return -p3 / 2 * (math.cos(3.141592653589793 * p / p4) - 1) + p2
end

function v.OutInSine(p, p2, p3, p4)
	if p < p4 / 2 then
		return v.OutSine(p * 2, p2, p3 / 2, p4)
	end

	return v.InSine(p * 2 - p4, p2 + p3 / 2, p3 / 2, p4)
end

function v.InQuad(p, p2, p3, p4)
	return p3 * math.pow(p / p4, 2) + p2
end

function v.OutQuad(p, p2, p3, p4)
	local v2 = p / p4
	return -p3 * v2 * (v2 - 2) + p2
end

function v.InOutQuad(p, p2, p3, p4)
	local v2 = p / p4 * 2

	if v2 < 1 then
		return p3 / 2 * math.pow(v2, 2) + p2
	end

	return -p3 / 2 * ((v2 - 1) * (v2 - 3) - 1) + p2
end

function v.OutInQuad(p, p2, p3, p4)
	if p < p4 / 2 then
		return v.OutQuad(p * 2, p2, p3 / 2, p4)
	end

	return v.InQuad(p * 2 - p4, p2 + p3 / 2, p3 / 2, p4)
end

function v.InCubic(p, p2, p3, p4)
	return p3 * math.pow(p / p4, 3) + p2
end

function v.OutCubic(p, p2, p3, p4)
	return p3 * (math.pow(p / p4 - 1, 3) + 1) + p2
end

function v.InOutCubic(p, p2, p3, p4)
	local v2 = p / p4 * 2

	if v2 < 1 then
		return p3 / 2 * v2 * v2 * v2 + p2
	end

	local v3 = v2 - 2
	return p3 / 2 * (v3 * v3 * v3 + 2) + p2
end

function v.OutInCubic(p, p2, p3, p4)
	if p < p4 / 2 then
		return v.OutCubic(p * 2, p2, p3 / 2, p4)
	end

	return v.InCubic(p * 2 - p4, p2 + p3 / 2, p3 / 2, p4)
end

function v.InQuart(p, p2, p3, p4)
	return p3 * math.pow(p / p4, 4) + p2
end

function v.OutQuart(p, p2, p3, p4)
	local v2 = p / p4 - 1
	return -p3 * (math.pow(v2, 4) - 1) + p2
end

function v.InOutQuart(p, p2, p3, p4)
	local v2 = p / p4 * 2

	if v2 < 1 then
		return p3 / 2 * math.pow(v2, 4) + p2
	end

	local v3 = v2 - 2
	return -p3 / 2 * (math.pow(v3, 4) - 2) + p2
end

function v.OutInQuart(p, p2, p3, p4)
	if p < p4 / 2 then
		return v.OutQuart(p * 2, p2, p3 / 2, p4)
	end

	return v.InQuart(p * 2 - p4, p2 + p3 / 2, p3 / 2, p4)
end

function v.InQuint(p, p2, p3, p4)
	return p3 * math.pow(p / p4, 5) + p2
end

function v.OutQuint(p, p2, p3, p4)
	return p3 * (math.pow(p / p4 - 1, 5) + 1) + p2
end

function v.InOutQuint(p, p2, p3, p4)
	local v2 = p / p4 * 2

	if v2 < 1 then
		return p3 / 2 * math.pow(v2, 5) + p2
	end

	local v3 = v2 - 2
	return p3 / 2 * (math.pow(v3, 5) + 2) + p2
end

function v.OutInQuint(p, p2, p3, p4)
	if p < p4 / 2 then
		return v.OutQuint(p * 2, p2, p3 / 2, p4)
	end

	return v.InQuint(p * 2 - p4, p2 + p3 / 2, p3 / 2, p4)
end

function v.InSextic(p, p2, p3, p4)
	return p3 * math.pow(p / p4, 6) + p2
end

function v.OutSextic(p, p2, p3, p4)
	local v2 = p / p4 - 1
	return -p3 * (math.pow(v2, 6) - 1) + p2
end

function v.InOutSextic(p, p2, p3, p4)
	local v2 = p / p4 * 2

	if v2 < 1 then
		return p3 / 2 * math.pow(v2, 6) + p2
	end

	local v3 = v2 - 2
	return -p3 / 2 * (math.pow(v3, 6) - 2) + p2
end

function v.OutInSextic(p, p2, p3, p4)
	if p < p4 / 2 then
		return v.OutSextic(p * 2, p2, p3 / 2, p4)
	end

	return v.InSextic(p * 2 - p4, p2 + p3 / 2, p3 / 2, p4)
end

function v.InExpo(p, p2, p3, p4)
	if p == 0 then
		return p2
	end

	return p3 * math.pow(2, 10 * (p / p4 - 1)) + p2 - p3 * 0.001
end

function v.OutExpo(p, p2, p3, p4)
	if p == p4 then
		return p2 + p3
	end

	return p3 * 1.001 * (-math.pow(2, -10 * p / p4) + 1) + p2
end

function v.InOutExpo(p, p2, p3, p4)
	if p == 0 then
		return p2
	end

	if p == p4 then
		return p2 + p3
	end

	local v2 = p / p4 * 2

	if v2 < 1 then
		return p3 / 2 * math.pow(2, 10 * (v2 - 1)) + p2 - p3 * 0.0005
	end

	local v3 = v2 - 1
	return p3 / 2 * 1.0005 * (-math.pow(2, -10 * v3) + 2) + p2
end

function v.OutInExpo(p, p2, p3, p4)
	if p < p4 / 2 then
		return v.OutExpo(p * 2, p2, p3 / 2, p4)
	end

	return v.InExpo(p * 2 - p4, p2 + p3 / 2, p3 / 2, p4)
end

function v.InCirc(p, p2, p3, p4)
	local v2 = p / p4
	return -p3 * (math.sqrt(1 - math.pow(v2, 2)) - 1) + p2
end

function v.OutCirc(p, p2, p3, p4)
	return p3 * math.sqrt(1 - math.pow(p / p4 - 1, 2)) + p2
end

function v.InOutCirc(p, p2, p3, p4)
	local v2 = p / p4 * 2

	if v2 < 1 then
		return -p3 / 2 * (math.sqrt(1 - v2 * v2) - 1) + p2
	end

	local v3 = v2 - 2
	return p3 / 2 * (math.sqrt(1 - v3 * v3) + 1) + p2
end

function v.OutInCirc(p, p2, p3, p4)
	if p < p4 / 2 then
		return v.OutCirc(p * 2, p2, p3 / 2, p4)
	end

	return v.InCirc(p * 2 - p4, p2 + p3 / 2, p3 / 2, p4)
end

function v.InBack(p, p2, p3, p4, value)
	local v2 = value or 1.70158
	local v3 = p / p4
	return p3 * v3 * v3 * ((v2 + 1) * v3 - v2) + p2
end

function v.OutBack(p, p2, p3, p4, value)
	local v2 = value or 1.70158
	local v3 = p / p4 - 1
	return p3 * (v3 * v3 * ((v2 + 1) * v3 + v2) + 1) + p2
end

function v.InOutBack(p, p2, p3, p4, value)
	local v2 = (value or 1.70158) * 1.525
	local v3 = p / p4 * 2

	if v3 < 1 then
		return p3 / 2 * (v3 * v3 * ((v2 + 1) * v3 - v2)) + p2
	end

	local v4 = v3 - 2
	return p3 / 2 * (v4 * v4 * ((v2 + 1) * v4 + v2) + 2) + p2
end

function v.OutInBack(p, p2, p3, p4, p5)
	if p < p4 / 2 then
		return v.OutBack(p * 2, p2, p3 / 2, p4, p5)
	end

	return v.InBack(p * 2 - p4, p2 + p3 / 2, p3 / 2, p4, p5)
end

function v.OutBounce(p, p2, p3, p4)
	local v2 = p / p4

	if v2 < 0.36363636363636365 then
		return p3 * (7.5625 * v2 * v2) + p2
	end

	if v2 < 0.7272727272727273 then
		local v3 = v2 - 0.5454545454545454
		return p3 * (7.5625 * v3 * v3 + 0.75) + p2
	end

	if v2 < 0.9090909090909091 then
		local v3 = v2 - 0.8181818181818182
		return p3 * (7.5625 * v3 * v3 + 0.9375) + p2
	end

	local v3 = v2 - 0.9545454545454546
	return p3 * (7.5625 * v3 * v3 + 0.984375) + p2
end

function v.InBounce(p, p2, p3, p4)
	return p3 - v.OutBounce(p4 - p, 0, p3, p4) + p2
end

function v.InOutBounce(p, p2, p3, p4)
	if p < p4 / 2 then
		return v.InBounce(p * 2, 0, p3, p4) * 0.5 + p2
	end

	return v.OutBounce(p * 2 - p4, 0, p3, p4) * 0.5 + p3 * 0.5 + p2
end

function v.OutInBounce(p, p2, p3, p4)
	if p < p4 / 2 then
		return v.OutBounce(p * 2, p2, p3 / 2, p4)
	end

	return v.InBounce(p * 2 - p4, p2 + p3 / 2, p3 / 2, p4)
end

function v.ElasticBlend(p, p2, p3, p4, p5, p6)
	if p2 == 0 then
		return p6
	end

	local v2 = math.abs(p5)
	p6 = p4 == 0 and 0 or p6 * (p4 / math.abs(p2))

	if math.abs(p * p3) < v2 then
		local v3 = math.abs(p * p3) / v2
		p6 = p6 * v3 + (1 - v3)
	end

	return p6
end

function v.InElastic(p, p2, p3, p4, p5, p6)
	local v2 = 1

	if p == 0 then
		return p2
	end

	local v3 = p / p4

	if v3 == 1 then
		return p2 + p3
	end

	local v4 = v3 - 1

	if not p6 or p6 == 0 then
		p6 = p4 * 0.3
	end

	local v5

	if p5 == nil or p5 < math.abs(p3) then
		v5 = p6 / 4
		v2 = v.ElasticBend(v4, p3, p4, p5, v5, v2)
		p5 = p3
	else
		v5 = p6 / 6.283185307179586 * math.asin(p3 / p5)
	end

	return -v2 * (p5 * math.pow(2, 10 * v4) * math.sin((v4 * p4 - v5) * 6.283185307179586 / p6)) + p2
end

function v.OutElastic(p, p2, p3, p4, p5, p6)
	local v2 = 1

	if p == 0 then
		return p2
	end

	local v3 = p / p4

	if v3 == 1 then
		return p2 + p3
	end

	local v4 = -v3

	if not p6 or p6 == 0 then
		p6 = p4 * 0.3
	end

	local v5

	if p5 == nil or p5 < math.abs(p3) then
		v5 = p6 / 4
		v2 = v.ElasticBlend(v4, p3, p4, p5, v5, v2)
		p5 = p3
	else
		v5 = p6 / 6.283185307179586 * math.asin(p3 / p5)
	end

	return v2 * (p5 * math.pow(2, 10 * v4) * math.sin((v4 * p4 - v5) * 6.283185307179586 / p6)) + p3 + p2
end

function v.InOutElastic(p, p2, p3, p4, p5, p6)
	local v2 = 1

	if p == 0 then
		return p2
	end

	local v3 = p / (p4 / 2)

	if v3 == 2 then
		return p2 + p3
	end

	local v4 = v3 - 1

	if not p6 or p6 == 0 then
		p6 = p4 * 0.44999999999999996
	end

	local v5

	if p5 == nil or p5 < math.abs(p3) then
		v5 = p6 / 4
		v2 = v.ElasticBlend(v4, p3, p4, p5, v5, v2)
		p5 = p3
	else
		v5 = p6 / 6.283185307179586 * math.asin(p3 / p5)
	end

	if v4 < 0 then
		return v2 * -0.5 * (p5 * math.pow(2, 10 * v4) * math.sin((v4 * p4 - v5) * 6.283185307179586 / p6)) + p2
	end

	local v6 = -v4
	return v2 * 0.5 * (p5 * math.pow(2, 10 * v6) * math.sin((v6 * p4 - v5) * 6.283185307179586 / p6)) + p3 + p2
end

function v.OutInElastic(p, p2, p3, p4, p5, p6)
	if p < p4 / 2 then
		return v.OutElastic(p * 2, p2, p3 / 2, p4, p5, p6)
	end

	return v.InElastic(p * 2 - p4, p2 + p3 / 2, p3 / 2, p4, p5, p6)
end

local HttpService = game:GetService("HttpService")
local v2 = {
	Type = "Linear",
	Params = {}
}
local v3 = {}
local get

get = function(p)
	local v4 = p or v2
	local jSONEncode = HttpService:JSONEncode(v4)

	if v3[jSONEncode] ~= nil then
		return v3[jSONEncode]
	end

	local params = v4.Params
	local type = v4.Type or "Linear"
	local direction = params.Direction or "In"
	local v5 = v[`{direction}{type}`] or v[type]

	if not v5 then
		return get(v2)
	end

	local amplitude = nil
	local period = nil

	if type == "Elastic" then
		amplitude = params.Amplitude or 1
		period = params.Period or 0.3
	elseif type == "Back" then
		amplitude = params.Overshoot or 1.70158
	end

	v3[jSONEncode] = function(p2)
		return v5(p2, 0, 1, 1, amplitude, period)
	end

	return v3[jSONEncode]
end

return {
	Get = get
}