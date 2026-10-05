local LuvUtils = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function distance_line_from_origin(get_bound)
	return math.abs(get_bound.intercept) / math.sqrt(get_bound.slope * get_bound.slope + 1)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function length_of_ray_until_intersect(p: number, get_bound)
	return get_bound.intercept / (math.sin(p) - get_bound.slope * math.cos(p))
end

function LuvUtils.get_bounds(p: number)
	local result = {}
	local v = (p + 16) ^ 3 / 1560896

	if not (LuvUtils.epsilon < v) then
		v = p / LuvUtils.kappa
	end

	for i = 1, 3 do
		local v2 = LuvUtils.m[i][1]
		local v3 = LuvUtils.m[i][2]
		local v4 = LuvUtils.m[i][3]

		for i2 = 0, 1 do
			local v5 = (284517 * v2 - 94839 * v4) * v
			local v6 = (838422 * v4 + 769860 * v3 + 731718 * v2) * p * v - i2 * 769860 * p
			local v7 = (632260 * v4 - 126452 * v3) * v + i2 * 126452
			table.insert(result, {
				slope = v5 / v7,
				intercept = v6 / v7
			})
		end
	end

	return result
end

function LuvUtils.max_safe_chroma_for_l(p: number)
	local get_bounds = LuvUtils.get_bounds(p)
	local v = 1.7976931348623157e308

	for i = 1, 6 do
		local v2 = distance_line_from_origin(get_bounds[i]) -- equivalent call inferred; original call site unknown

		if v2 >= 0 then
			v = math.min(v, v2)
		end
	end

	return v
end

function LuvUtils.max_safe_chroma_for_lh(p, p2: number)
	local v = p2 / 360 * 3.141592653589793 * 2
	local get_bounds = LuvUtils.get_bounds(p)
	local v2 = 1.7976931348623157e308

	for i = 1, 6 do
		local v3 = length_of_ray_until_intersect(v, get_bounds[i]) -- equivalent call inferred; original call site unknown

		if v3 >= 0 then
			v2 = math.min(v2, v3)
		end
	end

	return v2
end

function LuvUtils.dot_product(list, list2)
	return 0 + list[1] * list2[1] + list[2] * list2[2] + list[3] * list2[3]
end

function LuvUtils.from_linear(p: number)
	if p <= 0.0031308 then
		return p * 12.92
	end

	return p ^ 0.4166666666666667 * 1.055 - 0.055
end

function LuvUtils.to_linear(p: number)
	if p > 0.04045 then
		return ((p + 0.055) / 1.055) ^ 2.4
	end

	return p / 12.92
end

function LuvUtils.xyz_to_rgb(p)
	return {
		LuvUtils.from_linear(LuvUtils.dot_product(LuvUtils.m[1], p)),
		LuvUtils.from_linear(LuvUtils.dot_product(LuvUtils.m[2], p)),
		LuvUtils.from_linear(LuvUtils.dot_product(LuvUtils.m[3], p))
	}
end

function LuvUtils.rgb_to_xyz(list)
	local v = { LuvUtils.to_linear(list[1]), LuvUtils.to_linear(list[2]), LuvUtils.to_linear(list[3]) }
	return {
		LuvUtils.dot_product(LuvUtils.minv[1], v),
		LuvUtils.dot_product(LuvUtils.minv[2], v),
		LuvUtils.dot_product(LuvUtils.minv[3], v)
	}
end

function LuvUtils.y_to_l(p: number)
	if p <= LuvUtils.epsilon then
		return p / LuvUtils.refY * LuvUtils.kappa
	end

	return 116 * (p / LuvUtils.refY) ^ 0.3333333333333333 - 16
end

function LuvUtils.l_to_y(p: number)
	if p <= 8 then
		return LuvUtils.refY * p / LuvUtils.kappa
	end

	return LuvUtils.refY * ((p + 16) / 116) ^ 3
end

function LuvUtils.xyz_to_luv(list)
	local v = list[1]
	local v2 = list[2]
	local v3 = v + v2 * 15 + list[3] * 3
	local v4 = v * 4
	local v5 = v2 * 9
	local v6, v7

	if v3 == 0 then
		v6 = 0
		v7 = 0
	else
		v6 = v4 / v3
		v7 = v5 / v3
	end

	local y_to_l = LuvUtils.y_to_l(v2)

	if y_to_l == 0 then
		return { 0, 0, 0 }
	end

	return { y_to_l, 13 * y_to_l * (v6 - LuvUtils.refU), 13 * y_to_l * (v7 - LuvUtils.refV) }
end

function LuvUtils.luv_to_xyz(list)
	local v = list[1]
	local v2 = list[2]
	local v3 = list[3]

	if v == 0 then
		return { 0, 0, 0 }
	end

	local v4 = v2 / (v * 13) + LuvUtils.refU
	local v5 = v3 / (v * 13) + LuvUtils.refV
	local l_to_y = LuvUtils.l_to_y(v)
	local v6 = 0 - 9 * l_to_y * v4 / ((v4 - 4) * v5 - v4 * v5)
	return { v6, l_to_y, (9 * l_to_y - 15 * v5 * l_to_y - v5 * v6) / (3 * v5) }
end

function LuvUtils.luv_to_lch(list)
	local v = list[1]
	local v2 = list[2]
	local v3 = list[3]
	local v4 = math.sqrt(v2 * v2 + v3 * v3)
	local v5

	if v4 < 1e-8 then
		v5 = 0
	else
		v5 = math.atan2(v3, v2) * 180 / 3.141592653589793

		if v5 < 0 then
			v5 = 360 + v5
		end
	end

	return { v, v4, v5 }
