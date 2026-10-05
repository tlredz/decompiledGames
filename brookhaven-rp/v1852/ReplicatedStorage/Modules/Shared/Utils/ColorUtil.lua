local ColorUtil = {}

function ColorUtil.Color3ToRichText(color: Color3)
	return string.format("rgb(%d, %d, %d)", color.R * 255, color.G * 255, color.B * 255)
end

function ColorUtil.jsonColor3RGBtoColor3(data)
	return Color3.fromRGB(data.R, data.G, data.B)
end

function ColorUtil.color3ToJsonColor3(color: Color3)
	return {
		R = math.round(color.R * 255),
		G = math.round(color.G * 255),
		B = math.round(color.B * 255)
	}
end

function ColorUtil.darkenColor3(color: Color3, p: number)
	return Color3.new(color.R * p, color.G * p, color.B * p)
end

function ColorUtil.color3ToHSV(color: Color3)
	local R = color.R
	local G = color.G
	local B = color.B
	local v = 0
	local v2 = math.max(R, G, B)
	local v3 = math.min(R, G, B)
	local v4 = v2 - v3
	local v5

	if v2 == v3 then
		v5 = 0
	else
		local v6

		if v2 == R then
			v6 = (G - B) / v4

			if G < B then
				v6 += 6
			end
		elseif v2 == G then
			v6 = (B - R) / v4 + 2
		else
			v6 = (R - G) / v4 + 4
		end

		v5 = v6 / 6
	end

	if v4 > 0.001 then
		v = v4 / v2
	end

	return v5, v, v2
end

function ColorUtil.getRandomComplimentaryColor(color: Color3)
	local HSV, _, _ = color:ToHSV()
	local random = Random.new(tick())
	local v = (HSV + 0.5) % 1
	local v2 = random:NextInteger(0, 100) / 100
	local v3 = random:NextInteger(0, 100) / 100
	return (Color3.fromHSV(v, v2, v3))
end

function ColorUtil.ensureBrightVibrantColor(color: Color3)
	local HSV, v, v2 = color:ToHSV()
	local v3 = v2 < 0.7 and 0.7 or v2
	local v4 = v < 0.7 and 0.7 or v
	return (Color3.fromHSV(HSV, v4, v3))
end

return ColorUtil