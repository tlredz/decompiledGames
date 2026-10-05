local Color = require(script.Parent.Parent:WaitForChild("Color"))
local sqrt = math.sqrt
local pow = math.pow
local min = math.min
local max = math.max
local atan2 = math.atan2
local abs = math.abs
local cos = math.cos
local sin = math.sin
local exp = math.exp

local function deltaE(p, p2, p3: number?, p4: number?, p5: number?)
	local v = p3 == nil and 1 or p3
	local v2 = p4 == nil and 1 or p4
	local v3 = p5 == nil and 1 or p5

	local function rad2deg(p6: number)
		return p6 * 360 / 6.283185307179586
	end

	local function deg2rad(p6: number)
		return 6.283185307179586 * p6 / 360
	end

	local v4 = Color.new(p)
	local v5 = Color.new(p2)
	local lab = v4:lab()
	local lab2 = v5:lab()
	local v6 = lab[1]
	local v7 = lab[2]
	local v8 = lab[3]
	local v9 = lab2[1]
	local v10 = lab2[2]
	local v11 = lab2[3]
	local midpoint = (v6 + v9) / 2
	local midpoint2 = (sqrt(pow(v7, 2) + pow(v8, 2)) + sqrt(pow(v10, 2) + pow(v11, 2))) / 2
	local v18 = (1 - sqrt(pow(midpoint2, 7) / (pow(midpoint2, 7) + 6103515625))) * 0.5
	local v19 = v7 * (v18 + 1)
	local v20 = v10 * (v18 + 1)
	local v22 = sqrt(pow(v19, 2) + pow(v8, 2))
	local v24 = sqrt(pow(v20, 2) + pow(v11, 2))
	local midpoint3 = (v22 + v24) / 2
	local v26 = atan2(v8, v19) * 360 / 6.283185307179586
	local v27 = atan2(v11, v20) * 360 / 6.283185307179586

	if not (v26 >= 0) then
		v26 += 360
	end

	if not (v27 >= 0) then
		v27 += 360
	end

	local v29

	if abs(v26 - v27) > 180 then
		v29 = (v26 + v27 + 360) / 2
	else
		v29 = (v26 + v27) / 2
	end

	local v37 = 1 - cos(6.283185307179586 * (v29 - 30) / 360) * 0.17 + cos(6.283185307179586 * (v29 * 2) / 360) * 0.24 + cos(6.283185307179586 * (v29 * 3 + 6) / 360) * 0.32 - cos(6.283185307179586 * (v29 * 4 - 63) / 360) * 0.2
	local v38 = v27 - v26

	if not (abs(v38) <= 180) then
		if v27 <= v26 then
			v38 += 360
		else
			v38 -= 360
		end
	end

	local v42 = sqrt(v22 * v24) * 2 * sin(6.283185307179586 * v38 / 360 / 2)
	local v43 = v9 - v6
	local v44 = v24 - v22
	local v49 = pow(midpoint - 50, 2) * 0.015 / sqrt(pow(midpoint - 50, 2) + 20) + 1
	local v50 = midpoint3 * 0.045 + 1
	local v51 = midpoint3 * 0.015 * v37 + 1
	local v54 = exp(-pow((v29 - 275) / 25, 2)) * 30
	local v58 = -(sqrt(pow(midpoint3, 7) / (pow(midpoint3, 7) + 6103515625)) * 2) * sin(6.283185307179586 * v54 / 360 * 2)
	return (max(
		0,
		(min(
			100,
			(sqrt(pow(v43 / (v * v49), 2) + pow(v44 / (v2 * v50), 2) + pow(v42 / (v3 * v51), 2) + v58 * (v44 / (v2 * v50)) * (v42 / (v3 * v51))))
		))
	))
end

return deltaE