end

function LuvUtils.lch_to_luv(list)
	local v = list[1]
	local v2 = list[2]
	local v3 = list[3] / 360 * 2 * 3.141592653589793
	return { v, math.cos(v3) * v2, math.sin(v3) * v2 }
end

function LuvUtils.hsluv_to_lch(list)
	local v = list[1]
	local v2 = list[2]
	local v3 = list[3]

	if v3 > 99.9999999 then
		return { 100, 0, v }
	end

	if v3 < 1e-8 then
		return { 0, 0, v }
	end

	return { v3, LuvUtils.max_safe_chroma_for_lh(v3, v) / 100 * v2, v }
end

function LuvUtils.lch_to_hsluv(list)
	local v = list[1]
	local v2 = list[2]
	local v3 = list[3]
	local max_safe_chroma_for_lh = LuvUtils.max_safe_chroma_for_lh(v, v3)

	if v > 99.9999999 then
		return { v3, 0, 100 }
	end

	if v < 1e-8 then
		return { v3, 0, 0 }
	end

	return { v3, v2 / max_safe_chroma_for_lh * 100, v }
end

function LuvUtils.hpluv_to_lch(list)
	local v = list[1]
	local v2 = list[2]
	local v3 = list[3]

	if v3 > 99.9999999 then
		return { 100, 0, v }
	end

	if v3 < 1e-8 then
		return { 0, 0, v }
	end

	return { v3, LuvUtils.max_safe_chroma_for_l(v3) / 100 * v2, v }
end

function LuvUtils.lch_to_hpluv(list)
	local v = list[1]
	local v2 = list[2]
	local v3 = list[3]

	if v > 99.9999999 then
		return { v3, 0, 100 }
	end

	if v < 1e-8 then
		return { v3, 0, 0 }
	end

	return { v3, v2 / LuvUtils.max_safe_chroma_for_l(v) * 100, v }
end

function LuvUtils.rgb_to_hex(list)
	local v = "#"

	for i = 1, 3 do
		local v2 = math.floor(list[i] * 255 + 0.5)
		local v3 = math.fmod(v2, 16)
		local v4 = math.floor((v2 - v3) / 16)
		v = (v .. string.sub("0123456789abcdef", v4 + 1, v4 + 1)) .. string.sub("0123456789abcdef", v3 + 1, v3 + 1)
	end

	return v
end

function LuvUtils.hex_to_rgb(value: string)
	local v = string.lower(value)
	local result = {}

	for i = 0, 2 do
		local v2 = string.sub(v, i * 2 + 2, i * 2 + 2)
		local v3 = string.sub(v, i * 2 + 3, i * 2 + 3)
		local v4 = string.find("0123456789abcdef", v2) - 1
		local v5 = string.find("0123456789abcdef", v3) - 1
		result[i + 1] = (v4 * 16 + v5) / 255
	end

	return result
end

function LuvUtils.lch_to_rgb(p)
	return LuvUtils.xyz_to_rgb(LuvUtils.luv_to_xyz(LuvUtils.lch_to_luv(p)))
end

function LuvUtils.rgb_to_lch(p)
	return LuvUtils.luv_to_lch(LuvUtils.xyz_to_luv(LuvUtils.rgb_to_xyz(p)))
end

function LuvUtils.hsluv_to_rgb(p)
	return LuvUtils.lch_to_rgb(LuvUtils.hsluv_to_lch(p))
end

function LuvUtils.rgb_to_hsluv(p)
	return LuvUtils.lch_to_hsluv(LuvUtils.rgb_to_lch(p))
end

function LuvUtils.hpluv_to_rgb(p)
	return LuvUtils.lch_to_rgb(LuvUtils.hpluv_to_lch(p))
end

function LuvUtils.rgb_to_hpluv(p)
	return LuvUtils.lch_to_hpluv(LuvUtils.rgb_to_lch(p))
end

function LuvUtils.hsluv_to_hex(p)
	return LuvUtils.rgb_to_hex(LuvUtils.hsluv_to_rgb(p))
end

function LuvUtils.hpluv_to_hex(p)
	return LuvUtils.rgb_to_hex(LuvUtils.hpluv_to_rgb(p))
end

function LuvUtils.hex_to_hsluv(p: string)
	return LuvUtils.rgb_to_hsluv(LuvUtils.hex_to_rgb(p))
end

function LuvUtils.hex_to_hpluv(p: string)
	return LuvUtils.rgb_to_hpluv(LuvUtils.hex_to_rgb(p))
end

LuvUtils.m = {
	{ 3.240969941904521, -1.537383177570093, -0.498610760293 },
	{ -0.96924363628087, 1.87596750150772, 0.041555057407175 },
	{ 0.055630079696993, -0.20397695888897, 1.056971514242878 }
}
LuvUtils.minv = {
	{ 0.41239079926595, 0.35758433938387, 0.18048078840183 },
	{ 0.21263900587151, 0.71516867876775, 0.072192315360733 },
	{ 0.019330818715591, 0.11919477979462, 0.95053215224966 }
}
LuvUtils.refY = 1
LuvUtils.refU = 0.19783000664283
LuvUtils.refV = 0.46831999493879
LuvUtils.kappa = 903.2962962
LuvUtils.epsilon = 0.0088564516
return LuvUtils